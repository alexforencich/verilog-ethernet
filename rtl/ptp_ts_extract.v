/*

Copyright (c) 2019 Alex Forencich

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
 * PTP timestamp extract module
 */
module ptp_ts_extract #
(
    parameter TS_WIDTH = 96,
    parameter TS_OFFSET = 1,
    parameter USER_WIDTH = TS_WIDTH+TS_OFFSET
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI stream input
     */
    input  wire                   s_axis_tvalid,
    input  wire                   s_axis_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,

    /*
     * Timestamp output
     */
    output wire [TS_WIDTH-1:0]    m_axis_ts,
    output wire                   m_axis_ts_valid
);

reg frame_reg = 1'b0;

assign m_axis_ts = s_axis_tuser >> TS_OFFSET;
assign m_axis_ts_valid = s_axis_tvalid && !frame_reg;

always @(posedge clk) begin
    if (s_axis_tvalid) begin
        frame_reg <= !s_axis_tlast;
    end

    if (rst) begin
        frame_reg <= 1'b0;
    end
end

endmodule

`resetall
