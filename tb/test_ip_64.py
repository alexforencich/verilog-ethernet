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

    s_eth_hdr_valid = Signal(bool(0))
    s_eth_dest_mac = Signal(intbv(0)[48:])
    s_eth_src_mac = Signal(intbv(0)[48:])
    s_eth_type = Signal(intbv(0)[16:])
    s_eth_payload_axis_tdata = Signal(intbv(0)[64:])
    s_eth_payload_axis_tkeep = Signal(intbv(0)[8:])
    s_eth_payload_axis_tvalid = Signal(bool(0))
    s_eth_payload_axis_tlast = Signal(bool(0))
    s_eth_payload_axis_tuser = Signal(bool(0))
    arp_request_ready = Signal(bool(0))
    arp_response_valid = Signal(bool(0))
    arp_response_error = Signal(bool(0))
    arp_response_mac = Signal(intbv(0)[48:])
    s_ip_hdr_valid = Signal(bool(0))
    s_ip_dscp = Signal(intbv(0)[6:])
    s_ip_ecn = Signal(intbv(0)[2:])
    s_ip_length = Signal(intbv(0)[16:])
    s_ip_ttl = Signal(intbv(0)[8:])
    s_ip_protocol = Signal(intbv(0)[8:])
    s_ip_source_ip = Signal(intbv(0)[32:])
    s_ip_dest_ip = Signal(intbv(0)[32:])
    s_ip_payload_axis_tdata = Signal(intbv(0)[64:])
    s_ip_payload_axis_tkeep = Signal(intbv(0)[8:])
    s_ip_payload_axis_tvalid = Signal(bool(0))
    s_ip_payload_axis_tlast = Signal(bool(0))
    s_ip_payload_axis_tuser = Signal(bool(0))
    m_eth_payload_axis_tready = Signal(bool(0))
    m_eth_hdr_ready = Signal(bool(0))
    m_ip_hdr_ready = Signal(bool(0))
    m_ip_payload_axis_tready = Signal(bool(0))

    # Outputs
    s_eth_hdr_ready = Signal(bool(0))
    s_eth_payload_axis_tready = Signal(bool(0))
    s_ip_hdr_ready = Signal(bool(0))
    s_ip_payload_axis_tready = Signal(bool(0))
    m_eth_hdr_valid = Signal(bool(0))
    m_eth_dest_mac = Signal(intbv(0)[48:])
    m_eth_src_mac = Signal(intbv(0)[48:])
    m_eth_type = Signal(intbv(0)[16:])
    m_eth_payload_axis_tdata = Signal(intbv(0)[64:])
    m_eth_payload_axis_tkeep = Signal(intbv(0)[8:])
    m_eth_payload_axis_tvalid = Signal(bool(0))
    m_eth_payload_axis_tlast = Signal(bool(0))
    m_eth_payload_axis_tuser = Signal(bool(0))
    arp_request_valid = Signal(bool(0))
    arp_request_ip = Signal(intbv(0)[32:])
    arp_response_ready = Signal(bool(0))
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
        eth_hdr_ready=s_eth_hdr_ready,
        eth_hdr_valid=s_eth_hdr_valid,
        eth_dest_mac=s_eth_dest_mac,
        eth_src_mac=s_eth_src_mac,
        eth_type=s_eth_type,
        eth_payload_tdata=s_eth_payload_axis_tdata,
        eth_payload_tkeep=s_eth_payload_axis_tkeep,
        eth_payload_tvalid=s_eth_payload_axis_tvalid,
        eth_payload_tready=s_eth_payload_axis_tready,
        eth_payload_tlast=s_eth_payload_axis_tlast,
        eth_payload_tuser=s_eth_payload_axis_tuser,
        pause=eth_source_pause,
        name='eth_source'
    )

    eth_sink = eth_ep.EthFrameSink()

    eth_sink_logic = eth_sink.create_logic(
        clk,
        rst,
        eth_hdr_ready=m_eth_hdr_ready,
        eth_hdr_valid=m_eth_hdr_valid,
        eth_dest_mac=m_eth_dest_mac,
        eth_src_mac=m_eth_src_mac,
        eth_type=m_eth_type,
        eth_payload_tdata=m_eth_payload_axis_tdata,
        eth_payload_tkeep=m_eth_payload_axis_tkeep,
        eth_payload_tvalid=m_eth_payload_axis_tvalid,
        eth_payload_tready=m_eth_payload_axis_tready,
        eth_payload_tlast=m_eth_payload_axis_tlast,
        eth_payload_tuser=m_eth_payload_axis_tuser,
        pause=eth_sink_pause,
        name='eth_sink'
    )

    ip_source = ip_ep.IPFrameSource()

    ip_source_logic = ip_source.create_logic(
        clk,
        rst,
        ip_hdr_valid=s_ip_hdr_valid,
        ip_hdr_ready=s_ip_hdr_ready,
        ip_dscp=s_ip_dscp,
        ip_ecn=s_ip_ecn,
        ip_length=s_ip_length,
        ip_ttl=s_ip_ttl,
        ip_protocol=s_ip_protocol,
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

        s_eth_hdr_valid=s_eth_hdr_valid,
        s_eth_hdr_ready=s_eth_hdr_ready,
        s_eth_dest_mac=s_eth_dest_mac,
        s_eth_src_mac=s_eth_src_mac,
        s_eth_type=s_eth_type,
        s_eth_payload_axis_tdata=s_eth_payload_axis_tdata,
        s_eth_payload_axis_tkeep=s_eth_payload_axis_tkeep,
        s_eth_payload_axis_tvalid=s_eth_payload_axis_tvalid,
        s_eth_payload_axis_tready=s_eth_payload_axis_tready,
        s_eth_payload_axis_tlast=s_eth_payload_axis_tlast,
        s_eth_payload_axis_tuser=s_eth_payload_axis_tuser,

        m_eth_hdr_valid=m_eth_hdr_valid,
        m_eth_hdr_ready=m_eth_hdr_ready,
        m_eth_dest_mac=m_eth_dest_mac,
        m_eth_src_mac=m_eth_src_mac,
        m_eth_type=m_eth_type,
        m_eth_payload_axis_tdata=m_eth_payload_axis_tdata,
        m_eth_payload_axis_tkeep=m_eth_payload_axis_tkeep,
        m_eth_payload_axis_tvalid=m_eth_payload_axis_tvalid,
        m_eth_payload_axis_tready=m_eth_payload_axis_tready,
        m_eth_payload_axis_tlast=m_eth_payload_axis_tlast,
        m_eth_payload_axis_tuser=m_eth_payload_axis_tuser,

        arp_request_valid=arp_request_valid,
        arp_request_ready=arp_request_ready,
        arp_request_ip=arp_request_ip,
        arp_response_valid=arp_response_valid,
        arp_response_ready=arp_response_ready,
        arp_response_error=arp_response_error,
        arp_response_mac=arp_response_mac,

        s_ip_hdr_valid=s_ip_hdr_valid,
        s_ip_hdr_ready=s_ip_hdr_ready,
        s_ip_dscp=s_ip_dscp,
        s_ip_ecn=s_ip_ecn,
        s_ip_length=s_ip_length,
        s_ip_ttl=s_ip_ttl,
        s_ip_protocol=s_ip_protocol,
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
        while (s_eth_payload_axis_tvalid or s_ip_payload_axis_tvalid or
                m_eth_payload_axis_tvalid or m_ip_payload_axis_tvalid or
                s_eth_hdr_valid or s_ip_hdr_valid):
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

