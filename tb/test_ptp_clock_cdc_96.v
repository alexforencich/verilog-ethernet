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

`timescale 1ps / 1fs

/*
 * Testbench for ptp_clock_cdc
 */
module test_ptp_clock_cdc_96;

// Parameters
parameter TS_WIDTH = 96;
parameter NS_WIDTH = 4;
parameter FNS_WIDTH = 16;
parameter INPUT_PERIOD_NS = 4'h6;
parameter INPUT_PERIOD_FNS = 16'h6666;
parameter OUTPUT_PERIOD_NS = 4'h6;
parameter OUTPUT_PERIOD_FNS = 16'h6666;
parameter USE_SAMPLE_CLOCK = 1;
parameter LOG_FIFO_DEPTH = 3;
parameter LOG_RATE = 3;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_clk = 0;
reg input_rst = 0;
reg output_clk = 0;
reg output_rst = 0;
reg sample_clk = 0;
reg [TS_WIDTH-1:0] input_ts = 0;

// Outputs
wire [TS_WIDTH-1:0] output_ts;
wire output_ts_step;
wire output_pps;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_clk,
        input_rst,
        output_clk,
        output_rst,
        sample_clk,
        input_ts
    );
    $to_myhdl(
        output_ts,
        output_ts_step,
        output_pps
    );

    // dump file
    $dumpfile("test_ptp_clock_cdc_96.lxt");
    $dumpvars(0, test_ptp_clock_cdc_96);
end

ptp_clock_cdc #(
    .TS_WIDTH(TS_WIDTH),
    .NS_WIDTH(NS_WIDTH),
    .FNS_WIDTH(FNS_WIDTH),
    .INPUT_PERIOD_NS(INPUT_PERIOD_NS),
    .INPUT_PERIOD_FNS(INPUT_PERIOD_FNS),
    .OUTPUT_PERIOD_NS(OUTPUT_PERIOD_NS),
    .OUTPUT_PERIOD_FNS(OUTPUT_PERIOD_FNS),
    .USE_SAMPLE_CLOCK(USE_SAMPLE_CLOCK),
    .LOG_FIFO_DEPTH(LOG_FIFO_DEPTH),
    .LOG_RATE(LOG_RATE)
)
UUT (
    .input_clk(input_clk),
    .input_rst(input_rst),
    .output_clk(output_clk),
    .output_rst(output_rst),
    .sample_clk(sample_clk),
    .input_ts(input_ts),
    .output_ts(output_ts),
    .output_ts_step(output_ts_step),
    .output_pps(output_pps)
);

endmodule
