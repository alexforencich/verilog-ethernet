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
 * AXI4-Stream XGMII frame transmitter (AXI in, XGMII out)
 */
module axis_xgmii_tx_64 #
(
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [63:0] s_axis_tdata,
    input  wire [7:0]  s_axis_tkeep,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire        s_axis_tuser,

    /*
     * XGMII output
     */
    output wire [63:0] xgmii_txd,
    output wire [7:0]  xgmii_txc,

    /*
     * Configuration
     */
    input  wire [7:0]  ifg_delay
);

localparam MIN_FL_NOCRC = MIN_FRAME_LENGTH-4;
localparam MIN_FL_NOCRC_MS = MIN_FL_NOCRC & 16'hfff8;
localparam MIN_FL_NOCRC_LS = MIN_FL_NOCRC & 16'h0007;

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [7:0]
    XGMII_IDLE = 8'h07,
    XGMII_START = 8'hfb,
    XGMII_TERM = 8'hfd,
    XGMII_ERROR = 8'hfe;

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PAYLOAD = 3'd1,
    STATE_PAD = 3'd2,
    STATE_FCS_1 = 3'd3,
    STATE_FCS_2 = 3'd4,
    STATE_IFG = 3'd5,
    STATE_WAIT_END = 3'd6;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg swap_lanes;
reg unswap_lanes;

reg lanes_swapped = 1'b0;
reg [31:0] swap_txd = 32'd0;
reg [3:0] swap_txc = 4'd0;

reg [63:0] s_axis_tdata_masked;

reg [63:0] s_tdata_reg = 64'd0, s_tdata_next;
reg [7:0]  s_tkeep_reg = 8'd0, s_tkeep_next;

reg [63:0] fcs_output_txd_0;
reg [63:0] fcs_output_txd_1;
reg [7:0] fcs_output_txc_0;
reg [7:0] fcs_output_txc_1;

reg [7:0] ifg_offset;

reg extra_cycle;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [7:0] ifg_count_reg = 8'd0, ifg_count_next;
reg [1:0] deficit_idle_count_reg = 2'd0, deficit_idle_count_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

reg [63:0] xgmii_txd_reg = {8{XGMII_IDLE}}, xgmii_txd_next;
reg [7:0] xgmii_txc_reg = 8'b11111111, xgmii_txc_next;

assign s_axis_tready = s_axis_tready_reg;

assign xgmii_txd = xgmii_txd_reg;
assign xgmii_txc = xgmii_txc_reg;

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
    .data_in(s_tdata_reg[7:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next0)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(16),
    .STYLE("AUTO")
)
eth_crc_16 (
    .data_in(s_tdata_reg[15:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next1)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(24),
    .STYLE("AUTO")
)
eth_crc_24 (
    .data_in(s_tdata_reg[23:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next2)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(32),
    .STYLE("AUTO")
)
eth_crc_32 (
    .data_in(s_tdata_reg[31:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next3)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(40),
    .STYLE("AUTO")
)
eth_crc_40 (
    .data_in(s_tdata_reg[39:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next4)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(48),
    .STYLE("AUTO")
)
eth_crc_48 (
    .data_in(s_tdata_reg[47:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next5)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(56),
    .STYLE("AUTO")
)
eth_crc_56 (
    .data_in(s_tdata_reg[55:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next6)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(64),
    .STYLE("AUTO")
)
eth_crc_64 (
    .data_in(s_tdata_reg[63:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next7)
);

function [3:0] keep2count;
    input [7:0] k;
    casez (k)
        8'bzzzzzzz0: keep2count = 4'd0;
        8'bzzzzzz01: keep2count = 4'd1;
        8'bzzzzz011: keep2count = 4'd2;
        8'bzzzz0111: keep2count = 4'd3;
        8'bzzz01111: keep2count = 4'd4;
        8'bzz011111: keep2count = 4'd5;
        8'bz0111111: keep2count = 4'd6;
        8'b01111111: keep2count = 4'd7;
        8'b11111111: keep2count = 4'd8;
    endcase
endfunction

// Mask input data
integer j;

always @* begin
    for (j = 0; j < 8; j = j + 1) begin
        s_axis_tdata_masked[j*8 +: 8] = s_axis_tkeep[j] ? s_axis_tdata[j*8 +: 8] : 8'd0;
    end
end

// FCS cycle calculation
always @* begin
    casez (s_tkeep_reg)
        8'bzzzzzz01: begin
            fcs_output_txd_0 = {{2{XGMII_IDLE}}, XGMII_TERM, ~crc_next0[31:0], s_tdata_reg[7:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b11100000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd3;
            extra_cycle = 1'b0;
        end
        8'bzzzzz011: begin
            fcs_output_txd_0 = {XGMII_IDLE, XGMII_TERM, ~crc_next1[31:0], s_tdata_reg[15:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b11000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd2;
            extra_cycle = 1'b0;
        end
        8'bzzzz0111: begin
            fcs_output_txd_0 = {XGMII_TERM, ~crc_next2[31:0], s_tdata_reg[23:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b10000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd1;
            extra_cycle = 1'b0;
        end
        8'bzzz01111: begin
            fcs_output_txd_0 = {~crc_next3[31:0], s_tdata_reg[31:0]};
            fcs_output_txd_1 = {{7{XGMII_IDLE}}, XGMII_TERM};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd8;
            extra_cycle = 1'b1;
        end
        8'bzz011111: begin
            fcs_output_txd_0 = {~crc_next4[23:0], s_tdata_reg[39:0]};
            fcs_output_txd_1 = {{6{XGMII_IDLE}}, XGMII_TERM, ~crc_next4[31:24]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111110;
            ifg_offset = 8'd7;
            extra_cycle = 1'b1;
        end
        8'bz0111111: begin
            fcs_output_txd_0 = {~crc_next5[15:0], s_tdata_reg[47:0]};
            fcs_output_txd_1 = {{5{XGMII_IDLE}}, XGMII_TERM, ~crc_next5[31:16]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111100;
            ifg_offset = 8'd6;
            extra_cycle = 1'b1;
        end
        8'b01111111: begin
            fcs_output_txd_0 = {~crc_next6[7:0], s_tdata_reg[55:0]};
            fcs_output_txd_1 = {{4{XGMII_IDLE}}, XGMII_TERM, ~crc_next6[31:8]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111000;
            ifg_offset = 8'd5;
            extra_cycle = 1'b1;
        end
        8'b11111111: begin
            fcs_output_txd_0 = s_tdata_reg;
            fcs_output_txd_1 = {{3{XGMII_IDLE}}, XGMII_TERM, ~crc_next7[31:0]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11110000;
            ifg_offset = 8'd4;
            extra_cycle = 1'b1;
        end
        default: begin
            fcs_output_txd_0 = {8{XGMII_ERROR}};
            fcs_output_txd_1 = {8{XGMII_ERROR}};
            fcs_output_txc_0 = 8'b11111111;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd0;
            extra_cycle = 1'b1;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    swap_lanes = 1'b0;
    unswap_lanes = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    ifg_count_next = ifg_count_reg;
    deficit_idle_count_next = deficit_idle_count_reg;

    s_axis_tready_next = 1'b0;

    s_tdata_next = s_tdata_reg;
    s_tkeep_next = s_tkeep_reg;

    // XGMII idle
    xgmii_txd_next = {8{XGMII_IDLE}};
    xgmii_txc_next = 8'b11111111;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 16'd8;
            reset_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            // XGMII idle
            xgmii_txd_next = {8{XGMII_IDLE}};
            xgmii_txc_next = 8'b11111111;

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                // XGMII start and preamble
                if (ifg_count_reg > 8'd0) begin
                    // need to send more idles - swap lanes
                    swap_lanes = 1'b1;
                end else begin
                    // no more idles - unswap
                    unswap_lanes = 1'b1;
                end
                xgmii_txd_next = {ETH_SFD, {6{ETH_PRE}}, XGMII_START};
                xgmii_txc_next = 8'b00000001;
                s_axis_tready_next = 1'b1;
                state_next = STATE_PAYLOAD;
            end else begin
                ifg_count_next = 8'd0;
                deficit_idle_count_next = 2'd0;
                unswap_lanes = 1'b1;
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            update_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            frame_ptr_next = frame_ptr_reg + 16'd8;

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = 8'b00000000;

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                if (s_axis_tlast) begin
                    frame_ptr_next = frame_ptr_reg + keep2count(s_axis_tkeep);
                    s_axis_tready_next = 1'b0;
                    if (s_axis_tuser) begin
                        xgmii_txd_next = {{3{XGMII_IDLE}}, XGMII_TERM, {4{XGMII_ERROR}}};
                        xgmii_txc_next = 8'b11111111;
                        frame_ptr_next = 16'd0;
                        ifg_count_next = 8'd8;
                        state_next = STATE_IFG;
                    end else begin
                        s_axis_tready_next = 1'b0;

                        if (ENABLE_PADDING && (frame_ptr_reg < MIN_FL_NOCRC_MS || (frame_ptr_reg == MIN_FL_NOCRC_MS && keep2count(s_axis_tkeep) < MIN_FL_NOCRC_LS))) begin
                            s_tkeep_next = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 16'd8;

                            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-8)) begin
                                state_next = STATE_PAD;
                            end else begin
                                s_tkeep_next = 8'hff >> ((8-MIN_FL_NOCRC_LS) % 8);

                                state_next = STATE_FCS_1;
                            end
                        end else begin
                            state_next = STATE_FCS_1;
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                // tvalid deassert, fail frame
                xgmii_txd_next = {{3{XGMII_IDLE}}, XGMII_TERM, {4{XGMII_ERROR}}};
                xgmii_txc_next = 8'b11111111;
                frame_ptr_next = 16'd0;
                ifg_count_next = 8'd8;
                state_next = STATE_WAIT_END;
            end
        end
        STATE_PAD: begin
            // pad frame to MIN_FRAME_LENGTH
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = 8'b00000000;

            s_tdata_next = 64'd0;
            s_tkeep_next = 8'hff;

            update_crc = 1'b1;
            frame_ptr_next = frame_ptr_reg + 16'd8;

            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-8)) begin
                state_next = STATE_PAD;
            end else begin
                s_tkeep_next = 8'hff >> ((8-MIN_FL_NOCRC_LS) % 8);

                state_next = STATE_FCS_1;
            end
        end
        STATE_FCS_1: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = fcs_output_txd_0;
            xgmii_txc_next = fcs_output_txc_0;

            frame_ptr_next = 16'd0;

            ifg_count_next = (ifg_delay > 8'd12 ? ifg_delay : 8'd12) - ifg_offset + (lanes_swapped ? 8'd4 : 8'd0) + deficit_idle_count_reg;
            if (extra_cycle) begin
                state_next = STATE_FCS_2;
            end else begin
                state_next = STATE_IFG;
            end
        end
        STATE_FCS_2: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = fcs_output_txd_1;
            xgmii_txc_next = fcs_output_txc_1;

            reset_crc = 1'b1;
            frame_ptr_next = 16'd0;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_IFG: begin
            // send IFG
            if (ifg_count_reg > 8'd8) begin
                ifg_count_next = ifg_count_reg - 8'd8;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_WAIT_END: begin
            // wait for end of frame
            if (ifg_count_reg > 8'd8) begin
                ifg_count_next = ifg_count_reg - 8'd8;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (s_axis_tvalid) begin
                if (s_axis_tlast) begin
                    if (ENABLE_DIC) begin
                        if (ifg_count_next > 8'd7) begin
                            state_next = STATE_IFG;
                        end else begin
                            if (ifg_count_next >= 8'd4) begin
                                deficit_idle_count_next = ifg_count_next - 8'd4;
                            end else begin
                                deficit_idle_count_next = ifg_count_next;
                                ifg_count_next = 8'd0;
                            end
                            s_axis_tready_next = 1'b1;
                            state_next = STATE_IDLE;
                        end
                    end else begin
                        if (ifg_count_next > 8'd4) begin
                            state_next = STATE_IFG;
                        end else begin
                            s_axis_tready_next = 1'b1;
                            state_next = STATE_IDLE;
                        end
                    end
                end else begin
                    state_next = STATE_WAIT_END;
                end
            end else begin
                state_next = STATE_WAIT_END;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_ptr_reg <= 16'd0;

        ifg_count_reg <= 8'd0;
        deficit_idle_count_reg <= 2'd0;

        s_axis_tready_reg <= 1'b0;

        xgmii_txd_reg <= {8{XGMII_IDLE}};
        xgmii_txc_reg <= 8'b11111111;

        crc_state <= 32'hFFFFFFFF;

        lanes_swapped <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        ifg_count_reg <= ifg_count_next;
        deficit_idle_count_reg <= deficit_idle_count_next;

        s_axis_tready_reg <= s_axis_tready_next;

        if (swap_lanes || (lanes_swapped && !unswap_lanes)) begin
            lanes_swapped <= 1'b1;
            xgmii_txd_reg <= {xgmii_txd_next[31:0], swap_txd};
            xgmii_txc_reg <= {xgmii_txc_next[3:0], swap_txc};
        end else begin
            lanes_swapped <= 1'b0;
            xgmii_txd_reg <= xgmii_txd_next;
            xgmii_txc_reg <= xgmii_txc_next;
        end

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next7;
        end
    end

    s_tdata_reg <= s_tdata_next;
    s_tkeep_reg <= s_tkeep_next;

    swap_txd <= xgmii_txd_next[63:32];
    swap_txc <= xgmii_txc_next[7:4];
end

endmodule
