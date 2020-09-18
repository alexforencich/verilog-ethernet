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

`timescale 1ns / 1ps

/*
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 125MHz LVDS
     * Reset: Push button, active low
     */
    input  wire       clk_125mhz_p,
    input  wire       clk_125mhz_n,
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
    output wire [7:0] led,

    /*
     * UART: 115200 bps, 8N1
     */
    input  wire       uart_rxd,
    output wire       uart_txd,
    input  wire       uart_rts,
    output wire       uart_cts,

    /*
     * Ethernet: SFP+
     */
    input  wire       sfp0_rx_p,
    input  wire       sfp0_rx_n,
    output wire       sfp0_tx_p,
    output wire       sfp0_tx_n,
    input  wire       sfp1_rx_p,
    input  wire       sfp1_rx_n,
    output wire       sfp1_tx_p,
    output wire       sfp1_tx_n,
    input  wire       sfp2_rx_p,
    input  wire       sfp2_rx_n,
    output wire       sfp2_tx_p,
    output wire       sfp2_tx_n,
    input  wire       sfp3_rx_p,
    input  wire       sfp3_rx_n,
    output wire       sfp3_tx_p,
    output wire       sfp3_tx_n,
    input  wire       sfp_mgt_refclk_0_p,
    input  wire       sfp_mgt_refclk_0_n,
    output wire       sfp0_tx_disable_b,
    output wire       sfp1_tx_disable_b,
    output wire       sfp2_tx_disable_b,
    output wire       sfp3_tx_disable_b
);

// Clock and reset

wire clk_125mhz_ibufg;
wire clk_125mhz_bufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_125mhz_ibufg_inst (
   .O   (clk_125mhz_ibufg),
   .I   (clk_125mhz_p),
   .IB  (clk_125mhz_n) 
);

BUFG
clk_125mhz_bufg_in_inst (
    .I(clk_125mhz_ibufg),
    .O(clk_125mhz_bufg)
);

// MMCM instance
// 125 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 8, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCME4_BASE #(
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
    .CLKFBOUT_MULT_F(8),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(8.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_125mhz_bufg),
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

debounce_switch #(
    .WIDTH(9),
    .N(8),
    .RATE(156000)
)
debounce_switch_inst (
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
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

wire uart_rxd_int;
wire uart_rts_int;

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_156mhz_int),
    .in({uart_rxd, uart_rts}),
    .out({uart_rxd_int, uart_rts_int})
);

// XGMII 10G PHY
assign sfp0_tx_disable_b = 1'b1;
assign sfp1_tx_disable_b = 1'b1;
assign sfp2_tx_disable_b = 1'b1;
assign sfp3_tx_disable_b = 1'b1;

wire        sfp0_tx_clk_int;
wire        sfp0_tx_rst_int;
wire [63:0] sfp0_txd_int;
wire [7:0]  sfp0_txc_int;
wire        sfp0_rx_clk_int;
wire        sfp0_rx_rst_int;
wire [63:0] sfp0_rxd_int;
wire [7:0]  sfp0_rxc_int;

wire        sfp1_tx_clk_int;
wire        sfp1_tx_rst_int;
wire [63:0] sfp1_txd_int;
wire [7:0]  sfp1_txc_int;
wire        sfp1_rx_clk_int;
wire        sfp1_rx_rst_int;
wire [63:0] sfp1_rxd_int;
wire [7:0]  sfp1_rxc_int;

wire        sfp2_tx_clk_int;
wire        sfp2_tx_rst_int;
wire [63:0] sfp2_txd_int;
wire [7:0]  sfp2_txc_int;
wire        sfp2_rx_clk_int;
wire        sfp2_rx_rst_int;
wire [63:0] sfp2_rxd_int;
wire [7:0]  sfp2_rxc_int;

wire        sfp3_tx_clk_int;
wire        sfp3_tx_rst_int;
wire [63:0] sfp3_txd_int;
wire [7:0]  sfp3_txc_int;
wire        sfp3_rx_clk_int;
wire        sfp3_rx_rst_int;
wire [63:0] sfp3_rxd_int;
wire [7:0]  sfp3_rxc_int;

wire sfp0_rx_block_lock;
wire sfp1_rx_block_lock;
wire sfp2_rx_block_lock;
wire sfp3_rx_block_lock;

wire sfp_mgt_refclk;

wire [3:0] gt_txclkout;
wire gt_txusrclk;
wire gt_txusrclk2;

wire [3:0] gt_rxclkout;
wire [3:0] gt_rxusrclk;
wire [3:0] gt_rxusrclk2;

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

IBUFDS_GTE4 ibufds_gte4_sfp_mgt_refclk_inst (
    .I             (sfp_mgt_refclk_0_p),
    .IB            (sfp_mgt_refclk_0_n),
    .CEB           (1'b0),
    .O             (sfp_mgt_refclk),
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

BUFG_GT bufg_gt_tx_usrclk2_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd1),
    .I       (gt_txclkout[0]),
    .O       (gt_txusrclk2)
);

assign clk_156mhz_int = gt_txusrclk2;

always @(posedge gt_txusrclk, posedge gt_tx_reset) begin
    if (gt_tx_reset) begin
        gt_userclk_tx_active <= 1'b0;
    end else begin
        gt_userclk_tx_active <= 1'b1;
    end
end

genvar n;

generate

for (n = 0 ; n < 4; n = n + 1) begin

    BUFG_GT bufg_gt_rx_usrclk_0_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (gt_rxclkout[n]),
        .O       (gt_rxusrclk[n])
    );

    BUFG_GT bufg_gt_rx_usrclk2_0_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd1),
        .I       (gt_rxclkout[n]),
        .O       (gt_rxusrclk2[n])
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

wire [5:0] sfp0_gt_txheader;
wire [63:0] sfp0_gt_txdata;
wire sfp0_gt_rxgearboxslip;
wire [5:0] sfp0_gt_rxheader;
wire [1:0] sfp0_gt_rxheadervalid;
wire [63:0] sfp0_gt_rxdata;
wire [1:0] sfp0_gt_rxdatavalid;

wire [5:0] sfp1_gt_txheader;
wire [63:0] sfp1_gt_txdata;
wire sfp1_gt_rxgearboxslip;
wire [5:0] sfp1_gt_rxheader;
wire [1:0] sfp1_gt_rxheadervalid;
wire [63:0] sfp1_gt_rxdata;
wire [1:0] sfp1_gt_rxdatavalid;

wire [5:0] sfp2_gt_txheader;
wire [63:0] sfp2_gt_txdata;
wire sfp2_gt_rxgearboxslip;
wire [5:0] sfp2_gt_rxheader;
wire [1:0] sfp2_gt_rxheadervalid;
wire [63:0] sfp2_gt_rxdata;
wire [1:0] sfp2_gt_rxdatavalid;

wire [5:0] sfp3_gt_txheader;
wire [63:0] sfp3_gt_txdata;
wire sfp3_gt_rxgearboxslip;
wire [5:0] sfp3_gt_rxheader;
wire [1:0] sfp3_gt_rxheadervalid;
wire [63:0] sfp3_gt_rxdata;
wire [1:0] sfp3_gt_rxdatavalid;

gtwizard_ultrascale_0
sfp_gth_inst (
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

    .gtrefclk00_in(sfp_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gthrxn_in({sfp3_rx_n, sfp2_rx_n, sfp1_rx_n, sfp0_rx_n}),
    .gthrxp_in({sfp3_rx_p, sfp2_rx_p, sfp1_rx_p, sfp0_rx_p}),

    .rxusrclk_in(gt_rxusrclk),
    .rxusrclk2_in(gt_rxusrclk2),

    .gtwiz_userdata_tx_in({sfp3_gt_txdata, sfp2_gt_txdata, sfp1_gt_txdata, sfp0_gt_txdata}),
    .txheader_in({sfp3_gt_txheader, sfp2_gt_txheader, sfp1_gt_txheader, sfp0_gt_txheader}),
    .txsequence_in({4{7'b0}}),

    .txusrclk_in({4{gt_txusrclk}}),
    .txusrclk2_in({4{gt_txusrclk2}}),

    .gtpowergood_out(),

    .gthtxn_out({sfp3_tx_n, sfp2_tx_n, sfp1_tx_n, sfp0_tx_n}),
    .gthtxp_out({sfp3_tx_p, sfp2_tx_p, sfp1_tx_p, sfp0_tx_p}),

    .rxgearboxslip_in({sfp3_gt_rxgearboxslip, sfp2_gt_rxgearboxslip, sfp1_gt_rxgearboxslip, sfp0_gt_rxgearboxslip}),
    .gtwiz_userdata_rx_out({sfp3_gt_rxdata, sfp2_gt_rxdata, sfp1_gt_rxdata, sfp0_gt_rxdata}),
    .rxdatavalid_out({sfp3_gt_rxdatavalid, sfp2_gt_rxdatavalid, sfp1_gt_rxdatavalid, sfp0_gt_rxdatavalid}),
    .rxheader_out({sfp3_gt_rxheader, sfp2_gt_rxheader, sfp1_gt_rxheader, sfp0_gt_rxheader}),
    .rxheadervalid_out({sfp3_gt_rxheadervalid, sfp2_gt_rxheadervalid, sfp1_gt_rxheadervalid, sfp0_gt_rxheadervalid}),
    .rxoutclk_out(gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

assign sfp0_tx_clk_int = clk_156mhz_int;
assign sfp0_tx_rst_int = rst_156mhz_int;

assign sfp0_rx_clk_int = gt_rxusrclk2[0];

sync_reset #(
    .N(4)
)
sfp0_rx_rst_reset_sync_inst (
    .clk(sfp0_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp0_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp0_phy_inst (
    .tx_clk(sfp0_tx_clk_int),
    .tx_rst(sfp0_tx_rst_int),
    .rx_clk(sfp0_rx_clk_int),
    .rx_rst(sfp0_rx_rst_int),
    .xgmii_txd(sfp0_txd_int),
    .xgmii_txc(sfp0_txc_int),
    .xgmii_rxd(sfp0_rxd_int),
    .xgmii_rxc(sfp0_rxc_int),
    .serdes_tx_data(sfp0_gt_txdata),
    .serdes_tx_hdr(sfp0_gt_txheader),
    .serdes_rx_data(sfp0_gt_rxdata),
    .serdes_rx_hdr(sfp0_gt_rxheader),
    .serdes_rx_bitslip(sfp0_gt_rxgearboxslip),
    .rx_block_lock(sfp0_rx_block_lock),
    .rx_high_ber()
);

assign sfp1_tx_clk_int = clk_156mhz_int;
assign sfp1_tx_rst_int = rst_156mhz_int;

assign sfp1_rx_clk_int = gt_rxusrclk2[1];

sync_reset #(
    .N(4)
)
sfp1_rx_rst_reset_sync_inst (
    .clk(sfp1_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp1_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp1_phy_inst (
    .tx_clk(sfp1_tx_clk_int),
    .tx_rst(sfp1_tx_rst_int),
    .rx_clk(sfp1_rx_clk_int),
    .rx_rst(sfp1_rx_rst_int),
    .xgmii_txd(sfp1_txd_int),
    .xgmii_txc(sfp1_txc_int),
    .xgmii_rxd(sfp1_rxd_int),
    .xgmii_rxc(sfp1_rxc_int),
    .serdes_tx_data(sfp1_gt_txdata),
    .serdes_tx_hdr(sfp1_gt_txheader),
    .serdes_rx_data(sfp1_gt_rxdata),
    .serdes_rx_hdr(sfp1_gt_rxheader),
    .serdes_rx_bitslip(sfp1_gt_rxgearboxslip),
    .rx_block_lock(sfp1_rx_block_lock),
    .rx_high_ber()
);

assign sfp2_tx_clk_int = clk_156mhz_int;
assign sfp2_tx_rst_int = rst_156mhz_int;

assign sfp2_rx_clk_int = gt_rxusrclk2[2];

sync_reset #(
    .N(4)
)
sfp2_rx_rst_reset_sync_inst (
    .clk(sfp2_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp2_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp2_phy_inst (
    .tx_clk(sfp2_tx_clk_int),
    .tx_rst(sfp2_tx_rst_int),
    .rx_clk(sfp2_rx_clk_int),
    .rx_rst(sfp2_rx_rst_int),
    .xgmii_txd(sfp2_txd_int),
    .xgmii_txc(sfp2_txc_int),
    .xgmii_rxd(sfp2_rxd_int),
    .xgmii_rxc(sfp2_rxc_int),
    .serdes_tx_data(sfp2_gt_txdata),
    .serdes_tx_hdr(sfp2_gt_txheader),
    .serdes_rx_data(sfp2_gt_rxdata),
    .serdes_rx_hdr(sfp2_gt_rxheader),
    .serdes_rx_bitslip(sfp2_gt_rxgearboxslip),
    .rx_block_lock(sfp2_rx_block_lock),
    .rx_high_ber()
);

assign sfp3_tx_clk_int = clk_156mhz_int;
assign sfp3_tx_rst_int = rst_156mhz_int;

assign sfp3_rx_clk_int = gt_rxusrclk2[3];

sync_reset #(
    .N(4)
)
sfp3_rx_rst_reset_sync_inst (
    .clk(sfp3_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp3_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp3_phy_inst (
    .tx_clk(sfp3_tx_clk_int),
    .tx_rst(sfp3_tx_rst_int),
    .rx_clk(sfp3_rx_clk_int),
    .rx_rst(sfp3_rx_rst_int),
    .xgmii_txd(sfp3_txd_int),
    .xgmii_txc(sfp3_txc_int),
    .xgmii_rxd(sfp3_rxd_int),
    .xgmii_rxc(sfp3_rxc_int),
    .serdes_tx_data(sfp3_gt_txdata),
    .serdes_tx_hdr(sfp3_gt_txheader),
    .serdes_rx_data(sfp3_gt_rxdata),
    .serdes_rx_hdr(sfp3_gt_rxheader),
    .serdes_rx_bitslip(sfp3_gt_rxgearboxslip),
    .rx_block_lock(sfp3_rx_block_lock),
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
    .btnu(btnu_int),
    .btnl(btnl_int),
    .btnd(btnd_int),
    .btnr(btnr_int),
    .btnc(btnc_int),
    .sw(sw_int),
    .led(led),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts_int),
    .uart_cts(uart_cts),
    /*
     * Ethernet: SFP+
     */
    .sfp0_tx_clk(sfp0_tx_clk_int),
    .sfp0_tx_rst(sfp0_tx_rst_int),
    .sfp0_txd(sfp0_txd_int),
    .sfp0_txc(sfp0_txc_int),
    .sfp0_rx_clk(sfp0_rx_clk_int),
    .sfp0_rx_rst(sfp0_rx_rst_int),
    .sfp0_rxd(sfp0_rxd_int),
    .sfp0_rxc(sfp0_rxc_int),
    .sfp1_tx_clk(sfp1_tx_clk_int),
    .sfp1_tx_rst(sfp1_tx_rst_int),
    .sfp1_txd(sfp1_txd_int),
    .sfp1_txc(sfp1_txc_int),
    .sfp1_rx_clk(sfp1_rx_clk_int),
    .sfp1_rx_rst(sfp1_rx_rst_int),
    .sfp1_rxd(sfp1_rxd_int),
    .sfp1_rxc(sfp1_rxc_int),
    .sfp2_tx_clk(sfp2_tx_clk_int),
    .sfp2_tx_rst(sfp2_tx_rst_int),
    .sfp2_txd(sfp2_txd_int),
    .sfp2_txc(sfp2_txc_int),
    .sfp2_rx_clk(sfp2_rx_clk_int),
    .sfp2_rx_rst(sfp2_rx_rst_int),
    .sfp2_rxd(sfp2_rxd_int),
    .sfp2_rxc(sfp2_rxc_int),
    .sfp3_tx_clk(sfp3_tx_clk_int),
    .sfp3_tx_rst(sfp3_tx_rst_int),
    .sfp3_txd(sfp3_txd_int),
    .sfp3_txc(sfp3_txc_int),
    .sfp3_rx_clk(sfp3_rx_clk_int),
    .sfp3_rx_rst(sfp3_rx_rst_int),
    .sfp3_rxd(sfp3_rxd_int),
    .sfp3_rxc(sfp3_rxc_int)
);

endmodule
