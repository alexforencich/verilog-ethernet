#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

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

module = 'axis_async_fifo_adapter'
testbench = 'test_%s_64_8' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_adapter.v")
srcs.append("../rtl/axis_async_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DEPTH = 32
    S_DATA_WIDTH = 64
    S_KEEP_ENABLE = (S_DATA_WIDTH>8)
    S_KEEP_WIDTH = (S_DATA_WIDTH/8)
    M_DATA_WIDTH = 8
    M_KEEP_ENABLE = (M_DATA_WIDTH>8)
    M_KEEP_WIDTH = (M_DATA_WIDTH/8)
    ID_ENABLE = 1
    ID_WIDTH = 8
    DEST_ENABLE = 1
    DEST_WIDTH = 8
    USER_ENABLE = 1
    USER_WIDTH = 1
    PIPELINE_OUTPUT = 2
    FRAME_FIFO = 0
    USER_BAD_FRAME_VALUE = 1
    USER_BAD_FRAME_MASK = 1
    DROP_BAD_FRAME = 0
    DROP_WHEN_FULL = 0

    # Inputs
    s_clk = Signal(bool(0))
    s_rst = Signal(bool(0))
    m_clk = Signal(bool(0))
    m_rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_axis_tdata = Signal(intbv(0)[S_DATA_WIDTH:])
    s_axis_tkeep = Signal(intbv(1)[S_KEEP_WIDTH:])
    s_axis_tvalid = Signal(bool(0))
    s_axis_tlast = Signal(bool(0))
    s_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    s_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    s_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    m_axis_tready = Signal(bool(0))

    # Outputs
    s_axis_tready = Signal(bool(0))
    m_axis_tdata = Signal(intbv(0)[M_DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(1)[M_KEEP_WIDTH:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    m_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    m_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        s_clk,
        s_rst,
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
        m_clk,
        m_rst,
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

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        s_clk=s_clk,
        s_rst=s_rst,
        m_clk=m_clk,
        m_rst=m_rst,
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
        m_axis_tuser=m_axis_tuser
    )

    @always(delay(4))
    def s_clkgen():
        s_clk.next = not s_clk

    @always(delay(5))
    def m_clkgen():
        m_clk.next = not m_clk

    def wait_normal():
        while s_axis_tvalid or m_axis_tvalid:
            yield s_clk.posedge

    def wait_pause_source():
        while s_axis_tvalid or m_axis_tvalid:
            yield s_clk.posedge
            yield s_clk.posedge
            source_pause.next = False
            yield s_clk.posedge
            source_pause.next = True
            yield s_clk.posedge

        source_pause.next = False

    def wait_pause_sink():
        while s_axis_tvalid or m_axis_tvalid:
            sink_pause.next = True
            yield s_clk.posedge
            yield s_clk.posedge
            yield s_clk.posedge
            sink_pause.next = False
            yield s_clk.posedge

    @instance
    def check():
        yield delay(100)
        yield s_clk.posedge
        s_rst.next = 1
        m_rst.next = 1
        yield s_clk.posedge
        yield s_clk.posedge
        yield s_clk.posedge
        s_rst.next = 0
        m_rst.next = 0
        yield s_clk.posedge
        yield delay(100)
        yield s_clk.posedge

        for payload_len in range(1,18):
            yield s_clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = axis_ep.AXIStreamFrame(
                bytearray(range(payload_len)),
                id=1,
                dest=1,
            )

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame)
                yield s_clk.posedge
                yield s_clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                assert rx_frame == test_frame

                assert sink.empty()

                yield delay(100)

            yield s_clk.posedge
            print("test 2: back-to-back packets, length %d" % payload_len)
            current_test.next = 2

            test_frame1 = axis_ep.AXIStreamFrame(
                bytearray(range(payload_len)),
                id=2,
                dest=1,
            )
            test_frame2 = axis_ep.AXIStreamFrame(
                bytearray(range(payload_len)),
                id=2,
                dest=2,
            )

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield s_clk.posedge
                yield s_clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                assert rx_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                assert rx_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield s_clk.posedge
            print("test 3: tuser assert, length %d" % payload_len)
            current_test.next = 3

            test_frame1 = axis_ep.AXIStreamFrame(
                bytearray(range(payload_len)),
                id=3,
                dest=1,
                last_cycle_user=1
            )
            test_frame2 = axis_ep.AXIStreamFrame(
                bytearray(range(payload_len)),
                id=3,
                dest=2,
            )

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield s_clk.posedge
                yield s_clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                assert rx_frame == test_frame1
                assert rx_frame.last_cycle_user

                yield sink.wait()
                rx_frame = sink.recv()

                assert rx_frame == test_frame2

                assert sink.empty()

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

