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
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 200 MHz LVDS
     */
    input  wire       ref_clk_p,
    input  wire       ref_clk_n,

    input  wire       clk_gty2_lol_n,

    /*
     * GPIO
     */
    input  wire [1:0] btn,
    input  wire [7:0] sw,
    output wire [7:0] led,

    /*
     * I2C for board management
     */
    inout  wire       i2c_main_scl,
    inout  wire       i2c_main_sda,
    output wire       i2c_main_rst_n,

    /*
     * UART: 115200 bps, 8N1
     */
    output wire       uart_rxd,
    input  wire       uart_txd,
    input  wire       uart_rts,
    output wire       uart_cts,
    output wire       uart_rst_n,
    output wire       uart_suspend_n,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0] qsfp_1_tx_p,
    output wire [3:0] qsfp_1_tx_n,
    input  wire [3:0] qsfp_1_rx_p,
    input  wire [3:0] qsfp_1_rx_n,
    input  wire       qsfp_1_mgt_refclk_p,
    input  wire       qsfp_1_mgt_refclk_n,
    output wire       qsfp_1_resetl,
    input  wire       qsfp_1_modprsl,
    input  wire       qsfp_1_intl,

    output wire [3:0] qsfp_2_tx_p,
    output wire [3:0] qsfp_2_tx_n,
    input  wire [3:0] qsfp_2_rx_p,
    input  wire [3:0] qsfp_2_rx_n,
    input  wire       qsfp_2_mgt_refclk_p,
    input  wire       qsfp_2_mgt_refclk_n,
    output wire       qsfp_2_resetl,
    input  wire       qsfp_2_modprsl,
    input  wire       qsfp_2_intl,

    output wire [3:0] qsfp_3_tx_p,
    output wire [3:0] qsfp_3_tx_n,
    input  wire [3:0] qsfp_3_rx_p,
    input  wire [3:0] qsfp_3_rx_n,
    input  wire       qsfp_3_mgt_refclk_p,
    input  wire       qsfp_3_mgt_refclk_n,
    output wire       qsfp_3_resetl,
    input  wire       qsfp_3_modprsl,
    input  wire       qsfp_3_intl,

    output wire [3:0] qsfp_4_tx_p,
    output wire [3:0] qsfp_4_tx_n,
    input  wire [3:0] qsfp_4_rx_p,
    input  wire [3:0] qsfp_4_rx_n,
    input  wire       qsfp_4_mgt_refclk_p,
    input  wire       qsfp_4_mgt_refclk_n,
    output wire       qsfp_4_resetl,
    input  wire       qsfp_4_modprsl,
    input  wire       qsfp_4_intl,

    output wire [3:0] qsfp_5_tx_p,
    output wire [3:0] qsfp_5_tx_n,
    input  wire [3:0] qsfp_5_rx_p,
    input  wire [3:0] qsfp_5_rx_n,
    input  wire       qsfp_5_mgt_refclk_p,
    input  wire       qsfp_5_mgt_refclk_n,
    output wire       qsfp_5_resetl,
    input  wire       qsfp_5_modprsl,
    input  wire       qsfp_5_intl,

    output wire [3:0] qsfp_6_tx_p,
    output wire [3:0] qsfp_6_tx_n,
    input  wire [3:0] qsfp_6_rx_p,
    input  wire [3:0] qsfp_6_rx_n,
    input  wire       qsfp_6_mgt_refclk_p,
    input  wire       qsfp_6_mgt_refclk_n,
    output wire       qsfp_6_resetl,
    input  wire       qsfp_6_modprsl,
    input  wire       qsfp_6_intl,

    output wire [3:0] qsfp_7_tx_p,
    output wire [3:0] qsfp_7_tx_n,
    input  wire [3:0] qsfp_7_rx_p,
    input  wire [3:0] qsfp_7_rx_n,
    input  wire       qsfp_7_mgt_refclk_p,
    input  wire       qsfp_7_mgt_refclk_n,
    output wire       qsfp_7_resetl,
    input  wire       qsfp_7_modprsl,
    input  wire       qsfp_7_intl,

    output wire [3:0] qsfp_8_tx_p,
    output wire [3:0] qsfp_8_tx_n,
    input  wire [3:0] qsfp_8_rx_p,
    input  wire [3:0] qsfp_8_rx_n,
    input  wire       qsfp_8_mgt_refclk_p,
    input  wire       qsfp_8_mgt_refclk_n,
    output wire       qsfp_8_resetl,
    input  wire       qsfp_8_modprsl,
    input  wire       qsfp_8_intl,

    output wire [3:0] qsfp_9_tx_p,
    output wire [3:0] qsfp_9_tx_n,
    input  wire [3:0] qsfp_9_rx_p,
    input  wire [3:0] qsfp_9_rx_n,
    input  wire       qsfp_9_mgt_refclk_p,
    input  wire       qsfp_9_mgt_refclk_n,
    output wire       qsfp_9_resetl,
    input  wire       qsfp_9_modprsl,
    input  wire       qsfp_9_intl
);

// Clock and reset

wire ref_clk_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = ~btn[0];
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
ref_clk_ibufg_inst (
   .O   (ref_clk_ibufg),
   .I   (ref_clk_p),
   .IB  (ref_clk_n) 
);

// MMCM instance
// 200 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 5, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME4_BASE #(
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
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(5.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(ref_clk_ibufg),
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
wire btn_int;
wire [7:0] sw_int;

debounce_switch #(
    .WIDTH(9),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({btn[1],
        sw}),
    .out({btn_int,
        sw_int})
);

wire uart_txd_int;
wire uart_rts_int;

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_125mhz_int),
    .in({uart_txd, uart_rts}),
    .out({uart_txd_int, uart_rts_int})
);

wire i2c_scl_i;
wire i2c_scl_o;
wire i2c_scl_t;
wire i2c_sda_i;
wire i2c_sda_o;
wire i2c_sda_t;

assign i2c_scl_i = i2c_main_scl;
assign i2c_main_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_main_sda;
assign i2c_main_sda = i2c_sda_t ? 1'bz : i2c_sda_o;
assign i2c_main_rst_n = 1'b1;

// Si5341 init
wire [6:0] si5341_i2c_cmd_address;
wire si5341_i2c_cmd_start;
wire si5341_i2c_cmd_read;
wire si5341_i2c_cmd_write;
wire si5341_i2c_cmd_write_multiple;
wire si5341_i2c_cmd_stop;
wire si5341_i2c_cmd_valid;
wire si5341_i2c_cmd_ready;

wire [7:0] si5341_i2c_data_tdata;
wire si5341_i2c_data_tvalid;
wire si5341_i2c_data_tready;
wire si5341_i2c_data_tlast;

wire si5341_i2c_busy;

i2c_master
si5341_i2c_master_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .s_axis_cmd_address(si5341_i2c_cmd_address),
    .s_axis_cmd_start(si5341_i2c_cmd_start),
    .s_axis_cmd_read(si5341_i2c_cmd_read),
    .s_axis_cmd_write(si5341_i2c_cmd_write),
    .s_axis_cmd_write_multiple(si5341_i2c_cmd_write_multiple),
    .s_axis_cmd_stop(si5341_i2c_cmd_stop),
    .s_axis_cmd_valid(si5341_i2c_cmd_valid),
    .s_axis_cmd_ready(si5341_i2c_cmd_ready),
    .s_axis_data_tdata(si5341_i2c_data_tdata),
    .s_axis_data_tvalid(si5341_i2c_data_tvalid),
    .s_axis_data_tready(si5341_i2c_data_tready),
    .s_axis_data_tlast(si5341_i2c_data_tlast),
    .m_axis_data_tdata(),
    .m_axis_data_tvalid(),
    .m_axis_data_tready(1'b1),
    .m_axis_data_tlast(),
    .scl_i(i2c_scl_i),
    .scl_o(i2c_scl_o),
    .scl_t(i2c_scl_t),
    .sda_i(i2c_sda_i),
    .sda_o(i2c_sda_o),
    .sda_t(i2c_sda_t),
    .busy(),
    .bus_control(),
    .bus_active(),
    .missed_ack(),
    .prescale(312),
    .stop_on_idle(1)
);

si5341_i2c_init
si5341_i2c_init_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .m_axis_cmd_address(si5341_i2c_cmd_address),
    .m_axis_cmd_start(si5341_i2c_cmd_start),
    .m_axis_cmd_read(si5341_i2c_cmd_read),
    .m_axis_cmd_write(si5341_i2c_cmd_write),
    .m_axis_cmd_write_multiple(si5341_i2c_cmd_write_multiple),
    .m_axis_cmd_stop(si5341_i2c_cmd_stop),
    .m_axis_cmd_valid(si5341_i2c_cmd_valid),
    .m_axis_cmd_ready(si5341_i2c_cmd_ready),
    .m_axis_data_tdata(si5341_i2c_data_tdata),
    .m_axis_data_tvalid(si5341_i2c_data_tvalid),
    .m_axis_data_tready(si5341_i2c_data_tready),
    .m_axis_data_tlast(si5341_i2c_data_tlast),
    .busy(si5341_i2c_busy),
    .start(1'b1)
);

// XGMII 10G PHY
wire qsfp_reset = rst_125mhz_int || si5341_i2c_busy || !clk_gty2_lol_n;

// QSFP 1
assign qsfp_1_resetl = 1'b1;

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
wire        qsfp_1_tx_clk_4_int;
wire        qsfp_1_tx_rst_4_int;
wire [63:0] qsfp_1_txd_4_int;
wire [7:0]  qsfp_1_txc_4_int;
wire        qsfp_1_rx_clk_4_int;
wire        qsfp_1_rx_rst_4_int;
wire [63:0] qsfp_1_rxd_4_int;
wire [7:0]  qsfp_1_rxc_4_int;

assign clk_156mhz_int = qsfp_1_tx_clk_1_int;
assign rst_156mhz_int = qsfp_1_tx_rst_1_int;

wire qsfp_1_rx_block_lock_1;
wire qsfp_1_rx_block_lock_2;
wire qsfp_1_rx_block_lock_3;
wire qsfp_1_rx_block_lock_4;

wire qsfp_1_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_1_mgt_refclk_inst (
    .I             (qsfp_1_mgt_refclk_p),
    .IB            (qsfp_1_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_1_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_1_qpll0lock;
wire qsfp_1_qpll0outclk;
wire qsfp_1_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_1_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

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
    .xcvr_txp(qsfp_1_tx_p[0]),
    .xcvr_txn(qsfp_1_tx_n[0]),
    .xcvr_rxp(qsfp_1_rx_p[0]),
    .xcvr_rxn(qsfp_1_rx_n[0]),

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
    .HAS_COMMON(0)
)
qsfp_1_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

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
    .xcvr_txp(qsfp_1_tx_p[1]),
    .xcvr_txn(qsfp_1_tx_n[1]),
    .xcvr_rxp(qsfp_1_rx_p[1]),
    .xcvr_rxn(qsfp_1_rx_n[1]),

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
    .HAS_COMMON(0)
)
qsfp_1_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

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
    .xcvr_txp(qsfp_1_tx_p[2]),
    .xcvr_txn(qsfp_1_tx_n[2]),
    .xcvr_rxp(qsfp_1_rx_p[2]),
    .xcvr_rxn(qsfp_1_rx_n[2]),

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

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_1_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

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
    .xcvr_txp(qsfp_1_tx_p[3]),
    .xcvr_txn(qsfp_1_tx_n[3]),
    .xcvr_rxp(qsfp_1_rx_p[3]),
    .xcvr_rxn(qsfp_1_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_1_tx_clk_4_int),
    .phy_tx_rst(qsfp_1_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_1_txd_4_int),
    .phy_xgmii_txc(qsfp_1_txc_4_int),
    .phy_rx_clk(qsfp_1_rx_clk_4_int),
    .phy_rx_rst(qsfp_1_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_1_rxd_4_int),
    .phy_xgmii_rxc(qsfp_1_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_1_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 2
assign qsfp_2_resetl = 1'b1;

wire        qsfp_2_tx_clk_1_int;
wire        qsfp_2_tx_rst_1_int;
wire [63:0] qsfp_2_txd_1_int;
wire [7:0]  qsfp_2_txc_1_int;
wire        qsfp_2_rx_clk_1_int;
wire        qsfp_2_rx_rst_1_int;
wire [63:0] qsfp_2_rxd_1_int;
wire [7:0]  qsfp_2_rxc_1_int;
wire        qsfp_2_tx_clk_2_int;
wire        qsfp_2_tx_rst_2_int;
wire [63:0] qsfp_2_txd_2_int;
wire [7:0]  qsfp_2_txc_2_int;
wire        qsfp_2_rx_clk_2_int;
wire        qsfp_2_rx_rst_2_int;
wire [63:0] qsfp_2_rxd_2_int;
wire [7:0]  qsfp_2_rxc_2_int;
wire        qsfp_2_tx_clk_3_int;
wire        qsfp_2_tx_rst_3_int;
wire [63:0] qsfp_2_txd_3_int;
wire [7:0]  qsfp_2_txc_3_int;
wire        qsfp_2_rx_clk_3_int;
wire        qsfp_2_rx_rst_3_int;
wire [63:0] qsfp_2_rxd_3_int;
wire [7:0]  qsfp_2_rxc_3_int;
wire        qsfp_2_tx_clk_4_int;
wire        qsfp_2_tx_rst_4_int;
wire [63:0] qsfp_2_txd_4_int;
wire [7:0]  qsfp_2_txc_4_int;
wire        qsfp_2_rx_clk_4_int;
wire        qsfp_2_rx_rst_4_int;
wire [63:0] qsfp_2_rxd_4_int;
wire [7:0]  qsfp_2_rxc_4_int;

wire qsfp_2_rx_block_lock_1;
wire qsfp_2_rx_block_lock_2;
wire qsfp_2_rx_block_lock_3;
wire qsfp_2_rx_block_lock_4;

wire qsfp_2_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_2_mgt_refclk_inst (
    .I             (qsfp_2_mgt_refclk_p),
    .IB            (qsfp_2_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_2_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_2_qpll0lock;
wire qsfp_2_qpll0outclk;
wire qsfp_2_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_2_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_2_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_2_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_2_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_2_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_2_tx_p[0]),
    .xcvr_txn(qsfp_2_tx_n[0]),
    .xcvr_rxp(qsfp_2_rx_p[0]),
    .xcvr_rxn(qsfp_2_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_2_tx_clk_1_int),
    .phy_tx_rst(qsfp_2_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_2_txd_1_int),
    .phy_xgmii_txc(qsfp_2_txc_1_int),
    .phy_rx_clk(qsfp_2_rx_clk_1_int),
    .phy_rx_rst(qsfp_2_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_2_rxd_1_int),
    .phy_xgmii_rxc(qsfp_2_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_2_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_2_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_2_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_2_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_2_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_2_tx_p[1]),
    .xcvr_txn(qsfp_2_tx_n[1]),
    .xcvr_rxp(qsfp_2_rx_p[1]),
    .xcvr_rxn(qsfp_2_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_2_tx_clk_2_int),
    .phy_tx_rst(qsfp_2_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_2_txd_2_int),
    .phy_xgmii_txc(qsfp_2_txc_2_int),
    .phy_rx_clk(qsfp_2_rx_clk_2_int),
    .phy_rx_rst(qsfp_2_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_2_rxd_2_int),
    .phy_xgmii_rxc(qsfp_2_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_2_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_2_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_2_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_2_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_2_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_2_tx_p[2]),
    .xcvr_txn(qsfp_2_tx_n[2]),
    .xcvr_rxp(qsfp_2_rx_p[2]),
    .xcvr_rxn(qsfp_2_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_2_tx_clk_3_int),
    .phy_tx_rst(qsfp_2_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_2_txd_3_int),
    .phy_xgmii_txc(qsfp_2_txc_3_int),
    .phy_rx_clk(qsfp_2_rx_clk_3_int),
    .phy_rx_rst(qsfp_2_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_2_rxd_3_int),
    .phy_xgmii_rxc(qsfp_2_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_2_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_2_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_2_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_2_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_2_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_2_tx_p[3]),
    .xcvr_txn(qsfp_2_tx_n[3]),
    .xcvr_rxp(qsfp_2_rx_p[3]),
    .xcvr_rxn(qsfp_2_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_2_tx_clk_4_int),
    .phy_tx_rst(qsfp_2_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_2_txd_4_int),
    .phy_xgmii_txc(qsfp_2_txc_4_int),
    .phy_rx_clk(qsfp_2_rx_clk_4_int),
    .phy_rx_rst(qsfp_2_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_2_rxd_4_int),
    .phy_xgmii_rxc(qsfp_2_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_2_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 3
assign qsfp_3_resetl = 1'b1;

wire        qsfp_3_tx_clk_1_int;
wire        qsfp_3_tx_rst_1_int;
wire [63:0] qsfp_3_txd_1_int;
wire [7:0]  qsfp_3_txc_1_int;
wire        qsfp_3_rx_clk_1_int;
wire        qsfp_3_rx_rst_1_int;
wire [63:0] qsfp_3_rxd_1_int;
wire [7:0]  qsfp_3_rxc_1_int;
wire        qsfp_3_tx_clk_2_int;
wire        qsfp_3_tx_rst_2_int;
wire [63:0] qsfp_3_txd_2_int;
wire [7:0]  qsfp_3_txc_2_int;
wire        qsfp_3_rx_clk_2_int;
wire        qsfp_3_rx_rst_2_int;
wire [63:0] qsfp_3_rxd_2_int;
wire [7:0]  qsfp_3_rxc_2_int;
wire        qsfp_3_tx_clk_3_int;
wire        qsfp_3_tx_rst_3_int;
wire [63:0] qsfp_3_txd_3_int;
wire [7:0]  qsfp_3_txc_3_int;
wire        qsfp_3_rx_clk_3_int;
wire        qsfp_3_rx_rst_3_int;
wire [63:0] qsfp_3_rxd_3_int;
wire [7:0]  qsfp_3_rxc_3_int;
wire        qsfp_3_tx_clk_4_int;
wire        qsfp_3_tx_rst_4_int;
wire [63:0] qsfp_3_txd_4_int;
wire [7:0]  qsfp_3_txc_4_int;
wire        qsfp_3_rx_clk_4_int;
wire        qsfp_3_rx_rst_4_int;
wire [63:0] qsfp_3_rxd_4_int;
wire [7:0]  qsfp_3_rxc_4_int;

wire qsfp_3_rx_block_lock_1;
wire qsfp_3_rx_block_lock_2;
wire qsfp_3_rx_block_lock_3;
wire qsfp_3_rx_block_lock_4;

wire qsfp_3_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_3_mgt_refclk_inst (
    .I             (qsfp_3_mgt_refclk_p),
    .IB            (qsfp_3_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_3_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_3_qpll0lock;
wire qsfp_3_qpll0outclk;
wire qsfp_3_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_3_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_3_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_3_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_3_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_3_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_3_tx_p[0]),
    .xcvr_txn(qsfp_3_tx_n[0]),
    .xcvr_rxp(qsfp_3_rx_p[0]),
    .xcvr_rxn(qsfp_3_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_3_tx_clk_1_int),
    .phy_tx_rst(qsfp_3_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_3_txd_1_int),
    .phy_xgmii_txc(qsfp_3_txc_1_int),
    .phy_rx_clk(qsfp_3_rx_clk_1_int),
    .phy_rx_rst(qsfp_3_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_3_rxd_1_int),
    .phy_xgmii_rxc(qsfp_3_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_3_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_3_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_3_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_3_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_3_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_3_tx_p[1]),
    .xcvr_txn(qsfp_3_tx_n[1]),
    .xcvr_rxp(qsfp_3_rx_p[1]),
    .xcvr_rxn(qsfp_3_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_3_tx_clk_2_int),
    .phy_tx_rst(qsfp_3_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_3_txd_2_int),
    .phy_xgmii_txc(qsfp_3_txc_2_int),
    .phy_rx_clk(qsfp_3_rx_clk_2_int),
    .phy_rx_rst(qsfp_3_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_3_rxd_2_int),
    .phy_xgmii_rxc(qsfp_3_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_3_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_3_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_3_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_3_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_3_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_3_tx_p[2]),
    .xcvr_txn(qsfp_3_tx_n[2]),
    .xcvr_rxp(qsfp_3_rx_p[2]),
    .xcvr_rxn(qsfp_3_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_3_tx_clk_3_int),
    .phy_tx_rst(qsfp_3_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_3_txd_3_int),
    .phy_xgmii_txc(qsfp_3_txc_3_int),
    .phy_rx_clk(qsfp_3_rx_clk_3_int),
    .phy_rx_rst(qsfp_3_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_3_rxd_3_int),
    .phy_xgmii_rxc(qsfp_3_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_3_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_3_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_3_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_3_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_3_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_3_tx_p[3]),
    .xcvr_txn(qsfp_3_tx_n[3]),
    .xcvr_rxp(qsfp_3_rx_p[3]),
    .xcvr_rxn(qsfp_3_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_3_tx_clk_4_int),
    .phy_tx_rst(qsfp_3_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_3_txd_4_int),
    .phy_xgmii_txc(qsfp_3_txc_4_int),
    .phy_rx_clk(qsfp_3_rx_clk_4_int),
    .phy_rx_rst(qsfp_3_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_3_rxd_4_int),
    .phy_xgmii_rxc(qsfp_3_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_3_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 4
assign qsfp_4_resetl = 1'b1;

wire        qsfp_4_tx_clk_1_int;
wire        qsfp_4_tx_rst_1_int;
wire [63:0] qsfp_4_txd_1_int;
wire [7:0]  qsfp_4_txc_1_int;
wire        qsfp_4_rx_clk_1_int;
wire        qsfp_4_rx_rst_1_int;
wire [63:0] qsfp_4_rxd_1_int;
wire [7:0]  qsfp_4_rxc_1_int;
wire        qsfp_4_tx_clk_2_int;
wire        qsfp_4_tx_rst_2_int;
wire [63:0] qsfp_4_txd_2_int;
wire [7:0]  qsfp_4_txc_2_int;
wire        qsfp_4_rx_clk_2_int;
wire        qsfp_4_rx_rst_2_int;
wire [63:0] qsfp_4_rxd_2_int;
wire [7:0]  qsfp_4_rxc_2_int;
wire        qsfp_4_tx_clk_3_int;
wire        qsfp_4_tx_rst_3_int;
wire [63:0] qsfp_4_txd_3_int;
wire [7:0]  qsfp_4_txc_3_int;
wire        qsfp_4_rx_clk_3_int;
wire        qsfp_4_rx_rst_3_int;
wire [63:0] qsfp_4_rxd_3_int;
wire [7:0]  qsfp_4_rxc_3_int;
wire        qsfp_4_tx_clk_4_int;
wire        qsfp_4_tx_rst_4_int;
wire [63:0] qsfp_4_txd_4_int;
wire [7:0]  qsfp_4_txc_4_int;
wire        qsfp_4_rx_clk_4_int;
wire        qsfp_4_rx_rst_4_int;
wire [63:0] qsfp_4_rxd_4_int;
wire [7:0]  qsfp_4_rxc_4_int;

wire qsfp_4_rx_block_lock_1;
wire qsfp_4_rx_block_lock_2;
wire qsfp_4_rx_block_lock_3;
wire qsfp_4_rx_block_lock_4;

wire qsfp_4_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_4_mgt_refclk_inst (
    .I             (qsfp_4_mgt_refclk_p),
    .IB            (qsfp_4_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_4_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_4_qpll0lock;
wire qsfp_4_qpll0outclk;
wire qsfp_4_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_4_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_4_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_4_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_4_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_4_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_4_tx_p[0]),
    .xcvr_txn(qsfp_4_tx_n[0]),
    .xcvr_rxp(qsfp_4_rx_p[0]),
    .xcvr_rxn(qsfp_4_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_4_tx_clk_1_int),
    .phy_tx_rst(qsfp_4_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_4_txd_1_int),
    .phy_xgmii_txc(qsfp_4_txc_1_int),
    .phy_rx_clk(qsfp_4_rx_clk_1_int),
    .phy_rx_rst(qsfp_4_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_4_rxd_1_int),
    .phy_xgmii_rxc(qsfp_4_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_4_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_4_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_4_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_4_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_4_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_4_tx_p[1]),
    .xcvr_txn(qsfp_4_tx_n[1]),
    .xcvr_rxp(qsfp_4_rx_p[1]),
    .xcvr_rxn(qsfp_4_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_4_tx_clk_2_int),
    .phy_tx_rst(qsfp_4_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_4_txd_2_int),
    .phy_xgmii_txc(qsfp_4_txc_2_int),
    .phy_rx_clk(qsfp_4_rx_clk_2_int),
    .phy_rx_rst(qsfp_4_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_4_rxd_2_int),
    .phy_xgmii_rxc(qsfp_4_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_4_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_4_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_4_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_4_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_4_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_4_tx_p[2]),
    .xcvr_txn(qsfp_4_tx_n[2]),
    .xcvr_rxp(qsfp_4_rx_p[2]),
    .xcvr_rxn(qsfp_4_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_4_tx_clk_3_int),
    .phy_tx_rst(qsfp_4_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_4_txd_3_int),
    .phy_xgmii_txc(qsfp_4_txc_3_int),
    .phy_rx_clk(qsfp_4_rx_clk_3_int),
    .phy_rx_rst(qsfp_4_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_4_rxd_3_int),
    .phy_xgmii_rxc(qsfp_4_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_4_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_4_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_4_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_4_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_4_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_4_tx_p[3]),
    .xcvr_txn(qsfp_4_tx_n[3]),
    .xcvr_rxp(qsfp_4_rx_p[3]),
    .xcvr_rxn(qsfp_4_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_4_tx_clk_4_int),
    .phy_tx_rst(qsfp_4_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_4_txd_4_int),
    .phy_xgmii_txc(qsfp_4_txc_4_int),
    .phy_rx_clk(qsfp_4_rx_clk_4_int),
    .phy_rx_rst(qsfp_4_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_4_rxd_4_int),
    .phy_xgmii_rxc(qsfp_4_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_4_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 5
assign qsfp_5_resetl = 1'b1;

wire        qsfp_5_tx_clk_1_int;
wire        qsfp_5_tx_rst_1_int;
wire [63:0] qsfp_5_txd_1_int;
wire [7:0]  qsfp_5_txc_1_int;
wire        qsfp_5_rx_clk_1_int;
wire        qsfp_5_rx_rst_1_int;
wire [63:0] qsfp_5_rxd_1_int;
wire [7:0]  qsfp_5_rxc_1_int;
wire        qsfp_5_tx_clk_2_int;
wire        qsfp_5_tx_rst_2_int;
wire [63:0] qsfp_5_txd_2_int;
wire [7:0]  qsfp_5_txc_2_int;
wire        qsfp_5_rx_clk_2_int;
wire        qsfp_5_rx_rst_2_int;
wire [63:0] qsfp_5_rxd_2_int;
wire [7:0]  qsfp_5_rxc_2_int;
wire        qsfp_5_tx_clk_3_int;
wire        qsfp_5_tx_rst_3_int;
wire [63:0] qsfp_5_txd_3_int;
wire [7:0]  qsfp_5_txc_3_int;
wire        qsfp_5_rx_clk_3_int;
wire        qsfp_5_rx_rst_3_int;
wire [63:0] qsfp_5_rxd_3_int;
wire [7:0]  qsfp_5_rxc_3_int;
wire        qsfp_5_tx_clk_4_int;
wire        qsfp_5_tx_rst_4_int;
wire [63:0] qsfp_5_txd_4_int;
wire [7:0]  qsfp_5_txc_4_int;
wire        qsfp_5_rx_clk_4_int;
wire        qsfp_5_rx_rst_4_int;
wire [63:0] qsfp_5_rxd_4_int;
wire [7:0]  qsfp_5_rxc_4_int;

wire qsfp_5_rx_block_lock_1;
wire qsfp_5_rx_block_lock_2;
wire qsfp_5_rx_block_lock_3;
wire qsfp_5_rx_block_lock_4;

wire qsfp_5_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_5_mgt_refclk_inst (
    .I             (qsfp_5_mgt_refclk_p),
    .IB            (qsfp_5_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_5_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_5_qpll0lock;
wire qsfp_5_qpll0outclk;
wire qsfp_5_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_5_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_5_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_5_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_5_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_5_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_5_tx_p[0]),
    .xcvr_txn(qsfp_5_tx_n[0]),
    .xcvr_rxp(qsfp_5_rx_p[0]),
    .xcvr_rxn(qsfp_5_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_5_tx_clk_1_int),
    .phy_tx_rst(qsfp_5_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_5_txd_1_int),
    .phy_xgmii_txc(qsfp_5_txc_1_int),
    .phy_rx_clk(qsfp_5_rx_clk_1_int),
    .phy_rx_rst(qsfp_5_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_5_rxd_1_int),
    .phy_xgmii_rxc(qsfp_5_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_5_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_5_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_5_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_5_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_5_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_5_tx_p[1]),
    .xcvr_txn(qsfp_5_tx_n[1]),
    .xcvr_rxp(qsfp_5_rx_p[1]),
    .xcvr_rxn(qsfp_5_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_5_tx_clk_2_int),
    .phy_tx_rst(qsfp_5_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_5_txd_2_int),
    .phy_xgmii_txc(qsfp_5_txc_2_int),
    .phy_rx_clk(qsfp_5_rx_clk_2_int),
    .phy_rx_rst(qsfp_5_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_5_rxd_2_int),
    .phy_xgmii_rxc(qsfp_5_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_5_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_5_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_5_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_5_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_5_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_5_tx_p[2]),
    .xcvr_txn(qsfp_5_tx_n[2]),
    .xcvr_rxp(qsfp_5_rx_p[2]),
    .xcvr_rxn(qsfp_5_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_5_tx_clk_3_int),
    .phy_tx_rst(qsfp_5_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_5_txd_3_int),
    .phy_xgmii_txc(qsfp_5_txc_3_int),
    .phy_rx_clk(qsfp_5_rx_clk_3_int),
    .phy_rx_rst(qsfp_5_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_5_rxd_3_int),
    .phy_xgmii_rxc(qsfp_5_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_5_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_5_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_5_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_5_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_5_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_5_tx_p[3]),
    .xcvr_txn(qsfp_5_tx_n[3]),
    .xcvr_rxp(qsfp_5_rx_p[3]),
    .xcvr_rxn(qsfp_5_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_5_tx_clk_4_int),
    .phy_tx_rst(qsfp_5_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_5_txd_4_int),
    .phy_xgmii_txc(qsfp_5_txc_4_int),
    .phy_rx_clk(qsfp_5_rx_clk_4_int),
    .phy_rx_rst(qsfp_5_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_5_rxd_4_int),
    .phy_xgmii_rxc(qsfp_5_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_5_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 6
assign qsfp_6_resetl = 1'b1;

wire        qsfp_6_tx_clk_1_int;
wire        qsfp_6_tx_rst_1_int;
wire [63:0] qsfp_6_txd_1_int;
wire [7:0]  qsfp_6_txc_1_int;
wire        qsfp_6_rx_clk_1_int;
wire        qsfp_6_rx_rst_1_int;
wire [63:0] qsfp_6_rxd_1_int;
wire [7:0]  qsfp_6_rxc_1_int;
wire        qsfp_6_tx_clk_2_int;
wire        qsfp_6_tx_rst_2_int;
wire [63:0] qsfp_6_txd_2_int;
wire [7:0]  qsfp_6_txc_2_int;
wire        qsfp_6_rx_clk_2_int;
wire        qsfp_6_rx_rst_2_int;
wire [63:0] qsfp_6_rxd_2_int;
wire [7:0]  qsfp_6_rxc_2_int;
wire        qsfp_6_tx_clk_3_int;
wire        qsfp_6_tx_rst_3_int;
wire [63:0] qsfp_6_txd_3_int;
wire [7:0]  qsfp_6_txc_3_int;
wire        qsfp_6_rx_clk_3_int;
wire        qsfp_6_rx_rst_3_int;
wire [63:0] qsfp_6_rxd_3_int;
wire [7:0]  qsfp_6_rxc_3_int;
wire        qsfp_6_tx_clk_4_int;
wire        qsfp_6_tx_rst_4_int;
wire [63:0] qsfp_6_txd_4_int;
wire [7:0]  qsfp_6_txc_4_int;
wire        qsfp_6_rx_clk_4_int;
wire        qsfp_6_rx_rst_4_int;
wire [63:0] qsfp_6_rxd_4_int;
wire [7:0]  qsfp_6_rxc_4_int;

wire qsfp_6_rx_block_lock_1;
wire qsfp_6_rx_block_lock_2;
wire qsfp_6_rx_block_lock_3;
wire qsfp_6_rx_block_lock_4;

wire qsfp_6_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_6_mgt_refclk_inst (
    .I             (qsfp_6_mgt_refclk_p),
    .IB            (qsfp_6_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_6_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_6_qpll0lock;
wire qsfp_6_qpll0outclk;
wire qsfp_6_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_6_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_6_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_6_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_6_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_6_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_6_tx_p[0]),
    .xcvr_txn(qsfp_6_tx_n[0]),
    .xcvr_rxp(qsfp_6_rx_p[0]),
    .xcvr_rxn(qsfp_6_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_6_tx_clk_1_int),
    .phy_tx_rst(qsfp_6_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_6_txd_1_int),
    .phy_xgmii_txc(qsfp_6_txc_1_int),
    .phy_rx_clk(qsfp_6_rx_clk_1_int),
    .phy_rx_rst(qsfp_6_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_6_rxd_1_int),
    .phy_xgmii_rxc(qsfp_6_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_6_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_6_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_6_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_6_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_6_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_6_tx_p[1]),
    .xcvr_txn(qsfp_6_tx_n[1]),
    .xcvr_rxp(qsfp_6_rx_p[1]),
    .xcvr_rxn(qsfp_6_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_6_tx_clk_2_int),
    .phy_tx_rst(qsfp_6_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_6_txd_2_int),
    .phy_xgmii_txc(qsfp_6_txc_2_int),
    .phy_rx_clk(qsfp_6_rx_clk_2_int),
    .phy_rx_rst(qsfp_6_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_6_rxd_2_int),
    .phy_xgmii_rxc(qsfp_6_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_6_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_6_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_6_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_6_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_6_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_6_tx_p[2]),
    .xcvr_txn(qsfp_6_tx_n[2]),
    .xcvr_rxp(qsfp_6_rx_p[2]),
    .xcvr_rxn(qsfp_6_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_6_tx_clk_3_int),
    .phy_tx_rst(qsfp_6_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_6_txd_3_int),
    .phy_xgmii_txc(qsfp_6_txc_3_int),
    .phy_rx_clk(qsfp_6_rx_clk_3_int),
    .phy_rx_rst(qsfp_6_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_6_rxd_3_int),
    .phy_xgmii_rxc(qsfp_6_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_6_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_6_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_6_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_6_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_6_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_6_tx_p[3]),
    .xcvr_txn(qsfp_6_tx_n[3]),
    .xcvr_rxp(qsfp_6_rx_p[3]),
    .xcvr_rxn(qsfp_6_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_6_tx_clk_4_int),
    .phy_tx_rst(qsfp_6_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_6_txd_4_int),
    .phy_xgmii_txc(qsfp_6_txc_4_int),
    .phy_rx_clk(qsfp_6_rx_clk_4_int),
    .phy_rx_rst(qsfp_6_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_6_rxd_4_int),
    .phy_xgmii_rxc(qsfp_6_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_6_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 7
assign qsfp_7_resetl = 1'b1;

wire        qsfp_7_tx_clk_1_int;
wire        qsfp_7_tx_rst_1_int;
wire [63:0] qsfp_7_txd_1_int;
wire [7:0]  qsfp_7_txc_1_int;
wire        qsfp_7_rx_clk_1_int;
wire        qsfp_7_rx_rst_1_int;
wire [63:0] qsfp_7_rxd_1_int;
wire [7:0]  qsfp_7_rxc_1_int;
wire        qsfp_7_tx_clk_2_int;
wire        qsfp_7_tx_rst_2_int;
wire [63:0] qsfp_7_txd_2_int;
wire [7:0]  qsfp_7_txc_2_int;
wire        qsfp_7_rx_clk_2_int;
wire        qsfp_7_rx_rst_2_int;
wire [63:0] qsfp_7_rxd_2_int;
wire [7:0]  qsfp_7_rxc_2_int;
wire        qsfp_7_tx_clk_3_int;
wire        qsfp_7_tx_rst_3_int;
wire [63:0] qsfp_7_txd_3_int;
wire [7:0]  qsfp_7_txc_3_int;
wire        qsfp_7_rx_clk_3_int;
wire        qsfp_7_rx_rst_3_int;
wire [63:0] qsfp_7_rxd_3_int;
wire [7:0]  qsfp_7_rxc_3_int;
wire        qsfp_7_tx_clk_4_int;
wire        qsfp_7_tx_rst_4_int;
wire [63:0] qsfp_7_txd_4_int;
wire [7:0]  qsfp_7_txc_4_int;
wire        qsfp_7_rx_clk_4_int;
wire        qsfp_7_rx_rst_4_int;
wire [63:0] qsfp_7_rxd_4_int;
wire [7:0]  qsfp_7_rxc_4_int;

wire qsfp_7_rx_block_lock_1;
wire qsfp_7_rx_block_lock_2;
wire qsfp_7_rx_block_lock_3;
wire qsfp_7_rx_block_lock_4;

wire qsfp_7_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_7_mgt_refclk_inst (
    .I             (qsfp_7_mgt_refclk_p),
    .IB            (qsfp_7_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_7_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_7_qpll0lock;
wire qsfp_7_qpll0outclk;
wire qsfp_7_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_7_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_7_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_7_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_7_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_7_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_7_tx_p[0]),
    .xcvr_txn(qsfp_7_tx_n[0]),
    .xcvr_rxp(qsfp_7_rx_p[0]),
    .xcvr_rxn(qsfp_7_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_7_tx_clk_1_int),
    .phy_tx_rst(qsfp_7_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_7_txd_1_int),
    .phy_xgmii_txc(qsfp_7_txc_1_int),
    .phy_rx_clk(qsfp_7_rx_clk_1_int),
    .phy_rx_rst(qsfp_7_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_7_rxd_1_int),
    .phy_xgmii_rxc(qsfp_7_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_7_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_7_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_7_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_7_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_7_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_7_tx_p[1]),
    .xcvr_txn(qsfp_7_tx_n[1]),
    .xcvr_rxp(qsfp_7_rx_p[1]),
    .xcvr_rxn(qsfp_7_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_7_tx_clk_2_int),
    .phy_tx_rst(qsfp_7_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_7_txd_2_int),
    .phy_xgmii_txc(qsfp_7_txc_2_int),
    .phy_rx_clk(qsfp_7_rx_clk_2_int),
    .phy_rx_rst(qsfp_7_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_7_rxd_2_int),
    .phy_xgmii_rxc(qsfp_7_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_7_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_7_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_7_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_7_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_7_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_7_tx_p[2]),
    .xcvr_txn(qsfp_7_tx_n[2]),
    .xcvr_rxp(qsfp_7_rx_p[2]),
    .xcvr_rxn(qsfp_7_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_7_tx_clk_3_int),
    .phy_tx_rst(qsfp_7_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_7_txd_3_int),
    .phy_xgmii_txc(qsfp_7_txc_3_int),
    .phy_rx_clk(qsfp_7_rx_clk_3_int),
    .phy_rx_rst(qsfp_7_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_7_rxd_3_int),
    .phy_xgmii_rxc(qsfp_7_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_7_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_7_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_7_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_7_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_7_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_7_tx_p[3]),
    .xcvr_txn(qsfp_7_tx_n[3]),
    .xcvr_rxp(qsfp_7_rx_p[3]),
    .xcvr_rxn(qsfp_7_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_7_tx_clk_4_int),
    .phy_tx_rst(qsfp_7_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_7_txd_4_int),
    .phy_xgmii_txc(qsfp_7_txc_4_int),
    .phy_rx_clk(qsfp_7_rx_clk_4_int),
    .phy_rx_rst(qsfp_7_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_7_rxd_4_int),
    .phy_xgmii_rxc(qsfp_7_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_7_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 8
assign qsfp_8_resetl = 1'b1;

wire        qsfp_8_tx_clk_1_int;
wire        qsfp_8_tx_rst_1_int;
wire [63:0] qsfp_8_txd_1_int;
wire [7:0]  qsfp_8_txc_1_int;
wire        qsfp_8_rx_clk_1_int;
wire        qsfp_8_rx_rst_1_int;
wire [63:0] qsfp_8_rxd_1_int;
wire [7:0]  qsfp_8_rxc_1_int;
wire        qsfp_8_tx_clk_2_int;
wire        qsfp_8_tx_rst_2_int;
wire [63:0] qsfp_8_txd_2_int;
wire [7:0]  qsfp_8_txc_2_int;
wire        qsfp_8_rx_clk_2_int;
wire        qsfp_8_rx_rst_2_int;
wire [63:0] qsfp_8_rxd_2_int;
wire [7:0]  qsfp_8_rxc_2_int;
wire        qsfp_8_tx_clk_3_int;
wire        qsfp_8_tx_rst_3_int;
wire [63:0] qsfp_8_txd_3_int;
wire [7:0]  qsfp_8_txc_3_int;
wire        qsfp_8_rx_clk_3_int;
wire        qsfp_8_rx_rst_3_int;
wire [63:0] qsfp_8_rxd_3_int;
wire [7:0]  qsfp_8_rxc_3_int;
wire        qsfp_8_tx_clk_4_int;
wire        qsfp_8_tx_rst_4_int;
wire [63:0] qsfp_8_txd_4_int;
wire [7:0]  qsfp_8_txc_4_int;
wire        qsfp_8_rx_clk_4_int;
wire        qsfp_8_rx_rst_4_int;
wire [63:0] qsfp_8_rxd_4_int;
wire [7:0]  qsfp_8_rxc_4_int;

wire qsfp_8_rx_block_lock_1;
wire qsfp_8_rx_block_lock_2;
wire qsfp_8_rx_block_lock_3;
wire qsfp_8_rx_block_lock_4;

wire qsfp_8_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_8_mgt_refclk_inst (
    .I             (qsfp_8_mgt_refclk_p),
    .IB            (qsfp_8_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_8_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_8_qpll0lock;
wire qsfp_8_qpll0outclk;
wire qsfp_8_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_8_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_8_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_8_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_8_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_8_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_8_tx_p[0]),
    .xcvr_txn(qsfp_8_tx_n[0]),
    .xcvr_rxp(qsfp_8_rx_p[0]),
    .xcvr_rxn(qsfp_8_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_8_tx_clk_1_int),
    .phy_tx_rst(qsfp_8_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_8_txd_1_int),
    .phy_xgmii_txc(qsfp_8_txc_1_int),
    .phy_rx_clk(qsfp_8_rx_clk_1_int),
    .phy_rx_rst(qsfp_8_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_8_rxd_1_int),
    .phy_xgmii_rxc(qsfp_8_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_8_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_8_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_8_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_8_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_8_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_8_tx_p[1]),
    .xcvr_txn(qsfp_8_tx_n[1]),
    .xcvr_rxp(qsfp_8_rx_p[1]),
    .xcvr_rxn(qsfp_8_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_8_tx_clk_2_int),
    .phy_tx_rst(qsfp_8_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_8_txd_2_int),
    .phy_xgmii_txc(qsfp_8_txc_2_int),
    .phy_rx_clk(qsfp_8_rx_clk_2_int),
    .phy_rx_rst(qsfp_8_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_8_rxd_2_int),
    .phy_xgmii_rxc(qsfp_8_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_8_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_8_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_8_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_8_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_8_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_8_tx_p[2]),
    .xcvr_txn(qsfp_8_tx_n[2]),
    .xcvr_rxp(qsfp_8_rx_p[2]),
    .xcvr_rxn(qsfp_8_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_8_tx_clk_3_int),
    .phy_tx_rst(qsfp_8_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_8_txd_3_int),
    .phy_xgmii_txc(qsfp_8_txc_3_int),
    .phy_rx_clk(qsfp_8_rx_clk_3_int),
    .phy_rx_rst(qsfp_8_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_8_rxd_3_int),
    .phy_xgmii_rxc(qsfp_8_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_8_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_8_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_8_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_8_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_8_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_8_tx_p[3]),
    .xcvr_txn(qsfp_8_tx_n[3]),
    .xcvr_rxp(qsfp_8_rx_p[3]),
    .xcvr_rxn(qsfp_8_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_8_tx_clk_4_int),
    .phy_tx_rst(qsfp_8_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_8_txd_4_int),
    .phy_xgmii_txc(qsfp_8_txc_4_int),
    .phy_rx_clk(qsfp_8_rx_clk_4_int),
    .phy_rx_rst(qsfp_8_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_8_rxd_4_int),
    .phy_xgmii_rxc(qsfp_8_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_8_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

// QSFP 9
assign qsfp_9_resetl = 1'b1;

wire        qsfp_9_tx_clk_1_int;
wire        qsfp_9_tx_rst_1_int;
wire [63:0] qsfp_9_txd_1_int;
wire [7:0]  qsfp_9_txc_1_int;
wire        qsfp_9_rx_clk_1_int;
wire        qsfp_9_rx_rst_1_int;
wire [63:0] qsfp_9_rxd_1_int;
wire [7:0]  qsfp_9_rxc_1_int;
wire        qsfp_9_tx_clk_2_int;
wire        qsfp_9_tx_rst_2_int;
wire [63:0] qsfp_9_txd_2_int;
wire [7:0]  qsfp_9_txc_2_int;
wire        qsfp_9_rx_clk_2_int;
wire        qsfp_9_rx_rst_2_int;
wire [63:0] qsfp_9_rxd_2_int;
wire [7:0]  qsfp_9_rxc_2_int;
wire        qsfp_9_tx_clk_3_int;
wire        qsfp_9_tx_rst_3_int;
wire [63:0] qsfp_9_txd_3_int;
wire [7:0]  qsfp_9_txc_3_int;
wire        qsfp_9_rx_clk_3_int;
wire        qsfp_9_rx_rst_3_int;
wire [63:0] qsfp_9_rxd_3_int;
wire [7:0]  qsfp_9_rxc_3_int;
wire        qsfp_9_tx_clk_4_int;
wire        qsfp_9_tx_rst_4_int;
wire [63:0] qsfp_9_txd_4_int;
wire [7:0]  qsfp_9_txc_4_int;
wire        qsfp_9_rx_clk_4_int;
wire        qsfp_9_rx_rst_4_int;
wire [63:0] qsfp_9_rxd_4_int;
wire [7:0]  qsfp_9_rxc_4_int;

wire qsfp_9_rx_block_lock_1;
wire qsfp_9_rx_block_lock_2;
wire qsfp_9_rx_block_lock_3;
wire qsfp_9_rx_block_lock_4;

wire qsfp_9_mgt_refclk;

IBUFDS_GTE4 ibufds_gte4_qsfp_9_mgt_refclk_inst (
    .I             (qsfp_9_mgt_refclk_p),
    .IB            (qsfp_9_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_9_mgt_refclk),
    .ODIV2         ()
);

wire qsfp_9_qpll0lock;
wire qsfp_9_qpll0outclk;
wire qsfp_9_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
qsfp_9_phy_1_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(qsfp_9_mgt_refclk),
    .xcvr_qpll0lock_out(qsfp_9_qpll0lock),
    .xcvr_qpll0outclk_out(qsfp_9_qpll0outclk),
    .xcvr_qpll0outrefclk_out(qsfp_9_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(qsfp_9_tx_p[0]),
    .xcvr_txn(qsfp_9_tx_n[0]),
    .xcvr_rxp(qsfp_9_rx_p[0]),
    .xcvr_rxn(qsfp_9_rx_n[0]),

    // PHY connections
    .phy_tx_clk(qsfp_9_tx_clk_1_int),
    .phy_tx_rst(qsfp_9_tx_rst_1_int),
    .phy_xgmii_txd(qsfp_9_txd_1_int),
    .phy_xgmii_txc(qsfp_9_txc_1_int),
    .phy_rx_clk(qsfp_9_rx_clk_1_int),
    .phy_rx_rst(qsfp_9_rx_rst_1_int),
    .phy_xgmii_rxd(qsfp_9_rxd_1_int),
    .phy_xgmii_rxc(qsfp_9_rxc_1_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_9_rx_block_lock_1),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_9_phy_2_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_9_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_9_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_9_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_9_tx_p[1]),
    .xcvr_txn(qsfp_9_tx_n[1]),
    .xcvr_rxp(qsfp_9_rx_p[1]),
    .xcvr_rxn(qsfp_9_rx_n[1]),

    // PHY connections
    .phy_tx_clk(qsfp_9_tx_clk_2_int),
    .phy_tx_rst(qsfp_9_tx_rst_2_int),
    .phy_xgmii_txd(qsfp_9_txd_2_int),
    .phy_xgmii_txc(qsfp_9_txc_2_int),
    .phy_rx_clk(qsfp_9_rx_clk_2_int),
    .phy_rx_rst(qsfp_9_rx_rst_2_int),
    .phy_xgmii_rxd(qsfp_9_rxd_2_int),
    .phy_xgmii_rxc(qsfp_9_rxc_2_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_9_rx_block_lock_2),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_9_phy_3_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_9_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_9_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_9_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_9_tx_p[2]),
    .xcvr_txn(qsfp_9_tx_n[2]),
    .xcvr_rxp(qsfp_9_rx_p[2]),
    .xcvr_rxn(qsfp_9_rx_n[2]),

    // PHY connections
    .phy_tx_clk(qsfp_9_tx_clk_3_int),
    .phy_tx_rst(qsfp_9_tx_rst_3_int),
    .phy_xgmii_txd(qsfp_9_txd_3_int),
    .phy_xgmii_txc(qsfp_9_txc_3_int),
    .phy_rx_clk(qsfp_9_rx_clk_3_int),
    .phy_rx_rst(qsfp_9_rx_rst_3_int),
    .phy_xgmii_rxd(qsfp_9_rxd_3_int),
    .phy_xgmii_rxc(qsfp_9_rxc_3_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_9_rx_block_lock_3),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(0)
)
qsfp_9_phy_4_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(qsfp_reset),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(1'b0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0outclk_out(),
    .xcvr_qpll0outrefclk_out(),

    // PLL in
    .xcvr_qpll0lock_in(qsfp_9_qpll0lock),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(qsfp_9_qpll0outclk),
    .xcvr_qpll0refclk_in(qsfp_9_qpll0outrefclk),

    // Serial data
    .xcvr_txp(qsfp_9_tx_p[3]),
    .xcvr_txn(qsfp_9_tx_n[3]),
    .xcvr_rxp(qsfp_9_rx_p[3]),
    .xcvr_rxn(qsfp_9_rx_n[3]),

    // PHY connections
    .phy_tx_clk(qsfp_9_tx_clk_4_int),
    .phy_tx_rst(qsfp_9_tx_rst_4_int),
    .phy_xgmii_txd(qsfp_9_txd_4_int),
    .phy_xgmii_txc(qsfp_9_txc_4_int),
    .phy_rx_clk(qsfp_9_rx_clk_4_int),
    .phy_rx_rst(qsfp_9_rx_rst_4_int),
    .phy_xgmii_rxd(qsfp_9_rxd_4_int),
    .phy_xgmii_rxc(qsfp_9_rxc_4_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(qsfp_9_rx_block_lock_4),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
);

fpga_core
core_inst (
    /*
     * Clock: 156MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    /*
     * GPIO
     */
    .btn(btn_int),
    .sw(sw_int),
    .led(led),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd_int),
    .uart_rts(uart_rts_int),
    .uart_cts(uart_cts),
    .uart_rst_n(uart_rst_n),
    .uart_suspend_n(uart_suspend_n),
    /*
     * Ethernet: QSFP28
     */
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
    .qsfp_1_rxc_3(qsfp_1_rxc_3_int),
    .qsfp_1_tx_clk_4(qsfp_1_tx_clk_4_int),
    .qsfp_1_tx_rst_4(qsfp_1_tx_rst_4_int),
    .qsfp_1_txd_4(qsfp_1_txd_4_int),
    .qsfp_1_txc_4(qsfp_1_txc_4_int),
    .qsfp_1_rx_clk_4(qsfp_1_rx_clk_4_int),
    .qsfp_1_rx_rst_4(qsfp_1_rx_rst_4_int),
    .qsfp_1_rxd_4(qsfp_1_rxd_4_int),
    .qsfp_1_rxc_4(qsfp_1_rxc_4_int),
    .qsfp_2_tx_clk_1(qsfp_2_tx_clk_1_int),
    .qsfp_2_tx_rst_1(qsfp_2_tx_rst_1_int),
    .qsfp_2_txd_1(qsfp_2_txd_1_int),
    .qsfp_2_txc_1(qsfp_2_txc_1_int),
    .qsfp_2_rx_clk_1(qsfp_2_rx_clk_1_int),
    .qsfp_2_rx_rst_1(qsfp_2_rx_rst_1_int),
    .qsfp_2_rxd_1(qsfp_2_rxd_1_int),
    .qsfp_2_rxc_1(qsfp_2_rxc_1_int),
    .qsfp_2_tx_clk_2(qsfp_2_tx_clk_2_int),
    .qsfp_2_tx_rst_2(qsfp_2_tx_rst_2_int),
    .qsfp_2_txd_2(qsfp_2_txd_2_int),
    .qsfp_2_txc_2(qsfp_2_txc_2_int),
    .qsfp_2_rx_clk_2(qsfp_2_rx_clk_2_int),
    .qsfp_2_rx_rst_2(qsfp_2_rx_rst_2_int),
    .qsfp_2_rxd_2(qsfp_2_rxd_2_int),
    .qsfp_2_rxc_2(qsfp_2_rxc_2_int),
    .qsfp_2_tx_clk_3(qsfp_2_tx_clk_3_int),
    .qsfp_2_tx_rst_3(qsfp_2_tx_rst_3_int),
    .qsfp_2_txd_3(qsfp_2_txd_3_int),
    .qsfp_2_txc_3(qsfp_2_txc_3_int),
    .qsfp_2_rx_clk_3(qsfp_2_rx_clk_3_int),
    .qsfp_2_rx_rst_3(qsfp_2_rx_rst_3_int),
    .qsfp_2_rxd_3(qsfp_2_rxd_3_int),
    .qsfp_2_rxc_3(qsfp_2_rxc_3_int),
    .qsfp_2_tx_clk_4(qsfp_2_tx_clk_4_int),
    .qsfp_2_tx_rst_4(qsfp_2_tx_rst_4_int),
    .qsfp_2_txd_4(qsfp_2_txd_4_int),
    .qsfp_2_txc_4(qsfp_2_txc_4_int),
    .qsfp_2_rx_clk_4(qsfp_2_rx_clk_4_int),
    .qsfp_2_rx_rst_4(qsfp_2_rx_rst_4_int),
    .qsfp_2_rxd_4(qsfp_2_rxd_4_int),
    .qsfp_2_rxc_4(qsfp_2_rxc_4_int),
    .qsfp_3_tx_clk_1(qsfp_3_tx_clk_1_int),
    .qsfp_3_tx_rst_1(qsfp_3_tx_rst_1_int),
    .qsfp_3_txd_1(qsfp_3_txd_1_int),
    .qsfp_3_txc_1(qsfp_3_txc_1_int),
    .qsfp_3_rx_clk_1(qsfp_3_rx_clk_1_int),
    .qsfp_3_rx_rst_1(qsfp_3_rx_rst_1_int),
    .qsfp_3_rxd_1(qsfp_3_rxd_1_int),
    .qsfp_3_rxc_1(qsfp_3_rxc_1_int),
    .qsfp_3_tx_clk_2(qsfp_3_tx_clk_2_int),
    .qsfp_3_tx_rst_2(qsfp_3_tx_rst_2_int),
    .qsfp_3_txd_2(qsfp_3_txd_2_int),
    .qsfp_3_txc_2(qsfp_3_txc_2_int),
    .qsfp_3_rx_clk_2(qsfp_3_rx_clk_2_int),
    .qsfp_3_rx_rst_2(qsfp_3_rx_rst_2_int),
    .qsfp_3_rxd_2(qsfp_3_rxd_2_int),
    .qsfp_3_rxc_2(qsfp_3_rxc_2_int),
    .qsfp_3_tx_clk_3(qsfp_3_tx_clk_3_int),
    .qsfp_3_tx_rst_3(qsfp_3_tx_rst_3_int),
    .qsfp_3_txd_3(qsfp_3_txd_3_int),
    .qsfp_3_txc_3(qsfp_3_txc_3_int),
    .qsfp_3_rx_clk_3(qsfp_3_rx_clk_3_int),
    .qsfp_3_rx_rst_3(qsfp_3_rx_rst_3_int),
    .qsfp_3_rxd_3(qsfp_3_rxd_3_int),
    .qsfp_3_rxc_3(qsfp_3_rxc_3_int),
    .qsfp_3_tx_clk_4(qsfp_3_tx_clk_4_int),
    .qsfp_3_tx_rst_4(qsfp_3_tx_rst_4_int),
    .qsfp_3_txd_4(qsfp_3_txd_4_int),
    .qsfp_3_txc_4(qsfp_3_txc_4_int),
    .qsfp_3_rx_clk_4(qsfp_3_rx_clk_4_int),
    .qsfp_3_rx_rst_4(qsfp_3_rx_rst_4_int),
    .qsfp_3_rxd_4(qsfp_3_rxd_4_int),
    .qsfp_3_rxc_4(qsfp_3_rxc_4_int),
    .qsfp_4_tx_clk_1(qsfp_4_tx_clk_1_int),
    .qsfp_4_tx_rst_1(qsfp_4_tx_rst_1_int),
    .qsfp_4_txd_1(qsfp_4_txd_1_int),
    .qsfp_4_txc_1(qsfp_4_txc_1_int),
    .qsfp_4_rx_clk_1(qsfp_4_rx_clk_1_int),
    .qsfp_4_rx_rst_1(qsfp_4_rx_rst_1_int),
    .qsfp_4_rxd_1(qsfp_4_rxd_1_int),
    .qsfp_4_rxc_1(qsfp_4_rxc_1_int),
    .qsfp_4_tx_clk_2(qsfp_4_tx_clk_2_int),
    .qsfp_4_tx_rst_2(qsfp_4_tx_rst_2_int),
    .qsfp_4_txd_2(qsfp_4_txd_2_int),
    .qsfp_4_txc_2(qsfp_4_txc_2_int),
    .qsfp_4_rx_clk_2(qsfp_4_rx_clk_2_int),
    .qsfp_4_rx_rst_2(qsfp_4_rx_rst_2_int),
    .qsfp_4_rxd_2(qsfp_4_rxd_2_int),
    .qsfp_4_rxc_2(qsfp_4_rxc_2_int),
    .qsfp_4_tx_clk_3(qsfp_4_tx_clk_3_int),
    .qsfp_4_tx_rst_3(qsfp_4_tx_rst_3_int),
    .qsfp_4_txd_3(qsfp_4_txd_3_int),
    .qsfp_4_txc_3(qsfp_4_txc_3_int),
    .qsfp_4_rx_clk_3(qsfp_4_rx_clk_3_int),
    .qsfp_4_rx_rst_3(qsfp_4_rx_rst_3_int),
    .qsfp_4_rxd_3(qsfp_4_rxd_3_int),
    .qsfp_4_rxc_3(qsfp_4_rxc_3_int),
    .qsfp_4_tx_clk_4(qsfp_4_tx_clk_4_int),
    .qsfp_4_tx_rst_4(qsfp_4_tx_rst_4_int),
    .qsfp_4_txd_4(qsfp_4_txd_4_int),
    .qsfp_4_txc_4(qsfp_4_txc_4_int),
    .qsfp_4_rx_clk_4(qsfp_4_rx_clk_4_int),
    .qsfp_4_rx_rst_4(qsfp_4_rx_rst_4_int),
    .qsfp_4_rxd_4(qsfp_4_rxd_4_int),
    .qsfp_4_rxc_4(qsfp_4_rxc_4_int),
    .qsfp_5_tx_clk_1(qsfp_5_tx_clk_1_int),
    .qsfp_5_tx_rst_1(qsfp_5_tx_rst_1_int),
    .qsfp_5_txd_1(qsfp_5_txd_1_int),
    .qsfp_5_txc_1(qsfp_5_txc_1_int),
    .qsfp_5_rx_clk_1(qsfp_5_rx_clk_1_int),
    .qsfp_5_rx_rst_1(qsfp_5_rx_rst_1_int),
    .qsfp_5_rxd_1(qsfp_5_rxd_1_int),
    .qsfp_5_rxc_1(qsfp_5_rxc_1_int),
    .qsfp_5_tx_clk_2(qsfp_5_tx_clk_2_int),
    .qsfp_5_tx_rst_2(qsfp_5_tx_rst_2_int),
    .qsfp_5_txd_2(qsfp_5_txd_2_int),
    .qsfp_5_txc_2(qsfp_5_txc_2_int),
    .qsfp_5_rx_clk_2(qsfp_5_rx_clk_2_int),
    .qsfp_5_rx_rst_2(qsfp_5_rx_rst_2_int),
    .qsfp_5_rxd_2(qsfp_5_rxd_2_int),
    .qsfp_5_rxc_2(qsfp_5_rxc_2_int),
    .qsfp_5_tx_clk_3(qsfp_5_tx_clk_3_int),
    .qsfp_5_tx_rst_3(qsfp_5_tx_rst_3_int),
    .qsfp_5_txd_3(qsfp_5_txd_3_int),
    .qsfp_5_txc_3(qsfp_5_txc_3_int),
    .qsfp_5_rx_clk_3(qsfp_5_rx_clk_3_int),
    .qsfp_5_rx_rst_3(qsfp_5_rx_rst_3_int),
    .qsfp_5_rxd_3(qsfp_5_rxd_3_int),
    .qsfp_5_rxc_3(qsfp_5_rxc_3_int),
    .qsfp_5_tx_clk_4(qsfp_5_tx_clk_4_int),
    .qsfp_5_tx_rst_4(qsfp_5_tx_rst_4_int),
    .qsfp_5_txd_4(qsfp_5_txd_4_int),
    .qsfp_5_txc_4(qsfp_5_txc_4_int),
    .qsfp_5_rx_clk_4(qsfp_5_rx_clk_4_int),
    .qsfp_5_rx_rst_4(qsfp_5_rx_rst_4_int),
    .qsfp_5_rxd_4(qsfp_5_rxd_4_int),
    .qsfp_5_rxc_4(qsfp_5_rxc_4_int),
    .qsfp_6_tx_clk_1(qsfp_6_tx_clk_1_int),
    .qsfp_6_tx_rst_1(qsfp_6_tx_rst_1_int),
    .qsfp_6_txd_1(qsfp_6_txd_1_int),
    .qsfp_6_txc_1(qsfp_6_txc_1_int),
    .qsfp_6_rx_clk_1(qsfp_6_rx_clk_1_int),
    .qsfp_6_rx_rst_1(qsfp_6_rx_rst_1_int),
    .qsfp_6_rxd_1(qsfp_6_rxd_1_int),
    .qsfp_6_rxc_1(qsfp_6_rxc_1_int),
    .qsfp_6_tx_clk_2(qsfp_6_tx_clk_2_int),
    .qsfp_6_tx_rst_2(qsfp_6_tx_rst_2_int),
    .qsfp_6_txd_2(qsfp_6_txd_2_int),
    .qsfp_6_txc_2(qsfp_6_txc_2_int),
    .qsfp_6_rx_clk_2(qsfp_6_rx_clk_2_int),
    .qsfp_6_rx_rst_2(qsfp_6_rx_rst_2_int),
    .qsfp_6_rxd_2(qsfp_6_rxd_2_int),
    .qsfp_6_rxc_2(qsfp_6_rxc_2_int),
    .qsfp_6_tx_clk_3(qsfp_6_tx_clk_3_int),
    .qsfp_6_tx_rst_3(qsfp_6_tx_rst_3_int),
    .qsfp_6_txd_3(qsfp_6_txd_3_int),
    .qsfp_6_txc_3(qsfp_6_txc_3_int),
    .qsfp_6_rx_clk_3(qsfp_6_rx_clk_3_int),
    .qsfp_6_rx_rst_3(qsfp_6_rx_rst_3_int),
    .qsfp_6_rxd_3(qsfp_6_rxd_3_int),
    .qsfp_6_rxc_3(qsfp_6_rxc_3_int),
    .qsfp_6_tx_clk_4(qsfp_6_tx_clk_4_int),
    .qsfp_6_tx_rst_4(qsfp_6_tx_rst_4_int),
    .qsfp_6_txd_4(qsfp_6_txd_4_int),
    .qsfp_6_txc_4(qsfp_6_txc_4_int),
    .qsfp_6_rx_clk_4(qsfp_6_rx_clk_4_int),
    .qsfp_6_rx_rst_4(qsfp_6_rx_rst_4_int),
    .qsfp_6_rxd_4(qsfp_6_rxd_4_int),
    .qsfp_6_rxc_4(qsfp_6_rxc_4_int),
    .qsfp_7_tx_clk_1(qsfp_7_tx_clk_1_int),
    .qsfp_7_tx_rst_1(qsfp_7_tx_rst_1_int),
    .qsfp_7_txd_1(qsfp_7_txd_1_int),
    .qsfp_7_txc_1(qsfp_7_txc_1_int),
    .qsfp_7_rx_clk_1(qsfp_7_rx_clk_1_int),
    .qsfp_7_rx_rst_1(qsfp_7_rx_rst_1_int),
    .qsfp_7_rxd_1(qsfp_7_rxd_1_int),
    .qsfp_7_rxc_1(qsfp_7_rxc_1_int),
    .qsfp_7_tx_clk_2(qsfp_7_tx_clk_2_int),
    .qsfp_7_tx_rst_2(qsfp_7_tx_rst_2_int),
    .qsfp_7_txd_2(qsfp_7_txd_2_int),
    .qsfp_7_txc_2(qsfp_7_txc_2_int),
    .qsfp_7_rx_clk_2(qsfp_7_rx_clk_2_int),
    .qsfp_7_rx_rst_2(qsfp_7_rx_rst_2_int),
    .qsfp_7_rxd_2(qsfp_7_rxd_2_int),
    .qsfp_7_rxc_2(qsfp_7_rxc_2_int),
    .qsfp_7_tx_clk_3(qsfp_7_tx_clk_3_int),
    .qsfp_7_tx_rst_3(qsfp_7_tx_rst_3_int),
    .qsfp_7_txd_3(qsfp_7_txd_3_int),
    .qsfp_7_txc_3(qsfp_7_txc_3_int),
    .qsfp_7_rx_clk_3(qsfp_7_rx_clk_3_int),
    .qsfp_7_rx_rst_3(qsfp_7_rx_rst_3_int),
    .qsfp_7_rxd_3(qsfp_7_rxd_3_int),
    .qsfp_7_rxc_3(qsfp_7_rxc_3_int),
    .qsfp_7_tx_clk_4(qsfp_7_tx_clk_4_int),
    .qsfp_7_tx_rst_4(qsfp_7_tx_rst_4_int),
    .qsfp_7_txd_4(qsfp_7_txd_4_int),
    .qsfp_7_txc_4(qsfp_7_txc_4_int),
    .qsfp_7_rx_clk_4(qsfp_7_rx_clk_4_int),
    .qsfp_7_rx_rst_4(qsfp_7_rx_rst_4_int),
    .qsfp_7_rxd_4(qsfp_7_rxd_4_int),
    .qsfp_7_rxc_4(qsfp_7_rxc_4_int),
    .qsfp_8_tx_clk_1(qsfp_8_tx_clk_1_int),
    .qsfp_8_tx_rst_1(qsfp_8_tx_rst_1_int),
    .qsfp_8_txd_1(qsfp_8_txd_1_int),
    .qsfp_8_txc_1(qsfp_8_txc_1_int),
    .qsfp_8_rx_clk_1(qsfp_8_rx_clk_1_int),
    .qsfp_8_rx_rst_1(qsfp_8_rx_rst_1_int),
    .qsfp_8_rxd_1(qsfp_8_rxd_1_int),
    .qsfp_8_rxc_1(qsfp_8_rxc_1_int),
    .qsfp_8_tx_clk_2(qsfp_8_tx_clk_2_int),
    .qsfp_8_tx_rst_2(qsfp_8_tx_rst_2_int),
    .qsfp_8_txd_2(qsfp_8_txd_2_int),
    .qsfp_8_txc_2(qsfp_8_txc_2_int),
    .qsfp_8_rx_clk_2(qsfp_8_rx_clk_2_int),
    .qsfp_8_rx_rst_2(qsfp_8_rx_rst_2_int),
    .qsfp_8_rxd_2(qsfp_8_rxd_2_int),
    .qsfp_8_rxc_2(qsfp_8_rxc_2_int),
    .qsfp_8_tx_clk_3(qsfp_8_tx_clk_3_int),
    .qsfp_8_tx_rst_3(qsfp_8_tx_rst_3_int),
    .qsfp_8_txd_3(qsfp_8_txd_3_int),
    .qsfp_8_txc_3(qsfp_8_txc_3_int),
    .qsfp_8_rx_clk_3(qsfp_8_rx_clk_3_int),
    .qsfp_8_rx_rst_3(qsfp_8_rx_rst_3_int),
    .qsfp_8_rxd_3(qsfp_8_rxd_3_int),
    .qsfp_8_rxc_3(qsfp_8_rxc_3_int),
    .qsfp_8_tx_clk_4(qsfp_8_tx_clk_4_int),
    .qsfp_8_tx_rst_4(qsfp_8_tx_rst_4_int),
    .qsfp_8_txd_4(qsfp_8_txd_4_int),
    .qsfp_8_txc_4(qsfp_8_txc_4_int),
    .qsfp_8_rx_clk_4(qsfp_8_rx_clk_4_int),
    .qsfp_8_rx_rst_4(qsfp_8_rx_rst_4_int),
    .qsfp_8_rxd_4(qsfp_8_rxd_4_int),
    .qsfp_8_rxc_4(qsfp_8_rxc_4_int),
    .qsfp_9_tx_clk_1(qsfp_9_tx_clk_1_int),
    .qsfp_9_tx_rst_1(qsfp_9_tx_rst_1_int),
    .qsfp_9_txd_1(qsfp_9_txd_1_int),
    .qsfp_9_txc_1(qsfp_9_txc_1_int),
    .qsfp_9_rx_clk_1(qsfp_9_rx_clk_1_int),
    .qsfp_9_rx_rst_1(qsfp_9_rx_rst_1_int),
    .qsfp_9_rxd_1(qsfp_9_rxd_1_int),
    .qsfp_9_rxc_1(qsfp_9_rxc_1_int),
    .qsfp_9_tx_clk_2(qsfp_9_tx_clk_2_int),
    .qsfp_9_tx_rst_2(qsfp_9_tx_rst_2_int),
    .qsfp_9_txd_2(qsfp_9_txd_2_int),
    .qsfp_9_txc_2(qsfp_9_txc_2_int),
    .qsfp_9_rx_clk_2(qsfp_9_rx_clk_2_int),
    .qsfp_9_rx_rst_2(qsfp_9_rx_rst_2_int),
    .qsfp_9_rxd_2(qsfp_9_rxd_2_int),
    .qsfp_9_rxc_2(qsfp_9_rxc_2_int),
    .qsfp_9_tx_clk_3(qsfp_9_tx_clk_3_int),
    .qsfp_9_tx_rst_3(qsfp_9_tx_rst_3_int),
    .qsfp_9_txd_3(qsfp_9_txd_3_int),
    .qsfp_9_txc_3(qsfp_9_txc_3_int),
    .qsfp_9_rx_clk_3(qsfp_9_rx_clk_3_int),
    .qsfp_9_rx_rst_3(qsfp_9_rx_rst_3_int),
    .qsfp_9_rxd_3(qsfp_9_rxd_3_int),
    .qsfp_9_rxc_3(qsfp_9_rxc_3_int),
    .qsfp_9_tx_clk_4(qsfp_9_tx_clk_4_int),
    .qsfp_9_tx_rst_4(qsfp_9_tx_rst_4_int),
    .qsfp_9_txd_4(qsfp_9_txd_4_int),
    .qsfp_9_txc_4(qsfp_9_txc_4_int),
    .qsfp_9_rx_clk_4(qsfp_9_rx_clk_4_int),
    .qsfp_9_rx_rst_4(qsfp_9_rx_rst_4_int),
    .qsfp_9_rxd_4(qsfp_9_rxd_4_int),
    .qsfp_9_rxc_4(qsfp_9_rxc_4_int)
);

endmodule

`resetall
