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
     * Clock: 100MHz LVDS
     */
    input  wire       clk_100mhz_p,
    input  wire       clk_100mhz_n,

    /*
     * GPIO
     */
    output wire [1:0] sfp_1_led,
    output wire [1:0] sfp_2_led,
    output wire [1:0] sma_led,

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
    input  wire       sfp_mgt_refclk_p,
    input  wire       sfp_mgt_refclk_n,
    output wire       sfp_1_tx_disable,
    output wire       sfp_2_tx_disable,
    input  wire       sfp_1_npres,
    input  wire       sfp_2_npres,
    input  wire       sfp_1_los,
    input  wire       sfp_2_los,
    output wire       sfp_1_rs,
    output wire       sfp_2_rs
);

// Clock and reset

wire clk_100mhz_ibufg;
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
clk_100mhz_ibufg_inst (
   .O   (clk_100mhz_ibufg),
   .I   (clk_100mhz_p),
   .IB  (clk_100mhz_n) 
);

// MMCM instance
// 100 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 600 MHz to 1440 MHz
// M = 10, D = 1 sets Fvco = 1000 MHz (in range)
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
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_100mhz_ibufg),
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
wire [1:0] sfp_1_led_int;
wire [1:0] sfp_2_led_int;
wire [1:0] sma_led_int;

// XGMII 10G PHY

assign sfp_1_tx_disable = 1'b0;
assign sfp_2_tx_disable = 1'b0;
assign sfp_1_rs = 1'b1;
assign sfp_2_rs = 1'b1;

wire        sfp_1_tx_clk_int;
wire        sfp_1_tx_rst_int;
wire [63:0] sfp_1_txd_int;
wire [7:0]  sfp_1_txc_int;
wire        sfp_1_rx_clk_int;
wire        sfp_1_rx_rst_int;
wire [63:0] sfp_1_rxd_int;
wire [7:0]  sfp_1_rxc_int;
wire        sfp_2_tx_clk_int;
wire        sfp_2_tx_rst_int;
wire [63:0] sfp_2_txd_int;
wire [7:0]  sfp_2_txc_int;
wire        sfp_2_rx_clk_int;
wire        sfp_2_rx_rst_int;
wire [63:0] sfp_2_rxd_int;
wire [7:0]  sfp_2_rxc_int;

wire sfp_1_rx_block_lock;
wire sfp_2_rx_block_lock;

wire sfp_mgt_refclk;

wire [1:0] gt_txclkout;
wire gt_txusrclk;
wire gt_txusrclk2;

wire [1:0] gt_rxclkout;
wire [1:0] gt_rxusrclk;
wire [1:0] gt_rxusrclk2;

wire gt_reset_tx_done;
wire gt_reset_rx_done;

wire [1:0] gt_txprgdivresetdone;
wire [1:0] gt_txpmaresetdone;
wire [1:0] gt_rxprgdivresetdone;
wire [1:0] gt_rxpmaresetdone;

wire gt_tx_reset = ~((&gt_txprgdivresetdone) & (&gt_txpmaresetdone));
wire gt_rx_reset = ~&gt_rxpmaresetdone;

reg gt_userclk_tx_active = 1'b0;
reg [1:0] gt_userclk_rx_active = 1'b0;

IBUFDS_GTE3 ibufds_gte3_sfp_mgt_refclk_inst (
    .I             (sfp_mgt_refclk_p),
    .IB            (sfp_mgt_refclk_n),
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

for (n = 0 ; n < 2; n = n + 1) begin

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

wire [5:0] sfp_1_gt_txheader;
wire [127:0] sfp_1_gt_txdata;
wire sfp_1_gt_rxgearboxslip;
wire [5:0] sfp_1_gt_rxheader;
wire [1:0] sfp_1_gt_rxheadervalid;
wire [127:0] sfp_1_gt_rxdata;
wire [1:0] sfp_1_gt_rxdatavalid;

wire [5:0] sfp_2_gt_txheader;
wire [127:0] sfp_2_gt_txdata;
wire sfp_2_gt_rxgearboxslip;
wire [5:0] sfp_2_gt_rxheader;
wire [1:0] sfp_2_gt_rxheadervalid;
wire [127:0] sfp_2_gt_rxdata;
wire [1:0] sfp_2_gt_rxdatavalid;

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

    .gthrxn_in({sfp_2_rx_n, sfp_1_rx_n}),
    .gthrxp_in({sfp_2_rx_p, sfp_1_rx_p}),

    .rxusrclk_in(gt_rxusrclk),
    .rxusrclk2_in(gt_rxusrclk2),

    .txdata_in({sfp_2_gt_txdata, sfp_1_gt_txdata}),
    .txheader_in({sfp_2_gt_txheader, sfp_1_gt_txheader}),
    .txsequence_in({2{7'b0}}),

    .txusrclk_in({2{gt_txusrclk}}),
    .txusrclk2_in({2{gt_txusrclk2}}),

    .gtpowergood_out(),

    .gthtxn_out({sfp_2_tx_n, sfp_1_tx_n}),
    .gthtxp_out({sfp_2_tx_p, sfp_1_tx_p}),

    .txpolarity_in(2'b11),
    .rxpolarity_in(2'b00),

    .rxgearboxslip_in({sfp_2_gt_rxgearboxslip, sfp_1_gt_rxgearboxslip}),
    .rxdata_out({sfp_2_gt_rxdata, sfp_1_gt_rxdata}),
    .rxdatavalid_out({sfp_2_gt_rxdatavalid, sfp_1_gt_rxdatavalid}),
    .rxheader_out({sfp_2_gt_rxheader, sfp_1_gt_rxheader}),
    .rxheadervalid_out({sfp_2_gt_rxheadervalid, sfp_1_gt_rxheadervalid}),
    .rxoutclk_out(gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

assign sfp_1_tx_clk_int = clk_156mhz_int;
assign sfp_1_tx_rst_int = rst_156mhz_int;

assign sfp_1_rx_clk_int = gt_rxusrclk2[0];

sync_reset #(
    .N(4)
)
sfp_1_rx_rst_reset_sync_inst (
    .clk(sfp_1_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp_1_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp_1_phy_inst (
    .tx_clk(sfp_1_tx_clk_int),
    .tx_rst(sfp_1_tx_rst_int),
    .rx_clk(sfp_1_rx_clk_int),
    .rx_rst(sfp_1_rx_rst_int),
    .xgmii_txd(sfp_1_txd_int),
    .xgmii_txc(sfp_1_txc_int),
    .xgmii_rxd(sfp_1_rxd_int),
    .xgmii_rxc(sfp_1_rxc_int),
    .serdes_tx_data(sfp_1_gt_txdata),
    .serdes_tx_hdr(sfp_1_gt_txheader),
    .serdes_rx_data(sfp_1_gt_rxdata),
    .serdes_rx_hdr(sfp_1_gt_rxheader),
    .serdes_rx_bitslip(sfp_1_gt_rxgearboxslip),
    .rx_block_lock(sfp_1_rx_block_lock),
    .rx_high_ber()
);

assign sfp_2_tx_clk_int = clk_156mhz_int;
assign sfp_2_tx_rst_int = rst_156mhz_int;

assign sfp_2_rx_clk_int = gt_rxusrclk2[1];

sync_reset #(
    .N(4)
)
sfp_2_rx_rst_reset_sync_inst (
    .clk(sfp_2_rx_clk_int),
    .rst(~gt_reset_rx_done),
    .out(sfp_2_rx_rst_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp_2_phy_inst (
    .tx_clk(sfp_2_tx_clk_int),
    .tx_rst(sfp_2_tx_rst_int),
    .rx_clk(sfp_2_rx_clk_int),
    .rx_rst(sfp_2_rx_rst_int),
    .xgmii_txd(sfp_2_txd_int),
    .xgmii_txc(sfp_2_txc_int),
    .xgmii_rxd(sfp_2_rxd_int),
    .xgmii_rxc(sfp_2_rxc_int),
    .serdes_tx_data(sfp_2_gt_txdata),
    .serdes_tx_hdr(sfp_2_gt_txheader),
    .serdes_rx_data(sfp_2_gt_rxdata),
    .serdes_rx_hdr(sfp_2_gt_rxheader),
    .serdes_rx_bitslip(sfp_2_gt_rxgearboxslip),
    .rx_block_lock(sfp_2_rx_block_lock),
    .rx_high_ber()
);

assign sfp_1_led[0] = sfp_1_rx_block_lock;
assign sfp_1_led[1] = 1'b0;
assign sfp_2_led[0] = sfp_2_rx_block_lock;
assign sfp_2_led[1] = 1'b0;
assign sma_led = sma_led_int;

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
    .sfp_1_led(sfp_1_led_int),
    .sfp_2_led(sfp_2_led_int),
    .sma_led(sma_led_int),
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
    .sfp_2_rxc(sfp_2_rxc_int)
);

endmodule
