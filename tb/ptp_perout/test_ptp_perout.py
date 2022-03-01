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
from cocotb.triggers import RisingEdge, Timer

from cocotbext.eth import PtpClock


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        self.ptp_clock = PtpClock(
            ts_96=dut.input_ts_96,
            ts_step=dut.input_ts_step,
            clock=dut.clk,
            reset=dut.rst,
            period_ns=6.4
        )

        dut.enable.setimmediatevalue(0)
        dut.input_start.setimmediatevalue(0)
        dut.input_start_valid.setimmediatevalue(0)
        dut.input_period.setimmediatevalue(0)
        dut.input_period_valid.setimmediatevalue(0)
        dut.input_width.setimmediatevalue(0)
        dut.input_width_valid.setimmediatevalue(0)

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
async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    dut.enable <= 1

    await RisingEdge(dut.clk)

    dut.input_start <= 100 << 16
    dut.input_start_valid <= 1
    dut.input_period <= 100 << 16
    dut.input_period_valid <= 1
    dut.input_width <= 50 << 16
    dut.input_width_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_start_valid <= 0
    dut.input_period_valid <= 0
    dut.input_width_valid <= 0

    await Timer(10000, 'ns')

    await RisingEdge(dut.clk)

    dut.input_start <= 0 << 16
    dut.input_start_valid <= 1
    dut.input_period <= 100 << 16
    dut.input_period_valid <= 1
    dut.input_width <= 50 << 16
    dut.input_width_valid <= 1

    await RisingEdge(dut.clk)

    dut.input_start_valid <= 0
    dut.input_period_valid <= 0
    dut.input_width_valid <= 0

    await Timer(10000, 'ns')

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_ptp_perout(request):
    dut = "ptp_perout"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['FNS_ENABLE'] = 1
    parameters['OUT_START_S'] = 0
    parameters['OUT_START_NS'] = 0
    parameters['OUT_START_FNS'] = 0x0000
    parameters['OUT_PERIOD_S'] = 1
    parameters['OUT_PERIOD_NS'] = 0
    parameters['OUT_PERIOD_FNS'] = 0x0000
    parameters['OUT_WIDTH_S'] = 0
    parameters['OUT_WIDTH_NS'] = 1000
    parameters['OUT_WIDTH_FNS'] = 0x0000

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
