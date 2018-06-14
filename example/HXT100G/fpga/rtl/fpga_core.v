/*

Copyright (c) 2016-2018 Alex Forencich

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

`timescale 1 ns / 1 ps

module fpga_core
(
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    input  wire clk,
    input  wire rst,
    /*
     * GPIO
     */
    input  wire [1:0] sw,
    input  wire [3:0] jp,
    output wire [3:0] led,
    /*
     * Silicon Labs CP2102 USB UART
     */
    output wire uart_rst,
    input  wire uart_suspend,
    output wire uart_ri,
    output wire uart_dcd,
    input  wire uart_dtr,
    output wire uart_dsr,
    input  wire uart_txd,
    output wire uart_rxd,
    input  wire uart_rts,
    output wire uart_cts,
    /*
     * AirMax I/O
     */
    output wire amh_right_mdc,
    input  wire amh_right_mdio_i,
    output wire amh_right_mdio_o,
    output wire amh_right_mdio_t,
    output wire amh_left_mdc,
    input  wire amh_left_mdio_i,
    output wire amh_left_mdio_o,
    output wire amh_left_mdio_t,
    /*
     * 10G Ethernet
     */
    output wire [63:0] eth_r0_txd,
    output wire [7:0]  eth_r0_txc,
    input  wire [63:0] eth_r0_rxd,
    input  wire [7:0]  eth_r0_rxc,
    output wire [63:0] eth_r1_txd,
    output wire [7:0]  eth_r1_txc,
    input  wire [63:0] eth_r1_rxd,
    input  wire [7:0]  eth_r1_rxc,
    output wire [63:0] eth_r2_txd,
    output wire [7:0]  eth_r2_txc,
    input  wire [63:0] eth_r2_rxd,
    input  wire [7:0]  eth_r2_rxc,
    output wire [63:0] eth_r3_txd,
    output wire [7:0]  eth_r3_txc,
    input  wire [63:0] eth_r3_rxd,
    input  wire [7:0]  eth_r3_rxc,
    output wire [63:0] eth_r4_txd,
    output wire [7:0]  eth_r4_txc,
    input  wire [63:0] eth_r4_rxd,
    input  wire [7:0]  eth_r4_rxc,
    output wire [63:0] eth_r5_txd,
    output wire [7:0]  eth_r5_txc,
    input  wire [63:0] eth_r5_rxd,
    input  wire [7:0]  eth_r5_rxc,
    output wire [63:0] eth_r6_txd,
    output wire [7:0]  eth_r6_txc,
    input  wire [63:0] eth_r6_rxd,
    input  wire [7:0]  eth_r6_rxc,
    output wire [63:0] eth_r7_txd,
    output wire [7:0]  eth_r7_txc,
    input  wire [63:0] eth_r7_rxd,
    input  wire [7:0]  eth_r7_rxc,
    output wire [63:0] eth_r8_txd,
    output wire [7:0]  eth_r8_txc,
    input  wire [63:0] eth_r8_rxd,
    input  wire [7:0]  eth_r8_rxc,
    output wire [63:0] eth_r9_txd,
    output wire [7:0]  eth_r9_txc,
    input  wire [63:0] eth_r9_rxd,
    input  wire [7:0]  eth_r9_rxc,
    output wire [63:0] eth_r10_txd,
    output wire [7:0]  eth_r10_txc,
    input  wire [63:0] eth_r10_rxd,
    input  wire [7:0]  eth_r10_rxc,
    output wire [63:0] eth_r11_txd,
    output wire [7:0]  eth_r11_txc,
    input  wire [63:0] eth_r11_rxd,
    input  wire [7:0]  eth_r11_rxc,
    output wire [63:0] eth_l0_txd,
    output wire [7:0]  eth_l0_txc,
    input  wire [63:0] eth_l0_rxd,
    input  wire [7:0]  eth_l0_rxc,
    output wire [63:0] eth_l1_txd,
    output wire [7:0]  eth_l1_txc,
    input  wire [63:0] eth_l1_rxd,
    input  wire [7:0]  eth_l1_rxc,
    output wire [63:0] eth_l2_txd,
    output wire [7:0]  eth_l2_txc,
    input  wire [63:0] eth_l2_rxd,
    input  wire [7:0]  eth_l2_rxc,
    output wire [63:0] eth_l3_txd,
    output wire [7:0]  eth_l3_txc,
    input  wire [63:0] eth_l3_rxd,
    input  wire [7:0]  eth_l3_rxc,
    output wire [63:0] eth_l4_txd,
    output wire [7:0]  eth_l4_txc,
    input  wire [63:0] eth_l4_rxd,
    input  wire [7:0]  eth_l4_rxc,
    output wire [63:0] eth_l5_txd,
    output wire [7:0]  eth_l5_txc,
    input  wire [63:0] eth_l5_rxd,
    input  wire [7:0]  eth_l5_rxc,
    output wire [63:0] eth_l6_txd,
    output wire [7:0]  eth_l6_txc,
    input  wire [63:0] eth_l6_rxd,
    input  wire [7:0]  eth_l6_rxc,
    output wire [63:0] eth_l7_txd,
    output wire [7:0]  eth_l7_txc,
    input  wire [63:0] eth_l7_rxd,
    input  wire [7:0]  eth_l7_rxc,
    output wire [63:0] eth_l8_txd,
    output wire [7:0]  eth_l8_txc,
    input  wire [63:0] eth_l8_rxd,
    input  wire [7:0]  eth_l8_rxc,
    output wire [63:0] eth_l9_txd,
    output wire [7:0]  eth_l9_txc,
    input  wire [63:0] eth_l9_rxd,
    input  wire [7:0]  eth_l9_rxc,
    output wire [63:0] eth_l10_txd,
    output wire [7:0]  eth_l10_txc,
    input  wire [63:0] eth_l10_rxd,
    input  wire [7:0]  eth_l10_rxc,
    output wire [63:0] eth_l11_txd,
    output wire [7:0]  eth_l11_txc,
    input  wire [63:0] eth_l11_rxd,
    input  wire [7:0]  eth_l11_rxc
);

// UART
assign uart_rst = 1'b1;
assign uart_txd = 1'b1;

// AirMax I/O
assign amh_right_mdc = 1'b1;
assign amh_right_mdio_o = 1'b1;
assign amh_right_mdio_t = 1'b1;
assign amh_left_mdc = 1'b1;
assign amh_left_mdio_o = 1'b1;
assign amh_left_mdio_t = 1'b1;

// AXI between MAC and Ethernet modules
wire [63:0] rx_axis_tdata;
wire [7:0] rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tready;
wire rx_axis_tlast;
wire rx_axis_tuser;

wire [63:0] tx_axis_tdata;
wire [7:0] tx_axis_tkeep;
wire tx_axis_tvalid;
wire tx_axis_tready;
wire tx_axis_tlast;
wire tx_axis_tuser;

// Ethernet frame between Ethernet modules and UDP stack
wire rx_eth_hdr_ready;
wire rx_eth_hdr_valid;
wire [47:0] rx_eth_dest_mac;
wire [47:0] rx_eth_src_mac;
wire [15:0] rx_eth_type;
wire [63:0] rx_eth_payload_tdata;
wire [7:0] rx_eth_payload_tkeep;
wire rx_eth_payload_tvalid;
wire rx_eth_payload_tready;
wire rx_eth_payload_tlast;
wire rx_eth_payload_tuser;

wire tx_eth_hdr_ready;
wire tx_eth_hdr_valid;
wire [47:0] tx_eth_dest_mac;
wire [47:0] tx_eth_src_mac;
wire [15:0] tx_eth_type;
wire [63:0] tx_eth_payload_tdata;
wire [7:0] tx_eth_payload_tkeep;
wire tx_eth_payload_tvalid;
wire tx_eth_payload_tready;
wire tx_eth_payload_tlast;
wire tx_eth_payload_tuser;

// IP frame connections
wire rx_ip_hdr_valid;
wire rx_ip_hdr_ready;
wire [47:0] rx_ip_eth_dest_mac;
wire [47:0] rx_ip_eth_src_mac;
wire [15:0] rx_ip_eth_type;
wire [3:0] rx_ip_version;
wire [3:0] rx_ip_ihl;
wire [5:0] rx_ip_dscp;
wire [1:0] rx_ip_ecn;
wire [15:0] rx_ip_length;
wire [15:0] rx_ip_identification;
wire [2:0] rx_ip_flags;
wire [12:0] rx_ip_fragment_offset;
wire [7:0] rx_ip_ttl;
wire [7:0] rx_ip_protocol;
wire [15:0] rx_ip_header_checksum;
wire [31:0] rx_ip_source_ip;
wire [31:0] rx_ip_dest_ip;
wire [63:0] rx_ip_payload_tdata;
wire [7:0] rx_ip_payload_tkeep;
wire rx_ip_payload_tvalid;
wire rx_ip_payload_tready;
wire rx_ip_payload_tlast;
wire rx_ip_payload_tuser;

wire tx_ip_hdr_valid;
wire tx_ip_hdr_ready;
wire [5:0] tx_ip_dscp;
wire [1:0] tx_ip_ecn;
wire [15:0] tx_ip_length;
wire [7:0] tx_ip_ttl;
wire [7:0] tx_ip_protocol;
wire [31:0] tx_ip_source_ip;
wire [31:0] tx_ip_dest_ip;
wire [63:0] tx_ip_payload_tdata;
wire [7:0] tx_ip_payload_tkeep;
wire tx_ip_payload_tvalid;
wire tx_ip_payload_tready;
wire tx_ip_payload_tlast;
wire tx_ip_payload_tuser;

// UDP frame connections
wire rx_udp_hdr_valid;
wire rx_udp_hdr_ready;
wire [47:0] rx_udp_eth_dest_mac;
wire [47:0] rx_udp_eth_src_mac;
wire [15:0] rx_udp_eth_type;
wire [3:0] rx_udp_ip_version;
wire [3:0] rx_udp_ip_ihl;
wire [5:0] rx_udp_ip_dscp;
wire [1:0] rx_udp_ip_ecn;
wire [15:0] rx_udp_ip_length;
wire [15:0] rx_udp_ip_identification;
wire [2:0] rx_udp_ip_flags;
wire [12:0] rx_udp_ip_fragment_offset;
wire [7:0] rx_udp_ip_ttl;
wire [7:0] rx_udp_ip_protocol;
wire [15:0] rx_udp_ip_header_checksum;
wire [31:0] rx_udp_ip_source_ip;
wire [31:0] rx_udp_ip_dest_ip;
wire [15:0] rx_udp_source_port;
wire [15:0] rx_udp_dest_port;
wire [15:0] rx_udp_length;
wire [15:0] rx_udp_checksum;
wire [63:0] rx_udp_payload_tdata;
wire [7:0] rx_udp_payload_tkeep;
wire rx_udp_payload_tvalid;
wire rx_udp_payload_tready;
wire rx_udp_payload_tlast;
wire rx_udp_payload_tuser;

wire tx_udp_hdr_valid;
wire tx_udp_hdr_ready;
wire [5:0] tx_udp_ip_dscp;
wire [1:0] tx_udp_ip_ecn;
wire [7:0] tx_udp_ip_ttl;
wire [31:0] tx_udp_ip_source_ip;
wire [31:0] tx_udp_ip_dest_ip;
wire [15:0] tx_udp_source_port;
wire [15:0] tx_udp_dest_port;
wire [15:0] tx_udp_length;
wire [15:0] tx_udp_checksum;
wire [63:0] tx_udp_payload_tdata;
wire [7:0] tx_udp_payload_tkeep;
wire tx_udp_payload_tvalid;
wire tx_udp_payload_tready;
wire tx_udp_payload_tlast;
wire tx_udp_payload_tuser;

wire [63:0] rx_fifo_udp_payload_tdata;
wire [7:0] rx_fifo_udp_payload_tkeep;
wire rx_fifo_udp_payload_tvalid;
wire rx_fifo_udp_payload_tready;
wire rx_fifo_udp_payload_tlast;
wire rx_fifo_udp_payload_tuser;

wire [63:0] tx_fifo_udp_payload_tdata;
wire [7:0] tx_fifo_udp_payload_tkeep;
wire tx_fifo_udp_payload_tvalid;
wire tx_fifo_udp_payload_tready;
wire tx_fifo_udp_payload_tlast;
wire tx_fifo_udp_payload_tuser;

// Configuration
wire [47:0] local_mac   = 48'h02_00_00_00_00_00;
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd1,   8'd128};
wire [31:0] gateway_ip  = {8'd192, 8'd168, 8'd1,   8'd1};
wire [31:0] subnet_mask = {8'd255, 8'd255, 8'd255, 8'd0};

// IP ports not used
assign rx_ip_hdr_ready = 1;
assign rx_ip_payload_tready = 1;

assign tx_ip_hdr_valid = 0;
assign tx_ip_dscp = 0;
assign tx_ip_ecn = 0;
assign tx_ip_length = 0;
assign tx_ip_ttl = 0;
assign tx_ip_protocol = 0;
assign tx_ip_source_ip = 0;
assign tx_ip_dest_ip = 0;
assign tx_ip_payload_tdata = 0;
assign tx_ip_payload_tkeep = 0;
assign tx_ip_payload_tvalid = 0;
assign tx_ip_payload_tlast = 0;
assign tx_ip_payload_tuser = 0;

// Loop back UDP
wire match_cond = rx_udp_dest_port == 1234;
wire no_match = ~match_cond;

reg match_cond_reg = 0;
reg no_match_reg = 0;

always @(posedge clk) begin
    if (rst) begin
        match_cond_reg <= 0;
        no_match_reg <= 0;
    end else begin
        if (rx_udp_payload_tvalid) begin
            if ((~match_cond_reg & ~no_match_reg) |
                (rx_udp_payload_tvalid & rx_udp_payload_tready & rx_udp_payload_tlast)) begin
                match_cond_reg <= match_cond;
                no_match_reg <= no_match;
            end
        end else begin
            match_cond_reg <= 0;
            no_match_reg <= 0;
        end
    end
end

assign tx_udp_hdr_valid = rx_udp_hdr_valid & match_cond;
assign rx_udp_hdr_ready = (tx_eth_hdr_ready & match_cond) | no_match;
assign tx_udp_ip_dscp = 0;
assign tx_udp_ip_ecn = 0;
assign tx_udp_ip_ttl = 64;
assign tx_udp_ip_source_ip = local_ip;
assign tx_udp_ip_dest_ip = rx_udp_ip_source_ip;
assign tx_udp_source_port = rx_udp_dest_port;
assign tx_udp_dest_port = rx_udp_source_port;
assign tx_udp_length = rx_udp_length;
assign tx_udp_checksum = 0;
//assign tx_udp_payload_tdata = rx_udp_payload_tdata;
//assign tx_udp_payload_tkeep = rx_udp_payload_tkeep;
//assign tx_udp_payload_tvalid = rx_udp_payload_tvalid;
//assign rx_udp_payload_tready = tx_udp_payload_tready;
//assign tx_udp_payload_tlast = rx_udp_payload_tlast;
//assign tx_udp_payload_tuser = rx_udp_payload_tuser;

assign tx_udp_payload_tdata = tx_fifo_udp_payload_tdata;
assign tx_udp_payload_tkeep = tx_fifo_udp_payload_tkeep;
assign tx_udp_payload_tvalid = tx_fifo_udp_payload_tvalid;
assign tx_fifo_udp_payload_tready = tx_udp_payload_tready;
assign tx_udp_payload_tlast = tx_fifo_udp_payload_tlast;
assign tx_udp_payload_tuser = tx_fifo_udp_payload_tuser;

assign rx_fifo_udp_payload_tdata = rx_udp_payload_tdata;
assign rx_fifo_udp_payload_tkeep = rx_udp_payload_tkeep;
assign rx_fifo_udp_payload_tvalid = rx_udp_payload_tvalid & match_cond_reg;
assign rx_udp_payload_tready = (rx_fifo_udp_payload_tready & match_cond_reg) | no_match_reg;
assign rx_fifo_udp_payload_tlast = rx_udp_payload_tlast;
assign rx_fifo_udp_payload_tuser = rx_udp_payload_tuser;

// Place first payload byte onto LEDs
reg valid_last = 0;
reg [7:0] led_reg = 0;

always @(posedge clk) begin
    if (rst) begin
        led_reg <= 0;
    end else begin
        if (tx_udp_payload_tvalid) begin
            if (~valid_last) begin
                led_reg <= tx_udp_payload_tdata;
                valid_last <= 1'b1;
            end
            if (tx_udp_payload_tlast) begin
                valid_last <= 1'b0;
            end
        end
    end
end

//assign led = sw;
assign led = led_reg;

assign eth_r0_txd = 64'h0707070707070707;
assign eth_r0_txc = 8'hff;
assign eth_r1_txd = 64'h0707070707070707;
assign eth_r1_txc = 8'hff;
assign eth_r2_txd = 64'h0707070707070707;
assign eth_r2_txc = 8'hff;
assign eth_r3_txd = 64'h0707070707070707;
assign eth_r3_txc = 8'hff;
assign eth_r4_txd = 64'h0707070707070707;
assign eth_r4_txc = 8'hff;
assign eth_r5_txd = 64'h0707070707070707;
assign eth_r5_txc = 8'hff;
assign eth_r6_txd = 64'h0707070707070707;
assign eth_r6_txc = 8'hff;
assign eth_r7_txd = 64'h0707070707070707;
assign eth_r7_txc = 8'hff;
assign eth_r8_txd = 64'h0707070707070707;
assign eth_r8_txc = 8'hff;
assign eth_r9_txd = 64'h0707070707070707;
assign eth_r9_txc = 8'hff;
assign eth_r10_txd = 64'h0707070707070707;
assign eth_r10_txc = 8'hff;
assign eth_r11_txd = 64'h0707070707070707;
assign eth_r11_txc = 8'hff;

//assign eth_l0_txd = 64'h0707070707070707;
//assign eth_l0_txc = 8'hff;
assign eth_l1_txd = 64'h0707070707070707;
assign eth_l1_txc = 8'hff;
assign eth_l2_txd = 64'h0707070707070707;
assign eth_l2_txc = 8'hff;
assign eth_l3_txd = 64'h0707070707070707;
assign eth_l3_txc = 8'hff;
assign eth_l4_txd = 64'h0707070707070707;
assign eth_l4_txc = 8'hff;
assign eth_l5_txd = 64'h0707070707070707;
assign eth_l5_txc = 8'hff;
assign eth_l6_txd = 64'h0707070707070707;
assign eth_l6_txc = 8'hff;
assign eth_l7_txd = 64'h0707070707070707;
assign eth_l7_txc = 8'hff;
assign eth_l8_txd = 64'h0707070707070707;
assign eth_l8_txc = 8'hff;
assign eth_l9_txd = 64'h0707070707070707;
assign eth_l9_txc = 8'hff;
assign eth_l10_txd = 64'h0707070707070707;
assign eth_l10_txc = 8'hff;
assign eth_l11_txd = 64'h0707070707070707;
assign eth_l11_txc = 8'hff;

eth_mac_10g_fifo #(
    .ENABLE_PADDING(1),
    .ENABLE_DIC(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_ADDR_WIDTH(9),
    .RX_FIFO_ADDR_WIDTH(9)
)
eth_mac_10g_fifo_inst (
    .rx_clk(clk),
    .rx_rst(rst),
    .tx_clk(clk),
    .tx_rst(rst),
    .logic_clk(clk),
    .logic_rst(rst),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .xgmii_rxd(eth_l0_rxd),
    .xgmii_rxc(eth_l0_rxc),
    .xgmii_txd(eth_l0_txd),
    .xgmii_txc(eth_l0_txc),

    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),

    .ifg_delay(8'd12)
);

eth_axis_rx_64
eth_axis_rx_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(rx_axis_tdata),
    .input_axis_tkeep(rx_axis_tkeep),
    .input_axis_tvalid(rx_axis_tvalid),
    .input_axis_tready(rx_axis_tready),
    .input_axis_tlast(rx_axis_tlast),
    .input_axis_tuser(rx_axis_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(rx_eth_hdr_valid),
    .output_eth_hdr_ready(rx_eth_hdr_ready),
    .output_eth_dest_mac(rx_eth_dest_mac),
    .output_eth_src_mac(rx_eth_src_mac),
    .output_eth_type(rx_eth_type),
    .output_eth_payload_tdata(rx_eth_payload_tdata),
    .output_eth_payload_tkeep(rx_eth_payload_tkeep),
    .output_eth_payload_tvalid(rx_eth_payload_tvalid),
    .output_eth_payload_tready(rx_eth_payload_tready),
    .output_eth_payload_tlast(rx_eth_payload_tlast),
    .output_eth_payload_tuser(rx_eth_payload_tuser),
    // Status signals
    .busy(),
    .error_header_early_termination()
);

eth_axis_tx_64
eth_axis_tx_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(tx_eth_hdr_valid),
    .input_eth_hdr_ready(tx_eth_hdr_ready),
    .input_eth_dest_mac(tx_eth_dest_mac),
    .input_eth_src_mac(tx_eth_src_mac),
    .input_eth_type(tx_eth_type),
    .input_eth_payload_tdata(tx_eth_payload_tdata),
    .input_eth_payload_tkeep(tx_eth_payload_tkeep),
    .input_eth_payload_tvalid(tx_eth_payload_tvalid),
    .input_eth_payload_tready(tx_eth_payload_tready),
    .input_eth_payload_tlast(tx_eth_payload_tlast),
    .input_eth_payload_tuser(tx_eth_payload_tuser),
    // AXI output
    .output_axis_tdata(tx_axis_tdata),
    .output_axis_tkeep(tx_axis_tkeep),
    .output_axis_tvalid(tx_axis_tvalid),
    .output_axis_tready(tx_axis_tready),
    .output_axis_tlast(tx_axis_tlast),
    .output_axis_tuser(tx_axis_tuser),
    // Status signals
    .busy()
);

udp_complete_64
udp_complete_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(rx_eth_hdr_valid),
    .input_eth_hdr_ready(rx_eth_hdr_ready),
    .input_eth_dest_mac(rx_eth_dest_mac),
    .input_eth_src_mac(rx_eth_src_mac),
    .input_eth_type(rx_eth_type),
    .input_eth_payload_tdata(rx_eth_payload_tdata),
    .input_eth_payload_tkeep(rx_eth_payload_tkeep),
    .input_eth_payload_tvalid(rx_eth_payload_tvalid),
    .input_eth_payload_tready(rx_eth_payload_tready),
    .input_eth_payload_tlast(rx_eth_payload_tlast),
    .input_eth_payload_tuser(rx_eth_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(tx_eth_hdr_valid),
    .output_eth_hdr_ready(tx_eth_hdr_ready),
    .output_eth_dest_mac(tx_eth_dest_mac),
    .output_eth_src_mac(tx_eth_src_mac),
    .output_eth_type(tx_eth_type),
    .output_eth_payload_tdata(tx_eth_payload_tdata),
    .output_eth_payload_tkeep(tx_eth_payload_tkeep),
    .output_eth_payload_tvalid(tx_eth_payload_tvalid),
    .output_eth_payload_tready(tx_eth_payload_tready),
    .output_eth_payload_tlast(tx_eth_payload_tlast),
    .output_eth_payload_tuser(tx_eth_payload_tuser),
    // IP frame input
    .input_ip_hdr_valid(tx_ip_hdr_valid),
    .input_ip_hdr_ready(tx_ip_hdr_ready),
    .input_ip_dscp(tx_ip_dscp),
    .input_ip_ecn(tx_ip_ecn),
    .input_ip_length(tx_ip_length),
    .input_ip_ttl(tx_ip_ttl),
    .input_ip_protocol(tx_ip_protocol),
    .input_ip_source_ip(tx_ip_source_ip),
    .input_ip_dest_ip(tx_ip_dest_ip),
    .input_ip_payload_tdata(tx_ip_payload_tdata),
    .input_ip_payload_tkeep(tx_ip_payload_tkeep),
    .input_ip_payload_tvalid(tx_ip_payload_tvalid),
    .input_ip_payload_tready(tx_ip_payload_tready),
    .input_ip_payload_tlast(tx_ip_payload_tlast),
    .input_ip_payload_tuser(tx_ip_payload_tuser),
    // IP frame output
    .output_ip_hdr_valid(rx_ip_hdr_valid),
    .output_ip_hdr_ready(rx_ip_hdr_ready),
    .output_ip_eth_dest_mac(rx_ip_eth_dest_mac),
    .output_ip_eth_src_mac(rx_ip_eth_src_mac),
    .output_ip_eth_type(rx_ip_eth_type),
    .output_ip_version(rx_ip_version),
    .output_ip_ihl(rx_ip_ihl),
    .output_ip_dscp(rx_ip_dscp),
    .output_ip_ecn(rx_ip_ecn),
    .output_ip_length(rx_ip_length),
    .output_ip_identification(rx_ip_identification),
    .output_ip_flags(rx_ip_flags),
    .output_ip_fragment_offset(rx_ip_fragment_offset),
    .output_ip_ttl(rx_ip_ttl),
    .output_ip_protocol(rx_ip_protocol),
    .output_ip_header_checksum(rx_ip_header_checksum),
    .output_ip_source_ip(rx_ip_source_ip),
    .output_ip_dest_ip(rx_ip_dest_ip),
    .output_ip_payload_tdata(rx_ip_payload_tdata),
    .output_ip_payload_tkeep(rx_ip_payload_tkeep),
    .output_ip_payload_tvalid(rx_ip_payload_tvalid),
    .output_ip_payload_tready(rx_ip_payload_tready),
    .output_ip_payload_tlast(rx_ip_payload_tlast),
    .output_ip_payload_tuser(rx_ip_payload_tuser),
    // UDP frame input
    .input_udp_hdr_valid(tx_udp_hdr_valid),
    .input_udp_hdr_ready(tx_udp_hdr_ready),
    .input_udp_ip_dscp(tx_udp_ip_dscp),
    .input_udp_ip_ecn(tx_udp_ip_ecn),
    .input_udp_ip_ttl(tx_udp_ip_ttl),
    .input_udp_ip_source_ip(tx_udp_ip_source_ip),
    .input_udp_ip_dest_ip(tx_udp_ip_dest_ip),
    .input_udp_source_port(tx_udp_source_port),
    .input_udp_dest_port(tx_udp_dest_port),
    .input_udp_length(tx_udp_length),
    .input_udp_checksum(tx_udp_checksum),
    .input_udp_payload_tdata(tx_udp_payload_tdata),
    .input_udp_payload_tkeep(tx_udp_payload_tkeep),
    .input_udp_payload_tvalid(tx_udp_payload_tvalid),
    .input_udp_payload_tready(tx_udp_payload_tready),
    .input_udp_payload_tlast(tx_udp_payload_tlast),
    .input_udp_payload_tuser(tx_udp_payload_tuser),
    // UDP frame output
    .output_udp_hdr_valid(rx_udp_hdr_valid),
    .output_udp_hdr_ready(rx_udp_hdr_ready),
    .output_udp_eth_dest_mac(rx_udp_eth_dest_mac),
    .output_udp_eth_src_mac(rx_udp_eth_src_mac),
    .output_udp_eth_type(rx_udp_eth_type),
    .output_udp_ip_version(rx_udp_ip_version),
    .output_udp_ip_ihl(rx_udp_ip_ihl),
    .output_udp_ip_dscp(rx_udp_ip_dscp),
    .output_udp_ip_ecn(rx_udp_ip_ecn),
    .output_udp_ip_length(rx_udp_ip_length),
    .output_udp_ip_identification(rx_udp_ip_identification),
    .output_udp_ip_flags(rx_udp_ip_flags),
    .output_udp_ip_fragment_offset(rx_udp_ip_fragment_offset),
    .output_udp_ip_ttl(rx_udp_ip_ttl),
    .output_udp_ip_protocol(rx_udp_ip_protocol),
    .output_udp_ip_header_checksum(rx_udp_ip_header_checksum),
    .output_udp_ip_source_ip(rx_udp_ip_source_ip),
    .output_udp_ip_dest_ip(rx_udp_ip_dest_ip),
    .output_udp_source_port(rx_udp_source_port),
    .output_udp_dest_port(rx_udp_dest_port),
    .output_udp_length(rx_udp_length),
    .output_udp_checksum(rx_udp_checksum),
    .output_udp_payload_tdata(rx_udp_payload_tdata),
    .output_udp_payload_tkeep(rx_udp_payload_tkeep),
    .output_udp_payload_tvalid(rx_udp_payload_tvalid),
    .output_udp_payload_tready(rx_udp_payload_tready),
    .output_udp_payload_tlast(rx_udp_payload_tlast),
    .output_udp_payload_tuser(rx_udp_payload_tuser),
    // Status signals
    .ip_rx_busy(),
    .ip_tx_busy(),
    .udp_rx_busy(),
    .udp_tx_busy(),
    .ip_rx_error_header_early_termination(),
    .ip_rx_error_payload_early_termination(),
    .ip_rx_error_invalid_header(),
    .ip_rx_error_invalid_checksum(),
    .ip_tx_error_payload_early_termination(),
    .ip_tx_error_arp_failed(),
    .udp_rx_error_header_early_termination(),
    .udp_rx_error_payload_early_termination(),
    .udp_tx_error_payload_early_termination(),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_arp_cache(1'b0)
);

axis_fifo #(
    .ADDR_WIDTH(10),
    .DATA_WIDTH(64),
    .KEEP_ENABLE(1),
    .KEEP_WIDTH(8),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(1)
)
udp_payload_fifo (
    .clk(clk),
    .rst(rst),

    // AXI input
    .input_axis_tdata(rx_fifo_udp_payload_tdata),
    .input_axis_tkeep(rx_fifo_udp_payload_tkeep),
    .input_axis_tvalid(rx_fifo_udp_payload_tvalid),
    .input_axis_tready(rx_fifo_udp_payload_tready),
    .input_axis_tlast(rx_fifo_udp_payload_tlast),
    .input_axis_tid(0),
    .input_axis_tdest(0),
    .input_axis_tuser(rx_fifo_udp_payload_tuser),

    // AXI output
    .output_axis_tdata(tx_fifo_udp_payload_tdata),
    .output_axis_tkeep(tx_fifo_udp_payload_tkeep),
    .output_axis_tvalid(tx_fifo_udp_payload_tvalid),
    .output_axis_tready(tx_fifo_udp_payload_tready),
    .output_axis_tlast(tx_fifo_udp_payload_tlast),
    .output_axis_tid(),
    .output_axis_tdest(),
    .output_axis_tuser(tx_fifo_udp_payload_tuser)
);

endmodule
