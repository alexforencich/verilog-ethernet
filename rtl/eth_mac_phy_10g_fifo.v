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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10G Ethernet MAC/PHY combination with TX and RX FIFOs
 */
module eth_mac_phy_10g_fifo #
(
    parameter DATA_WIDTH = 64,
    parameter HDR_WIDTH = (DATA_WIDTH/32),
    parameter AXIS_DATA_WIDTH = DATA_WIDTH,
    parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8),
    parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0,
    parameter PRBS31_ENABLE = 0,
    parameter TX_SERDES_PIPELINE = 0,
    parameter RX_SERDES_PIPELINE = 0,
    parameter BITSLIP_HIGH_CYCLES = 1,
    parameter BITSLIP_LOW_CYCLES = 8,
    parameter COUNT_125US = 125000/6.4,
    parameter TX_FIFO_DEPTH = 4096,
    parameter TX_FIFO_PIPELINE_OUTPUT = 2,
    parameter TX_FRAME_FIFO = 1,
    parameter TX_DROP_OVERSIZE_FRAME = TX_FRAME_FIFO,
    parameter TX_DROP_BAD_FRAME = TX_DROP_OVERSIZE_FRAME,
    parameter TX_DROP_WHEN_FULL = 0,
    parameter RX_FIFO_DEPTH = 4096,
    parameter RX_FIFO_PIPELINE_OUTPUT = 2,
    parameter RX_FRAME_FIFO = 1,
    parameter RX_DROP_OVERSIZE_FRAME = RX_FRAME_FIFO,
    parameter RX_DROP_BAD_FRAME = RX_DROP_OVERSIZE_FRAME,
    parameter RX_DROP_WHEN_FULL = RX_DROP_OVERSIZE_FRAME,
    parameter PTP_PERIOD_NS = 4'h6,
    parameter PTP_PERIOD_FNS = 16'h6666,
    parameter PTP_USE_SAMPLE_CLOCK = 0,
    parameter TX_PTP_TS_ENABLE = 0,
    parameter RX_PTP_TS_ENABLE = 0,
    parameter TX_PTP_TS_FIFO_DEPTH = 64,
    parameter PTP_TS_WIDTH = 96,
    parameter TX_PTP_TAG_ENABLE = 0,
    parameter PTP_TAG_WIDTH = 16,
    parameter TX_USER_WIDTH = (TX_PTP_TS_ENABLE && TX_PTP_TAG_ENABLE ? PTP_TAG_WIDTH : 0) + 1,
    parameter RX_USER_WIDTH = (RX_PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1
)
(
    input  wire                       rx_clk,
    input  wire                       rx_rst,
    input  wire                       tx_clk,
    input  wire                       tx_rst,
    input  wire                       logic_clk,
    input  wire                       logic_rst,
    input  wire                       ptp_sample_clk,

    /*
     * AXI input
     */
    input  wire [AXIS_DATA_WIDTH-1:0] tx_axis_tdata,
    input  wire [AXIS_KEEP_WIDTH-1:0] tx_axis_tkeep,
    input  wire                       tx_axis_tvalid,
    output wire                       tx_axis_tready,
    input  wire                       tx_axis_tlast,
    input  wire [TX_USER_WIDTH-1:0]   tx_axis_tuser,

    /*
     * Transmit timestamp output
     */
    output wire [PTP_TS_WIDTH-1:0]    m_axis_tx_ptp_ts_96,
    output wire [PTP_TAG_WIDTH-1:0]   m_axis_tx_ptp_ts_tag,
    output wire                       m_axis_tx_ptp_ts_valid,
    input  wire                       m_axis_tx_ptp_ts_ready,

    /*
     * AXI output
     */
    output wire [AXIS_DATA_WIDTH-1:0] rx_axis_tdata,
    output wire [AXIS_KEEP_WIDTH-1:0] rx_axis_tkeep,
    output wire                       rx_axis_tvalid,
    input  wire                       rx_axis_tready,
    output wire                       rx_axis_tlast,
    output wire [RX_USER_WIDTH-1:0]   rx_axis_tuser,

    /*
     * SERDES interface
     */
    output wire [DATA_WIDTH-1:0]      serdes_tx_data,
    output wire [HDR_WIDTH-1:0]       serdes_tx_hdr,
    input  wire [DATA_WIDTH-1:0]      serdes_rx_data,
    input  wire [HDR_WIDTH-1:0]       serdes_rx_hdr,
    output wire                       serdes_rx_bitslip,

    /*
     * Status
     */
    output wire                       tx_error_underflow,
    output wire                       tx_fifo_overflow,
    output wire                       tx_fifo_bad_frame,
    output wire                       tx_fifo_good_frame,
    output wire                       rx_error_bad_frame,
    output wire                       rx_error_bad_fcs,
    output wire                       rx_bad_block,
    output wire                       rx_block_lock,
    output wire                       rx_high_ber,
    output wire                       rx_fifo_overflow,
    output wire                       rx_fifo_bad_frame,
    output wire                       rx_fifo_good_frame,

    /*
     * PTP clock
     */
    input  wire [PTP_TS_WIDTH-1:0]    ptp_ts_96,
    input  wire                       ptp_ts_step,

    /*
     * Configuration
     */
    input  wire [7:0]                 ifg_delay,
    input  wire                       tx_prbs31_enable,
    input  wire                       rx_prbs31_enable
);

parameter KEEP_WIDTH = DATA_WIDTH/8;

wire [DATA_WIDTH-1:0]      tx_fifo_axis_tdata;
wire [KEEP_WIDTH-1:0]      tx_fifo_axis_tkeep;
wire                       tx_fifo_axis_tvalid;
wire                       tx_fifo_axis_tready;
wire                       tx_fifo_axis_tlast;
wire [TX_USER_WIDTH-1:0]   tx_fifo_axis_tuser;

wire [DATA_WIDTH-1:0]      rx_fifo_axis_tdata;
wire [KEEP_WIDTH-1:0]      rx_fifo_axis_tkeep;
wire                       rx_fifo_axis_tvalid;
wire                       rx_fifo_axis_tlast;
wire [RX_USER_WIDTH-1:0]   rx_fifo_axis_tuser;

wire [PTP_TS_WIDTH-1:0]    tx_ptp_ts_96;
wire [PTP_TS_WIDTH-1:0]    rx_ptp_ts_96;

wire [PTP_TS_WIDTH-1:0]    tx_axis_ptp_ts_96;
wire [PTP_TAG_WIDTH-1:0]   tx_axis_ptp_ts_tag;
wire                       tx_axis_ptp_ts_valid;

// synchronize MAC status signals into logic clock domain
wire tx_error_underflow_int;

reg [0:0] tx_sync_reg_1 = 1'b0;
reg [0:0] tx_sync_reg_2 = 1'b0;
reg [0:0] tx_sync_reg_3 = 1'b0;
reg [0:0] tx_sync_reg_4 = 1'b0;

assign tx_error_underflow = tx_sync_reg_3[0] ^ tx_sync_reg_4[0];

always @(posedge tx_clk or posedge tx_rst) begin
    if (tx_rst) begin
        tx_sync_reg_1 <= 1'b0;
    end else begin
        tx_sync_reg_1 <= tx_sync_reg_1 ^ {tx_error_underflow_int};
    end
end

always @(posedge logic_clk or posedge logic_rst) begin
    if (logic_rst) begin
        tx_sync_reg_2 <= 1'b0;
        tx_sync_reg_3 <= 1'b0;
        tx_sync_reg_4 <= 1'b0;
    end else begin
        tx_sync_reg_2 <= tx_sync_reg_1;
        tx_sync_reg_3 <= tx_sync_reg_2;
        tx_sync_reg_4 <= tx_sync_reg_3;
    end
end

wire rx_error_bad_frame_int;
wire rx_error_bad_fcs_int;
wire rx_bad_block_int;
wire rx_block_lock_int;
wire rx_high_ber_int;

reg [4:0] rx_sync_reg_1 = 5'd0;
reg [4:0] rx_sync_reg_2 = 5'd0;
reg [4:0] rx_sync_reg_3 = 5'd0;
reg [4:0] rx_sync_reg_4 = 5'd0;

assign rx_error_bad_frame = rx_sync_reg_3[0] ^ rx_sync_reg_4[0];
assign rx_error_bad_fcs = rx_sync_reg_3[1] ^ rx_sync_reg_4[1];
assign rx_bad_block = rx_sync_reg_3[2] ^ rx_sync_reg_4[2];
assign rx_block_lock = rx_sync_reg_3[3] ^ rx_sync_reg_4[3];
assign rx_high_ber = rx_sync_reg_3[4] ^ rx_sync_reg_4[4];

always @(posedge rx_clk or posedge rx_rst) begin
    if (rx_rst) begin
        rx_sync_reg_1 <= 5'd0;
    end else begin
        rx_sync_reg_1 <= rx_sync_reg_1 ^ {rx_high_ber_int, rx_block_lock_int, rx_bad_block_int, rx_error_bad_fcs_int, rx_error_bad_frame_int};
    end
end

always @(posedge logic_clk or posedge logic_rst) begin
    if (logic_rst) begin
        rx_sync_reg_2 <= 5'd0;
        rx_sync_reg_3 <= 5'd0;
        rx_sync_reg_4 <= 5'd0;
    end else begin
        rx_sync_reg_2 <= rx_sync_reg_1;
        rx_sync_reg_3 <= rx_sync_reg_2;
        rx_sync_reg_4 <= rx_sync_reg_3;
    end
end

// PTP timestamping
generate

if (TX_PTP_TS_ENABLE) begin
    
    ptp_clock_cdc #(
        .TS_WIDTH(PTP_TS_WIDTH),
        .NS_WIDTH(4),
        .FNS_WIDTH(16),
        .USE_SAMPLE_CLOCK(PTP_USE_SAMPLE_CLOCK)
    )
    tx_ptp_cdc (
        .input_clk(logic_clk),
        .input_rst(logic_rst),
        .output_clk(tx_clk),
        .output_rst(tx_rst),
        .sample_clk(ptp_sample_clk),
        .input_ts(ptp_ts_96),
        .input_ts_step(ptp_ts_step),
        .output_ts(tx_ptp_ts_96),
        .output_ts_step(),
        .output_pps(),
        .locked()
    );

    axis_async_fifo #(
        .DEPTH(TX_PTP_TS_FIFO_DEPTH),
        .DATA_WIDTH(PTP_TS_WIDTH),
        .KEEP_ENABLE(0),
        .LAST_ENABLE(0),
        .ID_ENABLE(TX_PTP_TAG_ENABLE),
        .ID_WIDTH(PTP_TAG_WIDTH),
        .DEST_ENABLE(0),
        .USER_ENABLE(0),
        .FRAME_FIFO(0)
    )
    tx_ptp_ts_fifo (
        .async_rst(logic_rst | tx_rst),

        // AXI input
        .s_clk(tx_clk),
        .s_axis_tdata(tx_axis_ptp_ts_96),
        .s_axis_tkeep(0),
        .s_axis_tvalid(tx_axis_ptp_ts_valid),
        .s_axis_tready(),
        .s_axis_tlast(0),
        .s_axis_tid(tx_axis_ptp_ts_tag),
        .s_axis_tdest(0),
        .s_axis_tuser(0),

        // AXI output
        .m_clk(logic_clk),
        .m_axis_tdata(m_axis_tx_ptp_ts_96),
        .m_axis_tkeep(),
        .m_axis_tvalid(m_axis_tx_ptp_ts_valid),
        .m_axis_tready(m_axis_tx_ptp_ts_ready),
        .m_axis_tlast(),
        .m_axis_tid(m_axis_tx_ptp_ts_tag),
        .m_axis_tdest(),
        .m_axis_tuser(),

        // Status
        .s_status_overflow(),
        .s_status_bad_frame(),
        .s_status_good_frame(),
        .m_status_overflow(),
        .m_status_bad_frame(),
        .m_status_good_frame()
    );

end else begin

    assign m_axis_tx_ptp_ts_96 = {PTP_TS_WIDTH{1'b0}};
    assign m_axis_tx_ptp_ts_tag = {PTP_TAG_WIDTH{1'b0}};
    assign m_axis_tx_ptp_ts_valid = 1'b0;

    assign tx_ptp_ts_96 = {PTP_TS_WIDTH{1'b0}};

end

if (RX_PTP_TS_ENABLE) begin

    ptp_clock_cdc #(
        .TS_WIDTH(PTP_TS_WIDTH),
        .NS_WIDTH(4),
        .FNS_WIDTH(16),
        .USE_SAMPLE_CLOCK(PTP_USE_SAMPLE_CLOCK)
    )
    rx_ptp_cdc (
        .input_clk(logic_clk),
        .input_rst(logic_rst),
        .output_clk(rx_clk),
        .output_rst(rx_rst),
        .sample_clk(ptp_sample_clk),
        .input_ts(ptp_ts_96),
        .input_ts_step(ptp_ts_step),
        .output_ts(rx_ptp_ts_96),
        .output_ts_step(),
        .output_pps(),
        .locked()
    );

end else begin

    assign rx_ptp_ts_96 = {PTP_TS_WIDTH{1'b0}};

end

endgenerate

eth_mac_phy_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .TX_PTP_TS_ENABLE(TX_PTP_TS_ENABLE),
    .TX_PTP_TS_WIDTH(PTP_TS_WIDTH),
    .TX_PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .TX_PTP_TAG_WIDTH(PTP_TAG_WIDTH),
    .RX_PTP_TS_ENABLE(RX_PTP_TS_ENABLE),
    .RX_PTP_TS_WIDTH(PTP_TS_WIDTH),
    .TX_USER_WIDTH(TX_USER_WIDTH),
    .RX_USER_WIDTH(RX_USER_WIDTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .PRBS31_ENABLE(PRBS31_ENABLE),
    .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
    .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
    .COUNT_125US(COUNT_125US)
)
eth_mac_phy_10g_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),

    .tx_axis_tdata(tx_fifo_axis_tdata),
    .tx_axis_tkeep(tx_fifo_axis_tkeep),
    .tx_axis_tvalid(tx_fifo_axis_tvalid),
    .tx_axis_tready(tx_fifo_axis_tready),
    .tx_axis_tlast(tx_fifo_axis_tlast),
    .tx_axis_tuser(tx_fifo_axis_tuser),

    .rx_axis_tdata(rx_fifo_axis_tdata),
    .rx_axis_tkeep(rx_fifo_axis_tkeep),
    .rx_axis_tvalid(rx_fifo_axis_tvalid),
    .rx_axis_tlast(rx_fifo_axis_tlast),
    .rx_axis_tuser(rx_fifo_axis_tuser),

    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),

    .tx_ptp_ts(tx_ptp_ts_96),
    .rx_ptp_ts(rx_ptp_ts_96),
    .tx_axis_ptp_ts(tx_axis_ptp_ts_96),
    .tx_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .tx_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),

    .tx_error_underflow(tx_error_underflow_int),
    .rx_error_bad_frame(rx_error_bad_frame_int),
    .rx_error_bad_fcs(rx_error_bad_fcs_int),
    .rx_bad_block(rx_bad_block_int),
    .rx_block_lock(rx_block_lock_int),
    .rx_high_ber(rx_high_ber_int),

    .ifg_delay(ifg_delay),

    .tx_prbs31_enable(tx_prbs31_enable),
    .rx_prbs31_enable(rx_prbs31_enable)
);

axis_async_fifo_adapter #(
    .DEPTH(TX_FIFO_DEPTH),
    .S_DATA_WIDTH(AXIS_DATA_WIDTH),
    .S_KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .S_KEEP_WIDTH(AXIS_KEEP_WIDTH),
    .M_DATA_WIDTH(DATA_WIDTH),
    .M_KEEP_ENABLE(1),
    .M_KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(TX_USER_WIDTH),
    .PIPELINE_OUTPUT(TX_FIFO_PIPELINE_OUTPUT),
    .FRAME_FIFO(TX_FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(1'b1),
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_OVERSIZE_FRAME(TX_DROP_OVERSIZE_FRAME),
    .DROP_BAD_FRAME(TX_DROP_BAD_FRAME),
    .DROP_WHEN_FULL(TX_DROP_WHEN_FULL)
)
tx_fifo (
    // AXI input
    .s_clk(logic_clk),
    .s_rst(logic_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(tx_axis_tuser),
    // AXI output
    .m_clk(tx_clk),
    .m_rst(tx_rst),
    .m_axis_tdata(tx_fifo_axis_tdata),
    .m_axis_tkeep(tx_fifo_axis_tkeep),
    .m_axis_tvalid(tx_fifo_axis_tvalid),
    .m_axis_tready(tx_fifo_axis_tready),
    .m_axis_tlast(tx_fifo_axis_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(tx_fifo_axis_tuser),
    // Status
    .s_status_overflow(tx_fifo_overflow),
    .s_status_bad_frame(tx_fifo_bad_frame),
    .s_status_good_frame(tx_fifo_good_frame),
    .m_status_overflow(),
    .m_status_bad_frame(),
    .m_status_good_frame()
);

axis_async_fifo_adapter #(
    .DEPTH(RX_FIFO_DEPTH),
    .S_DATA_WIDTH(DATA_WIDTH),
    .S_KEEP_ENABLE(1),
    .S_KEEP_WIDTH(KEEP_WIDTH),
    .M_DATA_WIDTH(AXIS_DATA_WIDTH),
    .M_KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .M_KEEP_WIDTH(AXIS_KEEP_WIDTH),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(RX_USER_WIDTH),
    .PIPELINE_OUTPUT(RX_FIFO_PIPELINE_OUTPUT),
    .FRAME_FIFO(RX_FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(1'b1),
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_OVERSIZE_FRAME(RX_DROP_OVERSIZE_FRAME),
    .DROP_BAD_FRAME(RX_DROP_BAD_FRAME),
    .DROP_WHEN_FULL(RX_DROP_WHEN_FULL)
)
rx_fifo (
    // AXI input
    .s_clk(rx_clk),
    .s_rst(rx_rst),
    .s_axis_tdata(rx_fifo_axis_tdata),
    .s_axis_tkeep(rx_fifo_axis_tkeep),
    .s_axis_tvalid(rx_fifo_axis_tvalid),
    .s_axis_tready(),
    .s_axis_tlast(rx_fifo_axis_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(rx_fifo_axis_tuser),
    // AXI output
    .m_clk(logic_clk),
    .m_rst(logic_rst),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tready(rx_axis_tready),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(rx_axis_tuser),
    // Status
    .s_status_overflow(),
    .s_status_bad_frame(),
    .s_status_good_frame(),
    .m_status_overflow(rx_fifo_overflow),
    .m_status_bad_frame(rx_fifo_bad_frame),
    .m_status_good_frame(rx_fifo_good_frame)
);

endmodule

`resetall
