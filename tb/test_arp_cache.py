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

module = 'arp_cache'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    CACHE_ADDR_WIDTH = 2

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    query_request_valid = Signal(bool(0))
    query_request_ip = Signal(intbv(0)[32:])

    query_response_ready = Signal(bool(0))

    write_request_valid = Signal(bool(0))
    write_request_ip = Signal(intbv(0)[32:])
    write_request_mac = Signal(intbv(0)[48:])

    clear_cache = Signal(bool(0))

    # Outputs
    query_request_ready = Signal(bool(0))

    query_response_valid = Signal(bool(0))
    query_response_error = Signal(bool(0))
    query_response_mac = Signal(intbv(0)[48:])

    write_request_ready = Signal(bool(0))

    # sources and sinks
    query_request_source_pause = Signal(bool(0))
    query_response_sink_pause = Signal(bool(0))
    write_request_source_pause = Signal(bool(0))

    query_request_source = axis_ep.AXIStreamSource()

    query_request_source_logic = query_request_source.create_logic(
        clk,
        rst,
        tdata=(query_request_ip,),
        tvalid=query_request_valid,
        tready=query_request_ready,
        pause=query_request_source_pause,
        name='query_request_source'
    )

    query_response_sink = axis_ep.AXIStreamSink()

    query_response_sink_logic = query_response_sink.create_logic(
        clk,
        rst,
        tdata=(query_response_mac,),
        tvalid=query_response_valid,
        tready=query_response_ready,
        tuser=query_response_error,
        pause=query_response_sink_pause,
        name='query_response_sink'
    )

    write_request_source = axis_ep.AXIStreamSource()

    write_request_source_logic = write_request_source.create_logic(
        clk,
        rst,
        tdata=(write_request_ip, write_request_mac),
        tvalid=write_request_valid,
        tready=write_request_ready,
        pause=write_request_source_pause,
        name='write_request_source'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        query_request_valid=query_request_valid,
        query_request_ready=query_request_ready,
        query_request_ip=query_request_ip,

        query_response_valid=query_response_valid,
        query_response_ready=query_response_ready,
        query_response_error=query_response_error,
        query_response_mac=query_response_mac,

        write_request_valid=write_request_valid,
        write_request_ready=write_request_ready,
        write_request_ip=write_request_ip,
        write_request_mac=write_request_mac,

        clear_cache=clear_cache
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
        print("test 1: write")
        current_test.next = 1

        yield clk.posedge
        write_request_source.send([(0xc0a80111, 0x0000c0a80111)])
        write_request_source.send([(0xc0a80112, 0x0000c0a80112)])

        yield delay(100)

        while not write_request_source.empty():
            yield clk.posedge

        yield delay(100)

        yield clk.posedge
        print("test 2: read")
        current_test.next = 2

        yield clk.posedge
        query_request_source.send([(0xc0a80111, )])
        query_request_source.send([(0xc0a80112, )])
        query_request_source.send([(0xc0a80113, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80111
        assert not resp.user[0]

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80112
        assert not resp.user[0]

        # not in cache; was not written
        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.user[0]

        yield delay(100)

        yield clk.posedge
        print("test 3: write more")
        current_test.next = 3

        yield clk.posedge
        write_request_source.send([(0xc0a80121, 0x0000c0a80121)])
        write_request_source.send([(0xc0a80122, 0x0000c0a80122)])
        # overwrites 0xc0a80112
        write_request_source.send([(0xc0a80123, 0x0000c0a80123)])

        while not write_request_source.empty():
            yield clk.posedge

        yield delay(100)

        yield clk.posedge
        print("test 4: read more")
        current_test.next = 4

        yield clk.posedge
        query_request_source.send([(0xc0a80111, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80111
        assert not resp.user[0]

        # not in cache; was overwritten
        yield clk.posedge
        query_request_source.send([(0xc0a80112, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80121, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80121
        assert not resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80122, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80122
        assert not resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80123, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80123
        assert not resp.user[0]

        yield delay(100)

        yield clk.posedge
        print("test 5: Test overwrite")
        current_test.next = 5

        yield clk.posedge
        write_request_source.send([(0xc0a80123, 0x0000c0a80164)])

        while not write_request_source.empty():
            yield clk.posedge

        # read values
        yield clk.posedge
        query_request_source.send([(0xc0a80111, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80111
        assert not resp.user[0]

        # not in cache; was overwritten
        yield clk.posedge
        query_request_source.send([(0xc0a80112, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80121, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80121
        assert not resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80122, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80122
        assert not resp.user[0]

        yield clk.posedge
        query_request_source.send([(0xc0a80123, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.data[0][0] == 0x0000c0a80164
        assert not resp.user[0]

        yield delay(100)

        yield clk.posedge
        print("test 6: clear cache")
        current_test.next = 6

        yield clk.posedge
        clear_cache.next = True
        yield clk.posedge
        clear_cache.next = False

        yield delay(100)

        yield clk.posedge
        query_request_source.send([(0xc0a80111, )])

        yield query_response_sink.wait()
        resp = query_response_sink.recv()
        assert resp.user[0]

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

