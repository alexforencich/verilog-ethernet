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
import gmii_ep
import xgmii_ep

module = 'fpga_core'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/eth/rtl/eth_mac_1g_fifo.v")
srcs.append("../lib/eth/rtl/eth_mac_1g.v")
srcs.append("../lib/eth/rtl/axis_gmii_rx.v")
srcs.append("../lib/eth/rtl/axis_gmii_tx.v")
srcs.append("../lib/eth/rtl/eth_mac_10g_fifo.v")
srcs.append("../lib/eth/rtl/eth_mac_10g.v")
srcs.append("../lib/eth/rtl/axis_xgmii_rx_64.v")
srcs.append("../lib/eth/rtl/axis_xgmii_tx_64.v")
srcs.append("../lib/eth/rtl/lfsr.v")
srcs.append("../lib/eth/rtl/eth_axis_rx.v")
srcs.append("../lib/eth/rtl/eth_axis_tx.v")
srcs.append("../lib/eth/rtl/eth_axis_rx_64.v")
srcs.append("../lib/eth/rtl/eth_axis_tx_64.v")
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
srcs.append("../lib/eth/lib/axis/rtl/axis_adapter.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_fifo.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_switch.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_register.v")
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

    btnu = Signal(bool(0))
    btnl = Signal(bool(0))
    btnd = Signal(bool(0))
    btnr = Signal(bool(0))
    btnc = Signal(bool(0))
    sw = Signal(intbv(0)[4:])
    qsfp1_tx_clk_1 = Signal(bool(0))
    qsfp1_tx_rst_1 = Signal(bool(0))
    qsfp1_rx_clk_1 = Signal(bool(0))
    qsfp1_rx_rst_1 = Signal(bool(0))
    qsfp1_rxd_1 = Signal(intbv(0)[64:])
    qsfp1_rxc_1 = Signal(intbv(0)[8:])
    qsfp1_tx_clk_2 = Signal(bool(0))
    qsfp1_tx_rst_2 = Signal(bool(0))
    qsfp1_rx_clk_2 = Signal(bool(0))
    qsfp1_rx_rst_2 = Signal(bool(0))
    qsfp1_rxd_2 = Signal(intbv(0)[64:])
    qsfp1_rxc_2 = Signal(intbv(0)[8:])
    qsfp1_tx_clk_3 = Signal(bool(0))
    qsfp1_tx_rst_3 = Signal(bool(0))
    qsfp1_rx_clk_3 = Signal(bool(0))
    qsfp1_rx_rst_3 = Signal(bool(0))
    qsfp1_rxd_3 = Signal(intbv(0)[64:])
    qsfp1_rxc_3 = Signal(intbv(0)[8:])
    qsfp1_tx_clk_4 = Signal(bool(0))
    qsfp1_tx_rst_4 = Signal(bool(0))
    qsfp1_rx_clk_4 = Signal(bool(0))
    qsfp1_rx_rst_4 = Signal(bool(0))
    qsfp1_rxd_4 = Signal(intbv(0)[64:])
    qsfp1_rxc_4 = Signal(intbv(0)[8:])
    qsfp2_tx_clk_1 = Signal(bool(0))
    qsfp2_tx_rst_1 = Signal(bool(0))
    qsfp2_rx_clk_1 = Signal(bool(0))
    qsfp2_rx_rst_1 = Signal(bool(0))
    qsfp2_rxd_1 = Signal(intbv(0)[64:])
    qsfp2_rxc_1 = Signal(intbv(0)[8:])
    qsfp2_tx_clk_2 = Signal(bool(0))
    qsfp2_tx_rst_2 = Signal(bool(0))
    qsfp2_rx_clk_2 = Signal(bool(0))
    qsfp2_rx_rst_2 = Signal(bool(0))
    qsfp2_rxd_2 = Signal(intbv(0)[64:])
    qsfp2_rxc_2 = Signal(intbv(0)[8:])
    qsfp2_tx_clk_3 = Signal(bool(0))
    qsfp2_tx_rst_3 = Signal(bool(0))
    qsfp2_rx_clk_3 = Signal(bool(0))
    qsfp2_rx_rst_3 = Signal(bool(0))
    qsfp2_rxd_3 = Signal(intbv(0)[64:])
    qsfp2_rxc_3 = Signal(intbv(0)[8:])
    qsfp2_tx_clk_4 = Signal(bool(0))
    qsfp2_tx_rst_4 = Signal(bool(0))
    qsfp2_rx_clk_4 = Signal(bool(0))
    qsfp2_rx_rst_4 = Signal(bool(0))
    qsfp2_rxd_4 = Signal(intbv(0)[64:])
    qsfp2_rxc_4 = Signal(intbv(0)[8:])
    phy_gmii_clk = Signal(bool(0))
    phy_gmii_rst = Signal(bool(0))
    phy_gmii_clk_en = Signal(bool(0))
    phy_gmii_rxd = Signal(intbv(0)[8:])
    phy_gmii_rx_dv = Signal(bool(0))
    phy_gmii_rx_er = Signal(bool(0))
    phy_int_n = Signal(bool(1))
    uart_rxd = Signal(bool(0))
    uart_cts = Signal(bool(0))

    # Outputs
    led = Signal(intbv(0)[8:])
    qsfp1_txd_1 = Signal(intbv(0)[64:])
    qsfp1_txc_1 = Signal(intbv(0)[8:])
    qsfp1_txd_2 = Signal(intbv(0)[64:])
    qsfp1_txc_2 = Signal(intbv(0)[8:])
    qsfp1_txd_3 = Signal(intbv(0)[64:])
    qsfp1_txc_3 = Signal(intbv(0)[8:])
    qsfp1_txd_4 = Signal(intbv(0)[64:])
    qsfp1_txc_4 = Signal(intbv(0)[8:])
    qsfp2_txd_1 = Signal(intbv(0)[64:])
    qsfp2_txc_1 = Signal(intbv(0)[8:])
    qsfp2_txd_2 = Signal(intbv(0)[64:])
    qsfp2_txc_2 = Signal(intbv(0)[8:])
    qsfp2_txd_3 = Signal(intbv(0)[64:])
    qsfp2_txc_3 = Signal(intbv(0)[8:])
    qsfp2_txd_4 = Signal(intbv(0)[64:])
    qsfp2_txc_4 = Signal(intbv(0)[8:])
    phy_gmii_txd = Signal(intbv(0)[8:])
    phy_gmii_tx_en = Signal(bool(0))
    phy_gmii_tx_er = Signal(bool(0))
    phy_reset_n = Signal(bool(0))
    uart_txd = Signal(bool(0))
    uart_rts = Signal(bool(0))

    # sources and sinks
    qsfp1_1_source = xgmii_ep.XGMIISource()
    qsfp1_1_source_logic = qsfp1_1_source.create_logic(qsfp1_rx_clk_1, qsfp1_rx_rst_1, txd=qsfp1_rxd_1, txc=qsfp1_rxc_1, name='qsfp1_1_source')

    qsfp1_1_sink = xgmii_ep.XGMIISink()
    qsfp1_1_sink_logic = qsfp1_1_sink.create_logic(qsfp1_tx_clk_1, qsfp1_tx_rst_1, rxd=qsfp1_txd_1, rxc=qsfp1_txc_1, name='qsfp1_1_sink')

    qsfp1_2_source = xgmii_ep.XGMIISource()
    qsfp1_2_source_logic = qsfp1_2_source.create_logic(qsfp1_rx_clk_2, qsfp1_rx_rst_2, txd=qsfp1_rxd_2, txc=qsfp1_rxc_2, name='qsfp1_2_source')

    qsfp1_2_sink = xgmii_ep.XGMIISink()
    qsfp1_2_sink_logic = qsfp1_2_sink.create_logic(qsfp1_tx_clk_2, qsfp1_tx_rst_2, rxd=qsfp1_txd_2, rxc=qsfp1_txc_2, name='qsfp1_2_sink')

    qsfp1_3_source = xgmii_ep.XGMIISource()
    qsfp1_3_source_logic = qsfp1_3_source.create_logic(qsfp1_rx_clk_3, qsfp1_rx_rst_3, txd=qsfp1_rxd_3, txc=qsfp1_rxc_3, name='qsfp1_3_source')

    qsfp1_3_sink = xgmii_ep.XGMIISink()
    qsfp1_3_sink_logic = qsfp1_3_sink.create_logic(qsfp1_tx_clk_3, qsfp1_tx_rst_3, rxd=qsfp1_txd_3, rxc=qsfp1_txc_3, name='qsfp1_3_sink')

    qsfp1_4_source = xgmii_ep.XGMIISource()
    qsfp1_4_source_logic = qsfp1_4_source.create_logic(qsfp1_rx_clk_4, qsfp1_rx_rst_4, txd=qsfp1_rxd_4, txc=qsfp1_rxc_4, name='qsfp1_4_source')

    qsfp1_4_sink = xgmii_ep.XGMIISink()
    qsfp1_4_sink_logic = qsfp1_4_sink.create_logic(qsfp1_tx_clk_4, qsfp1_tx_rst_4, rxd=qsfp1_txd_4, rxc=qsfp1_txc_4, name='qsfp1_4_sink')

    qsfp2_1_source = xgmii_ep.XGMIISource()
    qsfp2_1_source_logic = qsfp2_1_source.create_logic(qsfp2_rx_clk_1, qsfp2_rx_rst_1, txd=qsfp2_rxd_1, txc=qsfp2_rxc_1, name='qsfp2_1_source')

    qsfp2_1_sink = xgmii_ep.XGMIISink()
    qsfp2_1_sink_logic = qsfp2_1_sink.create_logic(qsfp2_tx_clk_1, qsfp2_tx_rst_1, rxd=qsfp2_txd_1, rxc=qsfp2_txc_1, name='qsfp2_1_sink')

    qsfp2_2_source = xgmii_ep.XGMIISource()
    qsfp2_2_source_logic = qsfp2_2_source.create_logic(qsfp2_rx_clk_2, qsfp2_rx_rst_2, txd=qsfp2_rxd_2, txc=qsfp2_rxc_2, name='qsfp2_2_source')

    qsfp2_2_sink = xgmii_ep.XGMIISink()
    qsfp2_2_sink_logic = qsfp2_2_sink.create_logic(qsfp2_tx_clk_2, qsfp2_tx_rst_2, rxd=qsfp2_txd_2, rxc=qsfp2_txc_2, name='qsfp2_2_sink')

    qsfp2_3_source = xgmii_ep.XGMIISource()
    qsfp2_3_source_logic = qsfp2_3_source.create_logic(qsfp2_rx_clk_3, qsfp2_rx_rst_3, txd=qsfp2_rxd_3, txc=qsfp2_rxc_3, name='qsfp2_3_source')

    qsfp2_3_sink = xgmii_ep.XGMIISink()
    qsfp2_3_sink_logic = qsfp2_3_sink.create_logic(qsfp2_tx_clk_3, qsfp2_tx_rst_3, rxd=qsfp2_txd_3, rxc=qsfp2_txc_3, name='qsfp2_3_sink')

    qsfp2_4_source = xgmii_ep.XGMIISource()
    qsfp2_4_source_logic = qsfp2_4_source.create_logic(qsfp2_rx_clk_4, qsfp2_rx_rst_4, txd=qsfp2_rxd_4, txc=qsfp2_rxc_4, name='qsfp2_4_source')

    qsfp2_4_sink = xgmii_ep.XGMIISink()
    qsfp2_4_sink_logic = qsfp2_4_sink.create_logic(qsfp2_tx_clk_4, qsfp2_tx_rst_4, rxd=qsfp2_txd_4, rxc=qsfp2_txc_4, name='qsfp2_4_sink')

    gmii_source = gmii_ep.GMIISource()

    gmii_source_logic = gmii_source.create_logic(
        phy_gmii_clk,
        phy_gmii_rst,
        txd=phy_gmii_rxd,
        tx_en=phy_gmii_rx_dv,
        tx_er=phy_gmii_rx_er,
        clk_enable=phy_gmii_clk_en,
        name='gmii_source'
    )

    gmii_sink = gmii_ep.GMIISink()

    gmii_sink_logic = gmii_sink.create_logic(
        phy_gmii_clk,
        phy_gmii_rst,
        rxd=phy_gmii_txd,
        rx_dv=phy_gmii_tx_en,
        rx_er=phy_gmii_tx_er,
        clk_enable=phy_gmii_clk_en,
        name='gmii_sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        btnu=btnu,
        btnl=btnl,
        btnd=btnd,
        btnr=btnr,
        btnc=btnc,
        sw=sw,
        led=led,

        qsfp1_tx_clk_1=qsfp1_tx_clk_1,
        qsfp1_tx_rst_1=qsfp1_tx_rst_1,
        qsfp1_txd_1=qsfp1_txd_1,
        qsfp1_txc_1=qsfp1_txc_1,
        qsfp1_rx_clk_1=qsfp1_rx_clk_1,
        qsfp1_rx_rst_1=qsfp1_rx_rst_1,
        qsfp1_rxd_1=qsfp1_rxd_1,
        qsfp1_rxc_1=qsfp1_rxc_1,
        qsfp1_tx_clk_2=qsfp1_tx_clk_2,
        qsfp1_tx_rst_2=qsfp1_tx_rst_2,
        qsfp1_txd_2=qsfp1_txd_2,
        qsfp1_txc_2=qsfp1_txc_2,
        qsfp1_rx_clk_2=qsfp1_rx_clk_2,
        qsfp1_rx_rst_2=qsfp1_rx_rst_2,
        qsfp1_rxd_2=qsfp1_rxd_2,
        qsfp1_rxc_2=qsfp1_rxc_2,
        qsfp1_tx_clk_3=qsfp1_tx_clk_3,
        qsfp1_tx_rst_3=qsfp1_tx_rst_3,
        qsfp1_txd_3=qsfp1_txd_3,
        qsfp1_txc_3=qsfp1_txc_3,
        qsfp1_rx_clk_3=qsfp1_rx_clk_3,
        qsfp1_rx_rst_3=qsfp1_rx_rst_3,
        qsfp1_rxd_3=qsfp1_rxd_3,
        qsfp1_rxc_3=qsfp1_rxc_3,
        qsfp1_tx_clk_4=qsfp1_tx_clk_4,
        qsfp1_tx_rst_4=qsfp1_tx_rst_4,
        qsfp1_txd_4=qsfp1_txd_4,
        qsfp1_txc_4=qsfp1_txc_4,
        qsfp1_rx_clk_4=qsfp1_rx_clk_4,
        qsfp1_rx_rst_4=qsfp1_rx_rst_4,
        qsfp1_rxd_4=qsfp1_rxd_4,
        qsfp1_rxc_4=qsfp1_rxc_4,
        qsfp2_tx_clk_1=qsfp2_tx_clk_1,
        qsfp2_tx_rst_1=qsfp2_tx_rst_1,
        qsfp2_txd_1=qsfp2_txd_1,
        qsfp2_txc_1=qsfp2_txc_1,
        qsfp2_rx_clk_1=qsfp2_rx_clk_1,
        qsfp2_rx_rst_1=qsfp2_rx_rst_1,
        qsfp2_rxd_1=qsfp2_rxd_1,
        qsfp2_rxc_1=qsfp2_rxc_1,
        qsfp2_tx_clk_2=qsfp2_tx_clk_2,
        qsfp2_tx_rst_2=qsfp2_tx_rst_2,
        qsfp2_txd_2=qsfp2_txd_2,
        qsfp2_txc_2=qsfp2_txc_2,
        qsfp2_rx_clk_2=qsfp2_rx_clk_2,
        qsfp2_rx_rst_2=qsfp2_rx_rst_2,
        qsfp2_rxd_2=qsfp2_rxd_2,
        qsfp2_rxc_2=qsfp2_rxc_2,
        qsfp2_tx_clk_3=qsfp2_tx_clk_3,
        qsfp2_tx_rst_3=qsfp2_tx_rst_3,
        qsfp2_txd_3=qsfp2_txd_3,
        qsfp2_txc_3=qsfp2_txc_3,
        qsfp2_rx_clk_3=qsfp2_rx_clk_3,
        qsfp2_rx_rst_3=qsfp2_rx_rst_3,
        qsfp2_rxd_3=qsfp2_rxd_3,
        qsfp2_rxc_3=qsfp2_rxc_3,
        qsfp2_tx_clk_4=qsfp2_tx_clk_4,
        qsfp2_tx_rst_4=qsfp2_tx_rst_4,
        qsfp2_txd_4=qsfp2_txd_4,
        qsfp2_txc_4=qsfp2_txc_4,
        qsfp2_rx_clk_4=qsfp2_rx_clk_4,
        qsfp2_rx_rst_4=qsfp2_rx_rst_4,
        qsfp2_rxd_4=qsfp2_rxd_4,
        qsfp2_rxc_4=qsfp2_rxc_4,

        phy_gmii_clk=phy_gmii_clk,
        phy_gmii_rst=phy_gmii_rst,
        phy_gmii_clk_en=phy_gmii_clk_en,
        phy_gmii_rxd=phy_gmii_rxd,
        phy_gmii_rx_dv=phy_gmii_rx_dv,
        phy_gmii_rx_er=phy_gmii_rx_er,
        phy_gmii_txd=phy_gmii_txd,
        phy_gmii_tx_en=phy_gmii_tx_en,
        phy_gmii_tx_er=phy_gmii_tx_er,
        phy_reset_n=phy_reset_n,
        phy_int_n=phy_int_n,

        uart_rxd=uart_rxd,
        uart_txd=uart_txd,
        uart_rts=uart_rts,
        uart_cts=uart_cts
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        qsfp1_tx_clk_1.next = not qsfp1_tx_clk_1
        qsfp1_rx_clk_1.next = not qsfp1_rx_clk_1
        qsfp1_tx_clk_2.next = not qsfp1_tx_clk_2
        qsfp1_rx_clk_2.next = not qsfp1_rx_clk_2
        qsfp1_tx_clk_3.next = not qsfp1_tx_clk_3
        qsfp1_rx_clk_3.next = not qsfp1_rx_clk_3
        qsfp1_tx_clk_4.next = not qsfp1_tx_clk_4
        qsfp1_rx_clk_4.next = not qsfp1_rx_clk_4
        qsfp2_tx_clk_1.next = not qsfp2_tx_clk_1
        qsfp2_rx_clk_1.next = not qsfp2_rx_clk_1
        qsfp2_tx_clk_2.next = not qsfp2_tx_clk_2
        qsfp2_rx_clk_2.next = not qsfp2_rx_clk_2
        qsfp2_tx_clk_3.next = not qsfp2_tx_clk_3
        qsfp2_rx_clk_3.next = not qsfp2_rx_clk_3
        qsfp2_tx_clk_4.next = not qsfp2_tx_clk_4
        qsfp2_rx_clk_4.next = not qsfp2_rx_clk_4
        phy_gmii_clk.next = not phy_gmii_clk

    clk_enable_rate = Signal(int(0))
    clk_enable_div = Signal(int(0))

    @always(clk.posedge)
    def clk_enable_gen():
        if clk_enable_div.next > 0:
            phy_gmii_clk_en.next = 0
            clk_enable_div.next = clk_enable_div - 1
        else:
            phy_gmii_clk_en.next = 1
            clk_enable_div.next = clk_enable_rate - 1

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        qsfp1_tx_rst_1.next = 1
        qsfp1_rx_rst_1.next = 1
        qsfp1_tx_rst_2.next = 1
        qsfp1_rx_rst_2.next = 1
        qsfp1_tx_rst_3.next = 1
        qsfp1_rx_rst_3.next = 1
        qsfp1_tx_rst_4.next = 1
        qsfp1_rx_rst_4.next = 1
        qsfp2_tx_rst_1.next = 1
        qsfp2_rx_rst_1.next = 1
        qsfp2_tx_rst_2.next = 1
        qsfp2_rx_rst_2.next = 1
        qsfp2_tx_rst_3.next = 1
        qsfp2_rx_rst_3.next = 1
        qsfp2_tx_rst_4.next = 1
        qsfp2_rx_rst_4.next = 1
        phy_gmii_rst.next = 1
        yield clk.posedge
        rst.next = 0
        qsfp1_tx_rst_1.next = 0
        qsfp1_rx_rst_1.next = 0
        qsfp1_tx_rst_2.next = 0
        qsfp1_rx_rst_2.next = 0
        qsfp1_tx_rst_3.next = 0
        qsfp1_rx_rst_3.next = 0
        qsfp1_tx_rst_4.next = 0
        qsfp1_rx_rst_4.next = 0
        qsfp2_tx_rst_1.next = 0
        qsfp2_rx_rst_1.next = 0
        qsfp2_tx_rst_2.next = 0
        qsfp2_rx_rst_2.next = 0
        qsfp2_tx_rst_3.next = 0
        qsfp2_rx_rst_3.next = 0
        qsfp2_tx_rst_4.next = 0
        qsfp2_rx_rst_4.next = 0
        phy_gmii_rst.next = 0
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

        qsfp1_1_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # wait for ARP request packet
        while qsfp1_1_sink.empty():
            yield clk.posedge

        rx_frame = qsfp1_1_sink.recv()
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

        qsfp1_1_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+arp_frame.build_eth().build_axis_fcs().data)

        while qsfp1_1_sink.empty():
            yield clk.posedge

        rx_frame = qsfp1_1_sink.recv()
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

        assert qsfp1_1_source.empty()
        assert qsfp1_1_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 2: test gigabit tap")
        current_test.next = 2

        sw.next = 0x8 # enable tap on RX

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

        gmii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # loop packet back through on XGMII interface
        while qsfp1_1_sink.empty():
            yield clk.posedge

        qsfp1_1_source.send(qsfp1_1_sink.recv())

        while gmii_sink.empty():
            yield clk.posedge

        rx_frame = gmii_sink.recv()
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

        assert gmii_source.empty()
        assert gmii_sink.empty()
        assert qsfp1_1_source.empty()
        assert qsfp1_1_sink.empty()

        yield delay(100)

        sw.next = 0xc # enable tap on TX

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

        gmii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # loop packet back through on XGMII interface
        while qsfp1_1_sink.empty():
            yield clk.posedge

        qsfp1_1_source.send(qsfp1_1_sink.recv())

        while gmii_sink.empty():
            yield clk.posedge

        rx_frame = gmii_sink.recv()
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

        assert gmii_source.empty()
        assert gmii_sink.empty()
        assert qsfp1_1_source.empty()
        assert qsfp1_1_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
