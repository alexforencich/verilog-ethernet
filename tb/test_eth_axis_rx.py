#!/usr/bin/env python2
"""

Copyright (c) 2014 Alex Forencich

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
from Queue import Queue

import axis_ep
import eth_ep

module = 'eth_axis_rx'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_eth_axis_rx(clk,
                    rst,
                    current_test,

                    input_axis_tdata,
                    input_axis_tvalid,
                    input_axis_tready,
                    input_axis_tlast,
                    input_axis_tuser,

                    output_eth_hdr_valid,
                    output_eth_hdr_ready,
                    output_eth_dest_mac,
                    output_eth_src_mac,
                    output_eth_type,
                    output_eth_payload_tdata,
                    output_eth_payload_tvalid,
                    output_eth_payload_tready,
                    output_eth_payload_tlast,
                    output_eth_payload_tuser,

                    busy,
                    frame_error):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
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
                frame_error=frame_error)

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
    frame_error = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource(clk,
                                     rst,
                                     tdata=input_axis_tdata,
                                     tvalid=input_axis_tvalid,
                                     tready=input_axis_tready,
                                     tlast=input_axis_tlast,
                                     tuser=input_axis_tuser,
                                     fifo=source_queue,
                                     pause=source_pause,
                                     name='source')

    sink = eth_ep.EthFrameSink(clk,
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
                               fifo=sink_queue,
                               pause=sink_pause,
                               name='sink')

    # DUT
    dut = dut_eth_axis_rx(clk,
                          rst,
                          current_test,

                          input_axis_tdata,
                          input_axis_tvalid,
                          input_axis_tready,
                          input_axis_tlast,
                          input_axis_tuser,

                          output_eth_hdr_valid,
                          output_eth_hdr_ready,
                          output_eth_dest_mac,
                          output_eth_src_mac,
                          output_eth_type,
                          output_eth_payload_tdata,
                          output_eth_payload_tvalid,
                          output_eth_payload_tready,
                          output_eth_payload_tlast,
                          output_eth_payload_tuser,

                          busy,
                          frame_error)

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

        output_eth_hdr_ready.next = True
        yield clk.posedge

        yield clk.posedge
        print("test 1: test packet")
        current_test.next = 1

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'
        source_queue.put(test_frame.build_axis())
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(256))
        source_queue.put(test_frame.build_axis())
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(256))
        source_queue.put(test_frame.build_axis())
        yield clk.posedge

        yield delay(64)
        yield clk.posedge
        source_pause.next = True
        yield delay(32)
        yield clk.posedge
        source_pause.next = False

        yield delay(64)
        yield clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield clk.posedge
        sink_pause.next = False

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'
        source_queue.put(test_frame1.build_axis())
        source_queue.put(test_frame2.build_axis())
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alternate pause source")
        current_test.next = 5

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
        source_queue.put(test_frame1.build_axis())
        source_queue.put(test_frame2.build_axis())
        yield clk.posedge

        while input_axis_tvalid or output_eth_payload_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

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
        source_queue.put(test_frame1.build_axis())
        source_queue.put(test_frame2.build_axis())
        yield clk.posedge

        while input_axis_tvalid or output_eth_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 7: alternate pause source 2")
        current_test.next = 7

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(33))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(33))
        source_queue.put(test_frame1.build_axis())
        source_queue.put(test_frame2.build_axis())
        yield clk.posedge

        while input_axis_tvalid or output_eth_payload_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 8: alternate pause sink 2")
        current_test.next = 8

        test_frame1 = eth_ep.EthFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.payload = bytearray(range(33))
        test_frame2 = eth_ep.EthFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.payload = bytearray(range(33))
        source_queue.put(test_frame1.build_axis())
        source_queue.put(test_frame2.build_axis())
        yield clk.posedge

        while input_axis_tvalid or output_eth_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 9: tuser assert")
        current_test.next = 9

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'
        axi_frame = test_frame.build_axis()
        axi_frame.user = 1

        source_queue.put(axi_frame)
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame
        assert rx_frame.payload.user[-1]

        yield delay(100)

        yield clk.posedge
        print("test 10: truncated packet")
        current_test.next = 10

        test_frame = axis_ep.AXIStreamFrame()
        test_frame.data = bytearray(b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09')
        source_queue.put(test_frame)
        yield clk.posedge

        yield input_axis_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        assert frame_error

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

