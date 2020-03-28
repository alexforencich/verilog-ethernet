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
     * Clock: 300MHz LVDS
     */
    input  wire       clk_300mhz_p,
    input  wire       clk_300mhz_n,

    /*
     * GPIO
     */
    output wire [1:0] user_led_g,
    output wire       user_led_r,
    output wire [1:0] front_led,
    input  wire [1:0] user_sw,

    /*
     * Ethernet: QSFP28
     */
    output wire       qsfp_0_tx_0_p,
    output wire       qsfp_0_tx_0_n,
    input  wire       qsfp_0_rx_0_p,
    input  wire       qsfp_0_rx_0_n,
    output wire       qsfp_0_tx_1_p,
    output wire       qsfp_0_tx_1_n,
    input  wire       qsfp_0_rx_1_p,
    input  wire       qsfp_0_rx_1_n,
    output wire       qsfp_0_tx_2_p,
    output wire       qsfp_0_tx_2_n,
    input  wire       qsfp_0_rx_2_p,
    input  wire       qsfp_0_rx_2_n,
    output wire       qsfp_0_tx_3_p,
    output wire       qsfp_0_tx_3_n,
    input  wire       qsfp_0_rx_3_p,
    input  wire       qsfp_0_rx_3_n,
    input  wire       qsfp_0_mgt_refclk_p,
    input  wire       qsfp_0_mgt_refclk_n,
    input  wire       qsfp_0_modprs_l,
    output wire       qsfp_0_sel_l,

    output wire       qsfp_1_tx_0_p,
    output wire       qsfp_1_tx_0_n,
    input  wire       qsfp_1_rx_0_p,
    input  wire       qsfp_1_rx_0_n,
    output wire       qsfp_1_tx_1_p,
    output wire       qsfp_1_tx_1_n,
    input  wire       qsfp_1_rx_1_p,
    input  wire       qsfp_1_rx_1_n,
    output wire       qsfp_1_tx_2_p,
    output wire       qsfp_1_tx_2_n,
    input  wire       qsfp_1_rx_2_p,
    input  wire       qsfp_1_rx_2_n,
    output wire       qsfp_1_tx_3_p,
    output wire       qsfp_1_tx_3_n,
    input  wire       qsfp_1_rx_3_p,
    input  wire       qsfp_1_rx_3_n,
    input  wire       qsfp_1_mgt_refclk_p,
    input  wire       qsfp_1_mgt_refclk_n,
    input  wire       qsfp_1_modprs_l,
    output wire       qsfp_1_sel_l,

    output wire       qsfp_reset_l,
    input  wire       qsfp_int_l
);

// Clock and reset

wire clk_300mhz_ibufg;
wire clk_125mhz_mmcm_out;

// Internal 125 MHz clock
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
clk_300mhz_ibufg_inst (
   .O   (clk_300mhz_ibufg),
   .I   (clk_300mhz_p),
   .IB  (clk_300mhz_n) 
);

// MMCM instance
// 300 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 10, D = 3 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME3_BASE #(
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
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(3),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(3.333),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_300mhz_ibufg),
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
wire [1:0] user_sw_int;

debounce_switch #(
    .WIDTH(2),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({user_sw}),
    .out({user_sw_int})
);

// XGMII 10G PHY
assign qsfp_0_sel_l = 1'b0;

wire        qsfp_0_tx_clk_0_int;
wire        qsfp_0_tx_rst_0_int;
wire [63:0] qsfp_0_txd_0_int;
wire [7:0]  qsfp_0_txc_0_int;
wire        qsfp_0_rx_clk_0_int;
wire        qsfp_0_rx_rst_0_int;
wire [63:0] qsfp_0_rxd_0_int;
wire [7:0]  qsfp_0_rxc_0_int;
wire        qsfp_0_tx_clk_1_int;
wire        qsfp_0_tx_rst_1_int;
wire [63:0] qsfp_0_txd_1_int;
wire [7:0]  qsfp_0_txc_1_int;
wire        qsfp_0_rx_clk_1_int;
wire        qsfp_0_rx_rst_1_int;
wire [63:0] qsfp_0_rxd_1_int;
wire [7:0]  qsfp_0_rxc_1_int;
wire        qsfp_0_tx_clk_2_int;
wire        qsfp_0_tx_rst_2_int;
wire [63:0] qsfp_0_txd_2_int;
wire [7:0]  qsfp_0_txc_2_int;
wire        qsfp_0_rx_clk_2_int;
wire        qsfp_0_rx_rst_2_int;
wire [63:0] qsfp_0_rxd_2_int;
wire [7:0]  qsfp_0_rxc_2_int;
wire        qsfp_0_tx_clk_3_int;
wire        qsfp_0_tx_rst_3_int;
wire [63:0] qsfp_0_txd_3_int;
wire [7:0]  qsfp_0_txc_3_int;
wire        qsfp_0_rx_clk_3_int;
wire        qsfp_0_rx_rst_3_int;
wire [63:0] qsfp_0_rxd_3_int;
wire [7:0]  qsfp_0_rxc_3_int;

assign qsfp_1_sel_l = 1'b0;

wire        qsfp_1_tx_clk_0_int;
wire        qsfp_1_tx_rst_0_int;
wire [63:0] qsfp_1_txd_0_int;
wire [7:0]  qsfp_1_txc_0_int;
wire        qsfp_1_rx_clk_0_int;
wire        qsfp_1_rx_rst_0_int;
wire [63:0] qsfp_1_rxd_0_int;
wire [7:0]  qsfp_1_rxc_0_int;
wire        qsfp_1_tx_clk_1_int;
wire        qsfp_1_tx_rst_1_int;
wire [63:0] qsfp_1_txd_1_int;
wire [7:0]  qsfp_1_txc_1_int;
wire        qsfp_1_rx_clk_1_int;
wire        qsfp_1_rx_rst_1_int;
wire [63:0] qsfp_1_rxd_1_int;
wire [7:0]  qsfp_1_rxc_1_int;
wire        qsfp_1_tx_clk_2_int;
wire        qsfp_1_tx_rst_2_int;
wire [63:0] qsfp_1_txd_2_int;
wire [7:0]  qsfp_1_txc_2_int;
wire        qsfp_1_rx_clk_2_int;
wire        qsfp_1_rx_rst_2_int;
wire [63:0] qsfp_1_rxd_2_int;
wire [7:0]  qsfp_1_rxc_2_int;
wire        qsfp_1_tx_clk_3_int;
wire        qsfp_1_tx_rst_3_int;
wire [63:0] qsfp_1_txd_3_int;
wire [7:0]  qsfp_1_txc_3_int;
wire        qsfp_1_rx_clk_3_int;
wire        qsfp_1_rx_rst_3_int;
wire [63:0] qsfp_1_rxd_3_int;
wire [7:0]  qsfp_1_rxc_3_int;

assign qsfp_reset_l = 1'b1;

wire qsfp_0_rx_block_lock_0;
wire qsfp_0_rx_block_lock_1;
wire qsfp_0_rx_block_lock_2;
wire qsfp_0_rx_block_lock_3;

wire qsfp_1_rx_block_lock_0;
wire qsfp_1_rx_block_lock_1;
wire qsfp_1_rx_block_lock_2;
wire qsfp_1_rx_block_lock_3;

wire qsfp_0_mgt_refclk;
wire qsfp_1_mgt_refclk;

wire [7:0] gt_txclkout;
wire gt_txusrclk;

wire [7:0] gt_rxclkout;
wire [7:0] gt_rxusrclk;

wire gt_reset_tx_done;
wire gt_reset_rx_done;

wire [7:0] gt_txprgdivresetdone;
wire [7:0] gt_txpmaresetdone;
wire [7:0] gt_rxprgdivresetdone;
wire [7:0] gt_rxpmaresetdone;

wire gt_tx_reset = ~((&gt_txprgdivresetdone) & (&gt_txpmaresetdone));
wire gt_rx_reset = ~&gt_rxpmaresetdone;

reg gt_userclk_tx_active = 1'b0;
reg [7:0] gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_0_mgt_refclk_inst (
    .I             (qsfp_0_mgt_refclk_p),
    .IB            (qsfp_0_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_0_mgt_refclk),
    .ODIV2         ()
);

IBUFDS_GTE4 ibufds_gte4_qsfp_1_mgt_refclk_inst (
    .I             (qsfp_1_mgt_refclk_p),
    .IB            (qsfp_1_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_1_mgt_refclk),
    .ODIV2         ()
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

generate

genvar n;

for (n = 0; n < 8; n = n + 1) begin

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

wire [5:0] qsfp_0_gt_txheader_0;
wire [63:0] qsfp_0_gt_txdata_0;
wire qsfp_0_gt_rxgearboxslip_0;
wire [5:0] qsfp_0_gt_rxheader_0;
wire [1:0] qsfp_0_gt_rxheadervalid_0;
wire [63:0] qsfp_0_gt_rxdata_0;
wire [1:0] qsfp_0_gt_rxdatavalid_0;

wire [5:0] qsfp_0_gt_txheader_1;
wire [63:0] qsfp_0_gt_txdata_1;
wire qsfp_0_gt_rxgearboxslip_1;
wire [5:0] qsfp_0_gt_rxheader_1;
wire [1:0] qsfp_0_gt_rxheadervalid_1;
wire [63:0] qsfp_0_gt_rxdata_1;
wire [1:0] qsfp_0_gt_rxdatavalid_1;

wire [5:0] qsfp_0_gt_txheader_2;
wire [63:0] qsfp_0_gt_txdata_2;
wire qsfp_0_gt_rxgearboxslip_2;
wire [5:0] qsfp_0_gt_rxheader_2;
wire [1:0] qsfp_0_gt_rxheadervalid_2;
wire [63:0] qsfp_0_gt_rxdata_2;
wire [1:0] qsfp_0_gt_rxdatavalid_2;

wire [5:0] qsfp_0_gt_txheader_3;
wire [63:0] qsfp_0_gt_txdata_3;
wire qsfp_0_gt_rxgearboxslip_3;
wire [5:0] qsfp_0_gt_rxheader_3;
wire [1:0] qsfp_0_gt_rxheadervalid_3;
wire [63:0] qsfp_0_gt_rxdata_3;
wire [1:0] qsfp_0_gt_rxdatavalid_3;

wire [5:0] qsfp_1_gt_txheader_0;
wire [63:0] qsfp_1_gt_txdata_0;
wire qsfp_1_gt_rxgearboxslip_0;
wire [5:0] qsfp_1_gt_rxheader_0;
wire [1:0] qsfp_1_gt_rxheadervalid_0;
wire [63:0] qsfp_1_gt_rxdata_0;
wire [1:0] qsfp_1_gt_rxdatavalid_0;

wire [5:0] qsfp_1_gt_txheader_1;
wire [63:0] qsfp_1_gt_txdata_1;
wire qsfp_1_gt_rxgearboxslip_1;
wire [5:0] qsfp_1_gt_rxheader_1;
wire [1:0] qsfp_1_gt_rxheadervalid_1;
wire [63:0] qsfp_1_gt_rxdata_1;
wire [1:0] qsfp_1_gt_rxdatavalid_1;

wire [5:0] qsfp_1_gt_txheader_2;
wire [63:0] qsfp_1_gt_txdata_2;
wire qsfp_1_gt_rxgearboxslip_2;
wire [5:0] qsfp_1_gt_rxheader_2;
wire [1:0] qsfp_1_gt_rxheadervalid_2;
wire [63:0] qsfp_1_gt_rxdata_2;
wire [1:0] qsfp_1_gt_rxdatavalid_2;

wire [5:0] qsfp_1_gt_txheader_3;
wire [63:0] qsfp_1_gt_txdata_3;
wire qsfp_1_gt_rxgearboxslip_3;
wire [5:0] qsfp_1_gt_rxheader_3;
wire [1:0] qsfp_1_gt_rxheadervalid_3;
wire [63:0] qsfp_1_gt_rxdata_3;
wire [1:0] qsfp_1_gt_rxdatavalid_3;

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

    .gtrefclk00_in({qsfp_0_mgt_refclk, qsfp_1_mgt_refclk}),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_0_rx_3_n, qsfp_0_rx_2_n, qsfp_0_rx_1_n, qsfp_0_rx_0_n, qsfp_1_rx_3_n, qsfp_1_rx_2_n, qsfp_1_rx_1_n, qsfp_1_rx_0_n}),
    .gtyrxp_in({qsfp_0_rx_3_p, qsfp_0_rx_2_p, qsfp_0_rx_1_p, qsfp_0_rx_0_p, qsfp_1_rx_3_p, qsfp_1_rx_2_p, qsfp_1_rx_1_p, qsfp_1_rx_0_p}),

    .rxusrclk_in(gt_rxusrclk),
    .rxusrclk2_in(gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_0_gt_txdata_3, qsfp_0_gt_txdata_2, qsfp_0_gt_txdata_1, qsfp_0_gt_txdata_0, qsfp_1_gt_txdata_3, qsfp_1_gt_txdata_2, qsfp_1_gt_txdata_1, qsfp_1_gt_txdata_0}),
    .txheader_in({qsfp_0_gt_txheader_3, qsfp_0_gt_txheader_2, qsfp_0_gt_txheader_1, qsfp_0_gt_txheader_0, qsfp_1_gt_txheader_3, qsfp_1_gt_txheader_2, qsfp_1_gt_txheader_1, qsfp_1_gt_txheader_0}),
    .txsequence_in({8{1'b0}}),

    .txusrclk_in({8{gt_txusrclk}}),
    .txusrclk2_in({8{gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_0_tx_3_n, qsfp_0_tx_2_n, qsfp_0_tx_1_n, qsfp_0_tx_0_n, qsfp_1_tx_3_n, qsfp_1_tx_2_n, qsfp_1_tx_1_n, qsfp_1_tx_0_n}),
    .gtytxp_out({qsfp_0_tx_3_p, qsfp_0_tx_2_p, qsfp_0_tx_1_p, qsfp_0_tx_0_p, qsfp_1_tx_3_p, qsfp_1_tx_2_p, qsfp_1_tx_1_p, qsfp_1_tx_0_p}),

    .rxgearboxslip_in({qsfp_0_gt_rxgearboxslip_3, qsfp_0_gt_rxgearboxslip_2, qsfp_0_gt_rxgearboxslip_1, qsfp_0_gt_rxgearboxslip_0, qsfp_1_gt_rxgearboxslip_3, qsfp_1_gt_rxgearboxslip_2, qsfp_1_gt_rxgearboxslip_1, qsfp_1_gt_rxgearboxslip_0}),
    .gtwiz_userdata_rx_out({qsfp_0_gt_rxdata_3, qsfp_0_gt_rxdata_2, qsfp_0_gt_rxdata_1, qsfp_0_gt_rxdata_0, qsfp_1_gt_rxdata_3, qsfp_1_gt_rxdata_2, qsfp_1_gt_rxdata_1, qsfp_1_gt_rxdata_0}),
    .rxdatavalid_out({qsfp_0_gt_rxdatavalid_3, qsfp_0_gt_rxdatavalid_2, qsfp_0_gt_rxdatavalid_1, qsfp_0_gt_rxdatavalid_0, qsfp_1_gt_rxdatavalid_3, qsfp_1_gt_rxdatavalid_2, qsfp_1_gt_rxdatavalid_1, qsfp_1_gt_rxdatavalid_0}),
    .rxheader_out({qsfp_0_gt_rxheader_3, qsfp_0_gt_rxheader_2, qsfp_0_gt_rxheader_1, qsfp_0_gt_rxheader_0, qsfp_1_gt_rxheader_3, qsfp_1_gt_rxheader_2, qsfp_1_gt_rxheader_1, qsfp_1_gt_rxheader_0}),
    .rxheadervalid_out({qsfp_0_gt_rxheadervalid_3, qsfp_0_gt_rxheadervalid_2, qsfp_0_gt_rxheadervalid_1, qsfp_0_gt_rxheadervalid_0, qsfp_1_gt_rxheadervalid_3, qsfp_1_gt_rxheadervalid_2, qsfp_1_gt_rxheadervalid_1, qsfp_1_gt_rxheadervalid_0}),
    .rxoutclk_out(gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

assign qsfp_0_tx_clk_0_int = clk_156mhz_int;
assign qsfp_0_tx_rst_0_int = rst_156mhz_int;

assign qsfp_0_rx_clk_0_int = gt_rxusrclk[4];

sync_reset #(
    .N(4)
)
qsfp_0_rx_rst_0_reset_sync_inst (
    .clk(qsfp_0_rx_clk_0_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_0_rx_rst_0_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_0_inst (
    .tx_clk(qsfp_0_tx_clk_0_int),
    .tx_rst(qsfp_0_tx_rst_0_int),
    .rx_clk(qsfp_0_rx_clk_0_int),
    .rx_rst(qsfp_0_rx_rst_0_int),
    .xgmii_txd(qsfp_0_txd_0_int),
    .xgmii_txc(qsfp_0_txc_0_int),
    .xgmii_rxd(qsfp_0_rxd_0_int),
    .xgmii_rxc(qsfp_0_rxc_0_int),
    .serdes_tx_data(qsfp_0_gt_txdata_0),
    .serdes_tx_hdr(qsfp_0_gt_txheader_0),
    .serdes_rx_data(qsfp_0_gt_rxdata_0),
    .serdes_rx_hdr(qsfp_0_gt_rxheader_0),
    .serdes_rx_bitslip(qsfp_0_gt_rxgearboxslip_0),
    .rx_block_lock(qsfp_0_rx_block_lock_0),
    .rx_high_ber()
);

assign qsfp_0_tx_clk_1_int = clk_156mhz_int;
assign qsfp_0_tx_rst_1_int = rst_156mhz_int;

assign qsfp_0_rx_clk_1_int = gt_rxusrclk[5];

sync_reset #(
    .N(4)
)
qsfp_0_rx_rst_1_reset_sync_inst (
    .clk(qsfp_0_rx_clk_1_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_0_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_1_inst (
    .tx_clk(qsfp_0_tx_clk_1_int),
    .tx_rst(qsfp_0_tx_rst_1_int),
    .rx_clk(qsfp_0_rx_clk_1_int),
    .rx_rst(qsfp_0_rx_rst_1_int),
    .xgmii_txd(qsfp_0_txd_1_int),
    .xgmii_txc(qsfp_0_txc_1_int),
    .xgmii_rxd(qsfp_0_rxd_1_int),
    .xgmii_rxc(qsfp_0_rxc_1_int),
    .serdes_tx_data(qsfp_0_gt_txdata_1),
    .serdes_tx_hdr(qsfp_0_gt_txheader_1),
    .serdes_rx_data(qsfp_0_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_0_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_0_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_0_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_0_tx_clk_2_int = clk_156mhz_int;
assign qsfp_0_tx_rst_2_int = rst_156mhz_int;

assign qsfp_0_rx_clk_2_int = gt_rxusrclk[6];

sync_reset #(
    .N(4)
)
qsfp_0_rx_rst_2_reset_sync_inst (
    .clk(qsfp_0_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_0_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_2_inst (
    .tx_clk(qsfp_0_tx_clk_2_int),
    .tx_rst(qsfp_0_tx_rst_2_int),
    .rx_clk(qsfp_0_rx_clk_2_int),
    .rx_rst(qsfp_0_rx_rst_2_int),
    .xgmii_txd(qsfp_0_txd_2_int),
    .xgmii_txc(qsfp_0_txc_2_int),
    .xgmii_rxd(qsfp_0_rxd_2_int),
    .xgmii_rxc(qsfp_0_rxc_2_int),
    .serdes_tx_data(qsfp_0_gt_txdata_2),
    .serdes_tx_hdr(qsfp_0_gt_txheader_2),
    .serdes_rx_data(qsfp_0_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_0_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_0_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_0_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_0_tx_clk_3_int = clk_156mhz_int;
assign qsfp_0_tx_rst_3_int = rst_156mhz_int;

assign qsfp_0_rx_clk_3_int = gt_rxusrclk[7];

sync_reset #(
    .N(4)
)
qsfp_0_rx_rst_3_reset_sync_inst (
    .clk(qsfp_0_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_0_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_0_phy_3_inst (
    .tx_clk(qsfp_0_tx_clk_3_int),
    .tx_rst(qsfp_0_tx_rst_3_int),
    .rx_clk(qsfp_0_rx_clk_3_int),
    .rx_rst(qsfp_0_rx_rst_3_int),
    .xgmii_txd(qsfp_0_txd_3_int),
    .xgmii_txc(qsfp_0_txc_3_int),
    .xgmii_rxd(qsfp_0_rxd_3_int),
    .xgmii_rxc(qsfp_0_rxc_3_int),
    .serdes_tx_data(qsfp_0_gt_txdata_3),
    .serdes_tx_hdr(qsfp_0_gt_txheader_3),
    .serdes_rx_data(qsfp_0_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_0_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_0_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_0_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_1_tx_clk_0_int = clk_156mhz_int;
assign qsfp_1_tx_rst_0_int = rst_156mhz_int;

assign qsfp_1_rx_clk_0_int = gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_0_reset_sync_inst (
    .clk(qsfp_1_rx_clk_0_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_0_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_0_inst (
    .tx_clk(qsfp_1_tx_clk_0_int),
    .tx_rst(qsfp_1_tx_rst_0_int),
    .rx_clk(qsfp_1_rx_clk_0_int),
    .rx_rst(qsfp_1_rx_rst_0_int),
    .xgmii_txd(qsfp_1_txd_0_int),
    .xgmii_txc(qsfp_1_txc_0_int),
    .xgmii_rxd(qsfp_1_rxd_0_int),
    .xgmii_rxc(qsfp_1_rxc_0_int),
    .serdes_tx_data(qsfp_1_gt_txdata_0),
    .serdes_tx_hdr(qsfp_1_gt_txheader_0),
    .serdes_rx_data(qsfp_1_gt_rxdata_0),
    .serdes_rx_hdr(qsfp_1_gt_rxheader_0),
    .serdes_rx_bitslip(qsfp_1_gt_rxgearboxslip_0),
    .rx_block_lock(qsfp_1_rx_block_lock_0),
    .rx_high_ber()
);

assign qsfp_1_tx_clk_1_int = clk_156mhz_int;
assign qsfp_1_tx_rst_1_int = rst_156mhz_int;

assign qsfp_1_rx_clk_1_int = gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_1_reset_sync_inst (
    .clk(qsfp_1_rx_clk_1_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_1_inst (
    .tx_clk(qsfp_1_tx_clk_1_int),
    .tx_rst(qsfp_1_tx_rst_1_int),
    .rx_clk(qsfp_1_rx_clk_1_int),
    .rx_rst(qsfp_1_rx_rst_1_int),
    .xgmii_txd(qsfp_1_txd_1_int),
    .xgmii_txc(qsfp_1_txc_1_int),
    .xgmii_rxd(qsfp_1_rxd_1_int),
    .xgmii_rxc(qsfp_1_rxc_1_int),
    .serdes_tx_data(qsfp_1_gt_txdata_1),
    .serdes_tx_hdr(qsfp_1_gt_txheader_1),
    .serdes_rx_data(qsfp_1_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_1_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_1_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_1_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_1_tx_clk_2_int = clk_156mhz_int;
assign qsfp_1_tx_rst_2_int = rst_156mhz_int;

assign qsfp_1_rx_clk_2_int = gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_2_reset_sync_inst (
    .clk(qsfp_1_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_2_inst (
    .tx_clk(qsfp_1_tx_clk_2_int),
    .tx_rst(qsfp_1_tx_rst_2_int),
    .rx_clk(qsfp_1_rx_clk_2_int),
    .rx_rst(qsfp_1_rx_rst_2_int),
    .xgmii_txd(qsfp_1_txd_2_int),
    .xgmii_txc(qsfp_1_txc_2_int),
    .xgmii_rxd(qsfp_1_rxd_2_int),
    .xgmii_rxc(qsfp_1_rxc_2_int),
    .serdes_tx_data(qsfp_1_gt_txdata_2),
    .serdes_tx_hdr(qsfp_1_gt_txheader_2),
    .serdes_rx_data(qsfp_1_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_1_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_1_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_1_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_1_tx_clk_3_int = clk_156mhz_int;
assign qsfp_1_tx_rst_3_int = rst_156mhz_int;

assign qsfp_1_rx_clk_3_int = gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_3_reset_sync_inst (
    .clk(qsfp_1_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1),
    .TX_SERDES_PIPELINE(2),
    .RX_SERDES_PIPELINE(2),
    .COUNT_125US(125000/2.56)
)
qsfp_1_phy_3_inst (
    .tx_clk(qsfp_1_tx_clk_3_int),
    .tx_rst(qsfp_1_tx_rst_3_int),
    .rx_clk(qsfp_1_rx_clk_3_int),
    .rx_rst(qsfp_1_rx_rst_3_int),
    .xgmii_txd(qsfp_1_txd_3_int),
    .xgmii_txc(qsfp_1_txc_3_int),
    .xgmii_rxd(qsfp_1_rxd_3_int),
    .xgmii_rxc(qsfp_1_rxc_3_int),
    .serdes_tx_data(qsfp_1_gt_txdata_3),
    .serdes_tx_hdr(qsfp_1_gt_txheader_3),
    .serdes_rx_data(qsfp_1_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_1_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_1_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_1_rx_block_lock_3),
    .rx_high_ber()
);

//assign led = sw[0] ? {qsfp_1_rx_block_lock_4, qsfp_1_rx_block_lock_3, qsfp_1_rx_block_lock_2, qsfp_1_rx_block_lock_1, qsfp_0_rx_block_lock_4, qsfp_0_rx_block_lock_3, qsfp_0_rx_block_lock_2, qsfp_0_rx_block_lock_1} : led_int;
assign front_led = {1'b0, qsfp_0_rx_block_lock_0};

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
    .user_led_g(user_led_g),
    .user_led_r(user_led_r),
    //.front_led(front_led),
    .user_sw(user_sw_int),

    /*
     * Ethernet: QSFP28
     */
    .qsfp_0_tx_clk_0(qsfp_0_tx_clk_0_int),
    .qsfp_0_tx_rst_0(qsfp_0_tx_rst_0_int),
    .qsfp_0_txd_0(qsfp_0_txd_0_int),
    .qsfp_0_txc_0(qsfp_0_txc_0_int),
    .qsfp_0_rx_clk_0(qsfp_0_rx_clk_0_int),
    .qsfp_0_rx_rst_0(qsfp_0_rx_rst_0_int),
    .qsfp_0_rxd_0(qsfp_0_rxd_0_int),
    .qsfp_0_rxc_0(qsfp_0_rxc_0_int),
    .qsfp_0_tx_clk_1(qsfp_0_tx_clk_1_int),
    .qsfp_0_tx_rst_1(qsfp_0_tx_rst_1_int),
    .qsfp_0_txd_1(qsfp_0_txd_1_int),
    .qsfp_0_txc_1(qsfp_0_txc_1_int),
    .qsfp_0_rx_clk_1(qsfp_0_rx_clk_1_int),
    .qsfp_0_rx_rst_1(qsfp_0_rx_rst_1_int),
    .qsfp_0_rxd_1(qsfp_0_rxd_1_int),
    .qsfp_0_rxc_1(qsfp_0_rxc_1_int),
    .qsfp_0_tx_clk_2(qsfp_0_tx_clk_2_int),
    .qsfp_0_tx_rst_2(qsfp_0_tx_rst_2_int),
    .qsfp_0_txd_2(qsfp_0_txd_2_int),
    .qsfp_0_txc_2(qsfp_0_txc_2_int),
    .qsfp_0_rx_clk_2(qsfp_0_rx_clk_2_int),
    .qsfp_0_rx_rst_2(qsfp_0_rx_rst_2_int),
    .qsfp_0_rxd_2(qsfp_0_rxd_2_int),
    .qsfp_0_rxc_2(qsfp_0_rxc_2_int),
    .qsfp_0_tx_clk_3(qsfp_0_tx_clk_3_int),
    .qsfp_0_tx_rst_3(qsfp_0_tx_rst_3_int),
    .qsfp_0_txd_3(qsfp_0_txd_3_int),
    .qsfp_0_txc_3(qsfp_0_txc_3_int),
    .qsfp_0_rx_clk_3(qsfp_0_rx_clk_3_int),
    .qsfp_0_rx_rst_3(qsfp_0_rx_rst_3_int),
    .qsfp_0_rxd_3(qsfp_0_rxd_3_int),
    .qsfp_0_rxc_3(qsfp_0_rxc_3_int),
    .qsfp_1_tx_clk_0(qsfp_1_tx_clk_0_int),
    .qsfp_1_tx_rst_0(qsfp_1_tx_rst_0_int),
    .qsfp_1_txd_0(qsfp_1_txd_0_int),
    .qsfp_1_txc_0(qsfp_1_txc_0_int),
    .qsfp_1_rx_clk_0(qsfp_1_rx_clk_0_int),
    .qsfp_1_rx_rst_0(qsfp_1_rx_rst_0_int),
    .qsfp_1_rxd_0(qsfp_1_rxd_0_int),
    .qsfp_1_rxc_0(qsfp_1_rxc_0_int),
    .qsfp_1_tx_clk_1(qsfp_1_tx_clk_1_int),
    .qsfp_1_tx_rst_1(qsfp_1_tx_rst_1_int),
    .qsfp_1_txd_1(qsfp_1_txd_1_int),
    .qsfp_1_txc_1(qsfp_1_txc_1_int),
    .qsfp_1_rx_clk_1(qsfp_1_rx_clk_1_int),
    .qsfp_1_rx_rst_1(qsfp_1_rx_rst_1_int),
    .qsfp_1_rxd_1(qsfp_1_rxd_1_int),
    .qsfp_1_rxc_1(qsfp_1_rxc_1_int),
    .qsfp_1_tx_clk_2(qsfp_1_tx_clk_2_int),
    .qsfp_1_tx_rst_2(qsfp_1_tx_rst_2_int),
    .qsfp_1_txd_2(qsfp_1_txd_2_int),
    .qsfp_1_txc_2(qsfp_1_txc_2_int),
    .qsfp_1_rx_clk_2(qsfp_1_rx_clk_2_int),
    .qsfp_1_rx_rst_2(qsfp_1_rx_rst_2_int),
    .qsfp_1_rxd_2(qsfp_1_rxd_2_int),
    .qsfp_1_rxc_2(qsfp_1_rxc_2_int),
    .qsfp_1_tx_clk_3(qsfp_1_tx_clk_3_int),
    .qsfp_1_tx_rst_3(qsfp_1_tx_rst_3_int),
    .qsfp_1_txd_3(qsfp_1_txd_3_int),
    .qsfp_1_txc_3(qsfp_1_txc_3_int),
    .qsfp_1_rx_clk_3(qsfp_1_rx_clk_3_int),
    .qsfp_1_rx_rst_3(qsfp_1_rx_rst_3_int),
    .qsfp_1_rxd_3(qsfp_1_rxd_3_int),
    .qsfp_1_rxc_3(qsfp_1_rxc_3_int)
);

endmodule
