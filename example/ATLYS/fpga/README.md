# Verilog Ethernet Atlys Example Design

## Introduction

This example design targets the Digilent Atlys FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

*  FPGA: XC6SLX45CSG324-2
*  PHY: Marvell 88E1111

## How to build

Run make to build.  Ensure that the Xilinx ISE toolchain components are
in PATH.  

## How to test

Run make program to program the Atlys board with the Digilent command line
tools.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
