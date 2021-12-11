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

import logging
import os

from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator

import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotbext.axi import AxiStreamBus
from cocotbext.eth import EthMac


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 6.206, units="ns").start())

        # Ethernet
        cocotb.start_soon(Clock(dut.qsfp1_mac_1_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp1_mac_1_tx_clk, 6.206, units="ns").start())

        self.qsfp1_mac_1 = EthMac(
            tx_clk=dut.qsfp1_mac_1_tx_clk,
            tx_rst=dut.qsfp1_mac_1_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_1_tx_axis"),
            rx_clk=dut.qsfp1_mac_1_rx_clk,
            rx_rst=dut.qsfp1_mac_1_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_1_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp1_mac_2_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp1_mac_2_tx_clk, 6.206, units="ns").start())

        self.qsfp1_mac_2 = EthMac(
            tx_clk=dut.qsfp1_mac_2_tx_clk,
            tx_rst=dut.qsfp1_mac_2_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_2_tx_axis"),
            rx_clk=dut.qsfp1_mac_2_rx_clk,
            rx_rst=dut.qsfp1_mac_2_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_2_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp1_mac_3_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp1_mac_3_tx_clk, 6.206, units="ns").start())

        self.qsfp1_mac_3 = EthMac(
            tx_clk=dut.qsfp1_mac_3_tx_clk,
            tx_rst=dut.qsfp1_mac_3_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_3_tx_axis"),
            rx_clk=dut.qsfp1_mac_3_rx_clk,
            rx_rst=dut.qsfp1_mac_3_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_3_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp1_mac_4_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp1_mac_4_tx_clk, 6.206, units="ns").start())

        self.qsfp1_mac_4 = EthMac(
            tx_clk=dut.qsfp1_mac_4_tx_clk,
            tx_rst=dut.qsfp1_mac_4_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_4_tx_axis"),
            rx_clk=dut.qsfp1_mac_4_rx_clk,
            rx_rst=dut.qsfp1_mac_4_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp1_mac_4_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp2_mac_1_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp2_mac_1_tx_clk, 6.206, units="ns").start())

        self.qsfp2_mac_1 = EthMac(
            tx_clk=dut.qsfp2_mac_1_tx_clk,
            tx_rst=dut.qsfp2_mac_1_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_1_tx_axis"),
            rx_clk=dut.qsfp2_mac_1_rx_clk,
            rx_rst=dut.qsfp2_mac_1_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_1_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp2_mac_2_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp2_mac_2_tx_clk, 6.206, units="ns").start())

        self.qsfp2_mac_2 = EthMac(
            tx_clk=dut.qsfp2_mac_2_tx_clk,
            tx_rst=dut.qsfp2_mac_2_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_2_tx_axis"),
            rx_clk=dut.qsfp2_mac_2_rx_clk,
            rx_rst=dut.qsfp2_mac_2_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_2_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp2_mac_3_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp2_mac_3_tx_clk, 6.206, units="ns").start())

        self.qsfp2_mac_3 = EthMac(
            tx_clk=dut.qsfp2_mac_3_tx_clk,
            tx_rst=dut.qsfp2_mac_3_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_3_tx_axis"),
            rx_clk=dut.qsfp2_mac_3_rx_clk,
            rx_rst=dut.qsfp2_mac_3_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_3_rx_axis"),
            ifg=12, speed=10e9
        )

        cocotb.start_soon(Clock(dut.qsfp2_mac_4_rx_clk, 6.206, units="ns").start())
        cocotb.start_soon(Clock(dut.qsfp2_mac_4_tx_clk, 6.206, units="ns").start())

        self.qsfp2_mac_4 = EthMac(
            tx_clk=dut.qsfp2_mac_4_tx_clk,
            tx_rst=dut.qsfp2_mac_4_tx_rst,
            tx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_4_tx_axis"),
            rx_clk=dut.qsfp2_mac_4_rx_clk,
            rx_rst=dut.qsfp2_mac_4_rx_rst,
            rx_bus=AxiStreamBus.from_prefix(dut, "qsfp2_mac_4_rx_axis"),
            ifg=12, speed=10e9
        )

        dut.btn.setimmediatevalue(0)

    async def init(self):

        self.dut.rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_1_rx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_1_tx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_2_rx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_2_tx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_3_rx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_3_tx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_4_rx_rst.setimmediatevalue(0)
        self.dut.qsfp1_mac_4_tx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_1_rx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_1_tx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_2_rx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_2_tx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_3_rx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_3_tx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_4_rx_rst.setimmediatevalue(0)
        self.dut.qsfp2_mac_4_tx_rst.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 1
        self.dut.qsfp1_mac_1_rx_rst <= 1
        self.dut.qsfp1_mac_1_tx_rst <= 1
        self.dut.qsfp1_mac_2_rx_rst <= 1
        self.dut.qsfp1_mac_2_tx_rst <= 1
        self.dut.qsfp1_mac_3_rx_rst <= 1
        self.dut.qsfp1_mac_3_tx_rst <= 1
        self.dut.qsfp1_mac_4_rx_rst <= 1
        self.dut.qsfp1_mac_4_tx_rst <= 1
        self.dut.qsfp2_mac_1_rx_rst <= 1
        self.dut.qsfp2_mac_1_tx_rst <= 1
        self.dut.qsfp2_mac_2_rx_rst <= 1
        self.dut.qsfp2_mac_2_tx_rst <= 1
        self.dut.qsfp2_mac_3_rx_rst <= 1
        self.dut.qsfp2_mac_3_tx_rst <= 1
        self.dut.qsfp2_mac_4_rx_rst <= 1
        self.dut.qsfp2_mac_4_tx_rst <= 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 0
        self.dut.qsfp1_mac_1_rx_rst <= 0
        self.dut.qsfp1_mac_1_tx_rst <= 0
        self.dut.qsfp1_mac_2_rx_rst <= 0
        self.dut.qsfp1_mac_2_tx_rst <= 0
        self.dut.qsfp1_mac_3_rx_rst <= 0
        self.dut.qsfp1_mac_3_tx_rst <= 0
        self.dut.qsfp1_mac_4_rx_rst <= 0
        self.dut.qsfp1_mac_4_tx_rst <= 0
        self.dut.qsfp2_mac_1_rx_rst <= 0
        self.dut.qsfp2_mac_1_tx_rst <= 0
        self.dut.qsfp2_mac_2_rx_rst <= 0
        self.dut.qsfp2_mac_2_tx_rst <= 0
        self.dut.qsfp2_mac_3_rx_rst <= 0
        self.dut.qsfp2_mac_3_tx_rst <= 0
        self.dut.qsfp2_mac_4_rx_rst <= 0
        self.dut.qsfp2_mac_4_tx_rst <= 0

        for k in range(10):
            await RisingEdge(self.dut.clk)


@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    tb.log.info("test UDP RX packet")

    payload = bytes([x % 256 for x in range(256)])
    eth = Ether(src='5a:51:52:53:54:55', dst='02:00:00:00:00:00')
    ip = IP(src='192.168.1.100', dst='192.168.1.128')
    udp = UDP(sport=5678, dport=1234)
    test_pkt = eth / ip / udp / payload

    await tb.qsfp1_mac_1.rx.send(test_pkt.build())

    tb.log.info("receive ARP request")

    rx_frame = await tb.qsfp1_mac_1.tx.recv()

    rx_pkt = Ether(bytes(rx_frame))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt.dst == 'ff:ff:ff:ff:ff:ff'
    assert rx_pkt.src == test_pkt.dst
    assert rx_pkt[ARP].hwtype == 1
    assert rx_pkt[ARP].ptype == 0x0800
    assert rx_pkt[ARP].hwlen == 6
    assert rx_pkt[ARP].plen == 4
    assert rx_pkt[ARP].op == 1
    assert rx_pkt[ARP].hwsrc == test_pkt.dst
    assert rx_pkt[ARP].psrc == test_pkt[IP].dst
    assert rx_pkt[ARP].hwdst == '00:00:00:00:00:00'
    assert rx_pkt[ARP].pdst == test_pkt[IP].src

    tb.log.info("send ARP response")

    eth = Ether(src=test_pkt.src, dst=test_pkt.dst)
    arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
        hwsrc=test_pkt.src, psrc=test_pkt[IP].src,
        hwdst=test_pkt.dst, pdst=test_pkt[IP].dst)
    resp_pkt = eth / arp

    await tb.qsfp1_mac_1.rx.send(resp_pkt.build())

    tb.log.info("receive UDP packet")

    rx_frame = await tb.qsfp1_mac_1.tx.recv()

    rx_pkt = Ether(bytes(rx_frame))

    tb.log.info("RX packet: %s", repr(rx_pkt))

    assert rx_pkt.dst == test_pkt.src
    assert rx_pkt.src == test_pkt.dst
    assert rx_pkt[IP].dst == test_pkt[IP].src
    assert rx_pkt[IP].src == test_pkt[IP].dst
    assert rx_pkt[UDP].dport == test_pkt[UDP].sport
    assert rx_pkt[UDP].sport == test_pkt[UDP].dport
    assert rx_pkt[UDP].payload == test_pkt[UDP].payload

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


# cocotb-test

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
    ]

    parameters = {}

    parameters['AXIS_ETH_DATA_WIDTH'] = 64
    parameters['AXIS_ETH_KEEP_WIDTH'] = parameters['AXIS_ETH_DATA_WIDTH'] // 8

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
