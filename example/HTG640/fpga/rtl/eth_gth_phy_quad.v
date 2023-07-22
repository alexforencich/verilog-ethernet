/*

Copyright (c) 2015-2018 Alex Forencich

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
`timescale 1 ns / 1 ps
`default_nettype none

module eth_gth_phy_quad (
    /*
     * Clock and reset
     */
    input  wire clk156,
    input  wire rst156,
    input  wire dclk,
    input  wire dclk_reset,

    output wire txclk156,

    input  wire gth_reset,
    output wire gth_reset_done,

    /*
     * Transciever pins
     */
    input  wire refclk_p,
    input  wire refclk_n,
    output wire txp_0,
    output wire txn_0,
    input  wire rxp_0,
    input  wire rxn_0,
    output wire txp_1,
    output wire txn_1,
    input  wire rxp_1,
    input  wire rxn_1,
    output wire txp_2,
    output wire txn_2,
    input  wire rxp_2,
    input  wire rxn_2,
    output wire txp_3,
    output wire txn_3,
    input  wire rxp_3,
    input  wire rxn_3,

    /*
     * XGMII interfaces
     */
    input  wire [63:0] xgmii_txd_0,
    input  wire [7:0]  xgmii_txc_0,
    output wire [63:0] xgmii_rxd_0,
    output wire [7:0]  xgmii_rxc_0,
    input  wire [63:0] xgmii_txd_1,
    input  wire [7:0]  xgmii_txc_1,
    output wire [63:0] xgmii_rxd_1,
    output wire [7:0]  xgmii_rxc_1,
    input  wire [63:0] xgmii_txd_2,
    input  wire [7:0]  xgmii_txc_2,
    output wire [63:0] xgmii_rxd_2,
    output wire [7:0]  xgmii_rxc_2,
    input  wire [63:0] xgmii_txd_3,
    input  wire [7:0]  xgmii_txc_3,
    output wire [63:0] xgmii_rxd_3,
    output wire [7:0]  xgmii_rxc_3,

    /*
     * Control
     */
    input  wire tx_powerdown_0,
    input  wire rx_powerdown_0,
    input  wire tx_powerdown_1,
    input  wire rx_powerdown_1,
    input  wire tx_powerdown_2,
    input  wire rx_powerdown_2,
    input  wire tx_powerdown_3,
    input  wire rx_powerdown_3
);

wire [63:0] gth_txd_0;
wire [7:0]  gth_txc_0;
wire [63:0] gth_rxd_0;
wire [7:0]  gth_rxc_0;
wire [63:0] gth_txd_1;
wire [7:0]  gth_txc_1;
wire [63:0] gth_rxd_1;
wire [7:0]  gth_rxc_1;
wire [63:0] gth_txd_2;
wire [7:0]  gth_txc_2;
wire [63:0] gth_rxd_2;
wire [7:0]  gth_rxc_2;
wire [63:0] gth_txd_3;
wire [7:0]  gth_txc_3;
wire [63:0] gth_rxd_3;
wire [7:0]  gth_rxc_3;

wire        mgmt_rd;
wire        mgmt_wr;
wire        mgmt_rdack;
wire [20:0] mgmt_addr;
wire [15:0] mgmt_rddata;
wire [15:0] mgmt_wrdata;

wire        mgmt_rd0;
wire        mgmt_wr0;
wire [20:0] mgmt_addr0;
wire [15:0] mgmt_wrdata0;

wire        mgmt_req0;
wire        mgmt_gnt0;

wire        mgmt_rd1;
wire        mgmt_wr1;
wire [20:0] mgmt_addr1;
wire [15:0] mgmt_wrdata1;

wire        mgmt_req1;
wire        mgmt_gnt1;

wire        mgmt_rd2;
wire        mgmt_wr2;
wire [20:0] mgmt_addr2;
wire [15:0] mgmt_wrdata2;

wire        mgmt_req2;
wire        mgmt_gnt2;

wire        mgmt_rd3;
wire        mgmt_wr3;
wire [20:0] mgmt_addr3;
wire [15:0] mgmt_wrdata3;

wire        mgmt_req3;
wire        mgmt_gnt3;

// clocking
wire refclk;

IBUFDS_GTHE1 refclk_ibufds_inst
(
    .I(refclk_p),
    .IB(refclk_n),
    .O(refclk)
);

wire rx_clk_0;
wire rx_clk_0_buf;
wire rx_clk_1;
wire rx_clk_1_buf;
wire rx_clk_2;
wire rx_clk_2_buf;
wire rx_clk_3;
wire rx_clk_3_buf;

BUFR #(
        .SIM_DEVICE("VIRTEX6")
)
rx_clk_0_buf_inst
(
    .CE(1'b1),
    .CLR(1'b0),
    .I(rx_clk_0),
    .O(rx_clk_0_buf)
);

BUFR #(
        .SIM_DEVICE("VIRTEX6")
)
rx_clk_1_buf_inst
(
    .CE(1'b1),
    .CLR(1'b0),
    .I(rx_clk_1),
    .O(rx_clk_1_buf)
);

BUFG rx_clk_2_buf_inst
(
    .I(rx_clk_2),
    .O(rx_clk_2_buf)
);

BUFG rx_clk_3_buf_inst
(
    .I(rx_clk_3),
    .O(rx_clk_3_buf)
);

wire tx_resetdone_0;
wire rx_resetdone_0;
wire tx_resetdone_1;
wire rx_resetdone_1;
wire tx_resetdone_2;
wire rx_resetdone_2;
wire tx_resetdone_3;
wire rx_resetdone_3;

wire resetdone_0 = tx_resetdone_0 & rx_resetdone_0;
wire resetdone_1 = tx_resetdone_1 & rx_resetdone_1;
wire resetdone_2 = tx_resetdone_2 & rx_resetdone_2;
wire resetdone_3 = tx_resetdone_3 & rx_resetdone_3;

reg gth_reset_done_reg = 0;

assign gth_reset_done = gth_reset_done_reg;

// register overall reset done output
always @(posedge clk156) begin
    gth_reset_done_reg <= resetdone_0 & resetdone_1 & resetdone_2 & resetdone_3;
end

wire disable_drp_mgmt;

wire disable_drp = gth_reset_done & disable_drp_mgmt;

wire lane_sel = {mgmt_gnt3, mgmt_gnt2, mgmt_gnt1, mgmt_gnt0};

// GTH quad wrapper
ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_QUAD #
(
    // Simulation attributes
    .QUAD_SIM_GTHRESET_SPEEDUP(0)
)
gth_inst
(
     //------------------------------- Resetdone --------------------------------
    .TX_PCS_RESETDONE0_OUT          (tx_resetdone_0),
    .RX_PCS_CDR_RESETDONE0_OUT      (rx_resetdone_0),
    .TX_PCS_RESETDONE1_OUT          (tx_resetdone_1),
    .RX_PCS_CDR_RESETDONE1_OUT      (rx_resetdone_1),
    .TX_PCS_RESETDONE2_OUT          (tx_resetdone_2),
    .RX_PCS_CDR_RESETDONE2_OUT      (rx_resetdone_2),
    .TX_PCS_RESETDONE3_OUT          (tx_resetdone_3),
    .RX_PCS_CDR_RESETDONE3_OUT      (rx_resetdone_3),
    //------------------------------- Initdone ---------------------------------
    .GTHINITDONE_OUT                (),
    //------------------------------- PCS Resets -------------------------------
    .TX_PCS_RESET0_IN               (1'b0),
    .RX_PCS_CDR_RESET0_IN           (1'b0),
    .TX_PCS_RESET1_IN               (1'b0),
    .RX_PCS_CDR_RESET1_IN           (1'b0),
    .TX_PCS_RESET2_IN               (1'b0),
    .RX_PCS_CDR_RESET2_IN           (1'b0),
    .TX_PCS_RESET3_IN               (1'b0),
    .RX_PCS_CDR_RESET3_IN           (1'b0),
    //------------------------------- Powerdown --------------------------------
    .POWERDOWN0_IN                  (1'b0),
    .POWERDOWN1_IN                  (1'b0),
    .POWERDOWN2_IN                  (1'b0),
    .POWERDOWN3_IN                  (1'b0),
    .RXPOWERDOWN0_IN                ({rx_powerdown_0 | (~gth_reset_done), 1'b0}),
    .RXPOWERDOWN1_IN                ({rx_powerdown_1 | (~gth_reset_done), 1'b0}),
    .RXPOWERDOWN2_IN                ({rx_powerdown_2 | (~gth_reset_done), 1'b0}),
    .RXPOWERDOWN3_IN                ({rx_powerdown_3 | (~gth_reset_done), 1'b0}),
    .TXPOWERDOWN0_IN                ({tx_powerdown_0 | (~gth_reset_done), 1'b0}),
    .TXPOWERDOWN1_IN                ({tx_powerdown_1 | (~gth_reset_done), 1'b0}),
    .TXPOWERDOWN2_IN                ({tx_powerdown_2 | (~gth_reset_done), 1'b0}),
    .TXPOWERDOWN3_IN                ({tx_powerdown_3 | (~gth_reset_done), 1'b0}),
    //----------------------------- Receive Ports ------------------------------
    .RXBUFRESET0_IN                 (1'b0),
    .RXBUFRESET1_IN                 (1'b0),
    .RXBUFRESET2_IN                 (1'b0),
    .RXBUFRESET3_IN                 (1'b0),
    .RXCODEERR0_OUT                 (),
    .RXCODEERR1_OUT                 (),
    .RXCODEERR2_OUT                 (),
    .RXCODEERR3_OUT                 (),
    .RXCTRL0_OUT                    (gth_rxc_0),
    .RXCTRL1_OUT                    (gth_rxc_1),
    .RXCTRL2_OUT                    (gth_rxc_2),
    .RXCTRL3_OUT                    (gth_rxc_3),
    .RXCTRLACK0_OUT                 (),
    .RXCTRLACK1_OUT                 (),
    .RXCTRLACK2_OUT                 (),
    .RXCTRLACK3_OUT                 (),
    .RXDATA0_OUT                    (gth_rxd_0),
    .RXDATA1_OUT                    (gth_rxd_1),
    .RXDATA2_OUT                    (gth_rxd_2),
    .RXDATA3_OUT                    (gth_rxd_3),
    .RXN0_IN                        (rxn_0),
    .RXN1_IN                        (rxn_1),
    .RXN2_IN                        (rxn_2),
    .RXN3_IN                        (rxn_3),
    .RXP0_IN                        (rxp_0),
    .RXP1_IN                        (rxp_1),
    .RXP2_IN                        (rxp_2),
    .RXP3_IN                        (rxp_3),
    .RXUSERCLKIN0_IN                (rx_clk_0_buf),
    .RXUSERCLKIN1_IN                (rx_clk_1_buf),
    .RXUSERCLKIN2_IN                (rx_clk_2_buf),
    .RXUSERCLKIN3_IN                (rx_clk_3_buf),
    .RXUSERCLKOUT0_OUT              (rx_clk_0),
    .RXUSERCLKOUT1_OUT              (rx_clk_1),
    .RXUSERCLKOUT2_OUT              (rx_clk_2),
    .RXUSERCLKOUT3_OUT              (rx_clk_3),
    //----------- Shared Ports - Dynamic Reconfiguration Port () ------------
    .DADDR_IN                       (16'h0000),
    .DCLK_IN                        (dclk),
    .DEN_IN                         (1'b0),
    .DI_IN                          (16'h0000),
    .DISABLEDRP_IN                  (disable_drp),
    .DRDY_OUT                       (),
    .DRPDO_OUT                      (),
    .DWE_IN                         (1'b0),
    //-------------------------- Shared Ports - Other --------------------------
    .TSTREFCLKFAB_OUT               (),
    .TSTREFCLKOUT_OUT               (),
    .GTHINIT_IN                     (1'b0),
    .GTHRESET_IN                    (gth_reset),
    .MGMTPCSLANESEL_IN              (lane_sel),
    .MGMTPCSMMDADDR_IN              (mgmt_addr[20:16]),
    .MGMTPCSRDACK_OUT               (mgmt_rdack),
    .MGMTPCSRDDATA_OUT              (mgmt_rddata),
    .MGMTPCSREGADDR_IN              (mgmt_addr[15:0]),
    .MGMTPCSREGRD_IN                (mgmt_rd),
    .MGMTPCSREGWR_IN                (mgmt_wr),
    .MGMTPCSWRDATA_IN               (mgmt_wrdata),
    .REFCLK_IN                      (refclk),
    //----------------------------- Transmit Ports -----------------------------
    .TXBUFRESET0_IN                 (1'b0),
    .TXBUFRESET1_IN                 (1'b0),
    .TXBUFRESET2_IN                 (1'b0),
    .TXBUFRESET3_IN                 (1'b0),
    .TXCTRL0_IN                     (gth_txc_0),
    .TXCTRL1_IN                     (gth_txc_1),
    .TXCTRL2_IN                     (gth_txc_2),
    .TXCTRL3_IN                     (gth_txc_3),
    .TXCTRLACK0_OUT                 (),
    .TXCTRLACK1_OUT                 (),
    .TXCTRLACK2_OUT                 (),
    .TXCTRLACK3_OUT                 (),
    .TXDATA0_IN                     (gth_txd_0),
    .TXDATA1_IN                     (gth_txd_1),
    .TXDATA2_IN                     (gth_txd_2),
    .TXDATA3_IN                     (gth_txd_3),
    .TXN0_OUT                       (txn_0),
    .TXN1_OUT                       (txn_1),
    .TXN2_OUT                       (txn_2),
    .TXN3_OUT                       (txn_3),
    .TXP0_OUT                       (txp_0),
    .TXP1_OUT                       (txp_1),
    .TXP2_OUT                       (txp_2),
    .TXP3_OUT                       (txp_3),
    .TXUSERCLKIN0_IN                (clk156),
    .TXUSERCLKIN1_IN                (clk156),
    .TXUSERCLKIN2_IN                (clk156),
    .TXUSERCLKIN3_IN                (clk156),
    .TXUSERCLKOUT0_OUT              (txclk156),
    .TXUSERCLKOUT1_OUT              (),
    .TXUSERCLKOUT2_OUT              (),
    .TXUSERCLKOUT3_OUT              ()
);

wire [535:0] configuration_vector;

assign configuration_vector[14:1]    = 0;
assign configuration_vector[79:17]   = 0;
assign configuration_vector[109:84]  = 0;
assign configuration_vector[175:170] = 0;
assign configuration_vector[239:234] = 0;
assign configuration_vector[269:246] = 0;
assign configuration_vector[511:272] = 0;
assign configuration_vector[515:513] = 0;
assign configuration_vector[517:517] = 0;
assign configuration_vector[0]       = 0; // pma_loopback;
assign configuration_vector[15]      = 0; // pma_reset;
assign configuration_vector[16]      = 0; // global_tx_disable;
assign configuration_vector[83:80]   = 0; // pma_vs_loopback;
assign configuration_vector[110]     = 0; // pcs_loopback;
assign configuration_vector[111]     = 0; // pcs_reset;
assign configuration_vector[169:112] = 0; // test_patt_a;
assign configuration_vector[233:176] = 0; // test_patt_b;
assign configuration_vector[240]     = 0; // data_patt_sel;
assign configuration_vector[241]     = 0; // test_patt_sel;
assign configuration_vector[242]     = 0; // rx_test_patt_en;
assign configuration_vector[243]     = 0; // tx_test_patt_en;
assign configuration_vector[244]     = 0; // prbs31_tx_en;
assign configuration_vector[245]     = 0; // prbs31_rx_en;
assign configuration_vector[271:270] = 0; // pcs_vs_loopback;
assign configuration_vector[512]     = 0; // set_pma_link_status;
assign configuration_vector[516]     = 0; // set_pcs_link_status;
assign configuration_vector[518]     = 0; // clear_pcs_status2;
assign configuration_vector[519]     = 0; // clear_test_patt_err_count;
assign configuration_vector[535:520] = 0;

ten_gig_eth_pcs_pma_v2_6
ten_gig_eth_pcs_pma_core_inst_0
(
    .reset(rst156),
    .clk156(clk156),
    .rxclk156(rx_clk_0_buf),
    .xgmii_txd(xgmii_txd_0),
    .xgmii_txc(xgmii_txc_0),
    .xgmii_rxd(xgmii_rxd_0),
    .xgmii_rxc(xgmii_rxc_0),
    .configuration_vector(configuration_vector),
    .status_vector(),
    .dclk(dclk),
    .mgmt_req(mgmt_req0),
    .mgmt_gnt(mgmt_gnt0),
    .mgmt_rd_out(mgmt_rd0),
    .mgmt_wr_out(mgmt_wr0),
    .mgmt_addr_out(mgmt_addr0),
    .mgmt_rdack_in(mgmt_rdack),
    .mgmt_rddata_in(mgmt_rddata),
    .mgmt_wrdata_out(mgmt_wrdata0),
    .gt_txd(gth_txd_0),
    .gt_txc(gth_txc_0),
    .gt_rxd(gth_rxd_0),
    .gt_rxc(gth_rxc_0),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_v2_6
ten_gig_eth_pcs_pma_core_inst_1
(
    .reset(rst156),
    .clk156(clk156),
    .rxclk156(rx_clk_1_buf),
    .xgmii_txd(xgmii_txd_1),
    .xgmii_txc(xgmii_txc_1),
    .xgmii_rxd(xgmii_rxd_1),
    .xgmii_rxc(xgmii_rxc_1),
    .configuration_vector(configuration_vector),
    .status_vector(),
    .dclk(dclk),
    .mgmt_req(mgmt_req1),
    .mgmt_gnt(mgmt_gnt1),
    .mgmt_rd_out(mgmt_rd1),
    .mgmt_wr_out(mgmt_wr1),
    .mgmt_addr_out(mgmt_addr1),
    .mgmt_rdack_in(mgmt_rdack),
    .mgmt_rddata_in(mgmt_rddata),
    .mgmt_wrdata_out(mgmt_wrdata1),
    .gt_txd(gth_txd_1),
    .gt_txc(gth_txc_1),
    .gt_rxd(gth_rxd_1),
    .gt_rxc(gth_rxc_1),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_v2_6
ten_gig_eth_pcs_pma_core_inst_2
(
    .reset(rst156),
    .clk156(clk156),
    .rxclk156(rx_clk_2_buf),
    .xgmii_txd(xgmii_txd_2),
    .xgmii_txc(xgmii_txc_2),
    .xgmii_rxd(xgmii_rxd_2),
    .xgmii_rxc(xgmii_rxc_2),
    .configuration_vector(configuration_vector),
    .status_vector(),
    .dclk(dclk),
    .mgmt_req(mgmt_req2),
    .mgmt_gnt(mgmt_gnt2),
    .mgmt_rd_out(mgmt_rd2),
    .mgmt_wr_out(mgmt_wr2),
    .mgmt_addr_out(mgmt_addr2),
    .mgmt_rdack_in(mgmt_rdack),
    .mgmt_rddata_in(mgmt_rddata),
    .mgmt_wrdata_out(mgmt_wrdata2),
    .gt_txd(gth_txd_2),
    .gt_txc(gth_txc_2),
    .gt_rxd(gth_rxd_2),
    .gt_rxc(gth_rxc_2),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_v2_6
ten_gig_eth_pcs_pma_core_inst_3
(
    .reset(rst156),
    .clk156(clk156),
    .rxclk156(rx_clk_3_buf),
    .xgmii_txd(xgmii_txd_3),
    .xgmii_txc(xgmii_txc_3),
    .xgmii_rxd(xgmii_rxd_3),
    .xgmii_rxc(xgmii_rxc_3),
    .configuration_vector(configuration_vector),
    .status_vector(),
    .dclk(dclk),
    .mgmt_req(mgmt_req3),
    .mgmt_gnt(mgmt_gnt3),
    .mgmt_rd_out(mgmt_rd3),
    .mgmt_wr_out(mgmt_wr3),
    .mgmt_addr_out(mgmt_addr3),
    .mgmt_rdack_in(mgmt_rdack),
    .mgmt_rddata_in(mgmt_rddata),
    .mgmt_wrdata_out(mgmt_wrdata3),
    .gt_txd(gth_txd_3),
    .gt_txc(gth_txc_3),
    .gt_rxd(gth_rxd_3),
    .gt_rxc(gth_rxc_3),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .tx_disable()
);

ten_gig_eth_pcs_pma_v2_6_management_arbiter
mgmt_arb_inst
(
    .dclk(dclk),
    .reset(dclk_reset),

    .mgmt_rd0(mgmt_rd0),
    .mgmt_wr0(mgmt_wr0),
    .mgmt_addr0(mgmt_addr0),
    .mgmt_wrdata0(mgmt_wrdata0),

    .mgmt_req0(mgmt_req0),
    .mgmt_gnt0(mgmt_gnt0),

    .mgmt_rd1(mgmt_rd1),
    .mgmt_wr1(mgmt_wr1),
    .mgmt_addr1(mgmt_addr1),
    .mgmt_wrdata1(mgmt_wrdata1),

    .mgmt_req1(mgmt_req1),
    .mgmt_gnt1(mgmt_gnt1),

    .mgmt_rd2(mgmt_rd2),
    .mgmt_wr2(mgmt_wr2),
    .mgmt_addr2(mgmt_addr2),
    .mgmt_wrdata2(mgmt_wrdata2),

    .mgmt_req2(mgmt_req2),
    .mgmt_gnt2(mgmt_gnt2),

    .mgmt_rd3(mgmt_rd3),
    .mgmt_wr3(mgmt_wr3),
    .mgmt_addr3(mgmt_addr3),
    .mgmt_wrdata3(mgmt_wrdata3),

    .mgmt_req3(mgmt_req3),
    .mgmt_gnt3(mgmt_gnt3),

    .mgmt_rd(mgmt_rd),
    .mgmt_wr(mgmt_wr),
    .mgmt_addr(mgmt_addr),
    .mgmt_wrdata(mgmt_wrdata),

    .drp_req(1'b0),
    .drp_gnt(),

    .disable_drp(disable_drp_mgmt)
);

endmodule

`resetall
