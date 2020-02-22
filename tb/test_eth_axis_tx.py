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
import eth_ep

module = 'eth_axis_tx'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 8
    KEEP_ENABLE = (DATA_WIDTH>8)
    KEEP_WIDTH = int(DATA_WIDTH/8)

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:0])

    s_eth_hdr_valid = Signal(bool(0))
    s_eth_dest_mac = Signal(intbv(0)[48:])
    s_eth_src_mac = Signal(intbv(0)[48:])
    s_eth_type = Signal(intbv(0)[16:])
    s_eth_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    s_eth_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    s_eth_payload_axis_tvalid = Signal(bool(0))
    s_eth_payload_axis_tlast = Signal(bool(0))
    s_eth_payload_axis_tuser = Signal(bool(0))
    m_axis_tready = Signal(bool(0))

    # Outputs
    m_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tuser = Signal(bool(0))
    s_eth_hdr_ready = Signal(bool(0))
    s_eth_payload_axis_tready = Signal(bool(0))
    busy = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

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

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=m_axis_tdata,
        tkeep=m_axis_tkeep,
        tvalid=m_axis_tvalid,
        tready=m_axis_tready,
        tlast=m_axis_tlast,
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
        s_eth_payload_axis_tuser=s_eth_payload_axis_tuser,

        m_axis_tdata=m_axis_tdata,
        m_axis_tkeep=m_axis_tkeep,
        m_axis_tvalid=m_axis_tvalid,
        m_axis_tready=m_axis_tready,
        m_axis_tlast=m_axis_tlast,
        m_axis_tuser=m_axis_tuser,

        busy=busy
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        while s_eth_payload_axis_tvalid or m_axis_tvalid or s_eth_hdr_valid:
            yield clk.posedge

    def wait_pause_source():
        while s_eth_payload_axis_tvalid or m_axis_tvalid or s_eth_hdr_valid:
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            source_pause.next = True
            yield clk.posedge

        source_pause.next = False

    def wait_pause_sink():
        while s_eth_payload_axis_tvalid or m_axis_tvalid or s_eth_hdr_valid:
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

        for payload_len in range(1,KEEP_WIDTH*2+2):
            yield clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = eth_ep.EthFrame()
            test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame.eth_src_mac = 0x5A5152535455
            test_frame.eth_type = 0x8000
            test_frame.payload = bytearray(range(payload_len))

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = eth_ep.EthFrame()
                check_frame.parse_axis(rx_frame)

                assert check_frame == test_frame

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 2: back-to-back packets, length %d" % payload_len)
            current_test.next = 2

            test_frame1 = eth_ep.EthFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x8000
            test_frame1.payload = bytearray(range(payload_len))
            test_frame2 = eth_ep.EthFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x8000
            test_frame2.payload = bytearray(range(payload_len))

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = eth_ep.EthFrame()
                check_frame.parse_axis(rx_frame)

                assert check_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = eth_ep.EthFrame()
                check_frame.parse_axis(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 3: tuser assert, length %d" % payload_len)
            current_test.next = 3

            test_frame1 = eth_ep.EthFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x8000
            test_frame1.payload = bytearray(range(payload_len))
            test_frame2 = eth_ep.EthFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x8000
            test_frame2.payload = bytearray(range(payload_len))

            test_frame1.payload.user = 1

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = eth_ep.EthFrame()
                check_frame.parse_axis(rx_frame)

                assert check_frame == test_frame1
                assert rx_frame.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = eth_ep.EthFrame()
                check_frame.parse_axis(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

