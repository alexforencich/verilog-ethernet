/*

Copyright (c) 2016-2018 Alex Forencich

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

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [1:0] btn = 0;
reg sfp_1_tx_clk = 0;
reg sfp_1_tx_rst = 0;
reg sfp_1_rx_clk = 0;
reg sfp_1_rx_rst = 0;
reg [63:0] sfp_1_rxd = 0;
reg [7:0] sfp_1_rxc = 0;
reg sfp_2_tx_clk = 0;
reg sfp_2_tx_rst = 0;
reg sfp_2_rx_clk = 0;
reg sfp_2_rx_rst = 0;
reg [63:0] sfp_2_rxd = 0;
reg [7:0]  sfp_2_rxc = 0;
reg sfp_3_tx_clk = 0;
reg sfp_3_tx_rst = 0;
reg sfp_3_rx_clk = 0;
reg sfp_3_rx_rst = 0;
reg [63:0] sfp_3_rxd = 0;
reg [7:0]  sfp_3_rxc = 0;
reg sfp_4_tx_clk = 0;
reg sfp_4_tx_rst = 0;
reg sfp_4_rx_clk = 0;
reg sfp_4_rx_rst = 0;
reg [63:0] sfp_4_rxd = 0;
reg [7:0]  sfp_4_rxc = 0;

// Outputs
wire [1:0] sfp_1_led;
wire [1:0] sfp_2_led;
wire [1:0] sfp_3_led;
wire [1:0] sfp_4_led;
wire [1:0] led;
wire [63:0] sfp_1_txd;
wire [7:0] sfp_1_txc;
wire [63:0] sfp_2_txd;
wire [7:0] sfp_2_txc;
wire [63:0] sfp_3_txd;
wire [7:0] sfp_3_txc;
wire [63:0] sfp_4_txd;
wire [7:0] sfp_4_txc;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        btn,
        sfp_1_tx_clk,
        sfp_1_tx_rst,
        sfp_1_rx_clk,
        sfp_1_rx_rst,
        sfp_1_rxd,
        sfp_1_rxc,
        sfp_2_tx_clk,
        sfp_2_tx_rst,
        sfp_2_rx_clk,
        sfp_2_rx_rst,
        sfp_2_rxd,
        sfp_2_rxc,
        sfp_3_tx_clk,
        sfp_3_tx_rst,
        sfp_3_rx_clk,
        sfp_3_rx_rst,
        sfp_3_rxd,
        sfp_3_rxc,
        sfp_4_tx_clk,
        sfp_4_tx_rst,
        sfp_4_rx_clk,
        sfp_4_rx_rst,
        sfp_4_rxd,
        sfp_4_rxc
    );
    $to_myhdl(
        sfp_1_led,
        sfp_2_led,
        sfp_3_led,
        sfp_4_led,
        led,
        sfp_1_txd,
        sfp_1_txc,
        sfp_2_txd,
        sfp_2_txc,
        sfp_3_txd,
        sfp_3_txc,
        sfp_4_txd,
        sfp_4_txc
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core
UUT (
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .sfp_1_led(sfp_1_led),
    .sfp_2_led(sfp_2_led),
    .sfp_3_led(sfp_3_led),
    .sfp_4_led(sfp_4_led),
    .led(led),
    .sfp_1_tx_clk(sfp_1_tx_clk),
    .sfp_1_tx_rst(sfp_1_tx_rst),
    .sfp_1_txd(sfp_1_txd),
    .sfp_1_txc(sfp_1_txc),
    .sfp_1_rx_clk(sfp_1_rx_clk),
    .sfp_1_rx_rst(sfp_1_rx_rst),
    .sfp_1_rxd(sfp_1_rxd),
    .sfp_1_rxc(sfp_1_rxc),
    .sfp_2_tx_clk(sfp_2_tx_clk),
    .sfp_2_tx_rst(sfp_2_tx_rst),
    .sfp_2_txd(sfp_2_txd),
    .sfp_2_txc(sfp_2_txc),
    .sfp_2_rx_clk(sfp_2_rx_clk),
    .sfp_2_rx_rst(sfp_2_rx_rst),
    .sfp_2_rxd(sfp_2_rxd),
    .sfp_2_rxc(sfp_2_rxc),
    .sfp_3_tx_clk(sfp_3_tx_clk),
    .sfp_3_tx_rst(sfp_3_tx_rst),
    .sfp_3_txd(sfp_3_txd),
    .sfp_3_txc(sfp_3_txc),
    .sfp_3_rx_clk(sfp_3_rx_clk),
    .sfp_3_rx_rst(sfp_3_rx_rst),
    .sfp_3_rxd(sfp_3_rxd),
    .sfp_3_rxc(sfp_3_rxc),
    .sfp_4_tx_clk(sfp_4_tx_clk),
    .sfp_4_tx_rst(sfp_4_tx_rst),
    .sfp_4_txd(sfp_4_txd),
    .sfp_4_txc(sfp_4_txc),
    .sfp_4_rx_clk(sfp_4_rx_clk),
    .sfp_4_rx_rst(sfp_4_rx_rst),
    .sfp_4_rxd(sfp_4_rxd),
    .sfp_4_rxc(sfp_4_rxc)
);

endmodule
