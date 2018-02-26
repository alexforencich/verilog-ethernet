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
 * ARP block for IPv4, ethernet frame interface (64 bit datapath)
 */
module arp_64 #(
    parameter CACHE_ADDR_WIDTH = 2,
    parameter REQUEST_RETRY_COUNT = 4,
    parameter REQUEST_RETRY_INTERVAL = 125000000*2,
    parameter REQUEST_TIMEOUT = 125000000*30
)
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
    input  wire [63:0] input_eth_payload_tdata,
    input  wire [7:0]  input_eth_payload_tkeep,
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
    output wire [63:0] output_eth_payload_tdata,
    output wire [7:0]  output_eth_payload_tkeep,
    output wire        output_eth_payload_tvalid,
    input  wire        output_eth_payload_tready,
    output wire        output_eth_payload_tlast,
    output wire        output_eth_payload_tuser,

    /*
     * ARP requests
     */
    input  wire        arp_request_valid,
    input  wire [31:0] arp_request_ip,
    output wire        arp_response_valid,
    output wire        arp_response_error,
    output wire [47:0] arp_response_mac,

    /*
     * Configuration
     */
    input  wire [47:0] local_mac,
    input  wire [31:0] local_ip,
    input  wire [31:0] gateway_ip,
    input  wire [31:0] subnet_mask,
    input  wire        clear_cache
);

localparam [15:0]
    ARP_OPER_ARP_REQUEST = 16'h0001,
    ARP_OPER_ARP_REPLY = 16'h0002,
    ARP_OPER_INARP_REQUEST = 16'h0008,
    ARP_OPER_INARP_REPLY = 16'h0009;

wire incoming_frame_valid;
wire incoming_frame_ready;
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

reg outgoing_frame_valid_reg = 1'b0, outgoing_frame_valid_next;
wire outgoing_frame_ready;
reg [47:0] outgoing_eth_dest_mac_reg = 48'd0, outgoing_eth_dest_mac_next;
reg [15:0] outgoing_arp_oper_reg = 16'd0, outgoing_arp_oper_next;
reg [47:0] outgoing_arp_tha_reg = 48'd0, outgoing_arp_tha_next;
reg [31:0] outgoing_arp_tpa_reg = 32'd0, outgoing_arp_tpa_next;

// drop frame
reg drop_incoming_frame_reg = 1'b0, drop_incoming_frame_next;

// wait on incoming frames until we can reply
assign incoming_frame_ready = outgoing_frame_ready | drop_incoming_frame_reg;

/*
 * ARP frame processing
 */
arp_eth_rx_64
arp_eth_rx_inst (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(input_eth_hdr_valid),
    .input_eth_hdr_ready(input_eth_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_eth_payload_tdata(input_eth_payload_tdata),
    .input_eth_payload_tkeep(input_eth_payload_tkeep),
    .input_eth_payload_tvalid(input_eth_payload_tvalid),
    .input_eth_payload_tready(input_eth_payload_tready),
    .input_eth_payload_tlast(input_eth_payload_tlast),
    .input_eth_payload_tuser(input_eth_payload_tuser),
    // ARP frame output
    .output_frame_valid(incoming_frame_valid),
    .output_frame_ready(incoming_frame_ready),
    .output_eth_dest_mac(incoming_eth_dest_mac),
    .output_eth_src_mac(incoming_eth_src_mac),
    .output_eth_type(incoming_eth_type),
    .output_arp_htype(incoming_arp_htype),
    .output_arp_ptype(incoming_arp_ptype),
    .output_arp_hlen(incoming_arp_hlen),
    .output_arp_plen(incoming_arp_plen),
    .output_arp_oper(incoming_arp_oper),
    .output_arp_sha(incoming_arp_sha),
    .output_arp_spa(incoming_arp_spa),
    .output_arp_tha(incoming_arp_tha),
    .output_arp_tpa(incoming_arp_tpa),
    // Status signals
    .busy(),
    .error_header_early_termination(),
    .error_invalid_header()
);

arp_eth_tx_64
arp_eth_tx_inst (
    .clk(clk),
    .rst(rst),
    // ARP frame input
    .input_frame_valid(outgoing_frame_valid_reg),
    .input_frame_ready(outgoing_frame_ready),
    .input_eth_dest_mac(outgoing_eth_dest_mac_reg),
    .input_eth_src_mac(local_mac),
    .input_eth_type(16'h0806),
    .input_arp_htype(16'h0001),
    .input_arp_ptype(16'h0800),
    .input_arp_oper(outgoing_arp_oper_reg),
    .input_arp_sha(local_mac),
    .input_arp_spa(local_ip),
    .input_arp_tha(outgoing_arp_tha_reg),
    .input_arp_tpa(outgoing_arp_tpa_reg),
    // Ethernet frame output
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tkeep(output_eth_payload_tkeep),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
    // Status signals
    .busy()
);

wire incoming_eth_type_valid = (incoming_eth_type == 16'h0806);
wire incoming_arp_htype_valid = (incoming_arp_htype == 16'h0001);
wire incoming_arp_ptype_valid = (incoming_arp_ptype == 16'h0800);

wire incoming_arp_oper_arp_request = (incoming_arp_oper == ARP_OPER_ARP_REQUEST);
wire incoming_arp_oper_arp_reply = (incoming_arp_oper == ARP_OPER_ARP_REPLY);
wire incoming_arp_oper_inarp_request = (incoming_arp_oper == ARP_OPER_INARP_REQUEST);
wire incoming_arp_oper_inarp_reply = (incoming_arp_oper == ARP_OPER_INARP_REPLY);

wire filtered_incoming_frame_valid = incoming_frame_valid &
                                     incoming_eth_type_valid &
                                     incoming_arp_htype_valid &
                                     incoming_arp_ptype_valid;

wire filtered_incoming_arp_oper_arp_request = filtered_incoming_frame_valid & incoming_arp_oper_arp_request;
wire filtered_incoming_arp_oper_arp_reply = filtered_incoming_frame_valid & incoming_arp_oper_arp_reply;
wire filtered_incoming_arp_oper_inarp_request = filtered_incoming_frame_valid & incoming_arp_oper_inarp_request;
wire filtered_incoming_arp_oper_inarp_reply = filtered_incoming_frame_valid & incoming_arp_oper_inarp_reply;

wire cache_query_request_valid;
wire [31:0] cache_query_request_ip;
wire cache_query_response_valid;
wire cache_query_response_error;
wire [47:0] cache_query_response_mac;

reg cache_write_request_valid_reg = 1'b0, cache_write_request_valid_next;
reg [31:0] cache_write_request_ip_reg = 32'd0, cache_write_request_ip_next;
reg [47:0] cache_write_request_mac_reg = 48'd0, cache_write_request_mac_next;
wire cache_write_in_progress;
wire cache_write_complete;

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
    .query_request_valid(cache_query_request_valid),
    .query_request_ip(cache_query_request_ip),
    .query_response_valid(cache_query_response_valid),
    .query_response_error(cache_query_response_error),
    .query_response_mac(cache_query_response_mac),
    // Write cache
    .write_request_valid(cache_write_request_valid_reg),
    .write_request_ip(cache_write_request_ip_reg),
    .write_request_mac(cache_write_request_mac_reg),
    .write_in_progress(cache_write_in_progress),
    .write_complete(cache_write_complete),
    // Configuration
    .clear_cache(clear_cache)
);

reg arp_request_operation_reg = 1'b0, arp_request_operation_next;

reg arp_request_valid_reg = 1'b0, arp_request_valid_next;
reg [31:0] arp_request_ip_reg = 32'd0, arp_request_ip_next;

reg arp_response_error_reg = 1'b0, arp_response_error_next;
reg arp_response_broadcast_reg = 1'b0, arp_response_broadcast_next;

reg [5:0] arp_request_retry_cnt_reg = 6'd0, arp_request_retry_cnt_next;
reg [35:0] arp_request_timer_reg = 36'd0, arp_request_timer_next;

assign cache_query_request_valid = ~arp_request_operation_reg ? arp_request_valid_reg : 1'b1;
assign cache_query_request_ip = arp_request_ip_reg;

assign arp_response_valid = arp_response_error_reg | (cache_query_response_valid & ~cache_query_response_error & ~arp_request_operation_reg) | arp_response_broadcast_reg;
assign arp_response_error = arp_response_error_reg;
assign arp_response_mac = arp_response_broadcast_reg ? 48'hffffffffffff : cache_query_response_mac;

always @* begin
    outgoing_frame_valid_next = outgoing_frame_valid_reg & ~outgoing_frame_ready;
    outgoing_eth_dest_mac_next = outgoing_eth_dest_mac_reg;
    outgoing_arp_oper_next = outgoing_arp_oper_reg;
    outgoing_arp_tha_next = outgoing_arp_tha_reg;
    outgoing_arp_tpa_next = outgoing_arp_tpa_reg;

    cache_write_request_valid_next = 1'b0;
    cache_write_request_mac_next = 48'd0;
    cache_write_request_ip_next = 32'd0;

    arp_request_valid_next = 1'b0;
    arp_request_ip_next = arp_request_ip_reg;
    arp_request_operation_next = arp_request_operation_reg;
    arp_request_retry_cnt_next = arp_request_retry_cnt_reg;
    arp_request_timer_next = arp_request_timer_reg;
    arp_response_error_next = 1'b0;
    arp_response_broadcast_next = 1'b0;
    
    drop_incoming_frame_next = 1'b0;

    // manage incoming frames
    if (filtered_incoming_frame_valid & ~(outgoing_frame_valid_reg & ~outgoing_frame_ready)) begin
        // store sender addresses in cache
        cache_write_request_valid_next = 1'b1;
        cache_write_request_ip_next = incoming_arp_spa;
        cache_write_request_mac_next = incoming_arp_sha;
        if (incoming_arp_oper_arp_request) begin
            if (incoming_arp_tpa == local_ip) begin
                // send reply frame to valid incoming request
                outgoing_frame_valid_next = 1'b1;
                outgoing_eth_dest_mac_next = incoming_eth_src_mac;
                outgoing_arp_oper_next = ARP_OPER_ARP_REPLY;
                outgoing_arp_tha_next = incoming_arp_sha;
                outgoing_arp_tpa_next = incoming_arp_spa;
            end else begin
                // does not match -> drop it
                drop_incoming_frame_next = 1'b1;
            end
        end else if (incoming_arp_oper_inarp_request) begin
            if (incoming_arp_tha == local_mac) begin
                // send reply frame to valid incoming request
                outgoing_frame_valid_next = 1'b1;
                outgoing_eth_dest_mac_next = incoming_eth_src_mac;
                outgoing_arp_oper_next = ARP_OPER_INARP_REPLY;
                outgoing_arp_tha_next = incoming_arp_sha;
                outgoing_arp_tpa_next = incoming_arp_spa;
            end else begin
                // does not match -> drop it
                drop_incoming_frame_next = 1'b1;
            end
        end else begin
            // does not match -> drop it
            drop_incoming_frame_next = 1'b1;
        end
    end else if (incoming_frame_valid & ~filtered_incoming_frame_valid) begin
        // incoming invalid frame -> drop it
        drop_incoming_frame_next = 1'b1;
    end

    // manage ARP lookup requests
    if (~arp_request_operation_reg & ~arp_response_valid) begin
        if (arp_request_valid) begin
            if (~(arp_request_ip | subnet_mask) == 0) begin
                // broadcast address
                // (all bits in request IP set where subnet mask is clear)
                arp_request_valid_next = 1'b0;
                arp_response_broadcast_next = 1'b1;
            end else if (((arp_request_ip ^ gateway_ip) & subnet_mask) == 0) begin
                // within subnet, look up IP directly
                // (no bits differ between request IP and gateway IP where subnet mask is set)
                arp_request_valid_next = 1'b1;
                arp_request_ip_next = arp_request_ip;
            end else begin
                // outside of subnet, so look up gateway address
                arp_request_valid_next = 1'b1;
                arp_request_ip_next = gateway_ip;
            end
        end
        if (cache_query_response_error & ~arp_response_error) begin
            arp_request_operation_next = 1'b1;
            // send ARP request frame
            outgoing_frame_valid_next = 1'b1;
            outgoing_eth_dest_mac_next = 48'hFF_FF_FF_FF_FF_FF;
            outgoing_arp_oper_next = ARP_OPER_ARP_REQUEST;
            outgoing_arp_tha_next = 48'h00_00_00_00_00_00;
            outgoing_arp_tpa_next = arp_request_ip_reg;
            arp_request_retry_cnt_next = REQUEST_RETRY_COUNT-1;
            arp_request_timer_next = REQUEST_RETRY_INTERVAL;
        end
    end else if (arp_request_operation_reg) begin
        arp_request_timer_next = arp_request_timer_reg - 1;
        // if we got a response, it will go in the cache, so when the query succeds, we're done
        if (cache_query_response_valid  & ~cache_query_response_error) begin
            arp_request_operation_next = 1'b0;
        end
        // timer timeout
        if (arp_request_timer_reg == 0) begin
            if (arp_request_retry_cnt_reg > 0) begin
                // have more retries
                // send ARP request frame
                outgoing_frame_valid_next = 1'b1;
                outgoing_eth_dest_mac_next = 48'hFF_FF_FF_FF_FF_FF;
                outgoing_arp_oper_next = ARP_OPER_ARP_REQUEST;
                outgoing_arp_tha_next = 48'h00_00_00_00_00_00;
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
                arp_response_error_next = 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        outgoing_frame_valid_reg <= 1'b0;
        cache_write_request_valid_reg <= 1'b0;
        arp_request_valid_reg <= 1'b0;
        arp_request_operation_reg <= 1'b0;
        arp_request_retry_cnt_reg <= 6'd0;
        arp_request_timer_reg <= 36'd0;
        arp_response_error_reg <= 1'b0;
        arp_response_broadcast_reg <= 1'b0;
        drop_incoming_frame_reg <= 1'b0;
    end else begin
        outgoing_frame_valid_reg <= outgoing_frame_valid_next;
        cache_write_request_valid_reg <= cache_write_request_valid_next;
        arp_request_valid_reg <= arp_request_valid_next;
        arp_request_operation_reg <= arp_request_operation_next;
        arp_request_retry_cnt_reg <= arp_request_retry_cnt_next;
        arp_request_timer_reg <= arp_request_timer_next;
        arp_response_error_reg <= arp_response_error_next;
        arp_response_broadcast_reg <= arp_response_broadcast_next;
        drop_incoming_frame_reg <= drop_incoming_frame_next;
    end

    outgoing_eth_dest_mac_reg <= outgoing_eth_dest_mac_next;
    outgoing_arp_oper_reg <= outgoing_arp_oper_next;
    outgoing_arp_tha_reg <= outgoing_arp_tha_next;
    outgoing_arp_tpa_reg <= outgoing_arp_tpa_next;
    cache_write_request_mac_reg <= cache_write_request_mac_next;
    cache_write_request_ip_reg <= cache_write_request_ip_next;
    arp_request_ip_reg <= arp_request_ip_next;
end

endmodule
