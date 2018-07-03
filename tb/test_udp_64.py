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

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_ip_hdr_valid = Signal(bool(0))
    input_ip_eth_dest_mac = Signal(intbv(0)[48:])
    input_ip_eth_src_mac = Signal(intbv(0)[48:])
    input_ip_eth_type = Signal(intbv(0)[16:])
    input_ip_version = Signal(intbv(0)[4:])
    input_ip_ihl = Signal(intbv(0)[4:])
    input_ip_dscp = Signal(intbv(0)[6:])
    input_ip_ecn = Signal(intbv(0)[2:])
    input_ip_length = Signal(intbv(0)[16:])
    input_ip_identification = Signal(intbv(0)[16:])
    input_ip_flags = Signal(intbv(0)[3:])
    input_ip_fragment_offset = Signal(intbv(0)[13:])
    input_ip_ttl = Signal(intbv(0)[8:])
    input_ip_protocol = Signal(intbv(0)[8:])
    input_ip_header_checksum = Signal(intbv(0)[16:])
    input_ip_source_ip = Signal(intbv(0)[32:])
    input_ip_dest_ip = Signal(intbv(0)[32:])
    input_ip_payload_tdata = Signal(intbv(0)[64:])
    input_ip_payload_tkeep = Signal(intbv(0)[8:])
    input_ip_payload_tvalid = Signal(bool(0))
    input_ip_payload_tlast = Signal(bool(0))
    input_ip_payload_tuser = Signal(bool(0))
    input_udp_hdr_valid = Signal(bool(0))
    input_udp_eth_dest_mac = Signal(intbv(0)[48:])
    input_udp_eth_src_mac = Signal(intbv(0)[48:])
    input_udp_eth_type = Signal(intbv(0)[16:])
    input_udp_ip_version = Signal(intbv(0)[4:])
    input_udp_ip_ihl = Signal(intbv(0)[4:])
    input_udp_ip_dscp = Signal(intbv(0)[6:])
    input_udp_ip_ecn = Signal(intbv(0)[2:])
    input_udp_ip_identification = Signal(intbv(0)[16:])
    input_udp_ip_flags = Signal(intbv(0)[3:])
    input_udp_ip_fragment_offset = Signal(intbv(0)[13:])
    input_udp_ip_ttl = Signal(intbv(0)[8:])
    input_udp_ip_header_checksum = Signal(intbv(0)[16:])
    input_udp_ip_source_ip = Signal(intbv(0)[32:])
    input_udp_ip_dest_ip = Signal(intbv(0)[32:])
    input_udp_source_port = Signal(intbv(0)[16:])
    input_udp_dest_port = Signal(intbv(0)[16:])
    input_udp_length = Signal(intbv(0)[16:])
    input_udp_checksum = Signal(intbv(0)[16:])
    input_udp_payload_tdata = Signal(intbv(0)[64:])
    input_udp_payload_tkeep = Signal(intbv(0)[8:])
    input_udp_payload_tvalid = Signal(bool(0))
    input_udp_payload_tlast = Signal(bool(0))
    input_udp_payload_tuser = Signal(bool(0))
    output_ip_payload_tready = Signal(bool(0))
    output_ip_hdr_ready = Signal(bool(0))
    output_udp_hdr_ready = Signal(bool(0))
    output_udp_payload_tready = Signal(bool(0))

    # Outputs
    input_ip_hdr_ready = Signal(bool(0))
    input_ip_payload_tready = Signal(bool(0))
    input_udp_hdr_ready = Signal(bool(0))
    input_udp_payload_tready = Signal(bool(0))
    output_ip_hdr_valid = Signal(bool(0))
    output_ip_eth_dest_mac = Signal(intbv(0)[48:])
    output_ip_eth_src_mac = Signal(intbv(0)[48:])
    output_ip_eth_type = Signal(intbv(0)[16:])
    output_ip_version = Signal(intbv(0)[4:])
    output_ip_ihl = Signal(intbv(0)[4:])
    output_ip_dscp = Signal(intbv(0)[6:])
    output_ip_ecn = Signal(intbv(0)[2:])
    output_ip_length = Signal(intbv(0)[16:])
    output_ip_identification = Signal(intbv(0)[16:])
    output_ip_flags = Signal(intbv(0)[3:])
    output_ip_fragment_offset = Signal(intbv(0)[13:])
    output_ip_ttl = Signal(intbv(0)[8:])
    output_ip_protocol = Signal(intbv(0)[8:])
    output_ip_header_checksum = Signal(intbv(0)[16:])
    output_ip_source_ip = Signal(intbv(0)[32:])
    output_ip_dest_ip = Signal(intbv(0)[32:])
    output_ip_payload_tdata = Signal(intbv(0)[64:])
    output_ip_payload_tkeep = Signal(intbv(0)[8:])
    output_ip_payload_tvalid = Signal(bool(0))
    output_ip_payload_tlast = Signal(bool(0))
    output_ip_payload_tuser = Signal(bool(0))
    output_udp_hdr_valid = Signal(bool(0))
    output_udp_eth_dest_mac = Signal(intbv(0)[48:])
    output_udp_eth_src_mac = Signal(intbv(0)[48:])
    output_udp_eth_type = Signal(intbv(0)[16:])
    output_udp_ip_version = Signal(intbv(0)[4:])
    output_udp_ip_ihl = Signal(intbv(0)[4:])
    output_udp_ip_dscp = Signal(intbv(0)[6:])
    output_udp_ip_ecn = Signal(intbv(0)[2:])
    output_udp_ip_length = Signal(intbv(0)[16:])
    output_udp_ip_identification = Signal(intbv(0)[16:])
    output_udp_ip_flags = Signal(intbv(0)[3:])
    output_udp_ip_fragment_offset = Signal(intbv(0)[13:])
    output_udp_ip_ttl = Signal(intbv(0)[8:])
    output_udp_ip_protocol = Signal(intbv(0)[8:])
    output_udp_ip_header_checksum = Signal(intbv(0)[16:])
    output_udp_ip_source_ip = Signal(intbv(0)[32:])
    output_udp_ip_dest_ip = Signal(intbv(0)[32:])
    output_udp_source_port = Signal(intbv(0)[16:])
    output_udp_dest_port = Signal(intbv(0)[16:])
    output_udp_length = Signal(intbv(0)[16:])
    output_udp_checksum = Signal(intbv(0)[16:])
    output_udp_payload_tdata = Signal(intbv(0)[64:])
    output_udp_payload_tkeep = Signal(intbv(0)[8:])
    output_udp_payload_tvalid = Signal(bool(0))
    output_udp_payload_tlast = Signal(bool(0))
    output_udp_payload_tuser = Signal(bool(0))
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
        ip_hdr_ready=input_ip_hdr_ready,
        ip_hdr_valid=input_ip_hdr_valid,
        eth_dest_mac=input_ip_eth_dest_mac,
        eth_src_mac=input_ip_eth_src_mac,
        eth_type=input_ip_eth_type,
        ip_version=input_ip_version,
        ip_ihl=input_ip_ihl,
        ip_dscp=input_ip_dscp,
        ip_ecn=input_ip_ecn,
        ip_length=input_ip_length,
        ip_identification=input_ip_identification,
        ip_flags=input_ip_flags,
        ip_fragment_offset=input_ip_fragment_offset,
        ip_ttl=input_ip_ttl,
        ip_protocol=input_ip_protocol,
        ip_header_checksum=input_ip_header_checksum,
        ip_source_ip=input_ip_source_ip,
        ip_dest_ip=input_ip_dest_ip,
        ip_payload_tdata=input_ip_payload_tdata,
        ip_payload_tkeep=input_ip_payload_tkeep,
        ip_payload_tvalid=input_ip_payload_tvalid,
        ip_payload_tready=input_ip_payload_tready,
        ip_payload_tlast=input_ip_payload_tlast,
        ip_payload_tuser=input_ip_payload_tuser,
        pause=ip_source_pause,
        name='ip_source'
    )

    ip_sink = ip_ep.IPFrameSink()

    ip_sink_logic = ip_sink.create_logic(
        clk,
        rst,
        ip_hdr_ready=output_ip_hdr_ready,
        ip_hdr_valid=output_ip_hdr_valid,
        eth_dest_mac=output_ip_eth_dest_mac,
        eth_src_mac=output_ip_eth_src_mac,
        eth_type=output_ip_eth_type,
        ip_version=output_ip_version,
        ip_ihl=output_ip_ihl,
        ip_dscp=output_ip_dscp,
        ip_ecn=output_ip_ecn,
        ip_length=output_ip_length,
        ip_identification=output_ip_identification,
        ip_flags=output_ip_flags,
        ip_fragment_offset=output_ip_fragment_offset,
        ip_ttl=output_ip_ttl,
        ip_protocol=output_ip_protocol,
        ip_header_checksum=output_ip_header_checksum,
        ip_source_ip=output_ip_source_ip,
        ip_dest_ip=output_ip_dest_ip,
        ip_payload_tdata=output_ip_payload_tdata,
        ip_payload_tkeep=output_ip_payload_tkeep,
        ip_payload_tvalid=output_ip_payload_tvalid,
        ip_payload_tready=output_ip_payload_tready,
        ip_payload_tlast=output_ip_payload_tlast,
        ip_payload_tuser=output_ip_payload_tuser,
        pause=ip_sink_pause,
        name='ip_sink'
    )

    udp_source = udp_ep.UDPFrameSource()

    udp_source_logic = udp_source.create_logic(
        clk,
        rst,
        udp_hdr_ready=input_udp_hdr_ready,
        udp_hdr_valid=input_udp_hdr_valid,
        eth_dest_mac=input_udp_eth_dest_mac,
        eth_src_mac=input_udp_eth_src_mac,
        eth_type=input_udp_eth_type,
        ip_version=input_udp_ip_version,
        ip_ihl=input_udp_ip_ihl,
        ip_dscp=input_udp_ip_dscp,
        ip_ecn=input_udp_ip_ecn,
        ip_identification=input_udp_ip_identification,
        ip_flags=input_udp_ip_flags,
        ip_fragment_offset=input_udp_ip_fragment_offset,
        ip_ttl=input_udp_ip_ttl,
        ip_header_checksum=input_udp_ip_header_checksum,
        ip_source_ip=input_udp_ip_source_ip,
        ip_dest_ip=input_udp_ip_dest_ip,
        udp_source_port=input_udp_source_port,
        udp_dest_port=input_udp_dest_port,
        udp_length=input_udp_length,
        udp_checksum=input_udp_checksum,
        udp_payload_tdata=input_udp_payload_tdata,
        udp_payload_tkeep=input_udp_payload_tkeep,
        udp_payload_tvalid=input_udp_payload_tvalid,
        udp_payload_tready=input_udp_payload_tready,
        udp_payload_tlast=input_udp_payload_tlast,
        udp_payload_tuser=input_udp_payload_tuser,
        pause=udp_source_pause,
        name='udp_source'
    )

    udp_sink = udp_ep.UDPFrameSink()

    udp_sink_logic = udp_sink.create_logic(
        clk,
        rst,
        udp_hdr_ready=output_udp_hdr_ready,
        udp_hdr_valid=output_udp_hdr_valid,
        eth_dest_mac=output_udp_eth_dest_mac,
        eth_src_mac=output_udp_eth_src_mac,
        eth_type=output_udp_eth_type,
        ip_version=output_udp_ip_version,
        ip_ihl=output_udp_ip_ihl,
        ip_dscp=output_udp_ip_dscp,
        ip_ecn=output_udp_ip_ecn,
        ip_length=output_udp_ip_length,
        ip_identification=output_udp_ip_identification,
        ip_flags=output_udp_ip_flags,
        ip_fragment_offset=output_udp_ip_fragment_offset,
        ip_ttl=output_udp_ip_ttl,
        ip_protocol=output_udp_ip_protocol,
        ip_header_checksum=output_udp_ip_header_checksum,
        ip_source_ip=output_udp_ip_source_ip,
        ip_dest_ip=output_udp_ip_dest_ip,
        udp_source_port=output_udp_source_port,
        udp_dest_port=output_udp_dest_port,
        udp_length=output_udp_length,
        udp_checksum=output_udp_checksum,
        udp_payload_tdata=output_udp_payload_tdata,
        udp_payload_tkeep=output_udp_payload_tkeep,
        udp_payload_tvalid=output_udp_payload_tvalid,
        udp_payload_tready=output_udp_payload_tready,
        udp_payload_tlast=output_udp_payload_tlast,
        udp_payload_tuser=output_udp_payload_tuser,
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

        input_ip_hdr_valid=input_ip_hdr_valid,
        input_ip_hdr_ready=input_ip_hdr_ready,
        input_ip_eth_dest_mac=input_ip_eth_dest_mac,
        input_ip_eth_src_mac=input_ip_eth_src_mac,
        input_ip_eth_type=input_ip_eth_type,
        input_ip_version=input_ip_version,
        input_ip_ihl=input_ip_ihl,
        input_ip_dscp=input_ip_dscp,
        input_ip_ecn=input_ip_ecn,
        input_ip_length=input_ip_length,
        input_ip_identification=input_ip_identification,
        input_ip_flags=input_ip_flags,
        input_ip_fragment_offset=input_ip_fragment_offset,
        input_ip_ttl=input_ip_ttl,
        input_ip_protocol=input_ip_protocol,
        input_ip_header_checksum=input_ip_header_checksum,
        input_ip_source_ip=input_ip_source_ip,
        input_ip_dest_ip=input_ip_dest_ip,
        input_ip_payload_tdata=input_ip_payload_tdata,
        input_ip_payload_tkeep=input_ip_payload_tkeep,
        input_ip_payload_tvalid=input_ip_payload_tvalid,
        input_ip_payload_tready=input_ip_payload_tready,
        input_ip_payload_tlast=input_ip_payload_tlast,
        input_ip_payload_tuser=input_ip_payload_tuser,

        output_ip_hdr_valid=output_ip_hdr_valid,
        output_ip_hdr_ready=output_ip_hdr_ready,
        output_ip_eth_dest_mac=output_ip_eth_dest_mac,
        output_ip_eth_src_mac=output_ip_eth_src_mac,
        output_ip_eth_type=output_ip_eth_type,
        output_ip_version=output_ip_version,
        output_ip_ihl=output_ip_ihl,
        output_ip_dscp=output_ip_dscp,
        output_ip_ecn=output_ip_ecn,
        output_ip_length=output_ip_length,
        output_ip_identification=output_ip_identification,
        output_ip_flags=output_ip_flags,
        output_ip_fragment_offset=output_ip_fragment_offset,
        output_ip_ttl=output_ip_ttl,
        output_ip_protocol=output_ip_protocol,
        output_ip_header_checksum=output_ip_header_checksum,
        output_ip_source_ip=output_ip_source_ip,
        output_ip_dest_ip=output_ip_dest_ip,
        output_ip_payload_tdata=output_ip_payload_tdata,
        output_ip_payload_tkeep=output_ip_payload_tkeep,
        output_ip_payload_tvalid=output_ip_payload_tvalid,
        output_ip_payload_tready=output_ip_payload_tready,
        output_ip_payload_tlast=output_ip_payload_tlast,
        output_ip_payload_tuser=output_ip_payload_tuser,

        input_udp_hdr_valid=input_udp_hdr_valid,
        input_udp_hdr_ready=input_udp_hdr_ready,
        input_udp_eth_dest_mac=input_udp_eth_dest_mac,
        input_udp_eth_src_mac=input_udp_eth_src_mac,
        input_udp_eth_type=input_udp_eth_type,
        input_udp_ip_version=input_udp_ip_version,
        input_udp_ip_ihl=input_udp_ip_ihl,
        input_udp_ip_dscp=input_udp_ip_dscp,
        input_udp_ip_ecn=input_udp_ip_ecn,
        input_udp_ip_identification=input_udp_ip_identification,
        input_udp_ip_flags=input_udp_ip_flags,
        input_udp_ip_fragment_offset=input_udp_ip_fragment_offset,
        input_udp_ip_ttl=input_udp_ip_ttl,
        input_udp_ip_header_checksum=input_udp_ip_header_checksum,
        input_udp_ip_source_ip=input_udp_ip_source_ip,
        input_udp_ip_dest_ip=input_udp_ip_dest_ip,
        input_udp_source_port=input_udp_source_port,
        input_udp_dest_port=input_udp_dest_port,
        input_udp_length=input_udp_length,
        input_udp_checksum=input_udp_checksum,
        input_udp_payload_tdata=input_udp_payload_tdata,
        input_udp_payload_tkeep=input_udp_payload_tkeep,
        input_udp_payload_tvalid=input_udp_payload_tvalid,
        input_udp_payload_tready=input_udp_payload_tready,
        input_udp_payload_tlast=input_udp_payload_tlast,
        input_udp_payload_tuser=input_udp_payload_tuser,

        output_udp_hdr_valid=output_udp_hdr_valid,
        output_udp_hdr_ready=output_udp_hdr_ready,
        output_udp_eth_dest_mac=output_udp_eth_dest_mac,
        output_udp_eth_src_mac=output_udp_eth_src_mac,
        output_udp_eth_type=output_udp_eth_type,
        output_udp_ip_version=output_udp_ip_version,
        output_udp_ip_ihl=output_udp_ip_ihl,
        output_udp_ip_dscp=output_udp_ip_dscp,
        output_udp_ip_ecn=output_udp_ip_ecn,
        output_udp_ip_length=output_udp_ip_length,
        output_udp_ip_identification=output_udp_ip_identification,
        output_udp_ip_flags=output_udp_ip_flags,
        output_udp_ip_fragment_offset=output_udp_ip_fragment_offset,
        output_udp_ip_ttl=output_udp_ip_ttl,
        output_udp_ip_protocol=output_udp_ip_protocol,
        output_udp_ip_header_checksum=output_udp_ip_header_checksum,
        output_udp_ip_source_ip=output_udp_ip_source_ip,
        output_udp_ip_dest_ip=output_udp_ip_dest_ip,
        output_udp_source_port=output_udp_source_port,
        output_udp_dest_port=output_udp_dest_port,
        output_udp_length=output_udp_length,
        output_udp_checksum=output_udp_checksum,
        output_udp_payload_tdata=output_udp_payload_tdata,
        output_udp_payload_tkeep=output_udp_payload_tkeep,
        output_udp_payload_tvalid=output_udp_payload_tvalid,
        output_udp_payload_tready=output_udp_payload_tready,
        output_udp_payload_tlast=output_udp_payload_tlast,
        output_udp_payload_tuser=output_udp_payload_tuser,

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

