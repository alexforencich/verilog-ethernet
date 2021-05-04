# Verilog Ethernet DE5-Net Example Design

## Introduction

This example design targets the Terasic DE5-Net FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

*  FPGA: 5SGXEA7N2F45C2
*  PHY: 10G BASE-R PHY MegaCore

## How to build

Run make to build.  Ensure that the Altera Quartus toolchain components are
in PATH.  

## How to test

Run make program to program the DE5-Net board with the Altera software.  Then
run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
