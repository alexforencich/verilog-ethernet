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
 * Testbench for axis_baser_tx_64
 */
module test_axis_baser_tx_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = 2;
parameter ENABLE_PADDING = 1;
parameter ENABLE_DIC = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter PTP_PERIOD_NS = 4'h6;
parameter PTP_PERIOD_FNS = 16'h6666;
parameter PTP_TS_ENABLE = 0;
parameter PTP_TS_WIDTH = 96;
parameter PTP_TAG_ENABLE = PTP_TS_ENABLE;
parameter PTP_TAG_WIDTH = 16;
parameter USER_WIDTH = (PTP_TAG_ENABLE ? PTP_TAG_WIDTH : 0) + 1;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] s_axis_tkeep = 0;
reg s_axis_tvalid = 0;
reg s_axis_tlast = 0;
reg [USER_WIDTH-1:0] s_axis_tuser = 0;
reg [PTP_TS_WIDTH-1:0] ptp_ts = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire s_axis_tready;
wire [DATA_WIDTH-1:0] encoded_tx_data;
wire [HDR_WIDTH-1:0] encoded_tx_hdr;
wire [PTP_TS_WIDTH-1:0] m_axis_ptp_ts;
wire [PTP_TAG_WIDTH-1:0] m_axis_ptp_ts_tag;
wire m_axis_ptp_ts_valid;
wire [1:0] start_packet;
wire error_underflow;

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
        s_axis_tuser,
        ptp_ts,
        ifg_delay
    );
    $to_myhdl(
        s_axis_tready,
        encoded_tx_data,
        encoded_tx_hdr,
        m_axis_ptp_ts,
        m_axis_ptp_ts_tag,
        m_axis_ptp_ts_valid,
        start_packet,
        error_underflow
    );

    // dump file
    $dumpfile("test_axis_baser_tx_64.lxt");
    $dumpvars(0, test_axis_baser_tx_64);
end

axis_baser_tx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_PERIOD_NS(PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(PTP_PERIOD_FNS),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .PTP_TAG_ENABLE(PTP_TAG_ENABLE),
    .PTP_TAG_WIDTH(PTP_TAG_WIDTH),
    .USER_WIDTH(USER_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tuser(s_axis_tuser),
    .encoded_tx_data(encoded_tx_data),
    .encoded_tx_hdr(encoded_tx_hdr),
    .ptp_ts(ptp_ts),
    .m_axis_ptp_ts(m_axis_ptp_ts),
    .m_axis_ptp_ts_tag(m_axis_ptp_ts_tag),
    .m_axis_ptp_ts_valid(m_axis_ptp_ts_valid),
    .ifg_delay(ifg_delay),
    .start_packet(start_packet),
    .error_underflow(error_underflow)
);

endmodule
