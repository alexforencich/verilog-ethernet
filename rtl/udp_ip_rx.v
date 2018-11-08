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
 * UDP ethernet frame receiver (IP frame in, UDP frame out)
 */
module udp_ip_rx
(
    input  wire        clk,
    input  wire        rst,

    /*
     * IP frame input
     */
    input  wire        s_ip_hdr_valid,
    output wire        s_ip_hdr_ready,
    input  wire [47:0] s_eth_dest_mac,
    input  wire [47:0] s_eth_src_mac,
    input  wire [15:0] s_eth_type,
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
     * UDP frame output
     */
    output wire        m_udp_hdr_valid,
    input  wire        m_udp_hdr_ready,
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
    output wire        busy,
    output wire        error_header_early_termination,
    output wire        error_payload_early_termination
);

/*

UDP Frame

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

 source port                 2 octets
 desination port             2 octets
 length                      2 octets
 checksum                    2 octets

 payload                     length octets

This module receives an IP frame with header fields in parallel and payload on
an AXI stream interface, decodes and strips the UDP header fields, then
produces the header fields in parallel along with the UDP payload in a
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
reg store_ip_hdr;
reg store_udp_source_port_0;
reg store_udp_source_port_1;
reg store_udp_dest_port_0;
reg store_udp_dest_port_1;
reg store_udp_length_0;
reg store_udp_length_1;
reg store_udp_checksum_0;
reg store_udp_checksum_1;
reg store_last_word;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [7:0] last_word_data_reg = 8'd0;

reg m_udp_hdr_valid_reg = 1'b0, m_udp_hdr_valid_next;
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
reg [15:0] m_udp_source_port_reg = 16'd0;
reg [15:0] m_udp_dest_port_reg = 16'd0;
reg [15:0] m_udp_length_reg = 16'd0;
reg [15:0] m_udp_checksum_reg = 16'd0;

reg s_ip_hdr_ready_reg = 1'b0, s_ip_hdr_ready_next;
reg s_ip_payload_axis_tready_reg = 1'b0, s_ip_payload_axis_tready_next;

reg busy_reg = 1'b0;
reg error_header_early_termination_reg = 1'b0, error_header_early_termination_next;
reg error_payload_early_termination_reg = 1'b0, error_payload_early_termination_next;

// internal datapath
reg [7:0] m_udp_payload_axis_tdata_int;
reg       m_udp_payload_axis_tvalid_int;
reg       m_udp_payload_axis_tready_int_reg = 1'b0;
reg       m_udp_payload_axis_tlast_int;
reg       m_udp_payload_axis_tuser_int;
wire      m_udp_payload_axis_tready_int_early;

assign s_ip_hdr_ready = s_ip_hdr_ready_reg;
assign s_ip_payload_axis_tready = s_ip_payload_axis_tready_reg;

assign m_udp_hdr_valid = m_udp_hdr_valid_reg;
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
assign m_udp_source_port = m_udp_source_port_reg;
assign m_udp_dest_port = m_udp_dest_port_reg;
assign m_udp_length = m_udp_length_reg;
assign m_udp_checksum = m_udp_checksum_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;
assign error_payload_early_termination = error_payload_early_termination_reg;

always @* begin
    state_next = STATE_IDLE;

    s_ip_hdr_ready_next = 1'b0;
    s_ip_payload_axis_tready_next = 1'b0;

    store_ip_hdr = 1'b0;
    store_udp_source_port_0 = 1'b0;
    store_udp_source_port_1 = 1'b0;
    store_udp_dest_port_0 = 1'b0;
    store_udp_dest_port_1 = 1'b0;
    store_udp_length_0 = 1'b0;
    store_udp_length_1 = 1'b0;
    store_udp_checksum_0 = 1'b0;
    store_udp_checksum_1 = 1'b0;

    store_last_word = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    m_udp_hdr_valid_next = m_udp_hdr_valid_reg && !m_udp_hdr_ready;

    error_header_early_termination_next = 1'b0;
    error_payload_early_termination_next = 1'b0;

    m_udp_payload_axis_tdata_int = 8'd0;
    m_udp_payload_axis_tvalid_int = 1'b0;
    m_udp_payload_axis_tlast_int = 1'b0;
    m_udp_payload_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for header
            frame_ptr_next = 16'd0;
            s_ip_hdr_ready_next = !m_udp_hdr_valid_next;

            if (s_ip_hdr_ready && s_ip_hdr_valid) begin
                s_ip_hdr_ready_next = 1'b0;
                s_ip_payload_axis_tready_next = 1'b1;
                store_ip_hdr = 1'b1;
                state_next = STATE_READ_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_HEADER: begin
            // read header state
            s_ip_payload_axis_tready_next = 1'b1;

            if (s_ip_payload_axis_tready && s_ip_payload_axis_tvalid) begin
                // word transfer in - store it
                frame_ptr_next = frame_ptr_reg + 16'd1;
                state_next = STATE_READ_HEADER;

                case (frame_ptr_reg)
                    8'h00: store_udp_source_port_1 = 1'b1;
                    8'h01: store_udp_source_port_0 = 1'b1;
                    8'h02: store_udp_dest_port_1 = 1'b1;
                    8'h03: store_udp_dest_port_0 = 1'b1;
                    8'h04: store_udp_length_1 = 1'b1;
                    8'h05: store_udp_length_0 = 1'b1;
                    8'h06: store_udp_checksum_1 = 1'b1;
                    8'h07: begin
                        store_udp_checksum_0 = 1'b1;
                        m_udp_hdr_valid_next = 1'b1;
                        s_ip_payload_axis_tready_next = m_udp_payload_axis_tready_int_early;
                        state_next = STATE_READ_PAYLOAD;
                    end
                endcase

                if (s_ip_payload_axis_tlast) begin
                    error_header_early_termination_next = 1'b1;
                    m_udp_hdr_valid_next = 1'b0;
                    s_ip_hdr_ready_next = !m_udp_hdr_valid_next;
                    s_ip_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end

            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_READ_PAYLOAD: begin
            // read payload
            s_ip_payload_axis_tready_next = m_udp_payload_axis_tready_int_early;

            m_udp_payload_axis_tdata_int = s_ip_payload_axis_tdata;
            m_udp_payload_axis_tvalid_int = s_ip_payload_axis_tvalid;
            m_udp_payload_axis_tlast_int = s_ip_payload_axis_tlast;
            m_udp_payload_axis_tuser_int = s_ip_payload_axis_tuser;

            if (s_ip_payload_axis_tready && s_ip_payload_axis_tvalid) begin
                // word transfer through
                frame_ptr_next = frame_ptr_reg + 16'd1;
                if (s_ip_payload_axis_tlast) begin
                    if (frame_ptr_next != m_udp_length_reg) begin
                        // end of frame, but length does not match
                        m_udp_payload_axis_tuser_int = 1'b1;
                        error_payload_early_termination_next = 1'b1;
                    end
                    s_ip_hdr_ready_next = !m_udp_hdr_valid_next;
                    s_ip_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    if (frame_ptr_next == m_udp_length_reg) begin
                        store_last_word = 1'b1;
                        m_udp_payload_axis_tvalid_int = 1'b0;
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
            s_ip_payload_axis_tready_next = m_udp_payload_axis_tready_int_early;

            m_udp_payload_axis_tdata_int = last_word_data_reg;
            m_udp_payload_axis_tvalid_int = s_ip_payload_axis_tvalid && s_ip_payload_axis_tlast;
            m_udp_payload_axis_tlast_int = s_ip_payload_axis_tlast;
            m_udp_payload_axis_tuser_int = s_ip_payload_axis_tuser;

            if (s_ip_payload_axis_tready && s_ip_payload_axis_tvalid) begin
                if (s_ip_payload_axis_tlast) begin
                    s_ip_hdr_ready_next = !m_udp_hdr_valid_next;
                    s_ip_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_READ_PAYLOAD_LAST;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_LAST;
            end
        end
        STATE_WAIT_LAST: begin
            // wait for end of frame; read and discard
            s_ip_payload_axis_tready_next = 1'b1;

            if (s_ip_payload_axis_tready && s_ip_payload_axis_tvalid) begin
                if (s_ip_payload_axis_tlast) begin
                    s_ip_hdr_ready_next = !m_udp_hdr_valid_next;
                    s_ip_payload_axis_tready_next = 1'b0;
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
        frame_ptr_reg <= 16'd0;
        s_ip_hdr_ready_reg <= 1'b0;
        s_ip_payload_axis_tready_reg <= 1'b0;
        m_udp_hdr_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_header_early_termination_reg <= 1'b0;
        error_payload_early_termination_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        s_ip_hdr_ready_reg <= s_ip_hdr_ready_next;
        s_ip_payload_axis_tready_reg <= s_ip_payload_axis_tready_next;

        m_udp_hdr_valid_reg <= m_udp_hdr_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;
        error_payload_early_termination_reg <= error_payload_early_termination_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    // datapath
    if (store_ip_hdr) begin
        m_eth_dest_mac_reg <= s_eth_dest_mac;
        m_eth_src_mac_reg <= s_eth_src_mac;
        m_eth_type_reg <= s_eth_type;
        m_ip_version_reg <= s_ip_version;
        m_ip_ihl_reg <= s_ip_ihl;
        m_ip_dscp_reg <= s_ip_dscp;
        m_ip_ecn_reg <= s_ip_ecn;
        m_ip_length_reg <= s_ip_length;
        m_ip_identification_reg <= s_ip_identification;
        m_ip_flags_reg <= s_ip_flags;
        m_ip_fragment_offset_reg <= s_ip_fragment_offset;
        m_ip_ttl_reg <= s_ip_ttl;
        m_ip_protocol_reg <= s_ip_protocol;
        m_ip_header_checksum_reg <= s_ip_header_checksum;
        m_ip_source_ip_reg <= s_ip_source_ip;
        m_ip_dest_ip_reg <= s_ip_dest_ip;
    end

    if (store_last_word) begin
        last_word_data_reg <= m_udp_payload_axis_tdata_int;
    end

    if (store_udp_source_port_0) m_udp_source_port_reg[ 7: 0] <= s_ip_payload_axis_tdata;
    if (store_udp_source_port_1) m_udp_source_port_reg[15: 8] <= s_ip_payload_axis_tdata;
    if (store_udp_dest_port_0) m_udp_dest_port_reg[ 7: 0] <= s_ip_payload_axis_tdata;
    if (store_udp_dest_port_1) m_udp_dest_port_reg[15: 8] <= s_ip_payload_axis_tdata;
    if (store_udp_length_0) m_udp_length_reg[ 7: 0] <= s_ip_payload_axis_tdata;
    if (store_udp_length_1) m_udp_length_reg[15: 8] <= s_ip_payload_axis_tdata;
    if (store_udp_checksum_0) m_udp_checksum_reg[ 7: 0] <= s_ip_payload_axis_tdata;
    if (store_udp_checksum_1) m_udp_checksum_reg[15: 8] <= s_ip_payload_axis_tdata;
end

// output datapath logic
reg [7:0] m_udp_payload_axis_tdata_reg = 8'd0;
reg       m_udp_payload_axis_tvalid_reg = 1'b0, m_udp_payload_axis_tvalid_next;
reg       m_udp_payload_axis_tlast_reg = 1'b0;
reg       m_udp_payload_axis_tuser_reg = 1'b0;

reg [7:0] temp_m_udp_payload_axis_tdata_reg = 8'd0;
reg       temp_m_udp_payload_axis_tvalid_reg = 1'b0, temp_m_udp_payload_axis_tvalid_next;
reg       temp_m_udp_payload_axis_tlast_reg = 1'b0;
reg       temp_m_udp_payload_axis_tuser_reg = 1'b0;

// datapath control
reg store_udp_payload_int_to_output;
reg store_udp_payload_int_to_temp;
reg store_udp_payload_axis_temp_to_output;

assign m_udp_payload_axis_tdata = m_udp_payload_axis_tdata_reg;
assign m_udp_payload_axis_tvalid = m_udp_payload_axis_tvalid_reg;
assign m_udp_payload_axis_tlast = m_udp_payload_axis_tlast_reg;
assign m_udp_payload_axis_tuser = m_udp_payload_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_udp_payload_axis_tready_int_early = m_udp_payload_axis_tready || (!temp_m_udp_payload_axis_tvalid_reg && (!m_udp_payload_axis_tvalid_reg || !m_udp_payload_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_udp_payload_axis_tvalid_next = m_udp_payload_axis_tvalid_reg;
    temp_m_udp_payload_axis_tvalid_next = temp_m_udp_payload_axis_tvalid_reg;

    store_udp_payload_int_to_output = 1'b0;
    store_udp_payload_int_to_temp = 1'b0;
    store_udp_payload_axis_temp_to_output = 1'b0;
    
    if (m_udp_payload_axis_tready_int_reg) begin
        // input is ready
        if (m_udp_payload_axis_tready || !m_udp_payload_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_udp_payload_axis_tvalid_next = m_udp_payload_axis_tvalid_int;
            store_udp_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_udp_payload_axis_tvalid_next = m_udp_payload_axis_tvalid_int;
            store_udp_payload_int_to_temp = 1'b1;
        end
    end else if (m_udp_payload_axis_tready) begin
        // input is not ready, but output is ready
        m_udp_payload_axis_tvalid_next = temp_m_udp_payload_axis_tvalid_reg;
        temp_m_udp_payload_axis_tvalid_next = 1'b0;
        store_udp_payload_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_udp_payload_axis_tvalid_reg <= 1'b0;
        m_udp_payload_axis_tready_int_reg <= 1'b0;
        temp_m_udp_payload_axis_tvalid_reg <= 1'b0;
    end else begin
        m_udp_payload_axis_tvalid_reg <= m_udp_payload_axis_tvalid_next;
        m_udp_payload_axis_tready_int_reg <= m_udp_payload_axis_tready_int_early;
        temp_m_udp_payload_axis_tvalid_reg <= temp_m_udp_payload_axis_tvalid_next;
    end

    // datapath
    if (store_udp_payload_int_to_output) begin
        m_udp_payload_axis_tdata_reg <= m_udp_payload_axis_tdata_int;
        m_udp_payload_axis_tlast_reg <= m_udp_payload_axis_tlast_int;
        m_udp_payload_axis_tuser_reg <= m_udp_payload_axis_tuser_int;
    end else if (store_udp_payload_axis_temp_to_output) begin
        m_udp_payload_axis_tdata_reg <= temp_m_udp_payload_axis_tdata_reg;
        m_udp_payload_axis_tlast_reg <= temp_m_udp_payload_axis_tlast_reg;
        m_udp_payload_axis_tuser_reg <= temp_m_udp_payload_axis_tuser_reg;
    end

    if (store_udp_payload_int_to_temp) begin
        temp_m_udp_payload_axis_tdata_reg <= m_udp_payload_axis_tdata_int;
        temp_m_udp_payload_axis_tlast_reg <= m_udp_payload_axis_tlast_int;
        temp_m_udp_payload_axis_tuser_reg <= m_udp_payload_axis_tuser_int;
    end
end

endmodule
