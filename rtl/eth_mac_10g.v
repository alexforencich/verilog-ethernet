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
 * 10G Ethernet MAC
 */
module eth_mac_10g #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64
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
     * XGMII interface
     */
    input  wire [DATA_WIDTH-1:0] xgmii_rxd,
    input  wire [CTRL_WIDTH-1:0] xgmii_rxc,
    output wire [DATA_WIDTH-1:0] xgmii_txd,
    output wire [CTRL_WIDTH-1:0] xgmii_txc,

    /*
     * Status
     */
    output wire                  rx_error_bad_frame,
    output wire                  rx_error_bad_fcs,

    /*
     * Configuration
     */
    input  wire [7:0]            ifg_delay
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 32 && DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 32 or 64");
        $finish;
    end

    if (KEEP_WIDTH * 8 != DATA_WIDTH || CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end
end

generate

if (DATA_WIDTH == 64) begin

axis_xgmii_rx_64
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

axis_xgmii_tx_64 #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ifg_delay(ifg_delay)
);

end else begin

axis_xgmii_rx_32
axis_xgmii_rx_inst (
    .clk(rx_clk),
    .rst(rx_rst),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tuser(rx_axis_tuser),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

axis_xgmii_tx_32 #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
axis_xgmii_tx_inst (
    .clk(tx_clk),
    .rst(tx_rst),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tuser(tx_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ifg_delay(ifg_delay)
);

end

endgenerate

endmodule
