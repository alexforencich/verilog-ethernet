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

import itertools
import logging
import os
import random

from scapy.layers.l2 import Ether
from scapy.utils import mac2str

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Event
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame
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

        cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)
        self.mcf_source = McfSource(McfBus.from_prefix(dut, "mcf"), dut.clk, dut.rst)

        dut.tx_pause_req.setimmediatevalue(0)

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())
            self.mcf_source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

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

    async def send(self, pkt):
        await self.source.send(bytes(pkt))

    async def send_mcf(self, pkt):
        mcf = McfTransaction()
        mcf.eth_dst = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
        mcf.eth_src = int.from_bytes(mac2str(pkt[Ether].src), 'big')
        mcf.eth_type = pkt[Ether].type
        mcf.opcode = int.from_bytes(bytes(pkt[Ether].payload)[0:2], 'big')
        mcf.params = int.from_bytes(bytes(pkt[Ether].payload)[2:], 'little')

        await self.mcf_source.send(mcf)

    async def recv(self):
        rx_frame = await self.sink.recv()

        assert not rx_frame.tuser

        return Ether(bytes(rx_frame))


async def run_test_data(dut, payload_lengths=None, payload_data=None, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    id_width = len(tb.source.bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = 1
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    dut.tx_pause_req.value = 0

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = []

    for test_data in [payload_data(x) for x in payload_lengths()]:
        test_frame = AxiStreamFrame(test_data)
        test_frame.tid = cur_id | (0 << src_shift)
        test_frame.tdest = cur_id

        test_frames.append(test_frame)
        await tb.source.send(test_frame)

        cur_id = (cur_id + 1) % max_count

    for test_frame in test_frames:
        rx_frame = await tb.sink.recv()

        assert rx_frame.tdata == test_frame.tdata
        assert rx_frame.tid == test_frame.tid
        assert rx_frame.tdest == test_frame.tdest
        assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_mcf(dut, payload_lengths=None, payload_data=None, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    await tb.reset()

    dut.tx_pause_req.value = 0

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_pkts = []

    opcode = 1

    for payload in [payload_data(x) for x in payload_lengths()]:
        eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
        test_pkt = eth / (opcode.to_bytes(2, 'big') + payload)
        test_pkts.append(test_pkt.copy())

        await tb.send_mcf(test_pkt)

        opcode += 1

    for test_pkt in test_pkts:
        rx_pkt = await tb.recv()

        tb.log.info("RX packet: %s", repr(rx_pkt))

        # check prefix as frame gets zero-padded
        assert bytes(rx_pkt).find(bytes(test_pkt)) == 0

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_tuser_assert(dut):

    tb = TB(dut)

    await tb.reset()

    dut.tx_pause_req.value = 0

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data, tuser=1)
    await tb.source.send(test_frame)

    rx_frame = await tb.sink.recv()

    assert rx_frame.tdata == test_frame.tdata
    assert rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_arb_test(dut):

    tb = TB(dut)

    byte_lanes = tb.source.byte_lanes
    id_width = len(tb.source.bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = 1
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    dut.tx_pause_req.value = 0

    test_pkts = []
    test_frames = []

    for k in range(4):
        length = byte_lanes*16
        payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

        eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5', type=0x8000)
        test_pkt = eth / (cur_id.to_bytes(2, 'big') + payload)
        test_pkts.append((cur_id, test_pkt.copy()))

        test_frame = AxiStreamFrame(bytes(test_pkt), tx_complete=Event())
        test_frame.tid = cur_id | (0 << src_shift)
        test_frame.tdest = cur_id
        test_frames.append(test_frame)

        await tb.source.send(test_frame)

        cur_id = (cur_id + 1) % max_count

    length = random.randint(1, 18)
    payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

    eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
    test_pkt = eth / (cur_id.to_bytes(2, 'big') + payload)
    test_pkts.append((cur_id, test_pkt.copy()))

    # start transmit in the middle of frame 2
    await test_frames[1].tx_complete.wait()
    for j in range(8):
        await RisingEdge(dut.clk)
    await tb.send_mcf(test_pkt)
    await FallingEdge(dut.mcf_valid)

    cur_id = (cur_id + 1) % max_count

    for k in [0, 1, 2, 4, 3]:
        rx_frame = await tb.sink.recv()

        rx_pkt = Ether(bytes(rx_frame))

        tb.log.info("RX packet: %s", repr(rx_pkt))

        cur_id, test_pkt = test_pkts[k]

        if rx_pkt.type == 0x8808:
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            assert rx_frame.tid == 0
            assert rx_frame.tdest == 0
        else:
            assert bytes(rx_pkt) == bytes(test_pkt)
            assert rx_frame.tid == cur_id | (0 << src_shift)
            assert rx_frame.tdest == cur_id

        assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_stress_test(dut, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    byte_lanes = tb.source.byte_lanes
    id_width = len(tb.source.bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = 1
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    dut.tx_pause_req.value = 0

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_pkts = [list() for x in range(2)]

    for k in range(256):
        length = random.randint(1, byte_lanes*16)
        payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

        eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5', type=0x8000)
        test_pkt = eth / (cur_id.to_bytes(2, 'big') + payload)
        test_pkts[0].append((cur_id, test_pkt.copy()))

        test_frame = AxiStreamFrame(bytes(test_pkt))
        test_frame.tid = cur_id | (0 << src_shift)
        test_frame.tdest = cur_id

        await tb.source.send(test_frame)

        cur_id = (cur_id + 1) % max_count

    for k in range(16):
        length = random.randint(1, 18)
        payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

        eth = Ether(src='5A:51:52:53:54:55', dst='01:80:C2:00:00:01', type=0x8808)
        test_pkt = eth / (cur_id.to_bytes(2, 'big') + payload)
        test_pkts[1].append((cur_id, test_pkt.copy()))

        for c in range(random.randint(8, 64)):
            await RisingEdge(dut.clk)
        await tb.send_mcf(test_pkt)
        await FallingEdge(dut.mcf_valid)

        cur_id = (cur_id + 1) % max_count

    while any(test_pkts):
        rx_frame = await tb.sink.recv()

        rx_pkt = Ether(bytes(rx_frame))

        tb.log.info("RX packet: %s", repr(rx_pkt))

        test_pkt = None

        if rx_pkt.type == 0x8808:
            cur_id, test_pkt = test_pkts[1].pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            assert rx_frame.tid == 0
            assert rx_frame.tdest == 0
        else:
            cur_id, test_pkt = test_pkts[0].pop(0)
            assert bytes(rx_pkt) == bytes(test_pkt)
            assert rx_frame.tid == cur_id | (0 << src_shift)
            assert rx_frame.tdest == cur_id

        assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


def size_list():
    return list(range(1, 128)) + [512, 1514, 9214] + [60]*10


def mcf_size_list():
    return list(range(1, 19))


def incrementing_payload(length):
    return bytes(itertools.islice(itertools.cycle(range(256)), length))


if cocotb.SIM_NAME:

    factory = TestFactory(run_test_data)
    factory.add_option("payload_lengths", [size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()

    factory = TestFactory(run_test_mcf)
    factory.add_option("payload_lengths", [mcf_size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()

    factory = TestFactory(run_test_tuser_assert)
    factory.generate_tests()

    factory = TestFactory(run_arb_test)
    factory.generate_tests()

    factory = TestFactory(run_stress_test)
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("data_width", [8, 16, 32, 64, 128, 256, 512])
def test_mac_ctrl_tx(request, data_width):
    dut = "mac_ctrl_tx"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['ID_ENABLE'] = 1
    parameters['ID_WIDTH'] = 8
    parameters['DEST_ENABLE'] = 1
    parameters['DEST_WIDTH'] = 8
    parameters['USER_WIDTH'] = 1
    parameters['MCF_PARAMS_SIZE'] = 18

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
