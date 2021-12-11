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

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.eth import XgmiiFrame
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink

try:
    from baser import BaseRSerdesSource, BaseRSerdesSink
except ImportError:
    # attempt import from current directory
    sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
    try:
        from baser import BaseRSerdesSource, BaseRSerdesSink
    finally:
        del sys.path[0]


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        if len(dut.serdes_tx_data) == 64:
            cocotb.start_soon(Clock(dut.logic_clk, 6.4, units="ns").start())
            cocotb.start_soon(Clock(dut.rx_clk, 6.4, units="ns").start())
            cocotb.start_soon(Clock(dut.tx_clk, 6.4, units="ns").start())
        else:
            cocotb.start_soon(Clock(dut.logic_clk, 3.2, units="ns").start())
            cocotb.start_soon(Clock(dut.rx_clk, 3.2, units="ns").start())
            cocotb.start_soon(Clock(dut.tx_clk, 3.2, units="ns").start())

        self.serdes_source = BaseRSerdesSource(dut.serdes_rx_data, dut.serdes_rx_hdr, dut.rx_clk, slip=dut.serdes_rx_bitslip)
        self.serdes_sink = BaseRSerdesSink(dut.serdes_tx_data, dut.serdes_tx_hdr, dut.tx_clk)

        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "tx_axis"), dut.logic_clk, dut.logic_rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rx_axis"), dut.logic_clk, dut.logic_rst)

        dut.ptp_sample_clk.setimmediatevalue(0)
        dut.ptp_ts_96.setimmediatevalue(0)
        dut.ptp_ts_step.setimmediatevalue(0)

        dut.tx_prbs31_enable.setimmediatevalue(0)
        dut.rx_prbs31_enable.setimmediatevalue(0)

    async def reset(self):
        self.dut.logic_rst.setimmediatevalue(0)
        self.dut.rx_rst.setimmediatevalue(0)
        self.dut.tx_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.logic_clk)
        await RisingEdge(self.dut.logic_clk)
        self.dut.logic_rst <= 1
        self.dut.rx_rst <= 1
        self.dut.tx_rst <= 1
        await RisingEdge(self.dut.logic_clk)
        await RisingEdge(self.dut.logic_clk)
        self.dut.logic_rst <= 0
        self.dut.rx_rst <= 0
        self.dut.tx_rst <= 0
        await RisingEdge(self.dut.logic_clk)
        await RisingEdge(self.dut.logic_clk)


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.serdes_source.ifg = ifg
    tb.dut.ifg_delay <= ifg

    await tb.reset()

    tb.log.info("Wait for block lock")
    while not dut.rx_block_lock.value.integer:
        await RisingEdge(dut.rx_clk)

    # clear out sink buffer
    tb.axis_sink.clear()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        test_frame = XgmiiFrame.from_payload(test_data)
        await tb.serdes_source.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.axis_sink.recv()

        assert rx_frame.tdata == test_data
        assert rx_frame.tuser == 0

    assert tb.axis_sink.empty()

    await RisingEdge(dut.logic_clk)
    await RisingEdge(dut.logic_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.serdes_source.ifg = ifg
    tb.dut.ifg_delay <= ifg

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.axis_source.send(test_data)

    for test_data in test_frames:
        rx_frame = await tb.serdes_sink.recv()

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()

    assert tb.serdes_sink.empty()

    await RisingEdge(dut.logic_clk)
    await RisingEdge(dut.logic_clk)


async def run_test_tx_alignment(dut, payload_data=None, ifg=12):

    enable_dic = int(os.getenv("PARAM_ENABLE_DIC"))

    tb = TB(dut)

    byte_width = tb.axis_source.width // 8

    tb.serdes_source.ifg = ifg
    tb.dut.ifg_delay <= ifg

    for length in range(60, 92):

        await tb.reset()

        test_frames = [payload_data(length) for k in range(10)]
        start_lane = []

        for test_data in test_frames:
            await tb.axis_source.send(test_data)

        for test_data in test_frames:
            rx_frame = await tb.serdes_sink.recv()

            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None

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

        await RisingEdge(dut.logic_clk)

    assert tb.serdes_sink.empty()

    await RisingEdge(dut.logic_clk)
    await RisingEdge(dut.logic_clk)


async def run_test_rx_frame_sync(dut):

    tb = TB(dut)

    await tb.reset()

    tb.log.info("Wait for block lock")
    while not dut.rx_block_lock.value.integer:
        await RisingEdge(dut.rx_clk)

    assert dut.rx_block_lock.value.integer

    tb.log.info("Change offset")
    tb.serdes_source.bit_offset = 33

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    tb.log.info("Check for lock lost")
    assert not dut.rx_block_lock.value.integer
    assert dut.rx_high_ber.value.integer

    for k in range(500):
        await RisingEdge(dut.rx_clk)

    tb.log.info("Check for block lock")
    assert dut.rx_block_lock.value.integer

    for k in range(300):
        await RisingEdge(dut.rx_clk)

    tb.log.info("Check for high BER deassert")
    assert not dut.rx_high_ber.value.integer

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


def size_list():
    return list(range(60, 128)) + [512, 1514, 9214] + [60]*10


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


def cycle_en():
    return itertools.cycle([0, 0, 0, 1])


if cocotb.SIM_NAME:

    for test in [run_test_rx, run_test_tx]:

        factory = TestFactory(test)
        factory.add_option("payload_lengths", [size_list])
        factory.add_option("payload_data", [incrementing_payload])
        factory.add_option("ifg", [12, 0])
        factory.generate_tests()

    factory = TestFactory(run_test_tx_alignment)
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("ifg", [12])
    factory.generate_tests()

    factory = TestFactory(run_test_rx_frame_sync)
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("enable_dic", [1, 0])
@pytest.mark.parametrize("data_width", [64])
def test_eth_mac_phy_10g_fifo(request, data_width, enable_dic):
    dut = "eth_mac_phy_10g_fifo"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "eth_mac_phy_10g.v"),
        os.path.join(rtl_dir, "eth_mac_phy_10g_rx.v"),
        os.path.join(rtl_dir, "eth_mac_phy_10g_tx.v"),
        os.path.join(rtl_dir, "eth_phy_10g_rx_if.v"),
        os.path.join(rtl_dir, "eth_phy_10g_rx_ber_mon.v"),
        os.path.join(rtl_dir, "eth_phy_10g_rx_frame_sync.v"),
        os.path.join(rtl_dir, "eth_phy_10g_rx_watchdog.v"),
        os.path.join(rtl_dir, "eth_phy_10g_tx_if.v"),
        os.path.join(rtl_dir, "axis_baser_rx_64.v"),
        os.path.join(rtl_dir, "axis_baser_tx_64.v"),
        os.path.join(rtl_dir, "lfsr.v"),
        os.path.join(axis_rtl_dir, "axis_adapter.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['HDR_WIDTH'] = 2
    parameters['AXIS_DATA_WIDTH'] = parameters['DATA_WIDTH']
    parameters['AXIS_KEEP_ENABLE'] = int(parameters['AXIS_DATA_WIDTH'] > 8)
    parameters['AXIS_KEEP_WIDTH'] = parameters['AXIS_DATA_WIDTH'] // 8
    parameters['ENABLE_PADDING'] = 1
    parameters['ENABLE_DIC'] = enable_dic
    parameters['MIN_FRAME_LENGTH'] = 64
    parameters['TX_FIFO_DEPTH'] = 16384
    parameters['TX_FIFO_PIPELINE_OUTPUT'] = 2
    parameters['TX_FRAME_FIFO'] = 1
    parameters['TX_DROP_OVERSIZE_FRAME'] = parameters['TX_FRAME_FIFO']
    parameters['TX_DROP_BAD_FRAME'] = parameters['TX_DROP_OVERSIZE_FRAME']
    parameters['TX_DROP_WHEN_FULL'] = 0
    parameters['RX_FIFO_DEPTH'] = 16384
    parameters['RX_FIFO_PIPELINE_OUTPUT'] = 2
    parameters['RX_FRAME_FIFO'] = 1
    parameters['RX_DROP_OVERSIZE_FRAME'] = parameters['RX_FRAME_FIFO']
    parameters['RX_DROP_BAD_FRAME'] = parameters['RX_DROP_OVERSIZE_FRAME']
    parameters['RX_DROP_WHEN_FULL'] = parameters['RX_DROP_OVERSIZE_FRAME']
    parameters['PTP_PERIOD_NS'] = 0x6 if parameters['DATA_WIDTH'] == 64 else 0x3
    parameters['PTP_PERIOD_FNS'] = 0x6666 if parameters['DATA_WIDTH'] == 64 else 0x3333
    parameters['PTP_USE_SAMPLE_CLOCK'] = 0
    parameters['TX_PTP_TS_ENABLE'] = 0
    parameters['RX_PTP_TS_ENABLE'] = 0
    parameters['TX_PTP_TS_FIFO_DEPTH'] = 64
    parameters['PTP_TS_WIDTH'] = 96
    parameters['TX_PTP_TAG_ENABLE'] = 0
    parameters['PTP_TAG_WIDTH'] = 16
    parameters['TX_USER_WIDTH'] = (parameters['TX_PTP_TAG_WIDTH'] if parameters['TX_PTP_TS_ENABLE'] and parameters['TX_PTP_TAG_ENABLE'] else 0) + 1
    parameters['RX_USER_WIDTH'] = (parameters['RX_PTP_TS_WIDTH'] if parameters['RX_PTP_TS_ENABLE'] else 0) + 1
    parameters['BIT_REVERSE'] = 0
    parameters['SCRAMBLER_DISABLE'] = 0
    parameters['PRBS31_ENABLE'] = 1
    parameters['TX_SERDES_PIPELINE'] = 2
    parameters['RX_SERDES_PIPELINE'] = 2
    parameters['BITSLIP_HIGH_CYCLES'] = 1
    parameters['BITSLIP_LOW_CYCLES'] = 8
    parameters['COUNT_125US'] = int(1250/6.4)

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
