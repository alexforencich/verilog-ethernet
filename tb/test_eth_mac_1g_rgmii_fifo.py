#!/usr/bin/env python
"""

Copyright (c) 2015-2018 Alex Forencich

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

from myhdl import *
import os

import axis_ep
import eth_ep
import rgmii_ep

module = 'eth_mac_1g_rgmii_fifo'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("../rtl/axis_gmii_rx.v")
srcs.append("../rtl/axis_gmii_tx.v")
srcs.append("../rtl/eth_mac_1g.v")
srcs.append("../rtl/eth_mac_1g_rgmii.v")
srcs.append("../rtl/rgmii_phy_if.v")
srcs.append("../rtl/iddr.v")
srcs.append("../rtl/oddr.v")
srcs.append("../rtl/ssio_ddr_in.v")
srcs.append("../rtl/ssio_ddr_out.v")
srcs.append("../lib/axis/rtl/axis_async_fifo.v")
srcs.append("../lib/axis/rtl/axis_async_fifo_adapter.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TARGET = "SIM"
    IODDR_STYLE = "IODDR2"
    CLOCK_INPUT_STYLE = "BUFIO2"
    USE_CLK90 = "TRUE"
    AXIS_DATA_WIDTH = 8
    AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8)
    AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8)
    ENABLE_PADDING = 1
    MIN_FRAME_LENGTH = 64
    TX_FIFO_DEPTH = 4096
    TX_FIFO_PIPELINE_OUTPUT = 2
    TX_FRAME_FIFO = 1
    TX_DROP_BAD_FRAME = TX_FRAME_FIFO
    TX_DROP_WHEN_FULL = 0
    RX_FIFO_DEPTH = 4096
    RX_FIFO_PIPELINE_OUTPUT = 2
    RX_FRAME_FIFO = 1
    RX_DROP_BAD_FRAME = RX_FRAME_FIFO
    RX_DROP_WHEN_FULL = RX_FRAME_FIFO

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    gtx_clk = Signal(bool(0))
    gtx_clk90 = Signal(bool(0))
    gtx_rst = Signal(bool(0))
    logic_clk = Signal(bool(0))
    logic_rst = Signal(bool(0))
    tx_axis_tdata = Signal(intbv(0)[AXIS_DATA_WIDTH:])
    tx_axis_tkeep = Signal(intbv(1)[AXIS_KEEP_WIDTH:])
    tx_axis_tvalid = Signal(bool(0))
    tx_axis_tlast = Signal(bool(0))
    tx_axis_tuser = Signal(bool(0))
    rx_axis_tready = Signal(bool(0))
    rgmii_rx_clk = Signal(bool(0))
    rgmii_rxd = Signal(intbv(0)[4:])
    rgmii_rx_ctl = Signal(bool(0))
    ifg_delay = Signal(intbv(0)[8:])

    # Outputs
    tx_axis_tready = Signal(bool(0))
    rx_axis_tdata = Signal(intbv(0)[AXIS_DATA_WIDTH:])
    rx_axis_tkeep = Signal(intbv(1)[AXIS_KEEP_WIDTH:])
    rx_axis_tvalid = Signal(bool(0))
    rx_axis_tlast = Signal(bool(0))
    rx_axis_tuser = Signal(bool(0))
    rgmii_tx_clk = Signal(bool(0))
    rgmii_txd = Signal(intbv(0)[4:])
    rgmii_tx_ctl = Signal(bool(0))
    tx_error_underflow = Signal(bool(0))
    tx_fifo_overflow = Signal(bool(0))
    tx_fifo_bad_frame = Signal(bool(0))
    tx_fifo_good_frame = Signal(bool(0))
    rx_error_bad_frame = Signal(bool(0))
    rx_error_bad_fcs = Signal(bool(0))
    rx_fifo_overflow = Signal(bool(0))
    rx_fifo_bad_frame = Signal(bool(0))
    rx_fifo_good_frame = Signal(bool(0))
    speed = Signal(intbv(0)[2:])

    # sources and sinks
    axis_source_pause = Signal(bool(0))
    axis_sink_pause = Signal(bool(0))

    mii_select = Signal(bool(0))

    rgmii_source = rgmii_ep.RGMIISource()

    rgmii_source_logic = rgmii_source.create_logic(
        rgmii_rx_clk,
        rst,
        txd=rgmii_rxd,
        tx_ctl=rgmii_rx_ctl,
        mii_select=mii_select,
        name='rgmii_source'
    )

    rgmii_sink = rgmii_ep.RGMIISink()

    rgmii_sink_logic = rgmii_sink.create_logic(
        rgmii_tx_clk,
        rst,
        rxd=rgmii_txd,
        rx_ctl=rgmii_tx_ctl,
        mii_select=mii_select,
        name='rgmii_sink'
    )

    axis_source = axis_ep.AXIStreamSource()

    axis_source_logic = axis_source.create_logic(
        logic_clk,
        logic_rst,
        tdata=tx_axis_tdata,
        tkeep=tx_axis_tkeep,
        tvalid=tx_axis_tvalid,
        tready=tx_axis_tready,
        tlast=tx_axis_tlast,
        tuser=tx_axis_tuser,
        pause=axis_source_pause,
        name='axis_source'
    )

    axis_sink = axis_ep.AXIStreamSink()

    axis_sink_logic = axis_sink.create_logic(
        logic_clk,
        logic_rst,
        tdata=rx_axis_tdata,
        tkeep=rx_axis_tkeep,
        tvalid=rx_axis_tvalid,
        tready=rx_axis_tready,
        tlast=rx_axis_tlast,
        tuser=rx_axis_tuser,
        pause=axis_sink_pause,
        name='axis_sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        gtx_clk=gtx_clk,
        gtx_clk90=gtx_clk90,
        gtx_rst=gtx_rst,
        logic_clk=logic_clk,
        logic_rst=logic_rst,

        tx_axis_tdata=tx_axis_tdata,
        tx_axis_tkeep=tx_axis_tkeep,
        tx_axis_tvalid=tx_axis_tvalid,
        tx_axis_tready=tx_axis_tready,
        tx_axis_tlast=tx_axis_tlast,
        tx_axis_tuser=tx_axis_tuser,

        rx_axis_tdata=rx_axis_tdata,
        rx_axis_tkeep=rx_axis_tkeep,
        rx_axis_tvalid=rx_axis_tvalid,
        rx_axis_tready=rx_axis_tready,
        rx_axis_tlast=rx_axis_tlast,
        rx_axis_tuser=rx_axis_tuser,

        rgmii_rx_clk=rgmii_rx_clk,
        rgmii_rxd=rgmii_rxd,
        rgmii_rx_ctl=rgmii_rx_ctl,

        rgmii_tx_clk=rgmii_tx_clk,
        rgmii_txd=rgmii_txd,
        rgmii_tx_ctl=rgmii_tx_ctl,

        tx_error_underflow=tx_error_underflow,
        tx_fifo_overflow=tx_fifo_overflow,
        tx_fifo_bad_frame=tx_fifo_bad_frame,
        tx_fifo_good_frame=tx_fifo_good_frame,
        rx_error_bad_frame=rx_error_bad_frame,
        rx_error_bad_fcs=rx_error_bad_fcs,
        rx_fifo_overflow=rx_fifo_overflow,
        rx_fifo_bad_frame=rx_fifo_bad_frame,
        rx_fifo_good_frame=rx_fifo_good_frame,
        speed=speed,

        ifg_delay=ifg_delay
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        gtx_clk.next = not clk
        logic_clk.next = not clk

    @instance
    def clkgen2():
        yield delay(4+2)
        while True:
            gtx_clk90.next = not gtx_clk90
            yield delay(4)

    rx_clk_hp = Signal(int(4))

    @instance
    def rx_clk_gen():
        while True:
            yield delay(int(rx_clk_hp))
            rgmii_rx_clk.next = not rgmii_rx_clk

    rx_error_bad_frame_asserted = Signal(bool(0))
    rx_error_bad_fcs_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (rx_error_bad_frame):
            rx_error_bad_frame_asserted.next = 1
        if (rx_error_bad_fcs):
            rx_error_bad_fcs_asserted.next = 1

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        gtx_rst.next = 1
        logic_rst.next = 1
        yield clk.posedge
        rst.next = 0
        gtx_rst.next = 0
        logic_rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        ifg_delay.next = 12

        # testbench stimulus

        for rate, mii in [(4, 0), (20, 1), (200, 1)]:
            rx_clk_hp.next = rate
            mii_select.next = mii

            yield delay(1000)

            yield clk.posedge
            print("test 1: test rx packet")
            current_test.next = 1

            test_frame = eth_ep.EthFrame()
            test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame.eth_src_mac = 0x5A5152535455
            test_frame.eth_type = 0x8000
            test_frame.payload = bytearray(range(32))
            test_frame.update_fcs()

            axis_frame = test_frame.build_axis_fcs()

            rgmii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))

            yield axis_sink.wait()
            rx_frame = axis_sink.recv()

            eth_frame = eth_ep.EthFrame()
            eth_frame.parse_axis(rx_frame)
            eth_frame.update_fcs()

            assert eth_frame == test_frame

            yield delay(100)

            yield clk.posedge
            print("test 2: test tx packet")
            current_test.next = 2

            test_frame = eth_ep.EthFrame()
            test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame.eth_src_mac = 0x5A5152535455
            test_frame.eth_type = 0x8000
            test_frame.payload = bytearray(range(32))
            test_frame.update_fcs()

            axis_frame = test_frame.build_axis()

            axis_source.send(axis_frame)

            yield rgmii_sink.wait()
            rx_frame = rgmii_sink.recv()

            assert rx_frame.data[0:8] == bytearray(b'\x55\x55\x55\x55\x55\x55\x55\xD5')

            eth_frame = eth_ep.EthFrame()
            eth_frame.parse_axis_fcs(rx_frame.data[8:])

            print(hex(eth_frame.eth_fcs))
            print(hex(eth_frame.calc_fcs()))

            assert len(eth_frame.payload.data) == 46
            assert eth_frame.eth_fcs == eth_frame.calc_fcs()
            assert eth_frame.eth_dest_mac == test_frame.eth_dest_mac
            assert eth_frame.eth_src_mac == test_frame.eth_src_mac
            assert eth_frame.eth_type == test_frame.eth_type
            assert eth_frame.payload.data.index(test_frame.payload.data) == 0

            yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
