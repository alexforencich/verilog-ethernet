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
 * IPv4 and ARP block, ethernet frame interface (64 bit datapath)
 */
module ip_complete_64 #(
    parameter ARP_CACHE_ADDR_WIDTH = 9,
    parameter ARP_REQUEST_RETRY_COUNT = 4,
    parameter ARP_REQUEST_RETRY_INTERVAL = 156250000*2,
    parameter ARP_REQUEST_TIMEOUT = 156250000*30
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
     * Status
     */
    output wire rx_busy,
    output wire tx_busy,
    output wire rx_error_header_early_termination,
    output wire rx_error_payload_early_termination,
    output wire rx_error_invalid_header,
    output wire rx_error_invalid_checksum,
    output wire tx_error_payload_early_termination,
    output wire tx_error_arp_failed,

    /*
     * Configuration
     */
    input  wire [47:0] local_mac,
    input  wire [31:0] local_ip,
    input  wire [31:0] gateway_ip,
    input  wire [31:0] subnet_mask,
    input  wire        clear_arp_cache
);

/*

This module integrates the IP and ARP modules for a complete IP stack

*/

wire arp_request_valid;
wire arp_request_ready;
wire [31:0] arp_request_ip;
wire arp_response_valid;
wire arp_response_ready;
wire arp_response_error;
wire [47:0] arp_response_mac;

wire ip_rx_eth_hdr_valid;
wire ip_rx_eth_hdr_ready;
wire [47:0] ip_rx_eth_dest_mac;
wire [47:0] ip_rx_eth_src_mac;
wire [15:0] ip_rx_eth_type;
wire [63:0] ip_rx_eth_payload_axis_tdata;
wire [7:0] ip_rx_eth_payload_axis_tkeep;
wire ip_rx_eth_payload_axis_tvalid;
wire ip_rx_eth_payload_axis_tready;
wire ip_rx_eth_payload_axis_tlast;
wire ip_rx_eth_payload_axis_tuser;

wire ip_tx_eth_hdr_valid;
wire ip_tx_eth_hdr_ready;
wire [47:0] ip_tx_eth_dest_mac;
wire [47:0] ip_tx_eth_src_mac;
wire [15:0] ip_tx_eth_type;
wire [63:0] ip_tx_eth_payload_axis_tdata;
wire [7:0] ip_tx_eth_payload_axis_tkeep;
wire ip_tx_eth_payload_axis_tvalid;
wire ip_tx_eth_payload_axis_tready;
wire ip_tx_eth_payload_axis_tlast;
wire ip_tx_eth_payload_axis_tuser;

wire arp_rx_eth_hdr_valid;
wire arp_rx_eth_hdr_ready;
wire [47:0] arp_rx_eth_dest_mac;
wire [47:0] arp_rx_eth_src_mac;
wire [15:0] arp_rx_eth_type;
wire [63:0] arp_rx_eth_payload_axis_tdata;
wire [7:0] arp_rx_eth_payload_axis_tkeep;
wire arp_rx_eth_payload_axis_tvalid;
wire arp_rx_eth_payload_axis_tready;
wire arp_rx_eth_payload_axis_tlast;
wire arp_rx_eth_payload_axis_tuser;

wire arp_tx_eth_hdr_valid;
wire arp_tx_eth_hdr_ready;
wire [47:0] arp_tx_eth_dest_mac;
wire [47:0] arp_tx_eth_src_mac;
wire [15:0] arp_tx_eth_type;
wire [63:0] arp_tx_eth_payload_axis_tdata;
wire [7:0] arp_tx_eth_payload_axis_tkeep;
wire arp_tx_eth_payload_axis_tvalid;
wire arp_tx_eth_payload_axis_tready;
wire arp_tx_eth_payload_axis_tlast;
wire arp_tx_eth_payload_axis_tuser;

/*
 * Input classifier (eth_type)
 */
wire s_select_ip = (s_eth_type == 16'h0800);
wire s_select_arp = (s_eth_type == 16'h0806);
wire s_select_none = !(s_select_ip || s_select_arp);

reg s_select_ip_reg = 1'b0;
reg s_select_arp_reg = 1'b0;
reg s_select_none_reg = 1'b0;

always @(posedge clk) begin
    if (rst) begin
        s_select_ip_reg <= 1'b0;
        s_select_arp_reg <= 1'b0;
        s_select_none_reg <= 1'b0;
    end else begin
        if (s_eth_payload_axis_tvalid) begin
            if ((!s_select_ip_reg && !s_select_arp_reg && !s_select_none_reg) ||
                (s_eth_payload_axis_tvalid && s_eth_payload_axis_tready && s_eth_payload_axis_tlast)) begin
                s_select_ip_reg <= s_select_ip;
                s_select_arp_reg <= s_select_arp;
                s_select_none_reg <= s_select_none;
            end
        end else begin
            s_select_ip_reg <= 1'b0;
            s_select_arp_reg <= 1'b0;
            s_select_none_reg <= 1'b0;
        end
    end
end

assign ip_rx_eth_hdr_valid = s_select_ip && s_eth_hdr_valid;
assign ip_rx_eth_dest_mac = s_eth_dest_mac;
assign ip_rx_eth_src_mac = s_eth_src_mac;
assign ip_rx_eth_type = 16'h0800;
assign ip_rx_eth_payload_axis_tdata = s_eth_payload_axis_tdata;
assign ip_rx_eth_payload_axis_tkeep = s_eth_payload_axis_tkeep;
assign ip_rx_eth_payload_axis_tvalid = s_select_ip_reg && s_eth_payload_axis_tvalid;
assign ip_rx_eth_payload_axis_tlast = s_eth_payload_axis_tlast;
assign ip_rx_eth_payload_axis_tuser = s_eth_payload_axis_tuser;

assign arp_rx_eth_hdr_valid = s_select_arp && s_eth_hdr_valid;
assign arp_rx_eth_dest_mac = s_eth_dest_mac;
assign arp_rx_eth_src_mac = s_eth_src_mac;
assign arp_rx_eth_type = 16'h0806;
assign arp_rx_eth_payload_axis_tdata = s_eth_payload_axis_tdata;
assign arp_rx_eth_payload_axis_tkeep = s_eth_payload_axis_tkeep;
assign arp_rx_eth_payload_axis_tvalid = s_select_arp_reg && s_eth_payload_axis_tvalid;
assign arp_rx_eth_payload_axis_tlast = s_eth_payload_axis_tlast;
assign arp_rx_eth_payload_axis_tuser = s_eth_payload_axis_tuser;

assign s_eth_hdr_ready = (s_select_ip && ip_rx_eth_hdr_ready) ||
                         (s_select_arp && arp_rx_eth_hdr_ready) ||
                         (s_select_none);

assign s_eth_payload_axis_tready = (s_select_ip_reg && ip_rx_eth_payload_axis_tready) ||
                                   (s_select_arp_reg && arp_rx_eth_payload_axis_tready) ||
                                   s_select_none_reg;

/*
 * Output arbiter
 */
eth_arb_mux #(
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
eth_arb_mux_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame inputs
    .s_eth_hdr_valid({ip_tx_eth_hdr_valid, arp_tx_eth_hdr_valid}),
    .s_eth_hdr_ready({ip_tx_eth_hdr_ready, arp_tx_eth_hdr_ready}),
    .s_eth_dest_mac({ip_tx_eth_dest_mac, arp_tx_eth_dest_mac}),
    .s_eth_src_mac({ip_tx_eth_src_mac, arp_tx_eth_src_mac}),
    .s_eth_type({ip_tx_eth_type, arp_tx_eth_type}),
    .s_eth_payload_axis_tdata({ip_tx_eth_payload_axis_tdata, arp_tx_eth_payload_axis_tdata}),
    .s_eth_payload_axis_tkeep({ip_tx_eth_payload_axis_tkeep, arp_tx_eth_payload_axis_tkeep}),
    .s_eth_payload_axis_tvalid({ip_tx_eth_payload_axis_tvalid, arp_tx_eth_payload_axis_tvalid}),
    .s_eth_payload_axis_tready({ip_tx_eth_payload_axis_tready, arp_tx_eth_payload_axis_tready}),
    .s_eth_payload_axis_tlast({ip_tx_eth_payload_axis_tlast, arp_tx_eth_payload_axis_tlast}),
    .s_eth_payload_axis_tid(0),
    .s_eth_payload_axis_tdest(0),
    .s_eth_payload_axis_tuser({ip_tx_eth_payload_axis_tuser, arp_tx_eth_payload_axis_tuser}),
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
    .m_eth_payload_axis_tid(),
    .m_eth_payload_axis_tdest(),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser)
);

/*
 * IP module
 */
ip_64
ip_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(ip_rx_eth_hdr_valid),
    .s_eth_hdr_ready(ip_rx_eth_hdr_ready),
    .s_eth_dest_mac(ip_rx_eth_dest_mac),
    .s_eth_src_mac(ip_rx_eth_src_mac),
    .s_eth_type(ip_rx_eth_type),
    .s_eth_payload_axis_tdata(ip_rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(ip_rx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(ip_rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(ip_rx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(ip_rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(ip_rx_eth_payload_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(ip_tx_eth_hdr_valid),
    .m_eth_hdr_ready(ip_tx_eth_hdr_ready),
    .m_eth_dest_mac(ip_tx_eth_dest_mac),
    .m_eth_src_mac(ip_tx_eth_src_mac),
    .m_eth_type(ip_tx_eth_type),
    .m_eth_payload_axis_tdata(ip_tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(ip_tx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(ip_tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(ip_tx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(ip_tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(ip_tx_eth_payload_axis_tuser),
    // IP frame output
    .m_ip_hdr_valid(m_ip_hdr_valid),
    .m_ip_hdr_ready(m_ip_hdr_ready),
    .m_ip_eth_dest_mac(m_ip_eth_dest_mac),
    .m_ip_eth_src_mac(m_ip_eth_src_mac),
    .m_ip_eth_type(m_ip_eth_type),
    .m_ip_version(m_ip_version),
    .m_ip_ihl(m_ip_ihl),
    .m_ip_dscp(m_ip_dscp),
    .m_ip_ecn(m_ip_ecn),
    .m_ip_length(m_ip_length),
    .m_ip_identification(m_ip_identification),
    .m_ip_flags(m_ip_flags),
    .m_ip_fragment_offset(m_ip_fragment_offset),
    .m_ip_ttl(m_ip_ttl),
    .m_ip_protocol(m_ip_protocol),
    .m_ip_header_checksum(m_ip_header_checksum),
    .m_ip_source_ip(m_ip_source_ip),
    .m_ip_dest_ip(m_ip_dest_ip),
    .m_ip_payload_axis_tdata(m_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(m_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser),
    // IP frame input
    .s_ip_hdr_valid(s_ip_hdr_valid),
    .s_ip_hdr_ready(s_ip_hdr_ready),
    .s_ip_dscp(s_ip_dscp),
    .s_ip_ecn(s_ip_ecn),
    .s_ip_length(s_ip_length),
    .s_ip_ttl(s_ip_ttl),
    .s_ip_protocol(s_ip_protocol),
    .s_ip_source_ip(s_ip_source_ip),
    .s_ip_dest_ip(s_ip_dest_ip),
    .s_ip_payload_axis_tdata(s_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(s_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(s_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),
    // ARP requests
    .arp_request_valid(arp_request_valid),
    .arp_request_ready(arp_request_ready),
    .arp_request_ip(arp_request_ip),
    .arp_response_valid(arp_response_valid),
    .arp_response_ready(arp_response_ready),
    .arp_response_error(arp_response_error),
    .arp_response_mac(arp_response_mac),
    // Status
    .rx_busy(rx_busy),
    .tx_busy(tx_busy),
    .rx_error_header_early_termination(rx_error_header_early_termination),
    .rx_error_payload_early_termination(rx_error_payload_early_termination),
    .rx_error_invalid_header(rx_error_invalid_header),
    .rx_error_invalid_checksum(rx_error_invalid_checksum),
    .tx_error_payload_early_termination(tx_error_payload_early_termination),
    .tx_error_arp_failed(tx_error_arp_failed),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip)
);

/*
 * ARP module
 */
arp #(
    .DATA_WIDTH(64),
    .KEEP_ENABLE(1),
    .KEEP_WIDTH(8),
    .CACHE_ADDR_WIDTH(ARP_CACHE_ADDR_WIDTH),
    .REQUEST_RETRY_COUNT(ARP_REQUEST_RETRY_COUNT),
    .REQUEST_RETRY_INTERVAL(ARP_REQUEST_RETRY_INTERVAL),
    .REQUEST_TIMEOUT(ARP_REQUEST_TIMEOUT)
)
arp_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(arp_rx_eth_hdr_valid),
    .s_eth_hdr_ready(arp_rx_eth_hdr_ready),
    .s_eth_dest_mac(arp_rx_eth_dest_mac),
    .s_eth_src_mac(arp_rx_eth_src_mac),
    .s_eth_type(arp_rx_eth_type),
    .s_eth_payload_axis_tdata(arp_rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(arp_rx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(arp_rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(arp_rx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(arp_rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(arp_rx_eth_payload_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(arp_tx_eth_hdr_valid),
    .m_eth_hdr_ready(arp_tx_eth_hdr_ready),
    .m_eth_dest_mac(arp_tx_eth_dest_mac),
    .m_eth_src_mac(arp_tx_eth_src_mac),
    .m_eth_type(arp_tx_eth_type),
    .m_eth_payload_axis_tdata(arp_tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(arp_tx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(arp_tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(arp_tx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(arp_tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(arp_tx_eth_payload_axis_tuser),
    // ARP requests
    .arp_request_valid(arp_request_valid),
    .arp_request_ready(arp_request_ready),
    .arp_request_ip(arp_request_ip),
    .arp_response_valid(arp_response_valid),
    .arp_response_ready(arp_response_ready),
    .arp_response_error(arp_response_error),
    .arp_response_mac(arp_response_mac),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_cache(clear_arp_cache)
);

endmodule

`resetall
