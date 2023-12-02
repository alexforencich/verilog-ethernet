#!/usr/bin/env python
"""

Copyright (c) 2023 Alex Forencich

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
import sys
from decimal import Decimal
from statistics import mean, stdev

import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.utils import get_sim_steps, get_sim_time

try:
    from ptp_td import PtpTdSource
except ImportError:
    # attempt import from current directory
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    try:
        from ptp_td import PtpTdSource
    finally:
        del sys.path[0]


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.sample_clk, 9.9, units="ns").start())

        self.ptp_td_source = PtpTdSource(
            data=dut.ptp_td_sdi,
            clock=dut.ptp_clk,
            reset=dut.ptp_rst,
            period_ns=6.4
        )

        self.ptp_clock_period = 6.4
        dut.ptp_clk.setimmediatevalue(0)
        cocotb.start_soon(self._run_ptp_clock())

        self.clock_period = 6.4
        dut.clk.setimmediatevalue(0)
        cocotb.start_soon(self._run_clock())

        self.ref_ts_rel = []
        self.ref_ts_tod = []
        self.output_ts_rel = []
        self.output_ts_tod = []

        cocotb.start_soon(self._run_collect_ref_ts())
        cocotb.start_soon(self._run_collect_output_ts())

    async def reset(self):
        self.dut.ptp_rst.setimmediatevalue(0)
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.ptp_clk)
        await RisingEdge(self.dut.ptp_clk)
        self.dut.ptp_rst.value = 1
        self.dut.rst.value = 1
        for k in range(10):
            await RisingEdge(self.dut.ptp_clk)
        self.dut.ptp_rst.value = 0
        self.dut.rst.value = 0
        for k in range(10):
            await RisingEdge(self.dut.ptp_clk)

    def set_ptp_clock_period(self, period):
        self.ptp_clock_period = period

    async def _run_ptp_clock(self):
        period = None
        steps_per_ns = get_sim_steps(1.0, 'ns')

        while True:
            if period != self.ptp_clock_period:
                period = self.ptp_clock_period
                t = Timer(int(steps_per_ns * period / 2.0))
            await t
            self.dut.ptp_clk.value = 1
            await t
            self.dut.ptp_clk.value = 0

    def set_clock_period(self, period):
        self.clock_period = period

    def get_output_ts_tod_ns(self):
        ts = self.dut.output_ts_tod.value.integer
        return Decimal(ts >> 48).scaleb(9) + (Decimal(ts & 0xffffffffffff) / Decimal(2**16))

    def get_output_ts_rel_ns(self):
        ts = self.dut.output_ts_rel.value.integer
        return Decimal(ts) / Decimal(2**16)

    async def _run_clock(self):
        period = None
        steps_per_ns = get_sim_steps(1.0, 'ns')

        while True:
            if period != self.clock_period:
                period = self.clock_period
                t = Timer(int(steps_per_ns * period / 2.0))
            await t
            self.dut.clk.value = 1
            await t
            self.dut.clk.value = 0

    async def _run_collect_ref_ts(self):
        clk_event = RisingEdge(self.dut.ptp_clk)
        while True:
            await clk_event
            st = Decimal(get_sim_time('fs')).scaleb(-6)
            self.ref_ts_rel.append((st, self.ptp_td_source.get_ts_rel_ns()))
            self.ref_ts_tod.append((st, self.ptp_td_source.get_ts_tod_ns()))

    async def _run_collect_output_ts(self):
        clk_event = RisingEdge(self.dut.clk)
        while True:
            await clk_event
            st = Decimal(get_sim_time('fs')).scaleb(-6)
            self.output_ts_rel.append((st, self.get_output_ts_rel_ns()))
            self.output_ts_tod.append((st, self.get_output_ts_tod_ns()))

    def compute_ts_diff(self, ts_lst_1, ts_lst_2):
        ts_lst_1 = [x for x in ts_lst_1]

        diffs = []

        its1 = ts_lst_1.pop(0)
        its2 = ts_lst_1.pop(0)

        for ots in ts_lst_2:
            while its2[0] < ots[0] and ts_lst_1:
                its1 = its2
                its2 = ts_lst_1.pop(0)

            if its2[0] < ots[0]:
                break

            dt = its2[0] - its1[0]
            dts = its2[1] - its1[1]

            its = its1[1]+dts/dt*(ots[0]-its1[0])

            # diffs.append(ots[1] - its)
            diffs.append(float(ots[1] - its))

        return diffs

    async def measure_ts_diff(self, N=100):
        self.ref_ts_rel = []
        self.ref_ts_tod = []
        self.output_ts_rel = []
        self.output_ts_tod = []

        for k in range(N):
            await RisingEdge(self.dut.clk)

        rel_diffs = self.compute_ts_diff(self.ref_ts_rel, self.output_ts_rel)
        tod_diffs = self.compute_ts_diff(self.ref_ts_tod, self.output_ts_tod)

        return rel_diffs, tod_diffs


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    # set small offset between timestamps
    tb.ptp_td_source.set_ts_rel_ns(0)
    tb.ptp_td_source.set_ts_tod_ns(10000)

    await RisingEdge(dut.clk)
    tb.log.info("Same clock speed")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("10 ppm slower")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4*(1+.00001))

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("10 ppm faster")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4*(1-.00001))

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("200 ppm slower")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4*(1+.0002))

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("200 ppm faster")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4*(1-.0002))

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Coherent tracking (+/- 10 ppm)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4)

    await RisingEdge(dut.clk)

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

        tb.set_clock_period(period)

        for i in range(200):
            await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Coherent tracking (+/- 200 ppm)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.4)

    await RisingEdge(dut.clk)

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

        tb.set_clock_period(period)

        for i in range(20):
            await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Slightly faster (6.3 ns)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.3)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Slightly slower (6.5 ns)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(6.5)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Significantly faster (250 MHz)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(4.0)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Coherent tracking (250 MHz +0/-0.5%)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(4.0)

    await RisingEdge(dut.clk)

    period = 4.000
    step = 0.0002
    period_min = 4.0
    period_max = 4.0*(1+0.005)

    for i in range(5000):
        period += step

        if period <= period_min:
            step = abs(step)
        if period >= period_max:
            step = -abs(step)

        tb.set_clock_period(period)

        for i in range(20):
            await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Significantly slower (100 MHz)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(10.0)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    tb.log.info("Significantly faster (390.625 MHz)")

    tb.set_ptp_clock_period(6.4)
    tb.set_clock_period(2.56)

    await RisingEdge(dut.clk)

    for i in range(100000):
        await RisingEdge(dut.clk)

    assert tb.dut.locked.value.integer

    rel_diffs, tod_diffs = await tb.measure_ts_diff()
    tb.log.info(f"Difference (rel): {mean(rel_diffs)} ns (stdev: {stdev(rel_diffs)})")
    tb.log.info(f"Difference (ToD): {mean(tod_diffs)} ns (stdev: {stdev(tod_diffs)})")
    assert abs(mean(rel_diffs)) < 5
    assert abs(mean(tod_diffs)) < 5

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_ptp_td_leaf(request):
    dut = "ptp_td_leaf"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['TS_REL_EN'] = 1
    parameters['TS_TOD_EN'] = 1
    parameters['TS_FNS_W'] = 16
    parameters['TS_REL_NS_W'] = 48
    parameters['TS_TOD_S_W'] = 48
    parameters['TS_REL_W'] = parameters['TS_REL_NS_W'] + parameters['TS_FNS_W']
    parameters['TS_TOD_W'] = parameters['TS_TOD_S_W'] + 32 + parameters['TS_FNS_W']
    parameters['TD_SDI_PIPELINE'] = 2

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
