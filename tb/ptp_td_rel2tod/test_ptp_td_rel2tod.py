#!/usr/bin/env python
"""

Copyright (c) 2024 Alex Forencich

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

from cocotbext.axi.stream import define_stream

try:
    from ptp_td import PtpTdSource
except ImportError:
    # attempt import from current directory
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    try:
        from ptp_td import PtpTdSource
    finally:
        del sys.path[0]


TsBus, TsTransaction, TsSource, TsSink, TsMonitor = define_stream("Ts",
    signals=["valid"],
    optional_signals=["rel", "tod", "tag"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.ptp_clk, 6.4, units="ns").start())
        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        self.ptp_td_source = PtpTdSource(
            data=dut.ptp_td_sdi,
            clock=dut.ptp_clk,
            reset=dut.ptp_rst,
            period_ns=6.4
        )

        self.ts_source = TsSource(TsBus(dut, "input_ts"), dut.clk, dut.rst)
        self.ts_sink = TsSink(TsBus(dut, "output_ts"), dut.clk, dut.rst)

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


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    for start_rel, start_tod in [('1234', '123456789.987654321'),
            ('1234', '123456788.987654321'),
            ('1234.9', '123456789.987654321'),
            ('1234.9', '123456788.987654321'),
            ('1234', '123456789.907654321'),
            ('1234', '123456788.907654321'),
            ('1234.9', '123456789.907654321'),
            ('1234.9', '123456788.907654321')]:

        tb.log.info(f"Start rel ts: {start_rel} ns")
        tb.log.info(f"Start ToD ts: {start_tod} ns")

        tb.ptp_td_source.set_ts_rel_s(start_rel)
        tb.ptp_td_source.set_ts_tod_s(start_tod)

        for k in range(256*6):
            await RisingEdge(dut.clk)

        for offset in ['0', '0.05', '-0.9']:

            tb.log.info(f"Offset {offset} sec")
            ts_rel = tb.ptp_td_source.get_ts_rel_ns()
            ts_tod = tb.ptp_td_source.get_ts_tod_ns()

            tb.log.info(f"Current rel ts: {ts_rel} ns")
            tb.log.info(f"Current ToD ts: {ts_tod} ns")

            ts_rel += Decimal(offset).scaleb(9)
            ts_tod += Decimal(offset).scaleb(9)
            rel = int(ts_rel*2**16) & 0xffffffffffff

            tb.log.info(f"Input rel ts: {ts_rel} ns")
            tb.log.info(f"Input ToD ts: {ts_tod} ns")
            tb.log.info(f"Input relative ts raw: {rel} ({rel:#x})")

            await tb.ts_source.send(TsTransaction(rel=rel))
            out_ts = await tb.ts_sink.recv()

            tod = out_ts.tod.integer
            tb.log.info(f"Output ToD ts raw: {tod} ({tod:#x})")
            ns = Decimal(tod & 0xffff) / Decimal(2**16)
            ns = tb.ptp_td_source.ctx.add(ns, Decimal((tod >> 16) & 0xffffffff))
            tod = tb.ptp_td_source.ctx.add(ns, Decimal(tod >> 48).scaleb(9))
            tb.log.info(f"Output ToD ts: {tod} ns")

            tb.log.info(f"Output ns portion only: {ns} ns")

            diff = tod - ts_tod
            tb.log.info(f"Difference: {diff} ns")

            assert abs(diff) < 1e-3
            assert ns < 1000000000

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_ptp_td_rel2tod(request):
    dut = "ptp_td_rel2tod"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['TS_FNS_W'] = 16
    parameters['TS_REL_NS_W'] = 32
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
