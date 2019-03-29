#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

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
import mii_ep

module = 'eth_mac_mii'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("../rtl/axis_gmii_rx.v")
srcs.append("../rtl/axis_gmii_tx.v")
srcs.append("../rtl/eth_mac_1g.v")
srcs.append("../rtl/mii_phy_if.v")
srcs.append("../rtl/ssio_sdr_in.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    TARGET = "SIM"
    CLOCK_INPUT_STYLE = "BUFIO2"
    ENABLE_PADDING = 1
    MIN_FRAME_LENGTH = 64

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    tx_axis_tdata = Signal(intbv(0)[8:])
    tx_axis_tvalid = Signal(bool(0))
    tx_axis_tlast = Signal(bool(0))
    tx_axis_tuser = Signal(bool(0))
    mii_rx_clk = Signal(bool(0))
    mii_rxd = Signal(intbv(0)[4:])
    mii_rx_dv = Signal(bool(0))
    mii_rx_er = Signal(bool(0))
    mii_tx_clk = Signal(bool(0))
    ifg_delay = Signal(intbv(0)[8:])

    # Outputs
    rx_clk = Signal(bool(0))
    rx_rst = Signal(bool(0))
    tx_clk = Signal(bool(0))
    tx_rst = Signal(bool(0))
    tx_axis_tready = Signal(bool(0))
    rx_axis_tdata = Signal(intbv(0)[8:])
    rx_axis_tvalid = Signal(bool(0))
    rx_axis_tlast = Signal(bool(0))
    rx_axis_tuser = Signal(bool(0))
    mii_txd = Signal(intbv(0)[4:])
    mii_tx_en = Signal(bool(0))
    mii_tx_er = Signal(bool(0))
    tx_error_underflow = Signal(bool(0))
    rx_error_bad_frame = Signal(bool(0))
    rx_error_bad_fcs = Signal(bool(0))

    # sources and sinks
    axis_source_pause = Signal(bool(0))


    mii_source = mii_ep.MIISource()

    mii_source_logic = mii_source.create_logic(
        mii_rx_clk,
        rst,
        txd=mii_rxd,
        tx_en=mii_rx_dv,
        tx_er=mii_rx_er,
        name='mii_source'
    )

    mii_sink = mii_ep.MIISink()

    mii_sink_logic = mii_sink.create_logic(
        mii_tx_clk,
        rst,
        rxd=mii_txd,
        rx_dv=mii_tx_en,
        rx_er=mii_tx_er,
        name='mii_sink'
    )

    axis_source = axis_ep.AXIStreamSource()

    axis_source_logic = axis_source.create_logic(
        mii_rx_clk, #tx_clk,
        tx_rst,
        tdata=tx_axis_tdata,
        tvalid=tx_axis_tvalid,
        tready=tx_axis_tready,
        tlast=tx_axis_tlast,
        tuser=tx_axis_tuser,
        pause=axis_source_pause,
        name='axis_source'
    )

    axis_sink = axis_ep.AXIStreamSink()

    axis_sink_logic = axis_sink.create_logic(
        mii_rx_clk,
        rx_rst,
        tdata=rx_axis_tdata,
        tvalid=rx_axis_tvalid,
        tlast=rx_axis_tlast,
        tuser=rx_axis_tuser,
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

        rx_clk=rx_clk,
        rx_rst=rx_rst,
        tx_clk=tx_clk,
        tx_rst=tx_rst,

        tx_axis_tdata=tx_axis_tdata,
        tx_axis_tvalid=tx_axis_tvalid,
        tx_axis_tready=tx_axis_tready,
        tx_axis_tlast=tx_axis_tlast,
        tx_axis_tuser=tx_axis_tuser,

        rx_axis_tdata=rx_axis_tdata,
        rx_axis_tvalid=rx_axis_tvalid,
        rx_axis_tlast=rx_axis_tlast,
        rx_axis_tuser=rx_axis_tuser,

        mii_rx_clk=mii_rx_clk,
        mii_rxd=mii_rxd,
        mii_rx_dv=mii_rx_dv,
        mii_rx_er=mii_rx_er,

        mii_tx_clk=mii_tx_clk,
        mii_txd=mii_txd,
        mii_tx_en=mii_tx_en,
        mii_tx_er=mii_tx_er,

        tx_error_underflow=tx_error_underflow,
        rx_error_bad_frame=rx_error_bad_frame,
        rx_error_bad_fcs=rx_error_bad_fcs,

        ifg_delay=ifg_delay
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    phy_clk_hp = Signal(int(20))

    @instance
    def phy_clk_gen():
        while True:
            yield delay(int(phy_clk_hp))
            mii_rx_clk.next = not mii_rx_clk
            mii_tx_clk.next = not mii_rx_clk

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
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        ifg_delay.next = 12

        # testbench stimulus

        for rate in [20, 200]:
            phy_clk_hp.next = rate

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

            mii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))

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

            yield mii_sink.wait()
            rx_frame = mii_sink.recv()

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
