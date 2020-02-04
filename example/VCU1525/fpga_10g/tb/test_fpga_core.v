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

reg [3:0] sw = 0;
reg qsfp0_tx_clk_1 = 0;
reg qsfp0_tx_rst_1 = 0;
reg qsfp0_rx_clk_1 = 0;
reg qsfp0_rx_rst_1 = 0;
reg [63:0] qsfp0_rxd_1 = 0;
reg [7:0] qsfp0_rxc_1 = 0;
reg qsfp0_tx_clk_2 = 0;
reg qsfp0_tx_rst_2 = 0;
reg qsfp0_rx_clk_2 = 0;
reg qsfp0_rx_rst_2 = 0;
reg [63:0] qsfp0_rxd_2 = 0;
reg [7:0] qsfp0_rxc_2 = 0;
reg qsfp0_tx_clk_3 = 0;
reg qsfp0_tx_rst_3 = 0;
reg qsfp0_rx_clk_3 = 0;
reg qsfp0_rx_rst_3 = 0;
reg [63:0] qsfp0_rxd_3 = 0;
reg [7:0] qsfp0_rxc_3 = 0;
reg qsfp0_tx_clk_4 = 0;
reg qsfp0_tx_rst_4 = 0;
reg qsfp0_rx_clk_4 = 0;
reg qsfp0_rx_rst_4 = 0;
reg [63:0] qsfp0_rxd_4 = 0;
reg [7:0] qsfp0_rxc_4 = 0;
reg qsfp1_tx_clk_1 = 0;
reg qsfp1_tx_rst_1 = 0;
reg qsfp1_rx_clk_1 = 0;
reg qsfp1_rx_rst_1 = 0;
reg [63:0] qsfp1_rxd_1 = 0;
reg [7:0] qsfp1_rxc_1 = 0;
reg qsfp1_tx_clk_2 = 0;
reg qsfp1_tx_rst_2 = 0;
reg qsfp1_rx_clk_2 = 0;
reg qsfp1_rx_rst_2 = 0;
reg [63:0] qsfp1_rxd_2 = 0;
reg [7:0] qsfp1_rxc_2 = 0;
reg qsfp1_tx_clk_3 = 0;
reg qsfp1_tx_rst_3 = 0;
reg qsfp1_rx_clk_3 = 0;
reg qsfp1_rx_rst_3 = 0;
reg [63:0] qsfp1_rxd_3 = 0;
reg [7:0] qsfp1_rxc_3 = 0;
reg qsfp1_tx_clk_4 = 0;
reg qsfp1_tx_rst_4 = 0;
reg qsfp1_rx_clk_4 = 0;
reg qsfp1_rx_rst_4 = 0;
reg [63:0] qsfp1_rxd_4 = 0;
reg [7:0] qsfp1_rxc_4 = 0;
reg uart_txd = 0;

// Outputs
wire [2:0] led;
wire [63:0] qsfp0_txd_1;
wire [7:0] qsfp0_txc_1;
wire [63:0] qsfp0_txd_2;
wire [7:0] qsfp0_txc_2;
wire [63:0] qsfp0_txd_3;
wire [7:0] qsfp0_txc_3;
wire [63:0] qsfp0_txd_4;
wire [7:0] qsfp0_txc_4;
wire [63:0] qsfp1_txd_1;
wire [7:0] qsfp1_txc_1;
wire [63:0] qsfp1_txd_2;
wire [7:0] qsfp1_txc_2;
wire [63:0] qsfp1_txd_3;
wire [7:0] qsfp1_txc_3;
wire [63:0] qsfp1_txd_4;
wire [7:0] qsfp1_txc_4;
wire uart_rxd;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        sw,
        qsfp0_tx_clk_1,
        qsfp0_tx_rst_1,
        qsfp0_rx_clk_1,
        qsfp0_rx_rst_1,
        qsfp0_rxd_1,
        qsfp0_rxc_1,
        qsfp0_tx_clk_2,
        qsfp0_tx_rst_2,
        qsfp0_rx_clk_2,
        qsfp0_rx_rst_2,
        qsfp0_rxd_2,
        qsfp0_rxc_2,
        qsfp0_tx_clk_3,
        qsfp0_tx_rst_3,
        qsfp0_rx_clk_3,
        qsfp0_rx_rst_3,
        qsfp0_rxd_3,
        qsfp0_rxc_3,
        qsfp0_tx_clk_4,
        qsfp0_tx_rst_4,
        qsfp0_rx_clk_4,
        qsfp0_rx_rst_4,
        qsfp0_rxd_4,
        qsfp0_rxc_4,
        qsfp1_tx_clk_1,
        qsfp1_tx_rst_1,
        qsfp1_rx_clk_1,
        qsfp1_rx_rst_1,
        qsfp1_rxd_1,
        qsfp1_rxc_1,
        qsfp1_tx_clk_2,
        qsfp1_tx_rst_2,
        qsfp1_rx_clk_2,
        qsfp1_rx_rst_2,
        qsfp1_rxd_2,
        qsfp1_rxc_2,
        qsfp1_tx_clk_3,
        qsfp1_tx_rst_3,
        qsfp1_rx_clk_3,
        qsfp1_rx_rst_3,
        qsfp1_rxd_3,
        qsfp1_rxc_3,
        qsfp1_tx_clk_4,
        qsfp1_tx_rst_4,
        qsfp1_rx_clk_4,
        qsfp1_rx_rst_4,
        qsfp1_rxd_4,
        qsfp1_rxc_4,
        uart_txd
    );
    $to_myhdl(
        led,
        qsfp0_txd_1,
        qsfp0_txc_1,
        qsfp0_txd_2,
        qsfp0_txc_2,
        qsfp0_txd_3,
        qsfp0_txc_3,
        qsfp0_txd_4,
        qsfp0_txc_4,
        qsfp1_txd_1,
        qsfp1_txc_1,
        qsfp1_txd_2,
        qsfp1_txc_2,
        qsfp1_txd_3,
        qsfp1_txc_3,
        qsfp1_txd_4,
        qsfp1_txc_4,
        uart_rxd
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core
UUT (
    .clk(clk),
    .rst(rst),
    .sw(sw),
    .led(led),
    .qsfp0_tx_clk_1(qsfp0_tx_clk_1),
    .qsfp0_tx_rst_1(qsfp0_tx_rst_1),
    .qsfp0_txd_1(qsfp0_txd_1),
    .qsfp0_txc_1(qsfp0_txc_1),
    .qsfp0_rx_clk_1(qsfp0_rx_clk_1),
    .qsfp0_rx_rst_1(qsfp0_rx_rst_1),
    .qsfp0_rxd_1(qsfp0_rxd_1),
    .qsfp0_rxc_1(qsfp0_rxc_1),
    .qsfp0_tx_clk_2(qsfp0_tx_clk_2),
    .qsfp0_tx_rst_2(qsfp0_tx_rst_2),
    .qsfp0_txd_2(qsfp0_txd_2),
    .qsfp0_txc_2(qsfp0_txc_2),
    .qsfp0_rx_clk_2(qsfp0_rx_clk_2),
    .qsfp0_rx_rst_2(qsfp0_rx_rst_2),
    .qsfp0_rxd_2(qsfp0_rxd_2),
    .qsfp0_rxc_2(qsfp0_rxc_2),
    .qsfp0_tx_clk_3(qsfp0_tx_clk_3),
    .qsfp0_tx_rst_3(qsfp0_tx_rst_3),
    .qsfp0_txd_3(qsfp0_txd_3),
    .qsfp0_txc_3(qsfp0_txc_3),
    .qsfp0_rx_clk_3(qsfp0_rx_clk_3),
    .qsfp0_rx_rst_3(qsfp0_rx_rst_3),
    .qsfp0_rxd_3(qsfp0_rxd_3),
    .qsfp0_rxc_3(qsfp0_rxc_3),
    .qsfp0_tx_clk_4(qsfp0_tx_clk_4),
    .qsfp0_tx_rst_4(qsfp0_tx_rst_4),
    .qsfp0_txd_4(qsfp0_txd_4),
    .qsfp0_txc_4(qsfp0_txc_4),
    .qsfp0_rx_clk_4(qsfp0_rx_clk_4),
    .qsfp0_rx_rst_4(qsfp0_rx_rst_4),
    .qsfp0_rxd_4(qsfp0_rxd_4),
    .qsfp0_rxc_4(qsfp0_rxc_4),
    .qsfp1_tx_clk_1(qsfp1_tx_clk_1),
    .qsfp1_tx_rst_1(qsfp1_tx_rst_1),
    .qsfp1_txd_1(qsfp1_txd_1),
    .qsfp1_txc_1(qsfp1_txc_1),
    .qsfp1_rx_clk_1(qsfp1_rx_clk_1),
    .qsfp1_rx_rst_1(qsfp1_rx_rst_1),
    .qsfp1_rxd_1(qsfp1_rxd_1),
    .qsfp1_rxc_1(qsfp1_rxc_1),
    .qsfp1_tx_clk_2(qsfp1_tx_clk_2),
    .qsfp1_tx_rst_2(qsfp1_tx_rst_2),
    .qsfp1_txd_2(qsfp1_txd_2),
    .qsfp1_txc_2(qsfp1_txc_2),
    .qsfp1_rx_clk_2(qsfp1_rx_clk_2),
    .qsfp1_rx_rst_2(qsfp1_rx_rst_2),
    .qsfp1_rxd_2(qsfp1_rxd_2),
    .qsfp1_rxc_2(qsfp1_rxc_2),
    .qsfp1_tx_clk_3(qsfp1_tx_clk_3),
    .qsfp1_tx_rst_3(qsfp1_tx_rst_3),
    .qsfp1_txd_3(qsfp1_txd_3),
    .qsfp1_txc_3(qsfp1_txc_3),
    .qsfp1_rx_clk_3(qsfp1_rx_clk_3),
    .qsfp1_rx_rst_3(qsfp1_rx_rst_3),
    .qsfp1_rxd_3(qsfp1_rxd_3),
    .qsfp1_rxc_3(qsfp1_rxc_3),
    .qsfp1_tx_clk_4(qsfp1_tx_clk_4),
    .qsfp1_tx_rst_4(qsfp1_tx_rst_4),
    .qsfp1_txd_4(qsfp1_txd_4),
    .qsfp1_txc_4(qsfp1_txc_4),
    .qsfp1_rx_clk_4(qsfp1_rx_clk_4),
    .qsfp1_rx_rst_4(qsfp1_rx_rst_4),
    .qsfp1_rxd_4(qsfp1_rxd_4),
    .qsfp1_rxc_4(qsfp1_rxc_4),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd)
);

endmodule
