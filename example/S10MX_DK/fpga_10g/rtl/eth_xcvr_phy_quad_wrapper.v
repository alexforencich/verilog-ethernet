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
 * Transceiver and PHY quad wrapper
 */
module eth_xcvr_phy_quad_wrapper (
    input  wire        xcvr_ctrl_clk,
    input  wire        xcvr_ctrl_rst,
    input  wire        xcvr_ref_clk,
    output wire [3:0]  xcvr_tx_serial_data,
    input  wire [3:0]  xcvr_rx_serial_data,

    output wire        phy_1_tx_clk,
    output wire        phy_1_tx_rst,
    input  wire [63:0] phy_1_xgmii_txd,
    input  wire [7:0]  phy_1_xgmii_txc,
    output wire        phy_1_rx_clk,
    output wire        phy_1_rx_rst,
    output wire [63:0] phy_1_xgmii_rxd,
    output wire [7:0]  phy_1_xgmii_rxc,
    output wire        phy_1_rx_block_lock,
    output wire        phy_1_rx_high_ber,
    output wire        phy_2_tx_clk,
    output wire        phy_2_tx_rst,
    input  wire [63:0] phy_2_xgmii_txd,
    input  wire [7:0]  phy_2_xgmii_txc,
    output wire        phy_2_rx_clk,
    output wire        phy_2_rx_rst,
    output wire [63:0] phy_2_xgmii_rxd,
    output wire [7:0]  phy_2_xgmii_rxc,
    output wire        phy_2_rx_block_lock,
    output wire        phy_2_rx_high_ber,
    output wire        phy_3_tx_clk,
    output wire        phy_3_tx_rst,
    input  wire [63:0] phy_3_xgmii_txd,
    input  wire [7:0]  phy_3_xgmii_txc,
    output wire        phy_3_rx_clk,
    output wire        phy_3_rx_rst,
    output wire [63:0] phy_3_xgmii_rxd,
    output wire [7:0]  phy_3_xgmii_rxc,
    output wire        phy_3_rx_block_lock,
    output wire        phy_3_rx_high_ber,
    output wire        phy_4_tx_clk,
    output wire        phy_4_tx_rst,
    input  wire [63:0] phy_4_xgmii_txd,
    input  wire [7:0]  phy_4_xgmii_txc,
    output wire        phy_4_rx_clk,
    output wire        phy_4_rx_rst,
    output wire [63:0] phy_4_xgmii_rxd,
    output wire [7:0]  phy_4_xgmii_rxc,
    output wire        phy_4_rx_block_lock,
    output wire        phy_4_rx_high_ber
);

wire xcvr_pll_locked;
wire xcvr_pll_cal_busy;

wire xcvr_tx_serial_clk;

wire [3:0] xcvr_tx_analogreset;
wire [3:0] xcvr_rx_analogreset;
wire [3:0] xcvr_tx_digitalreset;
wire [3:0] xcvr_rx_digitalreset;
wire [3:0] xcvr_tx_analogreset_stat;
wire [3:0] xcvr_rx_analogreset_stat;
wire [3:0] xcvr_tx_digitalreset_stat;
wire [3:0] xcvr_rx_digitalreset_stat;
wire [3:0] xcvr_tx_cal_busy;
wire [3:0] xcvr_rx_cal_busy;
wire [3:0] xcvr_rx_is_lockedtoref;
wire [3:0] xcvr_rx_is_lockedtodata;
wire [3:0] xcvr_tx_ready;
wire [3:0] xcvr_rx_ready;

eth_xcvr_reset eth_xcvr_reset_inst (
    .clock                (xcvr_ctrl_clk),
    .reset                (xcvr_ctrl_rst),
    .tx_analogreset       (xcvr_tx_analogreset),
    .tx_digitalreset      (xcvr_tx_digitalreset),
    .tx_ready             (xcvr_tx_ready),
    .pll_locked           (xcvr_pll_locked),
    .pll_select           (4'd0),
    .tx_cal_busy          (xcvr_tx_cal_busy),
    .tx_analogreset_stat  (xcvr_tx_analogreset_stat),
    .tx_digitalreset_stat (xcvr_tx_digitalreset_stat),
    .pll_cal_busy         (xcvr_pll_cal_busy),
    .rx_analogreset       (xcvr_rx_analogreset),
    .rx_digitalreset      (xcvr_rx_digitalreset),
    .rx_ready             (xcvr_rx_ready),
    .rx_is_lockedtodata   (xcvr_rx_is_lockedtodata),
    .rx_cal_busy          (xcvr_rx_cal_busy),
    .rx_analogreset_stat  (xcvr_rx_analogreset_stat),
    .rx_digitalreset_stat (xcvr_rx_digitalreset_stat)
);

eth_xcvr_pll eth_xcvr_pll_inst (
    .pll_refclk0   (xcvr_ref_clk),
    .tx_serial_clk (xcvr_tx_serial_clk),
    .pll_locked    (xcvr_pll_locked),
    .pll_cal_busy  (xcvr_pll_cal_busy)
);

eth_xcvr_phy_wrapper eth_xcvr_phy_1 (
    .xcvr_ctrl_clk(xcvr_ctrl_clk),
    .xcvr_ctrl_rst(xcvr_ctrl_rst),

    .xcvr_tx_analogreset(xcvr_tx_analogreset[0]),
    .xcvr_rx_analogreset(xcvr_rx_analogreset[0]),
    .xcvr_tx_digitalreset(xcvr_tx_digitalreset[0]),
    .xcvr_rx_digitalreset(xcvr_rx_digitalreset[0]),
    .xcvr_tx_analogreset_stat(xcvr_tx_analogreset_stat[0]),
    .xcvr_rx_analogreset_stat(xcvr_rx_analogreset_stat[0]),
    .xcvr_tx_digitalreset_stat(xcvr_tx_digitalreset_stat[0]),
    .xcvr_rx_digitalreset_stat(xcvr_rx_digitalreset_stat[0]),
    .xcvr_tx_cal_busy(xcvr_tx_cal_busy[0]),
    .xcvr_rx_cal_busy(xcvr_rx_cal_busy[0]),
    .xcvr_tx_serial_clk(xcvr_tx_serial_clk),
    .xcvr_rx_cdr_refclk(xcvr_ref_clk),
    .xcvr_tx_serial_data(xcvr_tx_serial_data[0]),
    .xcvr_rx_serial_data(xcvr_rx_serial_data[0]),
    .xcvr_rx_is_lockedtoref(xcvr_rx_is_lockedtoref[0]),
    .xcvr_rx_is_lockedtodata(xcvr_rx_is_lockedtodata[0]),
    .xcvr_tx_ready(xcvr_tx_ready[0]),
    .xcvr_rx_ready(xcvr_rx_ready[0]),

    .phy_tx_clk(phy_1_tx_clk),
    .phy_tx_rst(phy_1_tx_rst),
    .phy_xgmii_txd(phy_1_xgmii_txd),
    .phy_xgmii_txc(phy_1_xgmii_txc),
    .phy_rx_clk(phy_1_rx_clk),
    .phy_rx_rst(phy_1_rx_rst),
    .phy_xgmii_rxd(phy_1_xgmii_rxd),
    .phy_xgmii_rxc(phy_1_xgmii_rxc),
    .phy_rx_block_lock(phy_1_rx_block_lock),
    .phy_rx_high_ber(phy_1_rx_high_ber)
);

eth_xcvr_phy_wrapper eth_xcvr_phy_2 (
    .xcvr_ctrl_clk(xcvr_ctrl_clk),
    .xcvr_ctrl_rst(xcvr_ctrl_rst),

    .xcvr_tx_analogreset(xcvr_tx_analogreset[1]),
    .xcvr_rx_analogreset(xcvr_rx_analogreset[1]),
    .xcvr_tx_digitalreset(xcvr_tx_digitalreset[1]),
    .xcvr_rx_digitalreset(xcvr_rx_digitalreset[1]),
    .xcvr_tx_analogreset_stat(xcvr_tx_analogreset_stat[1]),
    .xcvr_rx_analogreset_stat(xcvr_rx_analogreset_stat[1]),
    .xcvr_tx_digitalreset_stat(xcvr_tx_digitalreset_stat[1]),
    .xcvr_rx_digitalreset_stat(xcvr_rx_digitalreset_stat[1]),
    .xcvr_tx_cal_busy(xcvr_tx_cal_busy[1]),
    .xcvr_rx_cal_busy(xcvr_rx_cal_busy[1]),
    .xcvr_tx_serial_clk(xcvr_tx_serial_clk),
    .xcvr_rx_cdr_refclk(xcvr_ref_clk),
    .xcvr_tx_serial_data(xcvr_tx_serial_data[1]),
    .xcvr_rx_serial_data(xcvr_rx_serial_data[1]),
    .xcvr_rx_is_lockedtoref(xcvr_rx_is_lockedtoref[1]),
    .xcvr_rx_is_lockedtodata(xcvr_rx_is_lockedtodata[1]),
    .xcvr_tx_ready(xcvr_tx_ready[1]),
    .xcvr_rx_ready(xcvr_rx_ready[1]),

    .phy_tx_clk(phy_2_tx_clk),
    .phy_tx_rst(phy_2_tx_rst),
    .phy_xgmii_txd(phy_2_xgmii_txd),
    .phy_xgmii_txc(phy_2_xgmii_txc),
    .phy_rx_clk(phy_2_rx_clk),
    .phy_rx_rst(phy_2_rx_rst),
    .phy_xgmii_rxd(phy_2_xgmii_rxd),
    .phy_xgmii_rxc(phy_2_xgmii_rxc),
    .phy_rx_block_lock(phy_2_rx_block_lock),
    .phy_rx_high_ber(phy_2_rx_high_ber)
);

eth_xcvr_phy_wrapper eth_xcvr_phy_3 (
    .xcvr_ctrl_clk(xcvr_ctrl_clk),
    .xcvr_ctrl_rst(xcvr_ctrl_rst),

    .xcvr_tx_analogreset(xcvr_tx_analogreset[2]),
    .xcvr_rx_analogreset(xcvr_rx_analogreset[2]),
    .xcvr_tx_digitalreset(xcvr_tx_digitalreset[2]),
    .xcvr_rx_digitalreset(xcvr_rx_digitalreset[2]),
    .xcvr_tx_analogreset_stat(xcvr_tx_analogreset_stat[2]),
    .xcvr_rx_analogreset_stat(xcvr_rx_analogreset_stat[2]),
    .xcvr_tx_digitalreset_stat(xcvr_tx_digitalreset_stat[2]),
    .xcvr_rx_digitalreset_stat(xcvr_rx_digitalreset_stat[2]),
    .xcvr_tx_cal_busy(xcvr_tx_cal_busy[2]),
    .xcvr_rx_cal_busy(xcvr_rx_cal_busy[2]),
    .xcvr_tx_serial_clk(xcvr_tx_serial_clk),
    .xcvr_rx_cdr_refclk(xcvr_ref_clk),
    .xcvr_tx_serial_data(xcvr_tx_serial_data[2]),
    .xcvr_rx_serial_data(xcvr_rx_serial_data[2]),
    .xcvr_rx_is_lockedtoref(xcvr_rx_is_lockedtoref[2]),
    .xcvr_rx_is_lockedtodata(xcvr_rx_is_lockedtodata[2]),
    .xcvr_tx_ready(xcvr_tx_ready[2]),
    .xcvr_rx_ready(xcvr_rx_ready[2]),

    .phy_tx_clk(phy_3_tx_clk),
    .phy_tx_rst(phy_3_tx_rst),
    .phy_xgmii_txd(phy_3_xgmii_txd),
    .phy_xgmii_txc(phy_3_xgmii_txc),
    .phy_rx_clk(phy_3_rx_clk),
    .phy_rx_rst(phy_3_rx_rst),
    .phy_xgmii_rxd(phy_3_xgmii_rxd),
    .phy_xgmii_rxc(phy_3_xgmii_rxc),
    .phy_rx_block_lock(phy_3_rx_block_lock),
    .phy_rx_high_ber(phy_3_rx_high_ber)
);

eth_xcvr_phy_wrapper eth_xcvr_phy_4 (
    .xcvr_ctrl_clk(xcvr_ctrl_clk),
    .xcvr_ctrl_rst(xcvr_ctrl_rst),

    .xcvr_tx_analogreset(xcvr_tx_analogreset[3]),
    .xcvr_rx_analogreset(xcvr_rx_analogreset[3]),
    .xcvr_tx_digitalreset(xcvr_tx_digitalreset[3]),
    .xcvr_rx_digitalreset(xcvr_rx_digitalreset[3]),
    .xcvr_tx_analogreset_stat(xcvr_tx_analogreset_stat[3]),
    .xcvr_rx_analogreset_stat(xcvr_rx_analogreset_stat[3]),
    .xcvr_tx_digitalreset_stat(xcvr_tx_digitalreset_stat[3]),
    .xcvr_rx_digitalreset_stat(xcvr_rx_digitalreset_stat[3]),
    .xcvr_tx_cal_busy(xcvr_tx_cal_busy[3]),
    .xcvr_rx_cal_busy(xcvr_rx_cal_busy[3]),
    .xcvr_tx_serial_clk(xcvr_tx_serial_clk),
    .xcvr_rx_cdr_refclk(xcvr_ref_clk),
    .xcvr_tx_serial_data(xcvr_tx_serial_data[3]),
    .xcvr_rx_serial_data(xcvr_rx_serial_data[3]),
    .xcvr_rx_is_lockedtoref(xcvr_rx_is_lockedtoref[3]),
    .xcvr_rx_is_lockedtodata(xcvr_rx_is_lockedtodata[3]),
    .xcvr_tx_ready(xcvr_tx_ready[3]),
    .xcvr_rx_ready(xcvr_rx_ready[3]),

    .phy_tx_clk(phy_4_tx_clk),
    .phy_tx_rst(phy_4_tx_rst),
    .phy_xgmii_txd(phy_4_xgmii_txd),
    .phy_xgmii_txc(phy_4_xgmii_txc),
    .phy_rx_clk(phy_4_rx_clk),
    .phy_rx_rst(phy_4_rx_rst),
    .phy_xgmii_rxd(phy_4_xgmii_rxd),
    .phy_xgmii_rxc(phy_4_xgmii_rxc),
    .phy_rx_block_lock(phy_4_rx_block_lock),
    .phy_rx_high_ber(phy_4_rx_high_ber)
);

endmodule

`resetall
