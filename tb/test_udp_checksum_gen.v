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

`timescale 1ns / 1ps

/*
 * Testbench for udp_checksum_gen
 */
module test_udp_checksum_gen;

// Parameters
parameter PAYLOAD_FIFO_ADDR_WIDTH = 11;
parameter HEADER_FIFO_ADDR_WIDTH = 3;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_udp_hdr_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [3:0] input_ip_version = 0;
reg [3:0] input_ip_ihl = 0;
reg [5:0] input_ip_dscp = 0;
reg [1:0] input_ip_ecn = 0;
reg [15:0] input_ip_identification = 0;
reg [2:0] input_ip_flags = 0;
reg [12:0] input_ip_fragment_offset = 0;
reg [7:0] input_ip_ttl = 0;
reg [15:0] input_ip_header_checksum = 0;
reg [31:0] input_ip_source_ip = 0;
reg [31:0] input_ip_dest_ip = 0;
reg [15:0] input_udp_source_port = 0;
reg [15:0] input_udp_dest_port = 0;
reg [7:0] input_udp_payload_tdata = 0;
reg input_udp_payload_tvalid = 0;
reg input_udp_payload_tlast = 0;
reg input_udp_payload_tuser = 0;
reg output_udp_hdr_ready = 0;
reg output_udp_payload_tready = 0;

// Outputs
wire input_udp_hdr_ready;
wire input_udp_payload_tready;
wire output_udp_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
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
wire [15:0] output_udp_source_port;
wire [15:0] output_udp_dest_port;
wire [15:0] output_udp_length;
wire [15:0] output_udp_checksum;
wire [7:0] output_udp_payload_tdata;
wire output_udp_payload_tvalid;
wire output_udp_payload_tlast;
wire output_udp_payload_tuser;
wire busy;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_udp_hdr_valid,
        input_eth_dest_mac,
        input_eth_src_mac,
        input_eth_type,
        input_ip_version,
        input_ip_ihl,
        input_ip_dscp,
        input_ip_ecn,
        input_ip_identification,
        input_ip_flags,
        input_ip_fragment_offset,
        input_ip_ttl,
        input_ip_header_checksum,
        input_ip_source_ip,
        input_ip_dest_ip,
        input_udp_source_port,
        input_udp_dest_port,
        input_udp_payload_tdata,
        input_udp_payload_tvalid,
        input_udp_payload_tlast,
        input_udp_payload_tuser,
        output_udp_hdr_ready,
        output_udp_payload_tready
    );
    $to_myhdl(
        input_udp_hdr_ready,
        input_udp_payload_tready,
        output_udp_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
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
        output_udp_source_port,
        output_udp_dest_port,
        output_udp_length,
        output_udp_checksum,
        output_udp_payload_tdata,
        output_udp_payload_tvalid,
        output_udp_payload_tlast,
        output_udp_payload_tuser,
        busy
    );

    // dump file
    $dumpfile("test_udp_checksum_gen.lxt");
    $dumpvars(0, test_udp_checksum_gen);
end

udp_checksum_gen #(
    .PAYLOAD_FIFO_ADDR_WIDTH(PAYLOAD_FIFO_ADDR_WIDTH),
    .HEADER_FIFO_ADDR_WIDTH(HEADER_FIFO_ADDR_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .input_udp_hdr_valid(input_udp_hdr_valid),
    .input_udp_hdr_ready(input_udp_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_ip_version(input_ip_version),
    .input_ip_ihl(input_ip_ihl),
    .input_ip_dscp(input_ip_dscp),
    .input_ip_ecn(input_ip_ecn),
    .input_ip_identification(input_ip_identification),
    .input_ip_flags(input_ip_flags),
    .input_ip_fragment_offset(input_ip_fragment_offset),
    .input_ip_ttl(input_ip_ttl),
    .input_ip_header_checksum(input_ip_header_checksum),
    .input_ip_source_ip(input_ip_source_ip),
    .input_ip_dest_ip(input_ip_dest_ip),
    .input_udp_source_port(input_udp_source_port),
    .input_udp_dest_port(input_udp_dest_port),
    .input_udp_payload_tdata(input_udp_payload_tdata),
    .input_udp_payload_tvalid(input_udp_payload_tvalid),
    .input_udp_payload_tready(input_udp_payload_tready),
    .input_udp_payload_tlast(input_udp_payload_tlast),
    .input_udp_payload_tuser(input_udp_payload_tuser),
    .output_udp_hdr_valid(output_udp_hdr_valid),
    .output_udp_hdr_ready(output_udp_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
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
    .output_udp_source_port(output_udp_source_port),
    .output_udp_dest_port(output_udp_dest_port),
    .output_udp_length(output_udp_length),
    .output_udp_checksum(output_udp_checksum),
    .output_udp_payload_tdata(output_udp_payload_tdata),
    .output_udp_payload_tvalid(output_udp_payload_tvalid),
    .output_udp_payload_tready(output_udp_payload_tready),
    .output_udp_payload_tlast(output_udp_payload_tlast),
    .output_udp_payload_tuser(output_udp_payload_tuser),
    .busy(busy)
);

endmodule
