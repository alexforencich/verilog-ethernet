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

`timescale 1ns / 1ps

/*
 * IPv4 and ARP block, ethernet frame interface
 */
module ip_complete #(
    parameter ARP_CACHE_ADDR_WIDTH = 9,
    parameter ARP_REQUEST_RETRY_COUNT = 4,
    parameter ARP_REQUEST_RETRY_INTERVAL = 125000000*2,
    parameter ARP_REQUEST_TIMEOUT = 125000000*30
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
    input  wire [7:0]  input_eth_payload_tdata,
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
    output wire [7:0]  output_eth_payload_tdata,
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
    input  wire [7:0]  input_ip_payload_tdata,
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
    output wire [7:0]  output_ip_payload_tdata,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,

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
wire [7:0] ip_rx_eth_payload_tdata;
wire ip_rx_eth_payload_tvalid;
wire ip_rx_eth_payload_tready;
wire ip_rx_eth_payload_tlast;
wire ip_rx_eth_payload_tuser;

wire ip_tx_eth_hdr_valid;
wire ip_tx_eth_hdr_ready;
wire [47:0] ip_tx_eth_dest_mac;
wire [47:0] ip_tx_eth_src_mac;
wire [15:0] ip_tx_eth_type;
wire [7:0] ip_tx_eth_payload_tdata;
wire ip_tx_eth_payload_tvalid;
wire ip_tx_eth_payload_tready;
wire ip_tx_eth_payload_tlast;
wire ip_tx_eth_payload_tuser;

wire arp_rx_eth_hdr_valid;
wire arp_rx_eth_hdr_ready;
wire [47:0] arp_rx_eth_dest_mac;
wire [47:0] arp_rx_eth_src_mac;
wire [15:0] arp_rx_eth_type;
wire [7:0] arp_rx_eth_payload_tdata;
wire arp_rx_eth_payload_tvalid;
wire arp_rx_eth_payload_tready;
wire arp_rx_eth_payload_tlast;
wire arp_rx_eth_payload_tuser;

wire arp_tx_eth_hdr_valid;
wire arp_tx_eth_hdr_ready;
wire [47:0] arp_tx_eth_dest_mac;
wire [47:0] arp_tx_eth_src_mac;
wire [15:0] arp_tx_eth_type;
wire [7:0] arp_tx_eth_payload_tdata;
wire arp_tx_eth_payload_tvalid;
wire arp_tx_eth_payload_tready;
wire arp_tx_eth_payload_tlast;
wire arp_tx_eth_payload_tuser;

/*
 * Input classifier (eth_type)
 */
wire input_select_ip = (input_eth_type == 16'h0800);
wire input_select_arp = (input_eth_type == 16'h0806);
wire input_select_none = ~(input_select_ip | input_select_arp);

reg input_select_ip_reg = 1'b0;
reg input_select_arp_reg = 1'b0;
reg input_select_none_reg = 1'b0;

always @(posedge clk) begin
    if (rst) begin
        input_select_ip_reg <= 1'b0;
        input_select_arp_reg <= 1'b0;
        input_select_none_reg <= 1'b0;
    end else begin
        if (input_eth_payload_tvalid) begin
            if ((~input_select_ip_reg & ~input_select_arp_reg & ~input_select_none_reg) |
                (input_eth_payload_tvalid & input_eth_payload_tready & input_eth_payload_tlast)) begin
                input_select_ip_reg <= input_select_ip;
                input_select_arp_reg <= input_select_arp;
                input_select_none_reg <= input_select_none;
            end
        end else begin
            input_select_ip_reg <= 1'b0;
            input_select_arp_reg <= 1'b0;
            input_select_none_reg <= 1'b0;
        end
    end
end

assign ip_rx_eth_hdr_valid = input_select_ip & input_eth_hdr_valid;
assign ip_rx_eth_dest_mac = input_eth_dest_mac;
assign ip_rx_eth_src_mac = input_eth_src_mac;
assign ip_rx_eth_type = 16'h0800;
assign ip_rx_eth_payload_tdata = input_eth_payload_tdata;
assign ip_rx_eth_payload_tvalid = input_select_ip_reg & input_eth_payload_tvalid;
assign ip_rx_eth_payload_tlast = input_eth_payload_tlast;
assign ip_rx_eth_payload_tuser = input_eth_payload_tuser;

assign arp_rx_eth_hdr_valid = input_select_arp & input_eth_hdr_valid;
assign arp_rx_eth_dest_mac = input_eth_dest_mac;
assign arp_rx_eth_src_mac = input_eth_src_mac;
assign arp_rx_eth_type = 16'h0806;
assign arp_rx_eth_payload_tdata = input_eth_payload_tdata;
assign arp_rx_eth_payload_tvalid = input_select_arp_reg & input_eth_payload_tvalid;
assign arp_rx_eth_payload_tlast = input_eth_payload_tlast;
assign arp_rx_eth_payload_tuser = input_eth_payload_tuser;

assign input_eth_hdr_ready = (input_select_ip & ip_rx_eth_hdr_ready) |
                             (input_select_arp & arp_rx_eth_hdr_ready) |
                             (input_select_none);

assign input_eth_payload_tready = (input_select_ip_reg & ip_rx_eth_payload_tready) |
                                  (input_select_arp_reg & arp_rx_eth_payload_tready) |
                                  input_select_none_reg;

/*
 * Output arbiter
 */
eth_arb_mux_2
eth_arb_mux_2_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame inputs
    // ARP input (highest priority)
    .input_0_eth_hdr_valid(arp_tx_eth_hdr_valid),
    .input_0_eth_hdr_ready(arp_tx_eth_hdr_ready),
    .input_0_eth_dest_mac(arp_tx_eth_dest_mac),
    .input_0_eth_src_mac(arp_tx_eth_src_mac),
    .input_0_eth_type(arp_tx_eth_type),
    .input_0_eth_payload_tdata(arp_tx_eth_payload_tdata),
    .input_0_eth_payload_tvalid(arp_tx_eth_payload_tvalid),
    .input_0_eth_payload_tready(arp_tx_eth_payload_tready),
    .input_0_eth_payload_tlast(arp_tx_eth_payload_tlast),
    .input_0_eth_payload_tuser(arp_tx_eth_payload_tuser),
    // IP input (lowest priority)
    .input_1_eth_hdr_valid(ip_tx_eth_hdr_valid),
    .input_1_eth_hdr_ready(ip_tx_eth_hdr_ready),
    .input_1_eth_dest_mac(ip_tx_eth_dest_mac),
    .input_1_eth_src_mac(ip_tx_eth_src_mac),
    .input_1_eth_type(ip_tx_eth_type),
    .input_1_eth_payload_tdata(ip_tx_eth_payload_tdata),
    .input_1_eth_payload_tvalid(ip_tx_eth_payload_tvalid),
    .input_1_eth_payload_tready(ip_tx_eth_payload_tready),
    .input_1_eth_payload_tlast(ip_tx_eth_payload_tlast),
    .input_1_eth_payload_tuser(ip_tx_eth_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser)
);

/*
 * IP module
 */
ip
ip_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(ip_rx_eth_hdr_valid),
    .input_eth_hdr_ready(ip_rx_eth_hdr_ready),
    .input_eth_dest_mac(ip_rx_eth_dest_mac),
    .input_eth_src_mac(ip_rx_eth_src_mac),
    .input_eth_type(ip_rx_eth_type),
    .input_eth_payload_tdata(ip_rx_eth_payload_tdata),
    .input_eth_payload_tvalid(ip_rx_eth_payload_tvalid),
    .input_eth_payload_tready(ip_rx_eth_payload_tready),
    .input_eth_payload_tlast(ip_rx_eth_payload_tlast),
    .input_eth_payload_tuser(ip_rx_eth_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(ip_tx_eth_hdr_valid),
    .output_eth_hdr_ready(ip_tx_eth_hdr_ready),
    .output_eth_dest_mac(ip_tx_eth_dest_mac),
    .output_eth_src_mac(ip_tx_eth_src_mac),
    .output_eth_type(ip_tx_eth_type),
    .output_eth_payload_tdata(ip_tx_eth_payload_tdata),
    .output_eth_payload_tvalid(ip_tx_eth_payload_tvalid),
    .output_eth_payload_tready(ip_tx_eth_payload_tready),
    .output_eth_payload_tlast(ip_tx_eth_payload_tlast),
    .output_eth_payload_tuser(ip_tx_eth_payload_tuser),
    // IP frame output
    .output_ip_hdr_valid(output_ip_hdr_valid),
    .output_ip_hdr_ready(output_ip_hdr_ready),
    .output_ip_eth_dest_mac(output_ip_eth_dest_mac),
    .output_ip_eth_src_mac(output_ip_eth_src_mac),
    .output_ip_eth_type(output_ip_eth_type),
    .output_ip_version(output_ip_version),
    .output_ip_ihl(output_ip_ihl),
    .output_ip_dscp(output_ip_dscp),
    .output_ip_ecn(output_ip_ecn),
    .output_ip_length(output_ip_length),
    .output_ip_identification(output_ip_identification),
    .output_ip_flags(output_ip_flags),
    .output_ip_fragment_offset(output_ip_fragment_offset),
    .output_ip_ttl(output_ip_ttl),
    .output_ip_protocol(output_ip_protocol),
    .output_ip_header_checksum(output_ip_header_checksum),
    .output_ip_source_ip(output_ip_source_ip),
    .output_ip_dest_ip(output_ip_dest_ip),
    .output_ip_payload_tdata(output_ip_payload_tdata),
    .output_ip_payload_tvalid(output_ip_payload_tvalid),
    .output_ip_payload_tready(output_ip_payload_tready),
    .output_ip_payload_tlast(output_ip_payload_tlast),
    .output_ip_payload_tuser(output_ip_payload_tuser),
    // IP frame input
    .input_ip_hdr_valid(input_ip_hdr_valid),
    .input_ip_hdr_ready(input_ip_hdr_ready),
    .input_ip_dscp(input_ip_dscp),
    .input_ip_ecn(input_ip_ecn),
    .input_ip_length(input_ip_length),
    .input_ip_ttl(input_ip_ttl),
    .input_ip_protocol(input_ip_protocol),
    .input_ip_source_ip(input_ip_source_ip),
    .input_ip_dest_ip(input_ip_dest_ip),
    .input_ip_payload_tdata(input_ip_payload_tdata),
    .input_ip_payload_tvalid(input_ip_payload_tvalid),
    .input_ip_payload_tready(input_ip_payload_tready),
    .input_ip_payload_tlast(input_ip_payload_tlast),
    .input_ip_payload_tuser(input_ip_payload_tuser),
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
    .CACHE_ADDR_WIDTH(ARP_CACHE_ADDR_WIDTH),
    .REQUEST_RETRY_COUNT(ARP_REQUEST_RETRY_COUNT),
    .REQUEST_RETRY_INTERVAL(ARP_REQUEST_RETRY_INTERVAL),
    .REQUEST_TIMEOUT(ARP_REQUEST_TIMEOUT)
)
arp_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(arp_rx_eth_hdr_valid),
    .input_eth_hdr_ready(arp_rx_eth_hdr_ready),
    .input_eth_dest_mac(arp_rx_eth_dest_mac),
    .input_eth_src_mac(arp_rx_eth_src_mac),
    .input_eth_type(arp_rx_eth_type),
    .input_eth_payload_tdata(arp_rx_eth_payload_tdata),
    .input_eth_payload_tvalid(arp_rx_eth_payload_tvalid),
    .input_eth_payload_tready(arp_rx_eth_payload_tready),
    .input_eth_payload_tlast(arp_rx_eth_payload_tlast),
    .input_eth_payload_tuser(arp_rx_eth_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(arp_tx_eth_hdr_valid),
    .output_eth_hdr_ready(arp_tx_eth_hdr_ready),
    .output_eth_dest_mac(arp_tx_eth_dest_mac),
    .output_eth_src_mac(arp_tx_eth_src_mac),
    .output_eth_type(arp_tx_eth_type),
    .output_eth_payload_tdata(arp_tx_eth_payload_tdata),
    .output_eth_payload_tvalid(arp_tx_eth_payload_tvalid),
    .output_eth_payload_tready(arp_tx_eth_payload_tready),
    .output_eth_payload_tlast(arp_tx_eth_payload_tlast),
    .output_eth_payload_tuser(arp_tx_eth_payload_tuser),
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
