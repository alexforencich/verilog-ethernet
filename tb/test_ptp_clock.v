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

`timescale 1ps / 1fs

/*
 * Testbench for ptp_clock
 */
module test_ptp_clock;

// Parameters
parameter PERIOD_NS_WIDTH = 4;
parameter OFFSET_NS_WIDTH = 4;
parameter DRIFT_NS_WIDTH = 4;
parameter FNS_WIDTH = 16;
parameter PERIOD_NS = 4'h6;
parameter PERIOD_FNS = 16'h6666;
parameter DRIFT_ENABLE = 1;
parameter DRIFT_NS = 4'h0;
parameter DRIFT_FNS = 16'h0002;
parameter DRIFT_RATE = 16'h0005;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [95:0] input_ts_96 = 0;
reg input_ts_96_valid = 0;
reg [63:0] input_ts_64 = 0;
reg input_ts_64_valid = 0;
reg [PERIOD_NS_WIDTH-1:0] input_period_ns = 0;
reg [FNS_WIDTH-1:0] input_period_fns = 0;
reg input_period_valid = 0;
reg [OFFSET_NS_WIDTH-1:0] input_adj_ns = 0;
reg [FNS_WIDTH-1:0] input_adj_fns = 0;
reg [15:0] input_adj_count = 0;
reg input_adj_valid = 0;
reg [DRIFT_NS_WIDTH-1:0] input_drift_ns = 0;
reg [FNS_WIDTH-1:0] input_drift_fns = 0;
reg [15:0] input_drift_rate = 0;
reg input_drift_valid = 0;

// Outputs
wire input_adj_active;
wire [95:0] output_ts_96;
wire [63:0] output_ts_64;
wire output_ts_step;
wire output_pps;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_ts_96,
        input_ts_96_valid,
        input_ts_64,
        input_ts_64_valid,
        input_period_ns,
        input_period_fns,
        input_period_valid,
        input_adj_ns,
        input_adj_fns,
        input_adj_count,
        input_adj_valid,
        input_drift_ns,
        input_drift_fns,
        input_drift_rate,
        input_drift_valid
    );
    $to_myhdl(
        input_adj_active,
        output_ts_96,
        output_ts_64,
        output_ts_step,
        output_pps
    );

    // dump file
    $dumpfile("test_ptp_clock.lxt");
    $dumpvars(0, test_ptp_clock);
end

ptp_clock #(
    .PERIOD_NS_WIDTH(PERIOD_NS_WIDTH),
    .OFFSET_NS_WIDTH(OFFSET_NS_WIDTH),
    .DRIFT_NS_WIDTH (DRIFT_NS_WIDTH),
    .FNS_WIDTH(FNS_WIDTH),
    .PERIOD_NS(PERIOD_NS),
    .PERIOD_FNS(PERIOD_FNS),
    .DRIFT_ENABLE(DRIFT_ENABLE),
    .DRIFT_NS(DRIFT_NS),
    .DRIFT_FNS(DRIFT_FNS),
    .DRIFT_RATE(DRIFT_RATE)
)
UUT (
    .clk(clk),
    .rst(rst),
    .input_ts_96(input_ts_96),
    .input_ts_96_valid(input_ts_96_valid),
    .input_ts_64(input_ts_64),
    .input_ts_64_valid(input_ts_64_valid),
    .input_period_ns(input_period_ns),
    .input_period_fns(input_period_fns),
    .input_period_valid(input_period_valid),
    .input_adj_ns(input_adj_ns),
    .input_adj_fns(input_adj_fns),
    .input_adj_count(input_adj_count),
    .input_adj_valid(input_adj_valid),
    .input_adj_active(input_adj_active),
    .input_drift_ns(input_drift_ns),
    .input_drift_fns(input_drift_fns),
    .input_drift_rate(input_drift_rate),
    .input_drift_valid(input_drift_valid),
    .output_ts_96(output_ts_96),
    .output_ts_64(output_ts_64),
    .output_ts_step(output_ts_step),
    .output_pps(output_pps)
);

endmodule
