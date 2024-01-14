# Verilog Ethernet Arista 7132LB Example Design

## Introduction

This example design targets the Arista 7132LB-48Y4C switch.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

*  FPGA: xcvu9p-flgb2104-3-e
*  PHY: 10G BASE-R PHY IP core and internal GTY transceiver

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  

## How to test

Load the design onto the FPGA in the 7132LB switch either by using the hardware manager on the switch, or by copying the bit file to the switch with scp and then loading it onto the FPGA with xc3sprog.

To load the design with xc3sprog, run the following commands on the switch:

    switch>en
    switch#conf t
    switch(config)#bash sudo bash
    bash-4.2# user@host:/path/to/fpga.bit .
    bash-4.2# xc3sprog -c metamako -J 10000000 fpga.bit

Once the design is running on the FPGA, run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
