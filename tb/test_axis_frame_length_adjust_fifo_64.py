#!/usr/bin/env python
"""

Copyright (c) 2015-2016 Alex Forencich

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

module = 'axis_frame_length_adjust_fifo_64'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_frame_length_adjust.v")
srcs.append("../rtl/axis_fifo.v")
srcs.append("../rtl/axis_fifo_64.v")
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_frame_length_adjust_fifo_64(clk,
                                         rst,
                                         current_test,

                                         input_axis_tdata,
                                         input_axis_tkeep,
                                         input_axis_tvalid,
                                         input_axis_tready,
                                         input_axis_tlast,
                                         input_axis_tuser,

                                         output_axis_hdr_valid,
                                         output_axis_hdr_ready,
                                         output_axis_hdr_pad,
                                         output_axis_hdr_truncate,
                                         output_axis_hdr_length,
                                         output_axis_hdr_original_length,
                                         output_axis_tdata,
                                         output_axis_tkeep,
                                         output_axis_tvalid,
                                         output_axis_tready,
                                         output_axis_tlast,
                                         output_axis_tuser,

                                         length_min,
                                         length_max):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                input_axis_tdata=input_axis_tdata,
                input_axis_tkeep=input_axis_tkeep,
                input_axis_tvalid=input_axis_tvalid,
                input_axis_tready=input_axis_tready,
                input_axis_tlast=input_axis_tlast,
                input_axis_tuser=input_axis_tuser,

                output_axis_hdr_valid=output_axis_hdr_valid,
                output_axis_hdr_ready=output_axis_hdr_ready,
                output_axis_hdr_pad=output_axis_hdr_pad,
                output_axis_hdr_truncate=output_axis_hdr_truncate,
                output_axis_hdr_length=output_axis_hdr_length,
                output_axis_hdr_original_length=output_axis_hdr_original_length,
                output_axis_tdata=output_axis_tdata,
                output_axis_tkeep=output_axis_tkeep,
                output_axis_tvalid=output_axis_tvalid,
                output_axis_tready=output_axis_tready,
                output_axis_tlast=output_axis_tlast,
                output_axis_tuser=output_axis_tuser,

                length_min=length_min,
                length_max=length_max)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[64:])
    input_axis_tkeep = Signal(intbv(0)[8:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))
    output_axis_hdr_ready = Signal(bool(0))
    output_axis_tready = Signal(bool(0))
    length_min = Signal(intbv(0)[16:])
    length_max = Signal(intbv(0)[16:])

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_axis_hdr_valid = Signal(bool(0))
    output_axis_hdr_pad = Signal(bool(0))
    output_axis_hdr_truncate = Signal(bool(0))
    output_axis_hdr_length = Signal(intbv(0)[16:])
    output_axis_hdr_original_length = Signal(intbv(0)[16:])
    output_axis_tdata = Signal(intbv(0)[64:])
    output_axis_tkeep = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))
    hdr_sink_queue = Queue()
    hdr_sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource(clk,
                                     rst,
                                     tdata=input_axis_tdata,
                                     tkeep=input_axis_tkeep,
                                     tvalid=input_axis_tvalid,
                                     tready=input_axis_tready,
                                     tlast=input_axis_tlast,
                                     tuser=input_axis_tuser,
                                     fifo=source_queue,
                                     pause=source_pause,
                                     name='source')

    sink = axis_ep.AXIStreamSink(clk,
                                 rst,
                                 tdata=output_axis_tdata,
                                 tkeep=output_axis_tkeep,
                                 tvalid=output_axis_tvalid,
                                 tready=output_axis_tready,
                                 tlast=output_axis_tlast,
                                 tuser=output_axis_tuser,
                                 fifo=sink_queue,
                                 pause=sink_pause,
                                 name='sink')

    hdr_sink = axis_ep.AXIStreamSink(clk,
                                        rst,
                                        tdata=(output_axis_hdr_pad, output_axis_hdr_truncate, output_axis_hdr_length, output_axis_hdr_original_length),
                                        tvalid=output_axis_hdr_valid,
                                        tready=output_axis_hdr_ready,
                                        fifo=hdr_sink_queue,
                                        pause=hdr_sink_pause,
                                        name='hdr_sink')

    # DUT
    dut = dut_axis_frame_length_adjust_fifo_64(clk,
                                               rst,
                                               current_test,

                                               input_axis_tdata,
                                               input_axis_tkeep,
                                               input_axis_tvalid,
                                               input_axis_tready,
                                               input_axis_tlast,
                                               input_axis_tuser,

                                               output_axis_hdr_valid,
                                               output_axis_hdr_ready,
                                               output_axis_hdr_pad,
                                               output_axis_hdr_truncate,
                                               output_axis_hdr_length,
                                               output_axis_hdr_original_length,
                                               output_axis_tdata,
                                               output_axis_tkeep,
                                               output_axis_tvalid,
                                               output_axis_tready,
                                               output_axis_tlast,
                                               output_axis_tuser,

                                               length_min,
                                               length_max)

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        while input_axis_tvalid or output_axis_tvalid:
            yield clk.posedge

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

        length_min.next = 1
        length_max.next = 20

        for lmax in range(1,18):
            for lmin in range(0,lmax+1):
                length_min.next = lmin
                length_max.next = lmax

                for payload_len in range(1,18):
                    yield clk.posedge
                    print("test 1: test packet, length %d" % payload_len)
                    current_test.next = 1

                    test_frame = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))

                    for wait in wait_normal,:
                        source_queue.put(test_frame)
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        rx_frame = None
                        if not sink_queue.empty():
                            rx_frame = sink_queue.get()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame.data[:lm]

                        hdr = hdr_sink_queue.get(False)
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink_queue.empty()
                        assert hdr_sink_queue.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 2: back-to-back packets, length %d" % payload_len)
                    current_test.next = 2

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))

                    for wait in wait_normal,:
                        source_queue.put(test_frame1)
                        source_queue.put(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        rx_frame = None
                        if not sink_queue.empty():
                            rx_frame = sink_queue.get()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        hdr = hdr_sink_queue.get(False)
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        rx_frame = None
                        if not sink_queue.empty():
                            rx_frame = sink_queue.get()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        hdr = hdr_sink_queue.get(False)
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink_queue.empty()
                        assert hdr_sink_queue.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 3: tuser assert, length %d" % payload_len)
                    current_test.next = 3

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))

                    test_frame1.user = 1

                    for wait in wait_normal,:
                        source_queue.put(test_frame1)
                        source_queue.put(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        rx_frame = None
                        if not sink_queue.empty():
                            rx_frame = sink_queue.get()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        hdr = hdr_sink_queue.get(False)
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt
                        assert rx_frame.user[-1]

                        rx_frame = None
                        if not sink_queue.empty():
                            rx_frame = sink_queue.get()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        hdr = hdr_sink_queue.get(False)
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink_queue.empty()
                        assert hdr_sink_queue.empty()

                        yield delay(100)

        raise StopSimulation

    return dut, source, sink, hdr_sink, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

