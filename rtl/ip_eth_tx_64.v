/*

Copyright (c) 2014-2016 Alex Forencich

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
 * IP ethernet frame transmitter (IP frame in, Ethernet frame out, 64 bit datapath)
 */
module ip_eth_tx_64
(
    input  wire        clk,
    input  wire        rst,

    /*
     * IP frame input
     */
    input  wire        input_ip_hdr_valid,
    output wire        input_ip_hdr_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [5:0]  input_ip_dscp,
    input  wire [1:0]  input_ip_ecn,
    input  wire [15:0] input_ip_length,
    input  wire [15:0] input_ip_identification,
    input  wire [2:0]  input_ip_flags,
    input  wire [12:0] input_ip_fragment_offset,
    input  wire [7:0]  input_ip_ttl,
    input  wire [7:0]  input_ip_protocol,
    input  wire [31:0] input_ip_source_ip,
    input  wire [31:0] input_ip_dest_ip,
    input  wire [63:0] input_ip_payload_tdata,
    input  wire [7:0]  input_ip_payload_tkeep,
    input  wire        input_ip_payload_tvalid,
    output wire        input_ip_payload_tready,
    input  wire        input_ip_payload_tlast,
    input  wire        input_ip_payload_tuser,

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
     * Status signals
     */
    output wire        busy,
    output wire        error_payload_early_termination
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

This module receives an IP frame with header fields in parallel along with the
payload in an AXI stream, combines the header with the payload, passes through
the Ethernet headers, and transmits the complete Ethernet payload on an AXI
interface.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_WRITE_HEADER = 3'd1,
    STATE_WRITE_HEADER_LAST = 3'd2,
    STATE_WRITE_PAYLOAD = 3'd3,
    STATE_WRITE_PAYLOAD_LAST = 3'd4,
    STATE_WAIT_LAST = 3'd5;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_ip_hdr;
reg store_last_word;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg flush_save;
reg transfer_in_save;

reg [31:0] hdr_sum_temp;
reg [31:0] hdr_sum_reg = 32'd0, hdr_sum_next;

reg [63:0] last_word_data_reg = 64'd0;
reg [7:0] last_word_keep_reg = 8'd0;

reg [5:0] ip_dscp_reg = 6'd0;
reg [1:0] ip_ecn_reg = 2'd0;
reg [15:0] ip_length_reg = 16'd0;
reg [15:0] ip_identification_reg = 16'd0;
reg [2:0] ip_flags_reg = 3'd0;
reg [12:0] ip_fragment_offset_reg = 13'd0;
reg [7:0] ip_ttl_reg = 8'd0;
reg [7:0] ip_protocol_reg = 8'd0;
reg [31:0] ip_source_ip_reg = 32'd0;
reg [31:0] ip_dest_ip_reg = 32'd0;

reg input_ip_hdr_ready_reg = 1'b0, input_ip_hdr_ready_next;
reg input_ip_payload_tready_reg = 1'b0, input_ip_payload_tready_next;

reg output_eth_hdr_valid_reg = 1'b0, output_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 48'd0;
reg [47:0] output_eth_src_mac_reg = 48'd0;
reg [15:0] output_eth_type_reg = 16'd0;

reg busy_reg = 1'b0;
reg error_payload_early_termination_reg = 1'b0, error_payload_early_termination_next;

reg [63:0] save_ip_payload_tdata_reg = 64'd0;
reg [7:0] save_ip_payload_tkeep_reg = 8'd0;
reg save_ip_payload_tlast_reg = 1'b0;
reg save_ip_payload_tuser_reg = 1'b0;

reg [63:0] shift_ip_payload_tdata;
reg [7:0] shift_ip_payload_tkeep;
reg shift_ip_payload_tvalid;
reg shift_ip_payload_tlast;
reg shift_ip_payload_tuser;
reg shift_ip_payload_input_tready;
reg shift_ip_payload_extra_cycle;

// internal datapath
reg [63:0] output_eth_payload_tdata_int;
reg [7:0]  output_eth_payload_tkeep_int;
reg        output_eth_payload_tvalid_int;
reg        output_eth_payload_tready_int_reg = 1'b0;
reg        output_eth_payload_tlast_int;
reg        output_eth_payload_tuser_int;
wire       output_eth_payload_tready_int_early;

assign input_ip_hdr_ready = input_ip_hdr_ready_reg;
assign input_ip_payload_tready = input_ip_payload_tready_reg;

assign output_eth_hdr_valid = output_eth_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;

assign busy = busy_reg;
assign error_payload_early_termination = error_payload_early_termination_reg;

function [3:0] keep2count;
    input [7:0] k;
    case (k)
        8'b00000000: keep2count = 4'd0;
        8'b00000001: keep2count = 4'd1;
        8'b00000011: keep2count = 4'd2;
        8'b00000111: keep2count = 4'd3;
        8'b00001111: keep2count = 4'd4;
        8'b00011111: keep2count = 4'd5;
        8'b00111111: keep2count = 4'd6;
        8'b01111111: keep2count = 4'd7;
        8'b11111111: keep2count = 4'd8;
    endcase
endfunction

function [7:0] count2keep;
    input [3:0] k;
    case (k)
        4'd0: count2keep = 8'b00000000;
        4'd1: count2keep = 8'b00000001;
        4'd2: count2keep = 8'b00000011;
        4'd3: count2keep = 8'b00000111;
        4'd4: count2keep = 8'b00001111;
        4'd5: count2keep = 8'b00011111;
        4'd6: count2keep = 8'b00111111;
        4'd7: count2keep = 8'b01111111;
        4'd8: count2keep = 8'b11111111;
    endcase
endfunction

always @* begin
    shift_ip_payload_tdata[31:0] = save_ip_payload_tdata_reg[63:32];
    shift_ip_payload_tkeep[3:0] = save_ip_payload_tkeep_reg[7:4];
    shift_ip_payload_extra_cycle = save_ip_payload_tlast_reg & (save_ip_payload_tkeep_reg[7:4] != 0);

    if (shift_ip_payload_extra_cycle) begin
        shift_ip_payload_tdata[63:32] = 32'd0;
        shift_ip_payload_tkeep[7:4] = 4'd0;
        shift_ip_payload_tvalid = 1'b1;
        shift_ip_payload_tlast = save_ip_payload_tlast_reg;
        shift_ip_payload_tuser = save_ip_payload_tuser_reg;
        shift_ip_payload_input_tready = flush_save;
    end else begin
        shift_ip_payload_tdata[63:32] = input_ip_payload_tdata[31:0];
        shift_ip_payload_tkeep[7:4] = input_ip_payload_tkeep[3:0];
        shift_ip_payload_tvalid = input_ip_payload_tvalid;
        shift_ip_payload_tlast = (input_ip_payload_tlast & (input_ip_payload_tkeep[7:4] == 0));
        shift_ip_payload_tuser = (input_ip_payload_tuser & (input_ip_payload_tkeep[7:4] == 0));
        shift_ip_payload_input_tready = ~(input_ip_payload_tlast & input_ip_payload_tvalid & transfer_in_save) & ~save_ip_payload_tlast_reg;
    end
end

always @* begin
    state_next = STATE_IDLE;

    input_ip_hdr_ready_next = 1'b0;
    input_ip_payload_tready_next = 1'b0;

    store_ip_hdr = 1'b0;

    store_last_word = 1'b0;

    flush_save = 1'b0;
    transfer_in_save = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    hdr_sum_temp = 16'd0;
    hdr_sum_next = hdr_sum_reg;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;

    error_payload_early_termination_next = 1'b0;

    output_eth_payload_tdata_int = 1'b0;
    output_eth_payload_tkeep_int = 1'b0;
    output_eth_payload_tvalid_int = 1'b0;
    output_eth_payload_tlast_int = 1'b0;
    output_eth_payload_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 16'd0;
            flush_save = 1'b1;
            input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;

            if (input_ip_hdr_ready & input_ip_hdr_valid) begin
                store_ip_hdr = 1'b1;
                hdr_sum_next = {4'd4, 4'd5, input_ip_dscp, input_ip_ecn} +
                               input_ip_length +
                               input_ip_identification +
                               {input_ip_flags, input_ip_fragment_offset} +
                               {input_ip_ttl, input_ip_protocol} +
                               input_ip_source_ip[31:16] +
                               input_ip_source_ip[15: 0] +
                               input_ip_dest_ip[31:16] +
                               input_ip_dest_ip[15: 0];
                input_ip_hdr_ready_next = 1'b0;
                output_eth_hdr_valid_next = 1'b1;
                if (output_eth_payload_tready_int_reg) begin
                    output_eth_payload_tvalid_int = 1'b1;
                    output_eth_payload_tdata_int[ 7: 0] = {4'd4, 4'd5}; // ip_version, ip_ihl
                    output_eth_payload_tdata_int[15: 8] = {input_ip_dscp, input_ip_ecn};
                    output_eth_payload_tdata_int[23:16] = input_ip_length[15: 8];
                    output_eth_payload_tdata_int[31:24] = input_ip_length[ 7: 0];
                    output_eth_payload_tdata_int[39:32] = input_ip_identification[15: 8];
                    output_eth_payload_tdata_int[47:40] = input_ip_identification[ 7: 0];
                    output_eth_payload_tdata_int[55:48] = {input_ip_flags, input_ip_fragment_offset[12: 8]};
                    output_eth_payload_tdata_int[63:56] = input_ip_fragment_offset[ 7: 0];
                    output_eth_payload_tkeep_int = 8'hff;
                    frame_ptr_next = 16'd8;
                end
                state_next = STATE_WRITE_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // write header
            if (output_eth_payload_tready_int_reg) begin
                frame_ptr_next = frame_ptr_reg + 16'd8;
                output_eth_payload_tvalid_int = 1'b1;
                state_next = STATE_WRITE_HEADER;
                case (frame_ptr_reg)
                    8'h00: begin
                        output_eth_payload_tdata_int[ 7: 0] = {4'd4, 4'd5}; // ip_version, ip_ihl
                        output_eth_payload_tdata_int[15: 8] = {input_ip_dscp, input_ip_ecn};
                        output_eth_payload_tdata_int[23:16] = input_ip_length[15: 8];
                        output_eth_payload_tdata_int[31:24] = input_ip_length[ 7: 0];
                        output_eth_payload_tdata_int[39:32] = input_ip_identification[15: 8];
                        output_eth_payload_tdata_int[47:40] = input_ip_identification[ 7: 0];
                        output_eth_payload_tdata_int[55:48] = {input_ip_flags, input_ip_fragment_offset[12: 8]};
                        output_eth_payload_tdata_int[63:56] = input_ip_fragment_offset[ 7: 0];
                        output_eth_payload_tkeep_int = 8'hff;
                    end
                    8'h08: begin
                        hdr_sum_temp = hdr_sum_reg[15:0] + hdr_sum_reg[31:16];
                        hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                        output_eth_payload_tdata_int[ 7: 0] = ip_ttl_reg;
                        output_eth_payload_tdata_int[15: 8] = ip_protocol_reg;
                        output_eth_payload_tdata_int[23:16] = ~hdr_sum_temp[15: 8];
                        output_eth_payload_tdata_int[31:24] = ~hdr_sum_temp[ 7: 0];
                        output_eth_payload_tdata_int[39:32] = ip_source_ip_reg[31:24];
                        output_eth_payload_tdata_int[47:40] = ip_source_ip_reg[23:16];
                        output_eth_payload_tdata_int[55:48] = ip_source_ip_reg[15: 8];
                        output_eth_payload_tdata_int[63:56] = ip_source_ip_reg[ 7: 0];
                        output_eth_payload_tkeep_int = 8'hff;
                        input_ip_payload_tready_next = output_eth_payload_tready_int_early;
                        state_next = STATE_WRITE_HEADER_LAST;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // last header word requires first payload word; process accordingly
            input_ip_payload_tready_next = output_eth_payload_tready_int_early & shift_ip_payload_input_tready;

            if (input_ip_payload_tready & input_ip_payload_tvalid) begin
                output_eth_payload_tvalid_int = 1'b1;
                transfer_in_save = 1'b1;

                output_eth_payload_tdata_int[ 7: 0] = ip_dest_ip_reg[31:24];
                output_eth_payload_tdata_int[15: 8] = ip_dest_ip_reg[23:16];
                output_eth_payload_tdata_int[23:16] = ip_dest_ip_reg[15: 8];
                output_eth_payload_tdata_int[31:24] = ip_dest_ip_reg[ 7: 0];
                output_eth_payload_tdata_int[39:32] = shift_ip_payload_tdata[39:32];
                output_eth_payload_tdata_int[47:40] = shift_ip_payload_tdata[47:40];
                output_eth_payload_tdata_int[55:48] = shift_ip_payload_tdata[55:48];
                output_eth_payload_tdata_int[63:56] = shift_ip_payload_tdata[63:56];
                output_eth_payload_tkeep_int = {shift_ip_payload_tkeep[7:4], 4'hF};
                output_eth_payload_tlast_int = shift_ip_payload_tlast;
                output_eth_payload_tuser_int = shift_ip_payload_tuser;
                frame_ptr_next = frame_ptr_reg+keep2count(output_eth_payload_tkeep_int);

                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    output_eth_payload_tkeep_int = count2keep(ip_length_reg - frame_ptr_reg);
                    if (shift_ip_payload_tlast) begin
                        input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;
                        input_ip_payload_tready_next = 1'b0;
                        state_next = STATE_IDLE;
                    end else begin
                        store_last_word = 1'b1;
                        input_ip_payload_tready_next = shift_ip_payload_input_tready;
                        output_eth_payload_tvalid_int = 1'b0;
                        state_next = STATE_WRITE_PAYLOAD_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        error_payload_early_termination_next = 1'b1;
                        input_ip_payload_tready_next = shift_ip_payload_input_tready;
                        output_eth_payload_tuser_int = 1'b1;
                        state_next = STATE_WAIT_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD;
                    end
                end
            end else begin
                state_next = STATE_WRITE_HEADER_LAST;
            end
        end
        STATE_WRITE_PAYLOAD: begin
            // write payload
            input_ip_payload_tready_next = output_eth_payload_tready_int_early & shift_ip_payload_input_tready;

            output_eth_payload_tdata_int = shift_ip_payload_tdata;
            output_eth_payload_tkeep_int = shift_ip_payload_tkeep;
            output_eth_payload_tvalid_int = shift_ip_payload_tvalid;
            output_eth_payload_tlast_int = shift_ip_payload_tlast;
            output_eth_payload_tuser_int = shift_ip_payload_tuser;

            if (output_eth_payload_tready_int_reg & shift_ip_payload_tvalid) begin
                // word transfer through
                frame_ptr_next = frame_ptr_reg+keep2count(shift_ip_payload_tkeep);
                transfer_in_save = 1'b1;
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    output_eth_payload_tkeep_int = count2keep(ip_length_reg - frame_ptr_reg);
                    if (shift_ip_payload_tlast) begin
                        input_ip_payload_tready_next = 1'b0;
                        flush_save = 1'b1;
                        input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;
                        state_next = STATE_IDLE;
                    end else begin
                        store_last_word = 1'b1;
                        output_eth_payload_tvalid_int = 1'b0;
                        state_next = STATE_WRITE_PAYLOAD_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        error_payload_early_termination_next = 1'b1;
                        output_eth_payload_tuser_int = 1'b1;
                        input_ip_payload_tready_next = 1'b0;
                        flush_save = 1'b1;
                        input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD;
                    end
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD;
            end
        end
        STATE_WRITE_PAYLOAD_LAST: begin
            // read and discard until end of frame
            input_ip_payload_tready_next = output_eth_payload_tready_int_early & shift_ip_payload_input_tready;

            output_eth_payload_tdata_int = last_word_data_reg;
            output_eth_payload_tkeep_int = last_word_keep_reg;
            output_eth_payload_tvalid_int = shift_ip_payload_tvalid & shift_ip_payload_tlast;
            output_eth_payload_tlast_int = shift_ip_payload_tlast;
            output_eth_payload_tuser_int = shift_ip_payload_tuser;

            if (output_eth_payload_tready_int_reg & shift_ip_payload_tvalid) begin
                transfer_in_save = 1'b1;
                if (shift_ip_payload_tlast) begin
                    input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;
                    input_ip_payload_tready_next = 1'b0;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_LAST;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_LAST;
            end
        end
        STATE_WAIT_LAST: begin
            // read and discard until end of frame
            input_ip_payload_tready_next = shift_ip_payload_input_tready;

            if (shift_ip_payload_tvalid) begin
                transfer_in_save = 1'b1;
                if (shift_ip_payload_tlast) begin
                    input_ip_hdr_ready_next = ~output_eth_hdr_valid_reg;
                    input_ip_payload_tready_next = 1'b0;
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
        hdr_sum_reg <= 16'd0;
        input_ip_hdr_ready_reg <= 1'b0;
        input_ip_payload_tready_reg <= 1'b0;
        output_eth_hdr_valid_reg <= 1'b0;
        save_ip_payload_tlast_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_payload_early_termination_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        hdr_sum_reg <= hdr_sum_next;

        input_ip_hdr_ready_reg <= input_ip_hdr_ready_next;
        input_ip_payload_tready_reg <= input_ip_payload_tready_next;

        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;

        busy_reg <= state_next != STATE_IDLE;

        error_payload_early_termination_reg <= error_payload_early_termination_next;

        if (flush_save) begin
            save_ip_payload_tlast_reg <= 1'b0;
        end else if (transfer_in_save) begin
            save_ip_payload_tlast_reg <= input_ip_payload_tlast;
        end
    end

    // datapath
    if (store_ip_hdr) begin
        output_eth_dest_mac_reg <= input_eth_dest_mac;
        output_eth_src_mac_reg <= input_eth_src_mac;
        output_eth_type_reg <= input_eth_type;
        ip_dscp_reg <= input_ip_dscp;
        ip_ecn_reg <= input_ip_ecn;
        ip_length_reg <= input_ip_length;
        ip_identification_reg <= input_ip_identification;
        ip_flags_reg <= input_ip_flags;
        ip_fragment_offset_reg <= input_ip_fragment_offset;
        ip_ttl_reg <= input_ip_ttl;
        ip_protocol_reg <= input_ip_protocol;
        ip_source_ip_reg <= input_ip_source_ip;
        ip_dest_ip_reg <= input_ip_dest_ip;
    end

    if (store_last_word) begin
        last_word_data_reg <= output_eth_payload_tdata_int;
        last_word_keep_reg <= output_eth_payload_tkeep_int;
    end

    if (transfer_in_save) begin
        save_ip_payload_tdata_reg <= input_ip_payload_tdata;
        save_ip_payload_tkeep_reg <= input_ip_payload_tkeep;
        save_ip_payload_tuser_reg <= input_ip_payload_tuser;
    end
end

// output datapath logic
reg [64:0] output_eth_payload_tdata_reg = 64'd0;
reg [7:0]  output_eth_payload_tkeep_reg = 8'd0;
reg        output_eth_payload_tvalid_reg = 1'b0, output_eth_payload_tvalid_next;
reg        output_eth_payload_tlast_reg = 1'b0;
reg        output_eth_payload_tuser_reg = 1'b0;

reg [64:0] temp_eth_payload_tdata_reg = 64'd0;
reg [7:0]  temp_eth_payload_tkeep_reg = 8'd0;
reg        temp_eth_payload_tvalid_reg = 1'b0, temp_eth_payload_tvalid_next;
reg        temp_eth_payload_tlast_reg = 1'b0;
reg        temp_eth_payload_tuser_reg = 1'b0;

// datapath control
reg store_eth_payload_int_to_output;
reg store_eth_payload_int_to_temp;
reg store_eth_payload_temp_to_output;

assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_eth_payload_tvalid = output_eth_payload_tvalid_reg;
assign output_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_eth_payload_tuser = output_eth_payload_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_eth_payload_tready_int_early = output_eth_payload_tready | (~temp_eth_payload_tvalid_reg & (~output_eth_payload_tvalid_reg | ~output_eth_payload_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_eth_payload_tvalid_next = output_eth_payload_tvalid_reg;
    temp_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg;

    store_eth_payload_int_to_output = 1'b0;
    store_eth_payload_int_to_temp = 1'b0;
    store_eth_payload_temp_to_output = 1'b0;
    
    if (output_eth_payload_tready_int_reg) begin
        // input is ready
        if (output_eth_payload_tready | ~output_eth_payload_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_eth_payload_tvalid_next = output_eth_payload_tvalid_int;
            store_eth_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_eth_payload_tvalid_next = output_eth_payload_tvalid_int;
            store_eth_payload_int_to_temp = 1'b1;
        end
    end else if (output_eth_payload_tready) begin
        // input is not ready, but output is ready
        output_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg;
        temp_eth_payload_tvalid_next = 1'b0;
        store_eth_payload_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_eth_payload_tvalid_reg <= 1'b0;
        output_eth_payload_tready_int_reg <= 1'b0;
        temp_eth_payload_tvalid_reg <= 1'b0;
    end else begin
        output_eth_payload_tvalid_reg <= output_eth_payload_tvalid_next;
        output_eth_payload_tready_int_reg <= output_eth_payload_tready_int_early;
        temp_eth_payload_tvalid_reg <= temp_eth_payload_tvalid_next;
    end

    // datapath
    if (store_eth_payload_int_to_output) begin
        output_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        output_eth_payload_tkeep_reg <= output_eth_payload_tkeep_int;
        output_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        output_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end else if (store_eth_payload_temp_to_output) begin
        output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
        output_eth_payload_tkeep_reg <= temp_eth_payload_tkeep_reg;
        output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
        output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
    end

    if (store_eth_payload_int_to_temp) begin
        temp_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        temp_eth_payload_tkeep_reg <= output_eth_payload_tkeep_int;
        temp_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        temp_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end
end

endmodule
