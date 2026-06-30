/*

Copyright (c) 2026 Alex Forencich

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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10M/100M Ethernet MAC with RMII interface
 */
module eth_mac_rmii #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-6, 7-series
    // Use BUFG for Virtex-5, Spartan-6, Ultrascale
    parameter CLOCK_INPUT_STYLE = "BUFG",
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        rst,
    output wire        rx_clk,
    output wire        rx_rst,
    output wire        tx_clk,
    output wire        tx_rst,

    /*
     * AXI input
     */
    input  wire [7:0]  tx_axis_tdata,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [7:0]  rx_axis_tdata,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,

    /*
     * RMII interface
     */
    input  wire        rmii_ref_clk,
    input  wire        rmii_crs_dv,
    input  wire [1:0]  rmii_rxd,
    input  wire        rmii_rx_er,
    output wire [1:0]  rmii_txd,
    output wire        rmii_tx_en,

    /*
     * Status
     */
    output wire        tx_start_packet,
    output wire        tx_error_underflow,
    output wire        rx_start_packet,
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,

    /*
     * Configuration
     */
    input  wire [7:0]  cfg_ifg,
    input  wire        cfg_tx_enable,
    input  wire        cfg_rx_enable,
    // link speed, 2'b00 = 10 Mb/s, 2'b01 = 100 Mb/s (RMII has no 1000M)
    input  wire [1:0]  speed
);

// RMII is single-clock: rx and tx share the one forwarded reference clock, so
// rx_clk/tx_clk and rx_rst/tx_rst are tied together (cf. MII, which has separate
// recovered rx and forwarded tx clocks).
wire        mac_clk;
wire        mac_rst;

assign rx_clk = mac_clk;
assign tx_clk = mac_clk;
assign rx_rst = mac_rst;
assign tx_rst = mac_rst;

wire        mac_rx_clk_enable;
wire [7:0]  mac_gmii_rxd;
wire        mac_gmii_rx_dv;
wire        mac_gmii_rx_er;
wire        mac_tx_clk_enable;
wire [7:0]  mac_gmii_txd;
wire        mac_gmii_tx_en;
wire        mac_gmii_tx_er;

rmii_phy_if #(
    .TARGET(TARGET),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE)
)
rmii_phy_if_inst (
    .rst(rst),

    .ref_clk(rmii_ref_clk),
    .speed(speed),

    .mac_clk(mac_clk),
    .mac_rst(mac_rst),
    .mac_rx_clk_enable(mac_rx_clk_enable),
    .mac_gmii_rxd(mac_gmii_rxd),
    .mac_gmii_rx_dv(mac_gmii_rx_dv),
    .mac_gmii_rx_er(mac_gmii_rx_er),
    .mac_tx_clk_enable(mac_tx_clk_enable),
    .mac_gmii_txd(mac_gmii_txd),
    .mac_gmii_tx_en(mac_gmii_tx_en),
    .mac_gmii_tx_er(mac_gmii_tx_er),

    .phy_rmii_crs_dv(rmii_crs_dv),
    .phy_rmii_rxd(rmii_rxd),
    .phy_rmii_rx_er(rmii_rx_er),
    .phy_rmii_txd(rmii_txd),
    .phy_rmii_tx_en(rmii_tx_en)
);

eth_mac_1g #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_1g_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .gmii_rxd(mac_gmii_rxd),
    .gmii_rx_dv(mac_gmii_rx_dv),
    .gmii_rx_er(mac_gmii_rx_er),
    .gmii_txd(mac_gmii_txd),
    .gmii_tx_en(mac_gmii_tx_en),
    .gmii_tx_er(mac_gmii_tx_er),
    .rx_clk_enable(mac_rx_clk_enable),
    .tx_clk_enable(mac_tx_clk_enable),
    .rx_mii_select(1'b0),
    .tx_mii_select(1'b0),
    .tx_start_packet(tx_start_packet),
    .tx_error_underflow(tx_error_underflow),
    .rx_start_packet(rx_start_packet),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .cfg_ifg(cfg_ifg),
    .cfg_tx_enable(cfg_tx_enable),
    .cfg_rx_enable(cfg_rx_enable)
);

endmodule

`resetall
