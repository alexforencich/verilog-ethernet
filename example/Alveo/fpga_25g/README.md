# Verilog Ethernet Alveo Example Design

## Introduction

This design targets multiple FPGA boards, including most of the Xilinx Alveo line.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and will echo back any packets received.  The design will also respond correctly to ARP requests.

* FPGA
  * AU50: xcu50-fsvh2104-2-e
  * AU55C: xcu55c-fsvh2892-2L-e
  * AU55N/C1100: xcu55n-fsvh2892-2L-e
  * AU200: xcu200-fsgd2104-2-e
  * AU250: xcu250-fsgd2104-2-e
  * AU280: xcu280-fsvh2892-2L-e
  * VCU1525: xcvu9p-fsgd2104-2L-e
* PHY: 10G BASE-R PHY IP core and internal GTY transceiver

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are in PATH.

## How to test

Run make program to program the FPGA board with Vivado.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
