#!/usr/bin/env python
"""

Copyright (c) 2014-2017 Alex Forencich

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

import axis_ep

module = 'axis_demux_4'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 8

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))

    output_0_axis_tready = Signal(bool(0))
    output_1_axis_tready = Signal(bool(0))
    output_2_axis_tready = Signal(bool(0))
    output_3_axis_tready = Signal(bool(0))

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    input_axis_tready = Signal(bool(0))

    output_0_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_0_axis_tvalid = Signal(bool(0))
    output_0_axis_tlast = Signal(bool(0))
    output_0_axis_tuser = Signal(bool(0))
    output_1_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_1_axis_tvalid = Signal(bool(0))
    output_1_axis_tlast = Signal(bool(0))
    output_1_axis_tuser = Signal(bool(0))
    output_2_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_2_axis_tvalid = Signal(bool(0))
    output_2_axis_tlast = Signal(bool(0))
    output_2_axis_tuser = Signal(bool(0))
    output_3_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_3_axis_tvalid = Signal(bool(0))
    output_3_axis_tlast = Signal(bool(0))
    output_3_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_0_pause = Signal(bool(0))
    sink_1_pause = Signal(bool(0))
    sink_2_pause = Signal(bool(0))
    sink_3_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk,
        rst,
        tdata=input_axis_tdata,
        tvalid=input_axis_tvalid,
        tready=input_axis_tready,
        tlast=input_axis_tlast,
        tuser=input_axis_tuser,
        pause=source_pause,
        name='source'
    )

    sink_0 = axis_ep.AXIStreamSink()

    sink_0_logic = sink_0.create_logic(
        clk,
        rst,
        tdata=output_0_axis_tdata,
        tvalid=output_0_axis_tvalid,
        tready=output_0_axis_tready,
        tlast=output_0_axis_tlast,
        tuser=output_0_axis_tuser,
        pause=sink_0_pause,
        name='sink_0'
    )

    sink_1 = axis_ep.AXIStreamSink()

    sink_1_logic = sink_1.create_logic(
        clk,
        rst,
        tdata=output_1_axis_tdata,
        tvalid=output_1_axis_tvalid,
        tready=output_1_axis_tready,
        tlast=output_1_axis_tlast,
        tuser=output_1_axis_tuser,
        pause=sink_1_pause,
        name='sink_1'
    )

    sink_2 = axis_ep.AXIStreamSink()

    sink_2_logic = sink_2.create_logic(
        clk,
        rst,
        tdata=output_2_axis_tdata,
        tvalid=output_2_axis_tvalid,
        tready=output_2_axis_tready,
        tlast=output_2_axis_tlast,
        tuser=output_2_axis_tuser,
        pause=sink_2_pause,
        name='sink_2'
    )

    sink_3 = axis_ep.AXIStreamSink()

    sink_3_logic = sink_3.create_logic(
        clk,
        rst,
        tdata=output_3_axis_tdata,
        tvalid=output_3_axis_tvalid,
        tready=output_3_axis_tready,
        tlast=output_3_axis_tlast,
        tuser=output_3_axis_tuser,
        pause=sink_3_pause,
        name='sink_3'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        input_axis_tdata=input_axis_tdata,
        input_axis_tvalid=input_axis_tvalid,
        input_axis_tready=input_axis_tready,
        input_axis_tlast=input_axis_tlast,
        input_axis_tuser=input_axis_tuser,

        output_0_axis_tdata=output_0_axis_tdata,
        output_0_axis_tvalid=output_0_axis_tvalid,
        output_0_axis_tready=output_0_axis_tready,
        output_0_axis_tlast=output_0_axis_tlast,
        output_0_axis_tuser=output_0_axis_tuser,
        output_1_axis_tdata=output_1_axis_tdata,
        output_1_axis_tvalid=output_1_axis_tvalid,
        output_1_axis_tready=output_1_axis_tready,
        output_1_axis_tlast=output_1_axis_tlast,
        output_1_axis_tuser=output_1_axis_tuser,
        output_2_axis_tdata=output_2_axis_tdata,
        output_2_axis_tvalid=output_2_axis_tvalid,
        output_2_axis_tready=output_2_axis_tready,
        output_2_axis_tlast=output_2_axis_tlast,
        output_2_axis_tuser=output_2_axis_tuser,
        output_3_axis_tdata=output_3_axis_tdata,
        output_3_axis_tvalid=output_3_axis_tvalid,
        output_3_axis_tready=output_3_axis_tready,
        output_3_axis_tlast=output_3_axis_tlast,
        output_3_axis_tuser=output_3_axis_tuser,

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

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame)
        yield clk.posedge

        while input_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: select port 1")
        current_test.next = 2

        select.next = 1

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame)
        yield clk.posedge

        while input_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        select.next = 0

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets, different ports")
        current_test.next = 4

        select.next = 1

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_axis_tvalid:
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alterate pause source")
        current_test.next = 5

        select.next = 1

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_axis_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alterate pause sink")
        current_test.next = 6

        select.next = 1

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_axis_tvalid:
            sink_0_pause.next = True
            sink_1_pause.next = True
            sink_2_pause.next = True
            sink_3_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_0_pause.next = False
            sink_1_pause.next = False
            sink_2_pause.next = False
            sink_3_pause.next = False
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_0_logic, sink_1_logic, sink_2_logic, sink_3_logic, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

