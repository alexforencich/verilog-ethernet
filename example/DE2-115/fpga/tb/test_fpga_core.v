/*

Copyright (c) 2015-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Testbench for fpga_core
 */
module test_fpga_core;

// Parameters
parameter TARGET = "SIM";

// Inputs
reg clk = 0;
reg clk90 = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [3:0] btn = 0;
reg [17:0] sw = 0;
reg phy0_rx_clk = 0;
reg [3:0] phy0_rxd = 0;
reg phy0_rx_ctl = 0;
reg phy0_int_n = 1;
reg phy1_rx_clk = 0;
reg [3:0] phy1_rxd = 0;
reg phy1_rx_ctl = 0;
reg phy1_int_n = 1;

// Outputs
wire [17:0] ledr;
wire [8:0] ledg;
wire [6:0] hex0;
wire [6:0] hex1;
wire [6:0] hex2;
wire [6:0] hex3;
wire [6:0] hex4;
wire [6:0] hex5;
wire [6:0] hex6;
wire [6:0] hex7;
wire [35:0] gpio;
wire phy0_tx_clk;
wire [3:0] phy0_txd;
wire phy0_tx_ctl;
wire phy0_reset_n;
wire phy1_tx_clk;
wire [3:0] phy1_txd;
wire phy1_tx_ctl;
wire phy1_reset_n;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        clk90,
        rst,
        current_test,
        btn,
        sw,
        phy0_rx_clk,
        phy0_rxd,
        phy0_rx_ctl,
        phy0_int_n,
        phy1_rx_clk,
        phy1_rxd,
        phy1_rx_ctl,
        phy1_int_n
    );
    $to_myhdl(
        ledr,
        ledg,
        hex0,
        hex1,
        hex2,
        hex3,
        hex4,
        hex5,
        hex6,
        hex7,
        gpio,
        phy0_tx_clk,
        phy0_txd,
        phy0_tx_ctl,
        phy0_reset_n,
        phy1_tx_clk,
        phy1_txd,
        phy1_tx_ctl,
        phy1_reset_n
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core #(
    .TARGET(TARGET)
)
UUT (
    .clk(clk),
    .clk90(clk90),
    .rst(rst),
    .btn(btn),
    .sw(sw),
    .ledr(ledr),
    .ledg(ledg),
    .hex0(hex0),
    .hex1(hex1),
    .hex2(hex2),
    .hex3(hex3),
    .hex4(hex4),
    .hex5(hex5),
    .hex6(hex6),
    .hex7(hex7),
    .gpio(gpio),
    .phy0_rx_clk(phy0_rx_clk),
    .phy0_rxd(phy0_rxd),
    .phy0_rx_ctl(phy0_rx_ctl),
    .phy0_tx_clk(phy0_tx_clk),
    .phy0_txd(phy0_txd),
    .phy0_tx_ctl(phy0_tx_ctl),
    .phy0_reset_n(phy0_reset_n),
    .phy0_int_n(phy0_int_n),
    .phy1_rx_clk(phy1_rx_clk),
    .phy1_rxd(phy1_rxd),
    .phy1_rx_ctl(phy1_rx_ctl),
    .phy1_tx_clk(phy1_tx_clk),
    .phy1_txd(phy1_txd),
    .phy1_tx_ctl(phy1_tx_ctl),
    .phy1_reset_n(phy1_reset_n),
    .phy1_int_n(phy1_int_n)
);

endmodule
