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
     * GPIO
     */
    output wire       qsfp_led_act,
    output wire       qsfp_led_stat_g,
    output wire       qsfp_led_stat_y,
    output wire       hbm_cattrip,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0] qsfp_tx_p,
    output wire [3:0] qsfp_tx_n,
    input  wire [3:0] qsfp_rx_p,
    input  wire [3:0] qsfp_rx_n,
    input  wire       qsfp_mgt_refclk_0_p,
    input  wire       qsfp_mgt_refclk_0_n
    // input  wire       qsfp_mgt_refclk_1_p,
    // input  wire       qsfp_mgt_refclk_1_n
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

wire mmcm_rst = 1'b0;
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
wire        qsfp_tx_clk_1_int;
wire        qsfp_tx_rst_1_int;
wire [63:0] qsfp_txd_1_int;
wire [7:0]  qsfp_txc_1_int;
wire        qsfp_rx_clk_1_int;
wire        qsfp_rx_rst_1_int;
wire [63:0] qsfp_rxd_1_int;
wire [7:0]  qsfp_rxc_1_int;
wire        qsfp_tx_clk_2_int;
wire        qsfp_tx_rst_2_int;
wire [63:0] qsfp_txd_2_int;
wire [7:0]  qsfp_txc_2_int;
wire        qsfp_rx_clk_2_int;
wire        qsfp_rx_rst_2_int;
wire [63:0] qsfp_rxd_2_int;
wire [7:0]  qsfp_rxc_2_int;
wire        qsfp_tx_clk_3_int;
wire        qsfp_tx_rst_3_int;
wire [63:0] qsfp_txd_3_int;
wire [7:0]  qsfp_txc_3_int;
wire        qsfp_rx_clk_3_int;
wire        qsfp_rx_rst_3_int;
wire [63:0] qsfp_rxd_3_int;
wire [7:0]  qsfp_rxc_3_int;
wire        qsfp_tx_clk_4_int;
wire        qsfp_tx_rst_4_int;
wire [63:0] qsfp_txd_4_int;
wire [7:0]  qsfp_txc_4_int;
wire        qsfp_rx_clk_4_int;
wire        qsfp_rx_rst_4_int;
wire [63:0] qsfp_rxd_4_int;
wire [7:0]  qsfp_rxc_4_int;

assign clk_156mhz_int = qsfp_tx_clk_1_int;
assign rst_156mhz_int = qsfp_tx_rst_1_int;

wire qsfp_rx_block_lock_1;
wire qsfp_rx_block_lock_2;
wire qsfp_rx_block_lock_3;
wire qsfp_rx_block_lock_4;

wire qsfp_gtpowergood;

wire qsfp_mgt_refclk_0;
wire qsfp_mgt_refclk_0_int;
wire qsfp_mgt_refclk_0_bufg;

assign clk_161mhz_ref_int = qsfp_mgt_refclk_0_bufg;

IBUFDS_GTE4 ibufds_gte4_qsfp_mgt_refclk_0_inst (
    .I     (qsfp_mgt_refclk_0_p),
    .IB    (qsfp_mgt_refclk_0_n),
    .CEB   (1'b0),
    .O     (qsfp_mgt_refclk_0),
    .ODIV2 (qsfp_mgt_refclk_0_int)
);

BUFG_GT bufg_gt_refclk_inst (
    .CE      (qsfp_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (qsfp_mgt_refclk_0_int),
    .O       (qsfp_mgt_refclk_0_bufg)
);

eth_xcvr_phy_quad_wrapper #(
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_phy_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(qsfp_gtpowergood),

    /*
     * PLL
     */
    .xcvr_gtrefclk00_in(qsfp_mgt_refclk_0),

    /*
     * Serial data
     */
    .xcvr_txp(qsfp_tx_p),
    .xcvr_txn(qsfp_tx_n),
    .xcvr_rxp(qsfp_rx_p),
    .xcvr_rxn(qsfp_rx_n),

    /*
     * PHY connections
     */
    .phy_1_tx_clk(qsfp_tx_clk_1_int),
    .phy_1_tx_rst(qsfp_tx_rst_1_int),
    .phy_1_xgmii_txd(qsfp_txd_1_int),
    .phy_1_xgmii_txc(qsfp_txc_1_int),
    .phy_1_rx_clk(qsfp_rx_clk_1_int),
    .phy_1_rx_rst(qsfp_rx_rst_1_int),
    .phy_1_xgmii_rxd(qsfp_rxd_1_int),
    .phy_1_xgmii_rxc(qsfp_rxc_1_int),
    .phy_1_tx_bad_block(),
    .phy_1_rx_error_count(),
    .phy_1_rx_bad_block(),
    .phy_1_rx_sequence_error(),
    .phy_1_rx_block_lock(qsfp_rx_block_lock_1),
    .phy_1_rx_status(),
    .phy_1_cfg_tx_prbs31_enable(1'b0),
    .phy_1_cfg_rx_prbs31_enable(1'b0),

    .phy_2_tx_clk(qsfp_tx_clk_2_int),
    .phy_2_tx_rst(qsfp_tx_rst_2_int),
    .phy_2_xgmii_txd(qsfp_txd_2_int),
    .phy_2_xgmii_txc(qsfp_txc_2_int),
    .phy_2_rx_clk(qsfp_rx_clk_2_int),
    .phy_2_rx_rst(qsfp_rx_rst_2_int),
    .phy_2_xgmii_rxd(qsfp_rxd_2_int),
    .phy_2_xgmii_rxc(qsfp_rxc_2_int),
    .phy_2_tx_bad_block(),
    .phy_2_rx_error_count(),
    .phy_2_rx_bad_block(),
    .phy_2_rx_sequence_error(),
    .phy_2_rx_block_lock(qsfp_rx_block_lock_2),
    .phy_2_rx_status(),
    .phy_2_cfg_tx_prbs31_enable(1'b0),
    .phy_2_cfg_rx_prbs31_enable(1'b0),

    .phy_3_tx_clk(qsfp_tx_clk_3_int),
    .phy_3_tx_rst(qsfp_tx_rst_3_int),
    .phy_3_xgmii_txd(qsfp_txd_3_int),
    .phy_3_xgmii_txc(qsfp_txc_3_int),
    .phy_3_rx_clk(qsfp_rx_clk_3_int),
    .phy_3_rx_rst(qsfp_rx_rst_3_int),
    .phy_3_xgmii_rxd(qsfp_rxd_3_int),
    .phy_3_xgmii_rxc(qsfp_rxc_3_int),
    .phy_3_tx_bad_block(),
    .phy_3_rx_error_count(),
    .phy_3_rx_bad_block(),
    .phy_3_rx_sequence_error(),
    .phy_3_rx_block_lock(qsfp_rx_block_lock_3),
    .phy_3_rx_status(),
    .phy_3_cfg_tx_prbs31_enable(1'b0),
    .phy_3_cfg_rx_prbs31_enable(1'b0),

    .phy_4_tx_clk(qsfp_tx_clk_4_int),
    .phy_4_tx_rst(qsfp_tx_rst_4_int),
    .phy_4_xgmii_txd(qsfp_txd_4_int),
    .phy_4_xgmii_txc(qsfp_txc_4_int),
    .phy_4_rx_clk(qsfp_rx_clk_4_int),
    .phy_4_rx_rst(qsfp_rx_rst_4_int),
    .phy_4_xgmii_rxd(qsfp_rxd_4_int),
    .phy_4_xgmii_rxc(qsfp_rxc_4_int),
    .phy_4_tx_bad_block(),
    .phy_4_rx_error_count(),
    .phy_4_rx_bad_block(),
    .phy_4_rx_sequence_error(),
    .phy_4_rx_block_lock(qsfp_rx_block_lock_4),
    .phy_4_rx_status(),
    .phy_4_cfg_tx_prbs31_enable(1'b0),
    .phy_4_cfg_rx_prbs31_enable(1'b0)
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
     * GPIO
     */
    .qsfp_led_act(qsfp_led_act),
    .qsfp_led_stat_g(qsfp_led_stat_g),
    .qsfp_led_stat_y(qsfp_led_stat_y),
    /*
     * Ethernet: QSFP28
     */
    .qsfp_tx_clk_1(qsfp_tx_clk_1_int),
    .qsfp_tx_rst_1(qsfp_tx_rst_1_int),
    .qsfp_txd_1(qsfp_txd_1_int),
    .qsfp_txc_1(qsfp_txc_1_int),
    .qsfp_rx_clk_1(qsfp_rx_clk_1_int),
    .qsfp_rx_rst_1(qsfp_rx_rst_1_int),
    .qsfp_rxd_1(qsfp_rxd_1_int),
    .qsfp_rxc_1(qsfp_rxc_1_int),
    .qsfp_tx_clk_2(qsfp_tx_clk_2_int),
    .qsfp_tx_rst_2(qsfp_tx_rst_2_int),
    .qsfp_txd_2(qsfp_txd_2_int),
    .qsfp_txc_2(qsfp_txc_2_int),
    .qsfp_rx_clk_2(qsfp_rx_clk_2_int),
    .qsfp_rx_rst_2(qsfp_rx_rst_2_int),
    .qsfp_rxd_2(qsfp_rxd_2_int),
    .qsfp_rxc_2(qsfp_rxc_2_int),
    .qsfp_tx_clk_3(qsfp_tx_clk_3_int),
    .qsfp_tx_rst_3(qsfp_tx_rst_3_int),
    .qsfp_txd_3(qsfp_txd_3_int),
    .qsfp_txc_3(qsfp_txc_3_int),
    .qsfp_rx_clk_3(qsfp_rx_clk_3_int),
    .qsfp_rx_rst_3(qsfp_rx_rst_3_int),
    .qsfp_rxd_3(qsfp_rxd_3_int),
    .qsfp_rxc_3(qsfp_rxc_3_int),
    .qsfp_tx_clk_4(qsfp_tx_clk_4_int),
    .qsfp_tx_rst_4(qsfp_tx_rst_4_int),
    .qsfp_txd_4(qsfp_txd_4_int),
    .qsfp_txc_4(qsfp_txc_4_int),
    .qsfp_rx_clk_4(qsfp_rx_clk_4_int),
    .qsfp_rx_rst_4(qsfp_rx_rst_4_int),
    .qsfp_rxd_4(qsfp_rxd_4_int),
    .qsfp_rxc_4(qsfp_rxc_4_int)
);

endmodule

`resetall
