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

import eth_ep

module = 'eth_demux'
testbench = 'test_%s_64_4' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    M_COUNT = 4
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

    s_eth_hdr_valid = Signal(bool(0))
    s_eth_dest_mac = Signal(intbv(0)[48:])
    s_eth_src_mac = Signal(intbv(0)[48:])
    s_eth_type = Signal(intbv(0)[16:])
    s_eth_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    s_eth_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    s_eth_payload_axis_tvalid = Signal(bool(0))
    s_eth_payload_axis_tlast = Signal(bool(0))
    s_eth_payload_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    s_eth_payload_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    s_eth_payload_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    m_eth_hdr_ready_list = [Signal(bool(0)) for i in range(M_COUNT)]
    m_eth_payload_axis_tready_list = [Signal(bool(0)) for i in range(M_COUNT)]

    m_eth_hdr_ready = ConcatSignal(*reversed(m_eth_hdr_ready_list))
    m_eth_payload_axis_tready = ConcatSignal(*reversed(m_eth_payload_axis_tready_list))

    enable = Signal(bool(0))
    drop = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    s_eth_hdr_ready = Signal(bool(0))
    s_eth_payload_axis_tready = Signal(bool(0))

    m_eth_hdr_valid = Signal(intbv(0)[M_COUNT:])
    m_eth_dest_mac = Signal(intbv(0)[M_COUNT*48:])
    m_eth_src_mac = Signal(intbv(0)[M_COUNT*48:])
    m_eth_type = Signal(intbv(0)[M_COUNT*16:])
    m_eth_payload_axis_tdata = Signal(intbv(0)[M_COUNT*DATA_WIDTH:])
    m_eth_payload_axis_tkeep = Signal(intbv(0xf)[M_COUNT*KEEP_WIDTH:])
    m_eth_payload_axis_tvalid = Signal(intbv(0)[M_COUNT:])
    m_eth_payload_axis_tlast = Signal(intbv(0)[M_COUNT:])
    m_eth_payload_axis_tid = Signal(intbv(0)[M_COUNT*ID_WIDTH:])
    m_eth_payload_axis_tdest = Signal(intbv(0)[M_COUNT*DEST_WIDTH:])
    m_eth_payload_axis_tuser = Signal(intbv(0)[M_COUNT*USER_WIDTH:])

    m_eth_hdr_valid_list = [m_eth_hdr_valid(i) for i in range(M_COUNT)]
    m_eth_dest_mac_list = [m_eth_dest_mac((i+1)*48, i*48) for i in range(M_COUNT)]
    m_eth_src_mac_list = [m_eth_src_mac((i+1)*48, i*48) for i in range(M_COUNT)]
    m_eth_type_list = [m_eth_type((i+1)*16, i*16) for i in range(M_COUNT)]
    m_eth_payload_axis_tdata_list = [m_eth_payload_axis_tdata((i+1)*DATA_WIDTH, i*DATA_WIDTH) for i in range(M_COUNT)]
    m_eth_payload_axis_tkeep_list = [m_eth_payload_axis_tkeep((i+1)*KEEP_WIDTH, i*KEEP_WIDTH) for i in range(M_COUNT)]
    m_eth_payload_axis_tvalid_list = [m_eth_payload_axis_tvalid(i) for i in range(M_COUNT)]
    m_eth_payload_axis_tlast_list = [m_eth_payload_axis_tlast(i) for i in range(M_COUNT)]
    m_eth_payload_axis_tid_list = [m_eth_payload_axis_tid((i+1)*ID_WIDTH, i*ID_WIDTH) for i in range(M_COUNT)]
    m_eth_payload_axis_tdest_list = [m_eth_payload_axis_tdest((i+1)*DEST_WIDTH, i*DEST_WIDTH) for i in range(M_COUNT)]
    m_eth_payload_axis_tuser_list = [m_eth_payload_axis_tuser((i+1)*USER_WIDTH, i*USER_WIDTH) for i in range(M_COUNT)]

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause_list = []
    sink_list = []
    sink_logic_list = []

    source = eth_ep.EthFrameSource()

    source_logic = source.create_logic(
        clk,
        rst,
        eth_hdr_ready=s_eth_hdr_ready,
        eth_hdr_valid=s_eth_hdr_valid,
        eth_dest_mac=s_eth_dest_mac,
        eth_src_mac=s_eth_src_mac,
        eth_type=s_eth_type,
        eth_payload_tdata=s_eth_payload_axis_tdata,
        eth_payload_tkeep=s_eth_payload_axis_tkeep,
        eth_payload_tvalid=s_eth_payload_axis_tvalid,
        eth_payload_tready=s_eth_payload_axis_tready,
        eth_payload_tlast=s_eth_payload_axis_tlast,
        eth_payload_tuser=s_eth_payload_axis_tuser,
        pause=source_pause,
        name='source'
    )

    for k in range(M_COUNT):
        s = eth_ep.EthFrameSink()
        p = Signal(bool(0))

        sink_list.append(s)
        sink_pause_list.append(p)

        sink_logic_list.append(s.create_logic(
            clk,
            rst,
            eth_hdr_ready=m_eth_hdr_ready_list[k],
            eth_hdr_valid=m_eth_hdr_valid_list[k],
            eth_dest_mac=m_eth_dest_mac_list[k],
            eth_src_mac=m_eth_src_mac_list[k],
            eth_type=m_eth_type_list[k],
            eth_payload_tdata=m_eth_payload_axis_tdata_list[k],
            eth_payload_tkeep=m_eth_payload_axis_tkeep_list[k],
            eth_payload_tvalid=m_eth_payload_axis_tvalid_list[k],
            eth_payload_tready=m_eth_payload_axis_tready_list[k],
            eth_payload_tlast=m_eth_payload_axis_tlast_list[k],
            eth_payload_tuser=m_eth_payload_axis_tuser_list[k],
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

        s_eth_hdr_valid=s_eth_hdr_valid,
        s_eth_hdr_ready=s_eth_hdr_ready,
        s_eth_dest_mac=s_eth_dest_mac,
        s_eth_src_mac=s_eth_src_mac,
        s_eth_type=s_eth_type,
        s_eth_payload_axis_tdata=s_eth_payload_axis_tdata,
        s_eth_payload_axis_tkeep=s_eth_payload_axis_tkeep,
        s_eth_payload_axis_tvalid=s_eth_payload_axis_tvalid,
        s_eth_payload_axis_tready=s_eth_payload_axis_tready,
        s_eth_payload_axis_tlast=s_eth_payload_axis_tlast,
        s_eth_payload_axis_tid=s_eth_payload_axis_tid,
        s_eth_payload_axis_tdest=s_eth_payload_axis_tdest,
        s_eth_payload_axis_tuser=s_eth_payload_axis_tuser,

        m_eth_hdr_valid=m_eth_hdr_valid,
        m_eth_hdr_ready=m_eth_hdr_ready,
        m_eth_dest_mac=m_eth_dest_mac,
        m_eth_src_mac=m_eth_src_mac,
        m_eth_type=m_eth_type,
        m_eth_payload_axis_tdata=m_eth_payload_axis_tdata,
        m_eth_payload_axis_tkeep=m_eth_payload_axis_tkeep,
        m_eth_payload_axis_tvalid=m_eth_payload_axis_tvalid,
        m_eth_payload_axis_tready=m_eth_payload_axis_tready,
        m_eth_payload_axis_tlast=m_eth_payload_axis_tlast,
        m_eth_payload_axis_tid=m_eth_payload_axis_tid,
        m_eth_payload_axis_tdest=m_eth_payload_axis_tdest,
        m_eth_payload_axis_tuser=m_eth_payload_axis_tuser,

        enable=enable,
        drop=drop,
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

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source.send(test_frame)

        yield sink_list[0].wait()
        rx_frame = sink_list[0].recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: select port 1")
        current_test.next = 2

        select.next = 1

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source.send(test_frame)

        yield sink_list[1].wait()
        rx_frame = sink_list[1].recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        select.next = 0

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source.send(test_frame1)
        source.send(test_frame2)

        yield sink_list[0].wait()
        rx_frame = sink_list[0].recv()

        assert rx_frame == test_frame1

        yield sink_list[0].wait()
        rx_frame = sink_list[0].recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets, different ports")
        current_test.next = 4

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_eth_payload_axis_tvalid or s_eth_hdr_valid:
            yield clk.posedge
            select.next = 2

        yield sink_list[1].wait()
        rx_frame = sink_list[1].recv()

        assert rx_frame == test_frame1

        yield sink_list[2].wait()
        rx_frame = sink_list[2].recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alterate pause source")
        current_test.next = 5

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_eth_payload_axis_tvalid or s_eth_hdr_valid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            select.next = 2

        yield sink_list[1].wait()
        rx_frame = sink_list[1].recv()

        assert rx_frame == test_frame1

        yield sink_list[2].wait()
        rx_frame = sink_list[2].recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alterate pause sink")
        current_test.next = 6

        select.next = 1

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while s_eth_payload_axis_tvalid or s_eth_hdr_valid:
            for k in range(M_COUNT):
                sink_pause_list[k].next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            for k in range(M_COUNT):
                sink_pause_list[k].next = False
            yield clk.posedge
            select.next = 2

        yield sink_list[1].wait()
        rx_frame = sink_list[1].recv()

        assert rx_frame == test_frame1

        yield sink_list[2].wait()
        rx_frame = sink_list[2].recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 7: enable")
        current_test.next = 7

        enable.next = False
        select.next = 0

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source.send(test_frame)

        yield delay(500)

        assert sink_list[0].empty()

        enable.next = True

        yield sink_list[0].wait()
        rx_frame = sink_list[0].recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 8: drop")
        current_test.next = 8

        drop.next = True
        select.next = 0

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source.send(test_frame)

        yield delay(500)

        assert sink_list[0].empty()

        drop.next = False

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

