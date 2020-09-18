/*

Copyright (c) 2020 Alex Forencich

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

reg btnu = 0;
reg btnl = 0;
reg btnd = 0;
reg btnr = 0;
reg btnc = 0;
reg [7:0] sw = 0;
reg sfp0_tx_clk = 0;
reg sfp0_tx_rst = 0;
reg sfp0_rx_clk = 0;
reg sfp0_rx_rst = 0;
reg [63:0] sfp0_rxd = 0;
reg [7:0] sfp0_rxc = 0;
reg sfp1_tx_clk = 0;
reg sfp1_tx_rst = 0;
reg sfp1_rx_clk = 0;
reg sfp1_rx_rst = 0;
reg [63:0] sfp1_rxd = 0;
reg [7:0] sfp1_rxc = 0;
reg sfp2_tx_clk = 0;
reg sfp2_tx_rst = 0;
reg sfp2_rx_clk = 0;
reg sfp2_rx_rst = 0;
reg [63:0] sfp2_rxd = 0;
reg [7:0] sfp2_rxc = 0;
reg sfp3_tx_clk = 0;
reg sfp3_tx_rst = 0;
reg sfp3_rx_clk = 0;
reg sfp3_rx_rst = 0;
reg [63:0] sfp3_rxd = 0;
reg [7:0] sfp3_rxc = 0;
reg uart_rxd = 0;
reg uart_rts = 0;

// Outputs
wire [7:0] led;
wire [63:0] sfp0_txd;
wire [7:0] sfp0_txc;
wire [63:0] sfp1_txd;
wire [7:0] sfp1_txc;
wire [63:0] sfp_2_txd;
wire [7:0] sfp_2_txc;
wire [63:0] sfp_3_txd;
wire [7:0] sfp_3_txc;
wire uart_txd;
wire uart_cts;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw,
        sfp0_tx_clk,
        sfp0_tx_rst,
        sfp0_rx_clk,
        sfp0_rx_rst,
        sfp0_rxd,
        sfp0_rxc,
        sfp1_tx_clk,
        sfp1_tx_rst,
        sfp1_rx_clk,
        sfp1_rx_rst,
        sfp1_rxd,
        sfp1_rxc,
        sfp2_tx_clk,
        sfp2_tx_rst,
        sfp2_rx_clk,
        sfp2_rx_rst,
        sfp2_rxd,
        sfp2_rxc,
        sfp3_tx_clk,
        sfp3_tx_rst,
        sfp3_rx_clk,
        sfp3_rx_rst,
        sfp3_rxd,
        sfp3_rxc,
        uart_rxd,
        uart_rts
    );
    $to_myhdl(
        led,
        sfp0_txd,
        sfp0_txc,
        sfp1_txd,
        sfp1_txc,
        sfp2_txd,
        sfp2_txc,
        sfp3_txd,
        sfp3_txc,
        uart_txd,
        uart_cts
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core
UUT (
    .clk(clk),
    .rst(rst),
    .btnu(btnu),
    .btnl(btnl),
    .btnd(btnd),
    .btnr(btnr),
    .btnc(btnc),
    .sw(sw),
    .led(led),
    .sfp0_tx_clk(sfp0_tx_clk),
    .sfp0_tx_rst(sfp0_tx_rst),
    .sfp0_txd(sfp0_txd),
    .sfp0_txc(sfp0_txc),
    .sfp0_rx_clk(sfp0_rx_clk),
    .sfp0_rx_rst(sfp0_rx_rst),
    .sfp0_rxd(sfp0_rxd),
    .sfp0_rxc(sfp0_rxc),
    .sfp1_tx_clk(sfp1_tx_clk),
    .sfp1_tx_rst(sfp1_tx_rst),
    .sfp1_txd(sfp1_txd),
    .sfp1_txc(sfp1_txc),
    .sfp1_rx_clk(sfp1_rx_clk),
    .sfp1_rx_rst(sfp1_rx_rst),
    .sfp1_rxd(sfp1_rxd),
    .sfp1_rxc(sfp1_rxc),
    .sfp2_tx_clk(sfp2_tx_clk),
    .sfp2_tx_rst(sfp2_tx_rst),
    .sfp2_txd(sfp2_txd),
    .sfp2_txc(sfp2_txc),
    .sfp2_rx_clk(sfp2_rx_clk),
    .sfp2_rx_rst(sfp2_rx_rst),
    .sfp2_rxd(sfp2_rxd),
    .sfp2_rxc(sfp2_rxc),
    .sfp3_tx_clk(sfp3_tx_clk),
    .sfp3_tx_rst(sfp3_tx_rst),
    .sfp3_txd(sfp3_txd),
    .sfp3_txc(sfp3_txc),
    .sfp3_rx_clk(sfp3_rx_clk),
    .sfp3_rx_rst(sfp3_rx_rst),
    .sfp3_rxd(sfp3_rxd),
    .sfp3_rxc(sfp3_rxc),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts)
);

endmodule
