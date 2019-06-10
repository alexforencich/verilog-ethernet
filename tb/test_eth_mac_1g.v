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
 * Testbench for eth_mac_1g
 */
module test_eth_mac_1g;

// Parameters
parameter DATA_WIDTH = 8;
parameter ENABLE_PADDING = 1;
parameter MIN_FRAME_LENGTH = 64;
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
reg tx_axis_tvalid = 0;
reg tx_axis_tlast = 0;
reg [TX_USER_WIDTH-1:0] tx_axis_tuser = 0;
reg [DATA_WIDTH-1:0] gmii_rxd = 0;
reg gmii_rx_dv = 0;
reg gmii_rx_er = 0;
reg [TX_PTP_TS_WIDTH-1:0] tx_ptp_ts = 0;
reg [RX_PTP_TS_WIDTH-1:0] rx_ptp_ts = 0;
reg rx_clk_enable = 1;
reg tx_clk_enable = 1;
reg rx_mii_select = 0;
reg tx_mii_select = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire tx_axis_tready;
wire [DATA_WIDTH-1:0] rx_axis_tdata;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire [RX_USER_WIDTH-1:0] rx_axis_tuser;
wire [DATA_WIDTH-1:0] gmii_txd;
wire gmii_tx_en;
wire gmii_tx_er;
wire [TX_PTP_TS_WIDTH-1:0] tx_axis_ptp_ts;
wire [TX_PTP_TAG_WIDTH-1:0] tx_axis_ptp_ts_tag;
wire tx_axis_ptp_ts_valid;
wire tx_start_packet;
wire tx_error_underflow;
wire rx_start_packet;
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
        tx_axis_tvalid,
        tx_axis_tlast,
        tx_axis_tuser,
        gmii_rxd,
        gmii_rx_dv,
        gmii_rx_er,
        tx_ptp_ts,
        rx_ptp_ts,
        rx_clk_enable,
        tx_clk_enable,
        rx_mii_select,
        tx_mii_select,
        ifg_delay
    );
    $to_myhdl(
        tx_axis_tready,
        rx_axis_tdata,
        rx_axis_tvalid,
        rx_axis_tlast,
        rx_axis_tuser,
        gmii_txd,
        gmii_tx_en,
        gmii_tx_er,
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
    $dumpfile("test_eth_mac_1g.lxt");
    $dumpvars(0, test_eth_mac_1g);
end

eth_mac_1g #(
    .DATA_WIDTH(DATA_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
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
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),
    .tx_ptp_ts(tx_ptp_ts),
    .rx_ptp_ts(rx_ptp_ts),
    .tx_axis_ptp_ts(tx_axis_ptp_ts),
    .tx_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .tx_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .rx_clk_enable(rx_clk_enable),
    .tx_clk_enable(tx_clk_enable),
    .rx_mii_select(rx_mii_select),
    .tx_mii_select(tx_mii_select),
    .tx_start_packet(tx_start_packet),
    .tx_error_underflow(tx_error_underflow),
    .rx_start_packet(rx_start_packet),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .ifg_delay(ifg_delay)
);

endmodule
