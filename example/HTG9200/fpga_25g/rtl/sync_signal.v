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

// Language: Verilog-2001

`resetall
`timescale 1 ns / 1 ps
`default_nettype none

/*
 * Synchronizes an asyncronous signal to a given clock by using a pipeline of
 * two registers.
 */
module sync_signal #(
    parameter WIDTH=1, // width of the input and output signals
    parameter N=2 // depth of synchronizer
)(
    input wire clk,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

reg [WIDTH-1:0] sync_reg[N-1:0];

/*
 * The synchronized output is the last register in the pipeline.
 */
assign out = sync_reg[N-1];

integer k;

always @(posedge clk) begin
    sync_reg[0] <= in;
    for (k = 1; k < N; k = k + 1) begin
        sync_reg[k] <= sync_reg[k-1];
    end
end

endmodule

`resetall
