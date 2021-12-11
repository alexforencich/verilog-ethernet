#!/usr/bin/env python
"""

Copyright (c) 2021 Alex Forencich

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

import itertools
import logging
import os

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink
from cocotbext.axi.stream import define_stream

StatusBus, StatusTransaction, StatusSource, StatusSink, StatusMonitor = define_stream("Status",
    signals=["frame_pad", "frame_truncate", "frame_length", "frame_original_length", "valid"],
    optional_signals=["ready"]
)


class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)

        # Status
        self.status_sink = StatusSink(StatusBus.from_prefix(dut, "status"), dut.clk, dut.rst)

        self.dut.length_min.setimmediatevalue(0)
        self.dut.length_max.setimmediatevalue(2048)

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

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


async def run_test(dut, payload_lengths=None, payload_data=None, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    data_width = len(tb.source.bus.tkeep)
    byte_width = data_width // 8
    id_count = 2**len(tb.source.bus.tid)

    cur_id = 1

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    for length_max in range(1, 4):
        for length_min in range(0, length_max+1):
            tb.log.info("length_min %d, length_max %d", length_min, length_max)

            await RisingEdge(dut.clk)
            tb.dut.length_min.value = length_min
            tb.dut.length_max.value = length_max
            await RisingEdge(dut.clk)

            test_frames = []

            for test_data in [payload_data(x) for x in payload_lengths()]:
                test_frame = AxiStreamFrame(test_data, tid=cur_id, tdest=cur_id)

                test_frames.append(test_frame)
                await tb.source.send(test_frame)

                cur_id = (cur_id + 1) % id_count

            for test_frame in test_frames:
                rx_frame = await tb.sink.recv()

                len_rx = len(rx_frame.tdata)
                len_test = len(test_frame.tdata)
                len_min = min(len_rx, len_test)

                assert len_rx >= length_min
                assert len_rx <= length_max
                assert rx_frame.tdata[:len_min] == test_frame.tdata[:len_min]
                assert rx_frame.tid == test_frame.tid
                assert rx_frame.tdest == test_frame.tdest
                assert not rx_frame.tuser

                status = await tb.status_sink.recv()

                tb.log.info("Status: %s", status)

                assert status.frame_pad == int(len_test < length_min)
                assert status.frame_truncate == int(len_test > length_max)
                assert status.frame_length == len_rx
                assert status.frame_original_length == len_test

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_tuser_assert(dut):

    tb = TB(dut)

    await tb.reset()

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data, tuser=1)
    await tb.source.send(test_frame)

    rx_frame = await tb.sink.recv()

    assert rx_frame.tdata == test_data
    assert rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_init_sink_pause(dut):

    tb = TB(dut)

    await tb.reset()

    tb.sink.pause = True

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data)
    await tb.source.send(test_frame)

    for k in range(64):
        await RisingEdge(dut.clk)

    tb.sink.pause = False

    rx_frame = await tb.sink.recv()

    assert rx_frame.tdata == test_data
    assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_init_sink_pause_reset(dut):

    tb = TB(dut)

    await tb.reset()

    tb.sink.pause = True

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data)
    await tb.source.send(test_frame)

    for k in range(64):
        await RisingEdge(dut.clk)

    await tb.reset()

    tb.sink.pause = False

    for k in range(64):
        await RisingEdge(dut.clk)

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_overflow(dut):

    tb = TB(dut)

    await tb.reset()

    tb.sink.pause = True

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 2048))
    test_frame = AxiStreamFrame(test_data)
    await tb.source.send(test_frame)

    for k in range(2048):
        await RisingEdge(dut.clk)

    tb.sink.pause = False

    rx_frame = await tb.sink.recv()

    assert rx_frame.tdata == test_data
    assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


def size_list():
    data_width = len(cocotb.top.m_axis_tdata)
    byte_width = data_width // 8
    return list(range(1, byte_width*4+1))+[512]+[1]*64


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


if cocotb.SIM_NAME:

    factory = TestFactory(run_test)
    factory.add_option("payload_lengths", [size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()

    for test in [
                run_test_tuser_assert,
                run_test_init_sink_pause,
                run_test_init_sink_pause_reset,
                run_test_overflow
            ]:

        factory = TestFactory(test)
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))


@pytest.mark.parametrize("data_width", [8, 16, 32])
def test_axis_frame_length_adjust_fifo(request, data_width):
    dut = "axis_frame_length_adjust_fifo"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, f"axis_frame_length_adjust.v"),
        os.path.join(rtl_dir, f"axis_fifo.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['ID_ENABLE'] = 1
    parameters['ID_WIDTH'] = 8
    parameters['DEST_ENABLE'] = 1
    parameters['DEST_WIDTH'] = 8
    parameters['USER_ENABLE'] = 1
    parameters['USER_WIDTH'] = 1
    parameters['LEN_WIDTH'] = 16
    parameters['FRAME_FIFO_DEPTH'] = 1024
    parameters['HEADER_FIFO_DEPTH'] = 8

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
