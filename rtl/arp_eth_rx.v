/*

Copyright (c) 2014-2020 Alex Forencich

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
 * ARP ethernet frame receiver (Ethernet frame in, ARP frame out)
 */
module arp_eth_rx #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * Ethernet frame input
     */
    input  wire                   s_eth_hdr_valid,
    output wire                   s_eth_hdr_ready,
    input  wire [47:0]            s_eth_dest_mac,
    input  wire [47:0]            s_eth_src_mac,
    input  wire [15:0]            s_eth_type,
    input  wire [DATA_WIDTH-1:0]  s_eth_payload_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_eth_payload_axis_tkeep,
    input  wire                   s_eth_payload_axis_tvalid,
    output wire                   s_eth_payload_axis_tready,
    input  wire                   s_eth_payload_axis_tlast,
    input  wire                   s_eth_payload_axis_tuser,

    /*
     * ARP frame output
     */
    output wire                   m_frame_valid,
    input  wire                   m_frame_ready,
    output wire [47:0]            m_eth_dest_mac,
    output wire [47:0]            m_eth_src_mac,
    output wire [15:0]            m_eth_type,
    output wire [15:0]            m_arp_htype,
    output wire [15:0]            m_arp_ptype,
    output wire [7:0]             m_arp_hlen,
    output wire [7:0]             m_arp_plen,
    output wire [15:0]            m_arp_oper,
    output wire [47:0]            m_arp_sha,
    output wire [31:0]            m_arp_spa,
    output wire [47:0]            m_arp_tha,
    output wire [31:0]            m_arp_tpa,

    /*
     * Status signals
     */
    output wire                   busy,
    output wire                   error_header_early_termination,
    output wire                   error_invalid_header
);

parameter CYCLE_COUNT = (28+KEEP_WIDTH-1)/KEEP_WIDTH;

parameter PTR_WIDTH = $clog2(CYCLE_COUNT);

parameter OFFSET = 28 % KEEP_WIDTH;

// bus width assertions
initial begin
    if (KEEP_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: AXI stream interface requires byte (8-bit) granularity (instance %m)");
        $finish;
    end
end

/*

ARP Frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0806)          2 octets
 HTYPE (1)                   2 octets
 PTYPE (0x0800)              2 octets
 HLEN (6)                    1 octets
 PLEN (4)                    1 octets
 OPER                        2 octets
 SHA Sender MAC              6 octets
 SPA Sender IP               4 octets
 THA Target MAC              6 octets
 TPA Target IP               4 octets

This module receives an Ethernet frame with header fields in parallel and
payload on an AXI stream interface, decodes the ARP packet fields, and
produces the frame fields in parallel.  

*/

// datapath control signals
reg store_eth_hdr;

reg read_eth_header_reg = 1'b1, read_eth_header_next;
reg read_arp_header_reg = 1'b0, read_arp_header_next;
reg [PTR_WIDTH-1:0] ptr_reg = 0, ptr_next;

reg s_eth_hdr_ready_reg = 1'b0, s_eth_hdr_ready_next;
reg s_eth_payload_axis_tready_reg = 1'b0, s_eth_payload_axis_tready_next;

reg m_frame_valid_reg = 1'b0, m_frame_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0;
reg [47:0] m_eth_src_mac_reg = 48'd0;
reg [15:0] m_eth_type_reg = 16'd0;
reg [15:0] m_arp_htype_reg = 16'd0, m_arp_htype_next;
reg [15:0] m_arp_ptype_reg = 16'd0, m_arp_ptype_next;
reg [7:0]  m_arp_hlen_reg = 8'd0, m_arp_hlen_next;
reg [7:0]  m_arp_plen_reg = 8'd0, m_arp_plen_next;
reg [15:0] m_arp_oper_reg = 16'd0, m_arp_oper_next;
reg [47:0] m_arp_sha_reg = 48'd0, m_arp_sha_next;
reg [31:0] m_arp_spa_reg = 32'd0, m_arp_spa_next;
reg [47:0] m_arp_tha_reg = 48'd0, m_arp_tha_next;
reg [31:0] m_arp_tpa_reg = 32'd0, m_arp_tpa_next;

reg busy_reg = 1'b0;
reg error_header_early_termination_reg = 1'b0, error_header_early_termination_next;
reg error_invalid_header_reg = 1'b0, error_invalid_header_next;

assign s_eth_hdr_ready = s_eth_hdr_ready_reg;
assign s_eth_payload_axis_tready = s_eth_payload_axis_tready_reg;

assign m_frame_valid = m_frame_valid_reg;
assign m_eth_dest_mac = m_eth_dest_mac_reg;
assign m_eth_src_mac = m_eth_src_mac_reg;
assign m_eth_type = m_eth_type_reg;
assign m_arp_htype = m_arp_htype_reg;
assign m_arp_ptype = m_arp_ptype_reg;
assign m_arp_hlen = m_arp_hlen_reg;
assign m_arp_plen = m_arp_plen_reg;
assign m_arp_oper = m_arp_oper_reg;
assign m_arp_sha = m_arp_sha_reg;
assign m_arp_spa = m_arp_spa_reg;
assign m_arp_tha = m_arp_tha_reg;
assign m_arp_tpa = m_arp_tpa_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;
assign error_invalid_header = error_invalid_header_reg;

always @* begin
    read_eth_header_next = read_eth_header_reg;
    read_arp_header_next = read_arp_header_reg;
    ptr_next = ptr_reg;

    s_eth_hdr_ready_next = 1'b0;
    s_eth_payload_axis_tready_next = 1'b0;

    store_eth_hdr = 1'b0;

    m_frame_valid_next = m_frame_valid_reg && !m_frame_ready;

    m_arp_htype_next = m_arp_htype_reg;
    m_arp_ptype_next = m_arp_ptype_reg;
    m_arp_hlen_next = m_arp_hlen_reg;
    m_arp_plen_next = m_arp_plen_reg;
    m_arp_oper_next = m_arp_oper_reg;
    m_arp_sha_next = m_arp_sha_reg;
    m_arp_spa_next = m_arp_spa_reg;
    m_arp_tha_next = m_arp_tha_reg;
    m_arp_tpa_next = m_arp_tpa_reg;

    error_header_early_termination_next = 1'b0;
    error_invalid_header_next = 1'b0;

    if (s_eth_hdr_ready && s_eth_hdr_valid) begin
        if (read_eth_header_reg) begin
            store_eth_hdr = 1'b1;
            ptr_next = 0;
            read_eth_header_next = 1'b0;
            read_arp_header_next = 1'b1;
        end
    end

    if (s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) begin
        if (read_arp_header_reg) begin
            // word transfer in - store it
            ptr_next = ptr_reg + 1;

            `define _HEADER_FIELD_(offset, field) \
                if (ptr_reg == offset/KEEP_WIDTH && (!KEEP_ENABLE || s_eth_payload_axis_tkeep[offset%KEEP_WIDTH])) begin \
                    field = s_eth_payload_axis_tdata[(offset%KEEP_WIDTH)*8 +: 8]; \
                end

            `_HEADER_FIELD_(0,  m_arp_htype_next[1*8 +: 8])
            `_HEADER_FIELD_(1,  m_arp_htype_next[0*8 +: 8])
            `_HEADER_FIELD_(2,  m_arp_ptype_next[1*8 +: 8])
            `_HEADER_FIELD_(3,  m_arp_ptype_next[0*8 +: 8])
            `_HEADER_FIELD_(4,  m_arp_hlen_next[0*8 +: 8])
            `_HEADER_FIELD_(5,  m_arp_plen_next[0*8 +: 8])
            `_HEADER_FIELD_(6,  m_arp_oper_next[1*8 +: 8])
            `_HEADER_FIELD_(7,  m_arp_oper_next[0*8 +: 8])
            `_HEADER_FIELD_(8,  m_arp_sha_next[5*8 +: 8])
            `_HEADER_FIELD_(9,  m_arp_sha_next[4*8 +: 8])
            `_HEADER_FIELD_(10, m_arp_sha_next[3*8 +: 8])
            `_HEADER_FIELD_(11, m_arp_sha_next[2*8 +: 8])
            `_HEADER_FIELD_(12, m_arp_sha_next[1*8 +: 8])
            `_HEADER_FIELD_(13, m_arp_sha_next[0*8 +: 8])
            `_HEADER_FIELD_(14, m_arp_spa_next[3*8 +: 8])
            `_HEADER_FIELD_(15, m_arp_spa_next[2*8 +: 8])
            `_HEADER_FIELD_(16, m_arp_spa_next[1*8 +: 8])
            `_HEADER_FIELD_(17, m_arp_spa_next[0*8 +: 8])
            `_HEADER_FIELD_(18, m_arp_tha_next[5*8 +: 8])
            `_HEADER_FIELD_(19, m_arp_tha_next[4*8 +: 8])
            `_HEADER_FIELD_(20, m_arp_tha_next[3*8 +: 8])
            `_HEADER_FIELD_(21, m_arp_tha_next[2*8 +: 8])
            `_HEADER_FIELD_(22, m_arp_tha_next[1*8 +: 8])
            `_HEADER_FIELD_(23, m_arp_tha_next[0*8 +: 8])
            `_HEADER_FIELD_(24, m_arp_tpa_next[3*8 +: 8])
            `_HEADER_FIELD_(25, m_arp_tpa_next[2*8 +: 8])
            `_HEADER_FIELD_(26, m_arp_tpa_next[1*8 +: 8])
            `_HEADER_FIELD_(27, m_arp_tpa_next[0*8 +: 8])

            if (ptr_reg == 27/KEEP_WIDTH && (!KEEP_ENABLE || s_eth_payload_axis_tkeep[27%KEEP_WIDTH])) begin
                read_arp_header_next = 1'b0;
            end

            `undef _HEADER_FIELD_
        end

        if (s_eth_payload_axis_tlast) begin
            if (read_arp_header_next) begin
                // don't have the whole header
                error_header_early_termination_next = 1'b1;
            end else if (m_arp_hlen_next != 4'd6 || m_arp_plen_next != 4'd4) begin
                // lengths not valid
                error_invalid_header_next = 1'b1;
            end else begin
                // otherwise, transfer tuser
                m_frame_valid_next = !s_eth_payload_axis_tuser;
            end

            ptr_next = 1'b0;
            read_eth_header_next = 1'b1;
            read_arp_header_next = 1'b0;
        end
    end

    if (read_eth_header_next) begin
        s_eth_hdr_ready_next = !m_frame_valid_next;
    end else begin
        s_eth_payload_axis_tready_next = 1'b1;
    end
end

always @(posedge clk) begin
    read_eth_header_reg <= read_eth_header_next;
    read_arp_header_reg <= read_arp_header_next;
    ptr_reg <= ptr_next;

    s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;
    s_eth_payload_axis_tready_reg <= s_eth_payload_axis_tready_next;

    m_frame_valid_reg <= m_frame_valid_next;

    m_arp_htype_reg <= m_arp_htype_next;
    m_arp_ptype_reg <= m_arp_ptype_next;
    m_arp_hlen_reg <= m_arp_hlen_next;
    m_arp_plen_reg <= m_arp_plen_next;
    m_arp_oper_reg <= m_arp_oper_next;
    m_arp_sha_reg <= m_arp_sha_next;
    m_arp_spa_reg <= m_arp_spa_next;
    m_arp_tha_reg <= m_arp_tha_next;
    m_arp_tpa_reg <= m_arp_tpa_next;

    error_header_early_termination_reg <= error_header_early_termination_next;
    error_invalid_header_reg <= error_invalid_header_next;

    busy_reg <= read_arp_header_next;

    // datapath
    if (store_eth_hdr) begin
        m_eth_dest_mac_reg <= s_eth_dest_mac;
        m_eth_src_mac_reg <= s_eth_src_mac;
        m_eth_type_reg <= s_eth_type;
    end

    if (rst) begin
        read_eth_header_reg <= 1'b1;
        read_arp_header_reg <= 1'b0;
        ptr_reg <= 0;
        s_eth_payload_axis_tready_reg <= 1'b0;
        m_frame_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_header_early_termination_reg <= 1'b0;
        error_invalid_header_reg <= 1'b0;
    end 
end

endmodule

`resetall
