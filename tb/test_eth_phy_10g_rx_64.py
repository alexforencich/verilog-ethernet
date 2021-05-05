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

module = 'eth_phy_10g_rx'
testbench = 'test_%s_64' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/eth_phy_10g_rx_if.v")
srcs.append("../rtl/eth_phy_10g_rx_ber_mon.v")
srcs.append("../rtl/eth_phy_10g_rx_frame_sync.v")
srcs.append("../rtl/xgmii_baser_dec_64.v")
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def prbs31(width=8, state=0x7fffffff):
    while True:
        out = 0
        for i in range(width):
            if bool(state & 0x08000000) ^ bool(state & 0x40000000):
                state = ((state & 0x3fffffff) << 1) | 1
                out = out | 2**i
            else:
                state = (state & 0x3fffffff) << 1
        yield ~out & (2**width-1)

def bench():

    # Parameters
    DATA_WIDTH = 64
    CTRL_WIDTH = (DATA_WIDTH/8)
    HDR_WIDTH = 2
    BIT_REVERSE = 0
    SCRAMBLER_DISABLE = 0
    PRBS31_ENABLE = 1
    SERDES_PIPELINE = 2
    BITSLIP_HIGH_CYCLES = 1
    BITSLIP_LOW_CYCLES = 8
    COUNT_125US = 1250/6.4

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    serdes_rx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr = Signal(intbv(1)[HDR_WIDTH:])
    rx_prbs31_enable = Signal(bool(0))

    serdes_rx_data_int = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr_int = Signal(intbv(1)[HDR_WIDTH:])

    # Outputs
    xgmii_rxd = Signal(intbv(0)[DATA_WIDTH:])
    xgmii_rxc = Signal(intbv(0)[CTRL_WIDTH:])
    serdes_rx_bitslip = Signal(bool(0))
    rx_error_count = Signal(intbv(0)[7:])
    rx_bad_block = Signal(bool(0))
    rx_block_lock = Signal(bool(0))
    rx_high_ber = Signal(bool(0))

    # sources and sinks
    source = baser_serdes_ep.BaseRSerdesSource()

    source_logic = source.create_logic(
        clk,
        tx_data=serdes_rx_data_int,
        tx_header=serdes_rx_hdr_int,
        name='source'
    )

    sink = xgmii_ep.XGMIISink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        rxd=xgmii_rxd,
        rxc=xgmii_rxc,
        name='sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        xgmii_rxd=xgmii_rxd,
        xgmii_rxc=xgmii_rxc,
        serdes_rx_data=serdes_rx_data,
        serdes_rx_hdr=serdes_rx_hdr,
        serdes_rx_bitslip=serdes_rx_bitslip,
        rx_error_count=rx_error_count,
        rx_bad_block=rx_bad_block,
        rx_block_lock=rx_block_lock,
        rx_high_ber=rx_high_ber,
        rx_prbs31_enable=rx_prbs31_enable
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    load_bit_offset = []
    prbs_en = Signal(bool(0))

    @instance
    def shift_bits():
        bit_offset = 0
        last_data = 0

        prbs_gen = prbs31(66)

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

            if prbs_en:
                out_data = next(prbs_gen)

            serdes_rx_data.next = out_data >> 2
            serdes_rx_hdr.next = out_data & 3

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

        # testbench stimulus

        # wait for block lock
        while not rx_block_lock:
            yield clk.posedge

        # dump garbage
        while not sink.empty():
            sink.recv()

        for payload_len in list(range(16,34)):
            yield clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = bytearray(range(payload_len))

            xgmii_frame = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame)

            source.send(xgmii_frame)

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame.data

            assert sink.empty()

            yield delay(100)

            yield clk.posedge
            print("test 2: back-to-back packets, length %d" % payload_len)
            current_test.next = 2

            test_frame1 = bytearray(range(payload_len))
            test_frame2 = bytearray(range(payload_len))

            xgmii_frame1 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame1)
            xgmii_frame2 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame2)

            source.send(xgmii_frame1)
            source.send(xgmii_frame2)

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame1.data

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame2.data

            assert sink.empty()

            yield delay(100)

            yield clk.posedge
            print("test 3: errored frame, length %d" % payload_len)
            current_test.next = 3

            test_frame1 = bytearray(range(payload_len))
            test_frame2 = bytearray(range(payload_len))

            xgmii_frame1 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame1)
            xgmii_frame2 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame2)

            xgmii_frame1.error = 1

            source.send(xgmii_frame1)
            source.send(xgmii_frame2)

            yield sink.wait()
            rx_frame = sink.recv()

            #assert rx_frame.data == xgmii_frame1.data

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame2.data

            assert sink.empty()

            yield delay(100)

        yield clk.posedge
        print("test 4: test frame sync")
        current_test.next = 4

        assert rx_block_lock

        load_bit_offset.append(33)

        yield delay(600)

        assert not rx_block_lock
        assert rx_high_ber

        yield delay(3000)

        assert rx_block_lock

        yield delay(2000)

        assert not rx_high_ber

        yield delay(100)

        yield clk.posedge
        print("test 5: PRBS31 check")
        current_test.next = 5

        rx_prbs31_enable.next = True

        yield delay(100)

        for k in range(20):
            yield clk.posedge
            assert rx_error_count > 0

        prbs_en.next = True

        yield delay(100)

        for k in range(20):
            yield clk.posedge
            assert rx_error_count == 0

        prbs_en.next = False

        rx_prbs31_enable.next = False

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
