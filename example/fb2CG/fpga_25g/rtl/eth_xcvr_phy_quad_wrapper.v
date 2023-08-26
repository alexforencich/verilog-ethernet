/*

Copyright (c) 2023 Alex Forencich

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
 * Transceiver and PHY quad wrapper
 */
module eth_xcvr_phy_quad_wrapper #
(
    parameter COUNT = 4,
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2,
    parameter PRBS31_ENABLE = 0,
    parameter TX_SERDES_PIPELINE = 0,
    parameter RX_SERDES_PIPELINE = 0,
    parameter BITSLIP_HIGH_CYCLES = 1,
    parameter BITSLIP_LOW_CYCLES = 8,
    parameter COUNT_125US = 125000/6.4
)
(
    input  wire                   xcvr_ctrl_clk,
    input  wire                   xcvr_ctrl_rst,

    /*
     * Common
     */
    output wire                   xcvr_gtpowergood_out,

    /*
     * PLL
     */
    input  wire                   xcvr_gtrefclk00_in,

    /*
     * Serial data
     */
    output wire [COUNT-1:0]       xcvr_txp,
    output wire [COUNT-1:0]       xcvr_txn,
    input  wire [COUNT-1:0]       xcvr_rxp,
    input  wire [COUNT-1:0]       xcvr_rxn,

    /*
     * PHY connections
     */
    output wire                   phy_1_tx_clk,
    output wire                   phy_1_tx_rst,
    input  wire [DATA_WIDTH-1:0]  phy_1_xgmii_txd,
    input  wire [CTRL_WIDTH-1:0]  phy_1_xgmii_txc,
    output wire                   phy_1_rx_clk,
    output wire                   phy_1_rx_rst,
    output wire [DATA_WIDTH-1:0]  phy_1_xgmii_rxd,
    output wire [CTRL_WIDTH-1:0]  phy_1_xgmii_rxc,
    output wire                   phy_1_tx_bad_block,
    output wire [6:0]             phy_1_rx_error_count,
    output wire                   phy_1_rx_bad_block,
    output wire                   phy_1_rx_sequence_error,
    output wire                   phy_1_rx_block_lock,
    output wire                   phy_1_rx_high_ber,
    output wire                   phy_1_rx_status,
    input  wire                   phy_1_cfg_tx_prbs31_enable,
    input  wire                   phy_1_cfg_rx_prbs31_enable,

    output wire                   phy_2_tx_clk,
    output wire                   phy_2_tx_rst,
    input  wire [DATA_WIDTH-1:0]  phy_2_xgmii_txd,
    input  wire [CTRL_WIDTH-1:0]  phy_2_xgmii_txc,
    output wire                   phy_2_rx_clk,
    output wire                   phy_2_rx_rst,
    output wire [DATA_WIDTH-1:0]  phy_2_xgmii_rxd,
    output wire [CTRL_WIDTH-1:0]  phy_2_xgmii_rxc,
    output wire                   phy_2_tx_bad_block,
    output wire [6:0]             phy_2_rx_error_count,
    output wire                   phy_2_rx_bad_block,
    output wire                   phy_2_rx_sequence_error,
    output wire                   phy_2_rx_block_lock,
    output wire                   phy_2_rx_high_ber,
    output wire                   phy_2_rx_status,
    input  wire                   phy_2_cfg_tx_prbs31_enable,
    input  wire                   phy_2_cfg_rx_prbs31_enable,

    output wire                   phy_3_tx_clk,
    output wire                   phy_3_tx_rst,
    input  wire [DATA_WIDTH-1:0]  phy_3_xgmii_txd,
    input  wire [CTRL_WIDTH-1:0]  phy_3_xgmii_txc,
    output wire                   phy_3_rx_clk,
    output wire                   phy_3_rx_rst,
    output wire [DATA_WIDTH-1:0]  phy_3_xgmii_rxd,
    output wire [CTRL_WIDTH-1:0]  phy_3_xgmii_rxc,
    output wire                   phy_3_tx_bad_block,
    output wire [6:0]             phy_3_rx_error_count,
    output wire                   phy_3_rx_bad_block,
    output wire                   phy_3_rx_sequence_error,
    output wire                   phy_3_rx_block_lock,
    output wire                   phy_3_rx_high_ber,
    output wire                   phy_3_rx_status,
    input  wire                   phy_3_cfg_tx_prbs31_enable,
    input  wire                   phy_3_cfg_rx_prbs31_enable,

    output wire                   phy_4_tx_clk,
    output wire                   phy_4_tx_rst,
    input  wire [DATA_WIDTH-1:0]  phy_4_xgmii_txd,
    input  wire [CTRL_WIDTH-1:0]  phy_4_xgmii_txc,
    output wire                   phy_4_rx_clk,
    output wire                   phy_4_rx_rst,
    output wire [DATA_WIDTH-1:0]  phy_4_xgmii_rxd,
    output wire [CTRL_WIDTH-1:0]  phy_4_xgmii_rxc,
    output wire                   phy_4_tx_bad_block,
    output wire [6:0]             phy_4_rx_error_count,
    output wire                   phy_4_rx_bad_block,
    output wire                   phy_4_rx_sequence_error,
    output wire                   phy_4_rx_block_lock,
    output wire                   phy_4_rx_high_ber,
    output wire                   phy_4_rx_status,
    input  wire                   phy_4_cfg_tx_prbs31_enable,
    input  wire                   phy_4_cfg_rx_prbs31_enable
);

generate

wire xcvr_qpll0lock;
wire xcvr_qpll0clk;
wire xcvr_qpll0refclk;

if (COUNT > 0) begin : phy1

    eth_xcvr_phy_wrapper #(
        .HAS_COMMON(1),
        .DATA_WIDTH(DATA_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH),
        .HDR_WIDTH(HDR_WIDTH),
        .PRBS31_ENABLE(PRBS31_ENABLE),
        .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
        .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
        .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
        .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
        .COUNT_125US(COUNT_125US)
    )
    eth_xcvr_phy_1 (
        .xcvr_ctrl_clk(xcvr_ctrl_clk),
        .xcvr_ctrl_rst(xcvr_ctrl_rst),

        // Common
        .xcvr_gtpowergood_out(xcvr_gtpowergood_out),

        // PLL out
        .xcvr_gtrefclk00_in(xcvr_gtrefclk00_in),
        .xcvr_qpll0lock_out(xcvr_qpll0lock),
        .xcvr_qpll0clk_out(xcvr_qpll0clk),
        .xcvr_qpll0refclk_out(xcvr_qpll0refclk),

        // PLL in
        .xcvr_qpll0lock_in(1'b0),
        .xcvr_qpll0clk_in(1'b0),
        .xcvr_qpll0refclk_in(1'b0),

        // Serial data
        .xcvr_txp(xcvr_txp[0]),
        .xcvr_txn(xcvr_txn[0]),
        .xcvr_rxp(xcvr_rxp[0]),
        .xcvr_rxn(xcvr_rxn[0]),

        // PHY connections
        .phy_tx_clk(phy_1_tx_clk),
        .phy_tx_rst(phy_1_tx_rst),
        .phy_xgmii_txd(phy_1_xgmii_txd),
        .phy_xgmii_txc(phy_1_xgmii_txc),
        .phy_rx_clk(phy_1_rx_clk),
        .phy_rx_rst(phy_1_rx_rst),
        .phy_xgmii_rxd(phy_1_xgmii_rxd),
        .phy_xgmii_rxc(phy_1_xgmii_rxc),
        .phy_tx_bad_block(phy_1_tx_bad_block),
        .phy_rx_error_count(phy_1_rx_error_count),
        .phy_rx_bad_block(phy_1_rx_bad_block),
        .phy_rx_sequence_error(phy_1_rx_sequence_error),
        .phy_rx_block_lock(phy_1_rx_block_lock),
        .phy_rx_high_ber(phy_1_rx_high_ber),
        .phy_rx_status(phy_1_rx_status),
        .phy_cfg_tx_prbs31_enable(phy_1_cfg_tx_prbs31_enable),
        .phy_cfg_rx_prbs31_enable(phy_1_cfg_rx_prbs31_enable)
    );

end

if (COUNT > 1) begin : phy2

    eth_xcvr_phy_wrapper #(
        .HAS_COMMON(0),
        .DATA_WIDTH(DATA_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH),
        .HDR_WIDTH(HDR_WIDTH),
        .PRBS31_ENABLE(PRBS31_ENABLE),
        .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
        .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
        .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
        .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
        .COUNT_125US(COUNT_125US)
    )
    eth_xcvr_phy_2 (
        .xcvr_ctrl_clk(xcvr_ctrl_clk),
        .xcvr_ctrl_rst(xcvr_ctrl_rst),

        // Common
        .xcvr_gtpowergood_out(),

        // PLL out
        .xcvr_gtrefclk00_in(1'b0),
        .xcvr_qpll0lock_out(),
        .xcvr_qpll0clk_out(),
        .xcvr_qpll0refclk_out(),

        // PLL in
        .xcvr_qpll0lock_in(xcvr_qpll0lock),
        .xcvr_qpll0clk_in(xcvr_qpll0clk),
        .xcvr_qpll0refclk_in(xcvr_qpll0refclk),

        // Serial data
        .xcvr_txp(xcvr_txp[1]),
        .xcvr_txn(xcvr_txn[1]),
        .xcvr_rxp(xcvr_rxp[1]),
        .xcvr_rxn(xcvr_rxn[1]),

        // PHY connections
        .phy_tx_clk(phy_2_tx_clk),
        .phy_tx_rst(phy_2_tx_rst),
        .phy_xgmii_txd(phy_2_xgmii_txd),
        .phy_xgmii_txc(phy_2_xgmii_txc),
        .phy_rx_clk(phy_2_rx_clk),
        .phy_rx_rst(phy_2_rx_rst),
        .phy_xgmii_rxd(phy_2_xgmii_rxd),
        .phy_xgmii_rxc(phy_2_xgmii_rxc),
        .phy_tx_bad_block(phy_2_tx_bad_block),
        .phy_rx_error_count(phy_2_rx_error_count),
        .phy_rx_bad_block(phy_2_rx_bad_block),
        .phy_rx_sequence_error(phy_2_rx_sequence_error),
        .phy_rx_block_lock(phy_2_rx_block_lock),
        .phy_rx_high_ber(phy_2_rx_high_ber),
        .phy_rx_status(phy_2_rx_status),
        .phy_cfg_tx_prbs31_enable(phy_2_cfg_tx_prbs31_enable),
        .phy_cfg_rx_prbs31_enable(phy_2_cfg_rx_prbs31_enable)
    );

end

if (COUNT > 2) begin : phy3

    eth_xcvr_phy_wrapper #(
        .HAS_COMMON(0),
        .DATA_WIDTH(DATA_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH),
        .HDR_WIDTH(HDR_WIDTH),
        .PRBS31_ENABLE(PRBS31_ENABLE),
        .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
        .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
        .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
        .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
        .COUNT_125US(COUNT_125US)
    )
    eth_xcvr_phy_3 (
        .xcvr_ctrl_clk(xcvr_ctrl_clk),
        .xcvr_ctrl_rst(xcvr_ctrl_rst),

        // Common
        .xcvr_gtpowergood_out(),

        // PLL out
        .xcvr_gtrefclk00_in(1'b0),
        .xcvr_qpll0lock_out(),
        .xcvr_qpll0clk_out(),
        .xcvr_qpll0refclk_out(),

        // PLL in
        .xcvr_qpll0lock_in(xcvr_qpll0lock),
        .xcvr_qpll0clk_in(xcvr_qpll0clk),
        .xcvr_qpll0refclk_in(xcvr_qpll0refclk),

        // Serial data
        .xcvr_txp(xcvr_txp[2]),
        .xcvr_txn(xcvr_txn[2]),
        .xcvr_rxp(xcvr_rxp[2]),
        .xcvr_rxn(xcvr_rxn[2]),

        // PHY connections
        .phy_tx_clk(phy_3_tx_clk),
        .phy_tx_rst(phy_3_tx_rst),
        .phy_xgmii_txd(phy_3_xgmii_txd),
        .phy_xgmii_txc(phy_3_xgmii_txc),
        .phy_rx_clk(phy_3_rx_clk),
        .phy_rx_rst(phy_3_rx_rst),
        .phy_xgmii_rxd(phy_3_xgmii_rxd),
        .phy_xgmii_rxc(phy_3_xgmii_rxc),
        .phy_tx_bad_block(phy_3_tx_bad_block),
        .phy_rx_error_count(phy_3_rx_error_count),
        .phy_rx_bad_block(phy_3_rx_bad_block),
        .phy_rx_sequence_error(phy_3_rx_sequence_error),
        .phy_rx_block_lock(phy_3_rx_block_lock),
        .phy_rx_high_ber(phy_3_rx_high_ber),
        .phy_rx_status(phy_3_rx_status),
        .phy_cfg_tx_prbs31_enable(phy_3_cfg_tx_prbs31_enable),
        .phy_cfg_rx_prbs31_enable(phy_3_cfg_rx_prbs31_enable)
    );

end

if (COUNT > 3) begin : phy4

    eth_xcvr_phy_wrapper #(
        .HAS_COMMON(0),
        .DATA_WIDTH(DATA_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH),
        .HDR_WIDTH(HDR_WIDTH),
        .PRBS31_ENABLE(PRBS31_ENABLE),
        .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
        .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
        .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
        .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
        .COUNT_125US(COUNT_125US)
    )
    eth_xcvr_phy_4 (
        .xcvr_ctrl_clk(xcvr_ctrl_clk),
        .xcvr_ctrl_rst(xcvr_ctrl_rst),

        // Common
        .xcvr_gtpowergood_out(),

        // PLL out
        .xcvr_gtrefclk00_in(1'b0),
        .xcvr_qpll0lock_out(),
        .xcvr_qpll0clk_out(),
        .xcvr_qpll0refclk_out(),

        // PLL in
        .xcvr_qpll0lock_in(xcvr_qpll0lock),
        .xcvr_qpll0clk_in(xcvr_qpll0clk),
        .xcvr_qpll0refclk_in(xcvr_qpll0refclk),

        // Serial data
        .xcvr_txp(xcvr_txp[3]),
        .xcvr_txn(xcvr_txn[3]),
        .xcvr_rxp(xcvr_rxp[3]),
        .xcvr_rxn(xcvr_rxn[3]),

        // PHY connections
        .phy_tx_clk(phy_4_tx_clk),
        .phy_tx_rst(phy_4_tx_rst),
        .phy_xgmii_txd(phy_4_xgmii_txd),
        .phy_xgmii_txc(phy_4_xgmii_txc),
        .phy_rx_clk(phy_4_rx_clk),
        .phy_rx_rst(phy_4_rx_rst),
        .phy_xgmii_rxd(phy_4_xgmii_rxd),
        .phy_xgmii_rxc(phy_4_xgmii_rxc),
        .phy_tx_bad_block(phy_4_tx_bad_block),
        .phy_rx_error_count(phy_4_rx_error_count),
        .phy_rx_bad_block(phy_4_rx_bad_block),
        .phy_rx_sequence_error(phy_4_rx_sequence_error),
        .phy_rx_block_lock(phy_4_rx_block_lock),
        .phy_rx_high_ber(phy_4_rx_high_ber),
        .phy_rx_status(phy_4_rx_status),
        .phy_cfg_tx_prbs31_enable(phy_4_cfg_tx_prbs31_enable),
        .phy_cfg_rx_prbs31_enable(phy_4_cfg_rx_prbs31_enable)
    );

end

endgenerate

endmodule

`resetall
