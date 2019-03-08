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

module = 'udp_ip_tx_64'
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

    s_udp_hdr_valid = Signal(bool(0))
    s_eth_dest_mac = Signal(intbv(0)[48:])
    s_eth_src_mac = Signal(intbv(0)[48:])
    s_eth_type = Signal(intbv(0)[16:])
    s_ip_version = Signal(intbv(0)[4:])
    s_ip_ihl = Signal(intbv(0)[4:])
    s_ip_dscp = Signal(intbv(0)[6:])
    s_ip_ecn = Signal(intbv(0)[2:])
    s_ip_identification = Signal(intbv(0)[16:])
    s_ip_flags = Signal(intbv(0)[3:])
    s_ip_fragment_offset = Signal(intbv(0)[13:])
    s_ip_ttl = Signal(intbv(0)[8:])
    s_ip_protocol = Signal(intbv(0)[8:])
    s_ip_header_checksum = Signal(intbv(0)[16:])
    s_ip_source_ip = Signal(intbv(0)[32:])
    s_ip_dest_ip = Signal(intbv(0)[32:])
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

    # Outputs
    s_udp_hdr_ready = Signal(bool(0))
    s_udp_payload_axis_tready = Signal(bool(0))
    m_ip_hdr_valid = Signal(bool(0))
    m_eth_dest_mac = Signal(intbv(0)[48:])
    m_eth_src_mac = Signal(intbv(0)[48:])
    m_eth_type = Signal(intbv(0)[16:])
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
    busy = Signal(bool(0))
    error_payload_early_termination = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = udp_ep.UDPFrameSource()

    source_logic = source.create_logic(
        clk,
        rst,
        udp_hdr_ready=s_udp_hdr_ready,
        udp_hdr_valid=s_udp_hdr_valid,
        eth_dest_mac=s_eth_dest_mac,
        eth_src_mac=s_eth_src_mac,
        eth_type=s_eth_type,
        ip_version=s_ip_version,
        ip_ihl=s_ip_ihl,
        ip_dscp=s_ip_dscp,
        ip_ecn=s_ip_ecn,
        ip_identification=s_ip_identification,
        ip_flags=s_ip_flags,
        ip_fragment_offset=s_ip_fragment_offset,
        ip_ttl=s_ip_ttl,
        ip_protocol=s_ip_protocol,
        ip_header_checksum=s_ip_header_checksum,
        ip_source_ip=s_ip_source_ip,
        ip_dest_ip=s_ip_dest_ip,
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
        pause=source_pause,
        name='source'
    )

    sink = ip_ep.IPFrameSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        ip_hdr_ready=m_ip_hdr_ready,
        ip_hdr_valid=m_ip_hdr_valid,
        eth_dest_mac=m_eth_dest_mac,
        eth_src_mac=m_eth_src_mac,
        eth_type=m_eth_type,
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
        pause=sink_pause,
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

        s_udp_hdr_valid=s_udp_hdr_valid,
        s_udp_hdr_ready=s_udp_hdr_ready,
        s_eth_dest_mac=s_eth_dest_mac,
        s_eth_src_mac=s_eth_src_mac,
        s_eth_type=s_eth_type,
        s_ip_version=s_ip_version,
        s_ip_ihl=s_ip_ihl,
        s_ip_dscp=s_ip_dscp,
        s_ip_ecn=s_ip_ecn,
        s_ip_identification=s_ip_identification,
        s_ip_flags=s_ip_flags,
        s_ip_fragment_offset=s_ip_fragment_offset,
        s_ip_ttl=s_ip_ttl,
        s_ip_protocol=s_ip_protocol,
        s_ip_header_checksum=s_ip_header_checksum,
        s_ip_source_ip=s_ip_source_ip,
        s_ip_dest_ip=s_ip_dest_ip,
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

        m_ip_hdr_valid=m_ip_hdr_valid,
        m_ip_hdr_ready=m_ip_hdr_ready,
        m_eth_dest_mac=m_eth_dest_mac,
        m_eth_src_mac=m_eth_src_mac,
        m_eth_type=m_eth_type,
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

        busy=busy,
        error_payload_early_termination=error_payload_early_termination
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    error_payload_early_termination_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (error_payload_early_termination):
            error_payload_early_termination_asserted.next = 1

    def wait_normal():
        while s_udp_payload_axis_tvalid or m_ip_payload_axis_tvalid or s_udp_hdr_valid:
            yield clk.posedge

    def wait_pause_source():
        while s_udp_payload_axis_tvalid or m_ip_payload_axis_tvalid or s_udp_hdr_valid:
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge
            source_pause.next = True
            yield clk.posedge

        source_pause.next = False

    def wait_pause_sink():
        while s_udp_payload_axis_tvalid or m_ip_payload_axis_tvalid or s_udp_hdr_valid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
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

        for payload_len in range(1,18):
            yield clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = udp_ep.UDPFrame()
            test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame.eth_src_mac = 0x5A5152535455
            test_frame.eth_type = 0x0800
            test_frame.ip_version = 4
            test_frame.ip_ihl = 5
            test_frame.ip_length = None
            test_frame.ip_identification = 0
            test_frame.ip_flags = 2
            test_frame.ip_fragment_offset = 0
            test_frame.ip_ttl = 64
            test_frame.ip_protocol = 0x11
            test_frame.ip_header_checksum = None
            test_frame.ip_source_ip = 0xc0a80164
            test_frame.ip_dest_ip = 0xc0a80165
            test_frame.udp_source_port = 1
            test_frame.udp_dest_port = 2
            test_frame.udp_length = None
            test_frame.udp_checksum = None
            test_frame.payload = bytearray(range(payload_len))
            test_frame.build()

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 2: back-to-back packets, length %d" % payload_len)
            current_test.next = 2

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 3: tuser assert, length %d" % payload_len)
            current_test.next = 3

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1.payload.user = 1

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1
                assert rx_frame.payload.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 4: trailing bytes (1), length %d" % payload_len)
            current_test.next = 4

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data += bytearray(b'\x00')

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 5: trailing bytes (10), length %d" % payload_len)
            current_test.next = 5

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data += bytearray(b'\x00'*10)

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 6: trailing bytes with tuser assert (1), length %d" % payload_len)
            current_test.next = 6

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data += bytearray(b'\x00')
            test_frame1a.payload.user = 1

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1
                assert rx_frame.payload.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 7: trailing bytes with tuser assert (10), length %d" % payload_len)
            current_test.next = 7

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data += bytearray(b'\x00'*10)
            test_frame1a.payload.user = 1

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame1
                assert rx_frame.payload.user[-1]

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 8: truncated payload (1), length %d" % payload_len)
            current_test.next = 8

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len+1))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data = test_frame1a.payload.data[:-1]

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                error_payload_early_termination_asserted.next = 0

                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert rx_frame.payload.user[-1]
                assert error_payload_early_termination_asserted

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

                assert sink.empty()

                yield delay(100)

            yield clk.posedge
            print("test 9: truncated payload (10), length %d" % payload_len)
            current_test.next = 9

            test_frame1 = udp_ep.UDPFrame()
            test_frame1.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame1.eth_src_mac = 0x5A5152535455
            test_frame1.eth_type = 0x0800
            test_frame1.ip_version = 4
            test_frame1.ip_ihl = 5
            test_frame1.ip_length = None
            test_frame1.ip_identification = 0
            test_frame1.ip_flags = 2
            test_frame1.ip_fragment_offset = 0
            test_frame1.ip_ttl = 64
            test_frame1.ip_protocol = 0x11
            test_frame1.ip_header_checksum = None
            test_frame1.ip_source_ip = 0xc0a80164
            test_frame1.ip_dest_ip = 0xc0a80165
            test_frame1.udp_source_port = 1
            test_frame1.udp_dest_port = 2
            test_frame1.udp_length = None
            test_frame1.udp_checksum = None
            test_frame1.payload = bytearray(range(payload_len+10))
            test_frame1.build()
            test_frame2 = udp_ep.UDPFrame()
            test_frame2.eth_dest_mac = 0xDAD1D2D3D4D5
            test_frame2.eth_src_mac = 0x5A5152535455
            test_frame2.eth_type = 0x0800
            test_frame2.ip_version = 4
            test_frame2.ip_ihl = 5
            test_frame2.ip_length = None
            test_frame2.ip_identification = 0
            test_frame2.ip_flags = 2
            test_frame2.ip_fragment_offset = 0
            test_frame2.ip_ttl = 64
            test_frame2.ip_protocol = 0x11
            test_frame2.ip_header_checksum = None
            test_frame2.ip_source_ip = 0xc0a80164
            test_frame2.ip_dest_ip = 0xc0a80166
            test_frame2.udp_source_port = 1
            test_frame2.udp_dest_port = 2
            test_frame2.udp_length = None
            test_frame2.udp_checksum = None
            test_frame2.payload = bytearray(range(payload_len))
            test_frame2.build()

            test_frame1a = udp_ep.UDPFrame(test_frame1)
            test_frame1a.payload.data = test_frame1.payload.data[:-10]

            for wait in wait_normal, wait_pause_source, wait_pause_sink:
                error_payload_early_termination_asserted.next = 0

                source.send(test_frame1a)
                source.send(test_frame2)
                yield clk.posedge
                yield clk.posedge

                yield wait()

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert rx_frame.payload.user[-1]
                assert error_payload_early_termination_asserted

                yield sink.wait()
                rx_frame = sink.recv()

                check_frame = udp_ep.UDPFrame()
                check_frame.parse_ip(rx_frame)

                assert check_frame == test_frame2

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

