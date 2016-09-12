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

import axis_ep

module = 'axis_frame_length_adjust_fifo_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_frame_length_adjust.v")
srcs.append("../rtl/axis_fifo.v")
srcs.append("../rtl/axis_fifo_64.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 64
    KEEP_WIDTH = (DATA_WIDTH/8)
    FRAME_FIFO_ADDR_WIDTH = 9
    HEADER_FIFO_ADDR_WIDTH = 3

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
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
    output_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))
    hdr_sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk,
        rst,
        tdata=input_axis_tdata,
        tkeep=input_axis_tkeep,
        tvalid=input_axis_tvalid,
        tready=input_axis_tready,
        tlast=input_axis_tlast,
        tuser=input_axis_tuser,
        pause=source_pause,
        name='source'
    )

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=output_axis_tdata,
        tkeep=output_axis_tkeep,
        tvalid=output_axis_tvalid,
        tready=output_axis_tready,
        tlast=output_axis_tlast,
        tuser=output_axis_tuser,
        pause=sink_pause,
        name='sink'
    )

    hdr_sink = axis_ep.AXIStreamSink()

    hdr_sink_logic = hdr_sink.create_logic(
        clk,
        rst,
        tdata=(output_axis_hdr_pad, output_axis_hdr_truncate, output_axis_hdr_length, output_axis_hdr_original_length),
        tvalid=output_axis_hdr_valid,
        tready=output_axis_hdr_ready,
        pause=hdr_sink_pause,
        name='hdr_sink'
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
        length_max=length_max
    )

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
                        source.send(test_frame)
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

                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame.data[:lm]

                        hdr = hdr_sink.recv()
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink.empty()
                        assert hdr_sink.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 2: back-to-back packets, length %d" % payload_len)
                    current_test.next = 2

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))

                    for wait in wait_normal,:
                        source.send(test_frame1)
                        source.send(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        hdr = hdr_sink.recv()
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        hdr = hdr_sink.recv()
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink.empty()
                        assert hdr_sink.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 3: tuser assert, length %d" % payload_len)
                    current_test.next = 3

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)))

                    test_frame1.user = 1

                    for wait in wait_normal,:
                        source.send(test_frame1)
                        source.send(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge
                        yield clk.posedge

                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        hdr = hdr_sink.recv()
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt
                        assert rx_frame.user[-1]

                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        hdr = hdr_sink.recv()
                        assert hdr.data[0][0] == (lt < lmin)
                        assert hdr.data[0][1] == (lt > lmax)
                        assert hdr.data[0][2] == lrx
                        assert hdr.data[0][3] == lt

                        assert sink.empty()
                        assert hdr_sink.empty()

                        yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_logic, hdr_sink_logic, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

