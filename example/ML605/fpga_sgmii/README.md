# Verilog Ethernet ML605 SGMII Example Design

## Introduction

This example design targets the Xilinx ML605 FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.

Configure the PHY for SGMII by placing J66 and J67 across pins 2 and 3 and
opening J68.

*  FPGA: XC6VLX130T-1FF1156 or XC6VLX240T-1FF1156
*  PHY: Marvell M88E1111

## How to build

Run make to build.  Ensure that the Xilinx ISE toolchain components are
in PATH.

## How to test

Run make program to program the ML605 board with the Xilinx Impact software.
Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
