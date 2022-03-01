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
import subprocess

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Event
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink


class TB(object):
    def __init__(self, dut):
        self.dut = dut

        s_count = len(dut.axis_switch_inst.s_axis_tvalid)
        m_count = len(dut.axis_switch_inst.m_axis_tvalid)

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.source = [AxiStreamSource(AxiStreamBus.from_prefix(dut, f"s{k:02d}_axis"), dut.clk, dut.rst) for k in range(s_count)]
        self.sink = [AxiStreamSink(AxiStreamBus.from_prefix(dut, f"m{k:02d}_axis"), dut.clk, dut.rst) for k in range(m_count)]

    def set_idle_generator(self, generator=None):
        if generator:
            for source in self.source:
                source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            for sink in self.sink:
                sink.set_pause_generator(generator())

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


async def run_test(dut, payload_lengths=None, payload_data=None, idle_inserter=None, backpressure_inserter=None, s=0, m=0):

    tb = TB(dut)

    id_width = len(tb.source[0].bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = (len(tb.source)-1).bit_length()
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = []

    for test_data in [payload_data(x) for x in payload_lengths()]:
        test_frame = AxiStreamFrame(test_data)
        test_frame.tid = cur_id | (s << src_shift)
        test_frame.tdest = m

        test_frames.append(test_frame)
        await tb.source[s].send(test_frame)

        cur_id = (cur_id + 1) % max_count

    for test_frame in test_frames:
        rx_frame = await tb.sink[m].recv()

        assert rx_frame.tdata == test_frame.tdata
        assert (rx_frame.tid & id_mask) == test_frame.tid
        assert ((rx_frame.tid >> src_shift) & src_mask) == s
        assert (rx_frame.tid >> id_width) == s
        assert rx_frame.tdest == test_frame.tdest
        assert not rx_frame.tuser

    assert all(s.empty() for s in tb.sink)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_tuser_assert(dut, s=0, m=0):

    tb = TB(dut)

    await tb.reset()

    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), 32))
    test_frame = AxiStreamFrame(test_data, tuser=1, tdest=m)
    await tb.source[s].send(test_frame)

    rx_frame = await tb.sink[m].recv()

    assert rx_frame.tdata == test_data
    assert rx_frame.tuser

    assert all(s.empty() for s in tb.sink)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_arb_test(dut):

    tb = TB(dut)

    byte_lanes = tb.source[0].byte_lanes
    id_width = len(tb.source[0].bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = (len(tb.source)-1).bit_length()
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    test_frames = []

    length = byte_lanes*16
    test_data = bytearray(itertools.islice(itertools.cycle(range(256)), length))

    for k in range(5):
        test_frame = AxiStreamFrame(test_data, tx_complete=Event())

        src_ind = 0

        if k == 0:
            src_ind = 0
        elif k == 4:
            await test_frames[1].tx_complete.wait()
            for j in range(8):
                await RisingEdge(dut.clk)
            src_ind = 0
        else:
            src_ind = 1

        test_frame.tid = cur_id | (src_ind << src_shift)
        test_frame.tdest = 0

        test_frames.append(test_frame)
        await tb.source[src_ind].send(test_frame)

        cur_id = (cur_id + 1) % max_count

    for k in [0, 1, 2, 4, 3]:
        test_frame = test_frames[k]
        rx_frame = await tb.sink[0].recv()

        assert rx_frame.tdata == test_frame.tdata
        assert (rx_frame.tid & id_mask) == test_frame.tid
        assert ((rx_frame.tid >> src_shift) & src_mask) == (rx_frame.tid >> id_width)
        assert rx_frame.tdest == test_frame.tdest
        assert not rx_frame.tuser

    assert all(s.empty() for s in tb.sink)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_stress_test(dut, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    byte_lanes = tb.source[0].byte_lanes
    id_width = len(tb.source[0].bus.tid)
    id_count = 2**id_width
    id_mask = id_count-1

    src_width = (len(tb.source)-1).bit_length()
    src_mask = 2**src_width-1 if src_width else 0
    src_shift = id_width-src_width
    max_count = 2**src_shift
    count_mask = max_count-1

    cur_id = 1

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = [[list() for y in tb.sink] for x in tb.source]

    for p in range(len(tb.source)):
        for k in range(128):
            length = random.randint(1, byte_lanes*16)
            test_data = bytearray(itertools.islice(itertools.cycle(range(256)), length))
            test_frame = AxiStreamFrame(test_data)
            test_frame.tid = cur_id | (p << src_shift)
            test_frame.tdest = random.randrange(len(tb.sink))

            test_frames[p][test_frame.tdest].append(test_frame)
            await tb.source[p].send(test_frame)

            cur_id = (cur_id + 1) % max_count

    for lst in test_frames:
        while any(lst):
            rx_frame = await tb.sink[[x for x in lst if x][0][0].tdest].recv()

            test_frame = None

            for lst_a in test_frames:
                for lst_b in lst_a:
                    if lst_b and lst_b[0].tid == (rx_frame.tid & id_mask):
                        test_frame = lst_b.pop(0)
                        break

            assert test_frame is not None

            assert rx_frame.tdata == test_frame.tdata
            assert (rx_frame.tid & id_mask) == test_frame.tid
            assert ((rx_frame.tid >> src_shift) & src_mask) == (rx_frame.tid >> id_width)
            assert not rx_frame.tuser

    assert all(s.empty() for s in tb.sink)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


def size_list():
    data_width = len(cocotb.top.s00_axis_tdata)
    byte_width = data_width // 8
    return list(range(1, byte_width*4+1))+[512]+[1]*64


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


if cocotb.SIM_NAME:

    s_count = len(cocotb.top.axis_switch_inst.s_axis_tvalid)
    m_count = len(cocotb.top.axis_switch_inst.m_axis_tvalid)

    factory = TestFactory(run_test)
    factory.add_option("payload_lengths", [size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.add_option("s", range(min(s_count, 2)))
    factory.add_option("m", range(min(m_count, 2)))
    factory.generate_tests()

    for test in [run_test_tuser_assert]:
        factory = TestFactory(test)
        factory.add_option("s", range(min(s_count, 2)))
        factory.add_option("m", range(min(m_count, 2)))
        factory.generate_tests()

    if s_count > 1:
        factory = TestFactory(run_arb_test)
        factory.generate_tests()

    factory = TestFactory(run_stress_test)
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))


@pytest.mark.parametrize("data_width", [8, 16, 32])
@pytest.mark.parametrize("m_count", [1, 4])
@pytest.mark.parametrize("s_count", [1, 4])
def test_axis_switch(request, s_count, m_count, data_width):
    dut = "axis_switch"
    wrapper = f"{dut}_wrap_{s_count}x{m_count}"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = wrapper

    # generate wrapper
    wrapper_file = os.path.join(tests_dir, f"{wrapper}.v")
    if not os.path.exists(wrapper_file):
        subprocess.Popen(
            [os.path.join(rtl_dir, f"{dut}_wrap.py"), "-p", f"{s_count}", f"{m_count}"],
            cwd=tests_dir
        ).wait()

    verilog_sources = [
        wrapper_file,
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "axis_register.v"),
        os.path.join(rtl_dir, "arbiter.v"),
        os.path.join(rtl_dir, "priority_encoder.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['ID_ENABLE'] = 1
    parameters['S_ID_WIDTH'] = 16
    parameters['M_ID_WIDTH'] = parameters['S_ID_WIDTH'] + (s_count-1).bit_length()
    parameters['M_DEST_WIDTH'] = 8
    parameters['S_DEST_WIDTH'] = parameters['M_DEST_WIDTH'] + (m_count-1).bit_length()
    parameters['USER_ENABLE'] = 1
    parameters['USER_WIDTH'] = 1
    parameters['UPDATE_TID'] = 1
    parameters['S_REG_TYPE'] = 0
    parameters['M_REG_TYPE'] = 2
    parameters['ARB_TYPE_ROUND_ROBIN'] = 1
    parameters['ARB_LSB_HIGH_PRIORITY'] = 1

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    extra_env['S_COUNT'] = str(s_count)
    extra_env['M_COUNT'] = str(m_count)

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
