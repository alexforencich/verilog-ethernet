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

import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_sim_time


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        dut.input_ts_96.setimmediatevalue(0)
        dut.input_ts_96_valid.setimmediatevalue(0)
        dut.input_ts_64.setimmediatevalue(0)
        dut.input_ts_64_valid.setimmediatevalue(0)

        dut.input_period_ns.setimmediatevalue(0)
        dut.input_period_fns.setimmediatevalue(0)
        dut.input_period_valid.setimmediatevalue(0)

        dut.input_adj_ns.setimmediatevalue(0)
        dut.input_adj_fns.setimmediatevalue(0)
        dut.input_adj_count.setimmediatevalue(0)
        dut.input_adj_valid.setimmediatevalue(0)

        dut.input_drift_ns.setimmediatevalue(0)
        dut.input_drift_fns.setimmediatevalue(0)
        dut.input_drift_rate.setimmediatevalue(0)
        dut.input_drift_valid.setimmediatevalue(0)

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst <= 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)


@cocotb.test()
async def run_default_rate(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)
    start_time = get_sim_time('sec')
    start_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    start_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = get_sim_time('sec')
    stop_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    stop_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    time_delta = stop_time-start_time
    ts_96_delta = stop_ts_96-start_ts_96
    ts_64_delta = stop_ts_64-start_ts_64

    ts_96_diff = time_delta - ts_96_delta
    ts_64_diff = time_delta - ts_64_delta

    tb.log.info("sim time delta  : %g s", time_delta)
    tb.log.info("96 bit ts delta : %g s", ts_96_delta)
    tb.log.info("64 bit ts delta : %g s", ts_64_delta)
    tb.log.info("96 bit ts diff  : %g s", ts_96_diff)
    tb.log.info("64 bit ts diff  : %g s", ts_64_diff)

    assert abs(ts_96_diff) < 1e-12
    assert abs(ts_64_diff) < 1e-12

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_load_timestamps(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_ts_96 <= 12345678
    dut.input_ts_96_valid <= 1
    dut.input_ts_64 <= 12345678
    dut.input_ts_64_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_ts_96_valid <= 0
    dut.input_ts_64_valid <= 0

    await RisingEdge(dut.clk)

    assert dut.output_ts_96.value.integer == 12345678
    assert dut.output_ts_64.value.integer == 12345678
    assert dut.output_ts_step.value.integer == 1

    start_time = get_sim_time('sec')
    start_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    start_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    for k in range(2000):
        await RisingEdge(dut.clk)

    stop_time = get_sim_time('sec')
    stop_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    stop_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    time_delta = stop_time-start_time
    ts_96_delta = stop_ts_96-start_ts_96
    ts_64_delta = stop_ts_64-start_ts_64

    ts_96_diff = time_delta - ts_96_delta
    ts_64_diff = time_delta - ts_64_delta

    tb.log.info("sim time delta  : %g s", time_delta)
    tb.log.info("96 bit ts delta : %g s", ts_96_delta)
    tb.log.info("64 bit ts delta : %g s", ts_64_delta)
    tb.log.info("96 bit ts diff  : %g s", ts_96_diff)
    tb.log.info("64 bit ts diff  : %g s", ts_64_diff)

    assert abs(ts_96_diff) < 1e-12
    assert abs(ts_64_diff) < 1e-12

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_seconds_increment(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_ts_96 <= 999990000*2**16
    dut.input_ts_96_valid <= 1
    dut.input_ts_64 <= 999990000*2**16
    dut.input_ts_64_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_ts_96_valid <= 0
    dut.input_ts_64_valid <= 0

    await RisingEdge(dut.clk)

    start_time = get_sim_time('sec')
    start_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    start_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    saw_pps = False

    for k in range(3000):
        await RisingEdge(dut.clk)

        if dut.output_pps.value.integer:
            saw_pps = True
            assert dut.output_ts_96.value.integer >> 48 == 1
            assert dut.output_ts_96.value.integer & 0xffffffffffff < 10*2**16

    assert saw_pps

    stop_time = get_sim_time('sec')
    stop_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    stop_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    time_delta = stop_time-start_time
    ts_96_delta = stop_ts_96-start_ts_96
    ts_64_delta = stop_ts_64-start_ts_64

    ts_96_diff = time_delta - ts_96_delta
    ts_64_diff = time_delta - ts_64_delta

    tb.log.info("sim time delta  : %g s", time_delta)
    tb.log.info("96 bit ts delta : %g s", ts_96_delta)
    tb.log.info("64 bit ts delta : %g s", ts_64_delta)
    tb.log.info("96 bit ts diff  : %g s", ts_96_diff)
    tb.log.info("64 bit ts diff  : %g s", ts_64_diff)

    assert abs(ts_96_diff) < 1e-12
    assert abs(ts_64_diff) < 1e-12

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_frequency_adjustment(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_period_ns <= 0x6
    dut.input_period_fns <= 0x6624
    dut.input_period_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_period_valid <= 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = get_sim_time('sec')
    start_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    start_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = get_sim_time('sec')
    stop_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    stop_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    time_delta = stop_time-start_time
    ts_96_delta = stop_ts_96-start_ts_96
    ts_64_delta = stop_ts_64-start_ts_64

    ts_96_diff = time_delta - ts_96_delta * 6.4/(6+(0x6624+2/5)/2**16)
    ts_64_diff = time_delta - ts_64_delta * 6.4/(6+(0x6624+2/5)/2**16)

    tb.log.info("sim time delta  : %g s", time_delta)
    tb.log.info("96 bit ts delta : %g s", ts_96_delta)
    tb.log.info("64 bit ts delta : %g s", ts_64_delta)
    tb.log.info("96 bit ts diff  : %g s", ts_96_diff)
    tb.log.info("64 bit ts diff  : %g s", ts_64_diff)

    assert abs(ts_96_diff) < 1e-12
    assert abs(ts_64_diff) < 1e-12

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_drift_adjustment(dut):

    tb = TB(dut)

    await tb.reset()

    dut.input_drift_ns <= 0
    dut.input_drift_fns <= 20
    dut.input_drift_rate <= 5
    dut.input_drift_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_drift_valid <= 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = get_sim_time('sec')
    start_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    start_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = get_sim_time('sec')
    stop_ts_96 = (dut.output_ts_96.value.integer >> 48) + ((dut.output_ts_96.value.integer & 0xffffffffffff)/2**16*1e-9)
    stop_ts_64 = dut.output_ts_64.value.integer/2**16*1e-9

    time_delta = stop_time-start_time
    ts_96_delta = stop_ts_96-start_ts_96
    ts_64_delta = stop_ts_64-start_ts_64

    ts_96_diff = time_delta - ts_96_delta * 6.4/(6+(0x6666+20/5)/2**16)
    ts_64_diff = time_delta - ts_64_delta * 6.4/(6+(0x6666+20/5)/2**16)

    tb.log.info("sim time delta  : %g s", time_delta)
    tb.log.info("96 bit ts delta : %g s", ts_96_delta)
    tb.log.info("64 bit ts delta : %g s", ts_64_delta)
    tb.log.info("96 bit ts diff  : %g s", ts_96_diff)
    tb.log.info("64 bit ts diff  : %g s", ts_64_diff)

    assert abs(ts_96_diff) < 1e-12
    assert abs(ts_64_diff) < 1e-12

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_ptp_clock(request):
    dut = "ptp_clock"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['PERIOD_NS_WIDTH'] = 4
    parameters['OFFSET_NS_WIDTH'] = 4
    parameters['DRIFT_NS_WIDTH'] = 4
    parameters['FNS_WIDTH'] = 16
    parameters['PERIOD_NS'] = 0x6
    parameters['PERIOD_FNS'] = 0x6666
    parameters['DRIFT_ENABLE'] = 1
    parameters['DRIFT_NS'] = 0x0
    parameters['DRIFT_FNS'] = 0x0002
    parameters['DRIFT_RATE'] = 0x0005

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
