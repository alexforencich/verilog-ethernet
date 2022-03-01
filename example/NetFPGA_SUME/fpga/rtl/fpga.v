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
     * Clock: 200MHz LVDS
     */
    input  wire       clk_200mhz_p,
    input  wire       clk_200mhz_n,

    /*
     * GPIO
     */
    input  wire [1:0] btn,
    output wire [1:0] sfp_1_led,
    output wire [1:0] sfp_2_led,
    output wire [1:0] sfp_3_led,
    output wire [1:0] sfp_4_led,
    output wire [1:0] led,

    /*
     * I2C
     */
    inout  wire       i2c_scl,
    inout  wire       i2c_sda,
    output wire       i2c_mux_reset,

    /*
     * Ethernet: SFP+
     */
    input  wire       sfp_1_rx_p,
    input  wire       sfp_1_rx_n,
    output wire       sfp_1_tx_p,
    output wire       sfp_1_tx_n,
    input  wire       sfp_2_rx_p,
    input  wire       sfp_2_rx_n,
    output wire       sfp_2_tx_p,
    output wire       sfp_2_tx_n,
    input  wire       sfp_3_rx_p,
    input  wire       sfp_3_rx_n,
    output wire       sfp_3_tx_p,
    output wire       sfp_3_tx_n,
    input  wire       sfp_4_rx_p,
    input  wire       sfp_4_rx_n,
    output wire       sfp_4_tx_p,
    output wire       sfp_4_tx_n,
    input  wire       sfp_mgt_refclk_p,
    input  wire       sfp_mgt_refclk_n,
    output wire       sfp_clk_rst,
    input  wire       sfp_1_mod_detect,
    input  wire       sfp_2_mod_detect,
    input  wire       sfp_3_mod_detect,
    input  wire       sfp_4_mod_detect,
    output wire [1:0] sfp_1_rs,
    output wire [1:0] sfp_2_rs,
    output wire [1:0] sfp_3_rs,
    output wire [1:0] sfp_4_rs,
    input  wire       sfp_1_los,
    input  wire       sfp_2_los,
    input  wire       sfp_3_los,
    input  wire       sfp_4_los,
    output wire       sfp_1_tx_disable,
    output wire       sfp_2_tx_disable,
    output wire       sfp_3_tx_disable,
    output wire       sfp_4_tx_disable,
    input  wire       sfp_1_tx_fault,
    input  wire       sfp_2_tx_fault,
    input  wire       sfp_3_tx_fault,
    input  wire       sfp_4_tx_fault
);

// Clock and reset

wire clk_200mhz_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = 1'b0;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_200mhz_ibufg_inst (
   .O   (clk_200mhz_ibufg),
   .I   (clk_200mhz_p),
   .IB  (clk_200mhz_n) 
);

// MMCM instance
// 200 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 600 MHz to 1440 MHz
// M = 5, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME2_BASE #(
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
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(5.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_200mhz_ibufg),
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
wire [1:0] btn_int;
wire [1:0] sfp_1_led_int;
wire [1:0] sfp_2_led_int;
wire [1:0] sfp_3_led_int;
wire [1:0] sfp_4_led_int;
wire [1:0] led_int;

debounce_switch #(
    .WIDTH(2),
    .N(4),
    .RATE(156250)
)
debounce_switch_inst (
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    .in({btn}),
    .out({btn_int})
);

// I2C
wire i2c_scl_i;
wire i2c_scl_o;
wire i2c_scl_t;
wire i2c_sda_i;
wire i2c_sda_o;
wire i2c_sda_t;

assign i2c_scl_i = i2c_scl;
assign i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_sda;
assign i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

wire [6:0] si5324_i2c_cmd_address;
wire si5324_i2c_cmd_start;
wire si5324_i2c_cmd_read;
wire si5324_i2c_cmd_write;
wire si5324_i2c_cmd_write_multiple;
wire si5324_i2c_cmd_stop;
wire si5324_i2c_cmd_valid;
wire si5324_i2c_cmd_ready;

wire [7:0] si5324_i2c_data;
wire si5324_i2c_data_valid;
wire si5324_i2c_data_ready;
wire si5324_i2c_data_last;

wire si5324_i2c_init_busy;

assign i2c_mux_reset = rst_125mhz_int;
assign sfp_clk_rst = rst_125mhz_int;

// delay start by ~10 ms
reg [20:0] si5324_i2c_init_start_delay = 21'd0;

always @(posedge clk_125mhz_int) begin
    if (rst_125mhz_int) begin
        si5324_i2c_init_start_delay <= 21'd0;
    end else begin
        if (!si5324_i2c_init_start_delay[20]) begin
            si5324_i2c_init_start_delay <= si5324_i2c_init_start_delay + 21'd1;
        end
    end
end

si5324_i2c_init
si5324_i2c_init_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .cmd_address(si5324_i2c_cmd_address),
    .cmd_start(si5324_i2c_cmd_start),
    .cmd_read(si5324_i2c_cmd_read),
    .cmd_write(si5324_i2c_cmd_write),
    .cmd_write_multiple(si5324_i2c_cmd_write_multiple),
    .cmd_stop(si5324_i2c_cmd_stop),
    .cmd_valid(si5324_i2c_cmd_valid),
    .cmd_ready(si5324_i2c_cmd_ready),
    .data_out(si5324_i2c_data),
    .data_out_valid(si5324_i2c_data_valid),
    .data_out_ready(si5324_i2c_data_ready),
    .data_out_last(si5324_i2c_data_last),
    .busy(si5324_i2c_init_busy),
    .start(si5324_i2c_init_start_delay[20])
);

i2c_master
si5324_i2c_master_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .cmd_address(si5324_i2c_cmd_address),
    .cmd_start(si5324_i2c_cmd_start),
    .cmd_read(si5324_i2c_cmd_read),
    .cmd_write(si5324_i2c_cmd_write),
    .cmd_write_multiple(si5324_i2c_cmd_write_multiple),
    .cmd_stop(si5324_i2c_cmd_stop),
    .cmd_valid(si5324_i2c_cmd_valid),
    .cmd_ready(si5324_i2c_cmd_ready),
    .data_in(si5324_i2c_data),
    .data_in_valid(si5324_i2c_data_valid),
    .data_in_ready(si5324_i2c_data_ready),
    .data_in_last(si5324_i2c_data_last),
    .data_out(),
    .data_out_valid(),
    .data_out_ready(1),
    .data_out_last(),
    .scl_i(i2c_scl_i),
    .scl_o(i2c_scl_o),
    .scl_t(i2c_scl_t),
    .sda_i(i2c_sda_i),
    .sda_o(i2c_sda_o),
    .sda_t(i2c_sda_t),
    .busy(),
    .bus_control(),
    .bus_active(),
    .missed_ack(),
    .prescale(312),
    .stop_on_idle(1)
);

// XGMII 10G PHY

assign sfp_1_tx_disable = 1'b0;
assign sfp_2_tx_disable = 1'b0;
assign sfp_3_tx_disable = 1'b0;
assign sfp_4_tx_disable = 1'b0;
assign sfp_1_rs = 1'b1;
assign sfp_2_rs = 1'b1;
assign sfp_3_rs = 1'b1;
assign sfp_4_rs = 1'b1;

wire        sfp_1_tx_clk_int = clk_156mhz_int;
wire        sfp_1_tx_rst_int = rst_156mhz_int;
wire [63:0] sfp_1_txd_int;
wire [7:0]  sfp_1_txc_int;
wire        sfp_1_rx_clk_int = clk_156mhz_int;
wire        sfp_1_rx_rst_int = rst_156mhz_int;
wire [63:0] sfp_1_rxd_int;
wire [7:0]  sfp_1_rxc_int;
wire        sfp_2_tx_clk_int = clk_156mhz_int;
wire        sfp_2_tx_rst_int = rst_156mhz_int;
wire [63:0] sfp_2_txd_int;
wire [7:0]  sfp_2_txc_int;
wire        sfp_2_rx_clk_int = clk_156mhz_int;
wire        sfp_2_rx_rst_int = rst_156mhz_int;
wire [63:0] sfp_2_rxd_int;
wire [7:0]  sfp_2_rxc_int;
wire        sfp_3_tx_clk_int = clk_156mhz_int;
wire        sfp_3_tx_rst_int = rst_156mhz_int;
wire [63:0] sfp_3_txd_int;
wire [7:0]  sfp_3_txc_int;
wire        sfp_3_rx_clk_int = clk_156mhz_int;
wire        sfp_3_rx_rst_int = rst_156mhz_int;
wire [63:0] sfp_3_rxd_int;
wire [7:0]  sfp_3_rxc_int;
wire        sfp_4_tx_clk_int = clk_156mhz_int;
wire        sfp_4_tx_rst_int = rst_156mhz_int;
wire [63:0] sfp_4_txd_int;
wire [7:0]  sfp_4_txc_int;
wire        sfp_4_rx_clk_int = clk_156mhz_int;
wire        sfp_4_rx_rst_int = rst_156mhz_int;
wire [63:0] sfp_4_rxd_int;
wire [7:0]  sfp_4_rxc_int;

wire sfp_reset_in;
wire sfp_txusrclk;
wire sfp_txusrclk2;
wire sfp_coreclk;
wire sfp_qplloutclk;
wire sfp_qplloutrefclk;
wire sfp_qplllock;
wire sfp_gttxreset;
wire sfp_gtrxreset;
wire sfp_txuserrdy;
wire sfp_areset_datapathclk;
wire sfp_resetdone;
wire sfp_reset_counter_done;

sync_reset #(
    .N(4)
)
sync_reset_sfp_inst (
    .clk(sfp_coreclk),
    .rst(rst_125mhz_int || si5324_i2c_init_busy),
    .out(sfp_reset_in)
);

//assign sfp_reset_in = rst_125mhz_int || si5324_i2c_init_busy;

assign clk_156mhz_int = sfp_coreclk;

sync_reset #(
    .N(4)
)
sync_reset_156mhz_inst (
    .clk(clk_156mhz_int),
    .rst(!sfp_resetdone),
    .out(rst_156mhz_int)
);

wire [535:0] sfp_config_vector;

assign sfp_config_vector[14:1]    = 0;
assign sfp_config_vector[79:17]   = 0;
assign sfp_config_vector[109:84]  = 0;
assign sfp_config_vector[175:170] = 0;
assign sfp_config_vector[239:234] = 0;
assign sfp_config_vector[269:246] = 0;
assign sfp_config_vector[511:272] = 0;
assign sfp_config_vector[515:513] = 0;
assign sfp_config_vector[517:517] = 0;
assign sfp_config_vector[0]       = 0; // pma_loopback;
assign sfp_config_vector[15]      = 0; // pma_reset;
assign sfp_config_vector[16]      = 0; // global_tx_disable;
assign sfp_config_vector[83:80]   = 0; // pma_vs_loopback;
assign sfp_config_vector[110]     = 0; // pcs_loopback;
assign sfp_config_vector[111]     = 0; // pcs_reset;
assign sfp_config_vector[169:112] = 0; // test_patt_a;
assign sfp_config_vector[233:176] = 0; // test_patt_b;
assign sfp_config_vector[240]     = 0; // data_patt_sel;
assign sfp_config_vector[241]     = 0; // test_patt_sel;
assign sfp_config_vector[242]     = 0; // rx_test_patt_en;
assign sfp_config_vector[243]     = 0; // tx_test_patt_en;
assign sfp_config_vector[244]     = 0; // prbs31_tx_en;
assign sfp_config_vector[245]     = 0; // prbs31_rx_en;
assign sfp_config_vector[271:270] = 0; // pcs_vs_loopback;
assign sfp_config_vector[512]     = 0; // set_pma_link_status;
assign sfp_config_vector[516]     = 0; // set_pcs_link_status;
assign sfp_config_vector[518]     = 0; // clear_pcs_status2;
assign sfp_config_vector[519]     = 0; // clear_test_patt_err_count;
assign sfp_config_vector[535:520] = 0;

wire [447:0] sfp_1_status_vector;
wire [447:0] sfp_2_status_vector;
wire [447:0] sfp_3_status_vector;
wire [447:0] sfp_4_status_vector;

wire sfp_1_rx_block_lock = sfp_1_status_vector[256];
wire sfp_2_rx_block_lock = sfp_2_status_vector[256];
wire sfp_3_rx_block_lock = sfp_3_status_vector[256];
wire sfp_4_rx_block_lock = sfp_4_status_vector[256];

wire [7:0] sfp_1_core_status;
wire [7:0] sfp_2_core_status;
wire [7:0] sfp_3_core_status;
wire [7:0] sfp_4_core_status;

ten_gig_eth_pcs_pma_0
sfp_1_pcs_pma_inst (
    .dclk(clk_125mhz_int),
    .rxrecclk_out(),
    .refclk_p(sfp_mgt_refclk_p),
    .refclk_n(sfp_mgt_refclk_n),
    .sim_speedup_control(1'b0),
    .coreclk_out(sfp_coreclk),
    .qplloutclk_out(sfp_qplloutclk),
    .qplloutrefclk_out(sfp_qplloutrefclk),
    .qplllock_out(sfp_qplllock),
    .txusrclk_out(sfp_txusrclk),
    .txusrclk2_out(sfp_txusrclk2),
    .areset_datapathclk_out(sfp_areset_datapathclk),
    .gttxreset_out(sfp_gttxreset),
    .gtrxreset_out(sfp_gtrxreset),
    .txuserrdy_out(sfp_txuserrdy),
    .reset_counter_done_out(sfp_reset_counter_done),
    .reset(sfp_reset_in),
    .xgmii_txd(sfp_1_txd_int),
    .xgmii_txc(sfp_1_txc_int),
    .xgmii_rxd(sfp_1_rxd_int),
    .xgmii_rxc(sfp_1_rxc_int),
    .txp(sfp_1_tx_p),
    .txn(sfp_1_tx_n),
    .rxp(sfp_1_rx_p),
    .rxn(sfp_1_rx_n),
    .configuration_vector(sfp_config_vector),
    .status_vector(sfp_1_status_vector),
    .core_status(sfp_1_core_status),
    .resetdone_out(sfp_resetdone),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .drp_req(),
    .drp_gnt(1'b1),
    .drp_den_o(),
    .drp_dwe_o(),
    .drp_daddr_o(),
    .drp_di_o(),
    .drp_drdy_o(),
    .drp_drpdo_o(),
    .drp_den_i(1'b0),
    .drp_dwe_i(1'b0),
    .drp_daddr_i(16'd0),
    .drp_di_i(16'd0),
    .drp_drdy_i(1'b0),
    .drp_drpdo_i(16'd0),
    .pma_pmd_type(3'd0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_1
sfp_2_pcs_pma_inst (
    .dclk(clk_125mhz_int),
    .rxrecclk_out(),
    .coreclk(sfp_coreclk),
    .txusrclk(sfp_txusrclk),
    .txusrclk2(sfp_txusrclk2),
    .txoutclk(),
    .areset(sfp_reset_in),
    .areset_coreclk(sfp_areset_datapathclk),
    .gttxreset(sfp_gttxreset),
    .gtrxreset(sfp_gtrxreset),
    .sim_speedup_control(1'b0),
    .txuserrdy(sfp_txuserrdy),
    .qplllock(sfp_qplllock),
    .qplloutclk(sfp_qplloutclk),
    .qplloutrefclk(sfp_qplloutrefclk),
    .reset_counter_done(sfp_reset_counter_done),
    .xgmii_txd(sfp_2_txd_int),
    .xgmii_txc(sfp_2_txc_int),
    .xgmii_rxd(sfp_2_rxd_int),
    .xgmii_rxc(sfp_2_rxc_int),
    .txp(sfp_2_tx_p),
    .txn(sfp_2_tx_n),
    .rxp(sfp_2_rx_p),
    .rxn(sfp_2_rx_n),
    .configuration_vector(sfp_config_vector),
    .status_vector(sfp_2_status_vector),
    .core_status(sfp_2_core_status),
    .tx_resetdone(),
    .rx_resetdone(),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .drp_req(),
    .drp_gnt(1'b1),
    .drp_den_o(),
    .drp_dwe_o(),
    .drp_daddr_o(),
    .drp_di_o(),
    .drp_drdy_o(),
    .drp_drpdo_o(),
    .drp_den_i(1'b0),
    .drp_dwe_i(1'b0),
    .drp_daddr_i(16'd0),
    .drp_di_i(16'd0),
    .drp_drdy_i(1'b0),
    .drp_drpdo_i(16'd0),
    .pma_pmd_type(3'd0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_1
sfp_3_pcs_pma_inst (
    .dclk(clk_125mhz_int),
    .rxrecclk_out(),
    .coreclk(sfp_coreclk),
    .txusrclk(sfp_txusrclk),
    .txusrclk2(sfp_txusrclk2),
    .txoutclk(),
    .areset(sfp_reset_in),
    .areset_coreclk(sfp_areset_datapathclk),
    .gttxreset(sfp_gttxreset),
    .gtrxreset(sfp_gtrxreset),
    .sim_speedup_control(1'b0),
    .txuserrdy(sfp_txuserrdy),
    .qplllock(sfp_qplllock),
    .qplloutclk(sfp_qplloutclk),
    .qplloutrefclk(sfp_qplloutrefclk),
    .reset_counter_done(sfp_reset_counter_done),
    .xgmii_txd(sfp_3_txd_int),
    .xgmii_txc(sfp_3_txc_int),
    .xgmii_rxd(sfp_3_rxd_int),
    .xgmii_rxc(sfp_3_rxc_int),
    .txp(sfp_3_tx_p),
    .txn(sfp_3_tx_n),
    .rxp(sfp_3_rx_p),
    .rxn(sfp_3_rx_n),
    .configuration_vector(sfp_config_vector),
    .status_vector(sfp_3_status_vector),
    .core_status(sfp_3_core_status),
    .tx_resetdone(),
    .rx_resetdone(),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .drp_req(),
    .drp_gnt(1'b1),
    .drp_den_o(),
    .drp_dwe_o(),
    .drp_daddr_o(),
    .drp_di_o(),
    .drp_drdy_o(),
    .drp_drpdo_o(),
    .drp_den_i(1'b0),
    .drp_dwe_i(1'b0),
    .drp_daddr_i(16'd0),
    .drp_di_i(16'd0),
    .drp_drdy_i(1'b0),
    .drp_drpdo_i(16'd0),
    .pma_pmd_type(3'd0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_1
sfp_4_pcs_pma_inst (
    .dclk(clk_125mhz_int),
    .rxrecclk_out(),
    .coreclk(sfp_coreclk),
    .txusrclk(sfp_txusrclk),
    .txusrclk2(sfp_txusrclk2),
    .txoutclk(),
    .areset(sfp_reset_in),
    .areset_coreclk(sfp_areset_datapathclk),
    .gttxreset(sfp_gttxreset),
    .gtrxreset(sfp_gtrxreset),
    .sim_speedup_control(1'b0),
    .txuserrdy(sfp_txuserrdy),
    .qplllock(sfp_qplllock),
    .qplloutclk(sfp_qplloutclk),
    .qplloutrefclk(sfp_qplloutrefclk),
    .reset_counter_done(sfp_reset_counter_done),
    .xgmii_txd(sfp_4_txd_int),
    .xgmii_txc(sfp_4_txc_int),
    .xgmii_rxd(sfp_4_rxd_int),
    .xgmii_rxc(sfp_4_rxc_int),
    .txp(sfp_4_tx_p),
    .txn(sfp_4_tx_n),
    .rxp(sfp_4_rx_p),
    .rxn(sfp_4_rx_n),
    .configuration_vector(sfp_config_vector),
    .status_vector(sfp_4_status_vector),
    .core_status(sfp_4_core_status),
    .tx_resetdone(),
    .rx_resetdone(),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .drp_req(),
    .drp_gnt(1'b1),
    .drp_den_o(),
    .drp_dwe_o(),
    .drp_daddr_o(),
    .drp_di_o(),
    .drp_drdy_o(),
    .drp_drpdo_o(),
    .drp_den_i(1'b0),
    .drp_dwe_i(1'b0),
    .drp_daddr_i(16'd0),
    .drp_di_i(16'd0),
    .drp_drdy_i(1'b0),
    .drp_drpdo_i(16'd0),
    .pma_pmd_type(3'd0),
    .tx_disable()
);

assign sfp_1_led[0] = sfp_1_rx_block_lock;
assign sfp_1_led[1] = 1'b0;
assign sfp_2_led[0] = sfp_2_rx_block_lock;
assign sfp_2_led[1] = 1'b0;
assign sfp_3_led[0] = sfp_3_rx_block_lock;
assign sfp_3_led[1] = 1'b0;
assign sfp_4_led[0] = sfp_4_rx_block_lock;
assign sfp_4_led[1] = 1'b0;
assign led = led_int;

fpga_core
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    /*
     * GPIO
     */
    .btn(btn_int),
    .sfp_1_led(sfp_1_led_int),
    .sfp_2_led(sfp_2_led_int),
    .sfp_3_led(sfp_3_led_int),
    .sfp_4_led(sfp_4_led_int),
    .led(led_int),
    /*
     * Ethernet: SFP+
     */
    .sfp_1_tx_clk(sfp_1_tx_clk_int),
    .sfp_1_tx_rst(sfp_1_tx_rst_int),
    .sfp_1_txd(sfp_1_txd_int),
    .sfp_1_txc(sfp_1_txc_int),
    .sfp_1_rx_clk(sfp_1_rx_clk_int),
    .sfp_1_rx_rst(sfp_1_rx_rst_int),
    .sfp_1_rxd(sfp_1_rxd_int),
    .sfp_1_rxc(sfp_1_rxc_int),
    .sfp_2_tx_clk(sfp_2_tx_clk_int),
    .sfp_2_tx_rst(sfp_2_tx_rst_int),
    .sfp_2_txd(sfp_2_txd_int),
    .sfp_2_txc(sfp_2_txc_int),
    .sfp_2_rx_clk(sfp_2_rx_clk_int),
    .sfp_2_rx_rst(sfp_2_rx_rst_int),
    .sfp_2_rxd(sfp_2_rxd_int),
    .sfp_2_rxc(sfp_2_rxc_int),
    .sfp_3_tx_clk(sfp_3_tx_clk_int),
    .sfp_3_tx_rst(sfp_3_tx_rst_int),
    .sfp_3_txd(sfp_3_txd_int),
    .sfp_3_txc(sfp_3_txc_int),
    .sfp_3_rx_clk(sfp_3_rx_clk_int),
    .sfp_3_rx_rst(sfp_3_rx_rst_int),
    .sfp_3_rxd(sfp_3_rxd_int),
    .sfp_3_rxc(sfp_3_rxc_int),
    .sfp_4_tx_clk(sfp_4_tx_clk_int),
    .sfp_4_tx_rst(sfp_4_tx_rst_int),
    .sfp_4_txd(sfp_4_txd_int),
    .sfp_4_txc(sfp_4_txc_int),
    .sfp_4_rx_clk(sfp_4_rx_clk_int),
    .sfp_4_rx_rst(sfp_4_rx_rst_int),
    .sfp_4_rxd(sfp_4_rxd_int),
    .sfp_4_rxc(sfp_4_rxc_int)
);

endmodule

`resetall
