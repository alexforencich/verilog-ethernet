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

`timescale 1ns / 1ps

/*
 * Testbench for axis_fifo_adapter
 */
module test_axis_fifo_adapter_64_8;

// Parameters
parameter DEPTH = 32;
parameter S_DATA_WIDTH = 64;
parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8);
parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8);
parameter M_DATA_WIDTH = 8;
parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8);
parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8);
parameter ID_ENABLE = 1;
parameter ID_WIDTH = 8;
parameter DEST_ENABLE = 1;
parameter DEST_WIDTH = 8;
parameter USER_ENABLE = 1;
parameter USER_WIDTH = 1;
parameter PIPELINE_OUTPUT = 2;
parameter FRAME_FIFO = 0;
parameter USER_BAD_FRAME_VALUE = 1'b1;
parameter USER_BAD_FRAME_MASK = 1'b1;
parameter DROP_BAD_FRAME = 0;
parameter DROP_WHEN_FULL = 0;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [S_DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [S_KEEP_WIDTH-1:0] s_axis_tkeep = 0;
reg s_axis_tvalid = 0;
reg s_axis_tlast = 0;
reg [ID_WIDTH-1:0] s_axis_tid = 0;
reg [DEST_WIDTH-1:0] s_axis_tdest = 0;
reg [USER_WIDTH-1:0] s_axis_tuser = 0;
reg m_axis_tready = 0;

// Outputs
wire s_axis_tready;
wire [M_DATA_WIDTH-1:0] m_axis_tdata;
wire [M_KEEP_WIDTH-1:0] m_axis_tkeep;
wire m_axis_tvalid;
wire m_axis_tlast;
wire [ID_WIDTH-1:0] m_axis_tid;
wire [DEST_WIDTH-1:0] m_axis_tdest;
wire [USER_WIDTH-1:0] m_axis_tuser;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_axis_tdata,
        s_axis_tkeep,
        s_axis_tvalid,
        s_axis_tlast,
        s_axis_tid,
        s_axis_tdest,
        s_axis_tuser,
        m_axis_tready
    );
    $to_myhdl(
        s_axis_tready,
        m_axis_tdata,
        m_axis_tkeep,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tid,
        m_axis_tdest,
        m_axis_tuser
    );

    // dump file
    $dumpfile("test_axis_fifo_adapter_64_8.lxt");
    $dumpvars(0, test_axis_fifo_adapter_64_8);
end

axis_fifo_adapter #(
    .DEPTH(DEPTH),
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
    .USER_WIDTH(USER_WIDTH),
    .PIPELINE_OUTPUT(PIPELINE_OUTPUT),
    .FRAME_FIFO(FRAME_FIFO),
    .USER_BAD_FRAME_VALUE(USER_BAD_FRAME_VALUE),
    .USER_BAD_FRAME_MASK(USER_BAD_FRAME_MASK),
    .DROP_BAD_FRAME(DROP_BAD_FRAME),
    .DROP_WHEN_FULL(DROP_WHEN_FULL)
)
UUT (
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

endmodule
