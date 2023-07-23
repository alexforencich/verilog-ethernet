#!/usr/bin/env python
"""

Copyright (c) 2023 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

import logging
import os
import struct

from scapy.layers.l2 import Ether
from scapy.utils import mac2str

import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.utils import get_sim_time

from cocotbext.axi.stream import define_stream


McfBus, McfTransaction, McfSource, McfSink, McfMonitor = define_stream("Mcf",
    signals=["valid", "eth_dst", "eth_src", "eth_type", "opcode", "params"],
    optional_signals=["ready", "id", "dest", "user"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        self.mcf_source = McfSource(McfBus.from_prefix(dut, "mcf"), dut.clk, dut.rst)

        dut.rx_lfc_en.setimmediatevalue(0)
        dut.rx_lfc_ack.setimmediatevalue(0)

        dut.rx_pfc_en.setimmediatevalue(0)
        dut.rx_pfc_ack.setimmediatevalue(0)

        dut.cfg_rx_lfc_opcode.setimmediatevalue(0)
        dut.cfg_rx_lfc_en.setimmediatevalue(0)
        dut.cfg_rx_pfc_opcode.setimmediatevalue(0)
        dut.cfg_rx_pfc_en.setimmediatevalue(0)
        dut.cfg_quanta_step.setimmediatevalue(256)
        dut.cfg_quanta_clk_en.setimmediatevalue(1)

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

    async def send_mcf(self, pkt):
        mcf = McfTransaction()
        mcf.eth_dst = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
        mcf.eth_src = int.from_bytes(mac2str(pkt[Ether].src), 'big')
        mcf.eth_type = pkt[Ether].type
        mcf.opcode = int.from_bytes(bytes(pkt[Ether].payload)[0:2], 'big')
        mcf.params = int.from_bytes(bytes(pkt[Ether].payload)[2:], 'little')

        await self.mcf_source.send(mcf)


async def run_test_lfc(dut):

    tb = TB(dut)

    await tb.reset()

    dut.rx_lfc_en.value = 1
    dut.rx_lfc_ack.value = 0

    dut.rx_pfc_en.value = 0
    dut.rx_pfc_ack.value = 0

    dut.cfg_rx_lfc_opcode.value = 0x0001
    dut.cfg_rx_lfc_en.value = 1
    dut.cfg_rx_pfc_opcode.value = 0x0101
    dut.cfg_rx_pfc_en.value = 0
    dut.cfg_quanta_step.value = int(10000*256 / (512*156.25))
    dut.cfg_quanta_clk_en.value = 1

    tb.log.info("Test release time accuracy")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH', 0x0001, 100)

    await tb.send_mcf(test_pkt)

    while dut.rx_lfc_req.value == 0:
        await RisingEdge(dut.clk)
    dut.rx_lfc_ack.value = 1

    start_time = get_sim_time('sec')
    while dut.rx_lfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_lfc_ack.value = 0

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) == 100

    tb.log.info("Test release time accuracy (with refresh)")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH', 0x0001, 100)

    await tb.send_mcf(test_pkt)

    while dut.rx_lfc_req.value == 0:
        await RisingEdge(dut.clk)
    dut.rx_lfc_ack.value = 1

    for k in range(400):
        await RisingEdge(dut.clk)

    await tb.send_mcf(test_pkt)

    start_time = get_sim_time('sec')
    while dut.rx_lfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_lfc_ack.value = 0

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) == 100

    tb.log.info("Test explicit release")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH', 0x0001, 100)

    await tb.send_mcf(test_pkt)

    while dut.rx_lfc_req.value == 0:
        await RisingEdge(dut.clk)
    dut.rx_lfc_ack.value = 1

    start_time = get_sim_time('sec')

    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH', 0x0001, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_lfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_lfc_ack.value = 0

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) < 50

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_pfc(dut):

    tb = TB(dut)

    await tb.reset()

    dut.rx_lfc_en.value = 0
    dut.rx_lfc_ack.value = 0

    dut.rx_pfc_en.value = 0xFF
    dut.rx_pfc_ack.value = 0

    dut.cfg_rx_lfc_opcode.value = 0x0001
    dut.cfg_rx_lfc_en.value = 0
    dut.cfg_rx_pfc_opcode.value = 0x0101
    dut.cfg_rx_pfc_en.value = 1
    dut.cfg_quanta_step.value = int(10000*256 / (512*156.25))
    dut.cfg_quanta_clk_en.value = 1

    tb.log.info("Test release time accuracy")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0001, 100, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value == 0x00:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0x01

    start_time = get_sim_time('sec')
    while dut.rx_pfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_pfc_ack.value = 0x00

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) == 100

    tb.log.info("Test release time accuracy (with refresh)")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0001, 100, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value == 0x00:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0x01

    for k in range(400):
        await RisingEdge(dut.clk)

    await tb.send_mcf(test_pkt)

    start_time = get_sim_time('sec')
    while dut.rx_pfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_pfc_ack.value = 0x00

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) == 100

    tb.log.info("Test explicit release")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0001, 100, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value == 0x00:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0x01

    start_time = get_sim_time('sec')

    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0001, 0, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_pfc_ack.value = 0x00

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) < 50

    tb.log.info("Test all channels")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x00FF, 10, 20, 30, 40, 50, 60, 70, 80)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value != 0xff:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0xff

    start_time = get_sim_time('sec')

    for k in range(8):
        while dut.rx_pfc_req.value & (1 << k) != 0x00:
            await RisingEdge(dut.clk)
        stop_time = get_sim_time('sec')

        pause_time = stop_time-start_time
        pause_quanta = pause_time / (512 * 1/10e9)

        tb.log.info("pause time   : %g s", pause_time)
        tb.log.info("pause quanta : %f", pause_quanta)

        assert round(pause_quanta) == (k+1)*10

    dut.rx_pfc_ack.value = 0

    tb.log.info("Test isolation")
    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0001, 100, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value & 0x01 == 0x00:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0x01

    start_time = get_sim_time('sec')

    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0002, 0, 200, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value & 0x02 == 0x00:
        await RisingEdge(dut.clk)
    dut.rx_pfc_ack.value = 0x03

    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x0002, 0, 0, 0, 0, 0, 0, 0, 0)

    await tb.send_mcf(test_pkt)

    while dut.rx_pfc_req.value:
        await RisingEdge(dut.clk)
    stop_time = get_sim_time('sec')

    dut.rx_pfc_ack.value = 0x00

    pause_time = stop_time-start_time
    pause_quanta = pause_time / (512 * 1/10e9)

    tb.log.info("pause time   : %g s", pause_time)
    tb.log.info("pause quanta : %f", pause_quanta)

    assert round(pause_quanta) == 100

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


if cocotb.SIM_NAME:

    for test in [run_test_lfc, run_test_pfc]:

        factory = TestFactory(test)
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_mac_pause_ctrl_rx(request):
    dut = "mac_pause_ctrl_rx"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['MCF_PARAMS_SIZE'] = 18
    parameters['PFC_ENABLE'] = 1

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
