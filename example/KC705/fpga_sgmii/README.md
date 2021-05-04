# Verilog Ethernet KC705 Example Design

## Introduction

This example design targets the Xilinx KC705 FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

Configure the PHY for SGMII by placing J29 and J30 across pins 2 and 3 and
opening J64.

*  FPGA: XC7K325T-2FFG900C
*  PHY: Marvell 88E1111

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  

## How to test

Run make program to program the KC705 board with Vivado.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
