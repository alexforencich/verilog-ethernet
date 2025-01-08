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
 * UDP block, IP interface
 */
module udp #
(
    parameter CHECKSUM_GEN_ENABLE = 1,
    parameter CHECKSUM_PAYLOAD_FIFO_DEPTH = 2048,
    parameter CHECKSUM_HEADER_FIFO_DEPTH = 8
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * IP frame input
     */
    input  wire        s_ip_hdr_valid,
    output wire        s_ip_hdr_ready,
    input  wire [47:0] s_ip_eth_dest_mac,
    input  wire [47:0] s_ip_eth_src_mac,
    input  wire [15:0] s_ip_eth_type,
    input  wire [3:0]  s_ip_version,
    input  wire [3:0]  s_ip_ihl,
    input  wire [5:0]  s_ip_dscp,
    input  wire [1:0]  s_ip_ecn,
    input  wire [15:0] s_ip_length,
    input  wire [15:0] s_ip_identification,
    input  wire [2:0]  s_ip_flags,
    input  wire [12:0] s_ip_fragment_offset,
    input  wire [7:0]  s_ip_ttl,
    input  wire [7:0]  s_ip_protocol,
    input  wire [15:0] s_ip_header_checksum,
    input  wire [31:0] s_ip_source_ip,
    input  wire [31:0] s_ip_dest_ip,
    input  wire [7:0]  s_ip_payload_axis_tdata,
    input  wire        s_ip_payload_axis_tvalid,
    output wire        s_ip_payload_axis_tready,
    input  wire        s_ip_payload_axis_tlast,
    input  wire        s_ip_payload_axis_tuser,
    
    /*
     * IP frame output
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
    output wire [7:0]  m_ip_payload_axis_tdata,
    output wire        m_ip_payload_axis_tvalid,
    input  wire        m_ip_payload_axis_tready,
    output wire        m_ip_payload_axis_tlast,
    output wire        m_ip_payload_axis_tuser,
    
    /*
     * UDP frame input
     */
    input  wire        s_udp_hdr_valid,
    output wire        s_udp_hdr_ready,
    input  wire [47:0] s_udp_eth_dest_mac,
    input  wire [47:0] s_udp_eth_src_mac,
    input  wire [15:0] s_udp_eth_type,
    input  wire [3:0]  s_udp_ip_version,
    input  wire [3:0]  s_udp_ip_ihl,
    input  wire [5:0]  s_udp_ip_dscp,
    input  wire [1:0]  s_udp_ip_ecn,
    input  wire [15:0] s_udp_ip_identification,
    input  wire [2:0]  s_udp_ip_flags,
    input  wire [12:0] s_udp_ip_fragment_offset,
    input  wire [7:0]  s_udp_ip_ttl,
    input  wire [15:0] s_udp_ip_header_checksum,
    input  wire [31:0] s_udp_ip_source_ip,
    input  wire [31:0] s_udp_ip_dest_ip,
    input  wire [15:0] s_udp_source_port,
    input  wire [15:0] s_udp_dest_port,
    input  wire [15:0] s_udp_length,
    input  wire [15:0] s_udp_checksum,
    input  wire [7:0]  s_udp_payload_axis_tdata,
    input  wire        s_udp_payload_axis_tvalid,
    output wire        s_udp_payload_axis_tready,
    input  wire        s_udp_payload_axis_tlast,
    input  wire        s_udp_payload_axis_tuser,
    
    /*
     * UDP frame output
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
    output wire [7:0]  m_udp_payload_axis_tdata,
    output wire        m_udp_payload_axis_tvalid,
    input  wire        m_udp_payload_axis_tready,
    output wire        m_udp_payload_axis_tlast,
    output wire        m_udp_payload_axis_tuser,
    
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
wire [7:0]  tx_udp_payload_axis_tdata;
wire        tx_udp_payload_axis_tvalid;
wire        tx_udp_payload_axis_tready;
wire        tx_udp_payload_axis_tlast;
wire        tx_udp_payload_axis_tuser;

udp_ip_rx
udp_ip_rx_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .s_ip_hdr_valid(s_ip_hdr_valid),
    .s_ip_hdr_ready(s_ip_hdr_ready),
    .s_eth_dest_mac(s_ip_eth_dest_mac),
    .s_eth_src_mac(s_ip_eth_src_mac),
    .s_eth_type(s_ip_eth_type),
    .s_ip_version(s_ip_version),
    .s_ip_ihl(s_ip_ihl),
    .s_ip_dscp(s_ip_dscp),
    .s_ip_ecn(s_ip_ecn),
    .s_ip_length(s_ip_length),
    .s_ip_identification(s_ip_identification),
    .s_ip_flags(s_ip_flags),
    .s_ip_fragment_offset(s_ip_fragment_offset),
    .s_ip_ttl(s_ip_ttl),
    .s_ip_protocol(s_ip_protocol),
    .s_ip_header_checksum(s_ip_header_checksum),
    .s_ip_source_ip(s_ip_source_ip),
    .s_ip_dest_ip(s_ip_dest_ip),
    .s_ip_payload_axis_tdata(s_ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(s_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),
    // UDP frame output
    .m_udp_hdr_valid(m_udp_hdr_valid),
    .m_udp_hdr_ready(m_udp_hdr_ready),
    .m_eth_dest_mac(m_udp_eth_dest_mac),
    .m_eth_src_mac(m_udp_eth_src_mac),
    .m_eth_type(m_udp_eth_type),
    .m_ip_version(m_udp_ip_version),
    .m_ip_ihl(m_udp_ip_ihl),
    .m_ip_dscp(m_udp_ip_dscp),
    .m_ip_ecn(m_udp_ip_ecn),
    .m_ip_length(m_udp_ip_length),
    .m_ip_identification(m_udp_ip_identification),
    .m_ip_flags(m_udp_ip_flags),
    .m_ip_fragment_offset(m_udp_ip_fragment_offset),
    .m_ip_ttl(m_udp_ip_ttl),
    .m_ip_protocol(m_udp_ip_protocol),
    .m_ip_header_checksum(m_udp_ip_header_checksum),
    .m_ip_source_ip(m_udp_ip_source_ip),
    .m_ip_dest_ip(m_udp_ip_dest_ip),
    .m_udp_source_port(m_udp_source_port),
    .m_udp_dest_port(m_udp_dest_port),
    .m_udp_length(m_udp_length),
    .m_udp_checksum(m_udp_checksum),
    .m_udp_payload_axis_tdata(m_udp_payload_axis_tdata),
    .m_udp_payload_axis_tvalid(m_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready(m_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast(m_udp_payload_axis_tlast),
    .m_udp_payload_axis_tuser(m_udp_payload_axis_tuser),
    // Status signals
    .busy(rx_busy),
    .error_header_early_termination(rx_error_header_early_termination),
    .error_payload_early_termination(rx_error_payload_early_termination)
);

generate

if (CHECKSUM_GEN_ENABLE) begin

    udp_checksum_gen #(
        .PAYLOAD_FIFO_DEPTH(CHECKSUM_PAYLOAD_FIFO_DEPTH),
        .HEADER_FIFO_DEPTH(CHECKSUM_HEADER_FIFO_DEPTH)
    )
    udp_checksum_gen_inst (
        .clk(clk),
        .rst(rst),
        // UDP frame input
        .s_udp_hdr_valid(s_udp_hdr_valid),
        .s_udp_hdr_ready(s_udp_hdr_ready),
        .s_eth_dest_mac(s_udp_eth_dest_mac),
        .s_eth_src_mac(s_udp_eth_src_mac),
        .s_eth_type(s_udp_eth_type),
        .s_ip_version(s_udp_ip_version),
        .s_ip_ihl(s_udp_ip_ihl),
        .s_ip_dscp(s_udp_ip_dscp),
        .s_ip_ecn(s_udp_ip_ecn),
        .s_ip_identification(s_udp_ip_identification),
        .s_ip_flags(s_udp_ip_flags),
        .s_ip_fragment_offset(s_udp_ip_fragment_offset),
        .s_ip_ttl(s_udp_ip_ttl),
        .s_ip_header_checksum(s_udp_ip_header_checksum),
        .s_ip_source_ip(s_udp_ip_source_ip),
        .s_ip_dest_ip(s_udp_ip_dest_ip),
        .s_udp_source_port(s_udp_source_port),
        .s_udp_dest_port(s_udp_dest_port),
        .s_udp_payload_axis_tdata(s_udp_payload_axis_tdata),
        .s_udp_payload_axis_tvalid(s_udp_payload_axis_tvalid),
        .s_udp_payload_axis_tready(s_udp_payload_axis_tready),
        .s_udp_payload_axis_tlast(s_udp_payload_axis_tlast),
        .s_udp_payload_axis_tuser(s_udp_payload_axis_tuser),
        // UDP frame output
        .m_udp_hdr_valid(tx_udp_hdr_valid),
        .m_udp_hdr_ready(tx_udp_hdr_ready),
        .m_eth_dest_mac(tx_udp_eth_dest_mac),
        .m_eth_src_mac(tx_udp_eth_src_mac),
        .m_eth_type(tx_udp_eth_type),
        .m_ip_version(tx_udp_ip_version),
        .m_ip_ihl(tx_udp_ip_ihl),
        .m_ip_dscp(tx_udp_ip_dscp),
        .m_ip_ecn(tx_udp_ip_ecn),
        .m_ip_length(),
        .m_ip_identification(tx_udp_ip_identification),
        .m_ip_flags(tx_udp_ip_flags),
        .m_ip_fragment_offset(tx_udp_ip_fragment_offset),
        .m_ip_ttl(tx_udp_ip_ttl),
        .m_ip_protocol(),
        .m_ip_header_checksum(tx_udp_ip_header_checksum),
        .m_ip_source_ip(tx_udp_ip_source_ip),
        .m_ip_dest_ip(tx_udp_ip_dest_ip),
        .m_udp_source_port(tx_udp_source_port),
        .m_udp_dest_port(tx_udp_dest_port),
        .m_udp_length(tx_udp_length),
        .m_udp_checksum(tx_udp_checksum),
        .m_udp_payload_axis_tdata(tx_udp_payload_axis_tdata),
        .m_udp_payload_axis_tvalid(tx_udp_payload_axis_tvalid),
        .m_udp_payload_axis_tready(tx_udp_payload_axis_tready),
        .m_udp_payload_axis_tlast(tx_udp_payload_axis_tlast),
        .m_udp_payload_axis_tuser(tx_udp_payload_axis_tuser),
        // Status signals
        .busy()
    );

end else begin

    assign tx_udp_hdr_valid = s_udp_hdr_valid;
    assign s_udp_hdr_ready = tx_udp_hdr_ready;
    assign tx_udp_eth_dest_mac = s_udp_eth_dest_mac;
    assign tx_udp_eth_src_mac = s_udp_eth_src_mac;
    assign tx_udp_eth_type = s_udp_eth_type;
    assign tx_udp_ip_version = s_udp_ip_version;
    assign tx_udp_ip_ihl = s_udp_ip_ihl;
    assign tx_udp_ip_dscp = s_udp_ip_dscp;
    assign tx_udp_ip_ecn = s_udp_ip_ecn;
    assign tx_udp_ip_identification = s_udp_ip_identification;
    assign tx_udp_ip_flags = s_udp_ip_flags;
    assign tx_udp_ip_fragment_offset = s_udp_ip_fragment_offset;
    assign tx_udp_ip_ttl = s_udp_ip_ttl;
    assign tx_udp_ip_header_checksum = s_udp_ip_header_checksum;
    assign tx_udp_ip_source_ip = s_udp_ip_source_ip;
    assign tx_udp_ip_dest_ip = s_udp_ip_dest_ip;
    assign tx_udp_source_port = s_udp_source_port;
    assign tx_udp_dest_port = s_udp_dest_port;
    assign tx_udp_length = s_udp_length;
    assign tx_udp_checksum = s_udp_checksum;
    assign tx_udp_payload_axis_tdata = s_udp_payload_axis_tdata;
    assign tx_udp_payload_axis_tvalid = s_udp_payload_axis_tvalid;
    assign s_udp_payload_axis_tready = tx_udp_payload_axis_tready;
    assign tx_udp_payload_axis_tlast = s_udp_payload_axis_tlast;
    assign tx_udp_payload_axis_tuser = s_udp_payload_axis_tuser;

end

endgenerate

udp_ip_tx
udp_ip_tx_inst (
    .clk(clk),
    .rst(rst),
    // UDP frame input
    .s_udp_hdr_valid(tx_udp_hdr_valid),
    .s_udp_hdr_ready(tx_udp_hdr_ready),
    .s_eth_dest_mac(tx_udp_eth_dest_mac),
    .s_eth_src_mac(tx_udp_eth_src_mac),
    .s_eth_type(tx_udp_eth_type),
    .s_ip_version(tx_udp_ip_version),
    .s_ip_ihl(tx_udp_ip_ihl),
    .s_ip_dscp(tx_udp_ip_dscp),
    .s_ip_ecn(tx_udp_ip_ecn),
    .s_ip_identification(tx_udp_ip_identification),
    .s_ip_flags(tx_udp_ip_flags),
    .s_ip_fragment_offset(tx_udp_ip_fragment_offset),
    .s_ip_ttl(tx_udp_ip_ttl),
    .s_ip_protocol(8'h11),
    .s_ip_header_checksum(tx_udp_ip_header_checksum),
    .s_ip_source_ip(tx_udp_ip_source_ip),
    .s_ip_dest_ip(tx_udp_ip_dest_ip),
    .s_udp_source_port(tx_udp_source_port),
    .s_udp_dest_port(tx_udp_dest_port),
    .s_udp_length(tx_udp_length),
    .s_udp_checksum(tx_udp_checksum),
    .s_udp_payload_axis_tdata(tx_udp_payload_axis_tdata),
    .s_udp_payload_axis_tvalid(tx_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready(tx_udp_payload_axis_tready),
    .s_udp_payload_axis_tlast(tx_udp_payload_axis_tlast),
    .s_udp_payload_axis_tuser(tx_udp_payload_axis_tuser),
    // IP frame output
    .m_ip_hdr_valid(m_ip_hdr_valid),
    .m_ip_hdr_ready(m_ip_hdr_ready),
    .m_eth_dest_mac(m_ip_eth_dest_mac),
    .m_eth_src_mac(m_ip_eth_src_mac),
    .m_eth_type(m_ip_eth_type),
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
    .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser),
    // Status signals
    .busy(tx_busy),
    .error_payload_early_termination(tx_error_payload_early_termination)
);

endmodule

`resetall
