#!/usr/bin/env python
"""

Copyright (c) 2014-2016 Alex Forencich

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

import ip_ep

module = 'ip_demux_64_4'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_ip_hdr_valid = Signal(bool(0))
    input_eth_dest_mac = Signal(intbv(0)[48:])
    input_eth_src_mac = Signal(intbv(0)[48:])
    input_eth_type = Signal(intbv(0)[16:])
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

    output_0_ip_hdr_ready = Signal(bool(0))
    output_0_ip_payload_tready = Signal(bool(0))
    output_1_ip_hdr_ready = Signal(bool(0))
    output_1_ip_payload_tready = Signal(bool(0))
    output_2_ip_hdr_ready = Signal(bool(0))
    output_2_ip_payload_tready = Signal(bool(0))
    output_3_ip_hdr_ready = Signal(bool(0))
    output_3_ip_payload_tready = Signal(bool(0))

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    input_ip_hdr_ready = Signal(bool(0))
    input_ip_payload_tready = Signal(bool(0))

    output_0_ip_hdr_valid = Signal(bool(0))
    output_0_eth_dest_mac = Signal(intbv(0)[48:])
    output_0_eth_src_mac = Signal(intbv(0)[48:])
    output_0_eth_type = Signal(intbv(0)[16:])
    output_0_ip_version = Signal(intbv(0)[4:])
    output_0_ip_ihl = Signal(intbv(0)[4:])
    output_0_ip_dscp = Signal(intbv(0)[6:])
    output_0_ip_ecn = Signal(intbv(0)[2:])
    output_0_ip_length = Signal(intbv(0)[16:])
    output_0_ip_identification = Signal(intbv(0)[16:])
    output_0_ip_flags = Signal(intbv(0)[3:])
    output_0_ip_fragment_offset = Signal(intbv(0)[13:])
    output_0_ip_ttl = Signal(intbv(0)[8:])
    output_0_ip_protocol = Signal(intbv(0)[8:])
    output_0_ip_header_checksum = Signal(intbv(0)[16:])
    output_0_ip_source_ip = Signal(intbv(0)[32:])
    output_0_ip_dest_ip = Signal(intbv(0)[32:])
    output_0_ip_payload_tdata = Signal(intbv(0)[64:])
    output_0_ip_payload_tkeep = Signal(intbv(0)[8:])
    output_0_ip_payload_tvalid = Signal(bool(0))
    output_0_ip_payload_tlast = Signal(bool(0))
    output_0_ip_payload_tuser = Signal(bool(0))
    output_1_ip_hdr_valid = Signal(bool(0))
    output_1_eth_dest_mac = Signal(intbv(0)[48:])
    output_1_eth_src_mac = Signal(intbv(0)[48:])
    output_1_eth_type = Signal(intbv(0)[16:])
    output_1_ip_version = Signal(intbv(0)[4:])
    output_1_ip_ihl = Signal(intbv(0)[4:])
    output_1_ip_dscp = Signal(intbv(0)[6:])
    output_1_ip_ecn = Signal(intbv(0)[2:])
    output_1_ip_length = Signal(intbv(0)[16:])
    output_1_ip_identification = Signal(intbv(0)[16:])
    output_1_ip_flags = Signal(intbv(0)[3:])
    output_1_ip_fragment_offset = Signal(intbv(0)[13:])
    output_1_ip_ttl = Signal(intbv(0)[8:])
    output_1_ip_protocol = Signal(intbv(0)[8:])
    output_1_ip_header_checksum = Signal(intbv(0)[16:])
    output_1_ip_source_ip = Signal(intbv(0)[32:])
    output_1_ip_dest_ip = Signal(intbv(0)[32:])
    output_1_ip_payload_tdata = Signal(intbv(0)[64:])
    output_1_ip_payload_tkeep = Signal(intbv(0)[8:])
    output_1_ip_payload_tvalid = Signal(bool(0))
    output_1_ip_payload_tlast = Signal(bool(0))
    output_1_ip_payload_tuser = Signal(bool(0))
    output_2_ip_hdr_valid = Signal(bool(0))
    output_2_eth_dest_mac = Signal(intbv(0)[48:])
    output_2_eth_src_mac = Signal(intbv(0)[48:])
    output_2_eth_type = Signal(intbv(0)[16:])
    output_2_ip_version = Signal(intbv(0)[4:])
    output_2_ip_ihl = Signal(intbv(0)[4:])
    output_2_ip_dscp = Signal(intbv(0)[6:])
    output_2_ip_ecn = Signal(intbv(0)[2:])
    output_2_ip_length = Signal(intbv(0)[16:])
    output_2_ip_identification = Signal(intbv(0)[16:])
    output_2_ip_flags = Signal(intbv(0)[3:])
    output_2_ip_fragment_offset = Signal(intbv(0)[13:])
    output_2_ip_ttl = Signal(intbv(0)[8:])
    output_2_ip_protocol = Signal(intbv(0)[8:])
    output_2_ip_header_checksum = Signal(intbv(0)[16:])
    output_2_ip_source_ip = Signal(intbv(0)[32:])
    output_2_ip_dest_ip = Signal(intbv(0)[32:])
    output_2_ip_payload_tdata = Signal(intbv(0)[64:])
    output_2_ip_payload_tkeep = Signal(intbv(0)[8:])
    output_2_ip_payload_tvalid = Signal(bool(0))
    output_2_ip_payload_tlast = Signal(bool(0))
    output_2_ip_payload_tuser = Signal(bool(0))
    output_3_ip_hdr_valid = Signal(bool(0))
    output_3_eth_dest_mac = Signal(intbv(0)[48:])
    output_3_eth_src_mac = Signal(intbv(0)[48:])
    output_3_eth_type = Signal(intbv(0)[16:])
    output_3_ip_version = Signal(intbv(0)[4:])
    output_3_ip_ihl = Signal(intbv(0)[4:])
    output_3_ip_dscp = Signal(intbv(0)[6:])
    output_3_ip_ecn = Signal(intbv(0)[2:])
    output_3_ip_length = Signal(intbv(0)[16:])
    output_3_ip_identification = Signal(intbv(0)[16:])
    output_3_ip_flags = Signal(intbv(0)[3:])
    output_3_ip_fragment_offset = Signal(intbv(0)[13:])
    output_3_ip_ttl = Signal(intbv(0)[8:])
    output_3_ip_protocol = Signal(intbv(0)[8:])
    output_3_ip_header_checksum = Signal(intbv(0)[16:])
    output_3_ip_source_ip = Signal(intbv(0)[32:])
    output_3_ip_dest_ip = Signal(intbv(0)[32:])
    output_3_ip_payload_tdata = Signal(intbv(0)[64:])
    output_3_ip_payload_tkeep = Signal(intbv(0)[8:])
    output_3_ip_payload_tvalid = Signal(bool(0))
    output_3_ip_payload_tlast = Signal(bool(0))
    output_3_ip_payload_tuser = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_0_pause = Signal(bool(0))
    sink_1_pause = Signal(bool(0))
    sink_2_pause = Signal(bool(0))
    sink_3_pause = Signal(bool(0))

    source = ip_ep.IPFrameSource()

    source_logic = source.create_logic(
        clk,
        rst,
        ip_hdr_ready=input_ip_hdr_ready,
        ip_hdr_valid=input_ip_hdr_valid,
        eth_dest_mac=input_eth_dest_mac,
        eth_src_mac=input_eth_src_mac,
        eth_type=input_eth_type,
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
        pause=source_pause,
        name='source'
    )

    sink_0 = ip_ep.IPFrameSink()

    sink_0_logic = sink_0.create_logic(
        clk,
        rst,
        ip_hdr_ready=output_0_ip_hdr_ready,
        ip_hdr_valid=output_0_ip_hdr_valid,
        eth_dest_mac=output_0_eth_dest_mac,
        eth_src_mac=output_0_eth_src_mac,
        eth_type=output_0_eth_type,
        ip_version=output_0_ip_version,
        ip_ihl=output_0_ip_ihl,
        ip_dscp=output_0_ip_dscp,
        ip_ecn=output_0_ip_ecn,
        ip_length=output_0_ip_length,
        ip_identification=output_0_ip_identification,
        ip_flags=output_0_ip_flags,
        ip_fragment_offset=output_0_ip_fragment_offset,
        ip_ttl=output_0_ip_ttl,
        ip_protocol=output_0_ip_protocol,
        ip_header_checksum=output_0_ip_header_checksum,
        ip_source_ip=output_0_ip_source_ip,
        ip_dest_ip=output_0_ip_dest_ip,
        ip_payload_tdata=output_0_ip_payload_tdata,
        ip_payload_tkeep=output_0_ip_payload_tkeep,
        ip_payload_tvalid=output_0_ip_payload_tvalid,
        ip_payload_tready=output_0_ip_payload_tready,
        ip_payload_tlast=output_0_ip_payload_tlast,
        ip_payload_tuser=output_0_ip_payload_tuser,
        pause=sink_0_pause,
        name='sink_0'
    )

    sink_1 = ip_ep.IPFrameSink()

    sink_1_logic = sink_1.create_logic(
        clk,
        rst,
        ip_hdr_ready=output_1_ip_hdr_ready,
        ip_hdr_valid=output_1_ip_hdr_valid,
        eth_dest_mac=output_1_eth_dest_mac,
        eth_src_mac=output_1_eth_src_mac,
        eth_type=output_1_eth_type,
        ip_version=output_1_ip_version,
        ip_ihl=output_1_ip_ihl,
        ip_dscp=output_1_ip_dscp,
        ip_ecn=output_1_ip_ecn,
        ip_length=output_1_ip_length,
        ip_identification=output_1_ip_identification,
        ip_flags=output_1_ip_flags,
        ip_fragment_offset=output_1_ip_fragment_offset,
        ip_ttl=output_1_ip_ttl,
        ip_protocol=output_1_ip_protocol,
        ip_header_checksum=output_1_ip_header_checksum,
        ip_source_ip=output_1_ip_source_ip,
        ip_dest_ip=output_1_ip_dest_ip,
        ip_payload_tdata=output_1_ip_payload_tdata,
        ip_payload_tkeep=output_1_ip_payload_tkeep,
        ip_payload_tvalid=output_1_ip_payload_tvalid,
        ip_payload_tready=output_1_ip_payload_tready,
        ip_payload_tlast=output_1_ip_payload_tlast,
        ip_payload_tuser=output_1_ip_payload_tuser,
        pause=sink_1_pause,
        name='sink_1'
    )

    sink_2 = ip_ep.IPFrameSink()

    sink_2_logic = sink_2.create_logic(
        clk,
        rst,
        ip_hdr_ready=output_2_ip_hdr_ready,
        ip_hdr_valid=output_2_ip_hdr_valid,
        eth_dest_mac=output_2_eth_dest_mac,
        eth_src_mac=output_2_eth_src_mac,
        eth_type=output_2_eth_type,
        ip_version=output_2_ip_version,
        ip_ihl=output_2_ip_ihl,
        ip_dscp=output_2_ip_dscp,
        ip_ecn=output_2_ip_ecn,
        ip_length=output_2_ip_length,
        ip_identification=output_2_ip_identification,
        ip_flags=output_2_ip_flags,
        ip_fragment_offset=output_2_ip_fragment_offset,
        ip_ttl=output_2_ip_ttl,
        ip_protocol=output_2_ip_protocol,
        ip_header_checksum=output_2_ip_header_checksum,
        ip_source_ip=output_2_ip_source_ip,
        ip_dest_ip=output_2_ip_dest_ip,
        ip_payload_tdata=output_2_ip_payload_tdata,
        ip_payload_tkeep=output_2_ip_payload_tkeep,
        ip_payload_tvalid=output_2_ip_payload_tvalid,
        ip_payload_tready=output_2_ip_payload_tready,
        ip_payload_tlast=output_2_ip_payload_tlast,
        ip_payload_tuser=output_2_ip_payload_tuser,
        pause=sink_2_pause,
        name='sink_2'
    )

    sink_3 = ip_ep.IPFrameSink()

    sink_3_logic = sink_3.create_logic(
        clk,
        rst,
        ip_hdr_ready=output_3_ip_hdr_ready,
        ip_hdr_valid=output_3_ip_hdr_valid,
        eth_dest_mac=output_3_eth_dest_mac,
        eth_src_mac=output_3_eth_src_mac,
        eth_type=output_3_eth_type,
        ip_version=output_3_ip_version,
        ip_ihl=output_3_ip_ihl,
        ip_dscp=output_3_ip_dscp,
        ip_ecn=output_3_ip_ecn,
        ip_length=output_3_ip_length,
        ip_identification=output_3_ip_identification,
        ip_flags=output_3_ip_flags,
        ip_fragment_offset=output_3_ip_fragment_offset,
        ip_ttl=output_3_ip_ttl,
        ip_protocol=output_3_ip_protocol,
        ip_header_checksum=output_3_ip_header_checksum,
        ip_source_ip=output_3_ip_source_ip,
        ip_dest_ip=output_3_ip_dest_ip,
        ip_payload_tdata=output_3_ip_payload_tdata,
        ip_payload_tkeep=output_3_ip_payload_tkeep,
        ip_payload_tvalid=output_3_ip_payload_tvalid,
        ip_payload_tready=output_3_ip_payload_tready,
        ip_payload_tlast=output_3_ip_payload_tlast,
        ip_payload_tuser=output_3_ip_payload_tuser,
        pause=sink_3_pause,
        name='sink_3'
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
        input_eth_dest_mac=input_eth_dest_mac,
        input_eth_src_mac=input_eth_src_mac,
        input_eth_type=input_eth_type,
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

        output_0_ip_hdr_valid=output_0_ip_hdr_valid,
        output_0_ip_hdr_ready=output_0_ip_hdr_ready,
        output_0_eth_dest_mac=output_0_eth_dest_mac,
        output_0_eth_src_mac=output_0_eth_src_mac,
        output_0_eth_type=output_0_eth_type,
        output_0_ip_version=output_0_ip_version,
        output_0_ip_ihl=output_0_ip_ihl,
        output_0_ip_dscp=output_0_ip_dscp,
        output_0_ip_ecn=output_0_ip_ecn,
        output_0_ip_length=output_0_ip_length,
        output_0_ip_identification=output_0_ip_identification,
        output_0_ip_flags=output_0_ip_flags,
        output_0_ip_fragment_offset=output_0_ip_fragment_offset,
        output_0_ip_ttl=output_0_ip_ttl,
        output_0_ip_protocol=output_0_ip_protocol,
        output_0_ip_header_checksum=output_0_ip_header_checksum,
        output_0_ip_source_ip=output_0_ip_source_ip,
        output_0_ip_dest_ip=output_0_ip_dest_ip,
        output_0_ip_payload_tdata=output_0_ip_payload_tdata,
        output_0_ip_payload_tkeep=output_0_ip_payload_tkeep,
        output_0_ip_payload_tvalid=output_0_ip_payload_tvalid,
        output_0_ip_payload_tready=output_0_ip_payload_tready,
        output_0_ip_payload_tlast=output_0_ip_payload_tlast,
        output_0_ip_payload_tuser=output_0_ip_payload_tuser,
        output_1_ip_hdr_valid=output_1_ip_hdr_valid,
        output_1_ip_hdr_ready=output_1_ip_hdr_ready,
        output_1_eth_dest_mac=output_1_eth_dest_mac,
        output_1_eth_src_mac=output_1_eth_src_mac,
        output_1_eth_type=output_1_eth_type,
        output_1_ip_version=output_1_ip_version,
        output_1_ip_ihl=output_1_ip_ihl,
        output_1_ip_dscp=output_1_ip_dscp,
        output_1_ip_ecn=output_1_ip_ecn,
        output_1_ip_length=output_1_ip_length,
        output_1_ip_identification=output_1_ip_identification,
        output_1_ip_flags=output_1_ip_flags,
        output_1_ip_fragment_offset=output_1_ip_fragment_offset,
        output_1_ip_ttl=output_1_ip_ttl,
        output_1_ip_protocol=output_1_ip_protocol,
        output_1_ip_header_checksum=output_1_ip_header_checksum,
        output_1_ip_source_ip=output_1_ip_source_ip,
        output_1_ip_dest_ip=output_1_ip_dest_ip,
        output_1_ip_payload_tdata=output_1_ip_payload_tdata,
        output_1_ip_payload_tkeep=output_1_ip_payload_tkeep,
        output_1_ip_payload_tvalid=output_1_ip_payload_tvalid,
        output_1_ip_payload_tready=output_1_ip_payload_tready,
        output_1_ip_payload_tlast=output_1_ip_payload_tlast,
        output_1_ip_payload_tuser=output_1_ip_payload_tuser,
        output_2_ip_hdr_valid=output_2_ip_hdr_valid,
        output_2_ip_hdr_ready=output_2_ip_hdr_ready,
        output_2_eth_dest_mac=output_2_eth_dest_mac,
        output_2_eth_src_mac=output_2_eth_src_mac,
        output_2_eth_type=output_2_eth_type,
        output_2_ip_version=output_2_ip_version,
        output_2_ip_ihl=output_2_ip_ihl,
        output_2_ip_dscp=output_2_ip_dscp,
        output_2_ip_ecn=output_2_ip_ecn,
        output_2_ip_length=output_2_ip_length,
        output_2_ip_identification=output_2_ip_identification,
        output_2_ip_flags=output_2_ip_flags,
        output_2_ip_fragment_offset=output_2_ip_fragment_offset,
        output_2_ip_ttl=output_2_ip_ttl,
        output_2_ip_protocol=output_2_ip_protocol,
        output_2_ip_header_checksum=output_2_ip_header_checksum,
        output_2_ip_source_ip=output_2_ip_source_ip,
        output_2_ip_dest_ip=output_2_ip_dest_ip,
        output_2_ip_payload_tdata=output_2_ip_payload_tdata,
        output_2_ip_payload_tkeep=output_2_ip_payload_tkeep,
        output_2_ip_payload_tvalid=output_2_ip_payload_tvalid,
        output_2_ip_payload_tready=output_2_ip_payload_tready,
        output_2_ip_payload_tlast=output_2_ip_payload_tlast,
        output_2_ip_payload_tuser=output_2_ip_payload_tuser,
        output_3_ip_hdr_valid=output_3_ip_hdr_valid,
        output_3_ip_hdr_ready=output_3_ip_hdr_ready,
        output_3_eth_dest_mac=output_3_eth_dest_mac,
        output_3_eth_src_mac=output_3_eth_src_mac,
        output_3_eth_type=output_3_eth_type,
        output_3_ip_version=output_3_ip_version,
        output_3_ip_ihl=output_3_ip_ihl,
        output_3_ip_dscp=output_3_ip_dscp,
        output_3_ip_ecn=output_3_ip_ecn,
        output_3_ip_length=output_3_ip_length,
        output_3_ip_identification=output_3_ip_identification,
        output_3_ip_flags=output_3_ip_flags,
        output_3_ip_fragment_offset=output_3_ip_fragment_offset,
        output_3_ip_ttl=output_3_ip_ttl,
        output_3_ip_protocol=output_3_ip_protocol,
        output_3_ip_header_checksum=output_3_ip_header_checksum,
        output_3_ip_source_ip=output_3_ip_source_ip,
        output_3_ip_dest_ip=output_3_ip_dest_ip,
        output_3_ip_payload_tdata=output_3_ip_payload_tdata,
        output_3_ip_payload_tkeep=output_3_ip_payload_tkeep,
        output_3_ip_payload_tvalid=output_3_ip_payload_tvalid,
        output_3_ip_payload_tready=output_3_ip_payload_tready,
        output_3_ip_payload_tlast=output_3_ip_payload_tlast,
        output_3_ip_payload_tuser=output_3_ip_payload_tuser,

        enable=enable,
        select=select
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

        yield clk.posedge
        enable.next = True

        yield clk.posedge
        print("test 1: select port 0")
        current_test.next = 1

        select.next = 0

        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
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
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        source.send(test_frame)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: select port 1")
        current_test.next = 2

        select.next = 1

        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
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
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        source.send(test_frame)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: back-to-back packets, same port")
        current_test.next = 3

        select.next = 0

        test_frame1 = ip_ep.IPFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.ip_version = 4
        test_frame1.ip_ihl = 5
        test_frame1.ip_dscp = 0
        test_frame1.ip_ecn = 0
        test_frame1.ip_length = None
        test_frame1.ip_identification = 0
        test_frame1.ip_flags = 2
        test_frame1.ip_fragment_offset = 0
        test_frame1.ip_ttl = 64
        test_frame1.ip_protocol = 0x11
        test_frame1.ip_header_checksum = None
        test_frame1.ip_source_ip = 0xc0a80165
        test_frame1.ip_dest_ip = 0xc0a80164
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.ip_version = 4
        test_frame2.ip_ihl = 5
        test_frame2.ip_dscp = 0
        test_frame2.ip_ecn = 0
        test_frame2.ip_length = None
        test_frame2.ip_identification = 0
        test_frame2.ip_flags = 2
        test_frame2.ip_fragment_offset = 0
        test_frame2.ip_ttl = 64
        test_frame2.ip_protocol = 0x11
        test_frame2.ip_header_checksum = None
        test_frame2.ip_source_ip = 0xc0a80165
        test_frame2.ip_dest_ip = 0xc0a80164
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            yield clk.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_0.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets, different ports")
        current_test.next = 4

        select.next = 1

        test_frame1 = ip_ep.IPFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.ip_version = 4
        test_frame1.ip_ihl = 5
        test_frame1.ip_dscp = 0
        test_frame1.ip_ecn = 0
        test_frame1.ip_length = None
        test_frame1.ip_identification = 0
        test_frame1.ip_flags = 2
        test_frame1.ip_fragment_offset = 0
        test_frame1.ip_ttl = 64
        test_frame1.ip_protocol = 0x11
        test_frame1.ip_header_checksum = None
        test_frame1.ip_source_ip = 0xc0a80165
        test_frame1.ip_dest_ip = 0xc0a80164
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.ip_version = 4
        test_frame2.ip_ihl = 5
        test_frame2.ip_dscp = 0
        test_frame2.ip_ecn = 0
        test_frame2.ip_length = None
        test_frame2.ip_identification = 0
        test_frame2.ip_flags = 2
        test_frame2.ip_fragment_offset = 0
        test_frame2.ip_ttl = 64
        test_frame2.ip_protocol = 0x11
        test_frame2.ip_header_checksum = None
        test_frame2.ip_source_ip = 0xc0a80165
        test_frame2.ip_dest_ip = 0xc0a80164
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alterate pause source")
        current_test.next = 5

        select.next = 1

        test_frame1 = ip_ep.IPFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.ip_version = 4
        test_frame1.ip_ihl = 5
        test_frame1.ip_dscp = 0
        test_frame1.ip_ecn = 0
        test_frame1.ip_length = None
        test_frame1.ip_identification = 0
        test_frame1.ip_flags = 2
        test_frame1.ip_fragment_offset = 0
        test_frame1.ip_ttl = 64
        test_frame1.ip_protocol = 0x11
        test_frame1.ip_header_checksum = None
        test_frame1.ip_source_ip = 0xc0a80165
        test_frame1.ip_dest_ip = 0xc0a80164
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.ip_version = 4
        test_frame2.ip_ihl = 5
        test_frame2.ip_dscp = 0
        test_frame2.ip_ecn = 0
        test_frame2.ip_length = None
        test_frame2.ip_identification = 0
        test_frame2.ip_flags = 2
        test_frame2.ip_fragment_offset = 0
        test_frame2.ip_ttl = 64
        test_frame2.ip_protocol = 0x11
        test_frame2.ip_header_checksum = None
        test_frame2.ip_source_ip = 0xc0a80165
        test_frame2.ip_dest_ip = 0xc0a80164
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alterate pause sink")
        current_test.next = 6

        select.next = 1

        test_frame1 = ip_ep.IPFrame()
        test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame1.eth_src_mac = 0x5A5152535455
        test_frame1.eth_type = 0x8000
        test_frame1.ip_version = 4
        test_frame1.ip_ihl = 5
        test_frame1.ip_dscp = 0
        test_frame1.ip_ecn = 0
        test_frame1.ip_length = None
        test_frame1.ip_identification = 0
        test_frame1.ip_flags = 2
        test_frame1.ip_fragment_offset = 0
        test_frame1.ip_ttl = 64
        test_frame1.ip_protocol = 0x11
        test_frame1.ip_header_checksum = None
        test_frame1.ip_source_ip = 0xc0a80165
        test_frame1.ip_dest_ip = 0xc0a80164
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
        test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame2.eth_src_mac = 0x5A5152535455
        test_frame2.eth_type = 0x8000
        test_frame2.ip_version = 4
        test_frame2.ip_ihl = 5
        test_frame2.ip_dscp = 0
        test_frame2.ip_ecn = 0
        test_frame2.ip_length = None
        test_frame2.ip_identification = 0
        test_frame2.ip_flags = 2
        test_frame2.ip_fragment_offset = 0
        test_frame2.ip_ttl = 64
        test_frame2.ip_protocol = 0x11
        test_frame2.ip_header_checksum = None
        test_frame2.ip_source_ip = 0xc0a80165
        test_frame2.ip_dest_ip = 0xc0a80164
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()

        source.send(test_frame1)
        source.send(test_frame2)
        yield clk.posedge

        while input_ip_payload_tvalid or input_ip_hdr_valid:
            sink_0_pause.next = True
            sink_1_pause.next = True
            sink_2_pause.next = True
            sink_3_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_0_pause.next = False
            sink_1_pause.next = False
            sink_2_pause.next = False
            sink_3_pause.next = False
            yield clk.posedge
            select.next = 2
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink_1.recv()

        assert rx_frame == test_frame1

        rx_frame = sink_2.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_0_logic, sink_1_logic, sink_2_logic, sink_3_logic, clkgen, check

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

