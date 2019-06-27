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
 * Testbench for ptp_perout
 */
module test_ptp_perout;

// Parameters
parameter FNS_ENABLE = 1;
parameter OUT_START_S = 48'h0;
parameter OUT_START_NS = 30'h0;
parameter OUT_START_FNS = 16'h0000;
parameter OUT_PERIOD_S = 48'd1;
parameter OUT_PERIOD_NS = 30'd0;
parameter OUT_PERIOD_FNS = 16'h0000;
parameter OUT_WIDTH_S = 48'h0;
parameter OUT_WIDTH_NS = 30'd1000;
parameter OUT_WIDTH_FNS = 16'h0000;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [95:0] input_ts_96 = 0;
reg input_ts_step = 0;
reg enable = 0;
reg [95:0] input_start = 0;
reg input_start_valid = 0;
reg [95:0] input_period = 0;
reg input_period_valid = 0;
reg [95:0] input_width = 0;
reg input_width_valid = 0;

// Outputs
wire locked;
wire error;
wire output_pulse;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_ts_96,
        input_ts_step,
        enable,
        input_start,
        input_start_valid,
        input_period,
        input_period_valid,
        input_width,
        input_width_valid
    );
    $to_myhdl(
        locked,
        error,
        output_pulse
    );

    // dump file
    $dumpfile("test_ptp_perout.lxt");
    $dumpvars(0, test_ptp_perout);
end

ptp_perout #(
    .FNS_ENABLE(FNS_ENABLE),
    .OUT_START_S(OUT_START_S),
    .OUT_START_NS(OUT_START_NS),
    .OUT_START_FNS(OUT_START_FNS),
    .OUT_PERIOD_S(OUT_PERIOD_S),
    .OUT_PERIOD_NS(OUT_PERIOD_NS),
    .OUT_PERIOD_FNS(OUT_PERIOD_FNS),
    .OUT_WIDTH_S(OUT_WIDTH_S),
    .OUT_WIDTH_NS(OUT_WIDTH_NS),
    .OUT_WIDTH_FNS(OUT_WIDTH_FNS)
)
UUT (
    .clk(clk),
    .rst(rst),
    .input_ts_96(input_ts_96),
    .input_ts_step(input_ts_step),
    .enable(enable),
    .input_start(input_start),
    .input_start_valid(input_start_valid),
    .input_period(input_period),
    .input_period_valid(input_period_valid),
    .input_width(input_width),
    .input_width_valid(input_width_valid),
    .locked(locked),
    .error(error),
    .output_pulse(output_pulse)
);

endmodule
