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

    qsfp0_tx_clk_1 = Signal(bool(0))
    qsfp0_tx_rst_1 = Signal(bool(0))
    qsfp0_rx_clk_1 = Signal(bool(0))
    qsfp0_rx_rst_1 = Signal(bool(0))
    qsfp0_rxd_1 = Signal(intbv(0)[64:])
    qsfp0_rxc_1 = Signal(intbv(0)[8:])
    qsfp0_tx_clk_2 = Signal(bool(0))
    qsfp0_tx_rst_2 = Signal(bool(0))
    qsfp0_rx_clk_2 = Signal(bool(0))
    qsfp0_rx_rst_2 = Signal(bool(0))
    qsfp0_rxd_2 = Signal(intbv(0)[64:])
    qsfp0_rxc_2 = Signal(intbv(0)[8:])
    qsfp0_tx_clk_3 = Signal(bool(0))
    qsfp0_tx_rst_3 = Signal(bool(0))
    qsfp0_rx_clk_3 = Signal(bool(0))
    qsfp0_rx_rst_3 = Signal(bool(0))
    qsfp0_rxd_3 = Signal(intbv(0)[64:])
    qsfp0_rxc_3 = Signal(intbv(0)[8:])
    qsfp0_tx_clk_4 = Signal(bool(0))
    qsfp0_tx_rst_4 = Signal(bool(0))
    qsfp0_rx_clk_4 = Signal(bool(0))
    qsfp0_rx_rst_4 = Signal(bool(0))
    qsfp0_rxd_4 = Signal(intbv(0)[64:])
    qsfp0_rxc_4 = Signal(intbv(0)[8:])
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

    # Outputs
    qsfp0_txd_1 = Signal(intbv(0)[64:])
    qsfp0_txc_1 = Signal(intbv(0)[8:])
    qsfp0_txd_2 = Signal(intbv(0)[64:])
    qsfp0_txc_2 = Signal(intbv(0)[8:])
    qsfp0_txd_3 = Signal(intbv(0)[64:])
    qsfp0_txc_3 = Signal(intbv(0)[8:])
    qsfp0_txd_4 = Signal(intbv(0)[64:])
    qsfp0_txc_4 = Signal(intbv(0)[8:])
    qsfp1_txd_1 = Signal(intbv(0)[64:])
    qsfp1_txc_1 = Signal(intbv(0)[8:])
    qsfp1_txd_2 = Signal(intbv(0)[64:])
    qsfp1_txc_2 = Signal(intbv(0)[8:])
    qsfp1_txd_3 = Signal(intbv(0)[64:])
    qsfp1_txc_3 = Signal(intbv(0)[8:])
    qsfp1_txd_4 = Signal(intbv(0)[64:])
    qsfp1_txc_4 = Signal(intbv(0)[8:])

    # sources and sinks
    qsfp0_1_source = xgmii_ep.XGMIISource()
    qsfp0_1_source_logic = qsfp0_1_source.create_logic(qsfp0_rx_clk_1, qsfp0_rx_rst_1, txd=qsfp0_rxd_1, txc=qsfp0_rxc_1, name='qsfp0_1_source')

    qsfp0_1_sink = xgmii_ep.XGMIISink()
    qsfp0_1_sink_logic = qsfp0_1_sink.create_logic(qsfp0_tx_clk_1, qsfp0_tx_rst_1, rxd=qsfp0_txd_1, rxc=qsfp0_txc_1, name='qsfp0_1_sink')

    qsfp0_2_source = xgmii_ep.XGMIISource()
    qsfp0_2_source_logic = qsfp0_2_source.create_logic(qsfp0_rx_clk_2, qsfp0_rx_rst_2, txd=qsfp0_rxd_2, txc=qsfp0_rxc_2, name='qsfp0_2_source')

    qsfp0_2_sink = xgmii_ep.XGMIISink()
    qsfp0_2_sink_logic = qsfp0_2_sink.create_logic(qsfp0_tx_clk_2, qsfp0_tx_rst_2, rxd=qsfp0_txd_2, rxc=qsfp0_txc_2, name='qsfp0_2_sink')

    qsfp0_3_source = xgmii_ep.XGMIISource()
    qsfp0_3_source_logic = qsfp0_3_source.create_logic(qsfp0_rx_clk_3, qsfp0_rx_rst_3, txd=qsfp0_rxd_3, txc=qsfp0_rxc_3, name='qsfp0_3_source')

    qsfp0_3_sink = xgmii_ep.XGMIISink()
    qsfp0_3_sink_logic = qsfp0_3_sink.create_logic(qsfp0_tx_clk_3, qsfp0_tx_rst_3, rxd=qsfp0_txd_3, rxc=qsfp0_txc_3, name='qsfp0_3_sink')

    qsfp0_4_source = xgmii_ep.XGMIISource()
    qsfp0_4_source_logic = qsfp0_4_source.create_logic(qsfp0_rx_clk_4, qsfp0_rx_rst_4, txd=qsfp0_rxd_4, txc=qsfp0_rxc_4, name='qsfp0_4_source')

    qsfp0_4_sink = xgmii_ep.XGMIISink()
    qsfp0_4_sink_logic = qsfp0_4_sink.create_logic(qsfp0_tx_clk_4, qsfp0_tx_rst_4, rxd=qsfp0_txd_4, rxc=qsfp0_txc_4, name='qsfp0_4_sink')

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

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        qsfp0_tx_clk_1=qsfp0_tx_clk_1,
        qsfp0_tx_rst_1=qsfp0_tx_rst_1,
        qsfp0_txd_1=qsfp0_txd_1,
        qsfp0_txc_1=qsfp0_txc_1,
        qsfp0_rx_clk_1=qsfp0_rx_clk_1,
        qsfp0_rx_rst_1=qsfp0_rx_rst_1,
        qsfp0_rxd_1=qsfp0_rxd_1,
        qsfp0_rxc_1=qsfp0_rxc_1,
        qsfp0_tx_clk_2=qsfp0_tx_clk_2,
        qsfp0_tx_rst_2=qsfp0_tx_rst_2,
        qsfp0_txd_2=qsfp0_txd_2,
        qsfp0_txc_2=qsfp0_txc_2,
        qsfp0_rx_clk_2=qsfp0_rx_clk_2,
        qsfp0_rx_rst_2=qsfp0_rx_rst_2,
        qsfp0_rxd_2=qsfp0_rxd_2,
        qsfp0_rxc_2=qsfp0_rxc_2,
        qsfp0_tx_clk_3=qsfp0_tx_clk_3,
        qsfp0_tx_rst_3=qsfp0_tx_rst_3,
        qsfp0_txd_3=qsfp0_txd_3,
        qsfp0_txc_3=qsfp0_txc_3,
        qsfp0_rx_clk_3=qsfp0_rx_clk_3,
        qsfp0_rx_rst_3=qsfp0_rx_rst_3,
        qsfp0_rxd_3=qsfp0_rxd_3,
        qsfp0_rxc_3=qsfp0_rxc_3,
        qsfp0_tx_clk_4=qsfp0_tx_clk_4,
        qsfp0_tx_rst_4=qsfp0_tx_rst_4,
        qsfp0_txd_4=qsfp0_txd_4,
        qsfp0_txc_4=qsfp0_txc_4,
        qsfp0_rx_clk_4=qsfp0_rx_clk_4,
        qsfp0_rx_rst_4=qsfp0_rx_rst_4,
        qsfp0_rxd_4=qsfp0_rxd_4,
        qsfp0_rxc_4=qsfp0_rxc_4,
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
        qsfp1_rxc_4=qsfp1_rxc_4
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        qsfp0_tx_clk_1.next = not qsfp0_tx_clk_1
        qsfp0_rx_clk_1.next = not qsfp0_rx_clk_1
        qsfp0_tx_clk_2.next = not qsfp0_tx_clk_2
        qsfp0_rx_clk_2.next = not qsfp0_rx_clk_2
        qsfp0_tx_clk_3.next = not qsfp0_tx_clk_3
        qsfp0_rx_clk_3.next = not qsfp0_rx_clk_3
        qsfp0_tx_clk_4.next = not qsfp0_tx_clk_4
        qsfp0_rx_clk_4.next = not qsfp0_rx_clk_4
        qsfp1_tx_clk_1.next = not qsfp1_tx_clk_1
        qsfp1_rx_clk_1.next = not qsfp1_rx_clk_1
        qsfp1_tx_clk_2.next = not qsfp1_tx_clk_2
        qsfp1_rx_clk_2.next = not qsfp1_rx_clk_2
        qsfp1_tx_clk_3.next = not qsfp1_tx_clk_3
        qsfp1_rx_clk_3.next = not qsfp1_rx_clk_3
        qsfp1_tx_clk_4.next = not qsfp1_tx_clk_4
        qsfp1_rx_clk_4.next = not qsfp1_rx_clk_4

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        qsfp0_tx_rst_1.next = 1
        qsfp0_rx_rst_1.next = 1
        qsfp0_tx_rst_2.next = 1
        qsfp0_rx_rst_2.next = 1
        qsfp0_tx_rst_3.next = 1
        qsfp0_rx_rst_3.next = 1
        qsfp0_tx_rst_4.next = 1
        qsfp0_rx_rst_4.next = 1
        qsfp1_tx_rst_1.next = 1
        qsfp1_rx_rst_1.next = 1
        qsfp1_tx_rst_2.next = 1
        qsfp1_rx_rst_2.next = 1
        qsfp1_tx_rst_3.next = 1
        qsfp1_rx_rst_3.next = 1
        qsfp1_tx_rst_4.next = 1
        qsfp1_rx_rst_4.next = 1
        yield clk.posedge
        rst.next = 0
        qsfp0_tx_rst_1.next = 0
        qsfp0_rx_rst_1.next = 0
        qsfp0_tx_rst_2.next = 0
        qsfp0_rx_rst_2.next = 0
        qsfp0_tx_rst_3.next = 0
        qsfp0_rx_rst_3.next = 0
        qsfp0_tx_rst_4.next = 0
        qsfp0_rx_rst_4.next = 0
        qsfp1_tx_rst_1.next = 0
        qsfp1_rx_rst_1.next = 0
        qsfp1_tx_rst_2.next = 0
        qsfp1_rx_rst_2.next = 0
        qsfp1_tx_rst_3.next = 0
        qsfp1_rx_rst_3.next = 0
        qsfp1_tx_rst_4.next = 0
        qsfp1_rx_rst_4.next = 0
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

        qsfp0_1_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # wait for ARP request packet
        while qsfp0_1_sink.empty():
            yield clk.posedge

        rx_frame = qsfp0_1_sink.recv()
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

        qsfp0_1_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+arp_frame.build_eth().build_axis_fcs().data)

        while qsfp0_1_sink.empty():
            yield clk.posedge

        rx_frame = qsfp0_1_sink.recv()
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

        assert qsfp0_1_source.empty()
        assert qsfp0_1_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
