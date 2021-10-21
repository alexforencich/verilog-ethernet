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
 * IP ethernet frame receiver (Ethernet frame in, IP frame out)
 */
module ip_eth_rx
(
    input  wire        clk,
    input  wire        rst,

    /*
     * Ethernet frame input
     */
    input  wire        s_eth_hdr_valid,
    output wire        s_eth_hdr_ready,
    input  wire [47:0] s_eth_dest_mac,
    input  wire [47:0] s_eth_src_mac,
    input  wire [15:0] s_eth_type,
    input  wire [7:0]  s_eth_payload_axis_tdata,
    input  wire        s_eth_payload_axis_tvalid,
    output wire        s_eth_payload_axis_tready,
    input  wire        s_eth_payload_axis_tlast,
    input  wire        s_eth_payload_axis_tuser,

    /*
     * IP frame output
     */
    output wire        m_ip_hdr_valid,
    input  wire        m_ip_hdr_ready,
    output wire [47:0] m_eth_dest_mac,
    output wire [47:0] m_eth_src_mac,
    output wire [15:0] m_eth_type,
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
     * Status signals
     */
    output wire        busy,
    output wire        error_header_early_termination,
    output wire        error_payload_early_termination,
    output wire        error_invalid_header,
    output wire        error_invalid_checksum
);

/*

IP Frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0800)          2 octets
 Version (4)                 4 bits
 IHL (5-15)                  4 bits
 DSCP (0)                    6 bits
 ECN (0)                     2 bits
 length                      2 octets
 identification (0?)         2 octets
 flags (010)                 3 bits
 fragment offset (0)         13 bits
 time to live (64?)          1 octet
 protocol                    1 octet
 header checksum             2 octets
 source IP                   4 octets
 destination IP              4 octets
 options                     (IHL-5)*4 octets
 payload                     length octets

This module receives an Ethernet frame with header fields in parallel and
payload on an AXI stream interface, decodes and strips the IP header fields,
then produces the header fields in parallel along with the IP payload in a
separate AXI stream.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_READ_HEADER = 3'd1,
    STATE_READ_PAYLOAD = 3'd2,
    STATE_READ_PAYLOAD_LAST = 3'd3,
    STATE_WAIT_LAST = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_hdr;
reg store_ip_version_ihl;
reg store_ip_dscp_ecn;
reg store_ip_length_0;
reg store_ip_length_1;
reg store_ip_identification_0;
reg store_ip_identification_1;
reg store_ip_flags_fragment_offset_0;
reg store_ip_flags_fragment_offset_1;
reg store_ip_ttl;
reg store_ip_protocol;
reg store_ip_header_checksum_0;
reg store_ip_header_checksum_1;
reg store_ip_source_ip_0;
reg store_ip_source_ip_1;
reg store_ip_source_ip_2;
reg store_ip_source_ip_3;
reg store_ip_dest_ip_0;
reg store_ip_dest_ip_1;
reg store_ip_dest_ip_2;
reg store_ip_dest_ip_3;
reg store_last_word;

reg [5:0] hdr_ptr_reg = 6'd0, hdr_ptr_next;
reg [15:0] word_count_reg = 16'd0, word_count_next;

reg [15:0] hdr_sum_reg = 16'd0, hdr_sum_next;

reg [7:0] last_word_data_reg = 8'd0;

reg s_eth_hdr_ready_reg = 1'b0, s_eth_hdr_ready_next;
reg s_eth_payload_axis_tready_reg = 1'b0, s_eth_payload_axis_tready_next;

reg m_ip_hdr_valid_reg = 1'b0, m_ip_hdr_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0;
reg [47:0] m_eth_src_mac_reg = 48'd0;
reg [15:0] m_eth_type_reg = 16'd0;
reg [3:0] m_ip_version_reg = 4'd0;
reg [3:0] m_ip_ihl_reg = 4'd0;
reg [5:0] m_ip_dscp_reg = 6'd0;
reg [1:0] m_ip_ecn_reg = 2'd0;
reg [15:0] m_ip_length_reg = 16'd0;
reg [15:0] m_ip_identification_reg = 16'd0;
reg [2:0] m_ip_flags_reg = 3'd0;
reg [12:0] m_ip_fragment_offset_reg = 13'd0;
reg [7:0] m_ip_ttl_reg = 8'd0;
reg [7:0] m_ip_protocol_reg = 8'd0;
reg [15:0] m_ip_header_checksum_reg = 16'd0;
reg [31:0] m_ip_source_ip_reg = 32'd0;
reg [31:0] m_ip_dest_ip_reg = 32'd0;

reg busy_reg = 1'b0;
reg error_header_early_termination_reg = 1'b0, error_header_early_termination_next;
reg error_payload_early_termination_reg = 1'b0, error_payload_early_termination_next;
reg error_invalid_header_reg = 1'b0, error_invalid_header_next;
reg error_invalid_checksum_reg = 1'b0, error_invalid_checksum_next;

// internal datapath
reg [7:0] m_ip_payload_axis_tdata_int;
reg       m_ip_payload_axis_tvalid_int;
reg       m_ip_payload_axis_tready_int_reg = 1'b0;
reg       m_ip_payload_axis_tlast_int;
reg       m_ip_payload_axis_tuser_int;
wire      m_ip_payload_axis_tready_int_early;

assign s_eth_hdr_ready = s_eth_hdr_ready_reg;
assign s_eth_payload_axis_tready = s_eth_payload_axis_tready_reg;

assign m_ip_hdr_valid = m_ip_hdr_valid_reg;
assign m_eth_dest_mac = m_eth_dest_mac_reg;
assign m_eth_src_mac = m_eth_src_mac_reg;
assign m_eth_type = m_eth_type_reg;
assign m_ip_version = m_ip_version_reg;
assign m_ip_ihl = m_ip_ihl_reg;
assign m_ip_dscp = m_ip_dscp_reg;
assign m_ip_ecn = m_ip_ecn_reg;
assign m_ip_length = m_ip_length_reg;
assign m_ip_identification = m_ip_identification_reg;
assign m_ip_flags = m_ip_flags_reg;
assign m_ip_fragment_offset = m_ip_fragment_offset_reg;
assign m_ip_ttl = m_ip_ttl_reg;
assign m_ip_protocol = m_ip_protocol_reg;
assign m_ip_header_checksum = m_ip_header_checksum_reg;
assign m_ip_source_ip = m_ip_source_ip_reg;
assign m_ip_dest_ip = m_ip_dest_ip_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;
assign error_payload_early_termination = error_payload_early_termination_reg;
assign error_invalid_header = error_invalid_header_reg;
assign error_invalid_checksum = error_invalid_checksum_reg;

function [15:0] add1c16b;
    input [15:0] a, b;
    reg [16:0] t;
    begin
        t = a+b;
        add1c16b = t[15:0] + t[16];
    end
endfunction

always @* begin
    state_next = STATE_IDLE;

    s_eth_hdr_ready_next = 1'b0;
    s_eth_payload_axis_tready_next = 1'b0;

    store_eth_hdr = 1'b0;
    store_ip_version_ihl = 1'b0;
    store_ip_dscp_ecn = 1'b0;
    store_ip_length_0 = 1'b0;
    store_ip_length_1 = 1'b0;
    store_ip_identification_0 = 1'b0;
    store_ip_identification_1 = 1'b0;
    store_ip_flags_fragment_offset_0 = 1'b0;
    store_ip_flags_fragment_offset_1 = 1'b0;
    store_ip_ttl = 1'b0;
    store_ip_protocol = 1'b0;
    store_ip_header_checksum_0 = 1'b0;
    store_ip_header_checksum_1 = 1'b0;
    store_ip_source_ip_0 = 1'b0;
    store_ip_source_ip_1 = 1'b0;
    store_ip_source_ip_2 = 1'b0;
    store_ip_source_ip_3 = 1'b0;
    store_ip_dest_ip_0 = 1'b0;
    store_ip_dest_ip_1 = 1'b0;
    store_ip_dest_ip_2 = 1'b0;
    store_ip_dest_ip_3 = 1'b0;

    store_last_word = 1'b0;

    hdr_ptr_next = hdr_ptr_reg;
    word_count_next = word_count_reg;

    hdr_sum_next = hdr_sum_reg;

    m_ip_hdr_valid_next = m_ip_hdr_valid_reg && !m_ip_hdr_ready;

    error_header_early_termination_next = 1'b0;
    error_payload_early_termination_next = 1'b0;
    error_invalid_header_next = 1'b0;
    error_invalid_checksum_next = 1'b0;

    m_ip_payload_axis_tdata_int = 8'd0;
    m_ip_payload_axis_tvalid_int = 1'b0;
    m_ip_payload_axis_tlast_int = 1'b0;
    m_ip_payload_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for header
            hdr_ptr_next = 16'd0;
            hdr_sum_next = 16'd0;
            s_eth_hdr_ready_next = !m_ip_hdr_valid_next;

            if (s_eth_hdr_ready && s_eth_hdr_valid) begin
                s_eth_hdr_ready_next = 1'b0;
                s_eth_payload_axis_tready_next = 1'b1;
                store_eth_hdr = 1'b1;
                state_next = STATE_READ_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_HEADER: begin
            // read header
            s_eth_payload_axis_tready_next = 1'b1;
            word_count_next = m_ip_length_reg - 5*4;

            if (s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) begin
                // word transfer in - store it
                hdr_ptr_next = hdr_ptr_reg + 6'd1;
                state_next = STATE_READ_HEADER;

                if (hdr_ptr_reg[0]) begin
                    hdr_sum_next = add1c16b(hdr_sum_reg, {8'd0, s_eth_payload_axis_tdata});
                end else begin
                    hdr_sum_next = add1c16b(hdr_sum_reg, {s_eth_payload_axis_tdata, 8'd0});
                end

                case (hdr_ptr_reg)
                    6'h00: store_ip_version_ihl = 1'b1;
                    6'h01: store_ip_dscp_ecn = 1'b1;
                    6'h02: store_ip_length_1 = 1'b1;
                    6'h03: store_ip_length_0 = 1'b1;
                    6'h04: store_ip_identification_1 = 1'b1;
                    6'h05: store_ip_identification_0 = 1'b1;
                    6'h06: store_ip_flags_fragment_offset_1 = 1'b1;
                    6'h07: store_ip_flags_fragment_offset_0 = 1'b1;
                    6'h08: store_ip_ttl = 1'b1;
                    6'h09: store_ip_protocol = 1'b1;
                    6'h0A: store_ip_header_checksum_1 = 1'b1;
                    6'h0B: store_ip_header_checksum_0 = 1'b1;
                    6'h0C: store_ip_source_ip_3 = 1'b1;
                    6'h0D: store_ip_source_ip_2 = 1'b1;
                    6'h0E: store_ip_source_ip_1 = 1'b1;
                    6'h0F: store_ip_source_ip_0 = 1'b1;
                    6'h10: store_ip_dest_ip_3 = 1'b1;
                    6'h11: store_ip_dest_ip_2 = 1'b1;
                    6'h12: store_ip_dest_ip_1 = 1'b1;
                    6'h13: begin
                        store_ip_dest_ip_0 = 1'b1;
                        if (m_ip_version_reg != 4'd4 || m_ip_ihl_reg != 4'd5) begin
                            error_invalid_header_next = 1'b1;
                            state_next = STATE_WAIT_LAST;
                        end else if (hdr_sum_next != 16'hffff) begin
                            error_invalid_checksum_next = 1'b1;
                            state_next = STATE_WAIT_LAST;
                        end else begin
                            m_ip_hdr_valid_next = 1'b1;
                            s_eth_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;
                            state_next = STATE_READ_PAYLOAD;
                        end
                    end
                endcase

                if (s_eth_payload_axis_tlast) begin
                    error_header_early_termination_next = 1'b1;
                    m_ip_hdr_valid_next = 1'b0;
                    s_eth_hdr_ready_next = !m_ip_hdr_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end

            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_READ_PAYLOAD: begin
            // read payload
            s_eth_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;

            m_ip_payload_axis_tdata_int = s_eth_payload_axis_tdata;
            m_ip_payload_axis_tvalid_int = s_eth_payload_axis_tvalid;
            m_ip_payload_axis_tlast_int = s_eth_payload_axis_tlast;
            m_ip_payload_axis_tuser_int = s_eth_payload_axis_tuser;

            if (s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) begin
                // word transfer through
                word_count_next = word_count_reg - 16'd1;
                if (s_eth_payload_axis_tlast) begin
                    if (word_count_reg > 16'd1) begin
                        // end of frame, but length does not match
                        m_ip_payload_axis_tuser_int = 1'b1;
                        error_payload_early_termination_next = 1'b1;
                    end
                    s_eth_hdr_ready_next = !m_ip_hdr_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    if (word_count_reg == 16'd1) begin
                        store_last_word = 1'b1;
                        m_ip_payload_axis_tvalid_int = 1'b0;
                        state_next = STATE_READ_PAYLOAD_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD;
                    end
                end
            end else begin
                state_next = STATE_READ_PAYLOAD;
            end
        end
        STATE_READ_PAYLOAD_LAST: begin
            // read and discard until end of frame
            s_eth_payload_axis_tready_next = m_ip_payload_axis_tready_int_early;

            m_ip_payload_axis_tdata_int = last_word_data_reg;
            m_ip_payload_axis_tvalid_int = s_eth_payload_axis_tvalid && s_eth_payload_axis_tlast;
            m_ip_payload_axis_tlast_int = s_eth_payload_axis_tlast;
            m_ip_payload_axis_tuser_int = s_eth_payload_axis_tuser;

            if (s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) begin
                if (s_eth_payload_axis_tlast) begin
                    s_eth_hdr_ready_next = !m_ip_hdr_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_READ_PAYLOAD_LAST;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_LAST;
            end
        end
        STATE_WAIT_LAST: begin
            // read and discard until end of frame
            s_eth_payload_axis_tready_next = 1'b1;

            if (s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) begin
                if (s_eth_payload_axis_tlast) begin
                    s_eth_hdr_ready_next = !m_ip_hdr_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WAIT_LAST;
                end
            end else begin
                state_next = STATE_WAIT_LAST;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        s_eth_hdr_ready_reg <= 1'b0;
        s_eth_payload_axis_tready_reg <= 1'b0;
        m_ip_hdr_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_header_early_termination_reg <= 1'b0;
        error_payload_early_termination_reg <= 1'b0;
        error_invalid_header_reg <= 1'b0;
        error_invalid_checksum_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;
        s_eth_payload_axis_tready_reg <= s_eth_payload_axis_tready_next;

        m_ip_hdr_valid_reg <= m_ip_hdr_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;
        error_payload_early_termination_reg <= error_payload_early_termination_next;
        error_invalid_header_reg <= error_invalid_header_next;
        error_invalid_checksum_reg <= error_invalid_checksum_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    hdr_ptr_reg <= hdr_ptr_next;
    word_count_reg <= word_count_next;

    hdr_sum_reg <= hdr_sum_next;

    // datapath
    if (store_eth_hdr) begin
        m_eth_dest_mac_reg <= s_eth_dest_mac;
        m_eth_src_mac_reg <= s_eth_src_mac;
        m_eth_type_reg <= s_eth_type;
    end

    if (store_last_word) begin
        last_word_data_reg <= m_ip_payload_axis_tdata_int;
    end

    if (store_ip_version_ihl) {m_ip_version_reg, m_ip_ihl_reg} <= s_eth_payload_axis_tdata;
    if (store_ip_dscp_ecn) {m_ip_dscp_reg, m_ip_ecn_reg} <= s_eth_payload_axis_tdata;
    if (store_ip_length_0) m_ip_length_reg[ 7: 0] <= s_eth_payload_axis_tdata;
    if (store_ip_length_1) m_ip_length_reg[15: 8] <= s_eth_payload_axis_tdata;
    if (store_ip_identification_0) m_ip_identification_reg[ 7: 0] <= s_eth_payload_axis_tdata;
    if (store_ip_identification_1) m_ip_identification_reg[15: 8] <= s_eth_payload_axis_tdata;
    if (store_ip_flags_fragment_offset_0) m_ip_fragment_offset_reg[ 7:0] <= s_eth_payload_axis_tdata;
    if (store_ip_flags_fragment_offset_1) {m_ip_flags_reg, m_ip_fragment_offset_reg[12:8]} <= s_eth_payload_axis_tdata;
    if (store_ip_ttl) m_ip_ttl_reg <= s_eth_payload_axis_tdata;
    if (store_ip_protocol) m_ip_protocol_reg <= s_eth_payload_axis_tdata;
    if (store_ip_header_checksum_0) m_ip_header_checksum_reg[ 7: 0] <= s_eth_payload_axis_tdata;
    if (store_ip_header_checksum_1) m_ip_header_checksum_reg[15: 8] <= s_eth_payload_axis_tdata;
    if (store_ip_source_ip_0) m_ip_source_ip_reg[ 7: 0] <= s_eth_payload_axis_tdata;
    if (store_ip_source_ip_1) m_ip_source_ip_reg[15: 8] <= s_eth_payload_axis_tdata;
    if (store_ip_source_ip_2) m_ip_source_ip_reg[23:16] <= s_eth_payload_axis_tdata;
    if (store_ip_source_ip_3) m_ip_source_ip_reg[31:24] <= s_eth_payload_axis_tdata;
    if (store_ip_dest_ip_0) m_ip_dest_ip_reg[ 7: 0] <= s_eth_payload_axis_tdata;
    if (store_ip_dest_ip_1) m_ip_dest_ip_reg[15: 8] <= s_eth_payload_axis_tdata;
    if (store_ip_dest_ip_2) m_ip_dest_ip_reg[23:16] <= s_eth_payload_axis_tdata;
    if (store_ip_dest_ip_3) m_ip_dest_ip_reg[31:24] <= s_eth_payload_axis_tdata;
end

// output datapath logic
reg [7:0] m_ip_payload_axis_tdata_reg = 8'd0;
reg       m_ip_payload_axis_tvalid_reg = 1'b0, m_ip_payload_axis_tvalid_next;
reg       m_ip_payload_axis_tlast_reg = 1'b0;
reg       m_ip_payload_axis_tuser_reg = 1'b0;

reg [7:0] temp_m_ip_payload_axis_tdata_reg = 8'd0;
reg       temp_m_ip_payload_axis_tvalid_reg = 1'b0, temp_m_ip_payload_axis_tvalid_next;
reg       temp_m_ip_payload_axis_tlast_reg = 1'b0;
reg       temp_m_ip_payload_axis_tuser_reg = 1'b0;

// datapath control
reg store_ip_payload_int_to_output;
reg store_ip_payload_int_to_temp;
reg store_ip_payload_axis_temp_to_output;

assign m_ip_payload_axis_tdata = m_ip_payload_axis_tdata_reg;
assign m_ip_payload_axis_tvalid = m_ip_payload_axis_tvalid_reg;
assign m_ip_payload_axis_tlast = m_ip_payload_axis_tlast_reg;
assign m_ip_payload_axis_tuser = m_ip_payload_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_ip_payload_axis_tready_int_early = m_ip_payload_axis_tready || (!temp_m_ip_payload_axis_tvalid_reg && (!m_ip_payload_axis_tvalid_reg || !m_ip_payload_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_reg;
    temp_m_ip_payload_axis_tvalid_next = temp_m_ip_payload_axis_tvalid_reg;

    store_ip_payload_int_to_output = 1'b0;
    store_ip_payload_int_to_temp = 1'b0;
    store_ip_payload_axis_temp_to_output = 1'b0;
    
    if (m_ip_payload_axis_tready_int_reg) begin
        // input is ready
        if (m_ip_payload_axis_tready || !m_ip_payload_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_int;
            store_ip_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_int;
            store_ip_payload_int_to_temp = 1'b1;
        end
    end else if (m_ip_payload_axis_tready) begin
        // input is not ready, but output is ready
        m_ip_payload_axis_tvalid_next = temp_m_ip_payload_axis_tvalid_reg;
        temp_m_ip_payload_axis_tvalid_next = 1'b0;
        store_ip_payload_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_ip_payload_axis_tvalid_reg <= 1'b0;
        m_ip_payload_axis_tready_int_reg <= 1'b0;
        temp_m_ip_payload_axis_tvalid_reg <= 1'b0;
    end else begin
        m_ip_payload_axis_tvalid_reg <= m_ip_payload_axis_tvalid_next;
        m_ip_payload_axis_tready_int_reg <= m_ip_payload_axis_tready_int_early;
        temp_m_ip_payload_axis_tvalid_reg <= temp_m_ip_payload_axis_tvalid_next;
    end

    // datapath
    if (store_ip_payload_int_to_output) begin
        m_ip_payload_axis_tdata_reg <= m_ip_payload_axis_tdata_int;
        m_ip_payload_axis_tlast_reg <= m_ip_payload_axis_tlast_int;
        m_ip_payload_axis_tuser_reg <= m_ip_payload_axis_tuser_int;
    end else if (store_ip_payload_axis_temp_to_output) begin
        m_ip_payload_axis_tdata_reg <= temp_m_ip_payload_axis_tdata_reg;
        m_ip_payload_axis_tlast_reg <= temp_m_ip_payload_axis_tlast_reg;
        m_ip_payload_axis_tuser_reg <= temp_m_ip_payload_axis_tuser_reg;
    end

    if (store_ip_payload_int_to_temp) begin
        temp_m_ip_payload_axis_tdata_reg <= m_ip_payload_axis_tdata_int;
        temp_m_ip_payload_axis_tlast_reg <= m_ip_payload_axis_tlast_int;
        temp_m_ip_payload_axis_tuser_reg <= m_ip_payload_axis_tuser_int;
    end
end

endmodule

`resetall
