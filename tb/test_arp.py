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
import arp_ep

module = 'arp'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("../rtl/arp_cache.v")
srcs.append("../rtl/arp_eth_rx.v")
srcs.append("../rtl/arp_eth_tx.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 8
    KEEP_ENABLE = (DATA_WIDTH>8)
    KEEP_WIDTH = (DATA_WIDTH/8)
    CACHE_ADDR_WIDTH = 2
    REQUEST_RETRY_COUNT = 4
    REQUEST_RETRY_INTERVAL = 150
    REQUEST_TIMEOUT = 400

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    s_eth_hdr_valid = Signal(bool(0))
    s_eth_dest_mac = Signal(intbv(0)[48:])
    s_eth_src_mac = Signal(intbv(0)[48:])
    s_eth_type = Signal(intbv(0)[16:])
    s_eth_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    s_eth_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    s_eth_payload_axis_tvalid = Signal(bool(0))
    s_eth_payload_axis_tlast = Signal(bool(0))
    s_eth_payload_axis_tuser = Signal(bool(0))

    m_eth_payload_axis_tready = Signal(bool(0))
    m_eth_hdr_ready = Signal(bool(0))

    arp_request_valid = Signal(bool(0))
    arp_request_ip = Signal(intbv(0)[32:])
    arp_response_ready = Signal(bool(0))

    local_mac = Signal(intbv(0)[48:])
    local_ip = Signal(intbv(0)[32:])
    gateway_ip = Signal(intbv(0)[32:])
    subnet_mask = Signal(intbv(0)[32:])
    clear_cache = Signal(bool(0))

    # Outputs
    s_eth_hdr_ready = Signal(bool(0))
    s_eth_payload_axis_tready = Signal(bool(0))

    m_eth_hdr_valid = Signal(bool(0))
    m_eth_dest_mac = Signal(intbv(0)[48:])
    m_eth_src_mac = Signal(intbv(0)[48:])
    m_eth_type = Signal(intbv(0)[16:])
    m_eth_payload_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    m_eth_payload_axis_tkeep = Signal(intbv(1)[KEEP_WIDTH:])
    m_eth_payload_axis_tvalid = Signal(bool(0))
    m_eth_payload_axis_tlast = Signal(bool(0))
    m_eth_payload_axis_tuser = Signal(bool(0))

    arp_request_ready = Signal(bool(0))
    arp_response_valid = Signal(bool(0))
    arp_response_error = Signal(bool(0))
    arp_response_mac = Signal(intbv(0)[48:])

    # sources and sinks
    eth_source_pause = Signal(bool(0))
    eth_sink_pause = Signal(bool(0))

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

    arp_request_source = axis_ep.AXIStreamSource()

    arp_request_source_logic = arp_request_source.create_logic(
        clk,
        rst,
        tdata=(arp_request_ip,),
        tvalid=arp_request_valid,
        tready=arp_request_ready,
        name='arp_request_source'
    )

    arp_response_sink = axis_ep.AXIStreamSink()

    arp_response_sink_logic = arp_response_sink.create_logic(
        clk,
        rst,
        tdata=(arp_response_error, arp_response_mac),
        tvalid=arp_response_valid,
        tready=arp_response_ready,
        name='arp_response_sink'
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

        local_mac=local_mac,
        local_ip=local_ip,
        gateway_ip=gateway_ip,
        subnet_mask=subnet_mask,
        clear_cache=clear_cache
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
        local_mac.next = 0xDAD1D2D3D4D5
        local_ip.next = 0xc0a80165
        gateway_ip.next = 0xc0a80101
        subnet_mask.next = 0xFFFFFF00

        yield clk.posedge
        print("test 1: ARP request")
        current_test.next = 1

        test_frame = arp_ep.ARPFrame()
        test_frame.eth_dest_mac = 0xFFFFFFFFFFFF
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x0806
        test_frame.arp_htype = 0x0001
        test_frame.arp_ptype = 0x0800
        test_frame.arp_hlen = 6
        test_frame.arp_plen = 4
        test_frame.arp_oper = 1
        test_frame.arp_sha = 0x5A5152535455
        test_frame.arp_spa = 0xc0a80164
        test_frame.arp_tha = 0x000000000000
        test_frame.arp_tpa = 0xc0a80165
        eth_source.send(test_frame.build_eth())

        yield eth_sink.wait()
        rx_frame = eth_sink.recv()
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame.eth_dest_mac == 0x5A5152535455
        assert check_frame.eth_src_mac == 0xDAD1D2D3D4D5
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 2
        assert check_frame.arp_sha == 0xDAD1D2D3D4D5
        assert check_frame.arp_spa == 0xc0a80165
        assert check_frame.arp_tha == 0x5A5152535455
        assert check_frame.arp_tpa == 0xc0a80164

        yield delay(100)

        yield clk.posedge
        print("test 2: Cached read")
        current_test.next = 2

        arp_request_source.send([(0xc0a80164,)])

        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert not err
        assert mac == 0x5A5152535455

        yield delay(100)

        yield clk.posedge
        print("test 3: Unached read")
        current_test.next = 3

        arp_request_source.send([(0xc0a80166,)])

        # wait for ARP request packet
        yield eth_sink.wait()
        rx_frame = eth_sink.recv()
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
        assert check_frame.eth_src_mac == 0xDAD1D2D3D4D5
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 1
        assert check_frame.arp_sha == 0xDAD1D2D3D4D5
        assert check_frame.arp_spa == 0xc0a80165
        assert check_frame.arp_tha == 0x000000000000
        assert check_frame.arp_tpa == 0xc0a80166

        # generate response
        test_frame = arp_ep.ARPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x6A6162636465
        test_frame.eth_type = 0x0806
        test_frame.arp_htype = 0x0001
        test_frame.arp_ptype = 0x0800
        test_frame.arp_hlen = 6
        test_frame.arp_plen = 4
        test_frame.arp_oper = 2
        test_frame.arp_sha = 0x6A6162636465
        test_frame.arp_spa = 0xc0a80166
        test_frame.arp_tha = 0xDAD1D2D3D4D5
        test_frame.arp_tpa = 0xc0a80165
        eth_source.send(test_frame.build_eth())

        # wait for lookup
        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert not err
        assert mac == 0x6A6162636465

        yield delay(100)

        yield clk.posedge
        print("test 4: Unached read, outside of subnet")
        current_test.next = 4

        arp_request_source.send([(0x08080808,)])

        # wait for ARP request packet
        yield eth_sink.wait()
        rx_frame = eth_sink.recv()
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(rx_frame)

        assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
        assert check_frame.eth_src_mac == 0xDAD1D2D3D4D5
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 1
        assert check_frame.arp_sha == 0xDAD1D2D3D4D5
        assert check_frame.arp_spa == 0xc0a80165
        assert check_frame.arp_tha == 0x000000000000
        assert check_frame.arp_tpa == 0xc0a80101

        # generate response
        test_frame = arp_ep.ARPFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0xAABBCCDDEEFF
        test_frame.eth_type = 0x0806
        test_frame.arp_htype = 0x0001
        test_frame.arp_ptype = 0x0800
        test_frame.arp_hlen = 6
        test_frame.arp_plen = 4
        test_frame.arp_oper = 2
        test_frame.arp_sha = 0xAABBCCDDEEFF
        test_frame.arp_spa = 0xc0a80101
        test_frame.arp_tha = 0xDAD1D2D3D4D5
        test_frame.arp_tpa = 0xc0a80165
        eth_source.send(test_frame.build_eth())

        # wait for lookup
        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert not err
        assert mac == 0xAABBCCDDEEFF

        yield delay(100)

        yield clk.posedge
        print("test 5: Unached read, timeout")
        current_test.next = 5

        arp_request_source.send([(0xc0a80167,)])

        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert err

        # check for 4 ARP requests
        assert eth_sink.count() == 4

        while not eth_sink.empty():
            rx_frame = eth_sink.recv()

            check_frame = arp_ep.ARPFrame()
            check_frame.parse_eth(rx_frame)

            assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
            assert check_frame.eth_src_mac == 0xDAD1D2D3D4D5
            assert check_frame.eth_type == 0x0806
            assert check_frame.arp_htype == 0x0001
            assert check_frame.arp_ptype == 0x0800
            assert check_frame.arp_hlen == 6
            assert check_frame.arp_plen == 4
            assert check_frame.arp_oper == 1
            assert check_frame.arp_sha == 0xDAD1D2D3D4D5
            assert check_frame.arp_spa == 0xc0a80165
            assert check_frame.arp_tha == 0x000000000000
            assert check_frame.arp_tpa == 0xc0a80167

        yield delay(100)

        yield clk.posedge
        print("test 6: Broadcast")
        current_test.next = 6

        # subnet broadcast
        arp_request_source.send([(0xc0a801ff,)])

        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert not err
        assert mac == 0xffffffffffff

        # general broadcast
        arp_request_source.send([(0xffffffff,)])

        yield arp_response_sink.wait()
        err, mac = arp_response_sink.recv().data[0]

        assert not err
        assert mac == 0xffffffffffff

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

