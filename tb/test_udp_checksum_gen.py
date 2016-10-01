#!/usr/bin/env python
"""

Copyright (c) 2016 Alex Forencich

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

module = 'udp_checksum_gen'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/axis/rtl/axis_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    PAYLOAD_FIFO_ADDR_WIDTH = 11
    HEADER_FIFO_ADDR_WIDTH = 3

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_udp_hdr_valid = Signal(bool(0))
    input_eth_dest_mac = Signal(intbv(0)[48:])
    input_eth_src_mac = Signal(intbv(0)[48:])
    input_eth_type = Signal(intbv(0)[16:])
    input_ip_version = Signal(intbv(0)[4:])
    input_ip_ihl = Signal(intbv(0)[4:])
    input_ip_dscp = Signal(intbv(0)[6:])
    input_ip_ecn = Signal(intbv(0)[2:])
    input_ip_identification = Signal(intbv(0)[16:])
    input_ip_flags = Signal(intbv(0)[3:])
    input_ip_fragment_offset = Signal(intbv(0)[13:])
    input_ip_ttl = Signal(intbv(0)[8:])
    input_ip_header_checksum = Signal(intbv(0)[16:])
    input_ip_source_ip = Signal(intbv(0)[32:])
    input_ip_dest_ip = Signal(intbv(0)[32:])
    input_udp_source_port = Signal(intbv(0)[16:])
    input_udp_dest_port = Signal(intbv(0)[16:])
    input_udp_payload_tdata = Signal(intbv(0)[8:])
    input_udp_payload_tvalid = Signal(bool(0))
    input_udp_payload_tlast = Signal(bool(0))
    input_udp_payload_tuser = Signal(bool(0))

    output_udp_hdr_ready = Signal(bool(0))
    output_udp_payload_tready = Signal(bool(0))

    # Outputs
    input_udp_hdr_ready = Signal(bool(0))
    input_udp_payload_tready = Signal(bool(0))

    output_udp_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_ip_version = Signal(intbv(0)[4:])
    output_ip_ihl = Signal(intbv(0)[4:])
    output_ip_dscp = Signal(intbv(0)[6:])
    output_ip_ecn = Signal(intbv(0)[2:])
    output_ip_length = Signal(intbv(0)[16:])
    output_ip_identification = Signal(intbv(0)[16:])
    output_ip_flags = Signal(intbv(0)[3:])
    output_ip_fragment_offset = Signal(intbv(0)[13:])
    output_ip_ttl = Signal(intbv(0)[8:])
    output_ip_protocol = Signal(intbv(0x11)[8:])
    output_ip_header_checksum = Signal(intbv(0)[16:])
    output_ip_source_ip = Signal(intbv(0)[32:])
    output_ip_dest_ip = Signal(intbv(0)[32:])
    output_udp_source_port = Signal(intbv(0)[16:])
    output_udp_dest_port = Signal(intbv(0)[16:])
    output_udp_length = Signal(intbv(0)[16:])
    output_udp_checksum = Signal(intbv(0)[16:])
    output_udp_payload_tdata = Signal(intbv(0)[8:])
    output_udp_payload_tvalid = Signal(bool(0))
    output_udp_payload_tlast = Signal(bool(0))
    output_udp_payload_tuser = Signal(bool(0))

    busy = Signal(bool(0))

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = udp_ep.UDPFrameSource()

    source_logic = source.create_logic(
        clk,
        rst,
        udp_hdr_ready=input_udp_hdr_ready,
        udp_hdr_valid=input_udp_hdr_valid,
        eth_dest_mac=input_eth_dest_mac,
        eth_src_mac=input_eth_src_mac,
        eth_type=input_eth_type,
        ip_version=input_ip_version,
        ip_ihl=input_ip_ihl,
        ip_dscp=input_ip_dscp,
        ip_ecn=input_ip_ecn,
        ip_identification=input_ip_identification,
        ip_flags=input_ip_flags,
        ip_fragment_offset=input_ip_fragment_offset,
        ip_ttl=input_ip_ttl,
        ip_header_checksum=input_ip_header_checksum,
        ip_source_ip=input_ip_source_ip,
        ip_dest_ip=input_ip_dest_ip,
        udp_source_port=input_udp_source_port,
        udp_dest_port=input_udp_dest_port,
        udp_payload_tdata=input_udp_payload_tdata,
        udp_payload_tvalid=input_udp_payload_tvalid,
        udp_payload_tready=input_udp_payload_tready,
        udp_payload_tlast=input_udp_payload_tlast,
        udp_payload_tuser=input_udp_payload_tuser,
        pause=source_pause,
        name='source'
    )

    sink = udp_ep.UDPFrameSink()

    sink_logic = sink.create_logic(
        clk,
        rst,
        udp_hdr_ready=output_udp_hdr_ready,
        udp_hdr_valid=output_udp_hdr_valid,
        eth_dest_mac=output_eth_dest_mac,
        eth_src_mac=output_eth_src_mac,
        eth_type=output_eth_type,
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
        udp_source_port=output_udp_source_port,
        udp_dest_port=output_udp_dest_port,
        udp_length=output_udp_length,
        udp_checksum=output_udp_checksum,
        udp_payload_tdata=output_udp_payload_tdata,
        udp_payload_tvalid=output_udp_payload_tvalid,
        udp_payload_tready=output_udp_payload_tready,
        udp_payload_tlast=output_udp_payload_tlast,
        udp_payload_tuser=output_udp_payload_tuser,
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

        input_udp_hdr_valid=input_udp_hdr_valid,
        input_udp_hdr_ready=input_udp_hdr_ready,
        input_eth_dest_mac=input_eth_dest_mac,
        input_eth_src_mac=input_eth_src_mac,
        input_eth_type=input_eth_type,
        input_ip_version=input_ip_version,
        input_ip_ihl=input_ip_ihl,
        input_ip_dscp=input_ip_dscp,
        input_ip_ecn=input_ip_ecn,
        input_ip_identification=input_ip_identification,
        input_ip_flags=input_ip_flags,
        input_ip_fragment_offset=input_ip_fragment_offset,
        input_ip_ttl=input_ip_ttl,
        input_ip_header_checksum=input_ip_header_checksum,
        input_ip_source_ip=input_ip_source_ip,
        input_ip_dest_ip=input_ip_dest_ip,
        input_udp_source_port=input_udp_source_port,
        input_udp_dest_port=input_udp_dest_port,
        input_udp_payload_tdata=input_udp_payload_tdata,
        input_udp_payload_tvalid=input_udp_payload_tvalid,
        input_udp_payload_tready=input_udp_payload_tready,
        input_udp_payload_tlast=input_udp_payload_tlast,
        input_udp_payload_tuser=input_udp_payload_tuser,

        output_udp_hdr_valid=output_udp_hdr_valid,
        output_udp_hdr_ready=output_udp_hdr_ready,
        output_eth_dest_mac=output_eth_dest_mac,
        output_eth_src_mac=output_eth_src_mac,
        output_eth_type=output_eth_type,
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
        output_udp_source_port=output_udp_source_port,
        output_udp_dest_port=output_udp_dest_port,
        output_udp_length=output_udp_length,
        output_udp_checksum=output_udp_checksum,
        output_udp_payload_tdata=output_udp_payload_tdata,
        output_udp_payload_tvalid=output_udp_payload_tvalid,
        output_udp_payload_tready=output_udp_payload_tready,
        output_udp_payload_tlast=output_udp_payload_tlast,
        output_udp_payload_tuser=output_udp_payload_tuser,

        busy=busy
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if input_udp_payload_tvalid or output_udp_payload_tvalid or input_udp_hdr_valid or not source.empty():
                i = 4
            yield clk.posedge

    def wait_pause_source():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if input_udp_payload_tvalid or output_udp_payload_tvalid or input_udp_hdr_valid or not source.empty():
                i = 2
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

    def wait_pause_sink():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if input_udp_payload_tvalid or output_udp_payload_tvalid or input_udp_hdr_valid or not source.empty():
                i = 2
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

        # testbench stimulus

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

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame

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

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame1

                rx_frame = sink.recv()

                assert rx_frame == test_frame2

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

                yield clk.posedge
                yield clk.posedge
                yield clk.posedge

                rx_frame = sink.recv()

                assert rx_frame == test_frame1
                assert rx_frame.payload.user[-1]

                rx_frame = sink.recv()

                assert rx_frame == test_frame2

                assert sink.empty()

                yield delay(100)

        raise StopSimulation

    return dut, source_logic, sink_logic, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
