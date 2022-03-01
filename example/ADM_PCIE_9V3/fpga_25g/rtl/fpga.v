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
     * Clock: 300MHz LVDS
     */
    input  wire       clk_300mhz_p,
    input  wire       clk_300mhz_n,

    /*
     * GPIO
     */
    output wire [1:0] user_led_g,
    output wire       user_led_r,
    output wire [1:0] front_led,
    input  wire [1:0] user_sw,

    /*
     * Ethernet: QSFP28
     */
    output wire       qsfp_0_tx_0_p,
    output wire       qsfp_0_tx_0_n,
    input  wire       qsfp_0_rx_0_p,
    input  wire       qsfp_0_rx_0_n,
    output wire       qsfp_0_tx_1_p,
    output wire       qsfp_0_tx_1_n,
    input  wire       qsfp_0_rx_1_p,
    input  wire       qsfp_0_rx_1_n,
    output wire       qsfp_0_tx_2_p,
    output wire       qsfp_0_tx_2_n,
    input  wire       qsfp_0_rx_2_p,
    input  wire       qsfp_0_rx_2_n,
    output wire       qsfp_0_tx_3_p,
    output wire       qsfp_0_tx_3_n,
    input  wire       qsfp_0_rx_3_p,
    input  wire       qsfp_0_rx_3_n,
    input  wire       qsfp_0_mgt_refclk_p,
    input  wire       qsfp_0_mgt_refclk_n,
    input  wire       qsfp_0_modprs_l,
    output wire       qsfp_0_sel_l,

    output wire       qsfp_1_tx_0_p,
    output wire       qsfp_1_tx_0_n,
    input  wire       qsfp_1_rx_0_p,
    input  wire       qsfp_1_rx_0_n,
    output wire       qsfp_1_tx_1_p,
    output wire       qsfp_1_tx_1_n,
    input  wire       qsfp_1_rx_1_p,
    input  wire       qsfp_1_rx_1_n,
    output wire       qsfp_1_tx_2_p,
    output wire       qsfp_1_tx_2_n,
    input  wire       qsfp_1_rx_2_p,
    input  wire       qsfp_1_rx_2_n,
    output wire       qsfp_1_tx_3_p,
    output wire       qsfp_1_tx_3_n,
    input  wire       qsfp_1_rx_3_p,
    input  wire       qsfp_1_rx_3_n,
    input  wire       qsfp_1_mgt_refclk_p,
    input  wire       qsfp_1_mgt_refclk_n,
    input  wire       qsfp_1_modprs_l,
    output wire       qsfp_1_sel_l,

    output wire       qsfp_reset_l,
    input  wire       qsfp_int_l
);

// Clock and reset

wire clk_300mhz_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 390.625 MHz clock
wire clk_390mhz_int;
wire rst_390mhz_int;

wire mmcm_rst = 1'b0;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_300mhz_ibufg_inst (
   .O   (clk_300mhz_ibufg),
   .I   (clk_300mhz_p),
   .IB  (clk_300mhz_n) 
);

// MMCM instance
// 300 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 10, D = 3 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME3_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8),
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
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(3),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(3.333),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_300mhz_ibufg),
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
wire [1:0] user_sw_int;

debounce_switch #(
    .WIDTH(2),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({user_sw}),
    .out({user_sw_int})
);

// XGMII 10G PHY

assign qsfp_reset_l = 1'b1;

// QSFP 0
assign qsfp_0_sel_l = 1'b0;

wire        qsfp_0_tx_clk_0_int;
wire        qsfp_0_tx_rst_0_int;
wire [63:0] qsfp_0_txd_0_int;
wire [7:0]  qsfp_0_txc_0_int;
wire        qsfp_0_rx_clk_0_int;
wire        qsfp_0_rx_rst_0_int;
wire [63:0] qsfp_0_rxd_0_int;
wire [7:0]  qsfp_0_rxc_0_int;
wire        qsfp_0_tx_clk_1_int;
wire        qsfp_0_tx_rst_1_int;
wire [63:0] qsfp_0_txd_1_int;
wire [7:0]  qsfp_0_txc_1_int;
wire        qsfp_0_rx_clk_1_int;
wire        qsfp_0_rx_rst_1_int;
wire [63:0] qsfp_0_rxd_1_int;
wire [7:0]  qsfp_0_rxc_1_int;
wire        qsfp_0_tx_clk_2_int;
wire        qsfp_0_tx_rst_2_int;
wire [63:0] qsfp_0_txd_2_int;
wire [7:0]  qsfp_0_txc_2_int;
wire        qsfp_0_rx_clk_2_int;
wire        qsfp_0_rx_rst_2_int;
wire [63:0] qsfp_0_rxd_2_int;
wire [7:0]  qsfp_0_rxc_2_int;
wire        qsfp_0_tx_clk_3_int;
wire        qsfp_0_tx_rst_3_int;
wire [63:0] qsfp_0_txd_3_int;
wire [7:0]  qsfp_0_txc_3_int;
wire        qsfp_0_rx_clk_3_int;
wire        qsfp_0_rx_rst_3_int;
wire [63:0] qsfp_0_rxd_3_int;
wire [7:0]  qsfp_0_rxc_3_int;

assign clk_390mhz_int = qsfp_0_tx_clk_0_int;
assign rst_390mhz_int = qsfp_0_tx_rst_0_int;

wire qsfp_0_rx_block_lock_0;
wire qsfp_0_rx_block_lock_1;
wire qsfp_0_rx_block_lock_2;
wire qsfp_0_rx_block_lock_3;

wire qsfp_0_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_0_mgt_refclk_inst (
    .I     (qsfp_0_mgt_refclk_p),
    .IB    (qsfp_0_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (qsfp_0_mgt_refclk),
    .ODIV2 ()
);

wire qsfp_0_qpll0lock;
wire qsfp_0_qpll0outclk;
wire qsfp_0_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_0_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_0_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_0_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_0_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_0_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_0_tx_0_p),
    .xcvr_txn(qsfp_0_tx_0_n),
    .xcvr_rxp(qsfp_0_rx_0_p),
    .xcvr_rxn(qsfp_0_rx_0_n),

    // PHY connections
    .phy_tx_clk(qsfp_0_tx_clk_0_int),
    .phy_tx_rst(qsfp_0_tx_rst_0_int),
    .phy_xgmii_txd(qsfp_0_txd_0_int),
    .phy_xgmii_txc(qsfp_0_txc_0_int),
    .phy_rx_clk(qsfp_0_rx_clk_0_int),
    .phy_rx_rst(qsfp_0_rx_rst_0_int),
    .phy_xgmii_rxd(qsfp_0_rxd_0_int),
    .phy_xgmii_rxc(qsfp_0_rxc_0_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_0_rx_block_lock_0),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_1_inst (
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
    .xcvr_qpll0lock_in(qsfp_0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_0_tx_1_p),
    .xcvr_txn(qsfp_0_tx_1_n),
    .xcvr_rxp(qsfp_0_rx_1_p),
    .xcvr_rxn(qsfp_0_rx_1_n),

    // PHY connections
    .phy_tx_clk(qsfp_0_tx_clk_1_int),
    .phy_tx_rst(qsfp_0_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_0_txd_1_int),
    .phy_xgmii_txc(qsfp_0_txc_1_int),
    .phy_rx_clk(qsfp_0_rx_clk_1_int),
    .phy_rx_rst(qsfp_0_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_0_rxd_1_int),
    .phy_xgmii_rxc(qsfp_0_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_0_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_2_inst (
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
    .xcvr_qpll0lock_in(qsfp_0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_0_tx_2_p),
    .xcvr_txn(qsfp_0_tx_2_n),
    .xcvr_rxp(qsfp_0_rx_2_p),
    .xcvr_rxn(qsfp_0_rx_2_n),

    // PHY connections
    .phy_tx_clk(qsfp_0_tx_clk_2_int),
    .phy_tx_rst(qsfp_0_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_0_txd_2_int),
    .phy_xgmii_txc(qsfp_0_txc_2_int),
    .phy_rx_clk(qsfp_0_rx_clk_2_int),
    .phy_rx_rst(qsfp_0_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_0_rxd_2_int),
    .phy_xgmii_rxc(qsfp_0_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_0_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_3_inst (
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
    .xcvr_qpll0lock_in(qsfp_0_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_0_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_0_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_0_tx_3_p),
    .xcvr_txn(qsfp_0_tx_3_n),
    .xcvr_rxp(qsfp_0_rx_3_p),
    .xcvr_rxn(qsfp_0_rx_3_n),

    // PHY connections
    .phy_tx_clk(qsfp_0_tx_clk_3_int),
    .phy_tx_rst(qsfp_0_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_0_txd_3_int),
    .phy_xgmii_txc(qsfp_0_txc_3_int),
    .phy_rx_clk(qsfp_0_rx_clk_3_int),
    .phy_rx_rst(qsfp_0_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_0_rxd_3_int),
    .phy_xgmii_rxc(qsfp_0_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_0_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 1
assign qsfp_1_sel_l = 1'b0;

wire        qsfp_1_tx_clk_0_int;
wire        qsfp_1_tx_rst_0_int;
wire [63:0] qsfp_1_txd_0_int;
wire [7:0]  qsfp_1_txc_0_int;
wire        qsfp_1_rx_clk_0_int;
wire        qsfp_1_rx_rst_0_int;
wire [63:0] qsfp_1_rxd_0_int;
wire [7:0]  qsfp_1_rxc_0_int;
wire        qsfp_1_tx_clk_1_int;
wire        qsfp_1_tx_rst_1_int;
wire [63:0] qsfp_1_txd_1_int;
wire [7:0]  qsfp_1_txc_1_int;
wire        qsfp_1_rx_clk_1_int;
wire        qsfp_1_rx_rst_1_int;
wire [63:0] qsfp_1_rxd_1_int;
wire [7:0]  qsfp_1_rxc_1_int;
wire        qsfp_1_tx_clk_2_int;
wire        qsfp_1_tx_rst_2_int;
wire [63:0] qsfp_1_txd_2_int;
wire [7:0]  qsfp_1_txc_2_int;
wire        qsfp_1_rx_clk_2_int;
wire        qsfp_1_rx_rst_2_int;
wire [63:0] qsfp_1_rxd_2_int;
wire [7:0]  qsfp_1_rxc_2_int;
wire        qsfp_1_tx_clk_3_int;
wire        qsfp_1_tx_rst_3_int;
wire [63:0] qsfp_1_txd_3_int;
wire [7:0]  qsfp_1_txc_3_int;
wire        qsfp_1_rx_clk_3_int;
wire        qsfp_1_rx_rst_3_int;
wire [63:0] qsfp_1_rxd_3_int;
wire [7:0]  qsfp_1_rxc_3_int;

wire qsfp_1_rx_block_lock_0;
wire qsfp_1_rx_block_lock_1;
wire qsfp_1_rx_block_lock_2;
wire qsfp_1_rx_block_lock_3;

wire qsfp_1_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_1_mgt_refclk_inst (
    .I     (qsfp_1_mgt_refclk_p),
    .IB    (qsfp_1_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (qsfp_1_mgt_refclk),
    .ODIV2 ()
);

wire qsfp_1_qpll0lock;
wire qsfp_1_qpll0outclk;
wire qsfp_1_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_0_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_1_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_1_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_1_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_1_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_1_tx_0_p),
    .xcvr_txn(qsfp_1_tx_0_n),
    .xcvr_rxp(qsfp_1_rx_0_p),
    .xcvr_rxn(qsfp_1_rx_0_n),

    // PHY connections
    .phy_tx_clk(qsfp_1_tx_clk_0_int),
    .phy_tx_rst(qsfp_1_tx_rst_0_int),
    .phy_xgmii_txd(qsfp_1_txd_0_int),
    .phy_xgmii_txc(qsfp_1_txc_0_int),
    .phy_rx_clk(qsfp_1_rx_clk_0_int),
    .phy_rx_rst(qsfp_1_rx_rst_0_int),
    .phy_xgmii_rxd(qsfp_1_rxd_0_int),
    .phy_xgmii_rxc(qsfp_1_rxc_0_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_1_rx_block_lock_0),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_1_inst (
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
    .xcvr_qpll0lock_in(qsfp_1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_1_tx_1_p),
    .xcvr_txn(qsfp_1_tx_1_n),
    .xcvr_rxp(qsfp_1_rx_1_p),
    .xcvr_rxn(qsfp_1_rx_1_n),

    // PHY connections
    .phy_tx_clk(qsfp_1_tx_clk_1_int),
    .phy_tx_rst(qsfp_1_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_1_txd_1_int),
    .phy_xgmii_txc(qsfp_1_txc_1_int),
    .phy_rx_clk(qsfp_1_rx_clk_1_int),
    .phy_rx_rst(qsfp_1_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_1_rxd_1_int),
    .phy_xgmii_rxc(qsfp_1_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_1_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_2_inst (
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
    .xcvr_qpll0lock_in(qsfp_1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_1_tx_2_p),
    .xcvr_txn(qsfp_1_tx_2_n),
    .xcvr_rxp(qsfp_1_rx_2_p),
    .xcvr_rxn(qsfp_1_rx_2_n),

    // PHY connections
    .phy_tx_clk(qsfp_1_tx_clk_2_int),
    .phy_tx_rst(qsfp_1_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_1_txd_2_int),
    .phy_xgmii_txc(qsfp_1_txc_2_int),
    .phy_rx_clk(qsfp_1_rx_clk_2_int),
    .phy_rx_rst(qsfp_1_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_1_rxd_2_int),
    .phy_xgmii_rxc(qsfp_1_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_1_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_3_inst (
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
    .xcvr_qpll0lock_in(qsfp_1_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_1_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_1_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_1_tx_3_p),
    .xcvr_txn(qsfp_1_tx_3_n),
    .xcvr_rxp(qsfp_1_rx_3_p),
    .xcvr_rxn(qsfp_1_rx_3_n),

    // PHY connections
    .phy_tx_clk(qsfp_1_tx_clk_3_int),
    .phy_tx_rst(qsfp_1_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_1_txd_3_int),
    .phy_xgmii_txc(qsfp_1_txc_3_int),
    .phy_rx_clk(qsfp_1_rx_clk_3_int),
    .phy_rx_rst(qsfp_1_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_1_rxd_3_int),
    .phy_xgmii_rxc(qsfp_1_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_1_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

assign front_led[0] = qsfp_0_rx_block_lock_0;
assign front_led[1] = qsfp_1_rx_block_lock_0;

fpga_core
core_inst (
    /*
     * Clock: 390.625 MHz
     * Synchronous reset
     */
    .clk(clk_390mhz_int),
    .rst(rst_390mhz_int),
    /*
     * GPIO
     */
    .user_led_g(user_led_g),
    .user_led_r(user_led_r),
    //.front_led(front_led),
    .user_sw(user_sw_int),

    /*
     * Ethernet: QSFP28
     */
    .qsfp_0_tx_clk_0(qsfp_0_tx_clk_0_int),
    .qsfp_0_tx_rst_0(qsfp_0_tx_rst_0_int),
    .qsfp_0_txd_0(qsfp_0_txd_0_int),
    .qsfp_0_txc_0(qsfp_0_txc_0_int),
    .qsfp_0_rx_clk_0(qsfp_0_rx_clk_0_int),
    .qsfp_0_rx_rst_0(qsfp_0_rx_rst_0_int),
    .qsfp_0_rxd_0(qsfp_0_rxd_0_int),
    .qsfp_0_rxc_0(qsfp_0_rxc_0_int),
    .qsfp_0_tx_clk_1(qsfp_0_tx_clk_1_int),
    .qsfp_0_tx_rst_1(qsfp_0_tx_rst_1_int),
    .qsfp_0_txd_1(qsfp_0_txd_1_int),
    .qsfp_0_txc_1(qsfp_0_txc_1_int),
    .qsfp_0_rx_clk_1(qsfp_0_rx_clk_1_int),
    .qsfp_0_rx_rst_1(qsfp_0_rx_rst_1_int),
    .qsfp_0_rxd_1(qsfp_0_rxd_1_int),
    .qsfp_0_rxc_1(qsfp_0_rxc_1_int),
    .qsfp_0_tx_clk_2(qsfp_0_tx_clk_2_int),
    .qsfp_0_tx_rst_2(qsfp_0_tx_rst_2_int),
    .qsfp_0_txd_2(qsfp_0_txd_2_int),
    .qsfp_0_txc_2(qsfp_0_txc_2_int),
    .qsfp_0_rx_clk_2(qsfp_0_rx_clk_2_int),
    .qsfp_0_rx_rst_2(qsfp_0_rx_rst_2_int),
    .qsfp_0_rxd_2(qsfp_0_rxd_2_int),
    .qsfp_0_rxc_2(qsfp_0_rxc_2_int),
    .qsfp_0_tx_clk_3(qsfp_0_tx_clk_3_int),
    .qsfp_0_tx_rst_3(qsfp_0_tx_rst_3_int),
    .qsfp_0_txd_3(qsfp_0_txd_3_int),
    .qsfp_0_txc_3(qsfp_0_txc_3_int),
    .qsfp_0_rx_clk_3(qsfp_0_rx_clk_3_int),
    .qsfp_0_rx_rst_3(qsfp_0_rx_rst_3_int),
    .qsfp_0_rxd_3(qsfp_0_rxd_3_int),
    .qsfp_0_rxc_3(qsfp_0_rxc_3_int),
    .qsfp_1_tx_clk_0(qsfp_1_tx_clk_0_int),
    .qsfp_1_tx_rst_0(qsfp_1_tx_rst_0_int),
    .qsfp_1_txd_0(qsfp_1_txd_0_int),
    .qsfp_1_txc_0(qsfp_1_txc_0_int),
    .qsfp_1_rx_clk_0(qsfp_1_rx_clk_0_int),
    .qsfp_1_rx_rst_0(qsfp_1_rx_rst_0_int),
    .qsfp_1_rxd_0(qsfp_1_rxd_0_int),
    .qsfp_1_rxc_0(qsfp_1_rxc_0_int),
    .qsfp_1_tx_clk_1(qsfp_1_tx_clk_1_int),
    .qsfp_1_tx_rst_1(qsfp_1_tx_rst_1_int),
    .qsfp_1_txd_1(qsfp_1_txd_1_int),
    .qsfp_1_txc_1(qsfp_1_txc_1_int),
    .qsfp_1_rx_clk_1(qsfp_1_rx_clk_1_int),
    .qsfp_1_rx_rst_1(qsfp_1_rx_rst_1_int),
    .qsfp_1_rxd_1(qsfp_1_rxd_1_int),
    .qsfp_1_rxc_1(qsfp_1_rxc_1_int),
    .qsfp_1_tx_clk_2(qsfp_1_tx_clk_2_int),
    .qsfp_1_tx_rst_2(qsfp_1_tx_rst_2_int),
    .qsfp_1_txd_2(qsfp_1_txd_2_int),
    .qsfp_1_txc_2(qsfp_1_txc_2_int),
    .qsfp_1_rx_clk_2(qsfp_1_rx_clk_2_int),
    .qsfp_1_rx_rst_2(qsfp_1_rx_rst_2_int),
    .qsfp_1_rxd_2(qsfp_1_rxd_2_int),
    .qsfp_1_rxc_2(qsfp_1_rxc_2_int),
    .qsfp_1_tx_clk_3(qsfp_1_tx_clk_3_int),
    .qsfp_1_tx_rst_3(qsfp_1_tx_rst_3_int),
    .qsfp_1_txd_3(qsfp_1_txd_3_int),
    .qsfp_1_txc_3(qsfp_1_txc_3_int),
    .qsfp_1_rx_clk_3(qsfp_1_rx_clk_3_int),
    .qsfp_1_rx_rst_3(qsfp_1_rx_rst_3_int),
    .qsfp_1_rxd_3(qsfp_1_rxd_3_int),
    .qsfp_1_rxc_3(qsfp_1_rxc_3_int)
);

endmodule

`resetall
