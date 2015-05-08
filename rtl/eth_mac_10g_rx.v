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
module eth_mac_10g_rx
(
    input  wire        clk,
    input  wire        rst,

    /*
     * XGMII input
     */
    input  wire [63:0] xgmii_rxd,
    input  wire [7:0]  xgmii_rxc,

    /*
     * AXI output
     */
    output wire [63:0] output_axis_tdata,
    output wire [7:0]  output_axis_tkeep,
    output wire        output_axis_tvalid,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Status
     */
    output wire        error_bad_frame,
    output wire        error_bad_fcs
);

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PAYLOAD = 3'd1,
    STATE_LAST = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [63:0] xgmii_rxd_masked;

reg [63:0] fcs_output_tdata_0;
reg [63:0] fcs_output_tdata_1;
reg [7:0] fcs_output_tkeep_0;
reg [7:0] fcs_output_tkeep_1;

reg [7:0] last_cycle_tkeep_reg = 0, last_cycle_tkeep_next;
reg last_cycle_tuser_reg = 0, last_cycle_tuser_next;

reg lanes_swapped = 0;
reg [31:0] swap_rxd = 0;
reg [3:0] swap_rxc = 0;

reg [63:0] xgmii_rxd_d0 = 64'h0707070707070707;
reg [63:0] xgmii_rxd_d1 = 64'h0707070707070707;

reg [7:0] xgmii_rxc_d0 = 8'b11111111;
reg [7:0] xgmii_rxc_d1 = 8'b11111111;

reg [63:0] output_axis_tdata_reg = 0, output_axis_tdata_next;
reg [7:0] output_axis_tkeep_reg = 0, output_axis_tkeep_next;
reg output_axis_tvalid_reg = 0, output_axis_tvalid_next;
reg output_axis_tlast_reg = 0, output_axis_tlast_next;
reg output_axis_tuser_reg = 0, output_axis_tuser_next;

reg error_bad_frame_reg = 0, error_bad_frame_next;
reg error_bad_fcs_reg = 0, error_bad_fcs_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

reg [31:0] crc_next3_save = 0;
reg [31:0] crc_next4_save = 0;
reg [31:0] crc_next5_save = 0;
reg [31:0] crc_next6_save = 0;
reg [31:0] crc_next7_save = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

assign error_bad_frame = error_bad_frame_reg;
assign error_bad_fcs = error_bad_fcs_reg;

eth_crc_8
eth_crc_8_inst (
    .data_in(xgmii_rxd_d0[7:0]),
    .crc_state(crc_state),
    .crc_next(crc_next0)
);

eth_crc_16
eth_crc_16_inst (
    .data_in(xgmii_rxd_d0[15:0]),
    .crc_state(crc_state),
    .crc_next(crc_next1)
);

eth_crc_24
eth_crc_24_inst (
    .data_in(xgmii_rxd_d0[23:0]),
    .crc_state(crc_state),
    .crc_next(crc_next2)
);

eth_crc_32
eth_crc_32_inst (
    .data_in(xgmii_rxd_d0[31:0]),
    .crc_state(crc_state),
    .crc_next(crc_next3)
);

eth_crc_40
eth_crc_40_inst (
    .data_in(xgmii_rxd_d0[39:0]),
    .crc_state(crc_state),
    .crc_next(crc_next4)
);

eth_crc_48
eth_crc_48_inst (
    .data_in(xgmii_rxd_d0[47:0]),
    .crc_state(crc_state),
    .crc_next(crc_next5)
);

eth_crc_56
eth_crc_56_inst (
    .data_in(xgmii_rxd_d0[55:0]),
    .crc_state(crc_state),
    .crc_next(crc_next6)
);

eth_crc_64
eth_crc_64_inst (
    .data_in(xgmii_rxd_d0[63:0]),
    .crc_state(crc_state),
    .crc_next(crc_next7)
);

// FCS cycle calculation
always @* begin
    case (xgmii_rxc_d0)
        8'b11111111: begin
            fcs_output_tdata_0 = {~crc_next3_save[31:0], xgmii_rxd_d1[31:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00001111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11111110: begin
            fcs_output_tdata_0 = {~crc_next4_save[23:0], xgmii_rxd_d1[39:0]};
            fcs_output_tdata_1 = {56'd0, ~crc_next4_save[31:24]};
            fcs_output_tkeep_0 = 8'b00011111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11111100: begin
            fcs_output_tdata_0 = {~crc_next5_save[15:0], xgmii_rxd_d1[47:0]};
            fcs_output_tdata_1 = {48'd0, ~crc_next5_save[31:16]};
            fcs_output_tkeep_0 = 8'b00111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11111000: begin
            fcs_output_tdata_0 = {~crc_next6_save[7:0], xgmii_rxd_d1[55:0]};
            fcs_output_tdata_1 = {40'd0, ~crc_next6_save[31:8]};
            fcs_output_tkeep_0 = 8'b01111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11110000: begin
            fcs_output_tdata_0 = xgmii_rxd_d1;
            fcs_output_tdata_1 = {32'd0, ~crc_next7_save[31:0]};
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11100000: begin
            fcs_output_tdata_0 = {24'd0, ~crc_next0[31:0], xgmii_rxd_d0[7:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00000001;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b11000000: begin
            fcs_output_tdata_0 = {16'd0, ~crc_next1[31:0], xgmii_rxd_d0[15:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00000011;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b10000000: begin
            fcs_output_tdata_0 = {8'd0, ~crc_next2[31:0], xgmii_rxd_d0[23:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00000111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        default: begin
            fcs_output_tdata_0 = 0;
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 0;
            fcs_output_tkeep_1 = 0;
        end
    endcase
end

// detect control characters
reg [7:0] detect_start;
reg [7:0] detect_term;
reg [7:0] detect_error;

integer i;

always @* begin
    for (i = 0; i < 8; i = i + 1) begin
        detect_start[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == 8'hfb);
        detect_term[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == 8'hfd);
        detect_error[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == 8'hfe);
    end
end

// mask errors to within packet
reg [7:0] detect_error_masked;

always @* begin
    case (detect_term)
    8'b00000000: begin
        detect_error_masked = detect_error;
    end
    8'b00000001: begin
        detect_error_masked = 0;
    end
    8'b00000010: begin
        detect_error_masked = detect_error[0];
    end
    8'b00000100: begin
        detect_error_masked = detect_error[1:0];
    end
    8'b00001000: begin
        detect_error_masked = detect_error[2:0];
    end
    8'b00010000: begin
        detect_error_masked = detect_error[3:0];
    end
    8'b00100000: begin
        detect_error_masked = detect_error[4:0];
    end
    8'b01000000: begin
        detect_error_masked = detect_error[5:0];
    end
    8'b10000000: begin
        detect_error_masked = detect_error[6:0];
    end
    endcase
end

// Mask input data
integer j;

always @* begin
    for (j = 0; j < 8; j = j + 1) begin
        xgmii_rxd_masked[j*8 +: 8] = xgmii_rxc_d0[j] ? 8'd0 : xgmii_rxd_d0[j*8 +: 8];
    end
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 0;
    update_crc = 0;

    last_cycle_tkeep_next = last_cycle_tkeep_reg;
    last_cycle_tuser_next = last_cycle_tuser_reg;

    output_axis_tdata_next = 0;
    output_axis_tkeep_next = 0;
    output_axis_tvalid_next = 0;
    output_axis_tlast_next = 0;
    output_axis_tuser_next = 0;

    error_bad_frame_next = 0;
    error_bad_fcs_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for packet
            reset_crc = 1;

            if (xgmii_rxc_d1[0] && xgmii_rxd_d1[7:0] == 8'hfb) begin
                // start condition
                reset_crc = 0;
                update_crc = 1;
                state_next = STATE_PAYLOAD;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // read payload
            update_crc = 1;

            output_axis_tdata_next = xgmii_rxd_d1;
            output_axis_tkeep_next = ~xgmii_rxc_d1;
            output_axis_tvalid_next = 1;
            output_axis_tlast_next = 0;
            output_axis_tuser_next = 0;

            if (xgmii_rxc_d1[0] && xgmii_rxd_d1[7:0] == 8'hfb) begin
                // start condition in packet - flag as bad and restart
                output_axis_tlast_next = 1;
                output_axis_tuser_next = 1;
                error_bad_frame_next = 1;
                reset_crc = 1;
                state_next = STATE_PAYLOAD;
            end else if (detect_error_masked) begin
                // error condition
                output_axis_tlast_next = 1;
                output_axis_tuser_next = 1;
                error_bad_frame_next = 1;
                reset_crc = 1;
                state_next = STATE_IDLE;
            end else if (detect_term) begin
                if (detect_term[4:0]) begin
                    // end this cycle
                    reset_crc = 1;
                    output_axis_tkeep_next = fcs_output_tkeep_0;
                    output_axis_tlast_next = 1;
                    if (xgmii_rxd_masked != fcs_output_tdata_1 || xgmii_rxd_d1 != fcs_output_tdata_0) begin
                        output_axis_tuser_next = 1;
                        error_bad_frame_next = 1;
                        error_bad_fcs_next = 1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    // need extra cycle
                    last_cycle_tkeep_next = fcs_output_tkeep_0;
                    last_cycle_tuser_next = 0;
                    if (xgmii_rxd_masked != fcs_output_tdata_0) begin
                        error_bad_frame_next = 1;
                        error_bad_fcs_next = 1;
                        last_cycle_tuser_next = 1;
                    end
                    state_next = STATE_LAST;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_LAST: begin
            // last cycle of packet
            output_axis_tdata_next = xgmii_rxd_d1;
            output_axis_tkeep_next = last_cycle_tkeep_reg;
            output_axis_tvalid_next = 1;
            output_axis_tlast_next = 1;
            output_axis_tuser_next = last_cycle_tuser_reg;

            reset_crc = 1;

            if (xgmii_rxc_d1[0] && xgmii_rxd_d1[7:0] == 8'hfb) begin
                // start condition
                state_next = STATE_PAYLOAD;
            end else begin
                state_next = STATE_IDLE;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;

        last_cycle_tkeep_reg <= 0;
        last_cycle_tuser_reg <= 0;

        error_bad_frame_reg <= 0;
        error_bad_fcs_reg <= 0;
        
        crc_state <= 32'hFFFFFFFF;

        xgmii_rxd_d0 <= 64'h0707070707070707;
        xgmii_rxd_d1 <= 64'h0707070707070707;

        xgmii_rxc_d0 <= 8'b11111111;
        xgmii_rxc_d1 <= 8'b11111111;

        lanes_swapped <= 0;
        swap_rxd <= 0;
        swap_rxc <= 0;
    end else begin
        state_reg <= state_next;

        output_axis_tdata_reg <= output_axis_tdata_next;
        output_axis_tkeep_reg <= output_axis_tkeep_next;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tlast_reg <= output_axis_tlast_next;
        output_axis_tuser_reg <= output_axis_tuser_next;

        last_cycle_tkeep_reg <= last_cycle_tkeep_next;
        last_cycle_tuser_reg <= last_cycle_tuser_next;

        error_bad_frame_reg <= error_bad_frame_next;
        error_bad_fcs_reg <= error_bad_fcs_next;

        if (xgmii_rxc[0] && xgmii_rxd[7:0] == 8'hfb) begin
            lanes_swapped <= 0;
            xgmii_rxd_d0 <= xgmii_rxd;
            xgmii_rxc_d0 <= xgmii_rxc;
        end else if (xgmii_rxc[4] && xgmii_rxd[39:32] == 8'hfb) begin
            lanes_swapped <= 1;
            xgmii_rxd_d0 <= 64'h0707070707070707;
            xgmii_rxc_d0 <= 8'b11111111;
        end else if (lanes_swapped) begin
            xgmii_rxd_d0 <= {xgmii_rxd[31:0], swap_rxd};
            xgmii_rxc_d0 <= {xgmii_rxc[3:0], swap_rxc};
        end else begin
            xgmii_rxd_d0 <= xgmii_rxd;
            xgmii_rxc_d0 <= xgmii_rxc;
        end

        swap_rxd <= xgmii_rxd[63:32];
        swap_rxc <= xgmii_rxc[7:4];

        xgmii_rxd_d1 <= xgmii_rxd_d0;
        xgmii_rxc_d1 <= xgmii_rxc_d0;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;

            crc_next3_save <= 0;
            crc_next4_save <= 0;
            crc_next5_save <= 0;
            crc_next6_save <= 0;
            crc_next7_save <= 0;
        end else if (update_crc) begin
            crc_state <= crc_next7;

            crc_next3_save <= crc_next3;
            crc_next4_save <= crc_next4;
            crc_next5_save <= crc_next5;
            crc_next6_save <= crc_next6;
            crc_next7_save <= crc_next7;
        end
    end
end

endmodule
