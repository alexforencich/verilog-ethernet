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

module = 'axis_mux_4'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_mux_4(clk,
                 rst,
                 current_test,

                 input_0_axis_tdata,
                 input_0_axis_tvalid,
                 input_0_axis_tready,
                 input_0_axis_tlast,
                 input_0_axis_tuser,
                 input_1_axis_tdata,
                 input_1_axis_tvalid,
                 input_1_axis_tready,
                 input_1_axis_tlast,
                 input_1_axis_tuser,
                 input_2_axis_tdata,
                 input_2_axis_tvalid,
                 input_2_axis_tready,
                 input_2_axis_tlast,
                 input_2_axis_tuser,
                 input_3_axis_tdata,
                 input_3_axis_tvalid,
                 input_3_axis_tready,
                 input_3_axis_tlast,
                 input_3_axis_tuser,

                 output_axis_tdata,
                 output_axis_tvalid,
                 output_axis_tready,
                 output_axis_tlast,
                 output_axis_tuser,

                 enable,
                 select):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
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

                enable=enable,
                select=select)

def bench():

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

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    input_0_axis_tready = Signal(bool(0))
    input_1_axis_tready = Signal(bool(0))
    input_2_axis_tready = Signal(bool(0))
    input_3_axis_tready = Signal(bool(0))

    output_axis_tdata = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_0_queue = Queue()
    source_0_pause = Signal(bool(0))
    source_1_queue = Queue()
    source_1_pause = Signal(bool(0))
    source_2_queue = Queue()
    source_2_pause = Signal(bool(0))
    source_3_queue = Queue()
    source_3_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source_0 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_0_axis_tdata,
                                       tvalid=input_0_axis_tvalid,
                                       tready=input_0_axis_tready,
                                       tlast=input_0_axis_tlast,
                                       tuser=input_0_axis_tuser,
                                       fifo=source_0_queue,
                                       pause=source_0_pause,
                                       name='source0')
    source_1 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_1_axis_tdata,
                                       tvalid=input_1_axis_tvalid,
                                       tready=input_1_axis_tready,
                                       tlast=input_1_axis_tlast,
                                       tuser=input_1_axis_tuser,
                                       fifo=source_1_queue,
                                       pause=source_1_pause,
                                       name='source1')
    source_2 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_2_axis_tdata,
                                       tvalid=input_2_axis_tvalid,
                                       tready=input_2_axis_tready,
                                       tlast=input_2_axis_tlast,
                                       tuser=input_2_axis_tuser,
                                       fifo=source_2_queue,
                                       pause=source_2_pause,
                                       name='source2')
    source_3 = axis_ep.AXIStreamSource(clk,
                                       rst,
                                       tdata=input_3_axis_tdata,
                                       tvalid=input_3_axis_tvalid,
                                       tready=input_3_axis_tready,
                                       tlast=input_3_axis_tlast,
                                       tuser=input_3_axis_tuser,
                                       fifo=source_3_queue,
                                       pause=source_3_pause,
                                       name='source3')

    sink = axis_ep.AXIStreamSink(clk,
                                 rst,
                                 tdata=output_axis_tdata,
                                 tvalid=output_axis_tvalid,
                                 tready=output_axis_tready,
                                 tlast=output_axis_tlast,
                                 tuser=output_axis_tuser,
                                 fifo=sink_queue,
                                 pause=sink_pause,
                                 name='sink')

    # DUT
    dut = dut_axis_mux_4(clk,
                       rst,
                       current_test,

                       input_0_axis_tdata,
                       input_0_axis_tvalid,
                       input_0_axis_tready,
                       input_0_axis_tlast,
                       input_0_axis_tuser,
                       input_1_axis_tdata,
                       input_1_axis_tvalid,
                       input_1_axis_tready,
                       input_1_axis_tlast,
                       input_1_axis_tuser,
                       input_2_axis_tdata,
                       input_2_axis_tvalid,
                       input_2_axis_tready,
                       input_2_axis_tlast,
                       input_2_axis_tuser,
                       input_3_axis_tdata,
                       input_3_axis_tvalid,
                       input_3_axis_tready,
                       input_3_axis_tlast,
                       input_3_axis_tuser,

                       output_axis_tdata,
                       output_axis_tvalid,
                       output_axis_tready,
                       output_axis_tlast,
                       output_axis_tuser,

                       enable,
                       select)

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
        source_0_queue.put(test_frame)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

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
        source_1_queue.put(test_frame)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

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
        source_0_queue.put(test_frame1)
        source_0_queue.put(test_frame2)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

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
        source_1_queue.put(test_frame1)
        source_2_queue.put(test_frame2)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

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
        source_1_queue.put(test_frame1)
        source_2_queue.put(test_frame2)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
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
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

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
        source_1_queue.put(test_frame1)
        source_2_queue.put(test_frame2)
        yield clk.posedge

        while input_0_axis_tvalid or input_1_axis_tvalid or input_2_axis_tvalid or input_3_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return dut, source_0, source_1, source_2, source_3, sink, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

