/*

Copyright (c) 2014-2016 Alex Forencich

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
 * Testbench for udp_complete
 */
module test_udp_complete;

// Parameters
parameter ARP_CACHE_ADDR_WIDTH = 2;
parameter ARP_REQUEST_RETRY_COUNT = 4;
parameter ARP_REQUEST_RETRY_INTERVAL = 150;
parameter ARP_REQUEST_TIMEOUT = 400;
parameter UDP_CHECKSUM_GEN_ENABLE = 1;
parameter UDP_CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH = 11;
parameter UDP_CHECKSUM_HEADER_FIFO_ADDR_WIDTH = 3;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_eth_hdr_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [7:0] input_eth_payload_tdata = 0;
reg input_eth_payload_tvalid = 0;
reg input_eth_payload_tlast = 0;
reg input_eth_payload_tuser = 0;
reg arp_response_valid = 0;
reg arp_response_error = 0;
reg [47:0] arp_response_mac = 0;
reg input_ip_hdr_valid = 0;
reg [5:0] input_ip_dscp = 0;
reg [1:0] input_ip_ecn = 0;
reg [15:0] input_ip_length = 0;
reg [7:0] input_ip_ttl = 0;
reg [7:0] input_ip_protocol = 0;
reg [31:0] input_ip_source_ip = 0;
reg [31:0] input_ip_dest_ip = 0;
reg [7:0] input_ip_payload_tdata = 0;
reg input_ip_payload_tvalid = 0;
reg input_ip_payload_tlast = 0;
reg input_ip_payload_tuser = 0;
reg input_udp_hdr_valid = 0;
reg [5:0] input_udp_ip_dscp = 0;
reg [1:0] input_udp_ip_ecn = 0;
reg [7:0] input_udp_ip_ttl = 0;
reg [31:0] input_udp_ip_source_ip = 0;
reg [31:0] input_udp_ip_dest_ip = 0;
reg [15:0] input_udp_source_port = 0;
reg [15:0] input_udp_dest_port = 0;
reg [15:0] input_udp_length = 0;
reg [15:0] input_udp_checksum = 0;
reg [7:0] input_udp_payload_tdata = 0;
reg input_udp_payload_tvalid = 0;
reg input_udp_payload_tlast = 0;
reg input_udp_payload_tuser = 0;
reg output_eth_hdr_ready = 0;
reg output_eth_payload_tready = 0;
reg output_ip_hdr_ready = 0;
reg output_ip_payload_tready = 0;
reg output_udp_hdr_ready = 0;
reg output_udp_payload_tready = 0;
reg [47:0] local_mac = 0;
reg [31:0] local_ip = 0;
reg [31:0] gateway_ip = 0;
reg [31:0] subnet_mask = 0;
reg  clear_arp_cache = 0;

// Outputs
wire input_eth_hdr_ready;
wire input_eth_payload_tready;
wire input_ip_hdr_ready;
wire input_ip_payload_tready;
wire input_udp_hdr_ready;
wire input_udp_payload_tready;
wire output_eth_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [7:0] output_eth_payload_tdata;
wire output_eth_payload_tvalid;
wire output_eth_payload_tlast;
wire output_eth_payload_tuser;
wire arp_request_valid;
wire [31:0] arp_request_ip;
wire output_ip_hdr_valid;
wire [47:0] output_ip_eth_dest_mac;
wire [47:0] output_ip_eth_src_mac;
wire [15:0] output_ip_eth_type;
wire [3:0] output_ip_version;
wire [3:0] output_ip_ihl;
wire [5:0] output_ip_dscp;
wire [1:0] output_ip_ecn;
wire [15:0] output_ip_length;
wire [15:0] output_ip_identification;
wire [2:0] output_ip_flags;
wire [12:0] output_ip_fragment_offset;
wire [7:0] output_ip_ttl;
wire [7:0] output_ip_protocol;
wire [15:0] output_ip_header_checksum;
wire [31:0] output_ip_source_ip;
wire [31:0] output_ip_dest_ip;
wire [7:0] output_ip_payload_tdata;
wire output_ip_payload_tvalid;
wire output_ip_payload_tlast;
wire output_ip_payload_tuser;
wire output_udp_hdr_valid;
wire [47:0] output_udp_eth_dest_mac;
wire [47:0] output_udp_eth_src_mac;
wire [15:0] output_udp_eth_type;
wire [3:0] output_udp_ip_version;
wire [3:0] output_udp_ip_ihl;
wire [5:0] output_udp_ip_dscp;
wire [1:0] output_udp_ip_ecn;
wire [15:0] output_udp_ip_length;
wire [15:0] output_udp_ip_identification;
wire [2:0] output_udp_ip_flags;
wire [12:0] output_udp_ip_fragment_offset;
wire [7:0] output_udp_ip_ttl;
wire [7:0] output_udp_ip_protocol;
wire [15:0] output_udp_ip_header_checksum;
wire [31:0] output_udp_ip_source_ip;
wire [31:0] output_udp_ip_dest_ip;
wire [15:0] output_udp_source_port;
wire [15:0] output_udp_dest_port;
wire [15:0] output_udp_length;
wire [15:0] output_udp_checksum;
wire [7:0] output_udp_payload_tdata;
wire output_udp_payload_tvalid;
wire output_udp_payload_tlast;
wire output_udp_payload_tuser;
wire ip_rx_busy;
wire ip_tx_busy;
wire udp_rx_busy;
wire udp_tx_busy;
wire ip_rx_error_header_early_termination;
wire ip_rx_error_payload_early_termination;
wire ip_rx_error_invalid_header;
wire ip_rx_error_invalid_checksum;
wire ip_tx_error_payload_early_termination;
wire ip_tx_error_arp_failed;
wire udp_rx_error_header_early_termination;
wire udp_rx_error_payload_early_termination;
wire udp_tx_error_payload_early_termination;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_eth_hdr_valid,
        input_eth_dest_mac,
        input_eth_src_mac,
        input_eth_type,
        input_eth_payload_tdata,
        input_eth_payload_tvalid,
        input_eth_payload_tlast,
        input_eth_payload_tuser,
        input_ip_hdr_valid,
        input_ip_dscp,
        input_ip_ecn,
        input_ip_length,
        input_ip_ttl,
        input_ip_protocol,
        input_ip_source_ip,
        input_ip_dest_ip,
        input_ip_payload_tdata,
        input_ip_payload_tvalid,
        input_ip_payload_tlast,
        input_ip_payload_tuser,
        input_udp_hdr_valid,
        input_udp_ip_dscp,
        input_udp_ip_ecn,
        input_udp_ip_ttl,
        input_udp_ip_source_ip,
        input_udp_ip_dest_ip,
        input_udp_source_port,
        input_udp_dest_port,
        input_udp_length,
        input_udp_checksum,
        input_udp_payload_tdata,
        input_udp_payload_tvalid,
        input_udp_payload_tlast,
        input_udp_payload_tuser,
        output_eth_hdr_ready,
        output_eth_payload_tready,
        output_ip_hdr_ready,
        output_ip_payload_tready,
        output_udp_hdr_ready,
        output_udp_payload_tready,
        local_mac,
        local_ip,
        gateway_ip,
        subnet_mask,
        clear_arp_cache
    );
    $to_myhdl(
        input_eth_hdr_ready,
        input_eth_payload_tready,
        input_ip_hdr_ready,
        input_ip_payload_tready,
        input_udp_hdr_ready,
        input_udp_payload_tready,
        output_eth_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_eth_payload_tdata,
        output_eth_payload_tvalid,
        output_eth_payload_tlast,
        output_eth_payload_tuser,
        output_ip_hdr_valid,
        output_ip_eth_dest_mac,
        output_ip_eth_src_mac,
        output_ip_eth_type,
        output_ip_version,
        output_ip_ihl,
        output_ip_dscp,
        output_ip_ecn,
        output_ip_length,
        output_ip_identification,
        output_ip_flags,
        output_ip_fragment_offset,
        output_ip_ttl,
        output_ip_protocol,
        output_ip_header_checksum,
        output_ip_source_ip,
        output_ip_dest_ip,
        output_ip_payload_tdata,
        output_ip_payload_tvalid,
        output_ip_payload_tlast,
        output_ip_payload_tuser,
        output_udp_hdr_valid,
        output_udp_eth_dest_mac,
        output_udp_eth_src_mac,
        output_udp_eth_type,
        output_udp_ip_version,
        output_udp_ip_ihl,
        output_udp_ip_dscp,
        output_udp_ip_ecn,
        output_udp_ip_length,
        output_udp_ip_identification,
        output_udp_ip_flags,
        output_udp_ip_fragment_offset,
        output_udp_ip_ttl,
        output_udp_ip_protocol,
        output_udp_ip_header_checksum,
        output_udp_ip_source_ip,
        output_udp_ip_dest_ip,
        output_udp_source_port,
        output_udp_dest_port,
        output_udp_length,
        output_udp_checksum,
        output_udp_payload_tdata,
        output_udp_payload_tvalid,
        output_udp_payload_tlast,
        output_udp_payload_tuser,
        ip_rx_busy,
        ip_tx_busy,
        udp_rx_busy,
        udp_tx_busy,
        ip_rx_error_header_early_termination,
        ip_rx_error_payload_early_termination,
        ip_rx_error_invalid_header,
        ip_rx_error_invalid_checksum,
        ip_tx_error_payload_early_termination,
        ip_tx_error_arp_failed,
        udp_rx_error_header_early_termination,
        udp_rx_error_payload_early_termination,
        udp_tx_error_payload_early_termination
    );

    // dump file
    $dumpfile("test_udp_complete.lxt");
    $dumpvars(0, test_udp_complete);
end

udp_complete #(
    .ARP_CACHE_ADDR_WIDTH(ARP_CACHE_ADDR_WIDTH),
    .ARP_REQUEST_RETRY_COUNT(ARP_REQUEST_RETRY_COUNT),
    .ARP_REQUEST_RETRY_INTERVAL(ARP_REQUEST_RETRY_INTERVAL),
    .ARP_REQUEST_TIMEOUT(ARP_REQUEST_TIMEOUT),
    .UDP_CHECKSUM_GEN_ENABLE(UDP_CHECKSUM_GEN_ENABLE),
    .UDP_CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH(UDP_CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH),
    .UDP_CHECKSUM_HEADER_FIFO_ADDR_WIDTH(UDP_CHECKSUM_HEADER_FIFO_ADDR_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(input_eth_hdr_valid),
    .input_eth_hdr_ready(input_eth_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_eth_payload_tdata(input_eth_payload_tdata),
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
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
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
    // UDP frame input
    .input_udp_hdr_valid(input_udp_hdr_valid),
    .input_udp_hdr_ready(input_udp_hdr_ready),
    .input_udp_ip_dscp(input_udp_ip_dscp),
    .input_udp_ip_ecn(input_udp_ip_ecn),
    .input_udp_ip_ttl(input_udp_ip_ttl),
    .input_udp_ip_source_ip(input_udp_ip_source_ip),
    .input_udp_ip_dest_ip(input_udp_ip_dest_ip),
    .input_udp_source_port(input_udp_source_port),
    .input_udp_dest_port(input_udp_dest_port),
    .input_udp_length(input_udp_length),
    .input_udp_checksum(input_udp_checksum),
    .input_udp_payload_tdata(input_udp_payload_tdata),
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
    .output_udp_payload_tvalid(output_udp_payload_tvalid),
    .output_udp_payload_tready(output_udp_payload_tready),
    .output_udp_payload_tlast(output_udp_payload_tlast),
    .output_udp_payload_tuser(output_udp_payload_tuser),
    // Status signals
    .ip_rx_busy(ip_rx_busy),
    .ip_tx_busy(ip_tx_busy),
    .udp_rx_busy(udp_rx_busy),
    .udp_tx_busy(udp_tx_busy),
    .ip_rx_error_header_early_termination(ip_rx_error_header_early_termination),
    .ip_rx_error_payload_early_termination(ip_rx_error_payload_early_termination),
    .ip_rx_error_invalid_header(ip_rx_error_invalid_header),
    .ip_rx_error_invalid_checksum(ip_rx_error_invalid_checksum),
    .ip_tx_error_payload_early_termination(ip_tx_error_payload_early_termination),
    .ip_tx_error_arp_failed(ip_tx_error_arp_failed),
    .udp_rx_error_header_early_termination(udp_rx_error_header_early_termination),
    .udp_rx_error_payload_early_termination(udp_rx_error_payload_early_termination),
    .udp_tx_error_payload_early_termination(udp_tx_error_payload_early_termination),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_arp_cache(clear_arp_cache)
);

endmodule
