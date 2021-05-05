#!/usr/bin/env python
"""

Copyright (c) 2018 Alex Forencich

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
import xgmii_ep
import baser_serdes_ep

module = 'eth_phy_10g'
testbench = 'test_%s_64' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/eth_phy_10g_rx.v")
srcs.append("../rtl/eth_phy_10g_rx_if.v")
srcs.append("../rtl/eth_phy_10g_rx_ber_mon.v")
srcs.append("../rtl/eth_phy_10g_rx_frame_sync.v")
srcs.append("../rtl/eth_phy_10g_tx.v")
srcs.append("../rtl/eth_phy_10g_tx_if.v")
srcs.append("../rtl/xgmii_baser_dec_64.v")
srcs.append("../rtl/xgmii_baser_enc_64.v")
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 64
    CTRL_WIDTH = (DATA_WIDTH/8)
    HDR_WIDTH = 2
    BIT_REVERSE = 0
    SCRAMBLER_DISABLE = 0
    PRBS31_ENABLE = 1
    TX_SERDES_PIPELINE = 2
    RX_SERDES_PIPELINE = 2
    BITSLIP_HIGH_CYCLES = 1
    BITSLIP_LOW_CYCLES = 8
    COUNT_125US = 1250/6.4

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    rx_clk = Signal(bool(0))
    rx_rst = Signal(bool(0))
    tx_clk = Signal(bool(0))
    tx_rst = Signal(bool(0))
    xgmii_txd = Signal(intbv(0)[DATA_WIDTH:])
    xgmii_txc = Signal(intbv(0)[CTRL_WIDTH:])
    serdes_rx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr = Signal(intbv(1)[HDR_WIDTH:])
    tx_prbs31_enable = Signal(bool(0))
    rx_prbs31_enable = Signal(bool(0))

    serdes_rx_data_int = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr_int = Signal(intbv(1)[HDR_WIDTH:])

    # Outputs
    xgmii_rxd = Signal(intbv(0)[DATA_WIDTH:])
    xgmii_rxc = Signal(intbv(0)[CTRL_WIDTH:])
    serdes_tx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_tx_hdr = Signal(intbv(0)[HDR_WIDTH:])
    serdes_rx_bitslip = Signal(bool(0))
    rx_error_count = Signal(intbv(0)[7:])
    rx_bad_block = Signal(bool(0))
    rx_block_lock = Signal(bool(0))
    rx_high_ber = Signal(bool(0))

    # sources and sinks
    xgmii_source = xgmii_ep.XGMIISource()

    xgmii_source_logic = xgmii_source.create_logic(
        tx_clk,
        tx_rst,
        txd=xgmii_txd,
        txc=xgmii_txc,
        name='xgmii_source'
    )

    xgmii_sink = xgmii_ep.XGMIISink()

    xgmii_sink_logic = xgmii_sink.create_logic(
        rx_clk,
        rx_rst,
        rxd=xgmii_rxd,
        rxc=xgmii_rxc,
        name='xgmii_sink'
    )

    serdes_source = baser_serdes_ep.BaseRSerdesSource()

    serdes_source_logic = serdes_source.create_logic(
        rx_clk,
        tx_data=serdes_rx_data_int,
        tx_header=serdes_rx_hdr_int,
        name='serdes_source'
    )

    serdes_sink = baser_serdes_ep.BaseRSerdesSink()

    serdes_sink_logic = serdes_sink.create_logic(
        tx_clk,
        rx_data=serdes_tx_data,
        rx_header=serdes_tx_hdr,
        name='serdes_sink'
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
        xgmii_txd=xgmii_txd,
        xgmii_txc=xgmii_txc,
        xgmii_rxd=xgmii_rxd,
        xgmii_rxc=xgmii_rxc,
        serdes_tx_data=serdes_tx_data,
        serdes_tx_hdr=serdes_tx_hdr,
        serdes_rx_data=serdes_rx_data,
        serdes_rx_hdr=serdes_rx_hdr,
        serdes_rx_bitslip=serdes_rx_bitslip,
        rx_error_count=rx_error_count,
        rx_bad_block=rx_bad_block,
        rx_block_lock=rx_block_lock,
        rx_high_ber=rx_high_ber,
        tx_prbs31_enable=tx_prbs31_enable,
        rx_prbs31_enable=rx_prbs31_enable
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        rx_clk.next = not rx_clk
        tx_clk.next = not tx_clk

    load_bit_offset = []

    @instance
    def shift_bits():
        bit_offset = 0
        last_data = 0

        while True:
            yield clk.posedge

            if load_bit_offset:
                bit_offset = load_bit_offset.pop(0)

            if serdes_rx_bitslip:
                bit_offset += 1

            bit_offset = bit_offset % 66

            data = int(serdes_rx_data_int) << 2 | int(serdes_rx_hdr_int)

            out_data = ((last_data | data << 66) >> 66-bit_offset) & 0x3ffffffffffffffff

            last_data = data

            serdes_rx_data.next = out_data >> 2
            serdes_rx_hdr.next = out_data & 3

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        tx_rst.next = 1
        rx_rst.next = 1
        yield clk.posedge
        rst.next = 0
        tx_rst.next = 0
        rx_rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        # testbench stimulus

        # wait for block lock
        while not rx_block_lock:
            yield clk.posedge

        # dump garbage
        while not xgmii_sink.empty():
            xgmii_sink.recv()

        yield clk.posedge
        print("test 1: test RX packet")
        current_test.next = 1

        test_frame = bytearray(range(128))

        xgmii_frame = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame)

        xgmii_source.send(xgmii_frame)

        yield serdes_sink.wait()
        rx_frame = serdes_sink.recv()

        assert rx_frame.data == xgmii_frame.data

        assert xgmii_sink.empty()
        assert serdes_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 2: test TX packet")
        current_test.next = 2

        test_frame = bytearray(range(128))

        xgmii_frame = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame)

        serdes_source.send(xgmii_frame)

        yield xgmii_sink.wait()
        rx_frame = xgmii_sink.recv()

        assert rx_frame.data == xgmii_frame.data

        assert xgmii_sink.empty()
        assert serdes_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
