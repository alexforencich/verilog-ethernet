#!/usr/bin/env python2
"""

Copyright (c) 2014 Alex Forencich

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
from Queue import Queue

import eth_ep
import ip_ep

module = 'ip_eth_rx'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_ip_eth_rx(clk,
                    rst,
                    current_test,

                    input_eth_hdr_valid,
                    input_eth_hdr_ready,
                    input_eth_dest_mac,
                    input_eth_src_mac,
                    input_eth_type,
                    input_eth_payload_tdata,
                    input_eth_payload_tvalid,
                    input_eth_payload_tready,
                    input_eth_payload_tlast,
                    input_eth_payload_tuser,

                    output_ip_hdr_valid,
                    output_ip_hdr_ready,
                    output_eth_dest_mac,
                    output_eth_src_mac,
                    output_eth_type,
                    output_ip_version,
                    output_ip_ihl,
                    output_ip_dscp,
                    output_ip_ecn,
                    output_ip_length,
                    output_ip_identification,
                    output_ip_flags,
                    output_ip_fragment_offset,
                    output_ip_ttl,
                    output_ip_protocol,
                    output_ip_header_checksum,
                    output_ip_source_ip,
                    output_ip_dest_ip,
                    output_ip_payload_tdata,
                    output_ip_payload_tvalid,
                    output_ip_payload_tready,
                    output_ip_payload_tlast,
                    output_ip_payload_tuser,

                    busy,
                    error_header_early_termination,
                    error_payload_early_termination,
                    error_invalid_header,
                    error_invalid_checksum):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
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

                output_ip_hdr_valid=output_ip_hdr_valid,
                output_ip_hdr_ready=output_ip_hdr_ready,
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
                output_ip_payload_tdata=output_ip_payload_tdata,
                output_ip_payload_tvalid=output_ip_payload_tvalid,
                output_ip_payload_tready=output_ip_payload_tready,
                output_ip_payload_tlast=output_ip_payload_tlast,
                output_ip_payload_tuser=output_ip_payload_tuser,

                busy=busy,
                error_header_early_termination=error_header_early_termination,
                error_payload_early_termination=error_payload_early_termination,
                error_invalid_header=error_invalid_header,
                error_invalid_checksum=error_invalid_checksum)

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
    output_ip_hdr_ready = Signal(bool(0))
    output_ip_payload_tready = Signal(bool(0))

    # Outputs
    input_eth_hdr_ready = Signal(bool(0))
    input_eth_payload_tready = Signal(bool(0))
    output_ip_hdr_valid = Signal(bool(0))
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
    output_ip_protocol = Signal(intbv(0)[8:])
    output_ip_header_checksum = Signal(intbv(0)[16:])
    output_ip_source_ip = Signal(intbv(0)[32:])
    output_ip_dest_ip = Signal(intbv(0)[32:])
    output_ip_payload_tdata = Signal(intbv(0)[8:])
    output_ip_payload_tvalid = Signal(bool(0))
    output_ip_payload_tlast = Signal(bool(0))
    output_ip_payload_tuser = Signal(bool(0))
    busy = Signal(bool(0))
    error_header_early_termination = Signal(bool(0))
    error_payload_early_termination = Signal(bool(0))
    error_invalid_header = Signal(bool(0))
    error_invalid_checksum = Signal(bool(0))

    # sources and sinks
    source_queue = Queue()
    source_pause = Signal(bool(0))
    sink_queue = Queue()
    sink_pause = Signal(bool(0))

    source = eth_ep.EthFrameSource(clk,
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
                                   fifo=source_queue,
                                   pause=source_pause,
                                   name='source')

    sink = ip_ep.IPFrameSink(clk,
                             rst,
                             ip_hdr_ready=output_ip_hdr_ready,
                             ip_hdr_valid=output_ip_hdr_valid,
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
                             ip_payload_tdata=output_ip_payload_tdata,
                             ip_payload_tvalid=output_ip_payload_tvalid,
                             ip_payload_tready=output_ip_payload_tready,
                             ip_payload_tlast=output_ip_payload_tlast,
                             ip_payload_tuser=output_ip_payload_tuser,
                             fifo=sink_queue,
                             pause=sink_pause,
                             name='sink')

    # DUT
    dut = dut_ip_eth_rx(clk,
                        rst,
                        current_test,

                        input_eth_hdr_valid,
                        input_eth_hdr_ready,
                        input_eth_dest_mac,
                        input_eth_src_mac,
                        input_eth_type,
                        input_eth_payload_tdata,
                        input_eth_payload_tvalid,
                        input_eth_payload_tready,
                        input_eth_payload_tlast,
                        input_eth_payload_tuser,

                        output_ip_hdr_valid,
                        output_ip_hdr_ready,
                        output_eth_dest_mac,
                        output_eth_src_mac,
                        output_eth_type,
                        output_ip_version,
                        output_ip_ihl,
                        output_ip_dscp,
                        output_ip_ecn,
                        output_ip_length,
                        output_ip_identification,
                        output_ip_flags,
                        output_ip_fragment_offset,
                        output_ip_ttl,
                        output_ip_protocol,
                        output_ip_header_checksum,
                        output_ip_source_ip,
                        output_ip_dest_ip,
                        output_ip_payload_tdata,
                        output_ip_payload_tvalid,
                        output_ip_payload_tready,
                        output_ip_payload_tlast,
                        output_ip_payload_tuser,

                        busy,
                        error_header_early_termination,
                        error_payload_early_termination,
                        error_invalid_header,
                        error_invalid_checksum)

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
        print("test 1: test packet")
        current_test.next = 1

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: longer packet")
        current_test.next = 2

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = bytearray(range(256))
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 3: test packet with pauses")
        current_test.next = 3

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = bytearray(range(256))
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield delay(128)
        yield clk.posedge
        source_pause.next = True
        yield delay(32)
        yield clk.posedge
        source_pause.next = False

        yield delay(64)
        yield clk.posedge
        sink_pause.next = True
        yield delay(32)
        yield clk.posedge
        sink_pause.next = False

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 4: back-to-back packets")
        current_test.next = 4

        test_frame1 = ip_ep.IPFrame()
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
        test_frame1.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
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
        test_frame2.ip_dest_ip = 0xc0a80165
        test_frame2.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame2.build()
        source_queue.put(test_frame1.build_eth())
        source_queue.put(test_frame2.build_eth())
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 5: alternate pause source")
        current_test.next = 5

        test_frame1 = ip_ep.IPFrame()
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
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
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
        test_frame2.ip_dest_ip = 0xc0a80165
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()
        source_queue.put(test_frame1.build_eth())
        source_queue.put(test_frame2.build_eth())
        yield clk.posedge

        while input_eth_payload_tvalid or output_ip_payload_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 6: alternate pause sink")
        current_test.next = 6

        test_frame1 = ip_ep.IPFrame()
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
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
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
        test_frame2.ip_dest_ip = 0xc0a80165
        test_frame2.payload = bytearray(range(32))
        test_frame2.build()
        source_queue.put(test_frame1.build_eth())
        source_queue.put(test_frame2.build_eth())
        yield clk.posedge

        while input_eth_payload_tvalid or output_ip_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 7: alternate pause source 2")
        current_test.next = 7

        test_frame1 = ip_ep.IPFrame()
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
        test_frame1.payload = bytearray(range(32))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
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
        test_frame2.ip_dest_ip = 0xc0a80165
        test_frame2.payload = bytearray(range(33))
        test_frame2.build()
        source_queue.put(test_frame1.build_eth())
        source_queue.put(test_frame2.build_eth())
        yield clk.posedge

        while input_eth_payload_tvalid or output_ip_payload_tvalid:
            source_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            source_pause.next = False
            yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 8: alternate pause sink 2")
        current_test.next = 8

        test_frame1 = ip_ep.IPFrame()
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
        test_frame1.payload = bytearray(range(33))
        test_frame1.build()
        test_frame2 = ip_ep.IPFrame()
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
        test_frame2.ip_dest_ip = 0xc0a80165
        test_frame2.payload = bytearray(range(33))
        test_frame2.build()
        source_queue.put(test_frame1.build_eth())
        source_queue.put(test_frame2.build_eth())
        yield clk.posedge

        while input_eth_payload_tvalid or output_ip_payload_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame1

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame2

        yield delay(100)

        yield clk.posedge
        print("test 9: tuser assert")
        current_test.next = 9

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        eth_frame = test_frame.build_eth()
        eth_frame.payload.user = 1

        source_queue.put(eth_frame)
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame
        assert rx_frame.payload.user[-1]

        yield delay(100)

        yield clk.posedge
        print("test 10: truncated packet")
        current_test.next = 10

        eth_frame = eth_ep.EthFrame()
        eth_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        eth_frame.eth_src_mac = 0x5A5152535455
        eth_frame.eth_type = 0x0800
        eth_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'

        source_queue.put(eth_frame)
        yield clk.posedge

        yield input_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge
        assert error_header_early_termination

        yield delay(100)

        yield clk.posedge
        print("test 11: trailing bytes")
        current_test.next = 11

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        eth_frame = test_frame.build_eth()
        eth_frame.payload.data += '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'

        source_queue.put(eth_frame)
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame

        yield clk.posedge
        print("test 12: trailing bytes with tuser assert")
        current_test.next = 12

        test_frame = ip_ep.IPFrame()
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
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        eth_frame = test_frame.build_eth()
        eth_frame.payload.data += '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
        eth_frame.payload.user = 1

        source_queue.put(eth_frame)
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        assert rx_frame == test_frame
        assert rx_frame.payload.user[-1]

        yield delay(100)

        yield clk.posedge
        print("test 13: truncated payload")
        current_test.next = 13

        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 5
        test_frame.ip_length = 32
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80165
        test_frame.payload = '\x01\x02'
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield output_ip_payload_tlast.posedge
        yield clk.posedge
        assert error_payload_early_termination
        yield clk.posedge

        rx_frame = None
        if not sink_queue.empty():
            rx_frame = sink_queue.get()

        #assert rx_frame == test_frame
        assert rx_frame.payload.user[-1]

        yield delay(100)

        yield clk.posedge
        print("test 14: bad IHL")
        current_test.next = 14

        test_frame = ip_ep.IPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 6
        test_frame.ip_length = None
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80165
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield delay(160)
        yield clk.posedge
        yield clk.posedge

        assert error_invalid_header

        yield input_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        yield delay(100)

        yield clk.posedge
        print("test 15: bad checksum")
        current_test.next = 15

        test_frame = ip_ep.IPFrame()
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
        test_frame.ip_header_checksum = 0x1234
        test_frame.ip_source_ip = 0xc0a80164
        test_frame.ip_dest_ip = 0xc0a80165
        test_frame.payload = '\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C'
        test_frame.build()
        source_queue.put(test_frame.build_eth())
        yield clk.posedge

        yield delay(160)
        yield clk.posedge
        yield clk.posedge

        assert error_invalid_checksum

        yield input_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        yield delay(100)

        raise StopSimulation

    return dut, source, sink, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

