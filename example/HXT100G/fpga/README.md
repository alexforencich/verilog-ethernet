# Verilog Ethernet HXT100G Example Design

## Introduction

This example design targets the HiTech Global HXT100G FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

FPGA: XC6VHX565T-2FFG1923
PHY: 10G BASE-R PHY IP core and internal GTH transceiver

## How to build

Run make to build.  Ensure that the Xilinx ISE toolchain components are
in PATH.  

## How to test

Run make program to program the HXT100G board with the Xilinx Impact software.
Then run netcat -u 192.168.1.128 1234 to open a UDP connection to port 1234.
Anyntext entered into netcat will be echoed back after pressing enter.  


