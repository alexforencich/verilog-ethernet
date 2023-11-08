/*

Copyright (c) 2014-2021 Alex Forencich

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
module fpga  #
(
    parameter QUAD_CNT = 17,
    parameter CH_CNT = QUAD_CNT*4
)
(
    /*
     * Clock: 156.25MHz
     */
    input  wire [1:0]          refclk_user_p,
    input  wire [1:0]          refclk_user_n,

    /*
     * Ethernet: QSFP28
     */
    input  wire [CH_CNT-1:0]   eth_gt_ch_rx_p,
    input  wire [CH_CNT-1:0]   eth_gt_ch_rx_n,
    output wire [CH_CNT-1:0]   eth_gt_ch_tx_p,
    output wire [CH_CNT-1:0]   eth_gt_ch_tx_n,
    input  wire [QUAD_CNT-1:0] eth_gt_pri_refclk_p,
    input  wire [QUAD_CNT-1:0] eth_gt_pri_refclk_n
);

genvar n;

// Clock and reset

// Buffers
wire [1:0] refclk_user;

generate

for (n = 0; n < 2; n = n + 1) begin : refclk_buf

    IBUFGDS #(
       .DIFF_TERM("FALSE"),
       .IBUF_LOW_PWR("FALSE")   
    )
    refclk_ibufg_inst (
       .O   (refclk_user[n]),
       .I   (refclk_user_p[n]),
       .IB  (refclk_user_n[n]) 
    );
    
end

endgenerate

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
// 156.25 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 8, D = 1 sets Fvco = 1250 MHz
// Divide by 10 to get output frequency of 125 MHz
MMCME3_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(10),
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
    .CLKIN1_PERIOD(6.400),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(refclk_user[0]),
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

// XGMII 10G PHY
wire [CH_CNT-1:0]     eth_tx_clk;
wire [CH_CNT-1:0]     eth_tx_rst;
wire [CH_CNT*64-1:0]  eth_txd;
wire [CH_CNT*8-1:0]   eth_txc;
wire [CH_CNT-1:0]     eth_rx_clk;
wire [CH_CNT-1:0]     eth_rx_rst;
wire [CH_CNT*64-1:0]  eth_rxd;
wire [CH_CNT*8-1:0]   eth_rxc;


assign clk_156mhz_int = eth_tx_clk[0];
assign rst_156mhz_int = eth_tx_rst[0];

generate

for (n = 0; n < QUAD_CNT; n = n + 1) begin : eth_quad

    wire quad_mgt_refclk;

    IBUFDS_GTE4 ibufds_gte4_qsfp_1_mgt_refclk_inst (
        .I             (eth_gt_pri_refclk_p[n]),
        .IB            (eth_gt_pri_refclk_n[n]),
        .CEB           (1'b0),
        .O             (quad_mgt_refclk),
        .ODIV2         ()
    );

    eth_xcvr_phy_quad_wrapper
    quad_phy_inst (
        .xcvr_ctrl_clk(clk_125mhz_int),
        .xcvr_ctrl_rst(rst_125mhz_int),

        /*
         * Common
         */
        .xcvr_gtpowergood_out(),

        /*
         * PLL
         */
        .xcvr_gtrefclk00_in(quad_mgt_refclk),

        /*
         * Serial data
         */
        .xcvr_txp(eth_gt_ch_tx_p[n*4 +: 4]),
        .xcvr_txn(eth_gt_ch_tx_n[n*4 +: 4]),
        .xcvr_rxp(eth_gt_ch_rx_p[n*4 +: 4]),
        .xcvr_rxn(eth_gt_ch_rx_n[n*4 +: 4]),

        /*
         * PHY connections
         */
        .phy_1_tx_clk(eth_tx_clk[n*4+0 +: 1]),
        .phy_1_tx_rst(eth_tx_rst[n*4+0 +: 1]),
        .phy_1_xgmii_txd(eth_txd[(n*4+0)*64 +: 64]),
        .phy_1_xgmii_txc(eth_txc[(n*4+0)*8 +: 8]),
        .phy_1_rx_clk(eth_rx_clk[n*4+0 +: 1]),
        .phy_1_rx_rst(eth_rx_rst[n*4+0 +: 1]),
        .phy_1_xgmii_rxd(eth_rxd[(n*4+0)*64 +: 64]),
        .phy_1_xgmii_rxc(eth_rxc[(n*4+0)*8 +: 8]),
        .phy_1_tx_bad_block(),
        .phy_1_rx_error_count(),
        .phy_1_rx_bad_block(),
        .phy_1_rx_sequence_error(),
        .phy_1_rx_block_lock(),
        .phy_1_rx_high_ber(),
        .phy_1_rx_status(),
        .phy_1_cfg_tx_prbs31_enable(1'b0),
        .phy_1_cfg_rx_prbs31_enable(1'b0),

        .phy_2_tx_clk(eth_tx_clk[n*4+1 +: 1]),
        .phy_2_tx_rst(eth_tx_rst[n*4+1 +: 1]),
        .phy_2_xgmii_txd(eth_txd[(n*4+1)*64 +: 64]),
        .phy_2_xgmii_txc(eth_txc[(n*4+1)*8 +: 8]),
        .phy_2_rx_clk(eth_rx_clk[n*4+1 +: 1]),
        .phy_2_rx_rst(eth_rx_rst[n*4+1 +: 1]),
        .phy_2_xgmii_rxd(eth_rxd[(n*4+1)*64 +: 64]),
        .phy_2_xgmii_rxc(eth_rxc[(n*4+1)*8 +: 8]),
        .phy_2_tx_bad_block(),
        .phy_2_rx_error_count(),
        .phy_2_rx_bad_block(),
        .phy_2_rx_sequence_error(),
        .phy_2_rx_block_lock(),
        .phy_2_rx_high_ber(),
        .phy_2_rx_status(),
        .phy_2_cfg_tx_prbs31_enable(1'b0),
        .phy_2_cfg_rx_prbs31_enable(1'b0),

        .phy_3_tx_clk(eth_tx_clk[n*4+2 +: 1]),
        .phy_3_tx_rst(eth_tx_rst[n*4+2 +: 1]),
        .phy_3_xgmii_txd(eth_txd[(n*4+2)*64 +: 64]),
        .phy_3_xgmii_txc(eth_txc[(n*4+2)*8 +: 8]),
        .phy_3_rx_clk(eth_rx_clk[n*4+2 +: 1]),
        .phy_3_rx_rst(eth_rx_rst[n*4+2 +: 1]),
        .phy_3_xgmii_rxd(eth_rxd[(n*4+2)*64 +: 64]),
        .phy_3_xgmii_rxc(eth_rxc[(n*4+2)*8 +: 8]),
        .phy_3_tx_bad_block(),
        .phy_3_rx_error_count(),
        .phy_3_rx_bad_block(),
        .phy_3_rx_sequence_error(),
        .phy_3_rx_block_lock(),
        .phy_3_rx_high_ber(),
        .phy_3_rx_status(),
        .phy_3_cfg_tx_prbs31_enable(1'b0),
        .phy_3_cfg_rx_prbs31_enable(1'b0),

        .phy_4_tx_clk(eth_tx_clk[n*4+3 +: 1]),
        .phy_4_tx_rst(eth_tx_rst[n*4+3 +: 1]),
        .phy_4_xgmii_txd(eth_txd[(n*4+3)*64 +: 64]),
        .phy_4_xgmii_txc(eth_txc[(n*4+3)*8 +: 8]),
        .phy_4_rx_clk(eth_rx_clk[n*4+3 +: 1]),
        .phy_4_rx_rst(eth_rx_rst[n*4+3 +: 1]),
        .phy_4_xgmii_rxd(eth_rxd[(n*4+3)*64 +: 64]),
        .phy_4_xgmii_rxc(eth_rxc[(n*4+3)*8 +: 8]),
        .phy_4_tx_bad_block(),
        .phy_4_rx_error_count(),
        .phy_4_rx_bad_block(),
        .phy_4_rx_sequence_error(),
        .phy_4_rx_block_lock(),
        .phy_4_rx_high_ber(),
        .phy_4_rx_status(),
        .phy_4_cfg_tx_prbs31_enable(1'b0),
        .phy_4_cfg_rx_prbs31_enable(1'b0)
    );

end

endgenerate

fpga_core #(
    .CH_CNT(CH_CNT)
)
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),

    /*
     * Ethernet: QSFP28
     */
    .eth_tx_clk(eth_tx_clk),
    .eth_tx_rst(eth_tx_rst),
    .eth_txd(eth_txd),
    .eth_txc(eth_txc),
    .eth_rx_clk(eth_rx_clk),
    .eth_rx_rst(eth_rx_rst),
    .eth_rxd(eth_rxd),
    .eth_rxc(eth_rxc)
);

endmodule

`resetall
