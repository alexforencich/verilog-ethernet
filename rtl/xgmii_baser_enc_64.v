/*

Copyright (c) 2018 Alex Forencich

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
 * XGMII 10GBASE-R encoder
 */
module xgmii_baser_enc_64 #
(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * XGMII interface
     */
    input  wire [DATA_WIDTH-1:0] xgmii_txd,
    input  wire [CTRL_WIDTH-1:0] xgmii_txc,

    /*
     * 10GBASE-R encoded interface
     */
    output wire [DATA_WIDTH-1:0] encoded_tx_data,
    output wire [HDR_WIDTH-1:0]  encoded_tx_hdr,

    /*
     * Status
     */
    output wire                  tx_bad_block
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end

    if (HDR_WIDTH != 2) begin
        $error("Error: HDR_WIDTH must be 2");
        $finish;
    end
end

localparam [7:0]
    XGMII_IDLE   = 8'h07,
    XGMII_LPI    = 8'h06,
    XGMII_START  = 8'hfb,
    XGMII_TERM   = 8'hfd,
    XGMII_ERROR  = 8'hfe,
    XGMII_SEQ_OS = 8'h9c,
    XGMII_RES_0  = 8'h1c,
    XGMII_RES_1  = 8'h3c,
    XGMII_RES_2  = 8'h7c,
    XGMII_RES_3  = 8'hbc,
    XGMII_RES_4  = 8'hdc,
    XGMII_RES_5  = 8'hf7,
    XGMII_SIG_OS = 8'h5c;

localparam [6:0]
    CTRL_IDLE  = 7'h00,
    CTRL_LPI   = 7'h06,
    CTRL_ERROR = 7'h1e,
    CTRL_RES_0 = 7'h2d,
    CTRL_RES_1 = 7'h33,
    CTRL_RES_2 = 7'h4b,
    CTRL_RES_3 = 7'h55,
    CTRL_RES_4 = 7'h66,
    CTRL_RES_5 = 7'h78;

localparam [3:0]
    O_SEQ_OS = 4'h0,
    O_SIG_OS = 4'hf;

localparam [1:0]
    SYNC_DATA = 2'b10,
    SYNC_CTRL = 2'b01;

localparam [7:0]
    BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
    BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
    BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
    BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
    BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
    BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
    BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
    BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
    BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
    BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT

reg [DATA_WIDTH*7/8-1:0] encoded_ctrl;
reg [CTRL_WIDTH-1:0] encode_err;

reg [DATA_WIDTH-1:0] encoded_tx_data_reg = {DATA_WIDTH{1'b0}}, encoded_tx_data_next;
reg [HDR_WIDTH-1:0] encoded_tx_hdr_reg = {HDR_WIDTH{1'b0}}, encoded_tx_hdr_next;

reg tx_bad_block_reg = 1'b0, tx_bad_block_next;

assign encoded_tx_data = encoded_tx_data_reg;
assign encoded_tx_hdr = encoded_tx_hdr_reg;

assign tx_bad_block = tx_bad_block_reg;

integer i;

always @* begin
    tx_bad_block_next = 1'b0;

    for (i = 0; i < CTRL_WIDTH; i = i + 1) begin
        if (xgmii_txc[i]) begin
            // control
            case (xgmii_txd[8*i +: 8])
                XGMII_IDLE: begin
                    encoded_ctrl[7*i +: 7] = CTRL_IDLE;
                    encode_err[i] = 1'b0;
                end
                XGMII_LPI: begin
                    encoded_ctrl[7*i +: 7] = CTRL_LPI;
                    encode_err[i] = 1'b0;
                end
                XGMII_ERROR: begin
                    encoded_ctrl[7*i +: 7] = CTRL_ERROR;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_0: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_0;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_1: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_1;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_2: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_2;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_3: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_3;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_4: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_4;
                    encode_err[i] = 1'b0;
                end
                XGMII_RES_5: begin
                    encoded_ctrl[7*i +: 7] = CTRL_RES_5;
                    encode_err[i] = 1'b0;
                end
                default: begin
                    encoded_ctrl[7*i +: 7] = CTRL_ERROR;
                    encode_err[i] = 1'b1;
                end
            endcase
        end else begin
            // data (always invalid as control)
            encoded_ctrl[7*i +: 7] = CTRL_ERROR;
            encode_err[i] = 1'b1;
        end
    end

    if (xgmii_txc == 8'h00) begin
        encoded_tx_data_next = xgmii_txd;
        encoded_tx_hdr_next = SYNC_DATA;
        tx_bad_block_next = 1'b0;
    end else begin
        if (xgmii_txc == 8'h1f && xgmii_txd[39:32] == XGMII_SEQ_OS) begin
            // ordered set in lane 4
            encoded_tx_data_next = {xgmii_txd[63:40], O_SEQ_OS, encoded_ctrl[27:0], BLOCK_TYPE_OS_4};
            tx_bad_block_next = encode_err[3:0] != 0;
        end else if (xgmii_txc == 8'h1f && xgmii_txd[39:32] == XGMII_START) begin
            // start in lane 4
            encoded_tx_data_next = {xgmii_txd[63:40], 4'd0, encoded_ctrl[27:0], BLOCK_TYPE_START_4};
            tx_bad_block_next = encode_err[3:0] != 0;
        end else if (xgmii_txc == 8'h11 && xgmii_txd[7:0] == XGMII_SEQ_OS && xgmii_txd[39:32] == XGMII_START) begin
            // ordered set in lane 0, start in lane 4
            encoded_tx_data_next = {xgmii_txd[63:40], 4'd0, O_SEQ_OS, xgmii_txd[31:8], BLOCK_TYPE_OS_START};
            tx_bad_block_next = 1'b0;
        end else if (xgmii_txc == 8'h11 && xgmii_txd[7:0] == XGMII_SEQ_OS && xgmii_txd[39:32] == XGMII_SEQ_OS) begin
            // ordered set in lane 0 and lane 4
            encoded_tx_data_next = {xgmii_txd[63:40], O_SEQ_OS, O_SEQ_OS, xgmii_txd[31:8], BLOCK_TYPE_OS_04};
            tx_bad_block_next = 1'b0;
        end else if (xgmii_txc == 8'h01 && xgmii_txd[7:0] == XGMII_START) begin
            // start in lane 0
            encoded_tx_data_next = {xgmii_txd[63:8], BLOCK_TYPE_START_0};
            tx_bad_block_next = 1'b0;
        end else if (xgmii_txc == 8'hf1 && xgmii_txd[7:0] == XGMII_SEQ_OS) begin
            // ordered set in lane 0
            encoded_tx_data_next = {encoded_ctrl[55:28], O_SEQ_OS, xgmii_txd[31:8], BLOCK_TYPE_OS_0};
            tx_bad_block_next = encode_err[7:4] != 0;
        end else if (xgmii_txc == 8'hff && xgmii_txd[7:0] == XGMII_TERM) begin
            // terminate in lane 0
            encoded_tx_data_next = {encoded_ctrl[55:7], 7'd0, BLOCK_TYPE_TERM_0};
            tx_bad_block_next = encode_err[7:1] != 0;
        end else if (xgmii_txc == 8'hfe && xgmii_txd[15:8] == XGMII_TERM) begin
            // terminate in lane 1
            encoded_tx_data_next = {encoded_ctrl[55:14], 6'd0, xgmii_txd[7:0], BLOCK_TYPE_TERM_1};
            tx_bad_block_next = encode_err[7:2] != 0;
        end else if (xgmii_txc == 8'hfc && xgmii_txd[23:16] == XGMII_TERM) begin
            // terminate in lane 2
            encoded_tx_data_next = {encoded_ctrl[55:21], 5'd0, xgmii_txd[15:0], BLOCK_TYPE_TERM_2};
            tx_bad_block_next = encode_err[7:3] != 0;
        end else if (xgmii_txc == 8'hf8 && xgmii_txd[31:24] == XGMII_TERM) begin
            // terminate in lane 3
            encoded_tx_data_next = {encoded_ctrl[55:28], 4'd0, xgmii_txd[23:0], BLOCK_TYPE_TERM_3};
            tx_bad_block_next = encode_err[7:4] != 0;
        end else if (xgmii_txc == 8'hf0 && xgmii_txd[39:32] == XGMII_TERM) begin
            // terminate in lane 4
            encoded_tx_data_next = {encoded_ctrl[55:35], 3'd0, xgmii_txd[31:0], BLOCK_TYPE_TERM_4};
            tx_bad_block_next = encode_err[7:5] != 0;
        end else if (xgmii_txc == 8'he0 && xgmii_txd[47:40] == XGMII_TERM) begin
            // terminate in lane 5
            encoded_tx_data_next = {encoded_ctrl[55:42], 2'd0, xgmii_txd[39:0], BLOCK_TYPE_TERM_5};
            tx_bad_block_next = encode_err[7:6] != 0;
        end else if (xgmii_txc == 8'hc0 && xgmii_txd[55:48] == XGMII_TERM) begin
            // terminate in lane 6
            encoded_tx_data_next = {encoded_ctrl[55:49], 1'd0, xgmii_txd[47:0], BLOCK_TYPE_TERM_6};
            tx_bad_block_next = encode_err[7] != 0;
        end else if (xgmii_txc == 8'h80 && xgmii_txd[63:56] == XGMII_TERM) begin
            // terminate in lane 7
            encoded_tx_data_next = {xgmii_txd[55:0], BLOCK_TYPE_TERM_7};
            tx_bad_block_next = 1'b0;
        end else if (xgmii_txc == 8'hff) begin
            // all control
            encoded_tx_data_next = {encoded_ctrl, BLOCK_TYPE_CTRL};
            tx_bad_block_next = encode_err != 0;
        end else begin
            // no corresponding block format
            encoded_tx_data_next = {{8{CTRL_ERROR}}, BLOCK_TYPE_CTRL};
            tx_bad_block_next = 1'b1;
        end
        encoded_tx_hdr_next = SYNC_CTRL;
    end
end

always @(posedge clk) begin
    encoded_tx_data_reg <= encoded_tx_data_next;
    encoded_tx_hdr_reg <= encoded_tx_hdr_next;

    tx_bad_block_reg <= tx_bad_block_next;
end

endmodule

`resetall
