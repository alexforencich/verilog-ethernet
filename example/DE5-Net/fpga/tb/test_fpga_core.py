#!/usr/bin/env python
"""

Copyright (c) 2016 Alex Forencich

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

try:
    from queue import Queue
except ImportError:
    from Queue import Queue

import eth_ep
import arp_ep
import udp_ep
import xgmii_ep

module = 'fpga_core'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/eth/rtl/eth_mac_10g_fifo.v")
srcs.append("../lib/eth/rtl/eth_mac_10g.v")
srcs.append("../lib/eth/rtl/eth_mac_10g_rx.v")
srcs.append("../lib/eth/rtl/eth_mac_10g_tx.v")
srcs.append("../lib/eth/rtl/lfsr.v")
srcs.append("../lib/eth/rtl/eth_axis_rx_64.v")
srcs.append("../lib/eth/rtl/eth_axis_tx_64.v")
srcs.append("../lib/eth/rtl/udp_complete_64.v")
srcs.append("../lib/eth/rtl/udp_64.v")
srcs.append("../lib/eth/rtl/udp_ip_rx_64.v")
srcs.append("../lib/eth/rtl/udp_ip_tx_64.v")
srcs.append("../lib/eth/rtl/ip_complete_64.v")
srcs.append("../lib/eth/rtl/ip_64.v")
srcs.append("../lib/eth/rtl/ip_eth_rx_64.v")
srcs.append("../lib/eth/rtl/ip_eth_tx_64.v")
srcs.append("../lib/eth/rtl/ip_arb_mux_64_2.v")
srcs.append("../lib/eth/rtl/ip_mux_64_2.v")
srcs.append("../lib/eth/rtl/arp_64.v")
srcs.append("../lib/eth/rtl/arp_cache.v")
srcs.append("../lib/eth/rtl/arp_eth_rx_64.v")
srcs.append("../lib/eth/rtl/arp_eth_tx_64.v")
srcs.append("../lib/eth/rtl/eth_arb_mux_64_2.v")
srcs.append("../lib/eth/rtl/eth_mux_64_2.v")
srcs.append("../lib/eth/lib/axis/rtl/arbiter.v")
srcs.append("../lib/eth/lib/axis/rtl/priority_encoder.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_fifo_64.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_async_frame_fifo_64.v")
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_fpga_core(clk,
                  rst,
                  current_test,

                  btn,
                  sw,
                  led,
                  led_bkt,
                  led_hex0_d,
                  led_hex0_dp,
                  led_hex1_d,
                  led_hex1_dp,

                  sfp_a_txd,
                  sfp_a_txc,
                  sfp_a_rxd,
                  sfp_a_rxc,
                  sfp_b_txd,
                  sfp_b_txc,
                  sfp_b_rxd,
                  sfp_b_rxc,
                  sfp_c_txd,
                  sfp_c_txc,
                  sfp_c_rxd,
                  sfp_c_rxc,
                  sfp_d_txd,
                  sfp_d_txc,
                  sfp_d_rxd,
                  sfp_d_rxc):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                btn=btn,
                sw=sw,
                led=led,
                led_bkt=led_bkt,
                led_hex0_d=led_hex0_d,
                led_hex0_dp=led_hex0_dp,
                led_hex1_d=led_hex1_d,
                led_hex1_dp=led_hex1_dp,

                sfp_a_txd=sfp_a_txd,
                sfp_a_txc=sfp_a_txc,
                sfp_a_rxd=sfp_a_rxd,
                sfp_a_rxc=sfp_a_rxc,
                sfp_b_txd=sfp_b_txd,
                sfp_b_txc=sfp_b_txc,
                sfp_b_rxd=sfp_b_rxd,
                sfp_b_rxc=sfp_b_rxc,
                sfp_c_txd=sfp_c_txd,
                sfp_c_txc=sfp_c_txc,
                sfp_c_rxd=sfp_c_rxd,
                sfp_c_rxc=sfp_c_rxc,
                sfp_d_txd=sfp_d_txd,
                sfp_d_txc=sfp_d_txc,
                sfp_d_rxd=sfp_d_rxd,
                sfp_d_rxc=sfp_d_rxc)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    btn = Signal(intbv(0)[4:])
    sw = Signal(intbv(0)[4:])
    sfp_a_rxd = Signal(intbv(0)[64:])
    sfp_a_rxc = Signal(intbv(0)[8:])
    sfp_b_rxd = Signal(intbv(0)[64:])
    sfp_b_rxc = Signal(intbv(0)[8:])
    sfp_c_rxd = Signal(intbv(0)[64:])
    sfp_c_rxc = Signal(intbv(0)[8:])
    sfp_d_rxd = Signal(intbv(0)[64:])
    sfp_d_rxc = Signal(intbv(0)[8:])

    # Outputs
    led = Signal(intbv(0)[4:])
    led_bkt = Signal(intbv(0)[4:])
    led_hex0_d = Signal(intbv(0)[7:])
    led_hex0_dp = Signal(bool(0))
    led_hex1_d = Signal(intbv(0)[7:])
    led_hex1_dp = Signal(bool(0))
    sfp_a_txd = Signal(intbv(0)[64:])
    sfp_a_txc = Signal(intbv(0)[8:])
    sfp_b_txd = Signal(intbv(0)[64:])
    sfp_b_txc = Signal(intbv(0)[8:])
    sfp_c_txd = Signal(intbv(0)[64:])
    sfp_c_txc = Signal(intbv(0)[8:])
    sfp_d_txd = Signal(intbv(0)[64:])
    sfp_d_txc = Signal(intbv(0)[8:])

    # sources and sinks
    xgmii_a_source_queue = Queue()
    xgmii_a_sink_queue = Queue()
    xgmii_b_source_queue = Queue()
    xgmii_b_sink_queue = Queue()
    xgmii_c_source_queue = Queue()
    xgmii_c_sink_queue = Queue()
    xgmii_d_source_queue = Queue()
    xgmii_d_sink_queue = Queue()

    xgmii_a_source = xgmii_ep.XGMIISource(clk,
                                          rst,
                                          txd=sfp_a_rxd,
                                          txc=sfp_a_rxc,
                                          fifo=xgmii_a_source_queue,
                                          name='xgmii_a_source')

    xgmii_a_sink = xgmii_ep.XGMIISink(clk,
                                      rst,
                                      rxd=sfp_a_txd,
                                      rxc=sfp_a_txc,
                                      fifo=xgmii_a_sink_queue,
                                      name='xgmii_a_sink')

    xgmii_b_source = xgmii_ep.XGMIISource(clk,
                                          rst,
                                          txd=sfp_b_rxd,
                                          txc=sfp_b_rxc,
                                          fifo=xgmii_b_source_queue,
                                          name='xgmii_b_source')

    xgmii_b_sink = xgmii_ep.XGMIISink(clk,
                                      rst,
                                      rxd=sfp_b_txd,
                                      rxc=sfp_b_txc,
                                      fifo=xgmii_b_sink_queue,
                                      name='xgmii_b_sink')

    xgmii_c_source = xgmii_ep.XGMIISource(clk,
                                          rst,
                                          txd=sfp_c_rxd,
                                          txc=sfp_c_rxc,
                                          fifo=xgmii_c_source_queue,
                                          name='xgmii_c_source')

    xgmii_c_sink = xgmii_ep.XGMIISink(clk,
                                      rst,
                                      rxd=sfp_c_txd,
                                      rxc=sfp_c_txc,
                                      fifo=xgmii_c_sink_queue,
                                      name='xgmii_c_sink')

    xgmii_d_source = xgmii_ep.XGMIISource(clk,
                                          rst,
                                          txd=sfp_d_rxd,
                                          txc=sfp_d_rxc,
                                          fifo=xgmii_d_source_queue,
                                          name='xgmii_d_source')

    xgmii_d_sink = xgmii_ep.XGMIISink(clk,
                                      rst,
                                      rxd=sfp_d_txd,
                                      rxc=sfp_d_txc,
                                      fifo=xgmii_d_sink_queue,
                                      name='xgmii_d_sink')

    # DUT
    dut = dut_fpga_core(clk,
                        rst,
                        current_test,

                        btn,
                        sw,
                        led,
                        led_bkt,
                        led_hex0_d,
                        led_hex0_dp,
                        led_hex1_d,
                        led_hex1_dp,

                        sfp_a_txd,
                        sfp_a_txc,
                        sfp_a_rxd,
                        sfp_a_rxc,
                        sfp_b_txd,
                        sfp_b_txc,
                        sfp_b_rxd,
                        sfp_b_rxc,
                        sfp_c_txd,
                        sfp_c_txc,
                        sfp_c_rxd,
                        sfp_c_rxc,
                        sfp_d_txd,
                        sfp_d_txc,
                        sfp_d_rxd,
                        sfp_d_rxc)

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

        xgmii_a_source_queue.put(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame.build_eth().build_axis_fcs().data)

        # wait for ARP request packet
        while xgmii_a_sink_queue.empty():
            yield clk.posedge

        rx_frame = xgmii_a_sink_queue.get(False)
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

        xgmii_a_source_queue.put(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+arp_frame.build_eth().build_axis_fcs().data)

        while xgmii_a_sink_queue.empty():
            yield clk.posedge

        rx_frame = xgmii_a_sink_queue.get(False)
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

        assert xgmii_a_source_queue.empty()
        assert xgmii_a_sink_queue.empty()

        yield delay(100)

        raise StopSimulation

    return dut, xgmii_a_source, xgmii_a_sink, xgmii_b_source, xgmii_b_sink, xgmii_c_source, xgmii_c_sink, xgmii_d_source, xgmii_d_sink, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
