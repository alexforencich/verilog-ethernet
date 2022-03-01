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

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.eth import XgmiiSource, XgmiiSink, XgmiiFrame

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

        cocotb.start_soon(Clock(dut.tx_clk, 6.4, units="ns").start())
        cocotb.start_soon(Clock(dut.rx_clk, 6.4, units="ns").start())

        self.xgmii_source = XgmiiSource(dut.xgmii_txd, dut.xgmii_txc, dut.tx_clk, dut.tx_rst)
        self.xgmii_sink = XgmiiSink(dut.xgmii_rxd, dut.xgmii_rxc, dut.rx_clk, dut.rx_rst)

        self.serdes_source = BaseRSerdesSource(dut.serdes_rx_data, dut.serdes_rx_hdr, dut.rx_clk, slip=dut.serdes_rx_bitslip)
        self.serdes_sink = BaseRSerdesSink(dut.serdes_tx_data, dut.serdes_tx_hdr, dut.tx_clk)

        dut.tx_prbs31_enable.setimmediatevalue(0)
        dut.rx_prbs31_enable.setimmediatevalue(0)

    async def reset(self):
        self.dut.tx_rst.setimmediatevalue(0)
        self.dut.rx_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.tx_rst <= 1
        self.dut.rx_rst <= 1
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.tx_rst <= 0
        self.dut.rx_rst <= 0
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.serdes_source.ifg = ifg

    await tb.reset()

    tb.log.info("Wait for block lock")
    while not dut.rx_block_lock.value.integer:
        await RisingEdge(dut.rx_clk)

    # clear out sink buffer
    tb.xgmii_sink.clear()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        test_frame = XgmiiFrame.from_payload(test_data)
        await tb.serdes_source.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.xgmii_sink.recv()

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()

    assert tb.xgmii_sink.empty()

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12):

    tb = TB(dut)

    tb.xgmii_source.ifg = ifg
    tb.serdes_source.ifg = ifg

    await tb.reset()

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        test_frame = XgmiiFrame.from_payload(test_data)
        await tb.xgmii_source.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.serdes_sink.recv()

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()

    assert tb.serdes_sink.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


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
        factory.add_option("ifg", [12])
        factory.generate_tests()

    factory = TestFactory(run_test_rx_frame_sync)
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_eth_phy_10g(request):
    dut = "eth_phy_10g"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, f"{dut}_rx.v"),
        os.path.join(rtl_dir, f"{dut}_rx_if.v"),
        os.path.join(rtl_dir, f"{dut}_rx_ber_mon.v"),
        os.path.join(rtl_dir, f"{dut}_rx_frame_sync.v"),
        os.path.join(rtl_dir, f"{dut}_rx_watchdog.v"),
        os.path.join(rtl_dir, f"{dut}_tx.v"),
        os.path.join(rtl_dir, f"{dut}_tx_if.v"),
        os.path.join(rtl_dir, "xgmii_baser_dec_64.v"),
        os.path.join(rtl_dir, "xgmii_baser_enc_64.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = 64
    parameters['CTRL_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['HDR_WIDTH'] = 2
    parameters['BIT_REVERSE'] = 0
    parameters['SCRAMBLER_DISABLE'] = 0
    parameters['PRBS31_ENABLE'] = 1
    parameters['TX_SERDES_PIPELINE'] = 2
    parameters['RX_SERDES_PIPELINE'] = 2
    parameters['BITSLIP_HIGH_CYCLES'] = 1
    parameters['BITSLIP_LOW_CYCLES'] = 8
    parameters['COUNT_125US'] = int(1250/6.4)

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    extra_env['COCOTB_RESOLVE_X'] = 'RANDOM'

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
