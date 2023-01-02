/*

Copyright (c) 2014-2023 Alex Forencich

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
     * Clock: 25 MHz
     */
    input  wire       clk_25mhz,
    /*
     * GPIO
     */
    output wire       led,
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    input  wire       phy_0_rx_clk,
    input  wire [3:0] phy_0_rxd,
    input  wire       phy_0_rx_ctl,
    output wire       phy_0_tx_clk,
    output wire [3:0] phy_0_txd,
    output wire       phy_0_tx_ctl,

    input  wire       phy_1_rx_clk,
    input  wire [3:0] phy_1_rxd,
    input  wire       phy_1_rx_ctl,
    output wire       phy_1_tx_clk,
    output wire [3:0] phy_1_txd,
    output wire       phy_1_tx_ctl
);

// Clock and reset

// Internal 125 MHz clock
wire clk_125mhz_pll_out;
wire clk_125mhz_int;
wire clk90_125mhz_pll_out;
wire clk90_125mhz_int;
wire rst_125mhz_int;

wire pll_rst = 0;
wire pll_locked;
wire pll_clkfb;

// PLL instance
// 25 MHz in, 125 MHz out
// PFD range: 19 MHz to 400 MHz
// VCO range: 400 MHz to 1000 MHz
// M = 40, D = 1 sets Fvco = 1000
// Divide by 8 to get output frequency of 125 MHz
PLL_BASE #(
    .COMPENSATION(),
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE(8),
    .CLKOUT0_DUTY_CYCLE(0.50),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_DIVIDE(8),
    .CLKOUT1_DUTY_CYCLE(0.50),
    .CLKOUT1_PHASE(90.0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.50),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.50),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.50),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.50),
    .CLKOUT5_PHASE(0.0),
    .CLKFBOUT_MULT(40),
    .CLKFBOUT_PHASE(0.0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER(0.100),
    .CLKIN_PERIOD(25.0),
    .CLK_FEEDBACK("CLKFBOUT"),
    .RESET_ON_LOSS_OF_LOCK("FALSE")
)
clk_pll_inst (
    .CLKIN(clk_25mhz),
    .CLKFBIN(pll_clkfb),
    .RST(pll_rst),
    .CLKOUT0(clk_125mhz_pll_out),
    .CLKOUT1(clk90_125mhz_pll_out),
    .CLKOUT2(),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKFBOUT(pll_clkfb),
    .LOCKED(pll_locked)
);

BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_pll_out),
    .O(clk_125mhz_int)
);

BUFG
clk90_125mhz_bufg_inst (
    .I(clk90_125mhz_pll_out),
    .O(clk90_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~pll_locked),
    .out(rst_125mhz_int)
);

// GPIO
wire led_int;

assign led = led_int;

// IODELAY elements for RGMII interface to PHY
generate

genvar n;

// 2 ns delay (40 taps at about 50 ps/tap)
localparam PHY_0_RX_DELAY_TAPS = 40;

wire [3:0] phy_0_rxd_delay;
wire       phy_0_rx_ctl_delay;

IODELAY2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(PHY_0_RX_DELAY_TAPS),
    .ODELAY_VALUE(PHY_0_RX_DELAY_TAPS),
    .DELAY_SRC("IDATAIN")
)
phy_0_rx_ctl_idelay_inst (
    .DATAOUT(phy_0_rx_ctl_delay),
    .CAL(0),
    .CE(0),
    .CLK(0),
    .IDATAIN(phy_0_rx_ctl),
    .INC(0),
    .IOCLK0(0),
    .IOCLK1(0),
    .ODATAIN(0),
    .RST(0),
    .T(1)
);

for (n = 0; n < 4; n = n + 1) begin : phy_0_rxd_delay_ch
    
    IODELAY2 #(
        .IDELAY_TYPE("FIXED"),
        .IDELAY_VALUE(PHY_0_RX_DELAY_TAPS),
        .ODELAY_VALUE(PHY_0_RX_DELAY_TAPS),
        .DELAY_SRC("IDATAIN")
    )
    phy_0_rxd_idelay_inst (
        .DATAOUT(phy_0_rxd_delay[n]),
        .CAL(0),
        .CE(0),
        .CLK(0),
        .IDATAIN(phy_0_rxd[n]),
        .INC(0),
        .IOCLK0(0),
        .IOCLK1(0),
        .ODATAIN(0),
        .RST(0),
        .T(1)
    );

end

// 2 ns delay (40 taps at about 50 ps/tap)
localparam PHY_1_RX_DELAY_TAPS = 40;

wire [3:0] phy_1_rxd_delay;
wire       phy_1_rx_ctl_delay;

IODELAY2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(PHY_1_RX_DELAY_TAPS),
    .ODELAY_VALUE(PHY_1_RX_DELAY_TAPS),
    .DELAY_SRC("IDATAIN")
)
phy_1_rx_ctl_idelay_inst (
    .DATAOUT(phy_1_rx_ctl_delay),
    .CAL(0),
    .CE(0),
    .CLK(0),
    .IDATAIN(phy_1_rx_ctl),
    .INC(0),
    .IOCLK0(0),
    .IOCLK1(0),
    .ODATAIN(0),
    .RST(0),
    .T(1)
);

for (n = 0; n < 4; n = n + 1) begin : phy_1_rxd_delay_ch
    
    IODELAY2 #(
        .IDELAY_TYPE("FIXED"),
        .IDELAY_VALUE(PHY_1_RX_DELAY_TAPS),
        .ODELAY_VALUE(PHY_1_RX_DELAY_TAPS),
        .DELAY_SRC("IDATAIN")
    )
    phy_1_rxd_idelay_inst (
        .DATAOUT(phy_1_rxd_delay[n]),
        .CAL(0),
        .CE(0),
        .CLK(0),
        .IDATAIN(phy_1_rxd[n]),
        .INC(0),
        .IOCLK0(0),
        .IOCLK1(0),
        .ODATAIN(0),
        .RST(0),
        .T(1)
    );

end

endgenerate

fpga_core #(
    .TARGET("XILINX"),
    .USE_CLK90("FALSE")
)
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk_125mhz(clk_125mhz_int),
    .clk90_125mhz(clk90_125mhz_int),
    .rst_125mhz(rst_125mhz_int),
    /*
     * GPIO
     */
    .led(led_int),
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    .phy_0_rx_clk(phy_0_rx_clk),
    .phy_0_rxd(phy_0_rxd_delay),
    .phy_0_rx_ctl(phy_0_rx_ctl_delay),
    .phy_0_tx_clk(phy_0_tx_clk),
    .phy_0_txd(phy_0_txd),
    .phy_0_tx_ctl(phy_0_tx_ctl),

    .phy_1_rx_clk(phy_1_rx_clk),
    .phy_1_rxd(phy_1_rxd_delay),
    .phy_1_rx_ctl(phy_1_rx_ctl_delay),
    .phy_1_tx_clk(phy_1_tx_clk),
    .phy_1_txd(phy_1_txd),
    .phy_1_tx_ctl(phy_1_tx_ctl)
);

endmodule

`resetall
