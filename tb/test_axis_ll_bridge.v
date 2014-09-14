/*

Copyright (c) 2014 Alex Forencich

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

`timescale 1 ns / 1 ps

module test_axis_ll_bridge;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [7:0] axis_tdata = 8'd0;
reg axis_tvalid = 1'b0;
reg axis_tlast = 1'b0;
reg ll_dst_rdy_in_n = 1'b1;

// Outputs
wire [7:0] ll_data_out;
wire ll_sof_out_n;
wire ll_eof_out_n;
wire ll_src_rdy_out_n;
wire axis_tready;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                axis_tdata,
                axis_tvalid,
                axis_tlast,
                ll_dst_rdy_in_n);
    $to_myhdl(ll_data_out,
              ll_sof_out_n,
              ll_eof_out_n,
              ll_src_rdy_out_n,
              axis_tready);

    // dump file
    $dumpfile("test_axis_ll_bridge.lxt");
    $dumpvars(0, test_axis_ll_bridge);
end

axis_ll_bridge
UUT (
    .clk(clk),
    .rst(rst),
    // axi input
    .axis_tdata(axis_tdata),
    .axis_tvalid(axis_tvalid),
    .axis_tready(axis_tready),
    .axis_tlast(axis_tlast),
    // locallink output
    .ll_data_out(ll_data_out),
    .ll_sof_out_n(ll_sof_out_n),
    .ll_eof_out_n(ll_eof_out_n),
    .ll_src_rdy_out_n(ll_src_rdy_out_n),
    .ll_dst_rdy_in_n(ll_dst_rdy_in_n)
);

endmodule
