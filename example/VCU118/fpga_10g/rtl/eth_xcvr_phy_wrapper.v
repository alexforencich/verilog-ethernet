/*

Copyright (c) 2021 Alex Forencich

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
 * Transceiver and PHY wrapper
 */
module eth_xcvr_phy_wrapper #
(
    parameter HAS_COMMON = 1,
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
     * PLL out
     */
    input  wire                   xcvr_gtrefclk00_in,
    output wire                   xcvr_qpll0lock_out,
    output wire                   xcvr_qpll0outclk_out,
    output wire                   xcvr_qpll0outrefclk_out,

    /*
     * PLL in
     */
    input  wire                   xcvr_qpll0lock_in,
    output wire                   xcvr_qpll0reset_out,
    input  wire                   xcvr_qpll0clk_in,
    input  wire                   xcvr_qpll0refclk_in,

    /*
     * Serial data
     */
    output wire                   xcvr_txp,
    output wire                   xcvr_txn,
    input  wire                   xcvr_rxp,
    input  wire                   xcvr_rxn,

    /*
     * PHY connections
     */
    output wire                   phy_tx_clk,
    output wire                   phy_tx_rst,
    input  wire [DATA_WIDTH-1:0]  phy_xgmii_txd,
    input  wire [CTRL_WIDTH-1:0]  phy_xgmii_txc,
    output wire                   phy_rx_clk,
    output wire                   phy_rx_rst,
    output wire [DATA_WIDTH-1:0]  phy_xgmii_rxd,
    output wire [CTRL_WIDTH-1:0]  phy_xgmii_rxc,
    output wire                   phy_tx_bad_block,
    output wire [6:0]             phy_rx_error_count,
    output wire                   phy_rx_bad_block,
    output wire                   phy_rx_sequence_error,
    output wire                   phy_rx_block_lock,
    output wire                   phy_rx_high_ber,
    input  wire                   phy_tx_prbs31_enable,
    input  wire                   phy_rx_prbs31_enable
);

wire phy_rx_reset_req;

wire gt_reset_tx_datapath = 1'b0;
wire gt_reset_rx_datapath = phy_rx_reset_req;

wire gt_reset_tx_done;
wire gt_reset_rx_done;

wire [5:0] gt_txheader;
wire [63:0] gt_txdata;
wire gt_rxgearboxslip;
wire [5:0] gt_rxheader;
wire [1:0] gt_rxheadervalid;
wire [63:0] gt_rxdata;
wire [1:0] gt_rxdatavalid;

generate

if (HAS_COMMON) begin : xcvr

    eth_xcvr_gt_full
    eth_xcvr_gt_full_inst (
        // Common
        .gtwiz_reset_clk_freerun_in(xcvr_ctrl_clk),
        .gtwiz_reset_all_in(xcvr_ctrl_rst),
        .gtpowergood_out(xcvr_gtpowergood_out),

        // PLL
        .gtrefclk00_in(xcvr_gtrefclk00_in),
        .qpll0lock_out(xcvr_qpll0lock_out),
        .qpll0outclk_out(xcvr_qpll0outclk_out),
        .qpll0outrefclk_out(xcvr_qpll0outrefclk_out),

        // Serial data
        .gtytxp_out(xcvr_txp),
        .gtytxn_out(xcvr_txn),
        .gtyrxp_in(xcvr_rxp),
        .gtyrxn_in(xcvr_rxn),

        // Transmit
        .gtwiz_userclk_tx_reset_in(1'b0),
        .gtwiz_userclk_tx_srcclk_out(),
        .gtwiz_userclk_tx_usrclk_out(),
        .gtwiz_userclk_tx_usrclk2_out(phy_tx_clk),
        .gtwiz_userclk_tx_active_out(),
        .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
        .gtwiz_reset_tx_datapath_in(gt_reset_tx_datapath),
        .gtwiz_reset_tx_done_out(gt_reset_tx_done),
        .txpmaresetdone_out(),
        .txprgdivresetdone_out(),

        .gtwiz_userdata_tx_in(gt_txdata),
        .txheader_in(gt_txheader),
        .txsequence_in(7'b0),

        // Receive
        .gtwiz_userclk_rx_reset_in(1'b0),
        .gtwiz_userclk_rx_srcclk_out(),
        .gtwiz_userclk_rx_usrclk_out(),
        .gtwiz_userclk_rx_usrclk2_out(phy_rx_clk),
        .gtwiz_userclk_rx_active_out(),
        .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
        .gtwiz_reset_rx_datapath_in(gt_reset_rx_datapath),
        .gtwiz_reset_rx_cdr_stable_out(),
        .gtwiz_reset_rx_done_out(gt_reset_rx_done),
        .rxpmaresetdone_out(),
        .rxprgdivresetdone_out(),

        .rxgearboxslip_in(gt_rxgearboxslip),
        .gtwiz_userdata_rx_out(gt_rxdata),
        .rxdatavalid_out(gt_rxdatavalid),
        .rxheader_out(gt_rxheader),
        .rxheadervalid_out(gt_rxheadervalid),
        .rxstartofseq_out()
    );

end else begin : xcvr

    eth_xcvr_gt_channel
    eth_xcvr_gt_channel_inst (
        // Common
        .gtwiz_reset_clk_freerun_in(xcvr_ctrl_clk),
        .gtwiz_reset_all_in(xcvr_ctrl_rst),
        .gtpowergood_out(xcvr_gtpowergood_out),

        // PLL
        .gtwiz_reset_qpll0lock_in(xcvr_qpll0lock_in),
        .gtwiz_reset_qpll0reset_out(xcvr_qpll0reset_out),
        .qpll0clk_in(xcvr_qpll0clk_in),
        .qpll0refclk_in(xcvr_qpll0refclk_in),
        .qpll1clk_in(1'b0),
        .qpll1refclk_in(1'b0),

        // Serial data
        .gtytxp_out(xcvr_txp),
        .gtytxn_out(xcvr_txn),
        .gtyrxp_in(xcvr_rxp),
        .gtyrxn_in(xcvr_rxn),

        // Transmit
        .gtwiz_userclk_tx_reset_in(1'b0),
        .gtwiz_userclk_tx_srcclk_out(),
        .gtwiz_userclk_tx_usrclk_out(),
        .gtwiz_userclk_tx_usrclk2_out(phy_tx_clk),
        .gtwiz_userclk_tx_active_out(),
        .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
        .gtwiz_reset_tx_datapath_in(gt_reset_tx_datapath),
        .gtwiz_reset_tx_done_out(gt_reset_tx_done),
        .txpmaresetdone_out(),
        .txprgdivresetdone_out(),

        .gtwiz_userdata_tx_in(gt_txdata),
        .txheader_in(gt_txheader),
        .txsequence_in(7'b0),

        // Receive
        .gtwiz_userclk_rx_reset_in(1'b0),
        .gtwiz_userclk_rx_srcclk_out(),
        .gtwiz_userclk_rx_usrclk_out(),
        .gtwiz_userclk_rx_usrclk2_out(phy_rx_clk),
        .gtwiz_userclk_rx_active_out(),
        .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
        .gtwiz_reset_rx_datapath_in(gt_reset_rx_datapath),
        .gtwiz_reset_rx_cdr_stable_out(),
        .gtwiz_reset_rx_done_out(gt_reset_rx_done),
        .rxpmaresetdone_out(),
        .rxprgdivresetdone_out(),

        .rxgearboxslip_in(gt_rxgearboxslip),
        .gtwiz_userdata_rx_out(gt_rxdata),
        .rxdatavalid_out(gt_rxdatavalid),
        .rxheader_out(gt_rxheader),
        .rxheadervalid_out(gt_rxheadervalid),
        .rxstartofseq_out()
    );

end

endgenerate

sync_reset #(
    .N(4)
)
tx_reset_sync_inst (
    .clk(phy_tx_clk),
    .rst(!gt_reset_tx_done),
    .out(phy_tx_rst)
);

sync_reset #(
    .N(4)
)
rx_reset_sync_inst (
    .clk(phy_rx_clk),
    .rst(!gt_reset_rx_done),
    .out(phy_rx_rst)
);

eth_phy_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .BIT_REVERSE(1),
    .SCRAMBLER_DISABLE(0),
    .PRBS31_ENABLE(PRBS31_ENABLE),
    .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
    .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
    .COUNT_125US(COUNT_125US)
)
phy_inst (
    .tx_clk(phy_tx_clk),
    .tx_rst(phy_tx_rst),
    .rx_clk(phy_rx_clk),
    .rx_rst(phy_rx_rst),
    .xgmii_txd(phy_xgmii_txd),
    .xgmii_txc(phy_xgmii_txc),
    .xgmii_rxd(phy_xgmii_rxd),
    .xgmii_rxc(phy_xgmii_rxc),
    .serdes_tx_data(gt_txdata),
    .serdes_tx_hdr(gt_txheader),
    .serdes_rx_data(gt_rxdata),
    .serdes_rx_hdr(gt_rxheader),
    .serdes_rx_bitslip(gt_rxgearboxslip),
    .serdes_rx_reset_req(phy_rx_reset_req),
    .tx_bad_block(phy_tx_bad_block),
    .rx_error_count(phy_rx_error_count),
    .rx_bad_block(phy_rx_bad_block),
    .rx_sequence_error(phy_rx_sequence_error),
    .rx_block_lock(phy_rx_block_lock),
    .rx_high_ber(phy_rx_high_ber),
    .tx_prbs31_enable(phy_tx_prbs31_enable),
    .rx_prbs31_enable(phy_rx_prbs31_enable)
);

endmodule

`resetall
