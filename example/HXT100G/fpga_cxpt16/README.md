# Verilog Ethernet HXT100G Crosspoint Switch Design

## Introduction

This design targets the HiTech Global HXT100G FPGA board.

The design forms a 16x16 crosspoint switch for 10G Ethernet.  It is capable of
connecting any output port to any input port based on configuration frames
received over a dedicated configuration interface.

*  FPGA: XC6VHX565T-2FFG1923
*  PHY: 10G BASE-R PHY IP core and internal GTH transceiver

## How to build

Run make to build.  Ensure that the Xilinx ISE toolchain components are
in PATH.  

## How to use

SFP left ports 0-7 are connected to crosspoint input/output ports 0-7, SFP
right ports 0-7 are connected to crosspoint input/output ports 8-15.  SFP port
left 11 is the control port.  Send an Ethernet frame with ethtype 0x8099 to
this port to reconfigure the switch, the first 16 payload bytes corresponding
to the 16 switch output ports, each byte selecting which input port will be
connected.  It is possible to connect multiple output ports to the same input
port.
