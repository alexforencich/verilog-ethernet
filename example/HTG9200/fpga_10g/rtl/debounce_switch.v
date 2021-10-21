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
 * Synchronizes switch and button inputs with a slow sampled shift register
 */
module debounce_switch  #(
    parameter WIDTH=1, // width of the input and output signals
    parameter N=3, // length of shift register
    parameter RATE=125000 // clock division factor
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

reg [23:0] cnt_reg = 24'd0;

reg [N-1:0] debounce_reg[WIDTH-1:0];

reg [WIDTH-1:0] state;

/*
 * The synchronized output is the state register
 */
assign out = state;

integer k;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt_reg <= 0;
        state <= 0;
        
        for (k = 0; k < WIDTH; k = k + 1) begin
            debounce_reg[k] <= 0;
        end
    end else begin
        if (cnt_reg < RATE) begin
            cnt_reg <= cnt_reg + 24'd1;
        end else begin
            cnt_reg <= 24'd0;
        end
        
        if (cnt_reg == 24'd0) begin
            for (k = 0; k < WIDTH; k = k + 1) begin
                debounce_reg[k] <= {debounce_reg[k][N-2:0], in[k]};
            end
        end
        
        for (k = 0; k < WIDTH; k = k + 1) begin
            if (|debounce_reg[k] == 0) begin
                state[k] <= 0;
            end else if (&debounce_reg[k] == 1) begin
                state[k] <= 1;
            end else begin
                state[k] <= state[k];
            end
        end
    end
end

endmodule

`resetall
