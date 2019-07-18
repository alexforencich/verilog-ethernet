#!/usr/bin/env python
"""

Copyright (c) 2014-2018 Alex Forencich

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

import eth_ep
import ip_ep
import udp_ep

module = 'udp_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/udp_checksum_gen_64.v")
srcs.append("../rtl/udp_ip_rx_64.v")
srcs.append("../rtl/udp_ip_tx_64.v")
srcs.append("../lib/axis/rtl/axis_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    CHECKSUM_PAYLOAD_FIFO_DEPTH = 2048
    CHECKSUM_HEADER_FIFO_DEPTH = 8

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_ip_hdr_valid = Signal(bool(0))
    s_ip_eth_dest_mac = Signal(intbv(0)[48:])
    s_ip_eth_src_mac = Signal(intbv(0)[48:])
    s_ip_eth_type = Signal(intbv(0)[16:])
    s_ip_version = Signal(intbv(0)[4:])
    s_ip_ihl = Signal(intbv(0)[4:])
    s_ip_dscp = Signal(intbv(0)[6:])
    s_ip_ecn = Signal(intbv(0)[2:])
    s_ip_length = Signal(intbv(0)[16:])
    s_ip_identification = Signal(intbv(0)[16:])
    s_ip_flags = Signal(intbv(0)[3:])
    s_ip_fragment_offset = Signal(intbv(0)[13:])
    s_ip_ttl = Signal(intbv(0)[8:])
    s_ip_protocol = Signal(intbv(0)[8:])
    s_ip_header_checksum = Signal(intbv(0)[16:])
    s_ip_source_ip = Signal(intbv(0)[32:])
    s_ip_dest_ip = Signal(intbv(0)[32:])
    s_ip_payload_axis_tdata = Signal(intbv(0)[64:])
    s_ip_payload_axis_tkeep = Signal(intbv(0)[8:])
    s_ip_payload_axis_tvalid = Signal(bool(0))
    s_ip_payload_axis_tlast = Signal(bool(0))
    s_ip_payload_axis_tuser = Signal(bool(0))
    s_udp_hdr_valid = Signal(bool(0))
    s_udp_eth_dest_mac = Signal(intbv(0)[48:])
    s_udp_eth_src_mac = Signal(intbv(0)[48:])
    s_udp_eth_type = Signal(intbv(0)[16:])
    s_udp_ip_version = Signal(intbv(0)[4:])
    s_udp_ip_ihl = Signal(intbv(0)[4:])
    s_udp_ip_dscp = Signal(intbv(0)[6:])
    s_udp_ip_ecn = Signal(intbv(0)[2:])
    s_udp_ip_identification = Signal(intbv(0)[16:])
    s_udp_ip_flags = Signal(intbv(0)[3:])
    s_udp_ip_fragment_offset = Signal(intbv(0)[13:])
    s_udp_ip_ttl = Signal(intbv(0)[8:])
    s_udp_ip_header_checksum = Signal(intbv(0)[16:])
    s_udp_ip_source_ip = Signal(intbv(0)[32:])
    s_udp_ip_dest_ip = Signal(intbv(0)[32:])
    s_udp_source_port = Signal(intbv(0)[16:])
    s_udp_dest_port = Signal(intbv(0)[16:])
    s_udp_length = Signal(intbv(0)[16:])
    s_udp_checksum = Signal(intbv(0)[16:])
    s_udp_payload_axis_tdata = Signal(intbv(0)[64:])
    s_udp_payload_axis_tkeep = Signal(intbv(0)[8:])
    s_udp_payload_axis_tvalid = Signal(bool(0))
    s_udp_payload_axis_tlast = Signal(bool(0))
    s_udp_payload_axis_tuser = Signal(bool(0))
    m_ip_payload_axis_tready = Signal(bool(0))
    m_ip_hdr_ready = Signal(bool(0))
    m_udp_hdr_ready = Signal(bool(0))
    m_udp_payload_axis_tready = Signal(bool(0))

    # Outputs
    s_ip_hdr_ready = Signal(bool(0))
    s_ip_payload_axis_tready = Signal(bool(0))
    s_udp_hdr_ready = Signal(bool(0))
    s_udp_payload_axis_tready = Signal(bool(0))
    m_ip_hdr_valid = Signal(bool(0))
    m_ip_eth_dest_mac = Signal(intbv(0)[48:])
    m_ip_eth_src_mac = Signal(intbv(0)[48:])
    m_ip_eth_type = Signal(intbv(0)[16:])
    m_ip_version = Signal(intbv(0)[4:])
    m_ip_ihl = Signal(intbv(0)[4:])
    m_ip_dscp = Signal(intbv(0)[6:])
    m_ip_ecn = Signal(intbv(0)[2:])
    m_ip_length = Signal(intbv(0)[16:])
    m_ip_identification = Signal(intbv(0)[16:])
    m_ip_flags = Signal(intbv(0)[3:])
    m_ip_fragment_offset = Signal(intbv(0)[13:])
    m_ip_ttl = Signal(intbv(0)[8:])
    m_ip_protocol = Signal(intbv(0)[8:])
    m_ip_header_checksum = Signal(intbv(0)[16:])
    m_ip_source_ip = Signal(intbv(0)[32:])
    m_ip_dest_ip = Signal(intbv(0)[32:])
    m_ip_payload_axis_tdata = Signal(intbv(0)[64:])
    m_ip_payload_axis_tkeep = Signal(intbv(0)[8:])
    m_ip_payload_axis_tvalid = Signal(bool(0))
    m_ip_payload_axis_tlast = Signal(bool(0))
    m_ip_payload_axis_tuser = Signal(bool(0))
    m_udp_hdr_valid = Signal(bool(0))
    m_udp_eth_dest_mac = Signal(intbv(0)[48:])
    m_udp_eth_src_mac = Signal(intbv(0)[48:])
    m_udp_eth_type = Signal(intbv(0)[16:])
    m_udp_ip_version = Signal(intbv(0)[4:])
    m_udp_ip_ihl = Signal(intbv(0)[4:])
    m_udp_ip_dscp = Signal(intbv(0)[6:])
    m_udp_ip_ecn = Signal(intbv(0)[2:])
    m_udp_ip_length = Signal(intbv(0)[16:])
    m_udp_ip_identification = Signal(intbv(0)[16:])
    m_udp_ip_flags = Signal(intbv(0)[3:])
    m_udp_ip_fragment_offset = Signal(intbv(0)[13:])
    m_udp_ip_ttl = Signal(intbv(0)[8:])
    m_udp_ip_protocol = Signal(intbv(0)[8:])
    m_udp_ip_header_checksum = Signal(intbv(0)[16:])
    m_udp_ip_source_ip = Signal(intbv(0)[32:])
    m_udp_ip_dest_ip = Signal(intbv(0)[32:])
    m_udp_source_port = Signal(intbv(0)[16:])
    m_udp_dest_port = Signal(intbv(0)[16:])
    m_udp_length = Signal(intbv(0)[16:])
    m_udp_checksum = Signal(intbv(0)[16:])
    m_udp_payload_axis_tdata = Signal(intbv(0)[64:])
    m_udp_payload_axis_tkeep = Signal(intbv(0)[8:])
    m_udp_payload_axis_tvalid = Signal(bool(0))
    m_udp_payload_axis_tlast = Signal(bool(0))
    m_udp_payload_axis_tuser = Signal(bool(0))
    rx_busy = Signal(bool(0))
    tx_busy = Signal(bool(0))
    rx_error_header_early_termination = Signal(bool(0))
    rx_error_payload_early_termination = Signal(bool(0))
    tx_error_payload_early_termination = Signal(bool(0))

    # sources and sinks
    ip_source_pause = Signal(bool(0))
    ip_sink_pause = Signal(bool(0))
    udp_source_pause = Signal(bool(0))
    udp_sink_pause = Signal(bool(0))

    ip_source = ip_ep.IPFrameSource()

    ip_source_logic = ip_source.create_logic(
        clk,
        rst,
        ip_hdr_ready=s_ip_hdr_ready,
        ip_hdr_valid=s_ip_hdr_valid,
        eth_dest_mac=s_ip_eth_dest_mac,
        eth_src_mac=s_ip_eth_src_mac,
        eth_type=s_ip_eth_type,
        ip_version=s_ip_version,
        ip_ihl=s_ip_ihl,
        ip_dscp=s_ip_dscp,
        ip_ecn=s_ip_ecn,
        ip_length=s_ip_length,
        ip_identification=s_ip_identification,
        ip_flags=s_ip_flags,
        ip_fragment_offset=s_ip_fragment_offset,
        ip_ttl=s_ip_ttl,
        ip_protocol=s_ip_protocol,
        ip_header_checksum=s_ip_header_checksum,
        ip_source_ip=s_ip_source_ip,
        ip_dest_ip=s_ip_dest_ip,
        ip_payload_tdata=s_ip_payload_axis_tdata,
        ip_payload_tkeep=s_ip_payload_axis_tkeep,
        ip_payload_tvalid=s_ip_payload_axis_tvalid,
        ip_payload_tready=s_ip_payload_axis_tready,
        ip_payload_tlast=s_ip_payload_axis_tlast,
        ip_payload_tuser=s_ip_payload_axis_tuser,
        pause=ip_source_pause,
        name='ip_source'
    )

    ip_sink = ip_ep.IPFrameSink()

    ip_sink_logic = ip_sink.create_logic(
        clk,
        rst,
        ip_hdr_ready=m_ip_hdr_ready,
        ip_hdr_valid=m_ip_hdr_valid,
        eth_dest_mac=m_ip_eth_dest_mac,
        eth_src_mac=m_ip_eth_src_mac,
        eth_type=m_ip_eth_type,
        ip_version=m_ip_version,
        ip_ihl=m_ip_ihl,
        ip_dscp=m_ip_dscp,
        ip_ecn=m_ip_ecn,
        ip_length=m_ip_length,
        ip_identification=m_ip_identification,
        ip_flags=m_ip_flags,
        ip_fragment_offset=m_ip_fragment_offset,
        ip_ttl=m_ip_ttl,
        ip_protocol=m_ip_protocol,
        ip_header_checksum=m_ip_header_checksum,
        ip_source_ip=m_ip_source_ip,
        ip_dest_ip=m_ip_dest_ip,
        ip_payload_tdata=m_ip_payload_axis_tdata,
        ip_payload_tkeep=m_ip_payload_axis_tkeep,
        ip_payload_tvalid=m_ip_payload_axis_tvalid,
        ip_payload_tready=m_ip_payload_axis_tready,
        ip_payload_tlast=m_ip_payload_axis_tlast,
        ip_payload_tuser=m_ip_payload_axis_tuser,
        pause=ip_sink_pause,
        name='ip_sink'
    )

    udp_source = udp_ep.UDPFrameSource()

    udp_source_logic = udp_source.create_logic(
        clk,
        rst,
        udp_hdr_ready=s_udp_hdr_ready,
        udp_hdr_valid=s_udp_hdr_valid,
        eth_dest_mac=s_udp_eth_dest_mac,
        eth_src_mac=s_udp_eth_src_mac,
        eth_type=s_udp_eth_type,
        ip_version=s_udp_ip_version,
        ip_ihl=s_udp_ip_ihl,
        ip_dscp=s_udp_ip_dscp,
        ip_ecn=s_udp_ip_ecn,
        ip_identification=s_udp_ip_identification,
        ip_flags=s_udp_ip_flags,
        ip_fragment_offset=s_udp_ip_fragment_offset,
        ip_ttl=s_udp_ip_ttl,
        ip_header_checksum=s_udp_ip_header_checksum,
        ip_source_ip=s_udp_ip_source_ip,
        ip_dest_ip=s_udp_ip_dest_ip,
        udp_source_port=s_udp_source_port,
        udp_dest_port=s_udp_dest_port,
        udp_length=s_udp_length,
        udp_checksum=s_udp_checksum,
        udp_payload_tdata=s_udp_payload_axis_tdata,
        udp_payload_tkeep=s_udp_payload_axis_tkeep,
        udp_payload_tvalid=s_udp_payload_axis_tvalid,
        udp_payload_tready=s_udp_payload_axis_tready,
        udp_payload_tlast=s_udp_payload_axis_tlast,
        udp_payload_tuser=s_udp_payload_axis_tuser,
        pause=udp_source_pause,
        name='udp_source'
    )

    udp_sink = udp_ep.UDPFrameSink()

    udp_sink_logic = udp_sink.create_logic(
        clk,
        rst,
        udp_hdr_ready=m_udp_hdr_ready,
        udp_hdr_valid=m_udp_hdr_valid,
        eth_dest_mac=m_udp_eth_dest_mac,
        eth_src_mac=m_udp_eth_src_mac,
        eth_type=m_udp_eth_type,
        ip_version=m_udp_ip_version,
        ip_ihl=m_udp_ip_ihl,
        ip_dscp=m_udp_ip_dscp,
        ip_ecn=m_udp_ip_ecn,
        ip_length=m_udp_ip_length,
        ip_identification=m_udp_ip_identification,
        ip_flags=m_udp_ip_flags,
        ip_fragment_offset=m_udp_ip_fragment_offset,
        ip_ttl=m_udp_ip_ttl,
        ip_protocol=m_udp_ip_protocol,
        ip_header_checksum=m_udp_ip_header_checksum,
        ip_source_ip=m_udp_ip_source_ip,
        ip_dest_ip=m_udp_ip_dest_ip,
        udp_source_port=m_udp_source_port,
        udp_dest_port=m_udp_dest_port,
        udp_length=m_udp_length,
        udp_checksum=m_udp_checksum,
        udp_payload_tdata=m_udp_payload_axis_tdata,
        udp_payload_tkeep=m_udp_payload_axis_tkeep,
        udp_payload_tvalid=m_udp_payload_axis_tvalid,
        udp_payload_tready=m_udp_payload_axis_tready,
        udp_payload_tlast=m_udp_payload_axis_tlast,
        udp_payload_tuser=m_udp_payload_axis_tuser,
        pause=udp_sink_pause,
        name='udp_sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        s_ip_hdr_valid=s_ip_hdr_valid,
        s_ip_hdr_ready=s_ip_hdr_ready,
        s_ip_eth_dest_mac=s_ip_eth_dest_mac,
        s_ip_eth_src_mac=s_ip_eth_src_mac,
        s_ip_eth_type=s_ip_eth_type,
        s_ip_version=s_ip_version,
        s_ip_ihl=s_ip_ihl,
        s_ip_dscp=s_ip_dscp,
        s_ip_ecn=s_ip_ecn,
        s_ip_length=s_ip_length,
        s_ip_identification=s_ip_identification,
        s_ip_flags=s_ip_flags,
        s_ip_fragment_offset=s_ip_fragment_offset,
        s_ip_ttl=s_ip_ttl,
        s_ip_protocol=s_ip_protocol,
        s_ip_header_checksum=s_ip_header_checksum,
        s_ip_source_ip=s_ip_source_ip,
        s_ip_dest_ip=s_ip_dest_ip,
        s_ip_payload_axis_tdata=s_ip_payload_axis_tdata,
        s_ip_payload_axis_tkeep=s_ip_payload_axis_tkeep,
        s_ip_payload_axis_tvalid=s_ip_payload_axis_tvalid,
        s_ip_payload_axis_tready=s_ip_payload_axis_tready,
        s_ip_payload_axis_tlast=s_ip_payload_axis_tlast,
        s_ip_payload_axis_tuser=s_ip_payload_axis_tuser,

        m_ip_hdr_valid=m_ip_hdr_valid,
        m_ip_hdr_ready=m_ip_hdr_ready,
        m_ip_eth_dest_mac=m_ip_eth_dest_mac,
        m_ip_eth_src_mac=m_ip_eth_src_mac,
        m_ip_eth_type=m_ip_eth_type,
        m_ip_version=m_ip_version,
        m_ip_ihl=m_ip_ihl,
        m_ip_dscp=m_ip_dscp,
        m_ip_ecn=m_ip_ecn,
        m_ip_length=m_ip_length,
        m_ip_identification=m_ip_identification,
        m_ip_flags=m_ip_flags,
        m_ip_fragment_offset=m_ip_fragment_offset,
        m_ip_ttl=m_ip_ttl,
        m_ip_protocol=m_ip_protocol,
        m_ip_header_checksum=m_ip_header_checksum,
        m_ip_source_ip=m_ip_source_ip,
        m_ip_dest_ip=m_ip_dest_ip,
        m_ip_payload_axis_tdata=m_ip_payload_axis_tdata,
        m_ip_payload_axis_tkeep=m_ip_payload_axis_tkeep,
        m_ip_payload_axis_tvalid=m_ip_payload_axis_tvalid,
        m_ip_payload_axis_tready=m_ip_payload_axis_tready,
        m_ip_payload_axis_tlast=m_ip_payload_axis_tlast,
        m_ip_payload_axis_tuser=m_ip_payload_axis_tuser,

        s_udp_hdr_valid=s_udp_hdr_valid,
        s_udp_hdr_ready=s_udp_hdr_ready,
        s_udp_eth_dest_mac=s_udp_eth_dest_mac,
        s_udp_eth_src_mac=s_udp_eth_src_mac,
        s_udp_eth_type=s_udp_eth_type,
        s_udp_ip_version=s_udp_ip_version,
        s_udp_ip_ihl=s_udp_ip_ihl,
        s_udp_ip_dscp=s_udp_ip_dscp,
        s_udp_ip_ecn=s_udp_ip_ecn,
        s_udp_ip_identification=s_udp_ip_identification,
        s_udp_ip_flags=s_udp_ip_flags,
        s_udp_ip_fragment_offset=s_udp_ip_fragment_offset,
        s_udp_ip_ttl=s_udp_ip_ttl,
        s_udp_ip_header_checksum=s_udp_ip_header_checksum,
        s_udp_ip_source_ip=s_udp_ip_source_ip,
        s_udp_ip_dest_ip=s_udp_ip_dest_ip,
        s_udp_source_port=s_udp_source_port,
        s_udp_dest_port=s_udp_dest_port,
        s_udp_length=s_udp_length,
        s_udp_checksum=s_udp_checksum,
        s_udp_payload_axis_tdata=s_udp_payload_axis_tdata,
        s_udp_payload_axis_tkeep=s_udp_payload_axis_tkeep,
        s_udp_payload_axis_tvalid=s_udp_payload_axis_tvalid,
        s_udp_payload_axis_tready=s_udp_payload_axis_tready,
        s_udp_payload_axis_tlast=s_udp_payload_axis_tlast,
        s_udp_payload_axis_tuser=s_udp_payload_axis_tuser,

        m_udp_hdr_valid=m_udp_hdr_valid,
        m_udp_hdr_ready=m_udp_hdr_ready,
        m_udp_eth_dest_mac=m_udp_eth_dest_mac,
        m_udp_eth_src_mac=m_udp_eth_src_mac,
        m_udp_eth_type=m_udp_eth_type,
        m_udp_ip_version=m_udp_ip_version,
        m_udp_ip_ihl=m_udp_ip_ihl,
        m_udp_ip_dscp=m_udp_ip_dscp,
        m_udp_ip_ecn=m_udp_ip_ecn,
        m_udp_ip_length=m_udp_ip_length,
        m_udp_ip_identification=m_udp_ip_identification,
        m_udp_ip_flags=m_udp_ip_flags,
        m_udp_ip_fragment_offset=m_udp_ip_fragment_offset,
        m_udp_ip_ttl=m_udp_ip_ttl,
        m_udp_ip_protocol=m_udp_ip_protocol,
        m_udp_ip_header_checksum=m_udp_ip_header_checksum,
        m_udp_ip_source_ip=m_udp_ip_source_ip,
        m_udp_ip_dest_ip=m_udp_ip_dest_ip,
        m_udp_source_port=m_udp_source_port,
        m_udp_dest_port=m_udp_dest_port,
        m_udp_length=m_udp_length,
        m_udp_checksum=m_udp_checksum,
        m_udp_payload_axis_tdata=m_udp_payload_axis_tdata,
        m_udp_payload_axis_tkeep=m_udp_payload_axis_tkeep,
        m_udp_payload_axis_tvalid=m_udp_payload_axis_tvalid,
        m_udp_payload_axis_tready=m_udp_payload_axis_tready,
        m_udp_payload_axis_tlast=m_udp_payload_axis_tlast,
        m_udp_payload_axis_tuser=m_udp_payload_axis_tuser,

        rx_busy=rx_busy,
        tx_busy=tx_busy,
        rx_error_header_early_termination=rx_error_header_early_termination,
        rx_error_payload_early_termination=rx_error_payload_early_termination,
        tx_error_payload_early_termination=tx_error_payload_early_termination
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    rx_error_header_early_termination_asserted = Signal(bool(0))
    rx_error_payload_early_termination_asserted = Signal(bool(0))
    tx_error_payload_early_termination_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (rx_error_header_early_termination):
            rx_error_header_early_termination_asserted.next = 1
        if (rx_error_payload_early_termination):
            rx_error_payload_early_termination_asserted.next = 1
        if (tx_error_payload_early_termination):
            tx_error_payload_early_termination_asserted.next = 1

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

        yield clk.posedge
        print("test 1: test UDP RX packet")
        current_test.next = 1

        test_frame = udp_ep.UDPFrame()
        test_frame.eth_dest_mac = 0x5A5152535455
        test_frame.eth_src_mac = 0xDAD1D2D3D4D5
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 5
        test_frame.ip_dscp = 0
        test_frame.ip_ecn = 0
        test_frame.ip_length = None
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80165
        test_frame.ip_dest_ip = 0xc0a80164
        test_frame.udp_source_port = 1234
        test_frame.udp_dest_port = 5678
        test_frame.payload = bytearray(range(32))
        test_frame.build()
        ip_frame = test_frame.build_ip()

        ip_source.send(ip_frame)

        yield udp_sink.wait()
        rx_frame = udp_sink.recv()

        assert rx_frame == test_frame

        assert ip_source.empty()
        assert ip_sink.empty()
        assert udp_source.empty()
        assert udp_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 2: test UDP TX packet")
        current_test.next = 2

        test_frame = udp_ep.UDPFrame()
        test_frame.eth_dest_mac = 0x5A5152535455
        test_frame.eth_src_mac = 0xDAD1D2D3D4D5
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 5
        test_frame.ip_dscp = 0
        test_frame.ip_ecn = 0
        test_frame.ip_length = None
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80165
        test_frame.ip_dest_ip = 0xc0a80164
        test_frame.udp_source_port = 1234
        test_frame.udp_dest_port = 5678
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        udp_source.send(test_frame)

        yield ip_sink.wait()
        rx_frame = ip_sink.recv()

        check_frame = udp_ep.UDPFrame()
        check_frame.parse_ip(rx_frame)

        assert check_frame == test_frame

        assert ip_source.empty()
        assert ip_sink.empty()
        assert udp_source.empty()
        assert udp_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

