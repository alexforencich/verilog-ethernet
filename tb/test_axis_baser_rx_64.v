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
 * Testbench for axis_baser_rx_64
 */
module test_axis_baser_rx_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = 2;
parameter PTP_PERIOD_NS = 4'h6;
parameter PTP_PERIOD_FNS = 16'h6666;
parameter PTP_TS_ENABLE = 0;
parameter PTP_TS_WIDTH = 96;
parameter USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] encoded_rx_data = 0;
reg [HDR_WIDTH-1:0] encoded_rx_hdr = 1;
reg [PTP_TS_WIDTH-1:0] ptp_ts = 0;

// Outputs
wire [DATA_WIDTH-1:0] m_axis_tdata;
wire [KEEP_WIDTH-1:0] m_axis_tkeep;
wire m_axis_tvalid;
wire m_axis_tlast;
wire [USER_WIDTH-1:0] m_axis_tuser;
wire [1:0] start_packet;
wire error_bad_frame;
wire error_bad_fcs;
wire rx_bad_block;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        encoded_rx_data,
        encoded_rx_hdr,
        ptp_ts
    );
    $to_myhdl(
        m_axis_tdata,
        m_axis_tkeep,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tuser,
        start_packet,
        error_bad_frame,
        error_bad_fcs,
        rx_bad_block
    );

    // dump file
    $dumpfile("test_axis_baser_rx_64.lxt");
    $dumpvars(0, test_axis_baser_rx_64);
end

axis_baser_rx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .USER_WIDTH(USER_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .encoded_rx_data(encoded_rx_data),
    .encoded_rx_hdr(encoded_rx_hdr),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    .ptp_ts(ptp_ts),
    .start_packet(start_packet),
    .error_bad_frame(error_bad_frame),
    .error_bad_fcs(error_bad_fcs),
    .rx_bad_block(rx_bad_block)
);

endmodule
