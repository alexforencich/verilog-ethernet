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
 * IPv4 block, ethernet frame interface (64 bit datapath)
 */
module ip_64
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
     * Ethernet frame output
     */
    output wire        m_eth_hdr_valid,
    input  wire        m_eth_hdr_ready,
    output wire [47:0] m_eth_dest_mac,
    output wire [47:0] m_eth_src_mac,
    output wire [15:0] m_eth_type,
    output wire [63:0] m_eth_payload_axis_tdata,
    output wire [7:0]  m_eth_payload_axis_tkeep,
    output wire        m_eth_payload_axis_tvalid,
    input  wire        m_eth_payload_axis_tready,
    output wire        m_eth_payload_axis_tlast,
    output wire        m_eth_payload_axis_tuser,

    /*
     * ARP requests
     */
    output wire        arp_request_valid,
    input  wire        arp_request_ready,
    output wire [31:0] arp_request_ip,
    input  wire        arp_response_valid,
    output wire        arp_response_ready,
    input  wire        arp_response_error,
    input  wire [47:0] arp_response_mac,

    /*
     * IP input
     */
    input  wire        s_ip_hdr_valid,
    output wire        s_ip_hdr_ready,
    input  wire [5:0]  s_ip_dscp,
    input  wire [1:0]  s_ip_ecn,
    input  wire [15:0] s_ip_length,
    input  wire [7:0]  s_ip_ttl,
    input  wire [7:0]  s_ip_protocol,
    input  wire [31:0] s_ip_source_ip,
    input  wire [31:0] s_ip_dest_ip,
    input  wire [63:0] s_ip_payload_axis_tdata,
    input  wire [7:0]  s_ip_payload_axis_tkeep,
    input  wire        s_ip_payload_axis_tvalid,
    output wire        s_ip_payload_axis_tready,
    input  wire        s_ip_payload_axis_tlast,
    input  wire        s_ip_payload_axis_tuser,

    /*
     * IP output
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
    output wire [63:0] m_ip_payload_axis_tdata,
    output wire [7:0]  m_ip_payload_axis_tkeep,
    output wire        m_ip_payload_axis_tvalid,
    input  wire        m_ip_payload_axis_tready,
    output wire        m_ip_payload_axis_tlast,
    output wire        m_ip_payload_axis_tuser,

    /*
     * Status
     */
    output wire rx_busy,
    output wire tx_busy,
    output wire rx_error_header_early_termination,
    output wire rx_error_payload_early_termination,
    output wire rx_error_invalid_header,
    output wire rx_error_invalid_checksum,
    output wire tx_error_payload_early_termination,
    output wire tx_error_arp_failed,

    /*
     * Configuration
     */
    input  wire [47:0] local_mac,
    input  wire [31:0] local_ip
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_ARP_QUERY = 2'd1,
    STATE_WAIT_PACKET = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg outgoing_ip_hdr_valid_reg = 1'b0, outgoing_ip_hdr_valid_next;
wire outgoing_ip_hdr_ready;
reg [47:0] outgoing_eth_dest_mac_reg = 48'h000000000000, outgoing_eth_dest_mac_next;
wire outgoing_ip_payload_axis_tready;

/*
 * IP frame processing
 */
ip_eth_rx_64
ip_eth_rx_64_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(s_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),
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
    .m_ip_payload_axis_tkeep(m_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser),
    // Status signals
    .busy(rx_busy),
    .error_header_early_termination(rx_error_header_early_termination),
    .error_payload_early_termination(rx_error_payload_early_termination),
    .error_invalid_header(rx_error_invalid_header),
    .error_invalid_checksum(rx_error_invalid_checksum)
);

ip_eth_tx_64
ip_eth_tx_64_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .s_ip_hdr_valid(outgoing_ip_hdr_valid_reg),
    .s_ip_hdr_ready(outgoing_ip_hdr_ready),
    .s_eth_dest_mac(outgoing_eth_dest_mac_reg),
    .s_eth_src_mac(local_mac),
    .s_eth_type(16'h0800),
    .s_ip_dscp(s_ip_dscp),
    .s_ip_ecn(s_ip_ecn),
    .s_ip_length(s_ip_length),
    .s_ip_identification(16'd0),
    .s_ip_flags(3'b010),
    .s_ip_fragment_offset(13'd0),
    .s_ip_ttl(s_ip_ttl),
    .s_ip_protocol(s_ip_protocol),
    .s_ip_source_ip(s_ip_source_ip),
    .s_ip_dest_ip(s_ip_dest_ip),
    .s_ip_payload_axis_tdata(s_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(s_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(outgoing_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),
    // Ethernet frame output
    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(m_eth_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(m_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(m_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),
    // Status signals
    .busy(tx_busy),
    .error_payload_early_termination(tx_error_payload_early_termination)
);

reg s_ip_hdr_ready_reg = 1'b0, s_ip_hdr_ready_next;

reg arp_request_valid_reg = 1'b0, arp_request_valid_next;

reg arp_response_ready_reg = 1'b0, arp_response_ready_next;

reg drop_packet_reg = 1'b0, drop_packet_next;

assign s_ip_hdr_ready = s_ip_hdr_ready_reg;
assign s_ip_payload_axis_tready = outgoing_ip_payload_axis_tready || drop_packet_reg;

assign arp_request_valid = arp_request_valid_reg;
assign arp_request_ip = s_ip_dest_ip;
assign arp_response_ready = arp_response_ready_reg;

assign tx_error_arp_failed = arp_response_error;

always @* begin
    state_next = STATE_IDLE;

    arp_request_valid_next = arp_request_valid_reg && !arp_request_ready;
    arp_response_ready_next = 1'b0;
    drop_packet_next = 1'b0;

    s_ip_hdr_ready_next = 1'b0;

    outgoing_ip_hdr_valid_next = outgoing_ip_hdr_valid_reg && !outgoing_ip_hdr_ready;
    outgoing_eth_dest_mac_next = outgoing_eth_dest_mac_reg;

    case (state_reg)
        STATE_IDLE: begin
            // wait for outgoing packet
            if (s_ip_hdr_valid) begin
                // initiate ARP request
                arp_request_valid_next = 1'b1;
                arp_response_ready_next = 1'b1;
                state_next = STATE_ARP_QUERY;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_ARP_QUERY: begin
            arp_response_ready_next = 1'b1;

            if (arp_response_valid) begin
                // wait for ARP reponse
                if (arp_response_error) begin
                    // did not get MAC address; drop packet
                    s_ip_hdr_ready_next = 1'b1;
                    drop_packet_next = 1'b1;
                    state_next = STATE_WAIT_PACKET;
                end else begin
                    // got MAC address; send packet
                    s_ip_hdr_ready_next = 1'b1;
                    outgoing_ip_hdr_valid_next = 1'b1;
                    outgoing_eth_dest_mac_next = arp_response_mac;
                    state_next = STATE_WAIT_PACKET;
                end
            end else begin
                state_next = STATE_ARP_QUERY;
            end
        end
        STATE_WAIT_PACKET: begin
            drop_packet_next = drop_packet_reg;

            // wait for packet transfer to complete
            if (s_ip_payload_axis_tlast && s_ip_payload_axis_tready && s_ip_payload_axis_tvalid) begin
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_WAIT_PACKET;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        arp_request_valid_reg <= 1'b0;
        arp_response_ready_reg <= 1'b0;
        drop_packet_reg <= 1'b0;
        s_ip_hdr_ready_reg <= 1'b0;
        outgoing_ip_hdr_valid_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        arp_request_valid_reg <= arp_request_valid_next;
        arp_response_ready_reg <= arp_response_ready_next;
        drop_packet_reg <= drop_packet_next;

        s_ip_hdr_ready_reg <= s_ip_hdr_ready_next;

        outgoing_ip_hdr_valid_reg <= outgoing_ip_hdr_valid_next;
    end

    outgoing_eth_dest_mac_reg <= outgoing_eth_dest_mac_next;
end

endmodule

`resetall
