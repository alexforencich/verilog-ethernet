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

import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_sim_time

try:
    from ptp_td import PtpTdSink
except ImportError:
    # attempt import from current directory
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    try:
        from ptp_td import PtpTdSink
    finally:
        del sys.path[0]


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        self.ptp_td_sink = PtpTdSink(
            data=dut.ptp_td_sdo,
            clock=dut.clk,
            reset=dut.rst,
            period_ns=6.4
        )

        dut.input_ts_rel_ns.setimmediatevalue(0)
        dut.input_ts_rel_valid.setimmediatevalue(0)
        dut.input_ts_rel_offset_ns.setimmediatevalue(0)
        dut.input_ts_rel_offset_valid.setimmediatevalue(0)

        dut.input_ts_tod_s.setimmediatevalue(0)
        dut.input_ts_tod_ns.setimmediatevalue(0)
        dut.input_ts_tod_valid.setimmediatevalue(0)
        dut.input_ts_tod_offset_ns.setimmediatevalue(0)
        dut.input_ts_tod_offset_valid.setimmediatevalue(0)

        dut.input_ts_offset_fns.setimmediatevalue(0)
        dut.input_ts_offset_valid.setimmediatevalue(0)

        dut.input_period_ns.setimmediatevalue(0)
        dut.input_period_fns.setimmediatevalue(0)
        dut.input_period_valid.setimmediatevalue(0)
        dut.input_drift_num.setimmediatevalue(0)
        dut.input_drift_denom.setimmediatevalue(0)
        dut.input_drift_valid.setimmediatevalue(0)

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)


@cocotb.test()
async def run_default_rate(dut):

    tb = TB(dut)

    await tb.reset()

    for k in range(256*6):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta
    ts_rel_diff = time_delta - ts_rel_delta

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_load_timestamps(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_ts_tod_s.value = 12
    dut.input_ts_tod_ns.value = 123456789
    dut.input_ts_tod_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_tod_valid.value = 0

    dut.input_ts_rel_ns.value = 123456789
    dut.input_ts_rel_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_rel_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_rel_valid.value = 0

    for k in range(256*6):
        await RisingEdge(dut.clk)

    # assert tb.ptp_td_sink.get_ts_tod_s() - (12.123456789 + (256*6-(14*17+32)-2)*6.4e-9) < 6.4e-9
    # assert tb.ptp_td_sink.get_ts_rel_ns() - (123456789 + (256*6-(14*17+32)-1)*6.4) < 6.4

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta
    ts_rel_diff = time_delta - ts_rel_delta

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_offsets(dut):

    tb = TB(dut)

    await tb.reset()

    for k in range(256*6):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset FNS (positive)")

    await RisingEdge(dut.clk)

    dut.input_ts_offset_fns.value = 0x78000000 & 0xffffffff
    dut.input_ts_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_offset_valid.value = 0

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset FNS (negative)")

    await RisingEdge(dut.clk)

    dut.input_ts_offset_fns.value = -0x70000000 & 0xffffffff
    dut.input_ts_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_offset_valid.value = 0

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset relative TS (positive)")

    dut.input_ts_rel_offset_ns.value = 30000 & 0xffffffff
    dut.input_ts_rel_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_rel_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_rel_offset_valid.value = 0

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset relative TS (negative)")

    dut.input_ts_rel_offset_ns.value = -10000 & 0xffffffff
    dut.input_ts_rel_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_rel_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_rel_offset_valid.value = 0

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset ToD TS (positive)")

    dut.input_ts_tod_offset_ns.value = 510000000 & 0x3fffffff
    dut.input_ts_tod_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_offset_ready.value:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_tod_offset_valid.value = 0

    for k in range(2000):
        await RisingEdge(dut.clk)

    tb.log.info("Offset ToD TS (negative)")

    dut.input_ts_tod_offset_ns.value = -500000000 & 0x3fffffff
    dut.input_ts_tod_offset_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_offset_ready.value:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_offset_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_tod_offset_valid.value = 0

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta + Decimal(0.03125) + Decimal(20000000)
    ts_rel_diff = time_delta - ts_rel_delta + Decimal(0.03125) + Decimal(20000)

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_seconds_increment(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_ts_tod_s.value = 0
    dut.input_ts_tod_ns.value = 999990000
    dut.input_ts_tod_valid.value = 1

    await RisingEdge(dut.clk)
    while not dut.input_ts_tod_ready.value:
        await RisingEdge(dut.clk)

    dut.input_ts_tod_valid.value = 0

    for k in range(256*6):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    saw_pps = False

    for k in range(3000):
        await RisingEdge(dut.clk)

        if dut.output_pps.value.integer:
            saw_pps = True
            tb.log.info("Got PPS with sink ToD TS %s", tb.ptp_td_sink.get_ts_tod_ns())
            assert (tb.ptp_td_sink.get_ts_tod_s() - 1) < 6.4e-9

    assert saw_pps

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta
    ts_rel_diff = time_delta - ts_rel_delta

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_frequency_adjustment(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.clk)

    dut.input_period_ns.value = 0x6
    dut.input_period_fns.value = 0x66240000
    dut.input_period_valid.value = 1

    await RisingEdge(dut.clk)

    dut.input_period_valid.value = 0

    for k in range(256*6):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta * Decimal(6.4/(6+(0x66240000+2/5)/2**32))
    ts_rel_diff = time_delta - ts_rel_delta * Decimal(6.4/(6+(0x66240000+2/5)/2**32))

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


@cocotb.test()
async def run_drift_adjustment(dut):

    tb = TB(dut)

    await tb.reset()

    dut.input_drift_num.value = 20000
    dut.input_drift_denom.value = 5
    dut.input_drift_valid.value = 1

    await RisingEdge(dut.clk)

    dut.input_drift_valid.value = 0

    for k in range(256*6):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    start_time = Decimal(get_sim_time('fs')).scaleb(-6)
    start_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    start_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    for k in range(10000):
        await RisingEdge(dut.clk)

    stop_time = Decimal(get_sim_time('fs')).scaleb(-6)
    stop_ts_tod = tb.ptp_td_sink.get_ts_tod_ns()
    stop_ts_rel = tb.ptp_td_sink.get_ts_rel_ns()

    time_delta = stop_time-start_time
    ts_tod_delta = stop_ts_tod-start_ts_tod
    ts_rel_delta = stop_ts_rel-start_ts_rel

    tb.log.info("sim time delta : %s ns", time_delta)
    tb.log.info("ToD ts delta   : %s ns", ts_tod_delta)
    tb.log.info("Rel ts delta   : %s ns", ts_rel_delta)

    ts_tod_diff = time_delta - ts_tod_delta * Decimal(6.4/(6+(0x66666666+20000/5)/2**32))
    ts_rel_diff = time_delta - ts_rel_delta * Decimal(6.4/(6+(0x66666666+20000/5)/2**32))

    tb.log.info("ToD ts diff    : %s ns", ts_tod_diff)
    tb.log.info("Rel ts diff    : %s ns", ts_rel_diff)

    assert abs(ts_tod_diff) < 1e-3
    assert abs(ts_rel_diff) < 1e-3

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_ptp_td_phc(request):
    dut = "ptp_td_phc"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['PERIOD_NS_NUM'] = 32
    parameters['PERIOD_NS_DENOM'] = 5

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
