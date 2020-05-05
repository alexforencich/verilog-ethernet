/*

Copyright (c) 2015-2018 Alex Forencich

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
 * Testbench for axis_eth_fcs
 */
module test_axis_eth_fcs;

// Parameters
parameter DATA_WIDTH = 8;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] s_axis_tkeep = 0;
reg s_axis_tvalid = 0;
reg s_axis_tlast = 0;
reg s_axis_tuser = 0;

// Outputs
wire s_axis_tready;
wire [31:0] output_fcs;
wire output_fcs_valid;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_axis_tdata,
        s_axis_tkeep,
        s_axis_tvalid,
        s_axis_tlast,
        s_axis_tuser
    );
    $to_myhdl(
        s_axis_tready,
        output_fcs,
        output_fcs_valid
    );

    // dump file
    $dumpfile("test_axis_eth_fcs.lxt");
    $dumpvars(0, test_axis_eth_fcs);
end

axis_eth_fcs #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tuser(s_axis_tuser),
    .output_fcs(output_fcs),
    .output_fcs_valid(output_fcs_valid)
);

endmodule
