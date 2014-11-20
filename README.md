# Verilog Ethernet Components Readme

For more information and updates: http://alexforencich.com/wiki/en/verilog/ethernet/start

GitHub repository: https://github.com/alexforencich/verilog-ethernet

## Introduction

Collection of Ethernet-related components for both gigabit and 10G packet
processing (8 bit and 64 bit datapaths).  Includes modules for handling
Ethernet frames as well as IP, UDP, and ARP and the components for
constructing a complete UDP/IP stack.  Includes full MyHDL testbench with
intelligent bus cosimulation endpoints.

## Documentation

## eth_axis_rx module

Ethernet frame receiver.  

## eth_axis_rx_64 module

Ethernet frame receiver with 64 bit datapath for 10G Ethernet.

## eth_axis_tx module

Ethernet frame transmitter.

## eth_axis_tx_64 module

Ethernet frame transmitter with 64 bit datapath for 10G Ethernet.

### Common signals

    tdata   : Data (width generally DATA_WIDTH)
    tkeep   : Data word valid (width generally KEEP_WIDTH, present on _64 modules)
    tvalid  : Data valid
    tready  : Sink ready
    tlast   : End-of-frame
    tuser   : Bad frame (valid with tlast & tvalid)

### Source Files

    rtl/arbiter.v                   : General-purpose parametrizable arbiter
    rtl/eth_axis_rx.v               : Ethernet frame receiver
    rtl/eth_axis_rx_64.v            : Ethernet frame receiver (64 bit)
    rtl/eth_axis_tx.v               : Ethernet frame transmitter
    rtl/eth_axis_tx_64.v            : Ethernet frame transmitter (64 bit)

### AXI Stream Interface Example

two byte transfer with sink pause after each byte

              __    __    __    __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _________________
    tdata  XXXXXXXXX_D0__X_D1______________XXXXXXXXXXXXXXXXXXXXXXXX
                    _____ _________________
    tkeep  XXXXXXXXX_K0__X_K1______________XXXXXXXXXXXXXXXXXXXXXXXX
                    _______________________
    tvalid ________/                       \_______________________
           ______________             _____             ___________
    tready               \___________/     \___________/
                          _________________
    tlast  ______________/                 \_______________________

    tuser  ________________________________________________________


two back-to-back packets, no pauses

              __    __    __    __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _____ _____ _____ _____ _____
    tdata  XXXXXXXXX_A0__X_A1__X_A2__X_B0__X_B1__X_B2__XXXXXXXXXXXX
                    _____ _____ _____ _____ _____ _____
    tkeep  XXXXXXXXX_K0__X_K1__X_K2__X_K0__X_K1__X_K2__XXXXXXXXXXXX
                    ___________________________________
    tvalid ________/                                   \___________
           ________________________________________________________
    tready
                                _____             _____
    tlast  ____________________/     \___________/     \___________

    tuser  ________________________________________________________


bad frame

              __    __    __    __    __    __
    clk    __/  \__/  \__/  \__/  \__/  \__/  \__
                    _____ _____ _____
    tdata  XXXXXXXXX_A0__X_A1__X_A2__XXXXXXXXXXXX
                    _____ _____ _____
    tkeep  XXXXXXXXX_K0__X_K1__X_K2__XXXXXXXXXXXX
                    _________________
    tvalid ________/                 \___________
           ______________________________________
    tready
                                _____
    tlast  ____________________/     \___________
                                _____
    tuser  ____________________/     \___________


## Testing

Running the included testbenches requires MyHDL and Icarus Verilog.  Make sure
that myhdl.vpi is installed properly for cosimulation to work correctly.  The
testbenches can be run with a Python test runner like nose or py.test, or the
individual test scripts can be run with python directly.

### Testbench Files

    tb/arp_ep.py         : MyHDL ARP frame endpoints
    tb/axis_ep.py        : MyHDL AXI Stream endpoints
    tb/eth_ep.py         : MyHDL Ethernet frame endpoints
    tb/ip_ep.py          : MyHDL IP frame endpoints
    tb/udp_ep.py         : MyHDL UDP frame endpoints
