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
 * PTP tag insert module
 */
module ptp_tag_insert #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = DATA_WIDTH/8,
    parameter TAG_WIDTH = 16,
    parameter TAG_OFFSET = 1,
    parameter USER_WIDTH = TAG_WIDTH+TAG_OFFSET
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire [USER_WIDTH-1:0]  m_axis_tuser,

    /*
     * Tag input
     */
    input  wire [TAG_WIDTH-1:0]   s_axis_tag,
    input  wire                   s_axis_tag_valid,
    output wire                   s_axis_tag_ready
);

reg [TAG_WIDTH-1:0] tag_reg = {TAG_WIDTH{1'b0}};
reg tag_valid_reg = 1'b0;

reg [USER_WIDTH-1:0] user;

assign s_axis_tready = m_axis_tready && tag_valid_reg;

assign m_axis_tdata  = s_axis_tdata;
assign m_axis_tkeep  = s_axis_tkeep;
assign m_axis_tvalid = s_axis_tvalid && tag_valid_reg;
assign m_axis_tlast  = s_axis_tlast;
assign m_axis_tuser  = user;

assign s_axis_tag_ready = !tag_valid_reg;

always @* begin
    user = s_axis_tuser;
    user[TAG_OFFSET +: TAG_WIDTH] = tag_reg;
end

always @(posedge clk) begin
    if (tag_valid_reg) begin
        if (s_axis_tvalid && s_axis_tready && s_axis_tlast) begin
            tag_valid_reg <= 1'b0;
        end
    end else begin
        tag_reg <= s_axis_tag;
        tag_valid_reg <= s_axis_tag_valid;
    end

    if (rst) begin
        tag_valid_reg <= 1'b0;
    end
end

endmodule

`resetall
