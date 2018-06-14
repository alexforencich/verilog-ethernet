#!/usr/bin/env python
"""

Copyright (c) 2014-2018 Alex Forencich

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

module = 'arp_eth_tx'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_frame_valid = Signal(bool(0))
    input_eth_dest_mac = Signal(intbv(0)[48:])
    input_eth_src_mac = Signal(intbv(0)[48:])
    input_eth_type = Signal(intbv(0)[16:])
    input_arp_htype = Signal(intbv(0)[16:])
    input_arp_ptype = Signal(intbv(0)[16:])
    input_arp_oper = Signal(intbv(0)[16:])
    input_arp_sha = Signal(intbv(0)[48:])
    input_arp_spa = Signal(intbv(0)[32:])
    input_arp_tha = Signal(intbv(0)[48:])
    input_arp_tpa = Signal(intbv(0)[32:])
    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))

    # Outputs
    input_frame_ready = Signal(bool(0))
    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))
    busy = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = arp_ep.ARPFrameSource()

    source_logic = source.create_logic(
        clk,
        rst,
        frame_ready=input_frame_ready,
        frame_valid=input_frame_valid,
        eth_dest_mac=input_eth_dest_mac,
        eth_src_mac=input_eth_src_mac,
        eth_type=input_eth_type,
        arp_htype=input_arp_htype,
        arp_ptype=input_arp_ptype,
        arp_oper=input_arp_oper,
        arp_sha=input_arp_sha,
        arp_spa=input_arp_spa,
        arp_tha=input_arp_tha,
        arp_tpa=input_arp_tpa,
        pause=source_pause,
        name='source'
    )

    sink = eth_ep.EthFrameSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        eth_hdr_ready=output_eth_hdr_ready,
        eth_hdr_valid=output_eth_hdr_valid,
        eth_dest_mac=output_eth_dest_mac,
        eth_src_mac=output_eth_src_mac,
        eth_type=output_eth_type,
        eth_payload_tdata=output_eth_payload_tdata,
        eth_payload_tvalid=output_eth_payload_tvalid,
        eth_payload_tready=output_eth_payload_tready,
        eth_payload_tlast=output_eth_payload_tlast,
        eth_payload_tuser=output_eth_payload_tuser,
        pause=sink_pause,
        name='sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        input_frame_valid=input_frame_valid,
        input_frame_ready=input_frame_ready,
        input_eth_dest_mac=input_eth_dest_mac,
        input_eth_src_mac=input_eth_src_mac,
        input_eth_type=input_eth_type,
        input_arp_htype=input_arp_htype,
        input_arp_ptype=input_arp_ptype,
        input_arp_oper=input_arp_oper,
        input_arp_sha=input_arp_sha,
        input_arp_spa=input_arp_spa,
        input_arp_tha=input_arp_tha,
        input_arp_tpa=input_arp_tpa,

        output_eth_hdr_valid=output_eth_hdr_valid,
        output_eth_hdr_ready=output_eth_hdr_ready,
        output_eth_dest_mac=output_eth_dest_mac,
        output_eth_src_mac=output_eth_src_mac,
        output_eth_type=output_eth_type,
        output_eth_payload_tdata=output_eth_payload_tdata,
        output_eth_payload_tvalid=output_eth_payload_tvalid,
        output_eth_payload_tready=output_eth_payload_tready,
        output_eth_payload_tlast=output_eth_payload_tlast,
        output_eth_payload_tuser=output_eth_payload_tuser,

        busy=busy
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

        yield clk.posedge
        print("test 1: test packet")
        current_test.next = 1

        test_frame = arp_ep.ARPFrame()
        test_frame.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x0806
        test_frame.arp_htype = 0x0001
        test_frame.arp_ptype = 0x0800
        test_frame.arp_hlen = 6
        test_frame.arp_plen = 4
        test_frame.arp_oper = 1
        test_frame.arp_sha = 0x5A5152535455
        test_frame.arp_spa = 0xc0a80164
        test_frame.arp_tha = 0xDAD1D2D3D4D5
        test_frame.arp_tpa = 0xc0a80165
        source.send(test_frame)
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: test packet with pauses")
        current_test.next = 2

        test_frame = arp_ep.ARPFrame()
        test_frame.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x0806
        test_frame.arp_htype = 0x0001
        test_frame.arp_ptype = 0x0800
        test_frame.arp_hlen = 6
        test_frame.arp_plen = 4
        test_frame.arp_oper = 1
        test_frame.arp_sha = 0x5A5152535455
        test_frame.arp_spa = 0xc0a80164
        test_frame.arp_tha = 0xDAD1D2D3D4D5
        test_frame.arp_tpa = 0xc0a80165
        source.send(test_frame)
        yield clk.posedge

        yield delay(64)
        yield clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield clk.posedge
        sink_pause.next = False

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets")
        current_test.next = 3

        test_frame1 = arp_ep.ARPFrame()
        test_frame1.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x0806
        test_frame1.arp_htype = 0x0001
        test_frame1.arp_ptype = 0x0800
        test_frame1.arp_hlen = 6
        test_frame1.arp_plen = 4
        test_frame1.arp_oper = 1
        test_frame1.arp_sha = 0x5A5152535455
        test_frame1.arp_spa = 0xc0a80164
        test_frame1.arp_tha = 0xDAD1D2D3D4D5
        test_frame1.arp_tpa = 0xc0a80165
        test_frame2 = arp_ep.ARPFrame()
        test_frame2.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x0806
        test_frame2.arp_htype = 0x0001
        test_frame2.arp_ptype = 0x0800
        test_frame2.arp_hlen = 6
        test_frame2.arp_plen = 4
        test_frame2.arp_oper = 1
        test_frame2.arp_sha = 0x5A5152535455
        test_frame2.arp_spa = 0xc0a80164
        test_frame2.arp_tha = 0xDAD1D2D3D4D5
        test_frame2.arp_tpa = 0xc0a80165
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame1

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 4: alternate pause sink")
        current_test.next = 4

        test_frame1 = arp_ep.ARPFrame()
        test_frame1.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x0806
        test_frame1.arp_htype = 0x0001
        test_frame1.arp_ptype = 0x0800
        test_frame1.arp_hlen = 6
        test_frame1.arp_plen = 4
        test_frame1.arp_oper = 1
        test_frame1.arp_sha = 0x5A5152535455
        test_frame1.arp_spa = 0xc0a80164
        test_frame1.arp_tha = 0xDAD1D2D3D4D5
        test_frame1.arp_tpa = 0xc0a80165
        test_frame2 = arp_ep.ARPFrame()
        test_frame2.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x0806
        test_frame2.arp_htype = 0x0001
        test_frame2.arp_ptype = 0x0800
        test_frame2.arp_hlen = 6
        test_frame2.arp_plen = 4
        test_frame2.arp_oper = 1
        test_frame2.arp_sha = 0x5A5152535455
        test_frame2.arp_spa = 0xc0a80164
        test_frame2.arp_tha = 0xDAD1D2D3D4D5
        test_frame2.arp_tpa = 0xc0a80165
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while output_eth_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame1

        rx_frame = sink.recv()

        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)
        assert check_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

