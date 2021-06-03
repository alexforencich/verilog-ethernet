#!/usr/bin/env python
"""

Copyright (c) 2020 Alex Forencich

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

module = 'axis_ram_switch'
testbench = 'test_%s_4x1_64_256' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
# srcs.append("../rtl/axis_ram_switch_input.v")
# srcs.append("../rtl/axis_ram_switch_output.v")
srcs.append("../rtl/axis_adapter.v")
srcs.append("../rtl/arbiter.v")
srcs.append("../rtl/priority_encoder.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    FIFO_DEPTH = 512
    SPEEDUP = 0
    S_COUNT = 4
    M_COUNT = 1
    S_DATA_WIDTH = 64
    S_KEEP_ENABLE = (S_DATA_WIDTH>8)
    S_KEEP_WIDTH = (S_DATA_WIDTH/8)
    M_DATA_WIDTH = 256
    M_KEEP_ENABLE = (M_DATA_WIDTH>8)
    M_KEEP_WIDTH = (M_DATA_WIDTH/8)
    ID_ENABLE = 1
    ID_WIDTH = 8
    DEST_WIDTH = (M_COUNT+1-1).bit_length()
    USER_ENABLE = 1
    USER_WIDTH = 1
    USER_BAD_FRAME_VALUE = 1
    USER_BAD_FRAME_MASK = 1
    DROP_BAD_FRAME = 1
    DROP_WHEN_FULL = 0
    M_BASE = [0, 1, 2, 3]
    M_TOP = [0, 1, 2, 3]
    M_CONNECT = [0b1111]*M_COUNT
    ARB_TYPE_ROUND_ROBIN = 1
    ARB_LSB_HIGH_PRIORITY = 1
    RAM_PIPELINE = 2

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_axis_tdata_list = [Signal(intbv(0)[S_DATA_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tkeep_list = [Signal(intbv(1)[S_KEEP_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tvalid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_axis_tlast_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_axis_tid_list = [Signal(intbv(0)[ID_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tdest_list = [Signal(intbv(0)[DEST_WIDTH:]) for i in range(S_COUNT)]
    s_axis_tuser_list = [Signal(intbv(0)[USER_WIDTH:]) for i in range(S_COUNT)]

    # s_axis_tdata = ConcatSignal(*reversed(s_axis_tdata_list))
    # s_axis_tkeep = ConcatSignal(*reversed(s_axis_tkeep_list))
    # s_axis_tvalid = ConcatSignal(*reversed(s_axis_tvalid_list))
    # s_axis_tlast = ConcatSignal(*reversed(s_axis_tlast_list))
    # s_axis_tid = ConcatSignal(*reversed(s_axis_tid_list))
    # s_axis_tdest = ConcatSignal(*reversed(s_axis_tdest_list))
    # s_axis_tuser = ConcatSignal(*reversed(s_axis_tuser_list))

    if S_COUNT == 1:
        s_axis_tdata = s_axis_tdata_list[0]
        s_axis_tkeep = s_axis_tkeep_list[0]
        s_axis_tvalid = s_axis_tvalid_list[0]
        s_axis_tlast = s_axis_tlast_list[0]
        s_axis_tid = s_axis_tid_list[0]
        s_axis_tdest = s_axis_tdest_list[0]
        s_axis_tuser = s_axis_tuser_list[0]
    else:
        s_axis_tdata = ConcatSignal(*reversed(s_axis_tdata_list))
        s_axis_tkeep = ConcatSignal(*reversed(s_axis_tkeep_list))
        s_axis_tvalid = ConcatSignal(*reversed(s_axis_tvalid_list))
        s_axis_tlast = ConcatSignal(*reversed(s_axis_tlast_list))
        s_axis_tid = ConcatSignal(*reversed(s_axis_tid_list))
        s_axis_tdest = ConcatSignal(*reversed(s_axis_tdest_list))
        s_axis_tuser = ConcatSignal(*reversed(s_axis_tuser_list))

    m_axis_tready_list = [Signal(bool(0)) for i in range(M_COUNT)]

    # m_axis_tready = ConcatSignal(*reversed(m_axis_tready_list))

    if M_COUNT == 1:
        m_axis_tready = m_axis_tready_list[0]
    else:
        m_axis_tready = ConcatSignal(*reversed(m_axis_tready_list))

    # Outputs
    s_axis_tready = Signal(intbv(0)[S_COUNT:])

    s_axis_tready_list = [s_axis_tready(i) for i in range(S_COUNT)]

    m_axis_tdata = Signal(intbv(0)[M_COUNT*M_DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(0xf)[M_COUNT*M_KEEP_WIDTH:])
    m_axis_tvalid = Signal(intbv(0)[M_COUNT:])
    m_axis_tlast = Signal(intbv(0)[M_COUNT:])
    m_axis_tid = Signal(intbv(0)[M_COUNT*ID_WIDTH:])
    m_axis_tdest = Signal(intbv(0)[M_COUNT*DEST_WIDTH:])
    m_axis_tuser = Signal(intbv(0)[M_COUNT*USER_WIDTH:])

    m_axis_tdata_list = [m_axis_tdata((i+1)*M_DATA_WIDTH, i*M_DATA_WIDTH) for i in range(M_COUNT)]
    m_axis_tkeep_list = [m_axis_tkeep((i+1)*M_KEEP_WIDTH, i*M_KEEP_WIDTH) for i in range(M_COUNT)]
    m_axis_tvalid_list = [m_axis_tvalid(i) for i in range(M_COUNT)]
    m_axis_tlast_list = [m_axis_tlast(i) for i in range(M_COUNT)]
    m_axis_tid_list = [m_axis_tid((i+1)*ID_WIDTH, i*ID_WIDTH) for i in range(M_COUNT)]
    m_axis_tdest_list = [m_axis_tdest((i+1)*DEST_WIDTH, i*DEST_WIDTH) for i in range(M_COUNT)]
    m_axis_tuser_list = [m_axis_tuser((i+1)*USER_WIDTH, i*USER_WIDTH) for i in range(M_COUNT)]

    status_overflow = Signal(intbv(0)[S_COUNT:])
    status_bad_frame = Signal(intbv(0)[S_COUNT:])
    status_good_frame = Signal(intbv(0)[S_COUNT:])

    # sources and sinks
    source_pause_list = []
    source_list = []
    source_logic_list = []
    sink_pause_list = []
    sink_list = []
    sink_logic_list = []

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

    for k in range(M_COUNT):
        s = axis_ep.AXIStreamSink()
        p = Signal(bool(0))

        sink_list.append(s)
        sink_pause_list.append(p)

        sink_logic_list.append(s.create_logic(
            clk,
            rst,
            tdata=m_axis_tdata_list[k],
            tkeep=m_axis_tkeep_list[k],
            tvalid=m_axis_tvalid_list[k],
            tready=m_axis_tready_list[k],
            tlast=m_axis_tlast_list[k],
            tid=m_axis_tid_list[k],
            tdest=m_axis_tdest_list[k],
            tuser=m_axis_tuser_list[k],
            pause=p,
            name='sink_%d' % k
        ))

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

        status_overflow=status_overflow,
        status_bad_frame=status_bad_frame,
        status_good_frame=status_good_frame
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    status_overflow_latch = Signal(intbv(0)[S_COUNT:])
    status_bad_frame_latch = Signal(intbv(0)[S_COUNT:])
    status_good_frame_latch = Signal(intbv(0)[S_COUNT:])

    @always(clk.posedge)
    def monitor():
        if status_overflow:
            status_overflow_latch.next = status_overflow_latch | status_overflow
        if status_bad_frame:
            status_bad_frame_latch.next = status_bad_frame_latch | status_bad_frame
        if status_good_frame:
            status_good_frame_latch.next = status_good_frame_latch | status_good_frame

    def wait_normal():
        while s_axis_tvalid:
            yield clk.posedge

    def wait_pause_source():
        while s_axis_tvalid:
            yield clk.posedge
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = False
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = True
            yield clk.posedge

        for k in range(S_COUNT):
            source_pause_list[k].next = False

    def wait_pause_sink():
        while s_axis_tvalid:
            for k in range(M_COUNT):
                sink_pause_list[k].next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            for k in range(M_COUNT):
                sink_pause_list[k].next = False
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

        # testbench stimulus

        yield clk.posedge
        print("test 1: 0123 -> 0000")
        current_test.next = 1

        test_frame0 = axis_ep.AXIStreamFrame(b'\x01\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x01\x01\x00\xFF'+bytearray(range(256)), id=1, dest=0)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x01\x02\x00\xFF'+bytearray(range(256)), id=2, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x01\x03\x00\xFF'+bytearray(range(256)), id=3, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            source_list[1].send(test_frame1)
            source_list[2].send(test_frame2)
            source_list[3].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            yield sink_list[0].wait()
            rx_frame0 = sink_list[0].recv()

            assert rx_frame0 == test_frame0

            yield sink_list[0].wait()
            rx_frame1 = sink_list[0].recv()

            assert rx_frame1 == test_frame1

            yield sink_list[0].wait()
            rx_frame2 = sink_list[0].recv()

            assert rx_frame2 == test_frame2

            yield sink_list[0].wait()
            rx_frame3 = sink_list[0].recv()

            assert rx_frame3 == test_frame3

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0xf

            yield delay(100)

        yield clk.posedge
        print("test 2: 0000 -> 0000")
        current_test.next = 2

        test_frame0 = axis_ep.AXIStreamFrame(b'\x02\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x02\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x02\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x02\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            source_list[0].send(test_frame1)
            source_list[0].send(test_frame2)
            source_list[0].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            yield sink_list[0].wait()
            rx_frame0 = sink_list[0].recv()

            assert rx_frame0 == test_frame0

            yield sink_list[0].wait()
            rx_frame1 = sink_list[0].recv()

            assert rx_frame1 == test_frame1

            yield sink_list[0].wait()
            rx_frame2 = sink_list[0].recv()

            assert rx_frame2 == test_frame2

            yield sink_list[0].wait()
            rx_frame3 = sink_list[0].recv()

            assert rx_frame3 == test_frame3

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0x1

            yield delay(100)

        yield clk.posedge
        print("test 3: bad decoding")
        current_test.next = 3

        test_frame0 = axis_ep.AXIStreamFrame(b'\x03\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x03\x01\x01\xFF'+bytearray(range(256)), id=1, dest=1)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x03\x02\x00\xFF'+bytearray(range(256)), id=2, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x03\x03\x01\xFF'+bytearray(range(256)), id=3, dest=1)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            yield clk.posedge
            source_list[1].send(test_frame1)
            source_list[2].send(test_frame2)
            source_list[3].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            yield sink_list[0].wait()
            rx_frame0 = sink_list[0].recv()

            assert rx_frame0 == test_frame0

            yield sink_list[0].wait()
            rx_frame2 = sink_list[0].recv()

            assert rx_frame2 == test_frame2

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0x5

            yield delay(100)

        yield clk.posedge
        print("test 4: tuser assert")
        current_test.next = 4

        test_frame0 = axis_ep.AXIStreamFrame(b'\x04\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x04\x00\x01\xFF'+bytearray(range(256)), id=0, dest=0, last_cycle_user=1)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x04\x00\x02\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x04\x00\x03\xFF'+bytearray(range(256)), id=0, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            source_list[0].send(test_frame1)
            source_list[0].send(test_frame2)
            source_list[0].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            yield sink_list[0].wait()
            rx_frame0 = sink_list[0].recv()

            assert rx_frame0 == test_frame0

            yield sink_list[0].wait()
            rx_frame2 = sink_list[0].recv()

            assert rx_frame2 == test_frame2

            yield sink_list[0].wait()
            rx_frame3 = sink_list[0].recv()

            assert rx_frame3 == test_frame3

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x1
            assert status_good_frame_latch == 0x1

            yield delay(100)

        yield clk.posedge
        print("test 5: single packet overflow")
        current_test.next = 5

        test_frame0 = axis_ep.AXIStreamFrame(b'\x05\x00\x00\xFF'+bytearray(range(256))*3, id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x05\x01\x01\xFF'+bytearray(range(256))*3, id=1, dest=0)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x05\x02\x02\xFF'+bytearray(range(256))*3, id=2, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x05\x03\x03\xFF'+bytearray(range(256))*3, id=3, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            source_list[1].send(test_frame1)
            source_list[2].send(test_frame2)
            source_list[3].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            yield delay(100)

            assert sink_list[0].empty()

            assert status_overflow_latch == 0xf
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0x0

            yield delay(100)

        yield clk.posedge
        print("test 6: initial sink pause")
        current_test.next = 6

        test_frame0 = axis_ep.AXIStreamFrame(b'\x06\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)

        status_overflow_latch.next = 0
        status_bad_frame_latch.next = 0
        status_good_frame_latch.next = 0

        source_list[0].send(test_frame0)

        for k in range(M_COUNT):
            sink_pause_list[k].next = True

        yield clk.posedge
        yield clk.posedge
        while (s_axis_tvalid):
            yield clk.posedge
        for k in range(20):
            yield clk.posedge

        for k in range(M_COUNT):
            sink_pause_list[k].next = False

        yield wait_normal()

        yield sink_list[0].wait()
        rx_frame0 = sink_list[0].recv()

        assert rx_frame0 == test_frame0

        assert sink_list[0].empty()

        assert status_overflow_latch == 0x0
        assert status_bad_frame_latch == 0x0
        assert status_good_frame_latch == 0x1

        yield delay(100)

        yield clk.posedge
        print("test 7: initial sink pause, reset")
        current_test.next = 7

        test_frame0 = axis_ep.AXIStreamFrame(b'\x07\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)

        status_overflow_latch.next = 0
        status_bad_frame_latch.next = 0
        status_good_frame_latch.next = 0

        source_list[0].send(test_frame0)
        
        for k in range(M_COUNT):
            sink_pause_list[k].next = True
        
        yield clk.posedge
        yield clk.posedge
        while (s_axis_tvalid):
            yield clk.posedge
        for k in range(20):
            yield clk.posedge

        rst.next = 1
        yield clk.posedge
        rst.next = 0

        for k in range(M_COUNT):
            sink_pause_list[k].next = False

        yield delay(500)

        assert sink_list[0].empty()

        assert status_overflow_latch == 0x0
        assert status_bad_frame_latch == 0x0
        assert status_good_frame_latch == 0x1

        yield delay(100)

        yield clk.posedge
        print("test 8: backpressure test")
        current_test.next = 8

        test_frame0 = axis_ep.AXIStreamFrame(b'\x08\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x08\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x08\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x08\x00\x00\xFF'+bytearray(range(256)), id=0, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            source_list[0].send(test_frame0)
            source_list[0].send(test_frame1)
            source_list[0].send(test_frame2)
            source_list[0].send(test_frame3)

            for k in range(M_COUNT):
                sink_pause_list[k].next = True

            for k in range(100):
                yield clk.posedge

            for k in range(M_COUNT):
                sink_pause_list[k].next = False

            yield wait()

            yield sink_list[0].wait()
            rx_frame0 = sink_list[0].recv()

            assert rx_frame0 == test_frame0

            yield sink_list[0].wait()
            rx_frame1 = sink_list[0].recv()

            assert rx_frame1 == test_frame1

            yield sink_list[0].wait()
            rx_frame2 = sink_list[0].recv()

            assert rx_frame2 == test_frame2

            yield sink_list[0].wait()
            rx_frame3 = sink_list[0].recv()

            assert rx_frame3 == test_frame3

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0x1

            yield delay(100)

        yield clk.posedge
        print("test 9: many small packets, one to one")
        current_test.next = 9

        test_frame0 = axis_ep.AXIStreamFrame(b'\x09\x00\x00\xFF'+bytearray(range(4)), id=0, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            for k in range(64):
                source_list[0].send(test_frame0)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            for k in range(64):
                yield sink_list[0].wait()
                rx_frame0 = sink_list[0].recv()

                assert rx_frame0 == test_frame0

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0x1

            yield delay(100)

        yield clk.posedge
        print("test 10: many small packets, many to one")
        current_test.next = 10

        test_frame0 = axis_ep.AXIStreamFrame(b'\x0A\x00\x00\xFF'+bytearray(range(4)), id=0, dest=0)
        test_frame1 = axis_ep.AXIStreamFrame(b'\x0A\x01\x00\xFF'+bytearray(range(4)), id=1, dest=0)
        test_frame2 = axis_ep.AXIStreamFrame(b'\x0A\x02\x00\xFF'+bytearray(range(4)), id=2, dest=0)
        test_frame3 = axis_ep.AXIStreamFrame(b'\x0A\x03\x00\xFF'+bytearray(range(4)), id=3, dest=0)

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            status_overflow_latch.next = 0
            status_bad_frame_latch.next = 0
            status_good_frame_latch.next = 0

            for k in range(64):
                source_list[0].send(test_frame0)
                yield clk.posedge
                yield clk.posedge
                source_list[1].send(test_frame1)
                source_list[2].send(test_frame2)
                source_list[3].send(test_frame3)
            yield clk.posedge
            yield clk.posedge

            yield wait()

            for k in range(64):
                yield sink_list[0].wait()
                rx_frame0 = sink_list[0].recv()

                assert rx_frame0 == test_frame0

                yield sink_list[0].wait()
                rx_frame1 = sink_list[0].recv()

                assert rx_frame1 == test_frame1

                yield sink_list[0].wait()
                rx_frame2 = sink_list[0].recv()

                assert rx_frame2 == test_frame2

                yield sink_list[0].wait()
                rx_frame3 = sink_list[0].recv()

                assert rx_frame3 == test_frame3

            assert sink_list[0].empty()

            assert status_overflow_latch == 0x0
            assert status_bad_frame_latch == 0x0
            assert status_good_frame_latch == 0xf

            yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
