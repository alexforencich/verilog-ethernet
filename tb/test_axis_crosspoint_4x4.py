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

import axis_ep

module = 'axis_crosspoint_4x4'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 8
    KEEP_ENABLE = (DATA_WIDTH>8)
    KEEP_WIDTH = (DATA_WIDTH/8)
    LAST_ENABLE = 1
    ID_ENABLE = 1
    ID_WIDTH = 8
    DEST_ENABLE = 1
    DEST_WIDTH = 8
    USER_ENABLE = 1
    USER_WIDTH = 1

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_0_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_0_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    input_0_axis_tvalid = Signal(bool(0))
    input_0_axis_tlast = Signal(bool(0))
    input_0_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    input_0_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    input_0_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    input_1_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_1_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    input_1_axis_tvalid = Signal(bool(0))
    input_1_axis_tlast = Signal(bool(0))
    input_1_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    input_1_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    input_1_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    input_2_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_2_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    input_2_axis_tvalid = Signal(bool(0))
    input_2_axis_tlast = Signal(bool(0))
    input_2_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    input_2_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    input_2_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    input_3_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_3_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    input_3_axis_tvalid = Signal(bool(0))
    input_3_axis_tlast = Signal(bool(0))
    input_3_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    input_3_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    input_3_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    output_0_select = Signal(intbv(0)[2:])
    output_1_select = Signal(intbv(0)[2:])
    output_2_select = Signal(intbv(0)[2:])
    output_3_select = Signal(intbv(0)[2:])

    # Outputs
    output_0_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_0_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    output_0_axis_tvalid = Signal(bool(0))
    output_0_axis_tlast = Signal(bool(0))
    output_0_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    output_0_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    output_0_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    output_1_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_1_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    output_1_axis_tvalid = Signal(bool(0))
    output_1_axis_tlast = Signal(bool(0))
    output_1_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    output_1_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    output_1_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    output_2_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_2_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    output_2_axis_tvalid = Signal(bool(0))
    output_2_axis_tlast = Signal(bool(0))
    output_2_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    output_2_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    output_2_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    output_3_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_3_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    output_3_axis_tvalid = Signal(bool(0))
    output_3_axis_tlast = Signal(bool(0))
    output_3_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    output_3_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    output_3_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    # sources and sinks
    source_0_pause = Signal(bool(0))
    source_1_pause = Signal(bool(0))
    source_2_pause = Signal(bool(0))
    source_3_pause = Signal(bool(0))
    sink_0_pause = Signal(bool(0))
    sink_1_pause = Signal(bool(0))
    sink_2_pause = Signal(bool(0))
    sink_3_pause = Signal(bool(0))

    source_0 = axis_ep.AXIStreamSource()

    source_0_logic = source_0.create_logic(
        clk,
        rst,
        tdata=input_0_axis_tdata,
        tkeep=input_0_axis_tkeep,
        tvalid=input_0_axis_tvalid,
        tlast=input_0_axis_tlast,
        tid=input_0_axis_tid,
        tdest=input_0_axis_tdest,
        tuser=input_0_axis_tuser,
        pause=source_0_pause,
        name='source_0'
    )

    source_1 = axis_ep.AXIStreamSource()

    source_1_logic = source_1.create_logic(
        clk,
        rst,
        tdata=input_1_axis_tdata,
        tkeep=input_1_axis_tkeep,
        tvalid=input_1_axis_tvalid,
        tlast=input_1_axis_tlast,
        tid=input_1_axis_tid,
        tdest=input_1_axis_tdest,
        tuser=input_1_axis_tuser,
        pause=source_1_pause,
        name='source_1'
    )

    source_2 = axis_ep.AXIStreamSource()

    source_2_logic = source_2.create_logic(
        clk,
        rst,
        tdata=input_2_axis_tdata,
        tkeep=input_2_axis_tkeep,
        tvalid=input_2_axis_tvalid,
        tlast=input_2_axis_tlast,
        tid=input_2_axis_tid,
        tdest=input_2_axis_tdest,
        tuser=input_2_axis_tuser,
        pause=source_2_pause,
        name='source_2'
    )

    source_3 = axis_ep.AXIStreamSource()

    source_3_logic = source_3.create_logic(
        clk,
        rst,
        tdata=input_3_axis_tdata,
        tkeep=input_3_axis_tkeep,
        tvalid=input_3_axis_tvalid,
        tlast=input_3_axis_tlast,
        tid=input_3_axis_tid,
        tdest=input_3_axis_tdest,
        tuser=input_3_axis_tuser,
        pause=source_3_pause,
        name='source_3'
    )

    sink_0 = axis_ep.AXIStreamSink()

    sink_0_logic = sink_0.create_logic(
        clk,
        rst,
        tdata=output_0_axis_tdata,
        tkeep=output_0_axis_tkeep,
        tvalid=output_0_axis_tvalid,
        tlast=output_0_axis_tlast,
        tid=output_0_axis_tid,
        tdest=output_0_axis_tdest,
        tuser=output_0_axis_tuser,
        pause=sink_0_pause,
        name='sink_0'
    )

    sink_1 = axis_ep.AXIStreamSink()

    sink_1_logic = sink_1.create_logic(
        clk,
        rst,
        tdata=output_1_axis_tdata,
        tkeep=output_1_axis_tkeep,
        tvalid=output_1_axis_tvalid,
        tlast=output_1_axis_tlast,
        tid=output_1_axis_tid,
        tdest=output_1_axis_tdest,
        tuser=output_1_axis_tuser,
        pause=sink_1_pause,
        name='sink_1'
    )

    sink_2 = axis_ep.AXIStreamSink()

    sink_2_logic = sink_2.create_logic(
        clk,
        rst,
        tdata=output_2_axis_tdata,
        tkeep=output_2_axis_tkeep,
        tvalid=output_2_axis_tvalid,
        tlast=output_2_axis_tlast,
        tid=output_2_axis_tid,
        tdest=output_2_axis_tdest,
        tuser=output_2_axis_tuser,
        pause=sink_2_pause,
        name='sink_2'
    )

    sink_3 = axis_ep.AXIStreamSink()

    sink_3_logic = sink_3.create_logic(
        clk,
        rst,
        tdata=output_3_axis_tdata,
        tkeep=output_3_axis_tkeep,
        tvalid=output_3_axis_tvalid,
        tlast=output_3_axis_tlast,
        tid=output_3_axis_tid,
        tdest=output_3_axis_tdest,
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

        input_0_axis_tdata=input_0_axis_tdata,
        input_0_axis_tkeep=input_0_axis_tkeep,
        input_0_axis_tvalid=input_0_axis_tvalid,
        input_0_axis_tlast=input_0_axis_tlast,
        input_0_axis_tid=input_0_axis_tid,
        input_0_axis_tdest=input_0_axis_tdest,
        input_0_axis_tuser=input_0_axis_tuser,
        input_1_axis_tdata=input_1_axis_tdata,
        input_1_axis_tkeep=input_1_axis_tkeep,
        input_1_axis_tvalid=input_1_axis_tvalid,
        input_1_axis_tlast=input_1_axis_tlast,
        input_1_axis_tid=input_1_axis_tid,
        input_1_axis_tdest=input_1_axis_tdest,
        input_1_axis_tuser=input_1_axis_tuser,
        input_2_axis_tdata=input_2_axis_tdata,
        input_2_axis_tkeep=input_2_axis_tkeep,
        input_2_axis_tvalid=input_2_axis_tvalid,
        input_2_axis_tlast=input_2_axis_tlast,
        input_2_axis_tid=input_2_axis_tid,
        input_2_axis_tdest=input_2_axis_tdest,
        input_2_axis_tuser=input_2_axis_tuser,
        input_3_axis_tdata=input_3_axis_tdata,
        input_3_axis_tkeep=input_3_axis_tkeep,
        input_3_axis_tvalid=input_3_axis_tvalid,
        input_3_axis_tlast=input_3_axis_tlast,
        input_3_axis_tid=input_3_axis_tid,
        input_3_axis_tdest=input_3_axis_tdest,
        input_3_axis_tuser=input_3_axis_tuser,

        output_0_axis_tdata=output_0_axis_tdata,
        output_0_axis_tkeep=output_0_axis_tkeep,
        output_0_axis_tvalid=output_0_axis_tvalid,
        output_0_axis_tlast=output_0_axis_tlast,
        output_0_axis_tid=output_0_axis_tid,
        output_0_axis_tdest=output_0_axis_tdest,
        output_0_axis_tuser=output_0_axis_tuser,
        output_1_axis_tdata=output_1_axis_tdata,
        output_1_axis_tkeep=output_1_axis_tkeep,
        output_1_axis_tvalid=output_1_axis_tvalid,
        output_1_axis_tlast=output_1_axis_tlast,
        output_1_axis_tid=output_1_axis_tid,
        output_1_axis_tdest=output_1_axis_tdest,
        output_1_axis_tuser=output_1_axis_tuser,
        output_2_axis_tdata=output_2_axis_tdata,
        output_2_axis_tkeep=output_2_axis_tkeep,
        output_2_axis_tvalid=output_2_axis_tvalid,
        output_2_axis_tlast=output_2_axis_tlast,
        output_2_axis_tid=output_2_axis_tid,
        output_2_axis_tdest=output_2_axis_tdest,
        output_2_axis_tuser=output_2_axis_tuser,
        output_3_axis_tdata=output_3_axis_tdata,
        output_3_axis_tkeep=output_3_axis_tkeep,
        output_3_axis_tvalid=output_3_axis_tvalid,
        output_3_axis_tlast=output_3_axis_tlast,
        output_3_axis_tid=output_3_axis_tid,
        output_3_axis_tdest=output_3_axis_tdest,
        output_3_axis_tuser=output_3_axis_tuser,

        output_0_select=output_0_select,
        output_1_select=output_1_select,
        output_2_select=output_2_select,
        output_3_select=output_3_select
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

        yield clk.posedge
        print("test 1: 0123 -> 0123")
        current_test.next = 1

        output_0_select.next = 0
        output_1_select.next = 1
        output_2_select.next = 2
        output_3_select.next = 3

        test_frame0 = axis_ep.AXIStreamFrame(b'\x01\x00\x00\xFF\x01\x02\x03\x04', id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x01\x01\x01\xFF\x01\x02\x03\x04', id=1, dest=1)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x01\x02\x02\xFF\x01\x02\x03\x04', id=2, dest=2)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x01\x03\x03\xFF\x01\x02\x03\x04', id=3, dest=3)
        source_0.send(test_frame0)
        source_1.send(test_frame1)
        source_2.send(test_frame2)
        source_3.send(test_frame3)

        yield sink_0.wait()
        rx_frame0 = sink_0.recv()

        assert rx_frame0 == test_frame0

        yield sink_1.wait()
        rx_frame1 = sink_1.recv()

        assert rx_frame1 == test_frame1

        yield sink_2.wait()
        rx_frame2 = sink_2.recv()

        assert rx_frame2 == test_frame2

        yield sink_3.wait()
        rx_frame3 = sink_3.recv()

        assert rx_frame3 == test_frame3

        yield delay(100)

        yield clk.posedge
        print("test 2: 0123 -> 3210")
        current_test.next = 2

        output_0_select.next = 3
        output_1_select.next = 2
        output_2_select.next = 1
        output_3_select.next = 0

        test_frame0 = axis_ep.AXIStreamFrame(b'\x02\x00\x03\xFF\x01\x02\x03\x04', id=0, dest=3)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x02\x01\x02\xFF\x01\x02\x03\x04', id=1, dest=2)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x02\x02\x01\xFF\x01\x02\x03\x04', id=2, dest=1)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x02\x03\x00\xFF\x01\x02\x03\x04', id=3, dest=0)
        source_0.send(test_frame0)
        source_1.send(test_frame1)
        source_2.send(test_frame2)
        source_3.send(test_frame3)

        yield sink_0.wait()
        rx_frame0 = sink_0.recv()

        assert rx_frame0 == test_frame3

        yield sink_1.wait()
        rx_frame1 = sink_1.recv()

        assert rx_frame1 == test_frame2

        yield sink_2.wait()
        rx_frame2 = sink_2.recv()

        assert rx_frame2 == test_frame1

        yield sink_3.wait()
        rx_frame3 = sink_3.recv()

        assert rx_frame3 == test_frame0

        yield delay(100)

        yield clk.posedge
        print("test 3: 0000 -> 0123")
        current_test.next = 3

        output_0_select.next = 0
        output_1_select.next = 0
        output_2_select.next = 0
        output_3_select.next = 0

        test_frame0 = axis_ep.AXIStreamFrame(b'\x03\x00\xFF\xFF\x01\x02\x03\x04', id=0, dest=0)
        source_0.send(test_frame0)

        yield sink_0.wait()
        rx_frame0 = sink_0.recv()

        assert rx_frame0 == test_frame0

        yield sink_1.wait()
        rx_frame1 = sink_1.recv()

        assert rx_frame1 == test_frame0

        yield sink_2.wait()
        rx_frame2 = sink_2.recv()

        assert rx_frame2 == test_frame0

        yield sink_3.wait()
        rx_frame3 = sink_3.recv()

        assert rx_frame3 == test_frame0

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

