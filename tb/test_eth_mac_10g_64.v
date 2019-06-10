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
 * Testbench for eth_mac_10g
 */
module test_eth_mac_10g_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter ENABLE_PADDING = 1;
parameter ENABLE_DIC = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter PTP_PERIOD_NS = 4'h6;
parameter PTP_PERIOD_FNS = 16'h6666;
parameter TX_PTP_TS_ENABLE = 0;
parameter TX_PTP_TS_WIDTH = 96;
parameter TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE;
parameter TX_PTP_TAG_WIDTH = 16;
parameter RX_PTP_TS_ENABLE = 0;
parameter RX_PTP_TS_WIDTH = 96;
parameter TX_USER_WIDTH = (TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1;
parameter RX_USER_WIDTH = (RX_PTP_TS_ENABLE ? RX_PTP_TS_WIDTH : 0) + 1;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;
reg [DATA_WIDTH-1:0] tx_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] tx_axis_tkeep = 0;
reg tx_axis_tvalid = 0;
reg tx_axis_tlast = 0;
reg [TX_USER_WIDTH-1:0] tx_axis_tuser = 0;
reg [DATA_WIDTH-1:0] xgmii_rxd = 0;
reg [CTRL_WIDTH-1:0] xgmii_rxc = 0;
reg [TX_PTP_TS_WIDTH-1:0] tx_ptp_ts = 0;
reg [RX_PTP_TS_WIDTH-1:0] rx_ptp_ts = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire tx_axis_tready;
wire [DATA_WIDTH-1:0] rx_axis_tdata;
wire [KEEP_WIDTH-1:0] rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire [RX_USER_WIDTH-1:0] rx_axis_tuser;
wire [DATA_WIDTH-1:0] xgmii_txd;
wire [CTRL_WIDTH-1:0] xgmii_txc;
wire [TX_PTP_TS_WIDTH-1:0] tx_axis_ptp_ts;
wire [TX_PTP_TAG_WIDTH-1:0] tx_axis_ptp_ts_tag;
wire tx_axis_ptp_ts_valid;
wire [1:0] tx_start_packet;
wire tx_error_underflow;
wire [1:0] rx_start_packet;
wire rx_error_bad_frame;
wire rx_error_bad_fcs;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        rx_clk,
        rx_rst,
        tx_clk,
        tx_rst,
        tx_axis_tdata,
        tx_axis_tkeep,
        tx_axis_tvalid,
        tx_axis_tlast,
        tx_axis_tuser,
        xgmii_rxd,
        xgmii_rxc,
        tx_ptp_ts,
        rx_ptp_ts,
        ifg_delay
    );
    $to_myhdl(
        tx_axis_tready,
        rx_axis_tdata,
        rx_axis_tkeep,
        rx_axis_tvalid,
        rx_axis_tlast,
        rx_axis_tuser,
        xgmii_txd,
        xgmii_txc,
        tx_axis_ptp_ts,
        tx_axis_ptp_ts_tag,
        tx_axis_ptp_ts_valid,
        tx_start_packet,
        tx_error_underflow,
        rx_start_packet,
        rx_error_bad_frame,
        rx_error_bad_fcs
    );

    // dump file
    $dumpfile("test_eth_mac_10g_64.lxt");
    $dumpvars(0, test_eth_mac_10g_64);
end

eth_mac_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .TX_PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .TX_PTP_TS_WIDTH(TX_PTP_TS_WIDTH),
    .TX_PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .TX_PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .RX_PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .RX_PTP_TS_WIDTH(RX_PTP_TS_WIDTH),
    .TX_USER_WIDTH(TX_USER_WIDTH),
    .RX_USER_WIDTH(RX_USER_WIDTH)
)
UUT (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .tx_ptp_ts(tx_ptp_ts),
    .rx_ptp_ts(rx_ptp_ts),
    .tx_axis_ptp_ts(tx_axis_ptp_ts),
    .tx_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .tx_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .tx_start_packet(tx_start_packet),
    .tx_error_underflow(tx_error_underflow),
    .rx_start_packet(rx_start_packet),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .ifg_delay(ifg_delay)
);

endmodule
