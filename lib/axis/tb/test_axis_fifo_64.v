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
 * Testbench for axis_fifo
 */
module test_axis_fifo_64;

// Parameters
parameter ADDR_WIDTH = 2;
parameter DATA_WIDTH = 64;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter LAST_ENABLE = 1;
parameter ID_ENABLE = 1;
parameter ID_WIDTH = 8;
parameter DEST_ENABLE = 1;
parameter DEST_WIDTH = 8;
parameter USER_ENABLE = 1;
parameter USER_WIDTH = 1;

// Inputs
reg clk = 0;
reg rst = 0;
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

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
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
        output_axis_tuser
    );

    // dump file
    $dumpfile("test_axis_fifo_64.lxt");
    $dumpvars(0, test_axis_fifo_64);
end

axis_fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .LAST_ENABLE(LAST_ENABLE),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tkeep(input_axis_tkeep),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tid(input_axis_tid),
    .input_axis_tdest(input_axis_tdest),
    .input_axis_tuser(input_axis_tuser),
    // AXI output
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tid(output_axis_tid),
    .output_axis_tdest(output_axis_tdest),
    .output_axis_tuser(output_axis_tuser)
);

endmodule
