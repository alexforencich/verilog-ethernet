/*

Copyright (c) 2023 Alex Forencich

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
 * PFC and pause frame transmit handling
 */
module mac_pause_ctrl_tx #
(
    parameter MCF_PARAMS_SIZE = 18,
    parameter PFC_ENABLE = 1
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * MAC control frame interface
     */
    output wire                          mcf_valid,
    input  wire                          mcf_ready,
    output wire [47:0]                   mcf_eth_dst,
    output wire [47:0]                   mcf_eth_src,
    output wire [15:0]                   mcf_eth_type,
    output wire [15:0]                   mcf_opcode,
    output wire [MCF_PARAMS_SIZE*8-1:0]  mcf_params,

    /*
     * Link-level Flow Control (LFC) (IEEE 802.3 annex 31B PAUSE)
     */
    input  wire                          tx_lfc_req,
    input  wire                          tx_lfc_resend,

    /*
     * Priority Flow Control (PFC) (IEEE 802.3 annex 31D)
     */
    input  wire [7:0]                    tx_pfc_req,
    input  wire                          tx_pfc_resend,

    /*
     * Configuration
     */
    input  wire [47:0]                   cfg_tx_lfc_eth_dst,
    input  wire [47:0]                   cfg_tx_lfc_eth_src,
    input  wire [15:0]                   cfg_tx_lfc_eth_type,
    input  wire [15:0]                   cfg_tx_lfc_opcode,
    input  wire                          cfg_tx_lfc_en,
    input  wire [15:0]                   cfg_tx_lfc_quanta,
    input  wire [15:0]                   cfg_tx_lfc_refresh,
    input  wire [47:0]                   cfg_tx_pfc_eth_dst,
    input  wire [47:0]                   cfg_tx_pfc_eth_src,
    input  wire [15:0]                   cfg_tx_pfc_eth_type,
    input  wire [15:0]                   cfg_tx_pfc_opcode,
    input  wire                          cfg_tx_pfc_en,
    input  wire [8*16-1:0]               cfg_tx_pfc_quanta,
    input  wire [8*16-1:0]               cfg_tx_pfc_refresh,
    input  wire [9:0]                    cfg_quanta_step,
    input  wire                          cfg_quanta_clk_en,

    /*
     * Status
     */
    output wire                          stat_tx_lfc_pkt,
    output wire                          stat_tx_lfc_xon,
    output wire                          stat_tx_lfc_xoff,
    output wire                          stat_tx_lfc_paused,
    output wire                          stat_tx_pfc_pkt,
    output wire [7:0]                    stat_tx_pfc_xon,
    output wire [7:0]                    stat_tx_pfc_xoff,
    output wire [7:0]                    stat_tx_pfc_paused
);

localparam QFB = 8;

// check configuration
initial begin
    if (MCF_PARAMS_SIZE < (PFC_ENABLE ? 18 : 2)) begin
        $error("Error: MCF_PARAMS_SIZE too small for requested configuration (instance %m)");
        $finish;
    end
end

reg lfc_req_reg = 1'b0, lfc_req_next;
reg lfc_act_reg = 1'b0, lfc_act_next;
reg lfc_send_reg = 1'b0, lfc_send_next;
reg [7:0] pfc_req_reg = 8'd0, pfc_req_next;
reg [7:0] pfc_act_reg = 8'd0, pfc_act_next;
reg [7:0] pfc_en_reg = 8'd0, pfc_en_next;
reg pfc_send_reg = 1'b0, pfc_send_next;

reg [16+QFB-1:0] lfc_refresh_reg = 0, lfc_refresh_next;
reg [16+QFB-1:0] pfc_refresh_reg[0:7], pfc_refresh_next[0:7];

reg stat_tx_lfc_pkt_reg = 1'b0, stat_tx_lfc_pkt_next;
reg stat_tx_lfc_xon_reg = 1'b0, stat_tx_lfc_xon_next;
reg stat_tx_lfc_xoff_reg = 1'b0, stat_tx_lfc_xoff_next;
reg stat_tx_pfc_pkt_reg = 1'b0, stat_tx_pfc_pkt_next;
reg [7:0] stat_tx_pfc_xon_reg = 0, stat_tx_pfc_xon_next;
reg [7:0] stat_tx_pfc_xoff_reg = 0, stat_tx_pfc_xoff_next;

// MAC control interface
reg             mcf_pfc_sel_reg = PFC_ENABLE != 0, mcf_pfc_sel_next;
reg             mcf_valid_reg = 1'b0, mcf_valid_next;

wire [2*8-1:0] mcf_lfc_params;
assign mcf_lfc_params[16*0 +: 16] = lfc_req_reg ? {cfg_tx_lfc_quanta[0 +: 8], cfg_tx_lfc_quanta[8 +: 8]} : 0;

wire [18*8-1:0] mcf_pfc_params;
assign mcf_pfc_params[16*0 +: 16] = {pfc_en_reg, 8'd0};
assign mcf_pfc_params[16*1 +: 16] = pfc_req_reg[0] ? {cfg_tx_pfc_quanta[16*0+0 +: 8], cfg_tx_pfc_quanta[16*0+8 +: 8]} : 0;
assign mcf_pfc_params[16*2 +: 16] = pfc_req_reg[1] ? {cfg_tx_pfc_quanta[16*1+0 +: 8], cfg_tx_pfc_quanta[16*1+8 +: 8]} : 0;
assign mcf_pfc_params[16*3 +: 16] = pfc_req_reg[2] ? {cfg_tx_pfc_quanta[16*2+0 +: 8], cfg_tx_pfc_quanta[16*2+8 +: 8]} : 0;
assign mcf_pfc_params[16*4 +: 16] = pfc_req_reg[3] ? {cfg_tx_pfc_quanta[16*3+0 +: 8], cfg_tx_pfc_quanta[16*3+8 +: 8]} : 0;
assign mcf_pfc_params[16*5 +: 16] = pfc_req_reg[4] ? {cfg_tx_pfc_quanta[16*4+0 +: 8], cfg_tx_pfc_quanta[16*4+8 +: 8]} : 0;
assign mcf_pfc_params[16*6 +: 16] = pfc_req_reg[5] ? {cfg_tx_pfc_quanta[16*5+0 +: 8], cfg_tx_pfc_quanta[16*5+8 +: 8]} : 0;
assign mcf_pfc_params[16*7 +: 16] = pfc_req_reg[6] ? {cfg_tx_pfc_quanta[16*6+0 +: 8], cfg_tx_pfc_quanta[16*6+8 +: 8]} : 0;
assign mcf_pfc_params[16*8 +: 16] = pfc_req_reg[7] ? {cfg_tx_pfc_quanta[16*7+0 +: 8], cfg_tx_pfc_quanta[16*7+8 +: 8]} : 0;

assign mcf_valid = mcf_valid_reg;
assign mcf_eth_dst  = (PFC_ENABLE && mcf_pfc_sel_reg) ? cfg_tx_pfc_eth_dst  : cfg_tx_lfc_eth_dst;
assign mcf_eth_src  = (PFC_ENABLE && mcf_pfc_sel_reg) ? cfg_tx_pfc_eth_src  : cfg_tx_lfc_eth_src;
assign mcf_eth_type = (PFC_ENABLE && mcf_pfc_sel_reg) ? cfg_tx_pfc_eth_type : cfg_tx_lfc_eth_type;
assign mcf_opcode   = (PFC_ENABLE && mcf_pfc_sel_reg) ? cfg_tx_pfc_opcode   : cfg_tx_lfc_opcode;
assign mcf_params   = (PFC_ENABLE && mcf_pfc_sel_reg) ? mcf_pfc_params      : mcf_lfc_params;

assign stat_tx_lfc_pkt = stat_tx_lfc_pkt_reg;
assign stat_tx_lfc_xon = stat_tx_lfc_xon_reg;
assign stat_tx_lfc_xoff = stat_tx_lfc_xoff_reg;
assign stat_tx_lfc_paused = lfc_req_reg;
assign stat_tx_pfc_pkt = stat_tx_pfc_pkt_reg;
assign stat_tx_pfc_xon = stat_tx_pfc_xon_reg;
assign stat_tx_pfc_xoff = stat_tx_pfc_xoff_reg;
assign stat_tx_pfc_paused = pfc_req_reg;

integer k;

initial begin
    for (k = 0; k < 8; k = k + 1) begin
        pfc_refresh_reg[k] = 0;
    end
end

always @* begin
    lfc_req_next = lfc_req_reg;
    lfc_act_next = lfc_act_reg;
    lfc_send_next = lfc_send_reg | tx_lfc_resend;
    pfc_req_next = pfc_req_reg;
    pfc_act_next = pfc_act_reg;
    pfc_en_next = pfc_en_reg;
    pfc_send_next = pfc_send_reg | tx_pfc_resend;

    mcf_pfc_sel_next = mcf_pfc_sel_reg;
    mcf_valid_next = mcf_valid_reg && !mcf_ready;

    stat_tx_lfc_pkt_next = 1'b0;
    stat_tx_lfc_xon_next = 1'b0;
    stat_tx_lfc_xoff_next = 1'b0;
    stat_tx_pfc_pkt_next = 1'b0;
    stat_tx_pfc_xon_next = 0;
    stat_tx_pfc_xoff_next = 0;

    if (cfg_quanta_clk_en) begin
        if (lfc_refresh_reg > cfg_quanta_step) begin
            lfc_refresh_next = lfc_refresh_reg - cfg_quanta_step;
        end else begin
            lfc_refresh_next = 0;
            if (lfc_req_reg) begin
                lfc_send_next = 1'b1;
            end
        end
    end else begin
        lfc_refresh_next = lfc_refresh_reg;
    end

    for (k = 0; k < 8; k = k + 1) begin
        if (cfg_quanta_clk_en) begin
            if (pfc_refresh_reg[k] > cfg_quanta_step) begin
                pfc_refresh_next[k] = pfc_refresh_reg[k] - cfg_quanta_step;
            end else begin
                pfc_refresh_next[k] = 0;
                if (pfc_req_reg[k]) begin
                    pfc_send_next = 1'b1;
                end
            end
        end else begin
            pfc_refresh_next[k] = pfc_refresh_reg[k];
        end
    end

    if (cfg_tx_lfc_en) begin
        if (!mcf_valid_reg) begin
            if (lfc_req_reg != tx_lfc_req) begin
                lfc_req_next = tx_lfc_req;
                lfc_act_next = lfc_act_reg | tx_lfc_req;
                lfc_send_next = 1'b1;
            end

            if (lfc_send_reg && !(PFC_ENABLE && cfg_tx_pfc_en && pfc_send_reg)) begin
                mcf_pfc_sel_next = 1'b0;
                mcf_valid_next = lfc_act_reg;
                lfc_act_next = lfc_req_reg;
                lfc_refresh_next = lfc_req_reg ? {cfg_tx_lfc_refresh, {QFB{1'b0}}} : 0;
                lfc_send_next = 1'b0;

                stat_tx_lfc_pkt_next = lfc_act_reg;
                stat_tx_lfc_xon_next = lfc_act_reg && !lfc_req_reg;
                stat_tx_lfc_xoff_next = lfc_act_reg && lfc_req_reg;
            end
        end
    end

    if (PFC_ENABLE && cfg_tx_pfc_en) begin
        if (!mcf_valid_reg) begin
            if (pfc_req_reg != tx_pfc_req) begin
                pfc_req_next = tx_pfc_req;
                pfc_act_next = pfc_act_reg | tx_pfc_req;
                pfc_send_next = 1'b1;
            end

            if (pfc_send_reg) begin
                mcf_pfc_sel_next = 1'b1;
                mcf_valid_next = pfc_act_reg != 0;
                pfc_en_next = pfc_act_reg;
                pfc_act_next = pfc_req_reg;
                for (k = 0; k < 8; k = k + 1) begin
                    pfc_refresh_next[k] = pfc_req_reg[k] ? {cfg_tx_pfc_refresh[16*k +: 16], {QFB{1'b0}}} : 0;
                end
                pfc_send_next = 1'b0;

                stat_tx_pfc_pkt_next = pfc_act_reg != 0;
                stat_tx_pfc_xon_next = pfc_act_reg & ~pfc_req_reg;
                stat_tx_pfc_xoff_next = pfc_act_reg & pfc_req_reg;
            end
        end
    end
end

always @(posedge clk) begin
    lfc_req_reg <= lfc_req_next;
    lfc_act_reg <= lfc_act_next;
    lfc_send_reg <= lfc_send_next;
    pfc_req_reg <= pfc_req_next;
    pfc_act_reg <= pfc_act_next;
    pfc_en_reg <= pfc_en_next;
    pfc_send_reg <= pfc_send_next;

    mcf_pfc_sel_reg <= mcf_pfc_sel_next;
    mcf_valid_reg <= mcf_valid_next;

    lfc_refresh_reg <= lfc_refresh_next;
    for (k = 0; k < 8; k = k + 1) begin
        pfc_refresh_reg[k] <= pfc_refresh_next[k];
    end

    stat_tx_lfc_pkt_reg <= stat_tx_lfc_pkt_next;
    stat_tx_lfc_xon_reg <= stat_tx_lfc_xon_next;
    stat_tx_lfc_xoff_reg <= stat_tx_lfc_xoff_next;
    stat_tx_pfc_pkt_reg <= stat_tx_pfc_pkt_next;
    stat_tx_pfc_xon_reg <= stat_tx_pfc_xon_next;
    stat_tx_pfc_xoff_reg <= stat_tx_pfc_xoff_next;

    if (rst) begin
        lfc_req_reg <= 1'b0;
        lfc_act_reg <= 1'b0;
        lfc_send_reg <= 1'b0;
        pfc_req_reg <= 0;
        pfc_act_reg <= 0;
        pfc_send_reg <= 0;
        mcf_pfc_sel_reg <= PFC_ENABLE != 0;
        mcf_valid_reg <= 1'b0;
        lfc_refresh_reg <= 0;
        for (k = 0; k < 8; k = k + 1) begin
            pfc_refresh_reg[k] <= 0;
        end

        stat_tx_lfc_pkt_reg <= 1'b0;
        stat_tx_lfc_xon_reg <= 1'b0;
        stat_tx_lfc_xoff_reg <= 1'b0;
        stat_tx_pfc_pkt_reg <= 1'b0;
        stat_tx_pfc_xon_reg <= 0;
        stat_tx_pfc_xoff_reg <= 0;
    end
end

endmodule

`resetall
