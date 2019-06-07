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
import gmii_ep

module = 'axis_gmii_rx'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 8
    PTP_TS_ENABLE = 0
    PTP_TS_WIDTH = 96
    USER_WIDTH = (PTP_TS_WIDTH if PTP_TS_ENABLE else 0) + 1

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    gmii_rxd = Signal(intbv(0)[DATA_WIDTH:])
    gmii_rx_dv = Signal(bool(0))
    gmii_rx_er = Signal(bool(0))
    ptp_ts = Signal(intbv(0)[PTP_TS_WIDTH:])
    clk_enable = Signal(bool(1))
    mii_select = Signal(bool(0))

    # Outputs
    m_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axis_tvalid = Signal(bool(0))
    m_axis_tlast = Signal(bool(0))
    m_axis_tuser = Signal(intbv(0)[USER_WIDTH:])
    start_packet = Signal(bool(0))
    error_bad_frame = Signal(bool(0))
    error_bad_fcs = Signal(bool(0))

    # sources and sinks
    source = gmii_ep.GMIISource()

    source_logic = source.create_logic(
        clk,
        rst,
        txd=gmii_rxd,
        tx_en=gmii_rx_dv,
        tx_er=gmii_rx_er,
        clk_enable=clk_enable,
        mii_select=mii_select,
        name='source'
    )

    sink = axis_ep.AXIStreamSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        tdata=m_axis_tdata,
        tvalid=m_axis_tvalid,
        tlast=m_axis_tlast,
        tuser=m_axis_tuser,
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

        gmii_rxd=gmii_rxd,
        gmii_rx_dv=gmii_rx_dv,
        gmii_rx_er=gmii_rx_er,

        m_axis_tdata=m_axis_tdata,
        m_axis_tvalid=m_axis_tvalid,
        m_axis_tlast=m_axis_tlast,
        m_axis_tuser=m_axis_tuser,

        ptp_ts=ptp_ts,

        clk_enable=clk_enable,
        mii_select=mii_select,

        start_packet=start_packet,
        error_bad_frame=error_bad_frame,
        error_bad_fcs=error_bad_fcs
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    error_bad_frame_asserted = Signal(bool(0))
    error_bad_fcs_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (error_bad_frame):
            error_bad_frame_asserted.next = 1
        if (error_bad_fcs):
            error_bad_fcs_asserted.next = 1

    clk_enable_rate = Signal(int(0))
    clk_enable_div = Signal(int(0))

    @always(clk.posedge)
    def clk_enable_gen():
        if clk_enable_div.next > 0:
            clk_enable.next = 0
            clk_enable_div.next = clk_enable_div - 1
        else:
            clk_enable.next = 1
            clk_enable_div.next = clk_enable_rate - 1

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

        for rate, mii in [(1, 0), (10, 0), (5, 1)]:
            clk_enable_rate.next = rate
            mii_select.next = mii

            yield delay(100)

            for payload_len in list(range(1,18))+list(range(64,82)):
                yield clk.posedge
                print("test 1: test packet, length %d" % payload_len)
                current_test.next = 1

                test_frame = eth_ep.EthFrame()
                test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame.eth_src_mac = 0x5A5152535455
                test_frame.eth_type = 0x8000
                test_frame.payload = bytearray(range(payload_len))
                test_frame.update_fcs()

                axis_frame = test_frame.build_axis_fcs()
                gmii_frame = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))

                source.send(gmii_frame)

                yield sink.wait()
                rx_frame = sink.recv()

                eth_frame = eth_ep.EthFrame()
                eth_frame.parse_axis(rx_frame)
                eth_frame.update_fcs()

                assert eth_frame == test_frame

                assert sink.empty()

                yield delay(100)

                yield clk.posedge
                print("test 2: back-to-back packets, length %d" % payload_len)
                current_test.next = 2

                test_frame1 = eth_ep.EthFrame()
                test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame1.eth_src_mac = 0x5A5152535455
                test_frame1.eth_type = 0x8000
                test_frame1.payload = bytearray(range(payload_len))
                test_frame1.update_fcs()
                test_frame2 = eth_ep.EthFrame()
                test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame2.eth_src_mac = 0x5A5152535455
                test_frame2.eth_type = 0x8000
                test_frame2.payload = bytearray(range(payload_len))
                test_frame2.update_fcs()

                axis_frame1 = test_frame1.build_axis_fcs()
                axis_frame2 = test_frame2.build_axis_fcs()
                gmii_frame1 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame1))
                gmii_frame2 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame2))

                source.send(gmii_frame1)
                source.send(gmii_frame2)

                yield sink.wait()
                rx_frame = sink.recv()

                eth_frame = eth_ep.EthFrame()
                eth_frame.parse_axis(rx_frame)
                eth_frame.update_fcs()

                assert eth_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                eth_frame = eth_ep.EthFrame()
                eth_frame.parse_axis(rx_frame)
                eth_frame.update_fcs()

                assert eth_frame == test_frame2

                assert sink.empty()

                yield delay(100)

                yield clk.posedge
                print("test 3: truncated frame, length %d" % payload_len)
                current_test.next = 3

                test_frame1 = eth_ep.EthFrame()
                test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame1.eth_src_mac = 0x5A5152535455
                test_frame1.eth_type = 0x8000
                test_frame1.payload = bytearray(range(payload_len))
                test_frame1.update_fcs()
                test_frame2 = eth_ep.EthFrame()
                test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame2.eth_src_mac = 0x5A5152535455
                test_frame2.eth_type = 0x8000
                test_frame2.payload = bytearray(range(payload_len))
                test_frame2.update_fcs()

                axis_frame1 = test_frame1.build_axis_fcs()
                axis_frame2 = test_frame2.build_axis_fcs()

                axis_frame1.data = axis_frame1.data[:-1]

                error_bad_frame_asserted.next = 0
                error_bad_fcs_asserted.next = 0

                gmii_frame1 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame1))
                gmii_frame2 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame2))

                source.send(gmii_frame1)
                source.send(gmii_frame2)

                yield sink.wait()
                rx_frame = sink.recv()

                assert error_bad_frame_asserted
                assert error_bad_fcs_asserted

                assert rx_frame.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                eth_frame = eth_ep.EthFrame()
                eth_frame.parse_axis(rx_frame)
                eth_frame.update_fcs()

                assert eth_frame == test_frame2

                assert sink.empty()

                yield delay(100)

                yield clk.posedge
                print("test 4: errored frame, length %d" % payload_len)
                current_test.next = 4

                test_frame1 = eth_ep.EthFrame()
                test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame1.eth_src_mac = 0x5A5152535455
                test_frame1.eth_type = 0x8000
                test_frame1.payload = bytearray(range(payload_len))
                test_frame1.update_fcs()
                test_frame2 = eth_ep.EthFrame()
                test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
                test_frame2.eth_src_mac = 0x5A5152535455
                test_frame2.eth_type = 0x8000
                test_frame2.payload = bytearray(range(payload_len))
                test_frame2.update_fcs()

                axis_frame1 = test_frame1.build_axis_fcs()
                axis_frame2 = test_frame2.build_axis_fcs()

                error_bad_frame_asserted.next = 0
                error_bad_fcs_asserted.next = 0

                gmii_frame1 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame1))
                gmii_frame2 = gmii_ep.GMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame2))

                gmii_frame1.error = 1

                source.send(gmii_frame1)
                source.send(gmii_frame2)

                yield sink.wait()
                rx_frame = sink.recv()

                assert error_bad_frame_asserted
                assert not error_bad_fcs_asserted

                assert rx_frame.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                eth_frame = eth_ep.EthFrame()
                eth_frame.parse_axis(rx_frame)
                eth_frame.update_fcs()

                assert eth_frame == test_frame2

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
