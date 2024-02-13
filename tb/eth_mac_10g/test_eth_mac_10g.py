#!/usr/bin/env python
"""

Copyright (c) 2020-2023 Alex Forencich

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
import struct
import os

from scapy.layers.l2 import Ether

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_time_from_sim_steps
from cocotb.regression import TestFactory

from cocotbext.eth import XgmiiFrame, XgmiiSource, XgmiiSink, PtpClockSimTime
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

        if len(dut.xgmii_txd) == 64:
            self.clk_period = 6.4
        else:
            self.clk_period = 3.2

        cocotb.start_soon(Clock(dut.rx_clk, self.clk_period, units="ns").start())
        cocotb.start_soon(Clock(dut.tx_clk, self.clk_period, units="ns").start())

        self.xgmii_source = XgmiiSource(dut.xgmii_rxd, dut.xgmii_rxc, dut.rx_clk, dut.rx_rst)
        self.xgmii_sink = XgmiiSink(dut.xgmii_txd, dut.xgmii_txc, dut.tx_clk, dut.tx_rst)

        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "tx_axis"), dut.tx_clk, dut.tx_rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rx_axis"), dut.rx_clk, dut.rx_rst)

        self.rx_ptp_clock = PtpClockSimTime(ts_tod=dut.rx_ptp_ts, clock=dut.rx_clk)
        self.tx_ptp_clock = PtpClockSimTime(ts_tod=dut.tx_ptp_ts, clock=dut.tx_clk)
        self.tx_ptp_ts_sink = PtpTsSink(PtpTsBus.from_prefix(dut, "tx_axis_ptp"), dut.tx_clk, dut.tx_rst)

        dut.tx_lfc_req.setimmediatevalue(0)
        dut.tx_lfc_resend.setimmediatevalue(0)
        dut.rx_lfc_en.setimmediatevalue(0)
        dut.rx_lfc_ack.setimmediatevalue(0)

        dut.tx_pfc_req.setimmediatevalue(0)
        dut.tx_pfc_resend.setimmediatevalue(0)
        dut.rx_pfc_en.setimmediatevalue(0)
        dut.rx_pfc_ack.setimmediatevalue(0)

        dut.tx_lfc_pause_en.setimmediatevalue(0)
        dut.tx_pause_req.setimmediatevalue(0)

        dut.cfg_ifg.setimmediatevalue(0)
        dut.cfg_tx_enable.setimmediatevalue(0)
        dut.cfg_rx_enable.setimmediatevalue(0)
        dut.cfg_mcf_rx_eth_dst_mcast.setimmediatevalue(0)
        dut.cfg_mcf_rx_check_eth_dst_mcast.setimmediatevalue(0)
        dut.cfg_mcf_rx_eth_dst_ucast.setimmediatevalue(0)
        dut.cfg_mcf_rx_check_eth_dst_ucast.setimmediatevalue(0)
        dut.cfg_mcf_rx_eth_src.setimmediatevalue(0)
        dut.cfg_mcf_rx_check_eth_src.setimmediatevalue(0)
        dut.cfg_mcf_rx_eth_type.setimmediatevalue(0)
        dut.cfg_mcf_rx_opcode_lfc.setimmediatevalue(0)
        dut.cfg_mcf_rx_check_opcode_lfc.setimmediatevalue(0)
        dut.cfg_mcf_rx_opcode_pfc.setimmediatevalue(0)
        dut.cfg_mcf_rx_check_opcode_pfc.setimmediatevalue(0)
        dut.cfg_mcf_rx_forward.setimmediatevalue(0)
        dut.cfg_mcf_rx_enable.setimmediatevalue(0)
        dut.cfg_tx_lfc_eth_dst.setimmediatevalue(0)
        dut.cfg_tx_lfc_eth_src.setimmediatevalue(0)
        dut.cfg_tx_lfc_eth_type.setimmediatevalue(0)
        dut.cfg_tx_lfc_opcode.setimmediatevalue(0)
        dut.cfg_tx_lfc_en.setimmediatevalue(0)
        dut.cfg_tx_lfc_quanta.setimmediatevalue(0)
        dut.cfg_tx_lfc_refresh.setimmediatevalue(0)
        dut.cfg_tx_pfc_eth_dst.setimmediatevalue(0)
        dut.cfg_tx_pfc_eth_src.setimmediatevalue(0)
        dut.cfg_tx_pfc_eth_type.setimmediatevalue(0)
        dut.cfg_tx_pfc_opcode.setimmediatevalue(0)
        dut.cfg_tx_pfc_en.setimmediatevalue(0)
        dut.cfg_tx_pfc_quanta.setimmediatevalue(0)
        dut.cfg_tx_pfc_refresh.setimmediatevalue(0)
        dut.cfg_rx_lfc_opcode.setimmediatevalue(0)
        dut.cfg_rx_lfc_en.setimmediatevalue(0)
        dut.cfg_rx_pfc_opcode.setimmediatevalue(0)
        dut.cfg_rx_pfc_en.setimmediatevalue(0)

    async def reset(self):
        self.dut.rx_rst.setimmediatevalue(0)
        self.dut.tx_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.rx_clk)
        await RisingEdge(self.dut.rx_clk)
        self.dut.rx_rst.value = 1
        self.dut.tx_rst.value = 1
        await RisingEdge(self.dut.rx_clk)
        await RisingEdge(self.dut.rx_clk)
        self.dut.rx_rst.value = 0
        self.dut.tx_rst.value = 0
        await RisingEdge(self.dut.rx_clk)
        await RisingEdge(self.dut.rx_clk)


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_rx_enable.value = 1

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]
    tx_frames = []

    for test_data in test_frames:
        test_frame = XgmiiFrame.from_payload(test_data, tx_complete=tx_frames.append)
        await tb.xgmii_source.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.axis_sink.recv()
        tx_frame = tx_frames.pop(0)

        frame_error = rx_frame.tuser & 1
        ptp_ts = rx_frame.tuser >> 1
        ptp_ts_ns = ptp_ts / 2**16

        tx_frame_sfd_ns = get_time_from_sim_steps(tx_frame.sim_time_sfd, "ns")

        if tx_frame.start_lane == 4:
            # start in lane 4 reports 1 full cycle delay, so subtract half clock period
            tx_frame_sfd_ns -= tb.clk_period/2

        tb.log.info("RX frame PTP TS: %f ns", ptp_ts_ns)
        tb.log.info("TX frame SFD sim time: %f ns", tx_frame_sfd_ns)
        tb.log.info("Difference: %f ns", abs(ptp_ts_ns - tx_frame_sfd_ns))

        assert rx_frame.tdata == test_data
        assert frame_error == 0
        assert abs(ptp_ts_ns - tx_frame_sfd_ns - tb.clk_period) < 0.01

    assert tb.axis_sink.empty()

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.axis_source.send(AxiStreamFrame(test_data, tuser=2))

    for test_data in test_frames:
        rx_frame = await tb.xgmii_sink.recv()
        ptp_ts = await tb.tx_ptp_ts_sink.recv()

        ptp_ts_ns = int(ptp_ts.ts) / 2**16

        rx_frame_sfd_ns = get_time_from_sim_steps(rx_frame.sim_time_sfd, "ns")

        if rx_frame.start_lane == 4:
            # start in lane 4 reports 1 full cycle delay, so subtract half clock period
            rx_frame_sfd_ns -= tb.clk_period/2

        tb.log.info("TX frame PTP TS: %f ns", ptp_ts_ns)
        tb.log.info("RX frame SFD sim time: %f ns", rx_frame_sfd_ns)
        tb.log.info("Difference: %f ns", abs(rx_frame_sfd_ns - ptp_ts_ns))

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()
        assert rx_frame.ctrl is None
        assert abs(rx_frame_sfd_ns - ptp_ts_ns - tb.clk_period) < 0.01

    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_tx_alignment(dut, payload_data=None, ifg=12):

    enable_dic = int(os.getenv("PARAM_ENABLE_DIC"))

    tb = TB(dut)

    byte_width = tb.axis_source.width // 8

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    for length in range(60, 92):

        for k in range(10):
            await RisingEdge(dut.tx_clk)

        test_frames = [payload_data(length) for k in range(10)]
        start_lane = []

        for test_data in test_frames:
            await tb.axis_source.send(AxiStreamFrame(test_data, tuser=2))

        for test_data in test_frames:
            rx_frame = await tb.xgmii_sink.recv()
            ptp_ts = await tb.tx_ptp_ts_sink.recv()

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
            assert abs(rx_frame_sfd_ns - ptp_ts_ns - tb.clk_period) < 0.01

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

        await RisingEdge(dut.tx_clk)

    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_tx_underrun(dut, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        await tb.axis_source.send(test_frame)

    for k in range(64*16 // tb.axis_source.width):
        await RisingEdge(dut.tx_clk)

    tb.axis_source.pause = True

    for k in range(4):
        await RisingEdge(dut.tx_clk)

    tb.axis_source.pause = False

    for k in range(3):
        rx_frame = await tb.xgmii_sink.recv()

        if k == 1:
            assert rx_frame.data[-1] == 0xFE
            assert rx_frame.ctrl[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None

    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_tx_error(dut, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        if k == 1:
            test_frame.tuser = 1
        await tb.axis_source.send(test_frame)

    for k in range(3):
        rx_frame = await tb.xgmii_sink.recv()

        if k == 1:
            assert rx_frame.data[-1] == 0xFE
            assert rx_frame.ctrl[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.ctrl is None

    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_lfc(dut, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1
    tb.dut.cfg_rx_enable.value = 1

    await tb.reset()

    dut.tx_lfc_req.value = 0
    dut.tx_lfc_resend.value = 0
    dut.rx_lfc_en.value = 1
    dut.rx_lfc_ack.value = 0

    dut.tx_lfc_pause_en.value = 1
    dut.tx_pause_req.value = 0

    dut.cfg_mcf_rx_eth_dst_mcast.value = 0x0180C2000001
    dut.cfg_mcf_rx_check_eth_dst_mcast.value = 1
    dut.cfg_mcf_rx_eth_dst_ucast.value = 0xDAD1D2D3D4D5
    dut.cfg_mcf_rx_check_eth_dst_ucast.value = 0
    dut.cfg_mcf_rx_eth_src.value = 0x5A5152535455
    dut.cfg_mcf_rx_check_eth_src.value = 0
    dut.cfg_mcf_rx_eth_type.value = 0x8808
    dut.cfg_mcf_rx_opcode_lfc.value = 0x0001
    dut.cfg_mcf_rx_check_opcode_lfc.value = 1
    dut.cfg_mcf_rx_opcode_pfc.value = 0x0101
    dut.cfg_mcf_rx_check_opcode_pfc.value = 1

    dut.cfg_mcf_rx_forward.value = 0
    dut.cfg_mcf_rx_enable.value = 1

    dut.cfg_tx_lfc_eth_dst.value = 0x0180C2000001
    dut.cfg_tx_lfc_eth_src.value = 0x5A5152535455
    dut.cfg_tx_lfc_eth_type.value = 0x8808
    dut.cfg_tx_lfc_opcode.value = 0x0001
    dut.cfg_tx_lfc_en.value = 1
    dut.cfg_tx_lfc_quanta.value = 0xFFFF
    dut.cfg_tx_lfc_refresh.value = 0x7F00

    dut.cfg_rx_lfc_opcode.value = 0x0001
    dut.cfg_rx_lfc_en.value = 1

    test_tx_pkts = []
    test_rx_pkts = []

    for k in range(32):
        length = 512
        payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

        eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5', type=0x8000)
        test_pkt = eth / payload
        test_tx_pkts.append(test_pkt.copy())

        await tb.axis_source.send(bytes(test_pkt))

        eth = Ether(src='DA:D1:D2:D3:D4:D5', dst='5A:51:52:53:54:55', type=0x8000)
        test_pkt = eth / payload
        test_rx_pkts.append(test_pkt.copy())

        test_frame = XgmiiFrame.from_payload(bytes(test_pkt))
        await tb.xgmii_source.send(test_frame)

        if k == 16:
            eth = Ether(src='DA:D1:D2:D3:D4:D5', dst='01:80:C2:00:00:01', type=0x8808)
            test_pkt = eth / struct.pack('!HH', 0x0001, 100)
            test_rx_pkts.append(test_pkt.copy())

            test_frame = XgmiiFrame.from_payload(bytes(test_pkt))
            await tb.xgmii_source.send(test_frame)

    for k in range(200):
        await RisingEdge(dut.tx_clk)

    dut.tx_lfc_req.value = 1

    for k in range(200):
        await RisingEdge(dut.tx_clk)

    dut.tx_lfc_req.value = 0

    while not dut.rx_lfc_req.value.integer:
        await RisingEdge(dut.tx_clk)

    for k in range(200):
        await RisingEdge(dut.tx_clk)

    dut.tx_lfc_req.value = 1

    for k in range(200):
        await RisingEdge(dut.tx_clk)

    dut.tx_lfc_req.value = 0

    while test_rx_pkts:
        rx_frame = await tb.axis_sink.recv()

        rx_pkt = Ether(bytes(rx_frame))

        tb.log.info("RX packet: %s", repr(rx_pkt))

        if rx_pkt.type == 0x8808:
            test_pkt = test_rx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            if isinstance(rx_frame.tuser, list):
                assert rx_frame.tuser[-1] & 1
            else:
                assert rx_frame.tuser & 1
        else:
            test_pkt = test_rx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            if isinstance(rx_frame.tuser, list):
                assert not rx_frame.tuser[-1] & 1
            else:
                assert not rx_frame.tuser & 1

    tx_lfc_cnt = 0

    while test_tx_pkts:
        tx_frame = await tb.xgmii_sink.recv()

        tx_pkt = Ether(bytes(tx_frame.get_payload()))

        tb.log.info("TX packet: %s", repr(tx_pkt))

        if tx_pkt.type == 0x8808:
            tx_lfc_cnt += 1
        else:
            test_pkt = test_tx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(tx_pkt).find(bytes(test_pkt)) == 0

    assert tx_lfc_cnt == 4

    assert tb.axis_sink.empty()
    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_pfc(dut, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1
    tb.dut.cfg_rx_enable.value = 1

    await tb.reset()

    dut.tx_pfc_req.value = 0x00
    dut.tx_pfc_resend.value = 0
    dut.rx_pfc_en.value = 0xff
    dut.rx_pfc_ack.value = 0x00

    dut.tx_lfc_pause_en.value = 0
    dut.tx_pause_req.value = 0

    dut.cfg_mcf_rx_eth_dst_mcast.value = 0x0180C2000001
    dut.cfg_mcf_rx_check_eth_dst_mcast.value = 1
    dut.cfg_mcf_rx_eth_dst_ucast.value = 0xDAD1D2D3D4D5
    dut.cfg_mcf_rx_check_eth_dst_ucast.value = 0
    dut.cfg_mcf_rx_eth_src.value = 0x5A5152535455
    dut.cfg_mcf_rx_check_eth_src.value = 0
    dut.cfg_mcf_rx_eth_type.value = 0x8808
    dut.cfg_mcf_rx_opcode_lfc.value = 0x0001
    dut.cfg_mcf_rx_check_opcode_lfc.value = 1
    dut.cfg_mcf_rx_opcode_pfc.value = 0x0101
    dut.cfg_mcf_rx_check_opcode_pfc.value = 1

    dut.cfg_mcf_rx_forward.value = 0
    dut.cfg_mcf_rx_enable.value = 1

    dut.cfg_tx_pfc_eth_dst.value = 0x0180C2000001
    dut.cfg_tx_pfc_eth_src.value = 0x5A5152535455
    dut.cfg_tx_pfc_eth_type.value = 0x8808
    dut.cfg_tx_pfc_opcode.value = 0x0101
    dut.cfg_tx_pfc_en.value = 1
    dut.cfg_tx_pfc_quanta.value = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    dut.cfg_tx_pfc_refresh.value = 0x7F007F007F007F007F007F007F007F00

    dut.cfg_rx_pfc_opcode.value = 0x0101
    dut.cfg_rx_pfc_en.value = 1

    test_tx_pkts = []
    test_rx_pkts = []

    for k in range(32):
        length = 512
        payload = bytearray(itertools.islice(itertools.cycle(range(256)), length))

        eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5', type=0x8000)
        test_pkt = eth / payload
        test_tx_pkts.append(test_pkt.copy())

        await tb.axis_source.send(bytes(test_pkt))

        eth = Ether(src='DA:D1:D2:D3:D4:D5', dst='5A:51:52:53:54:55', type=0x8000)
        test_pkt = eth / payload
        test_rx_pkts.append(test_pkt.copy())

        test_frame = XgmiiFrame.from_payload(bytes(test_pkt))
        await tb.xgmii_source.send(test_frame)

        if k == 16:
            eth = Ether(src='DA:D1:D2:D3:D4:D5', dst='01:80:C2:00:00:01', type=0x8808)
            test_pkt = eth / struct.pack('!HH8H', 0x0101, 0x00FF, 10, 20, 30, 40, 50, 60, 70, 80)
            test_rx_pkts.append(test_pkt.copy())

            test_frame = XgmiiFrame.from_payload(bytes(test_pkt))
            await tb.xgmii_source.send(test_frame)

    for i in range(8):
        for k in range(200):
            await RisingEdge(dut.tx_clk)

        dut.tx_pfc_req.value = 0xff >> (7-i)

    for k in range(200):
        await RisingEdge(dut.tx_clk)

    dut.tx_pfc_req.value = 0x00

    while test_rx_pkts:
        rx_frame = await tb.axis_sink.recv()

        rx_pkt = Ether(bytes(rx_frame))

        tb.log.info("RX packet: %s", repr(rx_pkt))

        if rx_pkt.type == 0x8808:
            test_pkt = test_rx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            if isinstance(rx_frame.tuser, list):
                assert rx_frame.tuser[-1] & 1
            else:
                assert rx_frame.tuser & 1
        else:
            test_pkt = test_rx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(rx_pkt).find(bytes(test_pkt)) == 0
            if isinstance(rx_frame.tuser, list):
                assert not rx_frame.tuser[-1] & 1
            else:
                assert not rx_frame.tuser & 1

    tx_pfc_cnt = 0

    while test_tx_pkts:
        tx_frame = await tb.xgmii_sink.recv()

        tx_pkt = Ether(bytes(tx_frame.get_payload()))

        tb.log.info("TX packet: %s", repr(tx_pkt))

        if tx_pkt.type == 0x8808:
            tx_pfc_cnt += 1
        else:
            test_pkt = test_tx_pkts.pop(0)
            # check prefix as frame gets zero-padded
            assert bytes(tx_pkt).find(bytes(test_pkt)) == 0

    assert tx_pfc_cnt == 9

    assert tb.axis_sink.empty()
    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


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

    for test in [run_test_tx_underrun, run_test_tx_error]:

        factory = TestFactory(test)
        factory.add_option("ifg", [12])
        factory.generate_tests()

    if cocotb.top.PFC_ENABLE.value:
        for test in [run_test_lfc, run_test_pfc]:
            factory = TestFactory(test)
            factory.add_option("ifg", [12])
            factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize(("enable_dic", "pfc_en"), [(1, 1), (1, 0), (0, 0)])
@pytest.mark.parametrize("data_width", [32, 64])
def test_eth_mac_10g(request, data_width, enable_dic, pfc_en):
    dut = "eth_mac_10g"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "axis_xgmii_rx_32.v"),
        os.path.join(rtl_dir, "axis_xgmii_rx_64.v"),
        os.path.join(rtl_dir, "axis_xgmii_tx_32.v"),
        os.path.join(rtl_dir, "axis_xgmii_tx_64.v"),
        os.path.join(rtl_dir, "mac_ctrl_rx.v"),
        os.path.join(rtl_dir, "mac_ctrl_tx.v"),
        os.path.join(rtl_dir, "mac_pause_ctrl_rx.v"),
        os.path.join(rtl_dir, "mac_pause_ctrl_tx.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['CTRL_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['ENABLE_PADDING'] = 1
    parameters['ENABLE_DIC'] = enable_dic
    parameters['MIN_FRAME_LENGTH'] = 64
    parameters['PTP_TS_ENABLE'] = 1
    parameters['PTP_TS_FMT_TOD'] = 1
    parameters['PTP_TS_WIDTH'] = 96 if parameters['PTP_TS_FMT_TOD'] else 64
    parameters['TX_PTP_TS_CTRL_IN_TUSER'] = parameters['PTP_TS_ENABLE']
    parameters['TX_PTP_TAG_ENABLE'] = parameters['PTP_TS_ENABLE']
    parameters['TX_PTP_TAG_WIDTH'] = 16
    parameters['TX_USER_WIDTH'] = ((parameters['TX_PTP_TAG_WIDTH'] if parameters['TX_PTP_TAG_ENABLE'] else 0) + (1 if parameters['TX_PTP_TS_CTRL_IN_TUSER'] else 0) if parameters['PTP_TS_ENABLE'] else 0) + 1
    parameters['RX_USER_WIDTH'] = (parameters['PTP_TS_WIDTH'] if parameters['PTP_TS_ENABLE'] else 0) + 1
    parameters['PFC_ENABLE'] = pfc_en
    parameters['PAUSE_ENABLE'] = parameters['PFC_ENABLE']

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
