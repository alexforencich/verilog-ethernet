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

module test_axis_stat_counter;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [63:0] monitor_axis_tdata = 8'd0;
reg [7:0] monitor_axis_tkeep = 8'd0;
reg monitor_axis_tvalid = 1'b0;
reg monitor_axis_tready = 1'b0;
reg monitor_axis_tlast = 1'b0;
reg monitor_axis_tuser = 1'b0;
reg output_axis_tready = 1'b0;
reg [15:0] tag = 0;
reg trigger = 0;

// Outputs
wire [7:0] output_axis_tdata;
wire output_axis_tvalid;
wire output_axis_tlast;
wire output_axis_tuser;

initial begin
    // myhdl integration
    $from_myhdl(clk,
                rst,
                current_test,
                monitor_axis_tdata,
                monitor_axis_tkeep,
                monitor_axis_tvalid,
                monitor_axis_tready,
                monitor_axis_tlast,
                monitor_axis_tuser,
                output_axis_tready,
                tag,
                trigger);
    $to_myhdl(output_axis_tdata,
                output_axis_tvalid,
                output_axis_tlast,
                output_axis_tuser);

    // dump file
    $dumpfile("test_axis_stat_counter.lxt");
    $dumpvars(0, test_axis_stat_counter);
end

axis_stat_counter #(
    .DATA_WIDTH(64)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi monitor input
    .monitor_axis_tkeep(monitor_axis_tkeep),
    .monitor_axis_tvalid(monitor_axis_tvalid),
    .monitor_axis_tready(monitor_axis_tready),
    .monitor_axis_tlast(monitor_axis_tlast),
    // axi output
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tuser(output_axis_tuser),
    // configuration
    .tag(tag),
    .trigger(trigger)
);

endmodule
