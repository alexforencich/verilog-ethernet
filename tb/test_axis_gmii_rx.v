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

`timescale 1ns / 1ps

/*
 * Testbench for axis_gmii_rx
 */
module test_axis_gmii_rx;

// Parameters
parameter DATA_WIDTH = 8;
parameter PTP_TS_ENABLE = 0;
parameter PTP_TS_WIDTH = 96;
parameter USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] gmii_rxd = 0;
reg gmii_rx_dv = 0;
reg gmii_rx_er = 0;
reg [PTP_TS_WIDTH-1:0] ptp_ts = 0;
reg clk_enable = 1;
reg mii_select = 0;

// Outputs
wire [DATA_WIDTH-1:0] m_axis_tdata;
wire m_axis_tvalid;
wire m_axis_tlast;
wire [USER_WIDTH-1:0] m_axis_tuser;
wire start_packet;
wire error_bad_frame;
wire error_bad_fcs;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        gmii_rxd,
        gmii_rx_dv,
        gmii_rx_er,
        ptp_ts,
        clk_enable,
        mii_select
    );
    $to_myhdl(
        m_axis_tdata,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tuser,
        start_packet,
        error_bad_frame,
        error_bad_fcs
    );

    // dump file
    $dumpfile("test_axis_gmii_rx.lxt");
    $dumpvars(0, test_axis_gmii_rx);
end

axis_gmii_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .USER_WIDTH(USER_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    .ptp_ts(ptp_ts),
    .clk_enable(clk_enable),
    .mii_select(mii_select),
    .start_packet(start_packet),
    .error_bad_frame(error_bad_frame),
    .error_bad_fcs(error_bad_fcs)
);

endmodule
