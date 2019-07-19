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

`timescale 1ns / 1ps

/*
 * PTP clock CDC (clock domain crossing) module
 */
module ptp_clock_cdc #
(
    parameter TS_WIDTH = 96,
    parameter NS_WIDTH = 4,
    parameter FNS_WIDTH = 16,
    parameter INPUT_PERIOD_NS = 4'h6,
    parameter INPUT_PERIOD_FNS = 16'h6666,
    parameter OUTPUT_PERIOD_NS = 4'h6,
    parameter OUTPUT_PERIOD_FNS = 16'h6666,
    parameter USE_SAMPLE_CLOCK = 1,
    parameter LOG_FIFO_DEPTH = 3,
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

    /*
     * Timestamp outputs
     */
    output wire [TS_WIDTH-1:0]  output_ts,
    output wire                 output_ts_step,

    /*
     * PPS output
     */
    output wire                 output_pps
);

// bus width assertions
initial begin
    if (TS_WIDTH != 64 && TS_WIDTH != 96) begin
        $error("Error: Timestamp width must be 64 or 96");
        $finish;
    end
end

parameter TS_NS_WIDTH = TS_WIDTH == 96 ? 30 : 48;

parameter FIFO_ADDR_WIDTH = LOG_FIFO_DEPTH+1;
parameter LOG_AVG = 6;
parameter LOG_AVG_SCALE = LOG_AVG+8;
parameter LOG_AVG_SYNC_RATE = LOG_RATE;
parameter WR_PERIOD = ((((INPUT_PERIOD_NS << 16) + INPUT_PERIOD_FNS) + 64'd0) << 16) / ((OUTPUT_PERIOD_NS << 16) + OUTPUT_PERIOD_FNS) / 2**(LOG_RATE+1);

reg [NS_WIDTH-1:0] period_ns_reg = OUTPUT_PERIOD_NS;
reg [FNS_WIDTH-1:0] period_fns_reg = OUTPUT_PERIOD_FNS;

reg [47:0] ts_s_reg = 0;
reg [TS_NS_WIDTH-1:0] ts_ns_reg = 0;
reg [FNS_WIDTH-1:0] ts_fns_reg = 0;
reg [TS_NS_WIDTH-1:0] ts_ns_inc_reg = 0;
reg [FNS_WIDTH-1:0] ts_fns_inc_reg = 0;
reg [TS_NS_WIDTH+1-1:0] ts_ns_ovf_reg = {TS_NS_WIDTH+1{1'b1}};
reg [FNS_WIDTH-1:0] ts_fns_ovf_reg = {FNS_WIDTH{1'b1}};

reg ts_step_reg = 1'b0;

reg pps_reg = 0;

reg [FIFO_ADDR_WIDTH:0] wr_ptr_reg = {FIFO_ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [FIFO_ADDR_WIDTH:0] wr_ptr_gray_reg = {FIFO_ADDR_WIDTH+1{1'b0}}, wr_ptr_gray_next;
reg [FIFO_ADDR_WIDTH:0] rd_ptr_reg = {FIFO_ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [FIFO_ADDR_WIDTH:0] rd_ptr_gray_reg = {FIFO_ADDR_WIDTH+1{1'b0}}, rd_ptr_gray_next;

reg [FIFO_ADDR_WIDTH:0] wr_ptr_gray_sync1_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
reg [FIFO_ADDR_WIDTH:0] wr_ptr_gray_sync2_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
wire [FIFO_ADDR_WIDTH:0] wr_ptr_sync2;
reg [FIFO_ADDR_WIDTH:0] rd_ptr_gray_sync1_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
reg [FIFO_ADDR_WIDTH:0] rd_ptr_gray_sync2_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
wire [FIFO_ADDR_WIDTH:0] rd_ptr_sync2;

reg [FIFO_ADDR_WIDTH:0] wr_ptr_gray_sample_sync1_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
reg [FIFO_ADDR_WIDTH:0] wr_ptr_gray_sample_sync2_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
wire [FIFO_ADDR_WIDTH:0] wr_ptr_sample_sync2;
reg [FIFO_ADDR_WIDTH:0] rd_ptr_gray_sample_sync1_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
reg [FIFO_ADDR_WIDTH:0] rd_ptr_gray_sample_sync2_reg = {FIFO_ADDR_WIDTH+1{1'b0}};
wire [FIFO_ADDR_WIDTH:0] rd_ptr_sample_sync2;

reg [15:0] wr_acc_reg = 16'd0, wr_acc_next;
reg [15:0] wr_inc_reg = WR_PERIOD, wr_inc_next;
reg [31:0] err_int_reg = 0, err_int_next;

reg [LOG_RATE-1:0] rd_cnt_reg = {LOG_RATE{1'b0}}, rd_cnt_next;

reg [LOG_FIFO_DEPTH+LOG_AVG_SCALE+2-1:0] sample_acc_reg = 0;
reg [LOG_FIFO_DEPTH+LOG_AVG_SCALE+2-1:0] sample_avg_reg = 0;
reg [LOG_AVG_SYNC_RATE-1:0] sample_cnt_reg = 0;
reg sample_update_reg = 1'b0;
reg sample_update_sync1_reg = 1'b0;
reg sample_update_sync2_reg = 1'b0;
reg sample_update_sync3_reg = 1'b0;

reg [TS_WIDTH-1:0] mem[(2**FIFO_ADDR_WIDTH)-1:0];
reg [TS_WIDTH-1:0] mem_read_data_reg = 0;

// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
wire full = ((wr_ptr_gray_reg[FIFO_ADDR_WIDTH] != rd_ptr_gray_sync2_reg[FIFO_ADDR_WIDTH]) &&
             (wr_ptr_gray_reg[FIFO_ADDR_WIDTH-1] != rd_ptr_gray_sync2_reg[FIFO_ADDR_WIDTH-1]) &&
             (wr_ptr_gray_reg[FIFO_ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_reg[FIFO_ADDR_WIDTH-2:0]));
// empty when pointers match exactly
wire empty = rd_ptr_gray_reg == wr_ptr_gray_sync2_reg;

wire [FIFO_ADDR_WIDTH:0] wr_depth = wr_ptr_reg - rd_ptr_sync2;
wire [FIFO_ADDR_WIDTH:0] rd_depth = wr_ptr_sync2 - rd_ptr_reg;
wire [FIFO_ADDR_WIDTH:0] sample_depth = wr_ptr_sample_sync2 - rd_ptr_sample_sync2;

// control signals
reg write;
reg read;

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

generate

    genvar n;

    for (n = 0; n < FIFO_ADDR_WIDTH+1; n = n + 1) begin
        assign wr_ptr_sync2[n] = ^wr_ptr_gray_sync2_reg[FIFO_ADDR_WIDTH+1-1:n];
        assign rd_ptr_sync2[n] = ^rd_ptr_gray_sync2_reg[FIFO_ADDR_WIDTH+1-1:n];
        assign wr_ptr_sample_sync2[n] = ^wr_ptr_gray_sample_sync2_reg[FIFO_ADDR_WIDTH+1-1:n];
        assign rd_ptr_sample_sync2[n] = ^rd_ptr_gray_sample_sync2_reg[FIFO_ADDR_WIDTH+1-1:n];
    end

endgenerate

// pointer sync
always @(posedge input_clk) begin
    if (input_rst) begin
        rd_ptr_gray_sync1_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_sync2_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
    end else begin
        rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg;
        rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg;
    end
end

always @(posedge output_clk) begin
    if (output_rst) begin
        wr_ptr_gray_sync1_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_sync2_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg;
        wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg;
    end
end

always @(posedge sample_clk) begin
    rd_ptr_gray_sample_sync1_reg <= rd_ptr_gray_reg;
    rd_ptr_gray_sample_sync2_reg <= rd_ptr_gray_sample_sync1_reg;
    wr_ptr_gray_sample_sync1_reg <= wr_ptr_gray_reg;
    wr_ptr_gray_sample_sync2_reg <= wr_ptr_gray_sample_sync1_reg;
end

always @(posedge sample_clk) begin
    if (USE_SAMPLE_CLOCK) begin
        sample_acc_reg <= sample_acc_reg + ((sample_depth * 2**LOG_AVG_SCALE - sample_acc_reg) >> LOG_AVG);
        sample_cnt_reg <= sample_cnt_reg + 1;

        if (sample_cnt_reg == 0) begin
            sample_update_reg <= !sample_update_reg;
            sample_avg_reg <= sample_acc_reg;
        end
    end
end

always @(posedge input_clk) begin
    sample_update_sync1_reg <= sample_update_reg;
    sample_update_sync2_reg <= sample_update_sync1_reg;
    sample_update_sync3_reg <= sample_update_sync2_reg;
end

reg [LOG_FIFO_DEPTH+LOG_AVG_SCALE+2-1:0] sample_avg_sync_reg = 0;
reg sample_avg_sync_valid_reg = 0;

always @(posedge input_clk) begin
    if (USE_SAMPLE_CLOCK) begin
        sample_avg_sync_valid_reg <= 1'b0;
        if (sample_update_sync2_reg ^ sample_update_sync3_reg) begin
            sample_avg_sync_reg <= sample_avg_reg;
            sample_avg_sync_valid_reg <= 1'b1;
        end
    end else begin
        sample_acc_reg <= sample_acc_reg + ((wr_depth * 2**LOG_AVG_SCALE - sample_acc_reg) >> LOG_AVG);
        sample_cnt_reg <= sample_cnt_reg + 1;

        sample_avg_sync_valid_reg <= 1'b0;
        if (sample_cnt_reg == 0) begin
            sample_avg_sync_reg <= sample_acc_reg;
            sample_avg_sync_valid_reg <= 1'b1;
        end
    end
end

always @* begin
    write = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_gray_next = wr_ptr_gray_reg;

    wr_acc_next = wr_acc_reg + wr_inc_reg;
    wr_inc_next = wr_inc_reg;

    err_int_next = err_int_reg;

    if (sample_avg_sync_valid_reg) begin
        // updated sampled FIFO depth
        err_int_next = err_int_reg + (sample_avg_sync_reg - (2**LOG_FIFO_DEPTH * 2**LOG_AVG_SCALE));
        wr_inc_next = WR_PERIOD + (((2**LOG_FIFO_DEPTH * 2**LOG_AVG_SCALE) - sample_avg_sync_reg) >> 8) - ($signed(err_int_reg) >> 13);
        if ($signed(wr_inc_next) > $signed(WR_PERIOD*4)) begin
            wr_inc_next = WR_PERIOD*4;
        end else if ($signed(wr_inc_next) < $signed(WR_PERIOD/4)) begin
            wr_inc_next = WR_PERIOD/4;
        end
    end

    if (!full && wr_acc_reg[15] != wr_acc_next[15]) begin
        write = 1'b1;
        wr_ptr_next = wr_ptr_reg + 1;
        wr_ptr_gray_next = wr_ptr_next ^ (wr_ptr_next >> 1);
    end
end

always @(posedge input_clk) begin
    wr_ptr_reg <= wr_ptr_next;
    wr_ptr_gray_reg <= wr_ptr_gray_next;

    wr_acc_reg <= wr_acc_next;
    wr_inc_reg <= wr_inc_next;

    err_int_reg <= err_int_next;

    if (write) begin
        mem[wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= input_ts;
    end

    if (input_rst) begin
        wr_ptr_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        wr_acc_reg <= 16'd0;
        wr_inc_reg <= WR_PERIOD;

        err_int_reg <= 0;
    end
end

always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;
    rd_ptr_gray_next = rd_ptr_gray_reg;

    rd_cnt_next = rd_cnt_reg + 1;

    if (!empty && rd_cnt_reg == 0) begin
        read = 1'b1;
        rd_ptr_next = rd_ptr_reg + 1;
        rd_ptr_gray_next = rd_ptr_next ^ (rd_ptr_next >> 1);
    end
end

always @(posedge output_clk) begin
    rd_ptr_reg <= rd_ptr_next;
    rd_ptr_gray_reg <= rd_ptr_gray_next;

    rd_cnt_reg <= rd_cnt_next;

    if (!empty) begin
        mem_read_data_reg <= mem[rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
    end

    if (read) begin
        
    end

    if (output_rst) begin
        rd_ptr_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_reg <= {FIFO_ADDR_WIDTH+1{1'b0}};
        rd_cnt_reg <= {LOG_RATE{1'b0}};
    end
end

reg sec_mismatch_reg = 1'b0;
reg diff_valid_reg = 1'b0;
reg diff_offset_valid_reg = 1'b0;

reg [TS_NS_WIDTH+1-1:0] ts_ns_diff_reg = 31'd0;
reg [FNS_WIDTH-1:0] ts_fns_diff_reg = 16'd0;

reg [48:0] time_err_int_reg = 32'd0;

always @(posedge output_clk) begin
    ts_step_reg <= 0;

    diff_valid_reg <= 1'b0;
    diff_offset_valid_reg <= 1'b0;

    // 96 bit timestamp
    if (TS_WIDTH == 96) begin
        if (!ts_ns_ovf_reg[30]) begin
            // if the overflow lookahead did not borrow, one second has elapsed
            // increment seconds field, pre-compute both normal increment and overflow values
            {ts_ns_inc_reg, ts_fns_inc_reg} <= {ts_ns_ovf_reg, ts_fns_ovf_reg} + {period_ns_reg, period_fns_reg};
            {ts_ns_ovf_reg, ts_fns_ovf_reg} <= {ts_ns_ovf_reg, ts_fns_ovf_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
            {ts_ns_reg, ts_fns_reg} <= {ts_ns_ovf_reg, ts_fns_ovf_reg};
            ts_s_reg <= ts_s_reg + 1;
        end else begin
            // no increment seconds field, pre-compute both normal increment and overflow values
            {ts_ns_inc_reg, ts_fns_inc_reg} <= {ts_ns_inc_reg, ts_fns_inc_reg} + {period_ns_reg, period_fns_reg};
            {ts_ns_ovf_reg, ts_fns_ovf_reg} <= {ts_ns_inc_reg, ts_fns_inc_reg} + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
            {ts_ns_reg, ts_fns_reg} <= {ts_ns_inc_reg, ts_fns_inc_reg};
            ts_s_reg <= ts_s_reg;
        end
    end else if (TS_WIDTH == 64) begin
        {ts_ns_reg, ts_fns_reg} <= {ts_ns_reg, ts_fns_reg} + {period_ns_reg, period_fns_reg};
    end

    // FIFO dequeue
    if (read) begin
        // dequeue from FIFO
        if (TS_WIDTH == 96) begin
            if (mem_read_data_reg[95:48] != ts_s_reg) begin
                // seconds field doesn't match
                if (!sec_mismatch_reg) begin
                    // ignore the first time
                    sec_mismatch_reg <= 1'b1;
                end else begin
                    // two seconds mismatches in a row; step the clock
                    sec_mismatch_reg <= 1'b0;

                    {ts_ns_inc_reg, ts_fns_inc_reg} <= (FNS_WIDTH > 16 ? mem_read_data_reg[45:0] << (FNS_WIDTH-16) : mem_read_data_reg[45:0] >> (16-FNS_WIDTH)) + {period_ns_reg, period_fns_reg};
                    {ts_ns_ovf_reg, ts_fns_ovf_reg} <= (FNS_WIDTH > 16 ? mem_read_data_reg[45:0] << (FNS_WIDTH-16) : mem_read_data_reg[45:0] >> (16-FNS_WIDTH)) + {period_ns_reg, period_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
                    ts_s_reg <= mem_read_data_reg[95:48];
                    ts_ns_reg <= mem_read_data_reg[45:16];
                    ts_fns_reg <= FNS_WIDTH > 16 ? mem_read_data_reg[15:0] << (FNS_WIDTH-16) : mem_read_data_reg[15:0] >> (16-FNS_WIDTH);
                    ts_step_reg <= 1;
                end
            end else begin
                // compute difference
                sec_mismatch_reg <= 1'b0;
                diff_valid_reg <= 1'b1;
                {ts_ns_diff_reg, ts_fns_diff_reg} <= {ts_ns_reg, ts_fns_reg} - (FNS_WIDTH > 16 ? mem_read_data_reg[45:0] << (FNS_WIDTH-16) : mem_read_data_reg[45:0] >> (16-FNS_WIDTH));
            end
        end else if (TS_WIDTH == 64) begin
            if (mem_read_data_reg[63:48] != ts_ns_reg[47:32]) begin
                // high-order bits don't match
                if (!sec_mismatch_reg) begin
                    // ignore the first time
                    sec_mismatch_reg <= 1'b1;
                end else begin
                    // two seconds mismatches in a row; step the clock
                    sec_mismatch_reg <= 1'b0;

                    ts_ns_reg <= mem_read_data_reg[63:16];
                    ts_fns_reg <= FNS_WIDTH > 16 ? mem_read_data_reg[15:0] << (FNS_WIDTH-16) : mem_read_data_reg[15:0] >> (16-FNS_WIDTH);
                    ts_step_reg <= 1;
                end
            end else begin
                // compute difference
                sec_mismatch_reg <= 1'b0;
                diff_valid_reg <= 1'b1;
                {ts_ns_diff_reg, ts_fns_diff_reg} <= {ts_ns_reg, ts_fns_reg} - (FNS_WIDTH > 16 ? mem_read_data_reg[63:0] << (FNS_WIDTH-16) : mem_read_data_reg[63:0] >> (16-FNS_WIDTH));
            end
        end
    end else if (diff_valid_reg) begin
        // offset difference by FIFO delay
        diff_offset_valid_reg <= 1'b1;
        diff_valid_reg <= 1'b0;
        {ts_ns_diff_reg, ts_fns_diff_reg} <= {ts_ns_diff_reg, ts_fns_diff_reg} - ({period_ns_reg, period_fns_reg} * 2**(LOG_RATE + LOG_FIFO_DEPTH));
    end else if (diff_offset_valid_reg) begin
        // PI control
        diff_offset_valid_reg <= 1'b0;
        if (($signed({ts_ns_diff_reg, ts_fns_diff_reg}) / 2**10) + ($signed(time_err_int_reg) / 2**16) > 4*2**16) begin
            // limit positive adjustment
            time_err_int_reg <= 0;
            {period_ns_reg, period_fns_reg} <= $signed(OUTPUT_PERIOD_NS*2**16 + OUTPUT_PERIOD_FNS) - ({4'd4, {FNS_WIDTH{1'b0}}});
        end else if (($signed({ts_ns_diff_reg, ts_fns_diff_reg}) / 2**10) + ($signed(time_err_int_reg) / 2**16) < -8*2**16) begin
            // limit negative adjustment
            time_err_int_reg <= 0;
            {period_ns_reg, period_fns_reg} <= $signed(OUTPUT_PERIOD_NS*2**16 + OUTPUT_PERIOD_FNS) + ({4'd8, {FNS_WIDTH{1'b0}}});
        end else begin
            time_err_int_reg <= $signed(time_err_int_reg) + $signed({ts_ns_diff_reg, ts_fns_diff_reg});
            {period_ns_reg, period_fns_reg} <= $signed(OUTPUT_PERIOD_NS*2**16 + OUTPUT_PERIOD_FNS) - ($signed({ts_ns_diff_reg, ts_fns_diff_reg}) / 2**10) - ($signed(time_err_int_reg) / 2**16);
        end
    end

    if (TS_WIDTH == 96) begin
        pps_reg <= !ts_ns_ovf_reg[30];
    end else if (TS_WIDTH == 64) begin
        pps_reg <= 1'b0; // not currently implemented for 64 bit timestamp format
    end

    if (output_rst) begin
        period_ns_reg <= OUTPUT_PERIOD_NS;
        period_fns_reg <= OUTPUT_PERIOD_FNS;
        ts_s_reg <= 0;
        ts_ns_reg <= 0;
        ts_fns_reg <= 0;
        ts_ns_inc_reg <= 0;
        ts_fns_inc_reg <= 0;
        ts_ns_ovf_reg <= {TS_NS_WIDTH+1{1'b1}};
        ts_fns_ovf_reg <= {FNS_WIDTH{1'b1}};
        ts_step_reg <= 0;
        pps_reg <= 0;
    end
end

endmodule
