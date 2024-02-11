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
 * PTP time distribution PHC
 */
module ptp_td_phc #
(
    parameter PERIOD_NS_NUM = 32,
    parameter PERIOD_NS_DENOM = 5
)
(
    input  wire         clk,
    input  wire         rst,

    /*
     * ToD timestamp control
     */
    input  wire [47:0]  input_ts_tod_s,
    input  wire [29:0]  input_ts_tod_ns,
    input  wire         input_ts_tod_valid,
    output wire         input_ts_tod_ready,
    input  wire [29:0]  input_ts_tod_offset_ns,
    input  wire         input_ts_tod_offset_valid,
    output wire         input_ts_tod_offset_ready,

    /*
     * Relative timestamp control
     */
    input  wire [47:0]  input_ts_rel_ns,
    input  wire         input_ts_rel_valid,
    output wire         input_ts_rel_ready,
    input  wire [31:0]  input_ts_rel_offset_ns,
    input  wire         input_ts_rel_offset_valid,
    output wire         input_ts_rel_offset_ready,

    /*
     * Fractional ns control
     */
    input  wire [31:0]  input_ts_offset_fns,
    input  wire         input_ts_offset_valid,
    output wire         input_ts_offset_ready,

    /*
     * Period control
     */
    input  wire [7:0]   input_period_ns,
    input  wire [31:0]  input_period_fns,
    input  wire         input_period_valid,
    output wire         input_period_ready,
    input  wire [15:0]  input_drift_num,
    input  wire [15:0]  input_drift_denom,
    input  wire         input_drift_valid,
    output wire         input_drift_ready,

    /*
     * Time distribution serial data output
     */
    output wire         ptp_td_sdo,

    /*
     * PPS output
     */
    output wire         output_pps,
    output wire         output_pps_str
);

localparam INC_NS_W = 9+8;

localparam FNS_W = 32;

localparam PERIOD_NS = PERIOD_NS_NUM / PERIOD_NS_DENOM;
localparam PERIOD_NS_REM = PERIOD_NS_NUM - PERIOD_NS*PERIOD_NS_DENOM;
localparam PERIOD_FNS = (PERIOD_NS_REM * {32'd1, {FNS_W{1'b0}}}) / PERIOD_NS_DENOM;
localparam PERIOD_FNS_REM = (PERIOD_NS_REM * {32'd1, {FNS_W{1'b0}}}) - PERIOD_FNS*PERIOD_NS_DENOM;

localparam [30:0] NS_PER_S = 31'd1_000_000_000;

reg [7:0] period_ns_reg = PERIOD_NS;
reg [FNS_W-1:0] period_fns_reg = PERIOD_FNS;

reg [15:0] drift_num_reg = PERIOD_FNS_REM;
reg [15:0] drift_denom_reg = PERIOD_NS_DENOM;
reg [15:0] drift_cnt_reg = 0;
reg [15:0] drift_cnt_d1_reg = 0;
reg drift_apply_reg = 1'b0;
reg [23:0] drift_acc_reg = 0;

reg [INC_NS_W-1:0] ts_inc_ns_reg = 0;
reg [FNS_W-1:0] ts_fns_reg = 0;

reg [32:0] ts_rel_ns_inc_reg = 0;
reg [47:0] ts_rel_ns_reg = 0;
reg ts_rel_updated_reg = 1'b0;

reg [47:0] ts_tod_s_reg = 0;
reg [29:0] ts_tod_ns_reg = 0;
reg ts_tod_updated_reg = 1'b0;

reg [31:0] ts_tod_offset_ns_reg = 0;

reg [47:0] ts_tod_alt_s_reg = 0;
reg [31:0] ts_tod_alt_offset_ns_reg = 0;

reg [7:0] td_update_cnt_reg = 0;
reg td_update_reg = 1'b0;
reg [1:0] td_msg_i_reg = 0;

reg input_ts_tod_ready_reg = 1'b0;
reg input_ts_tod_offset_ready_reg = 1'b0;
reg input_ts_rel_ready_reg = 1'b0;
reg input_ts_rel_offset_ready_reg = 1'b0;
reg input_ts_offset_ready_reg = 1'b0;

reg [17*14-1:0] td_shift_reg = {17*14{1'b1}};

reg [15:0] pps_gen_fns_reg = 0;
reg [9:0]  pps_gen_ns_inc_reg = 0;
reg [30:0] pps_gen_ns_reg = 31'h40000000;

reg [9:0] pps_delay_reg = 0;
reg pps_reg = 0;
reg pps_str_reg = 0;

reg [3:0] update_state_reg = 0;

reg [47:0] adder_a_reg = 0;
reg [47:0] adder_b_reg = 0;
reg adder_cin_reg = 0;
reg [47:0] adder_sum_reg = 0;
reg adder_cout_reg = 0;
reg adder_busy_reg = 0;

assign input_ts_tod_ready = input_ts_tod_ready_reg;
assign input_ts_tod_offset_ready = input_ts_tod_offset_ready_reg;
assign input_ts_rel_ready = input_ts_rel_ready_reg;
assign input_ts_rel_offset_ready = input_ts_rel_offset_ready_reg;
assign input_ts_offset_ready = input_ts_offset_ready_reg;

assign input_period_ready = 1'b1;
assign input_drift_ready = 1'b1;

assign output_pps = pps_reg;
assign output_pps_str = pps_str_reg;

assign ptp_td_sdo = td_shift_reg[0];

always @(posedge clk) begin
    drift_apply_reg <= 1'b0;

    input_ts_tod_ready_reg <= 1'b0;
    input_ts_tod_offset_ready_reg <= 1'b0;
    input_ts_rel_ready_reg <= 1'b0;
    input_ts_rel_offset_ready_reg <= 1'b0;
    input_ts_offset_ready_reg <= 1'b0;

    // update and message generation cadence
    {td_update_reg, td_update_cnt_reg} <= td_update_cnt_reg + 1;

    // latch drift setting
    if (input_drift_valid) begin
        drift_num_reg <= input_drift_num;
        drift_denom_reg <= input_drift_denom;
    end

    // drift
    if (drift_denom_reg) begin
        if (drift_cnt_reg == 0) begin
            drift_cnt_reg <= drift_denom_reg - 1;
            drift_apply_reg <= 1'b1;
        end else begin
            drift_cnt_reg <= drift_cnt_reg - 1;
        end
    end else begin
        drift_cnt_reg <= 0;
    end

    drift_cnt_d1_reg <= drift_cnt_reg;

    // drift accumulation
    if (drift_apply_reg) begin
        drift_acc_reg <= drift_acc_reg + drift_num_reg;
    end

    // latch period setting
    if (input_period_valid) begin
        period_ns_reg <= input_period_ns;
        period_fns_reg <= input_period_fns;
    end

    // PPS generation
    if (td_update_reg) begin
        {pps_gen_ns_inc_reg, pps_gen_fns_reg} <= {period_ns_reg, period_fns_reg[31:16]} + ts_fns_reg[31:16];
    end else begin
        {pps_gen_ns_inc_reg, pps_gen_fns_reg} <= {period_ns_reg, period_fns_reg[31:16]} + pps_gen_fns_reg;
    end
    pps_gen_ns_reg <= pps_gen_ns_reg + pps_gen_ns_inc_reg;

    if (!pps_gen_ns_reg[30]) begin
        pps_delay_reg <= 14*17 + 32 + 240;
        pps_gen_ns_reg[30] <= 1'b1;
    end

    pps_reg <= 1'b0;

    if (ts_tod_ns_reg[29]) begin
        pps_str_reg <= 1'b0;
    end

    if (pps_delay_reg) begin
        pps_delay_reg <= pps_delay_reg - 1;
        if (pps_delay_reg == 1) begin
            pps_reg <= 1'b1;
            pps_str_reg <= 1'b1;
        end
    end

    // update state machine
    {adder_cout_reg, adder_sum_reg} <= adder_a_reg + adder_b_reg + adder_cin_reg;
    adder_busy_reg <= 1'b0;

    // computes the following:
    // {ts_inc_ns_reg, ts_fns_reg} = drift_acc_reg + $signed(input_ts_offset_fns) + {period_ns_reg, period_fns_reg} * 256 + ts_fns_reg
    // ts_rel_ns_reg = ts_rel_ns_reg + ts_inc_ns_reg + $signed(input_ts_rel_offset_ns);
    // ts_tod_ns_reg = ts_tod_ns_reg + ts_inc_ns_reg + $signed(input_ts_tod_offset_ns);
    //   if that borrowed,
    //     ts_tod_ns_reg = ts_tod_ns_reg + NS_PER_S
    //     ts_tod_s_reg = ts_tod_s_reg - 1
    //   else
    //     pps_gen_ns_reg = ts_tod_ns_reg - NS_PER_S
    //       if that did not borrow,
    //         ts_tod_ns_reg = ts_tod_ns_reg - NS_PER_S
    //         ts_tod_s_reg = ts_tod_s_reg + 1
    // ts_tod_offset_ns_reg = ts_tod_ns_reg - ts_rel_ns_reg
    //   if ts_tod_ns_reg[29]
    //     ts_tod_alt_offset_ns_reg = ts_tod_offset_ns_reg - NS_PER_S
    //     ts_tod_alt_s_reg = ts_tod_s_reg + 1
    //   else
    //     ts_tod_alt_offset_ns_reg = ts_tod_offset_ns_reg + NS_PER_S
    //     ts_tod_alt_s_reg = ts_tod_s_reg - 1

    if (!adder_busy_reg) begin
        case (update_state_reg)
            0: begin
                // idle

                // set relative timestamp
                if (input_ts_rel_valid) begin
                    ts_rel_ns_reg <= input_ts_rel_ns;
                    input_ts_rel_ready_reg <= 1'b1;
                    ts_rel_updated_reg <= 1'b1;
                end

                // set ToD timestamp
                if (input_ts_tod_valid) begin
                    ts_tod_s_reg <= input_ts_tod_s;
                    ts_tod_ns_reg <= input_ts_tod_ns;
                    input_ts_tod_ready_reg <= 1'b1;
                    ts_tod_updated_reg <= 1'b1;
                end

                // compute period 1 - add drift and requested offset
                if (drift_apply_reg) begin
                    adder_a_reg <= drift_acc_reg + drift_num_reg;
                end else begin
                    adder_a_reg <= drift_acc_reg;
                end
                adder_b_reg <= input_ts_offset_valid ? $signed(input_ts_offset_fns) : 0;
                adder_cin_reg <= 0;

                if (td_update_reg) begin
                    drift_acc_reg <= 0;
                    input_ts_offset_ready_reg <= input_ts_offset_valid;
                    update_state_reg <= 1;
                    adder_busy_reg <= 1'b1;
                end else begin
                    update_state_reg <= 0;
                end
            end
            1: begin
                // compute period 2 - add drift and offset to period
                adder_a_reg <= adder_sum_reg;
                adder_b_reg <= {period_ns_reg, period_fns_reg, 8'd0};
                adder_cin_reg <= 0;

                update_state_reg <= 2;
                adder_busy_reg <= 1'b1;
            end
            2: begin
                // compute next fns
                adder_a_reg <= adder_sum_reg;
                adder_b_reg <= ts_fns_reg;
                adder_cin_reg <= 0;

                update_state_reg <= 3;
                adder_busy_reg <= 1'b1;
            end
            3: begin
                // store fns
                {ts_inc_ns_reg, ts_fns_reg} <= {adder_cout_reg, adder_sum_reg};

                // compute relative timestamp 1 - add previous value and increment
                adder_a_reg <= ts_rel_ns_reg;
                adder_b_reg <= {adder_cout_reg, adder_sum_reg} >> FNS_W; // ts_inc_ns_reg
                adder_cin_reg <= 0;

                update_state_reg <= 4;
                adder_busy_reg <= 1'b1;
            end
            4: begin
                // compute relative timestamp 2 - add offset
                adder_a_reg <= adder_sum_reg;
                adder_b_reg <= 0;
                adder_cin_reg <= 0;

                // offset relative timestamp if requested
                if (input_ts_rel_offset_valid) begin
                    adder_b_reg <= $signed(input_ts_rel_offset_ns);
                    input_ts_rel_offset_ready_reg <= 1'b1;
                    ts_rel_updated_reg <= 1'b1;
                end

                update_state_reg <= 5;
                adder_busy_reg <= 1'b1;
            end
            5: begin
                // store relative timestamp
                ts_rel_ns_reg <= adder_sum_reg;

                // compute ToD timestamp 1 - add previous value and increment
                adder_a_reg <= ts_tod_ns_reg;
                adder_b_reg <= ts_inc_ns_reg;
                adder_cin_reg <= 0;

                update_state_reg <= 6;
                adder_busy_reg <= 1'b1;
            end
            6: begin
                // compute ToD timestamp 2 - add offset
                adder_a_reg <= adder_sum_reg;
                adder_b_reg <= 0;
                adder_cin_reg <= 0;

                // offset ToD timestamp if requested
                if (input_ts_tod_offset_valid) begin
                    adder_b_reg <= $signed(input_ts_tod_offset_ns);
                    input_ts_tod_offset_ready_reg <= 1'b1;
                    ts_tod_updated_reg <= 1'b1;
                end
                
                update_state_reg <= 7;
                adder_busy_reg <= 1'b1;
            end
            7: begin
                // compute ToD timestamp 3 - check for underflow/overflow
                ts_tod_ns_reg <= adder_sum_reg;

                if (adder_b_reg[47] && !adder_cout_reg) begin
                    // borrowed; add 1 billion
                    adder_a_reg <= adder_sum_reg;
                    adder_b_reg <= NS_PER_S;
                    adder_cin_reg <= 0;

                    update_state_reg <= 8;
                    adder_busy_reg <= 1'b1;
                end else begin
                    // did not borrow; subtract 1 billion to check for overflow
                    adder_a_reg <= adder_sum_reg;
                    adder_b_reg <= -NS_PER_S;
                    adder_cin_reg <= 0;

                    update_state_reg <= 9;
                    adder_busy_reg <= 1'b1;
                end
            end
            8: begin
                // seconds decrement
                ts_tod_ns_reg <= adder_sum_reg;
                pps_gen_ns_reg[30] <= 1'b1;

                adder_a_reg <= ts_tod_s_reg;
                adder_b_reg <= -1;
                adder_cin_reg <= 0;

                update_state_reg <= 10;
                adder_busy_reg <= 1'b1;
            end
            9: begin
                // seconds increment
                pps_gen_ns_reg <= adder_sum_reg;

                if (!adder_cout_reg) begin
                    // borrowed; leave seconds alone

                    adder_a_reg <= ts_tod_s_reg;
                    adder_b_reg <= 0;
                    adder_cin_reg <= 0;
                end else begin
                    // did not borrow; increment seconds
                    ts_tod_ns_reg <= adder_sum_reg;

                    adder_a_reg <= ts_tod_s_reg;
                    adder_b_reg <= 1;
                    adder_cin_reg <= 0;
                end

                update_state_reg <= 10;
                adder_busy_reg <= 1'b1;
            end
            10: begin
                // store seconds
                ts_tod_s_reg <= adder_sum_reg;

                // compute offset
                adder_a_reg <= ts_tod_ns_reg;
                adder_b_reg <= ~ts_rel_ns_reg;
                adder_cin_reg <= 1;

                update_state_reg <= 11;
                adder_busy_reg <= 1'b1;
            end
            11: begin
                // store offset
                ts_tod_offset_ns_reg <= adder_sum_reg;

                adder_a_reg <= adder_sum_reg;
                adder_b_reg <= -NS_PER_S;
                adder_cin_reg <= 0;

                if (ts_tod_ns_reg[29:27] == 3'b111) begin
                    // latter portion of second; compute offset for next second
                    adder_b_reg <= -NS_PER_S;
                    update_state_reg <= 12;
                    adder_busy_reg <= 1'b1;
                end else begin
                    // former portion of second; compute offset for previous second
                    adder_b_reg <= NS_PER_S;
                    update_state_reg <= 14;
                    adder_busy_reg <= 1'b1;
                end
            end
            12: begin
                // store alternate offset for next second
                ts_tod_alt_offset_ns_reg <= adder_sum_reg;

                adder_a_reg <= ts_tod_s_reg;
                adder_b_reg <= 1;
                adder_cin_reg <= 0;

                update_state_reg <= 13;
                adder_busy_reg <= 1'b1;
            end
            13: begin
                // store alternate second for next second
                ts_tod_alt_s_reg <= adder_sum_reg;

                update_state_reg <= 0;
            end
            14: begin
                // store alternate offset for previous second
                ts_tod_alt_offset_ns_reg <= adder_sum_reg;

                adder_a_reg <= ts_tod_s_reg;
                adder_b_reg <= -1;
                adder_cin_reg <= 0;

                update_state_reg <= 15;
                adder_busy_reg <= 1'b1;
            end
            15: begin
                // store alternate second for previous second
                ts_tod_alt_s_reg <= adder_sum_reg;

                update_state_reg <= 0;
            end
            default: begin
                // invalid state; return to idle
                update_state_reg <= 0;
            end
        endcase
    end

    // time distribution message generation
    td_shift_reg <= {1'b1, td_shift_reg} >> 1;

    if (td_update_reg) begin
        // word 0: control
        td_shift_reg[17*0+0 +: 1] <= 1'b0;
        td_shift_reg[17*0+1 +: 16] <= 0;
        td_shift_reg[17*0+1+0 +: 4] <= td_msg_i_reg;
        td_shift_reg[17*0+1+8 +: 1] <= ts_rel_updated_reg;
        td_shift_reg[17*0+1+9 +: 1] <= ts_tod_s_reg[0];
        ts_rel_updated_reg <= 1'b0;

        case (td_msg_i_reg)
            2'd0: begin
                // msg 0 word 1: current ToD ns 15:0
                td_shift_reg[17*1+0 +: 1] <= 1'b0;
                td_shift_reg[17*1+1 +: 16] <= ts_tod_ns_reg[15:0];
                // msg 0 word 2: current ToD ns 29:16
                td_shift_reg[17*2+0 +: 1] <= 1'b0;
                td_shift_reg[17*2+1+0 +: 15] <= ts_tod_ns_reg[29:16];
                td_shift_reg[17*2+1+15 +: 1] <= ts_tod_updated_reg;
                ts_tod_updated_reg <= 1'b0;
                // msg 0 word 3: current ToD seconds 15:0
                td_shift_reg[17*3+0 +: 1] <= 1'b0;
                td_shift_reg[17*3+1 +: 16] <= ts_tod_s_reg[15:0];
                // msg 0 word 4: current ToD seconds 31:16
                td_shift_reg[17*4+0 +: 1] <= 1'b0;
                td_shift_reg[17*4+1 +: 16] <= ts_tod_s_reg[31:16];
                // msg 0 word 5: current ToD seconds 47:32
                td_shift_reg[17*5+0 +: 1] <= 1'b0;
                td_shift_reg[17*5+1 +: 16] <= ts_tod_s_reg[47:32];
                
                td_msg_i_reg <= 2'd1;
            end
            2'd1: begin
                // msg 1 word 1: current ToD ns offset 15:0
                td_shift_reg[17*1+0 +: 1] <= 1'b0;
                td_shift_reg[17*1+1 +: 16] <= ts_tod_offset_ns_reg[15:0];
                // msg 1 word 2: current ToD ns offset 31:16
                td_shift_reg[17*2+0 +: 1] <= 1'b0;
                td_shift_reg[17*2+1 +: 16] <= ts_tod_offset_ns_reg[31:16];
                // msg 1 word 3: drift num
                td_shift_reg[17*3+0 +: 1] <= 1'b0;
                td_shift_reg[17*3+1 +: 16] <= drift_num_reg;
                // msg 1 word 4: drift denom
                td_shift_reg[17*4+0 +: 1] <= 1'b0;
                td_shift_reg[17*4+1 +: 16] <= drift_denom_reg;
                // msg 1 word 5: drift state
                td_shift_reg[17*5+0 +: 1] <= 1'b0;
                td_shift_reg[17*5+1 +: 16] <= drift_cnt_d1_reg;
                
                td_msg_i_reg <= 2'd2;
            end
            2'd2: begin
                // msg 2 word 1: alternate ToD ns offset 15:0
                td_shift_reg[17*1+0 +: 1] <= 1'b0;
                td_shift_reg[17*1+1 +: 16] <= ts_tod_alt_offset_ns_reg[15:0];
                // msg 2 word 2: alternate ToD ns offset 31:16
                td_shift_reg[17*2+0 +: 1] <= 1'b0;
                td_shift_reg[17*2+1 +: 16] <= ts_tod_alt_offset_ns_reg[31:16];
                // msg 2 word 3: alternate ToD seconds 15:0
                td_shift_reg[17*3+0 +: 1] <= 1'b0;
                td_shift_reg[17*3+1 +: 16] <= ts_tod_alt_s_reg[15:0];
                // msg 2 word 4: alternate ToD seconds 31:16
                td_shift_reg[17*4+0 +: 1] <= 1'b0;
                td_shift_reg[17*4+1 +: 16] <= ts_tod_alt_s_reg[31:16];
                // msg 2 word 5: alternate ToD seconds 47:32
                td_shift_reg[17*5+0 +: 1] <= 1'b0;
                td_shift_reg[17*5+1 +: 16] <= ts_tod_alt_s_reg[47:32];
                
                td_msg_i_reg <= 2'd0;
            end
        endcase

        // word 6: current fns 15:0
        td_shift_reg[17*6+0 +: 1] <= 1'b0;
        td_shift_reg[17*6+1 +: 16] <= ts_fns_reg[15:0];
        // word 7: current fns 31:16
        td_shift_reg[17*7+0 +: 1] <= 1'b0;
        td_shift_reg[17*7+1 +: 16] <= ts_fns_reg[31:16];
        // word 8: current ns 15:0
        td_shift_reg[17*8+0 +: 1] <= 1'b0;
        td_shift_reg[17*8+1 +: 16] <= ts_rel_ns_reg[15:0];
        // word 9: current ns 31:16
        td_shift_reg[17*9+0 +: 1] <= 1'b0;
        td_shift_reg[17*9+1 +: 16] <= ts_rel_ns_reg[31:16];
        // word 10: current ns 47:32
        td_shift_reg[17*10+0 +: 1] <= 1'b0;
        td_shift_reg[17*10+1 +: 16] <= ts_rel_ns_reg[47:32];
        // word 11: current phase increment fns 15:0
        td_shift_reg[17*11+0 +: 1] <= 1'b0;
        td_shift_reg[17*11+1 +: 16] <= period_fns_reg[15:0];
        // word 12: current phase increment fns 31:16
        td_shift_reg[17*12+0 +: 1] <= 1'b0;
        td_shift_reg[17*12+1 +: 16] <= period_fns_reg[31:16];
        // word 13: current phase increment ns 7:0 + crc
        td_shift_reg[17*13+0 +: 1] <= 1'b0;
        td_shift_reg[17*13+1 +: 16] <= period_ns_reg[7:0];
    end

    if (rst) begin
        period_ns_reg <= PERIOD_NS;
        period_fns_reg <= PERIOD_FNS;
        drift_num_reg <= PERIOD_FNS_REM;
        drift_denom_reg <= PERIOD_NS_DENOM;
        drift_cnt_reg <= 0;
        drift_acc_reg <= 0;
        ts_fns_reg <= 0;
        ts_rel_ns_reg <= 0;
        ts_rel_updated_reg <= 0;
        ts_tod_s_reg <= 0;
        ts_tod_ns_reg <= 0;
        ts_tod_updated_reg <= 0;

        pps_gen_ns_reg[30] <= 1'b1;
        pps_delay_reg <= 0;
        pps_reg <= 0;
        pps_str_reg <= 0;

        td_update_cnt_reg <= 0;
        td_update_reg <= 1'b0;
        td_msg_i_reg <= 0;

        td_shift_reg <= {17*14{1'b1}};
    end
end

endmodule

`resetall
