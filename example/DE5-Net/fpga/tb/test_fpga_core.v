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

reg [3:0] btn = 0;
reg [3:0] sw = 0;
reg [63:0] sfp_a_rxd = 0;
reg [7:0] sfp_a_rxc = 0;
reg [63:0] sfp_b_rxd = 0;
reg [7:0] sfp_b_rxc = 0;
reg [63:0] sfp_c_rxd = 0;
reg [7:0] sfp_c_rxc = 0;
reg [63:0] sfp_d_rxd = 0;
reg [7:0] sfp_d_rxc = 0;

// Outputs
wire [3:0] led;
wire [3:0] led_bkt;
wire [6:0] led_hex0_d;
wire led_hex0_dp;
wire [6:0] led_hex1_d;
wire led_hex1_dp;
wire [63:0] sfp_a_txd;
wire [7:0] sfp_a_txc;
wire [63:0] sfp_b_txd;
wire [7:0] sfp_b_txc;
wire [63:0] sfp_c_txd;
wire [7:0] sfp_c_txc;
wire [63:0] sfp_d_txd;
wire [7:0] sfp_d_txc;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        btn,
        sw,
        sfp_a_rxd,
        sfp_a_rxc,
        sfp_b_rxd,
        sfp_b_rxc,
        sfp_c_rxd,
        sfp_c_rxc,
        sfp_d_rxd,
        sfp_d_rxc
    );
    $to_myhdl(
        led,
        led_bkt,
        led_hex0_d,
        led_hex0_dp,
        led_hex1_d,
        led_hex1_dp,
        sfp_a_txd,
        sfp_a_txc,
        sfp_b_txd,
        sfp_b_txc,
        sfp_c_txd,
        sfp_c_txc,
        sfp_d_txd,
        sfp_d_txc
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
    .sw(sw),
    .led(led),
    .led_bkt(led_bkt),
    .led_hex0_d(led_hex0_d),
    .led_hex0_dp(led_hex0_dp),
    .led_hex1_d(led_hex1_d),
    .led_hex1_dp(led_hex1_dp),
    .sfp_a_txd(sfp_a_txd),
    .sfp_a_txc(sfp_a_txc),
    .sfp_a_rxd(sfp_a_rxd),
    .sfp_a_rxc(sfp_a_rxc),
    .sfp_b_txd(sfp_b_txd),
    .sfp_b_txc(sfp_b_txc),
    .sfp_b_rxd(sfp_b_rxd),
    .sfp_b_rxc(sfp_b_rxc),
    .sfp_c_txd(sfp_c_txd),
    .sfp_c_txc(sfp_c_txc),
    .sfp_c_rxd(sfp_c_rxd),
    .sfp_c_rxc(sfp_c_rxc),
    .sfp_d_txd(sfp_d_txd),
    .sfp_d_txc(sfp_d_txc),
    .sfp_d_rxd(sfp_d_rxd),
    .sfp_d_rxc(sfp_d_rxc)
);

endmodule
