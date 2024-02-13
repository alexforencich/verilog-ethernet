/*

Copyright (c) 2015-2023 Alex Forencich

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
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_FMT_TOD = 1,
    parameter PTP_TS_WIDTH = PTP_TS_FMT_TOD ? 96 : 64,
    parameter TX_PTP_TS_CTRL_IN_TUSER = 0,
    parameter TX_PTP_TAG_ENABLE = PTP_TS_ENABLE,
    parameter TX_PTP_TAG_WIDTH = 16,
    parameter TX_USER_WIDTH = (PTP_TS_ENABLE ? (TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + (TX_PTP_TS_CTRL_IN_TUSER ? 1 : 0) : 0) + 1,
    parameter RX_USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1,
    parameter PFC_ENABLE = 0,
    parameter PAUSE_ENABLE = PFC_ENABLE
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
    input  wire [PTP_TS_WIDTH-1:0]      tx_ptp_ts,
    input  wire [PTP_TS_WIDTH-1:0]      rx_ptp_ts,
    output wire [PTP_TS_WIDTH-1:0]      tx_axis_ptp_ts,
    output wire [TX_PTP_TAG_WIDTH-1:0]  tx_axis_ptp_ts_tag,
    output wire                         tx_axis_ptp_ts_valid,

    /*
     * Link-level Flow Control (LFC) (IEEE 802.3 annex 31B PAUSE)
     */
    input  wire                         tx_lfc_req,
    input  wire                         tx_lfc_resend,
    input  wire                         rx_lfc_en,
    output wire                         rx_lfc_req,
    input  wire                         rx_lfc_ack,

    /*
     * Priority Flow Control (PFC) (IEEE 802.3 annex 31D PFC)
     */
    input  wire [7:0]                   tx_pfc_req,
    input  wire                         tx_pfc_resend,
    input  wire [7:0]                   rx_pfc_en,
    output wire [7:0]                   rx_pfc_req,
    input  wire [7:0]                   rx_pfc_ack,

    /*
     * Pause interface
     */
    input  wire                         tx_lfc_pause_en,
    input  wire                         tx_pause_req,
    output wire                         tx_pause_ack,

    /*
     * Status
     */
    output wire [1:0]                   tx_start_packet,
    output wire                         tx_error_underflow,
    output wire [1:0]                   rx_start_packet,
    output wire                         rx_error_bad_frame,
    output wire                         rx_error_bad_fcs,
    output wire                         stat_tx_mcf,
    output wire                         stat_rx_mcf,
    output wire                         stat_tx_lfc_pkt,
    output wire                         stat_tx_lfc_xon,
    output wire                         stat_tx_lfc_xoff,
    output wire                         stat_tx_lfc_paused,
    output wire                         stat_tx_pfc_pkt,
    output wire [7:0]                   stat_tx_pfc_xon,
    output wire [7:0]                   stat_tx_pfc_xoff,
    output wire [7:0]                   stat_tx_pfc_paused,
    output wire                         stat_rx_lfc_pkt,
    output wire                         stat_rx_lfc_xon,
    output wire                         stat_rx_lfc_xoff,
    output wire                         stat_rx_lfc_paused,
    output wire                         stat_rx_pfc_pkt,
    output wire [7:0]                   stat_rx_pfc_xon,
    output wire [7:0]                   stat_rx_pfc_xoff,
    output wire [7:0]                   stat_rx_pfc_paused,

    /*
     * Configuration
     */
    input  wire [7:0]                   cfg_ifg,
    input  wire                         cfg_tx_enable,
    input  wire                         cfg_rx_enable,
    input  wire [47:0]                  cfg_mcf_rx_eth_dst_mcast,
    input  wire                         cfg_mcf_rx_check_eth_dst_mcast,
    input  wire [47:0]                  cfg_mcf_rx_eth_dst_ucast,
    input  wire                         cfg_mcf_rx_check_eth_dst_ucast,
    input  wire [47:0]                  cfg_mcf_rx_eth_src,
    input  wire                         cfg_mcf_rx_check_eth_src,
    input  wire [15:0]                  cfg_mcf_rx_eth_type,
    input  wire [15:0]                  cfg_mcf_rx_opcode_lfc,
    input  wire                         cfg_mcf_rx_check_opcode_lfc,
    input  wire [15:0]                  cfg_mcf_rx_opcode_pfc,
    input  wire                         cfg_mcf_rx_check_opcode_pfc,
    input  wire                         cfg_mcf_rx_forward,
    input  wire                         cfg_mcf_rx_enable,
    input  wire [47:0]                  cfg_tx_lfc_eth_dst,
    input  wire [47:0]                  cfg_tx_lfc_eth_src,
    input  wire [15:0]                  cfg_tx_lfc_eth_type,
    input  wire [15:0]                  cfg_tx_lfc_opcode,
    input  wire                         cfg_tx_lfc_en,
    input  wire [15:0]                  cfg_tx_lfc_quanta,
    input  wire [15:0]                  cfg_tx_lfc_refresh,
    input  wire [47:0]                  cfg_tx_pfc_eth_dst,
    input  wire [47:0]                  cfg_tx_pfc_eth_src,
    input  wire [15:0]                  cfg_tx_pfc_eth_type,
    input  wire [15:0]                  cfg_tx_pfc_opcode,
    input  wire                         cfg_tx_pfc_en,
    input  wire [8*16-1:0]              cfg_tx_pfc_quanta,
    input  wire [8*16-1:0]              cfg_tx_pfc_refresh,
    input  wire [15:0]                  cfg_rx_lfc_opcode,
    input  wire                         cfg_rx_lfc_en,
    input  wire [15:0]                  cfg_rx_pfc_opcode,
    input  wire                         cfg_rx_pfc_en
);

parameter MAC_CTRL_ENABLE = PAUSE_ENABLE || PFC_ENABLE;
parameter TX_USER_WIDTH_INT = MAC_CTRL_ENABLE ? (PTP_TS_ENABLE ? (TX_PTP_TAG_ENABLE ? TX_PTP_TAG_WIDTH : 0) + 1 : 0) + 1 : TX_USER_WIDTH;

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

wire [DATA_WIDTH-1:0]         tx_axis_tdata_int;
wire [KEEP_WIDTH-1:0]         tx_axis_tkeep_int;
wire                          tx_axis_tvalid_int;
wire                          tx_axis_tready_int;
wire                          tx_axis_tlast_int;
wire [TX_USER_WIDTH_INT-1:0]  tx_axis_tuser_int;

wire [DATA_WIDTH-1:0]     rx_axis_tdata_int;
wire [KEEP_WIDTH-1:0]     rx_axis_tkeep_int;
wire                      rx_axis_tvalid_int;
wire                      rx_axis_tlast_int;
wire [RX_USER_WIDTH-1:0]  rx_axis_tuser_int;

generate

if (DATA_WIDTH == 64) begin

axis_xgmii_rx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_FMT_TOD(PTP_TS_FMT_TOD),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .USER_WIDTH(RX_USER_WIDTH)
)
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata_int),
    .m_axis_tkeep(rx_axis_tkeep_int),
    .m_axis_tvalid(rx_axis_tvalid_int),
    .m_axis_tlast(rx_axis_tlast_int),
    .m_axis_tuser(rx_axis_tuser_int),
    .ptp_ts(rx_ptp_ts),
    .cfg_rx_enable(cfg_rx_enable),
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
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_FMT_TOD(PTP_TS_FMT_TOD),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .PTP_TS_CTRL_IN_TUSER(MAC_CTRL_ENABLE ? PTP_TS_ENABLE : TX_PTP_TS_CTRL_IN_TUSER),
    .PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .USER_WIDTH(TX_USER_WIDTH_INT)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata_int),
    .s_axis_tkeep(tx_axis_tkeep_int),
    .s_axis_tvalid(tx_axis_tvalid_int),
    .s_axis_tready(tx_axis_tready_int),
    .s_axis_tlast(tx_axis_tlast_int),
    .s_axis_tuser(tx_axis_tuser_int),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ptp_ts(tx_ptp_ts),
    .m_axis_ptp_ts(tx_axis_ptp_ts),
    .m_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .cfg_ifg(cfg_ifg),
    .cfg_tx_enable(cfg_tx_enable),
    .start_packet(tx_start_packet),
    .error_underflow(tx_error_underflow)
);

end else begin

axis_xgmii_rx_32 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .USER_WIDTH(RX_USER_WIDTH)
)
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata_int),
    .m_axis_tkeep(rx_axis_tkeep_int),
    .m_axis_tvalid(rx_axis_tvalid_int),
    .m_axis_tlast(rx_axis_tlast_int),
    .m_axis_tuser(rx_axis_tuser_int),
    .ptp_ts(rx_ptp_ts),
    .cfg_rx_enable(cfg_rx_enable),
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
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .PTP_TS_CTRL_IN_TUSER(MAC_CTRL_ENABLE ? PTP_TS_ENABLE : TX_PTP_TS_CTRL_IN_TUSER),
    .PTP_TAG_ENABLE(TX_PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(TX_PTP_TAG_WIDTH),
    .USER_WIDTH(TX_USER_WIDTH_INT)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata_int),
    .s_axis_tkeep(tx_axis_tkeep_int),
    .s_axis_tvalid(tx_axis_tvalid_int),
    .s_axis_tready(tx_axis_tready_int),
    .s_axis_tlast(tx_axis_tlast_int),
    .s_axis_tuser(tx_axis_tuser_int),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ptp_ts(tx_ptp_ts),
    .m_axis_ptp_ts(tx_axis_ptp_ts),
    .m_axis_ptp_ts_tag(tx_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(tx_axis_ptp_ts_valid),
    .cfg_ifg(cfg_ifg),
    .cfg_tx_enable(cfg_tx_enable),
    .start_packet(tx_start_packet[0]),
    .error_underflow(tx_error_underflow)
);

assign tx_start_packet[1] = 1'b0;

end

if (MAC_CTRL_ENABLE) begin : mac_ctrl

    localparam MCF_PARAMS_SIZE = PFC_ENABLE ? 18 : 2;

    wire                          tx_mcf_valid;
    wire                          tx_mcf_ready;
    wire [47:0]                   tx_mcf_eth_dst;
    wire [47:0]                   tx_mcf_eth_src;
    wire [15:0]                   tx_mcf_eth_type;
    wire [15:0]                   tx_mcf_opcode;
    wire [MCF_PARAMS_SIZE*8-1:0]  tx_mcf_params;

    wire                          rx_mcf_valid;
    wire [47:0]                   rx_mcf_eth_dst;
    wire [47:0]                   rx_mcf_eth_src;
    wire [15:0]                   rx_mcf_eth_type;
    wire [15:0]                   rx_mcf_opcode;
    wire [MCF_PARAMS_SIZE*8-1:0]  rx_mcf_params;

    // terminate LFC pause requests from RX internally on TX side
    wire                          tx_pause_req_int;
    wire                          rx_lfc_ack_int;

    reg tx_lfc_req_sync_reg_1 = 1'b0;
    reg tx_lfc_req_sync_reg_2 = 1'b0;
    reg tx_lfc_req_sync_reg_3 = 1'b0;

    always @(posedge rx_clk or posedge rx_rst) begin
        if (rx_rst) begin
            tx_lfc_req_sync_reg_1 <= 1'b0;
        end else begin
            tx_lfc_req_sync_reg_1 <= rx_lfc_req;
        end
    end

    always @(posedge tx_clk or posedge tx_rst) begin
        if (tx_rst) begin
            tx_lfc_req_sync_reg_2 <= 1'b0;
            tx_lfc_req_sync_reg_3 <= 1'b0;
        end else begin
            tx_lfc_req_sync_reg_2 <= tx_lfc_req_sync_reg_1;
            tx_lfc_req_sync_reg_3 <= tx_lfc_req_sync_reg_2;
        end
    end

    reg rx_lfc_ack_sync_reg_1 = 1'b0;
    reg rx_lfc_ack_sync_reg_2 = 1'b0;
    reg rx_lfc_ack_sync_reg_3 = 1'b0;

    always @(posedge tx_clk or posedge tx_rst) begin
        if (tx_rst) begin
            rx_lfc_ack_sync_reg_1 <= 1'b0;
        end else begin
            rx_lfc_ack_sync_reg_1 <= tx_lfc_pause_en ? tx_pause_ack : 0;
        end
    end

    always @(posedge rx_clk or posedge rx_rst) begin
        if (rx_rst) begin
            rx_lfc_ack_sync_reg_2 <= 1'b0;
            rx_lfc_ack_sync_reg_3 <= 1'b0;
        end else begin
            rx_lfc_ack_sync_reg_2 <= rx_lfc_ack_sync_reg_1;
            rx_lfc_ack_sync_reg_3 <= rx_lfc_ack_sync_reg_2;
        end
    end

    assign tx_pause_req_int = tx_pause_req || (tx_lfc_pause_en ? tx_lfc_req_sync_reg_3 : 0);

    assign rx_lfc_ack_int = rx_lfc_ack || rx_lfc_ack_sync_reg_3;

    // handle PTP TS enable bit in tuser
    wire [TX_USER_WIDTH_INT-1:0] tx_axis_tuser_in;

    if (PTP_TS_ENABLE && !TX_PTP_TS_CTRL_IN_TUSER) begin
        assign tx_axis_tuser_in = {tx_axis_tuser[TX_USER_WIDTH-1:1], 1'b1, tx_axis_tuser[0]};
    end else begin
        assign tx_axis_tuser_in = tx_axis_tuser;
    end

    mac_ctrl_tx #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(1),
        .KEEP_WIDTH(KEEP_WIDTH),
        .ID_ENABLE(0),
        .DEST_ENABLE(0),
        .USER_ENABLE(1),
        .USER_WIDTH(TX_USER_WIDTH_INT),
        .MCF_PARAMS_SIZE(MCF_PARAMS_SIZE)
    )
    mac_ctrl_tx_inst (
        .clk(tx_clk),
        .rst(tx_rst),

        /*
         * AXI stream input
         */
        .s_axis_tdata(tx_axis_tdata),
        .s_axis_tkeep(tx_axis_tkeep),
        .s_axis_tvalid(tx_axis_tvalid),
        .s_axis_tready(tx_axis_tready),
        .s_axis_tlast(tx_axis_tlast),
        .s_axis_tid(0),
        .s_axis_tdest(0),
        .s_axis_tuser(tx_axis_tuser_in),

        /*
         * AXI stream output
         */
        .m_axis_tdata(tx_axis_tdata_int),
        .m_axis_tkeep(tx_axis_tkeep_int),
        .m_axis_tvalid(tx_axis_tvalid_int),
        .m_axis_tready(tx_axis_tready_int),
        .m_axis_tlast(tx_axis_tlast_int),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser(tx_axis_tuser_int),

        /*
         * MAC control frame interface
         */
        .mcf_valid(tx_mcf_valid),
        .mcf_ready(tx_mcf_ready),
        .mcf_eth_dst(tx_mcf_eth_dst),
        .mcf_eth_src(tx_mcf_eth_src),
        .mcf_eth_type(tx_mcf_eth_type),
        .mcf_opcode(tx_mcf_opcode),
        .mcf_params(tx_mcf_params),
        .mcf_id(0),
        .mcf_dest(0),
        .mcf_user(0),

        /*
         * Pause interface
         */
        .tx_pause_req(tx_pause_req_int),
        .tx_pause_ack(tx_pause_ack),

        /*
         * Status
         */
        .stat_tx_mcf(stat_tx_mcf)
    );

    mac_ctrl_rx #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(1),
        .KEEP_WIDTH(KEEP_WIDTH),
        .ID_ENABLE(0),
        .DEST_ENABLE(0),
        .USER_ENABLE(1),
        .USER_WIDTH(RX_USER_WIDTH),
        .USE_READY(0),
        .MCF_PARAMS_SIZE(MCF_PARAMS_SIZE)
    )
    mac_ctrl_rx_inst (
        .clk(rx_clk),
        .rst(rx_rst),

        /*
         * AXI stream input
         */
        .s_axis_tdata(rx_axis_tdata_int),
        .s_axis_tkeep(rx_axis_tkeep_int),
        .s_axis_tvalid(rx_axis_tvalid_int),
        .s_axis_tready(),
        .s_axis_tlast(rx_axis_tlast_int),
        .s_axis_tid(0),
        .s_axis_tdest(0),
        .s_axis_tuser(rx_axis_tuser_int),

        /*
         * AXI stream output
         */
        .m_axis_tdata(rx_axis_tdata),
        .m_axis_tkeep(rx_axis_tkeep),
        .m_axis_tvalid(rx_axis_tvalid),
        .m_axis_tready(1'b1),
        .m_axis_tlast(rx_axis_tlast),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser(rx_axis_tuser),

        /*
         * MAC control frame interface
         */
        .mcf_valid(rx_mcf_valid),
        .mcf_eth_dst(rx_mcf_eth_dst),
        .mcf_eth_src(rx_mcf_eth_src),
        .mcf_eth_type(rx_mcf_eth_type),
        .mcf_opcode(rx_mcf_opcode),
        .mcf_params(rx_mcf_params),
        .mcf_id(),
        .mcf_dest(),
        .mcf_user(),

        /*
         * Configuration
         */
        .cfg_mcf_rx_eth_dst_mcast(cfg_mcf_rx_eth_dst_mcast),
        .cfg_mcf_rx_check_eth_dst_mcast(cfg_mcf_rx_check_eth_dst_mcast),
        .cfg_mcf_rx_eth_dst_ucast(cfg_mcf_rx_eth_dst_ucast),
        .cfg_mcf_rx_check_eth_dst_ucast(cfg_mcf_rx_check_eth_dst_ucast),
        .cfg_mcf_rx_eth_src(cfg_mcf_rx_eth_src),
        .cfg_mcf_rx_check_eth_src(cfg_mcf_rx_check_eth_src),
        .cfg_mcf_rx_eth_type(cfg_mcf_rx_eth_type),
        .cfg_mcf_rx_opcode_lfc(cfg_mcf_rx_opcode_lfc),
        .cfg_mcf_rx_check_opcode_lfc(cfg_mcf_rx_check_opcode_lfc),
        .cfg_mcf_rx_opcode_pfc(cfg_mcf_rx_opcode_pfc),
        .cfg_mcf_rx_check_opcode_pfc(cfg_mcf_rx_check_opcode_pfc && PFC_ENABLE),
        .cfg_mcf_rx_forward(cfg_mcf_rx_forward),
        .cfg_mcf_rx_enable(cfg_mcf_rx_enable),

        /*
         * Status
         */
        .stat_rx_mcf(stat_rx_mcf)
    );

    mac_pause_ctrl_tx #(
        .MCF_PARAMS_SIZE(MCF_PARAMS_SIZE),
        .PFC_ENABLE(PFC_ENABLE)
    )
    mac_pause_ctrl_tx_inst (
        .clk(tx_clk),
        .rst(tx_rst),

        /*
         * MAC control frame interface
         */
        .mcf_valid(tx_mcf_valid),
        .mcf_ready(tx_mcf_ready),
        .mcf_eth_dst(tx_mcf_eth_dst),
        .mcf_eth_src(tx_mcf_eth_src),
        .mcf_eth_type(tx_mcf_eth_type),
        .mcf_opcode(tx_mcf_opcode),
        .mcf_params(tx_mcf_params),

        /*
         * Pause (IEEE 802.3 annex 31B)
         */
        .tx_lfc_req(tx_lfc_req),
        .tx_lfc_resend(tx_lfc_resend),

        /*
         * Priority Flow Control (PFC) (IEEE 802.3 annex 31D)
         */
        .tx_pfc_req(tx_pfc_req),
        .tx_pfc_resend(tx_pfc_resend),

        /*
         * Configuration
         */
        .cfg_tx_lfc_eth_dst(cfg_tx_lfc_eth_dst),
        .cfg_tx_lfc_eth_src(cfg_tx_lfc_eth_src),
        .cfg_tx_lfc_eth_type(cfg_tx_lfc_eth_type),
        .cfg_tx_lfc_opcode(cfg_tx_lfc_opcode),
        .cfg_tx_lfc_en(cfg_tx_lfc_en),
        .cfg_tx_lfc_quanta(cfg_tx_lfc_quanta),
        .cfg_tx_lfc_refresh(cfg_tx_lfc_refresh),
        .cfg_tx_pfc_eth_dst(cfg_tx_pfc_eth_dst),
        .cfg_tx_pfc_eth_src(cfg_tx_pfc_eth_src),
        .cfg_tx_pfc_eth_type(cfg_tx_pfc_eth_type),
        .cfg_tx_pfc_opcode(cfg_tx_pfc_opcode),
        .cfg_tx_pfc_en(cfg_tx_pfc_en),
        .cfg_tx_pfc_quanta(cfg_tx_pfc_quanta),
        .cfg_tx_pfc_refresh(cfg_tx_pfc_refresh),
        .cfg_quanta_step((DATA_WIDTH*256)/512),
        .cfg_quanta_clk_en(1'b1),

        /*
         * Status
         */
        .stat_tx_lfc_pkt(stat_tx_lfc_pkt),
        .stat_tx_lfc_xon(stat_tx_lfc_xon),
        .stat_tx_lfc_xoff(stat_tx_lfc_xoff),
        .stat_tx_lfc_paused(stat_tx_lfc_paused),
        .stat_tx_pfc_pkt(stat_tx_pfc_pkt),
        .stat_tx_pfc_xon(stat_tx_pfc_xon),
        .stat_tx_pfc_xoff(stat_tx_pfc_xoff),
        .stat_tx_pfc_paused(stat_tx_pfc_paused)
    );

    mac_pause_ctrl_rx #(
        .MCF_PARAMS_SIZE(18),
        .PFC_ENABLE(PFC_ENABLE)
    )
    mac_pause_ctrl_rx_inst (
        .clk(rx_clk),
        .rst(rx_rst),

        /*
         * MAC control frame interface
         */
        .mcf_valid(rx_mcf_valid),
        .mcf_eth_dst(rx_mcf_eth_dst),
        .mcf_eth_src(rx_mcf_eth_src),
        .mcf_eth_type(rx_mcf_eth_type),
        .mcf_opcode(rx_mcf_opcode),
        .mcf_params(rx_mcf_params),

        /*
         * Pause (IEEE 802.3 annex 31B)
         */
        .rx_lfc_en(rx_lfc_en),
        .rx_lfc_req(rx_lfc_req),
        .rx_lfc_ack(rx_lfc_ack_int),

        /*
         * Priority Flow Control (PFC) (IEEE 802.3 annex 31D)
         */
        .rx_pfc_en(rx_pfc_en),
        .rx_pfc_req(rx_pfc_req),
        .rx_pfc_ack(rx_pfc_ack),

        /*
         * Configuration
         */
        .cfg_rx_lfc_opcode(cfg_rx_lfc_opcode),
        .cfg_rx_lfc_en(cfg_rx_lfc_en),
        .cfg_rx_pfc_opcode(cfg_rx_pfc_opcode),
        .cfg_rx_pfc_en(cfg_rx_pfc_en),
        .cfg_quanta_step((DATA_WIDTH*256)/512),
        .cfg_quanta_clk_en(1'b1),

        /*
         * Status
         */
        .stat_rx_lfc_pkt(stat_rx_lfc_pkt),
        .stat_rx_lfc_xon(stat_rx_lfc_xon),
        .stat_rx_lfc_xoff(stat_rx_lfc_xoff),
        .stat_rx_lfc_paused(stat_rx_lfc_paused),
        .stat_rx_pfc_pkt(stat_rx_pfc_pkt),
        .stat_rx_pfc_xon(stat_rx_pfc_xon),
        .stat_rx_pfc_xoff(stat_rx_pfc_xoff),
        .stat_rx_pfc_paused(stat_rx_pfc_paused)
    );

end else begin

    assign tx_axis_tdata_int = tx_axis_tdata;
    assign tx_axis_tkeep_int = tx_axis_tkeep;
    assign tx_axis_tvalid_int = tx_axis_tvalid;
    assign tx_axis_tready = tx_axis_tready_int;
    assign tx_axis_tlast_int = tx_axis_tlast;
    assign tx_axis_tuser_int = tx_axis_tuser;

    assign rx_axis_tdata = rx_axis_tdata_int;
    assign rx_axis_tkeep = rx_axis_tkeep_int;
    assign rx_axis_tvalid = rx_axis_tvalid_int;
    assign rx_axis_tlast = rx_axis_tlast_int;
    assign rx_axis_tuser = rx_axis_tuser_int;

    assign rx_lfc_req = 0;
    assign rx_pfc_req = 0;
    assign tx_pause_ack = 0;

    assign stat_tx_mcf = 0;
    assign stat_rx_mcf = 0;
    assign stat_tx_lfc_pkt = 0;
    assign stat_tx_lfc_xon = 0;
    assign stat_tx_lfc_xoff = 0;
    assign stat_tx_lfc_paused = 0;
    assign stat_tx_pfc_pkt = 0;
    assign stat_tx_pfc_xon = 0;
    assign stat_tx_pfc_xoff = 0;
    assign stat_tx_pfc_paused = 0;
    assign stat_rx_lfc_pkt = 0;
    assign stat_rx_lfc_xon = 0;
    assign stat_rx_lfc_xoff = 0;
    assign stat_rx_lfc_paused = 0;
    assign stat_rx_pfc_pkt = 0;
    assign stat_rx_pfc_xon = 0;
    assign stat_rx_pfc_xoff = 0;
    assign stat_rx_pfc_paused = 0;

end

endgenerate

endmodule

`resetall
