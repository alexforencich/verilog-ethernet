/*

Copyright (c) 2016-2018 Alex Forencich

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
`timescale 1 ns / 1 ps
`default_nettype none

module fpga_core
(
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    input  wire clk,
    input  wire rst,
    /*
     * GPIO
     */
    input  wire [1:0] sw,
    input  wire [3:0] jp,
    output wire [3:0] led,
    /*
     * Silicon Labs CP2102 USB UART
     */
    output wire uart_rst,
    input  wire uart_suspend,
    output wire uart_ri,
    output wire uart_dcd,
    input  wire uart_dtr,
    output wire uart_dsr,
    input  wire uart_txd,
    output wire uart_rxd,
    input  wire uart_rts,
    output wire uart_cts,
    /*
     * AirMax I/O
     */
    output wire amh_right_mdc,
    input  wire amh_right_mdio_i,
    output wire amh_right_mdio_o,
    output wire amh_right_mdio_t,
    output wire amh_left_mdc,
    input  wire amh_left_mdio_i,
    output wire amh_left_mdio_o,
    output wire amh_left_mdio_t,
    /*
     * 10G Ethernet
     */
    output wire [63:0] eth_r0_txd,
    output wire [7:0]  eth_r0_txc,
    input  wire [63:0] eth_r0_rxd,
    input  wire [7:0]  eth_r0_rxc,
    output wire [63:0] eth_r1_txd,
    output wire [7:0]  eth_r1_txc,
    input  wire [63:0] eth_r1_rxd,
    input  wire [7:0]  eth_r1_rxc,
    output wire [63:0] eth_r2_txd,
    output wire [7:0]  eth_r2_txc,
    input  wire [63:0] eth_r2_rxd,
    input  wire [7:0]  eth_r2_rxc,
    output wire [63:0] eth_r3_txd,
    output wire [7:0]  eth_r3_txc,
    input  wire [63:0] eth_r3_rxd,
    input  wire [7:0]  eth_r3_rxc,
    output wire [63:0] eth_r4_txd,
    output wire [7:0]  eth_r4_txc,
    input  wire [63:0] eth_r4_rxd,
    input  wire [7:0]  eth_r4_rxc,
    output wire [63:0] eth_r5_txd,
    output wire [7:0]  eth_r5_txc,
    input  wire [63:0] eth_r5_rxd,
    input  wire [7:0]  eth_r5_rxc,
    output wire [63:0] eth_r6_txd,
    output wire [7:0]  eth_r6_txc,
    input  wire [63:0] eth_r6_rxd,
    input  wire [7:0]  eth_r6_rxc,
    output wire [63:0] eth_r7_txd,
    output wire [7:0]  eth_r7_txc,
    input  wire [63:0] eth_r7_rxd,
    input  wire [7:0]  eth_r7_rxc,
    output wire [63:0] eth_r8_txd,
    output wire [7:0]  eth_r8_txc,
    input  wire [63:0] eth_r8_rxd,
    input  wire [7:0]  eth_r8_rxc,
    output wire [63:0] eth_r9_txd,
    output wire [7:0]  eth_r9_txc,
    input  wire [63:0] eth_r9_rxd,
    input  wire [7:0]  eth_r9_rxc,
    output wire [63:0] eth_r10_txd,
    output wire [7:0]  eth_r10_txc,
    input  wire [63:0] eth_r10_rxd,
    input  wire [7:0]  eth_r10_rxc,
    output wire [63:0] eth_r11_txd,
    output wire [7:0]  eth_r11_txc,
    input  wire [63:0] eth_r11_rxd,
    input  wire [7:0]  eth_r11_rxc,
    output wire [63:0] eth_l0_txd,
    output wire [7:0]  eth_l0_txc,
    input  wire [63:0] eth_l0_rxd,
    input  wire [7:0]  eth_l0_rxc,
    output wire [63:0] eth_l1_txd,
    output wire [7:0]  eth_l1_txc,
    input  wire [63:0] eth_l1_rxd,
    input  wire [7:0]  eth_l1_rxc,
    output wire [63:0] eth_l2_txd,
    output wire [7:0]  eth_l2_txc,
    input  wire [63:0] eth_l2_rxd,
    input  wire [7:0]  eth_l2_rxc,
    output wire [63:0] eth_l3_txd,
    output wire [7:0]  eth_l3_txc,
    input  wire [63:0] eth_l3_rxd,
    input  wire [7:0]  eth_l3_rxc,
    output wire [63:0] eth_l4_txd,
    output wire [7:0]  eth_l4_txc,
    input  wire [63:0] eth_l4_rxd,
    input  wire [7:0]  eth_l4_rxc,
    output wire [63:0] eth_l5_txd,
    output wire [7:0]  eth_l5_txc,
    input  wire [63:0] eth_l5_rxd,
    input  wire [7:0]  eth_l5_rxc,
    output wire [63:0] eth_l6_txd,
    output wire [7:0]  eth_l6_txc,
    input  wire [63:0] eth_l6_rxd,
    input  wire [7:0]  eth_l6_rxc,
    output wire [63:0] eth_l7_txd,
    output wire [7:0]  eth_l7_txc,
    input  wire [63:0] eth_l7_rxd,
    input  wire [7:0]  eth_l7_rxc,
    output wire [63:0] eth_l8_txd,
    output wire [7:0]  eth_l8_txc,
    input  wire [63:0] eth_l8_rxd,
    input  wire [7:0]  eth_l8_rxc,
    output wire [63:0] eth_l9_txd,
    output wire [7:0]  eth_l9_txc,
    input  wire [63:0] eth_l9_rxd,
    input  wire [7:0]  eth_l9_rxc,
    output wire [63:0] eth_l10_txd,
    output wire [7:0]  eth_l10_txc,
    input  wire [63:0] eth_l10_rxd,
    input  wire [7:0]  eth_l10_rxc,
    output wire [63:0] eth_l11_txd,
    output wire [7:0]  eth_l11_txc,
    input  wire [63:0] eth_l11_rxd,
    input  wire [7:0]  eth_l11_rxc
);

// UART
assign uart_rst = 1'b1;
assign uart_txd = 1'b1;

// AirMax I/O
assign amh_right_mdc = 1'b1;
assign amh_right_mdio_o = 1'b1;
assign amh_right_mdio_t = 1'b1;
assign amh_left_mdc = 1'b1;
assign amh_left_mdio_o = 1'b1;
assign amh_left_mdio_t = 1'b1;

assign eth_l8_txd = 64'h0707070707070707;
assign eth_l8_txc = 8'hff;
assign eth_l9_txd = 64'h0707070707070707;
assign eth_l9_txc = 8'hff;
assign eth_l10_txd = 64'h0707070707070707;
assign eth_l10_txc = 8'hff;
//assign eth_l11_txd = 64'h0707070707070707;
//assign eth_l11_txc = 8'hff;

assign eth_r8_txd = 64'h0707070707070707;
assign eth_r8_txc = 8'hff;
assign eth_r9_txd = 64'h0707070707070707;
assign eth_r9_txc = 8'hff;
assign eth_r10_txd = 64'h0707070707070707;
assign eth_r10_txc = 8'hff;
assign eth_r11_txd = 64'h0707070707070707;
assign eth_r11_txc = 8'hff;

reg [7:0] select_reg_0 = 0;
reg [7:0] select_reg_1 = 1;
reg [7:0] select_reg_2 = 2;
reg [7:0] select_reg_3 = 3;
reg [7:0] select_reg_4 = 4;
reg [7:0] select_reg_5 = 5;
reg [7:0] select_reg_6 = 6;
reg [7:0] select_reg_7 = 7;
reg [7:0] select_reg_8 = 8;
reg [7:0] select_reg_9 = 9;
reg [7:0] select_reg_10 = 10;
reg [7:0] select_reg_11 = 11;
reg [7:0] select_reg_12 = 12;
reg [7:0] select_reg_13 = 13;
reg [7:0] select_reg_14 = 14;
reg [7:0] select_reg_15 = 15;


axis_crosspoint #(
    .S_COUNT(16),
    .M_COUNT(16),
    .DATA_WIDTH(64),
    .KEEP_ENABLE(1),
    .KEEP_WIDTH(8),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0)
)
axis_crosspoint_inst (
    .clk(clk),
    .rst(rst),

    .s_axis_tdata({eth_r7_rxd, eth_r6_rxd, eth_r5_rxd, eth_r4_rxd, eth_r3_rxd, eth_r2_rxd, eth_r1_rxd, eth_r0_rxd, eth_l7_rxd, eth_l6_rxd, eth_l5_rxd, eth_l4_rxd, eth_l3_rxd, eth_l2_rxd, eth_l1_rxd, eth_l0_rxd}),
    .s_axis_tkeep({eth_r7_rxc, eth_r6_rxc, eth_r5_rxc, eth_r4_rxc, eth_r3_rxc, eth_r2_rxc, eth_r1_rxc, eth_r0_rxc, eth_l7_rxc, eth_l6_rxc, eth_l5_rxc, eth_l4_rxc, eth_l3_rxc, eth_l2_rxc, eth_l1_rxc, eth_l0_rxc}),
    .s_axis_tvalid(16'hffff),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0),

    .m_axis_tdata({eth_r7_txd, eth_r6_txd, eth_r5_txd, eth_r4_txd, eth_r3_txd, eth_r2_txd, eth_r1_txd, eth_r0_txd, eth_l7_txd, eth_l6_txd, eth_l5_txd, eth_l4_txd, eth_l3_txd, eth_l2_txd, eth_l1_txd, eth_l0_txd}),
    .m_axis_tkeep({eth_r7_txc, eth_r6_txc, eth_r5_txc, eth_r4_txc, eth_r3_txc, eth_r2_txc, eth_r1_txc, eth_r0_txc, eth_l7_txc, eth_l6_txc, eth_l5_txc, eth_l4_txc, eth_l3_txc, eth_l2_txc, eth_l1_txc, eth_l0_txc}),
    .m_axis_tvalid(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),

    .select({select_reg_15[3:0], select_reg_14[3:0], select_reg_13[3:0], select_reg_12[3:0], select_reg_11[3:0], select_reg_10[3:0], select_reg_9[3:0], select_reg_8[3:0], select_reg_7[3:0], select_reg_6[3:0], select_reg_5[3:0], select_reg_4[3:0], select_reg_3[3:0], select_reg_2[3:0], select_reg_1[3:0], select_reg_0[3:0]})
);

wire [63:0] eth_rx_axis_tdata;
wire [7:0] eth_rx_axis_tkeep;
wire eth_rx_axis_tvalid;
wire eth_rx_axis_tready;
wire eth_rx_axis_tlast;
wire eth_rx_axis_tuser;

wire eth_rx_hdr_valid;
wire eth_rx_hdr_ready;
wire [47:0] eth_rx_dest_mac;
wire [47:0] eth_rx_src_mac;
wire [15:0] eth_rx_type;
wire [63:0] eth_rx_payload_axis_tdata;
wire [7:0] eth_rx_payload_axis_tkeep;
wire eth_rx_payload_axis_tvalid;
wire eth_rx_payload_axis_tready;
wire eth_rx_payload_axis_tlast;
wire eth_rx_payload_axis_tuser;

eth_mac_10g_fifo #(
    .ENABLE_PADDING(1),
    .ENABLE_DIC(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1)
)
eth_mac_fifo_inst (
    .rx_clk(clk),
    .rx_rst(rst),
    .tx_clk(clk),
    .tx_rst(rst),
    .logic_clk(clk),
    .logic_rst(rst),
    .tx_axis_tdata(0),
    .tx_axis_tkeep(0),
    .tx_axis_tvalid(0),
    .tx_axis_tready(),
    .tx_axis_tlast(0),
    .tx_axis_tuser(0),
    .rx_axis_tdata(eth_rx_axis_tdata),
    .rx_axis_tkeep(eth_rx_axis_tkeep),
    .rx_axis_tvalid(eth_rx_axis_tvalid),
    .rx_axis_tready(eth_rx_axis_tready),
    .rx_axis_tlast(eth_rx_axis_tlast),
    .rx_axis_tuser(eth_rx_axis_tuser),
    .xgmii_rxd(eth_l11_rxd),
    .xgmii_rxc(eth_l11_rxc),
    .xgmii_txd(eth_l11_txd),
    .xgmii_txc(eth_l11_txc),
    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),
    .ifg_delay(12)
);

eth_axis_rx #(
    .DATA_WIDTH(64),
    .KEEP_WIDTH(8)
)
eth_axis_rxinst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(eth_rx_axis_tdata),
    .s_axis_tkeep(eth_rx_axis_tkeep),
    .s_axis_tvalid(eth_rx_axis_tvalid),
    .s_axis_tready(eth_rx_axis_tready),
    .s_axis_tlast(eth_rx_axis_tlast),
    .s_axis_tuser(eth_rx_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(eth_rx_hdr_valid),
    .m_eth_hdr_ready(eth_rx_hdr_ready),
    .m_eth_dest_mac(eth_rx_dest_mac),
    .m_eth_src_mac(eth_rx_src_mac),
    .m_eth_type(eth_rx_type),
    .m_eth_payload_axis_tdata(eth_rx_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(eth_rx_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(eth_rx_payload_axis_tvalid),
    .m_eth_payload_axis_tready(eth_rx_payload_axis_tready),
    .m_eth_payload_axis_tlast(eth_rx_payload_axis_tlast),
    .m_eth_payload_axis_tuser(eth_rx_payload_axis_tuser),
    // Status signals
    .busy(),
    .error_header_early_termination()
);

// interpret config packet
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_WORD_0 = 3'd1,
    STATE_WORD_1 = 3'd2,
    STATE_WAIT = 3'd3;

reg [2:0] state_reg = STATE_IDLE;

reg eth_rx_hdr_ready_reg = 0;
reg eth_rx_payload_axis_tready_reg = 0;

assign eth_rx_hdr_ready = eth_rx_hdr_ready_reg;
assign eth_rx_payload_axis_tready = eth_rx_payload_axis_tready_reg;

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        eth_rx_hdr_ready_reg <= 0;
        eth_rx_payload_axis_tready_reg <= 0;
        select_reg_0 <= 0;
        select_reg_1 <= 1;
        select_reg_2 <= 2;
        select_reg_3 <= 3;
        select_reg_4 <= 4;
        select_reg_5 <= 5;
        select_reg_6 <= 6;
        select_reg_7 <= 7;
        select_reg_8 <= 8;
        select_reg_9 <= 9;
        select_reg_10 <= 10;
        select_reg_11 <= 11;
        select_reg_12 <= 12;
        select_reg_13 <= 13;
        select_reg_14 <= 14;
        select_reg_15 <= 15;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                eth_rx_hdr_ready_reg <= 1;
                eth_rx_payload_axis_tready_reg <= 0;
                if (eth_rx_hdr_ready && eth_rx_hdr_valid) begin
                    if (eth_rx_type == 16'h8099) begin
                        state_reg <= STATE_WORD_0;
                        eth_rx_hdr_ready_reg <= 0;
                        eth_rx_payload_axis_tready_reg <= 1;
                    end else begin
                        state_reg <= STATE_WAIT;
                        eth_rx_hdr_ready_reg <= 0;
                        eth_rx_payload_axis_tready_reg <= 1;
                    end
                end
            end
            STATE_WORD_0: begin
                eth_rx_hdr_ready_reg <= 0;
                eth_rx_payload_axis_tready_reg <= 1;
                if (eth_rx_payload_axis_tready && eth_rx_payload_axis_tvalid) begin
                    if (eth_rx_payload_axis_tlast) begin
                        state_reg <= STATE_IDLE;
                        eth_rx_hdr_ready_reg <= 1;
                        eth_rx_payload_axis_tready_reg <= 0;
                    end else begin
                        select_reg_0 <= eth_rx_payload_axis_tdata[7:0];
                        select_reg_1 <= eth_rx_payload_axis_tdata[15:8];
                        select_reg_2 <= eth_rx_payload_axis_tdata[23:16];
                        select_reg_3 <= eth_rx_payload_axis_tdata[31:24];
                        select_reg_4 <= eth_rx_payload_axis_tdata[39:32];
                        select_reg_5 <= eth_rx_payload_axis_tdata[47:40];
                        select_reg_6 <= eth_rx_payload_axis_tdata[55:48];
                        select_reg_7 <= eth_rx_payload_axis_tdata[63:56];
                        state_reg <= STATE_WORD_1;
                        eth_rx_hdr_ready_reg <= 0;
                        eth_rx_payload_axis_tready_reg <= 1;
                    end
                end
            end
            STATE_WORD_1: begin
                eth_rx_hdr_ready_reg <= 0;
                eth_rx_payload_axis_tready_reg <= 1;
                if (eth_rx_payload_axis_tready && eth_rx_payload_axis_tvalid) begin
                    if (eth_rx_payload_axis_tlast) begin
                        state_reg <= STATE_IDLE;
                        eth_rx_hdr_ready_reg <= 1;
                        eth_rx_payload_axis_tready_reg <= 0;
                    end else begin
                        select_reg_8 <= eth_rx_payload_axis_tdata[7:0];
                        select_reg_9 <= eth_rx_payload_axis_tdata[15:8];
                        select_reg_10 <= eth_rx_payload_axis_tdata[23:16];
                        select_reg_11 <= eth_rx_payload_axis_tdata[31:24];
                        select_reg_12 <= eth_rx_payload_axis_tdata[39:32];
                        select_reg_13 <= eth_rx_payload_axis_tdata[47:40];
                        select_reg_14 <= eth_rx_payload_axis_tdata[55:48];
                        select_reg_15 <= eth_rx_payload_axis_tdata[63:56];
                        state_reg <= STATE_WAIT;
                        eth_rx_hdr_ready_reg <= 0;
                        eth_rx_payload_axis_tready_reg <= 1;
                    end
                end
            end
            STATE_WAIT: begin
                eth_rx_hdr_ready_reg <= 0;
                eth_rx_payload_axis_tready_reg <= 1;
                if (eth_rx_payload_axis_tready && eth_rx_payload_axis_tvalid) begin
                    if (eth_rx_payload_axis_tlast) begin
                        state_reg <= STATE_IDLE;
                        eth_rx_hdr_ready_reg <= 1;
                        eth_rx_payload_axis_tready_reg <= 0;
                    end else begin
                        state_reg <= STATE_WAIT;
                        eth_rx_hdr_ready_reg <= 0;
                        eth_rx_payload_axis_tready_reg <= 1;
                    end
                end
            end
        endcase
    end
end

endmodule

`resetall
