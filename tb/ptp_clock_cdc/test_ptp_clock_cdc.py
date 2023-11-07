#!/usr/bin/env python
"""

Copyright (c) 2020-2023 Alex Forencich

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

import logging
import os
from statistics import mean, stdev

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.utils import get_sim_steps, get_sim_time

from cocotbext.eth import PtpClock


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.sample_clk, 9.9, units="ns").start())

        if len(dut.input_ts) == 64:
            self.ptp_clock = PtpClock(
                ts_rel=dut.input_ts,
                ts_step=dut.input_ts_step,
                clock=dut.input_clk,
                reset=dut.input_rst,
                period_ns=6.4
            )
        else:
            self.ptp_clock = PtpClock(
                ts_tod=dut.input_ts,
                ts_step=dut.input_ts_step,
                clock=dut.input_clk,
                reset=dut.input_rst,
                period_ns=6.4
            )

        self.input_clock_period = 6.4
        dut.input_clk.setimmediatevalue(0)
        cocotb.start_soon(self._run_input_clock())

        self.output_clock_period = 6.4
        dut.output_clk.setimmediatevalue(0)
        cocotb.start_soon(self._run_output_clock())

    async def reset(self):
        self.dut.input_rst.setimmediatevalue(0)
        self.dut.output_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.input_clk)
        await RisingEdge(self.dut.input_clk)
        self.dut.input_rst.value = 1
        self.dut.output_rst.value = 1
        for k in range(10):
            await RisingEdge(self.dut.input_clk)
        self.dut.input_rst.value = 0
        self.dut.output_rst.value = 0
        for k in range(10):
            await RisingEdge(self.dut.input_clk)

    def set_input_clock_period(self, period):
        self.input_clock_period = period

    async def _run_input_clock(self):
        period = None
        steps_per_ns = get_sim_steps(1.0, 'ns')

        while True:
            if period != self.input_clock_period:
                period = self.input_clock_period
                t = Timer(int(steps_per_ns * period / 2.0))
            await t
            self.dut.input_clk.value = 1
            await t
            self.dut.input_clk.value = 0

    def set_output_clock_period(self, period):
        self.output_clock_period = period

    async def _run_output_clock(self):
        period = None
        steps_per_ns = get_sim_steps(1.0, 'ns')

        while True:
            if period != self.output_clock_period:
                period = self.output_clock_period
                t = Timer(int(steps_per_ns * period / 2.0))
            await t
            self.dut.output_clk.value = 1
            await t
            self.dut.output_clk.value = 0

    def get_input_ts_ns(self):
        ts = self.dut.input_ts.value.integer
        if len(self.dut.input_ts) == 64:
            return ts/2**16*1e-9
        else:
            return (ts >> 48) + ((ts & 0xffffffffffff)/2**16*1e-9)

    def get_output_ts_ns(self):
        ts = self.dut.output_ts.value.integer
        if len(self.dut.output_ts) == 64:
            return ts/2**16*1e-9
        else:
            return (ts >> 48) + ((ts & 0xffffffffffff)/2**16*1e-9)

    async def measure_ts_diff(self, N=100):
        input_ts_lst = []
        output_ts_lst = []

        async def collect_timestamps(clk, get_ts, lst):
            while True:
                await RisingEdge(clk)
                lst.append((get_sim_time('sec'), get_ts()))

        input_cr = cocotb.start_soon(collect_timestamps(self.dut.input_clk, self.get_input_ts_ns, input_ts_lst))
        output_cr = cocotb.start_soon(collect_timestamps(self.dut.output_clk, self.get_output_ts_ns, output_ts_lst))

        for k in range(N):
            await RisingEdge(self.dut.output_clk)

        input_cr.kill()
        output_cr.kill()

        diffs = []

        its1 = input_ts_lst.pop(0)
        its2 = input_ts_lst.pop(0)

        for ots in output_ts_lst:
            while its2[0] < ots[0] and input_ts_lst:
                its1 = its2
                its2 = input_ts_lst.pop(0)

            if its2[0] < ots[0]:
                break

            dt = its2[0] - its1[0]
            dts = its2[1] - its1[1]

            its = its1[1]+dts/dt*(ots[0]-its1[0])

            diffs.append(ots[1] - its)

        return diffs


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.input_clk)
    tb.log.info("Same clock speed")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("10 ppm slower")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4*(1+.00001))

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("10 ppm faster")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4*(1-.00001))

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("200 ppm slower")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4*(1+.0002))

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("200 ppm faster")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4*(1-.0002))

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Coherent tracking (+/- 10 ppm)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4)

    await RisingEdge(dut.input_clk)

    period = 6.400
    step = 0.000002
    period_min = 6.4*(1-.00001)
    period_max = 6.4*(1+.00001)

    for i in range(500):
        period += step

        if period <= period_min:
            step = abs(step)
        if period >= period_max:
            step = -abs(step)

        tb.set_output_clock_period(period)

        for i in range(200):
            await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Coherent tracking (+/- 200 ppm)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.4)

    await RisingEdge(dut.input_clk)

    period = 6.400
    step = 0.000002
    period_min = 6.4*(1-.0002)
    period_max = 6.4*(1+.0002)

    for i in range(5000):
        period += step

        if period <= period_min:
            step = abs(step)
        if period >= period_max:
            step = -abs(step)

        tb.set_output_clock_period(period)

        for i in range(20):
            await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Slightly faster (6.3 ns)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.3)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Slightly slower (6.5 ns)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(6.5)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Significantly faster (250 MHz)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(4.0)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Significantly slower (100 MHz)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(10.0)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    tb.log.info("Significantly faster (390.625 MHz)")

    tb.set_input_clock_period(6.4)
    tb.set_output_clock_period(2.56)

    await RisingEdge(dut.input_clk)

    for i in range(100000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference: {mean(diffs)*1e9} ns (stdev: {stdev(diffs)*1e9})")
    assert abs(mean(diffs)*1e9) < 5

    await RisingEdge(dut.input_clk)
    await RisingEdge(dut.input_clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("ts_width", [96, 64])
def test_ptp_clock_cdc(request, ts_width):
    dut = "ptp_clock_cdc"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['TS_WIDTH'] = ts_width
    parameters['NS_WIDTH'] = 4
    parameters['LOG_RATE'] = 3
    parameters['PIPELINE_OUTPUT'] = 0

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
