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
 * Testbench for eth_mac_1g_gmii
 */
module test_eth_mac_1g_gmii;

// Parameters
parameter TARGET = "SIM";
parameter IODDR_STYLE = "IODDR2";
parameter CLOCK_INPUT_STYLE = "BUFIO2";
parameter ENABLE_PADDING = 1;
parameter MIN_FRAME_LENGTH = 64;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg gtx_clk = 0;
reg gtx_rst = 0;
reg [7:0] tx_axis_tdata = 0;
reg tx_axis_tvalid = 0;
reg tx_axis_tlast = 0;
reg tx_axis_tuser = 0;
reg gmii_rx_clk = 0;
reg [7:0] gmii_rxd = 0;
reg gmii_rx_dv = 0;
reg gmii_rx_er = 0;
reg mii_tx_clk = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire rx_clk;
wire rx_rst;
wire tx_clk;
wire tx_rst;
wire tx_axis_tready;
wire [7:0] rx_axis_tdata;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire rx_axis_tuser;
wire gmii_tx_clk;
wire [7:0] gmii_txd;
wire gmii_tx_en;
wire gmii_tx_er;
wire tx_error_underflow;
wire rx_error_bad_frame;
wire rx_error_bad_fcs;
wire [1:0] speed;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        gtx_clk,
        gtx_rst,
        tx_axis_tdata,
        tx_axis_tvalid,
        tx_axis_tlast,
        tx_axis_tuser,
        gmii_rx_clk,
        gmii_rxd,
        gmii_rx_dv,
        gmii_rx_er,
        mii_tx_clk,
        ifg_delay
    );
    $to_myhdl(
        rx_clk,
        rx_rst,
        tx_clk,
        tx_rst,
        tx_axis_tready,
        rx_axis_tdata,
        rx_axis_tvalid,
        rx_axis_tlast,
        rx_axis_tuser,
        gmii_tx_clk,
        gmii_txd,
        gmii_tx_en,
        gmii_tx_er,
        tx_error_underflow,
        rx_error_bad_frame,
        rx_error_bad_fcs,
        speed
    );

    // dump file
    $dumpfile("test_eth_mac_1g_gmii.lxt");
    $dumpvars(0, test_eth_mac_1g_gmii);
end

eth_mac_1g_gmii #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
UUT (
    .gtx_clk(gtx_clk),
    .gtx_rst(gtx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .gmii_rx_clk(gmii_rx_clk),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_tx_clk(gmii_tx_clk),
    .mii_tx_clk(mii_tx_clk),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),
    .tx_error_underflow(tx_error_underflow),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .speed(speed),
    .ifg_delay(ifg_delay)
);

endmodule
