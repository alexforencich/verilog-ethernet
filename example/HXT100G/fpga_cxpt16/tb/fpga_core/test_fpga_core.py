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

import logging
import os

from scapy.layers.l2 import Ether

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

from cocotbext.eth import XgmiiFrame, XgmiiSource, XgmiiSink


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        # Ethernet
        self.eth_r0_source = XgmiiSource(dut.eth_r0_rxd, dut.eth_r0_rxc, dut.clk, dut.rst)
        self.eth_r0_sink = XgmiiSink(dut.eth_r0_txd, dut.eth_r0_txc, dut.clk, dut.rst)

        self.eth_r1_source = XgmiiSource(dut.eth_r1_rxd, dut.eth_r1_rxc, dut.clk, dut.rst)
        self.eth_r1_sink = XgmiiSink(dut.eth_r1_txd, dut.eth_r1_txc, dut.clk, dut.rst)

        self.eth_r2_source = XgmiiSource(dut.eth_r2_rxd, dut.eth_r2_rxc, dut.clk, dut.rst)
        self.eth_r2_sink = XgmiiSink(dut.eth_r2_txd, dut.eth_r2_txc, dut.clk, dut.rst)

        self.eth_r3_source = XgmiiSource(dut.eth_r3_rxd, dut.eth_r3_rxc, dut.clk, dut.rst)
        self.eth_r3_sink = XgmiiSink(dut.eth_r3_txd, dut.eth_r3_txc, dut.clk, dut.rst)

        self.eth_r4_source = XgmiiSource(dut.eth_r4_rxd, dut.eth_r4_rxc, dut.clk, dut.rst)
        self.eth_r4_sink = XgmiiSink(dut.eth_r4_txd, dut.eth_r4_txc, dut.clk, dut.rst)

        self.eth_r5_source = XgmiiSource(dut.eth_r5_rxd, dut.eth_r5_rxc, dut.clk, dut.rst)
        self.eth_r5_sink = XgmiiSink(dut.eth_r5_txd, dut.eth_r5_txc, dut.clk, dut.rst)

        self.eth_r6_source = XgmiiSource(dut.eth_r6_rxd, dut.eth_r6_rxc, dut.clk, dut.rst)
        self.eth_r6_sink = XgmiiSink(dut.eth_r6_txd, dut.eth_r6_txc, dut.clk, dut.rst)

        self.eth_r7_source = XgmiiSource(dut.eth_r7_rxd, dut.eth_r7_rxc, dut.clk, dut.rst)
        self.eth_r7_sink = XgmiiSink(dut.eth_r7_txd, dut.eth_r7_txc, dut.clk, dut.rst)

        self.eth_r8_source = XgmiiSource(dut.eth_r8_rxd, dut.eth_r8_rxc, dut.clk, dut.rst)
        self.eth_r8_sink = XgmiiSink(dut.eth_r8_txd, dut.eth_r8_txc, dut.clk, dut.rst)

        self.eth_r9_source = XgmiiSource(dut.eth_r9_rxd, dut.eth_r9_rxc, dut.clk, dut.rst)
        self.eth_r9_sink = XgmiiSink(dut.eth_r9_txd, dut.eth_r9_txc, dut.clk, dut.rst)

        self.eth_r10_source = XgmiiSource(dut.eth_r10_rxd, dut.eth_r10_rxc, dut.clk, dut.rst)
        self.eth_r10_sink = XgmiiSink(dut.eth_r10_txd, dut.eth_r10_txc, dut.clk, dut.rst)

        self.eth_r11_source = XgmiiSource(dut.eth_r11_rxd, dut.eth_r11_rxc, dut.clk, dut.rst)
        self.eth_r11_sink = XgmiiSink(dut.eth_r11_txd, dut.eth_r11_txc, dut.clk, dut.rst)

        self.eth_l0_source = XgmiiSource(dut.eth_l0_rxd, dut.eth_l0_rxc, dut.clk, dut.rst)
        self.eth_l0_sink = XgmiiSink(dut.eth_l0_txd, dut.eth_l0_txc, dut.clk, dut.rst)

        self.eth_l1_source = XgmiiSource(dut.eth_l1_rxd, dut.eth_l1_rxc, dut.clk, dut.rst)
        self.eth_l1_sink = XgmiiSink(dut.eth_l1_txd, dut.eth_l1_txc, dut.clk, dut.rst)

        self.eth_l2_source = XgmiiSource(dut.eth_l2_rxd, dut.eth_l2_rxc, dut.clk, dut.rst)
        self.eth_l2_sink = XgmiiSink(dut.eth_l2_txd, dut.eth_l2_txc, dut.clk, dut.rst)

        self.eth_l3_source = XgmiiSource(dut.eth_l3_rxd, dut.eth_l3_rxc, dut.clk, dut.rst)
        self.eth_l3_sink = XgmiiSink(dut.eth_l3_txd, dut.eth_l3_txc, dut.clk, dut.rst)

        self.eth_l4_source = XgmiiSource(dut.eth_l4_rxd, dut.eth_l4_rxc, dut.clk, dut.rst)
        self.eth_l4_sink = XgmiiSink(dut.eth_l4_txd, dut.eth_l4_txc, dut.clk, dut.rst)

        self.eth_l5_source = XgmiiSource(dut.eth_l5_rxd, dut.eth_l5_rxc, dut.clk, dut.rst)
        self.eth_l5_sink = XgmiiSink(dut.eth_l5_txd, dut.eth_l5_txc, dut.clk, dut.rst)

        self.eth_l6_source = XgmiiSource(dut.eth_l6_rxd, dut.eth_l6_rxc, dut.clk, dut.rst)
        self.eth_l6_sink = XgmiiSink(dut.eth_l6_txd, dut.eth_l6_txc, dut.clk, dut.rst)

        self.eth_l7_source = XgmiiSource(dut.eth_l7_rxd, dut.eth_l7_rxc, dut.clk, dut.rst)
        self.eth_l7_sink = XgmiiSink(dut.eth_l7_txd, dut.eth_l7_txc, dut.clk, dut.rst)

        self.eth_l8_source = XgmiiSource(dut.eth_l8_rxd, dut.eth_l8_rxc, dut.clk, dut.rst)
        self.eth_l8_sink = XgmiiSink(dut.eth_l8_txd, dut.eth_l8_txc, dut.clk, dut.rst)

        self.eth_l9_source = XgmiiSource(dut.eth_l9_rxd, dut.eth_l9_rxc, dut.clk, dut.rst)
        self.eth_l9_sink = XgmiiSink(dut.eth_l9_txd, dut.eth_l9_txc, dut.clk, dut.rst)

        self.eth_l10_source = XgmiiSource(dut.eth_l10_rxd, dut.eth_l10_rxc, dut.clk, dut.rst)
        self.eth_l10_sink = XgmiiSink(dut.eth_l10_txd, dut.eth_l10_txc, dut.clk, dut.rst)

        self.eth_l11_source = XgmiiSource(dut.eth_l11_rxd, dut.eth_l11_rxc, dut.clk, dut.rst)
        self.eth_l11_sink = XgmiiSink(dut.eth_l11_txd, dut.eth_l11_txc, dut.clk, dut.rst)

        dut.sw.setimmediatevalue(0)
        dut.jp.setimmediatevalue(0)
        dut.uart_suspend.setimmediatevalue(0)
        dut.uart_dtr.setimmediatevalue(0)
        dut.uart_txd.setimmediatevalue(0)
        dut.uart_rts.setimmediatevalue(0)
        dut.amh_right_mdio_i.setimmediatevalue(0)
        dut.amh_left_mdio_i.setimmediatevalue(0)

    async def init(self):

        self.dut.rst.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 0


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    tb.log.info("send test packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8000)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l0_source.send(test_frame)

    rx_frame = await tb.eth_l0_sink.recv()

    rx_pkt = Ether(bytes(rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt == test_pkt

    tb.log.info("update configuration")

    payload = bytes(range(15, -1, -1))
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8099)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l11_source.send(test_frame)

    await Timer(400, 'ns')

    tb.log.info("send test packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8000)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l0_source.send(test_frame)

    rx_frame = await tb.eth_r7_sink.recv()

    rx_pkt = Ether(bytes(rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt == test_pkt

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'lib', 'axis', 'rtl'))
eth_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'rtl'))


def test_fpga_core(request):
    dut = "fpga_core"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(eth_rtl_dir, "eth_mac_10g_fifo.v"),
        os.path.join(eth_rtl_dir, "eth_mac_10g.v"),
        os.path.join(eth_rtl_dir, "axis_xgmii_rx_64.v"),
        os.path.join(eth_rtl_dir, "axis_xgmii_tx_64.v"),
        os.path.join(eth_rtl_dir, "lfsr.v"),
        os.path.join(eth_rtl_dir, "eth_axis_rx.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
        os.path.join(axis_rtl_dir, "axis_crosspoint.v"),
    ]

    parameters = {}

    # parameters['A'] = val

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
