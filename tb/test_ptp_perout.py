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

module = 'ptp_perout'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    FNS_ENABLE = 1
    OUT_START_S = 0x0
    OUT_START_NS = 0x0
    OUT_START_FNS = 0x0000
    OUT_PERIOD_S = 1
    OUT_PERIOD_NS = 0
    OUT_PERIOD_FNS = 0x0000
    OUT_WIDTH_S = 0x0
    OUT_WIDTH_NS = 1000
    OUT_WIDTH_FNS = 0x0000

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_ts_96 = Signal(intbv(0)[96:])
    input_ts_step = Signal(bool(0))
    enable = Signal(bool(0))
    input_start = Signal(intbv(0)[96:])
    input_start_valid = Signal(bool(0))
    input_period = Signal(intbv(0)[96:])
    input_period_valid = Signal(bool(0))
    input_width = Signal(intbv(0)[96:])
    input_width_valid = Signal(bool(0))

    # Outputs
    locked = Signal(bool(0))
    error = Signal(bool(0))
    output_pulse = Signal(bool(0))

    # PTP clock
    ptp_clock = ptp.PtpClock()

    ptp_logic = ptp_clock.create_logic(
        clk,
        rst,
        ts_96=input_ts_96
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        input_ts_96=input_ts_96,
        input_ts_step=input_ts_step,
        enable=enable,
        input_start=input_start,
        input_start_valid=input_start_valid,
        input_period=input_period,
        input_period_valid=input_period_valid,
        input_width=input_width,
        input_width_valid=input_width_valid,
        locked=locked,
        error=error,
        output_pulse=output_pulse
    )

    @always(delay(32))
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

        # testbench stimulus

        enable.next = 1

        yield clk.posedge
        print("test 1: Test pulse out")
        current_test.next = 1

        input_start.next = 100 << 16
        input_start_valid.next = 1
        input_period.next = 100 << 16
        input_period_valid.next = 1
        input_width.next = 50 << 16
        input_width_valid.next = 1

        yield clk.posedge

        input_start_valid.next = 0
        input_period_valid.next = 0
        input_width_valid.next = 0


        yield delay(10000)

        yield delay(100)

        yield clk.posedge
        print("test 2: Test pulse out")
        current_test.next = 2

        input_start.next = 0 << 16
        input_start_valid.next = 1
        input_period.next = 100 << 16
        input_period_valid.next = 1
        input_width.next = 50 << 16
        input_width_valid.next = 1

        yield clk.posedge

        input_start_valid.next = 0
        input_period_valid.next = 0
        input_width_valid.next = 0


        yield delay(10000)

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
