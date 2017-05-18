/*

Copyright (c) 2014-2017 Alex Forencich

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
 * Testbench for axis_async_frame_fifo_64
 */
module test_axis_async_frame_fifo_64;

// Parameters
parameter ADDR_WIDTH = 6;
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter DROP_WHEN_FULL = 0;

// Inputs
reg async_rst = 0;
reg input_clk = 0;
reg output_clk = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] input_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] input_axis_tkeep = 0;
reg input_axis_tvalid = 0;
reg input_axis_tlast = 0;
reg input_axis_tuser = 0;
reg output_axis_tready = 0;

// Outputs
wire input_axis_tready;
wire [DATA_WIDTH-1:0] output_axis_tdata;
wire [KEEP_WIDTH-1:0] output_axis_tkeep;
wire output_axis_tvalid;
wire output_axis_tlast;
wire input_status_overflow;
wire input_status_bad_frame;
wire input_status_good_frame;
wire output_status_overflow;
wire output_status_bad_frame;
wire output_status_good_frame;

initial begin
    // myhdl integration
    $from_myhdl(
        async_rst,
        input_clk,
        output_clk,
        current_test,
        input_axis_tdata,
        input_axis_tkeep,
        input_axis_tvalid,
        input_axis_tlast,
        input_axis_tuser,
        output_axis_tready
    );
    $to_myhdl(
        input_axis_tready,
        output_axis_tdata,
        output_axis_tkeep,
        output_axis_tvalid,
        output_axis_tlast,
        input_status_overflow,
        input_status_bad_frame,
        input_status_good_frame,
        output_status_overflow,
        output_status_bad_frame,
        output_status_good_frame
    );

    // dump file
    $dumpfile("test_axis_async_frame_fifo_64.lxt");
    $dumpvars(0, test_axis_async_frame_fifo_64);
end

axis_async_frame_fifo_64 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .DROP_WHEN_FULL(DROP_WHEN_FULL)
)
UUT (
    // Common reset
    .async_rst(async_rst),
    // AXI input
    .input_clk(input_clk),
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tkeep(input_axis_tkeep),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    // AXI output
    .output_clk(output_clk),
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    // Status
    .input_status_overflow(input_status_overflow),
    .input_status_bad_frame(input_status_bad_frame),
    .input_status_good_frame(input_status_good_frame),
    .output_status_overflow(output_status_overflow),
    .output_status_bad_frame(output_status_bad_frame),
    .output_status_good_frame(output_status_good_frame)
);

endmodule
