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

reg btnu = 0;
reg btnl = 0;
reg btnd = 0;
reg btnr = 0;
reg btnc = 0;
reg [3:0] sw = 0;
reg qsfp_tx_clk_1 = 0;
reg qsfp_tx_rst_1 = 0;
reg qsfp_rx_clk_1 = 0;
reg qsfp_rx_rst_1 = 0;
reg [63:0] qsfp_rxd_1 = 0;
reg [7:0] qsfp_rxc_1 = 0;
reg qsfp_tx_clk_2 = 0;
reg qsfp_tx_rst_2 = 0;
reg qsfp_rx_clk_2 = 0;
reg qsfp_rx_rst_2 = 0;
reg [63:0] qsfp_rxd_2 = 0;
reg [7:0] qsfp_rxc_2 = 0;
reg qsfp_tx_clk_3 = 0;
reg qsfp_tx_rst_3 = 0;
reg qsfp_rx_clk_3 = 0;
reg qsfp_rx_rst_3 = 0;
reg [63:0] qsfp_rxd_3 = 0;
reg [7:0] qsfp_rxc_3 = 0;
reg qsfp_tx_clk_4 = 0;
reg qsfp_tx_rst_4 = 0;
reg qsfp_rx_clk_4 = 0;
reg qsfp_rx_rst_4 = 0;
reg [63:0] qsfp_rxd_4 = 0;
reg [7:0] qsfp_rxc_4 = 0;
reg phy_gmii_clk = 0;
reg phy_gmii_rst = 0;
reg phy_gmii_clk_en = 0;
reg [7:0] phy_gmii_rxd = 0;
reg phy_gmii_rx_dv = 0;
reg phy_gmii_rx_er = 0;
reg phy_int_n = 1;
reg uart_rxd = 0;
reg uart_cts = 0;

// Outputs
wire [7:0] led;
wire [63:0] qsfp_txd_1;
wire [7:0] qsfp_txc_1;
wire [63:0] qsfp_txd_2;
wire [7:0] qsfp_txc_2;
wire [63:0] qsfp_txd_3;
wire [7:0] qsfp_txc_3;
wire [63:0] qsfp_txd_4;
wire [7:0] qsfp_txc_4;
wire phy_tx_clk;
wire [7:0] phy_gmii_txd;
wire phy_gmii_tx_en;
wire phy_gmii_tx_er;
wire phy_reset_n;
wire uart_txd;
wire uart_rts;

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
        qsfp_tx_clk_1,
        qsfp_tx_rst_1,
        qsfp_rx_clk_1,
        qsfp_rx_rst_1,
        qsfp_rxd_1,
        qsfp_rxc_1,
        qsfp_tx_clk_2,
        qsfp_tx_rst_2,
        qsfp_rx_clk_2,
        qsfp_rx_rst_2,
        qsfp_rxd_2,
        qsfp_rxc_2,
        qsfp_tx_clk_3,
        qsfp_tx_rst_3,
        qsfp_rx_clk_3,
        qsfp_rx_rst_3,
        qsfp_rxd_3,
        qsfp_rxc_3,
        qsfp_tx_clk_4,
        qsfp_tx_rst_4,
        qsfp_rx_clk_4,
        qsfp_rx_rst_4,
        qsfp_rxd_4,
        qsfp_rxc_4,
        phy_gmii_clk,
        phy_gmii_rst,
        phy_gmii_clk_en,
        phy_gmii_rxd,
        phy_gmii_rx_dv,
        phy_gmii_rx_er,
        phy_int_n,
        uart_rxd,
        uart_cts
    );
    $to_myhdl(
        led,
        qsfp_txd_1,
        qsfp_txc_1,
        qsfp_txd_2,
        qsfp_txc_2,
        qsfp_txd_3,
        qsfp_txc_3,
        qsfp_txd_4,
        qsfp_txc_4,
        phy_gmii_txd,
        phy_gmii_tx_en,
        phy_gmii_tx_er,
        phy_reset_n,
        uart_txd,
        uart_rts
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
    .qsfp_tx_clk_1(qsfp_tx_clk_1),
    .qsfp_tx_rst_1(qsfp_tx_rst_1),
    .qsfp_txd_1(qsfp_txd_1),
    .qsfp_txc_1(qsfp_txc_1),
    .qsfp_rx_clk_1(qsfp_rx_clk_1),
    .qsfp_rx_rst_1(qsfp_rx_rst_1),
    .qsfp_rxd_1(qsfp_rxd_1),
    .qsfp_rxc_1(qsfp_rxc_1),
    .qsfp_tx_clk_2(qsfp_tx_clk_2),
    .qsfp_tx_rst_2(qsfp_tx_rst_2),
    .qsfp_txd_2(qsfp_txd_2),
    .qsfp_txc_2(qsfp_txc_2),
    .qsfp_rx_clk_2(qsfp_rx_clk_2),
    .qsfp_rx_rst_2(qsfp_rx_rst_2),
    .qsfp_rxd_2(qsfp_rxd_2),
    .qsfp_rxc_2(qsfp_rxc_2),
    .qsfp_tx_clk_3(qsfp_tx_clk_3),
    .qsfp_tx_rst_3(qsfp_tx_rst_3),
    .qsfp_txd_3(qsfp_txd_3),
    .qsfp_txc_3(qsfp_txc_3),
    .qsfp_rx_clk_3(qsfp_rx_clk_3),
    .qsfp_rx_rst_3(qsfp_rx_rst_3),
    .qsfp_rxd_3(qsfp_rxd_3),
    .qsfp_rxc_3(qsfp_rxc_3),
    .qsfp_tx_clk_4(qsfp_tx_clk_4),
    .qsfp_tx_rst_4(qsfp_tx_rst_4),
    .qsfp_txd_4(qsfp_txd_4),
    .qsfp_txc_4(qsfp_txc_4),
    .qsfp_rx_clk_4(qsfp_rx_clk_4),
    .qsfp_rx_rst_4(qsfp_rx_rst_4),
    .qsfp_rxd_4(qsfp_rxd_4),
    .qsfp_rxc_4(qsfp_rxc_4),
    .phy_gmii_clk(phy_gmii_clk),
    .phy_gmii_rst(phy_gmii_rst),
    .phy_gmii_clk_en(phy_gmii_clk_en),
    .phy_gmii_rxd(phy_gmii_rxd),
    .phy_gmii_rx_dv(phy_gmii_rx_dv),
    .phy_gmii_rx_er(phy_gmii_rx_er),
    .phy_gmii_txd(phy_gmii_txd),
    .phy_gmii_tx_en(phy_gmii_tx_en),
    .phy_gmii_tx_er(phy_gmii_tx_er),
    .phy_reset_n(phy_reset_n),
    .phy_int_n(phy_int_n),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts)
);

endmodule
