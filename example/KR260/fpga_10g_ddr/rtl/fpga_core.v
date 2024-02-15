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
 * FPGA core logic
 */
module fpga_core
(
    /*
     * Clock: 156.25MHz
     * Synchronous reset
     */
    input  wire        clk,
    input  wire        rst,

    /*
     * GPIO
     */
    output wire [1:0]  led,

    /*
     * Ethernet: SFP+
     */
    input  wire        sfp0_tx_clk,
    input  wire        sfp0_tx_rst,
    output wire [63:0] sfp0_txd,
    output wire [7:0]  sfp0_txc,
    input  wire        sfp0_rx_clk,
    input  wire        sfp0_rx_rst,
    input  wire [63:0] sfp0_rxd,
    input  wire [7:0]  sfp0_rxc,

    /*
     * Master AXI (for udp rx/tx)
     */
    output wire [07:00] m_axi_arid   ,
    output wire [31:00] m_axi_araddr ,
    output wire [07:00] m_axi_arlen  ,
    output wire [02:00] m_axi_arsize ,
    output wire [01:00] m_axi_arburst,
    output wire         m_axi_arlock ,
    output wire [03:00] m_axi_arcache,
    output wire [02:00] m_axi_arprot ,
    output wire         m_axi_arvalid,
    input  wire         m_axi_arready,
    input  wire [07:00] m_axi_rid    ,
    input  wire [63:00] m_axi_rdata  ,
    input  wire [01:00] m_axi_rresp  ,
    input  wire         m_axi_rlast  ,
    input  wire         m_axi_rvalid ,
    output wire         m_axi_rready ,     
    output wire [07:00] m_axi_awid   ,
    output wire [31:00] m_axi_awaddr ,
    output wire [07:00] m_axi_awlen  ,
    output wire [02:00] m_axi_awsize ,
    output wire [01:00] m_axi_awburst,
    output wire         m_axi_awlock ,
    output wire [03:00] m_axi_awcache,
    output wire [02:00] m_axi_awprot ,
    output wire         m_axi_awvalid,
    input  wire         m_axi_awready,
    output wire [63:00] m_axi_wdata  ,
    output wire [07:00] m_axi_wstrb  ,
    output wire         m_axi_wlast  ,
    output wire         m_axi_wvalid ,
    input  wire         m_axi_wready ,
    input  wire [07:00] m_axi_bid    ,
    input  wire [01:00] m_axi_bresp  ,
    input  wire         m_axi_bvalid ,
    output wire         m_axi_bready ,
    
    /*
     * Control
     */
    input  wire [31:00] shared_mem_ptr_i
);

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
wire [63:0] rx_eth_payload_axis_tdata;
wire [7:0] rx_eth_payload_axis_tkeep;
wire rx_eth_payload_axis_tvalid;
wire rx_eth_payload_axis_tready;
wire rx_eth_payload_axis_tlast;
wire rx_eth_payload_axis_tuser;

wire tx_eth_hdr_ready;
wire tx_eth_hdr_valid;
wire [47:0] tx_eth_dest_mac;
wire [47:0] tx_eth_src_mac;
wire [15:0] tx_eth_type;
wire [63:0] tx_eth_payload_axis_tdata;
wire [7:0] tx_eth_payload_axis_tkeep;
wire tx_eth_payload_axis_tvalid;
wire tx_eth_payload_axis_tready;
wire tx_eth_payload_axis_tlast;
wire tx_eth_payload_axis_tuser;

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
wire [63:0] rx_ip_payload_axis_tdata;
wire [7:0] rx_ip_payload_axis_tkeep;
wire rx_ip_payload_axis_tvalid;
wire rx_ip_payload_axis_tready;
wire rx_ip_payload_axis_tlast;
wire rx_ip_payload_axis_tuser;

wire tx_ip_hdr_valid;
wire tx_ip_hdr_ready;
wire [5:0] tx_ip_dscp;
wire [1:0] tx_ip_ecn;
wire [15:0] tx_ip_length;
wire [7:0] tx_ip_ttl;
wire [7:0] tx_ip_protocol;
wire [31:0] tx_ip_source_ip;
wire [31:0] tx_ip_dest_ip;
wire [63:0] tx_ip_payload_axis_tdata;
wire [7:0] tx_ip_payload_axis_tkeep;
wire tx_ip_payload_axis_tvalid;
wire tx_ip_payload_axis_tready;
wire tx_ip_payload_axis_tlast;
wire tx_ip_payload_axis_tuser;

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
wire [63:0] axis_udp_rx_payload_tdata;
wire [7:0]  axis_udp_rx_payload_tkeep;
wire        axis_udp_rx_payload_tvalid;
wire        axis_udp_rx_payload_tready;
wire        axis_udp_rx_payload_tlast;
wire        axis_udp_rx_payload_tuser;

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
wire [63:0] axis_udp_tx_payload_tdata;
wire [7:0]  axis_udp_tx_payload_tkeep;
wire        axis_udp_tx_payload_tvalid;
wire        axis_udp_tx_payload_tready;
wire        axis_udp_tx_payload_tlast;
wire        axis_udp_tx_payload_tuser;

// Configuration
wire [47:0] local_mac   = 48'h02_00_00_00_00_00;
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd2,   8'd128};
wire [31:0] gateway_ip  = {8'd192, 8'd168, 8'd2,   8'd1};
wire [31:0] subnet_mask = {8'd255, 8'd255, 8'd255, 8'd0};

// IP ports not used
assign rx_ip_hdr_ready = 1;
assign rx_ip_payload_axis_tready = 1;

assign tx_ip_hdr_valid = 0;
assign tx_ip_dscp = 0;
assign tx_ip_ecn = 0;
assign tx_ip_length = 0;
assign tx_ip_ttl = 0;
assign tx_ip_protocol = 0;
assign tx_ip_source_ip = 0;
assign tx_ip_dest_ip = 0;
assign tx_ip_payload_axis_tdata = 0;
assign tx_ip_payload_axis_tkeep = 0;
assign tx_ip_payload_axis_tvalid = 0;
assign tx_ip_payload_axis_tlast = 0;
assign tx_ip_payload_axis_tuser = 0;

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
        if (axis_udp_rx_payload_tvalid) begin
            if ((~match_cond_reg & ~no_match_reg) |
                (axis_udp_rx_payload_tvalid & axis_udp_rx_payload_tready & axis_udp_rx_payload_tlast)) begin
                match_cond_reg <= match_cond;
                no_match_reg <= no_match;
            end
        end else begin
            match_cond_reg <= 0;
            no_match_reg <= 0;
        end
    end
end

// assign tx_udp_hdr_valid = rx_udp_hdr_valid & match_cond;
assign rx_udp_hdr_ready = (tx_eth_hdr_ready & match_cond) | no_match;
assign tx_udp_ip_dscp = 0;
assign tx_udp_ip_ecn = 0;
assign tx_udp_ip_ttl = 64;
assign tx_udp_ip_source_ip = local_ip;
// assign tx_udp_ip_dest_ip = rx_udp_ip_source_ip;
// assign tx_udp_source_port = rx_udp_dest_port;
// assign tx_udp_dest_port = rx_udp_source_port;
// assign tx_udp_length = rx_udp_length;
assign tx_udp_checksum = 0;

assign tx_udp_hdr_valid = 1'b1; // TEMPORARY; anything to be checked to consider header as valid?
assign tx_udp_ip_dest_ip =  {8'd192, 8'd168, 8'd2,   8'd2};
assign tx_udp_source_port = 1234;
assign tx_udp_dest_port = 5678;
assign tx_udp_length = 1024;

// Place first payload byte onto LEDs
reg valid_last = 0;
reg [1:0] led_reg = 0;

always @(posedge clk) begin
    if (rst) begin
        led_reg <= 0;
    end else begin
        valid_last <= axis_udp_tx_payload_tvalid;
        if (axis_udp_tx_payload_tvalid & ~valid_last) begin
            led_reg <= axis_udp_tx_payload_tdata;
        end
    end
end

assign led = led_reg;

eth_mac_10g_fifo #(
    .ENABLE_PADDING(1),
    .ENABLE_DIC(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1)
)
eth_mac_10g_fifo_inst (
    .rx_clk(sfp0_rx_clk),
    .rx_rst(sfp0_rx_rst),
    .tx_clk(sfp0_tx_clk),
    .tx_rst(sfp0_tx_rst),
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

    .xgmii_rxd(sfp0_rxd),
    .xgmii_rxc(sfp0_rxc),
    .xgmii_txd(sfp0_txd),
    .xgmii_txc(sfp0_txc),

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

eth_axis_rx #(
    .DATA_WIDTH(64)
)
eth_axis_rx_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(rx_axis_tdata),
    .s_axis_tkeep(rx_axis_tkeep),
    .s_axis_tvalid(rx_axis_tvalid),
    .s_axis_tready(rx_axis_tready),
    .s_axis_tlast(rx_axis_tlast),
    .s_axis_tuser(rx_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(rx_eth_hdr_valid),
    .m_eth_hdr_ready(rx_eth_hdr_ready),
    .m_eth_dest_mac(rx_eth_dest_mac),
    .m_eth_src_mac(rx_eth_src_mac),
    .m_eth_type(rx_eth_type),
    .m_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(rx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(rx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
    // Status signals
    .busy(),
    .error_header_early_termination()
);

eth_axis_tx #(
    .DATA_WIDTH(64)
)
eth_axis_tx_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(tx_eth_hdr_valid),
    .s_eth_hdr_ready(tx_eth_hdr_ready),
    .s_eth_dest_mac(tx_eth_dest_mac),
    .s_eth_src_mac(tx_eth_src_mac),
    .s_eth_type(tx_eth_type),
    .s_eth_payload_axis_tdata(tx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(tx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(tx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(tx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(tx_eth_payload_axis_tuser),
    // AXI output
    .m_axis_tdata(tx_axis_tdata),
    .m_axis_tkeep(tx_axis_tkeep),
    .m_axis_tvalid(tx_axis_tvalid),
    .m_axis_tready(tx_axis_tready),
    .m_axis_tlast(tx_axis_tlast),
    .m_axis_tuser(tx_axis_tuser),
    // Status signals
    .busy()
);

udp_complete_64
udp_complete_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(rx_eth_hdr_valid),
    .s_eth_hdr_ready(rx_eth_hdr_ready),
    .s_eth_dest_mac(rx_eth_dest_mac),
    .s_eth_src_mac(rx_eth_src_mac),
    .s_eth_type(rx_eth_type),
    .s_eth_payload_axis_tdata(rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(rx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(rx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(rx_eth_payload_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(tx_eth_hdr_valid),
    .m_eth_hdr_ready(tx_eth_hdr_ready),
    .m_eth_dest_mac(tx_eth_dest_mac),
    .m_eth_src_mac(tx_eth_src_mac),
    .m_eth_type(tx_eth_type),
    .m_eth_payload_axis_tdata(tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(tx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(tx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(tx_eth_payload_axis_tuser),
    // IP frame input
    .s_ip_hdr_valid(tx_ip_hdr_valid),
    .s_ip_hdr_ready(tx_ip_hdr_ready),
    .s_ip_dscp(tx_ip_dscp),
    .s_ip_ecn(tx_ip_ecn),
    .s_ip_length(tx_ip_length),
    .s_ip_ttl(tx_ip_ttl),
    .s_ip_protocol(tx_ip_protocol),
    .s_ip_source_ip(tx_ip_source_ip),
    .s_ip_dest_ip(tx_ip_dest_ip),
    .s_ip_payload_axis_tdata(tx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(tx_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(tx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(tx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(tx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(tx_ip_payload_axis_tuser),
    // IP frame output
    .m_ip_hdr_valid(rx_ip_hdr_valid),
    .m_ip_hdr_ready(rx_ip_hdr_ready),
    .m_ip_eth_dest_mac(rx_ip_eth_dest_mac),
    .m_ip_eth_src_mac(rx_ip_eth_src_mac),
    .m_ip_eth_type(rx_ip_eth_type),
    .m_ip_version(rx_ip_version),
    .m_ip_ihl(rx_ip_ihl),
    .m_ip_dscp(rx_ip_dscp),
    .m_ip_ecn(rx_ip_ecn),
    .m_ip_length(rx_ip_length),
    .m_ip_identification(rx_ip_identification),
    .m_ip_flags(rx_ip_flags),
    .m_ip_fragment_offset(rx_ip_fragment_offset),
    .m_ip_ttl(rx_ip_ttl),
    .m_ip_protocol(rx_ip_protocol),
    .m_ip_header_checksum(rx_ip_header_checksum),
    .m_ip_source_ip(rx_ip_source_ip),
    .m_ip_dest_ip(rx_ip_dest_ip),
    .m_ip_payload_axis_tdata(rx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(rx_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(rx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(rx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(rx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(rx_ip_payload_axis_tuser),
    // UDP frame input
    .s_udp_hdr_valid(tx_udp_hdr_valid),
    .s_udp_hdr_ready(tx_udp_hdr_ready),
    .s_udp_ip_dscp(tx_udp_ip_dscp),
    .s_udp_ip_ecn(tx_udp_ip_ecn),
    .s_udp_ip_ttl(tx_udp_ip_ttl),
    .s_udp_ip_source_ip(tx_udp_ip_source_ip),
    .s_udp_ip_dest_ip(tx_udp_ip_dest_ip),
    .s_udp_source_port(tx_udp_source_port),
    .s_udp_dest_port(tx_udp_dest_port),
    .s_udp_length(tx_udp_length),
    .s_udp_checksum(tx_udp_checksum),
    .s_udp_payload_axis_tdata (axis_udp_tx_payload_tdata),
    .s_udp_payload_axis_tkeep (axis_udp_tx_payload_tkeep),
    .s_udp_payload_axis_tvalid(axis_udp_tx_payload_tvalid),
    .s_udp_payload_axis_tready(axis_udp_tx_payload_tready),
    .s_udp_payload_axis_tlast (axis_udp_tx_payload_tlast),
    .s_udp_payload_axis_tuser (axis_udp_tx_payload_tuser),
    // UDP frame output
    .m_udp_hdr_valid(rx_udp_hdr_valid),
    .m_udp_hdr_ready(rx_udp_hdr_ready),
    .m_udp_eth_dest_mac(rx_udp_eth_dest_mac),
    .m_udp_eth_src_mac(rx_udp_eth_src_mac),
    .m_udp_eth_type(rx_udp_eth_type),
    .m_udp_ip_version(rx_udp_ip_version),
    .m_udp_ip_ihl(rx_udp_ip_ihl),
    .m_udp_ip_dscp(rx_udp_ip_dscp),
    .m_udp_ip_ecn(rx_udp_ip_ecn),
    .m_udp_ip_length(rx_udp_ip_length),
    .m_udp_ip_identification(rx_udp_ip_identification),
    .m_udp_ip_flags(rx_udp_ip_flags),
    .m_udp_ip_fragment_offset(rx_udp_ip_fragment_offset),
    .m_udp_ip_ttl(rx_udp_ip_ttl),
    .m_udp_ip_protocol(rx_udp_ip_protocol),
    .m_udp_ip_header_checksum(rx_udp_ip_header_checksum),
    .m_udp_ip_source_ip(rx_udp_ip_source_ip),
    .m_udp_ip_dest_ip(rx_udp_ip_dest_ip),
    .m_udp_source_port(rx_udp_source_port),
    .m_udp_dest_port(rx_udp_dest_port),
    .m_udp_length(rx_udp_length),
    .m_udp_checksum(rx_udp_checksum),
    .m_udp_payload_axis_tdata (axis_udp_rx_payload_tdata),
    .m_udp_payload_axis_tkeep (axis_udp_rx_payload_tkeep),
    .m_udp_payload_axis_tvalid(axis_udp_rx_payload_tvalid),
    .m_udp_payload_axis_tready(axis_udp_rx_payload_tready),
    .m_udp_payload_axis_tlast (axis_udp_rx_payload_tlast),
    .m_udp_payload_axis_tuser (axis_udp_rx_payload_tuser),
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

// AXIS (internal) <-> AXI (external)

reg valid_address;
always @(posedge clk) begin
    if (rst || shared_mem_ptr_i == 32'b0) begin
        valid_address = 0;
    end else begin
        valid_address = 1;
    end
end 
reg valid_addr_last, valid_addr_sec2last;
wire valid_addr_one_pulse;
assign valid_addr_one_pulse = valid_addr_last & !valid_addr_sec2last;
always @(posedge clk) begin
    if (rst) begin
        valid_addr_last     <= 0;
        valid_addr_sec2last <= 0;
    end else begin
        valid_addr_last     <= valid_address;
        valid_addr_sec2last <= valid_addr_last;
    end
end

axi_dma_wr #(
    .AXI_DATA_WIDTH   (64),
    .AXI_ADDR_WIDTH   (32),
    .AXI_ID_WIDTH     (1),
    .AXI_MAX_BURST_LEN(256),
    .AXIS_DATA_WIDTH  (64),
    .AXIS_KEEP_ENABLE (1),
    .AXIS_KEEP_WIDTH  (8),
    .AXIS_LAST_ENABLE (1),
    .AXIS_ID_ENABLE   (0),
    .AXIS_DEST_ENABLE (0),
    .AXIS_USER_ENABLE (1),
    .AXIS_USER_WIDTH  (1)
) axi_dma_wr_inst (
    .clk                            (clk),
    .rst                            (rst),
    .s_axis_write_desc_addr         (shared_mem_ptr_i ),
    .s_axis_write_desc_len          (1024             ),
    .s_axis_write_desc_tag          (8'd0             ),
    .s_axis_write_desc_valid        (valid_address    ),
    .s_axis_write_desc_ready        (),
    .s_axis_write_data_tdata        (axis_udp_rx_payload_tdata ),
    .s_axis_write_data_tkeep        (axis_udp_rx_payload_tkeep ),
    .s_axis_write_data_tvalid       (axis_udp_rx_payload_tvalid),
    .s_axis_write_data_tready       (axis_udp_rx_payload_tready),
    .s_axis_write_data_tlast        (axis_udp_rx_payload_tlast ),
    .s_axis_write_data_tid          (1'b0),
    .s_axis_write_data_tdest        (),
    .s_axis_write_data_tuser        (axis_udp_rx_payload_tuser ),
    .m_axi_awid                     (m_axi_awid   ),
    .m_axi_awaddr                   (m_axi_awaddr ),
    .m_axi_awlen                    (m_axi_awlen  ),
    .m_axi_awsize                   (m_axi_awsize ),
    .m_axi_awburst                  (m_axi_awburst),
    .m_axi_awlock                   (m_axi_awlock ),
    .m_axi_awcache                  (m_axi_awcache),
    .m_axi_awprot                   (m_axi_awprot ),
    .m_axi_awvalid                  (m_axi_awvalid),
    .m_axi_awready                  (m_axi_awready),
    .m_axi_wdata                    (m_axi_wdata  ),
    .m_axi_wstrb                    (m_axi_wstrb  ),
    .m_axi_wlast                    (m_axi_wlast  ),
    .m_axi_wvalid                   (m_axi_wvalid ),
    .m_axi_wready                   (m_axi_wready ),
    .m_axi_bid                      (m_axi_bid    ),
    .m_axi_bresp                    (m_axi_bresp  ),
    .m_axi_bvalid                   (m_axi_bvalid ),
    .m_axi_bready                   (m_axi_bready ),
    .enable                         (1'b1 ),
    .abort                          (1'b0 )
);

axi_dma_rd #(
    .AXI_DATA_WIDTH           (64),
    .AXI_ADDR_WIDTH           (32),
    .AXI_ID_WIDTH             (1 ),
    .AXI_MAX_BURST_LEN        (256),
    .AXIS_DATA_WIDTH          (64),
    .AXIS_KEEP_ENABLE         (1 ),
    .AXIS_KEEP_WIDTH          (8 ),
    .AXIS_LAST_ENABLE         (1 ),
    .AXIS_ID_ENABLE           (0 ),
    .AXIS_DEST_ENABLE         (0 ),
    .AXIS_USER_ENABLE         (1 ),
    .AXIS_USER_WIDTH          (1 )   
) axi_dma_rd_inst (
    .clk                            (clk),
    .rst                            (rst),
    .s_axis_read_desc_addr          (shared_mem_ptr_i),
    .s_axis_read_desc_len           (1024),
    .s_axis_read_desc_tag           (8'd0),
    .s_axis_read_desc_id            (1'b0),
    .s_axis_read_desc_dest          (),
    .s_axis_read_desc_user          (1'b0),
    .s_axis_read_desc_valid         (valid_addr_one_pulse),
    .s_axis_read_desc_ready         ( ),
    .m_axis_read_desc_status_tag    ( ),
    .m_axis_read_desc_status_error  ( ),
    .m_axis_read_desc_status_valid  ( ),
    .m_axis_read_data_tdata         (axis_udp_tx_payload_tdata  ),
    .m_axis_read_data_tkeep         (axis_udp_tx_payload_tkeep  ),
    .m_axis_read_data_tvalid        (axis_udp_tx_payload_tvalid ), // Important: one-cycle pulse per each transaction to be performed; otherwise, axi_dma_rd will queue a second transaction after the intended one
    .m_axis_read_data_tready        (axis_udp_tx_payload_tready ),
    .m_axis_read_data_tlast         (axis_udp_tx_payload_tlast  ),
    .m_axis_read_data_tid           (                           ),
    .m_axis_read_data_tdest         (                           ),
    .m_axis_read_data_tuser         (axis_udp_tx_payload_tuser  ),
    .m_axi_arid                     (m_axi_arid         ),
    .m_axi_araddr                   (m_axi_araddr       ),
    .m_axi_arlen                    (m_axi_arlen        ),
    .m_axi_arsize                   (m_axi_arsize       ),
    .m_axi_arburst                  (m_axi_arburst      ),
    .m_axi_arlock                   (m_axi_arlock       ),
    .m_axi_arcache                  (m_axi_arcache      ),
    .m_axi_arprot                   (m_axi_arprot       ),
    .m_axi_arvalid                  (m_axi_arvalid      ),
    .m_axi_arready                  (m_axi_arready      ),
    .m_axi_rid                      (m_axi_rid          ),
    .m_axi_rdata                    (m_axi_rdata        ),
    .m_axi_rresp                    (m_axi_rresp        ),
    .m_axi_rlast                    (m_axi_rlast        ),
    .m_axi_rvalid                   (m_axi_rvalid       ),
    .m_axi_rready                   (m_axi_rready       ),
    .enable                         (1'b1               )
);

// Dump waves for simulation
`ifdef COCOTB_SIM
initial begin
  $dumpfile ("fpga_core.vcd");
  $dumpvars (0, fpga_core);
  #1;
end
`endif

endmodule

`resetall
