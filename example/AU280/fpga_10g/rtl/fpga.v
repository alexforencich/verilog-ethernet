/*

Copyright (c) 2014-2021 Alex Forencich

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
 * FPGA top-level module
 */
module fpga (
    /*
     * Reset: Push button, active low
     */
    input  wire       reset,

    /*
     * GPIO
     */
    output wire       hbm_cattrip,

    /*
     * Ethernet: QSFP28
     */
    output wire       qsfp0_tx1_p,
    output wire       qsfp0_tx1_n,
    input  wire       qsfp0_rx1_p,
    input  wire       qsfp0_rx1_n,
    output wire       qsfp0_tx2_p,
    output wire       qsfp0_tx2_n,
    input  wire       qsfp0_rx2_p,
    input  wire       qsfp0_rx2_n,
    output wire       qsfp0_tx3_p,
    output wire       qsfp0_tx3_n,
    input  wire       qsfp0_rx3_p,
    input  wire       qsfp0_rx3_n,
    output wire       qsfp0_tx4_p,
    output wire       qsfp0_tx4_n,
    input  wire       qsfp0_rx4_p,
    input  wire       qsfp0_rx4_n,
    // input  wire       qsfp0_mgt_refclk_0_p,
    // input  wire       qsfp0_mgt_refclk_0_n,
    input  wire       qsfp0_mgt_refclk_1_p,
    input  wire       qsfp0_mgt_refclk_1_n,
    output wire       qsfp0_refclk_oe_b,
    output wire       qsfp0_refclk_fs,

    output wire       qsfp1_tx1_p,
    output wire       qsfp1_tx1_n,
    input  wire       qsfp1_rx1_p,
    input  wire       qsfp1_rx1_n,
    output wire       qsfp1_tx2_p,
    output wire       qsfp1_tx2_n,
    input  wire       qsfp1_rx2_p,
    input  wire       qsfp1_rx2_n,
    output wire       qsfp1_tx3_p,
    output wire       qsfp1_tx3_n,
    input  wire       qsfp1_rx3_p,
    input  wire       qsfp1_rx3_n,
    output wire       qsfp1_tx4_p,
    output wire       qsfp1_tx4_n,
    input  wire       qsfp1_rx4_p,
    input  wire       qsfp1_rx4_n,
    // input  wire       qsfp1_mgt_refclk_0_p,
    // input  wire       qsfp1_mgt_refclk_0_n,
    input  wire       qsfp1_mgt_refclk_1_p,
    input  wire       qsfp1_mgt_refclk_1_n,
    output wire       qsfp1_refclk_oe_b,
    output wire       qsfp1_refclk_fs
);

// Clock and reset

wire clk_161mhz_ref_int;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = ~reset;
wire mmcm_locked;
wire mmcm_clkfb;

// MMCM instance
// 161.13 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 64, D = 11 sets Fvco = 937.5 MHz (in range)
// Divide by 7.5 to get output frequency of 125 MHz
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(7.5),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(64),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(11),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(6.206),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_161mhz_ref_int),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked),
    .out(rst_125mhz_int)
);

// GPIO
assign hbm_cattrip = 1'b0;

// XGMII 10G PHY

// QSFP0
assign qsfp0_refclk_oe_b = 1'b0;
assign qsfp0_refclk_fs = 1'b1;

wire        qsfp0_tx_clk_1_int;
wire        qsfp0_tx_rst_1_int;
wire [63:0] qsfp0_txd_1_int;
wire [7:0]  qsfp0_txc_1_int;
wire        qsfp0_rx_clk_1_int;
wire        qsfp0_rx_rst_1_int;
wire [63:0] qsfp0_rxd_1_int;
wire [7:0]  qsfp0_rxc_1_int;
wire        qsfp0_tx_clk_2_int;
wire        qsfp0_tx_rst_2_int;
wire [63:0] qsfp0_txd_2_int;
wire [7:0]  qsfp0_txc_2_int;
wire        qsfp0_rx_clk_2_int;
wire        qsfp0_rx_rst_2_int;
wire [63:0] qsfp0_rxd_2_int;
wire [7:0]  qsfp0_rxc_2_int;
wire        qsfp0_tx_clk_3_int;
wire        qsfp0_tx_rst_3_int;
wire [63:0] qsfp0_txd_3_int;
wire [7:0]  qsfp0_txc_3_int;
wire        qsfp0_rx_clk_3_int;
wire        qsfp0_rx_rst_3_int;
wire [63:0] qsfp0_rxd_3_int;
wire [7:0]  qsfp0_rxc_3_int;
wire        qsfp0_tx_clk_4_int;
wire        qsfp0_tx_rst_4_int;
wire [63:0] qsfp0_txd_4_int;
wire [7:0]  qsfp0_txc_4_int;
wire        qsfp0_rx_clk_4_int;
wire        qsfp0_rx_rst_4_int;
wire [63:0] qsfp0_rxd_4_int;
wire [7:0]  qsfp0_rxc_4_int;

assign clk_156mhz_int = qsfp0_tx_clk_1_int;
assign rst_156mhz_int = qsfp0_tx_rst_1_int;

wire qsfp0_rx_block_lock_1;
wire qsfp0_rx_block_lock_2;
wire qsfp0_rx_block_lock_3;
wire qsfp0_rx_block_lock_4;

wire qsfp0_gtpowergood;

wire qsfp0_mgt_refclk_1;
wire qsfp0_mgt_refclk_1_int;
wire qsfp0_mgt_refclk_1_bufg;

assign clk_161mhz_ref_int = qsfp0_mgt_refclk_1_bufg;

IBUFDS_GTE4 ibufds_gte4_qsfp0_mgt_refclk_1_inst (
    .I     (qsfp0_mgt_refclk_1_p),
    .IB    (qsfp0_mgt_refclk_1_n),
    .CEB   (1'b0),
    .O     (qsfp0_mgt_refclk_1),
    .ODIV2 (qsfp0_mgt_refclk_1_int)
);

BUFG_GT bufg_gt_refclk_inst (
    .CE      (qsfp0_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (qsfp0_mgt_refclk_1_int),
    .O       (qsfp0_mgt_refclk_1_bufg)
);

wire qsfp0_qpll0lock;
wire qsfp0_qpll0outclk;
wire qsfp0_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp0_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(qsfp0_gtpowergood),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp0_mgt_refclk_1),
    .xcvr_qpll0lock_out(qsfp0_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp0_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp0_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp0_tx1_p),
    .xcvr_txn(qsfp0_tx1_n),
    .xcvr_rxp(qsfp0_rx1_p),
    .xcvr_rxn(qsfp0_rx1_n),

    // PHY connections
    .phy_tx_clk(qsfp0_tx_clk_1_int),
    .phy_tx_rst(qsfp0_tx_rst_1_int),
    .phy_xgmii_txd(qsfp0_txd_1_int),
    .phy_xgmii_txc(qsfp0_txc_1_int),
    .phy_rx_clk(qsfp0_rx_clk_1_int),
    .phy_rx_rst(qsfp0_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp0_rxd_1_int),
    .phy_xgmii_rxc(qsfp0_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp0_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp0_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp0_tx2_p),
    .xcvr_txn(qsfp0_tx2_n),
    .xcvr_rxp(qsfp0_rx2_p),
    .xcvr_rxn(qsfp0_rx2_n),

    // PHY connections
    .phy_tx_clk(qsfp0_tx_clk_2_int),
    .phy_tx_rst(qsfp0_tx_rst_2_int),
    .phy_xgmii_txd(qsfp0_txd_2_int),
    .phy_xgmii_txc(qsfp0_txc_2_int),
    .phy_rx_clk(qsfp0_rx_clk_2_int),
    .phy_rx_rst(qsfp0_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp0_rxd_2_int),
    .phy_xgmii_rxc(qsfp0_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp0_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp0_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp0_tx3_p),
    .xcvr_txn(qsfp0_tx3_n),
    .xcvr_rxp(qsfp0_rx3_p),
    .xcvr_rxn(qsfp0_rx3_n),

    // PHY connections
    .phy_tx_clk(qsfp0_tx_clk_3_int),
    .phy_tx_rst(qsfp0_tx_rst_3_int),
    .phy_xgmii_txd(qsfp0_txd_3_int),
    .phy_xgmii_txc(qsfp0_txc_3_int),
    .phy_rx_clk(qsfp0_rx_clk_3_int),
    .phy_rx_rst(qsfp0_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp0_rxd_3_int),
    .phy_xgmii_rxc(qsfp0_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp0_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp0_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp0_tx4_p),
    .xcvr_txn(qsfp0_tx4_n),
    .xcvr_rxp(qsfp0_rx4_p),
    .xcvr_rxn(qsfp0_rx4_n),

    // PHY connections
    .phy_tx_clk(qsfp0_tx_clk_4_int),
    .phy_tx_rst(qsfp0_tx_rst_4_int),
    .phy_xgmii_txd(qsfp0_txd_4_int),
    .phy_xgmii_txc(qsfp0_txc_4_int),
    .phy_rx_clk(qsfp0_rx_clk_4_int),
    .phy_rx_rst(qsfp0_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp0_rxd_4_int),
    .phy_xgmii_rxc(qsfp0_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp0_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP1
assign qsfp1_refclk_oe_b = 1'b0;
assign qsfp1_refclk_fs = 1'b1;

wire        qsfp1_tx_clk_1_int;
wire        qsfp1_tx_rst_1_int;
wire [63:0] qsfp1_txd_1_int;
wire [7:0]  qsfp1_txc_1_int;
wire        qsfp1_rx_clk_1_int;
wire        qsfp1_rx_rst_1_int;
wire [63:0] qsfp1_rxd_1_int;
wire [7:0]  qsfp1_rxc_1_int;
wire        qsfp1_tx_clk_2_int;
wire        qsfp1_tx_rst_2_int;
wire [63:0] qsfp1_txd_2_int;
wire [7:0]  qsfp1_txc_2_int;
wire        qsfp1_rx_clk_2_int;
wire        qsfp1_rx_rst_2_int;
wire [63:0] qsfp1_rxd_2_int;
wire [7:0]  qsfp1_rxc_2_int;
wire        qsfp1_tx_clk_3_int;
wire        qsfp1_tx_rst_3_int;
wire [63:0] qsfp1_txd_3_int;
wire [7:0]  qsfp1_txc_3_int;
wire        qsfp1_rx_clk_3_int;
wire        qsfp1_rx_rst_3_int;
wire [63:0] qsfp1_rxd_3_int;
wire [7:0]  qsfp1_rxc_3_int;
wire        qsfp1_tx_clk_4_int;
wire        qsfp1_tx_rst_4_int;
wire [63:0] qsfp1_txd_4_int;
wire [7:0]  qsfp1_txc_4_int;
wire        qsfp1_rx_clk_4_int;
wire        qsfp1_rx_rst_4_int;
wire [63:0] qsfp1_rxd_4_int;
wire [7:0]  qsfp1_rxc_4_int;

wire qsfp1_rx_block_lock_1;
wire qsfp1_rx_block_lock_2;
wire qsfp1_rx_block_lock_3;
wire qsfp1_rx_block_lock_4;

wire qsfp1_mgt_refclk_1;

IBUFDS_GTE4 ibufds_gte4_qsfp1_mgt_refclk_1_inst (
    .I     (qsfp1_mgt_refclk_1_p),
    .IB    (qsfp1_mgt_refclk_1_n),
    .CEB   (1'b0),
    .O     (qsfp1_mgt_refclk_1),
    .ODIV2 ()
);

wire qsfp1_qpll0lock;
wire qsfp1_qpll0outclk;
wire qsfp1_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp1_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp1_mgt_refclk_1),
    .xcvr_qpll0lock_out(qsfp1_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp1_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp1_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp1_tx1_p),
    .xcvr_txn(qsfp1_tx1_n),
    .xcvr_rxp(qsfp1_rx1_p),
    .xcvr_rxn(qsfp1_rx1_n),

    // PHY connections
    .phy_tx_clk(qsfp1_tx_clk_1_int),
    .phy_tx_rst(qsfp1_tx_rst_1_int),
    .phy_xgmii_txd(qsfp1_txd_1_int),
    .phy_xgmii_txc(qsfp1_txc_1_int),
    .phy_rx_clk(qsfp1_rx_clk_1_int),
    .phy_rx_rst(qsfp1_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp1_rxd_1_int),
    .phy_xgmii_rxc(qsfp1_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp1_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp1_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp1_tx2_p),
    .xcvr_txn(qsfp1_tx2_n),
    .xcvr_rxp(qsfp1_rx2_p),
    .xcvr_rxn(qsfp1_rx2_n),

    // PHY connections
    .phy_tx_clk(qsfp1_tx_clk_2_int),
    .phy_tx_rst(qsfp1_tx_rst_2_int),
    .phy_xgmii_txd(qsfp1_txd_2_int),
    .phy_xgmii_txc(qsfp1_txc_2_int),
    .phy_rx_clk(qsfp1_rx_clk_2_int),
    .phy_rx_rst(qsfp1_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp1_rxd_2_int),
    .phy_xgmii_rxc(qsfp1_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp1_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp1_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp1_tx3_p),
    .xcvr_txn(qsfp1_tx3_n),
    .xcvr_rxp(qsfp1_rx3_p),
    .xcvr_rxn(qsfp1_rx3_n),

    // PHY connections
    .phy_tx_clk(qsfp1_tx_clk_3_int),
    .phy_tx_rst(qsfp1_tx_rst_3_int),
    .phy_xgmii_txd(qsfp1_txd_3_int),
    .phy_xgmii_txc(qsfp1_txc_3_int),
    .phy_rx_clk(qsfp1_rx_clk_3_int),
    .phy_rx_rst(qsfp1_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp1_rxd_3_int),
    .phy_xgmii_rxc(qsfp1_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp1_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp1_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp1_tx4_p),
    .xcvr_txn(qsfp1_tx4_n),
    .xcvr_rxp(qsfp1_rx4_p),
    .xcvr_rxn(qsfp1_rx4_n),

    // PHY connections
    .phy_tx_clk(qsfp1_tx_clk_4_int),
    .phy_tx_rst(qsfp1_tx_rst_4_int),
    .phy_xgmii_txd(qsfp1_txd_4_int),
    .phy_xgmii_txc(qsfp1_txc_4_int),
    .phy_rx_clk(qsfp1_rx_clk_4_int),
    .phy_rx_rst(qsfp1_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp1_rxd_4_int),
    .phy_xgmii_rxc(qsfp1_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp1_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

fpga_core
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    /*
     * Ethernet: QSFP28
     */
    .qsfp0_tx_clk_1(qsfp0_tx_clk_1_int),
    .qsfp0_tx_rst_1(qsfp0_tx_rst_1_int),
    .qsfp0_txd_1(qsfp0_txd_1_int),
    .qsfp0_txc_1(qsfp0_txc_1_int),
    .qsfp0_rx_clk_1(qsfp0_rx_clk_1_int),
    .qsfp0_rx_rst_1(qsfp0_rx_rst_1_int),
    .qsfp0_rxd_1(qsfp0_rxd_1_int),
    .qsfp0_rxc_1(qsfp0_rxc_1_int),
    .qsfp0_tx_clk_2(qsfp0_tx_clk_2_int),
    .qsfp0_tx_rst_2(qsfp0_tx_rst_2_int),
    .qsfp0_txd_2(qsfp0_txd_2_int),
    .qsfp0_txc_2(qsfp0_txc_2_int),
    .qsfp0_rx_clk_2(qsfp0_rx_clk_2_int),
    .qsfp0_rx_rst_2(qsfp0_rx_rst_2_int),
    .qsfp0_rxd_2(qsfp0_rxd_2_int),
    .qsfp0_rxc_2(qsfp0_rxc_2_int),
    .qsfp0_tx_clk_3(qsfp0_tx_clk_3_int),
    .qsfp0_tx_rst_3(qsfp0_tx_rst_3_int),
    .qsfp0_txd_3(qsfp0_txd_3_int),
    .qsfp0_txc_3(qsfp0_txc_3_int),
    .qsfp0_rx_clk_3(qsfp0_rx_clk_3_int),
    .qsfp0_rx_rst_3(qsfp0_rx_rst_3_int),
    .qsfp0_rxd_3(qsfp0_rxd_3_int),
    .qsfp0_rxc_3(qsfp0_rxc_3_int),
    .qsfp0_tx_clk_4(qsfp0_tx_clk_4_int),
    .qsfp0_tx_rst_4(qsfp0_tx_rst_4_int),
    .qsfp0_txd_4(qsfp0_txd_4_int),
    .qsfp0_txc_4(qsfp0_txc_4_int),
    .qsfp0_rx_clk_4(qsfp0_rx_clk_4_int),
    .qsfp0_rx_rst_4(qsfp0_rx_rst_4_int),
    .qsfp0_rxd_4(qsfp0_rxd_4_int),
    .qsfp0_rxc_4(qsfp0_rxc_4_int),
    .qsfp1_tx_clk_1(qsfp1_tx_clk_1_int),
    .qsfp1_tx_rst_1(qsfp1_tx_rst_1_int),
    .qsfp1_txd_1(qsfp1_txd_1_int),
    .qsfp1_txc_1(qsfp1_txc_1_int),
    .qsfp1_rx_clk_1(qsfp1_rx_clk_1_int),
    .qsfp1_rx_rst_1(qsfp1_rx_rst_1_int),
    .qsfp1_rxd_1(qsfp1_rxd_1_int),
    .qsfp1_rxc_1(qsfp1_rxc_1_int),
    .qsfp1_tx_clk_2(qsfp1_tx_clk_2_int),
    .qsfp1_tx_rst_2(qsfp1_tx_rst_2_int),
    .qsfp1_txd_2(qsfp1_txd_2_int),
    .qsfp1_txc_2(qsfp1_txc_2_int),
    .qsfp1_rx_clk_2(qsfp1_rx_clk_2_int),
    .qsfp1_rx_rst_2(qsfp1_rx_rst_2_int),
    .qsfp1_rxd_2(qsfp1_rxd_2_int),
    .qsfp1_rxc_2(qsfp1_rxc_2_int),
    .qsfp1_tx_clk_3(qsfp1_tx_clk_3_int),
    .qsfp1_tx_rst_3(qsfp1_tx_rst_3_int),
    .qsfp1_txd_3(qsfp1_txd_3_int),
    .qsfp1_txc_3(qsfp1_txc_3_int),
    .qsfp1_rx_clk_3(qsfp1_rx_clk_3_int),
    .qsfp1_rx_rst_3(qsfp1_rx_rst_3_int),
    .qsfp1_rxd_3(qsfp1_rxd_3_int),
    .qsfp1_rxc_3(qsfp1_rxc_3_int),
    .qsfp1_tx_clk_4(qsfp1_tx_clk_4_int),
    .qsfp1_tx_rst_4(qsfp1_tx_rst_4_int),
    .qsfp1_txd_4(qsfp1_txd_4_int),
    .qsfp1_txc_4(qsfp1_txc_4_int),
    .qsfp1_rx_clk_4(qsfp1_rx_clk_4_int),
    .qsfp1_rx_rst_4(qsfp1_rx_rst_4_int),
    .qsfp1_rxd_4(qsfp1_rxd_4_int),
    .qsfp1_rxc_4(qsfp1_rxc_4_int)
);

endmodule

`resetall
