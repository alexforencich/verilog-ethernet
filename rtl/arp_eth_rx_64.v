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
 * ARP ethernet frame receiver (Ethernet frame in, ARP frame out, 64 bit datapath)
 */
module arp_eth_rx_64
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
    input  wire [63:0] s_eth_payload_axis_tdata,
    input  wire [7:0]  s_eth_payload_axis_tkeep,
    input  wire        s_eth_payload_axis_tvalid,
    output wire        s_eth_payload_axis_tready,
    input  wire        s_eth_payload_axis_tlast,
    input  wire        s_eth_payload_axis_tuser,

    /*
     * ARP frame output
     */
    output wire        m_frame_valid,
    input  wire        m_frame_ready,
    output wire [47:0] m_eth_dest_mac,
    output wire [47:0] m_eth_src_mac,
    output wire [15:0] m_eth_type,
    output wire [15:0] m_arp_htype,
    output wire [15:0] m_arp_ptype,
    output wire [7:0]  m_arp_hlen,
    output wire [7:0]  m_arp_plen,
    output wire [15:0] m_arp_oper,
    output wire [47:0] m_arp_sha,
    output wire [31:0] m_arp_spa,
    output wire [47:0] m_arp_tha,
    output wire [31:0] m_arp_tpa,

    /*
     * Status signals
     */
    output wire        busy,
    output wire        error_header_early_termination,
    output wire        error_invalid_header
);

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

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_READ_HEADER = 3'd1,
    STATE_WAIT_LAST = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_hdr;
reg store_arp_hdr_word_0;
reg store_arp_hdr_word_1;
reg store_arp_hdr_word_2;
reg store_arp_hdr_word_3;

reg [7:0] frame_ptr_reg = 8'd0, frame_ptr_next;

reg s_eth_hdr_ready_reg = 1'b0, s_eth_hdr_ready_next;
reg s_eth_payload_axis_tready_reg = 1'b0, s_eth_payload_axis_tready_next;

reg m_frame_valid_reg = 1'b0, m_frame_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0;
reg [47:0] m_eth_src_mac_reg = 48'd0;
reg [15:0] m_eth_type_reg = 16'd0;
reg [15:0] m_arp_htype_reg = 16'd0;
reg [15:0] m_arp_ptype_reg = 16'd0;
reg [7:0]  m_arp_hlen_reg = 8'd0;
reg [7:0]  m_arp_plen_reg = 8'd0;
reg [15:0] m_arp_oper_reg = 16'd0;
reg [47:0] m_arp_sha_reg = 48'd0;
reg [31:0] m_arp_spa_reg = 32'd0;
reg [47:0] m_arp_tha_reg = 48'd0;
reg [31:0] m_arp_tpa_reg = 32'd0;

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
    state_next = STATE_IDLE;

    s_eth_hdr_ready_next = 1'b0;
    s_eth_payload_axis_tready_next = 1'b0;

    store_eth_hdr = 1'b0;
    store_arp_hdr_word_0 = 1'b0;
    store_arp_hdr_word_1 = 1'b0;
    store_arp_hdr_word_2 = 1'b0;
    store_arp_hdr_word_3 = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    m_frame_valid_next = m_frame_valid_reg && !m_frame_ready;

    error_header_early_termination_next = 1'b0;
    error_invalid_header_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 8'd0;
            s_eth_hdr_ready_next = !m_frame_valid_next;

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
            // read header state
            s_eth_payload_axis_tready_next = 1'b1;

            if (s_eth_payload_axis_tvalid) begin
                // word transfer in - store it
                frame_ptr_next = frame_ptr_reg + 8'd1;
                state_next = STATE_READ_HEADER;
                case (frame_ptr_reg)
                    8'h00: store_arp_hdr_word_0 = 1'b1;
                    8'h01: store_arp_hdr_word_1 = 1'b1;
                    8'h02: store_arp_hdr_word_2 = 1'b1;
                    8'h03: begin
                        store_arp_hdr_word_3 = 1'b1;
                        state_next = STATE_WAIT_LAST;
                    end
                endcase
                if (s_eth_payload_axis_tlast) begin
                    if (frame_ptr_reg != 8'h03 || (s_eth_payload_axis_tkeep & 8'h0F) != 8'h0F) begin
                        error_header_early_termination_next = 1'b1;
                    end else if (m_arp_hlen != 4'd6 || m_arp_plen != 4'd4) begin
                        error_invalid_header_next = 1'b1;
                    end else begin
                        m_frame_valid_next = !s_eth_payload_axis_tuser;
                    end
                    s_eth_hdr_ready_next = !m_frame_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_WAIT_LAST: begin
            // wait for end of frame; read and discard
            s_eth_payload_axis_tready_next = 1'b1;

            if (s_eth_payload_axis_tvalid) begin
                if (s_eth_payload_axis_tlast) begin
                    if (m_arp_hlen != 4'd6 || m_arp_plen != 4'd4) begin
                        // lengths not valid
                        error_invalid_header_next = 1'b1;
                    end else begin
                        // otherwise, transfer tuser
                        m_frame_valid_next = !s_eth_payload_axis_tuser;
                    end
                    s_eth_hdr_ready_next = !m_frame_valid_next;
                    s_eth_payload_axis_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WAIT_LAST;
                end
            end else begin
                // wait for end of frame; read and discard
                state_next = STATE_WAIT_LAST;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 8'd0;
        s_eth_payload_axis_tready_reg <= 1'b0;
        m_frame_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_header_early_termination_reg <= 1'b0;
        error_invalid_header_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;
        s_eth_payload_axis_tready_reg <= s_eth_payload_axis_tready_next;

        frame_ptr_reg <= frame_ptr_next;

        m_frame_valid_reg <= m_frame_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;
        error_invalid_header_reg <= error_invalid_header_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    // datapath
    if (store_eth_hdr) begin
        m_eth_dest_mac_reg <= s_eth_dest_mac;
        m_eth_src_mac_reg <= s_eth_src_mac;
        m_eth_type_reg <= s_eth_type;
    end

    if (store_arp_hdr_word_0) begin
        m_arp_htype_reg[15: 8] <= s_eth_payload_axis_tdata[ 7: 0];
        m_arp_htype_reg[ 7: 0] <= s_eth_payload_axis_tdata[15: 8];
        m_arp_ptype_reg[15: 8] <= s_eth_payload_axis_tdata[23:16];
        m_arp_ptype_reg[ 7: 0] <= s_eth_payload_axis_tdata[31:24];
        m_arp_hlen_reg <= s_eth_payload_axis_tdata[39:32];
        m_arp_plen_reg <= s_eth_payload_axis_tdata[47:40];
        m_arp_oper_reg[15: 8] <= s_eth_payload_axis_tdata[55:48];
        m_arp_oper_reg[ 7: 0] <= s_eth_payload_axis_tdata[63:56];
    end
    if (store_arp_hdr_word_1) begin
        m_arp_sha_reg[47:40] <= s_eth_payload_axis_tdata[ 7: 0];
        m_arp_sha_reg[39:32] <= s_eth_payload_axis_tdata[15: 8];
        m_arp_sha_reg[31:24] <= s_eth_payload_axis_tdata[23:16];
        m_arp_sha_reg[23:16] <= s_eth_payload_axis_tdata[31:24];
        m_arp_sha_reg[15: 8] <= s_eth_payload_axis_tdata[39:32];
        m_arp_sha_reg[ 7: 0] <= s_eth_payload_axis_tdata[47:40];
        m_arp_spa_reg[31:24] <= s_eth_payload_axis_tdata[55:48];
        m_arp_spa_reg[23:16] <= s_eth_payload_axis_tdata[63:56];
    end
    if (store_arp_hdr_word_2) begin
        m_arp_spa_reg[15: 8] <= s_eth_payload_axis_tdata[ 7: 0];
        m_arp_spa_reg[ 7: 0] <= s_eth_payload_axis_tdata[15: 8];
        m_arp_tha_reg[47:40] <= s_eth_payload_axis_tdata[23:16];
        m_arp_tha_reg[39:32] <= s_eth_payload_axis_tdata[31:24];
        m_arp_tha_reg[31:24] <= s_eth_payload_axis_tdata[39:32];
        m_arp_tha_reg[23:16] <= s_eth_payload_axis_tdata[47:40];
        m_arp_tha_reg[15: 8] <= s_eth_payload_axis_tdata[55:48];
        m_arp_tha_reg[ 7: 0] <= s_eth_payload_axis_tdata[63:56];
    end
    if (store_arp_hdr_word_3) begin
        m_arp_tpa_reg[31:24] <= s_eth_payload_axis_tdata[ 7: 0];
        m_arp_tpa_reg[23:16] <= s_eth_payload_axis_tdata[15: 8];
        m_arp_tpa_reg[15: 8] <= s_eth_payload_axis_tdata[23:16];
        m_arp_tpa_reg[ 7: 0] <= s_eth_payload_axis_tdata[31:24];
    end
end

endmodule
