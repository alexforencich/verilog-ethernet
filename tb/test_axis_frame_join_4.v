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

`timescale 1ns / 1ps

/*
 * Testbench for axis_frame_join
 */
module test_axis_frame_join_4;

// Parameters
parameter S_COUNT = 4;
parameter DATA_WIDTH = 8;
parameter TAG_ENABLE = 1;
parameter TAG_WIDTH = 16;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [S_COUNT*DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [S_COUNT-1:0] s_axis_tvalid = 0;
reg [S_COUNT-1:0] s_axis_tlast = 0;
reg [S_COUNT-1:0] s_axis_tuser = 0;
reg m_axis_tready = 0;
reg [TAG_WIDTH-1:0] tag = 0;

// Outputs
wire [S_COUNT-1:0] s_axis_tready;
wire [7:0] m_axis_tdata;
wire m_axis_tvalid;
wire m_axis_tlast;
wire m_axis_tuser;
wire busy;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_axis_tdata,
        s_axis_tvalid,
        s_axis_tlast,
        s_axis_tuser,
        m_axis_tready,
        tag
    );
    $to_myhdl(
        s_axis_tready,
        m_axis_tdata,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tuser,
        busy
    );

    // dump file
    $dumpfile("test_axis_frame_join_4.lxt");
    $dumpvars(0, test_axis_frame_join_4);
end

axis_frame_join #(
    .S_COUNT(S_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .TAG_ENABLE(TAG_ENABLE),
    .TAG_WIDTH(TAG_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tuser(s_axis_tuser),
    // axi output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    // config
    .tag(tag),
    // status
    .busy(busy)
);

endmodule
