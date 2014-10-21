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
import struct

import axis_ep

module = 'axis_stat_counter'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_axis_stat_counter(clk,
                 rst,
                 current_test,

                 monitor_axis_tdata,
                 monitor_axis_tkeep,
                 monitor_axis_tvalid,
                 monitor_axis_tready,
                 monitor_axis_tlast,
                 monitor_axis_tuser,
                 
                 output_axis_tdata,
                 output_axis_tvalid,
                 output_axis_tready,
                 output_axis_tlast,
                 output_axis_tuser,

                 tag,
                 trigger):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                monitor_axis_tdata=monitor_axis_tdata,
                monitor_axis_tkeep=monitor_axis_tkeep,
                monitor_axis_tvalid=monitor_axis_tvalid,
                monitor_axis_tready=monitor_axis_tready,
                monitor_axis_tlast=monitor_axis_tlast,
                monitor_axis_tuser=monitor_axis_tuser,

                output_axis_tdata=output_axis_tdata,
                output_axis_tvalid=output_axis_tvalid,
                output_axis_tready=output_axis_tready,
                output_axis_tlast=output_axis_tlast,
                output_axis_tuser=output_axis_tuser,

                tag=tag,
                trigger=trigger)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    monitor_axis_tdata = Signal(intbv(0)[64:])
    monitor_axis_tkeep = Signal(intbv(0)[8:])
    monitor_axis_tvalid = Signal(bool(0))
    monitor_axis_tready = Signal(bool(0))
    monitor_axis_tlast = Signal(bool(0))
    monitor_axis_tuser = Signal(bool(0))
    output_axis_tready = Signal(bool(0))

    tag = Signal(intbv(16)[16:])
    trigger = Signal(bool(0))

    # Outputs
    output_axis_tdata = Signal(intbv(0)[8:])
    output_axis_tvalid = Signal(bool(0))
    output_axis_tlast = Signal(bool(0))
    output_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    monitor_sink_queue = Queue()
    monitor_sink_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource(clk,
                                    rst,
                                    tdata=monitor_axis_tdata,
                                    tkeep=monitor_axis_tkeep,
                                    tvalid=monitor_axis_tvalid,
                                    tready=monitor_axis_tready,
                                    tlast=monitor_axis_tlast,
                                    tuser=monitor_axis_tuser,
                                    fifo=source_queue,
                                    pause=source_pause,
                                    name='source')

    monitor_sink = axis_ep.AXIStreamSink(clk,
                                rst,
                                tdata=monitor_axis_tdata,
                                tkeep=monitor_axis_tkeep,
                                tvalid=monitor_axis_tvalid,
                                tready=monitor_axis_tready,
                                tlast=monitor_axis_tlast,
                                tuser=monitor_axis_tuser,
                                fifo=monitor_sink_queue,
                                pause=monitor_sink_pause,
                                name='monitor_sink')

    sink = axis_ep.AXIStreamSink(clk,
                                rst,
                                tdata=output_axis_tdata,
                                tvalid=output_axis_tvalid,
                                tready=output_axis_tready,
                                tlast=output_axis_tlast,
                                tuser=output_axis_tuser,
                                fifo=sink_queue,
                                pause=sink_pause,
                                name='sink')

    # DUT
    dut = dut_axis_stat_counter(clk,
                           rst,
                           current_test,

                           monitor_axis_tdata,
                           monitor_axis_tkeep,
                           monitor_axis_tvalid,
                           monitor_axis_tready,
                           monitor_axis_tlast,
                           monitor_axis_tuser,

                           output_axis_tdata,
                           output_axis_tvalid,
                           output_axis_tready,
                           output_axis_tlast,
                           output_axis_tuser,

                           tag,
                           trigger)

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
        tag.next = 1

        yield clk.posedge
        print("test 1: test tick timer")
        current_test.next = 1

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        for i in range(100-1):
            yield clk.posedge

        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[1] == 100*8

        yield delay(100)

        yield clk.posedge
        print("test 2: pause sink")
        current_test.next = 2

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        for i in range(100-1):
            yield clk.posedge

        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        
        while trigger or output_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[1] == 100*8

        yield delay(100)

        yield clk.posedge
        print("test 3: test packet")
        current_test.next = 3

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            b'\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame.data)
        assert rx_frame_values[3] == 1

        yield delay(100)

        yield clk.posedge
        print("test 4: longer packet")
        current_test.next = 4

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source_queue.put(test_frame)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame.data)
        assert rx_frame_values[3] == 1

        yield delay(100)

        yield clk.posedge
        print("test 5: test packet with pauses")
        current_test.next = 5

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                            b'\x5A\x51\x52\x53\x54\x55' +
                                            b'\x80\x00' +
                                            bytearray(range(256)))
        source_queue.put(test_frame)
        yield clk.posedge

        yield delay(64)
        yield clk.posedge
        source_pause.next = True
        yield delay(32)
        yield clk.posedge
        source_pause.next = False

        yield delay(64)
        yield clk.posedge
        monitor_sink_pause.next = True
        yield delay(32)
        yield clk.posedge
        monitor_sink_pause.next = False

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame.data)
        assert rx_frame_values[3] == 1

        yield delay(100)

        yield clk.posedge
        print("test 6: back-to-back packets")
        current_test.next = 6

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame1.data) + len(test_frame2.data)
        assert rx_frame_values[3] == 2

        yield delay(100)

        yield clk.posedge
        print("test 7: alternate pause source")
        current_test.next = 7

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame1.data) + len(test_frame2.data)
        assert rx_frame_values[3] == 2

        yield delay(100)

        yield clk.posedge
        print("test 8: alternate pause sink")
        current_test.next = 8

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        test_frame1 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        test_frame2 = axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             b'\x02\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')
        source_queue.put(test_frame1)
        source_queue.put(test_frame2)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == len(test_frame1.data) + len(test_frame2.data)
        assert rx_frame_values[3] == 2

        yield delay(100)

        yield clk.posedge
        print("test 9: various length packets")
        current_test.next = 9

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        lens = [32, 48, 96, 128, 256]
        test_frame = []

        for i in range(len(lens)):
            test_frame.append(axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             bytearray(range(lens[i]))))

        for f in test_frame:
            source_queue.put(f)
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        print(rx_frame_values)

        assert rx_frame_values[0] == 1
        assert rx_frame_values[1] == cycles*8
        assert rx_frame_values[2] == sum(len(f.data) for f in test_frame)
        assert rx_frame_values[3] == len(test_frame)

        yield delay(100)

        yield clk.posedge
        print("test 10: various length packets with intermediate trigger")
        current_test.next = 10

        yield clk.posedge
        start_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0

        lens = [32, 48, 96, 128, 256]
        test_frame = []

        for i in range(len(lens)):
            test_frame.append(axis_ep.AXIStreamFrame(b'\xDA\xD1\xD2\xD3\xD4\xD5' +
                                             b'\x5A\x51\x52\x53\x54\x55' +
                                             b'\x80\x00' +
                                             bytearray(range(lens[i]))))

        for f in test_frame:
            source_queue.put(f)
        yield clk.posedge

        yield delay(200)

        yield clk.posedge
        trigger_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while monitor_axis_tvalid:
            yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge

        yield clk.posedge
        stop_time = now()
        trigger.next = 1
        yield clk.posedge
        trigger.next = 0
        yield clk.posedge

        while output_axis_tvalid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        # discard first trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        # check second trigger output
        if not sink_queue.empty():
            rx_frame2 = sink_queue.get()

        rx_frame_values = struct.unpack(">HLLL", rx_frame.data)
        cycles = (stop_time - start_time) / 8
        cycles1 = (trigger_time - start_time) / 8
        print(rx_frame_values)

        rx_frame2_values = struct.unpack(">HLLL", rx_frame2.data)
        cycles2 = (stop_time - trigger_time) / 8
        print(rx_frame2_values)

        assert rx_frame_values[0] == 1
        assert rx_frame2_values[0] == 1
        assert rx_frame_values[1] == cycles1*8
        assert rx_frame2_values[1] == cycles2*8
        assert rx_frame_values[1] + rx_frame2_values[1] == cycles*8
        assert rx_frame_values[2] + rx_frame2_values[2] == sum(len(f.data) for f in test_frame)
        assert rx_frame_values[3] + rx_frame2_values[3] == len(test_frame)

        yield delay(100)

        raise StopSimulation

    return dut, source, monitor_sink, sink, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

