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
import ll_ep

module = 'll_axis_bridge'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_ll_axis_bridge(clk,
                 rst,
                 current_test,

                 ll_data_in,
                 ll_sof_in_n,
                 ll_eof_in_n,
                 ll_src_rdy_in_n,
                 ll_dst_rdy_out_n,

                 axis_tdata,
                 axis_tvalid,
                 axis_tready,
                 axis_tlast):

    os.system(build_cmd)
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,

                ll_data_in=ll_data_in,
                ll_sof_in_n=ll_sof_in_n,
                ll_eof_in_n=ll_eof_in_n,
                ll_src_rdy_in_n=ll_src_rdy_in_n,
                ll_dst_rdy_out_n=ll_dst_rdy_out_n,

                axis_tdata=axis_tdata,
                axis_tvalid=axis_tvalid,
                axis_tready=axis_tready,
                axis_tlast=axis_tlast)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    ll_data_in = Signal(intbv(0)[8:])
    ll_sof_in_n = Signal(bool(1))
    ll_eof_in_n = Signal(bool(1))
    ll_src_rdy_in_n = Signal(bool(1))
    axis_tready = Signal(bool(0))

    # Outputs
    axis_tdata = Signal(intbv(0)[8:])
    axis_tvalid = Signal(bool(0))
    axis_tlast = Signal(bool(0))
    ll_dst_rdy_out_n = Signal(bool(1))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = ll_ep.LocalLinkSource(clk,
                                   rst,
                                   data_out=ll_data_in,
                                   sof_out_n=ll_sof_in_n,
                                   eof_out_n=ll_eof_in_n,
                                   src_rdy_out_n=ll_src_rdy_in_n,
                                   dst_rdy_in_n=ll_dst_rdy_out_n,
                                   fifo=source_queue,
                                   pause=source_pause,
                                   name='source')

    sink = axis_ep.AXIStreamSink(clk,
                                rst,
                                tdata=axis_tdata,
                                tvalid=axis_tvalid,
                                tready=axis_tready,
                                tlast=axis_tlast,
                                fifo=sink_queue,
                                pause=sink_pause,
                                name='sink')

    # DUT
    dut = dut_ll_axis_bridge(clk,
                        rst,
                        current_test,

                        ll_data_in,
                        ll_sof_in_n,
                        ll_eof_in_n,
                        ll_src_rdy_in_n,
                        ll_dst_rdy_out_n,

                        axis_tdata,
                        axis_tvalid,
                        axis_tready,
                        axis_tlast)

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

        source_queue.put(bytearray('\xDA\xD1\xD2\xD3\xD4\xD5' +
                                   '\x5A\x51\x52\x53\x54\x55' +
                                   '\x80\x00' +
                                   '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'))
        yield clk.posedge

        yield axis_tlast.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert bytearray(rx_frame) == ('\xDA\xD1\xD2\xD3\xD4\xD5' +
                                   '\x5A\x51\x52\x53\x54\x55' +
                                   '\x80\x00' +
                                   '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')

        yield delay(100)

        yield clk.posedge
        print("test 2: test packet with pauses")
        current_test.next = 2

        source_queue.put(bytearray('\xDA\xD1\xD2\xD3\xD4\xD5' +
                                   '\x5A\x51\x52\x53\x54\x55' +
                                   '\x80\x00' +
                                   '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10'))
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

        yield axis_tlast.negedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert bytearray(rx_frame) == ('\xDA\xD1\xD2\xD3\xD4\xD5' +
                                   '\x5A\x51\x52\x53\x54\x55' +
                                   '\x80\x00' +
                                   '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10')

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

