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
 * PFC and pause frame receive handling
 */
module mac_pause_ctrl_rx #
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
    input  wire                          mcf_valid,
    input  wire [47:0]                   mcf_eth_dst,
    input  wire [47:0]                   mcf_eth_src,
    input  wire [15:0]                   mcf_eth_type,
    input  wire [15:0]                   mcf_opcode,
    input  wire [MCF_PARAMS_SIZE*8-1:0]  mcf_params,

    /*
     * Link-level Flow Control (LFC) (IEEE 802.3 annex 31B PAUSE)
     */
    input  wire                          rx_lfc_en,
    output wire                          rx_lfc_req,
    input  wire                          rx_lfc_ack,

    /*
     * Priority Flow Control (PFC) (IEEE 802.3 annex 31D PFC)
     */
    input  wire [7:0]                    rx_pfc_en,
    output wire [7:0]                    rx_pfc_req,
    input  wire [7:0]                    rx_pfc_ack,

    /*
     * Configuration
     */
    input  wire [15:0]                   cfg_rx_lfc_opcode,
    input  wire                          cfg_rx_lfc_en,
    input  wire [15:0]                   cfg_rx_pfc_opcode,
    input  wire                          cfg_rx_pfc_en,
    input  wire [9:0]                    cfg_quanta_step,
    input  wire                          cfg_quanta_clk_en,

    /*
     * Status
     */
    output wire                          stat_rx_lfc_pkt,
    output wire                          stat_rx_lfc_xon,
    output wire                          stat_rx_lfc_xoff,
    output wire                          stat_rx_lfc_paused,
    output wire                          stat_rx_pfc_pkt,
    output wire [7:0]                    stat_rx_pfc_xon,
    output wire [7:0]                    stat_rx_pfc_xoff,
    output wire [7:0]                    stat_rx_pfc_paused
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
reg [7:0] pfc_req_reg = 8'd0, pfc_req_next;

reg [16+QFB-1:0] lfc_quanta_reg = 0, lfc_quanta_next;
reg [16+QFB-1:0] pfc_quanta_reg[0:7], pfc_quanta_next[0:7];

reg stat_rx_lfc_pkt_reg = 1'b0, stat_rx_lfc_pkt_next;
reg stat_rx_lfc_xon_reg = 1'b0, stat_rx_lfc_xon_next;
reg stat_rx_lfc_xoff_reg = 1'b0, stat_rx_lfc_xoff_next;
reg stat_rx_pfc_pkt_reg = 1'b0, stat_rx_pfc_pkt_next;
reg [7:0] stat_rx_pfc_xon_reg = 0, stat_rx_pfc_xon_next;
reg [7:0] stat_rx_pfc_xoff_reg = 0, stat_rx_pfc_xoff_next;

assign rx_lfc_req = lfc_req_reg;
assign rx_pfc_req = pfc_req_reg;

assign stat_rx_lfc_pkt = stat_rx_lfc_pkt_reg;
assign stat_rx_lfc_xon = stat_rx_lfc_xon_reg;
assign stat_rx_lfc_xoff = stat_rx_lfc_xoff_reg;
assign stat_rx_lfc_paused = lfc_req_reg;
assign stat_rx_pfc_pkt = stat_rx_pfc_pkt_reg;
assign stat_rx_pfc_xon = stat_rx_pfc_xon_reg;
assign stat_rx_pfc_xoff = stat_rx_pfc_xoff_reg;
assign stat_rx_pfc_paused = pfc_req_reg;

integer k;

initial begin
    for (k = 0; k < 8; k = k + 1) begin
        pfc_quanta_reg[k] = 0;
    end
end

always @* begin
    stat_rx_lfc_pkt_next = 1'b0;
    stat_rx_lfc_xon_next = 1'b0;
    stat_rx_lfc_xoff_next = 1'b0;
    stat_rx_pfc_pkt_next = 1'b0;
    stat_rx_pfc_xon_next = 0;
    stat_rx_pfc_xoff_next = 0;

    if (cfg_quanta_clk_en && rx_lfc_ack) begin
        if (lfc_quanta_reg > cfg_quanta_step) begin
            lfc_quanta_next = lfc_quanta_reg - cfg_quanta_step;
        end else begin
            lfc_quanta_next = 0;
        end
    end else begin
        lfc_quanta_next = lfc_quanta_reg;
    end

    lfc_req_next = (lfc_quanta_reg != 0) && rx_lfc_en && cfg_rx_lfc_en;

    for (k = 0; k < 8; k = k + 1) begin
        if (cfg_quanta_clk_en && rx_pfc_ack[k]) begin
            if (pfc_quanta_reg[k] > cfg_quanta_step) begin
                pfc_quanta_next[k] = pfc_quanta_reg[k] - cfg_quanta_step;
            end else begin
                pfc_quanta_next[k] = 0;
            end
        end else begin
            pfc_quanta_next[k] = pfc_quanta_reg[k];
        end

        pfc_req_next[k] = (pfc_quanta_reg[k] != 0) && rx_pfc_en[k] && cfg_rx_pfc_en;
    end

    if (mcf_valid) begin
        if (mcf_opcode == cfg_rx_lfc_opcode && cfg_rx_lfc_en) begin
            stat_rx_lfc_pkt_next = 1'b1;
            stat_rx_lfc_xon_next = {mcf_params[7:0], mcf_params[15:8]} == 0;
            stat_rx_lfc_xoff_next = {mcf_params[7:0], mcf_params[15:8]} != 0;
            lfc_quanta_next = {mcf_params[7:0], mcf_params[15:8], {QFB{1'b0}}};
        end else if (PFC_ENABLE && mcf_opcode == cfg_rx_pfc_opcode && cfg_rx_pfc_en) begin
            stat_rx_pfc_pkt_next = 1'b1;
            for (k = 0; k < 8; k = k + 1) begin
                if (mcf_params[k+8]) begin
                    stat_rx_pfc_xon_next[k] = {mcf_params[16+(k*16)+0 +: 8], mcf_params[16+(k*16)+8 +: 8]} == 0;
                    stat_rx_pfc_xoff_next[k] = {mcf_params[16+(k*16)+0 +: 8], mcf_params[16+(k*16)+8 +: 8]} != 0;
                    pfc_quanta_next[k] = {mcf_params[16+(k*16)+0 +: 8], mcf_params[16+(k*16)+8 +: 8], {QFB{1'b0}}};
                end
            end
        end
    end
end

always @(posedge clk) begin
    lfc_req_reg <= lfc_req_next;
    pfc_req_reg <= pfc_req_next;

    lfc_quanta_reg <= lfc_quanta_next;
    for (k = 0; k < 8; k = k + 1) begin
        pfc_quanta_reg[k] <= pfc_quanta_next[k];
    end

    stat_rx_lfc_pkt_reg <= stat_rx_lfc_pkt_next;
    stat_rx_lfc_xon_reg <= stat_rx_lfc_xon_next;
    stat_rx_lfc_xoff_reg <= stat_rx_lfc_xoff_next;
    stat_rx_pfc_pkt_reg <= stat_rx_pfc_pkt_next;
    stat_rx_pfc_xon_reg <= stat_rx_pfc_xon_next;
    stat_rx_pfc_xoff_reg <= stat_rx_pfc_xoff_next;

    if (rst) begin
        lfc_req_reg <= 1'b0;
        pfc_req_reg <= 8'd0;
        lfc_quanta_reg <= 0;
        for (k = 0; k < 8; k = k + 1) begin
            pfc_quanta_reg[k] <= 0;
        end

        stat_rx_lfc_pkt_reg <= 1'b0;
        stat_rx_lfc_xon_reg <= 1'b0;
        stat_rx_lfc_xoff_reg <= 1'b0;
        stat_rx_pfc_pkt_reg <= 1'b0;
        stat_rx_pfc_xon_reg <= 0;
        stat_rx_pfc_xoff_reg <= 0;
    end
end

endmodule

`resetall
