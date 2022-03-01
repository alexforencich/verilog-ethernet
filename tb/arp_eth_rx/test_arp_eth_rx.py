#!/usr/bin/env python
"""

Copyright (c) 2020 Alex Forencich

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

from scapy.layers.l2 import Ether, ARP
from scapy.utils import mac2str

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamSource
from cocotbext.axi.stream import define_stream


EthHdrBus, EthHdrTransaction, EthHdrSource, EthHdrSink, EthHdrMonitor = define_stream("EthHdr",
    signals=["hdr_valid", "hdr_ready", "dest_mac", "src_mac", "type"]
)

ArpHdrBus, ArpHdrTransaction, ArpHdrSource, ArpHdrSink, ArpHdrMonitor = define_stream("ArpHdr",
    signals=["frame_valid", "frame_ready", "eth_dest_mac", "eth_src_mac", "eth_type",
    "arp_htype", "arp_ptype", "arp_hlen", "arp_plen", "arp_oper", "arp_sha", "arp_spa", "arp_tha", "arp_tpa"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.header_source = EthHdrSource(EthHdrBus.from_prefix(dut, "s_eth"), dut.clk, dut.rst)
        self.payload_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_eth_payload_axis"), dut.clk, dut.rst)

        self.sink = ArpHdrSink(ArpHdrBus.from_prefix(dut, "m"), dut.clk, dut.rst)

    def set_idle_generator(self, generator=None):
        if generator:
            self.header_source.set_pause_generator(generator())
            self.payload_source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

    async def send(self, pkt):
        hdr = EthHdrTransaction()
        hdr.dest_mac = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
        hdr.src_mac = int.from_bytes(mac2str(pkt[Ether].src), 'big')
        hdr.type = pkt[Ether].type

        await self.header_source.send(hdr)
        await self.payload_source.send(bytes(pkt[Ether].payload))

    async def recv(self):
        rx_frame = await self.sink.recv()

        eth = Ether()
        eth.dst = rx_frame.eth_dest_mac.integer.to_bytes(6, 'big')
        eth.src = rx_frame.eth_src_mac.integer.to_bytes(6, 'big')
        eth.type = rx_frame.eth_type.integer
        arp = ARP()
        arp.hwtype = rx_frame.arp_htype.integer
        arp.ptype = rx_frame.arp_ptype.integer
        arp.hwlen = rx_frame.arp_hlen.integer
        arp.plen = rx_frame.arp_plen.integer
        arp.op = rx_frame.arp_oper.integer
        arp.hwsrc = rx_frame.arp_sha.integer.to_bytes(6, 'big')
        arp.psrc = rx_frame.arp_spa.integer
        arp.hwdst = rx_frame.arp_tha.integer.to_bytes(6, 'big')
        arp.pdst = rx_frame.arp_tpa.integer
        rx_pkt = eth / arp

        return Ether(bytes(rx_pkt))


async def run_test(dut, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5')
    arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
        hwsrc='5A:51:52:53:54:55', psrc='192.168.1.100',
        hwdst='DA:D1:D2:D3:D4:D5', pdst='192.168.1.101')
    test_pkt = eth / arp

    await tb.send(test_pkt)

    rx_pkt = await tb.recv()

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert bytes(rx_pkt) == bytes(test_pkt)

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


if cocotb.SIM_NAME:

    factory = TestFactory(run_test)
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("data_width", [8, 16, 32, 64, 128, 256, 512])
def test_arp_eth_rx(request, data_width):
    dut = "arp_eth_rx"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8

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
