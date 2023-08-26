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
     * Clock: 100MHz LVDS
     */
    input  wire       clk_100mhz_p,
    input  wire       clk_100mhz_n,

    /*
     * GPIO
     */
    output wire [1:0] sfp_1_led,
    output wire [1:0] sfp_2_led,
    output wire [1:0] sma_led,

    /*
     * Ethernet: SFP+
     */
    input  wire       sfp_1_rx_p,
    input  wire       sfp_1_rx_n,
    output wire       sfp_1_tx_p,
    output wire       sfp_1_tx_n,
    input  wire       sfp_2_rx_p,
    input  wire       sfp_2_rx_n,
    output wire       sfp_2_tx_p,
    output wire       sfp_2_tx_n,
    input  wire       sfp_mgt_refclk_p,
    input  wire       sfp_mgt_refclk_n,
    output wire       sfp_1_tx_disable,
    output wire       sfp_2_tx_disable,
    input  wire       sfp_1_npres,
    input  wire       sfp_2_npres,
    input  wire       sfp_1_los,
    input  wire       sfp_2_los,
    output wire       sfp_1_rs,
    output wire       sfp_2_rs
);

// Clock and reset

wire clk_100mhz_ibufg;

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

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_100mhz_ibufg_inst (
   .O   (clk_100mhz_ibufg),
   .I   (clk_100mhz_p),
   .IB  (clk_100mhz_n) 
);

// MMCM instance
// 100 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 600 MHz to 1440 MHz
// M = 10, D = 1 sets Fvco = 1000 MHz (in range)
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
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_100mhz_ibufg),
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
wire [1:0] sfp_1_led_int;
wire [1:0] sfp_2_led_int;
wire [1:0] sma_led_int;

// XGMII 10G PHY

assign sfp_1_tx_disable = 1'b0;
assign sfp_2_tx_disable = 1'b0;
assign sfp_1_rs = 1'b1;
assign sfp_2_rs = 1'b1;

wire        sfp_1_tx_clk_int;
wire        sfp_1_tx_rst_int;
wire [63:0] sfp_1_txd_int;
wire [7:0]  sfp_1_txc_int;
wire        sfp_1_rx_clk_int;
wire        sfp_1_rx_rst_int;
wire [63:0] sfp_1_rxd_int;
wire [7:0]  sfp_1_rxc_int;
wire        sfp_2_tx_clk_int;
wire        sfp_2_tx_rst_int;
wire [63:0] sfp_2_txd_int;
wire [7:0]  sfp_2_txc_int;
wire        sfp_2_rx_clk_int;
wire        sfp_2_rx_rst_int;
wire [63:0] sfp_2_rxd_int;
wire [7:0]  sfp_2_rxc_int;

assign clk_156mhz_int = sfp_1_tx_clk_int;
assign rst_156mhz_int = sfp_1_tx_rst_int;

wire sfp_1_rx_block_lock;
wire sfp_2_rx_block_lock;

wire sfp_mgt_refclk;

IBUFDS_GTE3 ibufds_gte3_sfp_mgt_refclk_inst (
    .I     (sfp_mgt_refclk_p),
    .IB    (sfp_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (sfp_mgt_refclk),
    .ODIV2 ()
);

eth_xcvr_phy_quad_wrapper #(
    .COUNT(2)
)
sfp_phy_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(),

    /*
     * PLL
     */
    .xcvr_gtrefclk00_in(sfp_mgt_refclk),

    /*
     * Serial data
     */
    .xcvr_txp({sfp_2_tx_p, sfp_1_tx_p}),
    .xcvr_txn({sfp_2_tx_n, sfp_1_tx_n}),
    .xcvr_rxp({sfp_2_rx_p, sfp_1_rx_p}),
    .xcvr_rxn({sfp_2_rx_n, sfp_1_rx_n}),

    /*
     * PHY connections
     */
    .phy_1_tx_clk(sfp_1_tx_clk_int),
    .phy_1_tx_rst(sfp_1_tx_rst_int),
    .phy_1_xgmii_txd(sfp_1_txd_int),
    .phy_1_xgmii_txc(sfp_1_txc_int),
    .phy_1_rx_clk(sfp_1_rx_clk_int),
    .phy_1_rx_rst(sfp_1_rx_rst_int),
    .phy_1_xgmii_rxd(sfp_1_rxd_int),
    .phy_1_xgmii_rxc(sfp_1_rxc_int),
    .phy_1_tx_bad_block(),
    .phy_1_rx_error_count(),
    .phy_1_rx_bad_block(),
    .phy_1_rx_sequence_error(),
    .phy_1_rx_block_lock(sfp_1_rx_block_lock),
    .phy_1_rx_status(),
    .phy_1_cfg_tx_prbs31_enable(1'b0),
    .phy_1_cfg_rx_prbs31_enable(1'b0),

    .phy_2_tx_clk(sfp_2_tx_clk_int),
    .phy_2_tx_rst(sfp_2_tx_rst_int),
    .phy_2_xgmii_txd(sfp_2_txd_int),
    .phy_2_xgmii_txc(sfp_2_txc_int),
    .phy_2_rx_clk(sfp_2_rx_clk_int),
    .phy_2_rx_rst(sfp_2_rx_rst_int),
    .phy_2_xgmii_rxd(sfp_2_rxd_int),
    .phy_2_xgmii_rxc(sfp_2_rxc_int),
    .phy_2_tx_bad_block(),
    .phy_2_rx_error_count(),
    .phy_2_rx_bad_block(),
    .phy_2_rx_sequence_error(),
    .phy_2_rx_block_lock(sfp_2_rx_block_lock),
    .phy_2_rx_status(),
    .phy_2_cfg_tx_prbs31_enable(1'b0),
    .phy_2_cfg_rx_prbs31_enable(1'b0)
);

assign sfp_1_led[0] = sfp_1_rx_block_lock;
assign sfp_1_led[1] = 1'b0;
assign sfp_2_led[0] = sfp_2_rx_block_lock;
assign sfp_2_led[1] = 1'b0;
assign sma_led = sma_led_int;

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
    .sfp_1_led(sfp_1_led_int),
    .sfp_2_led(sfp_2_led_int),
    .sma_led(sma_led_int),
    /*
     * Ethernet: SFP+
     */
    .sfp_1_tx_clk(sfp_1_tx_clk_int),
    .sfp_1_tx_rst(sfp_1_tx_rst_int),
    .sfp_1_txd(sfp_1_txd_int),
    .sfp_1_txc(sfp_1_txc_int),
    .sfp_1_rx_clk(sfp_1_rx_clk_int),
    .sfp_1_rx_rst(sfp_1_rx_rst_int),
    .sfp_1_rxd(sfp_1_rxd_int),
    .sfp_1_rxc(sfp_1_rxc_int),
    .sfp_2_tx_clk(sfp_2_tx_clk_int),
    .sfp_2_tx_rst(sfp_2_tx_rst_int),
    .sfp_2_txd(sfp_2_txd_int),
    .sfp_2_txc(sfp_2_txc_int),
    .sfp_2_rx_clk(sfp_2_rx_clk_int),
    .sfp_2_rx_rst(sfp_2_rx_rst_int),
    .sfp_2_rxd(sfp_2_rxd_int),
    .sfp_2_rxc(sfp_2_rxc_int)
);

endmodule

`resetall
