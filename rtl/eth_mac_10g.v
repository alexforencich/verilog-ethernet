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
 * 10G Ethernet MAC
 */
module eth_mac_10g #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter PTP_PERIOD_NS = 4'h6,
    parameter PTP_PERIOD_FNS = 16'h6666,
    parameter TX_PTP_TS_ENABLE = 0,
    parameter TX_PTP_TS_WIDTH = 96,
    parameter TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE,
    parameter TX_PTP_TAG_WIDTH = 16,
    parameter RX_PTP_TS_ENABLE = 0,
    parameter RX_PTP_TS_WIDTH = 96,
    parameter TX_USER_WIDTH = (TX_PTP_TS_ENABLE && TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1,
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
    input  wire [KEEP_WIDTH-1:0]        tx_axis_tkeep,
    input  wire                         tx_axis_tvalid,
    output wire                         tx_axis_tready,
    input  wire                         tx_axis_tlast,
    input  wire [TX_USER_WIDTH-1:0]     tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]        rx_axis_tdata,
    output wire [KEEP_WIDTH-1:0]        rx_axis_tkeep,
    output wire                         rx_axis_tvalid,
    output wire                         rx_axis_tlast,
    output wire [RX_USER_WIDTH-1:0]     rx_axis_tuser,

    /*
     * XGMII interface
     */
    input  wire [DATA_WIDTH-1:0]        xgmii_rxd,
    input  wire [CTRL_WIDTH-1:0]        xgmii_rxc,
    output wire [DATA_WIDTH-1:0]        xgmii_txd,
    output wire [CTRL_WIDTH-1:0]        xgmii_txc,

    /*
     * PTP
     */
    input  wire [TX_PTP_TS_WIDTH-1:0]   tx_ptp_ts,
    input  wire [RX_PTP_TS_WIDTH-1:0]   rx_ptp_ts,
    output wire [TX_PTP_TS_WIDTH-1:0]   tx_axis_ptp_ts,
    output wire [TX_PTP_TAG_WIDTH-1:0]  tx_axis_ptp_ts_tag,
    output wire                         tx_axis_ptp_ts_valid,

    /*
     * Status
     */
    output wire [1:0]                   tx_start_packet,
    output wire                         tx_error_underflow,
    output wire [1:0]                   rx_start_packet,
    output wire                         rx_error_bad_frame,
    output wire                         rx_error_bad_fcs,

    /*
     * Configuration
     */
    input  wire [7:0]                   ifg_delay
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 32 && DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 32 or 64");
        $finish;
    end

    if (KEEP_WIDTH * 8 != DATA_WIDTH || CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end
end

generate

if (DATA_WIDTH == 64) begin

axis_xgmii_rx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(RX_PTP_TS_WIDTH),
    .USER_WIDTH(RX_USER_WIDTH)
)
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .ptp_ts(rx_ptp_ts),
    .start_packet(rx_start_packet),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

axis_xgmii_tx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(TX_PTP_TS_WIDTH),
    .PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .USER_WIDTH(TX_USER_WIDTH)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ptp_ts(tx_ptp_ts),
    .m_axis_ptp_ts(tx_axis_ptp_ts),
    .m_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .ifg_delay(ifg_delay),
    .start_packet(tx_start_packet),
    .error_underflow(tx_error_underflow)
);

end else begin

axis_xgmii_rx_32 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(RX_PTP_TS_WIDTH),
    .USER_WIDTH(RX_USER_WIDTH)
)
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .ptp_ts(rx_ptp_ts),
    .start_packet(rx_start_packet[0]),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

assign rx_start_packet[1] = 1'b0;

axis_xgmii_tx_32 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .PTP_TS_WIDTH(TX_PTP_TS_WIDTH),
    .PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .USER_WIDTH(TX_USER_WIDTH)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ptp_ts(tx_ptp_ts),
    .m_axis_ptp_ts(tx_axis_ptp_ts),
    .m_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .ifg_delay(ifg_delay),
    .start_packet(tx_start_packet[0])
);

assign tx_start_packet[1] = 1'b0;

end

endgenerate

endmodule

`resetall
