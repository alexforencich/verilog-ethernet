#!/usr/bin/env python
"""

Copyright (c) 2014 Alex Forencich

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

import axis_ep

module = 'axis_crosspoint_4x4'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_crosspoint_4x4(clk,
                 rst,
                 current_test,

                 input_0_axis_tdata,
                 input_0_axis_tvalid,
                 input_0_axis_tlast,
                 input_1_axis_tdata,
                 input_1_axis_tvalid,
                 input_1_axis_tlast,
                 input_2_axis_tdata,
                 input_2_axis_tvalid,
                 input_2_axis_tlast,
                 input_3_axis_tdata,
                 input_3_axis_tvalid,
                 input_3_axis_tlast,

                 output_0_axis_tdata,
                 output_0_axis_tvalid,
                 output_0_axis_tlast,
                 output_1_axis_tdata,
                 output_1_axis_tvalid,
                 output_1_axis_tlast,
                 output_2_axis_tdata,
                 output_2_axis_tvalid,
                 output_2_axis_tlast,
                 output_3_axis_tdata,
                 output_3_axis_tvalid,
                 output_3_axis_tlast,

                 output_0_select,
                 output_1_select,
                 output_2_select,
                 output_3_select):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                input_0_axis_tdata=input_0_axis_tdata,
                input_0_axis_tvalid=input_0_axis_tvalid,
                input_0_axis_tlast=input_0_axis_tlast,
                input_1_axis_tdata=input_1_axis_tdata,
                input_1_axis_tvalid=input_1_axis_tvalid,
                input_1_axis_tlast=input_1_axis_tlast,
                input_2_axis_tdata=input_2_axis_tdata,
                input_2_axis_tvalid=input_2_axis_tvalid,
                input_2_axis_tlast=input_2_axis_tlast,
                input_3_axis_tdata=input_3_axis_tdata,
                input_3_axis_tvalid=input_3_axis_tvalid,
                input_3_axis_tlast=input_3_axis_tlast,

                output_0_axis_tdata=output_0_axis_tdata,
                output_0_axis_tvalid=output_0_axis_tvalid,
                output_0_axis_tlast=output_0_axis_tlast,
                output_1_axis_tdata=output_1_axis_tdata,
                output_1_axis_tvalid=output_1_axis_tvalid,
                output_1_axis_tlast=output_1_axis_tlast,
                output_2_axis_tdata=output_2_axis_tdata,
                output_2_axis_tvalid=output_2_axis_tvalid,
                output_2_axis_tlast=output_2_axis_tlast,
                output_3_axis_tdata=output_3_axis_tdata,
                output_3_axis_tvalid=output_3_axis_tvalid,
                output_3_axis_tlast=output_3_axis_tlast,

                output_0_select=output_0_select,
                output_1_select=output_1_select,
                output_2_select=output_2_select,
                output_3_select=output_3_select)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_0_axis_tdata = Signal(intbv(0)[8:])
    input_0_axis_tvalid = Signal(bool(0))
    input_0_axis_tlast = Signal(bool(0))
    input_1_axis_tdata = Signal(intbv(0)[8:])
    input_1_axis_tvalid = Signal(bool(0))
    input_1_axis_tlast = Signal(bool(0))
    input_2_axis_tdata = Signal(intbv(0)[8:])
    input_2_axis_tvalid = Signal(bool(0))
    input_2_axis_tlast = Signal(bool(0))
    input_3_axis_tdata = Signal(intbv(0)[8:])
    input_3_axis_tvalid = Signal(bool(0))
    input_3_axis_tlast = Signal(bool(0))

    output_0_select = Signal(intbv(0)[2:])
    output_1_select = Signal(intbv(0)[2:])
    output_2_select = Signal(intbv(0)[2:])
    output_3_select = Signal(intbv(0)[2:])

    # Outputs
    output_0_axis_tdata = Signal(intbv(0)[8:])
    output_0_axis_tvalid = Signal(bool(0))
    output_0_axis_tlast = Signal(bool(0))
    output_1_axis_tdata = Signal(intbv(0)[8:])
    output_1_axis_tvalid = Signal(bool(0))
    output_1_axis_tlast = Signal(bool(0))
    output_2_axis_tdata = Signal(intbv(0)[8:])
    output_2_axis_tvalid = Signal(bool(0))
    output_2_axis_tlast = Signal(bool(0))
    output_3_axis_tdata = Signal(intbv(0)[8:])
    output_3_axis_tvalid = Signal(bool(0))
    output_3_axis_tlast = Signal(bool(0))

    # sources and sinks
    source_0_queue = Queue()
    source_0_pause = Signal(bool(0))
    source_1_queue = Queue()
    source_1_pause = Signal(bool(0))
    source_2_queue = Queue()
    source_2_pause = Signal(bool(0))
    source_3_queue = Queue()
    source_3_pause = Signal(bool(0))
    sink_0_queue = Queue()
    sink_0_pause = Signal(bool(0))
    sink_1_queue = Queue()
    sink_1_pause = Signal(bool(0))
    sink_2_queue = Queue()
    sink_2_pause = Signal(bool(0))
    sink_3_queue = Queue()
    sink_3_pause = Signal(bool(0))

    source_0 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_0_axis_tdata,
                                       tvalid=input_0_axis_tvalid,
                                       tlast=input_0_axis_tlast,
                                       fifo=source_0_queue,
                                       pause=source_0_pause,
                                       name='source0')
    source_1 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_1_axis_tdata,
                                       tvalid=input_1_axis_tvalid,
                                       tlast=input_1_axis_tlast,
                                       fifo=source_1_queue,
                                       pause=source_1_pause,
                                       name='source1')
    source_2 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_2_axis_tdata,
                                       tvalid=input_2_axis_tvalid,
                                       tlast=input_2_axis_tlast,
                                       fifo=source_2_queue,
                                       pause=source_2_pause,
                                       name='source2')
    source_3 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_3_axis_tdata,
                                       tvalid=input_3_axis_tvalid,
                                       tlast=input_3_axis_tlast,
                                       fifo=source_3_queue,
                                       pause=source_3_pause,
                                       name='source3')

    sink_0 = axis_ep.AXIStreamSink(clk,
                                   rst,
                                   tdata=output_0_axis_tdata,
                                   tvalid=output_0_axis_tvalid,
                                   tlast=output_0_axis_tlast,
                                   fifo=sink_0_queue,
                                   pause=sink_0_pause,
                                   name='sink0')
    sink_1 = axis_ep.AXIStreamSink(clk,
                                   rst,
                                   tdata=output_1_axis_tdata,
                                   tvalid=output_1_axis_tvalid,
                                   tlast=output_1_axis_tlast,
                                   fifo=sink_1_queue,
                                   pause=sink_1_pause,
                                   name='sink1')
    sink_2 = axis_ep.AXIStreamSink(clk,
                                   rst,
                                   tdata=output_2_axis_tdata,
                                   tvalid=output_2_axis_tvalid,
                                   tlast=output_2_axis_tlast,
                                   fifo=sink_2_queue,
                                   pause=sink_2_pause,
                                   name='sink2')
    sink_3 = axis_ep.AXIStreamSink(clk,
                                   rst,
                                   tdata=output_3_axis_tdata,
                                   tvalid=output_3_axis_tvalid,
                                   tlast=output_3_axis_tlast,
                                   fifo=sink_3_queue,
                                   pause=sink_3_pause,
                                   name='sink3')

    # DUT
    dut = dut_axis_crosspoint_4x4(clk,
                       rst,
                       current_test,

                       input_0_axis_tdata,
                       input_0_axis_tvalid,
                       input_0_axis_tlast,
                       input_1_axis_tdata,
                       input_1_axis_tvalid,
                       input_1_axis_tlast,
                       input_2_axis_tdata,
                       input_2_axis_tvalid,
                       input_2_axis_tlast,
                       input_3_axis_tdata,
                       input_3_axis_tvalid,
                       input_3_axis_tlast,

                       output_0_axis_tdata,
                       output_0_axis_tvalid,
                       output_0_axis_tlast,
                       output_1_axis_tdata,
                       output_1_axis_tvalid,
                       output_1_axis_tlast,
                       output_2_axis_tdata,
                       output_2_axis_tvalid,
                       output_2_axis_tlast,
                       output_3_axis_tdata,
                       output_3_axis_tvalid,
                       output_3_axis_tlast,

                       output_0_select,
                       output_1_select,
                       output_2_select,
                       output_3_select)

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

        test_frame0 = axis_ep.AXIStreamFrame(b'\x01\x00\x00\xFF\x01\x02\x03\x04')
        test_frame1 = axis_ep.AXIStreamFrame(b'\x01\x01\x01\xFF\x01\x02\x03\x04')
        test_frame2 = axis_ep.AXIStreamFrame(b'\x01\x02\x02\xFF\x01\x02\x03\x04')
        test_frame3 = axis_ep.AXIStreamFrame(b'\x01\x03\x03\xFF\x01\x02\x03\x04')
        source_0_queue.put(test_frame0)
        source_1_queue.put(test_frame1)
        source_2_queue.put(test_frame2)
        source_3_queue.put(test_frame3)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame0 = None
        if not sink_0_queue.empty():
            rx_frame0 = sink_0_queue.get()

        assert rx_frame0 == test_frame0

        rx_frame1 = None
        if not sink_1_queue.empty():
            rx_frame1 = sink_1_queue.get()

        assert rx_frame1 == test_frame1

        rx_frame2 = None
        if not sink_2_queue.empty():
            rx_frame2 = sink_2_queue.get()

        assert rx_frame2 == test_frame2

        rx_frame3 = None
        if not sink_3_queue.empty():
            rx_frame3 = sink_3_queue.get()

        assert rx_frame3 == test_frame3

        yield delay(100)

        yield clk.posedge
        print("test 2: 0123 -> 3210")
        current_test.next = 2

        output_0_select.next = 3
        output_1_select.next = 2
        output_2_select.next = 1
        output_3_select.next = 0

        test_frame0 = axis_ep.AXIStreamFrame(b'\x02\x00\x03\xFF\x01\x02\x03\x04')
        test_frame1 = axis_ep.AXIStreamFrame(b'\x02\x01\x02\xFF\x01\x02\x03\x04')
        test_frame2 = axis_ep.AXIStreamFrame(b'\x02\x02\x01\xFF\x01\x02\x03\x04')
        test_frame3 = axis_ep.AXIStreamFrame(b'\x02\x03\x00\xFF\x01\x02\x03\x04')
        source_0_queue.put(test_frame0)
        source_1_queue.put(test_frame1)
        source_2_queue.put(test_frame2)
        source_3_queue.put(test_frame3)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame0 = None
        if not sink_0_queue.empty():
            rx_frame0 = sink_0_queue.get()

        assert rx_frame0 == test_frame3

        rx_frame1 = None
        if not sink_1_queue.empty():
            rx_frame1 = sink_1_queue.get()

        assert rx_frame1 == test_frame2

        rx_frame2 = None
        if not sink_2_queue.empty():
            rx_frame2 = sink_2_queue.get()

        assert rx_frame2 == test_frame1

        rx_frame3 = None
        if not sink_3_queue.empty():
            rx_frame3 = sink_3_queue.get()

        assert rx_frame3 == test_frame0

        yield delay(100)

        yield clk.posedge
        print("test 3: 0000 -> 0123")
        current_test.next = 3

        output_0_select.next = 0
        output_1_select.next = 0
        output_2_select.next = 0
        output_3_select.next = 0

        test_frame0 = axis_ep.AXIStreamFrame(b'\x03\x00\xFF\xFF\x01\x02\x03\x04')
        source_0_queue.put(test_frame0)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame0 = None
        if not sink_0_queue.empty():
            rx_frame0 = sink_0_queue.get()

        assert rx_frame0 == test_frame0

        rx_frame1 = None
        if not sink_1_queue.empty():
            rx_frame1 = sink_1_queue.get()

        assert rx_frame1 == test_frame0

        rx_frame2 = None
        if not sink_2_queue.empty():
            rx_frame2 = sink_2_queue.get()

        assert rx_frame2 == test_frame0

        rx_frame3 = None
        if not sink_3_queue.empty():
            rx_frame3 = sink_3_queue.get()

        assert rx_frame3 == test_frame0

        yield delay(100)

        raise StopSimulation

    return dut, source_0, source_1, source_2, source_3, sink_0, sink_1, sink_2, sink_3, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

