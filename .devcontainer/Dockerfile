FROM ubuntu:22.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        net-tools less python3 python3-pip \
        software-properties-common vim build-essential \
        git curl wget unzip python3-dev \
        gtkwave iverilog myhdl-cosimulation python3-myhdl

RUN pip3 install cocotb \
    cocotb-bus cocotb-test cocotbext-axi  \
    cocotbext-eth cocotbext-pcie  \
    pytest  scapy \
    tox pytest-xdist pytest-sugar

RUN git clone https://github.com/myhdl/myhdl && \
        cd myhdl/cosimulation/icarus && \
        make && cp myhdl.vpi /usr/lib/aarch64-linux-gnu/ivl/
