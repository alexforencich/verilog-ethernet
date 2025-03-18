# Verilog Ethernet Genesys2 Example Design

## Introduction

This example design targets the Digilent Genesys FPGA board.

The design by default listens to UDP port 1234 at IP address 192.168.1.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests.  

FPGA: xc7k325tffg900-2
PHY: Realtek RTL8211E-VL

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  

## How to test

Run make program to program the Nexys Video board with the Digilent command
line tools.  Then run netcat -u 192.168.1.128 1234 to open a UDP connection to
port 1234.  Any text entered into netcat will be echoed back after pressing
enter.  


