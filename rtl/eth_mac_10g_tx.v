/*

Copyright (c) 2015 Alex Forencich

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
 * 10G Ethernet MAC
 */
module eth_mac_10g_tx #
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
    input  wire [63:0] input_axis_tdata,
    input  wire [7:0]  input_axis_tkeep,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,

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

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PAYLOAD = 3'd1,
    STATE_PAD = 3'd2,
    STATE_FCS = 3'd3,
    STATE_IFG = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg swap_lanes;
reg unswap_lanes;

reg lanes_swapped = 0;
reg [31:0] swap_txd = 0;
reg [3:0] swap_txc = 0;

reg [63:0] input_axis_tdata_masked;

reg [63:0] fcs_input_tdata;
reg [7:0]  fcs_input_tkeep;

reg [63:0] fcs_output_txd_0;
reg [63:0] fcs_output_txd_1;
reg [7:0] fcs_output_txc_0;
reg [7:0] fcs_output_txc_1;

reg [7:0] ifg_offset;

reg [7:0] frame_ptr_reg = 0, frame_ptr_next;

reg [7:0] ifg_count_reg = 0, ifg_count_next;
reg [1:0] deficit_idle_count_reg = 0, deficit_idle_count_next;

reg [63:0] last_cycle_txd_reg = 0, last_cycle_txd_next;
reg [7:0] last_cycle_txc_reg = 0, last_cycle_txc_next;

reg busy_reg = 0;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

reg [63:0] xgmii_txd_reg = 64'h0707070707070707, xgmii_txd_next;
reg [7:0] xgmii_txc_reg = 8'b11111111, xgmii_txc_next;

assign input_axis_tready = input_axis_tready_reg;

assign xgmii_txd = xgmii_txd_reg;
assign xgmii_txc = xgmii_txc_reg;

eth_crc_8
eth_crc_8_inst (
    .data_in(fcs_input_tdata[7:0]),
    .crc_state(crc_state),
    .crc_next(crc_next0)
);

eth_crc_16
eth_crc_16_inst (
    .data_in(fcs_input_tdata[15:0]),
    .crc_state(crc_state),
    .crc_next(crc_next1)
);

eth_crc_24
eth_crc_24_inst (
    .data_in(fcs_input_tdata[23:0]),
    .crc_state(crc_state),
    .crc_next(crc_next2)
);

eth_crc_32
eth_crc_32_inst (
    .data_in(fcs_input_tdata[31:0]),
    .crc_state(crc_state),
    .crc_next(crc_next3)
);

eth_crc_40
eth_crc_40_inst (
    .data_in(fcs_input_tdata[39:0]),
    .crc_state(crc_state),
    .crc_next(crc_next4)
);

eth_crc_48
eth_crc_48_inst (
    .data_in(fcs_input_tdata[47:0]),
    .crc_state(crc_state),
    .crc_next(crc_next5)
);

eth_crc_56
eth_crc_56_inst (
    .data_in(fcs_input_tdata[55:0]),
    .crc_state(crc_state),
    .crc_next(crc_next6)
);

eth_crc_64
eth_crc_64_inst (
    .data_in(fcs_input_tdata[63:0]),
    .crc_state(crc_state),
    .crc_next(crc_next7)
);

function [3:0] keep2count;
    input [7:0] k;
    case (k)
        8'b00000000: keep2count = 0;
        8'b00000001: keep2count = 1;
        8'b00000011: keep2count = 2;
        8'b00000111: keep2count = 3;
        8'b00001111: keep2count = 4;
        8'b00011111: keep2count = 5;
        8'b00111111: keep2count = 6;
        8'b01111111: keep2count = 7;
        8'b11111111: keep2count = 8;
    endcase
endfunction

function [7:0] count2keep;
    input [3:0] k;
    case (k)
        4'd0: count2keep = 8'b00000000;
        4'd1: count2keep = 8'b00000001;
        4'd2: count2keep = 8'b00000011;
        4'd3: count2keep = 8'b00000111;
        4'd4: count2keep = 8'b00001111;
        4'd5: count2keep = 8'b00011111;
        4'd6: count2keep = 8'b00111111;
        4'd7: count2keep = 8'b01111111;
        4'd8: count2keep = 8'b11111111;
    endcase
endfunction

// Mask input data
always @* begin
    input_axis_tdata_masked[ 7: 0] = input_axis_tkeep[0] ? input_axis_tdata[ 7: 0] : 8'd0;
    input_axis_tdata_masked[15: 8] = input_axis_tkeep[1] ? input_axis_tdata[15: 8] : 8'd0;
    input_axis_tdata_masked[23:16] = input_axis_tkeep[2] ? input_axis_tdata[23:16] : 8'd0;
    input_axis_tdata_masked[31:24] = input_axis_tkeep[3] ? input_axis_tdata[31:24] : 8'd0;
    input_axis_tdata_masked[39:32] = input_axis_tkeep[4] ? input_axis_tdata[39:32] : 8'd0;
    input_axis_tdata_masked[47:40] = input_axis_tkeep[5] ? input_axis_tdata[47:40] : 8'd0;
    input_axis_tdata_masked[55:48] = input_axis_tkeep[6] ? input_axis_tdata[55:48] : 8'd0;
    input_axis_tdata_masked[63:56] = input_axis_tkeep[7] ? input_axis_tdata[63:56] : 8'd0;
end

// FCS cycle calculation
always @* begin
    case (fcs_input_tkeep)
        8'b00000001: begin
            fcs_output_txd_0 = {24'h0707fd, ~crc_next0[31:0], fcs_input_tdata[7:0]};
            fcs_output_txd_1 = {63'h0707070707070707};
            fcs_output_txc_0 = 8'b11100000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 3;
        end
        8'b00000011: begin
            fcs_output_txd_0 = {16'h07fd, ~crc_next1[31:0], fcs_input_tdata[15:0]};
            fcs_output_txd_1 = {63'h0707070707070707};
            fcs_output_txc_0 = 8'b11000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 2;
        end
        8'b00000111: begin
            fcs_output_txd_0 = {8'hfd, ~crc_next2[31:0], fcs_input_tdata[23:0]};
            fcs_output_txd_1 = {63'h0707070707070707};
            fcs_output_txc_0 = 8'b10000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 1;
        end
        8'b00001111: begin
            fcs_output_txd_0 = {~crc_next3[31:0], fcs_input_tdata[31:0]};
            fcs_output_txd_1 = {63'h07070707070707fd};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8;
        end
        8'b00011111: begin
            fcs_output_txd_0 = {~crc_next4[23:0], fcs_input_tdata[39:0]};
            fcs_output_txd_1 = {56'h070707070707fd, ~crc_next4[31:24]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111110;
            ifg_offset = 7;
        end
        8'b00111111: begin
            fcs_output_txd_0 = {~crc_next5[15:0], fcs_input_tdata[47:0]};
            fcs_output_txd_1 = {48'h0707070707fd, ~crc_next5[31:16]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111100;
            ifg_offset = 6;
        end
        8'b01111111: begin
            fcs_output_txd_0 = {~crc_next6[7:0], fcs_input_tdata[55:0]};
            fcs_output_txd_1 = {40'h07070707fd, ~crc_next6[31:8]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111000;
            ifg_offset = 5;
        end
        8'b11111111: begin
            fcs_output_txd_0 = fcs_input_tdata;
            fcs_output_txd_1 = {32'h070707fd, ~crc_next7[31:0]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11110000;
            ifg_offset = 4;
        end
        default: begin
            fcs_output_txd_0 = 0;
            fcs_output_txd_1 = 0;
            fcs_output_txc_0 = 0;
            fcs_output_txc_1 = 0;
            ifg_offset = 0;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 0;
    update_crc = 0;

    swap_lanes = 0;
    unswap_lanes = 0;

    frame_ptr_next = frame_ptr_reg;

    ifg_count_next = ifg_count_reg;
    deficit_idle_count_next = deficit_idle_count_reg;

    last_cycle_txd_next = last_cycle_txd_reg;
    last_cycle_txc_next = last_cycle_txc_reg;

    input_axis_tready_next = 0;

    fcs_input_tdata = 0;
    fcs_input_tkeep = 0;

    // XGMII idle
    xgmii_txd_next = 64'h0707070707070707;
    xgmii_txc_next = 8'b11111111;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;
            reset_crc = 1;

            // XGMII idle
            xgmii_txd_next = 64'h0707070707070707;
            xgmii_txc_next = 8'b11111111;

            if (input_axis_tvalid) begin
                // XGMII start and preamble
                if (ifg_count_reg > 0) begin
                    // need to send more idles - swap lanes
                    swap_lanes = 1;
                end else begin
                    // no more idles - unswap
                    unswap_lanes = 1;
                end
                xgmii_txd_next = 64'hd5555555555555fb;
                xgmii_txc_next = 8'b00000001;
                input_axis_tready_next = 1;
                state_next = STATE_PAYLOAD;
            end else begin
                ifg_count_next = 0;
                deficit_idle_count_next = 0;
                unswap_lanes = 1;
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            update_crc = 1;
            input_axis_tready_next = 1;

            xgmii_txd_next = input_axis_tdata_masked;
            xgmii_txc_next = 8'b00000000;

            fcs_input_tdata = input_axis_tdata_masked;
            fcs_input_tkeep = input_axis_tkeep;

            if (input_axis_tvalid) begin
                frame_ptr_next = frame_ptr_reg + keep2count(input_axis_tkeep);
                if (input_axis_tlast) begin
                    input_axis_tready_next = 0;
                    if (input_axis_tuser) begin
                        xgmii_txd_next = 64'h070707fdfefefefe;
                        xgmii_txc_next = 8'b11111111;
                        frame_ptr_next = 0;
                        ifg_count_next = 8;
                        state_next = STATE_IFG;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                            fcs_input_tkeep = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 8;

                            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                                input_axis_tready_next = 0;
                                state_next = STATE_PAD;
                            end else begin
                                fcs_input_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                                xgmii_txd_next = fcs_output_txd_0;
                                xgmii_txc_next = fcs_output_txc_0;
                                last_cycle_txd_next = fcs_output_txd_1;
                                last_cycle_txc_next = fcs_output_txc_1;

                                reset_crc = 1;
                                frame_ptr_next = 0;
                                input_axis_tready_next = 0;

                                ifg_count_next = (ifg_delay > 12 ? ifg_delay : 12) - ifg_offset + (lanes_swapped ? 4 : 0) + deficit_idle_count_reg;
                                if (fcs_output_txc_1 != 8'hff || fcs_output_txc_0 == 0) begin
                                    state_next = STATE_FCS;
                                end else begin
                                    state_next = STATE_IFG;
                                end
                            end
                        end else begin
                            xgmii_txd_next = fcs_output_txd_0;
                            xgmii_txc_next = fcs_output_txc_0;
                            last_cycle_txd_next = fcs_output_txd_1;
                            last_cycle_txc_next = fcs_output_txc_1;

                            reset_crc = 1;
                            frame_ptr_next = 0;
                            input_axis_tready_next = 0;

                            ifg_count_next = (ifg_delay > 12 ? ifg_delay : 12) - ifg_offset + (lanes_swapped ? 4 : 0) + deficit_idle_count_reg;
                            if (fcs_output_txc_1 != 8'hff || fcs_output_txc_0 == 0) begin
                                state_next = STATE_FCS;
                            end else begin
                                state_next = STATE_IFG;
                            end
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                xgmii_txd_next = 64'h070707fdfefefefe;
                xgmii_txc_next = 8'b11111111;
                frame_ptr_next = 0;
                ifg_count_next = 8;
                state_next = STATE_IFG;
            end
        end
        STATE_PAD: begin
            input_axis_tready_next = 0;

            xgmii_txd_next = 0;
            xgmii_txc_next = 8'b00000000;

            fcs_input_tdata = 0;
            fcs_input_tkeep = 8'hff;

            update_crc = 1;
            frame_ptr_next = frame_ptr_reg + 8;

            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                state_next = STATE_PAD;
            end else begin
                fcs_input_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                xgmii_txd_next = fcs_output_txd_0;
                xgmii_txc_next = fcs_output_txc_0;
                last_cycle_txd_next = fcs_output_txd_1;
                last_cycle_txc_next = fcs_output_txc_1;

                reset_crc = 1;
                frame_ptr_next = 0;
                input_axis_tready_next = 0;

                ifg_count_next = (ifg_delay > 12 ? ifg_delay : 12) - ifg_offset + (lanes_swapped ? 4 : 0) + deficit_idle_count_reg;
                if (fcs_output_txc_1 != 8'hff || fcs_output_txc_0 == 0) begin
                    state_next = STATE_FCS;
                end else begin
                    state_next = STATE_IFG;
                end
            end
        end
        STATE_FCS: begin
            // last cycle
            input_axis_tready_next = 0;

            xgmii_txd_next = last_cycle_txd_reg;
            xgmii_txc_next = last_cycle_txc_reg;
            
            reset_crc = 1;
            frame_ptr_next = 0;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 4) begin
                        deficit_idle_count_next = ifg_count_next - 4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 0;
                    end
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 4) begin
                    state_next = STATE_IFG;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_IFG: begin
            // send IFG
            if (ifg_count_reg > 8) begin
                ifg_count_next = ifg_count_reg - 8;
            end else begin
                ifg_count_next = 0;
            end

            reset_crc = 1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 4) begin
                        deficit_idle_count_next = ifg_count_next - 4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 0;
                    end
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 4) begin
                    state_next = STATE_IFG;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        
        frame_ptr_reg <= 0;

        ifg_count_reg <= 0;
        deficit_idle_count_reg <= 0;

        last_cycle_txd_reg <= 0;
        last_cycle_txc_reg <= 0;
        
        input_axis_tready_reg <= 0;

        xgmii_txd_reg <= 64'h0707070707070707;
        xgmii_txc_reg <= 8'b11111111;

        crc_state <= 32'hFFFFFFFF;

        lanes_swapped <= 0;
        swap_txd <= 0;
        swap_txc <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        ifg_count_reg <= ifg_count_next;
        deficit_idle_count_reg <= deficit_idle_count_next;

        last_cycle_txd_reg <= last_cycle_txd_next;
        last_cycle_txc_reg <= last_cycle_txc_next;

        input_axis_tready_reg <= input_axis_tready_next;

        if (lanes_swapped) begin
            if (unswap_lanes) begin
                lanes_swapped <= 0;
                xgmii_txd_reg <= xgmii_txd_next;
                xgmii_txc_reg <= xgmii_txc_next;
            end else begin
                xgmii_txd_reg <= {xgmii_txd_next[31:0], swap_txd};
                xgmii_txc_reg <= {xgmii_txc_next[3:0], swap_txc};
            end
        end else begin
            if (swap_lanes) begin
                lanes_swapped <= 1;
                xgmii_txd_reg <= {xgmii_txd_next[31:0], 32'h07070707};
                xgmii_txc_reg <= {xgmii_txc_next[3:0], 4'b1111};
            end else begin
                xgmii_txd_reg <= xgmii_txd_next;
                xgmii_txc_reg <= xgmii_txc_next;
            end
        end

        swap_txd <= xgmii_txd_next[63:32];
        swap_txc <= xgmii_txc_next[7:4];

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next7;
        end
    end
end

endmodule
