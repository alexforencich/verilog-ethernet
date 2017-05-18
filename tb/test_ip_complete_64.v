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
 * Testbench for ip_complete_64
 */
module test_ip_complete_64;

// Parameters
parameter ARP_CACHE_ADDR_WIDTH = 2;
parameter ARP_REQUEST_RETRY_COUNT = 4;
parameter ARP_REQUEST_RETRY_INTERVAL = 150;
parameter ARP_REQUEST_TIMEOUT = 400;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_eth_hdr_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [63:0] input_eth_payload_tdata = 0;
reg [7:0] input_eth_payload_tkeep = 0;
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
reg [63:0] input_ip_payload_tdata = 0;
reg [7:0] input_ip_payload_tkeep = 0;
reg input_ip_payload_tvalid = 0;
reg input_ip_payload_tlast = 0;
reg input_ip_payload_tuser = 0;
reg output_eth_hdr_ready = 0;
reg output_eth_payload_tready = 0;
reg output_ip_hdr_ready = 0;
reg output_ip_payload_tready = 0;
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
wire output_eth_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [63:0] output_eth_payload_tdata;
wire [7:0] output_eth_payload_tkeep;
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
wire [63:0] output_ip_payload_tdata;
wire [7:0] output_ip_payload_tkeep;
wire output_ip_payload_tvalid;
wire output_ip_payload_tlast;
wire output_ip_payload_tuser;
wire rx_busy;
wire tx_busy;
wire rx_error_header_early_termination;
wire rx_error_payload_early_termination;
wire rx_error_invalid_header;
wire rx_error_invalid_checksum;
wire tx_error_payload_early_termination;
wire tx_error_arp_failed;

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
        input_eth_payload_tkeep,
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
        input_ip_payload_tkeep,
        input_ip_payload_tvalid,
        input_ip_payload_tlast,
        input_ip_payload_tuser,
        output_eth_hdr_ready,
        output_eth_payload_tready,
        output_ip_hdr_ready,
        output_ip_payload_tready,
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
        output_eth_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_eth_payload_tdata,
        output_eth_payload_tkeep,
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
        output_ip_payload_tkeep,
        output_ip_payload_tvalid,
        output_ip_payload_tlast,
        output_ip_payload_tuser,
        rx_busy,
        tx_busy,
        rx_error_header_early_termination,
        rx_error_payload_early_termination,
        rx_error_invalid_header,
        rx_error_invalid_checksum,
        tx_error_payload_early_termination,
        tx_error_arp_failed
    );

    // dump file
    $dumpfile("test_ip_complete_64.lxt");
    $dumpvars(0, test_ip_complete_64);
end

ip_complete_64 #(
    .ARP_CACHE_ADDR_WIDTH(ARP_CACHE_ADDR_WIDTH),
    .ARP_REQUEST_RETRY_COUNT(ARP_REQUEST_RETRY_COUNT),
    .ARP_REQUEST_RETRY_INTERVAL(ARP_REQUEST_RETRY_INTERVAL),
    .ARP_REQUEST_TIMEOUT(ARP_REQUEST_TIMEOUT)
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
    .input_ip_payload_tkeep(input_ip_payload_tkeep),
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
    .output_ip_payload_tkeep(output_ip_payload_tkeep),
    .output_ip_payload_tvalid(output_ip_payload_tvalid),
    .output_ip_payload_tready(output_ip_payload_tready),
    .output_ip_payload_tlast(output_ip_payload_tlast),
    .output_ip_payload_tuser(output_ip_payload_tuser),
    // Status signals
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
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_arp_cache(clear_arp_cache)
);

endmodule
