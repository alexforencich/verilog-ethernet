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
 * UDP block, IP interface (64 bit datapath)
 */
module udp_64 #
(
    parameter CHECKSUM_GEN_ENABLE = 1,
    parameter CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH = 11,
    parameter CHECKSUM_HEADER_FIFO_ADDR_WIDTH = 3
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * IP frame input
     */
    input  wire        input_ip_hdr_valid,
    output wire        input_ip_hdr_ready,
    input  wire [47:0] input_ip_eth_dest_mac,
    input  wire [47:0] input_ip_eth_src_mac,
    input  wire [15:0] input_ip_eth_type,
    input  wire [3:0]  input_ip_version,
    input  wire [3:0]  input_ip_ihl,
    input  wire [5:0]  input_ip_dscp,
    input  wire [1:0]  input_ip_ecn,
    input  wire [15:0] input_ip_length,
    input  wire [15:0] input_ip_identification,
    input  wire [2:0]  input_ip_flags,
    input  wire [12:0] input_ip_fragment_offset,
    input  wire [7:0]  input_ip_ttl,
    input  wire [7:0]  input_ip_protocol,
    input  wire [15:0] input_ip_header_checksum,
    input  wire [31:0] input_ip_source_ip,
    input  wire [31:0] input_ip_dest_ip,
    input  wire [63:0] input_ip_payload_tdata,
    input  wire [7:0]  input_ip_payload_tkeep,
    input  wire        input_ip_payload_tvalid,
    output wire        input_ip_payload_tready,
    input  wire        input_ip_payload_tlast,
    input  wire        input_ip_payload_tuser,
    
    /*
     * IP frame output
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
    output wire [63:0] output_ip_payload_tdata,
    output wire [7:0]  output_ip_payload_tkeep,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,
    
    /*
     * UDP frame input
     */
    input  wire        input_udp_hdr_valid,
    output wire        input_udp_hdr_ready,
    input  wire [47:0] input_udp_eth_dest_mac,
    input  wire [47:0] input_udp_eth_src_mac,
    input  wire [15:0] input_udp_eth_type,
    input  wire [3:0]  input_udp_ip_version,
    input  wire [3:0]  input_udp_ip_ihl,
    input  wire [5:0]  input_udp_ip_dscp,
    input  wire [1:0]  input_udp_ip_ecn,
    input  wire [15:0] input_udp_ip_identification,
    input  wire [2:0]  input_udp_ip_flags,
    input  wire [12:0] input_udp_ip_fragment_offset,
    input  wire [7:0]  input_udp_ip_ttl,
    input  wire [15:0] input_udp_ip_header_checksum,
    input  wire [31:0] input_udp_ip_source_ip,
    input  wire [31:0] input_udp_ip_dest_ip,
    input  wire [15:0] input_udp_source_port,
    input  wire [15:0] input_udp_dest_port,
    input  wire [15:0] input_udp_length,
    input  wire [15:0] input_udp_checksum,
    input  wire [63:0] input_udp_payload_tdata,
    input  wire [7:0]  input_udp_payload_tkeep,
    input  wire        input_udp_payload_tvalid,
    output wire        input_udp_payload_tready,
    input  wire        input_udp_payload_tlast,
    input  wire        input_udp_payload_tuser,
    
    /*
     * UDP frame output
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
    output wire [63:0] output_udp_payload_tdata,
    output wire [7:0]  output_udp_payload_tkeep,
    output wire        output_udp_payload_tvalid,
    input  wire        output_udp_payload_tready,
    output wire        output_udp_payload_tlast,
    output wire        output_udp_payload_tuser,
    
    /*
     * Status signals
     */
    output wire        rx_busy,
    output wire        tx_busy,
    output wire        rx_error_header_early_termination,
    output wire        rx_error_payload_early_termination,
    output wire        tx_error_payload_early_termination
);

wire        tx_udp_hdr_valid;
wire        tx_udp_hdr_ready;
wire [47:0] tx_udp_eth_dest_mac;
wire [47:0] tx_udp_eth_src_mac;
wire [15:0] tx_udp_eth_type;
wire [3:0]  tx_udp_ip_version;
wire [3:0]  tx_udp_ip_ihl;
wire [5:0]  tx_udp_ip_dscp;
wire [1:0]  tx_udp_ip_ecn;
wire [15:0] tx_udp_ip_identification;
wire [2:0]  tx_udp_ip_flags;
wire [12:0] tx_udp_ip_fragment_offset;
wire [7:0]  tx_udp_ip_ttl;
wire [15:0] tx_udp_ip_header_checksum;
wire [31:0] tx_udp_ip_source_ip;
wire [31:0] tx_udp_ip_dest_ip;
wire [15:0] tx_udp_source_port;
wire [15:0] tx_udp_dest_port;
wire [15:0] tx_udp_length;
wire [15:0] tx_udp_checksum;
wire [63:0] tx_udp_payload_tdata;
wire [7:0]  tx_udp_payload_tkeep;
wire        tx_udp_payload_tvalid;
wire        tx_udp_payload_tready;
wire        tx_udp_payload_tlast;
wire        tx_udp_payload_tuser;

udp_ip_rx_64
udp_ip_rx_64_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .input_ip_hdr_valid(input_ip_hdr_valid),
    .input_ip_hdr_ready(input_ip_hdr_ready),
    .input_eth_dest_mac(input_ip_eth_dest_mac),
    .input_eth_src_mac(input_ip_eth_src_mac),
    .input_eth_type(input_ip_eth_type),
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
    .input_ip_payload_tkeep(input_ip_payload_tkeep),
    .input_ip_payload_tvalid(input_ip_payload_tvalid),
    .input_ip_payload_tready(input_ip_payload_tready),
    .input_ip_payload_tlast(input_ip_payload_tlast),
    .input_ip_payload_tuser(input_ip_payload_tuser),
    // UDP frame output
    .output_udp_hdr_valid(output_udp_hdr_valid),
    .output_udp_hdr_ready(output_udp_hdr_ready),
    .output_eth_dest_mac(output_udp_eth_dest_mac),
    .output_eth_src_mac(output_udp_eth_src_mac),
    .output_eth_type(output_udp_eth_type),
    .output_ip_version(output_udp_ip_version),
    .output_ip_ihl(output_udp_ip_ihl),
    .output_ip_dscp(output_udp_ip_dscp),
    .output_ip_ecn(output_udp_ip_ecn),
    .output_ip_length(output_udp_ip_length),
    .output_ip_identification(output_udp_ip_identification),
    .output_ip_flags(output_udp_ip_flags),
    .output_ip_fragment_offset(output_udp_ip_fragment_offset),
    .output_ip_ttl(output_udp_ip_ttl),
    .output_ip_protocol(output_udp_ip_protocol),
    .output_ip_header_checksum(output_udp_ip_header_checksum),
    .output_ip_source_ip(output_udp_ip_source_ip),
    .output_ip_dest_ip(output_udp_ip_dest_ip),
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
    // Status signals
    .busy(rx_busy),
    .error_header_early_termination(rx_error_header_early_termination),
    .error_payload_early_termination(rx_error_payload_early_termination)
);

generate

if (CHECKSUM_GEN_ENABLE) begin

    udp_checksum_gen_64 #(
        .PAYLOAD_FIFO_ADDR_WIDTH(CHECKSUM_PAYLOAD_FIFO_ADDR_WIDTH),
        .HEADER_FIFO_ADDR_WIDTH(CHECKSUM_HEADER_FIFO_ADDR_WIDTH)
    )
    udp_checksum_gen_64_inst (
        .clk(clk),
        .rst(rst),
        // UDP frame input
        .input_udp_hdr_valid(input_udp_hdr_valid),
        .input_udp_hdr_ready(input_udp_hdr_ready),
        .input_eth_dest_mac(input_udp_eth_dest_mac),
        .input_eth_src_mac(input_udp_eth_src_mac),
        .input_eth_type(input_udp_eth_type),
        .input_ip_version(input_udp_ip_version),
        .input_ip_ihl(input_udp_ip_ihl),
        .input_ip_dscp(input_udp_ip_dscp),
        .input_ip_ecn(input_udp_ip_ecn),
        .input_ip_identification(input_udp_ip_identification),
        .input_ip_flags(input_udp_ip_flags),
        .input_ip_fragment_offset(input_udp_ip_fragment_offset),
        .input_ip_ttl(input_udp_ip_ttl),
        .input_ip_header_checksum(input_udp_ip_header_checksum),
        .input_ip_source_ip(input_udp_ip_source_ip),
        .input_ip_dest_ip(input_udp_ip_dest_ip),
        .input_udp_source_port(input_udp_source_port),
        .input_udp_dest_port(input_udp_dest_port),
        .input_udp_payload_tdata(input_udp_payload_tdata),
        .input_udp_payload_tkeep(input_udp_payload_tkeep),
        .input_udp_payload_tvalid(input_udp_payload_tvalid),
        .input_udp_payload_tready(input_udp_payload_tready),
        .input_udp_payload_tlast(input_udp_payload_tlast),
        .input_udp_payload_tuser(input_udp_payload_tuser),
        // UDP frame output
        .output_udp_hdr_valid(tx_udp_hdr_valid),
        .output_udp_hdr_ready(tx_udp_hdr_ready),
        .output_eth_dest_mac(tx_udp_eth_dest_mac),
        .output_eth_src_mac(tx_udp_eth_src_mac),
        .output_eth_type(tx_udp_eth_type),
        .output_ip_version(tx_udp_ip_version),
        .output_ip_ihl(tx_udp_ip_ihl),
        .output_ip_dscp(tx_udp_ip_dscp),
        .output_ip_ecn(tx_udp_ip_ecn),
        .output_ip_length(),
        .output_ip_identification(tx_udp_ip_identification),
        .output_ip_flags(tx_udp_ip_flags),
        .output_ip_fragment_offset(tx_udp_ip_fragment_offset),
        .output_ip_ttl(tx_udp_ip_ttl),
        .output_ip_header_checksum(tx_udp_ip_header_checksum),
        .output_ip_source_ip(tx_udp_ip_source_ip),
        .output_ip_dest_ip(tx_udp_ip_dest_ip),
        .output_udp_source_port(tx_udp_source_port),
        .output_udp_dest_port(tx_udp_dest_port),
        .output_udp_length(tx_udp_length),
        .output_udp_checksum(tx_udp_checksum),
        .output_udp_payload_tdata(tx_udp_payload_tdata),
        .output_udp_payload_tkeep(tx_udp_payload_tkeep),
        .output_udp_payload_tvalid(tx_udp_payload_tvalid),
        .output_udp_payload_tready(tx_udp_payload_tready),
        .output_udp_payload_tlast(tx_udp_payload_tlast),
        .output_udp_payload_tuser(tx_udp_payload_tuser)
    );

end else begin

    assign tx_udp_hdr_valid = input_udp_hdr_valid;
    assign input_udp_hdr_ready = tx_udp_hdr_ready;
    assign tx_udp_eth_dest_mac = input_udp_eth_dest_mac;
    assign tx_udp_eth_src_mac = input_udp_eth_src_mac;
    assign tx_udp_eth_type = input_udp_eth_type;
    assign tx_udp_ip_version = input_udp_ip_version;
    assign tx_udp_ip_ihl = input_udp_ip_ihl;
    assign tx_udp_ip_dscp = input_udp_ip_dscp;
    assign tx_udp_ip_ecn = input_udp_ip_ecn;
    assign tx_udp_ip_identification = input_udp_ip_identification;
    assign tx_udp_ip_flags = input_udp_ip_flags;
    assign tx_udp_ip_fragment_offset = input_udp_ip_fragment_offset;
    assign tx_udp_ip_ttl = input_udp_ip_ttl;
    assign tx_udp_ip_header_checksum = input_udp_ip_header_checksum;
    assign tx_udp_ip_source_ip = input_udp_ip_source_ip;
    assign tx_udp_ip_dest_ip = input_udp_ip_dest_ip;
    assign tx_udp_source_port = input_udp_source_port;
    assign tx_udp_dest_port = input_udp_dest_port;
    assign tx_udp_length = input_udp_length;
    assign tx_udp_checksum = input_udp_checksum;
    assign tx_udp_payload_tdata = input_udp_payload_tdata;
    assign tx_udp_payload_tkeep = input_udp_payload_tkeep;
    assign tx_udp_payload_tvalid = input_udp_payload_tvalid;
    assign input_udp_payload_tready = tx_udp_payload_tready;
    assign tx_udp_payload_tlast = input_udp_payload_tlast;
    assign tx_udp_payload_tuser = input_udp_payload_tuser;

end

endgenerate

udp_ip_tx_64
udp_ip_tx_64_inst (
    .clk(clk),
    .rst(rst),
    // UDP frame input
    .input_udp_hdr_valid(tx_udp_hdr_valid),
    .input_udp_hdr_ready(tx_udp_hdr_ready),
    .input_eth_dest_mac(tx_udp_eth_dest_mac),
    .input_eth_src_mac(tx_udp_eth_src_mac),
    .input_eth_type(tx_udp_eth_type),
    .input_ip_version(tx_udp_ip_version),
    .input_ip_ihl(tx_udp_ip_ihl),
    .input_ip_dscp(tx_udp_ip_dscp),
    .input_ip_ecn(tx_udp_ip_ecn),
    .input_ip_identification(tx_udp_ip_identification),
    .input_ip_flags(tx_udp_ip_flags),
    .input_ip_fragment_offset(tx_udp_ip_fragment_offset),
    .input_ip_ttl(tx_udp_ip_ttl),
    .input_ip_protocol(8'h11),
    .input_ip_header_checksum(tx_udp_ip_header_checksum),
    .input_ip_source_ip(tx_udp_ip_source_ip),
    .input_ip_dest_ip(tx_udp_ip_dest_ip),
    .input_udp_source_port(tx_udp_source_port),
    .input_udp_dest_port(tx_udp_dest_port),
    .input_udp_length(tx_udp_length),
    .input_udp_checksum(tx_udp_checksum),
    .input_udp_payload_tdata(tx_udp_payload_tdata),
    .input_udp_payload_tkeep(tx_udp_payload_tkeep),
    .input_udp_payload_tvalid(tx_udp_payload_tvalid),
    .input_udp_payload_tready(tx_udp_payload_tready),
    .input_udp_payload_tlast(tx_udp_payload_tlast),
    .input_udp_payload_tuser(tx_udp_payload_tuser),
    // IP frame output
    .output_ip_hdr_valid(output_ip_hdr_valid),
    .output_ip_hdr_ready(output_ip_hdr_ready),
    .output_eth_dest_mac(output_ip_eth_dest_mac),
    .output_eth_src_mac(output_ip_eth_src_mac),
    .output_eth_type(output_ip_eth_type),
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
    .busy(tx_busy),
    .error_payload_early_termination(tx_error_payload_early_termination)
);

endmodule
