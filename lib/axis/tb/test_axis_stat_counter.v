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
 * Testbench for axis_stat_counter
 */
module test_axis_stat_counter;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter TAG_ENABLE = 1;
parameter TAG_WIDTH = 16;
parameter TICK_COUNT_ENABLE = 1;
parameter TICK_COUNT_WIDTH = 32;
parameter BYTE_COUNT_ENABLE = 1;
parameter BYTE_COUNT_WIDTH = 32;
parameter FRAME_COUNT_ENABLE = 1;
parameter FRAME_COUNT_WIDTH = 32;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] monitor_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] monitor_axis_tkeep = 0;
reg monitor_axis_tvalid = 0;
reg monitor_axis_tready = 0;
reg monitor_axis_tlast = 0;
reg monitor_axis_tuser = 0;
reg m_axis_tready = 0;
reg [TAG_WIDTH-1:0] tag = 0;
reg trigger = 0;

// Outputs
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
        monitor_axis_tdata,
        monitor_axis_tkeep,
        monitor_axis_tvalid,
        monitor_axis_tready,
        monitor_axis_tlast,
        monitor_axis_tuser,
        m_axis_tready,
        tag,
        trigger
    );
    $to_myhdl(
        m_axis_tdata,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tuser,
        busy
    );

    // dump file
    $dumpfile("test_axis_stat_counter.lxt");
    $dumpvars(0, test_axis_stat_counter);
end

axis_stat_counter #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .TAG_ENABLE(TAG_ENABLE),
    .TAG_WIDTH(TAG_WIDTH),
    .TICK_COUNT_ENABLE(TICK_COUNT_ENABLE),
    .TICK_COUNT_WIDTH(TICK_COUNT_WIDTH),
    .BYTE_COUNT_ENABLE(BYTE_COUNT_ENABLE),
    .BYTE_COUNT_WIDTH(BYTE_COUNT_WIDTH),
    .FRAME_COUNT_ENABLE(FRAME_COUNT_ENABLE),
    .FRAME_COUNT_WIDTH(FRAME_COUNT_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // axi monitor input
    .monitor_axis_tkeep(monitor_axis_tkeep),
    .monitor_axis_tvalid(monitor_axis_tvalid),
    .monitor_axis_tready(monitor_axis_tready),
    .monitor_axis_tlast(monitor_axis_tlast),
    // axi output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    // configuration
    .tag(tag),
    .trigger(trigger),
    // status
    .busy(busy)
);

endmodule
