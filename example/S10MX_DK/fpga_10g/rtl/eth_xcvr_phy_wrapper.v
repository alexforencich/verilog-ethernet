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
 * Transceiver and PHY wrapper
 */
module eth_xcvr_phy_wrapper (
    input  wire        xcvr_ctrl_clk,
    input  wire        xcvr_ctrl_rst,

    input  wire        xcvr_tx_analogreset,
    input  wire        xcvr_rx_analogreset,
    input  wire        xcvr_tx_digitalreset,
    input  wire        xcvr_rx_digitalreset,
    output wire        xcvr_tx_analogreset_stat,
    output wire        xcvr_rx_analogreset_stat,
    output wire        xcvr_tx_digitalreset_stat,
    output wire        xcvr_rx_digitalreset_stat,
    output wire        xcvr_tx_cal_busy,
    output wire        xcvr_rx_cal_busy,
    input  wire        xcvr_tx_serial_clk,
    input  wire        xcvr_rx_cdr_refclk,
    output wire        xcvr_tx_serial_data,
    input  wire        xcvr_rx_serial_data,
    output wire        xcvr_rx_is_lockedtoref,
    output wire        xcvr_rx_is_lockedtodata,
    input  wire        xcvr_tx_ready,
    input  wire        xcvr_rx_ready,

    output wire        phy_tx_clk,
    output wire        phy_tx_rst,
    input  wire [63:0] phy_xgmii_txd,
    input  wire [7:0]  phy_xgmii_txc,
    output wire        phy_rx_clk,
    output wire        phy_rx_rst,
    output wire [63:0] phy_xgmii_rxd,
    output wire [7:0]  phy_xgmii_rxc,
    output wire        phy_rx_block_lock,
    output wire        phy_rx_high_ber
);

wire xcvr_tx_clk;
wire xcvr_rx_clk;

assign phy_tx_clk = xcvr_tx_clk;
assign phy_rx_clk = xcvr_rx_clk;

wire [1:0] xcvr_tx_hdr;
wire [63:0] xcvr_tx_data;
wire [1:0] xcvr_rx_hdr;
wire [63:0] xcvr_rx_data;

wire [1:0] phy_tx_hdr;
wire [63:0] phy_tx_data;
wire [1:0] phy_rx_hdr;
wire [63:0] phy_rx_data;

wire xcvr_rx_bitslip;

assign {xcvr_tx_hdr, xcvr_tx_data} = {phy_tx_data, phy_tx_hdr};
assign {phy_rx_data, phy_rx_hdr} = {xcvr_rx_hdr, xcvr_rx_data};

eth_xcvr eth_xcvr_inst (
    .tx_analogreset          (xcvr_tx_analogreset),
    .rx_analogreset          (xcvr_rx_analogreset),
    .tx_digitalreset         (xcvr_tx_digitalreset),
    .rx_digitalreset         (xcvr_rx_digitalreset),
    .tx_analogreset_stat     (xcvr_tx_analogreset_stat),
    .rx_analogreset_stat     (xcvr_rx_analogreset_stat),
    .tx_digitalreset_stat    (xcvr_tx_digitalreset_stat),
    .rx_digitalreset_stat    (xcvr_rx_digitalreset_stat),
    .tx_cal_busy             (xcvr_tx_cal_busy),
    .rx_cal_busy             (xcvr_rx_cal_busy),
    .tx_serial_clk0          (xcvr_tx_serial_clk),
    .rx_cdr_refclk0          (xcvr_rx_cdr_refclk),
    .tx_serial_data          (xcvr_tx_serial_data),
    .rx_serial_data          (xcvr_rx_serial_data),
    .rx_is_lockedtoref       (xcvr_rx_is_lockedtoref),
    .rx_is_lockedtodata      (xcvr_rx_is_lockedtodata),
    .tx_coreclkin            (xcvr_tx_clk),
    .rx_coreclkin            (xcvr_rx_clk),
    .tx_clkout               (xcvr_tx_clk),
    .tx_clkout2              (),
    .rx_clkout               (xcvr_rx_clk),
    .rx_clkout2              (),
    .tx_parallel_data        (xcvr_tx_data),
    .tx_control              (xcvr_tx_hdr),
    .tx_enh_data_valid       (1'b1),
    .unused_tx_parallel_data (13'd0),
    .rx_parallel_data        (xcvr_rx_data),
    .rx_control              (xcvr_rx_hdr),
    .rx_enh_data_valid       (),
    .unused_rx_parallel_data (),
    .rx_bitslip              (xcvr_rx_bitslip)
);

sync_reset #(
    .N(4)
)
phy_tx_rst_reset_sync_inst (
    .clk(phy_tx_clk),
    .rst(~xcvr_tx_ready),
    .out(phy_tx_rst)
);

sync_reset #(
    .N(4)
)
phy_rx_rst_reset_sync_inst (
    .clk(phy_rx_clk),
    .rst(~xcvr_rx_ready),
    .out(phy_rx_rst)
);

eth_phy_10g #(
    .BIT_REVERSE(0),
    .BITSLIP_HIGH_CYCLES(32),
    .BITSLIP_LOW_CYCLES(32)
)
phy_inst (
    .tx_clk(phy_tx_clk),
    .tx_rst(phy_tx_rst),
    .rx_clk(phy_rx_clk),
    .rx_rst(phy_rx_rst),
    .xgmii_txd(phy_xgmii_txd),
    .xgmii_txc(phy_xgmii_txc),
    .xgmii_rxd(phy_xgmii_rxd),
    .xgmii_rxc(phy_xgmii_rxc),
    .serdes_tx_data(phy_tx_data),
    .serdes_tx_hdr(phy_tx_hdr),
    .serdes_rx_data(phy_rx_data),
    .serdes_rx_hdr(phy_rx_hdr),
    .serdes_rx_bitslip(xcvr_rx_bitslip),
    .rx_block_lock(phy_rx_block_lock),
    .rx_high_ber(phy_rx_high_ber)
);

endmodule

`resetall
