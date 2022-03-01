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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * IPv4 and ARP block with UDP support, ethernet frame interface (64 bit datapath)
 */
module udp_complete_64 #(
    parameter ARP_CACHE_ADDR_WIDTH = 9,
    parameter ARP_REQUEST_RETRY_COUNT = 4,
    parameter ARP_REQUEST_RETRY_INTERVAL = 125000000*2,
    parameter ARP_REQUEST_TIMEOUT = 125000000*30,
    parameter UDP_CHECKSUM_GEN_ENABLE = 1,
    parameter UDP_CHECKSUM_PAYLOAD_FIFO_DEPTH = 2048,
    parameter UDP_CHECKSUM_HEADER_FIFO_DEPTH = 8
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame input
     */
    input  wire        s_eth_hdr_valid,
    output wire        s_eth_hdr_ready,
    input  wire [47:0] s_eth_dest_mac,
    input  wire [47:0] s_eth_src_mac,
    input  wire [15:0] s_eth_type,
    input  wire [63:0] s_eth_payload_axis_tdata,
    input  wire [7:0]  s_eth_payload_axis_tkeep,
    input  wire        s_eth_payload_axis_tvalid,
    output wire        s_eth_payload_axis_tready,
    input  wire        s_eth_payload_axis_tlast,
    input  wire        s_eth_payload_axis_tuser,
    
    /*
     * Ethernet frame output
     */
    output wire        m_eth_hdr_valid,
    input  wire        m_eth_hdr_ready,
    output wire [47:0] m_eth_dest_mac,
    output wire [47:0] m_eth_src_mac,
    output wire [15:0] m_eth_type,
    output wire [63:0] m_eth_payload_axis_tdata,
    output wire [7:0]  m_eth_payload_axis_tkeep,
    output wire        m_eth_payload_axis_tvalid,
    input  wire        m_eth_payload_axis_tready,
    output wire        m_eth_payload_axis_tlast,
    output wire        m_eth_payload_axis_tuser,
    
    /*
     * IP input
     */
    input  wire        s_ip_hdr_valid,
    output wire        s_ip_hdr_ready,
    input  wire [5:0]  s_ip_dscp,
    input  wire [1:0]  s_ip_ecn,
    input  wire [15:0] s_ip_length,
    input  wire [7:0]  s_ip_ttl,
    input  wire [7:0]  s_ip_protocol,
    input  wire [31:0] s_ip_source_ip,
    input  wire [31:0] s_ip_dest_ip,
    input  wire [63:0] s_ip_payload_axis_tdata,
    input  wire [7:0]  s_ip_payload_axis_tkeep,
    input  wire        s_ip_payload_axis_tvalid,
    output wire        s_ip_payload_axis_tready,
    input  wire        s_ip_payload_axis_tlast,
    input  wire        s_ip_payload_axis_tuser,
    
    /*
     * IP output
     */
    output wire        m_ip_hdr_valid,
    input  wire        m_ip_hdr_ready,
    output wire [47:0] m_ip_eth_dest_mac,
    output wire [47:0] m_ip_eth_src_mac,
    output wire [15:0] m_ip_eth_type,
    output wire [3:0]  m_ip_version,
    output wire [3:0]  m_ip_ihl,
    output wire [5:0]  m_ip_dscp,
    output wire [1:0]  m_ip_ecn,
    output wire [15:0] m_ip_length,
    output wire [15:0] m_ip_identification,
    output wire [2:0]  m_ip_flags,
    output wire [12:0] m_ip_fragment_offset,
    output wire [7:0]  m_ip_ttl,
    output wire [7:0]  m_ip_protocol,
    output wire [15:0] m_ip_header_checksum,
    output wire [31:0] m_ip_source_ip,
    output wire [31:0] m_ip_dest_ip,
    output wire [63:0] m_ip_payload_axis_tdata,
    output wire [7:0]  m_ip_payload_axis_tkeep,
    output wire        m_ip_payload_axis_tvalid,
    input  wire        m_ip_payload_axis_tready,
    output wire        m_ip_payload_axis_tlast,
    output wire        m_ip_payload_axis_tuser,
    
    /*
     * UDP input
     */
    input  wire        s_udp_hdr_valid,
    output wire        s_udp_hdr_ready,
    input  wire [5:0]  s_udp_ip_dscp,
    input  wire [1:0]  s_udp_ip_ecn,
    input  wire [7:0]  s_udp_ip_ttl,
    input  wire [31:0] s_udp_ip_source_ip,
    input  wire [31:0] s_udp_ip_dest_ip,
    input  wire [15:0] s_udp_source_port,
    input  wire [15:0] s_udp_dest_port,
    input  wire [15:0] s_udp_length,
    input  wire [15:0] s_udp_checksum,
    input  wire [63:0] s_udp_payload_axis_tdata,
    input  wire [7:0]  s_udp_payload_axis_tkeep,
    input  wire        s_udp_payload_axis_tvalid,
    output wire        s_udp_payload_axis_tready,
    input  wire        s_udp_payload_axis_tlast,
    input  wire        s_udp_payload_axis_tuser,
    
    /*
     * UDP output
     */
    output wire        m_udp_hdr_valid,
    input  wire        m_udp_hdr_ready,
    output wire [47:0] m_udp_eth_dest_mac,
    output wire [47:0] m_udp_eth_src_mac,
    output wire [15:0] m_udp_eth_type,
    output wire [3:0]  m_udp_ip_version,
    output wire [3:0]  m_udp_ip_ihl,
    output wire [5:0]  m_udp_ip_dscp,
    output wire [1:0]  m_udp_ip_ecn,
    output wire [15:0] m_udp_ip_length,
    output wire [15:0] m_udp_ip_identification,
    output wire [2:0]  m_udp_ip_flags,
    output wire [12:0] m_udp_ip_fragment_offset,
    output wire [7:0]  m_udp_ip_ttl,
    output wire [7:0]  m_udp_ip_protocol,
    output wire [15:0] m_udp_ip_header_checksum,
    output wire [31:0] m_udp_ip_source_ip,
    output wire [31:0] m_udp_ip_dest_ip,
    output wire [15:0] m_udp_source_port,
    output wire [15:0] m_udp_dest_port,
    output wire [15:0] m_udp_length,
    output wire [15:0] m_udp_checksum,
    output wire [63:0] m_udp_payload_axis_tdata,
    output wire [7:0]  m_udp_payload_axis_tkeep,
    output wire        m_udp_payload_axis_tvalid,
    input  wire        m_udp_payload_axis_tready,
    output wire        m_udp_payload_axis_tlast,
    output wire        m_udp_payload_axis_tuser,

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
wire [63:0] ip_rx_ip_payload_axis_tdata;
wire [7:0] ip_rx_ip_payload_axis_tkeep;
wire ip_rx_ip_payload_axis_tvalid;
wire ip_rx_ip_payload_axis_tlast;
wire ip_rx_ip_payload_axis_tuser;
wire ip_rx_ip_payload_axis_tready;

wire ip_tx_ip_hdr_valid;
wire ip_tx_ip_hdr_ready;
wire [5:0] ip_tx_ip_dscp;
wire [1:0] ip_tx_ip_ecn;
wire [15:0] ip_tx_ip_length;
wire [7:0] ip_tx_ip_ttl;
wire [7:0] ip_tx_ip_protocol;
wire [31:0] ip_tx_ip_source_ip;
wire [31:0] ip_tx_ip_dest_ip;
wire [63:0] ip_tx_ip_payload_axis_tdata;
wire [7:0] ip_tx_ip_payload_axis_tkeep;
wire ip_tx_ip_payload_axis_tvalid;
wire ip_tx_ip_payload_axis_tlast;
wire ip_tx_ip_payload_axis_tuser;
wire ip_tx_ip_payload_axis_tready;

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
wire [63:0] udp_rx_ip_payload_axis_tdata;
wire [7:0] udp_rx_ip_payload_axis_tkeep;
wire udp_rx_ip_payload_axis_tvalid;
wire udp_rx_ip_payload_axis_tlast;
wire udp_rx_ip_payload_axis_tuser;
wire udp_rx_ip_payload_axis_tready;

wire udp_tx_ip_hdr_valid;
wire udp_tx_ip_hdr_ready;
wire [5:0] udp_tx_ip_dscp;
wire [1:0] udp_tx_ip_ecn;
wire [15:0] udp_tx_ip_length;
wire [7:0] udp_tx_ip_ttl;
wire [7:0] udp_tx_ip_protocol;
wire [31:0] udp_tx_ip_source_ip;
wire [31:0] udp_tx_ip_dest_ip;
wire [63:0] udp_tx_ip_payload_axis_tdata;
wire [7:0] udp_tx_ip_payload_axis_tkeep;
wire udp_tx_ip_payload_axis_tvalid;
wire udp_tx_ip_payload_axis_tlast;
wire udp_tx_ip_payload_axis_tuser;
wire udp_tx_ip_payload_axis_tready;

/*
 * Input classifier (ip_protocol)
 */
wire s_select_udp = (ip_rx_ip_protocol == 8'h11);
wire s_select_ip = !s_select_udp;

reg s_select_udp_reg = 1'b0;
reg s_select_ip_reg = 1'b0;

always @(posedge clk) begin
    if (rst) begin
        s_select_udp_reg <= 1'b0;
        s_select_ip_reg <= 1'b0;
    end else begin
        if (ip_rx_ip_payload_axis_tvalid) begin
            if ((!s_select_udp_reg && !s_select_ip_reg) ||
                (ip_rx_ip_payload_axis_tvalid && ip_rx_ip_payload_axis_tready && ip_rx_ip_payload_axis_tlast)) begin
                s_select_udp_reg <= s_select_udp;
                s_select_ip_reg <= s_select_ip;
            end
        end else begin
            s_select_udp_reg <= 1'b0;
            s_select_ip_reg <= 1'b0;
        end
    end
end

// IP frame to UDP module
assign udp_rx_ip_hdr_valid = s_select_udp && ip_rx_ip_hdr_valid;
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
assign udp_rx_ip_payload_axis_tdata = ip_rx_ip_payload_axis_tdata;
assign udp_rx_ip_payload_axis_tkeep = ip_rx_ip_payload_axis_tkeep;
assign udp_rx_ip_payload_axis_tvalid = s_select_udp_reg && ip_rx_ip_payload_axis_tvalid;
assign udp_rx_ip_payload_axis_tlast = ip_rx_ip_payload_axis_tlast;
assign udp_rx_ip_payload_axis_tuser = ip_rx_ip_payload_axis_tuser;

// External IP frame output
assign m_ip_hdr_valid = s_select_ip && ip_rx_ip_hdr_valid;
assign m_ip_eth_dest_mac = ip_rx_ip_eth_dest_mac;
assign m_ip_eth_src_mac = ip_rx_ip_eth_src_mac;
assign m_ip_eth_type = ip_rx_ip_eth_type;
assign m_ip_version = ip_rx_ip_version;
assign m_ip_ihl = ip_rx_ip_ihl;
assign m_ip_dscp = ip_rx_ip_dscp;
assign m_ip_ecn = ip_rx_ip_ecn;
assign m_ip_length = ip_rx_ip_length;
assign m_ip_identification = ip_rx_ip_identification;
assign m_ip_flags = ip_rx_ip_flags;
assign m_ip_fragment_offset = ip_rx_ip_fragment_offset;
assign m_ip_ttl = ip_rx_ip_ttl;
assign m_ip_protocol = ip_rx_ip_protocol;
assign m_ip_header_checksum = ip_rx_ip_header_checksum;
assign m_ip_source_ip = ip_rx_ip_source_ip;
assign m_ip_dest_ip = ip_rx_ip_dest_ip;
assign m_ip_payload_axis_tdata = ip_rx_ip_payload_axis_tdata;
assign m_ip_payload_axis_tkeep = ip_rx_ip_payload_axis_tkeep;
assign m_ip_payload_axis_tvalid = s_select_ip_reg && ip_rx_ip_payload_axis_tvalid;
assign m_ip_payload_axis_tlast = ip_rx_ip_payload_axis_tlast;
assign m_ip_payload_axis_tuser = ip_rx_ip_payload_axis_tuser;

assign ip_rx_ip_hdr_ready = (s_select_udp && udp_rx_ip_hdr_ready) ||
                            (s_select_ip && m_ip_hdr_ready);

assign ip_rx_ip_payload_axis_tready = (s_select_udp_reg && udp_rx_ip_payload_axis_tready) ||
                                      (s_select_ip_reg && m_ip_payload_axis_tready);

/*
 * Output arbiter
 */
ip_arb_mux #(
    .S_COUNT(2),
    .DATA_WIDTH(64),
    .KEEP_ENABLE(1),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(1),
    .ARB_TYPE_ROUND_ROBIN(0),
    .ARB_LSB_HIGH_PRIORITY(1)
)
ip_arb_mux_inst (
    .clk(clk),
    .rst(rst),
    // IP frame inputs
    .s_ip_hdr_valid({s_ip_hdr_valid, udp_tx_ip_hdr_valid}),
    .s_ip_hdr_ready({s_ip_hdr_ready, udp_tx_ip_hdr_ready}),
    .s_eth_dest_mac(0),
    .s_eth_src_mac(0),
    .s_eth_type(0),
    .s_ip_version(0),
    .s_ip_ihl(0),
    .s_ip_dscp({s_ip_dscp, udp_tx_ip_dscp}),
    .s_ip_ecn({s_ip_ecn, udp_tx_ip_ecn}),
    .s_ip_length({s_ip_length, udp_tx_ip_length}),
    .s_ip_identification(0),
    .s_ip_flags(0),
    .s_ip_fragment_offset(0),
    .s_ip_ttl({s_ip_ttl, udp_tx_ip_ttl}),
    .s_ip_protocol({s_ip_protocol, udp_tx_ip_protocol}),
    .s_ip_header_checksum(0),
    .s_ip_source_ip({s_ip_source_ip, udp_tx_ip_source_ip}),
    .s_ip_dest_ip({s_ip_dest_ip, udp_tx_ip_dest_ip}),
    .s_ip_payload_axis_tdata({s_ip_payload_axis_tdata, udp_tx_ip_payload_axis_tdata}),
    .s_ip_payload_axis_tkeep({s_ip_payload_axis_tkeep, udp_tx_ip_payload_axis_tkeep}),
    .s_ip_payload_axis_tvalid({s_ip_payload_axis_tvalid, udp_tx_ip_payload_axis_tvalid}),
    .s_ip_payload_axis_tready({s_ip_payload_axis_tready, udp_tx_ip_payload_axis_tready}),
    .s_ip_payload_axis_tlast({s_ip_payload_axis_tlast, udp_tx_ip_payload_axis_tlast}),
    .s_ip_payload_axis_tid(0),
    .s_ip_payload_axis_tdest(0),
    .s_ip_payload_axis_tuser({s_ip_payload_axis_tuser, udp_tx_ip_payload_axis_tuser}),
    // IP frame output
    .m_ip_hdr_valid(ip_tx_ip_hdr_valid),
    .m_ip_hdr_ready(ip_tx_ip_hdr_ready),
    .m_eth_dest_mac(),
    .m_eth_src_mac(),
    .m_eth_type(),
    .m_ip_version(),
    .m_ip_ihl(),
    .m_ip_dscp(ip_tx_ip_dscp),
    .m_ip_ecn(ip_tx_ip_ecn),
    .m_ip_length(ip_tx_ip_length),
    .m_ip_identification(),
    .m_ip_flags(),
    .m_ip_fragment_offset(),
    .m_ip_ttl(ip_tx_ip_ttl),
    .m_ip_protocol(ip_tx_ip_protocol),
    .m_ip_header_checksum(),
    .m_ip_source_ip(ip_tx_ip_source_ip),
    .m_ip_dest_ip(ip_tx_ip_dest_ip),
    .m_ip_payload_axis_tdata(ip_tx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(ip_tx_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(ip_tx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(ip_tx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(ip_tx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tid(),
    .m_ip_payload_axis_tdest(),
    .m_ip_payload_axis_tuser(ip_tx_ip_payload_axis_tuser)
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
    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(s_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(m_eth_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(m_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(m_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),
    // IP frame input
    .s_ip_hdr_valid(ip_tx_ip_hdr_valid),
    .s_ip_hdr_ready(ip_tx_ip_hdr_ready),
    .s_ip_dscp(ip_tx_ip_dscp),
    .s_ip_ecn(ip_tx_ip_ecn),
    .s_ip_length(ip_tx_ip_length),
    .s_ip_ttl(ip_tx_ip_ttl),
    .s_ip_protocol(ip_tx_ip_protocol),
    .s_ip_source_ip(ip_tx_ip_source_ip),
    .s_ip_dest_ip(ip_tx_ip_dest_ip),
    .s_ip_payload_axis_tdata(ip_tx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(ip_tx_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(ip_tx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(ip_tx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(ip_tx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(ip_tx_ip_payload_axis_tuser),
    // IP frame output
    .m_ip_hdr_valid(ip_rx_ip_hdr_valid),
    .m_ip_hdr_ready(ip_rx_ip_hdr_ready),
    .m_ip_eth_dest_mac(ip_rx_ip_eth_dest_mac),
    .m_ip_eth_src_mac(ip_rx_ip_eth_src_mac),
    .m_ip_eth_type(ip_rx_ip_eth_type),
    .m_ip_version(ip_rx_ip_version),
    .m_ip_ihl(ip_rx_ip_ihl),
    .m_ip_dscp(ip_rx_ip_dscp),
    .m_ip_ecn(ip_rx_ip_ecn),
    .m_ip_length(ip_rx_ip_length),
    .m_ip_identification(ip_rx_ip_identification),
    .m_ip_flags(ip_rx_ip_flags),
    .m_ip_fragment_offset(ip_rx_ip_fragment_offset),
    .m_ip_ttl(ip_rx_ip_ttl),
    .m_ip_protocol(ip_rx_ip_protocol),
    .m_ip_header_checksum(ip_rx_ip_header_checksum),
    .m_ip_source_ip(ip_rx_ip_source_ip),
    .m_ip_dest_ip(ip_rx_ip_dest_ip),
    .m_ip_payload_axis_tdata(ip_rx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(ip_rx_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(ip_rx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(ip_rx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(ip_rx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(ip_rx_ip_payload_axis_tuser),
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
    .CHECKSUM_PAYLOAD_FIFO_DEPTH(UDP_CHECKSUM_PAYLOAD_FIFO_DEPTH),
    .CHECKSUM_HEADER_FIFO_DEPTH(UDP_CHECKSUM_HEADER_FIFO_DEPTH)
)
udp_64_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .s_ip_hdr_valid(udp_rx_ip_hdr_valid),
    .s_ip_hdr_ready(udp_rx_ip_hdr_ready),
    .s_ip_eth_dest_mac(udp_rx_ip_eth_dest_mac),
    .s_ip_eth_src_mac(udp_rx_ip_eth_src_mac),
    .s_ip_eth_type(udp_rx_ip_eth_type),
    .s_ip_version(udp_rx_ip_version),
    .s_ip_ihl(udp_rx_ip_ihl),
    .s_ip_dscp(udp_rx_ip_dscp),
    .s_ip_ecn(udp_rx_ip_ecn),
    .s_ip_length(udp_rx_ip_length),
    .s_ip_identification(udp_rx_ip_identification),
    .s_ip_flags(udp_rx_ip_flags),
    .s_ip_fragment_offset(udp_rx_ip_fragment_offset),
    .s_ip_ttl(udp_rx_ip_ttl),
    .s_ip_protocol(udp_rx_ip_protocol),
    .s_ip_header_checksum(udp_rx_ip_header_checksum),
    .s_ip_source_ip(udp_rx_ip_source_ip),
    .s_ip_dest_ip(udp_rx_ip_dest_ip),
    .s_ip_payload_axis_tdata(udp_rx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(udp_rx_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(udp_rx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(udp_rx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(udp_rx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(udp_rx_ip_payload_axis_tuser),
    // IP frame output
    .m_ip_hdr_valid(udp_tx_ip_hdr_valid),
    .m_ip_hdr_ready(udp_tx_ip_hdr_ready),
    .m_ip_eth_dest_mac(),
    .m_ip_eth_src_mac(),
    .m_ip_eth_type(),
    .m_ip_version(),
    .m_ip_ihl(),
    .m_ip_dscp(udp_tx_ip_dscp),
    .m_ip_ecn(udp_tx_ip_ecn),
    .m_ip_length(udp_tx_ip_length),
    .m_ip_identification(),
    .m_ip_flags(),
    .m_ip_fragment_offset(),
    .m_ip_ttl(udp_tx_ip_ttl),
    .m_ip_protocol(udp_tx_ip_protocol),
    .m_ip_header_checksum(),
    .m_ip_source_ip(udp_tx_ip_source_ip),
    .m_ip_dest_ip(udp_tx_ip_dest_ip),
    .m_ip_payload_axis_tdata(udp_tx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(udp_tx_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(udp_tx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(udp_tx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(udp_tx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(udp_tx_ip_payload_axis_tuser),
    // UDP frame input
    .s_udp_hdr_valid(s_udp_hdr_valid),
    .s_udp_hdr_ready(s_udp_hdr_ready),
    .s_udp_eth_dest_mac(48'd0),
    .s_udp_eth_src_mac(48'd0),
    .s_udp_eth_type(16'd0),
    .s_udp_ip_version(4'd0),
    .s_udp_ip_ihl(4'd0),
    .s_udp_ip_dscp(s_udp_ip_dscp),
    .s_udp_ip_ecn(s_udp_ip_ecn),
    .s_udp_ip_identification(16'd0),
    .s_udp_ip_flags(3'd0),
    .s_udp_ip_fragment_offset(13'd0),
    .s_udp_ip_ttl(s_udp_ip_ttl),
    .s_udp_ip_header_checksum(16'd0),
    .s_udp_ip_source_ip(s_udp_ip_source_ip),
    .s_udp_ip_dest_ip(s_udp_ip_dest_ip),
    .s_udp_source_port(s_udp_source_port),
    .s_udp_dest_port(s_udp_dest_port),
    .s_udp_length(s_udp_length),
    .s_udp_checksum(s_udp_checksum),
    .s_udp_payload_axis_tdata(s_udp_payload_axis_tdata),
    .s_udp_payload_axis_tkeep(s_udp_payload_axis_tkeep),
    .s_udp_payload_axis_tvalid(s_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready(s_udp_payload_axis_tready),
    .s_udp_payload_axis_tlast(s_udp_payload_axis_tlast),
    .s_udp_payload_axis_tuser(s_udp_payload_axis_tuser),
    // UDP frame output
    .m_udp_hdr_valid(m_udp_hdr_valid),
    .m_udp_hdr_ready(m_udp_hdr_ready),
    .m_udp_eth_dest_mac(m_udp_eth_dest_mac),
    .m_udp_eth_src_mac(m_udp_eth_src_mac),
    .m_udp_eth_type(m_udp_eth_type),
    .m_udp_ip_version(m_udp_ip_version),
    .m_udp_ip_ihl(m_udp_ip_ihl),
    .m_udp_ip_dscp(m_udp_ip_dscp),
    .m_udp_ip_ecn(m_udp_ip_ecn),
    .m_udp_ip_length(m_udp_ip_length),
    .m_udp_ip_identification(m_udp_ip_identification),
    .m_udp_ip_flags(m_udp_ip_flags),
    .m_udp_ip_fragment_offset(m_udp_ip_fragment_offset),
    .m_udp_ip_ttl(m_udp_ip_ttl),
    .m_udp_ip_protocol(m_udp_ip_protocol),
    .m_udp_ip_header_checksum(m_udp_ip_header_checksum),
    .m_udp_ip_source_ip(m_udp_ip_source_ip),
    .m_udp_ip_dest_ip(m_udp_ip_dest_ip),
    .m_udp_source_port(m_udp_source_port),
    .m_udp_dest_port(m_udp_dest_port),
    .m_udp_length(m_udp_length),
    .m_udp_checksum(m_udp_checksum),
    .m_udp_payload_axis_tdata(m_udp_payload_axis_tdata),
    .m_udp_payload_axis_tkeep(m_udp_payload_axis_tkeep),
    .m_udp_payload_axis_tvalid(m_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready(m_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast(m_udp_payload_axis_tlast),
    .m_udp_payload_axis_tuser(m_udp_payload_axis_tuser),
    // Status
    .rx_busy(udp_rx_busy),
    .tx_busy(udp_tx_busy),
    .rx_error_header_early_termination(udp_rx_error_header_early_termination),
    .rx_error_payload_early_termination(udp_rx_error_payload_early_termination),
    .tx_error_payload_early_termination(udp_tx_error_payload_early_termination)
);

endmodule

`resetall
