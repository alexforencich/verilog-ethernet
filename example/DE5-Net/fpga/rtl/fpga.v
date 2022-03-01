/*

Copyright (c) 2016-2018 Alex Forencich

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
    // CPU reset button
    input  wire        CPU_RESET_n,
    // buttons
    input  wire [3:0]  BUTTON,
    input  wire [3:0]  SW,
    // LEDs
    output wire [6:0]  HEX0_D,
    output wire        HEX0_DP,
    output wire [6:0]  HEX1_D,
    output wire        HEX1_DP,
    output wire [3:0]  LED,
    output wire [3:0]  LED_BRACKET,
    output wire        LED_RJ45_L,
    output wire        LED_RJ45_R,
    // Temperature control
    //inout wire        TEMP_CLK,
    //inout wire        TEMP_DATA,
    //input wire        TEMP_INT_n,
    //input wire        TEMP_OVERT_n,
    output wire        FAN_CTRL,
    // 50 MHz clock inputs
    input  wire        OSC_50_B3B,
    input  wire        OSC_50_B3D,
    input  wire        OSC_50_B4A,
    input  wire        OSC_50_B4D,
    input  wire        OSC_50_B7A,
    input  wire        OSC_50_B7D,
    input  wire        OSC_50_B8A,
    input  wire        OSC_50_B8D,
    // PCIe interface
    //input  wire        PCIE_PERST_n,
    //input  wire        PCIE_REFCLK_p,
    //input  wire [7:0]  PCIE_RX_p,
    //output wire [7:0]  PCIE_TX_p,
    //input  wire        PCIE_WAKE_n,
    //inout  wire        PCIE_SMBCLK,
    //inout  wire        PCIE_SMBDAT,
    // Si570
    inout  wire        CLOCK_SCL,
    inout  wire        CLOCK_SDA,
    // 10G Ethernet
    input  wire        SFPA_LOS,
    input  wire        SFPA_TXFAULT,
    input  wire        SFPA_MOD0_PRESNT_n,
    inout  wire        SFPA_MOD1_SCL,
    inout  wire        SFPA_MOD2_SDA,
    output wire        SFPA_TXDISABLE,
    output wire [1:0]  SPFA_RATESEL,
    input  wire        SFPA_RX_p,
    output wire        SFPA_TX_p,
    input  wire        SFPB_LOS,
    input  wire        SFPB_TXFAULT,
    input  wire        SFPB_MOD0_PRESNT_n,
    inout  wire        SFPB_MOD1_SCL,
    inout  wire        SFPB_MOD2_SDA,
    output wire        SFPB_TXDISABLE,
    output wire [1:0]  SPFB_RATESEL,
    input  wire        SFPB_RX_p,
    output wire        SFPB_TX_p,
    input  wire        SFPC_LOS,
    input  wire        SFPC_TXFAULT,
    input  wire        SFPC_MOD0_PRESNT_n,
    inout  wire        SFPC_MOD1_SCL,
    inout  wire        SFPC_MOD2_SDA,
    output wire        SFPC_TXDISABLE,
    output wire [1:0]  SPFC_RATESEL,
    input  wire        SFPC_RX_p,
    output wire        SFPC_TX_p,
    input  wire        SFPD_LOS,
    input  wire        SFPD_TXFAULT,
    input  wire        SFPD_MOD0_PRESNT_n,
    inout  wire        SFPD_MOD1_SCL,
    inout  wire        SFPD_MOD2_SDA,
    output wire        SFPD_TXDISABLE,
    output wire [1:0]  SPFD_RATESEL,
    input  wire        SFPD_RX_p,
    output wire        SFPD_TX_p,
    input  wire        SFP_REFCLK_P
);

// Clock and reset

wire clk_50mhz = OSC_50_B3B;
wire rst_50mhz;

sync_reset #(
    .N(4)
)
sync_reset_50mhz_inst (
    .clk(clk_50mhz),
    .rst(~CPU_RESET_n),
    .out(rst_50mhz)
);

wire clk_156mhz;
wire rst_156mhz;

wire phy_pll_locked;

sync_reset #(
    .N(4)
)
sync_reset_156mhz_inst (
    .clk(clk_156mhz),
    .rst(rst_50mhz | ~phy_pll_locked),
    .out(rst_156mhz)
);

// GPIO

wire [3:0] btn_int;
wire [3:0] sw_int;
wire [3:0] led_int;
wire [3:0] led_bkt_int;
wire [6:0] led_hex0_d_int;
wire led_hex0_dp_int;
wire [6:0] led_hex1_d_int;
wire led_hex1_dp_int;

debounce_switch #(
    .WIDTH(8),
    .N(4),
    .RATE(156250)
)
debounce_switch_inst (
    .clk(clk_156mhz),
    .rst(rst_156mhz),
    .in({BUTTON,
        SW}),
    .out({btn_int,
        sw_int})
);

assign LED = ~led_int;
assign LED_BRACKET = ~led_bkt_int;
assign HEX0_D = ~led_hex0_d_int;
assign HEX0_DP = ~led_hex0_dp_int;
assign HEX1_D = ~led_hex1_d_int;
assign HEX1_DP = ~led_hex1_dp_int;

assign FAN_CTRL = 1;

// Si570 oscillator I2C init

wire si570_scl_i;
wire si570_scl_o;
wire si570_scl_t;
wire si570_sda_i;
wire si570_sda_o;
wire si570_sda_t;

assign si570_sda_i = CLOCK_SDA;
assign CLOCK_SDA = si570_sda_t ? 1'bz : si570_sda_o;
assign si570_scl_i = CLOCK_SCL;
assign CLOCK_SCL = si570_scl_t ? 1'bz : si570_scl_o;

wire [6:0] si570_i2c_cmd_address;
wire si570_i2c_cmd_start;
wire si570_i2c_cmd_read;
wire si570_i2c_cmd_write;
wire si570_i2c_cmd_write_multiple;
wire si570_i2c_cmd_stop;
wire si570_i2c_cmd_valid;
wire si570_i2c_cmd_ready;

wire [7:0] si570_i2c_data;
wire si570_i2c_data_valid;
wire si570_i2c_data_ready;
wire si570_i2c_data_last;

si570_i2c_init
si570_i2c_init_inst (
    .clk(clk_50mhz),
    .rst(rst_50mhz),
    .cmd_address(si570_i2c_cmd_address),
    .cmd_start(si570_i2c_cmd_start),
    .cmd_read(si570_i2c_cmd_read),
    .cmd_write(si570_i2c_cmd_write),
    .cmd_write_multiple(si570_i2c_cmd_write_multiple),
    .cmd_stop(si570_i2c_cmd_stop),
    .cmd_valid(si570_i2c_cmd_valid),
    .cmd_ready(si570_i2c_cmd_ready),
    .data_out(si570_i2c_data),
    .data_out_valid(si570_i2c_data_valid),
    .data_out_ready(si570_i2c_data_ready),
    .data_out_last(si570_i2c_data_last),
    .busy(),
    .start(1)
);

i2c_master
si570_i2c_master_inst (
    .clk(clk_50mhz),
    .rst(rst_50mhz),
    .cmd_address(si570_i2c_cmd_address),
    .cmd_start(si570_i2c_cmd_start),
    .cmd_read(si570_i2c_cmd_read),
    .cmd_write(si570_i2c_cmd_write),
    .cmd_write_multiple(si570_i2c_cmd_write_multiple),
    .cmd_stop(si570_i2c_cmd_stop),
    .cmd_valid(si570_i2c_cmd_valid),
    .cmd_ready(si570_i2c_cmd_ready),
    .data_in(si570_i2c_data),
    .data_in_valid(si570_i2c_data_valid),
    .data_in_ready(si570_i2c_data_ready),
    .data_in_last(si570_i2c_data_last),
    .data_out(),
    .data_out_valid(),
    .data_out_ready(1),
    .data_out_last(),
    .scl_i(si570_scl_i),
    .scl_o(si570_scl_o),
    .scl_t(si570_scl_t),
    .sda_i(si570_sda_i),
    .sda_o(si570_sda_o),
    .sda_t(si570_sda_t),
    .busy(),
    .bus_control(),
    .bus_active(),
    .missed_ack(),
    .prescale(312),
    .stop_on_idle(1)
);

// 10G Ethernet PHY

wire [71:0] sfp_a_tx_dc;
wire [71:0] sfp_a_rx_dc;
wire [71:0] sfp_b_tx_dc;
wire [71:0] sfp_b_rx_dc;
wire [71:0] sfp_c_tx_dc;
wire [71:0] sfp_c_rx_dc;
wire [71:0] sfp_d_tx_dc;
wire [71:0] sfp_d_rx_dc;

wire [367:0] phy_reconfig_from_xcvr;
wire [559:0] phy_reconfig_to_xcvr;

assign SFPA_MOD1_SCL = 1'bz;
assign SFPA_MOD2_SDA = 1'bz;
assign SFPA_TXDISABLE = 1'b0;
assign SPFA_RATESEL = 2'b00;

assign SFPB_MOD1_SCL = 1'bz;
assign SFPB_MOD2_SDA = 1'bz;
assign SFPB_TXDISABLE = 1'b0;
assign SPFB_RATESEL = 2'b00;

assign SFPC_MOD1_SCL = 1'bz;
assign SFPC_MOD2_SDA = 1'bz;
assign SFPC_TXDISABLE = 1'b0;
assign SPFC_RATESEL = 2'b00;

assign SFPD_MOD1_SCL = 1'bz;
assign SFPD_MOD2_SDA = 1'bz;
assign SFPD_TXDISABLE = 1'b0;
assign SPFD_RATESEL = 2'b00;

phy
phy_inst (
    .pll_ref_clk(SFP_REFCLK_P),
    .pll_locked(phy_pll_locked),

    .tx_serial_data_0(SFPA_TX_p),
    .rx_serial_data_0(SFPA_RX_p),
    .tx_serial_data_1(SFPB_TX_p),
    .rx_serial_data_1(SFPB_RX_p),
    .tx_serial_data_2(SFPC_TX_p),
    .rx_serial_data_2(SFPC_RX_p),
    .tx_serial_data_3(SFPD_TX_p),
    .rx_serial_data_3(SFPD_RX_p),

    .xgmii_tx_dc_0(sfp_a_tx_dc),
    .xgmii_rx_dc_0(sfp_a_rx_dc),
    .xgmii_tx_dc_1(sfp_b_tx_dc),
    .xgmii_rx_dc_1(sfp_b_rx_dc),
    .xgmii_tx_dc_2(sfp_c_tx_dc),
    .xgmii_rx_dc_2(sfp_c_rx_dc),
    .xgmii_tx_dc_3(sfp_d_tx_dc),
    .xgmii_rx_dc_3(sfp_d_rx_dc),

    .xgmii_rx_clk(clk_156mhz),
    .xgmii_tx_clk(clk_156mhz),

    .tx_ready(~rst_156mhz),
    .rx_ready(),

    .rx_data_ready(),

    .phy_mgmt_clk(clk_50mhz),
    .phy_mgmt_clk_reset(rst_50mhz),
    .phy_mgmt_address(9'd0),
    .phy_mgmt_read(1'b0),
    .phy_mgmt_readdata(),
    .phy_mgmt_waitrequest(),
    .phy_mgmt_write(1'b0),
    .phy_mgmt_writedata(32'd0),

    .reconfig_from_xcvr(phy_reconfig_from_xcvr),
    .reconfig_to_xcvr(phy_reconfig_to_xcvr)
);

phy_reconfig
phy_reconfig_inst (
    .reconfig_busy(),

    .mgmt_clk_clk(clk_50mhz),
    .mgmt_rst_reset(rst_50mhz),

    .reconfig_mgmt_address(7'd0),
    .reconfig_mgmt_read(1'b0),
    .reconfig_mgmt_readdata(),
    .reconfig_mgmt_waitrequest(),
    .reconfig_mgmt_write(1'b0),
    .reconfig_mgmt_writedata(32'd0),

    .reconfig_to_xcvr(phy_reconfig_to_xcvr),
    .reconfig_from_xcvr(phy_reconfig_from_xcvr)
);

// Convert XGMII interfaces

wire [63:0] sfp_a_txd_int;
wire [7:0]  sfp_a_txc_int;
wire [63:0] sfp_a_rxd_int;
wire [7:0]  sfp_a_rxc_int;
wire [63:0] sfp_b_txd_int;
wire [7:0]  sfp_b_txc_int;
wire [63:0] sfp_b_rxd_int;
wire [7:0]  sfp_b_rxc_int;
wire [63:0] sfp_c_txd_int;
wire [7:0]  sfp_c_txc_int;
wire [63:0] sfp_c_rxd_int;
wire [7:0]  sfp_c_rxc_int;
wire [63:0] sfp_d_txd_int;
wire [7:0]  sfp_d_txc_int;
wire [63:0] sfp_d_rxd_int;
wire [7:0]  sfp_d_rxc_int;

xgmii_interleave
xgmii_interleave_inst_a (
    .input_xgmii_d(sfp_a_txd_int),
    .input_xgmii_c(sfp_a_txc_int),
    .output_xgmii_dc(sfp_a_tx_dc)
);

xgmii_deinterleave
xgmii_deinterleave_inst_a (
    .input_xgmii_dc(sfp_a_rx_dc),
    .output_xgmii_d(sfp_a_rxd_int),
    .output_xgmii_c(sfp_a_rxc_int)
);

xgmii_interleave
xgmii_interleave_inst_b (
    .input_xgmii_d(sfp_b_txd_int),
    .input_xgmii_c(sfp_b_txc_int),
    .output_xgmii_dc(sfp_b_tx_dc)
);

xgmii_deinterleave
xgmii_deinterleave_inst_b (
    .input_xgmii_dc(sfp_b_rx_dc),
    .output_xgmii_d(sfp_b_rxd_int),
    .output_xgmii_c(sfp_b_rxc_int)
);

xgmii_interleave
xgmii_interleave_inst_c (
    .input_xgmii_d(sfp_c_txd_int),
    .input_xgmii_c(sfp_c_txc_int),
    .output_xgmii_dc(sfp_c_tx_dc)
);

xgmii_deinterleave
xgmii_deinterleave_inst_c (
    .input_xgmii_dc(sfp_c_rx_dc),
    .output_xgmii_d(sfp_c_rxd_int),
    .output_xgmii_c(sfp_c_rxc_int)
);

xgmii_interleave
xgmii_interleave_inst_d (
    .input_xgmii_d(sfp_d_txd_int),
    .input_xgmii_c(sfp_d_txc_int),
    .output_xgmii_dc(sfp_d_tx_dc)
);

xgmii_deinterleave
xgmii_deinterleave_inst_d (
    .input_xgmii_dc(sfp_d_rx_dc),
    .output_xgmii_d(sfp_d_rxd_int),
    .output_xgmii_c(sfp_d_rxc_int)
);

// Core logic

fpga_core
core_inst (
    /*
     * Clock: 156.25MHz
     * Synchronous reset
     */
    .clk(clk_156mhz),
    .rst(rst_156mhz),
    /*
     * GPIO
     */
    .btn(btn_int),
    .sw(sw_int),
    .led(led_int),
    .led_bkt(led_bkt_int),
    .led_hex0_d(led_hex0_d_int),
    .led_hex0_dp(led_hex0_dp_int),
    .led_hex1_d(led_hex1_d_int),
    .led_hex1_dp(led_hex1_dp_int),
    /*
     * 10G Ethernet
     */
    .sfp_a_txd(sfp_a_txd_int),
    .sfp_a_txc(sfp_a_txc_int),
    .sfp_a_rxd(sfp_a_rxd_int),
    .sfp_a_rxc(sfp_a_rxc_int),
    .sfp_b_txd(sfp_b_txd_int),
    .sfp_b_txc(sfp_b_txc_int),
    .sfp_b_rxd(sfp_b_rxd_int),
    .sfp_b_rxc(sfp_b_rxc_int),
    .sfp_c_txd(sfp_c_txd_int),
    .sfp_c_txc(sfp_c_txc_int),
    .sfp_c_rxd(sfp_c_rxd_int),
    .sfp_c_rxc(sfp_c_rxc_int),
    .sfp_d_txd(sfp_d_txd_int),
    .sfp_d_txc(sfp_d_txc_int),
    .sfp_d_rxd(sfp_d_rxd_int),
    .sfp_d_rxc(sfp_d_rxc_int)
);

endmodule

`resetall
