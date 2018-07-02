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
import struct

import axis_ep

module = 'axis_frame_join_4'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TAG_ENABLE = 1
    TAG_WIDTH = 16

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_0_axis_tdata = Signal(intbv(0)[8:])
    input_0_axis_tvalid = Signal(bool(0))
    input_0_axis_tlast = Signal(bool(0))
    input_0_axis_tuser = Signal(bool(0))
    input_1_axis_tdata = Signal(intbv(0)[8:])
    input_1_axis_tvalid = Signal(bool(0))
    input_1_axis_tlast = Signal(bool(0))
    input_1_axis_tuser = Signal(bool(0))
    input_2_axis_tdata = Signal(intbv(0)[8:])
    input_2_axis_tvalid = Signal(bool(0))
    input_2_axis_tlast = Signal(bool(0))
    input_2_axis_tuser = Signal(bool(0))
    input_3_axis_tdata = Signal(intbv(0)[8:])
    input_3_axis_tvalid = Signal(bool(0))
    input_3_axis_tlast = Signal(bool(0))
    input_3_axis_tuser = Signal(bool(0))
    output_axis_tready = Signal(bool(0))
    tag = Signal(intbv(0)[TAG_WIDTH:])

    # Outputs
    input_0_axis_tready = Signal(bool(0))
    input_1_axis_tready = Signal(bool(0))
    input_2_axis_tready = Signal(bool(0))
    input_3_axis_tready = Signal(bool(0))
    output_axis_tdata = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))
    busy = Signal(bool(0))

    # sources and sinks
    source_0_pause = Signal(bool(0))
    source_1_pause = Signal(bool(0))
    source_2_pause = Signal(bool(0))
    source_3_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source_0 = axis_ep.AXIStreamSource()

    source_0_logic = source_0.create_logic(
        clk,
        rst,
        tdata=input_0_axis_tdata,
        tvalid=input_0_axis_tvalid,
        tready=input_0_axis_tready,
        tlast=input_0_axis_tlast,
        tuser=input_0_axis_tuser,
        pause=source_0_pause,
        name='source_0'
    )

    source_1 = axis_ep.AXIStreamSource()

    source_1_logic = source_1.create_logic(
        clk,
        rst,
        tdata=input_1_axis_tdata,
        tvalid=input_1_axis_tvalid,
        tready=input_1_axis_tready,
        tlast=input_1_axis_tlast,
        tuser=input_1_axis_tuser,
        pause=source_1_pause,
        name='source_1'
    )

    source_2 = axis_ep.AXIStreamSource()

    source_2_logic = source_2.create_logic(
        clk,
        rst,
        tdata=input_2_axis_tdata,
        tvalid=input_2_axis_tvalid,
        tready=input_2_axis_tready,
        tlast=input_2_axis_tlast,
        tuser=input_2_axis_tuser,
        pause=source_2_pause,
        name='source_2'
    )

    source_3 = axis_ep.AXIStreamSource()

    source_3_logic = source_3.create_logic(
        clk,
        rst,
        tdata=input_3_axis_tdata,
        tvalid=input_3_axis_tvalid,
        tready=input_3_axis_tready,
        tlast=input_3_axis_tlast,
        tuser=input_3_axis_tuser,
        pause=source_3_pause,
        name='source_3'
    )

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=output_axis_tdata,
        tvalid=output_axis_tvalid,
        tready=output_axis_tready,
        tlast=output_axis_tlast,
        tuser=output_axis_tuser,
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

        input_0_axis_tdata=input_0_axis_tdata,
        input_0_axis_tvalid=input_0_axis_tvalid,
        input_0_axis_tready=input_0_axis_tready,
        input_0_axis_tlast=input_0_axis_tlast,
        input_0_axis_tuser=input_0_axis_tuser,

        input_1_axis_tdata=input_1_axis_tdata,
        input_1_axis_tvalid=input_1_axis_tvalid,
        input_1_axis_tready=input_1_axis_tready,
        input_1_axis_tlast=input_1_axis_tlast,
        input_1_axis_tuser=input_1_axis_tuser,

        input_2_axis_tdata=input_2_axis_tdata,
        input_2_axis_tvalid=input_2_axis_tvalid,
        input_2_axis_tready=input_2_axis_tready,
        input_2_axis_tlast=input_2_axis_tlast,
        input_2_axis_tuser=input_2_axis_tuser,

        input_3_axis_tdata=input_3_axis_tdata,
        input_3_axis_tvalid=input_3_axis_tvalid,
        input_3_axis_tready=input_3_axis_tready,
        input_3_axis_tlast=input_3_axis_tlast,
        input_3_axis_tuser=input_3_axis_tuser,

        output_axis_tdata=output_axis_tdata,
        output_axis_tvalid=output_axis_tvalid,
        output_axis_tready=output_axis_tready,
        output_axis_tlast=output_axis_tlast,
        output_axis_tuser=output_axis_tuser,

        tag=tag,
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
        tag.next = 1

        yield clk.posedge
        print("test 1: test packet")
        current_test.next = 1

        test_frame_0 = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1 = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2 = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3 = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0)
        source_1.send(test_frame_1)
        source_2.send(test_frame_2)
        source_3.send(test_frame_3)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0.data + test_frame_1.data + test_frame_2.data + test_frame_3.data

        yield delay(100)

        yield clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame_0 = axis_ep.AXIStreamFrame(b'\x00' + bytearray(range(256)) + b'\x00')
        test_frame_1 = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2 = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3 = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0)
        source_1.send(test_frame_1)
        source_2.send(test_frame_2)
        source_3.send(test_frame_3)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0.data + test_frame_1.data + test_frame_2.data + test_frame_3.data

        yield delay(100)

        yield clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame_0 = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1 = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2 = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3 = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0)
        source_1.send(test_frame_1)
        source_2.send(test_frame_2)
        source_3.send(test_frame_3)
        yield clk.posedge

        yield delay(64)
        yield clk.posedge
        source_1_pause.next = True
        yield delay(32)
        yield clk.posedge
        source_1_pause.next = False

        yield delay(64)
        yield clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield clk.posedge
        sink_pause.next = False

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0.data + test_frame_1.data + test_frame_2.data + test_frame_3.data

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame_0a = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_0b = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1a = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_1b = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2a = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_2b = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3a = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        test_frame_3b = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0a)
        source_0.send(test_frame_0b)
        source_1.send(test_frame_1a)
        source_1.send(test_frame_1b)
        source_2.send(test_frame_2a)
        source_2.send(test_frame_2b)
        source_3.send(test_frame_3a)
        source_3.send(test_frame_3b)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0a.data + test_frame_1a.data + test_frame_2a.data + test_frame_3a.data

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0b.data + test_frame_1b.data + test_frame_2b.data + test_frame_3b.data

        yield delay(100)

        yield clk.posedge
        print("test 5: alternate pause source")
        current_test.next = 5

        test_frame_0a = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_0b = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1a = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_1b = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2a = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_2b = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3a = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        test_frame_3b = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0a)
        source_0.send(test_frame_0b)
        source_1.send(test_frame_1a)
        source_1.send(test_frame_1b)
        source_2.send(test_frame_2a)
        source_2.send(test_frame_2b)
        source_3.send(test_frame_3a)
        source_3.send(test_frame_3b)
        yield clk.posedge

        while input_3_axis_tvalid or output_axis_tvalid:
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

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0a.data + test_frame_1a.data + test_frame_2a.data + test_frame_3a.data

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0b.data + test_frame_1b.data + test_frame_2b.data + test_frame_3b.data

        yield delay(100)

        yield clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

        test_frame_0a = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_0b = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1a = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_1b = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2a = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_2b = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3a = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        test_frame_3b = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        source_0.send(test_frame_0a)
        source_0.send(test_frame_0b)
        source_1.send(test_frame_1a)
        source_1.send(test_frame_1b)
        source_2.send(test_frame_2a)
        source_2.send(test_frame_2b)
        source_3.send(test_frame_3a)
        source_3.send(test_frame_3b)
        yield clk.posedge

        while input_3_axis_tvalid or output_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0a.data + test_frame_1a.data + test_frame_2a.data + test_frame_3a.data

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0b.data + test_frame_1b.data + test_frame_2b.data + test_frame_3b.data

        yield delay(100)

        yield clk.posedge
        print("test 7: tuser assert")
        current_test.next = 7

        test_frame_0 = axis_ep.AXIStreamFrame(b'\x00\xAA\xBB\xCC\xDD\x00')
        test_frame_1 = axis_ep.AXIStreamFrame(b'\x01\xAA\xBB\xCC\xDD\x01')
        test_frame_2 = axis_ep.AXIStreamFrame(b'\x02\xAA\xBB\xCC\xDD\x02')
        test_frame_3 = axis_ep.AXIStreamFrame(b'\x03\xAA\xBB\xCC\xDD\x03')
        test_frame_0.last_cycle_user = 1
        source_0.send(test_frame_0)
        source_1.send(test_frame_1)
        source_2.send(test_frame_2)
        source_3.send(test_frame_3)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame.data == struct.pack('>H', tag) + test_frame_0.data + test_frame_1.data + test_frame_2.data + test_frame_3.data
        assert rx_frame.last_cycle_user

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

