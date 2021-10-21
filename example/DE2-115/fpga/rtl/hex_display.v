/*

Copyright (c) 2020 Alex Forencich

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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 7 segment display hexadecimal encoding
 */
module hex_display #(
    parameter INVERT = 0
)
(
    input  wire [3:0] in,
    input  wire       enable,

    output wire [6:0] out
);

reg [6:0] enc;

always @* begin
    enc <= 7'b0000000;
    if (enable) begin
        case (in)
            4'h0: enc <= 7'b0111111;
            4'h1: enc <= 7'b0000110;
            4'h2: enc <= 7'b1011011;
            4'h3: enc <= 7'b1001111;
            4'h4: enc <= 7'b1100110;
            4'h5: enc <= 7'b1101101;
            4'h6: enc <= 7'b1111101;
            4'h7: enc <= 7'b0000111;
            4'h8: enc <= 7'b1111111;
            4'h9: enc <= 7'b1101111;
            4'ha: enc <= 7'b1110111;
            4'hb: enc <= 7'b1111100;
            4'hc: enc <= 7'b0111001;
            4'hd: enc <= 7'b1011110;
            4'he: enc <= 7'b1111001;
            4'hf: enc <= 7'b1110001;
        endcase
    end
end

assign out = INVERT ? ~enc : enc;

endmodule

`resetall
