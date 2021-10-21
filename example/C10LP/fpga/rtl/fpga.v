/*

Copyright (c) 2014-2018 Alex Forencich

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
     * Reset: Push button, active low
     */
    input  wire       enet_clk_125m,
    input  wire       c10_resetn,

    /*
     * GPIO
     */
    input  wire [3:0] user_pb,
    input  wire [2:0] user_dip,
    output wire [3:0] user_led,

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    input  wire       enet_rx_clk,
    input  wire [3:0] enet_rx_d,
    input  wire       enet_rx_dv,
    output wire       enet_tx_clk,
    output wire [3:0] enet_tx_d,
    output wire       enet_tx_en,
    output wire       enet_resetn,
    input  wire       enet_int
);

// Clock and reset

// Internal 125 MHz clock
wire clk_int;
wire rst_int;

wire pll_rst = ~c10_resetn;
wire pll_locked;

wire clk90_int;

altpll #(
    .bandwidth_type("AUTO"),
    .clk0_divide_by(1),
    .clk0_duty_cycle(50),
    .clk0_multiply_by(1),
    .clk0_phase_shift("0"),
    .clk1_divide_by(1),
    .clk1_duty_cycle(50),
    .clk1_multiply_by(1),
    .clk1_phase_shift("2000"),
    .compensate_clock("CLK0"),
    .inclk0_input_frequency(8000),
    .intended_device_family("Cyclone 10 LP"),
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
    .inclk({1'b0, enet_clk_125m}),
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
wire [2:0] sw_int;
wire [3:0] led_int;

debounce_switch #(
    .WIDTH(7),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_int),
    .rst(rst_int),
    .in({user_pb,
        user_dip}),
    .out({btn_int,
        sw_int})
);

assign user_led = ~led_int;

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
    .led(led_int),

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    .phy_rx_clk(enet_rx_clk),
    .phy_rxd(enet_rx_d),
    .phy_rx_ctl(enet_rx_dv),
    .phy_tx_clk(enet_tx_clk),
    .phy_txd(enet_tx_d),
    .phy_tx_ctl(enet_tx_en),
    .phy_reset_n(enet_resetn),
    .phy_int_n(enet_int)
);

endmodule

`resetall
