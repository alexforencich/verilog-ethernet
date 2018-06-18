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
import arp_ep
import ip_ep
import udp_ep

module = 'udp_complete'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/udp.v")
srcs.append("../rtl/udp_checksum_gen.v")
srcs.append("../rtl/udp_ip_rx.v")
srcs.append("../rtl/udp_ip_tx.v")
srcs.append("../rtl/ip_complete.v")
srcs.append("../rtl/ip.v")
srcs.append("../rtl/ip_eth_rx.v")
srcs.append("../rtl/ip_eth_tx.v")
srcs.append("../rtl/ip_arb_mux_2.v")
srcs.append("../rtl/ip_mux_2.v")
srcs.append("../rtl/arp.v")
srcs.append("../rtl/arp_cache.v")
srcs.append("../rtl/arp_eth_rx.v")
srcs.append("../rtl/arp_eth_tx.v")
srcs.append("../rtl/eth_arb_mux_2.v")
srcs.append("../rtl/eth_mux_2.v")
srcs.append("../rtl/lfsr.v")
srcs.append("../lib/axis/rtl/arbiter.v")
srcs.append("../lib/axis/rtl/priority_encoder.v")
srcs.append("../lib/axis/rtl/axis_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_eth_hdr_valid = Signal(bool(0))
    input_eth_dest_mac = Signal(intbv(0)[48:])
    input_eth_src_mac = Signal(intbv(0)[48:])
    input_eth_type = Signal(intbv(0)[16:])
    input_eth_payload_tdata = Signal(intbv(0)[8:])
    input_eth_payload_tvalid = Signal(bool(0))
    input_eth_payload_tlast = Signal(bool(0))
    input_eth_payload_tuser = Signal(bool(0))
    input_ip_hdr_valid = Signal(bool(0))
    input_ip_dscp = Signal(intbv(0)[6:])
    input_ip_ecn = Signal(intbv(0)[2:])
    input_ip_length = Signal(intbv(0)[16:])
    input_ip_ttl = Signal(intbv(0)[8:])
    input_ip_protocol = Signal(intbv(0)[8:])
    input_ip_source_ip = Signal(intbv(0)[32:])
    input_ip_dest_ip = Signal(intbv(0)[32:])
    input_ip_payload_tdata = Signal(intbv(0)[8:])
    input_ip_payload_tvalid = Signal(bool(0))
    input_ip_payload_tlast = Signal(bool(0))
    input_ip_payload_tuser = Signal(bool(0))
    input_udp_hdr_valid = Signal(bool(0))
    input_udp_ip_dscp = Signal(intbv(0)[6:])
    input_udp_ip_ecn = Signal(intbv(0)[2:])
    input_udp_ip_ttl = Signal(intbv(0)[8:])
    input_udp_ip_source_ip = Signal(intbv(0)[32:])
    input_udp_ip_dest_ip = Signal(intbv(0)[32:])
    input_udp_source_port = Signal(intbv(0)[16:])
    input_udp_dest_port = Signal(intbv(0)[16:])
    input_udp_length = Signal(intbv(0)[16:])
    input_udp_checksum = Signal(intbv(0)[16:])
    input_udp_payload_tdata = Signal(intbv(0)[8:])
    input_udp_payload_tvalid = Signal(bool(0))
    input_udp_payload_tlast = Signal(bool(0))
    input_udp_payload_tuser = Signal(bool(0))
    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))
    output_ip_hdr_ready = Signal(bool(0))
    output_ip_payload_tready = Signal(bool(0))
    output_udp_hdr_ready = Signal(bool(0))
    output_udp_payload_tready = Signal(bool(0))

    # Outputs
    input_eth_hdr_ready = Signal(bool(0))
    input_eth_payload_tready = Signal(bool(0))
    input_ip_hdr_ready = Signal(bool(0))
    input_ip_payload_tready = Signal(bool(0))
    input_udp_hdr_ready = Signal(bool(0))
    input_udp_payload_tready = Signal(bool(0))
    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))
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
    output_ip_payload_tdata = Signal(intbv(0)[8:])
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
    output_udp_payload_tdata = Signal(intbv(0)[8:])
    output_udp_payload_tvalid = Signal(bool(0))
    output_udp_payload_tlast = Signal(bool(0))
    output_udp_payload_tuser = Signal(bool(0))
    ip_rx_busy = Signal(bool(0))
    ip_tx_busy = Signal(bool(0))
    udp_rx_busy = Signal(bool(0))
    udp_tx_busy = Signal(bool(0))
    ip_rx_error_header_early_termination = Signal(bool(0))
    ip_rx_error_payload_early_termination = Signal(bool(0))
    ip_rx_error_invalid_header = Signal(bool(0))
    ip_rx_error_invalid_checksum = Signal(bool(0))
    ip_tx_error_payload_early_termination = Signal(bool(0))
    ip_tx_error_arp_failed = Signal(bool(0))
    udp_rx_error_header_early_termination = Signal(bool(0))
    udp_rx_error_payload_early_termination = Signal(bool(0))
    udp_tx_error_payload_early_termination = Signal(bool(0))
    local_mac = Signal(intbv(0)[48:])
    local_ip = Signal(intbv(0)[32:])
    gateway_ip = Signal(intbv(0)[32:])
    subnet_mask = Signal(intbv(0)[32:])
    clear_arp_cache = Signal(bool(0))

    # sources and sinks
    eth_source_pause = Signal(bool(0))
    eth_sink_pause = Signal(bool(0))
    ip_source_pause = Signal(bool(0))
    ip_sink_pause = Signal(bool(0))
    udp_source_pause = Signal(bool(0))
    udp_sink_pause = Signal(bool(0))

    eth_source = eth_ep.EthFrameSource()

    eth_source_logic = eth_source.create_logic(
        clk,
        rst,
        eth_hdr_ready=input_eth_hdr_ready,
        eth_hdr_valid=input_eth_hdr_valid,
        eth_dest_mac=input_eth_dest_mac,
        eth_src_mac=input_eth_src_mac,
        eth_type=input_eth_type,
        eth_payload_tdata=input_eth_payload_tdata,
        eth_payload_tvalid=input_eth_payload_tvalid,
        eth_payload_tready=input_eth_payload_tready,
        eth_payload_tlast=input_eth_payload_tlast,
        eth_payload_tuser=input_eth_payload_tuser,
        pause=eth_source_pause,
        name='eth_source'
    )

    eth_sink = eth_ep.EthFrameSink()

    eth_sink_logic = eth_sink.create_logic(
        clk,
        rst,
        eth_hdr_ready=output_eth_hdr_ready,
        eth_hdr_valid=output_eth_hdr_valid,
        eth_dest_mac=output_eth_dest_mac,
        eth_src_mac=output_eth_src_mac,
        eth_type=output_eth_type,
        eth_payload_tdata=output_eth_payload_tdata,
        eth_payload_tvalid=output_eth_payload_tvalid,
        eth_payload_tready=output_eth_payload_tready,
        eth_payload_tlast=output_eth_payload_tlast,
        eth_payload_tuser=output_eth_payload_tuser,
        pause=eth_sink_pause,
        name='eth_sink'
    )

    ip_source = ip_ep.IPFrameSource()

    ip_source_logic = ip_source.create_logic(
        clk,
        rst,
        ip_hdr_valid=input_ip_hdr_valid,
        ip_hdr_ready=input_ip_hdr_ready,
        ip_dscp=input_ip_dscp,
        ip_ecn=input_ip_ecn,
        ip_length=input_ip_length,
        ip_ttl=input_ip_ttl,
        ip_protocol=input_ip_protocol,
        ip_source_ip=input_ip_source_ip,
        ip_dest_ip=input_ip_dest_ip,
        ip_payload_tdata=input_ip_payload_tdata,
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
        ip_dscp=input_udp_ip_dscp,
        ip_ecn=input_udp_ip_ecn,
        ip_ttl=input_udp_ip_ttl,
        ip_source_ip=input_udp_ip_source_ip,
        ip_dest_ip=input_udp_ip_dest_ip,
        udp_source_port=input_udp_source_port,
        udp_dest_port=input_udp_dest_port,
        udp_length=input_udp_length,
        udp_checksum=input_udp_checksum,
        udp_payload_tdata=input_udp_payload_tdata,
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

        input_eth_hdr_valid=input_eth_hdr_valid,
        input_eth_hdr_ready=input_eth_hdr_ready,
        input_eth_dest_mac=input_eth_dest_mac,
        input_eth_src_mac=input_eth_src_mac,
        input_eth_type=input_eth_type,
        input_eth_payload_tdata=input_eth_payload_tdata,
        input_eth_payload_tvalid=input_eth_payload_tvalid,
        input_eth_payload_tready=input_eth_payload_tready,
        input_eth_payload_tlast=input_eth_payload_tlast,
        input_eth_payload_tuser=input_eth_payload_tuser,

        output_eth_hdr_valid=output_eth_hdr_valid,
        output_eth_hdr_ready=output_eth_hdr_ready,
        output_eth_dest_mac=output_eth_dest_mac,
        output_eth_src_mac=output_eth_src_mac,
        output_eth_type=output_eth_type,
        output_eth_payload_tdata=output_eth_payload_tdata,
        output_eth_payload_tvalid=output_eth_payload_tvalid,
        output_eth_payload_tready=output_eth_payload_tready,
        output_eth_payload_tlast=output_eth_payload_tlast,
        output_eth_payload_tuser=output_eth_payload_tuser,

        input_ip_hdr_valid=input_ip_hdr_valid,
        input_ip_hdr_ready=input_ip_hdr_ready,
        input_ip_dscp=input_ip_dscp,
        input_ip_ecn=input_ip_ecn,
        input_ip_length=input_ip_length,
        input_ip_ttl=input_ip_ttl,
        input_ip_protocol=input_ip_protocol,
        input_ip_source_ip=input_ip_source_ip,
        input_ip_dest_ip=input_ip_dest_ip,
        input_ip_payload_tdata=input_ip_payload_tdata,
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
        output_ip_payload_tvalid=output_ip_payload_tvalid,
        output_ip_payload_tready=output_ip_payload_tready,
        output_ip_payload_tlast=output_ip_payload_tlast,
        output_ip_payload_tuser=output_ip_payload_tuser,

        input_udp_hdr_valid=input_udp_hdr_valid,
        input_udp_hdr_ready=input_udp_hdr_ready,
        input_udp_ip_dscp=input_udp_ip_dscp,
        input_udp_ip_ecn=input_udp_ip_ecn,
        input_udp_ip_ttl=input_udp_ip_ttl,
        input_udp_ip_source_ip=input_udp_ip_source_ip,
        input_udp_ip_dest_ip=input_udp_ip_dest_ip,
        input_udp_source_port=input_udp_source_port,
        input_udp_dest_port=input_udp_dest_port,
        input_udp_length=input_udp_length,
        input_udp_checksum=input_udp_checksum,
        input_udp_payload_tdata=input_udp_payload_tdata,
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
        output_udp_payload_tvalid=output_udp_payload_tvalid,
        output_udp_payload_tready=output_udp_payload_tready,
        output_udp_payload_tlast=output_udp_payload_tlast,
        output_udp_payload_tuser=output_udp_payload_tuser,

        ip_rx_busy=ip_rx_busy,
        ip_tx_busy=ip_tx_busy,
        udp_rx_busy=udp_rx_busy,
        udp_tx_busy=udp_tx_busy,
        ip_rx_error_header_early_termination=ip_rx_error_header_early_termination,
        ip_rx_error_payload_early_termination=ip_rx_error_payload_early_termination,
        ip_rx_error_invalid_header=ip_rx_error_invalid_header,
        ip_rx_error_invalid_checksum=ip_rx_error_invalid_checksum,
        ip_tx_error_payload_early_termination=ip_tx_error_payload_early_termination,
        ip_tx_error_arp_failed=ip_tx_error_arp_failed,
        udp_rx_error_header_early_termination=udp_rx_error_header_early_termination,
        udp_rx_error_payload_early_termination=udp_rx_error_payload_early_termination,
        udp_tx_error_payload_early_termination=udp_tx_error_payload_early_termination,

        local_mac=local_mac,
        local_ip=local_ip,
        gateway_ip=gateway_ip,
        subnet_mask=subnet_mask,
        clear_arp_cache=clear_arp_cache
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    ip_rx_error_header_early_termination_asserted = Signal(bool(0))
    ip_rx_error_payload_early_termination_asserted = Signal(bool(0))
    ip_rx_error_invalid_header_asserted = Signal(bool(0))
    ip_rx_error_invalid_checksum_asserted = Signal(bool(0))
    ip_tx_error_payload_early_termination_asserted = Signal(bool(0))
    ip_tx_error_arp_failed_asserted = Signal(bool(0))
    udp_rx_error_header_early_termination_asserted = Signal(bool(0))
    udp_rx_error_payload_early_termination_asserted = Signal(bool(0))
    udp_tx_error_payload_early_termination_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (ip_rx_error_header_early_termination):
            ip_rx_error_header_early_termination_asserted.next = 1
        if (ip_rx_error_payload_early_termination):
            ip_rx_error_payload_early_termination_asserted.next = 1
        if (ip_rx_error_invalid_header):
            ip_rx_error_invalid_header_asserted.next = 1
        if (ip_rx_error_invalid_checksum):
            ip_rx_error_invalid_checksum_asserted.next = 1
        if (ip_tx_error_payload_early_termination):
            ip_tx_error_payload_early_termination_asserted.next = 1
        if (ip_tx_error_arp_failed):
            ip_tx_error_arp_failed_asserted.next = 1
        if (udp_rx_error_header_early_termination):
            udp_rx_error_header_early_termination_asserted.next = 1
        if (udp_rx_error_payload_early_termination):
            udp_rx_error_payload_early_termination_asserted.next = 1
        if (udp_tx_error_payload_early_termination):
            udp_tx_error_payload_early_termination_asserted.next = 1

    def wait_normal():
        i = 20
        while i > 0:
            i = max(0, i-1)
            if (input_eth_payload_tvalid or input_ip_payload_tvalid or input_udp_payload_tvalid or
                    output_eth_payload_tvalid or output_ip_payload_tvalid or output_udp_payload_tvalid or
                    input_eth_hdr_valid or input_ip_hdr_valid or input_udp_hdr_valid):
                i = 20
            yield clk.posedge

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

        # set MAC and IP address
        local_mac.next = 0x5A5152535455
        local_ip.next = 0xc0a80164
        gateway_ip.next = 0xc0a80101
        subnet_mask.next = 0xffffff00

        yield clk.posedge
        print("test 1: test IP RX packet")
        current_test.next = 1

        test_frame = ip_ep.IPFrame()
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
        test_frame.ip_protocol = 0x10
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80165
        test_frame.ip_dest_ip = 0xc0a80164
        test_frame.payload = bytearray(range(32))
        test_frame.build()
        eth_frame = test_frame.build_eth()

        eth_source.send(eth_frame)

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        rx_frame = ip_sink.recv()

        assert rx_frame == test_frame

        assert eth_source.empty()
        assert eth_sink.empty()
        assert ip_source.empty()
        assert ip_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 2: test IP TX packet")
        current_test.next = 2

        # send IP packet
        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
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
        test_frame.ip_protocol = 0x10
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80166
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        ip_source.send(test_frame)

        # wait for ARP request packet
        while eth_sink.empty():
            yield clk.posedge

        rx_frame = eth_sink.recv()
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
        assert check_frame.eth_src_mac == 0x5A5152535455
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 1
        assert check_frame.arp_sha == 0x5A5152535455
        assert check_frame.arp_spa == 0xc0a80164
        assert check_frame.arp_tha == 0x000000000000
        assert check_frame.arp_tpa == 0xc0a80166

        # generate response
        arp_frame = arp_ep.ARPFrame()
        arp_frame.eth_dest_mac = 0x5A5152535455
        arp_frame.eth_src_mac = 0xDAD1D2D3D4D5
        arp_frame.eth_type = 0x0806
        arp_frame.arp_htype = 0x0001
        arp_frame.arp_ptype = 0x0800
        arp_frame.arp_hlen = 6
        arp_frame.arp_plen = 4
        arp_frame.arp_oper = 2
        arp_frame.arp_sha = 0xDAD1D2D3D4D5
        arp_frame.arp_spa = 0xc0a80166
        arp_frame.arp_tha = 0x5A5152535455
        arp_frame.arp_tpa = 0xc0a80164
        eth_source.send(arp_frame.build_eth())

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        rx_frame = eth_sink.recv()

        check_frame = ip_ep.IPFrame()
        check_frame.parse_eth(rx_frame)

        print(test_frame)
        print(check_frame)

        assert check_frame == test_frame

        assert eth_source.empty()
        assert eth_sink.empty()
        assert ip_source.empty()
        assert ip_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 3: test IP TX arp fail packet")
        current_test.next = 2

        ip_tx_error_arp_failed_asserted.next = 0

        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
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
        test_frame.ip_protocol = 0x10
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80167
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        ip_source.send(test_frame)

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        assert ip_tx_error_arp_failed_asserted

        # check for 4 ARP requests
        assert eth_sink.count() == 4

        while not eth_sink.empty():
            rx_frame = eth_sink.recv()

            check_frame = arp_ep.ARPFrame()
            check_frame.parse_eth(rx_frame)

            assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
            assert check_frame.eth_src_mac == 0x5A5152535455
            assert check_frame.eth_type == 0x0806
            assert check_frame.arp_htype == 0x0001
            assert check_frame.arp_ptype == 0x0800
            assert check_frame.arp_hlen == 6
            assert check_frame.arp_plen == 4
            assert check_frame.arp_oper == 1
            assert check_frame.arp_sha == 0x5A5152535455
            assert check_frame.arp_spa == 0xc0a80164
            assert check_frame.arp_tha == 0x000000000000
            assert check_frame.arp_tpa == 0xc0a80167

        assert eth_source.empty()
        assert eth_sink.empty()
        assert ip_source.empty()
        assert ip_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 4: test UDP RX packet")
        current_test.next = 4

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
        eth_frame = test_frame.build_eth()

        eth_source.send(eth_frame)

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        rx_frame = udp_sink.recv()

        assert rx_frame == test_frame

        assert eth_source.empty()
        assert eth_sink.empty()
        assert udp_source.empty()
        assert udp_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 5: test UDP TX packet")
        current_test.next = 5

        test_frame = udp_ep.UDPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
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
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80166
        test_frame.udp_source_port = 1234
        test_frame.udp_dest_port = 5678
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        udp_source.send(test_frame)

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        rx_frame = eth_sink.recv()

        check_frame = udp_ep.UDPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame == test_frame

        assert eth_source.empty()
        assert eth_sink.empty()
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

