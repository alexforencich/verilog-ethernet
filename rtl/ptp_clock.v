/*

Copyright (c) 2015-2019 Alex Forencich

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
 * PTP clock module
 */
module ptp_clock #
(
    parameter PERIOD_NS_WIDTH = 4,
    parameter OFFSET_NS_WIDTH = 4,
    parameter DRIFT_NS_WIDTH = 4,
    parameter FNS_WIDTH = 16,
    parameter PERIOD_NS = 4'h6,
    parameter PERIOD_FNS = 16'h6666,
    parameter DRIFT_ENABLE = 1,
    parameter DRIFT_NS = 4'h0,
    parameter DRIFT_FNS = 16'h0002,
    parameter DRIFT_RATE = 16'h0005
)
(
    input  wire                       clk,
    input  wire                       rst,

    /*
     * Timestamp inputs for synchronization
     */
    input  wire [95:0]                input_ts_96,
    input  wire                       input_ts_96_valid,
    input  wire [63:0]                input_ts_64,
    input  wire                       input_ts_64_valid,

    /*
     * Period adjustment
     */
    input  wire [PERIOD_NS_WIDTH-1:0] input_period_ns,
    input  wire [FNS_WIDTH-1:0]       input_period_fns,
    input  wire                       input_period_valid,

    /*
     * Offset adjustment
     */
    input  wire [OFFSET_NS_WIDTH-1:0] input_adj_ns,
    input  wire [FNS_WIDTH-1:0]       input_adj_fns,
    input  wire [15:0]                input_adj_count,
    input  wire                       input_adj_valid,
    output wire                       input_adj_active,

    /*
     * Drift adjustment
     */
    input  wire [DRIFT_NS_WIDTH-1:0]  input_drift_ns,
    input  wire [FNS_WIDTH-1:0]       input_drift_fns,
    input  wire [15:0]                input_drift_rate,
    input  wire                       input_drift_valid,

    /*
     * Timestamp outputs
     */
    output wire [95:0]                output_ts_96,
    output wire [63:0]                output_ts_64,
    output wire                       output_ts_step,

    /*
     * PPS output
     */
    output wire                       output_pps
);

parameter INC_NS_WIDTH = $clog2(2**PERIOD_NS_WIDTH + 2**OFFSET_NS_WIDTH + 2**DRIFT_NS_WIDTH);

reg [PERIOD_NS_WIDTH-1:0] period_ns_reg = PERIOD_NS;
reg [FNS_WIDTH-1:0] period_fns_reg = PERIOD_FNS;

reg [OFFSET_NS_WIDTH-1:0] adj_ns_reg = 0;
reg [FNS_WIDTH-1:0] adj_fns_reg = 0;
reg [15:0] adj_count_reg = 0;
reg adj_active_reg = 0;

reg [DRIFT_NS_WIDTH-1:0] drift_ns_reg = DRIFT_NS;
reg [FNS_WIDTH-1:0] drift_fns_reg = DRIFT_FNS;
reg [15:0] drift_rate_reg = DRIFT_RATE;

reg [INC_NS_WIDTH-1:0] ts_inc_ns_reg = 0;
reg [FNS_WIDTH-1:0] ts_inc_fns_reg = 0;

reg [47:0] ts_96_s_reg = 0;
reg [29:0] ts_96_ns_reg = 0;
reg [FNS_WIDTH-1:0] ts_96_fns_reg = 0;
reg [29:0] ts_96_ns_inc_reg = 0;
reg [FNS_WIDTH-1:0] ts_96_fns_inc_reg = 0;
reg [30:0] ts_96_ns_ovf_reg = 31'h7fffffff;
reg [FNS_WIDTH-1:0] ts_96_fns_ovf_reg = 16'hffff;

reg [47:0] ts_64_ns_reg = 0;
reg [FNS_WIDTH-1:0] ts_64_fns_reg = 0;

reg ts_step_reg = 1'b0;

reg [15:0] drift_cnt = 0;

reg [47:0] temp;

reg pps_reg = 0;

assign input_adj_active = adj_active_reg;

assign output_ts_96[95:48] = ts_96_s_reg;
assign output_ts_96[47:46] = 2'b00;
assign output_ts_96[45:16] = ts_96_ns_reg;
assign output_ts_96[15:0]  = FNS_WIDTH > 16 ? ts_96_fns_reg >> (FNS_WIDTH-16) : ts_96_fns_reg << (16-FNS_WIDTH);
assign output_ts_64[63:16] = ts_64_ns_reg;
assign output_ts_64[15:0]  = FNS_WIDTH > 16 ? ts_64_fns_reg >> (FNS_WIDTH-16) : ts_64_fns_reg << (16-FNS_WIDTH);
assign output_ts_step = ts_step_reg;

assign output_pps = pps_reg;

always @(posedge clk) begin
    ts_step_reg <= 0;

    // latch parameters
    if (input_period_valid) begin
        period_ns_reg <= input_period_ns;
        period_fns_reg <= input_period_fns;
    end

    if (input_adj_valid) begin
        adj_ns_reg <= input_adj_ns;
        adj_fns_reg <= input_adj_fns;
        adj_count_reg <= input_adj_count;
    end

    if (DRIFT_ENABLE && input_drift_valid) begin
        drift_ns_reg <= input_drift_ns;
        drift_fns_reg <= input_drift_fns;
        drift_rate_reg <= input_drift_rate;
    end

    // timestamp increment calculation
    {ts_inc_ns_reg, ts_inc_fns_reg} <= $signed({1'b0, period_ns_reg, period_fns_reg}) +
        (adj_active_reg ? $signed({adj_ns_reg, adj_fns_reg}) : 0) +
        ((DRIFT_ENABLE && drift_cnt == 0) ? $signed({drift_ns_reg, drift_fns_reg}) : 0);

    // offset adjust counter
    if (adj_count_reg > 0) begin
        adj_count_reg <= adj_count_reg - 1;
        adj_active_reg <= 1;
        ts_step_reg <= 1;
    end else begin
        adj_active_reg <= 0;
    end

    // drift counter
    if (drift_cnt == 0) begin
        drift_cnt <= drift_rate_reg-1;
    end else begin
        drift_cnt <= drift_cnt - 1;
    end

    // 96 bit timestamp
    if (input_ts_96_valid) begin
        // load timestamp
        {ts_96_ns_inc_reg, ts_96_fns_inc_reg} <= (FNS_WIDTH > 16 ? input_ts_96[45:0] << (FNS_WIDTH-16) : input_ts_96[45:0] >> (16-FNS_WIDTH)) + {ts_inc_ns_reg, ts_inc_fns_reg};
        {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg} <= (FNS_WIDTH > 16 ? input_ts_96[45:0] << (FNS_WIDTH-16) : input_ts_96[45:0] >> (16-FNS_WIDTH)) + {ts_inc_ns_reg, ts_inc_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
        ts_96_s_reg <= input_ts_96[95:48];
        ts_96_ns_reg <= input_ts_96[45:16];
        ts_96_fns_reg <= FNS_WIDTH > 16 ? input_ts_96[15:0] << (FNS_WIDTH-16) : input_ts_96[15:0] >> (16-FNS_WIDTH);
        ts_step_reg <= 1;
    end else if (!ts_96_ns_ovf_reg[30]) begin
        // if the overflow lookahead did not borrow, one second has elapsed
        // increment seconds field, pre-compute both normal increment and overflow values
        {ts_96_ns_inc_reg, ts_96_fns_inc_reg} <= {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg} + {ts_inc_ns_reg, ts_inc_fns_reg};
        {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg} <= {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg} + {ts_inc_ns_reg, ts_inc_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
        {ts_96_ns_reg, ts_96_fns_reg} <= {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg};
        ts_96_s_reg <= ts_96_s_reg + 1;
    end else begin
        // no increment seconds field, pre-compute both normal increment and overflow values
        {ts_96_ns_inc_reg, ts_96_fns_inc_reg} <= {ts_96_ns_inc_reg, ts_96_fns_inc_reg} + {ts_inc_ns_reg, ts_inc_fns_reg};
        {ts_96_ns_ovf_reg, ts_96_fns_ovf_reg} <= {ts_96_ns_inc_reg, ts_96_fns_inc_reg} + {ts_inc_ns_reg, ts_inc_fns_reg} - {31'd1_000_000_000, {FNS_WIDTH{1'b0}}};
        {ts_96_ns_reg, ts_96_fns_reg} <= {ts_96_ns_inc_reg, ts_96_fns_inc_reg};
        ts_96_s_reg <= ts_96_s_reg;
    end

    // 64 bit timestamp
    if (input_ts_64_valid) begin
        // load timestamp
        {ts_64_ns_reg, ts_64_fns_reg} <= input_ts_64;
        ts_step_reg <= 1;
    end else begin
        {ts_64_ns_reg, ts_64_fns_reg} <= {ts_64_ns_reg, ts_64_fns_reg} + {ts_inc_ns_reg, ts_inc_fns_reg};
    end

    pps_reg <= !ts_96_ns_ovf_reg[30];

    if (rst) begin
        period_ns_reg <= PERIOD_NS;
        period_fns_reg <= PERIOD_FNS;
        adj_ns_reg <= 0;
        adj_fns_reg <= 0;
        adj_count_reg <= 0;
        adj_active_reg <= 0;
        drift_ns_reg <= DRIFT_NS;
        drift_fns_reg <= DRIFT_FNS;
        drift_rate_reg <= DRIFT_RATE;
        ts_inc_ns_reg <= 0;
        ts_inc_fns_reg <= 0;
        ts_96_s_reg <= 0;
        ts_96_ns_reg <= 0;
        ts_96_fns_reg <= 0;
        ts_96_ns_inc_reg <= 0;
        ts_96_fns_inc_reg <= 0;
        ts_96_ns_ovf_reg <= 31'h7fffffff;
        ts_96_fns_ovf_reg <= {FNS_WIDTH{1'b1}};
        ts_64_ns_reg <= 0;
        ts_64_fns_reg <= 0;
        ts_step_reg <= 0;
        drift_cnt <= 0;
        pps_reg <= 0;
    end
end

endmodule

`resetall
