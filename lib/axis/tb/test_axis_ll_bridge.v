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
 * Testbench for axis_ll_bridge
 */
module test_axis_ll_bridge;

// Parameters
parameter DATA_WIDTH = 8;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] s_axis_tdata = 0;
reg s_axis_tvalid = 0;
reg s_axis_tlast = 0;
reg ll_dst_rdy_in_n = 1;

// Outputs
wire [DATA_WIDTH-1:0] ll_data_out;
wire ll_sof_out_n;
wire ll_eof_out_n;
wire ll_src_rdy_out_n;
wire s_axis_tready;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_axis_tdata,
        s_axis_tvalid,
        s_axis_tlast,
        ll_dst_rdy_in_n
    );
    $to_myhdl(
        ll_data_out,
        ll_sof_out_n,
        ll_eof_out_n,
        ll_src_rdy_out_n,
        s_axis_tready
    );

    // dump file
    $dumpfile("test_axis_ll_bridge.lxt");
    $dumpvars(0, test_axis_ll_bridge);
end

axis_ll_bridge #(
    .DATA_WIDTH(DATA_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    // locallink output
    .ll_data_out(ll_data_out),
    .ll_sof_out_n(ll_sof_out_n),
    .ll_eof_out_n(ll_eof_out_n),
    .ll_src_rdy_out_n(ll_src_rdy_out_n),
    .ll_dst_rdy_in_n(ll_dst_rdy_in_n)
);

endmodule
