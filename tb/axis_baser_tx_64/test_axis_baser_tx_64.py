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
import sys

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_time_from_sim_steps
from cocotb.regression import TestFactory

from cocotbext.eth import PtpClockSimTime
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamFrame
from cocotbext.axi.stream import define_stream

try:
    from baser import BaseRSerdesSink
except ImportError:
    # attempt import from current directory
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    try:
        from baser import BaseRSerdesSink
    finally:
        del sys.path[0]


PtpTsBus, PtpTsTransaction, PtpTsSource, PtpTsSink, PtpTsMonitor = define_stream("PtpTs",
    signals=["ts", "ts_valid"],
    optional_signals=["ts_tag", "ts_ready"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        self.sink = BaseRSerdesSink(dut.encoded_tx_data, dut.encoded_tx_hdr, dut.clk, scramble=False)

        self.ptp_clock = PtpClockSimTime(ts_tod=dut.ptp_ts, clock=dut.clk)
        self.ptp_ts_sink = PtpTsSink(PtpTsBus.from_prefix(dut, "m_axis_ptp"), dut.clk, dut.rst)

        dut.cfg_ifg.setimmediatevalue(0)
        dut.cfg_tx_enable.setimmediatevalue(0)

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


async def run_test(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.source.send(AxiStreamFrame(test_data, tuser=2))

    for test_data in test_frames:
        rx_frame = await tb.sink.recv()
        ptp_ts = await tb.ptp_ts_sink.recv()

        ptp_ts_ns = int(ptp_ts.ts) / 2**16

        rx_frame_sfd_ns = get_time_from_sim_steps(rx_frame.sim_time_sfd, "ns")

        if rx_frame.start_lane == 4:
            # start in lane 4 reports 1 full cycle delay, so subtract half clock period
            rx_frame_sfd_ns -= 3.2

        tb.log.info("TX frame PTP TS: %f ns", ptp_ts_ns)
        tb.log.info("RX frame SFD sim time: %f ns", rx_frame_sfd_ns)
        tb.log.info("Difference: %f ns", abs(rx_frame_sfd_ns - ptp_ts_ns))

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()
        assert rx_frame.ctrl is None
        assert abs(rx_frame_sfd_ns - ptp_ts_ns - 12.8) < 0.01

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_alignment(dut, payload_data=None, ifg=12):

    enable_dic = int(os.getenv("PARAM_ENABLE_DIC"))

    tb = TB(dut)

    byte_width = tb.source.width // 8

    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    for length in range(60, 92):

        for k in range(10):
            await RisingEdge(dut.clk)

        test_frames = [payload_data(length) for k in range(10)]
        start_lane = []

        for test_data in test_frames:
            await tb.source.send(AxiStreamFrame(test_data, tuser=2))

        for test_data in test_frames:
            rx_frame = await tb.sink.recv()
            ptp_ts = await tb.ptp_ts_sink.recv()

            ptp_ts_ns = int(ptp_ts.ts) / 2**16

            rx_frame_sfd_ns = get_time_from_sim_steps(rx_frame.sim_time_sfd, "ns")

            if rx_frame.start_lane == 4:
                # start in lane 4 reports 1 full cycle delay, so subtract half clock period
                rx_frame_sfd_ns -= 3.2

            tb.log.info("TX frame PTP TS: %f ns", ptp_ts_ns)
            tb.log.info("RX frame SFD sim time: %f ns", rx_frame_sfd_ns)
            tb.log.info("Difference: %f ns", abs(rx_frame_sfd_ns - ptp_ts_ns))

            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None
            assert abs(rx_frame_sfd_ns - ptp_ts_ns - 12.8) < 0.01

            start_lane.append(rx_frame.start_lane)

        tb.log.info("length: %d", length)
        tb.log.info("start_lane: %s", start_lane)

        start_lane_ref = []

        # compute expected starting lanes
        lane = 0
        deficit_idle_count = 0

        for test_data in test_frames:
            if ifg == 0:
                lane = 0

            start_lane_ref.append(lane)
            lane = (lane + len(test_data)+4+ifg) % byte_width

            if enable_dic:
                offset = lane % 4
                if deficit_idle_count+offset >= 4:
                    offset += 4
                lane = (lane - offset) % byte_width
                deficit_idle_count = (deficit_idle_count + offset) % 4
            else:
                offset = lane % 4
                if offset > 0:
                    offset += 4
                lane = (lane - offset) % byte_width

        tb.log.info("start_lane_ref: %s", start_lane_ref)

        assert start_lane_ref == start_lane

        await RisingEdge(dut.clk)

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_underrun(dut, ifg=12):

    tb = TB(dut)

    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        await tb.source.send(test_frame)

    for k in range(16):
        await RisingEdge(dut.clk)

    tb.source.pause = True

    for k in range(4):
        await RisingEdge(dut.clk)

    tb.source.pause = False

    for k in range(3):
        rx_frame = await tb.sink.recv()

        if k == 1:
            assert rx_frame.data[-1] == 0xFE
            assert rx_frame.ctrl[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


async def run_test_error(dut, ifg=12):

    tb = TB(dut)

    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        if k == 1:
            test_frame.tuser = 1
        await tb.source.send(test_frame)

    for k in range(3):
        rx_frame = await tb.sink.recv()

        if k == 1:
            assert rx_frame.data[-1] == 0xFE
            assert rx_frame.ctrl[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def size_list():
    return list(range(60, 128)) + [512, 1514, 9214] + [60]*10


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


def cycle_en():
    return itertools.cycle([0, 0, 0, 1])


if cocotb.SIM_NAME:

    factory = TestFactory(run_test)
    factory.add_option("payload_lengths", [size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("ifg", [12])
    factory.generate_tests()

    factory = TestFactory(run_test_alignment)
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("ifg", [12])
    factory.generate_tests()

    for test in [run_test_underrun, run_test_error]:

        factory = TestFactory(test)
        factory.add_option("ifg", [12])
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("enable_dic", [1, 0])
def test_axis_baser_tx_64(request, enable_dic):
    dut = "axis_baser_tx_64"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = 64
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['HDR_WIDTH'] = 2
    parameters['ENABLE_PADDING'] = 1
    parameters['ENABLE_DIC'] = enable_dic
    parameters['MIN_FRAME_LENGTH'] = 64
    parameters['PTP_TS_ENABLE'] = 1
    parameters['PTP_TS_FMT_TOD'] = 1
    parameters['PTP_TS_WIDTH'] = 96 if parameters['PTP_TS_FMT_TOD'] else 64
    parameters['PTP_TS_CTRL_IN_TUSER'] = parameters['PTP_TS_ENABLE']
    parameters['PTP_TAG_ENABLE'] = parameters['PTP_TS_ENABLE']
    parameters['PTP_TAG_WIDTH'] = 16
    parameters['USER_WIDTH'] = ((parameters['PTP_TAG_WIDTH'] if parameters['PTP_TAG_ENABLE'] else 0) + (1 if parameters['PTP_TS_CTRL_IN_TUSER'] else 0) if parameters['PTP_TS_ENABLE'] else 0) + 1

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
