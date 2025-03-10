# Verilog Ethernet Xilinx KCU116 Example Design

## Introduction

This example design targets the Xilinx Kintex UltraScale+ KCU116 FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received. The design will also respond correctly to
ARP requests. Only SFP0 works by default.

The reference clock for the GTY transceiver connected to the SFPs is generated
by an external, on-board Si5328 clock chip which must be configured to output a
clock signal of 156.25MHz before the transceiver can be used. This configuration
is performed through the onboard Zynq-based baseboard management
controller. Software for configuring the Zynq BMC and setting the proper clock
frequencies can be found on Xilinx' website.

*  FPGA: XCKU5P-2FFVB676E
*  PHY: 10G BASE-R PHY IP core and internal GTY transceiver

## How to build

Run make to build. Ensure that the Xilinx Vivado toolchain components are in
PATH.

## How to test

Run make program to program the NetFPGA SUME board with Vivado. Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234. Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
