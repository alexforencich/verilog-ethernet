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
 * 10G Ethernet MAC/PHY combination
 */
module eth_mac_phy_10g #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = (DATA_WIDTH/32),
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0,
    parameter SLIP_COUNT_WIDTH = 3,
    parameter COUNT_125US = 125000/6.4
)
(
    input  wire                  rx_clk,
    input  wire                  rx_rst,
    input  wire                  tx_clk,
    input  wire                  tx_rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0] tx_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] tx_axis_tkeep,
    input  wire                  tx_axis_tvalid,
    output wire                  tx_axis_tready,
    input  wire                  tx_axis_tlast,
    input  wire                  tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0] rx_axis_tdata,
    output wire [KEEP_WIDTH-1:0] rx_axis_tkeep,
    output wire                  rx_axis_tvalid,
    output wire                  rx_axis_tlast,
    output wire                  rx_axis_tuser,

    /*
     * SERDES interface
     */
    output wire [DATA_WIDTH-1:0] serdes_tx_data,
    output wire [HDR_WIDTH-1:0]  serdes_tx_hdr,
    input  wire [DATA_WIDTH-1:0] serdes_rx_data,
    input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
    output wire                  serdes_rx_bitslip,

    /*
     * Status
     */
    output wire                  tx_start_packet_0,
    output wire                  tx_start_packet_4,
    output wire                  rx_start_packet_0,
    output wire                  rx_start_packet_4,
    output wire                  rx_error_bad_frame,
    output wire                  rx_error_bad_fcs,
    output wire                  rx_block_lock,
    output wire                  rx_high_ber,

    /*
     * Configuration
     */
    input  wire [7:0]            ifg_delay
);

eth_mac_phy_10g_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .SLIP_COUNT_WIDTH(SLIP_COUNT_WIDTH),
    .COUNT_125US(COUNT_125US)
)
eth_mac_phy_10g_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .rx_start_packet_0(rx_start_packet_0),
    .rx_start_packet_4(rx_start_packet_4),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber)
);

eth_mac_phy_10g_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE)
)
eth_mac_phy_10g_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .ifg_delay(ifg_delay),
    .tx_start_packet_0(tx_start_packet_0),
    .tx_start_packet_4(tx_start_packet_4)
);

endmodule
