# Verilog Ethernet VC707 Example Design

## Introduction

This example design targets the Xilinx VC707 FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

This board supports SGMII only.

*  FPGA: XC7VX485TFFG1761
*  PHY: Marvell 88E1111

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  For Vivado 2017.2 some files might have to be changed to SystemVerilog to parse.

## How to test

Run make program to program the VC707 board with Vivado.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    arping 192.168.1.128
