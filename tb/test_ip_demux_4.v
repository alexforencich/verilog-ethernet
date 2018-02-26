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
 * Testbench for ip_demux_4
 */
module test_ip_demux_4;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_ip_hdr_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [3:0] input_ip_version = 0;
reg [3:0] input_ip_ihl = 0;
reg [5:0] input_ip_dscp = 0;
reg [1:0] input_ip_ecn = 0;
reg [15:0] input_ip_length = 0;
reg [15:0] input_ip_identification = 0;
reg [2:0] input_ip_flags = 0;
reg [12:0] input_ip_fragment_offset = 0;
reg [7:0] input_ip_ttl = 0;
reg [7:0] input_ip_protocol = 0;
reg [15:0] input_ip_header_checksum = 0;
reg [31:0] input_ip_source_ip = 0;
reg [31:0] input_ip_dest_ip = 0;
reg [7:0] input_ip_payload_tdata = 0;
reg input_ip_payload_tvalid = 0;
reg input_ip_payload_tlast = 0;
reg input_ip_payload_tuser = 0;

reg output_0_ip_hdr_ready = 0;
reg output_0_ip_payload_tready = 0;
reg output_1_ip_hdr_ready = 0;
reg output_1_ip_payload_tready = 0;
reg output_2_ip_hdr_ready = 0;
reg output_2_ip_payload_tready = 0;
reg output_3_ip_hdr_ready = 0;
reg output_3_ip_payload_tready = 0;

reg enable = 0;
reg [1:0] select = 0;

// Outputs
wire input_ip_hdr_ready;
wire input_ip_payload_tready;

wire output_0_ip_hdr_valid;
wire [47:0] output_0_eth_dest_mac;
wire [47:0] output_0_eth_src_mac;
wire [15:0] output_0_eth_type;
wire [3:0] output_0_ip_version;
wire [3:0] output_0_ip_ihl;
wire [5:0] output_0_ip_dscp;
wire [1:0] output_0_ip_ecn;
wire [15:0] output_0_ip_length;
wire [15:0] output_0_ip_identification;
wire [2:0] output_0_ip_flags;
wire [12:0] output_0_ip_fragment_offset;
wire [7:0] output_0_ip_ttl;
wire [7:0] output_0_ip_protocol;
wire [15:0] output_0_ip_header_checksum;
wire [31:0] output_0_ip_source_ip;
wire [31:0] output_0_ip_dest_ip;
wire [7:0] output_0_ip_payload_tdata;
wire output_0_ip_payload_tvalid;
wire output_0_ip_payload_tlast;
wire output_0_ip_payload_tuser;
wire output_1_ip_hdr_valid;
wire [47:0] output_1_eth_dest_mac;
wire [47:0] output_1_eth_src_mac;
wire [15:0] output_1_eth_type;
wire [3:0] output_1_ip_version;
wire [3:0] output_1_ip_ihl;
wire [5:0] output_1_ip_dscp;
wire [1:0] output_1_ip_ecn;
wire [15:0] output_1_ip_length;
wire [15:0] output_1_ip_identification;
wire [2:0] output_1_ip_flags;
wire [12:0] output_1_ip_fragment_offset;
wire [7:0] output_1_ip_ttl;
wire [7:0] output_1_ip_protocol;
wire [15:0] output_1_ip_header_checksum;
wire [31:0] output_1_ip_source_ip;
wire [31:0] output_1_ip_dest_ip;
wire [7:0] output_1_ip_payload_tdata;
wire output_1_ip_payload_tvalid;
wire output_1_ip_payload_tlast;
wire output_1_ip_payload_tuser;
wire output_2_ip_hdr_valid;
wire [47:0] output_2_eth_dest_mac;
wire [47:0] output_2_eth_src_mac;
wire [15:0] output_2_eth_type;
wire [3:0] output_2_ip_version;
wire [3:0] output_2_ip_ihl;
wire [5:0] output_2_ip_dscp;
wire [1:0] output_2_ip_ecn;
wire [15:0] output_2_ip_length;
wire [15:0] output_2_ip_identification;
wire [2:0] output_2_ip_flags;
wire [12:0] output_2_ip_fragment_offset;
wire [7:0] output_2_ip_ttl;
wire [7:0] output_2_ip_protocol;
wire [15:0] output_2_ip_header_checksum;
wire [31:0] output_2_ip_source_ip;
wire [31:0] output_2_ip_dest_ip;
wire [7:0] output_2_ip_payload_tdata;
wire output_2_ip_payload_tvalid;
wire output_2_ip_payload_tlast;
wire output_2_ip_payload_tuser;
wire output_3_ip_hdr_valid;
wire [47:0] output_3_eth_dest_mac;
wire [47:0] output_3_eth_src_mac;
wire [15:0] output_3_eth_type;
wire [3:0] output_3_ip_version;
wire [3:0] output_3_ip_ihl;
wire [5:0] output_3_ip_dscp;
wire [1:0] output_3_ip_ecn;
wire [15:0] output_3_ip_length;
wire [15:0] output_3_ip_identification;
wire [2:0] output_3_ip_flags;
wire [12:0] output_3_ip_fragment_offset;
wire [7:0] output_3_ip_ttl;
wire [7:0] output_3_ip_protocol;
wire [15:0] output_3_ip_header_checksum;
wire [31:0] output_3_ip_source_ip;
wire [31:0] output_3_ip_dest_ip;
wire [7:0] output_3_ip_payload_tdata;
wire output_3_ip_payload_tvalid;
wire output_3_ip_payload_tlast;
wire output_3_ip_payload_tuser;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_ip_hdr_valid,
        input_eth_dest_mac,
        input_eth_src_mac,
        input_eth_type,
        input_ip_version,
        input_ip_ihl,
        input_ip_dscp,
        input_ip_ecn,
        input_ip_length,
        input_ip_identification,
        input_ip_flags,
        input_ip_fragment_offset,
        input_ip_ttl,
        input_ip_protocol,
        input_ip_header_checksum,
        input_ip_source_ip,
        input_ip_dest_ip,
        input_ip_payload_tdata,
        input_ip_payload_tvalid,
        input_ip_payload_tlast,
        input_ip_payload_tuser,
        output_0_ip_hdr_ready,
        output_0_ip_payload_tready,
        output_1_ip_hdr_ready,
        output_1_ip_payload_tready,
        output_2_ip_hdr_ready,
        output_2_ip_payload_tready,
        output_3_ip_hdr_ready,
        output_3_ip_payload_tready,
        enable,
        select
    );
    $to_myhdl(
        input_ip_hdr_ready,
        input_ip_payload_tready,
        output_0_ip_hdr_valid,
        output_0_eth_dest_mac,
        output_0_eth_src_mac,
        output_0_eth_type,
        output_0_ip_version,
        output_0_ip_ihl,
        output_0_ip_dscp,
        output_0_ip_ecn,
        output_0_ip_length,
        output_0_ip_identification,
        output_0_ip_flags,
        output_0_ip_fragment_offset,
        output_0_ip_ttl,
        output_0_ip_protocol,
        output_0_ip_header_checksum,
        output_0_ip_source_ip,
        output_0_ip_dest_ip,
        output_0_ip_payload_tdata,
        output_0_ip_payload_tvalid,
        output_0_ip_payload_tlast,
        output_0_ip_payload_tuser,
        output_1_ip_hdr_valid,
        output_1_eth_dest_mac,
        output_1_eth_src_mac,
        output_1_eth_type,
        output_1_ip_version,
        output_1_ip_ihl,
        output_1_ip_dscp,
        output_1_ip_ecn,
        output_1_ip_length,
        output_1_ip_identification,
        output_1_ip_flags,
        output_1_ip_fragment_offset,
        output_1_ip_ttl,
        output_1_ip_protocol,
        output_1_ip_header_checksum,
        output_1_ip_source_ip,
        output_1_ip_dest_ip,
        output_1_ip_payload_tdata,
        output_1_ip_payload_tvalid,
        output_1_ip_payload_tlast,
        output_1_ip_payload_tuser,
        output_2_ip_hdr_valid,
        output_2_eth_dest_mac,
        output_2_eth_src_mac,
        output_2_eth_type,
        output_2_ip_version,
        output_2_ip_ihl,
        output_2_ip_dscp,
        output_2_ip_ecn,
        output_2_ip_length,
        output_2_ip_identification,
        output_2_ip_flags,
        output_2_ip_fragment_offset,
        output_2_ip_ttl,
        output_2_ip_protocol,
        output_2_ip_header_checksum,
        output_2_ip_source_ip,
        output_2_ip_dest_ip,
        output_2_ip_payload_tdata,
        output_2_ip_payload_tvalid,
        output_2_ip_payload_tlast,
        output_2_ip_payload_tuser,
        output_3_ip_hdr_valid,
        output_3_eth_dest_mac,
        output_3_eth_src_mac,
        output_3_eth_type,
        output_3_ip_version,
        output_3_ip_ihl,
        output_3_ip_dscp,
        output_3_ip_ecn,
        output_3_ip_length,
        output_3_ip_identification,
        output_3_ip_flags,
        output_3_ip_fragment_offset,
        output_3_ip_ttl,
        output_3_ip_protocol,
        output_3_ip_header_checksum,
        output_3_ip_source_ip,
        output_3_ip_dest_ip,
        output_3_ip_payload_tdata,
        output_3_ip_payload_tvalid,
        output_3_ip_payload_tlast,
        output_3_ip_payload_tuser
    );

    // dump file
    $dumpfile("test_ip_demux_4.lxt");
    $dumpvars(0, test_ip_demux_4);
end

ip_demux_4
UUT (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .input_ip_hdr_valid(input_ip_hdr_valid),
    .input_ip_hdr_ready(input_ip_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_ip_version(input_ip_version),
    .input_ip_ihl(input_ip_ihl),
    .input_ip_dscp(input_ip_dscp),
    .input_ip_ecn(input_ip_ecn),
    .input_ip_length(input_ip_length),
    .input_ip_identification(input_ip_identification),
    .input_ip_flags(input_ip_flags),
    .input_ip_fragment_offset(input_ip_fragment_offset),
    .input_ip_ttl(input_ip_ttl),
    .input_ip_protocol(input_ip_protocol),
    .input_ip_header_checksum(input_ip_header_checksum),
    .input_ip_source_ip(input_ip_source_ip),
    .input_ip_dest_ip(input_ip_dest_ip),
    .input_ip_payload_tdata(input_ip_payload_tdata),
    .input_ip_payload_tvalid(input_ip_payload_tvalid),
    .input_ip_payload_tready(input_ip_payload_tready),
    .input_ip_payload_tlast(input_ip_payload_tlast),
    .input_ip_payload_tuser(input_ip_payload_tuser),
    // IP frame outputs
    .output_0_ip_hdr_valid(output_0_ip_hdr_valid),
    .output_0_ip_hdr_ready(output_0_ip_hdr_ready),
    .output_0_eth_dest_mac(output_0_eth_dest_mac),
    .output_0_eth_src_mac(output_0_eth_src_mac),
    .output_0_eth_type(output_0_eth_type),
    .output_0_ip_version(output_0_ip_version),
    .output_0_ip_ihl(output_0_ip_ihl),
    .output_0_ip_dscp(output_0_ip_dscp),
    .output_0_ip_ecn(output_0_ip_ecn),
    .output_0_ip_length(output_0_ip_length),
    .output_0_ip_identification(output_0_ip_identification),
    .output_0_ip_flags(output_0_ip_flags),
    .output_0_ip_fragment_offset(output_0_ip_fragment_offset),
    .output_0_ip_ttl(output_0_ip_ttl),
    .output_0_ip_protocol(output_0_ip_protocol),
    .output_0_ip_header_checksum(output_0_ip_header_checksum),
    .output_0_ip_source_ip(output_0_ip_source_ip),
    .output_0_ip_dest_ip(output_0_ip_dest_ip),
    .output_0_ip_payload_tdata(output_0_ip_payload_tdata),
    .output_0_ip_payload_tvalid(output_0_ip_payload_tvalid),
    .output_0_ip_payload_tready(output_0_ip_payload_tready),
    .output_0_ip_payload_tlast(output_0_ip_payload_tlast),
    .output_0_ip_payload_tuser(output_0_ip_payload_tuser),
    .output_1_ip_hdr_valid(output_1_ip_hdr_valid),
    .output_1_ip_hdr_ready(output_1_ip_hdr_ready),
    .output_1_eth_dest_mac(output_1_eth_dest_mac),
    .output_1_eth_src_mac(output_1_eth_src_mac),
    .output_1_eth_type(output_1_eth_type),
    .output_1_ip_version(output_1_ip_version),
    .output_1_ip_ihl(output_1_ip_ihl),
    .output_1_ip_dscp(output_1_ip_dscp),
    .output_1_ip_ecn(output_1_ip_ecn),
    .output_1_ip_length(output_1_ip_length),
    .output_1_ip_identification(output_1_ip_identification),
    .output_1_ip_flags(output_1_ip_flags),
    .output_1_ip_fragment_offset(output_1_ip_fragment_offset),
    .output_1_ip_ttl(output_1_ip_ttl),
    .output_1_ip_protocol(output_1_ip_protocol),
    .output_1_ip_header_checksum(output_1_ip_header_checksum),
    .output_1_ip_source_ip(output_1_ip_source_ip),
    .output_1_ip_dest_ip(output_1_ip_dest_ip),
    .output_1_ip_payload_tdata(output_1_ip_payload_tdata),
    .output_1_ip_payload_tvalid(output_1_ip_payload_tvalid),
    .output_1_ip_payload_tready(output_1_ip_payload_tready),
    .output_1_ip_payload_tlast(output_1_ip_payload_tlast),
    .output_1_ip_payload_tuser(output_1_ip_payload_tuser),
    .output_2_ip_hdr_valid(output_2_ip_hdr_valid),
    .output_2_ip_hdr_ready(output_2_ip_hdr_ready),
    .output_2_eth_dest_mac(output_2_eth_dest_mac),
    .output_2_eth_src_mac(output_2_eth_src_mac),
    .output_2_eth_type(output_2_eth_type),
    .output_2_ip_version(output_2_ip_version),
    .output_2_ip_ihl(output_2_ip_ihl),
    .output_2_ip_dscp(output_2_ip_dscp),
    .output_2_ip_ecn(output_2_ip_ecn),
    .output_2_ip_length(output_2_ip_length),
    .output_2_ip_identification(output_2_ip_identification),
    .output_2_ip_flags(output_2_ip_flags),
    .output_2_ip_fragment_offset(output_2_ip_fragment_offset),
    .output_2_ip_ttl(output_2_ip_ttl),
    .output_2_ip_protocol(output_2_ip_protocol),
    .output_2_ip_header_checksum(output_2_ip_header_checksum),
    .output_2_ip_source_ip(output_2_ip_source_ip),
    .output_2_ip_dest_ip(output_2_ip_dest_ip),
    .output_2_ip_payload_tdata(output_2_ip_payload_tdata),
    .output_2_ip_payload_tvalid(output_2_ip_payload_tvalid),
    .output_2_ip_payload_tready(output_2_ip_payload_tready),
    .output_2_ip_payload_tlast(output_2_ip_payload_tlast),
    .output_2_ip_payload_tuser(output_2_ip_payload_tuser),
    .output_3_ip_hdr_valid(output_3_ip_hdr_valid),
    .output_3_ip_hdr_ready(output_3_ip_hdr_ready),
    .output_3_eth_dest_mac(output_3_eth_dest_mac),
    .output_3_eth_src_mac(output_3_eth_src_mac),
    .output_3_eth_type(output_3_eth_type),
    .output_3_ip_version(output_3_ip_version),
    .output_3_ip_ihl(output_3_ip_ihl),
    .output_3_ip_dscp(output_3_ip_dscp),
    .output_3_ip_ecn(output_3_ip_ecn),
    .output_3_ip_length(output_3_ip_length),
    .output_3_ip_identification(output_3_ip_identification),
    .output_3_ip_flags(output_3_ip_flags),
    .output_3_ip_fragment_offset(output_3_ip_fragment_offset),
    .output_3_ip_ttl(output_3_ip_ttl),
    .output_3_ip_protocol(output_3_ip_protocol),
    .output_3_ip_header_checksum(output_3_ip_header_checksum),
    .output_3_ip_source_ip(output_3_ip_source_ip),
    .output_3_ip_dest_ip(output_3_ip_dest_ip),
    .output_3_ip_payload_tdata(output_3_ip_payload_tdata),
    .output_3_ip_payload_tvalid(output_3_ip_payload_tvalid),
    .output_3_ip_payload_tready(output_3_ip_payload_tready),
    .output_3_ip_payload_tlast(output_3_ip_payload_tlast),
    .output_3_ip_payload_tuser(output_3_ip_payload_tuser),
    // Control
    .enable(enable),
    .select(select)
);

endmodule
