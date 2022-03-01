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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 1G Ethernet MAC
 */
module eth_mac_1g #
(
    parameter DATA_WIDTH = 8,
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_PTP_TS_ENABLE = 0,
    parameter TX_PTP_TS_WIDTH = 96,
    parameter TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE,
    parameter TX_PTP_TAG_WIDTH = 16,
    parameter RX_PTP_TS_ENABLE = 0,
    parameter RX_PTP_TS_WIDTH = 96,
    parameter TX_USER_WIDTH = (TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1,
    parameter RX_USER_WIDTH = (RX_PTP_TS_ENABLE ? RX_PTP_TS_WIDTH : 0) + 1
)
(
    input  wire                         rx_clk,
    input  wire                         rx_rst,
    input  wire                         tx_clk,
    input  wire                         tx_rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]        tx_axis_tdata,
    input  wire                         tx_axis_tvalid,
    output wire                         tx_axis_tready,
    input  wire                         tx_axis_tlast,
    input  wire [TX_USER_WIDTH-1:0]     tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]        rx_axis_tdata,
    output wire                         rx_axis_tvalid,
    output wire                         rx_axis_tlast,
    output wire [RX_USER_WIDTH-1:0]     rx_axis_tuser,

    /*
     * GMII interface
     */
    input  wire [DATA_WIDTH-1:0]        gmii_rxd,
    input  wire                         gmii_rx_dv,
    input  wire                         gmii_rx_er,
    output wire [DATA_WIDTH-1:0]        gmii_txd,
    output wire                         gmii_tx_en,
    output wire                         gmii_tx_er,

    /*
     * PTP
     */
    input  wire [TX_PTP_TS_WIDTH-1:0]   tx_ptp_ts,
    input  wire [RX_PTP_TS_WIDTH-1:0]   rx_ptp_ts,
    output wire [TX_PTP_TS_WIDTH-1:0]   tx_axis_ptp_ts,
    output wire [TX_PTP_TAG_WIDTH-1:0]  tx_axis_ptp_ts_tag,
    output wire                         tx_axis_ptp_ts_valid,

    /*
     * Control
     */
    input  wire                         rx_clk_enable,
    input  wire                         tx_clk_enable,
    input  wire                         rx_mii_select,
    input  wire                         tx_mii_select,

    /*
     * Status
     */
    output wire                         tx_start_packet,
    output wire                         tx_error_underflow,
    output wire                         rx_start_packet,
    output wire                         rx_error_bad_frame,
    output wire                         rx_error_bad_fcs,

    /*
     * Configuration
     */
    input  wire [7:0]                   ifg_delay
);

axis_gmii_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(RX_PTP_TS_WIDTH),
    .USER_WIDTH(RX_USER_WIDTH)
)
axis_gmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .ptp_ts(rx_ptp_ts),
    .clk_enable(rx_clk_enable),
    .mii_select(rx_mii_select),
    .start_packet(rx_start_packet),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

axis_gmii_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(TX_PTP_TS_WIDTH),
    .PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .USER_WIDTH(TX_USER_WIDTH)
)
axis_gmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),
    .ptp_ts(tx_ptp_ts),
    .m_axis_ptp_ts(tx_axis_ptp_ts),
    .m_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .clk_enable(tx_clk_enable),
    .mii_select(tx_mii_select),
    .ifg_delay(ifg_delay),
    .start_packet(tx_start_packet),
    .error_underflow(tx_error_underflow)
);

endmodule

`resetall
