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

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotbext.eth import XgmiiFrame, XgmiiSource, XgmiiSink


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        dut.btn.setimmediatevalue(0)
        dut.sw.setimmediatevalue(0)

        dut.uart_txd.setimmediatevalue(1)
        dut.uart_rts.setimmediatevalue(1)

        # Ethernet
        cocotb.start_soon(Clock(dut.qsfp_1_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_1_1_source = XgmiiSource(dut.qsfp_1_rxd_1, dut.qsfp_1_rxc_1, dut.qsfp_1_rx_clk_1, dut.qsfp_1_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_1_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_1_1_sink = XgmiiSink(dut.qsfp_1_txd_1, dut.qsfp_1_txc_1, dut.qsfp_1_tx_clk_1, dut.qsfp_1_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_1_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_1_2_source = XgmiiSource(dut.qsfp_1_rxd_2, dut.qsfp_1_rxc_2, dut.qsfp_1_rx_clk_2, dut.qsfp_1_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_1_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_1_2_sink = XgmiiSink(dut.qsfp_1_txd_2, dut.qsfp_1_txc_2, dut.qsfp_1_tx_clk_2, dut.qsfp_1_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_1_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_1_3_source = XgmiiSource(dut.qsfp_1_rxd_3, dut.qsfp_1_rxc_3, dut.qsfp_1_rx_clk_3, dut.qsfp_1_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_1_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_1_3_sink = XgmiiSink(dut.qsfp_1_txd_3, dut.qsfp_1_txc_3, dut.qsfp_1_tx_clk_3, dut.qsfp_1_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_1_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_1_4_source = XgmiiSource(dut.qsfp_1_rxd_4, dut.qsfp_1_rxc_4, dut.qsfp_1_rx_clk_4, dut.qsfp_1_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_1_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_1_4_sink = XgmiiSink(dut.qsfp_1_txd_4, dut.qsfp_1_txc_4, dut.qsfp_1_tx_clk_4, dut.qsfp_1_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_2_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_2_1_source = XgmiiSource(dut.qsfp_2_rxd_1, dut.qsfp_2_rxc_1, dut.qsfp_2_rx_clk_1, dut.qsfp_2_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_2_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_2_1_sink = XgmiiSink(dut.qsfp_2_txd_1, dut.qsfp_2_txc_1, dut.qsfp_2_tx_clk_1, dut.qsfp_2_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_2_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_2_2_source = XgmiiSource(dut.qsfp_2_rxd_2, dut.qsfp_2_rxc_2, dut.qsfp_2_rx_clk_2, dut.qsfp_2_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_2_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_2_2_sink = XgmiiSink(dut.qsfp_2_txd_2, dut.qsfp_2_txc_2, dut.qsfp_2_tx_clk_2, dut.qsfp_2_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_2_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_2_3_source = XgmiiSource(dut.qsfp_2_rxd_3, dut.qsfp_2_rxc_3, dut.qsfp_2_rx_clk_3, dut.qsfp_2_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_2_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_2_3_sink = XgmiiSink(dut.qsfp_2_txd_3, dut.qsfp_2_txc_3, dut.qsfp_2_tx_clk_3, dut.qsfp_2_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_2_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_2_4_source = XgmiiSource(dut.qsfp_2_rxd_4, dut.qsfp_2_rxc_4, dut.qsfp_2_rx_clk_4, dut.qsfp_2_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_2_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_2_4_sink = XgmiiSink(dut.qsfp_2_txd_4, dut.qsfp_2_txc_4, dut.qsfp_2_tx_clk_4, dut.qsfp_2_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_3_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_3_1_source = XgmiiSource(dut.qsfp_3_rxd_1, dut.qsfp_3_rxc_1, dut.qsfp_3_rx_clk_1, dut.qsfp_3_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_3_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_3_1_sink = XgmiiSink(dut.qsfp_3_txd_1, dut.qsfp_3_txc_1, dut.qsfp_3_tx_clk_1, dut.qsfp_3_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_3_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_3_2_source = XgmiiSource(dut.qsfp_3_rxd_2, dut.qsfp_3_rxc_2, dut.qsfp_3_rx_clk_2, dut.qsfp_3_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_3_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_3_2_sink = XgmiiSink(dut.qsfp_3_txd_2, dut.qsfp_3_txc_2, dut.qsfp_3_tx_clk_2, dut.qsfp_3_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_3_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_3_3_source = XgmiiSource(dut.qsfp_3_rxd_3, dut.qsfp_3_rxc_3, dut.qsfp_3_rx_clk_3, dut.qsfp_3_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_3_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_3_3_sink = XgmiiSink(dut.qsfp_3_txd_3, dut.qsfp_3_txc_3, dut.qsfp_3_tx_clk_3, dut.qsfp_3_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_3_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_3_4_source = XgmiiSource(dut.qsfp_3_rxd_4, dut.qsfp_3_rxc_4, dut.qsfp_3_rx_clk_4, dut.qsfp_3_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_3_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_3_4_sink = XgmiiSink(dut.qsfp_3_txd_4, dut.qsfp_3_txc_4, dut.qsfp_3_tx_clk_4, dut.qsfp_3_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_4_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_4_1_source = XgmiiSource(dut.qsfp_4_rxd_1, dut.qsfp_4_rxc_1, dut.qsfp_4_rx_clk_1, dut.qsfp_4_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_4_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_4_1_sink = XgmiiSink(dut.qsfp_4_txd_1, dut.qsfp_4_txc_1, dut.qsfp_4_tx_clk_1, dut.qsfp_4_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_4_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_4_2_source = XgmiiSource(dut.qsfp_4_rxd_2, dut.qsfp_4_rxc_2, dut.qsfp_4_rx_clk_2, dut.qsfp_4_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_4_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_4_2_sink = XgmiiSink(dut.qsfp_4_txd_2, dut.qsfp_4_txc_2, dut.qsfp_4_tx_clk_2, dut.qsfp_4_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_4_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_4_3_source = XgmiiSource(dut.qsfp_4_rxd_3, dut.qsfp_4_rxc_3, dut.qsfp_4_rx_clk_3, dut.qsfp_4_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_4_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_4_3_sink = XgmiiSink(dut.qsfp_4_txd_3, dut.qsfp_4_txc_3, dut.qsfp_4_tx_clk_3, dut.qsfp_4_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_4_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_4_4_source = XgmiiSource(dut.qsfp_4_rxd_4, dut.qsfp_4_rxc_4, dut.qsfp_4_rx_clk_4, dut.qsfp_4_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_4_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_4_4_sink = XgmiiSink(dut.qsfp_4_txd_4, dut.qsfp_4_txc_4, dut.qsfp_4_tx_clk_4, dut.qsfp_4_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_5_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_5_1_source = XgmiiSource(dut.qsfp_5_rxd_1, dut.qsfp_5_rxc_1, dut.qsfp_5_rx_clk_1, dut.qsfp_5_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_5_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_5_1_sink = XgmiiSink(dut.qsfp_5_txd_1, dut.qsfp_5_txc_1, dut.qsfp_5_tx_clk_1, dut.qsfp_5_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_5_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_5_2_source = XgmiiSource(dut.qsfp_5_rxd_2, dut.qsfp_5_rxc_2, dut.qsfp_5_rx_clk_2, dut.qsfp_5_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_5_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_5_2_sink = XgmiiSink(dut.qsfp_5_txd_2, dut.qsfp_5_txc_2, dut.qsfp_5_tx_clk_2, dut.qsfp_5_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_5_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_5_3_source = XgmiiSource(dut.qsfp_5_rxd_3, dut.qsfp_5_rxc_3, dut.qsfp_5_rx_clk_3, dut.qsfp_5_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_5_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_5_3_sink = XgmiiSink(dut.qsfp_5_txd_3, dut.qsfp_5_txc_3, dut.qsfp_5_tx_clk_3, dut.qsfp_5_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_5_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_5_4_source = XgmiiSource(dut.qsfp_5_rxd_4, dut.qsfp_5_rxc_4, dut.qsfp_5_rx_clk_4, dut.qsfp_5_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_5_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_5_4_sink = XgmiiSink(dut.qsfp_5_txd_4, dut.qsfp_5_txc_4, dut.qsfp_5_tx_clk_4, dut.qsfp_5_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_6_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_6_1_source = XgmiiSource(dut.qsfp_6_rxd_1, dut.qsfp_6_rxc_1, dut.qsfp_6_rx_clk_1, dut.qsfp_6_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_6_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_6_1_sink = XgmiiSink(dut.qsfp_6_txd_1, dut.qsfp_6_txc_1, dut.qsfp_6_tx_clk_1, dut.qsfp_6_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_6_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_6_2_source = XgmiiSource(dut.qsfp_6_rxd_2, dut.qsfp_6_rxc_2, dut.qsfp_6_rx_clk_2, dut.qsfp_6_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_6_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_6_2_sink = XgmiiSink(dut.qsfp_6_txd_2, dut.qsfp_6_txc_2, dut.qsfp_6_tx_clk_2, dut.qsfp_6_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_6_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_6_3_source = XgmiiSource(dut.qsfp_6_rxd_3, dut.qsfp_6_rxc_3, dut.qsfp_6_rx_clk_3, dut.qsfp_6_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_6_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_6_3_sink = XgmiiSink(dut.qsfp_6_txd_3, dut.qsfp_6_txc_3, dut.qsfp_6_tx_clk_3, dut.qsfp_6_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_6_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_6_4_source = XgmiiSource(dut.qsfp_6_rxd_4, dut.qsfp_6_rxc_4, dut.qsfp_6_rx_clk_4, dut.qsfp_6_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_6_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_6_4_sink = XgmiiSink(dut.qsfp_6_txd_4, dut.qsfp_6_txc_4, dut.qsfp_6_tx_clk_4, dut.qsfp_6_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_7_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_7_1_source = XgmiiSource(dut.qsfp_7_rxd_1, dut.qsfp_7_rxc_1, dut.qsfp_7_rx_clk_1, dut.qsfp_7_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_7_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_7_1_sink = XgmiiSink(dut.qsfp_7_txd_1, dut.qsfp_7_txc_1, dut.qsfp_7_tx_clk_1, dut.qsfp_7_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_7_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_7_2_source = XgmiiSource(dut.qsfp_7_rxd_2, dut.qsfp_7_rxc_2, dut.qsfp_7_rx_clk_2, dut.qsfp_7_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_7_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_7_2_sink = XgmiiSink(dut.qsfp_7_txd_2, dut.qsfp_7_txc_2, dut.qsfp_7_tx_clk_2, dut.qsfp_7_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_7_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_7_3_source = XgmiiSource(dut.qsfp_7_rxd_3, dut.qsfp_7_rxc_3, dut.qsfp_7_rx_clk_3, dut.qsfp_7_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_7_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_7_3_sink = XgmiiSink(dut.qsfp_7_txd_3, dut.qsfp_7_txc_3, dut.qsfp_7_tx_clk_3, dut.qsfp_7_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_7_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_7_4_source = XgmiiSource(dut.qsfp_7_rxd_4, dut.qsfp_7_rxc_4, dut.qsfp_7_rx_clk_4, dut.qsfp_7_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_7_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_7_4_sink = XgmiiSink(dut.qsfp_7_txd_4, dut.qsfp_7_txc_4, dut.qsfp_7_tx_clk_4, dut.qsfp_7_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_8_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_8_1_source = XgmiiSource(dut.qsfp_8_rxd_1, dut.qsfp_8_rxc_1, dut.qsfp_8_rx_clk_1, dut.qsfp_8_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_8_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_8_1_sink = XgmiiSink(dut.qsfp_8_txd_1, dut.qsfp_8_txc_1, dut.qsfp_8_tx_clk_1, dut.qsfp_8_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_8_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_8_2_source = XgmiiSource(dut.qsfp_8_rxd_2, dut.qsfp_8_rxc_2, dut.qsfp_8_rx_clk_2, dut.qsfp_8_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_8_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_8_2_sink = XgmiiSink(dut.qsfp_8_txd_2, dut.qsfp_8_txc_2, dut.qsfp_8_tx_clk_2, dut.qsfp_8_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_8_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_8_3_source = XgmiiSource(dut.qsfp_8_rxd_3, dut.qsfp_8_rxc_3, dut.qsfp_8_rx_clk_3, dut.qsfp_8_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_8_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_8_3_sink = XgmiiSink(dut.qsfp_8_txd_3, dut.qsfp_8_txc_3, dut.qsfp_8_tx_clk_3, dut.qsfp_8_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_8_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_8_4_source = XgmiiSource(dut.qsfp_8_rxd_4, dut.qsfp_8_rxc_4, dut.qsfp_8_rx_clk_4, dut.qsfp_8_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_8_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_8_4_sink = XgmiiSink(dut.qsfp_8_txd_4, dut.qsfp_8_txc_4, dut.qsfp_8_tx_clk_4, dut.qsfp_8_tx_rst_4)

        cocotb.start_soon(Clock(dut.qsfp_9_rx_clk_1, 6.4, units="ns").start())
        self.qsfp_9_1_source = XgmiiSource(dut.qsfp_9_rxd_1, dut.qsfp_9_rxc_1, dut.qsfp_9_rx_clk_1, dut.qsfp_9_rx_rst_1)
        cocotb.start_soon(Clock(dut.qsfp_9_tx_clk_1, 6.4, units="ns").start())
        self.qsfp_9_1_sink = XgmiiSink(dut.qsfp_9_txd_1, dut.qsfp_9_txc_1, dut.qsfp_9_tx_clk_1, dut.qsfp_9_tx_rst_1)

        cocotb.start_soon(Clock(dut.qsfp_9_rx_clk_2, 6.4, units="ns").start())
        self.qsfp_9_2_source = XgmiiSource(dut.qsfp_9_rxd_2, dut.qsfp_9_rxc_2, dut.qsfp_9_rx_clk_2, dut.qsfp_9_rx_rst_2)
        cocotb.start_soon(Clock(dut.qsfp_9_tx_clk_2, 6.4, units="ns").start())
        self.qsfp_9_2_sink = XgmiiSink(dut.qsfp_9_txd_2, dut.qsfp_9_txc_2, dut.qsfp_9_tx_clk_2, dut.qsfp_9_tx_rst_2)

        cocotb.start_soon(Clock(dut.qsfp_9_rx_clk_3, 6.4, units="ns").start())
        self.qsfp_9_3_source = XgmiiSource(dut.qsfp_9_rxd_3, dut.qsfp_9_rxc_3, dut.qsfp_9_rx_clk_3, dut.qsfp_9_rx_rst_3)
        cocotb.start_soon(Clock(dut.qsfp_9_tx_clk_3, 6.4, units="ns").start())
        self.qsfp_9_3_sink = XgmiiSink(dut.qsfp_9_txd_3, dut.qsfp_9_txc_3, dut.qsfp_9_tx_clk_3, dut.qsfp_9_tx_rst_3)

        cocotb.start_soon(Clock(dut.qsfp_9_rx_clk_4, 6.4, units="ns").start())
        self.qsfp_9_4_source = XgmiiSource(dut.qsfp_9_rxd_4, dut.qsfp_9_rxc_4, dut.qsfp_9_rx_clk_4, dut.qsfp_9_rx_rst_4)
        cocotb.start_soon(Clock(dut.qsfp_9_tx_clk_4, 6.4, units="ns").start())
        self.qsfp_9_4_sink = XgmiiSink(dut.qsfp_9_txd_4, dut.qsfp_9_txc_4, dut.qsfp_9_tx_clk_4, dut.qsfp_9_tx_rst_4)

    async def init(self):

        self.dut.rst.setimmediatevalue(0)
        self.dut.qsfp_1_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_1_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_1_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_1_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_1_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_1_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_1_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_1_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_2_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_2_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_2_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_2_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_2_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_2_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_2_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_2_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_3_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_3_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_3_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_3_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_3_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_3_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_3_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_3_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_4_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_4_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_4_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_4_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_4_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_4_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_4_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_4_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_5_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_5_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_5_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_5_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_5_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_5_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_5_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_5_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_6_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_6_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_6_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_6_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_6_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_6_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_6_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_6_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_7_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_7_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_7_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_7_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_7_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_7_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_7_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_7_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_8_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_8_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_8_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_8_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_8_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_8_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_8_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_8_tx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_9_rx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_9_tx_rst_1.setimmediatevalue(0)
        self.dut.qsfp_9_rx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_9_tx_rst_2.setimmediatevalue(0)
        self.dut.qsfp_9_rx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_9_tx_rst_3.setimmediatevalue(0)
        self.dut.qsfp_9_rx_rst_4.setimmediatevalue(0)
        self.dut.qsfp_9_tx_rst_4.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 1
        self.dut.qsfp_1_rx_rst_1 <= 1
        self.dut.qsfp_1_tx_rst_1 <= 1
        self.dut.qsfp_1_rx_rst_2 <= 1
        self.dut.qsfp_1_tx_rst_2 <= 1
        self.dut.qsfp_1_rx_rst_3 <= 1
        self.dut.qsfp_1_tx_rst_3 <= 1
        self.dut.qsfp_1_rx_rst_4 <= 1
        self.dut.qsfp_1_tx_rst_4 <= 1
        self.dut.qsfp_2_rx_rst_1 <= 1
        self.dut.qsfp_2_tx_rst_1 <= 1
        self.dut.qsfp_2_rx_rst_2 <= 1
        self.dut.qsfp_2_tx_rst_2 <= 1
        self.dut.qsfp_2_rx_rst_3 <= 1
        self.dut.qsfp_2_tx_rst_3 <= 1
        self.dut.qsfp_2_rx_rst_4 <= 1
        self.dut.qsfp_2_tx_rst_4 <= 1
        self.dut.qsfp_3_rx_rst_1 <= 1
        self.dut.qsfp_3_tx_rst_1 <= 1
        self.dut.qsfp_3_rx_rst_2 <= 1
        self.dut.qsfp_3_tx_rst_2 <= 1
        self.dut.qsfp_3_rx_rst_3 <= 1
        self.dut.qsfp_3_tx_rst_3 <= 1
        self.dut.qsfp_3_rx_rst_4 <= 1
        self.dut.qsfp_3_tx_rst_4 <= 1
        self.dut.qsfp_4_rx_rst_1 <= 1
        self.dut.qsfp_4_tx_rst_1 <= 1
        self.dut.qsfp_4_rx_rst_2 <= 1
        self.dut.qsfp_4_tx_rst_2 <= 1
        self.dut.qsfp_4_rx_rst_3 <= 1
        self.dut.qsfp_4_tx_rst_3 <= 1
        self.dut.qsfp_4_rx_rst_4 <= 1
        self.dut.qsfp_4_tx_rst_4 <= 1
        self.dut.qsfp_5_rx_rst_1 <= 1
        self.dut.qsfp_5_tx_rst_1 <= 1
        self.dut.qsfp_5_rx_rst_2 <= 1
        self.dut.qsfp_5_tx_rst_2 <= 1
        self.dut.qsfp_5_rx_rst_3 <= 1
        self.dut.qsfp_5_tx_rst_3 <= 1
        self.dut.qsfp_5_rx_rst_4 <= 1
        self.dut.qsfp_5_tx_rst_4 <= 1
        self.dut.qsfp_6_rx_rst_1 <= 1
        self.dut.qsfp_6_tx_rst_1 <= 1
        self.dut.qsfp_6_rx_rst_2 <= 1
        self.dut.qsfp_6_tx_rst_2 <= 1
        self.dut.qsfp_6_rx_rst_3 <= 1
        self.dut.qsfp_6_tx_rst_3 <= 1
        self.dut.qsfp_6_rx_rst_4 <= 1
        self.dut.qsfp_6_tx_rst_4 <= 1
        self.dut.qsfp_7_rx_rst_1 <= 1
        self.dut.qsfp_7_tx_rst_1 <= 1
        self.dut.qsfp_7_rx_rst_2 <= 1
        self.dut.qsfp_7_tx_rst_2 <= 1
        self.dut.qsfp_7_rx_rst_3 <= 1
        self.dut.qsfp_7_tx_rst_3 <= 1
        self.dut.qsfp_7_rx_rst_4 <= 1
        self.dut.qsfp_7_tx_rst_4 <= 1
        self.dut.qsfp_8_rx_rst_1 <= 1
        self.dut.qsfp_8_tx_rst_1 <= 1
        self.dut.qsfp_8_rx_rst_2 <= 1
        self.dut.qsfp_8_tx_rst_2 <= 1
        self.dut.qsfp_8_rx_rst_3 <= 1
        self.dut.qsfp_8_tx_rst_3 <= 1
        self.dut.qsfp_8_rx_rst_4 <= 1
        self.dut.qsfp_8_tx_rst_4 <= 1
        self.dut.qsfp_9_rx_rst_1 <= 1
        self.dut.qsfp_9_tx_rst_1 <= 1
        self.dut.qsfp_9_rx_rst_2 <= 1
        self.dut.qsfp_9_tx_rst_2 <= 1
        self.dut.qsfp_9_rx_rst_3 <= 1
        self.dut.qsfp_9_tx_rst_3 <= 1
        self.dut.qsfp_9_rx_rst_4 <= 1
        self.dut.qsfp_9_tx_rst_4 <= 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 0
        self.dut.qsfp_1_rx_rst_1 <= 0
        self.dut.qsfp_1_tx_rst_1 <= 0
        self.dut.qsfp_1_rx_rst_2 <= 0
        self.dut.qsfp_1_tx_rst_2 <= 0
        self.dut.qsfp_1_rx_rst_3 <= 0
        self.dut.qsfp_1_tx_rst_3 <= 0
        self.dut.qsfp_1_rx_rst_4 <= 0
        self.dut.qsfp_1_tx_rst_4 <= 0
        self.dut.qsfp_2_rx_rst_1 <= 0
        self.dut.qsfp_2_tx_rst_1 <= 0
        self.dut.qsfp_2_rx_rst_2 <= 0
        self.dut.qsfp_2_tx_rst_2 <= 0
        self.dut.qsfp_2_rx_rst_3 <= 0
        self.dut.qsfp_2_tx_rst_3 <= 0
        self.dut.qsfp_2_rx_rst_4 <= 0
        self.dut.qsfp_2_tx_rst_4 <= 0
        self.dut.qsfp_3_rx_rst_1 <= 0
        self.dut.qsfp_3_tx_rst_1 <= 0
        self.dut.qsfp_3_rx_rst_2 <= 0
        self.dut.qsfp_3_tx_rst_2 <= 0
        self.dut.qsfp_3_rx_rst_3 <= 0
        self.dut.qsfp_3_tx_rst_3 <= 0
        self.dut.qsfp_3_rx_rst_4 <= 0
        self.dut.qsfp_3_tx_rst_4 <= 0
        self.dut.qsfp_4_rx_rst_1 <= 0
        self.dut.qsfp_4_tx_rst_1 <= 0
        self.dut.qsfp_4_rx_rst_2 <= 0
        self.dut.qsfp_4_tx_rst_2 <= 0
        self.dut.qsfp_4_rx_rst_3 <= 0
        self.dut.qsfp_4_tx_rst_3 <= 0
        self.dut.qsfp_4_rx_rst_4 <= 0
        self.dut.qsfp_4_tx_rst_4 <= 0
        self.dut.qsfp_5_rx_rst_1 <= 0
        self.dut.qsfp_5_tx_rst_1 <= 0
        self.dut.qsfp_5_rx_rst_2 <= 0
        self.dut.qsfp_5_tx_rst_2 <= 0
        self.dut.qsfp_5_rx_rst_3 <= 0
        self.dut.qsfp_5_tx_rst_3 <= 0
        self.dut.qsfp_5_rx_rst_4 <= 0
        self.dut.qsfp_5_tx_rst_4 <= 0
        self.dut.qsfp_6_rx_rst_1 <= 0
        self.dut.qsfp_6_tx_rst_1 <= 0
        self.dut.qsfp_6_rx_rst_2 <= 0
        self.dut.qsfp_6_tx_rst_2 <= 0
        self.dut.qsfp_6_rx_rst_3 <= 0
        self.dut.qsfp_6_tx_rst_3 <= 0
        self.dut.qsfp_6_rx_rst_4 <= 0
        self.dut.qsfp_6_tx_rst_4 <= 0
        self.dut.qsfp_7_rx_rst_1 <= 0
        self.dut.qsfp_7_tx_rst_1 <= 0
        self.dut.qsfp_7_rx_rst_2 <= 0
        self.dut.qsfp_7_tx_rst_2 <= 0
        self.dut.qsfp_7_rx_rst_3 <= 0
        self.dut.qsfp_7_tx_rst_3 <= 0
        self.dut.qsfp_7_rx_rst_4 <= 0
        self.dut.qsfp_7_tx_rst_4 <= 0
        self.dut.qsfp_8_rx_rst_1 <= 0
        self.dut.qsfp_8_tx_rst_1 <= 0
        self.dut.qsfp_8_rx_rst_2 <= 0
        self.dut.qsfp_8_tx_rst_2 <= 0
        self.dut.qsfp_8_rx_rst_3 <= 0
        self.dut.qsfp_8_tx_rst_3 <= 0
        self.dut.qsfp_8_rx_rst_4 <= 0
        self.dut.qsfp_8_tx_rst_4 <= 0
        self.dut.qsfp_9_rx_rst_1 <= 0
        self.dut.qsfp_9_tx_rst_1 <= 0
        self.dut.qsfp_9_rx_rst_2 <= 0
        self.dut.qsfp_9_tx_rst_2 <= 0
        self.dut.qsfp_9_rx_rst_3 <= 0
        self.dut.qsfp_9_tx_rst_3 <= 0
        self.dut.qsfp_9_rx_rst_4 <= 0
        self.dut.qsfp_9_tx_rst_4 <= 0


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    tb.log.info("test UDP RX packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00')
    ip = IP(src='192.168.1.100', dst='192.168.1.128')
    udp = UDP(sport=5678, dport=1234)
    test_pkt = eth / ip / udp / payload

    test_frame = XgmiiFrame.from_payload(test_pkt.build())

    await tb.qsfp_1_1_source.send(test_frame)

    tb.log.info("receive ARP request")

    rx_frame = await tb.qsfp_1_1_sink.recv()

    rx_pkt = Ether(bytes(rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt.dst == 'ff:ff:ff:ff:ff:ff'
    assert rx_pkt.src == test_pkt.dst
    assert rx_pkt[ARP].hwtype == 1
    assert rx_pkt[ARP].ptype == 0x0800
    assert rx_pkt[ARP].hwlen == 6
    assert rx_pkt[ARP].plen == 4
    assert rx_pkt[ARP].op == 1
    assert rx_pkt[ARP].hwsrc == test_pkt.dst
    assert rx_pkt[ARP].psrc == test_pkt[IP].dst
    assert rx_pkt[ARP].hwdst == '00:00:00:00:00:00'
    assert rx_pkt[ARP].pdst == test_pkt[IP].src

    tb.log.info("send ARP response")

    eth = Ether(src=test_pkt.src, dst=test_pkt.dst)
    arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
        hwsrc=test_pkt.src, psrc=test_pkt[IP].src,
        hwdst=test_pkt.dst, pdst=test_pkt[IP].dst)
    resp_pkt = eth / arp

    resp_frame = XgmiiFrame.from_payload(resp_pkt.build())

    await tb.qsfp_1_1_source.send(resp_frame)

    tb.log.info("receive UDP packet")

    rx_frame = await tb.qsfp_1_1_sink.recv()

    rx_pkt = Ether(bytes(rx_frame.get_payload()))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt.dst == test_pkt.src
    assert rx_pkt.src == test_pkt.dst
    assert rx_pkt[IP].dst == test_pkt[IP].src
    assert rx_pkt[IP].src == test_pkt[IP].dst
    assert rx_pkt[UDP].dport == test_pkt[UDP].sport
    assert rx_pkt[UDP].sport == test_pkt[UDP].dport
    assert rx_pkt[UDP].payload == test_pkt[UDP].payload

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
        os.path.join(eth_rtl_dir, "eth_axis_tx.v"),
        os.path.join(eth_rtl_dir, "udp_complete_64.v"),
        os.path.join(eth_rtl_dir, "udp_checksum_gen_64.v"),
        os.path.join(eth_rtl_dir, "udp_64.v"),
        os.path.join(eth_rtl_dir, "udp_ip_rx_64.v"),
        os.path.join(eth_rtl_dir, "udp_ip_tx_64.v"),
        os.path.join(eth_rtl_dir, "ip_complete_64.v"),
        os.path.join(eth_rtl_dir, "ip_64.v"),
        os.path.join(eth_rtl_dir, "ip_eth_rx_64.v"),
        os.path.join(eth_rtl_dir, "ip_eth_tx_64.v"),
        os.path.join(eth_rtl_dir, "ip_arb_mux.v"),
        os.path.join(eth_rtl_dir, "arp.v"),
        os.path.join(eth_rtl_dir, "arp_cache.v"),
        os.path.join(eth_rtl_dir, "arp_eth_rx.v"),
        os.path.join(eth_rtl_dir, "arp_eth_tx.v"),
        os.path.join(eth_rtl_dir, "eth_arb_mux.v"),
        os.path.join(axis_rtl_dir, "arbiter.v"),
        os.path.join(axis_rtl_dir, "priority_encoder.v"),
        os.path.join(axis_rtl_dir, "axis_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
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
