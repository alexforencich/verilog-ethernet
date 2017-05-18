#!/usr/bin/env python
"""

Copyright (c) 2014-2017 Alex Forencich

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

module = 'axis_async_fifo_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    ADDR_WIDTH = 2
    DATA_WIDTH = 64
    KEEP_WIDTH = (DATA_WIDTH/8)

    # Inputs
    async_rst = Signal(bool(0))
    input_clk = Signal(bool(0))
    output_clk = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    input_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
    input_axis_tvalid = Signal(bool(0))
    input_axis_tlast = Signal(bool(0))
    input_axis_tuser = Signal(bool(0))
    output_axis_tready = Signal(bool(0))

    # Outputs
    input_axis_tready = Signal(bool(0))
    output_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    output_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        input_clk,
        async_rst,
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
        output_clk,
        async_rst,
        tdata=output_axis_tdata,
        tkeep=output_axis_tkeep,
        tvalid=output_axis_tvalid,
        tready=output_axis_tready,
        tlast=output_axis_tlast,
        tuser=output_axis_tuser,
        pause=sink_pause,
        name='sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        async_rst=async_rst,
        input_clk=input_clk,
        output_clk=output_clk,
        current_test=current_test,

        input_axis_tdata=input_axis_tdata,
        input_axis_tkeep=input_axis_tkeep,
        input_axis_tvalid=input_axis_tvalid,
        input_axis_tready=input_axis_tready,
        input_axis_tlast=input_axis_tlast,
        input_axis_tuser=input_axis_tuser,

        output_axis_tdata=output_axis_tdata,
        output_axis_tkeep=output_axis_tkeep,
        output_axis_tvalid=output_axis_tvalid,
        output_axis_tready=output_axis_tready,
        output_axis_tlast=output_axis_tlast,
        output_axis_tuser=output_axis_tuser
    )

    @always(delay(4))
    def input_clkgen():
        input_clk.next = not input_clk

    @always(delay(5))
    def output_clkgen():
        output_clk.next = not output_clk

    @instance
    def check():
        yield delay(100)
        yield input_clk.posedge
        async_rst.next = 1
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge
        async_rst.next = 0
        yield input_clk.posedge
        yield delay(100)
        yield input_clk.posedge

        yield input_clk.posedge

        yield input_clk.posedge
        print("test 1: test packet")
        current_test.next = 1

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield input_clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source.send(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield input_clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source.send(test_frame)
        yield input_clk.posedge

        yield delay(64)
        yield input_clk.posedge
        source_pause.next = True
        yield delay(32)
        yield input_clk.posedge
        source_pause.next = False

        yield delay(64)
        yield output_clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield output_clk.posedge
        sink_pause.next = False

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield input_clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 5: alternate pause source")
        current_test.next = 5

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield input_clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            source_pause.next = True
            yield input_clk.posedge
            yield input_clk.posedge
            yield input_clk.posedge
            source_pause.next = False
            yield input_clk.posedge

        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source.send(test_frame1)
        source.send(test_frame2)
        yield input_clk.posedge

        while input_axis_tvalid or output_axis_tvalid:
            sink_pause.next = True
            yield output_clk.posedge
            yield output_clk.posedge
            yield output_clk.posedge
            sink_pause.next = False
            yield output_clk.posedge

        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield input_clk.posedge
        print("test 7: tuser assert")
        current_test.next = 7

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame.user = 1
        source.send(test_frame)
        yield input_clk.posedge

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame
        assert rx_frame.user[-1]

        yield delay(100)

        yield input_clk.posedge
        print("test 8: initial sink pause")
        current_test.next = 8

        test_frame = axis_ep.AXIStreamFrame(bytearray(range(24)))

        sink_pause.next = 1
        source.send(test_frame)
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge
        sink_pause.next = 0

        yield output_axis_tlast.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        rx_frame = sink.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield input_clk.posedge
        print("test 9: initial sink pause, assert reset")
        current_test.next = 9

        test_frame = axis_ep.AXIStreamFrame(bytearray(range(24)))

        sink_pause.next = 1
        source.send(test_frame)
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge
        yield input_clk.posedge

        async_rst.next = 1
        yield input_clk.posedge
        async_rst.next = 0

        sink_pause.next = 0

        yield delay(100)

        yield output_clk.posedge
        yield output_clk.posedge
        yield output_clk.posedge

        assert sink.empty()

        yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_logic, input_clkgen, output_clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

