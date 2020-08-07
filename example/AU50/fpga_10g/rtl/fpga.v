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

`timescale 1ns / 1ps

/*
 * FPGA top-level module
 */
module fpga (
    /*
     * GPIO
     */
    output wire       qsfp_led_act,
    output wire       qsfp_led_stat_g,
    output wire       qsfp_led_stat_y,
    output wire       hbm_cattrip,

    /*
     * Ethernet: QSFP28
     */
    output wire       qsfp_tx1_p,
    output wire       qsfp_tx1_n,
    input  wire       qsfp_rx1_p,
    input  wire       qsfp_rx1_n,
    output wire       qsfp_tx2_p,
    output wire       qsfp_tx2_n,
    input  wire       qsfp_rx2_p,
    input  wire       qsfp_rx2_n,
    output wire       qsfp_tx3_p,
    output wire       qsfp_tx3_n,
    input  wire       qsfp_rx3_p,
    input  wire       qsfp_rx3_n,
    output wire       qsfp_tx4_p,
    output wire       qsfp_tx4_n,
    input  wire       qsfp_rx4_p,
    input  wire       qsfp_rx4_n,
    input  wire       qsfp_mgt_refclk_0_p,
    input  wire       qsfp_mgt_refclk_0_n
    // input  wire       qsfp_mgt_refclk_1_p,
    // input  wire       qsfp_mgt_refclk_1_n
);

// Clock and reset

wire clk_161mhz_ref_int;

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

// MMCM instance
// 161.13 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 64, D = 11 sets Fvco = 937.5 MHz (in range)
// Divide by 7.5 to get output frequency of 125 MHz
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(7.5),
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
    .CLKFBOUT_MULT_F(64),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(11),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(6.206),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_161mhz_ref_int),
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
assign hbm_cattrip = 1'b0;

// XGMII 10G PHY
wire        qsfp_tx_clk_1_int;
wire        qsfp_tx_rst_1_int;
wire [63:0] qsfp_txd_1_int;
wire [7:0]  qsfp_txc_1_int;
wire        qsfp_rx_clk_1_int;
wire        qsfp_rx_rst_1_int;
wire [63:0] qsfp_rxd_1_int;
wire [7:0]  qsfp_rxc_1_int;
wire        qsfp_tx_clk_2_int;
wire        qsfp_tx_rst_2_int;
wire [63:0] qsfp_txd_2_int;
wire [7:0]  qsfp_txc_2_int;
wire        qsfp_rx_clk_2_int;
wire        qsfp_rx_rst_2_int;
wire [63:0] qsfp_rxd_2_int;
wire [7:0]  qsfp_rxc_2_int;
wire        qsfp_tx_clk_3_int;
wire        qsfp_tx_rst_3_int;
wire [63:0] qsfp_txd_3_int;
wire [7:0]  qsfp_txc_3_int;
wire        qsfp_rx_clk_3_int;
wire        qsfp_rx_rst_3_int;
wire [63:0] qsfp_rxd_3_int;
wire [7:0]  qsfp_rxc_3_int;
wire        qsfp_tx_clk_4_int;
wire        qsfp_tx_rst_4_int;
wire [63:0] qsfp_txd_4_int;
wire [7:0]  qsfp_txc_4_int;
wire        qsfp_rx_clk_4_int;
wire        qsfp_rx_rst_4_int;
wire [63:0] qsfp_rxd_4_int;
wire [7:0]  qsfp_rxc_4_int;

wire qsfp_rx_block_lock_1;
wire qsfp_rx_block_lock_2;
wire qsfp_rx_block_lock_3;
wire qsfp_rx_block_lock_4;

wire [3:0] qsfp_gtpowergood;

wire qsfp_mgt_refclk_0;
wire qsfp_mgt_refclk_0_int;
wire qsfp_mgt_refclk_0_bufg;

assign clk_161mhz_ref_int = qsfp_mgt_refclk_0_bufg;

wire [3:0] gt_txclkout;
wire gt_txusrclk;

wire [3:0] gt_rxclkout;
wire [3:0] gt_rxusrclk;

wire gt_reset_tx_done;
wire gt_reset_rx_done;

wire [3:0] gt_txprgdivresetdone;
wire [3:0] gt_txpmaresetdone;
wire [3:0] gt_rxprgdivresetdone;
wire [3:0] gt_rxpmaresetdone;

wire gt_tx_reset = ~((&gt_txprgdivresetdone) & (&gt_txpmaresetdone));
wire gt_rx_reset = ~&gt_rxpmaresetdone;

reg gt_userclk_tx_active = 1'b0;
reg [3:0] gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_mgt_refclk_0_inst (
    .I             (qsfp_mgt_refclk_0_p),
    .IB            (qsfp_mgt_refclk_0_n),
    .CEB           (1'b0),
    .O             (qsfp_mgt_refclk_0),
    .ODIV2         (qsfp_mgt_refclk_0_int)
);

BUFG_GT bufg_gt_refclk_inst (
    .CE      (&qsfp_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (qsfp_mgt_refclk_0_int),
    .O       (qsfp_mgt_refclk_0_bufg)
);

BUFG_GT bufg_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (gt_txclkout[0]),
    .O       (gt_txusrclk)
);

assign clk_156mhz_int = gt_txusrclk;

always @(posedge gt_txusrclk, posedge gt_tx_reset) begin
    if (gt_tx_reset) begin
        gt_userclk_tx_active <= 1'b0;
    end else begin
        gt_userclk_tx_active <= 1'b1;
    end
end

genvar n;

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (gt_rxclkout[n]),
        .O       (gt_rxusrclk[n])
    );

    always @(posedge gt_rxusrclk[n], posedge gt_rx_reset) begin
        if (gt_rx_reset) begin
            gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

sync_reset #(
    .N(4)
)
sync_reset_156mhz_inst (
    .clk(clk_156mhz_int),
    .rst(~gt_reset_tx_done),
    .out(rst_156mhz_int)
);

wire [5:0] qsfp_gt_txheader_1;
wire [63:0] qsfp_gt_txdata_1;
wire qsfp_gt_rxgearboxslip_1;
wire [5:0] qsfp_gt_rxheader_1;
wire [1:0] qsfp_gt_rxheadervalid_1;
wire [63:0] qsfp_gt_rxdata_1;
wire [1:0] qsfp_gt_rxdatavalid_1;

wire [5:0] qsfp_gt_txheader_2;
wire [63:0] qsfp_gt_txdata_2;
wire qsfp_gt_rxgearboxslip_2;
wire [5:0] qsfp_gt_rxheader_2;
wire [1:0] qsfp_gt_rxheadervalid_2;
wire [63:0] qsfp_gt_rxdata_2;
wire [1:0] qsfp_gt_rxdatavalid_2;

wire [5:0] qsfp_gt_txheader_3;
wire [63:0] qsfp_gt_txdata_3;
wire qsfp_gt_rxgearboxslip_3;
wire [5:0] qsfp_gt_rxheader_3;
wire [1:0] qsfp_gt_rxheadervalid_3;
wire [63:0] qsfp_gt_rxdata_3;
wire [1:0] qsfp_gt_rxdatavalid_3;

wire [5:0] qsfp_gt_txheader_4;
wire [63:0] qsfp_gt_txdata_4;
wire qsfp_gt_rxgearboxslip_4;
wire [5:0] qsfp_gt_rxheader_4;
wire [1:0] qsfp_gt_rxheadervalid_4;
wire [63:0] qsfp_gt_rxdata_4;
wire [1:0] qsfp_gt_rxdatavalid_4;

gtwizard_ultrascale_0
qsfp_gty_inst (
    .gtwiz_userclk_tx_active_in(&gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(rst_125mhz_int),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(gt_reset_rx_done),

    .gtrefclk00_in(qsfp_mgt_refclk_0),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_rx4_n, qsfp_rx3_n, qsfp_rx2_n, qsfp_rx1_n}),
    .gtyrxp_in({qsfp_rx4_p, qsfp_rx3_p, qsfp_rx2_p, qsfp_rx1_p}),

    .rxusrclk_in(gt_rxusrclk),
    .rxusrclk2_in(gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_gt_txdata_4, qsfp_gt_txdata_3, qsfp_gt_txdata_2, qsfp_gt_txdata_1}),
    .txheader_in({qsfp_gt_txheader_4, qsfp_gt_txheader_3, qsfp_gt_txheader_2, qsfp_gt_txheader_1}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{gt_txusrclk}}),
    .txusrclk2_in({4{gt_txusrclk}}),

    .gtpowergood_out(qsfp_gtpowergood),

    .gtytxn_out({qsfp_tx4_n, qsfp_tx3_n, qsfp_tx2_n, qsfp_tx1_n}),
    .gtytxp_out({qsfp_tx4_p, qsfp_tx3_p, qsfp_tx2_p, qsfp_tx1_p}),

    .rxgearboxslip_in({qsfp_gt_rxgearboxslip_4, qsfp_gt_rxgearboxslip_3, qsfp_gt_rxgearboxslip_2, qsfp_gt_rxgearboxslip_1}),
    .gtwiz_userdata_rx_out({qsfp_gt_rxdata_4, qsfp_gt_rxdata_3, qsfp_gt_rxdata_2, qsfp_gt_rxdata_1}),
    .rxdatavalid_out({qsfp_gt_rxdatavalid_4, qsfp_gt_rxdatavalid_3, qsfp_gt_rxdatavalid_2, qsfp_gt_rxdatavalid_1}),
    .rxheader_out({qsfp_gt_rxheader_4, qsfp_gt_rxheader_3, qsfp_gt_rxheader_2, qsfp_gt_rxheader_1}),
    .rxheadervalid_out({qsfp_gt_rxheadervalid_4, qsfp_gt_rxheadervalid_3, qsfp_gt_rxheadervalid_2, qsfp_gt_rxheadervalid_1}),
    .rxoutclk_out(gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

assign qsfp_tx_clk_1_int = clk_156mhz_int;
assign qsfp_tx_rst_1_int = rst_156mhz_int;

assign qsfp_rx_clk_1_int = gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_rx_rst_1_reset_sync_inst (
    .clk(qsfp_rx_clk_1_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .PRBS31_ENABLE(1)
)
qsfp_phy_1_inst (
    .tx_clk(qsfp_tx_clk_1_int),
    .tx_rst(qsfp_tx_rst_1_int),
    .rx_clk(qsfp_rx_clk_1_int),
    .rx_rst(qsfp_rx_rst_1_int),
    .xgmii_txd(qsfp_txd_1_int),
    .xgmii_txc(qsfp_txc_1_int),
    .xgmii_rxd(qsfp_rxd_1_int),
    .xgmii_rxc(qsfp_rxc_1_int),
    .serdes_tx_data(qsfp_gt_txdata_1),
    .serdes_tx_hdr(qsfp_gt_txheader_1),
    .serdes_rx_data(qsfp_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_gt_rxgearboxslip_1),
    .rx_error_count(qsfp_rx_error_count_1_int),
    .rx_block_lock(qsfp_rx_block_lock_1),
    .rx_high_ber(),
    .tx_prbs31_enable(qsfp_tx_prbs31_enable_1_int),
    .rx_prbs31_enable(qsfp_rx_prbs31_enable_1_int)
);

assign qsfp_tx_clk_2_int = clk_156mhz_int;
assign qsfp_tx_rst_2_int = rst_156mhz_int;

assign qsfp_rx_clk_2_int = gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_rx_rst_2_reset_sync_inst (
    .clk(qsfp_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .PRBS31_ENABLE(1)
)
qsfp_phy_2_inst (
    .tx_clk(qsfp_tx_clk_2_int),
    .tx_rst(qsfp_tx_rst_2_int),
    .rx_clk(qsfp_rx_clk_2_int),
    .rx_rst(qsfp_rx_rst_2_int),
    .xgmii_txd(qsfp_txd_2_int),
    .xgmii_txc(qsfp_txc_2_int),
    .xgmii_rxd(qsfp_rxd_2_int),
    .xgmii_rxc(qsfp_rxc_2_int),
    .serdes_tx_data(qsfp_gt_txdata_2),
    .serdes_tx_hdr(qsfp_gt_txheader_2),
    .serdes_rx_data(qsfp_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_gt_rxgearboxslip_2),
    .rx_error_count(qsfp_rx_error_count_2_int),
    .rx_block_lock(qsfp_rx_block_lock_2),
    .rx_high_ber(),
    .tx_prbs31_enable(qsfp_tx_prbs31_enable_2_int),
    .rx_prbs31_enable(qsfp_rx_prbs31_enable_2_int)
);

assign qsfp_tx_clk_3_int = clk_156mhz_int;
assign qsfp_tx_rst_3_int = rst_156mhz_int;

assign qsfp_rx_clk_3_int = gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_rx_rst_3_reset_sync_inst (
    .clk(qsfp_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .PRBS31_ENABLE(1)
)
qsfp_phy_3_inst (
    .tx_clk(qsfp_tx_clk_3_int),
    .tx_rst(qsfp_tx_rst_3_int),
    .rx_clk(qsfp_rx_clk_3_int),
    .rx_rst(qsfp_rx_rst_3_int),
    .xgmii_txd(qsfp_txd_3_int),
    .xgmii_txc(qsfp_txc_3_int),
    .xgmii_rxd(qsfp_rxd_3_int),
    .xgmii_rxc(qsfp_rxc_3_int),
    .serdes_tx_data(qsfp_gt_txdata_3),
    .serdes_tx_hdr(qsfp_gt_txheader_3),
    .serdes_rx_data(qsfp_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_gt_rxgearboxslip_3),
    .rx_error_count(qsfp_rx_error_count_3_int),
    .rx_block_lock(qsfp_rx_block_lock_3),
    .rx_high_ber(),
    .tx_prbs31_enable(qsfp_tx_prbs31_enable_3_int),
    .rx_prbs31_enable(qsfp_rx_prbs31_enable_3_int)
);

assign qsfp_tx_clk_4_int = clk_156mhz_int;
assign qsfp_tx_rst_4_int = rst_156mhz_int;

assign qsfp_rx_clk_4_int = gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_rx_rst_4_reset_sync_inst (
    .clk(qsfp_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .PRBS31_ENABLE(1)
)
qsfp_phy_4_inst (
    .tx_clk(qsfp_tx_clk_4_int),
    .tx_rst(qsfp_tx_rst_4_int),
    .rx_clk(qsfp_rx_clk_4_int),
    .rx_rst(qsfp_rx_rst_4_int),
    .xgmii_txd(qsfp_txd_4_int),
    .xgmii_txc(qsfp_txc_4_int),
    .xgmii_rxd(qsfp_rxd_4_int),
    .xgmii_rxc(qsfp_rxc_4_int),
    .serdes_tx_data(qsfp_gt_txdata_4),
    .serdes_tx_hdr(qsfp_gt_txheader_4),
    .serdes_rx_data(qsfp_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_gt_rxgearboxslip_4),
    .rx_error_count(qsfp_rx_error_count_4_int),
    .rx_block_lock(qsfp_rx_block_lock_4),
    .rx_high_ber(),
    .tx_prbs31_enable(qsfp_tx_prbs31_enable_4_int),
    .rx_prbs31_enable(qsfp_rx_prbs31_enable_4_int)
);

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
    .qsfp_led_act(qsfp_led_act),
    .qsfp_led_stat_g(qsfp_led_stat_g),
    .qsfp_led_stat_y(qsfp_led_stat_y),
    /*
     * Ethernet: QSFP28
     */
    .qsfp_tx_clk_1(qsfp_tx_clk_1_int),
    .qsfp_tx_rst_1(qsfp_tx_rst_1_int),
    .qsfp_txd_1(qsfp_txd_1_int),
    .qsfp_txc_1(qsfp_txc_1_int),
    .qsfp_rx_clk_1(qsfp_rx_clk_1_int),
    .qsfp_rx_rst_1(qsfp_rx_rst_1_int),
    .qsfp_rxd_1(qsfp_rxd_1_int),
    .qsfp_rxc_1(qsfp_rxc_1_int),
    .qsfp_tx_clk_2(qsfp_tx_clk_2_int),
    .qsfp_tx_rst_2(qsfp_tx_rst_2_int),
    .qsfp_txd_2(qsfp_txd_2_int),
    .qsfp_txc_2(qsfp_txc_2_int),
    .qsfp_rx_clk_2(qsfp_rx_clk_2_int),
    .qsfp_rx_rst_2(qsfp_rx_rst_2_int),
    .qsfp_rxd_2(qsfp_rxd_2_int),
    .qsfp_rxc_2(qsfp_rxc_2_int),
    .qsfp_tx_clk_3(qsfp_tx_clk_3_int),
    .qsfp_tx_rst_3(qsfp_tx_rst_3_int),
    .qsfp_txd_3(qsfp_txd_3_int),
    .qsfp_txc_3(qsfp_txc_3_int),
    .qsfp_rx_clk_3(qsfp_rx_clk_3_int),
    .qsfp_rx_rst_3(qsfp_rx_rst_3_int),
    .qsfp_rxd_3(qsfp_rxd_3_int),
    .qsfp_rxc_3(qsfp_rxc_3_int),
    .qsfp_tx_clk_4(qsfp_tx_clk_4_int),
    .qsfp_tx_rst_4(qsfp_tx_rst_4_int),
    .qsfp_txd_4(qsfp_txd_4_int),
    .qsfp_txc_4(qsfp_txc_4_int),
    .qsfp_rx_clk_4(qsfp_rx_clk_4_int),
    .qsfp_rx_rst_4(qsfp_rx_rst_4_int),
    .qsfp_rxd_4(qsfp_rxd_4_int),
    .qsfp_rxc_4(qsfp_rxc_4_int)
);

endmodule
