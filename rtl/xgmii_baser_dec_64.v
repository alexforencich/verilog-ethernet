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
 * XGMII 10GBASE-R decoder
 */
module xgmii_baser_dec_64 #
(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * 10GBASE-R encoded input
     */
    input  wire [DATA_WIDTH-1:0] encoded_rx_data,
    input  wire [HDR_WIDTH-1:0]  encoded_rx_hdr,

    /*
     * XGMII interface
     */
    output wire [DATA_WIDTH-1:0] xgmii_rxd,
    output wire [CTRL_WIDTH-1:0] xgmii_rxc,

    /*
     * Status
     */
    output wire                  rx_bad_block,
    output wire                  rx_sequence_error
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

reg [DATA_WIDTH-1:0] decoded_ctrl;
reg [CTRL_WIDTH-1:0] decode_err;

reg [DATA_WIDTH-1:0] xgmii_rxd_reg = {DATA_WIDTH{1'b0}}, xgmii_rxd_next;
reg [CTRL_WIDTH-1:0] xgmii_rxc_reg = {CTRL_WIDTH{1'b0}}, xgmii_rxc_next;

reg rx_bad_block_reg = 1'b0, rx_bad_block_next;
reg rx_sequence_error_reg = 1'b0, rx_sequence_error_next;
reg frame_reg = 1'b0, frame_next;

assign xgmii_rxd = xgmii_rxd_reg;
assign xgmii_rxc = xgmii_rxc_reg;

assign rx_bad_block = rx_bad_block_reg;
assign rx_sequence_error = rx_sequence_error_reg;

integer i;

always @* begin
    xgmii_rxd_next = {8{XGMII_ERROR}};
    xgmii_rxc_next = 8'hff;
    rx_bad_block_next = 1'b0;
    rx_sequence_error_next = 1'b0;
    frame_next = frame_reg;

    for (i = 0; i < CTRL_WIDTH; i = i + 1) begin
        case (encoded_rx_data[7*i+8 +: 7])
            CTRL_IDLE: begin
                decoded_ctrl[8*i +: 8] = XGMII_IDLE;
                decode_err[i] = 1'b0;
            end
            CTRL_LPI: begin
                decoded_ctrl[8*i +: 8] = XGMII_LPI;
                decode_err[i] = 1'b0;
            end
            CTRL_ERROR: begin
                decoded_ctrl[8*i +: 8] = XGMII_ERROR;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_0: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_0;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_1: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_1;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_2: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_2;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_3: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_3;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_4: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_4;
                decode_err[i] = 1'b0;
            end
            CTRL_RES_5: begin
                decoded_ctrl[8*i +: 8] = XGMII_RES_5;
                decode_err[i] = 1'b0;
            end
            default: begin
                decoded_ctrl[8*i +: 8] = XGMII_ERROR;
                decode_err[i] = 1'b1;
            end
        endcase
    end

    if (encoded_rx_hdr == SYNC_DATA) begin
        xgmii_rxd_next = encoded_rx_data;
        xgmii_rxc_next = 8'h00;
        rx_bad_block_next = 1'b0;
    end else if (encoded_rx_hdr == SYNC_CTRL) begin
        case (encoded_rx_data[7:0])
            BLOCK_TYPE_CTRL: begin
                // C7 C6 C5 C4 C3 C2 C1 C0 BT
                xgmii_rxd_next = decoded_ctrl;
                xgmii_rxc_next = 8'hff;
                rx_bad_block_next = decode_err != 0;
            end
            BLOCK_TYPE_OS_4: begin
                // D7 D6 D5 O4 C3 C2 C1 C0 BT
                xgmii_rxd_next[31:0] = decoded_ctrl[31:0];
                xgmii_rxc_next[3:0] = 4'hf;
                xgmii_rxd_next[63:40] = encoded_rx_data[63:40];
                xgmii_rxc_next[7:4] = 4'h1;
                if (encoded_rx_data[39:36] == O_SEQ_OS) begin
                    xgmii_rxd_next[39:32] = XGMII_SEQ_OS;
                    rx_bad_block_next = decode_err[3:0] != 0;
                end else begin
                    xgmii_rxd_next[39:32] = XGMII_ERROR;
                    rx_bad_block_next = 1'b1;
                end
            end
            BLOCK_TYPE_START_4: begin
                // D7 D6 D5    C3 C2 C1 C0 BT
                xgmii_rxd_next = {encoded_rx_data[63:40], XGMII_START, decoded_ctrl[31:0]};
                xgmii_rxc_next = 8'h1f;
                rx_bad_block_next = decode_err[3:0] != 0;
                rx_sequence_error_next = frame_reg;
                frame_next = 1'b1;
            end
            BLOCK_TYPE_OS_START: begin
                // D7 D6 D5    O0 D3 D2 D1 BT
                xgmii_rxd_next[31:8] = encoded_rx_data[31:8];
                xgmii_rxc_next[3:0] = 4'hf;
                if (encoded_rx_data[35:32] == O_SEQ_OS) begin
                    xgmii_rxd_next[7:0] = XGMII_SEQ_OS;
                    rx_bad_block_next = 1'b0;
                end else begin
                    xgmii_rxd_next[7:0] = XGMII_ERROR;
                    rx_bad_block_next = 1'b1;
                end
                xgmii_rxd_next[63:32] = {encoded_rx_data[63:40], XGMII_START};
                xgmii_rxc_next[7:4] = 4'h1;
                rx_sequence_error_next = frame_reg;
                frame_next = 1'b1;
            end
            BLOCK_TYPE_OS_04: begin
                // D7 D6 D5 O4 O0 D3 D2 D1 BT
                rx_bad_block_next = 1'b0;
                xgmii_rxd_next[31:8] = encoded_rx_data[31:8];
                xgmii_rxc_next[3:0] = 4'h1;
                if (encoded_rx_data[35:32] == O_SEQ_OS) begin
                    xgmii_rxd_next[7:0] = XGMII_SEQ_OS;
                end else begin
                    xgmii_rxd_next[7:0] = XGMII_ERROR;
                    rx_bad_block_next = 1'b1;
                end
                xgmii_rxd_next[63:40] = encoded_rx_data[63:40];
                xgmii_rxc_next[7:4] = 4'h1;
                if (encoded_rx_data[39:36] == O_SEQ_OS) begin
                    xgmii_rxd_next[39:32] = XGMII_SEQ_OS;
                end else begin
                    xgmii_rxd_next[39:32] = XGMII_ERROR;
                    rx_bad_block_next = 1'b1;
                end
            end
            BLOCK_TYPE_START_0: begin
                // D7 D6 D5 D4 D3 D2 D1    BT
                xgmii_rxd_next = {encoded_rx_data[63:8], XGMII_START};
                xgmii_rxc_next = 8'h01;
                rx_bad_block_next = 1'b0;
                rx_sequence_error_next = frame_reg;
                frame_next = 1'b1;
            end
            BLOCK_TYPE_OS_0: begin
                // C7 C6 C5 C4 O0 D3 D2 D1 BT
                xgmii_rxd_next[31:8] = encoded_rx_data[31:8];
                xgmii_rxc_next[3:0] = 4'h1;
                if (encoded_rx_data[35:32] == O_SEQ_OS) begin
                    xgmii_rxd_next[7:0] = XGMII_SEQ_OS;
                    rx_bad_block_next = decode_err[7:4] != 0;
                end else begin
                    xgmii_rxd_next[7:0] = XGMII_ERROR;
                    rx_bad_block_next = 1'b1;
                end
                xgmii_rxd_next[63:32] = decoded_ctrl[63:32];
                xgmii_rxc_next[7:4] = 4'hf;
            end
            BLOCK_TYPE_TERM_0: begin
                // C7 C6 C5 C4 C3 C2 C1    BT
                xgmii_rxd_next = {decoded_ctrl[63:8], XGMII_TERM};
                xgmii_rxc_next = 8'hff;
                rx_bad_block_next = decode_err[7:1] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_1: begin
                // C7 C6 C5 C4 C3 C2    D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:16], XGMII_TERM, encoded_rx_data[15:8]};
                xgmii_rxc_next = 8'hfe;
                rx_bad_block_next = decode_err[7:2] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_2: begin
                // C7 C6 C5 C4 C3    D1 D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:24], XGMII_TERM, encoded_rx_data[23:8]};
                xgmii_rxc_next = 8'hfc;
                rx_bad_block_next = decode_err[7:3] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_3: begin
                // C7 C6 C5 C4    D2 D1 D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:32], XGMII_TERM, encoded_rx_data[31:8]};
                xgmii_rxc_next = 8'hf8;
                rx_bad_block_next = decode_err[7:4] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_4: begin
                // C7 C6 C5    D3 D2 D1 D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:40], XGMII_TERM, encoded_rx_data[39:8]};
                xgmii_rxc_next = 8'hf0;
                rx_bad_block_next = decode_err[7:5] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_5: begin
                // C7 C6    D4 D3 D2 D1 D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:48], XGMII_TERM, encoded_rx_data[47:8]};
                xgmii_rxc_next = 8'he0;
                rx_bad_block_next = decode_err[7:6] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_6: begin
                // C7    D5 D4 D3 D2 D1 D0 BT
                xgmii_rxd_next = {decoded_ctrl[63:56], XGMII_TERM, encoded_rx_data[55:8]};
                xgmii_rxc_next = 8'hc0;
                rx_bad_block_next = decode_err[7] != 0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            BLOCK_TYPE_TERM_7: begin
                //    D6 D5 D4 D3 D2 D1 D0 BT
                xgmii_rxd_next = {XGMII_TERM, encoded_rx_data[63:8]};
                xgmii_rxc_next = 8'h80;
                rx_bad_block_next = 1'b0;
                rx_sequence_error_next = !frame_reg;
                frame_next = 1'b0;
            end
            default: begin
                // invalid block type
                xgmii_rxd_next = {8{XGMII_ERROR}};
                xgmii_rxc_next = 8'hff;
                rx_bad_block_next = 1'b1;
            end
        endcase
    end else begin
        // invalid header
        xgmii_rxd_next = {8{XGMII_ERROR}};
        xgmii_rxc_next = 8'hff;
        rx_bad_block_next = 1'b1;
    end
end

always @(posedge clk) begin
    xgmii_rxd_reg <= xgmii_rxd_next;
    xgmii_rxc_reg <= xgmii_rxc_next;

    rx_bad_block_reg <= rx_bad_block_next;
    rx_sequence_error_reg <= rx_sequence_error_next;
    frame_reg <= frame_next;

    if (rst) begin
        frame_reg <= 1'b0;
    end
end

endmodule

`resetall
