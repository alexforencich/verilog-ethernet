/*

Copyright (c) 2019-2021 Alex Forencich

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
 * PTP clock CDC (clock domain crossing) module
 */
module ptp_clock_cdc #
(
    parameter TS_WIDTH = 96,
    parameter NS_WIDTH = 4,
    parameter FNS_WIDTH = 16,
    parameter USE_SAMPLE_CLOCK = 1,
    parameter LOG_RATE = 3
)
(
    input  wire                 input_clk,
    input  wire                 input_rst,
    input  wire                 output_clk,
    input  wire                 output_rst,
    input  wire                 sample_clk,

    /*
     * Timestamp inputs from source PTP clock
     */
    input  wire [TS_WIDTH-1:0]  input_ts,
    input  wire                 input_ts_step,

    /*
     * Timestamp outputs
     */
    output wire [TS_WIDTH-1:0]  output_ts,
    output wire                 output_ts_step,

    /*
     * PPS output
     */
    output wire                 output_pps,

    /*
     * Status
     */
    output wire                 locked
);

// bus width assertions
initial begin
    if (TS_WIDTH != 64 && TS_WIDTH != 96) begin
        $error("Error: Timestamp width must be 64 or 96");
        $finish;
    end
end

parameter TS_NS_WIDTH = TS_WIDTH == 96 ? 30 : 48;

parameter PHASE_CNT_WIDTH = LOG_RATE;
parameter PHASE_ACC_WIDTH = PHASE_CNT_WIDTH+16;

parameter LOG_SAMPLE_SYNC_RATE = LOG_RATE;
parameter SAMPLE_ACC_WIDTH = LOG_SAMPLE_SYNC_RATE+2;

parameter DEST_SYNC_LOCK_WIDTH = 7;
parameter PTP_LOCK_WIDTH = 8;

reg [NS_WIDTH-1:0] period_ns_reg = 0, period_ns_next;
reg [FNS_WIDTH-1:0] period_fns_reg = 0, period_fns_next;

reg [47:0] src_ts_s_capt_reg = 0;
reg [TS_NS_WIDTH-1:0] src_ts_ns_capt_reg = 0;
reg [FNS_WIDTH-1:0] src_ts_fns_capt_reg = 0;
reg src_ts_step_capt_reg = 0;

reg [47:0] dest_ts_s_capt_reg = 0;
reg [TS_NS_WIDTH-1:0] dest_ts_ns_capt_reg = 0;
reg [FNS_WIDTH-1:0] dest_ts_fns_capt_reg = 0;

reg [47:0] ts_s_sync_reg = 0;
reg [TS_NS_WIDTH-1:0] ts_ns_sync_reg = 0;
reg [FNS_WIDTH-1:0] ts_fns_sync_reg = 0;
reg ts_step_sync_reg = 0;

reg [47:0] ts_s_reg = 0, ts_s_next;
reg [TS_NS_WIDTH-1:0] ts_ns_reg = 0, ts_ns_next;
reg [FNS_WIDTH-1:0] ts_fns_reg = 0, ts_fns_next;
reg [TS_NS_WIDTH-1:0] ts_ns_inc_reg = 0, ts_ns_inc_next;
reg [FNS_WIDTH-1:0] ts_fns_inc_reg = 0, ts_fns_inc_next;
reg [TS_NS_WIDTH+1-1:0] ts_ns_ovf_reg = {TS_NS_WIDTH+1{1'b1}}, ts_ns_ovf_next;
reg [FNS_WIDTH-1:0] ts_fns_ovf_reg = {FNS_WIDTH{1'b1}}, ts_fns_ovf_next;

reg ts_step_reg = 1'b0, ts_step_next;

reg pps_reg = 0;

reg [PHASE_CNT_WIDTH-1:0] src_phase_reg = {PHASE_CNT_WIDTH{1'b0}};
reg [PHASE_ACC_WIDTH-1:0] dest_phase_reg = {PHASE_ACC_WIDTH{1'b0}}, dest_phase_next;
reg [PHASE_ACC_WIDTH-1:0] dest_phase_inc_reg = {PHASE_ACC_WIDTH{1'b0}}, dest_phase_inc_next;

reg src_sync_reg = 1'b0;
reg src_update_reg = 1'b0;
reg dest_sync_reg = 1'b0, dest_sync_next = 1'b0;
reg dest_update_reg = 1'b0, dest_update_next = 1'b0;

reg src_sync_sync1_reg = 1'b0;
reg src_sync_sync2_reg = 1'b0;
reg src_sync_sync3_reg = 1'b0;
reg dest_sync_sync1_reg = 1'b0;
reg dest_sync_sync2_reg = 1'b0;
reg dest_sync_sync3_reg = 1'b0;

reg src_sync_sample_sync1_reg = 1'b0;
reg src_sync_sample_sync2_reg = 1'b0;
reg src_sync_sample_sync3_reg = 1'b0;
reg dest_sync_sample_sync1_reg = 1'b0;
reg dest_sync_sample_sync2_reg = 1'b0;
reg dest_sync_sample_sync3_reg = 1'b0;

reg [SAMPLE_ACC_WIDTH-1:0] sample_acc_reg = 0, sample_acc_next = 0;
reg [SAMPLE_ACC_WIDTH-1:0] sample_acc_out_reg = 0;
reg [LOG_SAMPLE_SYNC_RATE-1:0] sample_cnt_reg = 0;
reg sample_update_reg = 1'b0;
reg sample_update_sync1_reg = 1'b0;
reg sample_update_sync2_reg = 1'b0;
reg sample_update_sync3_reg = 1'b0;

generate

if (TS_WIDTH == 96) begin
    assign output_ts[95:48] = ts_s_reg;
    assign output_ts[47:46] = 2'b00;
    assign output_ts[45:16] = ts_ns_reg;
    assign output_ts[15:0]  = FNS_WIDTH > 16 ? ts_fns_reg >> (FNS_WIDTH-16) : ts_fns_reg << (16-FNS_WIDTH);
end else if (TS_WIDTH == 64) begin
    assign output_ts[63:16] = ts_ns_reg;
    assign output_ts[15:0]  = FNS_WIDTH > 16 ? ts_fns_reg >> (FNS_WIDTH-16) : ts_fns_reg << (16-FNS_WIDTH);
end

endgenerate

assign output_ts_step = ts_step_reg;

assign output_pps = pps_reg;

// source PTP clock capture and sync logic
reg input_ts_step_reg = 1'b0;

always @(posedge input_clk) begin
    input_ts_step_reg <= input_ts_step || input_ts_step_reg;

    {src_update_reg, src_phase_reg} <= src_phase_reg+1;

    if (src_update_reg) begin
        // capture source TS
        if (TS_WIDTH == 96) begin
            src_ts_s_capt_reg <= input_ts[95:48];
            src_ts_ns_capt_reg <= input_ts[45:16];
        end else begin
            src_ts_ns_capt_reg <= input_ts[63:16];
        end
        src_ts_fns_capt_reg <= FNS_WIDTH > 16 ? input_ts[15:0] << (FNS_WIDTH-16) : input_ts[15:0] >> (16-FNS_WIDTH);
        src_ts_step_capt_reg <= input_ts_step || input_ts_step_reg;
        input_ts_step_reg <= 1'b0;
        src_sync_reg <= !src_sync_reg;
    end

    if (input_rst) begin
        input_ts_step_reg <= 1'b0;

        src_phase_reg <= {PHASE_CNT_WIDTH{1'b0}};
        src_sync_reg <= 1'b0;
        src_update_reg <= 1'b0;
    end
end

// CDC logic
always @(posedge output_clk) begin
    src_sync_sync1_reg <= src_sync_reg;
    src_sync_sync2_reg <= src_sync_sync1_reg;
    src_sync_sync3_reg <= src_sync_sync2_reg;
    dest_sync_sync1_reg <= dest_sync_reg;
    dest_sync_sync2_reg <= dest_sync_sync1_reg;
    dest_sync_sync3_reg <= dest_sync_sync2_reg;
end

always @(posedge sample_clk) begin
    src_sync_sample_sync1_reg <= src_sync_reg;
    src_sync_sample_sync2_reg <= src_sync_sample_sync1_reg;
    src_sync_sample_sync3_reg <= src_sync_sample_sync2_reg;
    dest_sync_sample_sync1_reg <= dest_sync_reg;
    dest_sync_sample_sync2_reg <= dest_sync_sample_sync1_reg;
    dest_sync_sample_sync3_reg <= dest_sync_sample_sync2_reg;
end

reg edge_1_reg = 1'b0;
reg edge_2_reg = 1'b0;

reg [3:0] active_reg = 0;

always @(posedge sample_clk) begin
    if (USE_SAMPLE_CLOCK) begin
        // phase and frequency detector
        if (dest_sync_sample_sync2_reg && !dest_sync_sample_sync3_reg) begin
            if (src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg) begin
                edge_1_reg <= 1'b0;
                edge_2_reg <= 1'b0;
                active_reg[0] <= 1'b1;
            end else begin
                edge_1_reg <= !edge_2_reg;
                edge_2_reg <= 1'b0;
            end
        end else if (src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg) begin
            edge_1_reg <= 1'b0;
            edge_2_reg <= !edge_1_reg;
            active_reg[0] <= 1'b1;
        end

        // accumulator
        sample_acc_reg <= $signed(sample_acc_reg) + $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});

        sample_cnt_reg <= sample_cnt_reg + 1;

        if (sample_cnt_reg == 0) begin
            active_reg <= active_reg << 1;
            sample_acc_reg <= $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});
            sample_acc_out_reg <= sample_acc_reg;
            if (active_reg != 0) begin
                sample_update_reg <= !sample_update_reg;
            end
        end
    end
end

always @(posedge output_clk) begin
    sample_update_sync1_reg <= sample_update_reg;
    sample_update_sync2_reg <= sample_update_sync1_reg;
    sample_update_sync3_reg <= sample_update_sync2_reg;
end

reg [SAMPLE_ACC_WIDTH-1:0] sample_acc_sync_reg = 0;
reg sample_acc_sync_valid_reg = 0;

always @(posedge output_clk) begin
    if (USE_SAMPLE_CLOCK) begin
        // latch in synchronized counts from phase detector
        sample_acc_sync_valid_reg <= 1'b0;
        if (sample_update_sync2_reg ^ sample_update_sync3_reg) begin
            sample_acc_sync_reg <= sample_acc_out_reg;
            sample_acc_sync_valid_reg <= 1'b1;
        end
    end else begin
        // phase and frequency detector
        if (dest_sync_sync2_reg && !dest_sync_sync3_reg) begin
            if (src_sync_sync2_reg && !src_sync_sync3_reg) begin
                edge_1_reg <= 1'b0;
                edge_2_reg <= 1'b0;
                active_reg[0] <= 1'b1;
            end else begin
                edge_1_reg <= !edge_2_reg;
                edge_2_reg <= 1'b0;
            end
        end else if (src_sync_sync2_reg && !src_sync_sync3_reg) begin
            edge_1_reg <= 1'b0;
            edge_2_reg <= !edge_1_reg;
            active_reg[0] <= 1'b1;
        end

        // accumulator
        sample_acc_reg <= $signed(sample_acc_reg) + $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});

        sample_cnt_reg <= sample_cnt_reg + 1;

        sample_acc_sync_valid_reg <= 1'b0;
        if (sample_cnt_reg == 0) begin
            active_reg <= active_reg << 1;
            sample_acc_reg <= $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});
            sample_acc_sync_reg <= sample_acc_reg;
            if (active_reg != 0) begin
                sample_update_reg <= !sample_update_reg;
                sample_acc_sync_valid_reg <= 1'b1;
            end
        end
    end
end

reg [PHASE_ACC_WIDTH-1:0] dest_err_int_reg = 0, dest_err_int_next = 0;
reg [1:0] dest_ovf;

reg [DEST_SYNC_LOCK_WIDTH-1:0] dest_sync_lock_count_reg = 0, dest_sync_lock_count_next;
reg dest_sync_locked_reg = 1'b0, dest_sync_locked_next;

always @* begin
    {dest_update_next, dest_phase_next} = dest_phase_reg + dest_phase_inc_reg;
    dest_phase_inc_next = dest_phase_inc_reg;

    dest_err_int_next = dest_err_int_reg;

    dest_sync_lock_count_next = dest_sync_lock_count_reg;
    dest_sync_locked_next = dest_sync_locked_reg;

    if (sample_acc_sync_valid_reg) begin
        // updated sampled dest_phase error

        // time integral of error
        if (dest_sync_locked_reg) begin
            {dest_ovf, dest_err_int_next} = $signed({1'b0, dest_err_int_reg}) + $signed(sample_acc_sync_reg);
        end else begin
            {dest_ovf, dest_err_int_next} = $signed({1'b0, dest_err_int_reg}) + ($signed(sample_acc_sync_reg) * 2**6);
        end

        // saturate
        if (dest_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            dest_err_int_next = {PHASE_ACC_WIDTH{1'b0}};
        end else if (dest_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            dest_err_int_next = {PHASE_ACC_WIDTH{1'b1}};
        end

        // compute output
        if (dest_sync_locked_reg) begin
            {dest_ovf, dest_phase_inc_next} = $signed({1'b0, dest_err_int_reg}) + ($signed(sample_acc_sync_reg) * 2**4);
        end else begin
            {dest_ovf, dest_phase_inc_next} = $signed({1'b0, dest_err_int_reg}) + ($signed(sample_acc_sync_reg) * 2**10);
        end

        // saturate
        if (dest_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            dest_phase_inc_next = {PHASE_ACC_WIDTH{1'b0}};
        end else if (dest_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            dest_phase_inc_next = {PHASE_ACC_WIDTH{1'b1}};
        end

        // locked status
        if ($signed(sample_acc_sync_reg[SAMPLE_ACC_WIDTH-1:2]) == 0 || $signed(sample_acc_sync_reg[SAMPLE_ACC_WIDTH-1:1]) == -1) begin
            if (dest_sync_lock_count_reg == {DEST_SYNC_LOCK_WIDTH{1'b1}}) begin
                dest_sync_locked_next = 1'b1;
            end else begin
                dest_sync_lock_count_next = dest_sync_lock_count_reg + 1;
            end
        end else begin
            dest_sync_lock_count_next = 0;
            dest_sync_locked_next = 1'b0;
        end
    end
end

reg ts_sync_valid_reg = 1'b0;
reg ts_capt_valid_reg = 1'b0;

always @(posedge output_clk) begin
    dest_phase_reg <= dest_phase_next;
    dest_phase_inc_reg <= dest_phase_inc_next;
    dest_update_reg <= dest_update_next;

    if (dest_update_reg) begin
        // capture local TS
        dest_ts_s_capt_reg <= ts_s_reg;
        dest_ts_ns_capt_reg <= ts_ns_reg;
        dest_ts_fns_capt_reg <= ts_fns_reg;

        dest_sync_reg <= !dest_sync_reg;
        ts_capt_valid_reg <= 1'b1;
    end

    ts_sync_valid_reg <= 1'b0;

    if (src_sync_sync2_reg ^ src_sync_sync3_reg) begin
        // store captured source TS
        if (TS_WIDTH == 96) begin
            ts_s_sync_reg <= src_ts_s_capt_reg;
        end
        ts_ns_sync_reg <= src_ts_ns_capt_reg;
        ts_fns_sync_reg <= src_ts_fns_capt_reg;
        ts_step_sync_reg <= src_ts_step_capt_reg;

        ts_sync_valid_reg <= ts_capt_valid_reg;
        ts_capt_valid_reg <= 1'b0;
    end

    dest_err_int_reg <= dest_err_int_next;

    dest_sync_lock_count_reg <= dest_sync_lock_count_next;
    dest_sync_locked_reg <= dest_sync_locked_next;

    if (output_rst) begin
        dest_phase_reg <= {PHASE_ACC_WIDTH{1'b0}};
        dest_phase_inc_reg <= {PHASE_ACC_WIDTH{1'b0}};
        dest_sync_reg <= 1'b0;
        dest_update_reg <= 1'b0;

        dest_err_int_reg <= 0;

        dest_sync_lock_count_reg <= 0;
        dest_sync_locked_reg <= 1'b0;

        ts_sync_valid_reg <= 1'b0;
        ts_capt_valid_reg <= 1'b0;
    end
end

parameter TIME_ERR_INT_WIDTH = NS_WIDTH+FNS_WIDTH+16;

reg sec_mismatch_reg = 1'b0, sec_mismatch_next;
reg diff_valid_reg = 1'b0, diff_valid_next;
reg diff_corr_valid_reg = 1'b0, diff_corr_valid_next;

reg [47:0] ts_s_diff_reg = 0, ts_s_diff_next;
reg [TS_NS_WIDTH+1-1:0] ts_ns_diff_reg = 0, ts_ns_diff_next;
reg [FNS_WIDTH-1:0] ts_fns_diff_reg = 0, ts_fns_diff_next;

reg [16:0] ts_ns_diff_corr_reg = 0, ts_ns_diff_corr_next;
reg [FNS_WIDTH-1:0] ts_fns_diff_corr_reg = 0, ts_fns_diff_corr_next;

reg [TIME_ERR_INT_WIDTH-1:0] time_err_int_reg = 0, time_err_int_next;

reg [1:0] ptp_ovf;

reg [PTP_LOCK_WIDTH-1:0] ptp_lock_count_reg = 0, ptp_lock_count_next;
reg ptp_locked_reg = 1'b0, ptp_locked_next;

assign locked = ptp_locked_reg && dest_sync_locked_reg;

always @* begin
    period_ns_next = period_ns_reg;
    period_fns_next = period_fns_reg;

    ts_s_next = ts_s_reg;
    ts_ns_next = ts_ns_reg;
    ts_fns_next = ts_fns_reg;
    ts_ns_inc_next = ts_ns_inc_reg;
    ts_fns_inc_next = ts_fns_inc_reg;
    ts_ns_ovf_next = ts_ns_ovf_reg;
    ts_fns_ovf_next = ts_fns_ovf_reg;

    ts_step_next = 0;

    diff_valid_next = 1'b0;
    diff_corr_valid_next = 1'b0;

    sec_mismatch_next = sec_mismatch_reg;
    diff_valid_next = 1'b0;
    diff_corr_valid_next = 1'b0;
    
    ts_s_diff_next = ts_s_diff_reg;
    ts_ns_diff_next = ts_ns_diff_reg;
    ts_fns_diff_next = ts_fns_diff_reg;

    ts_ns_diff_corr_next = ts_ns_diff_corr_reg;
    ts_fns_diff_corr_next = ts_fns_diff_corr_reg;
    
    time_err_int_next = time_err_int_reg;

    ptp_lock_count_next = ptp_lock_count_reg;
    ptp_locked_next = ptp_locked_reg;

    // PTP clock
    if (TS_WIDTH == 96) begin
        // 96 bit timestamp
        if (!ts_ns_ovf_reg[30]) begin
            // if the overflow lookahead did not borrow, one second has elapsed
            // increment seconds field, pre-compute both normal increment and overflow values
            {ts_ns_inc_next, ts_fns_inc_next} = {ts_ns_ovf_reg, ts_fns_ovf_reg} + {period_ns_reg, period_fns_reg};
            {ts_ns_ovf_next, ts_fns_ovf_next} = {ts_ns_ovf_reg, ts_fns_ovf_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
            {ts_ns_next, ts_fns_next} = {ts_ns_ovf_reg, ts_fns_ovf_reg};
            ts_s_next = ts_s_next + 1;
        end else begin
            // no increment seconds field, pre-compute both normal increment and overflow values
            {ts_ns_inc_next, ts_fns_inc_next} = {ts_ns_inc_reg, ts_fns_inc_reg} + {period_ns_reg, period_fns_reg};
            {ts_ns_ovf_next, ts_fns_ovf_next} = {ts_ns_inc_reg, ts_fns_inc_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
            {ts_ns_next, ts_fns_next} = {ts_ns_inc_reg, ts_fns_inc_reg};
            ts_s_next = ts_s_next;
        end
    end else if (TS_WIDTH == 64) begin
        // 64 bit timestamp
        {ts_ns_next, ts_fns_next} = {ts_ns_reg, ts_fns_reg} + {period_ns_reg, period_fns_reg};
    end

    if (ts_sync_valid_reg) begin
        // Read new value
        if (TS_WIDTH == 96) begin
            if (ts_step_sync_reg || sec_mismatch_reg) begin
                // input stepped
                sec_mismatch_next = 1'b0;

                {ts_ns_inc_next, ts_fns_inc_next} = {ts_ns_sync_reg, ts_fns_sync_reg} + {period_ns_reg, period_fns_reg};
                {ts_ns_ovf_next, ts_fns_ovf_next} = {ts_ns_sync_reg, ts_fns_sync_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
                ts_s_next = ts_s_sync_reg;
                ts_ns_next = ts_ns_sync_reg;
                ts_fns_next = ts_fns_sync_reg;
                ts_step_next = 1;
            end else begin
                // compute difference
                sec_mismatch_next = 1'b0;
                diff_valid_next = 1'b1;
                ts_s_diff_next = ts_s_sync_reg - dest_ts_s_capt_reg;
                {ts_ns_diff_next, ts_fns_diff_next} = {ts_ns_sync_reg, ts_fns_sync_reg} - {dest_ts_ns_capt_reg, dest_ts_fns_capt_reg};
            end
        end else if (TS_WIDTH == 64) begin
            if (ts_step_sync_reg || sec_mismatch_reg) begin
                // input stepped
                sec_mismatch_next = 1'b0;

                ts_ns_next = ts_ns_sync_reg;
                ts_fns_next = ts_fns_sync_reg;
                ts_step_next = 1;
            end else begin
                // compute difference
                sec_mismatch_next = 1'b0;
                diff_valid_next = 1'b1;
                {ts_ns_diff_next, ts_fns_diff_next} = {ts_ns_sync_reg, ts_fns_sync_reg} - {dest_ts_ns_capt_reg, dest_ts_fns_capt_reg};
            end
        end
    end

    if (diff_valid_reg) begin
        // seconds field correction
        if (TS_WIDTH == 96) begin
            if ($signed(ts_s_diff_reg) == 0 && ($signed(ts_ns_diff_reg[30:16]) == 0 || $signed(ts_ns_diff_reg[30:16]) == -1)) begin
                // difference is small and no seconds difference; slew
                ts_ns_diff_corr_next = ts_ns_diff_reg[16:0];
                ts_fns_diff_corr_next = ts_fns_diff_reg;
                diff_corr_valid_next = 1'b1;
            end else if ($signed(ts_s_diff_reg) == 1 && ts_ns_diff_reg[30:16] == 15'h4465) begin
                // difference is small with 1 second difference; adjust and slew
                ts_ns_diff_corr_next = ts_ns_diff_reg[16:0] + 17'h0ca00;
                ts_fns_diff_corr_next = ts_fns_diff_reg;
                diff_corr_valid_next = 1'b1;
            end else if ($signed(ts_s_diff_reg) == -1 && ts_ns_diff_reg[30:16] == 15'h3b9a) begin
                // difference is small with 1 second difference; adjust and slew
                ts_ns_diff_corr_next = ts_ns_diff_reg[16:0] - 17'h0ca00;
                ts_fns_diff_corr_next = ts_fns_diff_reg;
                diff_corr_valid_next = 1'b1;
            end else begin
                // difference is too large; step the clock
                sec_mismatch_next = 1'b1;
            end
        end else if (TS_WIDTH == 64) begin
            if ($signed(ts_ns_diff_reg[47:16]) == 0 || $signed(ts_ns_diff_reg[47:16]) == -1) begin
                // difference is small enough to slew
                ts_ns_diff_corr_next = ts_ns_diff_reg[16:0];
                ts_fns_diff_corr_next = ts_fns_diff_reg;
                diff_corr_valid_next = 1'b1;
            end else begin
                // difference is too large; step the clock
                sec_mismatch_next = 1'b1;
            end
        end
    end

    if (diff_corr_valid_reg) begin
        // PI control

        // time integral of error
        if (ptp_locked_reg) begin
            {ptp_ovf, time_err_int_next} = $signed({1'b0, time_err_int_reg}) + $signed({ts_ns_diff_corr_reg, ts_fns_diff_corr_reg});
        end else begin
            {ptp_ovf, time_err_int_next} = $signed({1'b0, time_err_int_reg}) + ($signed({ts_ns_diff_corr_reg, ts_fns_diff_corr_reg}) * 2**3);
        end

        // saturate
        if (ptp_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            time_err_int_next = {TIME_ERR_INT_WIDTH{1'b0}};
        end else if (ptp_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            time_err_int_next = {TIME_ERR_INT_WIDTH{1'b1}};
        end

        // compute output
        if (ptp_locked_reg) begin
            {ptp_ovf, period_ns_next, period_fns_next} = ($signed({1'b0, time_err_int_reg}) / 2**16) + ($signed({ts_ns_diff_corr_reg, ts_fns_diff_corr_reg}) / 2**10);
        end else begin
            {ptp_ovf, period_ns_next, period_fns_next} = ($signed({1'b0, time_err_int_reg}) / 2**16) + ($signed({ts_ns_diff_corr_reg, ts_fns_diff_corr_reg}) / 2**7);
        end

        // saturate
        if (ptp_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            {period_ns_next, period_fns_next} = {NS_WIDTH+FNS_WIDTH{1'b0}};
        end else if (ptp_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            {period_ns_next, period_fns_next} = {NS_WIDTH+FNS_WIDTH{1'b1}};
        end

        // locked status
        if ($signed(ts_ns_diff_corr_reg[17-1:4]) == 0 || $signed(ts_ns_diff_corr_reg[17-1:4]) == -1) begin
            if (ptp_lock_count_reg == {PTP_LOCK_WIDTH{1'b1}}) begin
                ptp_locked_next = 1'b1;
            end else begin
                ptp_lock_count_next = ptp_lock_count_reg + 1;
            end
        end else begin
            ptp_lock_count_next = 0;
            ptp_locked_next = 1'b0;
        end
    end
end

always @(posedge output_clk) begin
    period_ns_reg <= period_ns_next;
    period_fns_reg <= period_fns_next;

    ts_s_reg <= ts_s_next;
    ts_ns_reg <= ts_ns_next;
    ts_fns_reg <= ts_fns_next;
    ts_ns_inc_reg <= ts_ns_inc_next;
    ts_fns_inc_reg <= ts_fns_inc_next;
    ts_ns_ovf_reg <= ts_ns_ovf_next;
    ts_fns_ovf_reg <= ts_fns_ovf_next;

    ts_step_reg <= ts_step_next;

    sec_mismatch_reg <= sec_mismatch_next;
    diff_valid_reg <= diff_valid_next;
    diff_corr_valid_reg <= diff_corr_valid_next;

    ts_s_diff_reg <= ts_s_diff_next;
    ts_ns_diff_reg <= ts_ns_diff_next;
    ts_fns_diff_reg <= ts_fns_diff_next;

    ts_ns_diff_corr_reg <= ts_ns_diff_corr_next;
    ts_fns_diff_corr_reg <= ts_fns_diff_corr_next;

    time_err_int_reg <= time_err_int_next;

    ptp_lock_count_reg <= ptp_lock_count_next;
    ptp_locked_reg <= ptp_locked_next;

    // PPS output
    if (TS_WIDTH == 96) begin
        pps_reg <= !ts_ns_ovf_reg[30];
    end else if (TS_WIDTH == 64) begin
        pps_reg <= 1'b0; // not currently implemented for 64 bit timestamp format
    end

    if (output_rst) begin
        period_ns_reg <= 0;
        period_fns_reg <= 0;
        ts_s_reg <= 0;
        ts_ns_reg <= 0;
        ts_fns_reg <= 0;
        ts_ns_inc_reg <= 0;
        ts_fns_inc_reg <= 0;
        ts_ns_ovf_reg <= {TS_NS_WIDTH+1{1'b1}};
        ts_fns_ovf_reg <= {FNS_WIDTH{1'b1}};
        ts_step_reg <= 0;
        pps_reg <= 0;

        sec_mismatch_reg <= 1'b0;
        diff_valid_reg <= 1'b0;
        diff_corr_valid_reg <= 1'b0;

        time_err_int_reg <= 0;

        ptp_lock_count_reg <= 0;
        ptp_locked_reg <= 1'b0;
    end
end

endmodule

`resetall
