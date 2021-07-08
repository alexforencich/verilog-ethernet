/*

Copyright (c) 2021 Alex Forencich

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
     * Clock: 200 MHz LVDS
     */
    input  wire       ref_clk_p,
    input  wire       ref_clk_n,

    input  wire       clk_gty2_lol_n,

    /*
     * GPIO
     */
    input  wire [1:0] btn,
    input  wire [7:0] sw,
    output wire [7:0] led,

    /*
     * I2C for board management
     */
    inout  wire       i2c_main_scl,
    inout  wire       i2c_main_sda,
    output wire       i2c_main_rst_n,

    /*
     * UART: 115200 bps, 8N1
     */
    output wire       uart_rxd,
    input  wire       uart_txd,
    input  wire       uart_rts,
    output wire       uart_cts,
    output wire       uart_rst_n,
    output wire       uart_suspend_n,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0] qsfp_1_tx_p,
    output wire [3:0] qsfp_1_tx_n,
    input  wire [3:0] qsfp_1_rx_p,
    input  wire [3:0] qsfp_1_rx_n,
    input  wire       qsfp_1_mgt_refclk_p,
    input  wire       qsfp_1_mgt_refclk_n,
    output wire       qsfp_1_resetl,
    input  wire       qsfp_1_modprsl,
    input  wire       qsfp_1_intl,

    output wire [3:0] qsfp_2_tx_p,
    output wire [3:0] qsfp_2_tx_n,
    input  wire [3:0] qsfp_2_rx_p,
    input  wire [3:0] qsfp_2_rx_n,
    input  wire       qsfp_2_mgt_refclk_p,
    input  wire       qsfp_2_mgt_refclk_n,
    output wire       qsfp_2_resetl,
    input  wire       qsfp_2_modprsl,
    input  wire       qsfp_2_intl,

    output wire [3:0] qsfp_3_tx_p,
    output wire [3:0] qsfp_3_tx_n,
    input  wire [3:0] qsfp_3_rx_p,
    input  wire [3:0] qsfp_3_rx_n,
    input  wire       qsfp_3_mgt_refclk_p,
    input  wire       qsfp_3_mgt_refclk_n,
    output wire       qsfp_3_resetl,
    input  wire       qsfp_3_modprsl,
    input  wire       qsfp_3_intl,

    output wire [3:0] qsfp_4_tx_p,
    output wire [3:0] qsfp_4_tx_n,
    input  wire [3:0] qsfp_4_rx_p,
    input  wire [3:0] qsfp_4_rx_n,
    input  wire       qsfp_4_mgt_refclk_p,
    input  wire       qsfp_4_mgt_refclk_n,
    output wire       qsfp_4_resetl,
    input  wire       qsfp_4_modprsl,
    input  wire       qsfp_4_intl,

    output wire [3:0] qsfp_5_tx_p,
    output wire [3:0] qsfp_5_tx_n,
    input  wire [3:0] qsfp_5_rx_p,
    input  wire [3:0] qsfp_5_rx_n,
    input  wire       qsfp_5_mgt_refclk_p,
    input  wire       qsfp_5_mgt_refclk_n,
    output wire       qsfp_5_resetl,
    input  wire       qsfp_5_modprsl,
    input  wire       qsfp_5_intl,

    output wire [3:0] qsfp_6_tx_p,
    output wire [3:0] qsfp_6_tx_n,
    input  wire [3:0] qsfp_6_rx_p,
    input  wire [3:0] qsfp_6_rx_n,
    input  wire       qsfp_6_mgt_refclk_p,
    input  wire       qsfp_6_mgt_refclk_n,
    output wire       qsfp_6_resetl,
    input  wire       qsfp_6_modprsl,
    input  wire       qsfp_6_intl,

    output wire [3:0] qsfp_7_tx_p,
    output wire [3:0] qsfp_7_tx_n,
    input  wire [3:0] qsfp_7_rx_p,
    input  wire [3:0] qsfp_7_rx_n,
    input  wire       qsfp_7_mgt_refclk_p,
    input  wire       qsfp_7_mgt_refclk_n,
    output wire       qsfp_7_resetl,
    input  wire       qsfp_7_modprsl,
    input  wire       qsfp_7_intl,

    output wire [3:0] qsfp_8_tx_p,
    output wire [3:0] qsfp_8_tx_n,
    input  wire [3:0] qsfp_8_rx_p,
    input  wire [3:0] qsfp_8_rx_n,
    input  wire       qsfp_8_mgt_refclk_p,
    input  wire       qsfp_8_mgt_refclk_n,
    output wire       qsfp_8_resetl,
    input  wire       qsfp_8_modprsl,
    input  wire       qsfp_8_intl,

    output wire [3:0] qsfp_9_tx_p,
    output wire [3:0] qsfp_9_tx_n,
    input  wire [3:0] qsfp_9_rx_p,
    input  wire [3:0] qsfp_9_rx_n,
    input  wire       qsfp_9_mgt_refclk_p,
    input  wire       qsfp_9_mgt_refclk_n,
    output wire       qsfp_9_resetl,
    input  wire       qsfp_9_modprsl,
    input  wire       qsfp_9_intl
);

// Clock and reset

wire ref_clk_ibufg;

wire clk_125mhz_mmcm_out;

// Internal 125 MHz clock
wire clk_125mhz_int;
wire rst_125mhz_int;

wire mmcm_rst = ~btn[0];
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
ref_clk_ibufg_inst (
   .O   (ref_clk_ibufg),
   .I   (ref_clk_p),
   .IB  (ref_clk_n) 
);

// MMCM instance
// 200 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 5, D = 1 sets Fvco = 1000 MHz (in range)
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
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(5.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(ref_clk_ibufg),
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
wire btn_int;
wire [7:0] sw_int;

debounce_switch #(
    .WIDTH(9),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({btn[1],
        sw}),
    .out({btn_int,
        sw_int})
);

wire uart_txd_int;
wire uart_rts_int;

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_125mhz_int),
    .in({uart_txd, uart_rts}),
    .out({uart_txd_int, uart_rts_int})
);

wire i2c_scl_i;
wire i2c_scl_o;
wire i2c_scl_t;
wire i2c_sda_i;
wire i2c_sda_o;
wire i2c_sda_t;

assign i2c_scl_i = i2c_main_scl;
assign i2c_main_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_main_sda;
assign i2c_main_sda = i2c_sda_t ? 1'bz : i2c_sda_o;
assign i2c_main_rst_n = 1'b1;

// Si5341 init
wire [6:0] si5341_i2c_cmd_address;
wire si5341_i2c_cmd_start;
wire si5341_i2c_cmd_read;
wire si5341_i2c_cmd_write;
wire si5341_i2c_cmd_write_multiple;
wire si5341_i2c_cmd_stop;
wire si5341_i2c_cmd_valid;
wire si5341_i2c_cmd_ready;

wire [7:0] si5341_i2c_data_tdata;
wire si5341_i2c_data_tvalid;
wire si5341_i2c_data_tready;
wire si5341_i2c_data_tlast;

wire si5341_i2c_busy;

i2c_master
si5341_i2c_master_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .s_axis_cmd_address(si5341_i2c_cmd_address),
    .s_axis_cmd_start(si5341_i2c_cmd_start),
    .s_axis_cmd_read(si5341_i2c_cmd_read),
    .s_axis_cmd_write(si5341_i2c_cmd_write),
    .s_axis_cmd_write_multiple(si5341_i2c_cmd_write_multiple),
    .s_axis_cmd_stop(si5341_i2c_cmd_stop),
    .s_axis_cmd_valid(si5341_i2c_cmd_valid),
    .s_axis_cmd_ready(si5341_i2c_cmd_ready),
    .s_axis_data_tdata(si5341_i2c_data_tdata),
    .s_axis_data_tvalid(si5341_i2c_data_tvalid),
    .s_axis_data_tready(si5341_i2c_data_tready),
    .s_axis_data_tlast(si5341_i2c_data_tlast),
    .m_axis_data_tdata(),
    .m_axis_data_tvalid(),
    .m_axis_data_tready(1'b1),
    .m_axis_data_tlast(),
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

si5341_i2c_init
si5341_i2c_init_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .m_axis_cmd_address(si5341_i2c_cmd_address),
    .m_axis_cmd_start(si5341_i2c_cmd_start),
    .m_axis_cmd_read(si5341_i2c_cmd_read),
    .m_axis_cmd_write(si5341_i2c_cmd_write),
    .m_axis_cmd_write_multiple(si5341_i2c_cmd_write_multiple),
    .m_axis_cmd_stop(si5341_i2c_cmd_stop),
    .m_axis_cmd_valid(si5341_i2c_cmd_valid),
    .m_axis_cmd_ready(si5341_i2c_cmd_ready),
    .m_axis_data_tdata(si5341_i2c_data_tdata),
    .m_axis_data_tvalid(si5341_i2c_data_tvalid),
    .m_axis_data_tready(si5341_i2c_data_tready),
    .m_axis_data_tlast(si5341_i2c_data_tlast),
    .busy(si5341_i2c_busy),
    .start(1'b1)
);

// XGMII 10G PHY
wire qsfp_reset = rst_125mhz_int || si5341_i2c_busy || !clk_gty2_lol_n;

// QSFP 1
assign qsfp_1_resetl = 1'b1;

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
wire        qsfp_1_tx_clk_4_int;
wire        qsfp_1_tx_rst_4_int;
wire [63:0] qsfp_1_txd_4_int;
wire [7:0]  qsfp_1_txc_4_int;
wire        qsfp_1_rx_clk_4_int;
wire        qsfp_1_rx_rst_4_int;
wire [63:0] qsfp_1_rxd_4_int;
wire [7:0]  qsfp_1_rxc_4_int;

wire qsfp_1_rx_block_lock_1;
wire qsfp_1_rx_block_lock_2;
wire qsfp_1_rx_block_lock_3;
wire qsfp_1_rx_block_lock_4;

wire qsfp_1_mgt_refclk;

wire [3:0] qsfp_1_gt_txclkout;
wire qsfp_1_gt_txusrclk;

wire [3:0] qsfp_1_gt_rxclkout;
wire [3:0] qsfp_1_gt_rxusrclk;

wire qsfp_1_gt_reset_tx_done;
wire qsfp_1_gt_reset_rx_done;

wire [3:0] qsfp_1_gt_txprgdivresetdone;
wire [3:0] qsfp_1_gt_txpmaresetdone;
wire [3:0] qsfp_1_gt_rxprgdivresetdone;
wire [3:0] qsfp_1_gt_rxpmaresetdone;

wire qsfp_1_gt_tx_reset = ~((&qsfp_1_gt_txprgdivresetdone) & (&qsfp_1_gt_txpmaresetdone));
wire qsfp_1_gt_rx_reset = ~&qsfp_1_gt_rxpmaresetdone;

reg qsfp_1_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_1_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_1_mgt_refclk_inst (
    .I             (qsfp_1_mgt_refclk_p),
    .IB            (qsfp_1_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_1_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_1_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_1_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_1_gt_txclkout[0]),
    .O       (qsfp_1_gt_txusrclk)
);

always @(posedge qsfp_1_gt_txusrclk, posedge qsfp_1_gt_tx_reset) begin
    if (qsfp_1_gt_tx_reset) begin
        qsfp_1_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_1_gt_userclk_tx_active <= 1'b1;
    end
end

genvar n;

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_1_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_1_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_1_gt_rxclkout[n]),
        .O       (qsfp_1_gt_rxusrclk[n])
    );

    always @(posedge qsfp_1_gt_rxusrclk[n], posedge qsfp_1_gt_rx_reset) begin
        if (qsfp_1_gt_rx_reset) begin
            qsfp_1_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_1_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_1_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_1_tx_rst_reset_sync_inst (
    .clk(qsfp_1_gt_txusrclk),
    .rst(~qsfp_1_gt_reset_tx_done),
    .out(qsfp_1_tx_reset)
);

assign clk_156mhz_int = qsfp_1_gt_txusrclk;
assign rst_156mhz_int = qsfp_1_tx_reset;

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

wire [5:0] qsfp_1_gt_txheader_4;
wire [63:0] qsfp_1_gt_txdata_4;
wire qsfp_1_gt_rxgearboxslip_4;
wire [5:0] qsfp_1_gt_rxheader_4;
wire [1:0] qsfp_1_gt_rxheadervalid_4;
wire [63:0] qsfp_1_gt_rxdata_4;
wire [1:0] qsfp_1_gt_rxdatavalid_4;

gtwiz_qsfp_1
qsfp_1_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_1_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_1_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_1_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_1_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_1_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_1_rx_n[3], qsfp_1_rx_n[0], qsfp_1_rx_n[2], qsfp_1_rx_n[1]}),
    .gtyrxp_in({qsfp_1_rx_p[3], qsfp_1_rx_p[0], qsfp_1_rx_p[2], qsfp_1_rx_p[1]}),

    .rxusrclk_in(qsfp_1_gt_rxusrclk),
    .rxusrclk2_in(qsfp_1_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_1_gt_txdata_4, qsfp_1_gt_txdata_1, qsfp_1_gt_txdata_3, qsfp_1_gt_txdata_2}),
    .txheader_in({qsfp_1_gt_txheader_4, qsfp_1_gt_txheader_1, qsfp_1_gt_txheader_3, qsfp_1_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_1_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_1_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_1_tx_n[3], qsfp_1_tx_n[0], qsfp_1_tx_n[2], qsfp_1_tx_n[1]}),
    .gtytxp_out({qsfp_1_tx_p[3], qsfp_1_tx_p[0], qsfp_1_tx_p[2], qsfp_1_tx_p[1]}),

    .rxgearboxslip_in({qsfp_1_gt_rxgearboxslip_4, qsfp_1_gt_rxgearboxslip_1, qsfp_1_gt_rxgearboxslip_3, qsfp_1_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_1_gt_rxdata_4, qsfp_1_gt_rxdata_1, qsfp_1_gt_rxdata_3, qsfp_1_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_1_gt_rxdatavalid_4, qsfp_1_gt_rxdatavalid_1, qsfp_1_gt_rxdatavalid_3, qsfp_1_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_1_gt_rxheader_4, qsfp_1_gt_rxheader_1, qsfp_1_gt_rxheader_3, qsfp_1_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_1_gt_rxheadervalid_4, qsfp_1_gt_rxheadervalid_1, qsfp_1_gt_rxheadervalid_3, qsfp_1_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_1_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_1_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_1_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_1_gt_txclkout),
    .txpmaresetdone_out(qsfp_1_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_1_gt_txprgdivresetdone)
);

assign qsfp_1_tx_clk_1_int = qsfp_1_gt_txusrclk;
assign qsfp_1_tx_rst_1_int = qsfp_1_tx_reset;

assign qsfp_1_rx_clk_1_int = qsfp_1_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_1_reset_sync_inst (
    .clk(qsfp_1_rx_clk_1_int),
    .rst(~qsfp_1_gt_reset_rx_done),
    .out(qsfp_1_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
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

assign qsfp_1_tx_clk_2_int = qsfp_1_gt_txusrclk;
assign qsfp_1_tx_rst_2_int = qsfp_1_tx_reset;

assign qsfp_1_rx_clk_2_int = qsfp_1_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_2_reset_sync_inst (
    .clk(qsfp_1_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
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

assign qsfp_1_tx_clk_3_int = qsfp_1_gt_txusrclk;
assign qsfp_1_tx_rst_3_int = qsfp_1_tx_reset;

assign qsfp_1_rx_clk_3_int = qsfp_1_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_3_reset_sync_inst (
    .clk(qsfp_1_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
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

assign qsfp_1_tx_clk_4_int = qsfp_1_gt_txusrclk;
assign qsfp_1_tx_rst_4_int = qsfp_1_tx_reset;

assign qsfp_1_rx_clk_4_int = qsfp_1_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_1_rx_rst_4_reset_sync_inst (
    .clk(qsfp_1_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_1_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_1_phy_4_inst (
    .tx_clk(qsfp_1_tx_clk_4_int),
    .tx_rst(qsfp_1_tx_rst_4_int),
    .rx_clk(qsfp_1_rx_clk_4_int),
    .rx_rst(qsfp_1_rx_rst_4_int),
    .xgmii_txd(qsfp_1_txd_4_int),
    .xgmii_txc(qsfp_1_txc_4_int),
    .xgmii_rxd(qsfp_1_rxd_4_int),
    .xgmii_rxc(qsfp_1_rxc_4_int),
    .serdes_tx_data(qsfp_1_gt_txdata_4),
    .serdes_tx_hdr(qsfp_1_gt_txheader_4),
    .serdes_rx_data(qsfp_1_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_1_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_1_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_1_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 2
assign qsfp_2_resetl = 1'b1;

wire        qsfp_2_tx_clk_1_int;
wire        qsfp_2_tx_rst_1_int;
wire [63:0] qsfp_2_txd_1_int;
wire [7:0]  qsfp_2_txc_1_int;
wire        qsfp_2_rx_clk_1_int;
wire        qsfp_2_rx_rst_1_int;
wire [63:0] qsfp_2_rxd_1_int;
wire [7:0]  qsfp_2_rxc_1_int;
wire        qsfp_2_tx_clk_2_int;
wire        qsfp_2_tx_rst_2_int;
wire [63:0] qsfp_2_txd_2_int;
wire [7:0]  qsfp_2_txc_2_int;
wire        qsfp_2_rx_clk_2_int;
wire        qsfp_2_rx_rst_2_int;
wire [63:0] qsfp_2_rxd_2_int;
wire [7:0]  qsfp_2_rxc_2_int;
wire        qsfp_2_tx_clk_3_int;
wire        qsfp_2_tx_rst_3_int;
wire [63:0] qsfp_2_txd_3_int;
wire [7:0]  qsfp_2_txc_3_int;
wire        qsfp_2_rx_clk_3_int;
wire        qsfp_2_rx_rst_3_int;
wire [63:0] qsfp_2_rxd_3_int;
wire [7:0]  qsfp_2_rxc_3_int;
wire        qsfp_2_tx_clk_4_int;
wire        qsfp_2_tx_rst_4_int;
wire [63:0] qsfp_2_txd_4_int;
wire [7:0]  qsfp_2_txc_4_int;
wire        qsfp_2_rx_clk_4_int;
wire        qsfp_2_rx_rst_4_int;
wire [63:0] qsfp_2_rxd_4_int;
wire [7:0]  qsfp_2_rxc_4_int;

wire qsfp_2_rx_block_lock_1;
wire qsfp_2_rx_block_lock_2;
wire qsfp_2_rx_block_lock_3;
wire qsfp_2_rx_block_lock_4;

wire qsfp_2_mgt_refclk;

wire [3:0] qsfp_2_gt_txclkout;
wire qsfp_2_gt_txusrclk;

wire [3:0] qsfp_2_gt_rxclkout;
wire [3:0] qsfp_2_gt_rxusrclk;

wire qsfp_2_gt_reset_tx_done;
wire qsfp_2_gt_reset_rx_done;

wire [3:0] qsfp_2_gt_txprgdivresetdone;
wire [3:0] qsfp_2_gt_txpmaresetdone;
wire [3:0] qsfp_2_gt_rxprgdivresetdone;
wire [3:0] qsfp_2_gt_rxpmaresetdone;

wire qsfp_2_gt_tx_reset = ~((&qsfp_2_gt_txprgdivresetdone) & (&qsfp_2_gt_txpmaresetdone));
wire qsfp_2_gt_rx_reset = ~&qsfp_2_gt_rxpmaresetdone;

reg qsfp_2_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_2_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_2_mgt_refclk_inst (
    .I             (qsfp_2_mgt_refclk_p),
    .IB            (qsfp_2_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_2_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_2_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_2_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_2_gt_txclkout[0]),
    .O       (qsfp_2_gt_txusrclk)
);

always @(posedge qsfp_2_gt_txusrclk, posedge qsfp_2_gt_tx_reset) begin
    if (qsfp_2_gt_tx_reset) begin
        qsfp_2_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_2_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_2_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_2_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_2_gt_rxclkout[n]),
        .O       (qsfp_2_gt_rxusrclk[n])
    );

    always @(posedge qsfp_2_gt_rxusrclk[n], posedge qsfp_2_gt_rx_reset) begin
        if (qsfp_2_gt_rx_reset) begin
            qsfp_2_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_2_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_2_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_2_tx_rst_reset_sync_inst (
    .clk(qsfp_2_gt_txusrclk),
    .rst(~qsfp_2_gt_reset_tx_done),
    .out(qsfp_2_tx_reset)
);

wire [5:0] qsfp_2_gt_txheader_1;
wire [63:0] qsfp_2_gt_txdata_1;
wire qsfp_2_gt_rxgearboxslip_1;
wire [5:0] qsfp_2_gt_rxheader_1;
wire [1:0] qsfp_2_gt_rxheadervalid_1;
wire [63:0] qsfp_2_gt_rxdata_1;
wire [1:0] qsfp_2_gt_rxdatavalid_1;

wire [5:0] qsfp_2_gt_txheader_2;
wire [63:0] qsfp_2_gt_txdata_2;
wire qsfp_2_gt_rxgearboxslip_2;
wire [5:0] qsfp_2_gt_rxheader_2;
wire [1:0] qsfp_2_gt_rxheadervalid_2;
wire [63:0] qsfp_2_gt_rxdata_2;
wire [1:0] qsfp_2_gt_rxdatavalid_2;

wire [5:0] qsfp_2_gt_txheader_3;
wire [63:0] qsfp_2_gt_txdata_3;
wire qsfp_2_gt_rxgearboxslip_3;
wire [5:0] qsfp_2_gt_rxheader_3;
wire [1:0] qsfp_2_gt_rxheadervalid_3;
wire [63:0] qsfp_2_gt_rxdata_3;
wire [1:0] qsfp_2_gt_rxdatavalid_3;

wire [5:0] qsfp_2_gt_txheader_4;
wire [63:0] qsfp_2_gt_txdata_4;
wire qsfp_2_gt_rxgearboxslip_4;
wire [5:0] qsfp_2_gt_rxheader_4;
wire [1:0] qsfp_2_gt_rxheadervalid_4;
wire [63:0] qsfp_2_gt_rxdata_4;
wire [1:0] qsfp_2_gt_rxdatavalid_4;

gtwiz_qsfp_2
qsfp_2_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_2_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_2_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_2_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_2_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_2_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_2_rx_n[3], qsfp_2_rx_n[0], qsfp_2_rx_n[2], qsfp_2_rx_n[1]}),
    .gtyrxp_in({qsfp_2_rx_p[3], qsfp_2_rx_p[0], qsfp_2_rx_p[2], qsfp_2_rx_p[1]}),

    .rxusrclk_in(qsfp_2_gt_rxusrclk),
    .rxusrclk2_in(qsfp_2_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_2_gt_txdata_4, qsfp_2_gt_txdata_1, qsfp_2_gt_txdata_3, qsfp_2_gt_txdata_2}),
    .txheader_in({qsfp_2_gt_txheader_4, qsfp_2_gt_txheader_1, qsfp_2_gt_txheader_3, qsfp_2_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_2_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_2_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_2_tx_n[3], qsfp_2_tx_n[0], qsfp_2_tx_n[2], qsfp_2_tx_n[1]}),
    .gtytxp_out({qsfp_2_tx_p[3], qsfp_2_tx_p[0], qsfp_2_tx_p[2], qsfp_2_tx_p[1]}),

    .rxgearboxslip_in({qsfp_2_gt_rxgearboxslip_4, qsfp_2_gt_rxgearboxslip_1, qsfp_2_gt_rxgearboxslip_3, qsfp_2_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_2_gt_rxdata_4, qsfp_2_gt_rxdata_1, qsfp_2_gt_rxdata_3, qsfp_2_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_2_gt_rxdatavalid_4, qsfp_2_gt_rxdatavalid_1, qsfp_2_gt_rxdatavalid_3, qsfp_2_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_2_gt_rxheader_4, qsfp_2_gt_rxheader_1, qsfp_2_gt_rxheader_3, qsfp_2_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_2_gt_rxheadervalid_4, qsfp_2_gt_rxheadervalid_1, qsfp_2_gt_rxheadervalid_3, qsfp_2_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_2_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_2_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_2_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_2_gt_txclkout),
    .txpmaresetdone_out(qsfp_2_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_2_gt_txprgdivresetdone)
);

assign qsfp_2_tx_clk_1_int = qsfp_2_gt_txusrclk;
assign qsfp_2_tx_rst_1_int = qsfp_2_tx_reset;

assign qsfp_2_rx_clk_1_int = qsfp_2_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_2_rx_rst_1_reset_sync_inst (
    .clk(qsfp_2_rx_clk_1_int),
    .rst(~qsfp_2_gt_reset_rx_done),
    .out(qsfp_2_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_2_phy_1_inst (
    .tx_clk(qsfp_2_tx_clk_1_int),
    .tx_rst(qsfp_2_tx_rst_1_int),
    .rx_clk(qsfp_2_rx_clk_1_int),
    .rx_rst(qsfp_2_rx_rst_1_int),
    .xgmii_txd(qsfp_2_txd_1_int),
    .xgmii_txc(qsfp_2_txc_1_int),
    .xgmii_rxd(qsfp_2_rxd_1_int),
    .xgmii_rxc(qsfp_2_rxc_1_int),
    .serdes_tx_data(qsfp_2_gt_txdata_1),
    .serdes_tx_hdr(qsfp_2_gt_txheader_1),
    .serdes_rx_data(qsfp_2_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_2_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_2_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_2_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_2_tx_clk_2_int = qsfp_2_gt_txusrclk;
assign qsfp_2_tx_rst_2_int = qsfp_2_tx_reset;

assign qsfp_2_rx_clk_2_int = qsfp_2_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_2_rx_rst_2_reset_sync_inst (
    .clk(qsfp_2_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_2_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_2_phy_2_inst (
    .tx_clk(qsfp_2_tx_clk_2_int),
    .tx_rst(qsfp_2_tx_rst_2_int),
    .rx_clk(qsfp_2_rx_clk_2_int),
    .rx_rst(qsfp_2_rx_rst_2_int),
    .xgmii_txd(qsfp_2_txd_2_int),
    .xgmii_txc(qsfp_2_txc_2_int),
    .xgmii_rxd(qsfp_2_rxd_2_int),
    .xgmii_rxc(qsfp_2_rxc_2_int),
    .serdes_tx_data(qsfp_2_gt_txdata_2),
    .serdes_tx_hdr(qsfp_2_gt_txheader_2),
    .serdes_rx_data(qsfp_2_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_2_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_2_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_2_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_2_tx_clk_3_int = qsfp_2_gt_txusrclk;
assign qsfp_2_tx_rst_3_int = qsfp_2_tx_reset;

assign qsfp_2_rx_clk_3_int = qsfp_2_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_2_rx_rst_3_reset_sync_inst (
    .clk(qsfp_2_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_2_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_2_phy_3_inst (
    .tx_clk(qsfp_2_tx_clk_3_int),
    .tx_rst(qsfp_2_tx_rst_3_int),
    .rx_clk(qsfp_2_rx_clk_3_int),
    .rx_rst(qsfp_2_rx_rst_3_int),
    .xgmii_txd(qsfp_2_txd_3_int),
    .xgmii_txc(qsfp_2_txc_3_int),
    .xgmii_rxd(qsfp_2_rxd_3_int),
    .xgmii_rxc(qsfp_2_rxc_3_int),
    .serdes_tx_data(qsfp_2_gt_txdata_3),
    .serdes_tx_hdr(qsfp_2_gt_txheader_3),
    .serdes_rx_data(qsfp_2_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_2_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_2_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_2_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_2_tx_clk_4_int = qsfp_2_gt_txusrclk;
assign qsfp_2_tx_rst_4_int = qsfp_2_tx_reset;

assign qsfp_2_rx_clk_4_int = qsfp_2_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_2_rx_rst_4_reset_sync_inst (
    .clk(qsfp_2_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_2_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_2_phy_4_inst (
    .tx_clk(qsfp_2_tx_clk_4_int),
    .tx_rst(qsfp_2_tx_rst_4_int),
    .rx_clk(qsfp_2_rx_clk_4_int),
    .rx_rst(qsfp_2_rx_rst_4_int),
    .xgmii_txd(qsfp_2_txd_4_int),
    .xgmii_txc(qsfp_2_txc_4_int),
    .xgmii_rxd(qsfp_2_rxd_4_int),
    .xgmii_rxc(qsfp_2_rxc_4_int),
    .serdes_tx_data(qsfp_2_gt_txdata_4),
    .serdes_tx_hdr(qsfp_2_gt_txheader_4),
    .serdes_rx_data(qsfp_2_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_2_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_2_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_2_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 3
assign qsfp_3_resetl = 1'b1;

wire        qsfp_3_tx_clk_1_int;
wire        qsfp_3_tx_rst_1_int;
wire [63:0] qsfp_3_txd_1_int;
wire [7:0]  qsfp_3_txc_1_int;
wire        qsfp_3_rx_clk_1_int;
wire        qsfp_3_rx_rst_1_int;
wire [63:0] qsfp_3_rxd_1_int;
wire [7:0]  qsfp_3_rxc_1_int;
wire        qsfp_3_tx_clk_2_int;
wire        qsfp_3_tx_rst_2_int;
wire [63:0] qsfp_3_txd_2_int;
wire [7:0]  qsfp_3_txc_2_int;
wire        qsfp_3_rx_clk_2_int;
wire        qsfp_3_rx_rst_2_int;
wire [63:0] qsfp_3_rxd_2_int;
wire [7:0]  qsfp_3_rxc_2_int;
wire        qsfp_3_tx_clk_3_int;
wire        qsfp_3_tx_rst_3_int;
wire [63:0] qsfp_3_txd_3_int;
wire [7:0]  qsfp_3_txc_3_int;
wire        qsfp_3_rx_clk_3_int;
wire        qsfp_3_rx_rst_3_int;
wire [63:0] qsfp_3_rxd_3_int;
wire [7:0]  qsfp_3_rxc_3_int;
wire        qsfp_3_tx_clk_4_int;
wire        qsfp_3_tx_rst_4_int;
wire [63:0] qsfp_3_txd_4_int;
wire [7:0]  qsfp_3_txc_4_int;
wire        qsfp_3_rx_clk_4_int;
wire        qsfp_3_rx_rst_4_int;
wire [63:0] qsfp_3_rxd_4_int;
wire [7:0]  qsfp_3_rxc_4_int;

wire qsfp_3_rx_block_lock_1;
wire qsfp_3_rx_block_lock_2;
wire qsfp_3_rx_block_lock_3;
wire qsfp_3_rx_block_lock_4;

wire qsfp_3_mgt_refclk;

wire [3:0] qsfp_3_gt_txclkout;
wire qsfp_3_gt_txusrclk;

wire [3:0] qsfp_3_gt_rxclkout;
wire [3:0] qsfp_3_gt_rxusrclk;

wire qsfp_3_gt_reset_tx_done;
wire qsfp_3_gt_reset_rx_done;

wire [3:0] qsfp_3_gt_txprgdivresetdone;
wire [3:0] qsfp_3_gt_txpmaresetdone;
wire [3:0] qsfp_3_gt_rxprgdivresetdone;
wire [3:0] qsfp_3_gt_rxpmaresetdone;

wire qsfp_3_gt_tx_reset = ~((&qsfp_3_gt_txprgdivresetdone) & (&qsfp_3_gt_txpmaresetdone));
wire qsfp_3_gt_rx_reset = ~&qsfp_3_gt_rxpmaresetdone;

reg qsfp_3_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_3_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_3_mgt_refclk_inst (
    .I             (qsfp_3_mgt_refclk_p),
    .IB            (qsfp_3_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_3_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_3_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_3_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_3_gt_txclkout[0]),
    .O       (qsfp_3_gt_txusrclk)
);

always @(posedge qsfp_3_gt_txusrclk, posedge qsfp_3_gt_tx_reset) begin
    if (qsfp_3_gt_tx_reset) begin
        qsfp_3_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_3_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_3_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_3_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_3_gt_rxclkout[n]),
        .O       (qsfp_3_gt_rxusrclk[n])
    );

    always @(posedge qsfp_3_gt_rxusrclk[n], posedge qsfp_3_gt_rx_reset) begin
        if (qsfp_3_gt_rx_reset) begin
            qsfp_3_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_3_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_3_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_3_tx_rst_reset_sync_inst (
    .clk(qsfp_3_gt_txusrclk),
    .rst(~qsfp_3_gt_reset_tx_done),
    .out(qsfp_3_tx_reset)
);

wire [5:0] qsfp_3_gt_txheader_1;
wire [63:0] qsfp_3_gt_txdata_1;
wire qsfp_3_gt_rxgearboxslip_1;
wire [5:0] qsfp_3_gt_rxheader_1;
wire [1:0] qsfp_3_gt_rxheadervalid_1;
wire [63:0] qsfp_3_gt_rxdata_1;
wire [1:0] qsfp_3_gt_rxdatavalid_1;

wire [5:0] qsfp_3_gt_txheader_2;
wire [63:0] qsfp_3_gt_txdata_2;
wire qsfp_3_gt_rxgearboxslip_2;
wire [5:0] qsfp_3_gt_rxheader_2;
wire [1:0] qsfp_3_gt_rxheadervalid_2;
wire [63:0] qsfp_3_gt_rxdata_2;
wire [1:0] qsfp_3_gt_rxdatavalid_2;

wire [5:0] qsfp_3_gt_txheader_3;
wire [63:0] qsfp_3_gt_txdata_3;
wire qsfp_3_gt_rxgearboxslip_3;
wire [5:0] qsfp_3_gt_rxheader_3;
wire [1:0] qsfp_3_gt_rxheadervalid_3;
wire [63:0] qsfp_3_gt_rxdata_3;
wire [1:0] qsfp_3_gt_rxdatavalid_3;

wire [5:0] qsfp_3_gt_txheader_4;
wire [63:0] qsfp_3_gt_txdata_4;
wire qsfp_3_gt_rxgearboxslip_4;
wire [5:0] qsfp_3_gt_rxheader_4;
wire [1:0] qsfp_3_gt_rxheadervalid_4;
wire [63:0] qsfp_3_gt_rxdata_4;
wire [1:0] qsfp_3_gt_rxdatavalid_4;

gtwiz_qsfp_3
qsfp_3_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_3_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_3_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_3_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_3_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_3_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_3_rx_n[3], qsfp_3_rx_n[0], qsfp_3_rx_n[2], qsfp_3_rx_n[1]}),
    .gtyrxp_in({qsfp_3_rx_p[3], qsfp_3_rx_p[0], qsfp_3_rx_p[2], qsfp_3_rx_p[1]}),

    .rxusrclk_in(qsfp_3_gt_rxusrclk),
    .rxusrclk2_in(qsfp_3_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_3_gt_txdata_4, qsfp_3_gt_txdata_1, qsfp_3_gt_txdata_3, qsfp_3_gt_txdata_2}),
    .txheader_in({qsfp_3_gt_txheader_4, qsfp_3_gt_txheader_1, qsfp_3_gt_txheader_3, qsfp_3_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_3_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_3_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_3_tx_n[3], qsfp_3_tx_n[0], qsfp_3_tx_n[2], qsfp_3_tx_n[1]}),
    .gtytxp_out({qsfp_3_tx_p[3], qsfp_3_tx_p[0], qsfp_3_tx_p[2], qsfp_3_tx_p[1]}),

    .rxgearboxslip_in({qsfp_3_gt_rxgearboxslip_4, qsfp_3_gt_rxgearboxslip_1, qsfp_3_gt_rxgearboxslip_3, qsfp_3_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_3_gt_rxdata_4, qsfp_3_gt_rxdata_1, qsfp_3_gt_rxdata_3, qsfp_3_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_3_gt_rxdatavalid_4, qsfp_3_gt_rxdatavalid_1, qsfp_3_gt_rxdatavalid_3, qsfp_3_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_3_gt_rxheader_4, qsfp_3_gt_rxheader_1, qsfp_3_gt_rxheader_3, qsfp_3_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_3_gt_rxheadervalid_4, qsfp_3_gt_rxheadervalid_1, qsfp_3_gt_rxheadervalid_3, qsfp_3_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_3_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_3_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_3_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_3_gt_txclkout),
    .txpmaresetdone_out(qsfp_3_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_3_gt_txprgdivresetdone)
);

assign qsfp_3_tx_clk_1_int = qsfp_3_gt_txusrclk;
assign qsfp_3_tx_rst_1_int = qsfp_3_tx_reset;

assign qsfp_3_rx_clk_1_int = qsfp_3_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_3_rx_rst_1_reset_sync_inst (
    .clk(qsfp_3_rx_clk_1_int),
    .rst(~qsfp_3_gt_reset_rx_done),
    .out(qsfp_3_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_3_phy_1_inst (
    .tx_clk(qsfp_3_tx_clk_1_int),
    .tx_rst(qsfp_3_tx_rst_1_int),
    .rx_clk(qsfp_3_rx_clk_1_int),
    .rx_rst(qsfp_3_rx_rst_1_int),
    .xgmii_txd(qsfp_3_txd_1_int),
    .xgmii_txc(qsfp_3_txc_1_int),
    .xgmii_rxd(qsfp_3_rxd_1_int),
    .xgmii_rxc(qsfp_3_rxc_1_int),
    .serdes_tx_data(qsfp_3_gt_txdata_1),
    .serdes_tx_hdr(qsfp_3_gt_txheader_1),
    .serdes_rx_data(qsfp_3_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_3_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_3_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_3_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_3_tx_clk_2_int = qsfp_3_gt_txusrclk;
assign qsfp_3_tx_rst_2_int = qsfp_3_tx_reset;

assign qsfp_3_rx_clk_2_int = qsfp_3_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_3_rx_rst_2_reset_sync_inst (
    .clk(qsfp_3_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_3_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_3_phy_2_inst (
    .tx_clk(qsfp_3_tx_clk_2_int),
    .tx_rst(qsfp_3_tx_rst_2_int),
    .rx_clk(qsfp_3_rx_clk_2_int),
    .rx_rst(qsfp_3_rx_rst_2_int),
    .xgmii_txd(qsfp_3_txd_2_int),
    .xgmii_txc(qsfp_3_txc_2_int),
    .xgmii_rxd(qsfp_3_rxd_2_int),
    .xgmii_rxc(qsfp_3_rxc_2_int),
    .serdes_tx_data(qsfp_3_gt_txdata_2),
    .serdes_tx_hdr(qsfp_3_gt_txheader_2),
    .serdes_rx_data(qsfp_3_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_3_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_3_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_3_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_3_tx_clk_3_int = qsfp_3_gt_txusrclk;
assign qsfp_3_tx_rst_3_int = qsfp_3_tx_reset;

assign qsfp_3_rx_clk_3_int = qsfp_3_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_3_rx_rst_3_reset_sync_inst (
    .clk(qsfp_3_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_3_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_3_phy_3_inst (
    .tx_clk(qsfp_3_tx_clk_3_int),
    .tx_rst(qsfp_3_tx_rst_3_int),
    .rx_clk(qsfp_3_rx_clk_3_int),
    .rx_rst(qsfp_3_rx_rst_3_int),
    .xgmii_txd(qsfp_3_txd_3_int),
    .xgmii_txc(qsfp_3_txc_3_int),
    .xgmii_rxd(qsfp_3_rxd_3_int),
    .xgmii_rxc(qsfp_3_rxc_3_int),
    .serdes_tx_data(qsfp_3_gt_txdata_3),
    .serdes_tx_hdr(qsfp_3_gt_txheader_3),
    .serdes_rx_data(qsfp_3_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_3_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_3_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_3_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_3_tx_clk_4_int = qsfp_3_gt_txusrclk;
assign qsfp_3_tx_rst_4_int = qsfp_3_tx_reset;

assign qsfp_3_rx_clk_4_int = qsfp_3_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_3_rx_rst_4_reset_sync_inst (
    .clk(qsfp_3_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_3_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_3_phy_4_inst (
    .tx_clk(qsfp_3_tx_clk_4_int),
    .tx_rst(qsfp_3_tx_rst_4_int),
    .rx_clk(qsfp_3_rx_clk_4_int),
    .rx_rst(qsfp_3_rx_rst_4_int),
    .xgmii_txd(qsfp_3_txd_4_int),
    .xgmii_txc(qsfp_3_txc_4_int),
    .xgmii_rxd(qsfp_3_rxd_4_int),
    .xgmii_rxc(qsfp_3_rxc_4_int),
    .serdes_tx_data(qsfp_3_gt_txdata_4),
    .serdes_tx_hdr(qsfp_3_gt_txheader_4),
    .serdes_rx_data(qsfp_3_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_3_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_3_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_3_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 4
assign qsfp_4_resetl = 1'b1;

wire        qsfp_4_tx_clk_1_int;
wire        qsfp_4_tx_rst_1_int;
wire [63:0] qsfp_4_txd_1_int;
wire [7:0]  qsfp_4_txc_1_int;
wire        qsfp_4_rx_clk_1_int;
wire        qsfp_4_rx_rst_1_int;
wire [63:0] qsfp_4_rxd_1_int;
wire [7:0]  qsfp_4_rxc_1_int;
wire        qsfp_4_tx_clk_2_int;
wire        qsfp_4_tx_rst_2_int;
wire [63:0] qsfp_4_txd_2_int;
wire [7:0]  qsfp_4_txc_2_int;
wire        qsfp_4_rx_clk_2_int;
wire        qsfp_4_rx_rst_2_int;
wire [63:0] qsfp_4_rxd_2_int;
wire [7:0]  qsfp_4_rxc_2_int;
wire        qsfp_4_tx_clk_3_int;
wire        qsfp_4_tx_rst_3_int;
wire [63:0] qsfp_4_txd_3_int;
wire [7:0]  qsfp_4_txc_3_int;
wire        qsfp_4_rx_clk_3_int;
wire        qsfp_4_rx_rst_3_int;
wire [63:0] qsfp_4_rxd_3_int;
wire [7:0]  qsfp_4_rxc_3_int;
wire        qsfp_4_tx_clk_4_int;
wire        qsfp_4_tx_rst_4_int;
wire [63:0] qsfp_4_txd_4_int;
wire [7:0]  qsfp_4_txc_4_int;
wire        qsfp_4_rx_clk_4_int;
wire        qsfp_4_rx_rst_4_int;
wire [63:0] qsfp_4_rxd_4_int;
wire [7:0]  qsfp_4_rxc_4_int;

wire qsfp_4_rx_block_lock_1;
wire qsfp_4_rx_block_lock_2;
wire qsfp_4_rx_block_lock_3;
wire qsfp_4_rx_block_lock_4;

wire qsfp_4_mgt_refclk;

wire [3:0] qsfp_4_gt_txclkout;
wire qsfp_4_gt_txusrclk;

wire [3:0] qsfp_4_gt_rxclkout;
wire [3:0] qsfp_4_gt_rxusrclk;

wire qsfp_4_gt_reset_tx_done;
wire qsfp_4_gt_reset_rx_done;

wire [3:0] qsfp_4_gt_txprgdivresetdone;
wire [3:0] qsfp_4_gt_txpmaresetdone;
wire [3:0] qsfp_4_gt_rxprgdivresetdone;
wire [3:0] qsfp_4_gt_rxpmaresetdone;

wire qsfp_4_gt_tx_reset = ~((&qsfp_4_gt_txprgdivresetdone) & (&qsfp_4_gt_txpmaresetdone));
wire qsfp_4_gt_rx_reset = ~&qsfp_4_gt_rxpmaresetdone;

reg qsfp_4_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_4_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_4_mgt_refclk_inst (
    .I             (qsfp_4_mgt_refclk_p),
    .IB            (qsfp_4_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_4_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_4_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_4_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_4_gt_txclkout[0]),
    .O       (qsfp_4_gt_txusrclk)
);

always @(posedge qsfp_4_gt_txusrclk, posedge qsfp_4_gt_tx_reset) begin
    if (qsfp_4_gt_tx_reset) begin
        qsfp_4_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_4_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_4_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_4_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_4_gt_rxclkout[n]),
        .O       (qsfp_4_gt_rxusrclk[n])
    );

    always @(posedge qsfp_4_gt_rxusrclk[n], posedge qsfp_4_gt_rx_reset) begin
        if (qsfp_4_gt_rx_reset) begin
            qsfp_4_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_4_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_4_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_4_tx_rst_reset_sync_inst (
    .clk(qsfp_4_gt_txusrclk),
    .rst(~qsfp_4_gt_reset_tx_done),
    .out(qsfp_4_tx_reset)
);

wire [5:0] qsfp_4_gt_txheader_1;
wire [63:0] qsfp_4_gt_txdata_1;
wire qsfp_4_gt_rxgearboxslip_1;
wire [5:0] qsfp_4_gt_rxheader_1;
wire [1:0] qsfp_4_gt_rxheadervalid_1;
wire [63:0] qsfp_4_gt_rxdata_1;
wire [1:0] qsfp_4_gt_rxdatavalid_1;

wire [5:0] qsfp_4_gt_txheader_2;
wire [63:0] qsfp_4_gt_txdata_2;
wire qsfp_4_gt_rxgearboxslip_2;
wire [5:0] qsfp_4_gt_rxheader_2;
wire [1:0] qsfp_4_gt_rxheadervalid_2;
wire [63:0] qsfp_4_gt_rxdata_2;
wire [1:0] qsfp_4_gt_rxdatavalid_2;

wire [5:0] qsfp_4_gt_txheader_3;
wire [63:0] qsfp_4_gt_txdata_3;
wire qsfp_4_gt_rxgearboxslip_3;
wire [5:0] qsfp_4_gt_rxheader_3;
wire [1:0] qsfp_4_gt_rxheadervalid_3;
wire [63:0] qsfp_4_gt_rxdata_3;
wire [1:0] qsfp_4_gt_rxdatavalid_3;

wire [5:0] qsfp_4_gt_txheader_4;
wire [63:0] qsfp_4_gt_txdata_4;
wire qsfp_4_gt_rxgearboxslip_4;
wire [5:0] qsfp_4_gt_rxheader_4;
wire [1:0] qsfp_4_gt_rxheadervalid_4;
wire [63:0] qsfp_4_gt_rxdata_4;
wire [1:0] qsfp_4_gt_rxdatavalid_4;

gtwiz_qsfp_4
qsfp_4_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_4_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_4_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_4_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_4_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_4_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_4_rx_n[3], qsfp_4_rx_n[0], qsfp_4_rx_n[2], qsfp_4_rx_n[1]}),
    .gtyrxp_in({qsfp_4_rx_p[3], qsfp_4_rx_p[0], qsfp_4_rx_p[2], qsfp_4_rx_p[1]}),

    .rxusrclk_in(qsfp_4_gt_rxusrclk),
    .rxusrclk2_in(qsfp_4_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_4_gt_txdata_4, qsfp_4_gt_txdata_1, qsfp_4_gt_txdata_3, qsfp_4_gt_txdata_2}),
    .txheader_in({qsfp_4_gt_txheader_4, qsfp_4_gt_txheader_1, qsfp_4_gt_txheader_3, qsfp_4_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_4_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_4_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_4_tx_n[3], qsfp_4_tx_n[0], qsfp_4_tx_n[2], qsfp_4_tx_n[1]}),
    .gtytxp_out({qsfp_4_tx_p[3], qsfp_4_tx_p[0], qsfp_4_tx_p[2], qsfp_4_tx_p[1]}),

    .rxgearboxslip_in({qsfp_4_gt_rxgearboxslip_4, qsfp_4_gt_rxgearboxslip_1, qsfp_4_gt_rxgearboxslip_3, qsfp_4_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_4_gt_rxdata_4, qsfp_4_gt_rxdata_1, qsfp_4_gt_rxdata_3, qsfp_4_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_4_gt_rxdatavalid_4, qsfp_4_gt_rxdatavalid_1, qsfp_4_gt_rxdatavalid_3, qsfp_4_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_4_gt_rxheader_4, qsfp_4_gt_rxheader_1, qsfp_4_gt_rxheader_3, qsfp_4_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_4_gt_rxheadervalid_4, qsfp_4_gt_rxheadervalid_1, qsfp_4_gt_rxheadervalid_3, qsfp_4_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_4_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_4_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_4_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_4_gt_txclkout),
    .txpmaresetdone_out(qsfp_4_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_4_gt_txprgdivresetdone)
);

assign qsfp_4_tx_clk_1_int = qsfp_4_gt_txusrclk;
assign qsfp_4_tx_rst_1_int = qsfp_4_tx_reset;

assign qsfp_4_rx_clk_1_int = qsfp_4_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_4_rx_rst_1_reset_sync_inst (
    .clk(qsfp_4_rx_clk_1_int),
    .rst(~qsfp_4_gt_reset_rx_done),
    .out(qsfp_4_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_4_phy_1_inst (
    .tx_clk(qsfp_4_tx_clk_1_int),
    .tx_rst(qsfp_4_tx_rst_1_int),
    .rx_clk(qsfp_4_rx_clk_1_int),
    .rx_rst(qsfp_4_rx_rst_1_int),
    .xgmii_txd(qsfp_4_txd_1_int),
    .xgmii_txc(qsfp_4_txc_1_int),
    .xgmii_rxd(qsfp_4_rxd_1_int),
    .xgmii_rxc(qsfp_4_rxc_1_int),
    .serdes_tx_data(qsfp_4_gt_txdata_1),
    .serdes_tx_hdr(qsfp_4_gt_txheader_1),
    .serdes_rx_data(qsfp_4_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_4_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_4_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_4_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_4_tx_clk_2_int = qsfp_4_gt_txusrclk;
assign qsfp_4_tx_rst_2_int = qsfp_4_tx_reset;

assign qsfp_4_rx_clk_2_int = qsfp_4_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_4_rx_rst_2_reset_sync_inst (
    .clk(qsfp_4_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_4_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_4_phy_2_inst (
    .tx_clk(qsfp_4_tx_clk_2_int),
    .tx_rst(qsfp_4_tx_rst_2_int),
    .rx_clk(qsfp_4_rx_clk_2_int),
    .rx_rst(qsfp_4_rx_rst_2_int),
    .xgmii_txd(qsfp_4_txd_2_int),
    .xgmii_txc(qsfp_4_txc_2_int),
    .xgmii_rxd(qsfp_4_rxd_2_int),
    .xgmii_rxc(qsfp_4_rxc_2_int),
    .serdes_tx_data(qsfp_4_gt_txdata_2),
    .serdes_tx_hdr(qsfp_4_gt_txheader_2),
    .serdes_rx_data(qsfp_4_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_4_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_4_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_4_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_4_tx_clk_3_int = qsfp_4_gt_txusrclk;
assign qsfp_4_tx_rst_3_int = qsfp_4_tx_reset;

assign qsfp_4_rx_clk_3_int = qsfp_4_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_4_rx_rst_3_reset_sync_inst (
    .clk(qsfp_4_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_4_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_4_phy_3_inst (
    .tx_clk(qsfp_4_tx_clk_3_int),
    .tx_rst(qsfp_4_tx_rst_3_int),
    .rx_clk(qsfp_4_rx_clk_3_int),
    .rx_rst(qsfp_4_rx_rst_3_int),
    .xgmii_txd(qsfp_4_txd_3_int),
    .xgmii_txc(qsfp_4_txc_3_int),
    .xgmii_rxd(qsfp_4_rxd_3_int),
    .xgmii_rxc(qsfp_4_rxc_3_int),
    .serdes_tx_data(qsfp_4_gt_txdata_3),
    .serdes_tx_hdr(qsfp_4_gt_txheader_3),
    .serdes_rx_data(qsfp_4_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_4_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_4_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_4_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_4_tx_clk_4_int = qsfp_4_gt_txusrclk;
assign qsfp_4_tx_rst_4_int = qsfp_4_tx_reset;

assign qsfp_4_rx_clk_4_int = qsfp_4_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_4_rx_rst_4_reset_sync_inst (
    .clk(qsfp_4_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_4_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_4_phy_4_inst (
    .tx_clk(qsfp_4_tx_clk_4_int),
    .tx_rst(qsfp_4_tx_rst_4_int),
    .rx_clk(qsfp_4_rx_clk_4_int),
    .rx_rst(qsfp_4_rx_rst_4_int),
    .xgmii_txd(qsfp_4_txd_4_int),
    .xgmii_txc(qsfp_4_txc_4_int),
    .xgmii_rxd(qsfp_4_rxd_4_int),
    .xgmii_rxc(qsfp_4_rxc_4_int),
    .serdes_tx_data(qsfp_4_gt_txdata_4),
    .serdes_tx_hdr(qsfp_4_gt_txheader_4),
    .serdes_rx_data(qsfp_4_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_4_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_4_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_4_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 5
assign qsfp_5_resetl = 1'b1;

wire        qsfp_5_tx_clk_1_int;
wire        qsfp_5_tx_rst_1_int;
wire [63:0] qsfp_5_txd_1_int;
wire [7:0]  qsfp_5_txc_1_int;
wire        qsfp_5_rx_clk_1_int;
wire        qsfp_5_rx_rst_1_int;
wire [63:0] qsfp_5_rxd_1_int;
wire [7:0]  qsfp_5_rxc_1_int;
wire        qsfp_5_tx_clk_2_int;
wire        qsfp_5_tx_rst_2_int;
wire [63:0] qsfp_5_txd_2_int;
wire [7:0]  qsfp_5_txc_2_int;
wire        qsfp_5_rx_clk_2_int;
wire        qsfp_5_rx_rst_2_int;
wire [63:0] qsfp_5_rxd_2_int;
wire [7:0]  qsfp_5_rxc_2_int;
wire        qsfp_5_tx_clk_3_int;
wire        qsfp_5_tx_rst_3_int;
wire [63:0] qsfp_5_txd_3_int;
wire [7:0]  qsfp_5_txc_3_int;
wire        qsfp_5_rx_clk_3_int;
wire        qsfp_5_rx_rst_3_int;
wire [63:0] qsfp_5_rxd_3_int;
wire [7:0]  qsfp_5_rxc_3_int;
wire        qsfp_5_tx_clk_4_int;
wire        qsfp_5_tx_rst_4_int;
wire [63:0] qsfp_5_txd_4_int;
wire [7:0]  qsfp_5_txc_4_int;
wire        qsfp_5_rx_clk_4_int;
wire        qsfp_5_rx_rst_4_int;
wire [63:0] qsfp_5_rxd_4_int;
wire [7:0]  qsfp_5_rxc_4_int;

wire qsfp_5_rx_block_lock_1;
wire qsfp_5_rx_block_lock_2;
wire qsfp_5_rx_block_lock_3;
wire qsfp_5_rx_block_lock_4;

wire qsfp_5_mgt_refclk;

wire [3:0] qsfp_5_gt_txclkout;
wire qsfp_5_gt_txusrclk;

wire [3:0] qsfp_5_gt_rxclkout;
wire [3:0] qsfp_5_gt_rxusrclk;

wire qsfp_5_gt_reset_tx_done;
wire qsfp_5_gt_reset_rx_done;

wire [3:0] qsfp_5_gt_txprgdivresetdone;
wire [3:0] qsfp_5_gt_txpmaresetdone;
wire [3:0] qsfp_5_gt_rxprgdivresetdone;
wire [3:0] qsfp_5_gt_rxpmaresetdone;

wire qsfp_5_gt_tx_reset = ~((&qsfp_5_gt_txprgdivresetdone) & (&qsfp_5_gt_txpmaresetdone));
wire qsfp_5_gt_rx_reset = ~&qsfp_5_gt_rxpmaresetdone;

reg qsfp_5_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_5_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_5_mgt_refclk_inst (
    .I             (qsfp_5_mgt_refclk_p),
    .IB            (qsfp_5_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_5_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_5_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_5_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_5_gt_txclkout[0]),
    .O       (qsfp_5_gt_txusrclk)
);

always @(posedge qsfp_5_gt_txusrclk, posedge qsfp_5_gt_tx_reset) begin
    if (qsfp_5_gt_tx_reset) begin
        qsfp_5_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_5_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_5_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_5_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_5_gt_rxclkout[n]),
        .O       (qsfp_5_gt_rxusrclk[n])
    );

    always @(posedge qsfp_5_gt_rxusrclk[n], posedge qsfp_5_gt_rx_reset) begin
        if (qsfp_5_gt_rx_reset) begin
            qsfp_5_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_5_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_5_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_5_tx_rst_reset_sync_inst (
    .clk(qsfp_5_gt_txusrclk),
    .rst(~qsfp_5_gt_reset_tx_done),
    .out(qsfp_5_tx_reset)
);

wire [5:0] qsfp_5_gt_txheader_1;
wire [63:0] qsfp_5_gt_txdata_1;
wire qsfp_5_gt_rxgearboxslip_1;
wire [5:0] qsfp_5_gt_rxheader_1;
wire [1:0] qsfp_5_gt_rxheadervalid_1;
wire [63:0] qsfp_5_gt_rxdata_1;
wire [1:0] qsfp_5_gt_rxdatavalid_1;

wire [5:0] qsfp_5_gt_txheader_2;
wire [63:0] qsfp_5_gt_txdata_2;
wire qsfp_5_gt_rxgearboxslip_2;
wire [5:0] qsfp_5_gt_rxheader_2;
wire [1:0] qsfp_5_gt_rxheadervalid_2;
wire [63:0] qsfp_5_gt_rxdata_2;
wire [1:0] qsfp_5_gt_rxdatavalid_2;

wire [5:0] qsfp_5_gt_txheader_3;
wire [63:0] qsfp_5_gt_txdata_3;
wire qsfp_5_gt_rxgearboxslip_3;
wire [5:0] qsfp_5_gt_rxheader_3;
wire [1:0] qsfp_5_gt_rxheadervalid_3;
wire [63:0] qsfp_5_gt_rxdata_3;
wire [1:0] qsfp_5_gt_rxdatavalid_3;

wire [5:0] qsfp_5_gt_txheader_4;
wire [63:0] qsfp_5_gt_txdata_4;
wire qsfp_5_gt_rxgearboxslip_4;
wire [5:0] qsfp_5_gt_rxheader_4;
wire [1:0] qsfp_5_gt_rxheadervalid_4;
wire [63:0] qsfp_5_gt_rxdata_4;
wire [1:0] qsfp_5_gt_rxdatavalid_4;

gtwiz_qsfp_5
qsfp_5_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_5_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_5_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_5_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_5_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_5_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_5_rx_n[0], qsfp_5_rx_n[3], qsfp_5_rx_n[2], qsfp_5_rx_n[1]}),
    .gtyrxp_in({qsfp_5_rx_p[0], qsfp_5_rx_p[3], qsfp_5_rx_p[2], qsfp_5_rx_p[1]}),

    .rxusrclk_in(qsfp_5_gt_rxusrclk),
    .rxusrclk2_in(qsfp_5_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_5_gt_txdata_1, qsfp_5_gt_txdata_4, qsfp_5_gt_txdata_3, qsfp_5_gt_txdata_2}),
    .txheader_in({qsfp_5_gt_txheader_1, qsfp_5_gt_txheader_4, qsfp_5_gt_txheader_3, qsfp_5_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_5_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_5_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_5_tx_n[0], qsfp_5_tx_n[3], qsfp_5_tx_n[2], qsfp_5_tx_n[1]}),
    .gtytxp_out({qsfp_5_tx_p[0], qsfp_5_tx_p[3], qsfp_5_tx_p[2], qsfp_5_tx_p[1]}),

    .rxgearboxslip_in({qsfp_5_gt_rxgearboxslip_1, qsfp_5_gt_rxgearboxslip_4, qsfp_5_gt_rxgearboxslip_3, qsfp_5_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_5_gt_rxdata_1, qsfp_5_gt_rxdata_4, qsfp_5_gt_rxdata_3, qsfp_5_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_5_gt_rxdatavalid_1, qsfp_5_gt_rxdatavalid_4, qsfp_5_gt_rxdatavalid_3, qsfp_5_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_5_gt_rxheader_1, qsfp_5_gt_rxheader_4, qsfp_5_gt_rxheader_3, qsfp_5_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_5_gt_rxheadervalid_1, qsfp_5_gt_rxheadervalid_4, qsfp_5_gt_rxheadervalid_3, qsfp_5_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_5_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_5_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_5_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_5_gt_txclkout),
    .txpmaresetdone_out(qsfp_5_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_5_gt_txprgdivresetdone)
);

assign qsfp_5_tx_clk_1_int = qsfp_5_gt_txusrclk;
assign qsfp_5_tx_rst_1_int = qsfp_5_tx_reset;

assign qsfp_5_rx_clk_1_int = qsfp_5_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_5_rx_rst_1_reset_sync_inst (
    .clk(qsfp_5_rx_clk_1_int),
    .rst(~qsfp_5_gt_reset_rx_done),
    .out(qsfp_5_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_5_phy_1_inst (
    .tx_clk(qsfp_5_tx_clk_1_int),
    .tx_rst(qsfp_5_tx_rst_1_int),
    .rx_clk(qsfp_5_rx_clk_1_int),
    .rx_rst(qsfp_5_rx_rst_1_int),
    .xgmii_txd(qsfp_5_txd_1_int),
    .xgmii_txc(qsfp_5_txc_1_int),
    .xgmii_rxd(qsfp_5_rxd_1_int),
    .xgmii_rxc(qsfp_5_rxc_1_int),
    .serdes_tx_data(qsfp_5_gt_txdata_1),
    .serdes_tx_hdr(qsfp_5_gt_txheader_1),
    .serdes_rx_data(qsfp_5_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_5_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_5_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_5_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_5_tx_clk_2_int = qsfp_5_gt_txusrclk;
assign qsfp_5_tx_rst_2_int = qsfp_5_tx_reset;

assign qsfp_5_rx_clk_2_int = qsfp_5_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_5_rx_rst_2_reset_sync_inst (
    .clk(qsfp_5_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_5_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_5_phy_2_inst (
    .tx_clk(qsfp_5_tx_clk_2_int),
    .tx_rst(qsfp_5_tx_rst_2_int),
    .rx_clk(qsfp_5_rx_clk_2_int),
    .rx_rst(qsfp_5_rx_rst_2_int),
    .xgmii_txd(qsfp_5_txd_2_int),
    .xgmii_txc(qsfp_5_txc_2_int),
    .xgmii_rxd(qsfp_5_rxd_2_int),
    .xgmii_rxc(qsfp_5_rxc_2_int),
    .serdes_tx_data(qsfp_5_gt_txdata_2),
    .serdes_tx_hdr(qsfp_5_gt_txheader_2),
    .serdes_rx_data(qsfp_5_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_5_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_5_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_5_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_5_tx_clk_3_int = qsfp_5_gt_txusrclk;
assign qsfp_5_tx_rst_3_int = qsfp_5_tx_reset;

assign qsfp_5_rx_clk_3_int = qsfp_5_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_5_rx_rst_3_reset_sync_inst (
    .clk(qsfp_5_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_5_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_5_phy_3_inst (
    .tx_clk(qsfp_5_tx_clk_3_int),
    .tx_rst(qsfp_5_tx_rst_3_int),
    .rx_clk(qsfp_5_rx_clk_3_int),
    .rx_rst(qsfp_5_rx_rst_3_int),
    .xgmii_txd(qsfp_5_txd_3_int),
    .xgmii_txc(qsfp_5_txc_3_int),
    .xgmii_rxd(qsfp_5_rxd_3_int),
    .xgmii_rxc(qsfp_5_rxc_3_int),
    .serdes_tx_data(qsfp_5_gt_txdata_3),
    .serdes_tx_hdr(qsfp_5_gt_txheader_3),
    .serdes_rx_data(qsfp_5_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_5_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_5_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_5_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_5_tx_clk_4_int = qsfp_5_gt_txusrclk;
assign qsfp_5_tx_rst_4_int = qsfp_5_tx_reset;

assign qsfp_5_rx_clk_4_int = qsfp_5_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_5_rx_rst_4_reset_sync_inst (
    .clk(qsfp_5_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_5_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_5_phy_4_inst (
    .tx_clk(qsfp_5_tx_clk_4_int),
    .tx_rst(qsfp_5_tx_rst_4_int),
    .rx_clk(qsfp_5_rx_clk_4_int),
    .rx_rst(qsfp_5_rx_rst_4_int),
    .xgmii_txd(qsfp_5_txd_4_int),
    .xgmii_txc(qsfp_5_txc_4_int),
    .xgmii_rxd(qsfp_5_rxd_4_int),
    .xgmii_rxc(qsfp_5_rxc_4_int),
    .serdes_tx_data(qsfp_5_gt_txdata_4),
    .serdes_tx_hdr(qsfp_5_gt_txheader_4),
    .serdes_rx_data(qsfp_5_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_5_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_5_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_5_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 6
assign qsfp_6_resetl = 1'b1;

wire        qsfp_6_tx_clk_1_int;
wire        qsfp_6_tx_rst_1_int;
wire [63:0] qsfp_6_txd_1_int;
wire [7:0]  qsfp_6_txc_1_int;
wire        qsfp_6_rx_clk_1_int;
wire        qsfp_6_rx_rst_1_int;
wire [63:0] qsfp_6_rxd_1_int;
wire [7:0]  qsfp_6_rxc_1_int;
wire        qsfp_6_tx_clk_2_int;
wire        qsfp_6_tx_rst_2_int;
wire [63:0] qsfp_6_txd_2_int;
wire [7:0]  qsfp_6_txc_2_int;
wire        qsfp_6_rx_clk_2_int;
wire        qsfp_6_rx_rst_2_int;
wire [63:0] qsfp_6_rxd_2_int;
wire [7:0]  qsfp_6_rxc_2_int;
wire        qsfp_6_tx_clk_3_int;
wire        qsfp_6_tx_rst_3_int;
wire [63:0] qsfp_6_txd_3_int;
wire [7:0]  qsfp_6_txc_3_int;
wire        qsfp_6_rx_clk_3_int;
wire        qsfp_6_rx_rst_3_int;
wire [63:0] qsfp_6_rxd_3_int;
wire [7:0]  qsfp_6_rxc_3_int;
wire        qsfp_6_tx_clk_4_int;
wire        qsfp_6_tx_rst_4_int;
wire [63:0] qsfp_6_txd_4_int;
wire [7:0]  qsfp_6_txc_4_int;
wire        qsfp_6_rx_clk_4_int;
wire        qsfp_6_rx_rst_4_int;
wire [63:0] qsfp_6_rxd_4_int;
wire [7:0]  qsfp_6_rxc_4_int;

wire qsfp_6_rx_block_lock_1;
wire qsfp_6_rx_block_lock_2;
wire qsfp_6_rx_block_lock_3;
wire qsfp_6_rx_block_lock_4;

wire qsfp_6_mgt_refclk;

wire [3:0] qsfp_6_gt_txclkout;
wire qsfp_6_gt_txusrclk;

wire [3:0] qsfp_6_gt_rxclkout;
wire [3:0] qsfp_6_gt_rxusrclk;

wire qsfp_6_gt_reset_tx_done;
wire qsfp_6_gt_reset_rx_done;

wire [3:0] qsfp_6_gt_txprgdivresetdone;
wire [3:0] qsfp_6_gt_txpmaresetdone;
wire [3:0] qsfp_6_gt_rxprgdivresetdone;
wire [3:0] qsfp_6_gt_rxpmaresetdone;

wire qsfp_6_gt_tx_reset = ~((&qsfp_6_gt_txprgdivresetdone) & (&qsfp_6_gt_txpmaresetdone));
wire qsfp_6_gt_rx_reset = ~&qsfp_6_gt_rxpmaresetdone;

reg qsfp_6_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_6_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_6_mgt_refclk_inst (
    .I             (qsfp_6_mgt_refclk_p),
    .IB            (qsfp_6_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_6_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_6_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_6_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_6_gt_txclkout[0]),
    .O       (qsfp_6_gt_txusrclk)
);

always @(posedge qsfp_6_gt_txusrclk, posedge qsfp_6_gt_tx_reset) begin
    if (qsfp_6_gt_tx_reset) begin
        qsfp_6_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_6_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_6_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_6_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_6_gt_rxclkout[n]),
        .O       (qsfp_6_gt_rxusrclk[n])
    );

    always @(posedge qsfp_6_gt_rxusrclk[n], posedge qsfp_6_gt_rx_reset) begin
        if (qsfp_6_gt_rx_reset) begin
            qsfp_6_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_6_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_6_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_6_tx_rst_reset_sync_inst (
    .clk(qsfp_6_gt_txusrclk),
    .rst(~qsfp_6_gt_reset_tx_done),
    .out(qsfp_6_tx_reset)
);

wire [5:0] qsfp_6_gt_txheader_1;
wire [63:0] qsfp_6_gt_txdata_1;
wire qsfp_6_gt_rxgearboxslip_1;
wire [5:0] qsfp_6_gt_rxheader_1;
wire [1:0] qsfp_6_gt_rxheadervalid_1;
wire [63:0] qsfp_6_gt_rxdata_1;
wire [1:0] qsfp_6_gt_rxdatavalid_1;

wire [5:0] qsfp_6_gt_txheader_2;
wire [63:0] qsfp_6_gt_txdata_2;
wire qsfp_6_gt_rxgearboxslip_2;
wire [5:0] qsfp_6_gt_rxheader_2;
wire [1:0] qsfp_6_gt_rxheadervalid_2;
wire [63:0] qsfp_6_gt_rxdata_2;
wire [1:0] qsfp_6_gt_rxdatavalid_2;

wire [5:0] qsfp_6_gt_txheader_3;
wire [63:0] qsfp_6_gt_txdata_3;
wire qsfp_6_gt_rxgearboxslip_3;
wire [5:0] qsfp_6_gt_rxheader_3;
wire [1:0] qsfp_6_gt_rxheadervalid_3;
wire [63:0] qsfp_6_gt_rxdata_3;
wire [1:0] qsfp_6_gt_rxdatavalid_3;

wire [5:0] qsfp_6_gt_txheader_4;
wire [63:0] qsfp_6_gt_txdata_4;
wire qsfp_6_gt_rxgearboxslip_4;
wire [5:0] qsfp_6_gt_rxheader_4;
wire [1:0] qsfp_6_gt_rxheadervalid_4;
wire [63:0] qsfp_6_gt_rxdata_4;
wire [1:0] qsfp_6_gt_rxdatavalid_4;

gtwiz_qsfp_6
qsfp_6_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_6_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_6_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_6_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_6_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_6_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_6_rx_n[3], qsfp_6_rx_n[0], qsfp_6_rx_n[2], qsfp_6_rx_n[1]}),
    .gtyrxp_in({qsfp_6_rx_p[3], qsfp_6_rx_p[0], qsfp_6_rx_p[2], qsfp_6_rx_p[1]}),

    .rxusrclk_in(qsfp_6_gt_rxusrclk),
    .rxusrclk2_in(qsfp_6_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_6_gt_txdata_4, qsfp_6_gt_txdata_1, qsfp_6_gt_txdata_3, qsfp_6_gt_txdata_2}),
    .txheader_in({qsfp_6_gt_txheader_4, qsfp_6_gt_txheader_1, qsfp_6_gt_txheader_3, qsfp_6_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_6_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_6_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_6_tx_n[3], qsfp_6_tx_n[0], qsfp_6_tx_n[2], qsfp_6_tx_n[1]}),
    .gtytxp_out({qsfp_6_tx_p[3], qsfp_6_tx_p[0], qsfp_6_tx_p[2], qsfp_6_tx_p[1]}),

    .rxgearboxslip_in({qsfp_6_gt_rxgearboxslip_4, qsfp_6_gt_rxgearboxslip_1, qsfp_6_gt_rxgearboxslip_3, qsfp_6_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_6_gt_rxdata_4, qsfp_6_gt_rxdata_1, qsfp_6_gt_rxdata_3, qsfp_6_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_6_gt_rxdatavalid_4, qsfp_6_gt_rxdatavalid_1, qsfp_6_gt_rxdatavalid_3, qsfp_6_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_6_gt_rxheader_4, qsfp_6_gt_rxheader_1, qsfp_6_gt_rxheader_3, qsfp_6_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_6_gt_rxheadervalid_4, qsfp_6_gt_rxheadervalid_1, qsfp_6_gt_rxheadervalid_3, qsfp_6_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_6_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_6_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_6_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_6_gt_txclkout),
    .txpmaresetdone_out(qsfp_6_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_6_gt_txprgdivresetdone)
);

assign qsfp_6_tx_clk_1_int = qsfp_6_gt_txusrclk;
assign qsfp_6_tx_rst_1_int = qsfp_6_tx_reset;

assign qsfp_6_rx_clk_1_int = qsfp_6_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_6_rx_rst_1_reset_sync_inst (
    .clk(qsfp_6_rx_clk_1_int),
    .rst(~qsfp_6_gt_reset_rx_done),
    .out(qsfp_6_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_6_phy_1_inst (
    .tx_clk(qsfp_6_tx_clk_1_int),
    .tx_rst(qsfp_6_tx_rst_1_int),
    .rx_clk(qsfp_6_rx_clk_1_int),
    .rx_rst(qsfp_6_rx_rst_1_int),
    .xgmii_txd(qsfp_6_txd_1_int),
    .xgmii_txc(qsfp_6_txc_1_int),
    .xgmii_rxd(qsfp_6_rxd_1_int),
    .xgmii_rxc(qsfp_6_rxc_1_int),
    .serdes_tx_data(qsfp_6_gt_txdata_1),
    .serdes_tx_hdr(qsfp_6_gt_txheader_1),
    .serdes_rx_data(qsfp_6_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_6_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_6_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_6_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_6_tx_clk_2_int = qsfp_6_gt_txusrclk;
assign qsfp_6_tx_rst_2_int = qsfp_6_tx_reset;

assign qsfp_6_rx_clk_2_int = qsfp_6_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_6_rx_rst_2_reset_sync_inst (
    .clk(qsfp_6_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_6_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_6_phy_2_inst (
    .tx_clk(qsfp_6_tx_clk_2_int),
    .tx_rst(qsfp_6_tx_rst_2_int),
    .rx_clk(qsfp_6_rx_clk_2_int),
    .rx_rst(qsfp_6_rx_rst_2_int),
    .xgmii_txd(qsfp_6_txd_2_int),
    .xgmii_txc(qsfp_6_txc_2_int),
    .xgmii_rxd(qsfp_6_rxd_2_int),
    .xgmii_rxc(qsfp_6_rxc_2_int),
    .serdes_tx_data(qsfp_6_gt_txdata_2),
    .serdes_tx_hdr(qsfp_6_gt_txheader_2),
    .serdes_rx_data(qsfp_6_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_6_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_6_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_6_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_6_tx_clk_3_int = qsfp_6_gt_txusrclk;
assign qsfp_6_tx_rst_3_int = qsfp_6_tx_reset;

assign qsfp_6_rx_clk_3_int = qsfp_6_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_6_rx_rst_3_reset_sync_inst (
    .clk(qsfp_6_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_6_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_6_phy_3_inst (
    .tx_clk(qsfp_6_tx_clk_3_int),
    .tx_rst(qsfp_6_tx_rst_3_int),
    .rx_clk(qsfp_6_rx_clk_3_int),
    .rx_rst(qsfp_6_rx_rst_3_int),
    .xgmii_txd(qsfp_6_txd_3_int),
    .xgmii_txc(qsfp_6_txc_3_int),
    .xgmii_rxd(qsfp_6_rxd_3_int),
    .xgmii_rxc(qsfp_6_rxc_3_int),
    .serdes_tx_data(qsfp_6_gt_txdata_3),
    .serdes_tx_hdr(qsfp_6_gt_txheader_3),
    .serdes_rx_data(qsfp_6_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_6_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_6_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_6_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_6_tx_clk_4_int = qsfp_6_gt_txusrclk;
assign qsfp_6_tx_rst_4_int = qsfp_6_tx_reset;

assign qsfp_6_rx_clk_4_int = qsfp_6_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_6_rx_rst_4_reset_sync_inst (
    .clk(qsfp_6_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_6_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_6_phy_4_inst (
    .tx_clk(qsfp_6_tx_clk_4_int),
    .tx_rst(qsfp_6_tx_rst_4_int),
    .rx_clk(qsfp_6_rx_clk_4_int),
    .rx_rst(qsfp_6_rx_rst_4_int),
    .xgmii_txd(qsfp_6_txd_4_int),
    .xgmii_txc(qsfp_6_txc_4_int),
    .xgmii_rxd(qsfp_6_rxd_4_int),
    .xgmii_rxc(qsfp_6_rxc_4_int),
    .serdes_tx_data(qsfp_6_gt_txdata_4),
    .serdes_tx_hdr(qsfp_6_gt_txheader_4),
    .serdes_rx_data(qsfp_6_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_6_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_6_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_6_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 7
assign qsfp_7_resetl = 1'b1;

wire        qsfp_7_tx_clk_1_int;
wire        qsfp_7_tx_rst_1_int;
wire [63:0] qsfp_7_txd_1_int;
wire [7:0]  qsfp_7_txc_1_int;
wire        qsfp_7_rx_clk_1_int;
wire        qsfp_7_rx_rst_1_int;
wire [63:0] qsfp_7_rxd_1_int;
wire [7:0]  qsfp_7_rxc_1_int;
wire        qsfp_7_tx_clk_2_int;
wire        qsfp_7_tx_rst_2_int;
wire [63:0] qsfp_7_txd_2_int;
wire [7:0]  qsfp_7_txc_2_int;
wire        qsfp_7_rx_clk_2_int;
wire        qsfp_7_rx_rst_2_int;
wire [63:0] qsfp_7_rxd_2_int;
wire [7:0]  qsfp_7_rxc_2_int;
wire        qsfp_7_tx_clk_3_int;
wire        qsfp_7_tx_rst_3_int;
wire [63:0] qsfp_7_txd_3_int;
wire [7:0]  qsfp_7_txc_3_int;
wire        qsfp_7_rx_clk_3_int;
wire        qsfp_7_rx_rst_3_int;
wire [63:0] qsfp_7_rxd_3_int;
wire [7:0]  qsfp_7_rxc_3_int;
wire        qsfp_7_tx_clk_4_int;
wire        qsfp_7_tx_rst_4_int;
wire [63:0] qsfp_7_txd_4_int;
wire [7:0]  qsfp_7_txc_4_int;
wire        qsfp_7_rx_clk_4_int;
wire        qsfp_7_rx_rst_4_int;
wire [63:0] qsfp_7_rxd_4_int;
wire [7:0]  qsfp_7_rxc_4_int;

wire qsfp_7_rx_block_lock_1;
wire qsfp_7_rx_block_lock_2;
wire qsfp_7_rx_block_lock_3;
wire qsfp_7_rx_block_lock_4;

wire qsfp_7_mgt_refclk;

wire [3:0] qsfp_7_gt_txclkout;
wire qsfp_7_gt_txusrclk;

wire [3:0] qsfp_7_gt_rxclkout;
wire [3:0] qsfp_7_gt_rxusrclk;

wire qsfp_7_gt_reset_tx_done;
wire qsfp_7_gt_reset_rx_done;

wire [3:0] qsfp_7_gt_txprgdivresetdone;
wire [3:0] qsfp_7_gt_txpmaresetdone;
wire [3:0] qsfp_7_gt_rxprgdivresetdone;
wire [3:0] qsfp_7_gt_rxpmaresetdone;

wire qsfp_7_gt_tx_reset = ~((&qsfp_7_gt_txprgdivresetdone) & (&qsfp_7_gt_txpmaresetdone));
wire qsfp_7_gt_rx_reset = ~&qsfp_7_gt_rxpmaresetdone;

reg qsfp_7_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_7_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_7_mgt_refclk_inst (
    .I             (qsfp_7_mgt_refclk_p),
    .IB            (qsfp_7_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_7_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_7_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_7_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_7_gt_txclkout[0]),
    .O       (qsfp_7_gt_txusrclk)
);

always @(posedge qsfp_7_gt_txusrclk, posedge qsfp_7_gt_tx_reset) begin
    if (qsfp_7_gt_tx_reset) begin
        qsfp_7_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_7_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_7_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_7_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_7_gt_rxclkout[n]),
        .O       (qsfp_7_gt_rxusrclk[n])
    );

    always @(posedge qsfp_7_gt_rxusrclk[n], posedge qsfp_7_gt_rx_reset) begin
        if (qsfp_7_gt_rx_reset) begin
            qsfp_7_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_7_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_7_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_7_tx_rst_reset_sync_inst (
    .clk(qsfp_7_gt_txusrclk),
    .rst(~qsfp_7_gt_reset_tx_done),
    .out(qsfp_7_tx_reset)
);

wire [5:0] qsfp_7_gt_txheader_1;
wire [63:0] qsfp_7_gt_txdata_1;
wire qsfp_7_gt_rxgearboxslip_1;
wire [5:0] qsfp_7_gt_rxheader_1;
wire [1:0] qsfp_7_gt_rxheadervalid_1;
wire [63:0] qsfp_7_gt_rxdata_1;
wire [1:0] qsfp_7_gt_rxdatavalid_1;

wire [5:0] qsfp_7_gt_txheader_2;
wire [63:0] qsfp_7_gt_txdata_2;
wire qsfp_7_gt_rxgearboxslip_2;
wire [5:0] qsfp_7_gt_rxheader_2;
wire [1:0] qsfp_7_gt_rxheadervalid_2;
wire [63:0] qsfp_7_gt_rxdata_2;
wire [1:0] qsfp_7_gt_rxdatavalid_2;

wire [5:0] qsfp_7_gt_txheader_3;
wire [63:0] qsfp_7_gt_txdata_3;
wire qsfp_7_gt_rxgearboxslip_3;
wire [5:0] qsfp_7_gt_rxheader_3;
wire [1:0] qsfp_7_gt_rxheadervalid_3;
wire [63:0] qsfp_7_gt_rxdata_3;
wire [1:0] qsfp_7_gt_rxdatavalid_3;

wire [5:0] qsfp_7_gt_txheader_4;
wire [63:0] qsfp_7_gt_txdata_4;
wire qsfp_7_gt_rxgearboxslip_4;
wire [5:0] qsfp_7_gt_rxheader_4;
wire [1:0] qsfp_7_gt_rxheadervalid_4;
wire [63:0] qsfp_7_gt_rxdata_4;
wire [1:0] qsfp_7_gt_rxdatavalid_4;

gtwiz_qsfp_7
qsfp_7_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_7_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_7_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_7_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_7_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_7_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_7_rx_n[3], qsfp_7_rx_n[0], qsfp_7_rx_n[2], qsfp_7_rx_n[1]}),
    .gtyrxp_in({qsfp_7_rx_p[3], qsfp_7_rx_p[0], qsfp_7_rx_p[2], qsfp_7_rx_p[1]}),

    .rxusrclk_in(qsfp_7_gt_rxusrclk),
    .rxusrclk2_in(qsfp_7_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_7_gt_txdata_4, qsfp_7_gt_txdata_1, qsfp_7_gt_txdata_3, qsfp_7_gt_txdata_2}),
    .txheader_in({qsfp_7_gt_txheader_4, qsfp_7_gt_txheader_1, qsfp_7_gt_txheader_3, qsfp_7_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_7_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_7_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_7_tx_n[3], qsfp_7_tx_n[0], qsfp_7_tx_n[2], qsfp_7_tx_n[1]}),
    .gtytxp_out({qsfp_7_tx_p[3], qsfp_7_tx_p[0], qsfp_7_tx_p[2], qsfp_7_tx_p[1]}),

    .rxgearboxslip_in({qsfp_7_gt_rxgearboxslip_4, qsfp_7_gt_rxgearboxslip_1, qsfp_7_gt_rxgearboxslip_3, qsfp_7_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_7_gt_rxdata_4, qsfp_7_gt_rxdata_1, qsfp_7_gt_rxdata_3, qsfp_7_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_7_gt_rxdatavalid_4, qsfp_7_gt_rxdatavalid_1, qsfp_7_gt_rxdatavalid_3, qsfp_7_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_7_gt_rxheader_4, qsfp_7_gt_rxheader_1, qsfp_7_gt_rxheader_3, qsfp_7_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_7_gt_rxheadervalid_4, qsfp_7_gt_rxheadervalid_1, qsfp_7_gt_rxheadervalid_3, qsfp_7_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_7_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_7_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_7_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_7_gt_txclkout),
    .txpmaresetdone_out(qsfp_7_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_7_gt_txprgdivresetdone)
);

assign qsfp_7_tx_clk_1_int = qsfp_7_gt_txusrclk;
assign qsfp_7_tx_rst_1_int = qsfp_7_tx_reset;

assign qsfp_7_rx_clk_1_int = qsfp_7_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_7_rx_rst_1_reset_sync_inst (
    .clk(qsfp_7_rx_clk_1_int),
    .rst(~qsfp_7_gt_reset_rx_done),
    .out(qsfp_7_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_7_phy_1_inst (
    .tx_clk(qsfp_7_tx_clk_1_int),
    .tx_rst(qsfp_7_tx_rst_1_int),
    .rx_clk(qsfp_7_rx_clk_1_int),
    .rx_rst(qsfp_7_rx_rst_1_int),
    .xgmii_txd(qsfp_7_txd_1_int),
    .xgmii_txc(qsfp_7_txc_1_int),
    .xgmii_rxd(qsfp_7_rxd_1_int),
    .xgmii_rxc(qsfp_7_rxc_1_int),
    .serdes_tx_data(qsfp_7_gt_txdata_1),
    .serdes_tx_hdr(qsfp_7_gt_txheader_1),
    .serdes_rx_data(qsfp_7_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_7_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_7_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_7_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_7_tx_clk_2_int = qsfp_7_gt_txusrclk;
assign qsfp_7_tx_rst_2_int = qsfp_7_tx_reset;

assign qsfp_7_rx_clk_2_int = qsfp_7_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_7_rx_rst_2_reset_sync_inst (
    .clk(qsfp_7_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_7_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_7_phy_2_inst (
    .tx_clk(qsfp_7_tx_clk_2_int),
    .tx_rst(qsfp_7_tx_rst_2_int),
    .rx_clk(qsfp_7_rx_clk_2_int),
    .rx_rst(qsfp_7_rx_rst_2_int),
    .xgmii_txd(qsfp_7_txd_2_int),
    .xgmii_txc(qsfp_7_txc_2_int),
    .xgmii_rxd(qsfp_7_rxd_2_int),
    .xgmii_rxc(qsfp_7_rxc_2_int),
    .serdes_tx_data(qsfp_7_gt_txdata_2),
    .serdes_tx_hdr(qsfp_7_gt_txheader_2),
    .serdes_rx_data(qsfp_7_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_7_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_7_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_7_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_7_tx_clk_3_int = qsfp_7_gt_txusrclk;
assign qsfp_7_tx_rst_3_int = qsfp_7_tx_reset;

assign qsfp_7_rx_clk_3_int = qsfp_7_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_7_rx_rst_3_reset_sync_inst (
    .clk(qsfp_7_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_7_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_7_phy_3_inst (
    .tx_clk(qsfp_7_tx_clk_3_int),
    .tx_rst(qsfp_7_tx_rst_3_int),
    .rx_clk(qsfp_7_rx_clk_3_int),
    .rx_rst(qsfp_7_rx_rst_3_int),
    .xgmii_txd(qsfp_7_txd_3_int),
    .xgmii_txc(qsfp_7_txc_3_int),
    .xgmii_rxd(qsfp_7_rxd_3_int),
    .xgmii_rxc(qsfp_7_rxc_3_int),
    .serdes_tx_data(qsfp_7_gt_txdata_3),
    .serdes_tx_hdr(qsfp_7_gt_txheader_3),
    .serdes_rx_data(qsfp_7_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_7_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_7_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_7_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_7_tx_clk_4_int = qsfp_7_gt_txusrclk;
assign qsfp_7_tx_rst_4_int = qsfp_7_tx_reset;

assign qsfp_7_rx_clk_4_int = qsfp_7_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_7_rx_rst_4_reset_sync_inst (
    .clk(qsfp_7_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_7_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_7_phy_4_inst (
    .tx_clk(qsfp_7_tx_clk_4_int),
    .tx_rst(qsfp_7_tx_rst_4_int),
    .rx_clk(qsfp_7_rx_clk_4_int),
    .rx_rst(qsfp_7_rx_rst_4_int),
    .xgmii_txd(qsfp_7_txd_4_int),
    .xgmii_txc(qsfp_7_txc_4_int),
    .xgmii_rxd(qsfp_7_rxd_4_int),
    .xgmii_rxc(qsfp_7_rxc_4_int),
    .serdes_tx_data(qsfp_7_gt_txdata_4),
    .serdes_tx_hdr(qsfp_7_gt_txheader_4),
    .serdes_rx_data(qsfp_7_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_7_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_7_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_7_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 8
assign qsfp_8_resetl = 1'b1;

wire        qsfp_8_tx_clk_1_int;
wire        qsfp_8_tx_rst_1_int;
wire [63:0] qsfp_8_txd_1_int;
wire [7:0]  qsfp_8_txc_1_int;
wire        qsfp_8_rx_clk_1_int;
wire        qsfp_8_rx_rst_1_int;
wire [63:0] qsfp_8_rxd_1_int;
wire [7:0]  qsfp_8_rxc_1_int;
wire        qsfp_8_tx_clk_2_int;
wire        qsfp_8_tx_rst_2_int;
wire [63:0] qsfp_8_txd_2_int;
wire [7:0]  qsfp_8_txc_2_int;
wire        qsfp_8_rx_clk_2_int;
wire        qsfp_8_rx_rst_2_int;
wire [63:0] qsfp_8_rxd_2_int;
wire [7:0]  qsfp_8_rxc_2_int;
wire        qsfp_8_tx_clk_3_int;
wire        qsfp_8_tx_rst_3_int;
wire [63:0] qsfp_8_txd_3_int;
wire [7:0]  qsfp_8_txc_3_int;
wire        qsfp_8_rx_clk_3_int;
wire        qsfp_8_rx_rst_3_int;
wire [63:0] qsfp_8_rxd_3_int;
wire [7:0]  qsfp_8_rxc_3_int;
wire        qsfp_8_tx_clk_4_int;
wire        qsfp_8_tx_rst_4_int;
wire [63:0] qsfp_8_txd_4_int;
wire [7:0]  qsfp_8_txc_4_int;
wire        qsfp_8_rx_clk_4_int;
wire        qsfp_8_rx_rst_4_int;
wire [63:0] qsfp_8_rxd_4_int;
wire [7:0]  qsfp_8_rxc_4_int;

wire qsfp_8_rx_block_lock_1;
wire qsfp_8_rx_block_lock_2;
wire qsfp_8_rx_block_lock_3;
wire qsfp_8_rx_block_lock_4;

wire qsfp_8_mgt_refclk;

wire [3:0] qsfp_8_gt_txclkout;
wire qsfp_8_gt_txusrclk;

wire [3:0] qsfp_8_gt_rxclkout;
wire [3:0] qsfp_8_gt_rxusrclk;

wire qsfp_8_gt_reset_tx_done;
wire qsfp_8_gt_reset_rx_done;

wire [3:0] qsfp_8_gt_txprgdivresetdone;
wire [3:0] qsfp_8_gt_txpmaresetdone;
wire [3:0] qsfp_8_gt_rxprgdivresetdone;
wire [3:0] qsfp_8_gt_rxpmaresetdone;

wire qsfp_8_gt_tx_reset = ~((&qsfp_8_gt_txprgdivresetdone) & (&qsfp_8_gt_txpmaresetdone));
wire qsfp_8_gt_rx_reset = ~&qsfp_8_gt_rxpmaresetdone;

reg qsfp_8_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_8_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_8_mgt_refclk_inst (
    .I             (qsfp_8_mgt_refclk_p),
    .IB            (qsfp_8_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_8_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_8_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_8_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_8_gt_txclkout[0]),
    .O       (qsfp_8_gt_txusrclk)
);

always @(posedge qsfp_8_gt_txusrclk, posedge qsfp_8_gt_tx_reset) begin
    if (qsfp_8_gt_tx_reset) begin
        qsfp_8_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_8_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_8_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_8_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_8_gt_rxclkout[n]),
        .O       (qsfp_8_gt_rxusrclk[n])
    );

    always @(posedge qsfp_8_gt_rxusrclk[n], posedge qsfp_8_gt_rx_reset) begin
        if (qsfp_8_gt_rx_reset) begin
            qsfp_8_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_8_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_8_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_8_tx_rst_reset_sync_inst (
    .clk(qsfp_8_gt_txusrclk),
    .rst(~qsfp_8_gt_reset_tx_done),
    .out(qsfp_8_tx_reset)
);

wire [5:0] qsfp_8_gt_txheader_1;
wire [63:0] qsfp_8_gt_txdata_1;
wire qsfp_8_gt_rxgearboxslip_1;
wire [5:0] qsfp_8_gt_rxheader_1;
wire [1:0] qsfp_8_gt_rxheadervalid_1;
wire [63:0] qsfp_8_gt_rxdata_1;
wire [1:0] qsfp_8_gt_rxdatavalid_1;

wire [5:0] qsfp_8_gt_txheader_2;
wire [63:0] qsfp_8_gt_txdata_2;
wire qsfp_8_gt_rxgearboxslip_2;
wire [5:0] qsfp_8_gt_rxheader_2;
wire [1:0] qsfp_8_gt_rxheadervalid_2;
wire [63:0] qsfp_8_gt_rxdata_2;
wire [1:0] qsfp_8_gt_rxdatavalid_2;

wire [5:0] qsfp_8_gt_txheader_3;
wire [63:0] qsfp_8_gt_txdata_3;
wire qsfp_8_gt_rxgearboxslip_3;
wire [5:0] qsfp_8_gt_rxheader_3;
wire [1:0] qsfp_8_gt_rxheadervalid_3;
wire [63:0] qsfp_8_gt_rxdata_3;
wire [1:0] qsfp_8_gt_rxdatavalid_3;

wire [5:0] qsfp_8_gt_txheader_4;
wire [63:0] qsfp_8_gt_txdata_4;
wire qsfp_8_gt_rxgearboxslip_4;
wire [5:0] qsfp_8_gt_rxheader_4;
wire [1:0] qsfp_8_gt_rxheadervalid_4;
wire [63:0] qsfp_8_gt_rxdata_4;
wire [1:0] qsfp_8_gt_rxdatavalid_4;

gtwiz_qsfp_8
qsfp_8_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_8_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_8_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_8_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_8_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_8_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_8_rx_n[3], qsfp_8_rx_n[0], qsfp_8_rx_n[2], qsfp_8_rx_n[1]}),
    .gtyrxp_in({qsfp_8_rx_p[3], qsfp_8_rx_p[0], qsfp_8_rx_p[2], qsfp_8_rx_p[1]}),

    .rxusrclk_in(qsfp_8_gt_rxusrclk),
    .rxusrclk2_in(qsfp_8_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_8_gt_txdata_4, qsfp_8_gt_txdata_1, qsfp_8_gt_txdata_3, qsfp_8_gt_txdata_2}),
    .txheader_in({qsfp_8_gt_txheader_4, qsfp_8_gt_txheader_1, qsfp_8_gt_txheader_3, qsfp_8_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_8_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_8_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_8_tx_n[3], qsfp_8_tx_n[0], qsfp_8_tx_n[2], qsfp_8_tx_n[1]}),
    .gtytxp_out({qsfp_8_tx_p[3], qsfp_8_tx_p[0], qsfp_8_tx_p[2], qsfp_8_tx_p[1]}),

    .rxgearboxslip_in({qsfp_8_gt_rxgearboxslip_4, qsfp_8_gt_rxgearboxslip_1, qsfp_8_gt_rxgearboxslip_3, qsfp_8_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_8_gt_rxdata_4, qsfp_8_gt_rxdata_1, qsfp_8_gt_rxdata_3, qsfp_8_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_8_gt_rxdatavalid_4, qsfp_8_gt_rxdatavalid_1, qsfp_8_gt_rxdatavalid_3, qsfp_8_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_8_gt_rxheader_4, qsfp_8_gt_rxheader_1, qsfp_8_gt_rxheader_3, qsfp_8_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_8_gt_rxheadervalid_4, qsfp_8_gt_rxheadervalid_1, qsfp_8_gt_rxheadervalid_3, qsfp_8_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_8_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_8_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_8_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_8_gt_txclkout),
    .txpmaresetdone_out(qsfp_8_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_8_gt_txprgdivresetdone)
);

assign qsfp_8_tx_clk_1_int = qsfp_8_gt_txusrclk;
assign qsfp_8_tx_rst_1_int = qsfp_8_tx_reset;

assign qsfp_8_rx_clk_1_int = qsfp_8_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_8_rx_rst_1_reset_sync_inst (
    .clk(qsfp_8_rx_clk_1_int),
    .rst(~qsfp_8_gt_reset_rx_done),
    .out(qsfp_8_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_8_phy_1_inst (
    .tx_clk(qsfp_8_tx_clk_1_int),
    .tx_rst(qsfp_8_tx_rst_1_int),
    .rx_clk(qsfp_8_rx_clk_1_int),
    .rx_rst(qsfp_8_rx_rst_1_int),
    .xgmii_txd(qsfp_8_txd_1_int),
    .xgmii_txc(qsfp_8_txc_1_int),
    .xgmii_rxd(qsfp_8_rxd_1_int),
    .xgmii_rxc(qsfp_8_rxc_1_int),
    .serdes_tx_data(qsfp_8_gt_txdata_1),
    .serdes_tx_hdr(qsfp_8_gt_txheader_1),
    .serdes_rx_data(qsfp_8_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_8_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_8_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_8_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_8_tx_clk_2_int = qsfp_8_gt_txusrclk;
assign qsfp_8_tx_rst_2_int = qsfp_8_tx_reset;

assign qsfp_8_rx_clk_2_int = qsfp_8_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_8_rx_rst_2_reset_sync_inst (
    .clk(qsfp_8_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_8_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_8_phy_2_inst (
    .tx_clk(qsfp_8_tx_clk_2_int),
    .tx_rst(qsfp_8_tx_rst_2_int),
    .rx_clk(qsfp_8_rx_clk_2_int),
    .rx_rst(qsfp_8_rx_rst_2_int),
    .xgmii_txd(qsfp_8_txd_2_int),
    .xgmii_txc(qsfp_8_txc_2_int),
    .xgmii_rxd(qsfp_8_rxd_2_int),
    .xgmii_rxc(qsfp_8_rxc_2_int),
    .serdes_tx_data(qsfp_8_gt_txdata_2),
    .serdes_tx_hdr(qsfp_8_gt_txheader_2),
    .serdes_rx_data(qsfp_8_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_8_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_8_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_8_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_8_tx_clk_3_int = qsfp_8_gt_txusrclk;
assign qsfp_8_tx_rst_3_int = qsfp_8_tx_reset;

assign qsfp_8_rx_clk_3_int = qsfp_8_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_8_rx_rst_3_reset_sync_inst (
    .clk(qsfp_8_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_8_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_8_phy_3_inst (
    .tx_clk(qsfp_8_tx_clk_3_int),
    .tx_rst(qsfp_8_tx_rst_3_int),
    .rx_clk(qsfp_8_rx_clk_3_int),
    .rx_rst(qsfp_8_rx_rst_3_int),
    .xgmii_txd(qsfp_8_txd_3_int),
    .xgmii_txc(qsfp_8_txc_3_int),
    .xgmii_rxd(qsfp_8_rxd_3_int),
    .xgmii_rxc(qsfp_8_rxc_3_int),
    .serdes_tx_data(qsfp_8_gt_txdata_3),
    .serdes_tx_hdr(qsfp_8_gt_txheader_3),
    .serdes_rx_data(qsfp_8_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_8_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_8_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_8_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_8_tx_clk_4_int = qsfp_8_gt_txusrclk;
assign qsfp_8_tx_rst_4_int = qsfp_8_tx_reset;

assign qsfp_8_rx_clk_4_int = qsfp_8_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_8_rx_rst_4_reset_sync_inst (
    .clk(qsfp_8_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_8_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_8_phy_4_inst (
    .tx_clk(qsfp_8_tx_clk_4_int),
    .tx_rst(qsfp_8_tx_rst_4_int),
    .rx_clk(qsfp_8_rx_clk_4_int),
    .rx_rst(qsfp_8_rx_rst_4_int),
    .xgmii_txd(qsfp_8_txd_4_int),
    .xgmii_txc(qsfp_8_txc_4_int),
    .xgmii_rxd(qsfp_8_rxd_4_int),
    .xgmii_rxc(qsfp_8_rxc_4_int),
    .serdes_tx_data(qsfp_8_gt_txdata_4),
    .serdes_tx_hdr(qsfp_8_gt_txheader_4),
    .serdes_rx_data(qsfp_8_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_8_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_8_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_8_rx_block_lock_4),
    .rx_high_ber()
);

// QSFP 9
assign qsfp_9_resetl = 1'b1;

wire        qsfp_9_tx_clk_1_int;
wire        qsfp_9_tx_rst_1_int;
wire [63:0] qsfp_9_txd_1_int;
wire [7:0]  qsfp_9_txc_1_int;
wire        qsfp_9_rx_clk_1_int;
wire        qsfp_9_rx_rst_1_int;
wire [63:0] qsfp_9_rxd_1_int;
wire [7:0]  qsfp_9_rxc_1_int;
wire        qsfp_9_tx_clk_2_int;
wire        qsfp_9_tx_rst_2_int;
wire [63:0] qsfp_9_txd_2_int;
wire [7:0]  qsfp_9_txc_2_int;
wire        qsfp_9_rx_clk_2_int;
wire        qsfp_9_rx_rst_2_int;
wire [63:0] qsfp_9_rxd_2_int;
wire [7:0]  qsfp_9_rxc_2_int;
wire        qsfp_9_tx_clk_3_int;
wire        qsfp_9_tx_rst_3_int;
wire [63:0] qsfp_9_txd_3_int;
wire [7:0]  qsfp_9_txc_3_int;
wire        qsfp_9_rx_clk_3_int;
wire        qsfp_9_rx_rst_3_int;
wire [63:0] qsfp_9_rxd_3_int;
wire [7:0]  qsfp_9_rxc_3_int;
wire        qsfp_9_tx_clk_4_int;
wire        qsfp_9_tx_rst_4_int;
wire [63:0] qsfp_9_txd_4_int;
wire [7:0]  qsfp_9_txc_4_int;
wire        qsfp_9_rx_clk_4_int;
wire        qsfp_9_rx_rst_4_int;
wire [63:0] qsfp_9_rxd_4_int;
wire [7:0]  qsfp_9_rxc_4_int;

wire qsfp_9_rx_block_lock_1;
wire qsfp_9_rx_block_lock_2;
wire qsfp_9_rx_block_lock_3;
wire qsfp_9_rx_block_lock_4;

wire qsfp_9_mgt_refclk;

wire [3:0] qsfp_9_gt_txclkout;
wire qsfp_9_gt_txusrclk;

wire [3:0] qsfp_9_gt_rxclkout;
wire [3:0] qsfp_9_gt_rxusrclk;

wire qsfp_9_gt_reset_tx_done;
wire qsfp_9_gt_reset_rx_done;

wire [3:0] qsfp_9_gt_txprgdivresetdone;
wire [3:0] qsfp_9_gt_txpmaresetdone;
wire [3:0] qsfp_9_gt_rxprgdivresetdone;
wire [3:0] qsfp_9_gt_rxpmaresetdone;

wire qsfp_9_gt_tx_reset = ~((&qsfp_9_gt_txprgdivresetdone) & (&qsfp_9_gt_txpmaresetdone));
wire qsfp_9_gt_rx_reset = ~&qsfp_9_gt_rxpmaresetdone;

reg qsfp_9_gt_userclk_tx_active = 1'b0;
reg [3:0] qsfp_9_gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp_9_mgt_refclk_inst (
    .I             (qsfp_9_mgt_refclk_p),
    .IB            (qsfp_9_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (qsfp_9_mgt_refclk),
    .ODIV2         ()
);

BUFG_GT bufg_qsfp_9_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (qsfp_9_gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (qsfp_9_gt_txclkout[0]),
    .O       (qsfp_9_gt_txusrclk)
);

always @(posedge qsfp_9_gt_txusrclk, posedge qsfp_9_gt_tx_reset) begin
    if (qsfp_9_gt_tx_reset) begin
        qsfp_9_gt_userclk_tx_active <= 1'b0;
    end else begin
        qsfp_9_gt_userclk_tx_active <= 1'b1;
    end
end

generate

for (n = 0; n < 4; n = n + 1) begin

    BUFG_GT bufg_qsfp_9_gt_rx_usrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (qsfp_9_gt_rx_reset),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (qsfp_9_gt_rxclkout[n]),
        .O       (qsfp_9_gt_rxusrclk[n])
    );

    always @(posedge qsfp_9_gt_rxusrclk[n], posedge qsfp_9_gt_rx_reset) begin
        if (qsfp_9_gt_rx_reset) begin
            qsfp_9_gt_userclk_rx_active[n] <= 1'b0;
        end else begin
            qsfp_9_gt_userclk_rx_active[n] <= 1'b1;
        end
    end

end

endgenerate

wire qsfp_9_tx_reset;

sync_reset #(
    .N(4)
)
qsfp_9_tx_rst_reset_sync_inst (
    .clk(qsfp_9_gt_txusrclk),
    .rst(~qsfp_9_gt_reset_tx_done),
    .out(qsfp_9_tx_reset)
);

wire [5:0] qsfp_9_gt_txheader_1;
wire [63:0] qsfp_9_gt_txdata_1;
wire qsfp_9_gt_rxgearboxslip_1;
wire [5:0] qsfp_9_gt_rxheader_1;
wire [1:0] qsfp_9_gt_rxheadervalid_1;
wire [63:0] qsfp_9_gt_rxdata_1;
wire [1:0] qsfp_9_gt_rxdatavalid_1;

wire [5:0] qsfp_9_gt_txheader_2;
wire [63:0] qsfp_9_gt_txdata_2;
wire qsfp_9_gt_rxgearboxslip_2;
wire [5:0] qsfp_9_gt_rxheader_2;
wire [1:0] qsfp_9_gt_rxheadervalid_2;
wire [63:0] qsfp_9_gt_rxdata_2;
wire [1:0] qsfp_9_gt_rxdatavalid_2;

wire [5:0] qsfp_9_gt_txheader_3;
wire [63:0] qsfp_9_gt_txdata_3;
wire qsfp_9_gt_rxgearboxslip_3;
wire [5:0] qsfp_9_gt_rxheader_3;
wire [1:0] qsfp_9_gt_rxheadervalid_3;
wire [63:0] qsfp_9_gt_rxdata_3;
wire [1:0] qsfp_9_gt_rxdatavalid_3;

wire [5:0] qsfp_9_gt_txheader_4;
wire [63:0] qsfp_9_gt_txdata_4;
wire qsfp_9_gt_rxgearboxslip_4;
wire [5:0] qsfp_9_gt_rxheader_4;
wire [1:0] qsfp_9_gt_rxheadervalid_4;
wire [63:0] qsfp_9_gt_rxdata_4;
wire [1:0] qsfp_9_gt_rxdatavalid_4;

gtwiz_qsfp_9
qsfp_9_gty_inst (
    .gtwiz_userclk_tx_active_in(&qsfp_9_gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(&qsfp_9_gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(qsfp_reset),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(qsfp_9_gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(qsfp_9_gt_reset_rx_done),

    .gtrefclk00_in(qsfp_9_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in({qsfp_9_rx_n[3], qsfp_9_rx_n[0], qsfp_9_rx_n[2], qsfp_9_rx_n[1]}),
    .gtyrxp_in({qsfp_9_rx_p[3], qsfp_9_rx_p[0], qsfp_9_rx_p[2], qsfp_9_rx_p[1]}),

    .rxusrclk_in(qsfp_9_gt_rxusrclk),
    .rxusrclk2_in(qsfp_9_gt_rxusrclk),

    .gtwiz_userdata_tx_in({qsfp_9_gt_txdata_4, qsfp_9_gt_txdata_1, qsfp_9_gt_txdata_3, qsfp_9_gt_txdata_2}),
    .txheader_in({qsfp_9_gt_txheader_4, qsfp_9_gt_txheader_1, qsfp_9_gt_txheader_3, qsfp_9_gt_txheader_2}),
    .txsequence_in({4{1'b0}}),

    .txusrclk_in({4{qsfp_9_gt_txusrclk}}),
    .txusrclk2_in({4{qsfp_9_gt_txusrclk}}),

    .gtpowergood_out(),

    .gtytxn_out({qsfp_9_tx_n[3], qsfp_9_tx_n[0], qsfp_9_tx_n[2], qsfp_9_tx_n[1]}),
    .gtytxp_out({qsfp_9_tx_p[3], qsfp_9_tx_p[0], qsfp_9_tx_p[2], qsfp_9_tx_p[1]}),

    .rxgearboxslip_in({qsfp_9_gt_rxgearboxslip_4, qsfp_9_gt_rxgearboxslip_1, qsfp_9_gt_rxgearboxslip_3, qsfp_9_gt_rxgearboxslip_2}),
    .gtwiz_userdata_rx_out({qsfp_9_gt_rxdata_4, qsfp_9_gt_rxdata_1, qsfp_9_gt_rxdata_3, qsfp_9_gt_rxdata_2}),
    .rxdatavalid_out({qsfp_9_gt_rxdatavalid_4, qsfp_9_gt_rxdatavalid_1, qsfp_9_gt_rxdatavalid_3, qsfp_9_gt_rxdatavalid_2}),
    .rxheader_out({qsfp_9_gt_rxheader_4, qsfp_9_gt_rxheader_1, qsfp_9_gt_rxheader_3, qsfp_9_gt_rxheader_2}),
    .rxheadervalid_out({qsfp_9_gt_rxheadervalid_4, qsfp_9_gt_rxheadervalid_1, qsfp_9_gt_rxheadervalid_3, qsfp_9_gt_rxheadervalid_2}),
    .rxoutclk_out(qsfp_9_gt_rxclkout),
    .rxpmaresetdone_out(qsfp_9_gt_rxpmaresetdone),
    .rxprgdivresetdone_out(qsfp_9_gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(qsfp_9_gt_txclkout),
    .txpmaresetdone_out(qsfp_9_gt_txpmaresetdone),
    .txprgdivresetdone_out(qsfp_9_gt_txprgdivresetdone)
);

assign qsfp_9_tx_clk_1_int = qsfp_9_gt_txusrclk;
assign qsfp_9_tx_rst_1_int = qsfp_9_tx_reset;

assign qsfp_9_rx_clk_1_int = qsfp_9_gt_rxusrclk[2];

sync_reset #(
    .N(4)
)
qsfp_9_rx_rst_1_reset_sync_inst (
    .clk(qsfp_9_rx_clk_1_int),
    .rst(~qsfp_9_gt_reset_rx_done),
    .out(qsfp_9_rx_rst_1_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_9_phy_1_inst (
    .tx_clk(qsfp_9_tx_clk_1_int),
    .tx_rst(qsfp_9_tx_rst_1_int),
    .rx_clk(qsfp_9_rx_clk_1_int),
    .rx_rst(qsfp_9_rx_rst_1_int),
    .xgmii_txd(qsfp_9_txd_1_int),
    .xgmii_txc(qsfp_9_txc_1_int),
    .xgmii_rxd(qsfp_9_rxd_1_int),
    .xgmii_rxc(qsfp_9_rxc_1_int),
    .serdes_tx_data(qsfp_9_gt_txdata_1),
    .serdes_tx_hdr(qsfp_9_gt_txheader_1),
    .serdes_rx_data(qsfp_9_gt_rxdata_1),
    .serdes_rx_hdr(qsfp_9_gt_rxheader_1),
    .serdes_rx_bitslip(qsfp_9_gt_rxgearboxslip_1),
    .rx_block_lock(qsfp_9_rx_block_lock_1),
    .rx_high_ber()
);

assign qsfp_9_tx_clk_2_int = qsfp_9_gt_txusrclk;
assign qsfp_9_tx_rst_2_int = qsfp_9_tx_reset;

assign qsfp_9_rx_clk_2_int = qsfp_9_gt_rxusrclk[0];

sync_reset #(
    .N(4)
)
qsfp_9_rx_rst_2_reset_sync_inst (
    .clk(qsfp_9_rx_clk_2_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_9_rx_rst_2_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_9_phy_2_inst (
    .tx_clk(qsfp_9_tx_clk_2_int),
    .tx_rst(qsfp_9_tx_rst_2_int),
    .rx_clk(qsfp_9_rx_clk_2_int),
    .rx_rst(qsfp_9_rx_rst_2_int),
    .xgmii_txd(qsfp_9_txd_2_int),
    .xgmii_txc(qsfp_9_txc_2_int),
    .xgmii_rxd(qsfp_9_rxd_2_int),
    .xgmii_rxc(qsfp_9_rxc_2_int),
    .serdes_tx_data(qsfp_9_gt_txdata_2),
    .serdes_tx_hdr(qsfp_9_gt_txheader_2),
    .serdes_rx_data(qsfp_9_gt_rxdata_2),
    .serdes_rx_hdr(qsfp_9_gt_rxheader_2),
    .serdes_rx_bitslip(qsfp_9_gt_rxgearboxslip_2),
    .rx_block_lock(qsfp_9_rx_block_lock_2),
    .rx_high_ber()
);

assign qsfp_9_tx_clk_3_int = qsfp_9_gt_txusrclk;
assign qsfp_9_tx_rst_3_int = qsfp_9_tx_reset;

assign qsfp_9_rx_clk_3_int = qsfp_9_gt_rxusrclk[1];

sync_reset #(
    .N(4)
)
qsfp_9_rx_rst_3_reset_sync_inst (
    .clk(qsfp_9_rx_clk_3_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_9_rx_rst_3_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_9_phy_3_inst (
    .tx_clk(qsfp_9_tx_clk_3_int),
    .tx_rst(qsfp_9_tx_rst_3_int),
    .rx_clk(qsfp_9_rx_clk_3_int),
    .rx_rst(qsfp_9_rx_rst_3_int),
    .xgmii_txd(qsfp_9_txd_3_int),
    .xgmii_txc(qsfp_9_txc_3_int),
    .xgmii_rxd(qsfp_9_rxd_3_int),
    .xgmii_rxc(qsfp_9_rxc_3_int),
    .serdes_tx_data(qsfp_9_gt_txdata_3),
    .serdes_tx_hdr(qsfp_9_gt_txheader_3),
    .serdes_rx_data(qsfp_9_gt_rxdata_3),
    .serdes_rx_hdr(qsfp_9_gt_rxheader_3),
    .serdes_rx_bitslip(qsfp_9_gt_rxgearboxslip_3),
    .rx_block_lock(qsfp_9_rx_block_lock_3),
    .rx_high_ber()
);

assign qsfp_9_tx_clk_4_int = qsfp_9_gt_txusrclk;
assign qsfp_9_tx_rst_4_int = qsfp_9_tx_reset;

assign qsfp_9_rx_clk_4_int = qsfp_9_gt_rxusrclk[3];

sync_reset #(
    .N(4)
)
qsfp_9_rx_rst_4_reset_sync_inst (
    .clk(qsfp_9_rx_clk_4_int),
    .rst(~gt_reset_rx_done),
    .out(qsfp_9_rx_rst_4_int)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp_9_phy_4_inst (
    .tx_clk(qsfp_9_tx_clk_4_int),
    .tx_rst(qsfp_9_tx_rst_4_int),
    .rx_clk(qsfp_9_rx_clk_4_int),
    .rx_rst(qsfp_9_rx_rst_4_int),
    .xgmii_txd(qsfp_9_txd_4_int),
    .xgmii_txc(qsfp_9_txc_4_int),
    .xgmii_rxd(qsfp_9_rxd_4_int),
    .xgmii_rxc(qsfp_9_rxc_4_int),
    .serdes_tx_data(qsfp_9_gt_txdata_4),
    .serdes_tx_hdr(qsfp_9_gt_txheader_4),
    .serdes_rx_data(qsfp_9_gt_rxdata_4),
    .serdes_rx_hdr(qsfp_9_gt_rxheader_4),
    .serdes_rx_bitslip(qsfp_9_gt_rxgearboxslip_4),
    .rx_block_lock(qsfp_9_rx_block_lock_4),
    .rx_high_ber()
);

fpga_core
core_inst (
    /*
     * Clock: 156MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    /*
     * GPIO
     */
    .btn(btn_int),
    .sw(sw_int),
    .led(led),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd_int),
    .uart_rts(uart_rts_int),
    .uart_cts(uart_cts),
    .uart_rst_n(uart_rst_n),
    .uart_suspend_n(uart_suspend_n),
    /*
     * Ethernet: QSFP28
     */
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
    .qsfp_1_rxc_3(qsfp_1_rxc_3_int),
    .qsfp_1_tx_clk_4(qsfp_1_tx_clk_4_int),
    .qsfp_1_tx_rst_4(qsfp_1_tx_rst_4_int),
    .qsfp_1_txd_4(qsfp_1_txd_4_int),
    .qsfp_1_txc_4(qsfp_1_txc_4_int),
    .qsfp_1_rx_clk_4(qsfp_1_rx_clk_4_int),
    .qsfp_1_rx_rst_4(qsfp_1_rx_rst_4_int),
    .qsfp_1_rxd_4(qsfp_1_rxd_4_int),
    .qsfp_1_rxc_4(qsfp_1_rxc_4_int),
    .qsfp_2_tx_clk_1(qsfp_2_tx_clk_1_int),
    .qsfp_2_tx_rst_1(qsfp_2_tx_rst_1_int),
    .qsfp_2_txd_1(qsfp_2_txd_1_int),
    .qsfp_2_txc_1(qsfp_2_txc_1_int),
    .qsfp_2_rx_clk_1(qsfp_2_rx_clk_1_int),
    .qsfp_2_rx_rst_1(qsfp_2_rx_rst_1_int),
    .qsfp_2_rxd_1(qsfp_2_rxd_1_int),
    .qsfp_2_rxc_1(qsfp_2_rxc_1_int),
    .qsfp_2_tx_clk_2(qsfp_2_tx_clk_2_int),
    .qsfp_2_tx_rst_2(qsfp_2_tx_rst_2_int),
    .qsfp_2_txd_2(qsfp_2_txd_2_int),
    .qsfp_2_txc_2(qsfp_2_txc_2_int),
    .qsfp_2_rx_clk_2(qsfp_2_rx_clk_2_int),
    .qsfp_2_rx_rst_2(qsfp_2_rx_rst_2_int),
    .qsfp_2_rxd_2(qsfp_2_rxd_2_int),
    .qsfp_2_rxc_2(qsfp_2_rxc_2_int),
    .qsfp_2_tx_clk_3(qsfp_2_tx_clk_3_int),
    .qsfp_2_tx_rst_3(qsfp_2_tx_rst_3_int),
    .qsfp_2_txd_3(qsfp_2_txd_3_int),
    .qsfp_2_txc_3(qsfp_2_txc_3_int),
    .qsfp_2_rx_clk_3(qsfp_2_rx_clk_3_int),
    .qsfp_2_rx_rst_3(qsfp_2_rx_rst_3_int),
    .qsfp_2_rxd_3(qsfp_2_rxd_3_int),
    .qsfp_2_rxc_3(qsfp_2_rxc_3_int),
    .qsfp_2_tx_clk_4(qsfp_2_tx_clk_4_int),
    .qsfp_2_tx_rst_4(qsfp_2_tx_rst_4_int),
    .qsfp_2_txd_4(qsfp_2_txd_4_int),
    .qsfp_2_txc_4(qsfp_2_txc_4_int),
    .qsfp_2_rx_clk_4(qsfp_2_rx_clk_4_int),
    .qsfp_2_rx_rst_4(qsfp_2_rx_rst_4_int),
    .qsfp_2_rxd_4(qsfp_2_rxd_4_int),
    .qsfp_2_rxc_4(qsfp_2_rxc_4_int),
    .qsfp_3_tx_clk_1(qsfp_3_tx_clk_1_int),
    .qsfp_3_tx_rst_1(qsfp_3_tx_rst_1_int),
    .qsfp_3_txd_1(qsfp_3_txd_1_int),
    .qsfp_3_txc_1(qsfp_3_txc_1_int),
    .qsfp_3_rx_clk_1(qsfp_3_rx_clk_1_int),
    .qsfp_3_rx_rst_1(qsfp_3_rx_rst_1_int),
    .qsfp_3_rxd_1(qsfp_3_rxd_1_int),
    .qsfp_3_rxc_1(qsfp_3_rxc_1_int),
    .qsfp_3_tx_clk_2(qsfp_3_tx_clk_2_int),
    .qsfp_3_tx_rst_2(qsfp_3_tx_rst_2_int),
    .qsfp_3_txd_2(qsfp_3_txd_2_int),
    .qsfp_3_txc_2(qsfp_3_txc_2_int),
    .qsfp_3_rx_clk_2(qsfp_3_rx_clk_2_int),
    .qsfp_3_rx_rst_2(qsfp_3_rx_rst_2_int),
    .qsfp_3_rxd_2(qsfp_3_rxd_2_int),
    .qsfp_3_rxc_2(qsfp_3_rxc_2_int),
    .qsfp_3_tx_clk_3(qsfp_3_tx_clk_3_int),
    .qsfp_3_tx_rst_3(qsfp_3_tx_rst_3_int),
    .qsfp_3_txd_3(qsfp_3_txd_3_int),
    .qsfp_3_txc_3(qsfp_3_txc_3_int),
    .qsfp_3_rx_clk_3(qsfp_3_rx_clk_3_int),
    .qsfp_3_rx_rst_3(qsfp_3_rx_rst_3_int),
    .qsfp_3_rxd_3(qsfp_3_rxd_3_int),
    .qsfp_3_rxc_3(qsfp_3_rxc_3_int),
    .qsfp_3_tx_clk_4(qsfp_3_tx_clk_4_int),
    .qsfp_3_tx_rst_4(qsfp_3_tx_rst_4_int),
    .qsfp_3_txd_4(qsfp_3_txd_4_int),
    .qsfp_3_txc_4(qsfp_3_txc_4_int),
    .qsfp_3_rx_clk_4(qsfp_3_rx_clk_4_int),
    .qsfp_3_rx_rst_4(qsfp_3_rx_rst_4_int),
    .qsfp_3_rxd_4(qsfp_3_rxd_4_int),
    .qsfp_3_rxc_4(qsfp_3_rxc_4_int),
    .qsfp_4_tx_clk_1(qsfp_4_tx_clk_1_int),
    .qsfp_4_tx_rst_1(qsfp_4_tx_rst_1_int),
    .qsfp_4_txd_1(qsfp_4_txd_1_int),
    .qsfp_4_txc_1(qsfp_4_txc_1_int),
    .qsfp_4_rx_clk_1(qsfp_4_rx_clk_1_int),
    .qsfp_4_rx_rst_1(qsfp_4_rx_rst_1_int),
    .qsfp_4_rxd_1(qsfp_4_rxd_1_int),
    .qsfp_4_rxc_1(qsfp_4_rxc_1_int),
    .qsfp_4_tx_clk_2(qsfp_4_tx_clk_2_int),
    .qsfp_4_tx_rst_2(qsfp_4_tx_rst_2_int),
    .qsfp_4_txd_2(qsfp_4_txd_2_int),
    .qsfp_4_txc_2(qsfp_4_txc_2_int),
    .qsfp_4_rx_clk_2(qsfp_4_rx_clk_2_int),
    .qsfp_4_rx_rst_2(qsfp_4_rx_rst_2_int),
    .qsfp_4_rxd_2(qsfp_4_rxd_2_int),
    .qsfp_4_rxc_2(qsfp_4_rxc_2_int),
    .qsfp_4_tx_clk_3(qsfp_4_tx_clk_3_int),
    .qsfp_4_tx_rst_3(qsfp_4_tx_rst_3_int),
    .qsfp_4_txd_3(qsfp_4_txd_3_int),
    .qsfp_4_txc_3(qsfp_4_txc_3_int),
    .qsfp_4_rx_clk_3(qsfp_4_rx_clk_3_int),
    .qsfp_4_rx_rst_3(qsfp_4_rx_rst_3_int),
    .qsfp_4_rxd_3(qsfp_4_rxd_3_int),
    .qsfp_4_rxc_3(qsfp_4_rxc_3_int),
    .qsfp_4_tx_clk_4(qsfp_4_tx_clk_4_int),
    .qsfp_4_tx_rst_4(qsfp_4_tx_rst_4_int),
    .qsfp_4_txd_4(qsfp_4_txd_4_int),
    .qsfp_4_txc_4(qsfp_4_txc_4_int),
    .qsfp_4_rx_clk_4(qsfp_4_rx_clk_4_int),
    .qsfp_4_rx_rst_4(qsfp_4_rx_rst_4_int),
    .qsfp_4_rxd_4(qsfp_4_rxd_4_int),
    .qsfp_4_rxc_4(qsfp_4_rxc_4_int),
    .qsfp_5_tx_clk_1(qsfp_5_tx_clk_1_int),
    .qsfp_5_tx_rst_1(qsfp_5_tx_rst_1_int),
    .qsfp_5_txd_1(qsfp_5_txd_1_int),
    .qsfp_5_txc_1(qsfp_5_txc_1_int),
    .qsfp_5_rx_clk_1(qsfp_5_rx_clk_1_int),
    .qsfp_5_rx_rst_1(qsfp_5_rx_rst_1_int),
    .qsfp_5_rxd_1(qsfp_5_rxd_1_int),
    .qsfp_5_rxc_1(qsfp_5_rxc_1_int),
    .qsfp_5_tx_clk_2(qsfp_5_tx_clk_2_int),
    .qsfp_5_tx_rst_2(qsfp_5_tx_rst_2_int),
    .qsfp_5_txd_2(qsfp_5_txd_2_int),
    .qsfp_5_txc_2(qsfp_5_txc_2_int),
    .qsfp_5_rx_clk_2(qsfp_5_rx_clk_2_int),
    .qsfp_5_rx_rst_2(qsfp_5_rx_rst_2_int),
    .qsfp_5_rxd_2(qsfp_5_rxd_2_int),
    .qsfp_5_rxc_2(qsfp_5_rxc_2_int),
    .qsfp_5_tx_clk_3(qsfp_5_tx_clk_3_int),
    .qsfp_5_tx_rst_3(qsfp_5_tx_rst_3_int),
    .qsfp_5_txd_3(qsfp_5_txd_3_int),
    .qsfp_5_txc_3(qsfp_5_txc_3_int),
    .qsfp_5_rx_clk_3(qsfp_5_rx_clk_3_int),
    .qsfp_5_rx_rst_3(qsfp_5_rx_rst_3_int),
    .qsfp_5_rxd_3(qsfp_5_rxd_3_int),
    .qsfp_5_rxc_3(qsfp_5_rxc_3_int),
    .qsfp_5_tx_clk_4(qsfp_5_tx_clk_4_int),
    .qsfp_5_tx_rst_4(qsfp_5_tx_rst_4_int),
    .qsfp_5_txd_4(qsfp_5_txd_4_int),
    .qsfp_5_txc_4(qsfp_5_txc_4_int),
    .qsfp_5_rx_clk_4(qsfp_5_rx_clk_4_int),
    .qsfp_5_rx_rst_4(qsfp_5_rx_rst_4_int),
    .qsfp_5_rxd_4(qsfp_5_rxd_4_int),
    .qsfp_5_rxc_4(qsfp_5_rxc_4_int),
    .qsfp_6_tx_clk_1(qsfp_6_tx_clk_1_int),
    .qsfp_6_tx_rst_1(qsfp_6_tx_rst_1_int),
    .qsfp_6_txd_1(qsfp_6_txd_1_int),
    .qsfp_6_txc_1(qsfp_6_txc_1_int),
    .qsfp_6_rx_clk_1(qsfp_6_rx_clk_1_int),
    .qsfp_6_rx_rst_1(qsfp_6_rx_rst_1_int),
    .qsfp_6_rxd_1(qsfp_6_rxd_1_int),
    .qsfp_6_rxc_1(qsfp_6_rxc_1_int),
    .qsfp_6_tx_clk_2(qsfp_6_tx_clk_2_int),
    .qsfp_6_tx_rst_2(qsfp_6_tx_rst_2_int),
    .qsfp_6_txd_2(qsfp_6_txd_2_int),
    .qsfp_6_txc_2(qsfp_6_txc_2_int),
    .qsfp_6_rx_clk_2(qsfp_6_rx_clk_2_int),
    .qsfp_6_rx_rst_2(qsfp_6_rx_rst_2_int),
    .qsfp_6_rxd_2(qsfp_6_rxd_2_int),
    .qsfp_6_rxc_2(qsfp_6_rxc_2_int),
    .qsfp_6_tx_clk_3(qsfp_6_tx_clk_3_int),
    .qsfp_6_tx_rst_3(qsfp_6_tx_rst_3_int),
    .qsfp_6_txd_3(qsfp_6_txd_3_int),
    .qsfp_6_txc_3(qsfp_6_txc_3_int),
    .qsfp_6_rx_clk_3(qsfp_6_rx_clk_3_int),
    .qsfp_6_rx_rst_3(qsfp_6_rx_rst_3_int),
    .qsfp_6_rxd_3(qsfp_6_rxd_3_int),
    .qsfp_6_rxc_3(qsfp_6_rxc_3_int),
    .qsfp_6_tx_clk_4(qsfp_6_tx_clk_4_int),
    .qsfp_6_tx_rst_4(qsfp_6_tx_rst_4_int),
    .qsfp_6_txd_4(qsfp_6_txd_4_int),
    .qsfp_6_txc_4(qsfp_6_txc_4_int),
    .qsfp_6_rx_clk_4(qsfp_6_rx_clk_4_int),
    .qsfp_6_rx_rst_4(qsfp_6_rx_rst_4_int),
    .qsfp_6_rxd_4(qsfp_6_rxd_4_int),
    .qsfp_6_rxc_4(qsfp_6_rxc_4_int),
    .qsfp_7_tx_clk_1(qsfp_7_tx_clk_1_int),
    .qsfp_7_tx_rst_1(qsfp_7_tx_rst_1_int),
    .qsfp_7_txd_1(qsfp_7_txd_1_int),
    .qsfp_7_txc_1(qsfp_7_txc_1_int),
    .qsfp_7_rx_clk_1(qsfp_7_rx_clk_1_int),
    .qsfp_7_rx_rst_1(qsfp_7_rx_rst_1_int),
    .qsfp_7_rxd_1(qsfp_7_rxd_1_int),
    .qsfp_7_rxc_1(qsfp_7_rxc_1_int),
    .qsfp_7_tx_clk_2(qsfp_7_tx_clk_2_int),
    .qsfp_7_tx_rst_2(qsfp_7_tx_rst_2_int),
    .qsfp_7_txd_2(qsfp_7_txd_2_int),
    .qsfp_7_txc_2(qsfp_7_txc_2_int),
    .qsfp_7_rx_clk_2(qsfp_7_rx_clk_2_int),
    .qsfp_7_rx_rst_2(qsfp_7_rx_rst_2_int),
    .qsfp_7_rxd_2(qsfp_7_rxd_2_int),
    .qsfp_7_rxc_2(qsfp_7_rxc_2_int),
    .qsfp_7_tx_clk_3(qsfp_7_tx_clk_3_int),
    .qsfp_7_tx_rst_3(qsfp_7_tx_rst_3_int),
    .qsfp_7_txd_3(qsfp_7_txd_3_int),
    .qsfp_7_txc_3(qsfp_7_txc_3_int),
    .qsfp_7_rx_clk_3(qsfp_7_rx_clk_3_int),
    .qsfp_7_rx_rst_3(qsfp_7_rx_rst_3_int),
    .qsfp_7_rxd_3(qsfp_7_rxd_3_int),
    .qsfp_7_rxc_3(qsfp_7_rxc_3_int),
    .qsfp_7_tx_clk_4(qsfp_7_tx_clk_4_int),
    .qsfp_7_tx_rst_4(qsfp_7_tx_rst_4_int),
    .qsfp_7_txd_4(qsfp_7_txd_4_int),
    .qsfp_7_txc_4(qsfp_7_txc_4_int),
    .qsfp_7_rx_clk_4(qsfp_7_rx_clk_4_int),
    .qsfp_7_rx_rst_4(qsfp_7_rx_rst_4_int),
    .qsfp_7_rxd_4(qsfp_7_rxd_4_int),
    .qsfp_7_rxc_4(qsfp_7_rxc_4_int),
    .qsfp_8_tx_clk_1(qsfp_8_tx_clk_1_int),
    .qsfp_8_tx_rst_1(qsfp_8_tx_rst_1_int),
    .qsfp_8_txd_1(qsfp_8_txd_1_int),
    .qsfp_8_txc_1(qsfp_8_txc_1_int),
    .qsfp_8_rx_clk_1(qsfp_8_rx_clk_1_int),
    .qsfp_8_rx_rst_1(qsfp_8_rx_rst_1_int),
    .qsfp_8_rxd_1(qsfp_8_rxd_1_int),
    .qsfp_8_rxc_1(qsfp_8_rxc_1_int),
    .qsfp_8_tx_clk_2(qsfp_8_tx_clk_2_int),
    .qsfp_8_tx_rst_2(qsfp_8_tx_rst_2_int),
    .qsfp_8_txd_2(qsfp_8_txd_2_int),
    .qsfp_8_txc_2(qsfp_8_txc_2_int),
    .qsfp_8_rx_clk_2(qsfp_8_rx_clk_2_int),
    .qsfp_8_rx_rst_2(qsfp_8_rx_rst_2_int),
    .qsfp_8_rxd_2(qsfp_8_rxd_2_int),
    .qsfp_8_rxc_2(qsfp_8_rxc_2_int),
    .qsfp_8_tx_clk_3(qsfp_8_tx_clk_3_int),
    .qsfp_8_tx_rst_3(qsfp_8_tx_rst_3_int),
    .qsfp_8_txd_3(qsfp_8_txd_3_int),
    .qsfp_8_txc_3(qsfp_8_txc_3_int),
    .qsfp_8_rx_clk_3(qsfp_8_rx_clk_3_int),
    .qsfp_8_rx_rst_3(qsfp_8_rx_rst_3_int),
    .qsfp_8_rxd_3(qsfp_8_rxd_3_int),
    .qsfp_8_rxc_3(qsfp_8_rxc_3_int),
    .qsfp_8_tx_clk_4(qsfp_8_tx_clk_4_int),
    .qsfp_8_tx_rst_4(qsfp_8_tx_rst_4_int),
    .qsfp_8_txd_4(qsfp_8_txd_4_int),
    .qsfp_8_txc_4(qsfp_8_txc_4_int),
    .qsfp_8_rx_clk_4(qsfp_8_rx_clk_4_int),
    .qsfp_8_rx_rst_4(qsfp_8_rx_rst_4_int),
    .qsfp_8_rxd_4(qsfp_8_rxd_4_int),
    .qsfp_8_rxc_4(qsfp_8_rxc_4_int),
    .qsfp_9_tx_clk_1(qsfp_9_tx_clk_1_int),
    .qsfp_9_tx_rst_1(qsfp_9_tx_rst_1_int),
    .qsfp_9_txd_1(qsfp_9_txd_1_int),
    .qsfp_9_txc_1(qsfp_9_txc_1_int),
    .qsfp_9_rx_clk_1(qsfp_9_rx_clk_1_int),
    .qsfp_9_rx_rst_1(qsfp_9_rx_rst_1_int),
    .qsfp_9_rxd_1(qsfp_9_rxd_1_int),
    .qsfp_9_rxc_1(qsfp_9_rxc_1_int),
    .qsfp_9_tx_clk_2(qsfp_9_tx_clk_2_int),
    .qsfp_9_tx_rst_2(qsfp_9_tx_rst_2_int),
    .qsfp_9_txd_2(qsfp_9_txd_2_int),
    .qsfp_9_txc_2(qsfp_9_txc_2_int),
    .qsfp_9_rx_clk_2(qsfp_9_rx_clk_2_int),
    .qsfp_9_rx_rst_2(qsfp_9_rx_rst_2_int),
    .qsfp_9_rxd_2(qsfp_9_rxd_2_int),
    .qsfp_9_rxc_2(qsfp_9_rxc_2_int),
    .qsfp_9_tx_clk_3(qsfp_9_tx_clk_3_int),
    .qsfp_9_tx_rst_3(qsfp_9_tx_rst_3_int),
    .qsfp_9_txd_3(qsfp_9_txd_3_int),
    .qsfp_9_txc_3(qsfp_9_txc_3_int),
    .qsfp_9_rx_clk_3(qsfp_9_rx_clk_3_int),
    .qsfp_9_rx_rst_3(qsfp_9_rx_rst_3_int),
    .qsfp_9_rxd_3(qsfp_9_rxd_3_int),
    .qsfp_9_rxc_3(qsfp_9_rxc_3_int),
    .qsfp_9_tx_clk_4(qsfp_9_tx_clk_4_int),
    .qsfp_9_tx_rst_4(qsfp_9_tx_rst_4_int),
    .qsfp_9_txd_4(qsfp_9_txd_4_int),
    .qsfp_9_txc_4(qsfp_9_txc_4_int),
    .qsfp_9_rx_clk_4(qsfp_9_rx_clk_4_int),
    .qsfp_9_rx_rst_4(qsfp_9_rx_rst_4_int),
    .qsfp_9_rxd_4(qsfp_9_rxd_4_int),
    .qsfp_9_rxc_4(qsfp_9_rxc_4_int)
);

endmodule
