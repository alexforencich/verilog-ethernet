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

// Language: Verilog 2001

`timescale 1 ns / 1 ps

module fpga_pads (
    /*
     * Pads
     */
    input wire clk_pad,
    input wire reset_n_pad,
    input wire btnu_pad,
    input wire btnl_pad,
    input wire btnd_pad,
    input wire btnr_pad,
    input wire btnc_pad,
    input wire [7:0] sw_pad,
    output wire [7:0] led_pad,
    input wire phy_rx_clk_pad,
    input wire [7:0] phy_rxd_pad,
    input wire phy_rx_dv_pad,
    input wire phy_rx_er_pad,
    output wire phy_gtx_clk_pad,
    output wire [7:0] phy_txd_pad,
    output wire phy_tx_en_pad,
    output wire phy_tx_er_pad,
    output wire phy_reset_n_pad,
    input wire uart_rxd_pad,
    output wire uart_txd_pad,
    /*
     * Internal
     */
    output wire clk_int,
    output wire rst_int,
    output wire btnu_int,
    output wire btnl_int,
    output wire btnd_int,
    output wire btnr_int,
    output wire btnc_int,
    output wire [7:0] sw_int,
    input wire [7:0] led_int,
    output wire phy_rx_clk_int,
    output wire [7:0] phy_rxd_int,
    output wire phy_rx_dv_int,
    output wire phy_rx_er_int,
    input wire phy_gtx_clk_int,
    input wire [7:0] phy_txd_int,
    input wire phy_tx_en_int,
    input wire phy_tx_er_int,
    input wire phy_reset_n_int,
    output wire uart_rxd_int,
    input wire uart_txd_int
);

wire clk_valid;
/*
 * Asynchronous reset created by from the combination of the external
 * asyncrhonous reset input and the DCM clk_valid output.
 */
wire reset0 = ~reset_n_pad;
wire reset1 = ~clk_valid;

/*
 * Create a 125MHz clock from a 100MHz clock.
 */
dcm_i100_o125
dcm_inst (
    .CLK_IN1(clk_pad),      // IN(1)
    .RESET(reset0),         // IN(1)
    .CLK_OUT1(clk_int),     // OUT(1)
    .LOCKED(clk_valid)      // OUT(1)
);

/*
 * Create a synchronous reset in the 125MHz domain.
 */
sync_reset #(
    .N(6)
)
sync_reset_inst (
    .clk(clk_int),           // IN(1)
    .rst(reset1),            // IN(1)
    .sync_reset_out(rst_int) // OUT(1)
);

/*
 * Synchronize the inputs.
 */
sync_signal #(
    .WIDTH(1),
    .N(2)
)
sync_signal_inst (
    .clk(clk_int),  //IN(1)
    .in({uart_rxd_pad}), //IN(1)
    .out({uart_rxd_int}) // OUT(1)
);

/*
 * Debounce the switches
 */
debounce_switch #(
    .WIDTH(13),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_int),          // IN(1)
    .rst(rst_int),          // IN(1)
    .in({btnu_pad,
        btnl_pad,
        btnd_pad,
        btnr_pad,
        btnc_pad,
        sw_pad}),       // IN(13)
    .out({btnu_int,
        btnl_int,
        btnd_int,
        btnr_int,
        btnc_int,
        sw_int})     // OUT(13)
);

/*
 * PHY inputs not synchronized here
 */
assign phy_rx_clk_int = phy_rx_clk_pad;
assign phy_rxd_int = phy_rxd_pad;
assign phy_rx_dv_int = phy_rx_dv_pad;
assign phy_rx_er_int = phy_rx_er_pad;

/*
 * PHY outputs not synchronized here
 */
assign phy_gtx_clk_pad = phy_gtx_clk_int;
assign phy_txd_pad = phy_txd_int;
assign phy_tx_en_pad = phy_tx_en_int;
assign phy_tx_er_pad = phy_tx_er_int;
assign phy_reset_n_pad = phy_reset_n_int;

/*
 * Outputs not synchronized here
 */
assign led_pad = led_int;
assign uart_txd_pad = uart_txd_int;

endmodule
