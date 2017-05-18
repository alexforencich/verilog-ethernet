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
 * IPv4 block, ethernet frame interface
 */
module ip
(
    input  wire        clk,
    input  wire        rst,

    /*
     * Ethernet frame input
     */
    input  wire        input_eth_hdr_valid,
    output wire        input_eth_hdr_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [7:0]  input_eth_payload_tdata,
    input  wire        input_eth_payload_tvalid,
    output wire        input_eth_payload_tready,
    input  wire        input_eth_payload_tlast,
    input  wire        input_eth_payload_tuser,

    /*
     * Ethernet frame output
     */
    output wire        output_eth_hdr_valid,
    input  wire        output_eth_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
    output wire [7:0]  output_eth_payload_tdata,
    output wire        output_eth_payload_tvalid,
    input  wire        output_eth_payload_tready,
    output wire        output_eth_payload_tlast,
    output wire        output_eth_payload_tuser,

    /*
     * ARP requests
     */
    output wire        arp_request_valid,
    output wire [31:0] arp_request_ip,
    input  wire        arp_response_valid,
    input  wire        arp_response_error,
    input  wire [47:0] arp_response_mac,

    /*
     * IP input
     */
    input  wire        input_ip_hdr_valid,
    output wire        input_ip_hdr_ready,
    input  wire [5:0]  input_ip_dscp,
    input  wire [1:0]  input_ip_ecn,
    input  wire [15:0] input_ip_length,
    input  wire [7:0]  input_ip_ttl,
    input  wire [7:0]  input_ip_protocol,
    input  wire [31:0] input_ip_source_ip,
    input  wire [31:0] input_ip_dest_ip,
    input  wire [7:0]  input_ip_payload_tdata,
    input  wire        input_ip_payload_tvalid,
    output wire        input_ip_payload_tready,
    input  wire        input_ip_payload_tlast,
    input  wire        input_ip_payload_tuser,

    /*
     * IP output
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
    output wire [7:0]  output_ip_payload_tdata,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,

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
wire outgoing_ip_payload_tready;

/*
 * IP frame processing
 */
ip_eth_rx
ip_eth_rx_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(input_eth_hdr_valid),
    .input_eth_hdr_ready(input_eth_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_eth_payload_tdata(input_eth_payload_tdata),
    .input_eth_payload_tvalid(input_eth_payload_tvalid),
    .input_eth_payload_tready(input_eth_payload_tready),
    .input_eth_payload_tlast(input_eth_payload_tlast),
    .input_eth_payload_tuser(input_eth_payload_tuser),
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
    .output_ip_payload_tvalid(output_ip_payload_tvalid),
    .output_ip_payload_tready(output_ip_payload_tready),
    .output_ip_payload_tlast(output_ip_payload_tlast),
    .output_ip_payload_tuser(output_ip_payload_tuser),
    // Status signals
    .busy(rx_busy),
    .error_header_early_termination(rx_error_header_early_termination),
    .error_payload_early_termination(rx_error_payload_early_termination),
    .error_invalid_header(rx_error_invalid_header),
    .error_invalid_checksum(rx_error_invalid_checksum)
);

ip_eth_tx
ip_eth_tx_inst (
    .clk(clk),
    .rst(rst),
    // IP frame input
    .input_ip_hdr_valid(outgoing_ip_hdr_valid_reg),
    .input_ip_hdr_ready(outgoing_ip_hdr_ready),
    .input_eth_dest_mac(outgoing_eth_dest_mac_reg),
    .input_eth_src_mac(local_mac),
    .input_eth_type(16'h0800),
    .input_ip_dscp(input_ip_dscp),
    .input_ip_ecn(input_ip_ecn),
    .input_ip_length(input_ip_length),
    .input_ip_identification(16'd0),
    .input_ip_flags(3'b010),
    .input_ip_fragment_offset(13'd0),
    .input_ip_ttl(input_ip_ttl),
    .input_ip_protocol(input_ip_protocol),
    .input_ip_source_ip(input_ip_source_ip),
    .input_ip_dest_ip(input_ip_dest_ip),
    .input_ip_payload_tdata(input_ip_payload_tdata),
    .input_ip_payload_tvalid(input_ip_payload_tvalid),
    .input_ip_payload_tready(outgoing_ip_payload_tready),
    .input_ip_payload_tlast(input_ip_payload_tlast),
    .input_ip_payload_tuser(input_ip_payload_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
    // Status signals
    .busy(tx_busy),
    .error_payload_early_termination(tx_error_payload_early_termination)
);

reg input_ip_hdr_ready_reg = 1'b0, input_ip_hdr_ready_next;

reg arp_request_valid_reg = 1'b0, arp_request_valid_next;

reg drop_packet_reg = 1'b0, drop_packet_next;

assign input_ip_hdr_ready = input_ip_hdr_ready_reg;
assign input_ip_payload_tready = outgoing_ip_payload_tready | drop_packet_reg;

assign arp_request_valid = arp_request_valid_reg | (input_ip_hdr_valid & ~input_ip_hdr_ready_reg);
assign arp_request_ip = input_ip_dest_ip;

assign tx_error_arp_failed = arp_response_error;

always @* begin
    state_next = STATE_IDLE;

    arp_request_valid_next = 1'b0;
    drop_packet_next = 1'b0;

    input_ip_hdr_ready_next = 1'b0;

    outgoing_ip_hdr_valid_next = outgoing_ip_hdr_valid_reg & ~outgoing_ip_hdr_ready;
    outgoing_eth_dest_mac_next = outgoing_eth_dest_mac_reg;

    case (state_reg)
        STATE_IDLE: begin
            // wait for outgoing packet
            if (input_ip_hdr_valid) begin
                // initiate ARP request
                arp_request_valid_next = 1'b1;
                state_next = STATE_ARP_QUERY;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_ARP_QUERY: begin
            arp_request_valid_next = 1;

            if (arp_response_valid) begin
                // wait for ARP reponse
                if (arp_response_error) begin
                    // did not get MAC address; drop packet
                    input_ip_hdr_ready_next = 1'b1;
                    arp_request_valid_next = 1'b0;
                    drop_packet_next = 1'b1;
                    state_next = STATE_WAIT_PACKET;
                end else begin
                    // got MAC address; send packet
                    input_ip_hdr_ready_next = 1'b1;
                    arp_request_valid_next = 1'b0;
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
            if (input_ip_payload_tlast & input_ip_payload_tready & input_ip_payload_tvalid) begin
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
        drop_packet_reg <= 1'b0;
        input_ip_hdr_ready_reg <= 1'b0;
        outgoing_ip_hdr_valid_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        arp_request_valid_reg <= arp_request_valid_next;
        drop_packet_reg <= drop_packet_next;

        input_ip_hdr_ready_reg <= input_ip_hdr_ready_next;

        outgoing_ip_hdr_valid_reg <= outgoing_ip_hdr_valid_next;
    end

    outgoing_eth_dest_mac_reg <= outgoing_eth_dest_mac_next;
end

endmodule
