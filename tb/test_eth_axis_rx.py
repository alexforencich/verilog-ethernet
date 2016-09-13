#!/usr/bin/env python
"""

Copyright (c) 2014-2016 Alex Forencich

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

module = 'eth_axis_rx'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[8:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))
    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))
    busy = Signal(bool(0))
    error_header_early_termination = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk,
        rst,
        tdata=input_axis_tdata,
        tvalid=input_axis_tvalid,
        tready=input_axis_tready,
        tlast=input_axis_tlast,
        tuser=input_axis_tuser,
        pause=source_pause,
        name='source'
    )

    sink = eth_ep.EthFrameSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        eth_hdr_ready=output_eth_hdr_ready,
        eth_hdr_valid=output_eth_hdr_valid,
        eth_dest_mac=output_eth_dest_mac,
        eth_src_mac=output_eth_src_mac,
        eth_type=output_eth_type,
        eth_payload_tdata=output_eth_payload_tdata,
        eth_payload_tvalid=output_eth_payload_tvalid,
        eth_payload_tready=output_eth_payload_tready,
        eth_payload_tlast=output_eth_payload_tlast,
        eth_payload_tuser=output_eth_payload_tuser,
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

        input_axis_tdata=input_axis_tdata,
        input_axis_tvalid=input_axis_tvalid,
        input_axis_tready=input_axis_tready,
        input_axis_tlast=input_axis_tlast,
        input_axis_tuser=input_axis_tuser,

        output_eth_hdr_valid=output_eth_hdr_valid,
        output_eth_hdr_ready=output_eth_hdr_ready,
        output_eth_dest_mac=output_eth_dest_mac,
        output_eth_src_mac=output_eth_src_mac,
        output_eth_type=output_eth_type,
        output_eth_payload_tdata=output_eth_payload_tdata,
        output_eth_payload_tvalid=output_eth_payload_tvalid,
        output_eth_payload_tready=output_eth_payload_tready,
        output_eth_payload_tlast=output_eth_payload_tlast,
        output_eth_payload_tuser=output_eth_payload_tuser,

        busy=busy,
        error_header_early_termination=error_header_early_termination
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    error_header_early_termination_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (error_header_early_termination):
            error_header_early_termination_asserted.next = 1

    def wait_normal():
        while input_axis_tvalid or output_eth_payload_tvalid:
            yield clk.posedge

    def wait_pause_source():
        while input_axis_tvalid or output_eth_payload_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

    def wait_pause_sink():
        while input_axis_tvalid or output_eth_payload_tvalid:
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

        for payload_len in range(1,18):
            yield clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = eth_ep.EthFrame()
            test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame.eth_src_mac = 0x5A5152535455
            test_frame.eth_type = 0x8000
            test_frame.payload = bytearray(range(payload_len))

            axis_frame = test_frame.build_axis()

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(axis_frame)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame

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

            axis_frame1 = test_frame1.build_axis()
            axis_frame2 = test_frame2.build_axis()

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(axis_frame1)
                source.send(axis_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame1

                rx_frame = sink.recv()

                assert rx_frame == test_frame2

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

            axis_frame1 = test_frame1.build_axis()
            axis_frame2 = test_frame2.build_axis()

            axis_frame1.user = 1

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(axis_frame1)
                source.send(axis_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame1
                assert rx_frame.payload.user[-1]

                rx_frame = sink.recv()

                assert rx_frame == test_frame2

                assert sink.empty()

                yield delay(100)

        for length in range(1,15):
            yield clk.posedge
            print("test 4: truncated packet, length %d" % length)
            current_test.next = 4

            test_frame1 = eth_ep.EthFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x8000
            test_frame1.payload = bytearray(range(16))
            test_frame2 = eth_ep.EthFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x8000
            test_frame2.payload = bytearray(range(16))

            axis_frame1 = test_frame1.build_axis()
            axis_frame2 = test_frame2.build_axis()

            axis_frame1.data = axis_frame1.data[:length]

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                error_header_early_termination_asserted.next = 0

                source.send(axis_frame1)
                source.send(axis_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                assert error_header_early_termination_asserted

                rx_frame = sink.recv()

                assert rx_frame == test_frame2

                assert sink.empty()

                yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_logic, clkgen, monitor, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

