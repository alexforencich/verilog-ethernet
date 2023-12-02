/*

Copyright (c) 2019-2023 Alex Forencich

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
`timescale 1ns / 1fs
`default_nettype none

/*
 * PTP clock CDC (clock domain crossing) module
 */
module ptp_clock_cdc #
(
    parameter TS_WIDTH = 96,
    parameter NS_WIDTH = 4,
    parameter LOG_RATE = 3,
    parameter PIPELINE_OUTPUT = 0
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

localparam FNS_WIDTH = 16;

localparam TS_NS_WIDTH = TS_WIDTH == 96 ? 30 : 48;
localparam TS_FNS_WIDTH = FNS_WIDTH > 16 ? 16 : FNS_WIDTH;

localparam CMP_FNS_WIDTH = 4;

localparam PHASE_CNT_WIDTH = LOG_RATE;
localparam PHASE_ACC_WIDTH = PHASE_CNT_WIDTH+16;

localparam LOG_SAMPLE_SYNC_RATE = LOG_RATE;
localparam SAMPLE_ACC_WIDTH = LOG_SAMPLE_SYNC_RATE+2;

localparam LOG_PHASE_ERR_RATE = 4;
localparam PHASE_ERR_ACC_WIDTH = LOG_PHASE_ERR_RATE+2;

localparam DEST_SYNC_LOCK_WIDTH = 7;
localparam FREQ_LOCK_WIDTH = 8;
localparam PTP_LOCK_WIDTH = 8;

localparam TIME_ERR_INT_WIDTH = NS_WIDTH+FNS_WIDTH;

localparam [30:0] NS_PER_S = 31'd1_000_000_000;

reg [NS_WIDTH+FNS_WIDTH-1:0] period_ns_reg = 0, period_ns_next = 0;
reg [NS_WIDTH+FNS_WIDTH-1:0] period_ns_delay_reg = 0, period_ns_delay_next = 0;
reg [31+FNS_WIDTH-1:0] period_ns_ovf_reg = 0, period_ns_ovf_next = 0;

reg [47:0] src_ts_s_capt_reg = 0;
reg [TS_NS_WIDTH+CMP_FNS_WIDTH-1:0] src_ts_ns_capt_reg = 0;
reg src_ts_step_capt_reg = 0;

reg [47:0] dest_ts_s_capt_reg = 0;
reg [TS_NS_WIDTH+CMP_FNS_WIDTH-1:0] dest_ts_ns_capt_reg = 0;

reg [47:0] src_ts_s_sync_reg = 0;
reg [TS_NS_WIDTH+CMP_FNS_WIDTH-1:0] src_ts_ns_sync_reg = 0;
reg src_ts_step_sync_reg = 0;

reg [47:0] ts_s_reg = 0, ts_s_next = 0;
reg [TS_NS_WIDTH+FNS_WIDTH-1:0] ts_ns_reg = 0, ts_ns_next = 0;
reg [TS_NS_WIDTH+FNS_WIDTH-1:0] ts_ns_inc_reg = 0, ts_ns_inc_next = 0;
reg [TS_NS_WIDTH+FNS_WIDTH+1-1:0] ts_ns_ovf_reg = {TS_NS_WIDTH+FNS_WIDTH+1{1'b1}}, ts_ns_ovf_next = 0;

reg ts_step_reg = 1'b0, ts_step_next;

reg pps_reg = 1'b0;

reg [47:0] ts_s_pipe_reg[0:PIPELINE_OUTPUT-1];
reg [TS_NS_WIDTH+CMP_FNS_WIDTH-1:0] ts_ns_pipe_reg[0:PIPELINE_OUTPUT-1];
reg ts_step_pipe_reg[0:PIPELINE_OUTPUT-1];
reg pps_pipe_reg[0:PIPELINE_OUTPUT-1];

reg [PHASE_CNT_WIDTH-1:0] src_phase_reg = {PHASE_CNT_WIDTH{1'b0}};
reg [PHASE_ACC_WIDTH-1:0] dest_phase_reg = {PHASE_ACC_WIDTH{1'b0}}, dest_phase_next;
reg [PHASE_ACC_WIDTH-1:0] dest_phase_inc_reg = {PHASE_ACC_WIDTH{1'b0}}, dest_phase_inc_next;

reg src_sync_reg = 1'b0;
reg src_update_reg = 1'b0;
reg src_phase_sync_reg = 1'b0;
reg dest_sync_reg = 1'b0;
reg dest_update_reg = 1'b0, dest_update_next = 1'b0;
reg dest_phase_sync_reg = 1'b0;

reg src_sync_sync1_reg = 1'b0;
reg src_sync_sync2_reg = 1'b0;
reg src_sync_sync3_reg = 1'b0;
reg src_phase_sync_sync1_reg = 1'b0;
reg src_phase_sync_sync2_reg = 1'b0;
reg src_phase_sync_sync3_reg = 1'b0;
reg dest_phase_sync_sync1_reg = 1'b0;
reg dest_phase_sync_sync2_reg = 1'b0;
reg dest_phase_sync_sync3_reg = 1'b0;

reg src_sync_sample_sync1_reg = 1'b0;
reg src_sync_sample_sync2_reg = 1'b0;
reg src_sync_sample_sync3_reg = 1'b0;
reg dest_sync_sample_sync1_reg = 1'b0;
reg dest_sync_sample_sync2_reg = 1'b0;
reg dest_sync_sample_sync3_reg = 1'b0;

reg [SAMPLE_ACC_WIDTH-1:0] sample_acc_reg = 0;
reg [SAMPLE_ACC_WIDTH-1:0] sample_acc_out_reg = 0;
reg [LOG_SAMPLE_SYNC_RATE-1:0] sample_cnt_reg = 0;
reg sample_update_reg = 1'b0;
reg sample_update_sync1_reg = 1'b0;
reg sample_update_sync2_reg = 1'b0;
reg sample_update_sync3_reg = 1'b0;

generate

if (PIPELINE_OUTPUT > 0) begin

    // pipeline
    (* shreg_extract = "no" *)
    reg [TS_WIDTH-1:0]  output_ts_reg[0:PIPELINE_OUTPUT-1];
    (* shreg_extract = "no" *)
    reg                 output_ts_step_reg[0:PIPELINE_OUTPUT-1];
    (* shreg_extract = "no" *)
    reg                 output_pps_reg[0:PIPELINE_OUTPUT-1];

    assign output_ts = output_ts_reg[PIPELINE_OUTPUT-1];
    assign output_ts_step = output_ts_step_reg[PIPELINE_OUTPUT-1];
    assign output_pps = output_pps_reg[PIPELINE_OUTPUT-1];

    integer i;

    initial begin
        for (i = 0; i < PIPELINE_OUTPUT; i = i + 1) begin
            output_ts_reg[i] = 0;
            output_ts_step_reg[i] = 1'b0;
            output_pps_reg[i] = 1'b0;
        end
    end

    always @(posedge output_clk) begin
        if (TS_WIDTH == 96) begin
            output_ts_reg[0][95:48] <= ts_s_reg;
            output_ts_reg[0][47:46] <= 2'b00;
            output_ts_reg[0][45:0]  <= {ts_ns_reg, 16'd0} >> FNS_WIDTH;
        end else if (TS_WIDTH == 64) begin
            output_ts_reg[0]  <= {ts_ns_reg, 16'd0} >> FNS_WIDTH;
        end

        output_ts_step_reg[0] <= ts_step_reg;
        output_pps_reg[0] <= pps_reg;

        for (i = 0; i < PIPELINE_OUTPUT-1; i = i + 1) begin
            output_ts_reg[i+1] <= output_ts_reg[i];
            output_ts_step_reg[i+1] <= output_ts_step_reg[i];
            output_pps_reg[i+1] <= output_pps_reg[i];
        end

        if (output_rst) begin
            for (i = 0; i < PIPELINE_OUTPUT; i = i + 1) begin
                output_ts_reg[i] <= 0;
                output_ts_step_reg[i] <= 1'b0;
                output_pps_reg[i] <= 1'b0;
            end
        end
    end

end else begin

    if (TS_WIDTH == 96) begin
        assign output_ts[95:48] = ts_s_reg;
        assign output_ts[47:46] = 2'b00;
        assign output_ts[45:0]  = {ts_ns_reg, 16'd0} >> FNS_WIDTH;
    end else if (TS_WIDTH == 64) begin
        assign output_ts = {ts_ns_reg, 16'd0} >> FNS_WIDTH;
    end

    assign output_ts_step = ts_step_reg;

    assign output_pps = pps_reg;

end

endgenerate

integer i;

initial begin
    for (i = 0; i < PIPELINE_OUTPUT; i = i + 1) begin
        ts_s_pipe_reg[i] = 0;
        ts_ns_pipe_reg[i] = 0;
        ts_step_pipe_reg[i] = 1'b0;
        pps_pipe_reg[i] = 1'b0;
    end
end

// source PTP clock capture and sync logic
reg input_ts_step_reg = 1'b0;

always @(posedge input_clk) begin
    input_ts_step_reg <= input_ts_step || input_ts_step_reg;

    src_phase_sync_reg <= input_ts[16+8];

    {src_update_reg, src_phase_reg} <= src_phase_reg+1;

    if (src_update_reg) begin
        // capture source TS
        if (TS_WIDTH == 96) begin
            src_ts_s_capt_reg <= input_ts[95:48];
            src_ts_ns_capt_reg <= input_ts[45:0] >> (16-CMP_FNS_WIDTH);
        end else begin
            src_ts_ns_capt_reg <= input_ts >> (16-CMP_FNS_WIDTH);
        end
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
    src_phase_sync_sync1_reg <= src_phase_sync_reg;
    src_phase_sync_sync2_reg <= src_phase_sync_sync1_reg;
    src_phase_sync_sync3_reg <= src_phase_sync_sync2_reg;
    dest_phase_sync_sync1_reg <= dest_phase_sync_reg;
    dest_phase_sync_sync2_reg <= dest_phase_sync_sync1_reg;
    dest_phase_sync_sync3_reg <= dest_phase_sync_sync2_reg;
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
    // phase and frequency detector
    if (dest_sync_sample_sync2_reg && !dest_sync_sample_sync3_reg) begin
        if (src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg) begin
            edge_1_reg <= 1'b0;
            edge_2_reg <= 1'b0;
        end else begin
            edge_1_reg <= !edge_2_reg;
            edge_2_reg <= 1'b0;
        end
    end else if (src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg) begin
        edge_1_reg <= 1'b0;
        edge_2_reg <= !edge_1_reg;
    end

    // accumulator
    sample_acc_reg <= $signed(sample_acc_reg) + $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});

    sample_cnt_reg <= sample_cnt_reg + 1;

    if (src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg) begin
        active_reg[0] <= 1'b1;
    end

    if (sample_cnt_reg == 0) begin
        active_reg <= {active_reg, src_sync_sample_sync2_reg && !src_sync_sample_sync3_reg};
        sample_acc_reg <= $signed({1'b0, edge_2_reg}) - $signed({1'b0, edge_1_reg});
        sample_acc_out_reg <= sample_acc_reg;
        if (active_reg != 0) begin
            sample_update_reg <= !sample_update_reg;
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

reg [PHASE_ERR_ACC_WIDTH-1:0] phase_err_acc_reg = 0;
reg [PHASE_ERR_ACC_WIDTH-1:0] phase_err_out_reg = 0;
reg [LOG_PHASE_ERR_RATE-1:0] phase_err_cnt_reg = 0;
reg phase_err_out_valid_reg = 0;

reg phase_edge_1_reg = 1'b0;
reg phase_edge_2_reg = 1'b0;

reg [5:0] phase_active_reg = 0;

reg ts_sync_valid_reg = 1'b0;
reg ts_capt_valid_reg = 1'b0;

always @(posedge output_clk) begin
    dest_phase_reg <= dest_phase_next;
    dest_phase_inc_reg <= dest_phase_inc_next;
    dest_update_reg <= dest_update_next;

    sample_acc_sync_valid_reg <= 1'b0;
    if (sample_update_sync2_reg ^ sample_update_sync3_reg) begin
        // latch in synchronized counts from phase detector
        sample_acc_sync_reg <= sample_acc_out_reg;
        sample_acc_sync_valid_reg <= 1'b1;
    end

    if (PIPELINE_OUTPUT > 0) begin
        dest_phase_sync_reg <= ts_ns_pipe_reg[PIPELINE_OUTPUT-1][8+FNS_WIDTH];
    end else begin
        dest_phase_sync_reg <= ts_ns_reg[8+FNS_WIDTH];
    end

    // phase and frequency detector
    if (dest_phase_sync_sync2_reg && !dest_phase_sync_sync3_reg) begin
        if (src_phase_sync_sync2_reg && !src_phase_sync_sync3_reg) begin
            phase_edge_1_reg <= 1'b0;
            phase_edge_2_reg <= 1'b0;
        end else begin
            phase_edge_1_reg <= !phase_edge_2_reg;
            phase_edge_2_reg <= 1'b0;
        end
    end else if (src_phase_sync_sync2_reg && !src_phase_sync_sync3_reg) begin
        phase_edge_1_reg <= 1'b0;
        phase_edge_2_reg <= !phase_edge_1_reg;
    end

    // accumulator
    phase_err_acc_reg <= $signed(phase_err_acc_reg) + $signed({1'b0, phase_edge_2_reg}) - $signed({1'b0, phase_edge_1_reg});

    phase_err_cnt_reg <= phase_err_cnt_reg + 1;

    if (src_phase_sync_sync2_reg && !src_phase_sync_sync3_reg) begin
        phase_active_reg[0] <= 1'b1;
    end

    phase_err_out_valid_reg <= 1'b0;
    if (phase_err_cnt_reg == 0) begin
        phase_active_reg <= {phase_active_reg, src_phase_sync_sync2_reg && !src_phase_sync_sync3_reg};
        phase_err_acc_reg <= $signed({1'b0, phase_edge_2_reg}) - $signed({1'b0, phase_edge_1_reg});
        phase_err_out_reg <= phase_err_acc_reg;
        if (phase_active_reg != 0) begin
            phase_err_out_valid_reg <= 1'b1;
        end
    end

    if (dest_update_reg) begin
        // capture local TS
        if (PIPELINE_OUTPUT > 0) begin
            dest_ts_s_capt_reg <= ts_s_pipe_reg[PIPELINE_OUTPUT-1];
            dest_ts_ns_capt_reg <= ts_ns_pipe_reg[PIPELINE_OUTPUT-1];
        end else begin
            dest_ts_s_capt_reg <= ts_s_reg;
            dest_ts_ns_capt_reg <= ts_ns_reg >> FNS_WIDTH-CMP_FNS_WIDTH;
        end

        dest_sync_reg <= !dest_sync_reg;
        ts_capt_valid_reg <= 1'b1;
    end

    if (src_sync_sync2_reg ^ src_sync_sync3_reg) begin
        // store captured source TS
        if (TS_WIDTH == 96) begin
            src_ts_s_sync_reg <= src_ts_s_capt_reg;
        end
        src_ts_ns_sync_reg <= src_ts_ns_capt_reg;
        src_ts_step_sync_reg <= src_ts_step_capt_reg;

        ts_sync_valid_reg <= 1'b1;
    end

    if (ts_sync_valid_reg && ts_capt_valid_reg) begin
        ts_sync_valid_reg <= 1'b0;
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

reg ts_diff_reg = 1'b0, ts_diff_next;
reg ts_diff_valid_reg = 1'b0, ts_diff_valid_next;
reg [3:0] mismatch_cnt_reg = 0, mismatch_cnt_next;
reg load_ts_reg = 1'b0, load_ts_next;

reg [9+CMP_FNS_WIDTH-1:0] ts_ns_diff_reg = 0, ts_ns_diff_next;

reg [TIME_ERR_INT_WIDTH-1:0] time_err_int_reg = 0, time_err_int_next;

reg [1:0] ptp_ovf;

reg [FREQ_LOCK_WIDTH-1:0] freq_lock_count_reg = 0, freq_lock_count_next;
reg freq_locked_reg = 1'b0, freq_locked_next;
reg [PTP_LOCK_WIDTH-1:0] ptp_lock_count_reg = 0, ptp_lock_count_next;
reg ptp_locked_reg = 1'b0, ptp_locked_next;

reg gain_sel_reg = 0, gain_sel_next;

assign locked = ptp_locked_reg && freq_locked_reg && dest_sync_locked_reg;

always @* begin
    period_ns_next = period_ns_reg;

    ts_s_next = ts_s_reg;
    ts_ns_next = ts_ns_reg;
    ts_ns_inc_next = ts_ns_inc_reg;
    ts_ns_ovf_next = ts_ns_ovf_reg;

    ts_step_next = 0;

    ts_diff_next = 1'b0;
    ts_diff_valid_next = 1'b0;
    mismatch_cnt_next = mismatch_cnt_reg;
    load_ts_next = load_ts_reg;

    ts_ns_diff_next = ts_ns_diff_reg;

    time_err_int_next = time_err_int_reg;

    freq_lock_count_next = freq_lock_count_reg;
    freq_locked_next = freq_locked_reg;
    ptp_lock_count_next = ptp_lock_count_reg;
    ptp_locked_next = ptp_locked_reg;

    gain_sel_next = gain_sel_reg;

    // PTP clock
    period_ns_delay_next = period_ns_reg;
    period_ns_ovf_next = {NS_PER_S, {FNS_WIDTH{1'b0}}} - period_ns_reg;

    if (TS_WIDTH == 96) begin
        // 96 bit timestamp
        ts_ns_inc_next = ts_ns_inc_reg + period_ns_delay_reg;
        ts_ns_ovf_next = ts_ns_inc_reg - period_ns_ovf_reg;
        ts_ns_next = ts_ns_inc_reg;

        if (!ts_ns_ovf_reg[30+FNS_WIDTH]) begin
            // if the overflow lookahead did not borrow, one second has elapsed
            // increment seconds field, pre-compute normal increment, force overflow lookahead borrow bit set
            ts_ns_inc_next = ts_ns_ovf_reg + period_ns_delay_reg;
            ts_ns_ovf_next[30+FNS_WIDTH] = 1'b1;
            ts_ns_next = ts_ns_ovf_reg;
            ts_s_next = ts_s_reg + 1;
        end
    end else if (TS_WIDTH == 64) begin
        // 64 bit timestamp
        ts_ns_next = ts_ns_reg + period_ns_reg;
    end

    if (ts_sync_valid_reg && ts_capt_valid_reg) begin
        // Read new value
        if (TS_WIDTH == 96) begin
            if (src_ts_step_sync_reg || load_ts_reg) begin
                // input stepped
                load_ts_next = 1'b0;

                ts_s_next = src_ts_s_sync_reg;
                ts_ns_next[TS_NS_WIDTH+FNS_WIDTH-1:9+FNS_WIDTH] = src_ts_ns_sync_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH];
                ts_ns_inc_next[TS_NS_WIDTH+FNS_WIDTH-1:9+FNS_WIDTH] = src_ts_ns_sync_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH];
                ts_ns_ovf_next[30+FNS_WIDTH] = 1'b1;
                ts_step_next = 1;
            end else begin
                // input did not step
                load_ts_next = 1'b0;
                ts_diff_valid_next = freq_locked_reg;
            end
            // compute difference
            ts_ns_diff_next = src_ts_ns_sync_reg - dest_ts_ns_capt_reg;
            ts_diff_next = src_ts_s_sync_reg != dest_ts_s_capt_reg || src_ts_ns_sync_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH] != dest_ts_ns_capt_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH];
        end else if (TS_WIDTH == 64) begin
            if (src_ts_step_sync_reg || load_ts_reg) begin
                // input stepped
                load_ts_next = 1'b0;

                ts_ns_next[TS_NS_WIDTH+FNS_WIDTH-1:9+FNS_WIDTH] = src_ts_ns_sync_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH];
                ts_step_next = 1;
            end else begin
                // input did not step
                load_ts_next = 1'b0;
                ts_diff_valid_next = freq_locked_reg;
            end
            // compute difference
            ts_ns_diff_next = src_ts_ns_sync_reg - dest_ts_ns_capt_reg;
            ts_diff_next = src_ts_ns_sync_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH] != dest_ts_ns_capt_reg[TS_NS_WIDTH+CMP_FNS_WIDTH-1:9+CMP_FNS_WIDTH];
        end
    end

    if (ts_diff_valid_reg) begin
        if (ts_diff_reg) begin
            if (&mismatch_cnt_reg) begin
                load_ts_next = 1'b1;
                mismatch_cnt_next = 0;
            end else begin
                mismatch_cnt_next = mismatch_cnt_reg + 1;
            end
        end else begin
            mismatch_cnt_next = 0;
        end
    end

    if (phase_err_out_valid_reg) begin
        // coarse phase/frequency lock of PTP clock
        if ($signed(phase_err_out_reg) > 4 || $signed(phase_err_out_reg) < -4) begin
            if (freq_lock_count_reg) begin
                freq_lock_count_next = freq_lock_count_reg - 1;
            end else begin
                freq_locked_next = 1'b0;
            end
        end else begin
            if (&freq_lock_count_reg) begin
                freq_locked_next = 1'b1;
            end else begin
                freq_lock_count_next = freq_lock_count_reg + 1;
            end
        end

        if (!freq_locked_reg) begin
            ts_ns_diff_next = $signed(phase_err_out_reg) * 8 * 2**CMP_FNS_WIDTH;
            ts_diff_valid_next = 1'b1;
        end
    end

    if (ts_diff_valid_reg) begin
        // PI control

        // gain scheduling
        casez (ts_ns_diff_reg[9+CMP_FNS_WIDTH-5 +: 5])
            5'b01zzz: gain_sel_next = 1'b1;
            5'b001zz: gain_sel_next = 1'b1;
            5'b0001z: gain_sel_next = 1'b1;
            5'b00001: gain_sel_next = 1'b1;
            5'b00000: gain_sel_next = 1'b0;
            5'b11111: gain_sel_next = 1'b0;
            5'b11110: gain_sel_next = 1'b1;
            5'b1110z: gain_sel_next = 1'b1;
            5'b110zz: gain_sel_next = 1'b1;
            5'b10zzz: gain_sel_next = 1'b1;
            default: gain_sel_next = 1'b0;
        endcase

        // time integral of error
        case (gain_sel_reg)
            1'b0: {ptp_ovf, time_err_int_next} = $signed({1'b0, time_err_int_reg}) + ($signed(ts_ns_diff_reg) / 2**4);
            1'b1: {ptp_ovf, time_err_int_next} = $signed({1'b0, time_err_int_reg}) + ($signed(ts_ns_diff_reg) * 2**2);
        endcase

        // saturate
        if (ptp_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            time_err_int_next = {TIME_ERR_INT_WIDTH{1'b0}};
        end else if (ptp_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            time_err_int_next = {TIME_ERR_INT_WIDTH{1'b1}};
        end

        // compute output
        case (gain_sel_reg)
            1'b0: {ptp_ovf, period_ns_next} = $signed({1'b0, time_err_int_reg}) + ($signed(ts_ns_diff_reg) * 2**2);
            1'b1: {ptp_ovf, period_ns_next} = $signed({1'b0, time_err_int_reg}) + ($signed(ts_ns_diff_reg) * 2**6);
        endcase

        // saturate
        if (ptp_ovf[1]) begin
            // sign bit set indicating underflow across zero; saturate to zero
            period_ns_next = {NS_WIDTH+FNS_WIDTH{1'b0}};
        end else if (ptp_ovf[0]) begin
            // sign bit clear but carry bit set indicating overflow; saturate to all 1
            period_ns_next = {NS_WIDTH+FNS_WIDTH{1'b1}};
        end

        // adjust period if integrator is saturated
        if (time_err_int_reg == 0) begin
            period_ns_next = {NS_WIDTH+FNS_WIDTH{1'b0}};
        end else if (~time_err_int_reg == 0) begin
            period_ns_next = {NS_WIDTH+FNS_WIDTH{1'b1}};
        end

        // locked status
        if (!freq_locked_reg) begin
            ptp_lock_count_next = 0;
            ptp_locked_next = 1'b0;
        end else if (gain_sel_reg == 1'b0) begin
            if (&ptp_lock_count_reg) begin
                ptp_locked_next = 1'b1;
            end else begin
                ptp_lock_count_next = ptp_lock_count_reg + 1;
            end
        end else begin
            if (ptp_lock_count_reg) begin
                ptp_lock_count_next = ptp_lock_count_reg - 1;
            end else begin
                ptp_locked_next = 1'b0;
            end
        end
    end
end

always @(posedge output_clk) begin
    period_ns_reg <= period_ns_next;
    period_ns_delay_reg <= period_ns_delay_next;
    period_ns_ovf_reg <= period_ns_ovf_next;

    ts_s_reg <= ts_s_next;
    ts_ns_reg <= ts_ns_next;
    ts_ns_inc_reg <= ts_ns_inc_next;
    ts_ns_ovf_reg <= ts_ns_ovf_next;

    ts_step_reg <= ts_step_next;

    ts_diff_reg <= ts_diff_next;
    ts_diff_valid_reg <= ts_diff_valid_next;
    mismatch_cnt_reg <= mismatch_cnt_next;
    load_ts_reg <= load_ts_next;

    ts_ns_diff_reg <= ts_ns_diff_next;

    time_err_int_reg <= time_err_int_next;

    freq_lock_count_reg <= freq_lock_count_next;
    freq_locked_reg <= freq_locked_next;
    ptp_lock_count_reg <= ptp_lock_count_next;
    ptp_locked_reg <= ptp_locked_next;

    gain_sel_reg <= gain_sel_next;

    // PPS output
    if (TS_WIDTH == 96) begin
        pps_reg <= !ts_ns_ovf_reg[30+FNS_WIDTH];
    end else if (TS_WIDTH == 64) begin
        pps_reg <= 1'b0; // not currently implemented for 64 bit timestamp format
    end

    // pipeline
    if (PIPELINE_OUTPUT > 0) begin
        ts_s_pipe_reg[0] <= ts_s_reg;
        ts_ns_pipe_reg[0] <= ts_ns_reg >> FNS_WIDTH-TS_FNS_WIDTH;
        ts_step_pipe_reg[0] <= ts_step_reg;
        pps_pipe_reg[0] <= pps_reg;

        for (i = 0; i < PIPELINE_OUTPUT-1; i = i + 1) begin
            ts_s_pipe_reg[i+1] <= ts_s_pipe_reg[i];
            ts_ns_pipe_reg[i+1] <= ts_ns_pipe_reg[i];
            ts_step_pipe_reg[i+1] <= ts_step_pipe_reg[i];
            pps_pipe_reg[i+1] <= pps_pipe_reg[i];
        end
    end

    if (output_rst) begin
        period_ns_reg <= 0;
        ts_s_reg <= 0;
        ts_ns_reg <= 0;
        ts_ns_inc_reg <= 0;
        ts_ns_ovf_reg[30+FNS_WIDTH] <= 1'b1;
        ts_step_reg <= 0;
        pps_reg <= 0;

        ts_diff_reg <= 1'b0;
        ts_diff_valid_reg <= 1'b0;
        mismatch_cnt_reg <= 0;
        load_ts_reg <= 0;

        time_err_int_reg <= 0;

        freq_lock_count_reg <= 0;
        freq_locked_reg <= 1'b0;
        ptp_lock_count_reg <= 0;
        ptp_locked_reg <= 1'b0;

        for (i = 0; i < PIPELINE_OUTPUT; i = i + 1) begin
            ts_s_pipe_reg[i] <= 0;
            ts_ns_pipe_reg[i] <= 0;
            ts_step_pipe_reg[i] <= 1'b0;
            pps_pipe_reg[i] <= 1'b0;
        end
    end
end

endmodule

`resetall
