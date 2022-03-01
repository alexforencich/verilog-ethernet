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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream to LocalLink bridge
 */
module axis_ll_bridge #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,

    /*
     * LocalLink output
     */
    output wire [DATA_WIDTH-1:0]  ll_data_out,
    output wire                   ll_sof_out_n,
    output wire                   ll_eof_out_n,
    output wire                   ll_src_rdy_out_n,
    input  wire                   ll_dst_rdy_in_n
);

reg last_tlast = 1'b1;

always @(posedge clk) begin
    if (rst) begin
        last_tlast = 1'b1;
    end else begin
        if (s_axis_tvalid && s_axis_tready) last_tlast = s_axis_tlast;
    end
end

// high for packet length 1 -> cannot set SOF and EOF in same cycle
// invalid packets are discarded
wire invalid = s_axis_tvalid && s_axis_tlast && last_tlast;

assign s_axis_tready = !ll_dst_rdy_in_n;

assign ll_data_out = s_axis_tdata;
assign ll_sof_out_n = !(last_tlast && s_axis_tvalid && !invalid);
assign ll_eof_out_n = !(s_axis_tlast && !invalid);
assign ll_src_rdy_out_n = !(s_axis_tvalid && !invalid);

endmodule

`resetall
