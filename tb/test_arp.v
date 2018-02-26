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
 * Testbench for arp
 */
module test_arp;

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

reg output_eth_hdr_ready = 0;
reg output_eth_payload_tready = 0;

reg arp_request_valid = 0;
reg [31:0] arp_request_ip = 0;

reg [47:0] local_mac = 0;
reg [31:0] local_ip = 0;
reg [31:0] gateway_ip = 0;
reg [31:0] subnet_mask = 0;
reg  clear_cache = 0;

// Outputs
wire input_eth_hdr_ready;
wire input_eth_payload_tready;

wire output_eth_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [7:0] output_eth_payload_tdata;
wire output_eth_payload_tvalid;
wire output_eth_payload_tlast;
wire output_eth_payload_tuser;

wire arp_response_valid;
wire arp_response_error;
wire [47:0] arp_response_mac;

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
        output_eth_hdr_ready,
        output_eth_payload_tready,
        arp_request_valid,
        arp_request_ip,
        local_mac,
        local_ip,
        gateway_ip,
        subnet_mask,
        clear_cache
    );
    $to_myhdl(
        input_eth_hdr_ready,
        input_eth_payload_tready,
        output_eth_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_eth_payload_tdata,
        output_eth_payload_tvalid,
        output_eth_payload_tlast,
        output_eth_payload_tuser,
        arp_response_valid,
        arp_response_error,
        arp_response_mac
    );

    // dump file
    $dumpfile("test_arp.lxt");
    $dumpvars(0, test_arp);
end

arp #(
    .CACHE_ADDR_WIDTH(2),
    .REQUEST_RETRY_COUNT(4),
    .REQUEST_RETRY_INTERVAL(150),
    .REQUEST_TIMEOUT(400)
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
    // ARP requests
    .arp_request_valid(arp_request_valid),
    .arp_request_ip(arp_request_ip),
    .arp_response_valid(arp_response_valid),
    .arp_response_error(arp_response_error),
    .arp_response_mac(arp_response_mac),
    // Configuration
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_cache(clear_cache)
);

endmodule
