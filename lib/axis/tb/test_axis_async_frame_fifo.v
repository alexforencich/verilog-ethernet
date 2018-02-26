/*

Copyright (c) 2014-2018 Alex Forencich

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
 * Testbench for axis_async_frame_fifo
 */
module test_axis_async_frame_fifo;

// Parameters
parameter ADDR_WIDTH = 9;
parameter DATA_WIDTH = 8;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter ID_ENABLE = 1;
parameter ID_WIDTH = 8;
parameter DEST_ENABLE = 1;
parameter DEST_WIDTH = 8;
parameter USER_ENABLE = 1;
parameter USER_WIDTH = 1;
parameter USER_BAD_FRAME_VALUE = 1'b1;
parameter USER_BAD_FRAME_MASK = 1'b1;
parameter DROP_BAD_FRAME = 1;
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
reg [ID_WIDTH-1:0] input_axis_tid = 0;
reg [DEST_WIDTH-1:0] input_axis_tdest = 0;
reg [USER_WIDTH-1:0] input_axis_tuser = 0;
reg output_axis_tready = 0;

// Outputs
wire input_axis_tready;
wire [DATA_WIDTH-1:0] output_axis_tdata;
wire [KEEP_WIDTH-1:0] output_axis_tkeep;
wire output_axis_tvalid;
wire output_axis_tlast;
wire [ID_WIDTH-1:0] output_axis_tid;
wire [DEST_WIDTH-1:0] output_axis_tdest;
wire [USER_WIDTH-1:0] output_axis_tuser;
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
        input_axis_tid,
        input_axis_tdest,
        input_axis_tuser,
        output_axis_tready
    );
    $to_myhdl(
        input_axis_tready,
        output_axis_tdata,
        output_axis_tkeep,
        output_axis_tvalid,
        output_axis_tlast,
        output_axis_tid,
        output_axis_tdest,
        output_axis_tuser,
        input_status_overflow,
        input_status_bad_frame,
        input_status_good_frame,
        output_status_overflow,
        output_status_bad_frame,
        output_status_good_frame
    );

    // dump file
    $dumpfile("test_axis_async_frame_fifo.lxt");
    $dumpvars(0, test_axis_async_frame_fifo);
end

axis_async_frame_fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .USER_BAD_FRAME_VALUE(USER_BAD_FRAME_VALUE),
    .USER_BAD_FRAME_MASK(USER_BAD_FRAME_MASK),
    .DROP_BAD_FRAME(DROP_BAD_FRAME),
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
    .input_axis_tid(input_axis_tid),
    .input_axis_tdest(input_axis_tdest),
    .input_axis_tuser(input_axis_tuser),
    // AXI output
    .output_clk(output_clk),
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tid(output_axis_tid),
    .output_axis_tdest(output_axis_tdest),
    .output_axis_tuser(output_axis_tuser),
    // Status
    .input_status_overflow(input_status_overflow),
    .input_status_bad_frame(input_status_bad_frame),
    .input_status_good_frame(input_status_good_frame),
    .output_status_overflow(output_status_overflow),
    .output_status_bad_frame(output_status_bad_frame),
    .output_status_good_frame(output_status_good_frame)
);

endmodule
