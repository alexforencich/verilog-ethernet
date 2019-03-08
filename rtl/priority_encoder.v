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
 * Priority encoder module
 */
module priority_encoder #
(
    parameter WIDTH = 4,
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "LOW"
)
(
    input  wire [WIDTH-1:0]         input_unencoded,
    output wire                     output_valid,
    output wire [$clog2(WIDTH)-1:0] output_encoded,
    output wire [WIDTH-1:0]         output_unencoded
);

// power-of-two width
parameter W1 = 2**$clog2(WIDTH);
parameter W2 = W1/2;

generate
    if (WIDTH == 1) begin
        // one input
        assign output_valid = input_unencoded;
        assign output_encoded = 0;
    end else if (WIDTH == 2) begin
        // two inputs - just an OR gate
        assign output_valid = |input_unencoded;
        if (LSB_PRIORITY == "LOW") begin
            assign output_encoded = input_unencoded[1];
        end else begin
            assign output_encoded = ~input_unencoded[0];
        end
    end else begin
        // more than two inputs - split into two parts and recurse
        // also pad input to correct power-of-two width
        wire [$clog2(W2)-1:0] out1, out2;
        wire valid1, valid2;
        priority_encoder #(
            .WIDTH(W2),
            .LSB_PRIORITY(LSB_PRIORITY)
        )
        priority_encoder_inst1 (
            .input_unencoded(input_unencoded[W2-1:0]),
            .output_valid(valid1),
            .output_encoded(out1)
        );
        priority_encoder #(
            .WIDTH(W2),
            .LSB_PRIORITY(LSB_PRIORITY)
        )
        priority_encoder_inst2 (
            .input_unencoded({{W1-WIDTH{1'b0}}, input_unencoded[WIDTH-1:W2]}),
            .output_valid(valid2),
            .output_encoded(out2)
        );
        // multiplexer to select part
        assign output_valid = valid1 | valid2;
        if (LSB_PRIORITY == "LOW") begin
            assign output_encoded = valid2 ? {1'b1, out2} : {1'b0, out1};
        end else begin
            assign output_encoded = valid1 ? {1'b0, out1} : {1'b1, out2};
        end
    end
endgenerate

// unencoded output
assign output_unencoded = 1 << output_encoded;

endmodule
