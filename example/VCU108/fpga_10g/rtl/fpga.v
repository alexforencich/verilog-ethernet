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
     * Clock: 125MHz LVDS
     * Reset: Push button, active low
     */
    input  wire       clk_125mhz_p,
    input  wire       clk_125mhz_n,
    input  wire       reset,

    /*
     * GPIO
     */
    input  wire       btnu,
    input  wire       btnl,
    input  wire       btnd,
    input  wire       btnr,
    input  wire       btnc,
    input  wire [3:0] sw,
    output wire [7:0] led,

    /*
     * I2C for board management
     */
    inout  wire       i2c_scl,
    inout  wire       i2c_sda,

    /*
     * Ethernet: QSFP28
     */
    input  wire       qsfp_rx1_p,
    input  wire       qsfp_rx1_n,
    input  wire       qsfp_rx2_p,
    input  wire       qsfp_rx2_n,
    input  wire       qsfp_rx3_p,
    input  wire       qsfp_rx3_n,
    input  wire       qsfp_rx4_p,
    input  wire       qsfp_rx4_n,
    output wire       qsfp_tx1_p,
    output wire       qsfp_tx1_n,
    output wire       qsfp_tx2_p,
    output wire       qsfp_tx2_n,
    output wire       qsfp_tx3_p,
    output wire       qsfp_tx3_n,
    output wire       qsfp_tx4_p,
    output wire       qsfp_tx4_n,
    input  wire       qsfp_mgt_refclk_0_p,
    input  wire       qsfp_mgt_refclk_0_n,
    // input  wire       qsfp_mgt_refclk_1_p,
    // input  wire       qsfp_mgt_refclk_1_n,
    // output wire       qsfp_recclk_p,
    // output wire       qsfp_recclk_n,
    output wire       qsfp_modsell,
    output wire       qsfp_resetl,
    input  wire       qsfp_modprsl,
    input  wire       qsfp_intl,
    output wire       qsfp_lpmode,

    /*
     * Ethernet: 1000BASE-T SGMII
     */
    input  wire       phy_sgmii_rx_p,
    input  wire       phy_sgmii_rx_n,
    output wire       phy_sgmii_tx_p,
    output wire       phy_sgmii_tx_n,
    input  wire       phy_sgmii_clk_p,
    input  wire       phy_sgmii_clk_n,
    output wire       phy_reset_n,
    input  wire       phy_int_n,

    /*
     * UART: 500000 bps, 8N1
     */
    input  wire       uart_rxd,
    output wire       uart_txd,
    output wire       uart_rts,
    input  wire       uart_cts
);

// Clock and reset

wire clk_125mhz_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_125mhz_ibufg_inst (
   .O   (clk_125mhz_ibufg),
   .I   (clk_125mhz_p),
   .IB  (clk_125mhz_n) 
);

// MMCM instance
// 125 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 600 MHz to 1440 MHz
// M = 5, D = 1 sets Fvco = 625 MHz (in range)
// Divide by 5 to get output frequency of 125 MHz
MMCME3_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(5),
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
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(8.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_125mhz_ibufg),
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
wire btnu_int;
wire btnl_int;
wire btnd_int;
wire btnr_int;
wire btnc_int;
wire [3:0] sw_int;

debounce_switch #(
    .WIDTH(9),
    .N(4),
    .RATE(156000)
)
debounce_switch_inst (
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    .in({btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw}),
    .out({btnu_int,
        btnl_int,
        btnd_int,
        btnr_int,
        btnc_int,
        sw_int})
);

wire uart_rxd_int;
wire uart_cts_int;

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_156mhz_int),
    .in({uart_rxd, uart_cts}),
    .out({uart_rxd_int, uart_cts_int})
);

// SI570 I2C
wire i2c_scl_i;
wire i2c_scl_o = 1'b1;
wire i2c_scl_t = 1'b1;
wire i2c_sda_i;
wire i2c_sda_o = 1'b1;
wire i2c_sda_t = 1'b1;

assign i2c_scl_i = i2c_scl;
assign i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_sda;
assign i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

// XGMII 10G PHY
assign qsfp_modsell = 1'b0;
assign qsfp_resetl = 1'b1;
assign qsfp_lpmode = 1'b0;

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

wire qsfp_mgt_refclk_0;

IBUFDS_GTE3 ibufds_gte3_qsfp_mgt_refclk_0_inst (
    .I     (qsfp_mgt_refclk_0_p),
    .IB    (qsfp_mgt_refclk_0_n),
    .CEB   (1'b0),
    .O     (qsfp_mgt_refclk_0),
    .ODIV2 ()
);

wire qsfp_qpll0lock;
wire qsfp_qpll0outclk;
wire qsfp_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_mgt_refclk_0),
    .xcvr_qpll0lock_out(qsfp_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_tx1_p),
    .xcvr_txn(qsfp_tx1_n),
    .xcvr_rxp(qsfp_rx1_p),
    .xcvr_rxn(qsfp_rx1_n),

    // PHY connections
    .phy_tx_clk(qsfp_tx_clk_1_int),
    .phy_tx_rst(qsfp_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_txd_1_int),
    .phy_xgmii_txc(qsfp_txc_1_int),
    .phy_rx_clk(qsfp_rx_clk_1_int),
    .phy_rx_rst(qsfp_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_rxd_1_int),
    .phy_xgmii_rxc(qsfp_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_phy_2_inst (
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
    .xcvr_qpll0lock_in(qsfp_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_tx2_p),
    .xcvr_txn(qsfp_tx2_n),
    .xcvr_rxp(qsfp_rx2_p),
    .xcvr_rxn(qsfp_rx2_n),

    // PHY connections
    .phy_tx_clk(qsfp_tx_clk_2_int),
    .phy_tx_rst(qsfp_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_txd_2_int),
    .phy_xgmii_txc(qsfp_txc_2_int),
    .phy_rx_clk(qsfp_rx_clk_2_int),
    .phy_rx_rst(qsfp_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_rxd_2_int),
    .phy_xgmii_rxc(qsfp_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_phy_3_inst (
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
    .xcvr_qpll0lock_in(qsfp_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_tx3_p),
    .xcvr_txn(qsfp_tx3_n),
    .xcvr_rxp(qsfp_rx3_p),
    .xcvr_rxn(qsfp_rx3_n),

    // PHY connections
    .phy_tx_clk(qsfp_tx_clk_3_int),
    .phy_tx_rst(qsfp_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_txd_3_int),
    .phy_xgmii_txc(qsfp_txc_3_int),
    .phy_rx_clk(qsfp_rx_clk_3_int),
    .phy_rx_rst(qsfp_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_rxd_3_int),
    .phy_xgmii_rxc(qsfp_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_phy_4_inst (
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
    .xcvr_qpll0lock_in(qsfp_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_tx4_p),
    .xcvr_txn(qsfp_tx4_n),
    .xcvr_rxp(qsfp_rx4_p),
    .xcvr_rxn(qsfp_rx4_n),

    // PHY connections
    .phy_tx_clk(qsfp_tx_clk_4_int),
    .phy_tx_rst(qsfp_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_txd_4_int),
    .phy_xgmii_txc(qsfp_txc_4_int),
    .phy_rx_clk(qsfp_rx_clk_4_int),
    .phy_rx_rst(qsfp_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_rxd_4_int),
    .phy_xgmii_rxc(qsfp_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// SGMII interface to PHY
wire phy_gmii_clk_int;
wire phy_gmii_rst_int;
wire phy_gmii_clk_en_int;
wire [7:0] phy_gmii_txd_int;
wire phy_gmii_tx_en_int;
wire phy_gmii_tx_er_int;
wire [7:0] phy_gmii_rxd_int;
wire phy_gmii_rx_dv_int;
wire phy_gmii_rx_er_int;

wire [15:0] gig_eth_pcspma_status_vector;

wire gig_eth_pcspma_status_link_status              = gig_eth_pcspma_status_vector[0];
wire gig_eth_pcspma_status_link_synchronization     = gig_eth_pcspma_status_vector[1];
wire gig_eth_pcspma_status_rudi_c                   = gig_eth_pcspma_status_vector[2];
wire gig_eth_pcspma_status_rudi_i                   = gig_eth_pcspma_status_vector[3];
wire gig_eth_pcspma_status_rudi_invalid             = gig_eth_pcspma_status_vector[4];
wire gig_eth_pcspma_status_rxdisperr                = gig_eth_pcspma_status_vector[5];
wire gig_eth_pcspma_status_rxnotintable             = gig_eth_pcspma_status_vector[6];
wire gig_eth_pcspma_status_phy_link_status          = gig_eth_pcspma_status_vector[7];
wire [1:0] gig_eth_pcspma_status_remote_fault_encdg = gig_eth_pcspma_status_vector[9:8];
wire [1:0] gig_eth_pcspma_status_speed              = gig_eth_pcspma_status_vector[11:10];
wire gig_eth_pcspma_status_duplex                   = gig_eth_pcspma_status_vector[12];
wire gig_eth_pcspma_status_remote_fault             = gig_eth_pcspma_status_vector[13];
wire [1:0] gig_eth_pcspma_status_pause              = gig_eth_pcspma_status_vector[15:14];

wire [4:0] gig_eth_pcspma_config_vector;

assign gig_eth_pcspma_config_vector[4] = 1'b1; // autonegotiation enable
assign gig_eth_pcspma_config_vector[3] = 1'b0; // isolate
assign gig_eth_pcspma_config_vector[2] = 1'b0; // power down
assign gig_eth_pcspma_config_vector[1] = 1'b0; // loopback enable
assign gig_eth_pcspma_config_vector[0] = 1'b0; // unidirectional enable

wire [15:0] gig_eth_pcspma_an_config_vector;

assign gig_eth_pcspma_an_config_vector[15]    = 1'b1;    // SGMII link status
assign gig_eth_pcspma_an_config_vector[14]    = 1'b1;    // SGMII Acknowledge
assign gig_eth_pcspma_an_config_vector[13:12] = 2'b01;   // full duplex
assign gig_eth_pcspma_an_config_vector[11:10] = 2'b10;   // SGMII speed
assign gig_eth_pcspma_an_config_vector[9]     = 1'b0;    // reserved
assign gig_eth_pcspma_an_config_vector[8:7]   = 2'b00;   // pause frames - SGMII reserved
assign gig_eth_pcspma_an_config_vector[6]     = 1'b0;    // reserved
assign gig_eth_pcspma_an_config_vector[5]     = 1'b0;    // full duplex - SGMII reserved
assign gig_eth_pcspma_an_config_vector[4:1]   = 4'b0000; // reserved
assign gig_eth_pcspma_an_config_vector[0]     = 1'b1;    // SGMII

gig_ethernet_pcs_pma_0
gig_eth_pcspma (
    // SGMII
    .txp                    (phy_sgmii_tx_p),
    .txn                    (phy_sgmii_tx_n),
    .rxp                    (phy_sgmii_rx_p),
    .rxn                    (phy_sgmii_rx_n),

    // Ref clock from PHY
    .refclk625_p            (phy_sgmii_clk_p),
    .refclk625_n            (phy_sgmii_clk_n),

    // async reset
    .reset                  (rst_125mhz_int),

    // clock and reset outputs
    .clk125_out             (phy_gmii_clk_int),
    .clk625_out             (),
    .clk312_out             (),
    .rst_125_out            (phy_gmii_rst_int),
    .idelay_rdy_out         (),
    .mmcm_locked_out        (),

    // MAC clocking
    .sgmii_clk_r            (),
    .sgmii_clk_f            (),
    .sgmii_clk_en           (phy_gmii_clk_en_int),
    
    // Speed control
    .speed_is_10_100        (gig_eth_pcspma_status_speed != 2'b10),
    .speed_is_100           (gig_eth_pcspma_status_speed == 2'b01),

    // Internal GMII
    .gmii_txd               (phy_gmii_txd_int),
    .gmii_tx_en             (phy_gmii_tx_en_int),
    .gmii_tx_er             (phy_gmii_tx_er_int),
    .gmii_rxd               (phy_gmii_rxd_int),
    .gmii_rx_dv             (phy_gmii_rx_dv_int),
    .gmii_rx_er             (phy_gmii_rx_er_int),
    .gmii_isolate           (),

    // Configuration
    .configuration_vector   (gig_eth_pcspma_config_vector),

    .an_interrupt           (),
    .an_adv_config_vector   (gig_eth_pcspma_an_config_vector),
    .an_restart_config      (1'b0),

    // Status
    .status_vector          (gig_eth_pcspma_status_vector),
    .signal_detect          (1'b1)
);

wire [7:0] led_int;

assign led[0] = sw[0] ? qsfp_rx_block_lock_1 : led_int[0];
assign led[1] = sw[0] ? qsfp_rx_block_lock_2 : led_int[1];
assign led[2] = sw[0] ? qsfp_rx_block_lock_3 : led_int[2];
assign led[3] = sw[0] ? qsfp_rx_block_lock_4 : led_int[3];
assign led[4] = sw[0] ? 1'b0 : led_int[4];
assign led[5] = sw[0] ? 1'b0 : led_int[5];
assign led[6] = sw[0] ? 1'b0 : led_int[6];
assign led[7] = sw[0] ? 1'b0 : led_int[7];

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
    .btnu(btnu_int),
    .btnl(btnl_int),
    .btnd(btnd_int),
    .btnr(btnr_int),
    .btnc(btnc_int),
    .sw(sw_int),
    .led(led_int),
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
    .qsfp_rxc_4(qsfp_rxc_4_int),
    /*
     * Ethernet: 1000BASE-T SGMII
     */
    .phy_gmii_clk(phy_gmii_clk_int),
    .phy_gmii_rst(phy_gmii_rst_int),
    .phy_gmii_clk_en(phy_gmii_clk_en_int),
    .phy_gmii_rxd(phy_gmii_rxd_int),
    .phy_gmii_rx_dv(phy_gmii_rx_dv_int),
    .phy_gmii_rx_er(phy_gmii_rx_er_int),
    .phy_gmii_txd(phy_gmii_txd_int),
    .phy_gmii_tx_en(phy_gmii_tx_en_int),
    .phy_gmii_tx_er(phy_gmii_tx_er_int),
    .phy_reset_n(phy_reset_n),
    .phy_int_n(phy_int_n),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts_int)
);

endmodule

`resetall
