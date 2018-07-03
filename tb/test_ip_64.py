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

import axis_ep
import eth_ep
import ip_ep

module = 'ip_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/ip_eth_rx_64.v")
srcs.append("../rtl/ip_eth_tx_64.v")
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
    input_eth_payload_tdata = Signal(intbv(0)[64:])
    input_eth_payload_tkeep = Signal(intbv(0)[8:])
    input_eth_payload_tvalid = Signal(bool(0))
    input_eth_payload_tlast = Signal(bool(0))
    input_eth_payload_tuser = Signal(bool(0))
    arp_request_ready = Signal(bool(0))
    arp_response_valid = Signal(bool(0))
    arp_response_error = Signal(bool(0))
    arp_response_mac = Signal(intbv(0)[48:])
    input_ip_hdr_valid = Signal(bool(0))
    input_ip_dscp = Signal(intbv(0)[6:])
    input_ip_ecn = Signal(intbv(0)[2:])
    input_ip_length = Signal(intbv(0)[16:])
    input_ip_ttl = Signal(intbv(0)[8:])
    input_ip_protocol = Signal(intbv(0)[8:])
    input_ip_source_ip = Signal(intbv(0)[32:])
    input_ip_dest_ip = Signal(intbv(0)[32:])
    input_ip_payload_tdata = Signal(intbv(0)[64:])
    input_ip_payload_tkeep = Signal(intbv(0)[8:])
    input_ip_payload_tvalid = Signal(bool(0))
    input_ip_payload_tlast = Signal(bool(0))
    input_ip_payload_tuser = Signal(bool(0))
    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))
    output_ip_hdr_ready = Signal(bool(0))
    output_ip_payload_tready = Signal(bool(0))

    # Outputs
    input_eth_hdr_ready = Signal(bool(0))
    input_eth_payload_tready = Signal(bool(0))
    input_ip_hdr_ready = Signal(bool(0))
    input_ip_payload_tready = Signal(bool(0))
    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[64:])
    output_eth_payload_tkeep = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))
    arp_request_valid = Signal(bool(0))
    arp_request_ip = Signal(intbv(0)[32:])
    arp_response_ready = Signal(bool(0))
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
    rx_busy = Signal(bool(0))
    tx_busy = Signal(bool(0))
    rx_error_header_early_termination = Signal(bool(0))
    rx_error_payload_early_termination = Signal(bool(0))
    rx_error_invalid_header = Signal(bool(0))
    rx_error_invalid_checksum = Signal(bool(0))
    tx_error_payload_early_termination = Signal(bool(0))
    tx_error_arp_failed = Signal(bool(0))
    local_mac = Signal(intbv(0)[48:])
    local_ip = Signal(intbv(0)[32:])

    # sources and sinks
    eth_source_pause = Signal(bool(0))
    eth_sink_pause = Signal(bool(0))
    ip_source_pause = Signal(bool(0))
    ip_sink_pause = Signal(bool(0))

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
        eth_payload_tkeep=input_eth_payload_tkeep,
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
        eth_payload_tkeep=output_eth_payload_tkeep,
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

    arp_request_sink = axis_ep.AXIStreamSink()

    arp_request_sink_logic = arp_request_sink.create_logic(
        clk,
        rst,
        tdata=(arp_request_ip,),
        tvalid=arp_request_valid,
        tready=arp_request_ready,
        name='arp_request_sink'
    )

    arp_response_source = axis_ep.AXIStreamSource()

    arp_response_source_logic = arp_response_source.create_logic(
        clk,
        rst,
        tdata=(arp_response_error, arp_response_mac),
        tvalid=arp_response_valid,
        tready=arp_response_ready,
        name='arp_response_source'
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
        input_eth_payload_tkeep=input_eth_payload_tkeep,
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
        output_eth_payload_tkeep=output_eth_payload_tkeep,
        output_eth_payload_tvalid=output_eth_payload_tvalid,
        output_eth_payload_tready=output_eth_payload_tready,
        output_eth_payload_tlast=output_eth_payload_tlast,
        output_eth_payload_tuser=output_eth_payload_tuser,

        arp_request_valid=arp_request_valid,
        arp_request_ready=arp_request_ready,
        arp_request_ip=arp_request_ip,
        arp_response_valid=arp_response_valid,
        arp_response_ready=arp_response_ready,
        arp_response_error=arp_response_error,
        arp_response_mac=arp_response_mac,

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

        rx_busy=rx_busy,
        tx_busy=tx_busy,
        rx_error_header_early_termination=rx_error_header_early_termination,
        rx_error_payload_early_termination=rx_error_payload_early_termination,
        rx_error_invalid_header=rx_error_invalid_header,
        rx_error_invalid_checksum=rx_error_invalid_checksum,
        tx_error_payload_early_termination=tx_error_payload_early_termination,
        tx_error_arp_failed=tx_error_arp_failed,

        local_mac=local_mac,
        local_ip=local_ip
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    arp_table = {}

    @instance
    def arp_emu():
        while True:
            yield clk.posedge

            if not arp_request_sink.empty():
                req_ip = arp_request_sink.recv().data[0][0]

                if req_ip in arp_table:
                    arp_response_source.send([(0, arp_table[req_ip])])
                else:
                    arp_response_source.send([(1, 0)])

    rx_error_header_early_termination_asserted = Signal(bool(0))
    rx_error_payload_early_termination_asserted = Signal(bool(0))
    rx_error_invalid_header_asserted = Signal(bool(0))
    rx_error_invalid_checksum_asserted = Signal(bool(0))
    tx_error_payload_early_termination_asserted = Signal(bool(0))
    tx_error_arp_failed_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (rx_error_header_early_termination):
            rx_error_header_early_termination_asserted.next = 1
        if (rx_error_payload_early_termination):
            rx_error_payload_early_termination_asserted.next = 1
        if (rx_error_invalid_header):
            rx_error_invalid_header_asserted.next = 1
        if (rx_error_invalid_checksum):
            rx_error_invalid_checksum_asserted.next = 1
        if (tx_error_payload_early_termination):
            tx_error_payload_early_termination_asserted.next = 1
        if (tx_error_arp_failed):
            tx_error_arp_failed_asserted.next = 1

    def wait_normal():
        while (input_eth_payload_tvalid or input_ip_payload_tvalid or
                output_eth_payload_tvalid or output_ip_payload_tvalid or
                input_eth_hdr_valid or input_ip_hdr_valid):
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

        # put an entry in the ARP table
        arp_table[0xc0a80165] = 0xDAD1D2D3D4D5

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
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80165
        test_frame.ip_dest_ip = 0xc0a80164
        test_frame.payload = bytearray(range(32))
        test_frame.build()
        eth_frame = test_frame.build_eth()

        eth_source.send(eth_frame)

        yield ip_sink.wait()
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
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80165
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        ip_source.send(test_frame)

        yield eth_sink.wait()
        rx_frame = eth_sink.recv()

        check_frame = ip_ep.IPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame == test_frame

        assert eth_source.empty()
        assert eth_sink.empty()
        assert ip_source.empty()
        assert ip_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 3: test IP TX arp fail packet")
        current_test.next = 2

        tx_error_arp_failed_asserted.next = 0

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
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80166
        test_frame.payload = bytearray(range(32))
        test_frame.build()

        ip_source.send(test_frame)

        yield clk.posedge
        yield clk.posedge

        yield wait_normal()

        yield clk.posedge
        yield clk.posedge

        assert tx_error_arp_failed_asserted

        assert eth_source.empty()
        assert eth_sink.empty()
        assert ip_source.empty()
        assert ip_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

