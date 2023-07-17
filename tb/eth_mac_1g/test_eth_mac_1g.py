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

import itertools
import logging
import os

import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_time_from_sim_steps
from cocotb.regression import TestFactory

from cocotbext.eth import GmiiFrame, GmiiSource, GmiiSink, PtpClockSimTime
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame
from cocotbext.axi.stream import define_stream


PtpTsBus, PtpTsTransaction, PtpTsSource, PtpTsSink, PtpTsMonitor = define_stream("PtpTs",
    signals=["ts", "ts_valid"],
    optional_signals=["ts_tag", "ts_ready"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self._enable_generator_rx = None
        self._enable_generator_tx = None
        self._enable_cr_rx = None
        self._enable_cr_tx = None

        cocotb.start_soon(Clock(dut.rx_clk, 8, units="ns").start())
        cocotb.start_soon(Clock(dut.tx_clk, 8, units="ns").start())

        self.gmii_source = GmiiSource(dut.gmii_rxd, dut.gmii_rx_er, dut.gmii_rx_dv,
            dut.rx_clk, dut.rx_rst, dut.rx_clk_enable, dut.rx_mii_select)
        self.gmii_sink = GmiiSink(dut.gmii_txd, dut.gmii_tx_er, dut.gmii_tx_en,
            dut.tx_clk, dut.tx_rst, dut.tx_clk_enable, dut.tx_mii_select)

        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "tx_axis"), dut.tx_clk, dut.tx_rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rx_axis"), dut.rx_clk, dut.rx_rst)

        self.rx_ptp_clock = PtpClockSimTime(ts_64=dut.rx_ptp_ts, clock=dut.rx_clk)
        self.tx_ptp_clock = PtpClockSimTime(ts_64=dut.tx_ptp_ts, clock=dut.tx_clk)
        self.tx_ptp_ts_sink = PtpTsSink(PtpTsBus.from_prefix(dut, "tx_axis_ptp"), dut.tx_clk, dut.tx_rst)

        dut.rx_clk_enable.setimmediatevalue(1)
        dut.tx_clk_enable.setimmediatevalue(1)
        dut.rx_mii_select.setimmediatevalue(0)
        dut.tx_mii_select.setimmediatevalue(0)
        dut.ifg_delay.setimmediatevalue(0)

    async def reset(self):
        self.dut.rx_rst.setimmediatevalue(0)
        self.dut.tx_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.rx_rst.value = 1
        self.dut.tx_rst.value = 1
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.rx_rst.value = 0
        self.dut.tx_rst.value = 0
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)

    def set_enable_generator_rx(self, generator=None):
        if self._enable_cr_rx is not None:
            self._enable_cr_rx.kill()
            self._enable_cr_rx = None

        self._enable_generator_rx = generator

        if self._enable_generator_rx is not None:
            self._enable_cr_rx = cocotb.start_soon(self._run_enable_rx())

    def set_enable_generator_tx(self, generator=None):
        if self._enable_cr_tx is not None:
            self._enable_cr_tx.kill()
            self._enable_cr_tx = None

        self._enable_generator_tx = generator

        if self._enable_generator_tx is not None:
            self._enable_cr_tx = cocotb.start_soon(self._run_enable_tx())

    def clear_enable_generator_rx(self):
        self.set_enable_generator_rx(None)

    def clear_enable_generator_tx(self):
        self.set_enable_generator_tx(None)

    async def _run_enable_rx(self):
        for val in self._enable_generator_rx:
            self.dut.rx_clk_enable.value = val
            await RisingEdge(self.dut.rx_clk)

    async def _run_enable_tx(self):
        for val in self._enable_generator_tx:
            self.dut.tx_clk_enable.value = val
            await RisingEdge(self.dut.tx_clk)


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12, enable_gen=None, mii_sel=False):

    tb = TB(dut)

    tb.gmii_source.ifg = ifg
    tb.dut.ifg_delay.value = ifg
    tb.dut.rx_mii_select.value = mii_sel
    tb.dut.tx_mii_select.value = mii_sel

    if enable_gen is not None:
        tb.set_enable_generator_rx(enable_gen())
        tb.set_enable_generator_tx(enable_gen())

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]
    tx_frames = []

    for test_data in test_frames:
        test_frame = GmiiFrame.from_payload(test_data, tx_complete=tx_frames.append)
        await tb.gmii_source.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.axis_sink.recv()
        tx_frame = tx_frames.pop(0)

        frame_error = rx_frame.tuser & 1
        ptp_ts = rx_frame.tuser >> 1
        ptp_ts_ns = ptp_ts / 2**16

        tx_frame_sfd_ns = get_time_from_sim_steps(tx_frame.sim_time_sfd, "ns")

        tb.log.info("RX frame PTP TS: %f ns", ptp_ts_ns)
        tb.log.info("TX frame SFD sim time: %f ns", tx_frame_sfd_ns)

        assert rx_frame.tdata == test_data
        assert frame_error == 0
        assert abs(ptp_ts_ns - tx_frame_sfd_ns - (32 if enable_gen else 8)) < 0.01

    assert tb.axis_sink.empty()

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12, enable_gen=None, mii_sel=False):

    tb = TB(dut)

    tb.gmii_source.ifg = ifg
    tb.dut.ifg_delay.value = ifg
    tb.dut.rx_mii_select.value = mii_sel
    tb.dut.tx_mii_select.value = mii_sel

    if enable_gen is not None:
        tb.set_enable_generator_rx(enable_gen())
        tb.set_enable_generator_tx(enable_gen())

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.axis_source.send(AxiStreamFrame(test_data, tuser=2))

    for test_data in test_frames:
        rx_frame = await tb.gmii_sink.recv()
        ptp_ts = await tb.tx_ptp_ts_sink.recv()

        ptp_ts_ns = int(ptp_ts.ts) / 2**16

        rx_frame_sfd_ns = get_time_from_sim_steps(rx_frame.sim_time_sfd, "ns")

        tb.log.info("TX frame PTP TS: %f ns", ptp_ts_ns)
        tb.log.info("RX frame SFD sim time: %f ns", rx_frame_sfd_ns)

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()
        assert rx_frame.error is None
        assert abs(rx_frame_sfd_ns - ptp_ts_ns - (32 if enable_gen else 8)) < 0.01

    assert tb.gmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


def size_list():
    return list(range(60, 128)) + [512, 1514] + [60]*10


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


def cycle_en():
    return itertools.cycle([0, 0, 0, 1])


if cocotb.SIM_NAME:

    for test in [run_test_rx, run_test_tx]:

        factory = TestFactory(test)
        factory.add_option("payload_lengths", [size_list])
        factory.add_option("payload_data", [incrementing_payload])
        factory.add_option("ifg", [12])
        factory.add_option("enable_gen", [None, cycle_en])
        factory.add_option("mii_sel", [False, True])
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_eth_mac_1g(request):
    dut = "eth_mac_1g"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "axis_gmii_rx.v"),
        os.path.join(rtl_dir, "axis_gmii_tx.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = 8
    parameters['ENABLE_PADDING'] = 1
    parameters['MIN_FRAME_LENGTH'] = 64
    parameters['TX_PTP_TS_ENABLE'] = 1
    parameters['TX_PTP_TS_WIDTH'] = 96
    parameters['TX_PTP_TS_CTRL_IN_TUSER'] = parameters['TX_PTP_TS_ENABLE']
    parameters['TX_PTP_TAG_ENABLE'] = parameters['TX_PTP_TS_ENABLE']
    parameters['TX_PTP_TAG_WIDTH'] = 16
    parameters['RX_PTP_TS_ENABLE'] = parameters['TX_PTP_TS_ENABLE']
    parameters['RX_PTP_TS_WIDTH'] = 96
    parameters['TX_USER_WIDTH'] = ((parameters['TX_PTP_TAG_WIDTH'] if parameters['TX_PTP_TAG_ENABLE'] else 0) + (1 if parameters['TX_PTP_TS_CTRL_IN_TUSER'] else 0) if parameters['TX_PTP_TS_ENABLE'] else 0) + 1
    parameters['RX_USER_WIDTH'] = (parameters['RX_PTP_TS_WIDTH'] if parameters['RX_PTP_TS_ENABLE'] else 0) + 1

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
