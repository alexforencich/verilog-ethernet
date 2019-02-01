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
 * Testbench for eth_mac_phy_10g
 */
module test_eth_mac_phy_10g;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = (DATA_WIDTH/32);
parameter ENABLE_PADDING = 1;
parameter ENABLE_DIC = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter BIT_REVERSE = 0;
parameter SCRAMBLER_DISABLE = 0;
parameter SLIP_COUNT_WIDTH = 3;
parameter COUNT_125US = 125000/6.4;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;
reg [DATA_WIDTH-1:0] tx_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] tx_axis_tkeep = 0;
reg tx_axis_tvalid = 0;
reg tx_axis_tlast = 0;
reg tx_axis_tuser = 0;
reg [DATA_WIDTH-1:0] serdes_rx_data = 0;
reg [HDR_WIDTH-1:0] serdes_rx_hdr = 1;
reg [7:0] ifg_delay = 0;

// Outputs
wire tx_axis_tready;
wire [DATA_WIDTH-1:0] rx_axis_tdata;
wire [KEEP_WIDTH-1:0] rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire rx_axis_tuser;
wire [DATA_WIDTH-1:0] serdes_tx_data;
wire [HDR_WIDTH-1:0] serdes_tx_hdr;
wire serdes_rx_bitslip;
wire tx_start_packet_0;
wire tx_start_packet_4;
wire rx_start_packet_0;
wire rx_start_packet_4;
wire rx_error_bad_frame;
wire rx_error_bad_fcs;
wire rx_block_lock;
wire rx_high_ber;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        rx_clk,
        rx_rst,
        tx_clk,
        tx_rst,
        tx_axis_tdata,
        tx_axis_tkeep,
        tx_axis_tvalid,
        tx_axis_tlast,
        tx_axis_tuser,
        serdes_rx_data,
        serdes_rx_hdr,
        ifg_delay
    );
    $to_myhdl(
        tx_axis_tready,
        rx_axis_tdata,
        rx_axis_tkeep,
        rx_axis_tvalid,
        rx_axis_tlast,
        rx_axis_tuser,
        serdes_tx_data,
        serdes_tx_hdr,
        serdes_rx_bitslip,
        tx_start_packet_0,
        tx_start_packet_4,
        rx_start_packet_0,
        rx_start_packet_4,
        rx_error_bad_frame,
        rx_error_bad_fcs,
        rx_block_lock,
        rx_high_ber
    );

    // dump file
    $dumpfile("test_eth_mac_phy_10g.lxt");
    $dumpvars(0, test_eth_mac_phy_10g);
end

eth_mac_phy_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .SLIP_COUNT_WIDTH(SLIP_COUNT_WIDTH),
    .COUNT_125US(COUNT_125US)
)
UUT (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .tx_start_packet_0(tx_start_packet_0),
    .tx_start_packet_4(tx_start_packet_4),
    .rx_start_packet_0(rx_start_packet_0),
    .rx_start_packet_4(rx_start_packet_4),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber),
    .ifg_delay(ifg_delay)
);

endmodule
