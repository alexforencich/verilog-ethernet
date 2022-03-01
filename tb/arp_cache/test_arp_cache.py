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
from cocotb.regression import TestFactory

from cocotbext.axi.stream import define_stream


CacheOpBus, CacheOpTransaction, CacheOpSource, CacheOpSink, CacheOpMonitor = define_stream("CacheOp",
    signals=["valid", "ready"],
    optional_signals=["ip", "mac", "error"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.query_request_source = CacheOpSource(CacheOpBus.from_prefix(dut, "query_request"), dut.clk, dut.rst)
        self.query_response_sink = CacheOpSink(CacheOpBus.from_prefix(dut, "query_response"), dut.clk, dut.rst)

        self.write_request_source = CacheOpSource(CacheOpBus.from_prefix(dut, "write_request"), dut.clk, dut.rst)

        dut.clear_cache.setimmediatevalue(0)

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


async def run_test(dut):

    tb = TB(dut)

    await tb.reset()

    await RisingEdge(dut.write_request_ready)

    tb.log.info("Test write")

    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80111, mac=0x0000c0a80111))
    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80112, mac=0x0000c0a80112))

    await tb.write_request_source.wait()

    tb.log.info("Test read")

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80111))
    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80112))
    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80113))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80111
    assert not resp.error

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80112
    assert not resp.error

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.error

    tb.log.info("Test write pt. 2")

    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80121, mac=0x0000c0a80121))
    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80122, mac=0x0000c0a80122))
    # overwrites 0xc0a80112
    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80123, mac=0x0000c0a80123))

    await tb.write_request_source.wait()

    tb.log.info("Test read pt. 2")

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80111))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80111
    assert not resp.error

    # not in cache; was overwritten
    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80112))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80121))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80121
    assert not resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80122))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80122
    assert not resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80123))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80123
    assert not resp.error

    tb.log.info("Test overwrite")

    await tb.write_request_source.send(CacheOpTransaction(ip=0xc0a80123, mac=0x0000c0a80164))

    await tb.write_request_source.wait()

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80111))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80111
    assert not resp.error

    # not in cache; was overwritten
    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80112))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80121))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80121
    assert not resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80122))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80122
    assert not resp.error

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80123))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.mac == 0x0000c0a80164
    assert not resp.error

    tb.log.info("Clear cache")

    await RisingEdge(dut.clk)
    dut.clear_cache <= 1
    await RisingEdge(dut.clk)
    dut.clear_cache <= 0

    await tb.query_request_source.send(CacheOpTransaction(ip=0xc0a80111))

    resp = await tb.query_response_sink.recv()
    tb.log.info(f"Response: {resp}")
    assert resp.error

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


if cocotb.SIM_NAME:

    factory = TestFactory(run_test)
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_arp_cache(request):
    dut = "arp_cache"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['CACHE_ADDR_WIDTH'] = 2

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
