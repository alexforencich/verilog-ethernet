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
 * IP 2 port arbitrated multiplexer
 */
module ip_arb_mux_2 #
(
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "PRIORITY",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * IP frame inputs
     */
    input  wire        input_0_ip_hdr_valid,
    output wire        input_0_ip_hdr_ready,
    input  wire [47:0] input_0_eth_dest_mac,
    input  wire [47:0] input_0_eth_src_mac,
    input  wire [15:0] input_0_eth_type,
    input  wire [3:0]  input_0_ip_version,
    input  wire [3:0]  input_0_ip_ihl,
    input  wire [5:0]  input_0_ip_dscp,
    input  wire [1:0]  input_0_ip_ecn,
    input  wire [15:0] input_0_ip_length,
    input  wire [15:0] input_0_ip_identification,
    input  wire [2:0]  input_0_ip_flags,
    input  wire [12:0] input_0_ip_fragment_offset,
    input  wire [7:0]  input_0_ip_ttl,
    input  wire [7:0]  input_0_ip_protocol,
    input  wire [15:0] input_0_ip_header_checksum,
    input  wire [31:0] input_0_ip_source_ip,
    input  wire [31:0] input_0_ip_dest_ip,
    input  wire [7:0]  input_0_ip_payload_tdata,
    input  wire        input_0_ip_payload_tvalid,
    output wire        input_0_ip_payload_tready,
    input  wire        input_0_ip_payload_tlast,
    input  wire        input_0_ip_payload_tuser,

    input  wire        input_1_ip_hdr_valid,
    output wire        input_1_ip_hdr_ready,
    input  wire [47:0] input_1_eth_dest_mac,
    input  wire [47:0] input_1_eth_src_mac,
    input  wire [15:0] input_1_eth_type,
    input  wire [3:0]  input_1_ip_version,
    input  wire [3:0]  input_1_ip_ihl,
    input  wire [5:0]  input_1_ip_dscp,
    input  wire [1:0]  input_1_ip_ecn,
    input  wire [15:0] input_1_ip_length,
    input  wire [15:0] input_1_ip_identification,
    input  wire [2:0]  input_1_ip_flags,
    input  wire [12:0] input_1_ip_fragment_offset,
    input  wire [7:0]  input_1_ip_ttl,
    input  wire [7:0]  input_1_ip_protocol,
    input  wire [15:0] input_1_ip_header_checksum,
    input  wire [31:0] input_1_ip_source_ip,
    input  wire [31:0] input_1_ip_dest_ip,
    input  wire [7:0]  input_1_ip_payload_tdata,
    input  wire        input_1_ip_payload_tvalid,
    output wire        input_1_ip_payload_tready,
    input  wire        input_1_ip_payload_tlast,
    input  wire        input_1_ip_payload_tuser,

    /*
     * IP frame output
     */
    output wire        output_ip_hdr_valid,
    input  wire        output_ip_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
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
    output wire        output_ip_payload_tuser
);

wire [1:0] request;
wire [1:0] acknowledge;
wire [1:0] grant;
wire grant_valid;
wire [0:0] grant_encoded;

assign acknowledge[0] = input_0_ip_payload_tvalid & input_0_ip_payload_tready & input_0_ip_payload_tlast;
assign request[0] = input_0_ip_hdr_valid;
assign acknowledge[1] = input_1_ip_payload_tvalid & input_1_ip_payload_tready & input_1_ip_payload_tlast;
assign request[1] = input_1_ip_hdr_valid;

// mux instance
ip_mux_2
mux_inst (
    .clk(clk),
    .rst(rst),
    .input_0_ip_hdr_valid(input_0_ip_hdr_valid & grant[0]),
    .input_0_ip_hdr_ready(input_0_ip_hdr_ready),
    .input_0_eth_dest_mac(input_0_eth_dest_mac),
    .input_0_eth_src_mac(input_0_eth_src_mac),
    .input_0_eth_type(input_0_eth_type),
    .input_0_ip_version(input_0_ip_version),
    .input_0_ip_ihl(input_0_ip_ihl),
    .input_0_ip_dscp(input_0_ip_dscp),
    .input_0_ip_ecn(input_0_ip_ecn),
    .input_0_ip_length(input_0_ip_length),
    .input_0_ip_identification(input_0_ip_identification),
    .input_0_ip_flags(input_0_ip_flags),
    .input_0_ip_fragment_offset(input_0_ip_fragment_offset),
    .input_0_ip_ttl(input_0_ip_ttl),
    .input_0_ip_protocol(input_0_ip_protocol),
    .input_0_ip_header_checksum(input_0_ip_header_checksum),
    .input_0_ip_source_ip(input_0_ip_source_ip),
    .input_0_ip_dest_ip(input_0_ip_dest_ip),
    .input_0_ip_payload_tdata(input_0_ip_payload_tdata),
    .input_0_ip_payload_tvalid(input_0_ip_payload_tvalid & grant[0]),
    .input_0_ip_payload_tready(input_0_ip_payload_tready),
    .input_0_ip_payload_tlast(input_0_ip_payload_tlast),
    .input_0_ip_payload_tuser(input_0_ip_payload_tuser),
    .input_1_ip_hdr_valid(input_1_ip_hdr_valid & grant[1]),
    .input_1_ip_hdr_ready(input_1_ip_hdr_ready),
    .input_1_eth_dest_mac(input_1_eth_dest_mac),
    .input_1_eth_src_mac(input_1_eth_src_mac),
    .input_1_eth_type(input_1_eth_type),
    .input_1_ip_version(input_1_ip_version),
    .input_1_ip_ihl(input_1_ip_ihl),
    .input_1_ip_dscp(input_1_ip_dscp),
    .input_1_ip_ecn(input_1_ip_ecn),
    .input_1_ip_length(input_1_ip_length),
    .input_1_ip_identification(input_1_ip_identification),
    .input_1_ip_flags(input_1_ip_flags),
    .input_1_ip_fragment_offset(input_1_ip_fragment_offset),
    .input_1_ip_ttl(input_1_ip_ttl),
    .input_1_ip_protocol(input_1_ip_protocol),
    .input_1_ip_header_checksum(input_1_ip_header_checksum),
    .input_1_ip_source_ip(input_1_ip_source_ip),
    .input_1_ip_dest_ip(input_1_ip_dest_ip),
    .input_1_ip_payload_tdata(input_1_ip_payload_tdata),
    .input_1_ip_payload_tvalid(input_1_ip_payload_tvalid & grant[1]),
    .input_1_ip_payload_tready(input_1_ip_payload_tready),
    .input_1_ip_payload_tlast(input_1_ip_payload_tlast),
    .input_1_ip_payload_tuser(input_1_ip_payload_tuser),
    .output_ip_hdr_valid(output_ip_hdr_valid),
    .output_ip_hdr_ready(output_ip_hdr_ready),
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
    .output_ip_payload_tdata(output_ip_payload_tdata),
    .output_ip_payload_tvalid(output_ip_payload_tvalid),
    .output_ip_payload_tready(output_ip_payload_tready),
    .output_ip_payload_tlast(output_ip_payload_tlast),
    .output_ip_payload_tuser(output_ip_payload_tuser),
    .enable(grant_valid),
    .select(grant_encoded)
);

// arbiter instance
arbiter #(
    .PORTS(2),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

endmodule
