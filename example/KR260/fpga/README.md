# Verilog Ethernet KR260 Example Design

## Introduction

This example design targets the AMD KR260 FPGA SoC board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

*  FPGA: `XCK26-SFVC784-2LV-C` (or `-I`, if industrial-grade)
*  PHY: 10G BASE-R PHY IP core and internal GTY transceiver

## How to build

:warning: *<ins>To generate the bitstream for the reference design example here
you need a Vivado license</ins>*. In case you don't have it, you can either
fetch it from [here](https://www.xilinx.com/support/licensing_solution_center.html)
or use the the default "30 day evaluation license"  that comes with Vivado default
installation.

Run `make` to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.

## How to test

Program the KR260 board with Vivado's Hardware Device Manager (via JTAG). Connect the KR260 SFP+ port to a 10G Ethernet NIC in your host. Then run in your host machine:

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
