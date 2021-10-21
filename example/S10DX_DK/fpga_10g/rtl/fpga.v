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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 100 MHz
     * Reset: Push button, active low
     */
    input  wire       clk2_100m_fpga_2i_p,
    input  wire       cpu_resetn,

    /*
     * GPIO
     */
    input  wire       user_pb,
    output wire [3:0] user_led_g,

    /*
     * Ethernet: QSFP28
     */
    output wire [3:0] qsfp1_tx_p,
    output wire [3:0] qsfp1_tx_n,
    input  wire [3:0] qsfp1_rx_p,
    input  wire [3:0] qsfp1_rx_n,
    output wire [3:0] qsfp2_tx_p,
    output wire [3:0] qsfp2_tx_n,
    input  wire [3:0] qsfp2_rx_p,
    input  wire [3:0] qsfp2_rx_n,
    input  wire clk_156p25m_qsfp0_p
);

// Clock and reset

wire ninit_done;

reset_release reset_release_inst (
    .ninit_done (ninit_done)
);

wire clk_100mhz = clk2_100m_fpga_2i_p;
wire rst_100mhz;

sync_reset #(
    .N(4)
)
sync_reset_100mhz_inst (
    .clk(clk_100mhz),
    .rst(~cpu_resetn || ninit_done),
    .out(rst_100mhz)
);

wire clk_161mhz;
wire rst_161mhz;

// GPIO
wire btn_int;
wire [3:0] led_int;

debounce_switch #(
    .WIDTH(1),
    .N(4),
    .RATE(161132)
)
debounce_switch_inst (
    .clk(clk_161mhz),
    .rst(rst_161mhz),
    .in({~user_pb}),
    .out({btn_int})
);

assign user_led_g = led_int;

// QSFP interfaces
wire        qsfp1_mac_1_clk_int;
wire        qsfp1_mac_1_rst_int;

wire [63:0] qsfp1_mac_1_rx_axis_tdata_int;
wire [7:0]  qsfp1_mac_1_rx_axis_tkeep_int;
wire        qsfp1_mac_1_rx_axis_tvalid_int;
wire        qsfp1_mac_1_rx_axis_tlast_int;
wire        qsfp1_mac_1_rx_axis_tuser_int;

wire [63:0] qsfp1_mac_1_tx_axis_tdata_int;
wire [7:0]  qsfp1_mac_1_tx_axis_tkeep_int;
wire        qsfp1_mac_1_tx_axis_tvalid_int;
wire        qsfp1_mac_1_tx_axis_tready_int;
wire        qsfp1_mac_1_tx_axis_tlast_int;
wire        qsfp1_mac_1_tx_axis_tuser_int;

wire        qsfp1_mac_2_clk_int;
wire        qsfp1_mac_2_rst_int;

wire [63:0] qsfp1_mac_2_rx_axis_tdata_int;
wire [7:0]  qsfp1_mac_2_rx_axis_tkeep_int;
wire        qsfp1_mac_2_rx_axis_tvalid_int;
wire        qsfp1_mac_2_rx_axis_tlast_int;
wire        qsfp1_mac_2_rx_axis_tuser_int;

wire [63:0] qsfp1_mac_2_tx_axis_tdata_int;
wire [7:0]  qsfp1_mac_2_tx_axis_tkeep_int;
wire        qsfp1_mac_2_tx_axis_tvalid_int;
wire        qsfp1_mac_2_tx_axis_tready_int;
wire        qsfp1_mac_2_tx_axis_tlast_int;
wire        qsfp1_mac_2_tx_axis_tuser_int;

wire        qsfp1_mac_3_clk_int;
wire        qsfp1_mac_3_rst_int;

wire [63:0] qsfp1_mac_3_rx_axis_tdata_int;
wire [7:0]  qsfp1_mac_3_rx_axis_tkeep_int;
wire        qsfp1_mac_3_rx_axis_tvalid_int;
wire        qsfp1_mac_3_rx_axis_tlast_int;
wire        qsfp1_mac_3_rx_axis_tuser_int;

wire [63:0] qsfp1_mac_3_tx_axis_tdata_int;
wire [7:0]  qsfp1_mac_3_tx_axis_tkeep_int;
wire        qsfp1_mac_3_tx_axis_tvalid_int;
wire        qsfp1_mac_3_tx_axis_tready_int;
wire        qsfp1_mac_3_tx_axis_tlast_int;
wire        qsfp1_mac_3_tx_axis_tuser_int;

wire        qsfp1_mac_4_clk_int;
wire        qsfp1_mac_4_rst_int;

wire [63:0] qsfp1_mac_4_rx_axis_tdata_int;
wire [7:0]  qsfp1_mac_4_rx_axis_tkeep_int;
wire        qsfp1_mac_4_rx_axis_tvalid_int;
wire        qsfp1_mac_4_rx_axis_tlast_int;
wire        qsfp1_mac_4_rx_axis_tuser_int;

wire [63:0] qsfp1_mac_4_tx_axis_tdata_int;
wire [7:0]  qsfp1_mac_4_tx_axis_tkeep_int;
wire        qsfp1_mac_4_tx_axis_tvalid_int;
wire        qsfp1_mac_4_tx_axis_tready_int;
wire        qsfp1_mac_4_tx_axis_tlast_int;
wire        qsfp1_mac_4_tx_axis_tuser_int;

wire        qsfp2_mac_1_clk_int;
wire        qsfp2_mac_1_rst_int;

wire [63:0] qsfp2_mac_1_rx_axis_tdata_int;
wire [7:0]  qsfp2_mac_1_rx_axis_tkeep_int;
wire        qsfp2_mac_1_rx_axis_tvalid_int;
wire        qsfp2_mac_1_rx_axis_tlast_int;
wire        qsfp2_mac_1_rx_axis_tuser_int;

wire [63:0] qsfp2_mac_1_tx_axis_tdata_int;
wire [7:0]  qsfp2_mac_1_tx_axis_tkeep_int;
wire        qsfp2_mac_1_tx_axis_tvalid_int;
wire        qsfp2_mac_1_tx_axis_tready_int;
wire        qsfp2_mac_1_tx_axis_tlast_int;
wire        qsfp2_mac_1_tx_axis_tuser_int;

wire        qsfp2_mac_2_clk_int;
wire        qsfp2_mac_2_rst_int;

wire [63:0] qsfp2_mac_2_rx_axis_tdata_int;
wire [7:0]  qsfp2_mac_2_rx_axis_tkeep_int;
wire        qsfp2_mac_2_rx_axis_tvalid_int;
wire        qsfp2_mac_2_rx_axis_tlast_int;
wire        qsfp2_mac_2_rx_axis_tuser_int;

wire [63:0] qsfp2_mac_2_tx_axis_tdata_int;
wire [7:0]  qsfp2_mac_2_tx_axis_tkeep_int;
wire        qsfp2_mac_2_tx_axis_tvalid_int;
wire        qsfp2_mac_2_tx_axis_tready_int;
wire        qsfp2_mac_2_tx_axis_tlast_int;
wire        qsfp2_mac_2_tx_axis_tuser_int;

wire        qsfp2_mac_3_clk_int;
wire        qsfp2_mac_3_rst_int;

wire [63:0] qsfp2_mac_3_rx_axis_tdata_int;
wire [7:0]  qsfp2_mac_3_rx_axis_tkeep_int;
wire        qsfp2_mac_3_rx_axis_tvalid_int;
wire        qsfp2_mac_3_rx_axis_tlast_int;
wire        qsfp2_mac_3_rx_axis_tuser_int;

wire [63:0] qsfp2_mac_3_tx_axis_tdata_int;
wire [7:0]  qsfp2_mac_3_tx_axis_tkeep_int;
wire        qsfp2_mac_3_tx_axis_tvalid_int;
wire        qsfp2_mac_3_tx_axis_tready_int;
wire        qsfp2_mac_3_tx_axis_tlast_int;
wire        qsfp2_mac_3_tx_axis_tuser_int;

wire        qsfp2_mac_4_clk_int;
wire        qsfp2_mac_4_rst_int;

wire [63:0] qsfp2_mac_4_rx_axis_tdata_int;
wire [7:0]  qsfp2_mac_4_rx_axis_tkeep_int;
wire        qsfp2_mac_4_rx_axis_tvalid_int;
wire        qsfp2_mac_4_rx_axis_tlast_int;
wire        qsfp2_mac_4_rx_axis_tuser_int;

wire [63:0] qsfp2_mac_4_tx_axis_tdata_int;
wire [7:0]  qsfp2_mac_4_tx_axis_tkeep_int;
wire        qsfp2_mac_4_tx_axis_tvalid_int;
wire        qsfp2_mac_4_tx_axis_tready_int;
wire        qsfp2_mac_4_tx_axis_tlast_int;
wire        qsfp2_mac_4_tx_axis_tuser_int;

assign clk_161mhz = qsfp1_mac_1_clk_int;
assign rst_161mhz = qsfp1_mac_1_rst_int;

eth_mac_quad_wrapper qsfp1_mac_inst (
    .ctrl_clk(clk_100mhz),
    .ctrl_rst(rst_100mhz),

    .tx_serial_data_p(qsfp1_tx_p),
    .tx_serial_data_n(qsfp1_tx_n),
    .rx_serial_data_p(qsfp1_rx_p),
    .rx_serial_data_n(qsfp1_rx_n),
    .ref_clk(clk_156p25m_qsfp0_p),

    .mac_1_clk(qsfp1_mac_1_clk_int),
    .mac_1_rst(qsfp1_mac_1_rst_int),

    .mac_1_rx_axis_tdata(qsfp1_mac_1_rx_axis_tdata_int),
    .mac_1_rx_axis_tkeep(qsfp1_mac_1_rx_axis_tkeep_int),
    .mac_1_rx_axis_tvalid(qsfp1_mac_1_rx_axis_tvalid_int),
    .mac_1_rx_axis_tlast(qsfp1_mac_1_rx_axis_tlast_int),
    .mac_1_rx_axis_tuser(qsfp1_mac_1_rx_axis_tuser_int),

    .mac_1_tx_axis_tdata(qsfp1_mac_1_tx_axis_tdata_int),
    .mac_1_tx_axis_tkeep(qsfp1_mac_1_tx_axis_tkeep_int),
    .mac_1_tx_axis_tvalid(qsfp1_mac_1_tx_axis_tvalid_int),
    .mac_1_tx_axis_tready(qsfp1_mac_1_tx_axis_tready_int),
    .mac_1_tx_axis_tlast(qsfp1_mac_1_tx_axis_tlast_int),
    .mac_1_tx_axis_tuser(qsfp1_mac_1_tx_axis_tuser_int),

    .mac_2_clk(qsfp1_mac_3_clk_int),
    .mac_2_rst(qsfp1_mac_3_rst_int),

    .mac_2_rx_axis_tdata(qsfp1_mac_3_rx_axis_tdata_int),
    .mac_2_rx_axis_tkeep(qsfp1_mac_3_rx_axis_tkeep_int),
    .mac_2_rx_axis_tvalid(qsfp1_mac_3_rx_axis_tvalid_int),
    .mac_2_rx_axis_tlast(qsfp1_mac_3_rx_axis_tlast_int),
    .mac_2_rx_axis_tuser(qsfp1_mac_3_rx_axis_tuser_int),

    .mac_2_tx_axis_tdata(qsfp1_mac_3_tx_axis_tdata_int),
    .mac_2_tx_axis_tkeep(qsfp1_mac_3_tx_axis_tkeep_int),
    .mac_2_tx_axis_tvalid(qsfp1_mac_3_tx_axis_tvalid_int),
    .mac_2_tx_axis_tready(qsfp1_mac_3_tx_axis_tready_int),
    .mac_2_tx_axis_tlast(qsfp1_mac_3_tx_axis_tlast_int),
    .mac_2_tx_axis_tuser(qsfp1_mac_3_tx_axis_tuser_int),

    .mac_3_clk(qsfp1_mac_2_clk_int),
    .mac_3_rst(qsfp1_mac_2_rst_int),

    .mac_3_rx_axis_tdata(qsfp1_mac_2_rx_axis_tdata_int),
    .mac_3_rx_axis_tkeep(qsfp1_mac_2_rx_axis_tkeep_int),
    .mac_3_rx_axis_tvalid(qsfp1_mac_2_rx_axis_tvalid_int),
    .mac_3_rx_axis_tlast(qsfp1_mac_2_rx_axis_tlast_int),
    .mac_3_rx_axis_tuser(qsfp1_mac_2_rx_axis_tuser_int),

    .mac_3_tx_axis_tdata(qsfp1_mac_2_tx_axis_tdata_int),
    .mac_3_tx_axis_tkeep(qsfp1_mac_2_tx_axis_tkeep_int),
    .mac_3_tx_axis_tvalid(qsfp1_mac_2_tx_axis_tvalid_int),
    .mac_3_tx_axis_tready(qsfp1_mac_2_tx_axis_tready_int),
    .mac_3_tx_axis_tlast(qsfp1_mac_2_tx_axis_tlast_int),
    .mac_3_tx_axis_tuser(qsfp1_mac_2_tx_axis_tuser_int),

    .mac_4_clk(qsfp1_mac_4_clk_int),
    .mac_4_rst(qsfp1_mac_4_rst_int),

    .mac_4_rx_axis_tdata(qsfp1_mac_4_rx_axis_tdata_int),
    .mac_4_rx_axis_tkeep(qsfp1_mac_4_rx_axis_tkeep_int),
    .mac_4_rx_axis_tvalid(qsfp1_mac_4_rx_axis_tvalid_int),
    .mac_4_rx_axis_tlast(qsfp1_mac_4_rx_axis_tlast_int),
    .mac_4_rx_axis_tuser(qsfp1_mac_4_rx_axis_tuser_int),

    .mac_4_tx_axis_tdata(qsfp1_mac_4_tx_axis_tdata_int),
    .mac_4_tx_axis_tkeep(qsfp1_mac_4_tx_axis_tkeep_int),
    .mac_4_tx_axis_tvalid(qsfp1_mac_4_tx_axis_tvalid_int),
    .mac_4_tx_axis_tready(qsfp1_mac_4_tx_axis_tready_int),
    .mac_4_tx_axis_tlast(qsfp1_mac_4_tx_axis_tlast_int),
    .mac_4_tx_axis_tuser(qsfp1_mac_4_tx_axis_tuser_int)
);

eth_mac_quad_wrapper qsfp2_mac_inst (
    .ctrl_clk(clk_100mhz),
    .ctrl_rst(rst_100mhz),

    .tx_serial_data_p(qsfp2_tx_p),
    .tx_serial_data_n(qsfp2_tx_n),
    .rx_serial_data_p(qsfp2_rx_p),
    .rx_serial_data_n(qsfp2_rx_n),
    .ref_clk(clk_156p25m_qsfp0_p),

    .mac_1_clk(qsfp2_mac_1_clk_int),
    .mac_1_rst(qsfp2_mac_1_rst_int),

    .mac_1_rx_axis_tdata(qsfp2_mac_1_rx_axis_tdata_int),
    .mac_1_rx_axis_tkeep(qsfp2_mac_1_rx_axis_tkeep_int),
    .mac_1_rx_axis_tvalid(qsfp2_mac_1_rx_axis_tvalid_int),
    .mac_1_rx_axis_tlast(qsfp2_mac_1_rx_axis_tlast_int),
    .mac_1_rx_axis_tuser(qsfp2_mac_1_rx_axis_tuser_int),

    .mac_1_tx_axis_tdata(qsfp2_mac_1_tx_axis_tdata_int),
    .mac_1_tx_axis_tkeep(qsfp2_mac_1_tx_axis_tkeep_int),
    .mac_1_tx_axis_tvalid(qsfp2_mac_1_tx_axis_tvalid_int),
    .mac_1_tx_axis_tready(qsfp2_mac_1_tx_axis_tready_int),
    .mac_1_tx_axis_tlast(qsfp2_mac_1_tx_axis_tlast_int),
    .mac_1_tx_axis_tuser(qsfp2_mac_1_tx_axis_tuser_int),

    .mac_2_clk(qsfp2_mac_3_clk_int),
    .mac_2_rst(qsfp2_mac_3_rst_int),

    .mac_2_rx_axis_tdata(qsfp2_mac_3_rx_axis_tdata_int),
    .mac_2_rx_axis_tkeep(qsfp2_mac_3_rx_axis_tkeep_int),
    .mac_2_rx_axis_tvalid(qsfp2_mac_3_rx_axis_tvalid_int),
    .mac_2_rx_axis_tlast(qsfp2_mac_3_rx_axis_tlast_int),
    .mac_2_rx_axis_tuser(qsfp2_mac_3_rx_axis_tuser_int),

    .mac_2_tx_axis_tdata(qsfp2_mac_3_tx_axis_tdata_int),
    .mac_2_tx_axis_tkeep(qsfp2_mac_3_tx_axis_tkeep_int),
    .mac_2_tx_axis_tvalid(qsfp2_mac_3_tx_axis_tvalid_int),
    .mac_2_tx_axis_tready(qsfp2_mac_3_tx_axis_tready_int),
    .mac_2_tx_axis_tlast(qsfp2_mac_3_tx_axis_tlast_int),
    .mac_2_tx_axis_tuser(qsfp2_mac_3_tx_axis_tuser_int),

    .mac_3_clk(qsfp2_mac_2_clk_int),
    .mac_3_rst(qsfp2_mac_2_rst_int),

    .mac_3_rx_axis_tdata(qsfp2_mac_2_rx_axis_tdata_int),
    .mac_3_rx_axis_tkeep(qsfp2_mac_2_rx_axis_tkeep_int),
    .mac_3_rx_axis_tvalid(qsfp2_mac_2_rx_axis_tvalid_int),
    .mac_3_rx_axis_tlast(qsfp2_mac_2_rx_axis_tlast_int),
    .mac_3_rx_axis_tuser(qsfp2_mac_2_rx_axis_tuser_int),

    .mac_3_tx_axis_tdata(qsfp2_mac_2_tx_axis_tdata_int),
    .mac_3_tx_axis_tkeep(qsfp2_mac_2_tx_axis_tkeep_int),
    .mac_3_tx_axis_tvalid(qsfp2_mac_2_tx_axis_tvalid_int),
    .mac_3_tx_axis_tready(qsfp2_mac_2_tx_axis_tready_int),
    .mac_3_tx_axis_tlast(qsfp2_mac_2_tx_axis_tlast_int),
    .mac_3_tx_axis_tuser(qsfp2_mac_2_tx_axis_tuser_int),

    .mac_4_clk(qsfp2_mac_4_clk_int),
    .mac_4_rst(qsfp2_mac_4_rst_int),

    .mac_4_rx_axis_tdata(qsfp2_mac_4_rx_axis_tdata_int),
    .mac_4_rx_axis_tkeep(qsfp2_mac_4_rx_axis_tkeep_int),
    .mac_4_rx_axis_tvalid(qsfp2_mac_4_rx_axis_tvalid_int),
    .mac_4_rx_axis_tlast(qsfp2_mac_4_rx_axis_tlast_int),
    .mac_4_rx_axis_tuser(qsfp2_mac_4_rx_axis_tuser_int),

    .mac_4_tx_axis_tdata(qsfp2_mac_4_tx_axis_tdata_int),
    .mac_4_tx_axis_tkeep(qsfp2_mac_4_tx_axis_tkeep_int),
    .mac_4_tx_axis_tvalid(qsfp2_mac_4_tx_axis_tvalid_int),
    .mac_4_tx_axis_tready(qsfp2_mac_4_tx_axis_tready_int),
    .mac_4_tx_axis_tlast(qsfp2_mac_4_tx_axis_tlast_int),
    .mac_4_tx_axis_tuser(qsfp2_mac_4_tx_axis_tuser_int)
);

// Core logic
fpga_core
core_inst (
    /*
     * Clock: 161.1328125 MHz
     * Synchronous reset
     */
    .clk(clk_161mhz),
    .rst(rst_161mhz),
    /*
     * GPIO
     */
    .btn(btn_int),
    .led(led_int),
    /*
     * Ethernet: QSFP28
     */
    .qsfp1_mac_1_rx_clk(qsfp1_mac_1_clk_int),
    .qsfp1_mac_1_rx_rst(qsfp1_mac_1_rst_int),
    .qsfp1_mac_1_rx_axis_tdata(qsfp1_mac_1_rx_axis_tdata_int),
    .qsfp1_mac_1_rx_axis_tkeep(qsfp1_mac_1_rx_axis_tkeep_int),
    .qsfp1_mac_1_rx_axis_tvalid(qsfp1_mac_1_rx_axis_tvalid_int),
    .qsfp1_mac_1_rx_axis_tlast(qsfp1_mac_1_rx_axis_tlast_int),
    .qsfp1_mac_1_rx_axis_tuser(qsfp1_mac_1_rx_axis_tuser_int),

    .qsfp1_mac_1_tx_clk(qsfp1_mac_1_clk_int),
    .qsfp1_mac_1_tx_rst(qsfp1_mac_1_rst_int),
    .qsfp1_mac_1_tx_axis_tdata(qsfp1_mac_1_tx_axis_tdata_int),
    .qsfp1_mac_1_tx_axis_tkeep(qsfp1_mac_1_tx_axis_tkeep_int),
    .qsfp1_mac_1_tx_axis_tvalid(qsfp1_mac_1_tx_axis_tvalid_int),
    .qsfp1_mac_1_tx_axis_tready(qsfp1_mac_1_tx_axis_tready_int),
    .qsfp1_mac_1_tx_axis_tlast(qsfp1_mac_1_tx_axis_tlast_int),
    .qsfp1_mac_1_tx_axis_tuser(qsfp1_mac_1_tx_axis_tuser_int),

    .qsfp1_mac_2_rx_clk(qsfp1_mac_2_clk_int),
    .qsfp1_mac_2_rx_rst(qsfp1_mac_2_rst_int),
    .qsfp1_mac_2_rx_axis_tdata(qsfp1_mac_2_rx_axis_tdata_int),
    .qsfp1_mac_2_rx_axis_tkeep(qsfp1_mac_2_rx_axis_tkeep_int),
    .qsfp1_mac_2_rx_axis_tvalid(qsfp1_mac_2_rx_axis_tvalid_int),
    .qsfp1_mac_2_rx_axis_tlast(qsfp1_mac_2_rx_axis_tlast_int),
    .qsfp1_mac_2_rx_axis_tuser(qsfp1_mac_2_rx_axis_tuser_int),

    .qsfp1_mac_2_tx_clk(qsfp1_mac_2_clk_int),
    .qsfp1_mac_2_tx_rst(qsfp1_mac_2_rst_int),
    .qsfp1_mac_2_tx_axis_tdata(qsfp1_mac_2_tx_axis_tdata_int),
    .qsfp1_mac_2_tx_axis_tkeep(qsfp1_mac_2_tx_axis_tkeep_int),
    .qsfp1_mac_2_tx_axis_tvalid(qsfp1_mac_2_tx_axis_tvalid_int),
    .qsfp1_mac_2_tx_axis_tready(qsfp1_mac_2_tx_axis_tready_int),
    .qsfp1_mac_2_tx_axis_tlast(qsfp1_mac_2_tx_axis_tlast_int),
    .qsfp1_mac_2_tx_axis_tuser(qsfp1_mac_2_tx_axis_tuser_int),

    .qsfp1_mac_3_rx_clk(qsfp1_mac_3_clk_int),
    .qsfp1_mac_3_rx_rst(qsfp1_mac_3_rst_int),
    .qsfp1_mac_3_rx_axis_tdata(qsfp1_mac_3_rx_axis_tdata_int),
    .qsfp1_mac_3_rx_axis_tkeep(qsfp1_mac_3_rx_axis_tkeep_int),
    .qsfp1_mac_3_rx_axis_tvalid(qsfp1_mac_3_rx_axis_tvalid_int),
    .qsfp1_mac_3_rx_axis_tlast(qsfp1_mac_3_rx_axis_tlast_int),
    .qsfp1_mac_3_rx_axis_tuser(qsfp1_mac_3_rx_axis_tuser_int),

    .qsfp1_mac_3_tx_clk(qsfp1_mac_3_clk_int),
    .qsfp1_mac_3_tx_rst(qsfp1_mac_3_rst_int),
    .qsfp1_mac_3_tx_axis_tdata(qsfp1_mac_3_tx_axis_tdata_int),
    .qsfp1_mac_3_tx_axis_tkeep(qsfp1_mac_3_tx_axis_tkeep_int),
    .qsfp1_mac_3_tx_axis_tvalid(qsfp1_mac_3_tx_axis_tvalid_int),
    .qsfp1_mac_3_tx_axis_tready(qsfp1_mac_3_tx_axis_tready_int),
    .qsfp1_mac_3_tx_axis_tlast(qsfp1_mac_3_tx_axis_tlast_int),
    .qsfp1_mac_3_tx_axis_tuser(qsfp1_mac_3_tx_axis_tuser_int),

    .qsfp1_mac_4_rx_clk(qsfp1_mac_4_clk_int),
    .qsfp1_mac_4_rx_rst(qsfp1_mac_4_rst_int),
    .qsfp1_mac_4_rx_axis_tdata(qsfp1_mac_4_rx_axis_tdata_int),
    .qsfp1_mac_4_rx_axis_tkeep(qsfp1_mac_4_rx_axis_tkeep_int),
    .qsfp1_mac_4_rx_axis_tvalid(qsfp1_mac_4_rx_axis_tvalid_int),
    .qsfp1_mac_4_rx_axis_tlast(qsfp1_mac_4_rx_axis_tlast_int),
    .qsfp1_mac_4_rx_axis_tuser(qsfp1_mac_4_rx_axis_tuser_int),

    .qsfp1_mac_4_tx_clk(qsfp1_mac_4_clk_int),
    .qsfp1_mac_4_tx_rst(qsfp1_mac_4_rst_int),
    .qsfp1_mac_4_tx_axis_tdata(qsfp1_mac_4_tx_axis_tdata_int),
    .qsfp1_mac_4_tx_axis_tkeep(qsfp1_mac_4_tx_axis_tkeep_int),
    .qsfp1_mac_4_tx_axis_tvalid(qsfp1_mac_4_tx_axis_tvalid_int),
    .qsfp1_mac_4_tx_axis_tready(qsfp1_mac_4_tx_axis_tready_int),
    .qsfp1_mac_4_tx_axis_tlast(qsfp1_mac_4_tx_axis_tlast_int),
    .qsfp1_mac_4_tx_axis_tuser(qsfp1_mac_4_tx_axis_tuser_int),

    .qsfp2_mac_1_rx_clk(qsfp2_mac_1_clk_int),
    .qsfp2_mac_1_rx_rst(qsfp2_mac_1_rst_int),
    .qsfp2_mac_1_rx_axis_tdata(qsfp2_mac_1_rx_axis_tdata_int),
    .qsfp2_mac_1_rx_axis_tkeep(qsfp2_mac_1_rx_axis_tkeep_int),
    .qsfp2_mac_1_rx_axis_tvalid(qsfp2_mac_1_rx_axis_tvalid_int),
    .qsfp2_mac_1_rx_axis_tlast(qsfp2_mac_1_rx_axis_tlast_int),
    .qsfp2_mac_1_rx_axis_tuser(qsfp2_mac_1_rx_axis_tuser_int),

    .qsfp2_mac_1_tx_clk(qsfp2_mac_1_clk_int),
    .qsfp2_mac_1_tx_rst(qsfp2_mac_1_rst_int),
    .qsfp2_mac_1_tx_axis_tdata(qsfp2_mac_1_tx_axis_tdata_int),
    .qsfp2_mac_1_tx_axis_tkeep(qsfp2_mac_1_tx_axis_tkeep_int),
    .qsfp2_mac_1_tx_axis_tvalid(qsfp2_mac_1_tx_axis_tvalid_int),
    .qsfp2_mac_1_tx_axis_tready(qsfp2_mac_1_tx_axis_tready_int),
    .qsfp2_mac_1_tx_axis_tlast(qsfp2_mac_1_tx_axis_tlast_int),
    .qsfp2_mac_1_tx_axis_tuser(qsfp2_mac_1_tx_axis_tuser_int),

    .qsfp2_mac_2_rx_clk(qsfp2_mac_2_clk_int),
    .qsfp2_mac_2_rx_rst(qsfp2_mac_2_rst_int),
    .qsfp2_mac_2_rx_axis_tdata(qsfp2_mac_2_rx_axis_tdata_int),
    .qsfp2_mac_2_rx_axis_tkeep(qsfp2_mac_2_rx_axis_tkeep_int),
    .qsfp2_mac_2_rx_axis_tvalid(qsfp2_mac_2_rx_axis_tvalid_int),
    .qsfp2_mac_2_rx_axis_tlast(qsfp2_mac_2_rx_axis_tlast_int),
    .qsfp2_mac_2_rx_axis_tuser(qsfp2_mac_2_rx_axis_tuser_int),

    .qsfp2_mac_2_tx_clk(qsfp2_mac_2_clk_int),
    .qsfp2_mac_2_tx_rst(qsfp2_mac_2_rst_int),
    .qsfp2_mac_2_tx_axis_tdata(qsfp2_mac_2_tx_axis_tdata_int),
    .qsfp2_mac_2_tx_axis_tkeep(qsfp2_mac_2_tx_axis_tkeep_int),
    .qsfp2_mac_2_tx_axis_tvalid(qsfp2_mac_2_tx_axis_tvalid_int),
    .qsfp2_mac_2_tx_axis_tready(qsfp2_mac_2_tx_axis_tready_int),
    .qsfp2_mac_2_tx_axis_tlast(qsfp2_mac_2_tx_axis_tlast_int),
    .qsfp2_mac_2_tx_axis_tuser(qsfp2_mac_2_tx_axis_tuser_int),

    .qsfp2_mac_3_rx_clk(qsfp2_mac_3_clk_int),
    .qsfp2_mac_3_rx_rst(qsfp2_mac_3_rst_int),
    .qsfp2_mac_3_rx_axis_tdata(qsfp2_mac_3_rx_axis_tdata_int),
    .qsfp2_mac_3_rx_axis_tkeep(qsfp2_mac_3_rx_axis_tkeep_int),
    .qsfp2_mac_3_rx_axis_tvalid(qsfp2_mac_3_rx_axis_tvalid_int),
    .qsfp2_mac_3_rx_axis_tlast(qsfp2_mac_3_rx_axis_tlast_int),
    .qsfp2_mac_3_rx_axis_tuser(qsfp2_mac_3_rx_axis_tuser_int),

    .qsfp2_mac_3_tx_clk(qsfp2_mac_3_clk_int),
    .qsfp2_mac_3_tx_rst(qsfp2_mac_3_rst_int),
    .qsfp2_mac_3_tx_axis_tdata(qsfp2_mac_3_tx_axis_tdata_int),
    .qsfp2_mac_3_tx_axis_tkeep(qsfp2_mac_3_tx_axis_tkeep_int),
    .qsfp2_mac_3_tx_axis_tvalid(qsfp2_mac_3_tx_axis_tvalid_int),
    .qsfp2_mac_3_tx_axis_tready(qsfp2_mac_3_tx_axis_tready_int),
    .qsfp2_mac_3_tx_axis_tlast(qsfp2_mac_3_tx_axis_tlast_int),
    .qsfp2_mac_3_tx_axis_tuser(qsfp2_mac_3_tx_axis_tuser_int),

    .qsfp2_mac_4_rx_clk(qsfp2_mac_4_clk_int),
    .qsfp2_mac_4_rx_rst(qsfp2_mac_4_rst_int),
    .qsfp2_mac_4_rx_axis_tdata(qsfp2_mac_4_rx_axis_tdata_int),
    .qsfp2_mac_4_rx_axis_tkeep(qsfp2_mac_4_rx_axis_tkeep_int),
    .qsfp2_mac_4_rx_axis_tvalid(qsfp2_mac_4_rx_axis_tvalid_int),
    .qsfp2_mac_4_rx_axis_tlast(qsfp2_mac_4_rx_axis_tlast_int),
    .qsfp2_mac_4_rx_axis_tuser(qsfp2_mac_4_rx_axis_tuser_int),

    .qsfp2_mac_4_tx_clk(qsfp2_mac_4_clk_int),
    .qsfp2_mac_4_tx_rst(qsfp2_mac_4_rst_int),
    .qsfp2_mac_4_tx_axis_tdata(qsfp2_mac_4_tx_axis_tdata_int),
    .qsfp2_mac_4_tx_axis_tkeep(qsfp2_mac_4_tx_axis_tkeep_int),
    .qsfp2_mac_4_tx_axis_tvalid(qsfp2_mac_4_tx_axis_tvalid_int),
    .qsfp2_mac_4_tx_axis_tready(qsfp2_mac_4_tx_axis_tready_int),
    .qsfp2_mac_4_tx_axis_tlast(qsfp2_mac_4_tx_axis_tlast_int),
    .qsfp2_mac_4_tx_axis_tuser(qsfp2_mac_4_tx_axis_tuser_int)
);

endmodule

`resetall
