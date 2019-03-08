#!/usr/bin/env python
"""

Copyright (c) 2016-2018 Alex Forencich

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

module = 'axis_cobs_encode'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def cobs_encode(block):
    block = bytearray(block)
    enc = bytearray()

    seg = bytearray()
    code = 1

    new_data = True

    for b in block:
        if b == 0:
            enc.append(code)
            enc.extend(seg)
            code = 1
            seg = bytearray()
            new_data = True
        else:
            code += 1
            seg.append(b)
            new_data = True
            if code == 255:
                enc.append(code)
                enc.extend(seg)
                code = 1
                seg = bytearray()
                new_data = False

    if new_data:
        enc.append(code)
        enc.extend(seg)

    return bytes(enc)

def cobs_decode(block):
    block = bytearray(block)
    dec = bytearray()

    code = 0

    i = 0

    if 0 in block:
        return None

    while i < len(block):
        code = block[i]
        i += 1
        if i+code-1 > len(block):
            return None
        dec.extend(block[i:i+code-1])
        i += code-1
        if code < 255 and i < len(block):
            dec.append(0)

    return bytes(dec)

def prbs31(state = 0x7fffffff):
    while True:
        for i in range(8):
            if bool(state & 0x08000000) ^ bool(state & 0x40000000):
                state = ((state & 0x3fffffff) << 1) | 1
            else:
                state = (state & 0x3fffffff) << 1
        yield state & 0xff

def bench():

    # Parameters
    APPEND_ZERO = 0

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_axis_tdata = Signal(intbv(0)[8:])
    s_axis_tvalid = Signal(bool(0))
    s_axis_tlast = Signal(bool(0))
    s_axis_tuser = Signal(bool(0))
    m_axis_tready = Signal(bool(0))

    # Outputs
    s_axis_tready = Signal(bool(0))
    m_axis_tdata = Signal(intbv(0)[8:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tuser = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = axis_ep.AXIStreamSource()

    source_logic = source.create_logic(
        clk,
        rst,
        tdata=s_axis_tdata,
        tvalid=s_axis_tvalid,
        tready=s_axis_tready,
        tlast=s_axis_tlast,
        tuser=s_axis_tuser,
        pause=source_pause,
        name='source'
    )

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=m_axis_tdata,
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

        s_axis_tdata=s_axis_tdata,
        s_axis_tvalid=s_axis_tvalid,
        s_axis_tready=s_axis_tready,
        s_axis_tlast=s_axis_tlast,
        s_axis_tuser=s_axis_tuser,

        m_axis_tdata=m_axis_tdata,
        m_axis_tvalid=m_axis_tvalid,
        m_axis_tready=m_axis_tready,
        m_axis_tlast=m_axis_tlast,
        m_axis_tuser=m_axis_tuser
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if s_axis_tvalid or m_axis_tvalid or not source.empty():
                i = 4
            yield clk.posedge

    def wait_pause_source():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if s_axis_tvalid or m_axis_tvalid or not source.empty():
                i = 2
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            source_pause.next = True
            yield clk.posedge

        source_pause.next = False

    def wait_pause_sink():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if s_axis_tvalid or m_axis_tvalid or not source.empty():
                i = 2
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

        # testbench stimulus

        for payload_len in list(range(1,33))+list(range(253,259))+[512]:
            gen = prbs31()
            for block in [bytearray([0]*payload_len),
                        bytearray([k%255+1 for k in range(payload_len)]),
                        b'\x00'+bytearray([k%255+1 for k in range(payload_len)])+b'\x00',
                        bytearray([next(gen) for i in range(payload_len)])]:
                yield clk.posedge
                print("test 1: test packet, length %d" % payload_len)
                current_test.next = 1

                enc = cobs_encode(block)

                test_frame = axis_ep.AXIStreamFrame(block)

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    source.send(test_frame)
                    yield clk.posedge
                    yield clk.posedge

                    yield wait()

                    yield sink.wait()
                    rx_frame = sink.recv()

                    assert cobs_decode(enc) == block
                    assert rx_frame.data == enc
                    assert cobs_decode(rx_frame.data) == block
                    assert not rx_frame.last_cycle_user

                    assert sink.empty()

                    yield delay(100)

                yield clk.posedge
                print("test 2: back-to-back packets, length %d" % payload_len)
                current_test.next = 2

                test_frame1 = axis_ep.AXIStreamFrame(block)
                test_frame2 = axis_ep.AXIStreamFrame(block)

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    source.send(test_frame1)
                    source.send(test_frame2)
                    yield clk.posedge
                    yield clk.posedge

                    yield wait()

                    yield sink.wait()
                    rx_frame = sink.recv()

                    assert cobs_decode(enc) == block
                    assert rx_frame.data == enc
                    assert cobs_decode(rx_frame.data) == block
                    assert not rx_frame.last_cycle_user

                    yield sink.wait()
                    rx_frame = sink.recv()

                    assert cobs_decode(enc) == block
                    assert rx_frame.data == enc
                    assert cobs_decode(rx_frame.data) == block
                    assert not rx_frame.last_cycle_user

                    assert sink.empty()

                    yield delay(100)

                yield clk.posedge
                print("test 3: tuser assert, length %d" % payload_len)
                current_test.next = 3

                test_frame1 = axis_ep.AXIStreamFrame(block)
                test_frame2 = axis_ep.AXIStreamFrame(block)

                test_frame1.last_cycle_user = 1

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    source.send(test_frame1)
                    source.send(test_frame2)
                    yield clk.posedge
                    yield clk.posedge

                    yield wait()

                    yield sink.wait()
                    rx_frame = sink.recv()

                    assert cobs_decode(rx_frame.data) == None
                    assert rx_frame.last_cycle_user

                    yield sink.wait()
                    rx_frame = sink.recv()

                    assert cobs_decode(enc) == block
                    assert rx_frame.data == enc
                    assert cobs_decode(rx_frame.data) == block
                    assert not rx_frame.last_cycle_user

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
