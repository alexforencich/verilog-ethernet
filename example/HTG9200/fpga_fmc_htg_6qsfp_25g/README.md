# Verilog Ethernet HTG-9200 + HTG 6x QSFP28 FMC+ Example Design

## Introduction

This example design targets the HiTech Global HTG-9200 FPGA board with the HiTech Global HTG-FMC-X6QSFP28 FMC+ board installed on J9.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and will echo back any packets received.  The design will also respond correctly to ARP requests.

The design is configured to run all 15 QSFP28 modules synchronous to the GTY reference oscillator (U47) on the HTG-9200.  This is done by forwarding the MGT reference clock for QSFP1 through the FPGA to the SYNC_C2M pins on the FMC+, which is connected as a reference input to the Si5341 PLL (U7) on the FMC+.

*  FPGA: xcvu9p-flgb2104-2-e
*  PHY: 10G BASE-R PHY IP core and internal GTY transceiver

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are in PATH.

## How to test

Run make program to program the HTG-9200 board with Vivado.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
