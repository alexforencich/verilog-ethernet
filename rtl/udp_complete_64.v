/*

Copyright (c) 2014-2017 Alex Forencich

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
 * IPv4 and ARP block with UDP support, ethernet frame interface (64 bit datapath)
 */
module udp_complete_64 #(
    parameter ARP_CACHE_ADDR_WIDTH = 2,
    parameter ARP_REQUEST_RETRY_COUNT = 4,
    parameter ARP_REQUEST_RETRY_INTERVAL = 125000000*2,
    parameter ARP_REQUEST_TIMEOUT = 125000000*30,
    parameter UDP_CHECKSUM_GEN_ENABLE = 1,
    parameter UDP_CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH = 11,
    parameter UDP_CHECKSUM_HEADER_FIFO_ADDR_WIDTH = 3
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame input
     */
    input  wire        input_eth_hdr_valid,
    output wire        input_eth_hdr_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [63:0]  input_eth_payload_tdata,
    input  wire [7:0]  input_eth_payload_tkeep,
    input  wire        input_eth_payload_tvalid,
    output wire        input_eth_payload_tready,
    input  wire        input_eth_payload_tlast,
    input  wire        input_eth_payload_tuser,
    
    /*
     * Ethernet frame output
     */
    output wire        output_eth_hdr_valid,
    input  wire        output_eth_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
    output wire [63:0]  output_eth_payload_tdata,
    output wire [7:0]  output_eth_payload_tkeep,
    output wire        output_eth_payload_tvalid,
    input  wire        output_eth_payload_tready,
    output wire        output_eth_payload_tlast,
    output wire        output_eth_payload_tuser,
    
    /*
     * IP input
     */
    input  wire        input_ip_hdr_valid,
    output wire        input_ip_hdr_ready,
    input  wire [5:0]  input_ip_dscp,
    input  wire [1:0]  input_ip_ecn,
    input  wire [15:0] input_ip_length,
    input  wire [7:0]  input_ip_ttl,
    input  wire [7:0]  input_ip_protocol,
    input  wire [31:0] input_ip_source_ip,
    input  wire [31:0] input_ip_dest_ip,
    input  wire [63:0]  input_ip_payload_tdata,
    input  wire [7:0]  input_ip_payload_tkeep,
    input  wire        input_ip_payload_tvalid,
    output wire        input_ip_payload_tready,
    input  wire        input_ip_payload_tlast,
    input  wire        input_ip_payload_tuser,
    
    /*
     * IP output
     */
    output wire        output_ip_hdr_valid,
    input  wire        output_ip_hdr_ready,
    output wire [47:0] output_ip_eth_dest_mac,
    output wire [47:0] output_ip_eth_src_mac,
    output wire [15:0] output_ip_eth_type,
    output wire [3:0]  output_ip_version,
    output wire [3:0]  output_ip_ihl,
    output wire [5:0]  output_ip_dscp,
    output wire [1:0]  output_ip_ecn,
    output wire [15:0] output_ip_length,
    output wire [15:0] output_ip_identification,
    output wire [2:0]  output_ip_flags,
    output wire [12:0] output_ip_fragment_offset,
    output wire [7:0]  output_ip_ttl,
    output wire [7:0]  output_ip_protocol,
    output wire [15:0] output_ip_header_checksum,
    output wire [31:0] output_ip_source_ip,
    output wire [31:0] output_ip_dest_ip,
    output wire [63:0]  output_ip_payload_tdata,
    output wire [7:0]  output_ip_payload_tkeep,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,
    
    /*
     * UDP input
     */
    input  wire        input_udp_hdr_valid,
    output wire        input_udp_hdr_ready,
    input  wire [5:0]  input_udp_ip_dscp,
    input  wire [1:0]  input_udp_ip_ecn,
    input  wire [7:0]  input_udp_ip_ttl,
    input  wire [31:0] input_udp_ip_source_ip,
    input  wire [31:0] input_udp_ip_dest_ip,
    input  wire [15:0] input_udp_source_port,
    input  wire [15:0] input_udp_dest_port,
    input  wire [15:0] input_udp_length,
    input  wire [15:0] input_udp_checksum,
    input  wire [63:0]  input_udp_payload_tdata,
    input  wire [7:0]  input_udp_payload_tkeep,
    input  wire        input_udp_payload_tvalid,
    output wire        input_udp_payload_tready,
    input  wire        input_udp_payload_tlast,
    input  wire        input_udp_payload_tuser,
    
    /*
     * UDP output
     */
    output wire        output_udp_hdr_valid,
    input  wire        output_udp_hdr_ready,
    output wire [47:0] output_udp_eth_dest_mac,
    output wire [47:0] output_udp_eth_src_mac,
    output wire [15:0] output_udp_eth_type,
    output wire [3:0]  output_udp_ip_version,
    output wire [3:0]  output_udp_ip_ihl,
    output wire [5:0]  output_udp_ip_dscp,
    output wire [1:0]  output_udp_ip_ecn,
    output wire [15:0] output_udp_ip_length,
    output wire [15:0] output_udp_ip_identification,
    output wire [2:0]  output_udp_ip_flags,
    output wire [12:0] output_udp_ip_fragment_offset,
    output wire [7:0]  output_udp_ip_ttl,
    output wire [7:0]  output_udp_ip_protocol,
    output wire [15:0] output_udp_ip_header_checksum,
    output wire [31:0] output_udp_ip_source_ip,
    output wire [31:0] output_udp_ip_dest_ip,
    output wire [15:0] output_udp_source_port,
    output wire [15:0] output_udp_dest_port,
    output wire [15:0] output_udp_length,
    output wire [15:0] output_udp_checksum,
    output wire [63:0]  output_udp_payload_tdata,
    output wire [7:0]  output_udp_payload_tkeep,
    output wire        output_udp_payload_tvalid,
    input  wire        output_udp_payload_tready,
    output wire        output_udp_payload_tlast,
    output wire        output_udp_payload_tuser,

    /*
     * Status
     */
    output wire        ip_rx_busy,
    output wire        ip_tx_busy,
    output wire        udp_rx_busy,
    output wire        udp_tx_busy,
    output wire        ip_rx_error_header_early_termination,
    output wire        ip_rx_error_payload_early_termination,
    output wire        ip_rx_error_invalid_header,
    output wire        ip_rx_error_invalid_checksum,
    output wire        ip_tx_error_payload_early_termination,
    output wire        ip_tx_error_arp_failed,
    output wire        udp_rx_error_header_early_termination,
    output wire        udp_rx_error_payload_early_termination,
    output wire        udp_tx_error_payload_early_termination,

    /*
     * Configuration
     */
    input  wire [47:0] local_mac,
    input  wire [31:0] local_ip,
    input  wire [31:0] gateway_ip,
    input  wire [31:0] subnet_mask,
    input  wire        clear_arp_cache
);

wire ip_rx_ip_hdr_valid;
wire ip_rx_ip_hdr_ready;
wire [47:0] ip_rx_ip_eth_dest_mac;
wire [47:0] ip_rx_ip_eth_src_mac;
wire [15:0] ip_rx_ip_eth_type;
wire [3:0] ip_rx_ip_version;
wire [3:0] ip_rx_ip_ihl;
wire [5:0] ip_rx_ip_dscp;
wire [1:0] ip_rx_ip_ecn;
wire [15:0] ip_rx_ip_length;
wire [15:0] ip_rx_ip_identification;
wire [2:0] ip_rx_ip_flags;
wire [12:0] ip_rx_ip_fragment_offset;
wire [7:0] ip_rx_ip_ttl;
wire [7:0] ip_rx_ip_protocol;
wire [15:0] ip_rx_ip_header_checksum;
wire [31:0] ip_rx_ip_source_ip;
wire [31:0] ip_rx_ip_dest_ip;
wire [63:0] ip_rx_ip_payload_tdata;
wire [7:0] ip_rx_ip_payload_tkeep;
wire ip_rx_ip_payload_tvalid;
wire ip_rx_ip_payload_tlast;
wire ip_rx_ip_payload_tuser;
wire ip_rx_ip_payload_tready;

wire ip_tx_ip_hdr_valid;
wire ip_tx_ip_hdr_ready;
wire [5:0] ip_tx_ip_dscp;
wire [1:0] ip_tx_ip_ecn;
wire [15:0] ip_tx_ip_length;
wire [7:0] ip_tx_ip_ttl;
wire [7:0] ip_tx_ip_protocol;
wire [31:0] ip_tx_ip_source_ip;
wire [31:0] ip_tx_ip_dest_ip;
wire [63:0] ip_tx_ip_payload_tdata;
wire [7:0] ip_tx_ip_payload_tkeep;
wire ip_tx_ip_payload_tvalid;
wire ip_tx_ip_payload_tlast;
wire ip_tx_ip_payload_tuser;
wire ip_tx_ip_payload_tready;

wire udp_rx_ip_hdr_valid;
wire udp_rx_ip_hdr_ready;
wire [47:0] udp_rx_ip_eth_dest_mac;
wire [47:0] udp_rx_ip_eth_src_mac;
wire [15:0] udp_rx_ip_eth_type;
wire [3:0] udp_rx_ip_version;
wire [3:0] udp_rx_ip_ihl;
wire [5:0] udp_rx_ip_dscp;
wire [1:0] udp_rx_ip_ecn;
wire [15:0] udp_rx_ip_length;
wire [15:0] udp_rx_ip_identification;
wire [2:0] udp_rx_ip_flags;
wire [12:0] udp_rx_ip_fragment_offset;
wire [7:0] udp_rx_ip_ttl;
wire [7:0] udp_rx_ip_protocol;
wire [15:0] udp_rx_ip_header_checksum;
wire [31:0] udp_rx_ip_source_ip;
wire [31:0] udp_rx_ip_dest_ip;
wire [63:0] udp_rx_ip_payload_tdata;
wire [7:0] udp_rx_ip_payload_tkeep;
wire udp_rx_ip_payload_tvalid;
wire udp_rx_ip_payload_tlast;
wire udp_rx_ip_payload_tuser;
wire udp_rx_ip_payload_tready;

wire udp_tx_ip_hdr_valid;
wire udp_tx_ip_hdr_ready;
wire [5:0] udp_tx_ip_dscp;
wire [1:0] udp_tx_ip_ecn;
wire [15:0] udp_tx_ip_length;
wire [7:0] udp_tx_ip_ttl;
wire [7:0] udp_tx_ip_protocol;
wire [31:0] udp_tx_ip_source_ip;
wire [31:0] udp_tx_ip_dest_ip;
wire [63:0] udp_tx_ip_payload_tdata;
wire [7:0] udp_tx_ip_payload_tkeep;
wire udp_tx_ip_payload_tvalid;
wire udp_tx_ip_payload_tlast;
wire udp_tx_ip_payload_tuser;
wire udp_tx_ip_payload_tready;

/*
 * Input classifier (ip_protocol)
 */
wire input_select_udp = (ip_rx_ip_protocol == 8'h11);
wire input_select_ip = ~input_select_udp;

reg input_select_udp_reg = 1'b0;
reg input_select_ip_reg = 1'b0;

always @(posedge clk) begin
    if (rst) begin
        input_select_udp_reg <= 1'b0;
        input_select_ip_reg <= 1'b0;
    end else begin
        if (ip_rx_ip_payload_tvalid) begin
            if ((~input_select_udp_reg & ~input_select_ip_reg) |
                (ip_rx_ip_payload_tvalid & ip_rx_ip_payload_tready & ip_rx_ip_payload_tlast)) begin
                input_select_udp_reg <= input_select_udp;
                input_select_ip_reg <= input_select_ip;
            end
        end else begin
            input_select_udp_reg <= 1'b0;
            input_select_ip_reg <= 1'b0;
        end
    end
end

// IP frame to UDP module
assign udp_rx_ip_hdr_valid = input_select_udp & ip_rx_ip_hdr_valid;
assign udp_rx_ip_eth_dest_mac = ip_rx_ip_eth_dest_mac;
assign udp_rx_ip_eth_src_mac = ip_rx_ip_eth_src_mac;
assign udp_rx_ip_eth_type = ip_rx_ip_eth_type;
assign udp_rx_ip_version = ip_rx_ip_version;
assign udp_rx_ip_ihl = ip_rx_ip_ihl;
assign udp_rx_ip_dscp = ip_rx_ip_dscp;
assign udp_rx_ip_ecn = ip_rx_ip_ecn;
assign udp_rx_ip_length = ip_rx_ip_length;
assign udp_rx_ip_identification = ip_rx_ip_identification;
assign udp_rx_ip_flags = ip_rx_ip_flags;
assign udp_rx_ip_fragment_offset = ip_rx_ip_fragment_offset;
assign udp_rx_ip_ttl = ip_rx_ip_ttl;
assign udp_rx_ip_protocol = 8'h11;
assign udp_rx_ip_header_checksum = ip_rx_ip_header_checksum;
assign udp_rx_ip_source_ip = ip_rx_ip_source_ip;
assign udp_rx_ip_dest_ip = ip_rx_ip_dest_ip;
assign udp_rx_ip_payload_tdata = ip_rx_ip_payload_tdata;
assign udp_rx_ip_payload_tkeep = ip_rx_ip_payload_tkeep;
assign udp_rx_ip_payload_tvalid = input_select_udp_reg & ip_rx_ip_payload_tvalid;
assign udp_rx_ip_payload_tlast = ip_rx_ip_payload_tlast;
assign udp_rx_ip_payload_tuser = ip_rx_ip_payload_tuser;

// External IP frame output
assign output_ip_hdr_valid = input_select_ip & ip_rx_ip_hdr_valid;
assign output_ip_eth_dest_mac = ip_rx_ip_eth_dest_mac;
assign output_ip_eth_src_mac = ip_rx_ip_eth_src_mac;
assign output_ip_eth_type = ip_rx_ip_eth_type;
assign output_ip_version = ip_rx_ip_version;
assign output_ip_ihl = ip_rx_ip_ihl;
assign output_ip_dscp = ip_rx_ip_dscp;
assign output_ip_ecn = ip_rx_ip_ecn;
assign output_ip_length = ip_rx_ip_length;
assign output_ip_identification = ip_rx_ip_identification;
assign output_ip_flags = ip_rx_ip_flags;
assign output_ip_fragment_offset = ip_rx_ip_fragment_offset;
assign output_ip_ttl = ip_rx_ip_ttl;
assign output_ip_protocol = ip_rx_ip_protocol;
assign output_ip_header_checksum = ip_rx_ip_header_checksum;
assign output_ip_source_ip = ip_rx_ip_source_ip;
assign output_ip_dest_ip = ip_rx_ip_dest_ip;
assign output_ip_payload_tdata = ip_rx_ip_payload_tdata;
assign output_ip_payload_tkeep = ip_rx_ip_payload_tkeep;
assign output_ip_payload_tvalid = input_select_ip_reg & ip_rx_ip_payload_tvalid;
assign output_ip_payload_tlast = ip_rx_ip_payload_tlast;
assign output_ip_payload_tuser = ip_rx_ip_payload_tuser;

assign ip_rx_ip_hdr_ready = (input_select_udp & udp_rx_ip_hdr_ready) |
                            (input_select_ip & output_ip_hdr_ready);

assign ip_rx_ip_payload_tready = (input_select_udp_reg & udp_rx_ip_payload_tready) |
                                 (input_select_ip_reg & output_ip_payload_tready);

/*
 * Output arbiter
 */
ip_arb_mux_64_2
ip_arb_mux_64_2_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input from UDP module
    .input_0_ip_hdr_valid(udp_tx_ip_hdr_valid),
    .input_0_ip_hdr_ready(udp_tx_ip_hdr_ready),
    .input_0_eth_dest_mac(48'd0),
    .input_0_eth_src_mac(48'd0),
    .input_0_eth_type(16'd0),
    .input_0_ip_version(4'd0),
    .input_0_ip_ihl(4'd0),
    .input_0_ip_dscp(udp_tx_ip_dscp),
    .input_0_ip_ecn(udp_tx_ip_ecn),
    .input_0_ip_length(udp_tx_ip_length),
    .input_0_ip_identification(16'd0),
    .input_0_ip_flags(3'd0),
    .input_0_ip_fragment_offset(13'd0),
    .input_0_ip_ttl(udp_tx_ip_ttl),
    .input_0_ip_protocol(udp_tx_ip_protocol),
    .input_0_ip_header_checksum(16'd0),
    .input_0_ip_source_ip(udp_tx_ip_source_ip),
    .input_0_ip_dest_ip(udp_tx_ip_dest_ip),
    .input_0_ip_payload_tdata(udp_tx_ip_payload_tdata),
    .input_0_ip_payload_tkeep(udp_tx_ip_payload_tkeep),
    .input_0_ip_payload_tvalid(udp_tx_ip_payload_tvalid),
    .input_0_ip_payload_tready(udp_tx_ip_payload_tready),
    .input_0_ip_payload_tlast(udp_tx_ip_payload_tlast),
    .input_0_ip_payload_tuser(udp_tx_ip_payload_tuser),
    // External IP frame input
    .input_1_ip_hdr_valid(input_ip_hdr_valid),
    .input_1_ip_hdr_ready(input_ip_hdr_ready),
    .input_1_eth_dest_mac(48'd0),
    .input_1_eth_src_mac(48'd0),
    .input_1_eth_type(16'd0),
    .input_1_ip_version(4'd0),
    .input_1_ip_ihl(4'd0),
    .input_1_ip_dscp(input_ip_dscp),
    .input_1_ip_ecn(input_ip_ecn),
    .input_1_ip_length(input_ip_length),
    .input_1_ip_identification(16'd0),
    .input_1_ip_flags(3'd0),
    .input_1_ip_fragment_offset(13'd0),
    .input_1_ip_ttl(input_ip_ttl),
    .input_1_ip_protocol(input_ip_protocol),
    .input_1_ip_header_checksum(16'd0),
    .input_1_ip_source_ip(input_ip_source_ip),
    .input_1_ip_dest_ip(input_ip_dest_ip),
    .input_1_ip_payload_tdata(input_ip_payload_tdata),
    .input_1_ip_payload_tkeep(input_ip_payload_tkeep),
    .input_1_ip_payload_tvalid(input_ip_payload_tvalid),
    .input_1_ip_payload_tready(input_ip_payload_tready),
    .input_1_ip_payload_tlast(input_ip_payload_tlast),
    .input_1_ip_payload_tuser(input_ip_payload_tuser),
    // IP frame output to IP stack
    .output_ip_hdr_valid(ip_tx_ip_hdr_valid),
    .output_ip_hdr_ready(ip_tx_ip_hdr_ready),
    .output_eth_dest_mac(),
    .output_eth_src_mac(),
    .output_eth_type(),
    .output_ip_version(),
    .output_ip_ihl(),
    .output_ip_dscp(ip_tx_ip_dscp),
    .output_ip_ecn(ip_tx_ip_ecn),
    .output_ip_length(ip_tx_ip_length),
    .output_ip_identification(),
    .output_ip_flags(),
    .output_ip_fragment_offset(),
    .output_ip_ttl(ip_tx_ip_ttl),
    .output_ip_protocol(ip_tx_ip_protocol),
    .output_ip_header_checksum(),
    .output_ip_source_ip(ip_tx_ip_source_ip),
    .output_ip_dest_ip(ip_tx_ip_dest_ip),
    .output_ip_payload_tdata(ip_tx_ip_payload_tdata),
    .output_ip_payload_tkeep(ip_tx_ip_payload_tkeep),
    .output_ip_payload_tvalid(ip_tx_ip_payload_tvalid),
    .output_ip_payload_tready(ip_tx_ip_payload_tready),
    .output_ip_payload_tlast(ip_tx_ip_payload_tlast),
    .output_ip_payload_tuser(ip_tx_ip_payload_tuser)
);

/*
 * IP stack
 */
ip_complete_64 #(
    .ARP_CACHE_ADDR_WIDTH(ARP_CACHE_ADDR_WIDTH),
    .ARP_REQUEST_RETRY_COUNT(ARP_REQUEST_RETRY_COUNT),
    .ARP_REQUEST_RETRY_INTERVAL(ARP_REQUEST_RETRY_INTERVAL),
    .ARP_REQUEST_TIMEOUT(ARP_REQUEST_TIMEOUT)
)
ip_complete_64_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(input_eth_hdr_valid),
    .input_eth_hdr_ready(input_eth_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_eth_payload_tdata(input_eth_payload_tdata),
    .input_eth_payload_tkeep(input_eth_payload_tkeep),
    .input_eth_payload_tvalid(input_eth_payload_tvalid),
    .input_eth_payload_tready(input_eth_payload_tready),
    .input_eth_payload_tlast(input_eth_payload_tlast),
    .input_eth_payload_tuser(input_eth_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tkeep(output_eth_payload_tkeep),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
    // IP frame input
    .input_ip_hdr_valid(ip_tx_ip_hdr_valid),
    .input_ip_hdr_ready(ip_tx_ip_hdr_ready),
    .input_ip_dscp(ip_tx_ip_dscp),
    .input_ip_ecn(ip_tx_ip_ecn),
    .input_ip_length(ip_tx_ip_length),
    .input_ip_ttl(ip_tx_ip_ttl),
    .input_ip_protocol(ip_tx_ip_protocol),
    .input_ip_source_ip(ip_tx_ip_source_ip),
    .input_ip_dest_ip(ip_tx_ip_dest_ip),
    .input_ip_payload_tdata(ip_tx_ip_payload_tdata),
    .input_ip_payload_tkeep(ip_tx_ip_payload_tkeep),
    .input_ip_payload_tvalid(ip_tx_ip_payload_tvalid),
    .input_ip_payload_tready(ip_tx_ip_payload_tready),
    .input_ip_payload_tlast(ip_tx_ip_payload_tlast),
    .input_ip_payload_tuser(ip_tx_ip_payload_tuser),
    // IP frame output
    .output_ip_hdr_valid(ip_rx_ip_hdr_valid),
    .output_ip_hdr_ready(ip_rx_ip_hdr_ready),
    .output_ip_eth_dest_mac(ip_rx_ip_eth_dest_mac),
    .output_ip_eth_src_mac(ip_rx_ip_eth_src_mac),
    .output_ip_eth_type(ip_rx_ip_eth_type),
    .output_ip_version(ip_rx_ip_version),
    .output_ip_ihl(ip_rx_ip_ihl),
    .output_ip_dscp(ip_rx_ip_dscp),
    .output_ip_ecn(ip_rx_ip_ecn),
    .output_ip_length(ip_rx_ip_length),
    .output_ip_identification(ip_rx_ip_identification),
    .output_ip_flags(ip_rx_ip_flags),
    .output_ip_fragment_offset(ip_rx_ip_fragment_offset),
    .output_ip_ttl(ip_rx_ip_ttl),
    .output_ip_protocol(ip_rx_ip_protocol),
    .output_ip_header_checksum(ip_rx_ip_header_checksum),
    .output_ip_source_ip(ip_rx_ip_source_ip),
    .output_ip_dest_ip(ip_rx_ip_dest_ip),
    .output_ip_payload_tdata(ip_rx_ip_payload_tdata),
    .output_ip_payload_tkeep(ip_rx_ip_payload_tkeep),
    .output_ip_payload_tvalid(ip_rx_ip_payload_tvalid),
    .output_ip_payload_tready(ip_rx_ip_payload_tready),
    .output_ip_payload_tlast(ip_rx_ip_payload_tlast),
    .output_ip_payload_tuser(ip_rx_ip_payload_tuser),
    // Status
    .rx_busy(ip_rx_busy),
    .tx_busy(ip_tx_busy),
    .rx_error_header_early_termination(ip_rx_error_header_early_termination),
    .rx_error_payload_early_termination(ip_rx_error_payload_early_termination),
    .rx_error_invalid_header(ip_rx_error_invalid_header),
    .rx_error_invalid_checksum(ip_rx_error_invalid_checksum),
    .tx_error_payload_early_termination(ip_tx_error_payload_early_termination),
    .tx_error_arp_failed(ip_tx_error_arp_failed),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_arp_cache(clear_arp_cache)
);

/*
 * UDP interface
 */
udp_64 #(
    .CHECKSUM_GEN_ENABLE(UDP_CHECKSUM_GEN_ENABLE),
    .CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH(UDP_CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH),
    .CHECKSUM_HEADER_FIFO_ADDR_WIDTH(UDP_CHECKSUM_HEADER_FIFO_ADDR_WIDTH)
)
udp_64_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .input_ip_hdr_valid(udp_rx_ip_hdr_valid),
    .input_ip_hdr_ready(udp_rx_ip_hdr_ready),
    .input_ip_eth_dest_mac(udp_rx_ip_eth_dest_mac),
    .input_ip_eth_src_mac(udp_rx_ip_eth_src_mac),
    .input_ip_eth_type(udp_rx_ip_eth_type),
    .input_ip_version(udp_rx_ip_version),
    .input_ip_ihl(udp_rx_ip_ihl),
    .input_ip_dscp(udp_rx_ip_dscp),
    .input_ip_ecn(udp_rx_ip_ecn),
    .input_ip_length(udp_rx_ip_length),
    .input_ip_identification(udp_rx_ip_identification),
    .input_ip_flags(udp_rx_ip_flags),
    .input_ip_fragment_offset(udp_rx_ip_fragment_offset),
    .input_ip_ttl(udp_rx_ip_ttl),
    .input_ip_protocol(udp_rx_ip_protocol),
    .input_ip_header_checksum(udp_rx_ip_header_checksum),
    .input_ip_source_ip(udp_rx_ip_source_ip),
    .input_ip_dest_ip(udp_rx_ip_dest_ip),
    .input_ip_payload_tdata(udp_rx_ip_payload_tdata),
    .input_ip_payload_tkeep(udp_rx_ip_payload_tkeep),
    .input_ip_payload_tvalid(udp_rx_ip_payload_tvalid),
    .input_ip_payload_tready(udp_rx_ip_payload_tready),
    .input_ip_payload_tlast(udp_rx_ip_payload_tlast),
    .input_ip_payload_tuser(udp_rx_ip_payload_tuser),
    // IP frame output
    .output_ip_hdr_valid(udp_tx_ip_hdr_valid),
    .output_ip_hdr_ready(udp_tx_ip_hdr_ready),
    .output_ip_eth_dest_mac(),
    .output_ip_eth_src_mac(),
    .output_ip_eth_type(),
    .output_ip_version(),
    .output_ip_ihl(),
    .output_ip_dscp(udp_tx_ip_dscp),
    .output_ip_ecn(udp_tx_ip_ecn),
    .output_ip_length(udp_tx_ip_length),
    .output_ip_identification(),
    .output_ip_flags(),
    .output_ip_fragment_offset(),
    .output_ip_ttl(udp_tx_ip_ttl),
    .output_ip_protocol(udp_tx_ip_protocol),
    .output_ip_header_checksum(),
    .output_ip_source_ip(udp_tx_ip_source_ip),
    .output_ip_dest_ip(udp_tx_ip_dest_ip),
    .output_ip_payload_tdata(udp_tx_ip_payload_tdata),
    .output_ip_payload_tkeep(udp_tx_ip_payload_tkeep),
    .output_ip_payload_tvalid(udp_tx_ip_payload_tvalid),
    .output_ip_payload_tready(udp_tx_ip_payload_tready),
    .output_ip_payload_tlast(udp_tx_ip_payload_tlast),
    .output_ip_payload_tuser(udp_tx_ip_payload_tuser),
    // UDP frame input
    .input_udp_hdr_valid(input_udp_hdr_valid),
    .input_udp_hdr_ready(input_udp_hdr_ready),
    .input_udp_eth_dest_mac(48'd0),
    .input_udp_eth_src_mac(48'd0),
    .input_udp_eth_type(16'd0),
    .input_udp_ip_version(4'd0),
    .input_udp_ip_ihl(4'd0),
    .input_udp_ip_dscp(input_udp_ip_dscp),
    .input_udp_ip_ecn(input_udp_ip_ecn),
    .input_udp_ip_identification(16'd0),
    .input_udp_ip_flags(3'd0),
    .input_udp_ip_fragment_offset(13'd0),
    .input_udp_ip_ttl(input_udp_ip_ttl),
    .input_udp_ip_header_checksum(16'd0),
    .input_udp_ip_source_ip(input_udp_ip_source_ip),
    .input_udp_ip_dest_ip(input_udp_ip_dest_ip),
    .input_udp_source_port(input_udp_source_port),
    .input_udp_dest_port(input_udp_dest_port),
    .input_udp_length(input_udp_length),
    .input_udp_checksum(input_udp_checksum),
    .input_udp_payload_tdata(input_udp_payload_tdata),
    .input_udp_payload_tkeep(input_udp_payload_tkeep),
    .input_udp_payload_tvalid(input_udp_payload_tvalid),
    .input_udp_payload_tready(input_udp_payload_tready),
    .input_udp_payload_tlast(input_udp_payload_tlast),
    .input_udp_payload_tuser(input_udp_payload_tuser),
    // UDP frame output
    .output_udp_hdr_valid(output_udp_hdr_valid),
    .output_udp_hdr_ready(output_udp_hdr_ready),
    .output_udp_eth_dest_mac(output_udp_eth_dest_mac),
    .output_udp_eth_src_mac(output_udp_eth_src_mac),
    .output_udp_eth_type(output_udp_eth_type),
    .output_udp_ip_version(output_udp_ip_version),
    .output_udp_ip_ihl(output_udp_ip_ihl),
    .output_udp_ip_dscp(output_udp_ip_dscp),
    .output_udp_ip_ecn(output_udp_ip_ecn),
    .output_udp_ip_length(output_udp_ip_length),
    .output_udp_ip_identification(output_udp_ip_identification),
    .output_udp_ip_flags(output_udp_ip_flags),
    .output_udp_ip_fragment_offset(output_udp_ip_fragment_offset),
    .output_udp_ip_ttl(output_udp_ip_ttl),
    .output_udp_ip_protocol(output_udp_ip_protocol),
    .output_udp_ip_header_checksum(output_udp_ip_header_checksum),
    .output_udp_ip_source_ip(output_udp_ip_source_ip),
    .output_udp_ip_dest_ip(output_udp_ip_dest_ip),
    .output_udp_source_port(output_udp_source_port),
    .output_udp_dest_port(output_udp_dest_port),
    .output_udp_length(output_udp_length),
    .output_udp_checksum(output_udp_checksum),
    .output_udp_payload_tdata(output_udp_payload_tdata),
    .output_udp_payload_tkeep(output_udp_payload_tkeep),
    .output_udp_payload_tvalid(output_udp_payload_tvalid),
    .output_udp_payload_tready(output_udp_payload_tready),
    .output_udp_payload_tlast(output_udp_payload_tlast),
    .output_udp_payload_tuser(output_udp_payload_tuser),
    // Status
    .rx_busy(udp_rx_busy),
    .tx_busy(udp_tx_busy),
    .rx_error_header_early_termination(udp_rx_error_header_early_termination),
    .rx_error_payload_early_termination(udp_rx_error_payload_early_termination),
    .tx_error_payload_early_termination(udp_tx_error_payload_early_termination)
);

endmodule
