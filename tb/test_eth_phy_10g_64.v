/*

Copyright (c) 2018 Alex Forencich

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

`timescale 1ns / 1ps

/*
 * Testbench for eth_phy_10g
 */
module test_eth_phy_10g_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = 2;
parameter BIT_REVERSE = 0;
parameter SCRAMBLER_DISABLE = 0;
parameter PRBS31_ENABLE = 1;
parameter TX_SERDES_PIPELINE = 2;
parameter RX_SERDES_PIPELINE = 2;
parameter BITSLIP_HIGH_CYCLES = 1;
parameter BITSLIP_LOW_CYCLES = 8;
parameter COUNT_125US = 125000/6.4;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg rx_clk = 0;
reg rx_rst = 0;
reg tx_clk = 0;
reg tx_rst = 0;
reg [DATA_WIDTH-1:0] xgmii_txd = 0;
reg [CTRL_WIDTH-1:0] xgmii_txc = 0;
reg [DATA_WIDTH-1:0] serdes_rx_data = 0;
reg [HDR_WIDTH-1:0] serdes_rx_hdr = 1;
reg tx_prbs31_enable = 0;
reg rx_prbs31_enable = 0;

// Outputs
wire [DATA_WIDTH-1:0] xgmii_rxd;
wire [CTRL_WIDTH-1:0] xgmii_rxc;
wire [DATA_WIDTH-1:0] serdes_tx_data;
wire [HDR_WIDTH-1:0] serdes_tx_hdr;
wire serdes_rx_bitslip;
wire [6:0] rx_error_count;
wire rx_bad_block;
wire rx_block_lock;
wire rx_high_ber;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        rx_clk,
        rx_rst,
        tx_clk,
        tx_rst,
        xgmii_txd,
        xgmii_txc,
        serdes_rx_data,
        serdes_rx_hdr,
        tx_prbs31_enable,
        rx_prbs31_enable
    );
    $to_myhdl(
        xgmii_rxd,
        xgmii_rxc,
        serdes_tx_data,
        serdes_tx_hdr,
        serdes_rx_bitslip,
        rx_error_count,
        rx_bad_block,
        rx_block_lock,
        rx_high_ber
    );

    // dump file
    $dumpfile("test_eth_phy_10g_64.lxt");
    $dumpvars(0, test_eth_phy_10g_64);
end

eth_phy_10g #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .BIT_REVERSE(BIT_REVERSE),
    .SCRAMBLER_DISABLE(SCRAMBLER_DISABLE),
    .PRBS31_ENABLE(PRBS31_ENABLE),
    .TX_SERDES_PIPELINE(TX_SERDES_PIPELINE),
    .RX_SERDES_PIPELINE(RX_SERDES_PIPELINE),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES),
    .COUNT_125US(COUNT_125US)
)
UUT (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .serdes_tx_data(serdes_tx_data),
    .serdes_tx_hdr(serdes_tx_hdr),
    .serdes_rx_data(serdes_rx_data),
    .serdes_rx_hdr(serdes_rx_hdr),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .rx_error_count(rx_error_count),
    .rx_bad_block(rx_bad_block),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber),
    .tx_prbs31_enable(tx_prbs31_enable),
    .rx_prbs31_enable(rx_prbs31_enable)
);

endmodule
