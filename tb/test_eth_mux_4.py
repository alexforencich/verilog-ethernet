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

module = 'eth_mux_4'
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

    input_0_eth_hdr_valid = Signal(bool(0))
    input_0_eth_dest_mac = Signal(intbv(0)[48:])
    input_0_eth_src_mac = Signal(intbv(0)[48:])
    input_0_eth_type = Signal(intbv(0)[16:])
    input_0_eth_payload_tdata = Signal(intbv(0)[8:])
    input_0_eth_payload_tvalid = Signal(bool(0))
    input_0_eth_payload_tlast = Signal(bool(0))
    input_0_eth_payload_tuser = Signal(bool(0))
    input_1_eth_hdr_valid = Signal(bool(0))
    input_1_eth_dest_mac = Signal(intbv(0)[48:])
    input_1_eth_src_mac = Signal(intbv(0)[48:])
    input_1_eth_type = Signal(intbv(0)[16:])
    input_1_eth_payload_tdata = Signal(intbv(0)[8:])
    input_1_eth_payload_tvalid = Signal(bool(0))
    input_1_eth_payload_tlast = Signal(bool(0))
    input_1_eth_payload_tuser = Signal(bool(0))
    input_2_eth_hdr_valid = Signal(bool(0))
    input_2_eth_dest_mac = Signal(intbv(0)[48:])
    input_2_eth_src_mac = Signal(intbv(0)[48:])
    input_2_eth_type = Signal(intbv(0)[16:])
    input_2_eth_payload_tdata = Signal(intbv(0)[8:])
    input_2_eth_payload_tvalid = Signal(bool(0))
    input_2_eth_payload_tlast = Signal(bool(0))
    input_2_eth_payload_tuser = Signal(bool(0))
    input_3_eth_hdr_valid = Signal(bool(0))
    input_3_eth_dest_mac = Signal(intbv(0)[48:])
    input_3_eth_src_mac = Signal(intbv(0)[48:])
    input_3_eth_type = Signal(intbv(0)[16:])
    input_3_eth_payload_tdata = Signal(intbv(0)[8:])
    input_3_eth_payload_tvalid = Signal(bool(0))
    input_3_eth_payload_tlast = Signal(bool(0))
    input_3_eth_payload_tuser = Signal(bool(0))

    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    input_0_eth_hdr_ready = Signal(bool(0))
    input_0_eth_payload_tready = Signal(bool(0))
    input_1_eth_hdr_ready = Signal(bool(0))
    input_1_eth_payload_tready = Signal(bool(0))
    input_2_eth_hdr_ready = Signal(bool(0))
    input_2_eth_payload_tready = Signal(bool(0))
    input_3_eth_hdr_ready = Signal(bool(0))
    input_3_eth_payload_tready = Signal(bool(0))

    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))

    # sources and sinks
    source_0_pause = Signal(bool(0))
    source_1_pause = Signal(bool(0))
    source_2_pause = Signal(bool(0))
    source_3_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source_0 = eth_ep.EthFrameSource()

    source_0_logic = source_0.create_logic(
        clk,
        rst,
        eth_hdr_ready=input_0_eth_hdr_ready,
        eth_hdr_valid=input_0_eth_hdr_valid,
        eth_dest_mac=input_0_eth_dest_mac,
        eth_src_mac=input_0_eth_src_mac,
        eth_type=input_0_eth_type,
        eth_payload_tdata=input_0_eth_payload_tdata,
        eth_payload_tvalid=input_0_eth_payload_tvalid,
        eth_payload_tready=input_0_eth_payload_tready,
        eth_payload_tlast=input_0_eth_payload_tlast,
        eth_payload_tuser=input_0_eth_payload_tuser,
        pause=source_0_pause,
        name='source_0'
    )

    source_1 = eth_ep.EthFrameSource()

    source_1_logic = source_1.create_logic(
        clk,
        rst,
        eth_hdr_ready=input_1_eth_hdr_ready,
        eth_hdr_valid=input_1_eth_hdr_valid,
        eth_dest_mac=input_1_eth_dest_mac,
        eth_src_mac=input_1_eth_src_mac,
        eth_type=input_1_eth_type,
        eth_payload_tdata=input_1_eth_payload_tdata,
        eth_payload_tvalid=input_1_eth_payload_tvalid,
        eth_payload_tready=input_1_eth_payload_tready,
        eth_payload_tlast=input_1_eth_payload_tlast,
        eth_payload_tuser=input_1_eth_payload_tuser,
        pause=source_1_pause,
        name='source_1'
    )

    source_2 = eth_ep.EthFrameSource()

    source_2_logic = source_2.create_logic(
        clk,
        rst,
        eth_hdr_ready=input_2_eth_hdr_ready,
        eth_hdr_valid=input_2_eth_hdr_valid,
        eth_dest_mac=input_2_eth_dest_mac,
        eth_src_mac=input_2_eth_src_mac,
        eth_type=input_2_eth_type,
        eth_payload_tdata=input_2_eth_payload_tdata,
        eth_payload_tvalid=input_2_eth_payload_tvalid,
        eth_payload_tready=input_2_eth_payload_tready,
        eth_payload_tlast=input_2_eth_payload_tlast,
        eth_payload_tuser=input_2_eth_payload_tuser,
        pause=source_2_pause,
        name='source_2'
    )

    source_3 = eth_ep.EthFrameSource()

    source_3_logic = source_3.create_logic(
        clk,
        rst,
        eth_hdr_ready=input_3_eth_hdr_ready,
        eth_hdr_valid=input_3_eth_hdr_valid,
        eth_dest_mac=input_3_eth_dest_mac,
        eth_src_mac=input_3_eth_src_mac,
        eth_type=input_3_eth_type,
        eth_payload_tdata=input_3_eth_payload_tdata,
        eth_payload_tvalid=input_3_eth_payload_tvalid,
        eth_payload_tready=input_3_eth_payload_tready,
        eth_payload_tlast=input_3_eth_payload_tlast,
        eth_payload_tuser=input_3_eth_payload_tuser,
        pause=source_3_pause,
        name='source_3'
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

        input_0_eth_hdr_valid=input_0_eth_hdr_valid,
        input_0_eth_hdr_ready=input_0_eth_hdr_ready,
        input_0_eth_dest_mac=input_0_eth_dest_mac,
        input_0_eth_src_mac=input_0_eth_src_mac,
        input_0_eth_type=input_0_eth_type,
        input_0_eth_payload_tdata=input_0_eth_payload_tdata,
        input_0_eth_payload_tvalid=input_0_eth_payload_tvalid,
        input_0_eth_payload_tready=input_0_eth_payload_tready,
        input_0_eth_payload_tlast=input_0_eth_payload_tlast,
        input_0_eth_payload_tuser=input_0_eth_payload_tuser,
        input_1_eth_hdr_valid=input_1_eth_hdr_valid,
        input_1_eth_hdr_ready=input_1_eth_hdr_ready,
        input_1_eth_dest_mac=input_1_eth_dest_mac,
        input_1_eth_src_mac=input_1_eth_src_mac,
        input_1_eth_type=input_1_eth_type,
        input_1_eth_payload_tdata=input_1_eth_payload_tdata,
        input_1_eth_payload_tvalid=input_1_eth_payload_tvalid,
        input_1_eth_payload_tready=input_1_eth_payload_tready,
        input_1_eth_payload_tlast=input_1_eth_payload_tlast,
        input_1_eth_payload_tuser=input_1_eth_payload_tuser,
        input_2_eth_hdr_valid=input_2_eth_hdr_valid,
        input_2_eth_hdr_ready=input_2_eth_hdr_ready,
        input_2_eth_dest_mac=input_2_eth_dest_mac,
        input_2_eth_src_mac=input_2_eth_src_mac,
        input_2_eth_type=input_2_eth_type,
        input_2_eth_payload_tdata=input_2_eth_payload_tdata,
        input_2_eth_payload_tvalid=input_2_eth_payload_tvalid,
        input_2_eth_payload_tready=input_2_eth_payload_tready,
        input_2_eth_payload_tlast=input_2_eth_payload_tlast,
        input_2_eth_payload_tuser=input_2_eth_payload_tuser,
        input_3_eth_hdr_valid=input_3_eth_hdr_valid,
        input_3_eth_hdr_ready=input_3_eth_hdr_ready,
        input_3_eth_dest_mac=input_3_eth_dest_mac,
        input_3_eth_src_mac=input_3_eth_src_mac,
        input_3_eth_type=input_3_eth_type,
        input_3_eth_payload_tdata=input_3_eth_payload_tdata,
        input_3_eth_payload_tvalid=input_3_eth_payload_tvalid,
        input_3_eth_payload_tready=input_3_eth_payload_tready,
        input_3_eth_payload_tlast=input_3_eth_payload_tlast,
        input_3_eth_payload_tuser=input_3_eth_payload_tuser,

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

        enable=enable,
        select=select
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
        enable.next = True

        yield clk.posedge
        print("test 1: select port 0")
        current_test.next = 1

        select.next = 0

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source_0.send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: select port 1")
        current_test.next = 2

        select.next = 1

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source_1.send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        select.next = 0

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_0.send(test_frame1)
        source_0.send(test_frame2)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets, different ports")
        current_test.next = 4

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_1.send(test_frame1)
        source_2.send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while input_0_eth_payload_tvalid or input_1_eth_payload_tvalid or input_2_eth_payload_tvalid or input_3_eth_payload_tvalid:
            yield clk.posedge
            select.next = 2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alterate pause source")
        current_test.next = 5

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_1.send(test_frame1)
        source_2.send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while input_0_eth_payload_tvalid or input_1_eth_payload_tvalid or input_2_eth_payload_tvalid or input_3_eth_payload_tvalid:
            source_0_pause.next = True
            source_1_pause.next = True
            source_2_pause.next = True
            source_3_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_0_pause.next = False
            source_1_pause.next = False
            source_2_pause.next = False
            source_3_pause.next = False
            yield clk.posedge
            select.next = 2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alterate pause sink")
        current_test.next = 6

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_1.send(test_frame1)
        source_2.send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while input_0_eth_payload_tvalid or input_1_eth_payload_tvalid or input_2_eth_payload_tvalid or input_3_eth_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge
            select.next = 2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

