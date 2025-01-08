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
 * ARP block for IPv4, ethernet frame interface
 */
module arp #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Log2 of ARP cache size
    parameter CACHE_ADDR_WIDTH = 9,
    // ARP request retry count
    parameter REQUEST_RETRY_COUNT = 4,
    // ARP request retry interval (in cycles)
    parameter REQUEST_RETRY_INTERVAL = 125000000*2,
    // ARP request timeout (in cycles)
    parameter REQUEST_TIMEOUT = 125000000*30
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
     * Ethernet frame output
     */
    output wire                   m_eth_hdr_valid,
    input  wire                   m_eth_hdr_ready,
    output wire [47:0]            m_eth_dest_mac,
    output wire [47:0]            m_eth_src_mac,
    output wire [15:0]            m_eth_type,
    output wire [DATA_WIDTH-1:0]  m_eth_payload_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_eth_payload_axis_tkeep,
    output wire                   m_eth_payload_axis_tvalid,
    input  wire                   m_eth_payload_axis_tready,
    output wire                   m_eth_payload_axis_tlast,
    output wire                   m_eth_payload_axis_tuser,

    /*
     * ARP requests
     */
    input  wire                   arp_request_valid,
    output wire                   arp_request_ready,
    input  wire [31:0]            arp_request_ip,
    output wire                   arp_response_valid,
    input  wire                   arp_response_ready,
    output wire                   arp_response_error,
    output wire [47:0]            arp_response_mac,

    /*
     * Configuration
     */
    input  wire [47:0]            local_mac,
    input  wire [31:0]            local_ip,
    input  wire [31:0]            gateway_ip,
    input  wire [31:0]            subnet_mask,
    input  wire                   clear_cache
);

localparam [15:0]
    ARP_OPER_ARP_REQUEST = 16'h0001,
    ARP_OPER_ARP_REPLY = 16'h0002,
    ARP_OPER_INARP_REQUEST = 16'h0008,
    ARP_OPER_INARP_REPLY = 16'h0009;

wire incoming_frame_valid;
reg incoming_frame_ready;
wire [47:0] incoming_eth_dest_mac;
wire [47:0] incoming_eth_src_mac;
wire [15:0] incoming_eth_type;
wire [15:0] incoming_arp_htype;
wire [15:0] incoming_arp_ptype;
wire [7:0]  incoming_arp_hlen;
wire [7:0]  incoming_arp_plen;
wire [15:0] incoming_arp_oper;
wire [47:0] incoming_arp_sha;
wire [31:0] incoming_arp_spa;
wire [47:0] incoming_arp_tha;
wire [31:0] incoming_arp_tpa;

/*
 * ARP frame processing
 */
arp_eth_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
arp_eth_rx_inst (
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
    // ARP frame output
    .m_frame_valid(incoming_frame_valid),
    .m_frame_ready(incoming_frame_ready),
    .m_eth_dest_mac(incoming_eth_dest_mac),
    .m_eth_src_mac(incoming_eth_src_mac),
    .m_eth_type(incoming_eth_type),
    .m_arp_htype(incoming_arp_htype),
    .m_arp_ptype(incoming_arp_ptype),
    .m_arp_hlen(incoming_arp_hlen),
    .m_arp_plen(incoming_arp_plen),
    .m_arp_oper(incoming_arp_oper),
    .m_arp_sha(incoming_arp_sha),
    .m_arp_spa(incoming_arp_spa),
    .m_arp_tha(incoming_arp_tha),
    .m_arp_tpa(incoming_arp_tpa),
    // Status signals
    .busy(),
    .error_header_early_termination(),
    .error_invalid_header()
);

reg outgoing_frame_valid_reg = 1'b0, outgoing_frame_valid_next;
wire outgoing_frame_ready;
reg [47:0] outgoing_eth_dest_mac_reg = 48'd0, outgoing_eth_dest_mac_next;
reg [15:0] outgoing_arp_oper_reg = 16'd0, outgoing_arp_oper_next;
reg [47:0] outgoing_arp_tha_reg = 48'd0, outgoing_arp_tha_next;
reg [31:0] outgoing_arp_tpa_reg = 32'd0, outgoing_arp_tpa_next;

arp_eth_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
arp_eth_tx_inst (
    .clk(clk),
    .rst(rst),
    // ARP frame input
    .s_frame_valid(outgoing_frame_valid_reg),
    .s_frame_ready(outgoing_frame_ready),
    .s_eth_dest_mac(outgoing_eth_dest_mac_reg),
    .s_eth_src_mac(local_mac),
    .s_eth_type(16'h0806),
    .s_arp_htype(16'h0001),
    .s_arp_ptype(16'h0800),
    .s_arp_oper(outgoing_arp_oper_reg),
    .s_arp_sha(local_mac),
    .s_arp_spa(local_ip),
    .s_arp_tha(outgoing_arp_tha_reg),
    .s_arp_tpa(outgoing_arp_tpa_reg),
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
    .busy()
);

reg cache_query_request_valid_reg = 1'b0, cache_query_request_valid_next;
reg [31:0] cache_query_request_ip_reg = 32'd0, cache_query_request_ip_next;
wire cache_query_response_valid;
wire cache_query_response_error;
wire [47:0] cache_query_response_mac;

reg cache_write_request_valid_reg = 1'b0, cache_write_request_valid_next;
reg [31:0] cache_write_request_ip_reg = 32'd0, cache_write_request_ip_next;
reg [47:0] cache_write_request_mac_reg = 48'd0, cache_write_request_mac_next;

/*
 * ARP cache
 */
arp_cache #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
)
arp_cache_inst (
    .clk(clk),
    .rst(rst),
    // Query cache
    .query_request_valid(cache_query_request_valid_reg),
    .query_request_ready(),
    .query_request_ip(cache_query_request_ip_reg),
    .query_response_valid(cache_query_response_valid),
    .query_response_ready(1'b1),
    .query_response_error(cache_query_response_error),
    .query_response_mac(cache_query_response_mac),
    // Write cache
    .write_request_valid(cache_write_request_valid_reg),
    .write_request_ready(),
    .write_request_ip(cache_write_request_ip_reg),
    .write_request_mac(cache_write_request_mac_reg),
    // Configuration
    .clear_cache(clear_cache)
);

reg arp_request_operation_reg = 1'b0, arp_request_operation_next;

reg arp_request_ready_reg = 1'b0, arp_request_ready_next;
reg [31:0] arp_request_ip_reg = 32'd0, arp_request_ip_next;

reg arp_response_valid_reg = 1'b0, arp_response_valid_next;
reg arp_response_error_reg = 1'b0, arp_response_error_next;
reg [47:0] arp_response_mac_reg = 48'd0, arp_response_mac_next;

reg [5:0] arp_request_retry_cnt_reg = 6'd0, arp_request_retry_cnt_next;
reg [35:0] arp_request_timer_reg = 36'd0, arp_request_timer_next;

assign arp_request_ready = arp_request_ready_reg;

assign arp_response_valid = arp_response_valid_reg;
assign arp_response_error = arp_response_error_reg;
assign arp_response_mac = arp_response_mac_reg;

always @* begin
    incoming_frame_ready = 1'b0;

    outgoing_frame_valid_next = outgoing_frame_valid_reg && !outgoing_frame_ready;
    outgoing_eth_dest_mac_next = outgoing_eth_dest_mac_reg;
    outgoing_arp_oper_next = outgoing_arp_oper_reg;
    outgoing_arp_tha_next = outgoing_arp_tha_reg;
    outgoing_arp_tpa_next = outgoing_arp_tpa_reg;

    cache_query_request_valid_next = 1'b0;
    cache_query_request_ip_next = cache_query_request_ip_reg;

    cache_write_request_valid_next = 1'b0;
    cache_write_request_mac_next = cache_write_request_mac_reg;
    cache_write_request_ip_next = cache_write_request_ip_reg;

    arp_request_ready_next = 1'b0;
    arp_request_ip_next = arp_request_ip_reg;
    arp_request_operation_next = arp_request_operation_reg;
    arp_request_retry_cnt_next = arp_request_retry_cnt_reg;
    arp_request_timer_next = arp_request_timer_reg;
    arp_response_valid_next = arp_response_valid_reg && !arp_response_ready;
    arp_response_error_next = 1'b0;
    arp_response_mac_next = 48'd0;

    // manage incoming frames
    incoming_frame_ready = outgoing_frame_ready;
    if (incoming_frame_valid && incoming_frame_ready) begin
        if (incoming_eth_type == 16'h0806 && incoming_arp_htype == 16'h0001 && incoming_arp_ptype == 16'h0800) begin
            // store sender addresses in cache
            cache_write_request_valid_next = 1'b1;
            cache_write_request_ip_next = incoming_arp_spa;
            cache_write_request_mac_next = incoming_arp_sha;
            if (incoming_arp_oper == ARP_OPER_ARP_REQUEST) begin
                // ARP request
                if (incoming_arp_tpa == local_ip) begin
                    // send reply frame to valid incoming request
                    outgoing_frame_valid_next = 1'b1;
                    outgoing_eth_dest_mac_next = incoming_eth_src_mac;
                    outgoing_arp_oper_next = ARP_OPER_ARP_REPLY;
                    outgoing_arp_tha_next = incoming_arp_sha;
                    outgoing_arp_tpa_next = incoming_arp_spa;
                end
            end else if (incoming_arp_oper == ARP_OPER_INARP_REQUEST) begin
                // INARP request
                if (incoming_arp_tha == local_mac) begin
                    // send reply frame to valid incoming request
                    outgoing_frame_valid_next = 1'b1;
                    outgoing_eth_dest_mac_next = incoming_eth_src_mac;
                    outgoing_arp_oper_next = ARP_OPER_INARP_REPLY;
                    outgoing_arp_tha_next = incoming_arp_sha;
                    outgoing_arp_tpa_next = incoming_arp_spa;
                end 
            end
        end
    end

    // manage ARP lookup requests
    if (arp_request_operation_reg) begin
        arp_request_ready_next = 1'b0;
        cache_query_request_valid_next = 1'b1;
        arp_request_timer_next = arp_request_timer_reg - 1;
        // if we got a response, it will go in the cache, so when the query succeds, we're done
        if (cache_query_response_valid && !cache_query_response_error) begin
            arp_request_operation_next = 1'b0;
            cache_query_request_valid_next = 1'b0;
            arp_response_valid_next = 1'b1;
            arp_response_error_next = 1'b0;
            arp_response_mac_next = cache_query_response_mac;
        end
        // timer timeout
        if (arp_request_timer_reg == 0) begin
            if (arp_request_retry_cnt_reg > 0) begin
                // have more retries
                // send ARP request frame
                outgoing_frame_valid_next = 1'b1;
                outgoing_eth_dest_mac_next = 48'hffffffffffff;
                outgoing_arp_oper_next = ARP_OPER_ARP_REQUEST;
                outgoing_arp_tha_next = 48'h000000000000;
                outgoing_arp_tpa_next = arp_request_ip_reg;
                arp_request_retry_cnt_next = arp_request_retry_cnt_reg - 1;
                if (arp_request_retry_cnt_reg > 1) begin
                    arp_request_timer_next = REQUEST_RETRY_INTERVAL;
                end else begin
                    arp_request_timer_next = REQUEST_TIMEOUT;
                end
            end else begin
                // out of retries
                arp_request_operation_next = 1'b0;
                arp_response_valid_next = 1'b1;
                arp_response_error_next = 1'b1;
                cache_query_request_valid_next = 1'b0;
            end
        end
    end else begin
        arp_request_ready_next = !arp_response_valid_next;
        if (cache_query_request_valid_reg) begin
            cache_query_request_valid_next = 1'b1;
            if (cache_query_response_valid) begin
                if (cache_query_response_error) begin
                    arp_request_operation_next = 1'b1;
                    // send ARP request frame
                    outgoing_frame_valid_next = 1'b1;
                    outgoing_eth_dest_mac_next = 48'hffffffffffff;
                    outgoing_arp_oper_next = ARP_OPER_ARP_REQUEST;
                    outgoing_arp_tha_next = 48'h000000000000;
                    outgoing_arp_tpa_next = arp_request_ip_reg;
                    arp_request_retry_cnt_next = REQUEST_RETRY_COUNT-1;
                    arp_request_timer_next = REQUEST_RETRY_INTERVAL;
                end else begin
                    cache_query_request_valid_next = 1'b0;
                    arp_response_valid_next = 1'b1;
                    arp_response_error_next = 1'b0;
                    arp_response_mac_next = cache_query_response_mac;
                end
            end
        end else if (arp_request_valid && arp_request_ready) begin
            if (arp_request_ip == 32'hffffffff) begin
                // broadcast address; use broadcast MAC address
                arp_response_valid_next = 1'b1;
                arp_response_error_next = 1'b0;
                arp_response_mac_next = 48'hffffffffffff;
            end else if (((arp_request_ip ^ gateway_ip) & subnet_mask) == 0) begin
                // within subnet
                // (no bits differ between request IP and gateway IP where subnet mask is set)
                if (~(arp_request_ip | subnet_mask) == 0) begin
                    // broadcast address; use broadcast MAC address
                    // (all bits in request IP set where subnet mask is clear)
                    arp_response_valid_next = 1'b1;
                    arp_response_error_next = 1'b0;
                    arp_response_mac_next = 48'hffffffffffff;
                end else begin
                    // unicast address; look up IP directly
                    cache_query_request_valid_next = 1'b1;
                    cache_query_request_ip_next = arp_request_ip;
                    arp_request_ip_next = arp_request_ip;
                end
            end else begin
                // outside of subnet, so look up gateway address
                cache_query_request_valid_next = 1'b1;
                cache_query_request_ip_next = gateway_ip;
                arp_request_ip_next = gateway_ip;
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        outgoing_frame_valid_reg <= 1'b0;
        cache_query_request_valid_reg <= 1'b0;
        cache_write_request_valid_reg <= 1'b0;
        arp_request_ready_reg <= 1'b0;
        arp_request_operation_reg <= 1'b0;
        arp_request_retry_cnt_reg <= 6'd0;
        arp_request_timer_reg <= 36'd0;
        arp_response_valid_reg <= 1'b0;
    end else begin
        outgoing_frame_valid_reg <= outgoing_frame_valid_next;
        cache_query_request_valid_reg <= cache_query_request_valid_next;
        cache_write_request_valid_reg <= cache_write_request_valid_next;
        arp_request_ready_reg <= arp_request_ready_next;
        arp_request_operation_reg <= arp_request_operation_next;
        arp_request_retry_cnt_reg <= arp_request_retry_cnt_next;
        arp_request_timer_reg <= arp_request_timer_next;
        arp_response_valid_reg <= arp_response_valid_next;
    end

    cache_query_request_ip_reg <= cache_query_request_ip_next;
    outgoing_eth_dest_mac_reg <= outgoing_eth_dest_mac_next;
    outgoing_arp_oper_reg <= outgoing_arp_oper_next;
    outgoing_arp_tha_reg <= outgoing_arp_tha_next;
    outgoing_arp_tpa_reg <= outgoing_arp_tpa_next;
    cache_write_request_mac_reg <= cache_write_request_mac_next;
    cache_write_request_ip_reg <= cache_write_request_ip_next;
    arp_request_ip_reg <= arp_request_ip_next;
    arp_response_error_reg <= arp_response_error_next;
    arp_response_mac_reg <= arp_response_mac_next;
end

endmodule

`resetall
