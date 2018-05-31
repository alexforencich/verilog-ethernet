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

reg [1:0] sw = 0;
reg [3:0] jp = 0;
reg uart_suspend = 0;
reg uart_dtr = 0;
reg uart_txd = 0;
reg uart_rts = 0;
reg amh_right_mdio_i = 0;
reg amh_left_mdio_i = 0;
reg [63:0] eth_r0_rxd = 0;
reg [7:0] eth_r0_rxc = 0;
reg [63:0] eth_r1_rxd = 0;
reg [7:0] eth_r1_rxc = 0;
reg [63:0] eth_r2_rxd = 0;
reg [7:0] eth_r2_rxc = 0;
reg [63:0] eth_r3_rxd = 0;
reg [7:0] eth_r3_rxc = 0;
reg [63:0] eth_r4_rxd = 0;
reg [7:0] eth_r4_rxc = 0;
reg [63:0] eth_r5_rxd = 0;
reg [7:0] eth_r5_rxc = 0;
reg [63:0] eth_r6_rxd = 0;
reg [7:0] eth_r6_rxc = 0;
reg [63:0] eth_r7_rxd = 0;
reg [7:0] eth_r7_rxc = 0;
reg [63:0] eth_r8_rxd = 0;
reg [7:0] eth_r8_rxc = 0;
reg [63:0] eth_r9_rxd = 0;
reg [7:0] eth_r9_rxc = 0;
reg [63:0] eth_r10_rxd = 0;
reg [7:0] eth_r10_rxc = 0;
reg [63:0] eth_r11_rxd = 0;
reg [7:0] eth_r11_rxc = 0;
reg [63:0] eth_l0_rxd = 0;
reg [7:0] eth_l0_rxc = 0;
reg [63:0] eth_l1_rxd = 0;
reg [7:0] eth_l1_rxc = 0;
reg [63:0] eth_l2_rxd = 0;
reg [7:0] eth_l2_rxc = 0;
reg [63:0] eth_l3_rxd = 0;
reg [7:0] eth_l3_rxc = 0;
reg [63:0] eth_l4_rxd = 0;
reg [7:0] eth_l4_rxc = 0;
reg [63:0] eth_l5_rxd = 0;
reg [7:0] eth_l5_rxc = 0;
reg [63:0] eth_l6_rxd = 0;
reg [7:0] eth_l6_rxc = 0;
reg [63:0] eth_l7_rxd = 0;
reg [7:0] eth_l7_rxc = 0;
reg [63:0] eth_l8_rxd = 0;
reg [7:0] eth_l8_rxc = 0;
reg [63:0] eth_l9_rxd = 0;
reg [7:0] eth_l9_rxc = 0;
reg [63:0] eth_l10_rxd = 0;
reg [7:0] eth_l10_rxc = 0;
reg [63:0] eth_l11_rxd = 0;
reg [7:0] eth_l11_rxc = 0;

// Outputs
wire [3:0] led;
wire uart_rst;
wire uart_ri;
wire uart_dcd;
wire uart_dsr;
wire uart_rxd;
wire uart_cts;
wire amh_right_mdc;
wire amh_right_mdio_o;
wire amh_right_mdio_t;
wire amh_left_mdc;
wire amh_left_mdio_o;
wire amh_left_mdio_t;
wire [63:0] eth_r0_txd;
wire [7:0] eth_r0_txc;
wire [63:0] eth_r1_txd;
wire [7:0] eth_r1_txc;
wire [63:0] eth_r2_txd;
wire [7:0] eth_r2_txc;
wire [63:0] eth_r3_txd;
wire [7:0] eth_r3_txc;
wire [63:0] eth_r4_txd;
wire [7:0] eth_r4_txc;
wire [63:0] eth_r5_txd;
wire [7:0] eth_r5_txc;
wire [63:0] eth_r6_txd;
wire [7:0] eth_r6_txc;
wire [63:0] eth_r7_txd;
wire [7:0] eth_r7_txc;
wire [63:0] eth_r8_txd;
wire [7:0] eth_r8_txc;
wire [63:0] eth_r9_txd;
wire [7:0] eth_r9_txc;
wire [63:0] eth_r10_txd;
wire [7:0] eth_r10_txc;
wire [63:0] eth_r11_txd;
wire [7:0] eth_r11_txc;
wire [63:0] eth_l0_txd;
wire [7:0] eth_l0_txc;
wire [63:0] eth_l1_txd;
wire [7:0] eth_l1_txc;
wire [63:0] eth_l2_txd;
wire [7:0] eth_l2_txc;
wire [63:0] eth_l3_txd;
wire [7:0] eth_l3_txc;
wire [63:0] eth_l4_txd;
wire [7:0] eth_l4_txc;
wire [63:0] eth_l5_txd;
wire [7:0] eth_l5_txc;
wire [63:0] eth_l6_txd;
wire [7:0] eth_l6_txc;
wire [63:0] eth_l7_txd;
wire [7:0] eth_l7_txc;
wire [63:0] eth_l8_txd;
wire [7:0] eth_l8_txc;
wire [63:0] eth_l9_txd;
wire [7:0] eth_l9_txc;
wire [63:0] eth_l10_txd;
wire [7:0] eth_l10_txc;
wire [63:0] eth_l11_txd;
wire [7:0] eth_l11_txc;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        sw,
        jp,
        uart_suspend,
        uart_dtr,
        uart_txd,
        uart_rts,
        amh_right_mdio_i,
        amh_left_mdio_i,
        eth_r0_rxd,
        eth_r0_rxc,
        eth_r1_rxd,
        eth_r1_rxc,
        eth_r2_rxd,
        eth_r2_rxc,
        eth_r3_rxd,
        eth_r3_rxc,
        eth_r4_rxd,
        eth_r4_rxc,
        eth_r5_rxd,
        eth_r5_rxc,
        eth_r6_rxd,
        eth_r6_rxc,
        eth_r7_rxd,
        eth_r7_rxc,
        eth_r8_rxd,
        eth_r8_rxc,
        eth_r9_rxd,
        eth_r9_rxc,
        eth_r10_rxd,
        eth_r10_rxc,
        eth_r11_rxd,
        eth_r11_rxc,
        eth_l0_rxd,
        eth_l0_rxc,
        eth_l1_rxd,
        eth_l1_rxc,
        eth_l2_rxd,
        eth_l2_rxc,
        eth_l3_rxd,
        eth_l3_rxc,
        eth_l4_rxd,
        eth_l4_rxc,
        eth_l5_rxd,
        eth_l5_rxc,
        eth_l6_rxd,
        eth_l6_rxc,
        eth_l7_rxd,
        eth_l7_rxc,
        eth_l8_rxd,
        eth_l8_rxc,
        eth_l9_rxd,
        eth_l9_rxc,
        eth_l10_rxd,
        eth_l10_rxc,
        eth_l11_rxd,
        eth_l11_rxc
    );
    $to_myhdl(
        led,
        uart_rst,
        uart_ri,
        uart_dcd,
        uart_dsr,
        uart_rxd,
        uart_cts,
        amh_right_mdc,
        amh_right_mdio_o,
        amh_right_mdio_t,
        amh_left_mdc,
        amh_left_mdio_o,
        amh_left_mdio_t,
        eth_r0_txd,
        eth_r0_txc,
        eth_r1_txd,
        eth_r1_txc,
        eth_r2_txd,
        eth_r2_txc,
        eth_r3_txd,
        eth_r3_txc,
        eth_r4_txd,
        eth_r4_txc,
        eth_r5_txd,
        eth_r5_txc,
        eth_r6_txd,
        eth_r6_txc,
        eth_r7_txd,
        eth_r7_txc,
        eth_r8_txd,
        eth_r8_txc,
        eth_r9_txd,
        eth_r9_txc,
        eth_r10_txd,
        eth_r10_txc,
        eth_r11_txd,
        eth_r11_txc,
        eth_l0_txd,
        eth_l0_txc,
        eth_l1_txd,
        eth_l1_txc,
        eth_l2_txd,
        eth_l2_txc,
        eth_l3_txd,
        eth_l3_txc,
        eth_l4_txd,
        eth_l4_txc,
        eth_l5_txd,
        eth_l5_txc,
        eth_l6_txd,
        eth_l6_txc,
        eth_l7_txd,
        eth_l7_txc,
        eth_l8_txd,
        eth_l8_txc,
        eth_l9_txd,
        eth_l9_txc,
        eth_l10_txd,
        eth_l10_txc,
        eth_l11_txd,
        eth_l11_txc
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
    .jp(jp),
    .led(led),
    .uart_rst(uart_rst),
    .uart_suspend(uart_suspend),
    .uart_ri(uart_ri),
    .uart_dcd(uart_dcd),
    .uart_dtr(uart_dtr),
    .uart_dsr(uart_dsr),
    .uart_txd(uart_txd),
    .uart_rxd(uart_rxd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts),
    .amh_right_mdc(amh_right_mdc),
    .amh_right_mdio_i(amh_right_mdio_i),
    .amh_right_mdio_o(amh_right_mdio_o),
    .amh_right_mdio_t(amh_right_mdio_t),
    .amh_left_mdc(amh_left_mdc),
    .amh_left_mdio_i(amh_left_mdio_i),
    .amh_left_mdio_o(amh_left_mdio_o),
    .amh_left_mdio_t(amh_left_mdio_t),
    .eth_r0_txd(eth_r0_txd),
    .eth_r0_txc(eth_r0_txc),
    .eth_r0_rxd(eth_r0_rxd),
    .eth_r0_rxc(eth_r0_rxc),
    .eth_r1_txd(eth_r1_txd),
    .eth_r1_txc(eth_r1_txc),
    .eth_r1_rxd(eth_r1_rxd),
    .eth_r1_rxc(eth_r1_rxc),
    .eth_r2_txd(eth_r2_txd),
    .eth_r2_txc(eth_r2_txc),
    .eth_r2_rxd(eth_r2_rxd),
    .eth_r2_rxc(eth_r2_rxc),
    .eth_r3_txd(eth_r3_txd),
    .eth_r3_txc(eth_r3_txc),
    .eth_r3_rxd(eth_r3_rxd),
    .eth_r3_rxc(eth_r3_rxc),
    .eth_r4_txd(eth_r4_txd),
    .eth_r4_txc(eth_r4_txc),
    .eth_r4_rxd(eth_r4_rxd),
    .eth_r4_rxc(eth_r4_rxc),
    .eth_r5_txd(eth_r5_txd),
    .eth_r5_txc(eth_r5_txc),
    .eth_r5_rxd(eth_r5_rxd),
    .eth_r5_rxc(eth_r5_rxc),
    .eth_r6_txd(eth_r6_txd),
    .eth_r6_txc(eth_r6_txc),
    .eth_r6_rxd(eth_r6_rxd),
    .eth_r6_rxc(eth_r6_rxc),
    .eth_r7_txd(eth_r7_txd),
    .eth_r7_txc(eth_r7_txc),
    .eth_r7_rxd(eth_r7_rxd),
    .eth_r7_rxc(eth_r7_rxc),
    .eth_r8_txd(eth_r8_txd),
    .eth_r8_txc(eth_r8_txc),
    .eth_r8_rxd(eth_r8_rxd),
    .eth_r8_rxc(eth_r8_rxc),
    .eth_r9_txd(eth_r9_txd),
    .eth_r9_txc(eth_r9_txc),
    .eth_r9_rxd(eth_r9_rxd),
    .eth_r9_rxc(eth_r9_rxc),
    .eth_r10_txd(eth_r10_txd),
    .eth_r10_txc(eth_r10_txc),
    .eth_r10_rxd(eth_r10_rxd),
    .eth_r10_rxc(eth_r10_rxc),
    .eth_r11_txd(eth_r11_txd),
    .eth_r11_txc(eth_r11_txc),
    .eth_r11_rxd(eth_r11_rxd),
    .eth_r11_rxc(eth_r11_rxc),
    .eth_l0_txd(eth_l0_txd),
    .eth_l0_txc(eth_l0_txc),
    .eth_l0_rxd(eth_l0_rxd),
    .eth_l0_rxc(eth_l0_rxc),
    .eth_l1_txd(eth_l1_txd),
    .eth_l1_txc(eth_l1_txc),
    .eth_l1_rxd(eth_l1_rxd),
    .eth_l1_rxc(eth_l1_rxc),
    .eth_l2_txd(eth_l2_txd),
    .eth_l2_txc(eth_l2_txc),
    .eth_l2_rxd(eth_l2_rxd),
    .eth_l2_rxc(eth_l2_rxc),
    .eth_l3_txd(eth_l3_txd),
    .eth_l3_txc(eth_l3_txc),
    .eth_l3_rxd(eth_l3_rxd),
    .eth_l3_rxc(eth_l3_rxc),
    .eth_l4_txd(eth_l4_txd),
    .eth_l4_txc(eth_l4_txc),
    .eth_l4_rxd(eth_l4_rxd),
    .eth_l4_rxc(eth_l4_rxc),
    .eth_l5_txd(eth_l5_txd),
    .eth_l5_txc(eth_l5_txc),
    .eth_l5_rxd(eth_l5_rxd),
    .eth_l5_rxc(eth_l5_rxc),
    .eth_l6_txd(eth_l6_txd),
    .eth_l6_txc(eth_l6_txc),
    .eth_l6_rxd(eth_l6_rxd),
    .eth_l6_rxc(eth_l6_rxc),
    .eth_l7_txd(eth_l7_txd),
    .eth_l7_txc(eth_l7_txc),
    .eth_l7_rxd(eth_l7_rxd),
    .eth_l7_rxc(eth_l7_rxc),
    .eth_l8_txd(eth_l8_txd),
    .eth_l8_txc(eth_l8_txc),
    .eth_l8_rxd(eth_l8_rxd),
    .eth_l8_rxc(eth_l8_rxc),
    .eth_l9_txd(eth_l9_txd),
    .eth_l9_txc(eth_l9_txc),
    .eth_l9_rxd(eth_l9_rxd),
    .eth_l9_rxc(eth_l9_rxc),
    .eth_l10_txd(eth_l10_txd),
    .eth_l10_txc(eth_l10_txc),
    .eth_l10_rxd(eth_l10_rxd),
    .eth_l10_rxc(eth_l10_rxc),
    .eth_l11_txd(eth_l11_txd),
    .eth_l11_txc(eth_l11_txc),
    .eth_l11_rxd(eth_l11_rxd),
    .eth_l11_rxc(eth_l11_rxc)
);

endmodule
