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
 * Testbench for axis_frame_len
 */
module test_axis_frame_len_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter LEN_WIDTH = 16;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [KEEP_WIDTH-1:0] monitor_axis_tkeep = 0;
reg monitor_axis_tvalid = 0;
reg monitor_axis_tready = 0;
reg monitor_axis_tlast = 0;

// Outputs
wire [LEN_WIDTH-1:0] frame_len;
wire frame_len_valid;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        monitor_axis_tkeep,
        monitor_axis_tvalid,
        monitor_axis_tready,
        monitor_axis_tlast
    );
    $to_myhdl(
        frame_len,
        frame_len_valid
    );

    // dump file
    $dumpfile("test_axis_frame_len_64.lxt");
    $dumpvars(0, test_axis_frame_len_64);
end

axis_frame_len #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .LEN_WIDTH(LEN_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // AXI monitor
    .monitor_axis_tkeep(monitor_axis_tkeep),
    .monitor_axis_tvalid(monitor_axis_tvalid),
    .monitor_axis_tready(monitor_axis_tready),
    .monitor_axis_tlast(monitor_axis_tlast),
    // Status
    .frame_len(frame_len),
    .frame_len_valid(frame_len_valid)
);

endmodule
