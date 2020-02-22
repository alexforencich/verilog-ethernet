#!/usr/bin/env python
"""

Copyright (c) 2016-2018 Alex Forencich

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

from myhdl import *
import os

import eth_ep
import arp_ep
import udp_ep
import xgmii_ep

module = 'fpga_core'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/eth/rtl/eth_mac_10g_fifo.v")
srcs.append("../lib/eth/rtl/eth_mac_10g.v")
srcs.append("../lib/eth/rtl/axis_xgmii_rx_64.v")
srcs.append("../lib/eth/rtl/axis_xgmii_tx_64.v")
srcs.append("../lib/eth/rtl/lfsr.v")
srcs.append("../lib/eth/rtl/eth_axis_rx.v")
srcs.append("../lib/eth/rtl/eth_axis_tx.v")
srcs.append("../lib/eth/rtl/udp_complete_64.v")
srcs.append("../lib/eth/rtl/udp_checksum_gen_64.v")
srcs.append("../lib/eth/rtl/udp_64.v")
srcs.append("../lib/eth/rtl/udp_ip_rx_64.v")
srcs.append("../lib/eth/rtl/udp_ip_tx_64.v")
srcs.append("../lib/eth/rtl/ip_complete_64.v")
srcs.append("../lib/eth/rtl/ip_64.v")
srcs.append("../lib/eth/rtl/ip_eth_rx_64.v")
srcs.append("../lib/eth/rtl/ip_eth_tx_64.v")
srcs.append("../lib/eth/rtl/ip_arb_mux.v")
srcs.append("../lib/eth/rtl/arp.v")
srcs.append("../lib/eth/rtl/arp_cache.v")
srcs.append("../lib/eth/rtl/arp_eth_rx.v")
srcs.append("../lib/eth/rtl/arp_eth_tx.v")
srcs.append("../lib/eth/rtl/eth_arb_mux.v")
srcs.append("../lib/eth/lib/axis/rtl/arbiter.v")
srcs.append("../lib/eth/lib/axis/rtl/priority_encoder.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_fifo.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_async_fifo.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    sw = Signal(intbv(0)[2:])
    jp = Signal(intbv(0)[4:])
    uart_suspend = Signal(bool(0))
    uart_dtr = Signal(bool(0))
    uart_txd = Signal(bool(0))
    uart_rts = Signal(bool(0))
    amh_right_mdio_i = Signal(bool(0))
    amh_left_mdio_i = Signal(bool(0))
    eth_r0_rxd = Signal(intbv(0)[64:])
    eth_r0_rxc = Signal(intbv(0)[8:])
    eth_r1_rxd = Signal(intbv(0)[64:])
    eth_r1_rxc = Signal(intbv(0)[8:])
    eth_r2_rxd = Signal(intbv(0)[64:])
    eth_r2_rxc = Signal(intbv(0)[8:])
    eth_r3_rxd = Signal(intbv(0)[64:])
    eth_r3_rxc = Signal(intbv(0)[8:])
    eth_r4_rxd = Signal(intbv(0)[64:])
    eth_r4_rxc = Signal(intbv(0)[8:])
    eth_r5_rxd = Signal(intbv(0)[64:])
    eth_r5_rxc = Signal(intbv(0)[8:])
    eth_r6_rxd = Signal(intbv(0)[64:])
    eth_r6_rxc = Signal(intbv(0)[8:])
    eth_r7_rxd = Signal(intbv(0)[64:])
    eth_r7_rxc = Signal(intbv(0)[8:])
    eth_r8_rxd = Signal(intbv(0)[64:])
    eth_r8_rxc = Signal(intbv(0)[8:])
    eth_r9_rxd = Signal(intbv(0)[64:])
    eth_r9_rxc = Signal(intbv(0)[8:])
    eth_r10_rxd = Signal(intbv(0)[64:])
    eth_r10_rxc = Signal(intbv(0)[8:])
    eth_r11_rxd = Signal(intbv(0)[64:])
    eth_r11_rxc = Signal(intbv(0)[8:])
    eth_l0_rxd = Signal(intbv(0)[64:])
    eth_l0_rxc = Signal(intbv(0)[8:])
    eth_l1_rxd = Signal(intbv(0)[64:])
    eth_l1_rxc = Signal(intbv(0)[8:])
    eth_l2_rxd = Signal(intbv(0)[64:])
    eth_l2_rxc = Signal(intbv(0)[8:])
    eth_l3_rxd = Signal(intbv(0)[64:])
    eth_l3_rxc = Signal(intbv(0)[8:])
    eth_l4_rxd = Signal(intbv(0)[64:])
    eth_l4_rxc = Signal(intbv(0)[8:])
    eth_l5_rxd = Signal(intbv(0)[64:])
    eth_l5_rxc = Signal(intbv(0)[8:])
    eth_l6_rxd = Signal(intbv(0)[64:])
    eth_l6_rxc = Signal(intbv(0)[8:])
    eth_l7_rxd = Signal(intbv(0)[64:])
    eth_l7_rxc = Signal(intbv(0)[8:])
    eth_l8_rxd = Signal(intbv(0)[64:])
    eth_l8_rxc = Signal(intbv(0)[8:])
    eth_l9_rxd = Signal(intbv(0)[64:])
    eth_l9_rxc = Signal(intbv(0)[8:])
    eth_l10_rxd = Signal(intbv(0)[64:])
    eth_l10_rxc = Signal(intbv(0)[8:])
    eth_l11_rxd = Signal(intbv(0)[64:])
    eth_l11_rxc = Signal(intbv(0)[8:])

    # Outputs
    led = Signal(intbv(0)[4:])
    uart_rst = Signal(bool(0))
    uart_ri = Signal(bool(0))
    uart_dcd = Signal(bool(0))
    uart_dsr = Signal(bool(0))
    uart_rxd = Signal(bool(1))
    uart_cts = Signal(bool(0))
    amh_right_mdc = Signal(bool(1))
    amh_right_mdio_o = Signal(bool(1))
    amh_right_mdio_t = Signal(bool(1))
    amh_left_mdc = Signal(bool(1))
    amh_left_mdio_o = Signal(bool(1))
    amh_left_mdio_t = Signal(bool(1))
    eth_r0_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r0_txc = Signal(intbv(0xff)[8:])
    eth_r1_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r1_txc = Signal(intbv(0xff)[8:])
    eth_r2_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r2_txc = Signal(intbv(0xff)[8:])
    eth_r3_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r3_txc = Signal(intbv(0xff)[8:])
    eth_r4_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r4_txc = Signal(intbv(0xff)[8:])
    eth_r5_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r5_txc = Signal(intbv(0xff)[8:])
    eth_r6_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r6_txc = Signal(intbv(0xff)[8:])
    eth_r7_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r7_txc = Signal(intbv(0xff)[8:])
    eth_r8_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r8_txc = Signal(intbv(0xff)[8:])
    eth_r9_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r9_txc = Signal(intbv(0xff)[8:])
    eth_r10_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r10_txc = Signal(intbv(0xff)[8:])
    eth_r11_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_r11_txc = Signal(intbv(0xff)[8:])
    eth_l0_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l0_txc = Signal(intbv(0xff)[8:])
    eth_l1_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l1_txc = Signal(intbv(0xff)[8:])
    eth_l2_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l2_txc = Signal(intbv(0xff)[8:])
    eth_l3_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l3_txc = Signal(intbv(0xff)[8:])
    eth_l4_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l4_txc = Signal(intbv(0xff)[8:])
    eth_l5_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l5_txc = Signal(intbv(0xff)[8:])
    eth_l6_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l6_txc = Signal(intbv(0xff)[8:])
    eth_l7_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l7_txc = Signal(intbv(0xff)[8:])
    eth_l8_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l8_txc = Signal(intbv(0xff)[8:])
    eth_l9_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l9_txc = Signal(intbv(0xff)[8:])
    eth_l10_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l10_txc = Signal(intbv(0xff)[8:])
    eth_l11_txd = Signal(intbv(0x0707070707070707)[64:])
    eth_l11_txc = Signal(intbv(0xff)[8:])

    # sources and sinks
    eth_r0_source = xgmii_ep.XGMIISource()
    eth_r0_source_logic = eth_r0_source.create_logic(clk, rst, txd=eth_r0_rxd, txc=eth_r0_rxc, name='eth_r0_source')

    eth_r0_sink = xgmii_ep.XGMIISink()
    eth_r0_sink_logic = eth_r0_sink.create_logic(clk, rst, rxd=eth_r0_txd, rxc=eth_r0_txc, name='eth_r0_sink')

    eth_r1_source = xgmii_ep.XGMIISource()
    eth_r1_source_logic = eth_r1_source.create_logic(clk, rst, txd=eth_r1_rxd, txc=eth_r1_rxc, name='eth_r1_source')

    eth_r1_sink = xgmii_ep.XGMIISink()
    eth_r1_sink_logic = eth_r1_sink.create_logic(clk, rst, rxd=eth_r1_txd, rxc=eth_r1_txc, name='eth_r1_sink')

    eth_r2_source = xgmii_ep.XGMIISource()
    eth_r2_source_logic = eth_r2_source.create_logic(clk, rst, txd=eth_r2_rxd, txc=eth_r2_rxc, name='eth_r2_source')

    eth_r2_sink = xgmii_ep.XGMIISink()
    eth_r2_sink_logic = eth_r2_sink.create_logic(clk, rst, rxd=eth_r2_txd, rxc=eth_r2_txc, name='eth_r2_sink')

    eth_r3_source = xgmii_ep.XGMIISource()
    eth_r3_source_logic = eth_r3_source.create_logic(clk, rst, txd=eth_r3_rxd, txc=eth_r3_rxc, name='eth_r3_source')

    eth_r3_sink = xgmii_ep.XGMIISink()
    eth_r3_sink_logic = eth_r3_sink.create_logic(clk, rst, rxd=eth_r3_txd, rxc=eth_r3_txc, name='eth_r3_sink')

    eth_r4_source = xgmii_ep.XGMIISource()
    eth_r4_source_logic = eth_r4_source.create_logic(clk, rst, txd=eth_r4_rxd, txc=eth_r4_rxc, name='eth_r4_source')

    eth_r4_sink = xgmii_ep.XGMIISink()
    eth_r4_sink_logic = eth_r4_sink.create_logic(clk, rst, rxd=eth_r4_txd, rxc=eth_r4_txc, name='eth_r4_sink')

    eth_r5_source = xgmii_ep.XGMIISource()
    eth_r5_source_logic = eth_r5_source.create_logic(clk, rst, txd=eth_r5_rxd, txc=eth_r5_rxc, name='eth_r5_source')

    eth_r5_sink = xgmii_ep.XGMIISink()
    eth_r5_sink_logic = eth_r5_sink.create_logic(clk, rst, rxd=eth_r5_txd, rxc=eth_r5_txc, name='eth_r5_sink')

    eth_r6_source = xgmii_ep.XGMIISource()
    eth_r6_source_logic = eth_r6_source.create_logic(clk, rst, txd=eth_r6_rxd, txc=eth_r6_rxc, name='eth_r6_source')

    eth_r6_sink = xgmii_ep.XGMIISink()
    eth_r6_sink_logic = eth_r6_sink.create_logic(clk, rst, rxd=eth_r6_txd, rxc=eth_r6_txc, name='eth_r6_sink')

    eth_r7_source = xgmii_ep.XGMIISource()
    eth_r7_source_logic = eth_r7_source.create_logic(clk, rst, txd=eth_r7_rxd, txc=eth_r7_rxc, name='eth_r7_source')

    eth_r7_sink = xgmii_ep.XGMIISink()
    eth_r7_sink_logic = eth_r7_sink.create_logic(clk, rst, rxd=eth_r7_txd, rxc=eth_r7_txc, name='eth_r7_sink')

    eth_r8_source = xgmii_ep.XGMIISource()
    eth_r8_source_logic = eth_r8_source.create_logic(clk, rst, txd=eth_r8_rxd, txc=eth_r8_rxc, name='eth_r8_source')

    eth_r8_sink = xgmii_ep.XGMIISink()
    eth_r8_sink_logic = eth_r8_sink.create_logic(clk, rst, rxd=eth_r8_txd, rxc=eth_r8_txc, name='eth_r8_sink')

    eth_r9_source = xgmii_ep.XGMIISource()
    eth_r9_source_logic = eth_r9_source.create_logic(clk, rst, txd=eth_r9_rxd, txc=eth_r9_rxc, name='eth_r9_source')

    eth_r9_sink = xgmii_ep.XGMIISink()
    eth_r9_sink_logic = eth_r9_sink.create_logic(clk, rst, rxd=eth_r9_txd, rxc=eth_r9_txc, name='eth_r9_sink')

    eth_r10_source = xgmii_ep.XGMIISource()
    eth_r10_source_logic = eth_r10_source.create_logic(clk, rst, txd=eth_r10_rxd, txc=eth_r10_rxc, name='eth_r10_source')

    eth_r10_sink = xgmii_ep.XGMIISink()
    eth_r10_sink_logic = eth_r10_sink.create_logic(clk, rst, rxd=eth_r10_txd, rxc=eth_r10_txc, name='eth_r10_sink')

    eth_r11_source = xgmii_ep.XGMIISource()
    eth_r11_source_logic = eth_r11_source.create_logic(clk, rst, txd=eth_r11_rxd, txc=eth_r11_rxc, name='eth_r11_source')

    eth_r11_sink = xgmii_ep.XGMIISink()
    eth_r11_sink_logic = eth_r11_sink.create_logic(clk, rst, rxd=eth_r11_txd, rxc=eth_r11_txc, name='eth_r11_sink')

    eth_l0_source = xgmii_ep.XGMIISource()
    eth_l0_source_logic = eth_l0_source.create_logic(clk, rst, txd=eth_l0_rxd, txc=eth_l0_rxc, name='eth_l0_source')

    eth_l0_sink = xgmii_ep.XGMIISink()
    eth_l0_sink_logic = eth_l0_sink.create_logic(clk, rst, rxd=eth_l0_txd, rxc=eth_l0_txc, name='eth_l0_sink')

    eth_l1_source = xgmii_ep.XGMIISource()
    eth_l1_source_logic = eth_l1_source.create_logic(clk, rst, txd=eth_l1_rxd, txc=eth_l1_rxc, name='eth_l1_source')

    eth_l1_sink = xgmii_ep.XGMIISink()
    eth_l1_sink_logic = eth_l1_sink.create_logic(clk, rst, rxd=eth_l1_txd, rxc=eth_l1_txc, name='eth_l1_sink')

    eth_l2_source = xgmii_ep.XGMIISource()
    eth_l2_source_logic = eth_l2_source.create_logic(clk, rst, txd=eth_l2_rxd, txc=eth_l2_rxc, name='eth_l2_source')

    eth_l2_sink = xgmii_ep.XGMIISink()
    eth_l2_sink_logic = eth_l2_sink.create_logic(clk, rst, rxd=eth_l2_txd, rxc=eth_l2_txc, name='eth_l2_sink')

    eth_l3_source = xgmii_ep.XGMIISource()
    eth_l3_source_logic = eth_l3_source.create_logic(clk, rst, txd=eth_l3_rxd, txc=eth_l3_rxc, name='eth_l3_source')

    eth_l3_sink = xgmii_ep.XGMIISink()
    eth_l3_sink_logic = eth_l3_sink.create_logic(clk, rst, rxd=eth_l3_txd, rxc=eth_l3_txc, name='eth_l3_sink')

    eth_l4_source = xgmii_ep.XGMIISource()
    eth_l4_source_logic = eth_l4_source.create_logic(clk, rst, txd=eth_l4_rxd, txc=eth_l4_rxc, name='eth_l4_source')

    eth_l4_sink = xgmii_ep.XGMIISink()
    eth_l4_sink_logic = eth_l4_sink.create_logic(clk, rst, rxd=eth_l4_txd, rxc=eth_l4_txc, name='eth_l4_sink')

    eth_l5_source = xgmii_ep.XGMIISource()
    eth_l5_source_logic = eth_l5_source.create_logic(clk, rst, txd=eth_l5_rxd, txc=eth_l5_rxc, name='eth_l5_source')

    eth_l5_sink = xgmii_ep.XGMIISink()
    eth_l5_sink_logic = eth_l5_sink.create_logic(clk, rst, rxd=eth_l5_txd, rxc=eth_l5_txc, name='eth_l5_sink')

    eth_l6_source = xgmii_ep.XGMIISource()
    eth_l6_source_logic = eth_l6_source.create_logic(clk, rst, txd=eth_l6_rxd, txc=eth_l6_rxc, name='eth_l6_source')

    eth_l6_sink = xgmii_ep.XGMIISink()
    eth_l6_sink_logic = eth_l6_sink.create_logic(clk, rst, rxd=eth_l6_txd, rxc=eth_l6_txc, name='eth_l6_sink')

    eth_l7_source = xgmii_ep.XGMIISource()
    eth_l7_source_logic = eth_l7_source.create_logic(clk, rst, txd=eth_l7_rxd, txc=eth_l7_rxc, name='eth_l7_source')

    eth_l7_sink = xgmii_ep.XGMIISink()
    eth_l7_sink_logic = eth_l7_sink.create_logic(clk, rst, rxd=eth_l7_txd, rxc=eth_l7_txc, name='eth_l7_sink')

    eth_l8_source = xgmii_ep.XGMIISource()
    eth_l8_source_logic = eth_l8_source.create_logic(clk, rst, txd=eth_l8_rxd, txc=eth_l8_rxc, name='eth_l8_source')

    eth_l8_sink = xgmii_ep.XGMIISink()
    eth_l8_sink_logic = eth_l8_sink.create_logic(clk, rst, rxd=eth_l8_txd, rxc=eth_l8_txc, name='eth_l8_sink')

    eth_l9_source = xgmii_ep.XGMIISource()
    eth_l9_source_logic = eth_l9_source.create_logic(clk, rst, txd=eth_l9_rxd, txc=eth_l9_rxc, name='eth_l9_source')

    eth_l9_sink = xgmii_ep.XGMIISink()
    eth_l9_sink_logic = eth_l9_sink.create_logic(clk, rst, rxd=eth_l9_txd, rxc=eth_l9_txc, name='eth_l9_sink')

    eth_l10_source = xgmii_ep.XGMIISource()
    eth_l10_source_logic = eth_l10_source.create_logic(clk, rst, txd=eth_l10_rxd, txc=eth_l10_rxc, name='eth_l10_source')

    eth_l10_sink = xgmii_ep.XGMIISink()
    eth_l10_sink_logic = eth_l10_sink.create_logic(clk, rst, rxd=eth_l10_txd, rxc=eth_l10_txc, name='eth_l10_sink')

    eth_l11_source = xgmii_ep.XGMIISource()
    eth_l11_source_logic = eth_l11_source.create_logic(clk, rst, txd=eth_l11_rxd, txc=eth_l11_rxc, name='eth_l11_source')

    eth_l11_sink = xgmii_ep.XGMIISink()
    eth_l11_sink_logic = eth_l11_sink.create_logic(clk, rst, rxd=eth_l11_txd, rxc=eth_l11_txc, name='eth_l11_sink')

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        sw=sw,
        jp=jp,
        led=led,

        uart_rst=uart_rst,
        uart_suspend=uart_suspend,
        uart_ri=uart_ri,
        uart_dcd=uart_dcd,
        uart_dtr=uart_dtr,
        uart_dsr=uart_dsr,
        uart_txd=uart_txd,
        uart_rxd=uart_rxd,
        uart_rts=uart_rts,
        uart_cts=uart_cts,

        amh_right_mdc=amh_right_mdc,
        amh_right_mdio_i=amh_right_mdio_i,
        amh_right_mdio_o=amh_right_mdio_o,
        amh_right_mdio_t=amh_right_mdio_t,
        amh_left_mdc=amh_left_mdc,
        amh_left_mdio_i=amh_left_mdio_i,
        amh_left_mdio_o=amh_left_mdio_o,
        amh_left_mdio_t=amh_left_mdio_t,

        eth_r0_txd=eth_r0_txd,
        eth_r0_txc=eth_r0_txc,
        eth_r0_rxd=eth_r0_rxd,
        eth_r0_rxc=eth_r0_rxc,
        eth_r1_txd=eth_r1_txd,
        eth_r1_txc=eth_r1_txc,
        eth_r1_rxd=eth_r1_rxd,
        eth_r1_rxc=eth_r1_rxc,
        eth_r2_txd=eth_r2_txd,
        eth_r2_txc=eth_r2_txc,
        eth_r2_rxd=eth_r2_rxd,
        eth_r2_rxc=eth_r2_rxc,
        eth_r3_txd=eth_r3_txd,
        eth_r3_txc=eth_r3_txc,
        eth_r3_rxd=eth_r3_rxd,
        eth_r3_rxc=eth_r3_rxc,
        eth_r4_txd=eth_r4_txd,
        eth_r4_txc=eth_r4_txc,
        eth_r4_rxd=eth_r4_rxd,
        eth_r4_rxc=eth_r4_rxc,
        eth_r5_txd=eth_r5_txd,
        eth_r5_txc=eth_r5_txc,
        eth_r5_rxd=eth_r5_rxd,
        eth_r5_rxc=eth_r5_rxc,
        eth_r6_txd=eth_r6_txd,
        eth_r6_txc=eth_r6_txc,
        eth_r6_rxd=eth_r6_rxd,
        eth_r6_rxc=eth_r6_rxc,
        eth_r7_txd=eth_r7_txd,
        eth_r7_txc=eth_r7_txc,
        eth_r7_rxd=eth_r7_rxd,
        eth_r7_rxc=eth_r7_rxc,
        eth_r8_txd=eth_r8_txd,
        eth_r8_txc=eth_r8_txc,
        eth_r8_rxd=eth_r8_rxd,
        eth_r8_rxc=eth_r8_rxc,
        eth_r9_txd=eth_r9_txd,
        eth_r9_txc=eth_r9_txc,
        eth_r9_rxd=eth_r9_rxd,
        eth_r9_rxc=eth_r9_rxc,
        eth_r10_txd=eth_r10_txd,
        eth_r10_txc=eth_r10_txc,
        eth_r10_rxd=eth_r10_rxd,
        eth_r10_rxc=eth_r10_rxc,
        eth_r11_txd=eth_r11_txd,
        eth_r11_txc=eth_r11_txc,
        eth_r11_rxd=eth_r11_rxd,
        eth_r11_rxc=eth_r11_rxc,
        eth_l0_txd=eth_l0_txd,
        eth_l0_txc=eth_l0_txc,
        eth_l0_rxd=eth_l0_rxd,
        eth_l0_rxc=eth_l0_rxc,
        eth_l1_txd=eth_l1_txd,
        eth_l1_txc=eth_l1_txc,
        eth_l1_rxd=eth_l1_rxd,
        eth_l1_rxc=eth_l1_rxc,
        eth_l2_txd=eth_l2_txd,
        eth_l2_txc=eth_l2_txc,
        eth_l2_rxd=eth_l2_rxd,
        eth_l2_rxc=eth_l2_rxc,
        eth_l3_txd=eth_l3_txd,
        eth_l3_txc=eth_l3_txc,
        eth_l3_rxd=eth_l3_rxd,
        eth_l3_rxc=eth_l3_rxc,
        eth_l4_txd=eth_l4_txd,
        eth_l4_txc=eth_l4_txc,
        eth_l4_rxd=eth_l4_rxd,
        eth_l4_rxc=eth_l4_rxc,
        eth_l5_txd=eth_l5_txd,
        eth_l5_txc=eth_l5_txc,
        eth_l5_rxd=eth_l5_rxd,
        eth_l5_rxc=eth_l5_rxc,
        eth_l6_txd=eth_l6_txd,
        eth_l6_txc=eth_l6_txc,
        eth_l6_rxd=eth_l6_rxd,
        eth_l6_rxc=eth_l6_rxc,
        eth_l7_txd=eth_l7_txd,
        eth_l7_txc=eth_l7_txc,
        eth_l7_rxd=eth_l7_rxd,
        eth_l7_rxc=eth_l7_rxc,
        eth_l8_txd=eth_l8_txd,
        eth_l8_txc=eth_l8_txc,
        eth_l8_rxd=eth_l8_rxd,
        eth_l8_rxc=eth_l8_rxc,
        eth_l9_txd=eth_l9_txd,
        eth_l9_txc=eth_l9_txc,
        eth_l9_rxd=eth_l9_rxd,
        eth_l9_rxc=eth_l9_rxc,
        eth_l10_txd=eth_l10_txd,
        eth_l10_txc=eth_l10_txc,
        eth_l10_rxd=eth_l10_rxd,
        eth_l10_rxc=eth_l10_rxc,
        eth_l11_txd=eth_l11_txd,
        eth_l11_txc=eth_l11_txc,
        eth_l11_rxd=eth_l11_rxd,
        eth_l11_rxc=eth_l11_rxc
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        # testbench stimulus

        yield clk.posedge
        print("test 1: test UDP RX packet")
        current_test.next = 1

        test_frame = udp_ep.UDPFrame()
        test_frame.eth_dest_mac = 0x020000000000
        test_frame.eth_src_mac = 0xDAD1D2D3D4D5
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 5
        test_frame.ip_dscp = 0
        test_frame.ip_ecn = 0
        test_frame.ip_length = None
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80181
        test_frame.ip_dest_ip = 0xc0a80180
        test_frame.udp_source_port = 5678
        test_frame.udp_dest_port = 1234
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        eth_l0_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # wait for ARP request packet
        while eth_l0_sink.empty():
            yield clk.posedge

        rx_frame = eth_l0_sink.recv()
        check_eth_frame = eth_ep.EthFrame()
        check_eth_frame.parse_axis_fcs(rx_frame.data[8:])
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(check_eth_frame)

        print(check_frame)

        assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
        assert check_frame.eth_src_mac == 0x020000000000
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 1
        assert check_frame.arp_sha == 0x020000000000
        assert check_frame.arp_spa == 0xc0a80180
        assert check_frame.arp_tha == 0x000000000000
        assert check_frame.arp_tpa == 0xc0a80181

        # generate response
        arp_frame = arp_ep.ARPFrame()
        arp_frame.eth_dest_mac = 0x020000000000
        arp_frame.eth_src_mac = 0xDAD1D2D3D4D5
        arp_frame.eth_type = 0x0806
        arp_frame.arp_htype = 0x0001
        arp_frame.arp_ptype = 0x0800
        arp_frame.arp_hlen = 6
        arp_frame.arp_plen = 4
        arp_frame.arp_oper = 2
        arp_frame.arp_sha = 0xDAD1D2D3D4D5
        arp_frame.arp_spa = 0xc0a80181
        arp_frame.arp_tha = 0x020000000000
        arp_frame.arp_tpa = 0xc0a80180

        eth_l0_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+arp_frame.build_eth().build_axis_fcs().data)

        while eth_l0_sink.empty():
            yield clk.posedge

        rx_frame = eth_l0_sink.recv()
        check_eth_frame = eth_ep.EthFrame()
        check_eth_frame.parse_axis_fcs(rx_frame.data[8:])
        check_frame = udp_ep.UDPFrame()
        check_frame.parse_eth(check_eth_frame)

        print(check_frame)

        assert check_frame.eth_dest_mac == 0xDAD1D2D3D4D5
        assert check_frame.eth_src_mac == 0x020000000000
        assert check_frame.eth_type == 0x0800
        assert check_frame.ip_version == 4
        assert check_frame.ip_ihl == 5
        assert check_frame.ip_dscp == 0
        assert check_frame.ip_ecn == 0
        assert check_frame.ip_identification == 0
        assert check_frame.ip_flags == 2
        assert check_frame.ip_fragment_offset == 0
        assert check_frame.ip_ttl == 64
        assert check_frame.ip_protocol == 0x11
        assert check_frame.ip_source_ip == 0xc0a80180
        assert check_frame.ip_dest_ip == 0xc0a80181
        assert check_frame.udp_source_port == 1234
        assert check_frame.udp_dest_port == 5678
        assert check_frame.payload.data == bytearray(range(32))

        assert eth_l0_source.empty()
        assert eth_l0_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
