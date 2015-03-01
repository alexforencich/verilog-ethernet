/*

Copyright (c) 2014 Alex Forencich

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

module fpga (
    /*
     * Clock: 100MHz
     * Reset: Push button, active low
     */
    input wire clk,
    input wire reset_n,
    /*
     * GPIO
     */
    input wire btnu,
    input wire btnl,
    input wire btnd,
    input wire btnr,
    input wire btnc,
    input wire [7:0] sw,
    output wire [7:0] led,
    /*
     * Ethernet: 1000BASE-T GMII
     */
    input wire phy_rx_clk,
    input wire [7:0] phy_rxd,
    input wire phy_rx_dv,
    input wire phy_rx_er,
    output wire phy_gtx_clk,
    output wire [7:0] phy_txd,
    output wire phy_tx_en,
    output wire phy_tx_er,
    output wire phy_reset_n,
    /*
     * UART: 500000 bps, 8N1
     */
    input wire uart_rxd,
    output wire uart_txd
);

/*
 * Clock: 125MHz
 * Synchronous reset
 */
wire clk_int;
wire rst_int;
/*
 * GPIO
 */
wire btnu_int;
wire btnl_int;
wire btnd_int;
wire btnr_int;
wire btnc_int;
wire [7:0] sw_int;
wire [7:0] led_int;
/*
 * Ethernet: 1000BASE-T GMII
 */
wire phy_rx_clk_int;
wire [7:0] phy_rxd_int;
wire phy_rx_dv_int;
wire phy_rx_er_int;
wire phy_gtx_clk_int;
wire [7:0] phy_txd_int;
wire phy_tx_en_int;
wire phy_tx_er_int;
wire phy_reset_n_int;
/*
 * UART: 115200 bps, 8N1
 */
wire uart_rxd_int;
wire uart_txd_int;

fpga_core
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk(clk_int),
    .rst(rst_int),
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
     * Ethernet: 1000BASE-T GMII
     */
    .phy_rx_clk(phy_rx_clk_int),
    .phy_rxd(phy_rxd_int),
    .phy_rx_dv(phy_rx_dv_int),
    .phy_rx_er(phy_rx_er_int),
    .phy_gtx_clk(phy_gtx_clk_int),
    .phy_txd(phy_txd_int),
    .phy_tx_en(phy_tx_en_int),
    .phy_tx_er(phy_tx_er_int),
    .phy_reset_n(phy_reset_n_int),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd_int)
);

fpga_pads
pads_inst (
    /*
     * Pads
     */
    .clk_pad(clk),
    .reset_n_pad(reset_n),
    .btnu_pad(btnu),
    .btnl_pad(btnl),
    .btnd_pad(btnd),
    .btnr_pad(btnr),
    .btnc_pad(btnc),
    .sw_pad(sw),
    .led_pad(led),
    .phy_rx_clk_pad(phy_rx_clk),
    .phy_rxd_pad(phy_rxd),
    .phy_rx_dv_pad(phy_rx_dv),
    .phy_rx_er_pad(phy_rx_er),
    .phy_gtx_clk_pad(phy_gtx_clk),
    .phy_txd_pad(phy_txd),
    .phy_tx_en_pad(phy_tx_en),
    .phy_tx_er_pad(phy_tx_er),
    .phy_reset_n_pad(phy_reset_n),
    .uart_rxd_pad(uart_rxd),
    .uart_txd_pad(uart_txd),
    /*
     * Internal
     */
    .clk_int(clk_int),
    .rst_int(rst_int),
    .btnu_int(btnu_int),
    .btnl_int(btnl_int),
    .btnd_int(btnd_int),
    .btnr_int(btnr_int),
    .btnc_int(btnc_int),
    .sw_int(sw_int),
    .led_int(led_int),
    .phy_rx_clk_int(phy_rx_clk_int),
    .phy_rxd_int(phy_rxd_int),
    .phy_rx_dv_int(phy_rx_dv_int),
    .phy_rx_er_int(phy_rx_er_int),
    .phy_gtx_clk_int(phy_gtx_clk_int),
    .phy_txd_int(phy_txd_int),
    .phy_tx_en_int(phy_tx_en_int),
    .phy_tx_er_int(phy_tx_er_int),
    .phy_reset_n_int(phy_reset_n_int),
    .uart_rxd_int(uart_rxd_int),
    .uart_txd_int(uart_txd_int)
);

endmodule
