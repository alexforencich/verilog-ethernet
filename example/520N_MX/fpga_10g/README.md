# Verilog Ethernet BittWare 520N-MX Example Design

## Introduction

This example design targets the BittWare 520N-MX board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.

*  FPGA: 1SM21CHU2F53E2VG
*  PHY: Transceiver in 10G BASE-R native mode

## How to build

Run make to build.  Ensure that the Intel Quartus Prime Pro toolchain
components are in PATH.

## How to test

Run make program to program the board with the Intel software.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
