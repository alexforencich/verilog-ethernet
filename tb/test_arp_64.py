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

module = 'arp_64'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/arp_cache.v")
srcs.append("../rtl/arp_eth_rx_64.v")
srcs.append("../rtl/arp_eth_tx_64.v")
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

    output_eth_payload_tready = Signal(bool(0))
    output_eth_hdr_ready = Signal(bool(0))

    arp_request_valid = Signal(bool(0))
    arp_request_ip = Signal(intbv(0)[32:])

    local_mac = Signal(intbv(0)[48:])
    local_ip = Signal(intbv(0)[32:])
    gateway_ip = Signal(intbv(0)[32:])
    subnet_mask = Signal(intbv(0)[32:])
    clear_cache = Signal(bool(0))

    # Outputs
    input_eth_hdr_ready = Signal(bool(0))
    input_eth_payload_tready = Signal(bool(0))

    output_eth_hdr_valid = Signal(bool(0))
    output_eth_dest_mac = Signal(intbv(0)[48:])
    output_eth_src_mac = Signal(intbv(0)[48:])
    output_eth_type = Signal(intbv(0)[16:])
    output_eth_payload_tdata = Signal(intbv(0)[64:])
    output_eth_payload_tkeep = Signal(intbv(0)[8:])
    output_eth_payload_tvalid = Signal(bool(0))
    output_eth_payload_tlast = Signal(bool(0))
    output_eth_payload_tuser = Signal(bool(0))

    arp_response_valid = Signal(bool(0))
    arp_response_error = Signal(bool(0))
    arp_response_mac = Signal(intbv(0)[48:])

    # sources and sinks
    source_pause = Signal(bool(0))
    sink_pause = Signal(bool(0))

    source = eth_ep.EthFrameSource()

    source_logic = source.create_logic(
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
        pause=source_pause,
        name='source'
    )

    sink = eth_ep.EthFrameSink()

    sink_logic = sink.create_logic(
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
        arp_request_ip=arp_request_ip,
        arp_response_valid=arp_response_valid,
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
        source.send(test_frame.build_eth())
        yield clk.posedge

        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()
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

        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0xc0a80164
        yield clk.posedge
        arp_request_valid.next = False

        yield arp_response_valid.posedge
        assert not bool(arp_response_error)
        assert int(arp_response_mac) == 0x5A5152535455

        yield delay(100)

        yield clk.posedge
        print("test 3: Unached read")
        current_test.next = 3

        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0xc0a80166
        yield clk.posedge
        arp_request_valid.next = False

        # wait for ARP request packet
        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()
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
        source.send(test_frame.build_eth())
        yield clk.posedge

        # wait for lookup
        yield arp_response_valid.posedge
        assert not bool(arp_response_error)
        assert int(arp_response_mac) == 0x6A6162636465

        yield delay(100)

        yield clk.posedge
        print("test 4: Unached read, outside of subnet")
        current_test.next = 4

        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0x08080808
        yield clk.posedge
        arp_request_valid.next = False

        # wait for ARP request packet
        yield output_eth_payload_tlast.posedge
        yield clk.posedge
        yield clk.posedge

        rx_frame = sink.recv()
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
        source.send(test_frame.build_eth())
        yield clk.posedge

        # wait for lookup
        yield arp_response_valid.posedge
        assert not bool(arp_response_error)
        assert int(arp_response_mac) == 0xAABBCCDDEEFF

        yield delay(100)

        yield clk.posedge
        print("test 5: Unached read, timeout")
        current_test.next = 5

        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0xc0a80167
        yield clk.posedge
        arp_request_valid.next = False

        yield arp_response_valid.posedge
        assert bool(arp_response_error)

        # check for 4 ARP requests
        assert sink.count() == 4

        while not sink.empty():
            rx_frame = sink.recv()

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
        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0xc0a801FF
        yield clk.posedge
        arp_request_valid.next = False

        yield arp_response_valid.posedge
        assert not bool(arp_response_error)
        assert int(arp_response_mac) == 0xFFFFFFFFFFFF

        # general broadcast
        yield clk.posedge
        arp_request_valid.next = True
        arp_request_ip.next = 0xFFFFFFFF
        yield clk.posedge
        arp_request_valid.next = False

        yield arp_response_valid.posedge
        assert not bool(arp_response_error)
        assert int(arp_response_mac) == 0xFFFFFFFFFFFF

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()

