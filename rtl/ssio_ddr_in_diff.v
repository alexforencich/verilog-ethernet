/*

Copyright (c) 2016-2018 Alex Forencich

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
 * Generic source synchronous DDR input
 */
module ssio_ddr_in_diff #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR2",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-6, 7-series
    // Use BUFG for Virtex-5, Spartan-6, Ultrascale
    parameter CLOCK_INPUT_STYLE = "BUFG",
    // Width of register in bits
    parameter WIDTH = 1
)
(
    input  wire             input_clk_p,
    input  wire             input_clk_n,

    input  wire [WIDTH-1:0] input_d_p,
    input  wire [WIDTH-1:0] input_d_n,

    output wire             output_clk,

    output wire [WIDTH-1:0] output_q1,
    output wire [WIDTH-1:0] output_q2
);

wire input_clk;
wire [WIDTH-1:0] input_d;

genvar n;

generate

if (TARGET == "XILINX") begin
    IBUFDS
    clk_ibufds_inst (
        .I(input_clk_p),
        .IB(input_clk_n),
        .O(input_clk)
    );
    for (n = 0; n < WIDTH; n = n + 1) begin
        IBUFDS
        data_ibufds_inst (
            .I(input_d_p[n]),
            .IB(input_d_n[n]),
            .O(input_d[n])
        );
    end
end else if (TARGET == "ALTERA") begin
    ALT_INBUF_DIFF
    clk_inbuf_diff_inst (
        .i(input_clk_p),
        .ibar(input_clk_n),
        .o(input_clk)
    );
    for (n = 0; n < WIDTH; n = n + 1) begin
        ALT_INBUF_DIFF
        data_inbuf_diff_inst (
            .i(input_d_p[n]),
            .ibar(input_d_n[n]),
            .o(input_d[n])
        );
    end
end else begin
    assign input_clk = input_clk_p;
    assign input_d = input_d_p;
end

endgenerate

ssio_ddr_in #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .WIDTH(WIDTH)
)
ssio_ddr_in_inst(
    .input_clk(input_clk),
    .input_d(input_d),
    .output_clk(output_clk),
    .output_q1(output_q1),
    .output_q2(output_q2)
);

endmodule

`resetall
