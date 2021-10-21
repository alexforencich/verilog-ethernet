/*

Copyright (c) 2020 Alex Forencich

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
     * Clock: 125MHz
     */
    input  wire        CLOCK_50,

    /*
     * GPIO
     */
    input  wire [3:0]  KEY,
    input  wire [17:0] SW,
    output wire [8:0]  LEDG,
    output wire [17:0] LEDR,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5,
    output wire [6:0]  HEX6,
    output wire [6:0]  HEX7,
    output wire [35:0] GPIO,

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    output wire        ENET0_GTX_CLK,
    output wire [3:0]  ENET0_TX_DATA,
    output wire        ENET0_TX_EN,
    input  wire        ENET0_RX_CLK,
    input  wire [3:0]  ENET0_RX_DATA,
    input  wire        ENET0_RX_DV,
    output wire        ENET0_RST_N,
    input  wire        ENET0_INT_N,

    output wire        ENET1_GTX_CLK,
    output wire [3:0]  ENET1_TX_DATA,
    output wire        ENET1_TX_EN,
    input  wire        ENET1_RX_CLK,
    input  wire [3:0]  ENET1_RX_DATA,
    input  wire        ENET1_RX_DV,
    output wire        ENET1_RST_N,
    input  wire        ENET1_INT_N
);

// Clock and reset

// Internal 125 MHz clock
wire clk_int;
wire rst_int;

wire pll_rst = ~KEY[3];
wire pll_locked;

wire clk90_int;

altpll #(
    .bandwidth_type("AUTO"),
    .clk0_divide_by(2),
    .clk0_duty_cycle(50),
    .clk0_multiply_by(5),
    .clk0_phase_shift("0"),
    .clk1_divide_by(2),
    .clk1_duty_cycle(50),
    .clk1_multiply_by(5),
    .clk1_phase_shift("2000"),
    .compensate_clock("CLK0"),
    .inclk0_input_frequency(20000),
    .intended_device_family("Cyclone IV E"),
    .operation_mode("NORMAL"),
    .pll_type("AUTO"),
    .port_activeclock("PORT_UNUSED"),
    .port_areset("PORT_USED"),
    .port_clkbad0("PORT_UNUSED"),
    .port_clkbad1("PORT_UNUSED"),
    .port_clkloss("PORT_UNUSED"),
    .port_clkswitch("PORT_UNUSED"),
    .port_configupdate("PORT_UNUSED"),
    .port_fbin("PORT_UNUSED"),
    .port_inclk0("PORT_USED"),
    .port_inclk1("PORT_UNUSED"),
    .port_locked("PORT_USED"),
    .port_pfdena("PORT_UNUSED"),
    .port_phasecounterselect("PORT_UNUSED"),
    .port_phasedone("PORT_UNUSED"),
    .port_phasestep("PORT_UNUSED"),
    .port_phaseupdown("PORT_UNUSED"),
    .port_pllena("PORT_UNUSED"),
    .port_scanaclr("PORT_UNUSED"),
    .port_scanclk("PORT_UNUSED"),
    .port_scanclkena("PORT_UNUSED"),
    .port_scandata("PORT_UNUSED"),
    .port_scandataout("PORT_UNUSED"),
    .port_scandone("PORT_UNUSED"),
    .port_scanread("PORT_UNUSED"),
    .port_scanwrite("PORT_UNUSED"),
    .port_clk0("PORT_USED"),
    .port_clk1("PORT_USED"),
    .port_clk2("PORT_UNUSED"),
    .port_clk3("PORT_UNUSED"),
    .port_clk4("PORT_UNUSED"),
    .port_clk5("PORT_UNUSED"),
    .port_clkena0("PORT_UNUSED"),
    .port_clkena1("PORT_UNUSED"),
    .port_clkena2("PORT_UNUSED"),
    .port_clkena3("PORT_UNUSED"),
    .port_clkena4("PORT_UNUSED"),
    .port_clkena5("PORT_UNUSED"),
    .port_extclk0("PORT_UNUSED"),
    .port_extclk1("PORT_UNUSED"),
    .port_extclk2("PORT_UNUSED"),
    .port_extclk3("PORT_UNUSED"),
    .self_reset_on_loss_lock("ON"),
    .width_clock(5)
)
altpll_component (
    .areset(pll_rst),
    .inclk({1'b0, CLOCK_50}),
    .clk({clk90_int, clk_int}),
    .locked(pll_locked),
    .activeclock(),
    .clkbad(),
    .clkena({6{1'b1}}),
    .clkloss(),
    .clkswitch(1'b0),
    .configupdate(1'b0),
    .enable0(),
    .enable1(),
    .extclk(),
    .extclkena({4{1'b1}}),
    .fbin(1'b1),
    .fbmimicbidir(),
    .fbout(),
    .fref(),
    .icdrclk(),
    .pfdena(1'b1),
    .phasecounterselect({4{1'b1}}),
    .phasedone(),
    .phasestep(1'b1),
    .phaseupdown(1'b1),
    .pllena(1'b1),
    .scanaclr(1'b0),
    .scanclk(1'b0),
    .scanclkena(1'b1),
    .scandata(1'b0),
    .scandataout(),
    .scandone(),
    .scanread(1'b0),
    .scanwrite(1'b0),
    .sclkout0(),
    .sclkout1(),
    .vcooverrange(),
    .vcounderrange()
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_int),
    .rst(~pll_locked),
    .out(rst_int)
);

// GPIO
wire [3:0] btn_int;
wire [17:0] sw_int;

debounce_switch #(
    .WIDTH(4+18),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_int),
    .rst(rst_int),
    .in({~KEY,
        SW}),
    .out({btn_int,
        sw_int})
);

fpga_core #(
    .TARGET("ALTERA")
)
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk(clk_int),
    .clk90(clk90_int),
    .rst(rst_int),

    /*
     * GPIO
     */
    .btn(btn_int),
    .sw(sw_int),
    .ledg(LEDG),
    .ledr(LEDR),
    .hex0(HEX0),
    .hex1(HEX1),
    .hex2(HEX2),
    .hex3(HEX3),
    .hex4(HEX4),
    .hex5(HEX5),
    .hex6(HEX6),
    .hex7(HEX7),
    .gpio(GPIO),

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    .phy0_rx_clk(ENET0_RX_CLK),
    .phy0_rxd(ENET0_RX_DATA),
    .phy0_rx_ctl(ENET0_RX_DV),
    .phy0_tx_clk(ENET0_GTX_CLK),
    .phy0_txd(ENET0_TX_DATA),
    .phy0_tx_ctl(ENET0_TX_EN),
    .phy0_reset_n(ENET0_RST_N),
    .phy0_int_n(ENET0_INT_N),

    .phy1_rx_clk(ENET1_RX_CLK),
    .phy1_rxd(ENET1_RX_DATA),
    .phy1_rx_ctl(ENET1_RX_DV),
    .phy1_tx_clk(ENET1_GTX_CLK),
    .phy1_txd(ENET1_TX_DATA),
    .phy1_tx_ctl(ENET1_TX_EN),
    .phy1_reset_n(ENET1_RST_N),
    .phy1_int_n(ENET1_INT_N)
);

endmodule

`resetall
