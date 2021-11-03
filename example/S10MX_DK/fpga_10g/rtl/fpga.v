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
     * Clock: 100 MHz
     * Reset: Push button, active low
     */
    input  wire        clk_sys_100m_p,
    input  wire        cpu_resetn,

    /*
     * GPIO
     */
    output wire [3:0]  user_led,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0]  qsfp0_tx_p,
    input  wire [3:0]  qsfp0_rx_p,
    input  wire        refclk_qsfp0_p,

    output wire        qsfp0_modsel_l,
    output wire        qsfp0_reset_l,
    input  wire        qsfp0_modprs_l,
    output wire        qsfp0_lpmode,
    input  wire        qsfp0_int_l,

    output wire [3:0]  qsfp1_tx_p,
    input  wire [3:0]  qsfp1_rx_p,
    input  wire        refclk_qsfp1_p,

    output wire        qsfp1_modsel_l,
    output wire        qsfp1_reset_l,
    input  wire        qsfp1_modprs_l,
    output wire        qsfp1_lpmode,
    input  wire        qsfp1_int_l
);

// Clock and reset
wire ninit_done;

reset_release reset_release_inst (
    .ninit_done (ninit_done)
);

wire clk_100mhz = clk_sys_100m_p;
wire rst_100mhz;

sync_reset #(
    .N(4)
)
sync_reset_100mhz_inst (
    .clk(clk_100mhz),
    .rst(~cpu_resetn || ninit_done),
    .out(rst_100mhz)
);

wire clk_156mhz_int;
wire rst_156mhz_int;

// XGMII 10G PHY

// QSFP0
assign qsfp0_modsel_l = 1'b0;
assign qsfp0_reset_l = 1'b1;
assign qsfp0_lpmode = 1'b0;

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

eth_xcvr_phy_quad_wrapper qsfp0_eth_xcvr_phy_quad (
    .xcvr_ctrl_clk(clk_100mhz),
    .xcvr_ctrl_rst(rst_100mhz),
    .xcvr_ref_clk(refclk_qsfp0_p),
    .xcvr_tx_serial_data(qsfp0_tx_p),
    .xcvr_rx_serial_data(qsfp0_rx_p),

    .phy_1_tx_clk(qsfp0_tx_clk_1_int),
    .phy_1_tx_rst(qsfp0_tx_rst_1_int),
    .phy_1_xgmii_txd(qsfp0_txd_1_int),
    .phy_1_xgmii_txc(qsfp0_txc_1_int),
    .phy_1_rx_clk(qsfp0_rx_clk_1_int),
    .phy_1_rx_rst(qsfp0_rx_rst_1_int),
    .phy_1_xgmii_rxd(qsfp0_rxd_1_int),
    .phy_1_xgmii_rxc(qsfp0_rxc_1_int),
    .phy_1_rx_block_lock(qsfp0_rx_block_lock_1),
    .phy_1_rx_high_ber(),
    .phy_2_tx_clk(qsfp0_tx_clk_2_int),
    .phy_2_tx_rst(qsfp0_tx_rst_2_int),
    .phy_2_xgmii_txd(qsfp0_txd_2_int),
    .phy_2_xgmii_txc(qsfp0_txc_2_int),
    .phy_2_rx_clk(qsfp0_rx_clk_2_int),
    .phy_2_rx_rst(qsfp0_rx_rst_2_int),
    .phy_2_xgmii_rxd(qsfp0_rxd_2_int),
    .phy_2_xgmii_rxc(qsfp0_rxc_2_int),
    .phy_2_rx_block_lock(qsfp0_rx_block_lock_2),
    .phy_2_rx_high_ber(),
    .phy_3_tx_clk(qsfp0_tx_clk_3_int),
    .phy_3_tx_rst(qsfp0_tx_rst_3_int),
    .phy_3_xgmii_txd(qsfp0_txd_3_int),
    .phy_3_xgmii_txc(qsfp0_txc_3_int),
    .phy_3_rx_clk(qsfp0_rx_clk_3_int),
    .phy_3_rx_rst(qsfp0_rx_rst_3_int),
    .phy_3_xgmii_rxd(qsfp0_rxd_3_int),
    .phy_3_xgmii_rxc(qsfp0_rxc_3_int),
    .phy_3_rx_block_lock(qsfp0_rx_block_lock_3),
    .phy_3_rx_high_ber(),
    .phy_4_tx_clk(qsfp0_tx_clk_4_int),
    .phy_4_tx_rst(qsfp0_tx_rst_4_int),
    .phy_4_xgmii_txd(qsfp0_txd_4_int),
    .phy_4_xgmii_txc(qsfp0_txc_4_int),
    .phy_4_rx_clk(qsfp0_rx_clk_4_int),
    .phy_4_rx_rst(qsfp0_rx_rst_4_int),
    .phy_4_xgmii_rxd(qsfp0_rxd_4_int),
    .phy_4_xgmii_rxc(qsfp0_rxc_4_int),
    .phy_4_rx_block_lock(qsfp0_rx_block_lock_4),
    .phy_4_rx_high_ber()
);

// QSFP1
assign qsfp1_modsel_l = 1'b0;
assign qsfp1_reset_l = 1'b1;
assign qsfp1_lpmode = 1'b0;

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

eth_xcvr_phy_quad_wrapper qsfp1_eth_xcvr_phy_quad (
    .xcvr_ctrl_clk(clk_100mhz),
    .xcvr_ctrl_rst(rst_100mhz),
    .xcvr_ref_clk(refclk_qsfp1_p),
    .xcvr_tx_serial_data(qsfp1_tx_p),
    .xcvr_rx_serial_data(qsfp1_rx_p),

    .phy_1_tx_clk(qsfp1_tx_clk_1_int),
    .phy_1_tx_rst(qsfp1_tx_rst_1_int),
    .phy_1_xgmii_txd(qsfp1_txd_1_int),
    .phy_1_xgmii_txc(qsfp1_txc_1_int),
    .phy_1_rx_clk(qsfp1_rx_clk_1_int),
    .phy_1_rx_rst(qsfp1_rx_rst_1_int),
    .phy_1_xgmii_rxd(qsfp1_rxd_1_int),
    .phy_1_xgmii_rxc(qsfp1_rxc_1_int),
    .phy_1_rx_block_lock(qsfp1_rx_block_lock_1),
    .phy_1_rx_high_ber(),
    .phy_2_tx_clk(qsfp1_tx_clk_2_int),
    .phy_2_tx_rst(qsfp1_tx_rst_2_int),
    .phy_2_xgmii_txd(qsfp1_txd_2_int),
    .phy_2_xgmii_txc(qsfp1_txc_2_int),
    .phy_2_rx_clk(qsfp1_rx_clk_2_int),
    .phy_2_rx_rst(qsfp1_rx_rst_2_int),
    .phy_2_xgmii_rxd(qsfp1_rxd_2_int),
    .phy_2_xgmii_rxc(qsfp1_rxc_2_int),
    .phy_2_rx_block_lock(qsfp1_rx_block_lock_2),
    .phy_2_rx_high_ber(),
    .phy_3_tx_clk(qsfp1_tx_clk_3_int),
    .phy_3_tx_rst(qsfp1_tx_rst_3_int),
    .phy_3_xgmii_txd(qsfp1_txd_3_int),
    .phy_3_xgmii_txc(qsfp1_txc_3_int),
    .phy_3_rx_clk(qsfp1_rx_clk_3_int),
    .phy_3_rx_rst(qsfp1_rx_rst_3_int),
    .phy_3_xgmii_rxd(qsfp1_rxd_3_int),
    .phy_3_xgmii_rxc(qsfp1_rxc_3_int),
    .phy_3_rx_block_lock(qsfp1_rx_block_lock_3),
    .phy_3_rx_high_ber(),
    .phy_4_tx_clk(qsfp1_tx_clk_4_int),
    .phy_4_tx_rst(qsfp1_tx_rst_4_int),
    .phy_4_xgmii_txd(qsfp1_txd_4_int),
    .phy_4_xgmii_txc(qsfp1_txc_4_int),
    .phy_4_rx_clk(qsfp1_rx_clk_4_int),
    .phy_4_rx_rst(qsfp1_rx_rst_4_int),
    .phy_4_xgmii_rxd(qsfp1_rxd_4_int),
    .phy_4_xgmii_rxc(qsfp1_rxc_4_int),
    .phy_4_rx_block_lock(qsfp1_rx_block_lock_4),
    .phy_4_rx_high_ber()
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
    .user_led(user_led),
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
