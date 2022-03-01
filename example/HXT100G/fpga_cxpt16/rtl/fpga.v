/*

Copyright (c) 2016-2018 Alex Forencich

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
`timescale 1 ns / 1 ps
`default_nettype none

module fpga (
    /*
     * Clock: 50MHz
     */
    input  wire sys_clk,
    /*
     * Clock: 200MHz
     */
    //input  wire clk_ddr3_p,
    //input  wire clk_ddr3_n,
    /*
     * Clock: User
     */
    //input  wire clk_usr_p,
    //input  wire clk_usr_pr_n,
    /*
     * Reset: Push button, active low
     */
    input  wire reset_n,
    /*
     * GPIO
     */
    input  wire [1:0] sw,
    input  wire [3:0] jp,
    output wire [3:0] led,
    /*
     * Silicon Labs CP2102 USB UART
     */
    output wire uart_rst,
    input  wire uart_suspend,
    output wire uart_ri,
    output wire uart_dcd,
    input  wire uart_dtr,
    output wire uart_dsr,
    input  wire uart_txd,
    output wire uart_rxd,
    input  wire uart_rts,
    output wire uart_cts,
    /*
     * Clock muxes
     */
    inout  wire clk_gth_scl,
    inout  wire clk_gth_sda,
    output wire clk_gth_rst_n,
    input  wire clk_gthl_alm,
    input  wire clk_gthl_lol,
    input  wire clk_gthr_alm,
    input  wire clk_gthr_lol,
    /*
     * AirMax I/O
     */
    output wire amh_right_mdc,
    inout  wire amh_right_mdio,
    output wire amh_right_phy_rst_n,
    output wire amh_left_mdc,
    inout  wire amh_left_mdio,
    output wire amh_left_phy_rst_n,
    /*
     * 10G Ethernet
     */
    input  wire gth_quad_A_refclk_p,
    input  wire gth_quad_A_refclk_n,
    output wire gth_quad_A_txp_0,
    output wire gth_quad_A_txn_0,
    input  wire gth_quad_A_rxp_0,
    input  wire gth_quad_A_rxn_0,
    output wire gth_quad_A_txp_1,
    output wire gth_quad_A_txn_1,
    input  wire gth_quad_A_rxp_1,
    input  wire gth_quad_A_rxn_1,
    output wire gth_quad_A_txp_2,
    output wire gth_quad_A_txn_2,
    input  wire gth_quad_A_rxp_2,
    input  wire gth_quad_A_rxn_2,
    output wire gth_quad_A_txp_3,
    output wire gth_quad_A_txn_3,
    input  wire gth_quad_A_rxp_3,
    input  wire gth_quad_A_rxn_3,
    input  wire gth_quad_B_refclk_p,
    input  wire gth_quad_B_refclk_n,
    output wire gth_quad_B_txp_0,
    output wire gth_quad_B_txn_0,
    input  wire gth_quad_B_rxp_0,
    input  wire gth_quad_B_rxn_0,
    output wire gth_quad_B_txp_1,
    output wire gth_quad_B_txn_1,
    input  wire gth_quad_B_rxp_1,
    input  wire gth_quad_B_rxn_1,
    output wire gth_quad_B_txp_2,
    output wire gth_quad_B_txn_2,
    input  wire gth_quad_B_rxp_2,
    input  wire gth_quad_B_rxn_2,
    output wire gth_quad_B_txp_3,
    output wire gth_quad_B_txn_3,
    input  wire gth_quad_B_rxp_3,
    input  wire gth_quad_B_rxn_3,
    input  wire gth_quad_C_refclk_p,
    input  wire gth_quad_C_refclk_n,
    output wire gth_quad_C_txp_0,
    output wire gth_quad_C_txn_0,
    input  wire gth_quad_C_rxp_0,
    input  wire gth_quad_C_rxn_0,
    output wire gth_quad_C_txp_1,
    output wire gth_quad_C_txn_1,
    input  wire gth_quad_C_rxp_1,
    input  wire gth_quad_C_rxn_1,
    output wire gth_quad_C_txp_2,
    output wire gth_quad_C_txn_2,
    input  wire gth_quad_C_rxp_2,
    input  wire gth_quad_C_rxn_2,
    output wire gth_quad_C_txp_3,
    output wire gth_quad_C_txn_3,
    input  wire gth_quad_C_rxp_3,
    input  wire gth_quad_C_rxn_3,
    input  wire gth_quad_D_refclk_p,
    input  wire gth_quad_D_refclk_n,
    output wire gth_quad_D_txp_0,
    output wire gth_quad_D_txn_0,
    input  wire gth_quad_D_rxp_0,
    input  wire gth_quad_D_rxn_0,
    output wire gth_quad_D_txp_1,
    output wire gth_quad_D_txn_1,
    input  wire gth_quad_D_rxp_1,
    input  wire gth_quad_D_rxn_1,
    output wire gth_quad_D_txp_2,
    output wire gth_quad_D_txn_2,
    input  wire gth_quad_D_rxp_2,
    input  wire gth_quad_D_rxn_2,
    output wire gth_quad_D_txp_3,
    output wire gth_quad_D_txn_3,
    input  wire gth_quad_D_rxp_3,
    input  wire gth_quad_D_rxn_3,
    input  wire gth_quad_E_refclk_p,
    input  wire gth_quad_E_refclk_n,
    output wire gth_quad_E_txp_0,
    output wire gth_quad_E_txn_0,
    input  wire gth_quad_E_rxp_0,
    input  wire gth_quad_E_rxn_0,
    output wire gth_quad_E_txp_1,
    output wire gth_quad_E_txn_1,
    input  wire gth_quad_E_rxp_1,
    input  wire gth_quad_E_rxn_1,
    output wire gth_quad_E_txp_2,
    output wire gth_quad_E_txn_2,
    input  wire gth_quad_E_rxp_2,
    input  wire gth_quad_E_rxn_2,
    output wire gth_quad_E_txp_3,
    output wire gth_quad_E_txn_3,
    input  wire gth_quad_E_rxp_3,
    input  wire gth_quad_E_rxn_3,
    input  wire gth_quad_F_refclk_p,
    input  wire gth_quad_F_refclk_n,
    output wire gth_quad_F_txp_0,
    output wire gth_quad_F_txn_0,
    input  wire gth_quad_F_rxp_0,
    input  wire gth_quad_F_rxn_0,
    output wire gth_quad_F_txp_1,
    output wire gth_quad_F_txn_1,
    input  wire gth_quad_F_rxp_1,
    input  wire gth_quad_F_rxn_1,
    output wire gth_quad_F_txp_2,
    output wire gth_quad_F_txn_2,
    input  wire gth_quad_F_rxp_2,
    input  wire gth_quad_F_rxn_2,
    output wire gth_quad_F_txp_3,
    output wire gth_quad_F_txn_3,
    input  wire gth_quad_F_rxp_3,
    input  wire gth_quad_F_rxn_3
);

/*
 * Clock: 50MHz
 */
wire sys_clk_ibufg;
wire sys_clk_int;

/*
 * Clock: 156.25 MHz
 */
wire clk_156mhz;

/*
 * Synchronous reset
 */
wire sys_rst;
wire rst_156mhz;

/*
 * GPIO
 */
wire [1:0] sw_int;
wire [3:0] jp_int;
wire [3:0] led_int;

/*
 * Silicon Labs CP2102 USB UART
 */
wire uart_sys_rst;
wire uart_suspend_int;
wire uart_ri_int;
wire uart_dcd_int;
wire uart_dtr_int;
wire uart_dsr_int;
wire uart_txd_int;
wire uart_rxd_int;
wire uart_rts_int;
wire uart_cts_int;

/*
 * Clock muxes
 */
wire clk_gth_scl_i;
wire clk_gth_scl_o;
wire clk_gth_scl_t;
wire clk_gth_sda_i;
wire clk_gth_sda_o;
wire clk_gth_sda_t;
wire clk_gthl_alm_int;
wire clk_gthl_lol_int;
wire clk_gthr_alm_int;
wire clk_gthr_lol_int;

/*
 * AirMax I/O
 */
wire amh_right_mdc_int;
wire amh_right_mdio_i_int;
wire amh_right_mdio_o_int;
wire amh_right_mdio_t_int;
wire amh_left_mdc_int;
wire amh_left_mdio_i_int;
wire amh_left_mdio_o_int;
wire amh_left_mdio_t_int;

/*
 * 10G Ethernet
 */
wire [63:0] eth_r0_txd;
wire [7:0]  eth_r0_txc;
wire [63:0] eth_r0_rxd;
wire [7:0]  eth_r0_rxc;
wire [63:0] eth_r1_txd;
wire [7:0]  eth_r1_txc;
wire [63:0] eth_r1_rxd;
wire [7:0]  eth_r1_rxc;
wire [63:0] eth_r2_txd;
wire [7:0]  eth_r2_txc;
wire [63:0] eth_r2_rxd;
wire [7:0]  eth_r2_rxc;
wire [63:0] eth_r3_txd;
wire [7:0]  eth_r3_txc;
wire [63:0] eth_r3_rxd;
wire [7:0]  eth_r3_rxc;
wire [63:0] eth_r4_txd;
wire [7:0]  eth_r4_txc;
wire [63:0] eth_r4_rxd;
wire [7:0]  eth_r4_rxc;
wire [63:0] eth_r5_txd;
wire [7:0]  eth_r5_txc;
wire [63:0] eth_r5_rxd;
wire [7:0]  eth_r5_rxc;
wire [63:0] eth_r6_txd;
wire [7:0]  eth_r6_txc;
wire [63:0] eth_r6_rxd;
wire [7:0]  eth_r6_rxc;
wire [63:0] eth_r7_txd;
wire [7:0]  eth_r7_txc;
wire [63:0] eth_r7_rxd;
wire [7:0]  eth_r7_rxc;
wire [63:0] eth_r8_txd;
wire [7:0]  eth_r8_txc;
wire [63:0] eth_r8_rxd;
wire [7:0]  eth_r8_rxc;
wire [63:0] eth_r9_txd;
wire [7:0]  eth_r9_txc;
wire [63:0] eth_r9_rxd;
wire [7:0]  eth_r9_rxc;
wire [63:0] eth_r10_txd;
wire [7:0]  eth_r10_txc;
wire [63:0] eth_r10_rxd;
wire [7:0]  eth_r10_rxc;
wire [63:0] eth_r11_txd;
wire [7:0]  eth_r11_txc;
wire [63:0] eth_r11_rxd;
wire [7:0]  eth_r11_rxc;
wire [63:0] eth_l0_txd;
wire [7:0]  eth_l0_txc;
wire [63:0] eth_l0_rxd;
wire [7:0]  eth_l0_rxc;
wire [63:0] eth_l1_txd;
wire [7:0]  eth_l1_txc;
wire [63:0] eth_l1_rxd;
wire [7:0]  eth_l1_rxc;
wire [63:0] eth_l2_txd;
wire [7:0]  eth_l2_txc;
wire [63:0] eth_l2_rxd;
wire [7:0]  eth_l2_rxc;
wire [63:0] eth_l3_txd;
wire [7:0]  eth_l3_txc;
wire [63:0] eth_l3_rxd;
wire [7:0]  eth_l3_rxc;
wire [63:0] eth_l4_txd;
wire [7:0]  eth_l4_txc;
wire [63:0] eth_l4_rxd;
wire [7:0]  eth_l4_rxc;
wire [63:0] eth_l5_txd;
wire [7:0]  eth_l5_txc;
wire [63:0] eth_l5_rxd;
wire [7:0]  eth_l5_rxc;
wire [63:0] eth_l6_txd;
wire [7:0]  eth_l6_txc;
wire [63:0] eth_l6_rxd;
wire [7:0]  eth_l6_rxc;
wire [63:0] eth_l7_txd;
wire [7:0]  eth_l7_txc;
wire [63:0] eth_l7_rxd;
wire [7:0]  eth_l7_rxc;
wire [63:0] eth_l8_txd;
wire [7:0]  eth_l8_txc;
wire [63:0] eth_l8_rxd;
wire [7:0]  eth_l8_rxc;
wire [63:0] eth_l9_txd;
wire [7:0]  eth_l9_txc;
wire [63:0] eth_l9_rxd;
wire [7:0]  eth_l9_rxc;
wire [63:0] eth_l10_txd;
wire [7:0]  eth_l10_txc;
wire [63:0] eth_l10_rxd;
wire [7:0]  eth_l10_rxc;
wire [63:0] eth_l11_txd;
wire [7:0]  eth_l11_txc;
wire [63:0] eth_l11_rxd;
wire [7:0]  eth_l11_rxc;

// Clock buffering for 50 MHz sys_clk
IBUFG
sys_clk_ibufg_inst (
    .I(sys_clk),
    .O(sys_clk_ibufg)
);

BUFG
sys_clk_bufg_inst (
    .I(sys_clk_ibufg),
    .O(sys_clk_int)
);

// 156.25 MHz clock from GTH
wire txclk156;

BUFG
clk156_bufg_inst (
    .I(txclk156),
    .O(clk_156mhz)
);

// Synchronize reset signal
sync_reset #(
    .N(6)
)
sync_reset_inst (
    .clk(sys_clk_int),
    .rst(~reset_n),
    .out(sys_rst)
);

sync_signal #(
    .WIDTH(4),
    .N(2)
)
sync_signal_50mhz_inst (
    .clk(sys_clk_int),
    .in({clk_gthl_alm,
        clk_gthl_lol,
        clk_gthr_alm,
        clk_gthr_lol}),
    .out({clk_gthl_alm_int,
        clk_gthl_lol_int,
        clk_gthr_alm_int,
        clk_gthr_lol_int})
);

sync_signal #(
    .WIDTH(4),
    .N(2)
)
sync_signal_156mhz_inst (
    .clk(clk_156mhz),
    .in({uart_suspend,
        uart_dtr,
        uart_txd,
        uart_rts}),
    .out({uart_suspend_int,
        uart_dtr_int,
        uart_txd_int,
        uart_rts_int})
);

// Debounce switch inputs
debounce_switch #(
    .WIDTH(6),
    .N(4),
    .RATE(50000)
)
debounce_switch_inst (
    .clk(sys_clk_int),
    .rst(sys_rst),
    .in({sw, jp}),
    .out({sw_int, jp_int})
);

// pass through outputs
assign led = led_int;

assign uart_rst = uart_rst_int;
assign uart_ri = uart_ri_int;
assign uart_dcd = uart_dcd_int;
assign uart_dsr = uart_dsr_int;
assign uart_rxd = uart_rxd_int;
assign uart_cts = uart_cts_int;

// clock mux I2C
assign clk_gth_scl_i = clk_gth_scl;
assign clk_gth_scl = clk_gth_scl_t ? 1'bz : clk_gth_scl_o;
assign clk_gth_sda_i = clk_gth_sda;
assign clk_gth_sda = clk_gth_sda_t ? 1'bz : clk_gth_sda_o;

assign clk_gth_rst_n = ~sys_rst;

wire [6:0] clk_gth_i2c_cmd_address;
wire clk_gth_i2c_cmd_start;
wire clk_gth_i2c_cmd_read;
wire clk_gth_i2c_cmd_write;
wire clk_gth_i2c_cmd_write_multiple;
wire clk_gth_i2c_cmd_stop;
wire clk_gth_i2c_cmd_valid;
wire clk_gth_i2c_cmd_ready;

wire [7:0] clk_gth_i2c_data;
wire clk_gth_i2c_data_valid;
wire clk_gth_i2c_data_ready;
wire clk_gth_i2c_data_last;

gth_i2c_init
clk_gth_i2c_init (
    .clk(sys_clk_int),
    .rst(sys_rst),
    .cmd_address(clk_gth_i2c_cmd_address),
    .cmd_start(clk_gth_i2c_cmd_start),
    .cmd_read(clk_gth_i2c_cmd_read),
    .cmd_write(clk_gth_i2c_cmd_write),
    .cmd_write_multiple(clk_gth_i2c_cmd_write_multiple),
    .cmd_stop(clk_gth_i2c_cmd_stop),
    .cmd_valid(clk_gth_i2c_cmd_valid),
    .cmd_ready(clk_gth_i2c_cmd_ready),
    .data_out(clk_gth_i2c_data),
    .data_out_valid(clk_gth_i2c_data_valid),
    .data_out_ready(clk_gth_i2c_data_ready),
    .data_out_last(clk_gth_i2c_data_last),
    .busy(),
    .start(1)
);

i2c_master
clk_gth_i2c_master (
    .clk(sys_clk_int),
    .rst(sys_rst),
    .cmd_address(clk_gth_i2c_cmd_address),
    .cmd_start(clk_gth_i2c_cmd_start),
    .cmd_read(clk_gth_i2c_cmd_read),
    .cmd_write(clk_gth_i2c_cmd_write),
    .cmd_write_multiple(clk_gth_i2c_cmd_write_multiple),
    .cmd_stop(clk_gth_i2c_cmd_stop),
    .cmd_valid(clk_gth_i2c_cmd_valid),
    .cmd_ready(clk_gth_i2c_cmd_ready),
    .data_in(clk_gth_i2c_data),
    .data_in_valid(clk_gth_i2c_data_valid),
    .data_in_ready(clk_gth_i2c_data_ready),
    .data_in_last(clk_gth_i2c_data_last),
    .data_out(),
    .data_out_valid(),
    .data_out_ready(1),
    .data_out_last(),
    .scl_i(clk_gth_scl_i),
    .scl_o(clk_gth_scl_o),
    .scl_t(clk_gth_scl_t),
    .sda_i(clk_gth_sda_i),
    .sda_o(clk_gth_sda_o),
    .sda_t(clk_gth_sda_t),
    .busy(),
    .bus_control(),
    .bus_active(),
    .missed_ack(),
    .prescale(312),
    .stop_on_idle(1)
);

// reset logic
wire gth_reset;

wire gth_reset_done_A;
wire gth_reset_done_B;
wire gth_reset_done_C;
wire gth_reset_done_D;
wire gth_reset_done_E;
wire gth_reset_done_F;

wire gth_reset_done = gth_reset_done_A & gth_reset_done_B & gth_reset_done_C & gth_reset_done_D & gth_reset_done_E & gth_reset_done_F;

wire clk_gth_ready = ~clk_gthl_lol_int & ~clk_gthr_lol_int;

sync_reset #(
    .N(6)
)
sync_reset_gth_inst (
    .clk(sys_clk_int),
    .rst(sys_rst | ~clk_gth_ready),
    .out(gth_reset)
);

sync_reset #(
    .N(6)
)
sync_reset_156mhz_inst (
    .clk(clk_156mhz),
    .rst(gth_reset | ~gth_reset_done),
    .out(rst_156mhz)
);

assign amh_right_phy_rst_n = ~rst_156mhz;
assign amh_left_phy_rst_n = ~rst_156mhz;

// AirMax I/O

assign amh_right_mdc = amh_right_mdc_int;

assign amh_right_mdio_i_int = amh_right_mdio;
assign amh_right_mdio = amh_right_mdio_t_int ? 1'bz : amh_right_mdio_o_int;

assign amh_left_mdc = amh_left_mdc_int;

assign amh_left_mdio_i_int = amh_left_mdio;
assign amh_left_mdio = amh_left_mdio_t_int ? 1'bz : amh_left_mdio_o_int;

// 10G Ethernet PCS/PMA

// Quad A X0Y0
eth_gth_phy_quad
eth_gth_phy_quad_A_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(txclk156), // pickoff one transmit clock for 156.25 MHz core clock

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_A),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_A_refclk_p),
    .refclk_n(gth_quad_A_refclk_n),
    .txn_0(gth_quad_A_txn_0),
    .txp_0(gth_quad_A_txp_0),
    .rxn_0(gth_quad_A_rxn_0),
    .rxp_0(gth_quad_A_rxp_0),
    .txn_1(gth_quad_A_txn_1),
    .txp_1(gth_quad_A_txp_1),
    .rxn_1(gth_quad_A_rxn_1),
    .rxp_1(gth_quad_A_rxp_1),
    .txn_2(gth_quad_A_txn_2),
    .txp_2(gth_quad_A_txp_2),
    .rxn_2(gth_quad_A_rxn_2),
    .rxp_2(gth_quad_A_rxp_2),
    .txn_3(gth_quad_A_txn_3),
    .txp_3(gth_quad_A_txp_3),
    .rxn_3(gth_quad_A_rxn_3),
    .rxp_3(gth_quad_A_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_r0_txd),
    .xgmii_txc_0(eth_r0_txc),
    .xgmii_rxd_0(eth_r0_rxd),
    .xgmii_rxc_0(eth_r0_rxc),
    .xgmii_txd_1(eth_r2_txd),
    .xgmii_txc_1(eth_r2_txc),
    .xgmii_rxd_1(eth_r2_rxd),
    .xgmii_rxc_1(eth_r2_rxc),
    .xgmii_txd_2(eth_r4_txd),
    .xgmii_txc_2(eth_r4_txc),
    .xgmii_rxd_2(eth_r4_rxd),
    .xgmii_rxc_2(eth_r4_rxc),
    .xgmii_txd_3(eth_r6_txd),
    .xgmii_txc_3(eth_r6_txc),
    .xgmii_rxd_3(eth_r6_rxd),
    .xgmii_rxc_3(eth_r6_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);

// Quad B X0Y1
eth_gth_phy_quad
eth_gth_phy_quad_B_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(),

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_B),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_B_refclk_p),
    .refclk_n(gth_quad_B_refclk_n),
    .txn_0(gth_quad_B_txn_0),
    .txp_0(gth_quad_B_txp_0),
    .rxn_0(gth_quad_B_rxn_0),
    .rxp_0(gth_quad_B_rxp_0),
    .txn_1(gth_quad_B_txn_1),
    .txp_1(gth_quad_B_txp_1),
    .rxn_1(gth_quad_B_rxn_1),
    .rxp_1(gth_quad_B_rxp_1),
    .txn_2(gth_quad_B_txn_2),
    .txp_2(gth_quad_B_txp_2),
    .rxn_2(gth_quad_B_rxn_2),
    .rxp_2(gth_quad_B_rxp_2),
    .txn_3(gth_quad_B_txn_3),
    .txp_3(gth_quad_B_txp_3),
    .rxn_3(gth_quad_B_rxn_3),
    .rxp_3(gth_quad_B_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_r3_txd),
    .xgmii_txc_0(eth_r3_txc),
    .xgmii_rxd_0(eth_r3_rxd),
    .xgmii_rxc_0(eth_r3_rxc),
    .xgmii_txd_1(eth_r5_txd),
    .xgmii_txc_1(eth_r5_txc),
    .xgmii_rxd_1(eth_r5_rxd),
    .xgmii_rxc_1(eth_r5_rxc),
    .xgmii_txd_2(eth_r1_txd),
    .xgmii_txc_2(eth_r1_txc),
    .xgmii_rxd_2(eth_r1_rxd),
    .xgmii_rxc_2(eth_r1_rxc),
    .xgmii_txd_3(eth_r7_txd),
    .xgmii_txc_3(eth_r7_txc),
    .xgmii_rxd_3(eth_r7_rxd),
    .xgmii_rxc_3(eth_r7_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);

// Quad C X0Y2
eth_gth_phy_quad
eth_gth_phy_quad_C_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(),

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_C),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_C_refclk_p),
    .refclk_n(gth_quad_C_refclk_n),
    .txn_0(gth_quad_C_txn_0),
    .txp_0(gth_quad_C_txp_0),
    .rxn_0(gth_quad_C_rxn_0),
    .rxp_0(gth_quad_C_rxp_0),
    .txn_1(gth_quad_C_txn_1),
    .txp_1(gth_quad_C_txp_1),
    .rxn_1(gth_quad_C_rxn_1),
    .rxp_1(gth_quad_C_rxp_1),
    .txn_2(gth_quad_C_txn_2),
    .txp_2(gth_quad_C_txp_2),
    .rxn_2(gth_quad_C_rxn_2),
    .rxp_2(gth_quad_C_rxp_2),
    .txn_3(gth_quad_C_txn_3),
    .txp_3(gth_quad_C_txp_3),
    .rxn_3(gth_quad_C_rxn_3),
    .rxp_3(gth_quad_C_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_r8_txd),
    .xgmii_txc_0(eth_r8_txc),
    .xgmii_rxd_0(eth_r8_rxd),
    .xgmii_rxc_0(eth_r8_rxc),
    .xgmii_txd_1(eth_r9_txd),
    .xgmii_txc_1(eth_r9_txc),
    .xgmii_rxd_1(eth_r9_rxd),
    .xgmii_rxc_1(eth_r9_rxc),
    .xgmii_txd_2(eth_r11_txd),
    .xgmii_txc_2(eth_r11_txc),
    .xgmii_rxd_2(eth_r11_rxd),
    .xgmii_rxc_2(eth_r11_rxc),
    .xgmii_txd_3(eth_r10_txd),
    .xgmii_txc_3(eth_r10_txc),
    .xgmii_rxd_3(eth_r10_rxd),
    .xgmii_rxc_3(eth_r10_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);

// Quad D X1Y0
eth_gth_phy_quad
eth_gth_phy_quad_D_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(),

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_D),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_D_refclk_p),
    .refclk_n(gth_quad_D_refclk_n),
    .txn_0(gth_quad_D_txn_0),
    .txp_0(gth_quad_D_txp_0),
    .rxn_0(gth_quad_D_rxn_0),
    .rxp_0(gth_quad_D_rxp_0),
    .txn_1(gth_quad_D_txn_1),
    .txp_1(gth_quad_D_txp_1),
    .rxn_1(gth_quad_D_rxn_1),
    .rxp_1(gth_quad_D_rxp_1),
    .txn_2(gth_quad_D_txn_2),
    .txp_2(gth_quad_D_txp_2),
    .rxn_2(gth_quad_D_rxn_2),
    .rxp_2(gth_quad_D_rxp_2),
    .txn_3(gth_quad_D_txn_3),
    .txp_3(gth_quad_D_txp_3),
    .rxn_3(gth_quad_D_rxn_3),
    .rxp_3(gth_quad_D_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_l0_txd),
    .xgmii_txc_0(eth_l0_txc),
    .xgmii_rxd_0(eth_l0_rxd),
    .xgmii_rxc_0(eth_l0_rxc),
    .xgmii_txd_1(eth_l2_txd),
    .xgmii_txc_1(eth_l2_txc),
    .xgmii_rxd_1(eth_l2_rxd),
    .xgmii_rxc_1(eth_l2_rxc),
    .xgmii_txd_2(eth_l4_txd),
    .xgmii_txc_2(eth_l4_txc),
    .xgmii_rxd_2(eth_l4_rxd),
    .xgmii_rxc_2(eth_l4_rxc),
    .xgmii_txd_3(eth_l6_txd),
    .xgmii_txc_3(eth_l6_txc),
    .xgmii_rxd_3(eth_l6_rxd),
    .xgmii_rxc_3(eth_l6_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);

// Quad E X1Y1
eth_gth_phy_quad
eth_gth_phy_quad_E_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(),

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_E),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_E_refclk_p),
    .refclk_n(gth_quad_E_refclk_n),
    .txn_0(gth_quad_E_txn_0),
    .txp_0(gth_quad_E_txp_0),
    .rxn_0(gth_quad_E_rxn_0),
    .rxp_0(gth_quad_E_rxp_0),
    .txn_1(gth_quad_E_txn_1),
    .txp_1(gth_quad_E_txp_1),
    .rxn_1(gth_quad_E_rxn_1),
    .rxp_1(gth_quad_E_rxp_1),
    .txn_2(gth_quad_E_txn_2),
    .txp_2(gth_quad_E_txp_2),
    .rxn_2(gth_quad_E_rxn_2),
    .rxp_2(gth_quad_E_rxp_2),
    .txn_3(gth_quad_E_txn_3),
    .txp_3(gth_quad_E_txp_3),
    .rxn_3(gth_quad_E_rxn_3),
    .rxp_3(gth_quad_E_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_l3_txd),
    .xgmii_txc_0(eth_l3_txc),
    .xgmii_rxd_0(eth_l3_rxd),
    .xgmii_rxc_0(eth_l3_rxc),
    .xgmii_txd_1(eth_l5_txd),
    .xgmii_txc_1(eth_l5_txc),
    .xgmii_rxd_1(eth_l5_rxd),
    .xgmii_rxc_1(eth_l5_rxc),
    .xgmii_txd_2(eth_l1_txd),
    .xgmii_txc_2(eth_l1_txc),
    .xgmii_rxd_2(eth_l1_rxd),
    .xgmii_rxc_2(eth_l1_rxc),
    .xgmii_txd_3(eth_l7_txd),
    .xgmii_txc_3(eth_l7_txc),
    .xgmii_rxd_3(eth_l7_rxd),
    .xgmii_rxc_3(eth_l7_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);

// Quad F X1Y2
eth_gth_phy_quad
eth_gth_phy_quad_F_inst (
    /*
     * Clock and reset
     */
    .clk156(clk_156mhz),
    .rst156(rst_156mhz),
    .dclk(sys_clk_int),
    .dclk_reset(sys_rst),
    .txclk156(),

    .gth_reset(gth_reset),
    .gth_reset_done(gth_reset_done_F),

    /*
     * Transciever pins
     */
    .refclk_p(gth_quad_F_refclk_p),
    .refclk_n(gth_quad_F_refclk_n),
    .txn_0(gth_quad_F_txn_0),
    .txp_0(gth_quad_F_txp_0),
    .rxn_0(gth_quad_F_rxn_0),
    .rxp_0(gth_quad_F_rxp_0),
    .txn_1(gth_quad_F_txn_1),
    .txp_1(gth_quad_F_txp_1),
    .rxn_1(gth_quad_F_rxn_1),
    .rxp_1(gth_quad_F_rxp_1),
    .txn_2(gth_quad_F_txn_2),
    .txp_2(gth_quad_F_txp_2),
    .rxn_2(gth_quad_F_rxn_2),
    .rxp_2(gth_quad_F_rxp_2),
    .txn_3(gth_quad_F_txn_3),
    .txp_3(gth_quad_F_txp_3),
    .rxn_3(gth_quad_F_rxn_3),
    .rxp_3(gth_quad_F_rxp_3),

    /*
     * XGMII interfaces
     */
    .xgmii_txd_0(eth_l8_txd),
    .xgmii_txc_0(eth_l8_txc),
    .xgmii_rxd_0(eth_l8_rxd),
    .xgmii_rxc_0(eth_l8_rxc),
    .xgmii_txd_1(eth_l9_txd),
    .xgmii_txc_1(eth_l9_txc),
    .xgmii_rxd_1(eth_l9_rxd),
    .xgmii_rxc_1(eth_l9_rxc),
    .xgmii_txd_2(eth_l11_txd),
    .xgmii_txc_2(eth_l11_txc),
    .xgmii_rxd_2(eth_l11_rxd),
    .xgmii_rxc_2(eth_l11_rxc),
    .xgmii_txd_3(eth_l10_txd),
    .xgmii_txc_3(eth_l10_txc),
    .xgmii_rxd_3(eth_l10_rxd),
    .xgmii_rxc_3(eth_l10_rxc),

    /*
     * Control
     */
    .tx_powerdown_0(1'b0),
    .rx_powerdown_0(1'b0),
    .tx_powerdown_1(1'b0),
    .rx_powerdown_1(1'b0),
    .tx_powerdown_2(1'b0),
    .rx_powerdown_2(1'b0),
    .tx_powerdown_3(1'b0),
    .rx_powerdown_3(1'b0)
);


fpga_core
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk_156mhz),
    .rst(rst_156mhz),
    /*
     * GPIO
     */
    .sw(sw_int),
    .jp(jp_int),
    .led(led_int),
    /*
     * Silicon Labs CP2102 USB UART
     */
    .uart_rst(uart_rst_int),
    .uart_suspend(uart_suspend_int),
    .uart_ri(uart_ri_int),
    .uart_dcd(uart_dcd_int),
    .uart_dtr(uart_dtr_int),
    .uart_dsr(uart_dsr_int),
    .uart_txd(uart_txd_int),
    .uart_rxd(uart_rxd_int),
    .uart_rts(uart_rts_int),
    .uart_cts(uart_cts_int),
    /*
     * AirMax I/O
     */
    .amh_right_mdc(amh_right_mdc_int),
    .amh_right_mdio_i(amh_right_mdio_i_int),
    .amh_right_mdio_o(amh_right_mdio_o_int),
    .amh_right_mdio_t(amh_right_mdio_t_int),
    .amh_left_mdc(amh_left_mdc_int),
    .amh_left_mdio_i(amh_left_mdio_i_int),
    .amh_left_mdio_o(amh_left_mdio_o_int),
    .amh_left_mdio_t(amh_left_mdio_t_int),
    /*
     * 10G Ethernet XGMII
     */
    .eth_r0_txd(eth_r0_txd),
    .eth_r0_txc(eth_r0_txc),
    .eth_r0_rxd(eth_r0_rxd),
    .eth_r0_rxc(eth_r0_rxc),
    .eth_r1_txd(eth_r1_txd),
    .eth_r1_txc(eth_r1_txc),
    .eth_r1_rxd(eth_r1_rxd),
    .eth_r1_rxc(eth_r1_rxc),
    .eth_r2_txd(eth_r2_txd),
    .eth_r2_txc(eth_r2_txc),
    .eth_r2_rxd(eth_r2_rxd),
    .eth_r2_rxc(eth_r2_rxc),
    .eth_r3_txd(eth_r3_txd),
    .eth_r3_txc(eth_r3_txc),
    .eth_r3_rxd(eth_r3_rxd),
    .eth_r3_rxc(eth_r3_rxc),
    .eth_r4_txd(eth_r4_txd),
    .eth_r4_txc(eth_r4_txc),
    .eth_r4_rxd(eth_r4_rxd),
    .eth_r4_rxc(eth_r4_rxc),
    .eth_r5_txd(eth_r5_txd),
    .eth_r5_txc(eth_r5_txc),
    .eth_r5_rxd(eth_r5_rxd),
    .eth_r5_rxc(eth_r5_rxc),
    .eth_r6_txd(eth_r6_txd),
    .eth_r6_txc(eth_r6_txc),
    .eth_r6_rxd(eth_r6_rxd),
    .eth_r6_rxc(eth_r6_rxc),
    .eth_r7_txd(eth_r7_txd),
    .eth_r7_txc(eth_r7_txc),
    .eth_r7_rxd(eth_r7_rxd),
    .eth_r7_rxc(eth_r7_rxc),
    .eth_r8_txd(eth_r8_txd),
    .eth_r8_txc(eth_r8_txc),
    .eth_r8_rxd(eth_r8_rxd),
    .eth_r8_rxc(eth_r8_rxc),
    .eth_r9_txd(eth_r9_txd),
    .eth_r9_txc(eth_r9_txc),
    .eth_r9_rxd(eth_r9_rxd),
    .eth_r9_rxc(eth_r9_rxc),
    .eth_r10_txd(eth_r10_txd),
    .eth_r10_txc(eth_r10_txc),
    .eth_r10_rxd(eth_r10_rxd),
    .eth_r10_rxc(eth_r10_rxc),
    .eth_r11_txd(eth_r11_txd),
    .eth_r11_txc(eth_r11_txc),
    .eth_r11_rxd(eth_r11_rxd),
    .eth_r11_rxc(eth_r11_rxc),
    .eth_l0_txd(eth_l0_txd),
    .eth_l0_txc(eth_l0_txc),
    .eth_l0_rxd(eth_l0_rxd),
    .eth_l0_rxc(eth_l0_rxc),
    .eth_l1_txd(eth_l1_txd),
    .eth_l1_txc(eth_l1_txc),
    .eth_l1_rxd(eth_l1_rxd),
    .eth_l1_rxc(eth_l1_rxc),
    .eth_l2_txd(eth_l2_txd),
    .eth_l2_txc(eth_l2_txc),
    .eth_l2_rxd(eth_l2_rxd),
    .eth_l2_rxc(eth_l2_rxc),
    .eth_l3_txd(eth_l3_txd),
    .eth_l3_txc(eth_l3_txc),
    .eth_l3_rxd(eth_l3_rxd),
    .eth_l3_rxc(eth_l3_rxc),
    .eth_l4_txd(eth_l4_txd),
    .eth_l4_txc(eth_l4_txc),
    .eth_l4_rxd(eth_l4_rxd),
    .eth_l4_rxc(eth_l4_rxc),
    .eth_l5_txd(eth_l5_txd),
    .eth_l5_txc(eth_l5_txc),
    .eth_l5_rxd(eth_l5_rxd),
    .eth_l5_rxc(eth_l5_rxc),
    .eth_l6_txd(eth_l6_txd),
    .eth_l6_txc(eth_l6_txc),
    .eth_l6_rxd(eth_l6_rxd),
    .eth_l6_rxc(eth_l6_rxc),
    .eth_l7_txd(eth_l7_txd),
    .eth_l7_txc(eth_l7_txc),
    .eth_l7_rxd(eth_l7_rxd),
    .eth_l7_rxc(eth_l7_rxc),
    .eth_l8_txd(eth_l8_txd),
    .eth_l8_txc(eth_l8_txc),
    .eth_l8_rxd(eth_l8_rxd),
    .eth_l8_rxc(eth_l8_rxc),
    .eth_l9_txd(eth_l9_txd),
    .eth_l9_txc(eth_l9_txc),
    .eth_l9_rxd(eth_l9_rxd),
    .eth_l9_rxc(eth_l9_rxc),
    .eth_l10_txd(eth_l10_txd),
    .eth_l10_txc(eth_l10_txc),
    .eth_l10_rxd(eth_l10_rxd),
    .eth_l10_rxc(eth_l10_rxc),
    .eth_l11_txd(eth_l11_txd),
    .eth_l11_txc(eth_l11_txc),
    .eth_l11_rxd(eth_l11_rxd),
    .eth_l11_rxc(eth_l11_rxc)
);

endmodule

`resetall
