/*

Copyright (c) 2019 Alex Forencich

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
 * PTP period out module
 */
module ptp_perout #
(
    parameter FNS_ENABLE = 1,
    parameter OUT_START_S = 48'h0,
    parameter OUT_START_NS = 30'h0,
    parameter OUT_START_FNS = 16'h0000,
    parameter OUT_PERIOD_S = 48'd1,
    parameter OUT_PERIOD_NS = 30'd0,
    parameter OUT_PERIOD_FNS = 16'h0000,
    parameter OUT_WIDTH_S = 48'h0,
    parameter OUT_WIDTH_NS = 30'd1000,
    parameter OUT_WIDTH_FNS = 16'h0000
)
(
    input  wire         clk,
    input  wire         rst,

    /*
     * Timestamp input from PTP clock
     */
    input  wire [95:0]  input_ts_96,
    input  wire         input_ts_step,

    /*
     * Control
     */
    input  wire         enable,
    input  wire [95:0]  input_start,
    input  wire         input_start_valid,
    input  wire [95:0]  input_period,
    input  wire         input_period_valid,
    input  wire [95:0]  input_width,
    input  wire         input_width_valid,

    /*
     * Status
     */
    output wire         locked,
    output wire         error,

    /*
     * Pulse output
     */
    output wire         output_pulse
);

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_UPDATE_RISE_1 = 3'd1,
    STATE_UPDATE_RISE_2 = 3'd2,
    STATE_UPDATE_FALL_1 = 3'd3,
    STATE_UPDATE_FALL_2 = 3'd4,
    STATE_WAIT_EDGE = 3'd5;

reg [2:0] state_reg = STATE_IDLE, state_next;

reg [47:0] time_s_reg = 0;
reg [30:0] time_ns_reg = 0;
reg [15:0] time_fns_reg = 0;

reg [47:0] next_rise_s_reg = 0, next_rise_s_next;
reg [30:0] next_rise_ns_reg = 0, next_rise_ns_next;
reg [15:0] next_rise_fns_reg = 0, next_rise_fns_next;

reg [47:0] next_fall_s_reg = 0, next_fall_s_next;
reg [30:0] next_fall_ns_reg = 0, next_fall_ns_next;
reg [15:0] next_fall_fns_reg = 0, next_fall_fns_next;

reg [47:0] start_s_reg = OUT_START_S;
reg [30:0] start_ns_reg = OUT_START_NS;
reg [15:0] start_fns_reg = OUT_START_FNS;

reg [47:0] period_s_reg = OUT_PERIOD_S;
reg [30:0] period_ns_reg = OUT_PERIOD_NS;
reg [15:0] period_fns_reg = OUT_PERIOD_FNS;

reg [47:0] width_s_reg = OUT_WIDTH_S;
reg [30:0] width_ns_reg = OUT_WIDTH_NS;
reg [15:0] width_fns_reg = OUT_WIDTH_FNS;

reg [29:0] ts_96_ns_inc_reg = 0, ts_96_ns_inc_next;
reg [15:0] ts_96_fns_inc_reg = 0, ts_96_fns_inc_next;
reg [30:0] ts_96_ns_ovf_reg = 0, ts_96_ns_ovf_next;
reg [15:0] ts_96_fns_ovf_reg = 0, ts_96_fns_ovf_next;

reg locked_reg = 1'b0, locked_next;
reg error_reg = 1'b0, error_next;
reg level_reg = 1'b0, level_next;
reg output_reg = 1'b0, output_next;

assign locked = locked_reg;
assign error = error_reg;
assign output_pulse = output_reg;

always @* begin
    state_next = STATE_IDLE;

    next_rise_s_next = next_rise_s_reg;
    next_rise_ns_next = next_rise_ns_reg;
    next_rise_fns_next = next_rise_fns_reg;

    next_fall_s_next = next_fall_s_reg;
    next_fall_ns_next = next_fall_ns_reg;
    next_fall_fns_next = next_fall_fns_reg;

    ts_96_ns_inc_next = ts_96_ns_inc_reg;
    ts_96_fns_inc_next = ts_96_fns_inc_reg;

    ts_96_ns_ovf_next = ts_96_ns_ovf_reg;
    ts_96_fns_ovf_next = ts_96_fns_ovf_reg;

    locked_next = locked_reg;
    error_next = error_reg;
    level_next = level_reg;
    output_next = output_reg;

    if (input_start_valid || input_period_valid || input_ts_step) begin
        locked_next = 1'b0;
        level_next = 1'b0;
        output_next = 1'b0;
        error_next = input_ts_step;
        state_next = STATE_IDLE;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // set next rise to start time
                next_rise_s_next = start_s_reg;
                next_rise_ns_next = start_ns_reg;
                if (FNS_ENABLE) begin
                    next_rise_fns_next = start_fns_reg;
                end
                locked_next = 1'b0;
                level_next = 1'b0;
                output_next = 1'b0;
                state_next = STATE_UPDATE_FALL_1;
            end
            STATE_UPDATE_RISE_1: begin
                // set next rise time to next rise time plus period
                {ts_96_ns_inc_next, ts_96_fns_inc_next} = {next_rise_ns_reg, next_rise_fns_reg} + {period_ns_reg, period_fns_reg};
                {ts_96_ns_ovf_next, ts_96_fns_ovf_next} = {next_rise_ns_reg, next_rise_fns_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, 16'd0};
                state_next = STATE_UPDATE_RISE_2;
            end
            STATE_UPDATE_RISE_2: begin
                if (!ts_96_ns_ovf_reg[30]) begin
                    // if the overflow lookahead did not borrow, one second has elapsed
                    next_rise_s_next = next_rise_s_reg + period_s_reg + 1;
                    next_rise_ns_next = ts_96_ns_ovf_reg;
                    next_rise_fns_next = ts_96_fns_ovf_reg;
                end else begin
                    // no increment seconds field
                    next_rise_s_next = next_rise_s_reg + period_s_reg;
                    next_rise_ns_next = ts_96_ns_inc_reg;
                    next_rise_fns_next = ts_96_fns_inc_reg;
                end
                state_next = STATE_WAIT_EDGE;
            end
            STATE_UPDATE_FALL_1: begin
                // set next fall time to next rise time plus width
                {ts_96_ns_inc_next, ts_96_fns_inc_next} = {next_rise_ns_reg, next_rise_fns_reg} + {width_ns_reg, width_fns_reg};
                {ts_96_ns_ovf_next, ts_96_fns_ovf_next} = {next_rise_ns_reg, next_rise_fns_reg} + {width_ns_reg, width_fns_reg} - {31'd1_000_000_000, 16'd0};
                state_next = STATE_UPDATE_FALL_2;
            end
            STATE_UPDATE_FALL_2: begin
                if (!ts_96_ns_ovf_reg[30]) begin
                    // if the overflow lookahead did not borrow, one second has elapsed
                    next_fall_s_next = next_rise_s_reg + width_s_reg + 1;
                    next_fall_ns_next = ts_96_ns_ovf_reg;
                    next_fall_fns_next = ts_96_fns_ovf_reg;
                end else begin
                    // no increment seconds field
                    next_fall_s_next = next_rise_s_reg + width_s_reg;
                    next_fall_ns_next = ts_96_ns_inc_reg;
                    next_fall_fns_next = ts_96_fns_inc_reg;
                end
                state_next = STATE_WAIT_EDGE;
            end
            STATE_WAIT_EDGE: begin
                if ((time_s_reg > next_rise_s_reg) || (time_s_reg == next_rise_s_reg && {time_ns_reg, time_fns_reg} > {next_rise_ns_reg, next_rise_fns_reg})) begin
                    // rising edge
                    level_next = 1'b1;
                    output_next = enable && locked_reg;
                    state_next = STATE_UPDATE_RISE_1;
                end else if ((time_s_reg > next_fall_s_reg) || (time_s_reg == next_fall_s_reg && {time_ns_reg, time_fns_reg} > {next_fall_ns_reg, next_fall_fns_reg})) begin
                    // falling edge
                    level_next = 1'b0;
                    output_next = 1'b0;
                    state_next = STATE_UPDATE_FALL_1;
                end else begin
                    locked_next = locked_reg || level_reg;
                    error_next = error_reg && !(locked_reg || level_reg);
                    state_next = STATE_WAIT_EDGE;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    state_reg <= state_next;

    time_s_reg <= input_ts_96[95:48];
    time_ns_reg <= input_ts_96[45:16];
    if (FNS_ENABLE) begin
        time_fns_reg <= input_ts_96[15:0];
    end

    if (input_start_valid) begin
        start_s_reg <= input_start[95:48];
        start_ns_reg <= input_start[45:16];
        if (FNS_ENABLE) begin
            start_fns_reg <= input_start[15:0];
        end
    end

    if (input_period_valid) begin
        period_s_reg <= input_period[95:48];
        period_ns_reg <= input_period[45:16];
        if (FNS_ENABLE) begin
            period_fns_reg <= input_period[15:0];
        end
    end

    if (input_width_valid) begin
        width_s_reg <= input_width[95:48];
        width_ns_reg <= input_width[45:16];
        if (FNS_ENABLE) begin
            width_fns_reg <= input_width[15:0];
        end
    end

    next_rise_s_reg <= next_rise_s_next;
    next_rise_ns_reg <= next_rise_ns_next;
    if (FNS_ENABLE) begin
        next_rise_fns_reg <= next_rise_fns_next;
    end

    next_fall_s_reg <= next_fall_s_next;
    next_fall_ns_reg <= next_fall_ns_next;
    if (FNS_ENABLE) begin
        next_fall_fns_reg <= next_fall_fns_next;
    end

    ts_96_ns_inc_reg <= ts_96_ns_inc_next;
    if (FNS_ENABLE) begin
        ts_96_fns_inc_reg <= ts_96_fns_inc_next;
    end

    ts_96_ns_ovf_reg <= ts_96_ns_ovf_next;
    if (FNS_ENABLE) begin
        ts_96_fns_ovf_reg <= ts_96_fns_ovf_next;
    end

    locked_reg <= locked_next;
    error_reg <= error_next;
    level_reg <= level_next;
    output_reg <= output_next;

    if (rst) begin
        state_reg <= STATE_IDLE;

        start_s_reg <= OUT_START_S;
        start_ns_reg <= OUT_START_NS;
        start_fns_reg <= OUT_START_FNS;

        period_s_reg <= OUT_PERIOD_S;
        period_ns_reg <= OUT_PERIOD_NS;
        period_fns_reg <= OUT_PERIOD_FNS;

        width_s_reg <= OUT_WIDTH_S;
        width_ns_reg <= OUT_WIDTH_NS;
        width_fns_reg <= OUT_WIDTH_FNS;

        locked_reg <= 1'b0;
        error_reg <= 1'b0;
        output_reg <= 1'b0;
    end
end

endmodule

`resetall
