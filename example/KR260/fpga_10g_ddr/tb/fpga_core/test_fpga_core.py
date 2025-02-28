"""

Copyright (c) 2020 Alex Forencich

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

###################################################################################
# Imports
###################################################################################

import logging
import os

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotbext.eth import XgmiiFrame, XgmiiSource, XgmiiSink
from cocotbext.axi import AxiBus, AxiRam

###################################################################################
# TB class (common for all tests)
###################################################################################

class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.4, units="ns").start())

        # Ethernet
        cocotb.start_soon(Clock(dut.sfp0_rx_clk, 6.4, units="ns").start())
        self.sfp0_source = XgmiiSource(dut.sfp0_rxd, dut.sfp0_rxc, dut.sfp0_rx_clk, dut.sfp0_rx_rst)
        cocotb.start_soon(Clock(dut.sfp0_tx_clk, 6.4, units="ns").start())
        self.sfp0_sink = XgmiiSink(dut.sfp0_txd, dut.sfp0_txc, dut.sfp0_tx_clk, dut.sfp0_tx_rst)

        # AXI master interface
        self.axi_ram = AxiRam(AxiBus.from_prefix(dut, "m_axi"), dut.clk, dut.rst, size=2**16)
        self.dut.shared_mem_ptr_i = 64

    async def init(self):

        self.dut.rst.setimmediatevalue(0)
        self.dut.sfp0_rx_rst.setimmediatevalue(0)
        self.dut.sfp0_tx_rst.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst.value = 1
        self.dut.sfp0_rx_rst.value = 1
        self.dut.sfp0_tx_rst.value = 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst.value = 0
        self.dut.sfp0_rx_rst.value = 0
        self.dut.sfp0_tx_rst.value = 0

###################################################################################
# Test: sfprx_to_shmem 
# Stimulus: SFP packet generated and sent to DUT SFP RX port
# Expected: packet payload available at DUT m_axi 
###################################################################################

@cocotb.test()
async def run_test_1024byte_udp_rx(dut):

    # Initialize TB

    tb = TB(dut)
    await tb.init()

    # Generate UDP packet and send it to DUT through SFP rx

    tb.log.info("Generating UDP packet...")
    # Payload
    payload = bytes([x % 256 for x in range(256)])
    payload_1024b = payload
    for _ in range(int(1024/256)-1): payload_1024b += payload
    # Wrap packet
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00')
    ip = IP(src='192.168.2.100', dst='192.168.2.128')
    udp = UDP(sport=5678, dport=1234)
    test_pkt = eth / ip / udp / payload_1024b
    test_frame = XgmiiFrame.from_payload(test_pkt.build())
    # Send packet to DUT
    await tb.sfp0_source.send(test_frame)
    for _ in range(1000): await RisingEdge(dut.clk)

    # Check memory content amd dump it

    read_str = tb.axi_ram.read(int(tb.dut.shared_mem_ptr_i), 1024)
    tb.log.info("Dumping axi ram content..." + tb.axi_ram.hexdump_str(0x0000, 2048, prefix="RAM"))
    assert(read_str == payload_1024b)
    await RisingEdge(dut.clk)

###################################################################################
# Test: shmem_to_sfprx
# Stimulus: UDP packet payload placed at shared memory 
# Expected: packet payload available at DUT sfp tx 
###################################################################################

@cocotb.test()
async def run_test_1024byte_udp_tx(dut):

    # Initialize TB

    tb = TB(dut)
    await tb.init()
    tb.log.info("test UDP TX packet")

    # Generate pkt_info (only to store src/dst info)

    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00')
    ip = IP(src='192.168.2.2', dst='192.168.2.128')
    udp = UDP(sport=5678, dport=1234)
    info_pkt = eth / ip / udp

    # Generate payload and dump it into axi ram

    payload = bytes([x % 256 for x in range(256)])
    payload_1024b = payload
    for _ in range(int(1024/256)-1): payload_1024b += payload
    tb.axi_ram.write(int(tb.dut.shared_mem_ptr_i), payload_1024b)
    tb.log.info(tb.axi_ram.hexdump_str(0x0000, 2048, prefix="RAM"))
    
    # Monitor sfp tx until detecting traffic (ARP request from the DUT)

    tb.log.info("receive ARP request from DUT")
    rx_frame = await tb.sfp0_sink.recv()
    rx_pkt = Ether(bytes(rx_frame.get_payload()))
    tb.log.info("RX packet: %s", repr(rx_pkt))
    tb.log.info(rx_pkt.payload)

    assert rx_pkt.dst == 'ff:ff:ff:ff:ff:ff'
    assert rx_pkt.src == info_pkt.dst
    assert rx_pkt[ARP].hwtype == 1
    assert rx_pkt[ARP].ptype == 0x0800
    assert rx_pkt[ARP].hwlen == 6
    assert rx_pkt[ARP].plen == 4
    assert rx_pkt[ARP].op == 1
    assert rx_pkt[ARP].hwsrc == info_pkt.dst
    assert rx_pkt[ARP].psrc == info_pkt[IP].dst
    assert rx_pkt[ARP].hwdst == '00:00:00:00:00:00'
    assert rx_pkt[ARP].pdst == info_pkt[IP].src

    # Monitor sfp tx until detecting traffic (ARP response to the DUT)

    tb.log.info("send ARP response to DUT")
    arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
        hwsrc=info_pkt.src, psrc=info_pkt[IP].src,
        hwdst=info_pkt.dst, pdst=info_pkt[IP].dst)
    resp_pkt = eth / arp
    resp_frame = XgmiiFrame.from_payload(resp_pkt.build())
    await tb.sfp0_source.send(resp_frame)

    # Monitor sfp tx until detecting traffic (UDP from the DUT)

    tb.log.info("receive UDP packet from DUT")
    rx_frame = await tb.sfp0_sink.recv()
    rx_pkt = Ether(bytes(rx_frame.get_payload()))
    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt.dst == info_pkt.src
    assert rx_pkt.src == info_pkt.dst
    assert rx_pkt[IP].dst == info_pkt[IP].src
    assert rx_pkt[IP].src == info_pkt[IP].dst
    assert rx_pkt[UDP].dport == info_pkt[UDP].sport
    assert rx_pkt[UDP].sport == info_pkt[UDP].dport

    for _ in range(10): await RisingEdge(dut.clk)

###################################################################################
# paths, cocotb and simulator definitions
###################################################################################

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'lib', 'axis', 'rtl'))
eth_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'rtl'))


def test_fpga_core(request):
    dut = "fpga_core"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(eth_rtl_dir, "eth_mac_10g_fifo.v"),
        os.path.join(eth_rtl_dir, "eth_mac_10g.v"),
        os.path.join(eth_rtl_dir, "axis_xgmii_rx_64.v"),
        os.path.join(eth_rtl_dir, "axis_xgmii_tx_64.v"),
        os.path.join(eth_rtl_dir, "lfsr.v"),
        os.path.join(eth_rtl_dir, "eth_axis_rx.v"),
        os.path.join(eth_rtl_dir, "eth_axis_tx.v"),
        os.path.join(eth_rtl_dir, "udp_complete_64.v"),
        os.path.join(eth_rtl_dir, "udp_checksum_gen_64.v"),
        os.path.join(eth_rtl_dir, "udp_64.v"),
        os.path.join(eth_rtl_dir, "udp_ip_rx_64.v"),
        os.path.join(eth_rtl_dir, "udp_ip_tx_64.v"),
        os.path.join(eth_rtl_dir, "ip_complete_64.v"),
        os.path.join(eth_rtl_dir, "ip_64.v"),
        os.path.join(eth_rtl_dir, "ip_eth_rx_64.v"),
        os.path.join(eth_rtl_dir, "ip_eth_tx_64.v"),
        os.path.join(eth_rtl_dir, "ip_arb_mux.v"),
        os.path.join(eth_rtl_dir, "arp.v"),
        os.path.join(eth_rtl_dir, "arp_cache.v"),
        os.path.join(eth_rtl_dir, "arp_eth_rx.v"),
        os.path.join(eth_rtl_dir, "arp_eth_tx.v"),
        os.path.join(eth_rtl_dir, "eth_arb_mux.v"),
        os.path.join(axis_rtl_dir, "arbiter.v"),
        os.path.join(axis_rtl_dir, "priority_encoder.v"),
        os.path.join(axis_rtl_dir, "axis_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
        os.path.join(axis_rtl_dir, "axi_dma_wr.v"),
        os.path.join(axis_rtl_dir, "axi_dma_rd.v"),
    ]

    parameters = {}

    # parameters['A'] = val

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
