#!/usr/bin/env python
"""

Copyright (c) 2015-2018 Alex Forencich

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

module = 'axis_frame_length_adjust'
testbench = 'test_%s_64' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 64
    KEEP_ENABLE = (DATA_WIDTH>8)
    KEEP_WIDTH = (DATA_WIDTH/8)
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

    s_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    s_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    s_axis_tvalid = Signal(bool(0))
    s_axis_tlast = Signal(bool(0))
    s_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    s_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    s_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    m_axis_tready = Signal(bool(0))
    status_ready = Signal(bool(0))
    length_min = Signal(intbv(0)[16:])
    length_max = Signal(intbv(0)[16:])

    # Outputs
    s_axis_tready = Signal(bool(0))
    m_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    m_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    m_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    status_valid = Signal(bool(0))
    status_frame_pad = Signal(bool(0))
    status_frame_truncate = Signal(bool(0))
    status_frame_length = Signal(intbv(0)[16:])
    status_frame_original_length = Signal(intbv(0)[16:])

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))
    status_sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk,
        rst,
        tdata=s_axis_tdata,
        tkeep=s_axis_tkeep,
        tvalid=s_axis_tvalid,
        tready=s_axis_tready,
        tlast=s_axis_tlast,
        tid=s_axis_tid,
        tdest=s_axis_tdest,
        tuser=s_axis_tuser,
        pause=source_pause,
        name='source'
    )

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=m_axis_tdata,
        tkeep=m_axis_tkeep,
        tvalid=m_axis_tvalid,
        tready=m_axis_tready,
        tlast=m_axis_tlast,
        tid=m_axis_tid,
        tdest=m_axis_tdest,
        tuser=m_axis_tuser,
        pause=sink_pause,
        name='sink'
    )

    status_sink = axis_ep.AXIStreamSink()

    status_sink_logic = status_sink.create_logic(
        clk,
        rst,
        tdata=(status_frame_pad, status_frame_truncate, status_frame_length, status_frame_original_length),
        tvalid=status_valid,
        tready=status_ready,
        pause=status_sink_pause,
        name='status_sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        s_axis_tdata=s_axis_tdata,
        s_axis_tkeep=s_axis_tkeep,
        s_axis_tvalid=s_axis_tvalid,
        s_axis_tready=s_axis_tready,
        s_axis_tlast=s_axis_tlast,
        s_axis_tid=s_axis_tid,
        s_axis_tdest=s_axis_tdest,
        s_axis_tuser=s_axis_tuser,

        m_axis_tdata=m_axis_tdata,
        m_axis_tkeep=m_axis_tkeep,
        m_axis_tvalid=m_axis_tvalid,
        m_axis_tready=m_axis_tready,
        m_axis_tlast=m_axis_tlast,
        m_axis_tid=m_axis_tid,
        m_axis_tdest=m_axis_tdest,
        m_axis_tuser=m_axis_tuser,

        status_valid=status_valid,
        status_ready=status_ready,
        status_frame_pad=status_frame_pad,
        status_frame_truncate=status_frame_truncate,
        status_frame_length=status_frame_length,
        status_frame_original_length=status_frame_original_length,

        length_min=length_min,
        length_max=length_max
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        while s_axis_tvalid or m_axis_tvalid:
            yield clk.posedge

    def wait_pause_source():
        while s_axis_tvalid or m_axis_tvalid:
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            source_pause.next = True
            yield clk.posedge

        source_pause.next = False

    def wait_pause_sink():
        while s_axis_tvalid or m_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
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

                    test_frame = axis_ep.AXIStreamFrame(bytearray(range(payload_len)), id=1, dest=1)

                    for wait in wait_normal, wait_pause_source, wait_pause_sink:
                        source.send(test_frame)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield sink.wait()
                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame.data[:lm]

                        yield status_sink.wait()
                        status = status_sink.recv()
                        assert status.data[0][0] == (lt < lmin)
                        assert status.data[0][1] == (lt > lmax)
                        assert status.data[0][2] == lrx
                        assert status.data[0][3] == lt

                        assert sink.empty()
                        assert status_sink.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 2: back-to-back packets, length %d" % payload_len)
                    current_test.next = 2

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)), id=2, dest=1)
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)), id=2, dest=2)

                    for wait in wait_normal, wait_pause_source, wait_pause_sink:
                        source.send(test_frame1)
                        source.send(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield sink.wait()
                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        yield status_sink.wait()
                        status = status_sink.recv()
                        assert status.data[0][0] == (lt < lmin)
                        assert status.data[0][1] == (lt > lmax)
                        assert status.data[0][2] == lrx
                        assert status.data[0][3] == lt

                        yield sink.wait()
                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        yield status_sink.wait()
                        status = status_sink.recv()
                        assert status.data[0][0] == (lt < lmin)
                        assert status.data[0][1] == (lt > lmax)
                        assert status.data[0][2] == lrx
                        assert status.data[0][3] == lt

                        assert sink.empty()
                        assert status_sink.empty()

                        yield delay(100)

                    yield clk.posedge
                    print("test 3: tuser assert, length %d" % payload_len)
                    current_test.next = 3

                    test_frame1 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)), id=3, dest=1)
                    test_frame2 = axis_ep.AXIStreamFrame(bytearray(range(payload_len)), id=3, dest=2)

                    test_frame1.last_cycle_user = 1

                    for wait in wait_normal, wait_pause_source, wait_pause_sink:
                        source.send(test_frame1)
                        source.send(test_frame2)
                        yield clk.posedge
                        yield clk.posedge

                        yield wait()

                        yield sink.wait()
                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame1.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame1.data[:lm]

                        assert rx_frame.last_cycle_user

                        yield status_sink.wait()
                        status = status_sink.recv()
                        assert status.data[0][0] == (lt < lmin)
                        assert status.data[0][1] == (lt > lmax)
                        assert status.data[0][2] == lrx
                        assert status.data[0][3] == lt

                        yield sink.wait()
                        rx_frame = sink.recv()

                        lrx = len(rx_frame.data)
                        lt = len(test_frame2.data)
                        lm = min(lrx, lt)
                        assert lrx >= lmin
                        assert lrx <= lmax
                        assert rx_frame.data[:lm] == test_frame2.data[:lm]

                        yield status_sink.wait()
                        status = status_sink.recv()
                        assert status.data[0][0] == (lt < lmin)
                        assert status.data[0][1] == (lt > lmax)
                        assert status.data[0][2] == lrx
                        assert status.data[0][3] == lt

                        assert sink.empty()
                        assert status_sink.empty()

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

