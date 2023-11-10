/*

Copyright (c) 2023 Alex Forencich

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
 * Testbench top-level module
 */
module test_fpga_core #
(
    parameter SW_CNT = 4,
    parameter LED_CNT = 3,
    parameter UART_CNT = 1,
    parameter QSFP_CNT = 2,
    parameter CH_CNT = QSFP_CNT*4
)
(
    input wire                   clk,
    input wire                   rst,

    /*
     * GPIO
     */
    input  wire [SW_CNT-1:0]     sw,
    output wire [LED_CNT-1:0]    led,
    output wire [QSFP_CNT-1:0]   qsfp_led_act,
    output wire [QSFP_CNT-1:0]   qsfp_led_stat_g,
    output wire [QSFP_CNT-1:0]   qsfp_led_stat_y,

    /*
     * UART
     */
    output wire [UART_CNT-1:0]   uart_txd,
    input  wire [UART_CNT-1:0]   uart_rxd
);

genvar n;

// XGMII 10G PHY
wire [CH_CNT-1:0]     eth_tx_clk;
wire [CH_CNT-1:0]     eth_tx_rst;
wire [CH_CNT*64-1:0]  eth_txd;
wire [CH_CNT*8-1:0]   eth_txc;
wire [CH_CNT-1:0]     eth_rx_clk;
wire [CH_CNT-1:0]     eth_rx_rst;
wire [CH_CNT*64-1:0]  eth_rxd;
wire [CH_CNT*8-1:0]   eth_rxc;

generate

for (n = 0; n < CH_CNT; n = n + 1) begin : ch

    wire         ch_tx_clk;
    wire         ch_tx_rst;
    wire [63:0]  ch_txd;
    wire [7:0]   ch_txc;
    wire         ch_rx_clk;
    wire         ch_rx_rst;
    wire [63:0]  ch_rxd;
    wire [7:0]   ch_rxc;

    assign eth_tx_clk[n +: 1] = ch_tx_clk;
    assign eth_tx_rst[n +: 1] = ch_tx_rst;
    assign ch_txd = eth_txd[n*64 +: 64];
    assign ch_txc = eth_txc[n*8 +: 8];
    assign eth_rx_clk[n +: 1] = ch_rx_clk;
    assign eth_rx_rst[n +: 1] = ch_rx_rst;
    assign eth_rxd[n*64 +: 64] = ch_rxd;
    assign eth_rxc[n*8 +: 8] = ch_rxc;

end

endgenerate

fpga_core #(
    .SW_CNT(SW_CNT),
    .LED_CNT(LED_CNT),
    .UART_CNT(UART_CNT),
    .QSFP_CNT(QSFP_CNT),
    .CH_CNT(CH_CNT)
)
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk),
    .rst(rst),

    /*
     * GPIO
     */
    .sw(sw),
    .led(led),
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
