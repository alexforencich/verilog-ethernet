/*

Copyright (c) 2015-2016 Alex Forencich

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
 * 10G Ethernet MAC
 */
module eth_mac_10g #
(
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        rx_clk,
    input  wire        rx_rst,
    input  wire        tx_clk,
    input  wire        tx_rst,

    /*
     * AXI input
     */
    input  wire [63:0] tx_axis_tdata,
    input  wire [7:0]  tx_axis_tkeep,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [63:0] rx_axis_tdata,
    output wire [7:0]  rx_axis_tkeep,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,

    /*
     * XGMII interface
     */
    input  wire [63:0] xgmii_rxd,
    input  wire [7:0]  xgmii_rxc,
    output wire [63:0] xgmii_txd,
    output wire [7:0]  xgmii_txc,

    /*
     * Status
     */
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,

    /*
     * Configuration
     */
    input  wire [7:0]  ifg_delay
);

eth_mac_10g_rx
eth_mac_10g_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .output_axis_tdata(rx_axis_tdata),
    .output_axis_tkeep(rx_axis_tkeep),
    .output_axis_tvalid(rx_axis_tvalid),
    .output_axis_tlast(rx_axis_tlast),
    .output_axis_tuser(rx_axis_tuser),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

eth_mac_10g_tx #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_10g_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .input_axis_tdata(tx_axis_tdata),
    .input_axis_tkeep(tx_axis_tkeep),
    .input_axis_tvalid(tx_axis_tvalid),
    .input_axis_tready(tx_axis_tready),
    .input_axis_tlast(tx_axis_tlast),
    .input_axis_tuser(tx_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ifg_delay(ifg_delay)
);

endmodule
