/*

Copyright (c) 2014-2026 Alex Forencich

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
     * Clock: 100MHz
     * Reset: Push button, active low
     */
    input  wire       clk,
    input  wire       reset_n,

    /*
     * GPIO
     */
    output wire [7:0] led,

    /*
     * Ethernet: 100BASE-T RMII (LAN8720A, FPGA-sourced 50 MHz REF_CLK)
     */
    output wire       phy_ref_clk,
    input  wire       phy_crs_dv,
    input  wire [1:0] phy_rxd,
    input  wire       phy_rx_er,
    output wire [1:0] phy_txd,
    output wire       phy_tx_en,
    output wire       phy_reset_n
);

// Clock and reset

wire clk_ibufg;

// Internal 100 MHz logic clock and 50 MHz RMII reference
wire clk_int;
wire clk_50_int;
wire rst_int;

wire mmcm_rst = ~reset_n;
wire mmcm_locked;
wire mmcm_clkfb;

wire clk_mmcm_out;
wire clk_50_mmcm_out;

IBUFG
clk_ibufg_inst(
    .I(clk),
    .O(clk_ibufg)
);

// MMCM instance
// 100 MHz in, 100 MHz + 50 MHz out
// M = 10, D = 1 sets Fvco = 1000 MHz (in 600-1200 MHz range)
// Divide by 10 to get 100 MHz logic clock
// Divide by 20 to get 50 MHz RMII reference clock
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(10),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(20),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk_50_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_bufg_inst (
    .I(clk_mmcm_out),
    .O(clk_int)
);

BUFG
clk_50_bufg_inst (
    .I(clk_50_mmcm_out),
    .O(clk_50_int)
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_int),
    .rst(~mmcm_locked),
    .out(rst_int)
);

// Forward the 50 MHz reference to the PHY
assign phy_ref_clk = clk_50_int;

// RMII TX is source-synchronous (the FPGA forwards REF_CLK), so relaunch TXD/
// TX_EN on the falling edge of REF_CLK to meet the PHY's setup/hold (see the
// rmii_io_timing constraints in fpga.xdc).
wire [1:0] phy_txd_int;
wire       phy_tx_en_int;

(* IOB = "TRUE" *)
reg [1:0] phy_txd_reg = 2'd0;
(* IOB = "TRUE" *)
reg phy_tx_en_reg = 1'b0;

always @(negedge clk_50_int) begin
    phy_txd_reg <= phy_txd_int;
    phy_tx_en_reg <= phy_tx_en_int;
end

assign phy_txd = phy_txd_reg;
assign phy_tx_en = phy_tx_en_reg;

fpga_core #(
    .TARGET("XILINX")
)
core_inst (
    /*
     * Clock: 100MHz logic, 50MHz RMII reference
     * Synchronous reset
     */
    .clk(clk_int),
    .rst(rst_int),
    .ref_clk(clk_50_int),
    /*
     * GPIO
     */
    .led(led),
    /*
     * Ethernet: 100BASE-T RMII
     */
    .phy_crs_dv(phy_crs_dv),
    .phy_rxd(phy_rxd),
    .phy_rx_er(phy_rx_er),
    .phy_txd(phy_txd_int),
    .phy_tx_en(phy_tx_en_int),
    .phy_reset_n(phy_reset_n)
);

endmodule

`resetall
