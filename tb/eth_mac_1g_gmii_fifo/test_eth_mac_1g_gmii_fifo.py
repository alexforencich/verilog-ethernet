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
from cocotb.regression import TestFactory

from cocotbext.eth import GmiiFrame, GmiiPhy
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink


class TB:
    def __init__(self, dut, speed=1000e6):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.gtx_clk, 8, units="ns").start())
        cocotb.start_soon(Clock(dut.logic_clk, 8, units="ns").start())

        self.gmii_phy = GmiiPhy(dut.gmii_txd, dut.gmii_tx_er, dut.gmii_tx_en, dut.mii_tx_clk, dut.gmii_tx_clk,
            dut.gmii_rxd, dut.gmii_rx_er, dut.gmii_rx_dv, dut.gmii_rx_clk, speed=speed)

        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "tx_axis"), dut.logic_clk, dut.logic_rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rx_axis"), dut.logic_clk, dut.logic_rst)

        dut.ifg_delay.setimmediatevalue(0)

    async def reset(self):
        self.dut.gtx_rst.setimmediatevalue(0)
        self.dut.logic_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.gtx_rst <= 1
        self.dut.logic_rst <= 1
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)
        self.dut.gtx_rst <= 0
        self.dut.logic_rst <= 0
        await RisingEdge(self.dut.tx_clk)
        await RisingEdge(self.dut.tx_clk)

    def set_speed(self, speed):
        pass


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.gmii_phy.rx.ifg = ifg
    tb.dut.ifg_delay <= ifg

    tb.set_speed(speed)

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    if speed == 10e6:
        assert dut.speed == 0
    elif speed == 100e6:
        assert dut.speed == 1
    else:
        assert dut.speed == 2

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        test_frame = GmiiFrame.from_payload(test_data)
        await tb.gmii_phy.rx.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.axis_sink.recv()

        assert rx_frame.tdata == test_data
        assert rx_frame.tuser == 0

    assert tb.axis_sink.empty()

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.gmii_phy.rx.ifg = ifg
    tb.dut.ifg_delay <= ifg

    tb.set_speed(speed)

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    if speed == 10e6:
        assert dut.speed == 0
    elif speed == 100e6:
        assert dut.speed == 1
    else:
        assert dut.speed == 2

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.axis_source.send(test_data)

    for test_data in test_frames:
        rx_frame = await tb.gmii_phy.tx.recv()

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()
        assert rx_frame.error is None

    assert tb.gmii_phy.tx.empty()

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
        factory.add_option("speed", [1000e6, 100e6, 10e6])
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


def test_eth_mac_1g_gmii_fifo(request):
    dut = "eth_mac_1g_gmii_fifo"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "eth_mac_1g_gmii.v"),
        os.path.join(rtl_dir, "gmii_phy_if.v"),
        os.path.join(rtl_dir, "ssio_sdr_in.v"),
        os.path.join(rtl_dir, "ssio_sdr_out.v"),
        os.path.join(rtl_dir, "oddr.v"),
        os.path.join(rtl_dir, "eth_mac_1g.v"),
        os.path.join(rtl_dir, "axis_gmii_rx.v"),
        os.path.join(rtl_dir, "axis_gmii_tx.v"),
        os.path.join(rtl_dir, "lfsr.v"),
        os.path.join(axis_rtl_dir, "axis_adapter.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
    ]

    parameters = {}

    parameters['AXIS_DATA_WIDTH'] = 8
    parameters['AXIS_KEEP_ENABLE'] = int(parameters['AXIS_DATA_WIDTH'] > 8)
    parameters['AXIS_KEEP_WIDTH'] = parameters['AXIS_DATA_WIDTH'] // 8
    parameters['ENABLE_PADDING'] = 1
    parameters['MIN_FRAME_LENGTH'] = 64
    parameters['TX_FIFO_DEPTH'] = 16384
    parameters['TX_FRAME_FIFO'] = 1
    parameters['TX_DROP_OVERSIZE_FRAME'] = parameters['TX_FRAME_FIFO']
    parameters['TX_DROP_BAD_FRAME'] = parameters['TX_DROP_OVERSIZE_FRAME']
    parameters['TX_DROP_WHEN_FULL'] = 0
    parameters['RX_FIFO_DEPTH'] = 16384
    parameters['RX_FRAME_FIFO'] = 1
    parameters['RX_DROP_OVERSIZE_FRAME'] = parameters['RX_FRAME_FIFO']
    parameters['RX_DROP_BAD_FRAME'] = parameters['RX_DROP_OVERSIZE_FRAME']
    parameters['RX_DROP_WHEN_FULL'] = parameters['RX_DROP_OVERSIZE_FRAME']

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
