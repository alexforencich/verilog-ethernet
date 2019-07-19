#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

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

import ptp

module = 'ptp_clock_cdc'
testbench = 'test_%s_96' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TS_WIDTH = 96
    NS_WIDTH = 4
    FNS_WIDTH = 16
    INPUT_PERIOD_NS = 0x6
    INPUT_PERIOD_FNS = 0x6666
    OUTPUT_PERIOD_NS = 0x6
    OUTPUT_PERIOD_FNS = 0x6666
    USE_SAMPLE_CLOCK = 1
    LOG_FIFO_DEPTH = 3
    LOG_RATE = 3

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_clk = Signal(bool(0))
    input_rst = Signal(bool(0))
    output_clk = Signal(bool(0))
    output_rst = Signal(bool(0))
    sample_clk = Signal(bool(0))
    input_ts = Signal(intbv(0)[96:])

    # Outputs
    output_ts = Signal(intbv(0)[96:])
    output_ts_step = Signal(bool(0))
    output_pps = Signal(bool(0))

    # PTP clock
    ptp_clock = ptp.PtpClock(period_ns=INPUT_PERIOD_NS, period_fns=INPUT_PERIOD_FNS)

    ptp_logic = ptp_clock.create_logic(
        input_clk,
        input_rst,
        ts_96=input_ts
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        input_clk=input_clk,
        input_rst=input_rst,
        output_clk=output_clk,
        output_rst=output_rst,
        sample_clk=sample_clk,
        input_ts=input_ts,
        output_ts=output_ts,
        output_ts_step=output_ts_step,
        output_pps=output_pps
    )

    @always(delay(3200))
    def clkgen():
        clk.next = not clk
        input_clk.next = not input_clk

    output_clk_hp = Signal(int(3200))

    @instance
    def clkgen_output():
        while True:
            yield delay(int(output_clk_hp))
            output_clk.next = not output_clk

    @always(delay(5000))
    def clkgen_sample():
        sample_clk.next = not sample_clk

    @instance
    def check():
        yield delay(100000)
        yield clk.posedge
        rst.next = 1
        input_rst.next = 1
        output_rst.next = 1
        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        input_rst.next = 0
        output_rst.next = 0
        yield clk.posedge
        yield delay(100000)
        yield clk.posedge

        # testbench stimulus

        yield clk.posedge
        print("test 1: Same clock speed")
        current_test.next = 1

        yield clk.posedge

        for i in range(20000):
            yield clk.posedge

        input_stop_ts = input_ts[96:48] + (input_ts[48:0]/2**16*1e-9)
        output_stop_ts = output_ts[96:48] + (output_ts[48:0]/2**16*1e-9)

        print(input_stop_ts-output_stop_ts)

        assert abs(input_stop_ts-output_stop_ts) < 1e-8

        yield delay(100000)

        yield clk.posedge
        print("test 2: Slightly faster")
        current_test.next = 2

        output_clk_hp.next = 3100

        yield clk.posedge

        for i in range(20000):
            yield clk.posedge

        input_stop_ts = input_ts[96:48] + (input_ts[48:0]/2**16*1e-9)
        output_stop_ts = output_ts[96:48] + (output_ts[48:0]/2**16*1e-9)

        print(input_stop_ts-output_stop_ts)

        assert abs(input_stop_ts-output_stop_ts) < 1e-8

        yield delay(100000)

        yield clk.posedge
        print("test 3: Slightly slower")
        current_test.next = 3

        output_clk_hp.next = 3300

        yield clk.posedge

        for i in range(20000):
            yield clk.posedge

        input_stop_ts = input_ts[96:48] + (input_ts[48:0]/2**16*1e-9)
        output_stop_ts = output_ts[96:48] + (output_ts[48:0]/2**16*1e-9)

        print(input_stop_ts-output_stop_ts)

        assert abs(input_stop_ts-output_stop_ts) < 1e-8

        yield delay(100000)

        yield clk.posedge
        print("test 4: Significantly faster")
        current_test.next = 4

        output_clk_hp.next = 2000

        yield clk.posedge

        for i in range(20000):
            yield clk.posedge

        input_stop_ts = input_ts[96:48] + (input_ts[48:0]/2**16*1e-9)
        output_stop_ts = output_ts[96:48] + (output_ts[48:0]/2**16*1e-9)

        print(input_stop_ts-output_stop_ts)

        assert abs(input_stop_ts-output_stop_ts) < 1e-8

        yield delay(100000)

        yield clk.posedge
        print("test 5: Significantly slower")
        current_test.next = 5

        output_clk_hp.next = 5000

        yield clk.posedge

        for i in range(30000):
            yield clk.posedge

        input_stop_ts = input_ts[96:48] + (input_ts[48:0]/2**16*1e-9)
        output_stop_ts = output_ts[96:48] + (output_ts[48:0]/2**16*1e-9)

        print(input_stop_ts-output_stop_ts)

        assert abs(input_stop_ts-output_stop_ts) < 1e-8

        yield delay(100000)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
