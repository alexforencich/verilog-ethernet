/*

Copyright (c) 2020-2021 Alex Forencich
Copyright (c) 2023 Víctor Mayoral Vilches

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
// module fpga #
// (
//     // AXI interface configuration (DMA)
//     parameter AXI_DATA_WIDTH = 128,
//     parameter AXI_ADDR_WIDTH = 32,
//     parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
//     parameter AXI_ID_WIDTH = 8,

//     // Interrupts
//     parameter IRQ_COUNT = 32,
//     parameter IRQ_STRETCH = 10,

//     // AXI lite interface configuration (control)
//     parameter AXIL_CTRL_DATA_WIDTH = 32,
//     parameter AXIL_CTRL_ADDR_WIDTH = 24,
//     parameter AXIL_CTRL_STRB_WIDTH = (AXIL_CTRL_DATA_WIDTH/8),

//     // AXI lite interface configuration (application control)
//     parameter AXIL_APP_CTRL_DATA_WIDTH = AXIL_CTRL_DATA_WIDTH,
//     parameter AXIL_APP_CTRL_ADDR_WIDTH = 24,
//     parameter AXIL_APP_CTRL_STRB_WIDTH = (AXIL_APP_CTRL_DATA_WIDTH/8)
// )
module fpga (
    /*
     * Clock: 25 MHz LVCMOS18
     */
     input wire clk_25mhz_ref,

    /*
     * GPIO
     */
    output wire [1:0] led,

    /*
     * Ethernet: SFP+
     */
    input  wire       sfp0_rx_p,
    input  wire       sfp0_rx_n,
    output wire       sfp0_tx_p,
    output wire       sfp0_tx_n,
    input  wire       sfp_mgt_refclk_0_p,
    input  wire       sfp_mgt_refclk_0_n,
    output wire       sfp0_tx_disable_b
);

// Clock and reset
wire clk_25mhz_bufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

// wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;


// BUFG stands for "buffer gate." The BUFG primitive is used to create a 
// buffer gate, which is a digital circuit component that is used to 
// amplify and/or isolate a signal.
// 
// Using a BUFG gate helps to ensure that the clock signal is distributed 
// properly throughout the system and reaches all the necessary components 
// with minimal delay.
// 
// https://docs.xilinx.com/r/2022.1-English/ug974-vivado-ultrascale-libraries/BUFG
BUFG
clk_25mhz_bufg_in_inst (
    .I(clk_25mhz_ref),
    .O(clk_25mhz_bufg)
);


// Base Mixed Mode Clock Manager (MMCM)
// 
// used to implement a Phase-Locked Loop (PLL) with Multiplier/Multiplier 
// and Phase Shift (MMCM) functionality
// see https://docs.xilinx.com/r/2022.1-English/ug974-vivado-ultrascale-libraries/MMCME4_BASE

// MMCM instance
// 25 MHz in, 125 MHz out
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
    .CLKFBOUT_MULT_F(40),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(40.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_25mhz_bufg),
    .CLKFBIN(mmcm_clkfb),
    // .RST(mmcm_rst),
    .RST(1'b0),
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

// // Clock and reset
// wire zynq_pl_clk;
// wire zynq_pl_reset;

// // Zynq AXI MM
// wire [IRQ_COUNT-1:0]                 irq;

// wire [AXI_ID_WIDTH-1:0]              axi_awid;
// wire [AXI_ADDR_WIDTH-1:0]            axi_awaddr;
// wire [7:0]                           axi_awlen;
// wire [2:0]                           axi_awsize;
// wire [1:0]                           axi_awburst;
// wire                                 axi_awlock;
// wire [3:0]                           axi_awcache;
// wire [2:0]                           axi_awprot;
// wire                                 axi_awvalid;
// wire                                 axi_awready;
// wire [AXI_DATA_WIDTH-1:0]            axi_wdata;
// wire [AXI_STRB_WIDTH-1:0]            axi_wstrb;
// wire                                 axi_wlast;
// wire                                 axi_wvalid;
// wire                                 axi_wready;
// wire [AXI_ID_WIDTH-1:0]              axi_bid;
// wire [1:0]                           axi_bresp;
// wire                                 axi_bvalid;
// wire                                 axi_bready;
// wire [AXI_ID_WIDTH-1:0]              axi_arid;
// wire [AXI_ADDR_WIDTH-1:0]            axi_araddr;
// wire [7:0]                           axi_arlen;
// wire [2:0]                           axi_arsize;
// wire [1:0]                           axi_arburst;
// wire                                 axi_arlock;
// wire [3:0]                           axi_arcache;
// wire [2:0]                           axi_arprot;
// wire                                 axi_arvalid;
// wire                                 axi_arready;
// wire [AXI_ID_WIDTH-1:0]              axi_rid;
// wire [AXI_DATA_WIDTH-1:0]            axi_rdata;
// wire [1:0]                           axi_rresp;
// wire                                 axi_rlast;
// wire                                 axi_rvalid;
// wire                                 axi_rready;

// // AXI lite connections
// wire [AXIL_CTRL_ADDR_WIDTH-1:0]      axil_ctrl_awaddr;
// wire [2:0]                           axil_ctrl_awprot;
// wire                                 axil_ctrl_awvalid;
// wire                                 axil_ctrl_awready;
// wire [AXIL_CTRL_DATA_WIDTH-1:0]      axil_ctrl_wdata;
// wire [AXIL_CTRL_STRB_WIDTH-1:0]      axil_ctrl_wstrb;
// wire                                 axil_ctrl_wvalid;
// wire                                 axil_ctrl_wready;
// wire [1:0]                           axil_ctrl_bresp;
// wire                                 axil_ctrl_bvalid;
// wire                                 axil_ctrl_bready;
// wire [AXIL_CTRL_ADDR_WIDTH-1:0]      axil_ctrl_araddr;
// wire [2:0]                           axil_ctrl_arprot;
// wire                                 axil_ctrl_arvalid;
// wire                                 axil_ctrl_arready;
// wire [AXIL_CTRL_DATA_WIDTH-1:0]      axil_ctrl_rdata;
// wire [1:0]                           axil_ctrl_rresp;
// wire                                 axil_ctrl_rvalid;
// wire                                 axil_ctrl_rready;

// wire [AXIL_APP_CTRL_ADDR_WIDTH-1:0]  axil_app_ctrl_awaddr;
// wire [2:0]                           axil_app_ctrl_awprot;
// wire                                 axil_app_ctrl_awvalid;
// wire                                 axil_app_ctrl_awready;
// wire [AXIL_APP_CTRL_DATA_WIDTH-1:0]  axil_app_ctrl_wdata;
// wire [AXIL_APP_CTRL_STRB_WIDTH-1:0]  axil_app_ctrl_wstrb;
// wire                                 axil_app_ctrl_wvalid;
// wire                                 axil_app_ctrl_wready;
// wire [1:0]                           axil_app_ctrl_bresp;
// wire                                 axil_app_ctrl_bvalid;
// wire                                 axil_app_ctrl_bready;
// wire [AXIL_APP_CTRL_ADDR_WIDTH-1:0]  axil_app_ctrl_araddr;
// wire [2:0]                           axil_app_ctrl_arprot;
// wire                                 axil_app_ctrl_arvalid;
// wire                                 axil_app_ctrl_arready;
// wire [AXIL_APP_CTRL_DATA_WIDTH-1:0]  axil_app_ctrl_rdata;
// wire [1:0]                           axil_app_ctrl_rresp;
// wire                                 axil_app_ctrl_rvalid;
// wire                                 axil_app_ctrl_rready;

// // implements an interrupt stretching mechanism to extend the duration 
// // of an interrupt signal to ensure that it is long enough to be detected 
// // by the receiving system. 
// reg [(IRQ_COUNT*IRQ_STRETCH)-1:0] irq_stretch = {(IRQ_COUNT*IRQ_STRETCH){1'b0}};
// always @(posedge zynq_pl_clk) begin
//     if (zynq_pl_reset) begin
//         irq_stretch <= {(IRQ_COUNT*IRQ_STRETCH){1'b0}};
//     end else begin
//         /* IRQ shift vector */
//         irq_stretch <= {irq_stretch[0 +: (IRQ_COUNT*IRQ_STRETCH)-IRQ_COUNT], irq};
//     end
// end

// reg [IRQ_COUNT-1:0] zynq_irq;
// integer i, k;
// always @* begin
//     for (k = 0; k < IRQ_COUNT; k = k + 1) begin
//         zynq_irq[k] = 1'b0;
//         for (i = 0; i < (IRQ_COUNT*IRQ_STRETCH); i = i + IRQ_COUNT) begin
//             zynq_irq[k] = zynq_irq[k] | irq_stretch[k + i];
//         end
//     end
// end

// // Zynq UltraScale+ PS
// zynq_ps zynq_ps_inst (
//     .pl_clk0(zynq_pl_clk),
//     .pl_reset(zynq_pl_reset),
//     .pl_ps_irq0(zynq_irq),

//     .m_axil_ctrl_araddr(axil_ctrl_araddr),
//     .m_axil_ctrl_arprot(axil_ctrl_arprot),
//     .m_axil_ctrl_arready(axil_ctrl_arready),
//     .m_axil_ctrl_arvalid(axil_ctrl_arvalid),
//     .m_axil_ctrl_awaddr(axil_ctrl_awaddr),
//     .m_axil_ctrl_awprot(axil_ctrl_awprot),
//     .m_axil_ctrl_awready(axil_ctrl_awready),
//     .m_axil_ctrl_awvalid(axil_ctrl_awvalid),
//     .m_axil_ctrl_bready(axil_ctrl_bready),
//     .m_axil_ctrl_bresp(axil_ctrl_bresp),
//     .m_axil_ctrl_bvalid(axil_ctrl_bvalid),
//     .m_axil_ctrl_rdata(axil_ctrl_rdata),
//     .m_axil_ctrl_rready(axil_ctrl_rready),
//     .m_axil_ctrl_rresp(axil_ctrl_rresp),
//     .m_axil_ctrl_rvalid(axil_ctrl_rvalid),
//     .m_axil_ctrl_wdata(axil_ctrl_wdata),
//     .m_axil_ctrl_wready(axil_ctrl_wready),
//     .m_axil_ctrl_wstrb(axil_ctrl_wstrb),
//     .m_axil_ctrl_wvalid(axil_ctrl_wvalid),

//     .m_axil_app_ctrl_araddr(axil_app_ctrl_araddr),
//     .m_axil_app_ctrl_arprot(axil_app_ctrl_arprot),
//     .m_axil_app_ctrl_arready(axil_app_ctrl_arready),
//     .m_axil_app_ctrl_arvalid(axil_app_ctrl_arvalid),
//     .m_axil_app_ctrl_awaddr(axil_app_ctrl_awaddr),
//     .m_axil_app_ctrl_awprot(axil_app_ctrl_awprot),
//     .m_axil_app_ctrl_awready(axil_app_ctrl_awready),
//     .m_axil_app_ctrl_awvalid(axil_app_ctrl_awvalid),
//     .m_axil_app_ctrl_bready(axil_app_ctrl_bready),
//     .m_axil_app_ctrl_bresp(axil_app_ctrl_bresp),
//     .m_axil_app_ctrl_bvalid(axil_app_ctrl_bvalid),
//     .m_axil_app_ctrl_rdata(axil_app_ctrl_rdata),
//     .m_axil_app_ctrl_rready(axil_app_ctrl_rready),
//     .m_axil_app_ctrl_rresp(axil_app_ctrl_rresp),
//     .m_axil_app_ctrl_rvalid(axil_app_ctrl_rvalid),
//     .m_axil_app_ctrl_wdata(axil_app_ctrl_wdata),
//     .m_axil_app_ctrl_wready(axil_app_ctrl_wready),
//     .m_axil_app_ctrl_wstrb(axil_app_ctrl_wstrb),
//     .m_axil_app_ctrl_wvalid(axil_app_ctrl_wvalid),

//     .s_axi_dma_araddr(axi_araddr),
//     .s_axi_dma_arburst(axi_arburst),
//     .s_axi_dma_arcache(axi_arcache),
//     .s_axi_dma_arid(axi_arid),
//     .s_axi_dma_arlen(axi_arlen),
//     .s_axi_dma_arlock(axi_arlock),
//     .s_axi_dma_arprot(axi_arprot),
//     .s_axi_dma_arqos({4{1'b0}}),
//     .s_axi_dma_arready(axi_arready),
//     .s_axi_dma_arsize(axi_arsize),
//     .s_axi_dma_aruser(1'b0),
//     .s_axi_dma_arvalid(axi_arvalid),
//     .s_axi_dma_awaddr(axi_awaddr),
//     .s_axi_dma_awburst(axi_awburst),
//     .s_axi_dma_awcache(axi_awcache),
//     .s_axi_dma_awid(axi_awid),
//     .s_axi_dma_awlen(axi_awlen),
//     .s_axi_dma_awlock(axi_awlock),
//     .s_axi_dma_awprot(axi_awprot),
//     .s_axi_dma_awqos({4{1'b0}}),
//     .s_axi_dma_awready(axi_awready),
//     .s_axi_dma_awsize(axi_awsize),
//     .s_axi_dma_awuser(1'b0),
//     .s_axi_dma_awvalid(axi_awvalid),
//     .s_axi_dma_bid(axi_bid),
//     .s_axi_dma_bready(axi_bready),
//     .s_axi_dma_bresp(axi_bresp),
//     .s_axi_dma_bvalid(axi_bvalid),
//     .s_axi_dma_rdata(axi_rdata),
//     .s_axi_dma_rid(axi_rid),
//     .s_axi_dma_rlast(axi_rlast),
//     .s_axi_dma_rready(axi_rready),
//     .s_axi_dma_rresp(axi_rresp),
//     .s_axi_dma_rvalid(axi_rvalid),
//     .s_axi_dma_wdata(axi_wdata),
//     .s_axi_dma_wlast(axi_wlast),
//     .s_axi_dma_wready(axi_wready),
//     .s_axi_dma_wstrb(axi_wstrb),
//     .s_axi_dma_wvalid(axi_wvalid)
// );

// XGMII 10G PHY
assign sfp0_tx_disable_b = 1'b1;

wire        sfp0_tx_clk_int;
wire        sfp0_tx_rst_int;
wire [63:0] sfp0_txd_int;
wire [7:0]  sfp0_txc_int;
wire        sfp0_rx_clk_int;
wire        sfp0_rx_rst_int;
wire [63:0] sfp0_rxd_int;
wire [7:0]  sfp0_rxc_int;

assign clk_156mhz_int = sfp0_tx_clk_int;
assign rst_156mhz_int = sfp0_tx_rst_int;

wire sfp0_rx_block_lock;

wire sfp_mgt_refclk_0;

// Gigabit Transceiver Buffer
// 
// Differential input buffer designed to work with the GTE 
// (Gigabit Transceiver) transceiver tiles
// 
// see https://docs.xilinx.com/r/2022.1-English/ug974-vivado-ultrascale-libraries/IBUFDS_GTE4
IBUFDS_GTE4 ibufds_gte4_sfp_mgt_refclk_0_inst (
    .I     (sfp_mgt_refclk_0_p),
    .IB    (sfp_mgt_refclk_0_n),
    .CEB   (1'b0),
    .O     (sfp_mgt_refclk_0),
    .ODIV2 ()
);

wire sfp_qpll0lock;
wire sfp_qpll0outclk;
wire sfp_qpll0outrefclk;

eth_xcvr_phy_wrapper #(
    .HAS_COMMON(1)
)
sfp0_phy_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(rst_125mhz_int),

    // Common
    .xcvr_gtpowergood_out(),

    // PLL out
    .xcvr_gtrefclk00_in(sfp_mgt_refclk_0),
    .xcvr_qpll0lock_out(sfp_qpll0lock),
    .xcvr_qpll0outclk_out(sfp_qpll0outclk),
    .xcvr_qpll0outrefclk_out(sfp_qpll0outrefclk),

    // PLL in
    .xcvr_qpll0lock_in(1'b0),
    .xcvr_qpll0reset_out(),
    .xcvr_qpll0clk_in(1'b0),
    .xcvr_qpll0refclk_in(1'b0),

    // Serial data
    .xcvr_txp(sfp0_tx_p),
    .xcvr_txn(sfp0_tx_n),
    .xcvr_rxp(sfp0_rx_p),
    .xcvr_rxn(sfp0_rx_n),

    // PHY connections
    .phy_tx_clk(sfp0_tx_clk_int),
    .phy_tx_rst(sfp0_tx_rst_int),
    .phy_xgmii_txd(sfp0_txd_int),
    .phy_xgmii_txc(sfp0_txc_int),
    .phy_rx_clk(sfp0_rx_clk_int),
    .phy_rx_rst(sfp0_rx_rst_int),
    .phy_xgmii_rxd(sfp0_rxd_int),
    .phy_xgmii_rxc(sfp0_rxc_int),
    .phy_tx_bad_block(),
    .phy_rx_error_count(),
    .phy_rx_bad_block(),
    .phy_rx_sequence_error(),
    .phy_rx_block_lock(sfp0_rx_block_lock),
    .phy_rx_high_ber(),
    .phy_tx_prbs31_enable(),
    .phy_rx_prbs31_enable()
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
    .led(led),
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
    .sfp0_rxc(sfp0_rxc_int)
);

endmodule

`resetall
