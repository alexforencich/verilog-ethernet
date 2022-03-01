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
 * XGMII control/data interleave
 */
module xgmii_interleave
(
    input  wire [63:0] input_xgmii_d,
    input  wire [7:0]  input_xgmii_c,

    output wire [72:0] output_xgmii_dc
);

assign output_xgmii_dc[7:0] = input_xgmii_d[7:0];
assign output_xgmii_dc[8] = input_xgmii_c[0];
assign output_xgmii_dc[16:9] = input_xgmii_d[15:8];
assign output_xgmii_dc[17] = input_xgmii_c[1];
assign output_xgmii_dc[25:18] = input_xgmii_d[23:16];
assign output_xgmii_dc[26] = input_xgmii_c[2];
assign output_xgmii_dc[34:27] = input_xgmii_d[31:24];
assign output_xgmii_dc[35] = input_xgmii_c[3];
assign output_xgmii_dc[43:36] = input_xgmii_d[39:32];
assign output_xgmii_dc[44] = input_xgmii_c[4];
assign output_xgmii_dc[52:45] = input_xgmii_d[47:40];
assign output_xgmii_dc[53] = input_xgmii_c[5];
assign output_xgmii_dc[61:54] = input_xgmii_d[55:48];
assign output_xgmii_dc[62] = input_xgmii_c[6];
assign output_xgmii_dc[70:63] = input_xgmii_d[63:56];
assign output_xgmii_dc[71] = input_xgmii_c[7];

endmodule

`resetall
