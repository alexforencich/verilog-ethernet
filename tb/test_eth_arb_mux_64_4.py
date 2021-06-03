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

module = 'eth_arb_mux'
testbench = 'test_%s_64_4' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/axis/rtl/arbiter.v")
srcs.append("../lib/axis/rtl/priority_encoder.v")
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
    ARB_TYPE_ROUND_ROBIN = 0
    ARB_LSB_HIGH_PRIORITY = 1

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_eth_hdr_valid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_eth_dest_mac_list = [Signal(intbv(0)[48:]) for i in range(S_COUNT)]
    s_eth_src_mac_list = [Signal(intbv(0)[48:]) for i in range(S_COUNT)]
    s_eth_type_list = [Signal(intbv(0)[16:]) for i in range(S_COUNT)]
    s_eth_payload_axis_tdata_list = [Signal(intbv(0)[DATA_WIDTH:]) for i in range(S_COUNT)]
    s_eth_payload_axis_tkeep_list = [Signal(intbv(1)[KEEP_WIDTH:]) for i in range(S_COUNT)]
    s_eth_payload_axis_tvalid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_eth_payload_axis_tlast_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_eth_payload_axis_tid_list = [Signal(intbv(0)[ID_WIDTH:]) for i in range(S_COUNT)]
    s_eth_payload_axis_tdest_list = [Signal(intbv(0)[DEST_WIDTH:]) for i in range(S_COUNT)]
    s_eth_payload_axis_tuser_list = [Signal(intbv(0)[USER_WIDTH:]) for i in range(S_COUNT)]

    s_eth_hdr_valid = ConcatSignal(*reversed(s_eth_hdr_valid_list))
    s_eth_dest_mac = ConcatSignal(*reversed(s_eth_dest_mac_list))
    s_eth_src_mac = ConcatSignal(*reversed(s_eth_src_mac_list))
    s_eth_type = ConcatSignal(*reversed(s_eth_type_list))
    s_eth_payload_axis_tdata = ConcatSignal(*reversed(s_eth_payload_axis_tdata_list))
    s_eth_payload_axis_tkeep = ConcatSignal(*reversed(s_eth_payload_axis_tkeep_list))
    s_eth_payload_axis_tvalid = ConcatSignal(*reversed(s_eth_payload_axis_tvalid_list))
    s_eth_payload_axis_tlast = ConcatSignal(*reversed(s_eth_payload_axis_tlast_list))
    s_eth_payload_axis_tid = ConcatSignal(*reversed(s_eth_payload_axis_tid_list))
    s_eth_payload_axis_tdest = ConcatSignal(*reversed(s_eth_payload_axis_tdest_list))
    s_eth_payload_axis_tuser = ConcatSignal(*reversed(s_eth_payload_axis_tuser_list))

    m_eth_hdr_ready = Signal(bool(0))
    m_eth_payload_axis_tready = Signal(bool(0))

    # Outputs
    s_eth_hdr_ready = Signal(intbv(0)[S_COUNT:])
    s_eth_payload_axis_tready = Signal(intbv(0)[S_COUNT:])

    s_eth_hdr_ready_list = [s_eth_hdr_ready(i) for i in range(S_COUNT)]
    s_eth_payload_axis_tready_list = [s_eth_payload_axis_tready(i) for i in range(S_COUNT)]

    m_eth_hdr_valid = Signal(bool(0))
    m_eth_dest_mac = Signal(intbv(0)[48:])
    m_eth_src_mac = Signal(intbv(0)[48:])
    m_eth_type = Signal(intbv(0)[16:])
    m_eth_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_eth_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_eth_payload_axis_tvalid = Signal(bool(0))
    m_eth_payload_axis_tlast = Signal(bool(0))
    m_eth_payload_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    m_eth_payload_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    m_eth_payload_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    # sources and sinks
    source_pause_list = []
    source_list = []
    source_logic_list = []
    sink_pause = Signal(bool(0))

    for k in range(S_COUNT):
        s = eth_ep.EthFrameSource()
        p = Signal(bool(0))

        source_list.append(s)
        source_pause_list.append(p)

        source_logic_list.append(s.create_logic(
            clk,
            rst,
            eth_hdr_ready=s_eth_hdr_ready_list[k],
            eth_hdr_valid=s_eth_hdr_valid_list[k],
            eth_dest_mac=s_eth_dest_mac_list[k],
            eth_src_mac=s_eth_src_mac_list[k],
            eth_type=s_eth_type_list[k],
            eth_payload_tdata=s_eth_payload_axis_tdata_list[k],
            eth_payload_tkeep=s_eth_payload_axis_tkeep_list[k],
            eth_payload_tvalid=s_eth_payload_axis_tvalid_list[k],
            eth_payload_tready=s_eth_payload_axis_tready_list[k],
            eth_payload_tlast=s_eth_payload_axis_tlast_list[k],
            eth_payload_tuser=s_eth_payload_axis_tuser_list[k],
            pause=p,
            name='source_%d' % k
        ))

    sink = eth_ep.EthFrameSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        eth_hdr_ready=m_eth_hdr_ready,
        eth_hdr_valid=m_eth_hdr_valid,
        eth_dest_mac=m_eth_dest_mac,
        eth_src_mac=m_eth_src_mac,
        eth_type=m_eth_type,
        eth_payload_tdata=m_eth_payload_axis_tdata,
        eth_payload_tkeep=m_eth_payload_axis_tkeep,
        eth_payload_tvalid=m_eth_payload_axis_tvalid,
        eth_payload_tready=m_eth_payload_axis_tready,
        eth_payload_tlast=m_eth_payload_axis_tlast,
        eth_payload_tuser=m_eth_payload_axis_tuser,
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
        m_eth_payload_axis_tuser=m_eth_payload_axis_tuser
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
        print("test 1: port 0")
        current_test.next = 1

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A0052535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source_list[0].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: port 1")
        current_test.next = 2

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A0152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))

        source_list[1].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A0052535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A0052535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

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

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A0152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A0252535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alterate pause source")
        current_test.next = 5

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A0152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A0252535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while s_eth_payload_axis_tvalid:
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

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alterate pause sink")
        current_test.next = 6

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A0152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A0252535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while s_eth_payload_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 7: back-to-back packets, different ports, arbitration test")
        current_test.next = 7

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A0152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(32))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A0252535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(32))

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        source_list[2].send(test_frame2)
        source_list[2].send(test_frame2)
        source_list[2].send(test_frame2)
        source_list[2].send(test_frame2)
        yield clk.posedge

        yield delay(120)
        yield clk.posedge
        source_list[1].send(test_frame1)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

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

