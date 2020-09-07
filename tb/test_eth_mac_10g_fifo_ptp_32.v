/*

Copyright (c) 2019 Alex Forencich

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
 * Testbench for eth_mac_10g_fifo
 */
module test_eth_mac_10g_fifo_ptp_32;

// Parameters
parameter DATA_WIDTH = 32;
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter AXIS_DATA_WIDTH = DATA_WIDTH;
parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8);
parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8);
parameter ENABLE_PADDING = 1;
parameter ENABLE_DIC = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter TX_FIFO_DEPTH = 4096;
parameter TX_FIFO_PIPELINE_OUTPUT = 2;
parameter TX_FRAME_FIFO = 1;
parameter TX_DROP_BAD_FRAME = TX_FRAME_FIFO;
parameter TX_DROP_WHEN_FULL = 0;
parameter RX_FIFO_DEPTH = 4096;
parameter RX_FIFO_PIPELINE_OUTPUT = 2;
parameter RX_FRAME_FIFO = 1;
parameter RX_DROP_BAD_FRAME = RX_FRAME_FIFO;
parameter RX_DROP_WHEN_FULL = RX_FRAME_FIFO;
parameter LOGIC_PTP_PERIOD_NS = 4'h3;
parameter LOGIC_PTP_PERIOD_FNS = 16'h3333;
parameter PTP_PERIOD_NS = 4'h3;
parameter PTP_PERIOD_FNS = 16'h3333;
parameter PTP_USE_SAMPLE_CLOCK = 0;
parameter TX_PTP_TS_ENABLE = 1;
parameter RX_PTP_TS_ENABLE = 1;
parameter TX_PTP_TS_FIFO_DEPTH = 64;
parameter RX_PTP_TS_FIFO_DEPTH = 64;
parameter PTP_TS_WIDTH = 96;
parameter TX_PTP_TAG_ENABLE = 1;
parameter PTP_TAG_WIDTH = 16;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;
reg logic_clk = 0;
reg logic_rst = 0;
reg ptp_sample_clk = 0;
reg [AXIS_DATA_WIDTH-1:0] tx_axis_tdata = 0;
reg [AXIS_KEEP_WIDTH-1:0] tx_axis_tkeep = 0;
reg tx_axis_tvalid = 0;
reg tx_axis_tlast = 0;
reg tx_axis_tuser = 0;
reg [PTP_TAG_WIDTH-1:0] s_axis_tx_ptp_ts_tag = 0;
reg s_axis_tx_ptp_ts_valid = 0;
reg m_axis_tx_ptp_ts_ready = 0;
reg rx_axis_tready = 0;
reg m_axis_rx_ptp_ts_ready = 0;
reg [DATA_WIDTH-1:0] xgmii_rxd = 0;
reg [CTRL_WIDTH-1:0] xgmii_rxc = 0;
reg [PTP_TS_WIDTH-1:0] ptp_ts_96 = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire tx_axis_tready;
wire s_axis_tx_ptp_ts_ready;
wire [PTP_TS_WIDTH-1:0] m_axis_tx_ptp_ts_96;
wire [PTP_TAG_WIDTH-1:0] m_axis_tx_ptp_ts_tag;
wire m_axis_tx_ptp_ts_valid;
wire [AXIS_DATA_WIDTH-1:0] rx_axis_tdata;
wire [AXIS_KEEP_WIDTH-1:0] rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire rx_axis_tuser;
wire [PTP_TS_WIDTH-1:0] m_axis_rx_ptp_ts_96;
wire m_axis_rx_ptp_ts_valid;
wire [DATA_WIDTH-1:0] xgmii_txd;
wire [CTRL_WIDTH-1:0] xgmii_txc;
wire tx_error_underflow;
wire tx_fifo_overflow;
wire tx_fifo_bad_frame;
wire tx_fifo_good_frame;
wire rx_error_bad_frame;
wire rx_error_bad_fcs;
wire rx_fifo_overflow;
wire rx_fifo_bad_frame;
wire rx_fifo_good_frame;

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
        logic_clk,
        logic_rst,
        ptp_sample_clk,
        tx_axis_tdata,
        tx_axis_tkeep,
        tx_axis_tvalid,
        tx_axis_tlast,
        tx_axis_tuser,
        s_axis_tx_ptp_ts_tag,
        s_axis_tx_ptp_ts_valid,
        m_axis_tx_ptp_ts_ready,
        rx_axis_tready,
        m_axis_rx_ptp_ts_ready,
        xgmii_rxd,
        xgmii_rxc,
        ptp_ts_96,
        ifg_delay
    );
    $to_myhdl(
        tx_axis_tready,
        s_axis_tx_ptp_ts_ready,
        m_axis_tx_ptp_ts_96,
        m_axis_tx_ptp_ts_tag,
        m_axis_tx_ptp_ts_valid,
        rx_axis_tdata,
        rx_axis_tkeep,
        rx_axis_tvalid,
        rx_axis_tlast,
        rx_axis_tuser,
        m_axis_rx_ptp_ts_96,
        m_axis_rx_ptp_ts_valid,
        xgmii_txd,
        xgmii_txc,
        tx_error_underflow,
        tx_fifo_overflow,
        tx_fifo_bad_frame,
        tx_fifo_good_frame,
        rx_error_bad_frame,
        rx_error_bad_fcs,
        rx_fifo_overflow,
        rx_fifo_bad_frame,
        rx_fifo_good_frame
    );

    // dump file
    $dumpfile("test_eth_mac_10g_fifo_ptp_32.lxt");
    $dumpvars(0, test_eth_mac_10g_fifo_ptp_32);
end

eth_mac_10g_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
    .AXIS_KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .AXIS_KEEP_WIDTH(AXIS_KEEP_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_FIFO_PIPELINE_OUTPUT(TX_FIFO_PIPELINE_OUTPUT),
    .TX_FRAME_FIFO(TX_FRAME_FIFO),
    .TX_DROP_BAD_FRAME(TX_DROP_BAD_FRAME),
    .TX_DROP_WHEN_FULL(TX_DROP_WHEN_FULL),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .RX_FIFO_PIPELINE_OUTPUT(RX_FIFO_PIPELINE_OUTPUT),
    .RX_FRAME_FIFO(RX_FRAME_FIFO),
    .RX_DROP_BAD_FRAME(RX_DROP_BAD_FRAME),
    .RX_DROP_WHEN_FULL(RX_DROP_WHEN_FULL),
    .LOGIC_PTP_PERIOD_NS(LOGIC_PTP_PERIOD_NS),
    .LOGIC_PTP_PERIOD_FNS(LOGIC_PTP_PERIOD_FNS),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .PTP_USE_SAMPLE_CLOCK(PTP_USE_SAMPLE_CLOCK),
    .TX_PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .RX_PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .TX_PTP_TS_FIFO_DEPTH(TX_PTP_TS_FIFO_DEPTH),
    .RX_PTP_TS_FIFO_DEPTH(RX_PTP_TS_FIFO_DEPTH),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .TX_PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(PTP_TAG_WIDTH)
)
UUT (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .logic_clk(logic_clk),
    .logic_rst(logic_rst),
    .ptp_sample_clk(ptp_sample_clk),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .s_axis_tx_ptp_ts_tag(s_axis_tx_ptp_ts_tag),
    .s_axis_tx_ptp_ts_valid(s_axis_tx_ptp_ts_valid),
    .s_axis_tx_ptp_ts_ready(s_axis_tx_ptp_ts_ready),
    .m_axis_tx_ptp_ts_96(m_axis_tx_ptp_ts_96),
    .m_axis_tx_ptp_ts_tag(m_axis_tx_ptp_ts_tag),
    .m_axis_tx_ptp_ts_valid(m_axis_tx_ptp_ts_valid),
    .m_axis_tx_ptp_ts_ready(m_axis_tx_ptp_ts_ready),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .m_axis_rx_ptp_ts_96(m_axis_rx_ptp_ts_96),
    .m_axis_rx_ptp_ts_valid(m_axis_rx_ptp_ts_valid),
    .m_axis_rx_ptp_ts_ready(m_axis_rx_ptp_ts_ready),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .tx_error_underflow(tx_error_underflow),
    .tx_fifo_overflow(tx_fifo_overflow),
    .tx_fifo_bad_frame(tx_fifo_bad_frame),
    .tx_fifo_good_frame(tx_fifo_good_frame),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .rx_fifo_overflow(rx_fifo_overflow),
    .rx_fifo_bad_frame(rx_fifo_bad_frame),
    .rx_fifo_good_frame(rx_fifo_good_frame),
    .ptp_ts_96(ptp_ts_96),
    .ifg_delay(ifg_delay)
);

endmodule
