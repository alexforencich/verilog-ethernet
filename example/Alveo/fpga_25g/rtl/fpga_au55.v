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
module fpga #
(
    parameter QSFP_CNT = 2,
    parameter UART_CNT = 3
)
(
    /*
     * Reset: Push button, active low
     */
    input  wire                 reset,

    /*
     * GPIO
     */
    output wire [QSFP_CNT-1:0]  qsfp_led_act,
    output wire [QSFP_CNT-1:0]  qsfp_led_stat_g,
    output wire [QSFP_CNT-1:0]  qsfp_led_stat_y,
    output wire                 hbm_cattrip,

    /*
     * UART
     */
    output wire [UART_CNT-1:0]  uart_txd,
    input  wire [UART_CNT-1:0]  uart_rxd,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0]           qsfp0_tx_p,
    output wire [3:0]           qsfp0_tx_n,
    input  wire [3:0]           qsfp0_rx_p,
    input  wire [3:0]           qsfp0_rx_n,
    input  wire                 qsfp0_mgt_refclk_p,
    input  wire                 qsfp0_mgt_refclk_n,

    output wire [3:0]           qsfp1_tx_p,
    output wire [3:0]           qsfp1_tx_n,
    input  wire [3:0]           qsfp1_rx_p,
    input  wire [3:0]           qsfp1_rx_n,
    input  wire                 qsfp1_mgt_refclk_p,
    input  wire                 qsfp1_mgt_refclk_n
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
localparam CH_CNT = QSFP_CNT*4;

wire [CH_CNT-1:0]     eth_tx_clk;
wire [CH_CNT-1:0]     eth_tx_rst;
wire [CH_CNT*64-1:0]  eth_txd;
wire [CH_CNT*8-1:0]   eth_txc;
wire [CH_CNT-1:0]     eth_rx_clk;
wire [CH_CNT-1:0]     eth_rx_rst;
wire [CH_CNT*64-1:0]  eth_rxd;
wire [CH_CNT*8-1:0]   eth_rxc;

assign clk_156mhz_int = eth_tx_clk[0];
assign rst_156mhz_int = eth_tx_rst[0];

// QSFP0
wire qsfp0_rx_block_lock_1;
wire qsfp0_rx_block_lock_2;
wire qsfp0_rx_block_lock_3;
wire qsfp0_rx_block_lock_4;

wire qsfp0_gtpowergood;

wire qsfp0_mgt_refclk;
wire qsfp0_mgt_refclk_int;
wire qsfp0_mgt_refclk_bufg;

assign clk_161mhz_ref_int = qsfp0_mgt_refclk_bufg;

IBUFDS_GTE4 ibufds_gte4_qsfp0_mgt_refclk_inst (
    .I     (qsfp0_mgt_refclk_p),
    .IB    (qsfp0_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (qsfp0_mgt_refclk),
    .ODIV2 (qsfp0_mgt_refclk_int)
);

BUFG_GT bufg_gt_refclk_inst (
    .CE      (qsfp0_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (qsfp0_mgt_refclk_int),
    .O       (qsfp0_mgt_refclk_bufg)
);

eth_xcvr_phy_quad_wrapper #(
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp0_phy_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(qsfp0_gtpowergood),

    /*
     * PLL
     */
    .xcvr_gtrefclk00_in(qsfp0_mgt_refclk),

    /*
     * Serial data
     */
    .xcvr_txp(qsfp0_tx_p),
    .xcvr_txn(qsfp0_tx_n),
    .xcvr_rxp(qsfp0_rx_p),
    .xcvr_rxn(qsfp0_rx_n),

    /*
     * PHY connections
     */
    .phy_1_tx_clk(eth_tx_clk[0*4+0 +: 1]),
    .phy_1_tx_rst(eth_tx_rst[0*4+0 +: 1]),
    .phy_1_xgmii_txd(eth_txd[(0*4+0)*64 +: 64]),
    .phy_1_xgmii_txc(eth_txc[(0*4+0)*8 +: 8]),
    .phy_1_rx_clk(eth_rx_clk[0*4+0 +: 1]),
    .phy_1_rx_rst(eth_rx_rst[0*4+0 +: 1]),
    .phy_1_xgmii_rxd(eth_rxd[(0*4+0)*64 +: 64]),
    .phy_1_xgmii_rxc(eth_rxc[(0*4+0)*8 +: 8]),
    .phy_1_tx_bad_block(),
    .phy_1_rx_error_count(),
    .phy_1_rx_bad_block(),
    .phy_1_rx_sequence_error(),
    .phy_1_rx_block_lock(qsfp0_rx_block_lock_1),
    .phy_1_rx_status(),
    .phy_1_cfg_tx_prbs31_enable(1'b0),
    .phy_1_cfg_rx_prbs31_enable(1'b0),

    .phy_2_tx_clk(eth_tx_clk[0*4+1 +: 1]),
    .phy_2_tx_rst(eth_tx_rst[0*4+1 +: 1]),
    .phy_2_xgmii_txd(eth_txd[(0*4+1)*64 +: 64]),
    .phy_2_xgmii_txc(eth_txc[(0*4+1)*8 +: 8]),
    .phy_2_rx_clk(eth_rx_clk[0*4+1 +: 1]),
    .phy_2_rx_rst(eth_rx_rst[0*4+1 +: 1]),
    .phy_2_xgmii_rxd(eth_rxd[(0*4+1)*64 +: 64]),
    .phy_2_xgmii_rxc(eth_rxc[(0*4+1)*8 +: 8]),
    .phy_2_tx_bad_block(),
    .phy_2_rx_error_count(),
    .phy_2_rx_bad_block(),
    .phy_2_rx_sequence_error(),
    .phy_2_rx_block_lock(qsfp0_rx_block_lock_2),
    .phy_2_rx_status(),
    .phy_2_cfg_tx_prbs31_enable(1'b0),
    .phy_2_cfg_rx_prbs31_enable(1'b0),

    .phy_3_tx_clk(eth_tx_clk[0*4+2 +: 1]),
    .phy_3_tx_rst(eth_tx_rst[0*4+2 +: 1]),
    .phy_3_xgmii_txd(eth_txd[(0*4+2)*64 +: 64]),
    .phy_3_xgmii_txc(eth_txc[(0*4+2)*8 +: 8]),
    .phy_3_rx_clk(eth_rx_clk[0*4+2 +: 1]),
    .phy_3_rx_rst(eth_rx_rst[0*4+2 +: 1]),
    .phy_3_xgmii_rxd(eth_rxd[(0*4+2)*64 +: 64]),
    .phy_3_xgmii_rxc(eth_rxc[(0*4+2)*8 +: 8]),
    .phy_3_tx_bad_block(),
    .phy_3_rx_error_count(),
    .phy_3_rx_bad_block(),
    .phy_3_rx_sequence_error(),
    .phy_3_rx_block_lock(qsfp0_rx_block_lock_3),
    .phy_3_rx_status(),
    .phy_3_cfg_tx_prbs31_enable(1'b0),
    .phy_3_cfg_rx_prbs31_enable(1'b0),

    .phy_4_tx_clk(eth_tx_clk[0*4+3 +: 1]),
    .phy_4_tx_rst(eth_tx_rst[0*4+3 +: 1]),
    .phy_4_xgmii_txd(eth_txd[(0*4+3)*64 +: 64]),
    .phy_4_xgmii_txc(eth_txc[(0*4+3)*8 +: 8]),
    .phy_4_rx_clk(eth_rx_clk[0*4+3 +: 1]),
    .phy_4_rx_rst(eth_rx_rst[0*4+3 +: 1]),
    .phy_4_xgmii_rxd(eth_rxd[(0*4+3)*64 +: 64]),
    .phy_4_xgmii_rxc(eth_rxc[(0*4+3)*8 +: 8]),
    .phy_4_tx_bad_block(),
    .phy_4_rx_error_count(),
    .phy_4_rx_bad_block(),
    .phy_4_rx_sequence_error(),
    .phy_4_rx_block_lock(qsfp0_rx_block_lock_4),
    .phy_4_rx_status(),
    .phy_4_cfg_tx_prbs31_enable(1'b0),
    .phy_4_cfg_rx_prbs31_enable(1'b0)
);

// QSFP1
wire qsfp1_rx_block_lock_1;
wire qsfp1_rx_block_lock_2;
wire qsfp1_rx_block_lock_3;
wire qsfp1_rx_block_lock_4;

wire qsfp1_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp1_mgt_refclk_inst (
    .I     (qsfp1_mgt_refclk_p),
    .IB    (qsfp1_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (qsfp1_mgt_refclk),
    .ODIV2 ()
);

eth_xcvr_phy_quad_wrapper #(
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp1_phy_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(),

    /*
     * PLL
     */
    .xcvr_gtrefclk00_in(qsfp1_mgt_refclk),

    /*
     * Serial data
     */
    .xcvr_txp(qsfp1_tx_p),
    .xcvr_txn(qsfp1_tx_n),
    .xcvr_rxp(qsfp1_rx_p),
    .xcvr_rxn(qsfp1_rx_n),

    /*
     * PHY connections
     */
    .phy_1_tx_clk(eth_tx_clk[1*4+0 +: 1]),
    .phy_1_tx_rst(eth_tx_rst[1*4+0 +: 1]),
    .phy_1_xgmii_txd(eth_txd[(1*4+0)*64 +: 64]),
    .phy_1_xgmii_txc(eth_txc[(1*4+0)*8 +: 8]),
    .phy_1_rx_clk(eth_rx_clk[1*4+0 +: 1]),
    .phy_1_rx_rst(eth_rx_rst[1*4+0 +: 1]),
    .phy_1_xgmii_rxd(eth_rxd[(1*4+0)*64 +: 64]),
    .phy_1_xgmii_rxc(eth_rxc[(1*4+0)*8 +: 8]),
    .phy_1_tx_bad_block(),
    .phy_1_rx_error_count(),
    .phy_1_rx_bad_block(),
    .phy_1_rx_sequence_error(),
    .phy_1_rx_block_lock(qsfp1_rx_block_lock_1),
    .phy_1_rx_status(),
    .phy_1_cfg_tx_prbs31_enable(1'b0),
    .phy_1_cfg_rx_prbs31_enable(1'b0),

    .phy_2_tx_clk(eth_tx_clk[1*4+1 +: 1]),
    .phy_2_tx_rst(eth_tx_rst[1*4+1 +: 1]),
    .phy_2_xgmii_txd(eth_txd[(1*4+1)*64 +: 64]),
    .phy_2_xgmii_txc(eth_txc[(1*4+1)*8 +: 8]),
    .phy_2_rx_clk(eth_rx_clk[1*4+1 +: 1]),
    .phy_2_rx_rst(eth_rx_rst[1*4+1 +: 1]),
    .phy_2_xgmii_rxd(eth_rxd[(1*4+1)*64 +: 64]),
    .phy_2_xgmii_rxc(eth_rxc[(1*4+1)*8 +: 8]),
    .phy_2_tx_bad_block(),
    .phy_2_rx_error_count(),
    .phy_2_rx_bad_block(),
    .phy_2_rx_sequence_error(),
    .phy_2_rx_block_lock(qsfp1_rx_block_lock_2),
    .phy_2_rx_status(),
    .phy_2_cfg_tx_prbs31_enable(1'b0),
    .phy_2_cfg_rx_prbs31_enable(1'b0),

    .phy_3_tx_clk(eth_tx_clk[1*4+2 +: 1]),
    .phy_3_tx_rst(eth_tx_rst[1*4+2 +: 1]),
    .phy_3_xgmii_txd(eth_txd[(1*4+2)*64 +: 64]),
    .phy_3_xgmii_txc(eth_txc[(1*4+2)*8 +: 8]),
    .phy_3_rx_clk(eth_rx_clk[1*4+2 +: 1]),
    .phy_3_rx_rst(eth_rx_rst[1*4+2 +: 1]),
    .phy_3_xgmii_rxd(eth_rxd[(1*4+2)*64 +: 64]),
    .phy_3_xgmii_rxc(eth_rxc[(1*4+2)*8 +: 8]),
    .phy_3_tx_bad_block(),
    .phy_3_rx_error_count(),
    .phy_3_rx_bad_block(),
    .phy_3_rx_sequence_error(),
    .phy_3_rx_block_lock(qsfp1_rx_block_lock_3),
    .phy_3_rx_status(),
    .phy_3_cfg_tx_prbs31_enable(1'b0),
    .phy_3_cfg_rx_prbs31_enable(1'b0),

    .phy_4_tx_clk(eth_tx_clk[1*4+3 +: 1]),
    .phy_4_tx_rst(eth_tx_rst[1*4+3 +: 1]),
    .phy_4_xgmii_txd(eth_txd[(1*4+3)*64 +: 64]),
    .phy_4_xgmii_txc(eth_txc[(1*4+3)*8 +: 8]),
    .phy_4_rx_clk(eth_rx_clk[1*4+3 +: 1]),
    .phy_4_rx_rst(eth_rx_rst[1*4+3 +: 1]),
    .phy_4_xgmii_rxd(eth_rxd[(1*4+3)*64 +: 64]),
    .phy_4_xgmii_rxc(eth_rxc[(1*4+3)*8 +: 8]),
    .phy_4_tx_bad_block(),
    .phy_4_rx_error_count(),
    .phy_4_rx_bad_block(),
    .phy_4_rx_sequence_error(),
    .phy_4_rx_block_lock(qsfp1_rx_block_lock_4),
    .phy_4_rx_status(),
    .phy_4_cfg_tx_prbs31_enable(1'b0),
    .phy_4_cfg_rx_prbs31_enable(1'b0)
);

fpga_core #(
    .UART_CNT(UART_CNT),
    .QSFP_CNT(QSFP_CNT),
    .CH_CNT(CH_CNT)
)
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
    .sw(0),
    .led(),
    .qsfp_led_act(qsfp_led_act),
    .qsfp_led_stat_g(qsfp_led_stat_g),
    .qsfp_led_stat_y(qsfp_led_stat_y),

    /*
     * UART
     */
    .uart_txd(uart_txd),
    .uart_rxd(uart_rxd),

    /*
     * Ethernet: QSFP28
     */
    .eth_tx_clk(eth_tx_clk),
    .eth_tx_rst(eth_tx_rst),
    .eth_txd(eth_txd),
    .eth_txc(eth_txc),
    .eth_rx_clk(eth_rx_clk),
    .eth_rx_rst(eth_rx_rst),
    .eth_rxd(eth_rxd),
    .eth_rxc(eth_rxc)
);

endmodule

`resetall
