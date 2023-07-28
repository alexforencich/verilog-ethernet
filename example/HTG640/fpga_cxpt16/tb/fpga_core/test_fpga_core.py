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
        self.eth_r_source = []
        self.eth_r_sink = []

        for x in range(12):
            source = XgmiiSource(getattr(dut, f"eth_r{x}_rxd"), getattr(dut, f"eth_r{x}_rxc"), dut.clk, dut.rst)
            self.eth_r_source.append(source)
            sink = XgmiiSink(getattr(dut, f"eth_r{x}_txd"), getattr(dut, f"eth_r{x}_txc"), dut.clk, dut.rst)
            self.eth_r_sink.append(sink)

        self.eth_l_source = []
        self.eth_l_sink = []

        for x in range(12):
            source = XgmiiSource(getattr(dut, f"eth_l{x}_rxd"), getattr(dut, f"eth_l{x}_rxc"), dut.clk, dut.rst)
            self.eth_l_source.append(source)
            sink = XgmiiSink(getattr(dut, f"eth_l{x}_txd"), getattr(dut, f"eth_l{x}_txc"), dut.clk, dut.rst)
            self.eth_l_sink.append(sink)

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

        self.dut.rst.value = 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst.value = 0


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    tb.log.info("send test packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8000)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l_source[0].send(test_frame)

    rx_frame = await tb.eth_l_sink[0].recv()

    rx_pkt = Ether(bytes(rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt == test_pkt

    tb.log.info("update configuration")

    payload = bytes(range(15, -1, -1))
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8099)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l_source[11].send(test_frame)

    await Timer(400, 'ns')

    tb.log.info("send test packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00', type=0x8000)
    test_pkt = eth / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.eth_l_source[0].send(test_frame)

    rx_frame = await tb.eth_r_sink[7].recv()

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
