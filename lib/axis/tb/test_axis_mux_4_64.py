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

module = 'axis_mux'
testbench = 'test_%s_4_64' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    S_COUNT = 4
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

    s_axis_tdata_list = [Signal(intbv(0)[DATA_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tkeep_list = [Signal(intbv(1)[KEEP_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tvalid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_axis_tlast_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_axis_tid_list = [Signal(intbv(0)[ID_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tdest_list = [Signal(intbv(0)[DEST_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tuser_list = [Signal(intbv(0)[USER_WIDTH:]) for i in range(S_COUNT)]

    s_axis_tdata = ConcatSignal(*reversed(s_axis_tdata_list))
    s_axis_tkeep = ConcatSignal(*reversed(s_axis_tkeep_list))
    s_axis_tvalid = ConcatSignal(*reversed(s_axis_tvalid_list))
    s_axis_tlast = ConcatSignal(*reversed(s_axis_tlast_list))
    s_axis_tid = ConcatSignal(*reversed(s_axis_tid_list))
    s_axis_tdest = ConcatSignal(*reversed(s_axis_tdest_list))
    s_axis_tuser = ConcatSignal(*reversed(s_axis_tuser_list))

    m_axis_tready = Signal(bool(0))

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    s_axis_tready = Signal(intbv(0)[S_COUNT:])

    s_axis_tready_list = [s_axis_tready(i) for i in range(S_COUNT)]

    m_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    m_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    m_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    # sources and sinks
    source_pause_list = []
    source_list = []
    source_logic_list = []
    sink_pause = Signal(bool(0))

    for k in range(S_COUNT):
        s = axis_ep.AXIStreamSource()
        p = Signal(bool(0))

        source_list.append(s)
        source_pause_list.append(p)

        source_logic_list.append(s.create_logic(
            clk,
            rst,
            tdata=s_axis_tdata_list[k],
            tkeep=s_axis_tkeep_list[k],
            tvalid=s_axis_tvalid_list[k],
            tready=s_axis_tready_list[k],
            tlast=s_axis_tlast_list[k],
            tid=s_axis_tid_list[k],
            tdest=s_axis_tdest_list[k],
            tuser=s_axis_tuser_list[k],
            pause=p,
            name='source_%d' % k
        ))

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

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=1,
            dest=1
        )

        source_list[0].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: select port 1")
        current_test.next = 2

        select.next = 1

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=2,
            dest=1
        )

        source_list[1].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        select.next = 0

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=3,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=3,
            dest=2
        )

        source_list[0].send(test_frame1)
        source_list[0].send(test_frame2)

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

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=4,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=4,
            dest=2
        )

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid:
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
        print("test 5: alternate pause source")
        current_test.next = 5

        select.next = 1

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=5,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=5,
            dest=2
        )

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid:
            yield clk.posedge
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = False
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = True
            yield clk.posedge
            select.next = 2

        for k in range(S_COUNT):
            source_pause_list[k].next = False

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

        select.next = 1

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=6,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=6,
            dest=2
        )

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid:
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

