#!/usr/bin/env python
"""

Copyright (c) 2020 Alex Forencich

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

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.utils import get_sim_steps

from cocotbext.eth import PtpClock


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.input_clk, 6.4, units="ns").start())

        cocotb.start_soon(Clock(dut.sample_clk, 10, units="ns").start())

        if len(dut.input_ts) == 64:
            self.ptp_clock = PtpClock(
                ts_64=dut.input_ts,
                ts_step=dut.input_ts_step,
                clock=dut.input_clk,
                reset=dut.input_rst,
                period_ns=6.4
            )
        else:
            self.ptp_clock = PtpClock(
                ts_96=dut.input_ts,
                ts_step=dut.input_ts_step,
                clock=dut.input_clk,
                reset=dut.input_rst,
                period_ns=6.4
            )

        self._clock_cr = None
        self.set_output_clock_period(6.4)

    async def reset(self):
        self.dut.input_rst.setimmediatevalue(0)
        self.dut.output_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.input_clk)
        await RisingEdge(self.dut.input_clk)
        self.dut.input_rst <= 1
        self.dut.output_rst <= 1
        for k in range(10):
            await RisingEdge(self.dut.input_clk)
        self.dut.input_rst <= 0
        self.dut.output_rst <= 0
        for k in range(10):
            await RisingEdge(self.dut.input_clk)

    def set_output_clock_period(self, period):
        if self._clock_cr is not None:
            self._clock_cr.kill()

        self._clock_cr = cocotb.start_soon(self._run_clock(period))

    async def _run_clock(self, period):
        half_period = get_sim_steps(period / 2.0, 'ns')
        t = Timer(half_period)

        while True:
            await t
            self.dut.output_clk <= 1
            await t
            self.dut.output_clk <= 0

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

    async def measure_ts_diff(self, N=1000):
        total = 0
        for k in range(N):
            input_ts_ns = self.get_input_ts_ns()
            output_ts_ns = self.get_output_ts_ns()
            total += input_ts_ns-output_ts_ns
            await Timer(100, 'ps')
        return total/N


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.input_clk)
    tb.log.info("Same clock speed")

    await RisingEdge(dut.input_clk)

    for i in range(40000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diff = await tb.measure_ts_diff()*1e9

    tb.log.info(f"Difference: {diff} ns")

    assert abs(diff) < 10

    await RisingEdge(dut.input_clk)
    tb.log.info("Slightly faster")

    tb.set_output_clock_period(6.2)

    await RisingEdge(dut.input_clk)

    for i in range(40000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diff = await tb.measure_ts_diff()*1e9

    tb.log.info(f"Difference: {diff} ns")

    assert abs(diff) < 10

    await RisingEdge(dut.input_clk)
    tb.log.info("Slightly slower")

    tb.set_output_clock_period(6.6)

    await RisingEdge(dut.input_clk)

    for i in range(40000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diff = await tb.measure_ts_diff()*1e9

    tb.log.info(f"Difference: {diff} ns")

    assert abs(diff) < 10

    await RisingEdge(dut.input_clk)
    tb.log.info("Significantly faster")

    tb.set_output_clock_period(4.0)

    await RisingEdge(dut.input_clk)

    for i in range(40000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diff = await tb.measure_ts_diff()*1e9

    tb.log.info(f"Difference: {diff} ns")

    assert abs(diff) < 10

    await RisingEdge(dut.input_clk)
    tb.log.info("Significantly slower")

    tb.set_output_clock_period(10.0)

    await RisingEdge(dut.input_clk)

    for i in range(30000):
        await RisingEdge(dut.input_clk)

    assert tb.dut.locked.value.integer

    diff = await tb.measure_ts_diff()*1e9

    tb.log.info(f"Difference: {diff} ns")

    assert abs(diff) < 10

    await RisingEdge(dut.input_clk)
    await RisingEdge(dut.input_clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("sample_clock", [1, 0])
@pytest.mark.parametrize("ts_width", [96, 64])
def test_ptp_clock_cdc(request, ts_width, sample_clock):
    dut = "ptp_clock_cdc"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['TS_WIDTH'] = ts_width
    parameters['NS_WIDTH'] = 4
    parameters['FNS_WIDTH'] = 16
    parameters['USE_SAMPLE_CLOCK'] = sample_clock
    parameters['LOG_RATE'] = 3

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
