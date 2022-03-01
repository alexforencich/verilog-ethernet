/*

Copyright (c) 2015-2018 Alex Forencich

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
 * AXI4-Stream frame length adjuster with FIFO
 */
module axis_frame_length_adjust_fifo #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Depth of data FIFO in words
    parameter FRAME_FIFO_DEPTH = 4096,
    // Depth of header FIFO
    parameter HEADER_FIFO_DEPTH = 8
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
    input  wire [ID_WIDTH-1:0]    s_axis_tid,
    input  wire [DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,

    /*
     * AXI output
     */
    output wire                   m_axis_hdr_valid,
    input  wire                   m_axis_hdr_ready,
    output wire                   m_axis_hdr_pad,
    output wire                   m_axis_hdr_truncate,
    output wire [15:0]            m_axis_hdr_length,
    output wire [15:0]            m_axis_hdr_original_length,
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire [ID_WIDTH-1:0]    m_axis_tid,
    output wire [DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [USER_WIDTH-1:0]  m_axis_tuser,

    /*
     * Configuration
     */
    input  wire [15:0]            length_min,
    input  wire [15:0]            length_max
);

wire [DATA_WIDTH-1:0] fifo_axis_tdata;
wire [KEEP_WIDTH-1:0] fifo_axis_tkeep;
wire fifo_axis_tvalid;
wire fifo_axis_tready;
wire fifo_axis_tlast;
wire [ID_WIDTH-1:0] fifo_axis_tid;
wire [DEST_WIDTH-1:0] fifo_axis_tdest;
wire [USER_WIDTH-1:0] fifo_axis_tuser;

wire status_valid;
wire status_ready;
wire status_frame_pad;
wire status_frame_truncate;
wire [15:0] status_frame_length;
wire [15:0] status_frame_original_length;

axis_frame_length_adjust #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
)
axis_frame_length_adjust_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tid(s_axis_tid),
    .s_axis_tdest(s_axis_tdest),
    .s_axis_tuser(s_axis_tuser),
    // AXI output
    .m_axis_tdata(fifo_axis_tdata),
    .m_axis_tkeep(fifo_axis_tkeep),
    .m_axis_tvalid(fifo_axis_tvalid),
    .m_axis_tready(fifo_axis_tready),
    .m_axis_tlast(fifo_axis_tlast),
    .m_axis_tid(fifo_axis_tid),
    .m_axis_tdest(fifo_axis_tdest),
    .m_axis_tuser(fifo_axis_tuser),
    // Status
    .status_valid(status_valid),
    .status_ready(status_ready),
    .status_frame_pad(status_frame_pad),
    .status_frame_truncate(status_frame_truncate),
    .status_frame_length(status_frame_length),
    .status_frame_original_length(status_frame_original_length),
    // Configuration
    .length_min(length_min),
    .length_max(length_max)
);

axis_fifo #(
    .DEPTH(FRAME_FIFO_DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .LAST_ENABLE(1),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .FRAME_FIFO(0)
)
frame_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(fifo_axis_tdata),
    .s_axis_tkeep(fifo_axis_tkeep),
    .s_axis_tvalid(fifo_axis_tvalid),
    .s_axis_tready(fifo_axis_tready),
    .s_axis_tlast(fifo_axis_tlast),
    .s_axis_tid(fifo_axis_tid),
    .s_axis_tdest(fifo_axis_tdest),
    .s_axis_tuser(fifo_axis_tuser),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(m_axis_tid),
    .m_axis_tdest(m_axis_tdest),
    .m_axis_tuser(m_axis_tuser),
    // Status
    .status_overflow(),
    .status_bad_frame(),
    .status_good_frame()
);

axis_fifo #(
    .DEPTH(HEADER_FIFO_DEPTH),
    .DATA_WIDTH(1+1+16+16),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0),
    .FRAME_FIFO(0)
)
header_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata({status_frame_pad, status_frame_truncate, status_frame_length, status_frame_original_length}),
    .s_axis_tkeep(0),
    .s_axis_tvalid(status_valid),
    .s_axis_tready(status_ready),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0),
    // AXI output
    .m_axis_tdata({m_axis_hdr_pad, m_axis_hdr_truncate, m_axis_hdr_length, m_axis_hdr_original_length}),
    .m_axis_tkeep(),
    .m_axis_tvalid(m_axis_hdr_valid),
    .m_axis_tready(m_axis_hdr_ready),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    // Status
    .status_overflow(),
    .status_bad_frame(),
    .status_good_frame()
);

endmodule

`resetall
