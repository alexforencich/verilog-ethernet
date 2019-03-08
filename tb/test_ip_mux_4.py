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

import ip_ep

module = 'ip_mux'
testbench = 'test_%s_4' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    S_COUNT = 4
    DATA_WIDTH = 8
    KEEP_ENABLE = (DATA_WIDTH>8)
    KEEP_WIDTH = (DATA_WIDTH/8)
    ID_ENABLE = 1
    ID_WIDTH = 8
    DEST_ENABLE = 1
    DEST_WIDTH = 8
    USER_ENABLE = 1
    USER_WIDTH = 1

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_ip_hdr_valid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_eth_dest_mac_list = [Signal(intbv(0)[48:]) for i in range(S_COUNT)]
    s_eth_src_mac_list = [Signal(intbv(0)[48:]) for i in range(S_COUNT)]
    s_eth_type_list = [Signal(intbv(0)[16:]) for i in range(S_COUNT)]
    s_ip_version_list = [Signal(intbv(0)[4:]) for i in range(S_COUNT)]
    s_ip_ihl_list = [Signal(intbv(0)[4:]) for i in range(S_COUNT)]
    s_ip_dscp_list = [Signal(intbv(0)[6:]) for i in range(S_COUNT)]
    s_ip_ecn_list = [Signal(intbv(0)[2:]) for i in range(S_COUNT)]
    s_ip_length_list = [Signal(intbv(0)[16:]) for i in range(S_COUNT)]
    s_ip_identification_list = [Signal(intbv(0)[16:]) for i in range(S_COUNT)]
    s_ip_flags_list = [Signal(intbv(0)[3:]) for i in range(S_COUNT)]
    s_ip_fragment_offset_list = [Signal(intbv(0)[13:]) for i in range(S_COUNT)]
    s_ip_ttl_list = [Signal(intbv(0)[8:]) for i in range(S_COUNT)]
    s_ip_protocol_list = [Signal(intbv(0)[8:]) for i in range(S_COUNT)]
    s_ip_header_checksum_list = [Signal(intbv(0)[16:]) for i in range(S_COUNT)]
    s_ip_source_ip_list = [Signal(intbv(0)[32:]) for i in range(S_COUNT)]
    s_ip_dest_ip_list = [Signal(intbv(0)[32:]) for i in range(S_COUNT)]
    s_ip_payload_axis_tdata_list = [Signal(intbv(0)[DATA_WIDTH:]) for i in range(S_COUNT)]
    s_ip_payload_axis_tkeep_list = [Signal(intbv(1)[KEEP_WIDTH:]) for i in range(S_COUNT)]
    s_ip_payload_axis_tvalid_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_ip_payload_axis_tlast_list = [Signal(bool(0)) for i in range(S_COUNT)]
    s_ip_payload_axis_tid_list = [Signal(intbv(0)[ID_WIDTH:]) for i in range(S_COUNT)]
    s_ip_payload_axis_tdest_list = [Signal(intbv(0)[DEST_WIDTH:]) for i in range(S_COUNT)]
    s_ip_payload_axis_tuser_list = [Signal(intbv(0)[USER_WIDTH:]) for i in range(S_COUNT)]

    s_ip_hdr_valid = ConcatSignal(*reversed(s_ip_hdr_valid_list))
    s_eth_dest_mac = ConcatSignal(*reversed(s_eth_dest_mac_list))
    s_eth_src_mac = ConcatSignal(*reversed(s_eth_src_mac_list))
    s_eth_type = ConcatSignal(*reversed(s_eth_type_list))
    s_ip_version = ConcatSignal(*reversed(s_ip_version_list))
    s_ip_ihl = ConcatSignal(*reversed(s_ip_ihl_list))
    s_ip_dscp = ConcatSignal(*reversed(s_ip_dscp_list))
    s_ip_ecn = ConcatSignal(*reversed(s_ip_ecn_list))
    s_ip_length = ConcatSignal(*reversed(s_ip_length_list))
    s_ip_identification = ConcatSignal(*reversed(s_ip_identification_list))
    s_ip_flags = ConcatSignal(*reversed(s_ip_flags_list))
    s_ip_fragment_offset = ConcatSignal(*reversed(s_ip_fragment_offset_list))
    s_ip_ttl = ConcatSignal(*reversed(s_ip_ttl_list))
    s_ip_protocol = ConcatSignal(*reversed(s_ip_protocol_list))
    s_ip_header_checksum = ConcatSignal(*reversed(s_ip_header_checksum_list))
    s_ip_source_ip = ConcatSignal(*reversed(s_ip_source_ip_list))
    s_ip_dest_ip = ConcatSignal(*reversed(s_ip_dest_ip_list))
    s_ip_payload_axis_tdata = ConcatSignal(*reversed(s_ip_payload_axis_tdata_list))
    s_ip_payload_axis_tkeep = ConcatSignal(*reversed(s_ip_payload_axis_tkeep_list))
    s_ip_payload_axis_tvalid = ConcatSignal(*reversed(s_ip_payload_axis_tvalid_list))
    s_ip_payload_axis_tlast = ConcatSignal(*reversed(s_ip_payload_axis_tlast_list))
    s_ip_payload_axis_tid = ConcatSignal(*reversed(s_ip_payload_axis_tid_list))
    s_ip_payload_axis_tdest = ConcatSignal(*reversed(s_ip_payload_axis_tdest_list))
    s_ip_payload_axis_tuser = ConcatSignal(*reversed(s_ip_payload_axis_tuser_list))

    m_ip_hdr_ready = Signal(bool(0))
    m_ip_payload_axis_tready = Signal(bool(0))

    enable = Signal(bool(0))
    select = Signal(intbv(0)[2:])

    # Outputs
    s_ip_hdr_ready = Signal(intbv(0)[S_COUNT:])
    s_ip_payload_axis_tready = Signal(intbv(0)[S_COUNT:])

    s_ip_hdr_ready_list = [s_ip_hdr_ready(i) for i in range(S_COUNT)]
    s_ip_payload_axis_tready_list = [s_ip_payload_axis_tready(i) for i in range(S_COUNT)]

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
    m_ip_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_ip_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_ip_payload_axis_tvalid = Signal(bool(0))
    m_ip_payload_axis_tlast = Signal(bool(0))
    m_ip_payload_axis_tid = Signal(intbv(0)[ID_WIDTH:])
    m_ip_payload_axis_tdest = Signal(intbv(0)[DEST_WIDTH:])
    m_ip_payload_axis_tuser = Signal(intbv(0)[USER_WIDTH:])

    # sources and sinks
    source_pause_list = []
    source_list = []
    source_logic_list = []
    sink_pause = Signal(bool(0))

    for k in range(S_COUNT):
        s = ip_ep.IPFrameSource()
        p = Signal(bool(0))

        source_list.append(s)
        source_pause_list.append(p)

        source_logic_list.append(s.create_logic(
            clk,
            rst,
            ip_hdr_ready=s_ip_hdr_ready_list[k],
            ip_hdr_valid=s_ip_hdr_valid_list[k],
            eth_dest_mac=s_eth_dest_mac_list[k],
            eth_src_mac=s_eth_src_mac_list[k],
            eth_type=s_eth_type_list[k],
            ip_version=s_ip_version_list[k],
            ip_ihl=s_ip_ihl_list[k],
            ip_dscp=s_ip_dscp_list[k],
            ip_ecn=s_ip_ecn_list[k],
            ip_length=s_ip_length_list[k],
            ip_identification=s_ip_identification_list[k],
            ip_flags=s_ip_flags_list[k],
            ip_fragment_offset=s_ip_fragment_offset_list[k],
            ip_ttl=s_ip_ttl_list[k],
            ip_protocol=s_ip_protocol_list[k],
            ip_header_checksum=s_ip_header_checksum_list[k],
            ip_source_ip=s_ip_source_ip_list[k],
            ip_dest_ip=s_ip_dest_ip_list[k],
            ip_payload_tdata=s_ip_payload_axis_tdata_list[k],
            ip_payload_tkeep=s_ip_payload_axis_tkeep_list[k],
            ip_payload_tvalid=s_ip_payload_axis_tvalid_list[k],
            ip_payload_tready=s_ip_payload_axis_tready_list[k],
            ip_payload_tlast=s_ip_payload_axis_tlast_list[k],
            ip_payload_tuser=s_ip_payload_axis_tuser_list[k],
            pause=p,
            name='source_%d' % k
        ))

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

        s_ip_hdr_valid=s_ip_hdr_valid,
        s_ip_hdr_ready=s_ip_hdr_ready,
        s_eth_dest_mac=s_eth_dest_mac,
        s_eth_src_mac=s_eth_src_mac,
        s_eth_type=s_eth_type,
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
        s_ip_payload_axis_tid=s_ip_payload_axis_tid,
        s_ip_payload_axis_tdest=s_ip_payload_axis_tdest,
        s_ip_payload_axis_tuser=s_ip_payload_axis_tuser,

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
        m_ip_payload_axis_tid=m_ip_payload_axis_tid,
        m_ip_payload_axis_tdest=m_ip_payload_axis_tdest,
        m_ip_payload_axis_tuser=m_ip_payload_axis_tuser,

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

        source_list[0].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

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

        source_list[1].send(test_frame)

        yield sink.wait()
        rx_frame = sink.recv()

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

        source_list[0].send(test_frame1)
        source_list[0].send(test_frame2)

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

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

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while s_ip_payload_axis_tvalid:
            yield clk.posedge
            select.next = 2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

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

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while s_ip_payload_axis_tvalid:
            yield clk.posedge
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = False
            yield clk.posedge
            for k in range(S_COUNT):
                source_pause_list[k].next = True
            yield clk.posedge
            select.next = 2

        for k in range(S_COUNT):
            source_pause_list[k].next = False

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

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

        source_list[1].send(test_frame1)
        source_list[2].send(test_frame2)
        yield clk.posedge
        yield clk.posedge

        while s_ip_payload_axis_tvalid:
            sink_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            sink_pause.next = False
            yield clk.posedge
            select.next = 2

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame1

        yield sink.wait()
        rx_frame = sink.recv()

        assert rx_frame == test_frame2

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

