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
 * AXI4-Stream FIFO with width converter
 */
module axis_fifo_adapter #
(
    // FIFO depth in words
    // KEEP_WIDTH words per cycle if KEEP_ENABLE set
    // Rounded up to nearest power of 2 cycles
    parameter DEPTH = 4096,
    // Width of input AXI stream interface in bits
    parameter S_DATA_WIDTH = 8,
    // Propagate tkeep signal on input interface
    // If disabled, tkeep assumed to be 1'b1
    parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8),
    // tkeep signal width (words per cycle) on input interface
    parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8),
    // Width of output AXI stream interface in bits
    parameter M_DATA_WIDTH = 8,
    // Propagate tkeep signal on output interface
    // If disabled, tkeep assumed to be 1'b1
    parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8),
    // tkeep signal width (words per cycle) on output interface
    parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8),
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
    // number of output pipeline registers
    parameter PIPELINE_OUTPUT = 2,
    // Frame FIFO mode - operate on frames instead of cycles
    // When set, m_axis_tvalid will not be deasserted within a frame
    // Requires LAST_ENABLE set
    parameter FRAME_FIFO = 0,
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1,
    // Drop frames larger than FIFO
    // Requires FRAME_FIFO set
    parameter DROP_OVERSIZE_FRAME = FRAME_FIFO,
    // Drop frames marked bad
    // Requires FRAME_FIFO and DROP_OVERSIZE_FRAME set
    parameter DROP_BAD_FRAME = 0,
    // Drop incoming frames when full
    // When set, s_axis_tready is always asserted
    // Requires FRAME_FIFO and DROP_OVERSIZE_FRAME set
    parameter DROP_WHEN_FULL = 0
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI input
     */
    input  wire [S_DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [S_KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                     s_axis_tvalid,
    output wire                     s_axis_tready,
    input  wire                     s_axis_tlast,
    input  wire [ID_WIDTH-1:0]      s_axis_tid,
    input  wire [DEST_WIDTH-1:0]    s_axis_tdest,
    input  wire [USER_WIDTH-1:0]    s_axis_tuser,

    /*
     * AXI output
     */
    output wire [M_DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [M_KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast,
    output wire [ID_WIDTH-1:0]      m_axis_tid,
    output wire [DEST_WIDTH-1:0]    m_axis_tdest,
    output wire [USER_WIDTH-1:0]    m_axis_tuser,

    /*
     * Status
     */
    output wire                     status_overflow,
    output wire                     status_bad_frame,
    output wire                     status_good_frame
);

// force keep width to 1 when disabled
parameter S_KEEP_WIDTH_INT = S_KEEP_ENABLE ? S_KEEP_WIDTH : 1;
parameter M_KEEP_WIDTH_INT = M_KEEP_ENABLE ? M_KEEP_WIDTH : 1;

// bus word sizes (must be identical)
parameter S_DATA_WORD_SIZE = S_DATA_WIDTH / S_KEEP_WIDTH_INT;
parameter M_DATA_WORD_SIZE = M_DATA_WIDTH / M_KEEP_WIDTH_INT;
// output bus is wider
parameter EXPAND_BUS = M_KEEP_WIDTH_INT > S_KEEP_WIDTH_INT;
// total data and keep widths
parameter DATA_WIDTH = EXPAND_BUS ? M_DATA_WIDTH : S_DATA_WIDTH;
parameter KEEP_WIDTH = EXPAND_BUS ? M_KEEP_WIDTH_INT : S_KEEP_WIDTH_INT;

// bus width assertions
initial begin
    if (S_DATA_WORD_SIZE * S_KEEP_WIDTH_INT != S_DATA_WIDTH) begin
        $error("Error: input data width not evenly divisble (instance %m)");
        $finish;
    end

    if (M_DATA_WORD_SIZE * M_KEEP_WIDTH_INT != M_DATA_WIDTH) begin
        $error("Error: output data width not evenly divisble (instance %m)");
        $finish;
    end

    if (S_DATA_WORD_SIZE != M_DATA_WORD_SIZE) begin
        $error("Error: word size mismatch (instance %m)");
        $finish;
    end
end

wire [DATA_WIDTH-1:0]  pre_fifo_axis_tdata;
wire [KEEP_WIDTH-1:0]  pre_fifo_axis_tkeep;
wire                   pre_fifo_axis_tvalid;
wire                   pre_fifo_axis_tready;
wire                   pre_fifo_axis_tlast;
wire [ID_WIDTH-1:0]    pre_fifo_axis_tid;
wire [DEST_WIDTH-1:0]  pre_fifo_axis_tdest;
wire [USER_WIDTH-1:0]  pre_fifo_axis_tuser;

wire [DATA_WIDTH-1:0]  post_fifo_axis_tdata;
wire [KEEP_WIDTH-1:0]  post_fifo_axis_tkeep;
wire                   post_fifo_axis_tvalid;
wire                   post_fifo_axis_tready;
wire                   post_fifo_axis_tlast;
wire [ID_WIDTH-1:0]    post_fifo_axis_tid;
wire [DEST_WIDTH-1:0]  post_fifo_axis_tdest;
wire [USER_WIDTH-1:0]  post_fifo_axis_tuser;

generate

if (M_KEEP_WIDTH_INT == S_KEEP_WIDTH_INT) begin

    // same width, no adapter needed

    assign pre_fifo_axis_tdata = s_axis_tdata;
    assign pre_fifo_axis_tkeep = s_axis_tkeep;
    assign pre_fifo_axis_tvalid = s_axis_tvalid;
    assign s_axis_tready = pre_fifo_axis_tready;
    assign pre_fifo_axis_tlast = s_axis_tlast;
    assign pre_fifo_axis_tid = s_axis_tid;
    assign pre_fifo_axis_tdest = s_axis_tdest;
    assign pre_fifo_axis_tuser = s_axis_tuser;

    assign m_axis_tdata = post_fifo_axis_tdata;
    assign m_axis_tkeep = post_fifo_axis_tkeep;
    assign m_axis_tvalid = post_fifo_axis_tvalid;
    assign post_fifo_axis_tready = m_axis_tready;
    assign m_axis_tlast = post_fifo_axis_tlast;
    assign m_axis_tid = post_fifo_axis_tid;
    assign m_axis_tdest = post_fifo_axis_tdest;
    assign m_axis_tuser = post_fifo_axis_tuser;

end else if (EXPAND_BUS) begin

    // output wider, adapt width before FIFO

    axis_adapter #(
        .S_DATA_WIDTH(S_DATA_WIDTH),
        .S_KEEP_ENABLE(S_KEEP_ENABLE),
        .S_KEEP_WIDTH(S_KEEP_WIDTH),
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .M_KEEP_ENABLE(M_KEEP_ENABLE),
        .M_KEEP_WIDTH(M_KEEP_WIDTH),
        .ID_ENABLE(ID_ENABLE),
        .ID_WIDTH(ID_WIDTH),
        .DEST_ENABLE(DEST_ENABLE),
        .DEST_WIDTH(DEST_WIDTH),
        .USER_ENABLE(USER_ENABLE),
        .USER_WIDTH(USER_WIDTH)
    )
    adapter_inst (
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
        .m_axis_tdata(pre_fifo_axis_tdata),
        .m_axis_tkeep(pre_fifo_axis_tkeep),
        .m_axis_tvalid(pre_fifo_axis_tvalid),
        .m_axis_tready(pre_fifo_axis_tready),
        .m_axis_tlast(pre_fifo_axis_tlast),
        .m_axis_tid(pre_fifo_axis_tid),
        .m_axis_tdest(pre_fifo_axis_tdest),
        .m_axis_tuser(pre_fifo_axis_tuser)
    );

    assign m_axis_tdata = post_fifo_axis_tdata;
    assign m_axis_tkeep = post_fifo_axis_tkeep;
    assign m_axis_tvalid = post_fifo_axis_tvalid;
    assign post_fifo_axis_tready = m_axis_tready;
    assign m_axis_tlast = post_fifo_axis_tlast;
    assign m_axis_tid = post_fifo_axis_tid;
    assign m_axis_tdest = post_fifo_axis_tdest;
    assign m_axis_tuser = post_fifo_axis_tuser;
    
end else begin

    // input wider, adapt width after FIFO
    
    assign pre_fifo_axis_tdata = s_axis_tdata;
    assign pre_fifo_axis_tkeep = s_axis_tkeep;
    assign pre_fifo_axis_tvalid = s_axis_tvalid;
    assign s_axis_tready = pre_fifo_axis_tready;
    assign pre_fifo_axis_tlast = s_axis_tlast;
    assign pre_fifo_axis_tid = s_axis_tid;
    assign pre_fifo_axis_tdest = s_axis_tdest;
    assign pre_fifo_axis_tuser = s_axis_tuser;

    axis_adapter #(
        .S_DATA_WIDTH(S_DATA_WIDTH),
        .S_KEEP_ENABLE(S_KEEP_ENABLE),
        .S_KEEP_WIDTH(S_KEEP_WIDTH),
        .M_DATA_WIDTH(M_DATA_WIDTH),
        .M_KEEP_ENABLE(M_KEEP_ENABLE),
        .M_KEEP_WIDTH(M_KEEP_WIDTH),
        .ID_ENABLE(ID_ENABLE),
        .ID_WIDTH(ID_WIDTH),
        .DEST_ENABLE(DEST_ENABLE),
        .DEST_WIDTH(DEST_WIDTH),
        .USER_ENABLE(USER_ENABLE),
        .USER_WIDTH(USER_WIDTH)
    )
    adapter_inst (
        .clk(clk),
        .rst(rst),
        // AXI input
        .s_axis_tdata(post_fifo_axis_tdata),
        .s_axis_tkeep(post_fifo_axis_tkeep),
        .s_axis_tvalid(post_fifo_axis_tvalid),
        .s_axis_tready(post_fifo_axis_tready),
        .s_axis_tlast(post_fifo_axis_tlast),
        .s_axis_tid(post_fifo_axis_tid),
        .s_axis_tdest(post_fifo_axis_tdest),
        .s_axis_tuser(post_fifo_axis_tuser),
        // AXI output
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(m_axis_tkeep),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tid(m_axis_tid),
        .m_axis_tdest(m_axis_tdest),
        .m_axis_tuser(m_axis_tuser)
    );

end

endgenerate

axis_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(EXPAND_BUS ? M_KEEP_ENABLE : S_KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .LAST_ENABLE(1),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .PIPELINE_OUTPUT(PIPELINE_OUTPUT),
    .FRAME_FIFO(FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(USER_BAD_FRAME_VALUE),
    .USER_BAD_FRAME_MASK(USER_BAD_FRAME_MASK),
    .DROP_OVERSIZE_FRAME(DROP_OVERSIZE_FRAME),
    .DROP_BAD_FRAME(DROP_BAD_FRAME),
    .DROP_WHEN_FULL(DROP_WHEN_FULL)
)
fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(pre_fifo_axis_tdata),
    .s_axis_tkeep(pre_fifo_axis_tkeep),
    .s_axis_tvalid(pre_fifo_axis_tvalid),
    .s_axis_tready(pre_fifo_axis_tready),
    .s_axis_tlast(pre_fifo_axis_tlast),
    .s_axis_tid(pre_fifo_axis_tid),
    .s_axis_tdest(pre_fifo_axis_tdest),
    .s_axis_tuser(pre_fifo_axis_tuser),
    // AXI output
    .m_axis_tdata(post_fifo_axis_tdata),
    .m_axis_tkeep(post_fifo_axis_tkeep),
    .m_axis_tvalid(post_fifo_axis_tvalid),
    .m_axis_tready(post_fifo_axis_tready),
    .m_axis_tlast(post_fifo_axis_tlast),
    .m_axis_tid(post_fifo_axis_tid),
    .m_axis_tdest(post_fifo_axis_tdest),
    .m_axis_tuser(post_fifo_axis_tuser),
    // Status
    .status_overflow(status_overflow),
    .status_bad_frame(status_bad_frame),
    .status_good_frame(status_good_frame)
);

endmodule

`resetall
