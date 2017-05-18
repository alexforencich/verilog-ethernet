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

module = 'arp_cache'
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

    query_request_valid = Signal(bool(0))
    query_request_ip = Signal(intbv(0)[32:])

    write_request_valid = Signal(bool(0))
    write_request_ip = Signal(intbv(0)[32:])
    write_request_mac = Signal(intbv(0)[48:])

    clear_cache = Signal(bool(0))

    # Outputs
    query_response_valid = Signal(bool(0))
    query_response_error = Signal(bool(0))
    query_response_mac = Signal(intbv(0)[48:])

    write_in_progress = Signal(bool(0))
    write_complete = Signal(bool(0))

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        query_request_valid=query_request_valid,
        query_request_ip=query_request_ip,
        query_response_valid=query_response_valid,
        query_response_error=query_response_error,
        query_response_mac=query_response_mac,

        write_request_valid=write_request_valid,
        write_request_ip=write_request_ip,
        write_request_mac=write_request_mac,
        write_in_progress=write_in_progress,
        write_complete=write_complete,

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
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80111
        write_request_mac.next = 0x0000c0a80111
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80112
        write_request_mac.next = 0x0000c0a80112
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield delay(100)

        yield clk.posedge
        print("test 2: read")
        current_test.next = 2

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80111

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80112
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80112

        # not in cache; was not written
        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80113
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield delay(100)

        yield clk.posedge
        print("test 3: write more")
        current_test.next = 3

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80121
        write_request_mac.next = 0x0000c0a80121
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80122
        write_request_mac.next = 0x0000c0a80122
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        # overwrites 0xc0a80121 due to LRU
        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80123
        write_request_mac.next = 0x0000c0a80123
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield delay(100)

        yield clk.posedge
        print("test 4: read more")
        current_test.next = 4

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80111

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80112
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80112

        # not in cache; was overwritten
        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80121
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80122
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80122

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80123
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80123

        # LRU reset by previous operation

        yield delay(100)

        yield clk.posedge
        print("test 5: LRU test")
        current_test.next = 5

        # read to set LRU bit
        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80111

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80131
        write_request_mac.next = 0x0000c0a80131
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80132
        write_request_mac.next = 0x0000c0a80132
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80133
        write_request_mac.next = 0x0000c0a80133
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        # read values
        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80111

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80112
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80121
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80122
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80123
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80131
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80131

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80132
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80132

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80133
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80133

        # LRU reset by previous operation

        yield delay(100)

        yield clk.posedge
        print("test 6: Test overwrite")
        current_test.next = 6

        yield clk.posedge
        write_request_valid.next = True
        write_request_ip.next = 0xc0a80133
        write_request_mac.next = 0x0000c0a80164
        yield clk.posedge
        write_request_valid.next = False

        yield write_complete.posedge
        yield clk.posedge

        # read values
        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80111

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80112
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80121
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80122
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80123
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80131
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80131

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80132
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80132

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80133
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert not bool(query_response_error)
        assert int(query_response_mac) == 0x0000c0a80164

        # LRU reset by previous operation

        yield delay(100)

        yield clk.posedge
        print("test 7: clear cache")
        current_test.next = 7

        yield clk.posedge
        clear_cache.next = True
        yield clk.posedge
        clear_cache.next = False

        yield delay(100)

        yield clk.posedge
        query_request_valid.next = True
        query_request_ip.next = 0xc0a80111
        yield clk.posedge
        query_request_valid.next = False

        yield query_response_valid.posedge
        assert bool(query_response_error)

        yield delay(100)

        raise StopSimulation

    return dut, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

