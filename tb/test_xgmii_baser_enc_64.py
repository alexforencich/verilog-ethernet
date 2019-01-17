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

module = 'xgmii_baser_enc_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 64
    CTRL_WIDTH = (DATA_WIDTH/8)
    HDR_WIDTH = 2

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    xgmii_txd = Signal(intbv(0)[DATA_WIDTH:])
    xgmii_txc = Signal(intbv(0)[CTRL_WIDTH:])

    # Outputs
    encoded_tx_data = Signal(intbv(0)[DATA_WIDTH:])
    encoded_tx_hdr = Signal(intbv(0)[HDR_WIDTH:])

    # sources and sinks
    source = xgmii_ep.XGMIISource()

    source_logic = source.create_logic(
        clk,
        rst,
        txd=xgmii_txd,
        txc=xgmii_txc,
        name='source'
    )

    sink = baser_serdes_ep.BaseRSerdesSink()

    sink_logic = sink.create_logic(
        clk,
        rx_data=encoded_tx_data,
        rx_header=encoded_tx_hdr,
        scramble=False,
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
        xgmii_txd=xgmii_txd,
        xgmii_txc=xgmii_txc,
        encoded_tx_data=encoded_tx_data,
        encoded_tx_hdr=encoded_tx_hdr
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

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

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
