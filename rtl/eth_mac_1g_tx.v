/*

Copyright (c) 2015-2017 Alex Forencich

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
 * 1G Ethernet MAC
 */
module eth_mac_1g_tx #
(
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [7:0]  input_axis_tdata,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,

    /*
     * GMII output
     */
    output wire [7:0]  gmii_txd,
    output wire        gmii_tx_en,
    output wire        gmii_tx_er,

    /*
     * Configuration
     */
    input  wire [7:0]  ifg_delay
);

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PREAMBLE = 3'd1,
    STATE_PAYLOAD = 3'd2,
    STATE_PAD = 3'd3,
    STATE_FCS = 3'd4,
    STATE_WAIT_END = 3'd5,
    STATE_IFG = 3'd6;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [7:0] gmii_txd_reg = 8'd0, gmii_txd_next;
reg gmii_tx_en_reg = 1'b0, gmii_tx_en_next;
reg gmii_tx_er_reg = 1'b0, gmii_tx_er_next;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
wire [31:0] crc_next;

assign input_axis_tready = input_axis_tready_reg;

assign gmii_txd = gmii_txd_reg;
assign gmii_tx_en = gmii_tx_en_reg;
assign gmii_tx_er = gmii_tx_er_reg;

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(8),
    .STYLE("AUTO")
)
eth_crc_8 (
    .data_in(gmii_txd_next),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    input_axis_tready_next = 1'b0;

    gmii_txd_next = 8'd0;
    gmii_tx_en_next = 1'b0;
    gmii_tx_er_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for packet
            reset_crc = 1'b1;

            if (input_axis_tvalid) begin
                frame_ptr_next = 16'd1;
                gmii_txd_next = 8'h55; // Preamble
                gmii_tx_en_next = 1'b1;
                state_next = STATE_PREAMBLE;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PREAMBLE: begin
            // send preamble
            reset_crc = 1'b1;
            frame_ptr_next = frame_ptr_reg + 16'd1;

            gmii_txd_next = 8'h55; // Preamble
            gmii_tx_en_next = 1'b1;

            if (frame_ptr_reg == 16'd7) begin
                // end of preamble; start payload
                frame_ptr_next = 16'd0;
                input_axis_tready_next = 1'b1;
                gmii_txd_next = 8'hD5; // SFD
                state_next = STATE_PAYLOAD;
            end else begin
                state_next = STATE_PREAMBLE;
            end
        end
        STATE_PAYLOAD: begin
            // send payload
            update_crc = 1'b1;
            input_axis_tready_next = 1'b1;

            frame_ptr_next = frame_ptr_reg + 16'd1;

            gmii_txd_next = input_axis_tdata;
            gmii_tx_en_next = 1'b1;

            if (input_axis_tvalid) begin
                if (input_axis_tlast) begin
                    input_axis_tready_next = 1'b0;
                    if (input_axis_tuser) begin
                        gmii_tx_er_next = 1'b1;
                        frame_ptr_next = 1'b0;
                        state_next = STATE_IFG;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_reg < MIN_FRAME_LENGTH-5) begin
                            state_next = STATE_PAD;
                        end else begin
                            frame_ptr_next = 16'd0;
                            state_next = STATE_FCS;
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                // tvalid deassert, fail frame
                gmii_tx_er_next = 1'b1;
                frame_ptr_next = 16'd0;
                state_next = STATE_WAIT_END;
            end
        end
        STATE_PAD: begin
            // send padding
            update_crc = 1'b1;
            frame_ptr_next = frame_ptr_reg + 16'd1;

            gmii_txd_next = 8'd0;
            gmii_tx_en_next = 1'b1;

            if (frame_ptr_reg < MIN_FRAME_LENGTH-5) begin
                state_next = STATE_PAD;
            end else begin
                frame_ptr_next = 16'd0;
                state_next = STATE_FCS;
            end
        end
        STATE_FCS: begin
            // send FCS
            frame_ptr_next = frame_ptr_reg + 16'd1;

            case (frame_ptr_reg)
                2'd0: gmii_txd_next = ~crc_state[7:0];
                2'd1: gmii_txd_next = ~crc_state[15:8];
                2'd2: gmii_txd_next = ~crc_state[23:16];
                2'd3: gmii_txd_next = ~crc_state[31:24];
            endcase
            gmii_tx_en_next = 1'b1;

            if (frame_ptr_reg < 3) begin
                state_next = STATE_FCS;
            end else begin
                frame_ptr_next = 16'd0;
                state_next = STATE_IFG;
            end
        end
        STATE_WAIT_END: begin
            // wait for end of frame
            frame_ptr_next = frame_ptr_reg + 16'd1;
            reset_crc = 1'b1;

            if (input_axis_tvalid) begin
                if (input_axis_tlast) begin
                    if (frame_ptr_reg < ifg_delay-1) begin
                        state_next = STATE_IFG;
                    end else begin
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_WAIT_END;
                end
            end else begin
                state_next = STATE_WAIT_END;
            end
        end
        STATE_IFG: begin
            // send IFG
            frame_ptr_next = frame_ptr_reg + 16'd1;
            reset_crc = 1'b1;

            if (frame_ptr_reg < ifg_delay-1) begin
                state_next = STATE_IFG;
            end else begin
                state_next = STATE_IDLE;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_ptr_reg <= 16'd0;

        input_axis_tready_reg <= 1'b0;

        gmii_txd_reg <= 8'd0;
        gmii_tx_en_reg <= 1'b0;
        gmii_tx_er_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        input_axis_tready_reg <= input_axis_tready_next;

        gmii_txd_reg <= gmii_txd_next;
        gmii_tx_en_reg <= gmii_tx_en_next;
        gmii_tx_er_reg <= gmii_tx_er_next;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next;
        end
    end
end

endmodule
