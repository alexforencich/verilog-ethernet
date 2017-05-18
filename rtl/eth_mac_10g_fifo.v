/*

Copyright (c) 2015-2017 Alex Forencich

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
 * 10G Ethernet MAC with TX and RX FIFOs
 */
module eth_mac_10g_fifo #
(
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_FIFO_ADDR_WIDTH = 9,
    parameter RX_FIFO_ADDR_WIDTH = 9
)
(
    input  wire        rx_clk,
    input  wire        rx_rst,
    input  wire        tx_clk,
    input  wire        tx_rst,
    input  wire        logic_clk,
    input  wire        logic_rst,

    /*
     * AXI input
     */
    input  wire [63:0] tx_axis_tdata,
    input  wire [7:0]  tx_axis_tkeep,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [63:0] rx_axis_tdata,
    output wire [7:0]  rx_axis_tkeep,
    output wire        rx_axis_tvalid,
    input  wire        rx_axis_tready,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,

    /*
     * XGMII interface
     */
    input  wire [63:0] xgmii_rxd,
    input  wire [7:0]  xgmii_rxc,
    output wire [63:0] xgmii_txd,
    output wire [7:0]  xgmii_txc,

    /*
     * Status
     */
    output wire        tx_fifo_overflow,
    output wire        tx_fifo_bad_frame,
    output wire        tx_fifo_good_frame,
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,
    output wire        rx_fifo_overflow,
    output wire        rx_fifo_bad_frame,
    output wire        rx_fifo_good_frame,

    /*
     * Configuration
     */
    input  wire [7:0]  ifg_delay
);

wire [63:0] tx_fifo_axis_tdata;
wire [7:0]  tx_fifo_axis_tkeep;
wire        tx_fifo_axis_tvalid;
wire        tx_fifo_axis_tready;
wire        tx_fifo_axis_tlast;
wire        tx_fifo_axis_tuser;

wire [63:0] rx_fifo_axis_tdata;
wire [7:0]  rx_fifo_axis_tkeep;
wire        rx_fifo_axis_tvalid;
wire        rx_fifo_axis_tlast;
wire        rx_fifo_axis_tuser;

// synchronize MAC status signals into logic clock domain
wire rx_error_bad_frame_int;
wire rx_error_bad_fcs_int;

reg [1:0] rx_sync_reg_1 = 2'd0;
reg [1:0] rx_sync_reg_2 = 2'd0;
reg [1:0] rx_sync_reg_3 = 2'd0;
reg [1:0] rx_sync_reg_4 = 2'd0;

assign rx_error_bad_frame = rx_sync_reg_3[0] ^ rx_sync_reg_4[0];
assign rx_error_bad_fcs = rx_sync_reg_3[1] ^ rx_sync_reg_4[1];

always @(posedge rx_clk or posedge rx_rst) begin
    if (rx_rst) begin
        rx_sync_reg_1 <= 2'd0;
    end else begin
        rx_sync_reg_1 <= rx_sync_reg_1 ^ {rx_error_bad_frame_int, rx_error_bad_frame_int};
    end
end

always @(posedge logic_clk or posedge logic_rst) begin
    if (logic_rst) begin
        rx_sync_reg_2 <= 2'd0;
        rx_sync_reg_3 <= 2'd0;
        rx_sync_reg_4 <= 2'd0;
    end else begin
        rx_sync_reg_2 <= rx_sync_reg_1;
        rx_sync_reg_3 <= rx_sync_reg_2;
        rx_sync_reg_4 <= rx_sync_reg_3;
    end
end

eth_mac_10g #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_10g_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_axis_tdata(tx_fifo_axis_tdata),
    .tx_axis_tkeep(tx_fifo_axis_tkeep),
    .tx_axis_tvalid(tx_fifo_axis_tvalid),
    .tx_axis_tready(tx_fifo_axis_tready),
    .tx_axis_tlast(tx_fifo_axis_tlast),
    .tx_axis_tuser(tx_fifo_axis_tuser),
    .rx_axis_tdata(rx_fifo_axis_tdata),
    .rx_axis_tkeep(rx_fifo_axis_tkeep),
    .rx_axis_tvalid(rx_fifo_axis_tvalid),
    .rx_axis_tlast(rx_fifo_axis_tlast),
    .rx_axis_tuser(rx_fifo_axis_tuser),
    .xgmii_rxd(xgmii_rxd),
    .xgmii_rxc(xgmii_rxc),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .rx_error_bad_frame(rx_error_bad_frame_int),
    .rx_error_bad_fcs(rx_error_bad_fcs_int),
    .ifg_delay(ifg_delay)
);

axis_async_frame_fifo_64 #(
    .ADDR_WIDTH(TX_FIFO_ADDR_WIDTH),
    .DATA_WIDTH(64),
    .DROP_WHEN_FULL(0)
)
tx_fifo (
    // Common reset
    .async_rst(logic_rst | tx_rst),
    // AXI input
    .input_clk(logic_clk),
    .input_axis_tdata(tx_axis_tdata),
    .input_axis_tkeep(tx_axis_tkeep),
    .input_axis_tvalid(tx_axis_tvalid),
    .input_axis_tready(tx_axis_tready),
    .input_axis_tlast(tx_axis_tlast),
    .input_axis_tuser(tx_axis_tuser),
    // AXI output
    .output_clk(tx_clk),
    .output_axis_tdata(tx_fifo_axis_tdata),
    .output_axis_tkeep(tx_fifo_axis_tkeep),
    .output_axis_tvalid(tx_fifo_axis_tvalid),
    .output_axis_tready(tx_fifo_axis_tready),
    .output_axis_tlast(tx_fifo_axis_tlast),
    // Status
    .input_status_overflow(tx_fifo_overflow),
    .input_status_bad_frame(tx_fifo_bad_frame),
    .input_status_good_frame(tx_fifo_good_frame),
    .output_status_overflow(),
    .output_status_bad_frame(),
    .output_status_good_frame()
);

assign tx_fifo_axis_tuser = 1'b0;

axis_async_frame_fifo_64 #(
    .ADDR_WIDTH(RX_FIFO_ADDR_WIDTH),
    .DATA_WIDTH(64),
    .DROP_WHEN_FULL(1)
)
rx_fifo (
    // Common reset
    .async_rst(rx_rst | logic_rst),
    // AXI input
    .input_clk(rx_clk),
    .input_axis_tdata(rx_fifo_axis_tdata),
    .input_axis_tkeep(rx_fifo_axis_tkeep),
    .input_axis_tvalid(rx_fifo_axis_tvalid),
    .input_axis_tready(),
    .input_axis_tlast(rx_fifo_axis_tlast),
    .input_axis_tuser(rx_fifo_axis_tuser),
    // AXI output
    .output_clk(logic_clk),
    .output_axis_tdata(rx_axis_tdata),
    .output_axis_tkeep(rx_axis_tkeep),
    .output_axis_tvalid(rx_axis_tvalid),
    .output_axis_tready(rx_axis_tready),
    .output_axis_tlast(rx_axis_tlast),
    // Status
    .input_status_overflow(),
    .input_status_bad_frame(),
    .input_status_good_frame(),
    .output_status_overflow(rx_fifo_overflow),
    .output_status_bad_frame(rx_fifo_bad_frame),
    .output_status_good_frame(rx_fifo_good_frame)
);

assign rx_axis_tuser = 1'b0;

endmodule
