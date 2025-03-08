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
     * Reset: Push button, active low
     */
    input  wire       reset,

    /*
     * GPIO
     */
    input  wire [3:0] sw,
    output wire [2:0] led,

    /*
     * I2C for board management
     */
    inout  wire       i2c_scl,
    inout  wire       i2c_sda,

    /*
     * Ethernet: QSFP28
     */
    output wire       qsfp0_tx1_p,
    output wire       qsfp0_tx1_n,
    input  wire       qsfp0_rx1_p,
    input  wire       qsfp0_rx1_n,
    output wire       qsfp0_tx2_p,
    output wire       qsfp0_tx2_n,
    input  wire       qsfp0_rx2_p,
    input  wire       qsfp0_rx2_n,
    output wire       qsfp0_tx3_p,
    output wire       qsfp0_tx3_n,
    input  wire       qsfp0_rx3_p,
    input  wire       qsfp0_rx3_n,
    output wire       qsfp0_tx4_p,
    output wire       qsfp0_tx4_n,
    input  wire       qsfp0_rx4_p,
    input  wire       qsfp0_rx4_n,
    // input  wire       qsfp0_mgt_refclk_0_p,
    // input  wire       qsfp0_mgt_refclk_0_n,
    input  wire       qsfp0_mgt_refclk_1_p,
    input  wire       qsfp0_mgt_refclk_1_n,
    output wire       qsfp0_modsell,
    output wire       qsfp0_resetl,
    input  wire       qsfp0_modprsl,
    input  wire       qsfp0_intl,
    output wire       qsfp0_lpmode,
    output wire       qsfp0_refclk_reset,
    output wire [1:0] qsfp0_fs,

    output wire       qsfp1_tx1_p,
    output wire       qsfp1_tx1_n,
    input  wire       qsfp1_rx1_p,
    input  wire       qsfp1_rx1_n,
    output wire       qsfp1_tx2_p,
    output wire       qsfp1_tx2_n,
    input  wire       qsfp1_rx2_p,
    input  wire       qsfp1_rx2_n,
    output wire       qsfp1_tx3_p,
    output wire       qsfp1_tx3_n,
    input  wire       qsfp1_rx3_p,
    input  wire       qsfp1_rx3_n,
    output wire       qsfp1_tx4_p,
    output wire       qsfp1_tx4_n,
    input  wire       qsfp1_rx4_p,
    input  wire       qsfp1_rx4_n,
    // input  wire       qsfp1_mgt_refclk_0_p,
    // input  wire       qsfp1_mgt_refclk_0_n,
    // input  wire       qsfp1_mgt_refclk_1_p,
    // input  wire       qsfp1_mgt_refclk_1_n,
    output wire       qsfp1_modsell,
    output wire       qsfp1_resetl,
    input  wire       qsfp1_modprsl,
    input  wire       qsfp1_intl,
    output wire       qsfp1_lpmode,
    output wire       qsfp1_refclk_reset,
    output wire [1:0] qsfp1_fs,

    /*
     * UART: 500000 bps, 8N1
     */
    output wire       uart_rxd,
    input  wire       uart_txd
);

// Clock and reset

wire cfgmclk_int;

wire clk_161mhz_ref_int;

wire clk_125mhz_mmcm_out;

// Internal 125 MHz clock
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst;
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
    .sync_reset_out(rst_125mhz_int)
);

// GPIO
wire [3:0] sw_int;

debounce_switch #(
    .WIDTH(4),
    .N(4),
    .RATE(156000)
)
debounce_switch_inst (
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    .in({sw}),
    .out({sw_int})
);

wire uart_txd_int;

sync_signal #(
    .WIDTH(1),
    .N(2)
)
sync_signal_inst (
    .clk(clk_156mhz_int),
    .in({uart_txd}),
    .out({uart_txd_int})
);

// SI570 I2C
wire i2c_scl_i;
wire i2c_scl_o = 1'b1;
wire i2c_scl_t = 1'b1;
wire i2c_sda_i;
wire i2c_sda_o = 1'b1;
wire i2c_sda_t = 1'b1;

assign i2c_scl_i = i2c_scl;
assign i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_sda;
assign i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

// startupe3 instance
wire cfgmclk;

STARTUPE3
startupe3_inst (
    .CFGCLK(),
    .CFGMCLK(cfgmclk),
    .DI(4'd0),
    .DO(),
    .DTS(1'b1),
    .EOS(),
    .FCSBO(1'b0),
    .FCSBTS(1'b1),
    .GSR(1'b0),
    .GTS(1'b0),
    .KEYCLEARB(1'b1),
    .PACK(1'b0),
    .PREQ(),
    .USRCCLKO(1'b0),
    .USRCCLKTS(1'b1),
    .USRDONEO(1'b0),
    .USRDONETS(1'b1)
);

BUFG
cfgmclk_bufg_inst (
    .I(cfgmclk),
    .O(cfgmclk_int)
);

// configure SI5335 clock generators
reg qsfp_refclk_reset_reg = 1'b1;
reg sys_reset_reg = 1'b1;

reg [9:0] reset_timer_reg = 0;

assign mmcm_rst = sys_reset_reg;

always @(posedge cfgmclk_int) begin
    if (&reset_timer_reg) begin
        if (qsfp_refclk_reset_reg) begin
            qsfp_refclk_reset_reg <= 1'b0;
            reset_timer_reg <= 0;
        end else begin
            qsfp_refclk_reset_reg <= 1'b0;
            sys_reset_reg <= 1'b0;
        end
    end else begin
        reset_timer_reg <= reset_timer_reg + 1;
    end

    if (!reset) begin
        qsfp_refclk_reset_reg <= 1'b1;
        sys_reset_reg <= 1'b1;
        reset_timer_reg <= 0;
    end
end

// XGMII 10G PHY
assign qsfp0_modsell = 1'b0;
assign qsfp0_resetl = 1'b1;
assign qsfp0_lpmode = 1'b0;
assign qsfp0_refclk_reset = qsfp_refclk_reset_reg;
assign qsfp0_fs = 2'b10;

wire        qsfp0_tx_clk_1_int;
wire        qsfp0_tx_rst_1_int;
wire [63:0] qsfp0_txd_1_int;
wire [7:0]  qsfp0_txc_1_int;
wire        qsfp0_rx_clk_1_int;
wire        qsfp0_rx_rst_1_int;
wire [63:0] qsfp0_rxd_1_int;
wire [7:0]  qsfp0_rxc_1_int;
wire        qsfp0_tx_clk_2_int;
wire        qsfp0_tx_rst_2_int;
wire [63:0] qsfp0_txd_2_int;
wire [7:0]  qsfp0_txc_2_int;
wire        qsfp0_rx_clk_2_int;
wire        qsfp0_rx_rst_2_int;
wire [63:0] qsfp0_rxd_2_int;
wire [7:0]  qsfp0_rxc_2_int;
wire        qsfp0_tx_clk_3_int;
wire        qsfp0_tx_rst_3_int;
wire [63:0] qsfp0_txd_3_int;
wire [7:0]  qsfp0_txc_3_int;
wire        qsfp0_rx_clk_3_int;
wire        qsfp0_rx_rst_3_int;
wire [63:0] qsfp0_rxd_3_int;
wire [7:0]  qsfp0_rxc_3_int;
wire        qsfp0_tx_clk_4_int;
wire        qsfp0_tx_rst_4_int;
wire [63:0] qsfp0_txd_4_int;
wire [7:0]  qsfp0_txc_4_int;
wire        qsfp0_rx_clk_4_int;
wire        qsfp0_rx_rst_4_int;
wire [63:0] qsfp0_rxd_4_int;
wire [7:0]  qsfp0_rxc_4_int;

assign qsfp1_modsell = 1'b0;
assign qsfp1_resetl = 1'b1;
assign qsfp1_lpmode = 1'b0;
assign qsfp1_refclk_reset = qsfp_refclk_reset_reg;
assign qsfp1_fs = 2'b10;

wire        qsfp1_tx_clk_1_int;
wire        qsfp1_tx_rst_1_int;
wire [63:0] qsfp1_txd_1_int;
wire [7:0]  qsfp1_txc_1_int;
wire        qsfp1_rx_clk_1_int;
wire        qsfp1_rx_rst_1_int;
wire [63:0] qsfp1_rxd_1_int;
wire [7:0]  qsfp1_rxc_1_int;
wire        qsfp1_tx_clk_2_int;
wire        qsfp1_tx_rst_2_int;
wire [63:0] qsfp1_txd_2_int;
wire [7:0]  qsfp1_txc_2_int;
wire        qsfp1_rx_clk_2_int;
wire        qsfp1_rx_rst_2_int;
wire [63:0] qsfp1_rxd_2_int;
wire [7:0]  qsfp1_rxc_2_int;
wire        qsfp1_tx_clk_3_int;
wire        qsfp1_tx_rst_3_int;
wire [63:0] qsfp1_txd_3_int;
wire [7:0]  qsfp1_txc_3_int;
wire        qsfp1_rx_clk_3_int;
wire        qsfp1_rx_rst_3_int;
wire [63:0] qsfp1_rxd_3_int;
wire [7:0]  qsfp1_rxc_3_int;
wire        qsfp1_tx_clk_4_int;
wire        qsfp1_tx_rst_4_int;
wire [63:0] qsfp1_txd_4_int;
wire [7:0]  qsfp1_txc_4_int;
wire        qsfp1_rx_clk_4_int;
wire        qsfp1_rx_rst_4_int;
wire [63:0] qsfp1_rxd_4_int;
wire [7:0]  qsfp1_rxc_4_int;

wire qsfp0_rx_block_lock_1;
wire qsfp0_rx_block_lock_2;
wire qsfp0_rx_block_lock_3;
wire qsfp0_rx_block_lock_4;

wire qsfp1_rx_block_lock_1;
wire qsfp1_rx_block_lock_2;
wire qsfp1_rx_block_lock_3;
wire qsfp1_rx_block_lock_4;

wire [7:0] qsfp_gtpowergood;

wire qsfp0_mgt_refclk_1;
wire qsfp0_mgt_refclk_1_int;
wire qsfp0_mgt_refclk_1_bufg;

assign clk_161mhz_ref_int = qsfp0_mgt_refclk_1_bufg;

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

IBUFDS_GTE4 ibufds_gte4_qsfp0_mgt_refclk_1_inst (
    .I             (qsfp0_mgt_refclk_1_p),
    .IB            (qsfp0_mgt_refclk_1_n),
    .CEB           (1'b0),
    .O             (qsfp0_mgt_refclk_1),
    .ODIV2         (qsfp0_mgt_refclk_1_int)
);

BUFG_GT bufg_gt_refclk_inst (
    .CE      (&qsfp_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (qsfp0_mgt_refclk_1_int),
    .O       (qsfp0_mgt_refclk_1_bufg)
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
    .sync_reset_out(rst_156mhz_int)
);

wire [5:0] qsfp0_gt_txheader_1;
wire [127:0] qsfp0_gt_txdata_1;
wire qsfp0_gt_rxgearboxslip_1;
wire [5:0] qsfp0_gt_rxheader_1;
wire [1:0] qsfp0_gt_rxheadervalid_1;
wire [127:0] qsfp0_gt_rxdata_1;
wire [1:0] qsfp0_gt_rxdatavalid_1;

wire [5:0] qsfp0_gt_txheader_2;
wire [127:0] qsfp0_gt_txdata_2;
wire qsfp0_gt_rxgearboxslip_2;
wire [5:0] qsfp0_gt_rxheader_2;
wire [1:0] qsfp0_gt_rxheadervalid_2;
wire [127:0] qsfp0_gt_rxdata_2;
wire [1:0] qsfp0_gt_rxdatavalid_2;

wire [5:0] qsfp0_gt_txheader_3;
wire [127:0] qsfp0_gt_txdata_3;
wire qsfp0_gt_rxgearboxslip_3;
wire [5:0] qsfp0_gt_rxheader_3;
wire [1:0] qsfp0_gt_rxheadervalid_3;
wire [127:0] qsfp0_gt_rxdata_3;
wire [1:0] qsfp0_gt_rxdatavalid_3;

wire [5:0] qsfp0_gt_txheader_4;
wire [127:0] qsfp0_gt_txdata_4;
wire qsfp0_gt_rxgearboxslip_4;
wire [5:0] qsfp0_gt_rxheader_4;
wire [1:0] qsfp0_gt_rxheadervalid_4;
wire [127:0] qsfp0_gt_rxdata_4;
wire [1:0] qsfp0_gt_rxdatavalid_4;

wire [5:0] qsfp1_gt_txheader_1;
wire [127:0] qsfp1_gt_txdata_1;
wire qsfp1_gt_rxgearboxslip_1;
wire [5:0] qsfp1_gt_rxheader_1;
wire [1:0] qsfp1_gt_rxheadervalid_1;
wire [127:0] qsfp1_gt_rxdata_1;
wire [1:0] qsfp1_gt_rxdatavalid_1;

wire [5:0] qsfp1_gt_txheader_2;
wire [127:0] qsfp1_gt_txdata_2;
wire qsfp1_gt_rxgearboxslip_2;
wire [5:0] qsfp1_gt_rxheader_2;
wire [1:0] qsfp1_gt_rxheadervalid_2;
wire [127:0] qsfp1_gt_rxdata_2;
wire [1:0] qsfp1_gt_rxdatavalid_2;

wire [5:0] qsfp1_gt_txheader_3;
wire [127:0] qsfp1_gt_txdata_3;
wire qsfp1_gt_rxgearboxslip_3;
wire [5:0] qsfp1_gt_rxheader_3;
wire [1:0] qsfp1_gt_rxheadervalid_3;
wire [127:0] qsfp1_gt_rxdata_3;
wire [1:0] qsfp1_gt_rxdatavalid_3;

wire [5:0] qsfp1_gt_txheader_4;
wire [127:0] qsfp1_gt_txdata_4;
wire qsfp1_gt_rxgearboxslip_4;
wire [5:0] qsfp1_gt_rxheader_4;
wire [1:0] qsfp1_gt_rxheadervalid_4;
wire [127:0] qsfp1_gt_rxdata_4;
wire [1:0] qsfp1_gt_rxdatavalid_4;

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

    .gtrefclk00_in({2{qsfp0_mgt_refclk_1}}),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp0_rx4_n, qsfp0_rx3_n, qsfp0_rx2_n, qsfp0_rx1_n, qsfp1_rx4_n, qsfp1_rx3_n, qsfp1_rx2_n, qsfp1_rx1_n}),
    .gtyrxp_in({qsfp0_rx4_p, qsfp0_rx3_p, qsfp0_rx2_p, qsfp0_rx1_p, qsfp1_rx4_p, qsfp1_rx3_p, qsfp1_rx2_p, qsfp1_rx1_p}),

    .rxusrclk_in(gt_rxusrclk),
    .rxusrclk2_in(gt_rxusrclk),

    .txdata_in({qsfp0_gt_txdata_4, qsfp0_gt_txdata_3, qsfp0_gt_txdata_2, qsfp0_gt_txdata_1, qsfp1_gt_txdata_4, qsfp1_gt_txdata_3, qsfp1_gt_txdata_2, qsfp1_gt_txdata_1}),
    .txheader_in({qsfp0_gt_txheader_4, qsfp0_gt_txheader_3, qsfp0_gt_txheader_2, qsfp0_gt_txheader_1, qsfp1_gt_txheader_4, qsfp1_gt_txheader_3, qsfp1_gt_txheader_2, qsfp1_gt_txheader_1}),
    .txsequence_in({8{1'b0}}),

    .txusrclk_in({8{gt_txusrclk}}),
    .txusrclk2_in({8{gt_txusrclk}}),

    .gtpowergood_out(qsfp_gtpowergood),

    .gtytxn_out({qsfp0_tx4_n, qsfp0_tx3_n, qsfp0_tx2_n, qsfp0_tx1_n, qsfp1_tx4_n, qsfp1_tx3_n, qsfp1_tx2_n, qsfp1_tx1_n}),
    .gtytxp_out({qsfp0_tx4_p, qsfp0_tx3_p, qsfp0_tx2_p, qsfp0_tx1_p, qsfp1_tx4_p, qsfp1_tx3_p, qsfp1_tx2_p, qsfp1_tx1_p}),

    .rxgearboxslip_in({qsfp0_gt_rxgearboxslip_4, qsfp0_gt_rxgearboxslip_3, qsfp0_gt_rxgearboxslip_2, qsfp0_gt_rxgearboxslip_1, qsfp1_gt_rxgearboxslip_4, qsfp1_gt_rxgearboxslip_3, qsfp1_gt_rxgearboxslip_2, qsfp1_gt_rxgearboxslip_1}),
    .rxdata_out({qsfp0_gt_rxdata_4, qsfp0_gt_rxdata_3, qsfp0_gt_rxdata_2, qsfp0_gt_rxdata_1, qsfp1_gt_rxdata_4, qsfp1_gt_rxdata_3, qsfp1_gt_rxdata_2, qsfp1_gt_rxdata_1}),
    .rxdatavalid_out({qsfp0_gt_rxdatavalid_4, qsfp0_gt_rxdatavalid_3, qsfp0_gt_rxdatavalid_2, qsfp0_gt_rxdatavalid_1, qsfp1_gt_rxdatavalid_4, qsfp1_gt_rxdatavalid_3, qsfp1_gt_rxdatavalid_2, qsfp1_gt_rxdatavalid_1}),
    .rxheader_out({qsfp0_gt_rxheader_4, qsfp0_gt_rxheader_3, qsfp0_gt_rxheader_2, qsfp0_gt_rxheader_1, qsfp1_gt_rxheader_4, qsfp1_gt_rxheader_3, qsfp1_gt_rxheader_2, qsfp1_gt_rxheader_1}),
    .rxheadervalid_out({qsfp0_gt_rxheadervalid_4, qsfp0_gt_rxheadervalid_3, qsfp0_gt_rxheadervalid_2, qsfp0_gt_rxheadervalid_1, qsfp1_gt_rxheadervalid_4, qsfp1_gt_rxheadervalid_3, qsfp1_gt_rxheadervalid_2, qsfp1_gt_rxheadervalid_1}),
    .rxoutclk_out(gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

assign qsfp0_tx_clk_1_int = clk_156mhz_int;
assign qsfp0_tx_rst_1_int = rst_156mhz_int;

assign qsfp0_rx_clk_1_int = gt_rxusrclk[4];

sync_reset #(
    .N(4)
)
qsfp0_rx_rst_1_reset_sync_inst (
    .clk(qsfp0_rx_clk_1_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp0_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp0_phy_1_inst (
    .tx_clk(qsfp0_tx_clk_1_int),
    .tx_rst(qsfp0_tx_rst_1_int),
    .rx_clk(qsfp0_rx_clk_1_int),
    .rx_rst(qsfp0_rx_rst_1_int),
    .xgmii_txd(qsfp0_txd_1_int),
    .xgmii_txc(qsfp0_txc_1_int),
    .xgmii_rxd(qsfp0_rxd_1_int),
    .xgmii_rxc(qsfp0_rxc_1_int),
    .serdes_tx_data(qsfp0_gt_txdata_1),
    .serdes_tx_hdr(qsfp0_gt_txheader_1),
    .serdes_rx_data(qsfp0_gt_rxdata_1),
    .serdes_rx_hdr(qsfp0_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp0_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp0_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp0_tx_clk_2_int = clk_156mhz_int;
assign qsfp0_tx_rst_2_int = rst_156mhz_int;

assign qsfp0_rx_clk_2_int = gt_rxusrclk[5];

sync_reset #(
    .N(4)
)
qsfp0_rx_rst_2_reset_sync_inst (
    .clk(qsfp0_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp0_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp0_phy_2_inst (
    .tx_clk(qsfp0_tx_clk_2_int),
    .tx_rst(qsfp0_tx_rst_2_int),
    .rx_clk(qsfp0_rx_clk_2_int),
    .rx_rst(qsfp0_rx_rst_2_int),
    .xgmii_txd(qsfp0_txd_2_int),
    .xgmii_txc(qsfp0_txc_2_int),
    .xgmii_rxd(qsfp0_rxd_2_int),
    .xgmii_rxc(qsfp0_rxc_2_int),
    .serdes_tx_data(qsfp0_gt_txdata_2),
    .serdes_tx_hdr(qsfp0_gt_txheader_2),
    .serdes_rx_data(qsfp0_gt_rxdata_2),
    .serdes_rx_hdr(qsfp0_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp0_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp0_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp0_tx_clk_3_int = clk_156mhz_int;
assign qsfp0_tx_rst_3_int = rst_156mhz_int;

assign qsfp0_rx_clk_3_int = gt_rxusrclk[6];

sync_reset #(
    .N(4)
)
qsfp0_rx_rst_3_reset_sync_inst (
    .clk(qsfp0_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp0_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp0_phy_3_inst (
    .tx_clk(qsfp0_tx_clk_3_int),
    .tx_rst(qsfp0_tx_rst_3_int),
    .rx_clk(qsfp0_rx_clk_3_int),
    .rx_rst(qsfp0_rx_rst_3_int),
    .xgmii_txd(qsfp0_txd_3_int),
    .xgmii_txc(qsfp0_txc_3_int),
    .xgmii_rxd(qsfp0_rxd_3_int),
    .xgmii_rxc(qsfp0_rxc_3_int),
    .serdes_tx_data(qsfp0_gt_txdata_3),
    .serdes_tx_hdr(qsfp0_gt_txheader_3),
    .serdes_rx_data(qsfp0_gt_rxdata_3),
    .serdes_rx_hdr(qsfp0_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp0_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp0_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp0_tx_clk_4_int = clk_156mhz_int;
assign qsfp0_tx_rst_4_int = rst_156mhz_int;

assign qsfp0_rx_clk_4_int = gt_rxusrclk[7];

sync_reset #(
    .N(4)
)
qsfp0_rx_rst_4_reset_sync_inst (
    .clk(qsfp0_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp0_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp0_phy_4_inst (
    .tx_clk(qsfp0_tx_clk_4_int),
    .tx_rst(qsfp0_tx_rst_4_int),
    .rx_clk(qsfp0_rx_clk_4_int),
    .rx_rst(qsfp0_rx_rst_4_int),
    .xgmii_txd(qsfp0_txd_4_int),
    .xgmii_txc(qsfp0_txc_4_int),
    .xgmii_rxd(qsfp0_rxd_4_int),
    .xgmii_rxc(qsfp0_rxc_4_int),
    .serdes_tx_data(qsfp0_gt_txdata_4),
    .serdes_tx_hdr(qsfp0_gt_txheader_4),
    .serdes_rx_data(qsfp0_gt_rxdata_4),
    .serdes_rx_hdr(qsfp0_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp0_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp0_rx_block_lock_4),
    .rx_high_ber()
);

assign qsfp1_tx_clk_1_int = clk_156mhz_int;
assign qsfp1_tx_rst_1_int = rst_156mhz_int;

assign qsfp1_rx_clk_1_int = gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp1_rx_rst_1_reset_sync_inst (
    .clk(qsfp1_rx_clk_1_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp1_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp1_phy_1_inst (
    .tx_clk(qsfp1_tx_clk_1_int),
    .tx_rst(qsfp1_tx_rst_1_int),
    .rx_clk(qsfp1_rx_clk_1_int),
    .rx_rst(qsfp1_rx_rst_1_int),
    .xgmii_txd(qsfp1_txd_1_int),
    .xgmii_txc(qsfp1_txc_1_int),
    .xgmii_rxd(qsfp1_rxd_1_int),
    .xgmii_rxc(qsfp1_rxc_1_int),
    .serdes_tx_data(qsfp1_gt_txdata_1),
    .serdes_tx_hdr(qsfp1_gt_txheader_1),
    .serdes_rx_data(qsfp1_gt_rxdata_1),
    .serdes_rx_hdr(qsfp1_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp1_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp1_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp1_tx_clk_2_int = clk_156mhz_int;
assign qsfp1_tx_rst_2_int = rst_156mhz_int;

assign qsfp1_rx_clk_2_int = gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp1_rx_rst_2_reset_sync_inst (
    .clk(qsfp1_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp1_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp1_phy_2_inst (
    .tx_clk(qsfp1_tx_clk_2_int),
    .tx_rst(qsfp1_tx_rst_2_int),
    .rx_clk(qsfp1_rx_clk_2_int),
    .rx_rst(qsfp1_rx_rst_2_int),
    .xgmii_txd(qsfp1_txd_2_int),
    .xgmii_txc(qsfp1_txc_2_int),
    .xgmii_rxd(qsfp1_rxd_2_int),
    .xgmii_rxc(qsfp1_rxc_2_int),
    .serdes_tx_data(qsfp1_gt_txdata_2),
    .serdes_tx_hdr(qsfp1_gt_txheader_2),
    .serdes_rx_data(qsfp1_gt_rxdata_2),
    .serdes_rx_hdr(qsfp1_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp1_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp1_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp1_tx_clk_3_int = clk_156mhz_int;
assign qsfp1_tx_rst_3_int = rst_156mhz_int;

assign qsfp1_rx_clk_3_int = gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp1_rx_rst_3_reset_sync_inst (
    .clk(qsfp1_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp1_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp1_phy_3_inst (
    .tx_clk(qsfp1_tx_clk_3_int),
    .tx_rst(qsfp1_tx_rst_3_int),
    .rx_clk(qsfp1_rx_clk_3_int),
    .rx_rst(qsfp1_rx_rst_3_int),
    .xgmii_txd(qsfp1_txd_3_int),
    .xgmii_txc(qsfp1_txc_3_int),
    .xgmii_rxd(qsfp1_rxd_3_int),
    .xgmii_rxc(qsfp1_rxc_3_int),
    .serdes_tx_data(qsfp1_gt_txdata_3),
    .serdes_tx_hdr(qsfp1_gt_txheader_3),
    .serdes_rx_data(qsfp1_gt_rxdata_3),
    .serdes_rx_hdr(qsfp1_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp1_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp1_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp1_tx_clk_4_int = clk_156mhz_int;
assign qsfp1_tx_rst_4_int = rst_156mhz_int;

assign qsfp1_rx_clk_4_int = gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp1_rx_rst_4_reset_sync_inst (
    .clk(qsfp1_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .sync_reset_out(qsfp1_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp1_phy_4_inst (
    .tx_clk(qsfp1_tx_clk_4_int),
    .tx_rst(qsfp1_tx_rst_4_int),
    .rx_clk(qsfp1_rx_clk_4_int),
    .rx_rst(qsfp1_rx_rst_4_int),
    .xgmii_txd(qsfp1_txd_4_int),
    .xgmii_txc(qsfp1_txc_4_int),
    .xgmii_rxd(qsfp1_rxd_4_int),
    .xgmii_rxc(qsfp1_rxc_4_int),
    .serdes_tx_data(qsfp1_gt_txdata_4),
    .serdes_tx_hdr(qsfp1_gt_txheader_4),
    .serdes_rx_data(qsfp1_gt_rxdata_4),
    .serdes_rx_hdr(qsfp1_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp1_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp1_rx_block_lock_4),
    .rx_high_ber()
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
    .sw(sw_int),
    .led(led),
    /*
     * Ethernet: QSFP28
     */
    .qsfp0_tx_clk_1(qsfp0_tx_clk_1_int),
    .qsfp0_tx_rst_1(qsfp0_tx_rst_1_int),
    .qsfp0_txd_1(qsfp0_txd_1_int),
    .qsfp0_txc_1(qsfp0_txc_1_int),
    .qsfp0_rx_clk_1(qsfp0_rx_clk_1_int),
    .qsfp0_rx_rst_1(qsfp0_rx_rst_1_int),
    .qsfp0_rxd_1(qsfp0_rxd_1_int),
    .qsfp0_rxc_1(qsfp0_rxc_1_int),
    .qsfp0_tx_clk_2(qsfp0_tx_clk_2_int),
    .qsfp0_tx_rst_2(qsfp0_tx_rst_2_int),
    .qsfp0_txd_2(qsfp0_txd_2_int),
    .qsfp0_txc_2(qsfp0_txc_2_int),
    .qsfp0_rx_clk_2(qsfp0_rx_clk_2_int),
    .qsfp0_rx_rst_2(qsfp0_rx_rst_2_int),
    .qsfp0_rxd_2(qsfp0_rxd_2_int),
    .qsfp0_rxc_2(qsfp0_rxc_2_int),
    .qsfp0_tx_clk_3(qsfp0_tx_clk_3_int),
    .qsfp0_tx_rst_3(qsfp0_tx_rst_3_int),
    .qsfp0_txd_3(qsfp0_txd_3_int),
    .qsfp0_txc_3(qsfp0_txc_3_int),
    .qsfp0_rx_clk_3(qsfp0_rx_clk_3_int),
    .qsfp0_rx_rst_3(qsfp0_rx_rst_3_int),
    .qsfp0_rxd_3(qsfp0_rxd_3_int),
    .qsfp0_rxc_3(qsfp0_rxc_3_int),
    .qsfp0_tx_clk_4(qsfp0_tx_clk_4_int),
    .qsfp0_tx_rst_4(qsfp0_tx_rst_4_int),
    .qsfp0_txd_4(qsfp0_txd_4_int),
    .qsfp0_txc_4(qsfp0_txc_4_int),
    .qsfp0_rx_clk_4(qsfp0_rx_clk_4_int),
    .qsfp0_rx_rst_4(qsfp0_rx_rst_4_int),
    .qsfp0_rxd_4(qsfp0_rxd_4_int),
    .qsfp0_rxc_4(qsfp0_rxc_4_int),
    .qsfp1_tx_clk_1(qsfp1_tx_clk_1_int),
    .qsfp1_tx_rst_1(qsfp1_tx_rst_1_int),
    .qsfp1_txd_1(qsfp1_txd_1_int),
    .qsfp1_txc_1(qsfp1_txc_1_int),
    .qsfp1_rx_clk_1(qsfp1_rx_clk_1_int),
    .qsfp1_rx_rst_1(qsfp1_rx_rst_1_int),
    .qsfp1_rxd_1(qsfp1_rxd_1_int),
    .qsfp1_rxc_1(qsfp1_rxc_1_int),
    .qsfp1_tx_clk_2(qsfp1_tx_clk_2_int),
    .qsfp1_tx_rst_2(qsfp1_tx_rst_2_int),
    .qsfp1_txd_2(qsfp1_txd_2_int),
    .qsfp1_txc_2(qsfp1_txc_2_int),
    .qsfp1_rx_clk_2(qsfp1_rx_clk_2_int),
    .qsfp1_rx_rst_2(qsfp1_rx_rst_2_int),
    .qsfp1_rxd_2(qsfp1_rxd_2_int),
    .qsfp1_rxc_2(qsfp1_rxc_2_int),
    .qsfp1_tx_clk_3(qsfp1_tx_clk_3_int),
    .qsfp1_tx_rst_3(qsfp1_tx_rst_3_int),
    .qsfp1_txd_3(qsfp1_txd_3_int),
    .qsfp1_txc_3(qsfp1_txc_3_int),
    .qsfp1_rx_clk_3(qsfp1_rx_clk_3_int),
    .qsfp1_rx_rst_3(qsfp1_rx_rst_3_int),
    .qsfp1_rxd_3(qsfp1_rxd_3_int),
    .qsfp1_rxc_3(qsfp1_rxc_3_int),
    .qsfp1_tx_clk_4(qsfp1_tx_clk_4_int),
    .qsfp1_tx_rst_4(qsfp1_tx_rst_4_int),
    .qsfp1_txd_4(qsfp1_txd_4_int),
    .qsfp1_txc_4(qsfp1_txc_4_int),
    .qsfp1_rx_clk_4(qsfp1_rx_clk_4_int),
    .qsfp1_rx_rst_4(qsfp1_rx_rst_4_int),
    .qsfp1_rxd_4(qsfp1_rxd_4_int),
    .qsfp1_rxc_4(qsfp1_rxc_4_int),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd_int)
);

endmodule
