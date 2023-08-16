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
import random

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink


class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)

        dut.pause_req.setimmediatevalue(0)

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

    id_count = 2**len(tb.source.bus.tid)

    cur_id = 1

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = []

    for test_data in [payload_data(x) for x in payload_lengths()]:
        test_frame = AxiStreamFrame(test_data)
        test_frame.tid = cur_id
        test_frame.tdest = cur_id

        test_frames.append(test_frame)
        await tb.source.send(test_frame)

        cur_id = (cur_id + 1) % id_count

    for test_frame in test_frames:
        rx_frame = await tb.sink.recv()

        assert rx_frame.tdata == test_frame.tdata
        assert rx_frame.tid == test_frame.tid
        assert rx_frame.tdest == test_frame.tdest
        assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_tuser_assert(dut):

    tb = TB(dut)

    await tb.reset()

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data, tuser=1)
    await tb.source.send(test_frame)

    if dut.DROP_BAD_FRAME.value:
        for k in range(64):
            await RisingEdge(dut.clk)

    else:
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


async def run_test_pause(dut):

    tb = TB(dut)

    byte_lanes = max(tb.source.byte_lanes, tb.sink.byte_lanes)

    await tb.reset()

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 16*byte_lanes))
    test_frame = AxiStreamFrame(test_data)

    for k in range(16):
        await tb.source.send(test_frame)

    for k in range(60):
        await RisingEdge(dut.clk)

    dut.pause_req.value = 1

    for k in range(64):
        await RisingEdge(dut.clk)

    assert tb.sink.idle()

    dut.pause_req.value = 0

    for k in range(16):
        rx_frame = await tb.sink.recv()

        assert rx_frame.tdata == test_data
        assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_overflow(dut):

    tb = TB(dut)

    depth = dut.DEPTH.value
    byte_lanes = min(tb.source.byte_lanes, tb.sink.byte_lanes)

    await tb.reset()

    tb.sink.pause = True

    size = (16*byte_lanes)
    count = depth*2 // size

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), size))
    test_frame = AxiStreamFrame(test_data)
    for k in range(count):
        await tb.source.send(test_frame)

    for k in range((depth//byte_lanes)*3):
        await RisingEdge(dut.clk)

    if dut.DROP_WHEN_FULL.value or dut.MARK_WHEN_FULL.value:
        assert tb.source.idle()
    else:
        assert not tb.source.idle()

    tb.sink.pause = False

    if dut.DROP_WHEN_FULL.value or dut.MARK_WHEN_FULL.value:
        for k in range((depth//byte_lanes)*3):
            await RisingEdge(dut.clk)

        rx_count = 0

        while not tb.sink.empty():
            rx_frame = await tb.sink.recv()

            if dut.MARK_WHEN_FULL.value and rx_frame.tuser:
                continue

            assert rx_frame.tdata == test_data
            assert not rx_frame.tuser

            rx_count += 1

        assert rx_count < count

    else:
        for k in range(count):
            rx_frame = await tb.sink.recv()

            assert rx_frame.tdata == test_data
            assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_oversize(dut):

    tb = TB(dut)

    depth = dut.DEPTH.value
    byte_lanes = min(tb.source.byte_lanes, tb.sink.byte_lanes)

    await tb.reset()

    tb.sink.pause = True

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), depth*2))
    test_frame = AxiStreamFrame(test_data)
    await tb.source.send(test_frame)

    for k in range((depth//byte_lanes)*2):
        await RisingEdge(dut.clk)

    tb.sink.pause = False

    if dut.DROP_OVERSIZE_FRAME.value:
        for k in range((depth//byte_lanes)*2):
            await RisingEdge(dut.clk)

    else:
        rx_frame = await tb.sink.recv()

        if dut.MARK_WHEN_FULL.value:
            assert rx_frame.tuser
        else:
            assert rx_frame.tdata == test_data
            assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_stress_test(dut, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    byte_lanes = max(tb.source.byte_lanes, tb.sink.byte_lanes)
    id_count = 2**len(tb.source.bus.tid)

    cur_id = 1

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = []

    for k in range(512):
        length = random.randint(1, byte_lanes*16)
        test_data = bytearray(itertools.islice(itertools.cycle(range(256)), length))
        test_frame = AxiStreamFrame(test_data)
        test_frame.tid = cur_id
        test_frame.tdest = cur_id

        test_frames.append(test_frame)
        await tb.source.send(test_frame)

        cur_id = (cur_id + 1) % id_count

    if dut.DROP_WHEN_FULL.value or dut.MARK_WHEN_FULL.value:
        cycles = 0
        while cycles < 100:
            cycles += 1
            if not tb.source.idle() or dut.s_axis_tvalid.value.integer or dut.m_axis_tvalid.value.integer or dut.status_depth.value.integer:
                cycles = 0
            await RisingEdge(dut.clk)

        while not tb.sink.empty():
            rx_frame = await tb.sink.recv()

            if dut.MARK_WHEN_FULL.value and rx_frame.tuser:
                continue

            assert not rx_frame.tuser

            while True:
                test_frame = test_frames.pop(0)
                if rx_frame.tid == test_frame.tid and rx_frame.tdest == test_frame.tdest and rx_frame.tdata == test_frame.tdata:
                    break

        assert len(test_frames) < 512

    else:
        for test_frame in test_frames:
            rx_frame = await tb.sink.recv()

            assert rx_frame.tdata == test_frame.tdata
            assert rx_frame.tid == test_frame.tid
            assert rx_frame.tdest == test_frame.tdest
            assert not rx_frame.tuser

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


def size_list():
    data_width = max(len(cocotb.top.m_axis_tdata), len(cocotb.top.s_axis_tdata))
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
                run_test_pause,
                run_test_overflow,
                run_test_oversize
            ]:

        factory = TestFactory(test)
        factory.generate_tests()

    factory = TestFactory(run_stress_test)
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))


@pytest.mark.parametrize(("frame_fifo", "drop_oversize_frame", "drop_bad_frame",
    "drop_when_full", "mark_when_full"),
    [(0, 0, 0, 0, 0), (1, 0, 0, 0, 0), (1, 1, 0, 0, 0), (1, 1, 1, 0, 0),
        (1, 1, 1, 1, 0), (0, 0, 0, 0, 1)])
@pytest.mark.parametrize("m_data_width", [8, 16, 32])
@pytest.mark.parametrize("s_data_width", [8, 16, 32])
def test_axis_fifo_adapter(request, s_data_width, m_data_width,
        frame_fifo, drop_oversize_frame, drop_bad_frame,
        drop_when_full, mark_when_full):
    dut = "axis_fifo_adapter"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "axis_fifo.v"),
        os.path.join(rtl_dir, "axis_adapter.v"),
    ]

    parameters = {}

    parameters['S_DATA_WIDTH'] = s_data_width
    parameters['S_KEEP_ENABLE'] = int(parameters['S_DATA_WIDTH'] > 8)
    parameters['S_KEEP_WIDTH'] = (parameters['S_DATA_WIDTH'] + 7) // 8
    parameters['M_DATA_WIDTH'] = m_data_width
    parameters['M_KEEP_ENABLE'] = int(parameters['M_DATA_WIDTH'] > 8)
    parameters['M_KEEP_WIDTH'] = (parameters['M_DATA_WIDTH'] + 7) // 8
    parameters['DEPTH'] = 1024 * max(parameters['S_KEEP_WIDTH'], parameters['M_KEEP_WIDTH'])
    parameters['ID_ENABLE'] = 1
    parameters['ID_WIDTH'] = 8
    parameters['DEST_ENABLE'] = 1
    parameters['DEST_WIDTH'] = 8
    parameters['USER_ENABLE'] = 1
    parameters['USER_WIDTH'] = 1
    parameters['RAM_PIPELINE'] = 1
    parameters['OUTPUT_FIFO_ENABLE'] = 0
    parameters['FRAME_FIFO'] = frame_fifo
    parameters['USER_BAD_FRAME_VALUE'] = 1
    parameters['USER_BAD_FRAME_MASK'] = 1
    parameters['DROP_OVERSIZE_FRAME'] = drop_oversize_frame
    parameters['DROP_BAD_FRAME'] = drop_bad_frame
    parameters['DROP_WHEN_FULL'] = drop_when_full
    parameters['MARK_WHEN_FULL'] = mark_when_full
    parameters['PAUSE_ENABLE'] = 1
    parameters['FRAME_PAUSE'] = 1

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
