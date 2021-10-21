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
     * Clock: 200MHz
     * Reset: Push button, active high
     */
    input  wire       sys_clk_p,
    input  wire       sys_clk_n,
    input  wire       reset,
    /*
     * GPIO
     */
    input  wire       btnu,
    input  wire       btnl,
    input  wire       btnd,
    input  wire       btnr,
    input  wire       btnc,
    input  wire [7:0] sw,
    output wire       ledu,
    output wire       ledl,
    output wire       ledd,
    output wire       ledr,
    output wire       ledc,
    output wire [7:0] led,
    /*
     * Ethernet: 1000BASE-T SGMII
     */
    input  wire       phy_sgmii_rx_p,
    input  wire       phy_sgmii_rx_n,
    output wire       phy_sgmii_tx_p,
    output wire       phy_sgmii_tx_n,
    input  wire       phy_sgmii_clk_p,
    input  wire       phy_sgmii_clk_n,
    output wire       phy_reset_n,
    /*
     * Silicon Labs CP2103 USB UART
     */
    output wire       uart_rxd,
    input  wire       uart_txd,
    input  wire       uart_rts,
    output wire       uart_cts
);

// Clock and reset

wire sys_clk_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS
clk_ibufgds_inst(
    .I(sys_clk_p),
    .IB(sys_clk_n),
    .O(sys_clk_ibufg)
);

// MMCM instance
// 200 MHz in, 125 MHz out
// PFD range: 10 MHz to 450 MHz
// VCO range: 600 MHz to 1200 MHz
// M = 5, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCM_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(1),
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
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.100),
    .CLKIN1_PERIOD(5.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(sys_clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
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
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked),
    .out(rst_125mhz_int)
);

// GPIO
wire btnu_int;
wire btnl_int;
wire btnd_int;
wire btnr_int;
wire btnc_int;
wire [7:0] sw_int;

wire ledu_int;
wire ledl_int;
wire ledd_int;
wire ledr_int;
wire ledc_int;
wire [7:0] led_int;

wire uart_rxd_int;
wire uart_txd_int;
wire uart_rts_int;
wire uart_cts_int;

debounce_switch #(
    .WIDTH(13),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw}),
    .out({btnu_int,
        btnl_int,
        btnd_int,
        btnr_int,
        btnc_int,
        sw_int})
);

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_125mhz_int),
    .in({uart_txd,
        uart_rts}),
    .out({uart_txd_int,
        uart_rts_int})
);

assign ledu = ledu_int;
assign ledl = ledl_int;
assign ledd = ledd_int;
assign ledr = ledr_int;
assign ledc = ledc_int;
//assign led = led_int;

assign uart_rxd = uart_rxd_int;
assign uart_cts = uart_cts_int;

// SGMII interface to PHY
wire phy_gmii_clk_int;
wire phy_gmii_rst_int;
wire phy_gmii_clk_en_int;
wire [7:0] phy_gmii_txd_int;
wire phy_gmii_tx_en_int;
wire phy_gmii_tx_er_int;
wire [7:0] phy_gmii_rxd_int;
wire phy_gmii_rx_dv_int;
wire phy_gmii_rx_er_int;

wire phy_sgmii_mgtrefclk;
wire phy_sgmii_txoutclk;
wire phy_sgmii_userclk2;

IBUFDS_GTXE1
phy_sgmii_ibufds_mgtrefclk (
    .CEB   (1'b0),
    .I     (phy_sgmii_clk_p),
    .IB    (phy_sgmii_clk_n),
    .O     (phy_sgmii_mgtrefclk),
    .ODIV2 ()
);

BUFG
phy_sgmii_bufg_userclk2 (
    .I     (phy_sgmii_txoutclk),
    .O     (phy_sgmii_userclk2)
);

assign phy_gmii_clk_int = phy_sgmii_userclk2;

sync_reset #(
    .N(4)
)
sync_reset_pcspma_inst (
    .clk(phy_gmii_clk_int),
    .rst(rst_125mhz_int),
    .out(phy_gmii_rst_int)
);

wire [15:0] pcspma_status_vector;

wire pcspma_status_link_status              = pcspma_status_vector[0];
wire pcspma_status_link_synchronization     = pcspma_status_vector[1];
wire pcspma_status_rudi_c                   = pcspma_status_vector[2];
wire pcspma_status_rudi_i                   = pcspma_status_vector[3];
wire pcspma_status_rudi_invalid             = pcspma_status_vector[4];
wire pcspma_status_rxdisperr                = pcspma_status_vector[5];
wire pcspma_status_rxnotintable             = pcspma_status_vector[6];
wire pcspma_status_phy_link_status          = pcspma_status_vector[7];
wire [1:0] pcspma_status_remote_fault_encdg = pcspma_status_vector[9:8];
wire [1:0] pcspma_status_speed              = pcspma_status_vector[11:10];
wire pcspma_status_duplex                   = pcspma_status_vector[12];
wire pcspma_status_remote_fault             = pcspma_status_vector[13];
wire [1:0] pcspma_status_pause              = pcspma_status_vector[15:14];

wire [4:0] pcspma_config_vector;

assign pcspma_config_vector[4] = 1'b1; // autonegotiation enable
assign pcspma_config_vector[3] = 1'b0; // isolate
assign pcspma_config_vector[2] = 1'b0; // power down
assign pcspma_config_vector[1] = 1'b0; // loopback enable
assign pcspma_config_vector[0] = 1'b0; // unidirectional enable

wire [15:0] pcspma_an_config_vector;

assign pcspma_an_config_vector[15]    = 1'b1;    // SGMII link status
assign pcspma_an_config_vector[14]    = 1'b1;    // SGMII Acknowledge
assign pcspma_an_config_vector[13:12] = 2'b01;   // full duplex
assign pcspma_an_config_vector[11:10] = 2'b10;   // SGMII speed
assign pcspma_an_config_vector[9]     = 1'b0;    // reserved
assign pcspma_an_config_vector[8:7]   = 2'b00;   // pause frames - SGMII reserved
assign pcspma_an_config_vector[6]     = 1'b0;    // reserved
assign pcspma_an_config_vector[5]     = 1'b0;    // full duplex - SGMII reserved
assign pcspma_an_config_vector[4:1]   = 4'b0000; // reserved
assign pcspma_an_config_vector[0]     = 1'b1;    // SGMII

gig_eth_pcs_pma_v11_5_block
eth_pcspma (
    // Transceiver Interface
    .mgtrefclk             (phy_sgmii_mgtrefclk),
    .gtx_reset_clk         (clk_125mhz_int),
    .txp                   (phy_sgmii_tx_p),
    .txn                   (phy_sgmii_tx_n),
    .rxp                   (phy_sgmii_rx_p),
    .rxn                   (phy_sgmii_rx_n),
    .txoutclk              (phy_sgmii_txoutclk),
    .userclk2              (phy_sgmii_userclk2),
    .pma_reset             (rst_125mhz_int),
    // GMII Interface
    .sgmii_clk_r           (),
    .sgmii_clk_f           (),
    .sgmii_clk_en          (phy_gmii_clk_en_int),
    .gmii_txd              (phy_gmii_txd_int),
    .gmii_tx_en            (phy_gmii_tx_en_int),
    .gmii_tx_er            (phy_gmii_tx_er_int),
    .gmii_rxd              (phy_gmii_rxd_int),
    .gmii_rx_dv            (phy_gmii_rx_dv_int),
    .gmii_rx_er            (phy_gmii_rx_er_int),
    .gmii_isolate          (),
    // Management: Alternative to MDIO Interface
    .configuration_vector  (pcspma_config_vector),
    .an_interrupt          (),
    .an_adv_config_vector  (pcspma_an_config_vector),
    .an_restart_config     (1'b0),
    .link_timer_value      (9'd50),
    // Speed Control
    .speed_is_10_100       (pcspma_status_speed != 2'b10),
    .speed_is_100          (pcspma_status_speed == 2'b01),
    // General IO's
    .status_vector         (pcspma_status_vector),
    .reset                 (rst_125mhz_int),
    .signal_detect         (1'b1)
);

// SGMII interface debug:
// SW1:1 (sw[0]) off for payload byte, on for status vector
// SW1:2 (sw[1]) off for LSB of status vector, on for MSB
assign led = sw[7] ? (sw[6] ? pcspma_status_vector[15:8] : pcspma_status_vector[7:0]) : led_int;

fpga_core
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk_125mhz(clk_125mhz_int),
    .rst_125mhz(rst_125mhz_int),
    /*
     * GPIO
     */
    .btnu(btnu_int),
    .btnl(btnl_int),
    .btnd(btnd_int),
    .btnr(btnr_int),
    .btnc(btnc_int),
    .sw(sw_int),
    .ledu(ledu_int),
    .ledl(ledl_int),
    .ledd(ledd_int),
    .ledr(ledr_int),
    .ledc(ledc_int),
    .led(led_int),
    /*
     * Ethernet: 1000BASE-T SGMII
     */
    .phy_gmii_clk(phy_gmii_clk_int),
    .phy_gmii_rst(phy_gmii_rst_int),
    .phy_gmii_clk_en(phy_gmii_clk_en_int),
    .phy_gmii_rxd(phy_gmii_rxd_int),
    .phy_gmii_rx_dv(phy_gmii_rx_dv_int),
    .phy_gmii_rx_er(phy_gmii_rx_er_int),
    .phy_gmii_txd(phy_gmii_txd_int),
    .phy_gmii_tx_en(phy_gmii_tx_en_int),
    .phy_gmii_tx_er(phy_gmii_tx_er_int),
    .phy_reset_n(phy_reset_n),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd_int),
    .uart_rts(uart_rts_int),
    .uart_cts(uart_cts_int)
);

endmodule

`resetall
