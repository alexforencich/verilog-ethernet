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
import math

module = 'axis_broadcast'
testbench = 'test_%s_4' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    M_COUNT = 4
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

    s_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    s_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    s_axis_tvalid = Signal(bool(0))
    s_axis_tlast = Signal(bool(0))
    s_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    s_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    s_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    m_axis_tready_list = [Signal(bool(0)) for i in range(M_COUNT)]

    m_axis_tready = ConcatSignal(*reversed(m_axis_tready_list))

    # Outputs
    s_axis_tready = Signal(bool(0))

    m_axis_tdata = Signal(intbv(0)[M_COUNT*DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(0xf)[M_COUNT*KEEP_WIDTH:])
    m_axis_tvalid = Signal(intbv(0)[M_COUNT:])
    m_axis_tlast = Signal(intbv(0)[M_COUNT:])
    m_axis_tid = Signal(intbv(0)[M_COUNT*ID_WIDTH:])
    m_axis_tdest = Signal(intbv(0)[M_COUNT*DEST_WIDTH:])
    m_axis_tuser = Signal(intbv(0)[M_COUNT*USER_WIDTH:])

    m_axis_tdata_list = [m_axis_tdata((i+1)*DATA_WIDTH, i*DATA_WIDTH) for i in range(M_COUNT)]
    m_axis_tkeep_list = [m_axis_tkeep((i+1)*KEEP_WIDTH, i*KEEP_WIDTH) for i in range(M_COUNT)]
    m_axis_tvalid_list = [m_axis_tvalid(i) for i in range(M_COUNT)]
    m_axis_tlast_list = [m_axis_tlast(i) for i in range(M_COUNT)]
    m_axis_tid_list = [m_axis_tid((i+1)*ID_WIDTH, i*ID_WIDTH) for i in range(M_COUNT)]
    m_axis_tdest_list = [m_axis_tdest((i+1)*DEST_WIDTH, i*DEST_WIDTH) for i in range(M_COUNT)]
    m_axis_tuser_list = [m_axis_tuser((i+1)*USER_WIDTH, i*USER_WIDTH) for i in range(M_COUNT)]

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause_list = []
    sink_list = []
    sink_logic_list = []

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
        m_axis_tuser=m_axis_tuser
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
        print("test 1: test packet")
        current_test.next = 1

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=1
        )

        source.send(test_frame)

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            bytearray(range(256)),
            id=1
        )

        source.send(test_frame)

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=3,
            dest=1
        )

        source.send(test_frame)
        yield clk.posedge

        yield delay(64)
        yield clk.posedge
        source_pause.next = True
        yield delay(32)
        yield clk.posedge
        source_pause.next = False

        yield delay(64)
        yield clk.posedge
        for k in range(M_COUNT):
            sink_pause_list[k].next = True
        yield delay(32)
        yield clk.posedge
        for k in range(M_COUNT):
            sink_pause_list[k].next = False

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=4,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=4,
            dest=2
        )

        source.send(test_frame1)
        source.send(test_frame2)

        for sink in sink_list:
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

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=5,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=5,
            dest=2
        )

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid or m_axis_tvalid:
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            source_pause.next = True
            yield clk.posedge

        source_pause.next = False

        for sink in sink_list:
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

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=6,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=6,
            dest=2
        )

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid or m_axis_tvalid:
            for k in range(M_COUNT):
                sink_pause_list[k].next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            for k in range(M_COUNT):
                sink_pause_list[k].next = False
            yield clk.posedge

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame1

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 7: alternate pause individual sinks")
        current_test.next = 7

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=7,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=7,
            dest=2
        )

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_axis_tvalid or m_axis_tvalid:
            for pause in sink_pause_list:
                pause.next = True
                yield clk.posedge
                yield clk.posedge
                yield clk.posedge
                pause.next = False
                yield clk.posedge

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame1

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 8: alternate un-pause individual sinks")
        current_test.next = 8

        test_frame1 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=8,
            dest=1
        )
        test_frame2 = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=8,
            dest=2
        )

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        for pause in sink_pause_list:
            pause.next = True

        while s_axis_tvalid or m_axis_tvalid:
            for pause in sink_pause_list:
                yield clk.posedge
                yield clk.posedge
                yield clk.posedge
                pause.next = False
                yield clk.posedge
                pause.next = True

        for pause in sink_pause_list:
            pause.next = False

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame1

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 9: tuser assert")
        current_test.next = 9

        test_frame = axis_ep.AXIStreamFrame(
            b'\xDA\xD1\xD2\xD3\xD4\xD5' +
            b'\x5A\x51\x52\x53\x54\x55' +
            b'\x80\x00' +
            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10',
            id=9,
            dest=1,
            last_cycle_user=1
        )

        source.send(test_frame)

        for sink in sink_list:
            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame == test_frame
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

