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
 * Testbench for udp_64
 */
module test_udp_64;

// Parameters
parameter CHECKSUM_GEN_ENABLE = 1;
parameter CHECKSUM_PAYLOAD_FIFO_DEPTH = 2048;
parameter CHECKSUM_HEADER_FIFO_DEPTH = 8;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg s_ip_hdr_valid = 0;
reg [47:0] s_ip_eth_dest_mac = 0;
reg [47:0] s_ip_eth_src_mac = 0;
reg [15:0] s_ip_eth_type = 0;
reg [3:0] s_ip_version = 0;
reg [3:0] s_ip_ihl = 0;
reg [5:0] s_ip_dscp = 0;
reg [1:0] s_ip_ecn = 0;
reg [15:0] s_ip_length = 0;
reg [15:0] s_ip_identification = 0;
reg [2:0] s_ip_flags = 0;
reg [12:0] s_ip_fragment_offset = 0;
reg [7:0] s_ip_ttl = 0;
reg [7:0] s_ip_protocol = 0;
reg [15:0] s_ip_header_checksum = 0;
reg [31:0] s_ip_source_ip = 0;
reg [31:0] s_ip_dest_ip = 0;
reg [63:0] s_ip_payload_axis_tdata = 0;
reg [7:0] s_ip_payload_axis_tkeep = 0;
reg s_ip_payload_axis_tvalid = 0;
reg s_ip_payload_axis_tlast = 0;
reg s_ip_payload_axis_tuser = 0;
reg s_udp_hdr_valid = 0;
reg [47:0] s_udp_eth_dest_mac = 0;
reg [47:0] s_udp_eth_src_mac = 0;
reg [15:0] s_udp_eth_type = 0;
reg [3:0] s_udp_ip_version = 0;
reg [3:0] s_udp_ip_ihl = 0;
reg [5:0] s_udp_ip_dscp = 0;
reg [1:0] s_udp_ip_ecn = 0;
reg [15:0] s_udp_ip_identification = 0;
reg [2:0] s_udp_ip_flags = 0;
reg [12:0] s_udp_ip_fragment_offset = 0;
reg [7:0] s_udp_ip_ttl = 0;
reg [15:0] s_udp_ip_header_checksum = 0;
reg [31:0] s_udp_ip_source_ip = 0;
reg [31:0] s_udp_ip_dest_ip = 0;
reg [15:0] s_udp_source_port = 0;
reg [15:0] s_udp_dest_port = 0;
reg [15:0] s_udp_length = 0;
reg [15:0] s_udp_checksum = 0;
reg [63:0] s_udp_payload_axis_tdata = 0;
reg [7:0] s_udp_payload_axis_tkeep = 0;
reg s_udp_payload_axis_tvalid = 0;
reg s_udp_payload_axis_tlast = 0;
reg s_udp_payload_axis_tuser = 0;
reg m_ip_hdr_ready = 0;
reg m_ip_payload_axis_tready = 0;
reg m_udp_hdr_ready = 0;
reg m_udp_payload_axis_tready = 0;

// Outputs
wire s_ip_hdr_ready;
wire s_ip_payload_axis_tready;
wire s_udp_hdr_ready;
wire s_udp_payload_axis_tready;
wire m_ip_hdr_valid;
wire [47:0] m_ip_eth_dest_mac;
wire [47:0] m_ip_eth_src_mac;
wire [15:0] m_ip_eth_type;
wire [3:0] m_ip_version;
wire [3:0] m_ip_ihl;
wire [5:0] m_ip_dscp;
wire [1:0] m_ip_ecn;
wire [15:0] m_ip_length;
wire [15:0] m_ip_identification;
wire [2:0] m_ip_flags;
wire [12:0] m_ip_fragment_offset;
wire [7:0] m_ip_ttl;
wire [7:0] m_ip_protocol;
wire [15:0] m_ip_header_checksum;
wire [31:0] m_ip_source_ip;
wire [31:0] m_ip_dest_ip;
wire [63:0] m_ip_payload_axis_tdata;
wire [7:0] m_ip_payload_axis_tkeep;
wire m_ip_payload_axis_tvalid;
wire m_ip_payload_axis_tlast;
wire m_ip_payload_axis_tuser;
wire m_udp_hdr_valid;
wire [47:0] m_udp_eth_dest_mac;
wire [47:0] m_udp_eth_src_mac;
wire [15:0] m_udp_eth_type;
wire [3:0] m_udp_ip_version;
wire [3:0] m_udp_ip_ihl;
wire [5:0] m_udp_ip_dscp;
wire [1:0] m_udp_ip_ecn;
wire [15:0] m_udp_ip_length;
wire [15:0] m_udp_ip_identification;
wire [2:0] m_udp_ip_flags;
wire [12:0] m_udp_ip_fragment_offset;
wire [7:0] m_udp_ip_ttl;
wire [7:0] m_udp_ip_protocol;
wire [15:0] m_udp_ip_header_checksum;
wire [31:0] m_udp_ip_source_ip;
wire [31:0] m_udp_ip_dest_ip;
wire [15:0] m_udp_source_port;
wire [15:0] m_udp_dest_port;
wire [15:0] m_udp_length;
wire [15:0] m_udp_checksum;
wire [63:0] m_udp_payload_axis_tdata;
wire [7:0] m_udp_payload_axis_tkeep;
wire m_udp_payload_axis_tvalid;
wire m_udp_payload_axis_tlast;
wire m_udp_payload_axis_tuser;
wire rx_busy;
wire tx_busy;
wire rx_error_header_early_termination;
wire rx_error_payload_early_termination;
wire tx_error_payload_early_termination;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_ip_hdr_valid,
        s_ip_eth_dest_mac,
        s_ip_eth_src_mac,
        s_ip_eth_type,
        s_ip_version,
        s_ip_ihl,
        s_ip_dscp,
        s_ip_ecn,
        s_ip_length,
        s_ip_identification,
        s_ip_flags,
        s_ip_fragment_offset,
        s_ip_ttl,
        s_ip_protocol,
        s_ip_header_checksum,
        s_ip_source_ip,
        s_ip_dest_ip,
        s_ip_payload_axis_tdata,
        s_ip_payload_axis_tkeep,
        s_ip_payload_axis_tvalid,
        s_ip_payload_axis_tlast,
        s_ip_payload_axis_tuser,
        s_udp_hdr_valid,
        s_udp_eth_dest_mac,
        s_udp_eth_src_mac,
        s_udp_eth_type,
        s_udp_ip_version,
        s_udp_ip_ihl,
        s_udp_ip_dscp,
        s_udp_ip_ecn,
        s_udp_ip_identification,
        s_udp_ip_flags,
        s_udp_ip_fragment_offset,
        s_udp_ip_ttl,
        s_udp_ip_header_checksum,
        s_udp_ip_source_ip,
        s_udp_ip_dest_ip,
        s_udp_source_port,
        s_udp_dest_port,
        s_udp_length,
        s_udp_checksum,
        s_udp_payload_axis_tdata,
        s_udp_payload_axis_tkeep,
        s_udp_payload_axis_tvalid,
        s_udp_payload_axis_tlast,
        s_udp_payload_axis_tuser,
        m_ip_hdr_ready,
        m_ip_payload_axis_tready,
        m_udp_hdr_ready,
        m_udp_payload_axis_tready
    );
    $to_myhdl(
        s_ip_hdr_ready,
        s_ip_payload_axis_tready,
        s_udp_hdr_ready,
        s_udp_payload_axis_tready,
        m_ip_hdr_valid,
        m_ip_eth_dest_mac,
        m_ip_eth_src_mac,
        m_ip_eth_type,
        m_ip_version,
        m_ip_ihl,
        m_ip_dscp,
        m_ip_ecn,
        m_ip_length,
        m_ip_identification,
        m_ip_flags,
        m_ip_fragment_offset,
        m_ip_ttl,
        m_ip_protocol,
        m_ip_header_checksum,
        m_ip_source_ip,
        m_ip_dest_ip,
        m_ip_payload_axis_tdata,
        m_ip_payload_axis_tkeep,
        m_ip_payload_axis_tvalid,
        m_ip_payload_axis_tlast,
        m_ip_payload_axis_tuser,
        m_udp_hdr_valid,
        m_udp_eth_dest_mac,
        m_udp_eth_src_mac,
        m_udp_eth_type,
        m_udp_ip_version,
        m_udp_ip_ihl,
        m_udp_ip_dscp,
        m_udp_ip_ecn,
        m_udp_ip_length,
        m_udp_ip_identification,
        m_udp_ip_flags,
        m_udp_ip_fragment_offset,
        m_udp_ip_ttl,
        m_udp_ip_protocol,
        m_udp_ip_header_checksum,
        m_udp_ip_source_ip,
        m_udp_ip_dest_ip,
        m_udp_source_port,
        m_udp_dest_port,
        m_udp_length,
        m_udp_checksum,
        m_udp_payload_axis_tdata,
        m_udp_payload_axis_tkeep,
        m_udp_payload_axis_tvalid,
        m_udp_payload_axis_tlast,
        m_udp_payload_axis_tuser,
        rx_busy,
        tx_busy,
        rx_error_header_early_termination,
        rx_error_payload_early_termination,
        tx_error_payload_early_termination
    );

    // dump file
    $dumpfile("test_udp_64.lxt");
    $dumpvars(0, test_udp_64);
end

udp_64 #(
    .CHECKSUM_GEN_ENABLE(CHECKSUM_GEN_ENABLE),
    .CHECKSUM_PAYLOAD_FIFO_DEPTH(CHECKSUM_PAYLOAD_FIFO_DEPTH),
    .CHECKSUM_HEADER_FIFO_DEPTH(CHECKSUM_HEADER_FIFO_DEPTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .s_ip_hdr_valid(s_ip_hdr_valid),
    .s_ip_hdr_ready(s_ip_hdr_ready),
    .s_ip_eth_dest_mac(s_ip_eth_dest_mac),
    .s_ip_eth_src_mac(s_ip_eth_src_mac),
    .s_ip_eth_type(s_ip_eth_type),
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
    .s_ip_payload_axis_tkeep(s_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(s_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),
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
    // UDP frame input
    .s_udp_hdr_valid(s_udp_hdr_valid),
    .s_udp_hdr_ready(s_udp_hdr_ready),
    .s_udp_eth_dest_mac(s_udp_eth_dest_mac),
    .s_udp_eth_src_mac(s_udp_eth_src_mac),
    .s_udp_eth_type(s_udp_eth_type),
    .s_udp_ip_version(s_udp_ip_version),
    .s_udp_ip_ihl(s_udp_ip_ihl),
    .s_udp_ip_dscp(s_udp_ip_dscp),
    .s_udp_ip_ecn(s_udp_ip_ecn),
    .s_udp_ip_identification(s_udp_ip_identification),
    .s_udp_ip_flags(s_udp_ip_flags),
    .s_udp_ip_fragment_offset(s_udp_ip_fragment_offset),
    .s_udp_ip_ttl(s_udp_ip_ttl),
    .s_udp_ip_header_checksum(s_udp_ip_header_checksum),
    .s_udp_ip_source_ip(s_udp_ip_source_ip),
    .s_udp_ip_dest_ip(s_udp_ip_dest_ip),
    .s_udp_source_port(s_udp_source_port),
    .s_udp_dest_port(s_udp_dest_port),
    .s_udp_length(s_udp_length),
    .s_udp_checksum(s_udp_checksum),
    .s_udp_payload_axis_tdata(s_udp_payload_axis_tdata),
    .s_udp_payload_axis_tkeep(s_udp_payload_axis_tkeep),
    .s_udp_payload_axis_tvalid(s_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready(s_udp_payload_axis_tready),
    .s_udp_payload_axis_tlast(s_udp_payload_axis_tlast),
    .s_udp_payload_axis_tuser(s_udp_payload_axis_tuser),
    // UDP frame output
    .m_udp_hdr_valid(m_udp_hdr_valid),
    .m_udp_hdr_ready(m_udp_hdr_ready),
    .m_udp_eth_dest_mac(m_udp_eth_dest_mac),
    .m_udp_eth_src_mac(m_udp_eth_src_mac),
    .m_udp_eth_type(m_udp_eth_type),
    .m_udp_ip_version(m_udp_ip_version),
    .m_udp_ip_ihl(m_udp_ip_ihl),
    .m_udp_ip_dscp(m_udp_ip_dscp),
    .m_udp_ip_ecn(m_udp_ip_ecn),
    .m_udp_ip_length(m_udp_ip_length),
    .m_udp_ip_identification(m_udp_ip_identification),
    .m_udp_ip_flags(m_udp_ip_flags),
    .m_udp_ip_fragment_offset(m_udp_ip_fragment_offset),
    .m_udp_ip_ttl(m_udp_ip_ttl),
    .m_udp_ip_protocol(m_udp_ip_protocol),
    .m_udp_ip_header_checksum(m_udp_ip_header_checksum),
    .m_udp_ip_source_ip(m_udp_ip_source_ip),
    .m_udp_ip_dest_ip(m_udp_ip_dest_ip),
    .m_udp_source_port(m_udp_source_port),
    .m_udp_dest_port(m_udp_dest_port),
    .m_udp_length(m_udp_length),
    .m_udp_checksum(m_udp_checksum),
    .m_udp_payload_axis_tdata(m_udp_payload_axis_tdata),
    .m_udp_payload_axis_tkeep(m_udp_payload_axis_tkeep),
    .m_udp_payload_axis_tvalid(m_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready(m_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast(m_udp_payload_axis_tlast),
    .m_udp_payload_axis_tuser(m_udp_payload_axis_tuser),
    // Status signals
    .rx_busy(rx_busy),
    .tx_busy(tx_busy),
    .rx_error_header_early_termination(rx_error_header_early_termination),
    .rx_error_payload_early_termination(rx_error_payload_early_termination),
    .tx_error_payload_early_termination(tx_error_payload_early_termination)
);

endmodule
