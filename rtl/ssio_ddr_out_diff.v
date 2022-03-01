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
 * Generic source synchronous DDR output
 */
module ssio_ddr_out_diff #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR2",
    // Use 90 degree clock for transmit ("TRUE", "FALSE")
    parameter USE_CLK90 = "TRUE",
    // Width of register in bits
    parameter WIDTH = 1
)
(
    input  wire             clk,
    input  wire             clk90,

    input  wire [WIDTH-1:0] input_d1,
    input  wire [WIDTH-1:0] input_d2,

    output wire             output_clk_p,
    output wire             output_clk_n,
    output wire [WIDTH-1:0] output_q_p,
    output wire [WIDTH-1:0] output_q_n
);

wire output_clk;
wire [WIDTH-1:0] output_q;

ssio_ddr_out #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .USE_CLK90(USE_CLK90),
    .WIDTH(WIDTH)
)
ssio_ddr_out_inst(
    .clk(clk),
    .clk90(clk90),
    .input_d1(input_d1),
    .input_d2(input_d2),
    .output_clk(output_clk),
    .output_q(output_q)
);

genvar n;

generate

if (TARGET == "XILINX") begin
    OBUFDS
    clk_obufds_inst (
        .I(output_clk),
        .O(output_clk_p),
        .OB(output_clk_n)
    );
    for (n = 0; n < WIDTH; n = n + 1) begin
        OBUFDS
        data_obufds_inst (
            .I(output_q[n]),
            .O(output_q_p[n]),
            .OB(output_q_n[n])
        );
    end
end else if (TARGET == "ALTERA") begin
    ALT_OUTBUF_DIFF
    clk_outbuf_diff_inst (
        .i(output_clk),
        .o(output_clk_p),
        .obar(output_clk_n)
    );
    for (n = 0; n < WIDTH; n = n + 1) begin
        ALT_OUTBUF_DIFF
        data_outbuf_diff_inst (
            .i(output_q[n]),
            .o(output_q_p[n]),
            .obar(output_q_n[n])
        );
    end
end else begin
    assign output_clk_p = output_clk;
    assign output_clk_n = ~output_clk;
    assign output_q_p = output_q;
    assign output_q_n = ~output_q;
end

endgenerate

endmodule

`resetall
