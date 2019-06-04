#!/usr/bin/env python
"""

Copyright (c) 2015-2019 Alex Forencich

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

module = 'ptp_clock'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    PERIOD_NS_WIDTH = 4
    OFFSET_NS_WIDTH = 4
    DRIFT_NS_WIDTH = 4
    FNS_WIDTH = 16
    PERIOD_NS = 0x6
    PERIOD_FNS = 0x6666
    DRIFT_ENABLE = 1
    DRIFT_NS = 0x0
    DRIFT_FNS = 0x0002
    DRIFT_RATE = 0x0005

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_ts_96 = Signal(intbv(0)[96:])
    input_ts_96_valid = Signal(bool(0))
    input_ts_64 = Signal(intbv(0)[64:])
    input_ts_64_valid = Signal(bool(0))
    input_period_ns = Signal(intbv(0)[PERIOD_NS_WIDTH:])
    input_period_fns = Signal(intbv(0)[FNS_WIDTH:])
    input_period_valid = Signal(bool(0))
    input_adj_ns = Signal(intbv(0)[OFFSET_NS_WIDTH:])
    input_adj_fns = Signal(intbv(0)[FNS_WIDTH:])
    input_adj_count = Signal(intbv(0)[16:])
    input_adj_valid = Signal(bool(0))
    input_drift_ns = Signal(intbv(0)[DRIFT_NS_WIDTH:])
    input_drift_fns = Signal(intbv(0)[FNS_WIDTH:])
    input_drift_rate = Signal(intbv(0)[16:])
    input_drift_valid = Signal(bool(0))

    # Outputs
    input_adj_active = Signal(bool(0))
    output_ts_96 = Signal(intbv(0)[96:])
    output_ts_64 = Signal(intbv(0)[64:])
    output_ts_step = Signal(bool(0))
    output_pps = Signal(bool(0))

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        input_ts_96=input_ts_96,
        input_ts_96_valid=input_ts_96_valid,
        input_ts_64=input_ts_64,
        input_ts_64_valid=input_ts_64_valid,

        input_period_ns=input_period_ns,
        input_period_fns=input_period_fns,
        input_period_valid=input_period_valid,

        input_adj_ns=input_adj_ns,
        input_adj_fns=input_adj_fns,
        input_adj_count=input_adj_count,
        input_adj_valid=input_adj_valid,
        input_adj_active=input_adj_active,

        input_drift_ns=input_drift_ns,
        input_drift_fns=input_drift_fns,
        input_drift_rate=input_drift_rate,
        input_drift_valid=input_drift_valid,

        output_ts_96=output_ts_96,
        output_ts_64=output_ts_64,
        output_ts_step=output_ts_step,

        output_pps=output_pps
    )

    @always(delay(3200))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100000)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100000)
        yield clk.posedge

        # testbench stimulus

        yield clk.posedge
        print("test 1: Default rate and drift")
        current_test.next = 1

        yield clk.posedge
        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(10000):
            yield clk.posedge

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96)) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64)) < 1e-12

        yield delay(100000)

        yield clk.posedge
        print("test 2: Load timestamps")
        current_test.next = 2

        input_ts_96.next = 12345678
        input_ts_96_valid.next = 1
        input_ts_64.next = 87654321
        input_ts_64_valid.next = 1

        yield clk.posedge

        input_ts_96_valid.next = 0
        input_ts_64_valid.next = 0

        yield clk.posedge

        assert output_ts_96 == 12345678
        assert output_ts_64 == 87654321
        
        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(2000):
            yield clk.posedge

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96)) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64)) < 1e-12

        yield delay(100000)

        yield clk.posedge
        print("test 3: Seconds increment")
        current_test.next = 3

        input_ts_96.next = 999990000*2**16
        input_ts_96_valid.next = 1
        input_ts_64.next = 999990000*2**16
        input_ts_64_valid.next = 1

        yield clk.posedge

        input_ts_96_valid.next = 0
        input_ts_64_valid.next = 0

        yield clk.posedge

        assert output_ts_96 == 999990000*2**16
        assert output_ts_64 == 999990000*2**16
        
        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(3000):
            yield clk.posedge

            if output_pps:
                assert output_ts_96[96:48] == 1
                assert output_ts_96[48:0] < 10*2**16

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96)) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64)) < 1e-12

        yield delay(100000)

        yield clk.posedge
        print("test 4: Offset adjust")
        current_test.next = 4

        input_ts_96.next = 0
        input_ts_96_valid.next = 1
        input_ts_64.next = 0
        input_ts_64_valid.next = 1

        yield clk.posedge

        input_ts_96_valid.next = 0
        input_ts_64_valid.next = 0

        yield clk.posedge

        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(2000):
            yield clk.posedge        

        # 1 ns offset - 1024*64/65536 = 1
        input_adj_ns.next = 0
        input_adj_fns.next = 64
        input_adj_count.next = 1024
        input_adj_valid.next = 1

        for i in range(2000):
            yield clk.posedge
            input_adj_valid.next = 0

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96) + 1e-9) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64) + 1e-9) < 1e-12

        yield delay(100000)

        yield clk.posedge
        print("test 5: Frequency adjust")
        current_test.next = 5

        input_ts_96.next = 0
        input_ts_96_valid.next = 1
        input_ts_64.next = 0
        input_ts_64_valid.next = 1

        input_period_ns.next = 6
        input_period_fns.next = 0x6624
        input_period_valid.next = 1

        # flush old period out of pipeline registers
        yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        input_ts_96_valid.next = 0
        input_ts_64_valid.next = 0
        input_period_valid.next = 0

        yield clk.posedge
        
        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(10000):
            yield clk.posedge

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96) * 6.4/(6+(0x6624+2/5)/2**16)) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64) * 6.4/(6+(0x6624+2/5)/2**16)) < 1e-12

        yield delay(100000)

        yield clk.posedge
        print("test 6: Drift adjust")
        current_test.next = 6

        input_ts_96.next = 0
        input_ts_96_valid.next = 1
        input_ts_64.next = 0
        input_ts_64_valid.next = 1

        input_period_ns.next = 6
        input_period_fns.next = 0x6666
        input_period_valid.next = 1

        input_drift_ns.next = 0
        input_drift_fns.next = 20
        input_drift_rate.next = 5
        input_drift_valid.next = 1

        # flush old period out of pipeline registers
        yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        input_ts_96_valid.next = 0
        input_ts_64_valid.next = 0
        input_period_valid.next = 0
        input_drift_valid.next = 0

        yield clk.posedge
        
        start_time = now()*1e-12
        start_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        start_ts_64 = output_ts_64/2**16*1e-9

        for i in range(10000):
            yield clk.posedge

        stop_time = now()*1e-12
        stop_ts_96 = output_ts_96[96:48] + (output_ts_96[48:0]/2**16*1e-9)
        stop_ts_64 = output_ts_64/2**16*1e-9

        print(stop_time-start_time)
        print(stop_ts_96-start_ts_96)
        print(stop_ts_64-start_ts_64)

        assert abs((stop_time-start_time) - (stop_ts_96-start_ts_96) * 6.4/(6+(0x6666+20/5)/2**16)) < 1e-12
        assert abs((stop_time-start_time) - (stop_ts_64-start_ts_64) * 6.4/(6+(0x6666+20/5)/2**16)) < 1e-12

        yield delay(100000)

        raise StopSimulation

    return dut, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
