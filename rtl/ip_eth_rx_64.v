/*

Copyright (c) 2014 Alex Forencich

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
 * IP ethernet frame receiver (Ethernet frame in, IP frame out, 64 bit datapath)
 */
module ip_eth_rx_64
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
     * IP frame output
     */
    output wire        output_ip_hdr_valid,
    input  wire        output_ip_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
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
    output wire [63:0] output_ip_payload_tdata,
    output wire [7:0]  output_ip_payload_tkeep,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,

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

This module receives an Ethernet frame with decoded fields and decodes
the AXI packet format.  If the Ethertype does not match, the packet is
discarded.

*/

localparam [3:0]
    STATE_IDLE = 4'd0,
    STATE_READ_HEADER = 4'd1,
    STATE_READ_PAYLOAD_IDLE = 4'd2,
    STATE_READ_PAYLOAD_TRANSFER = 4'd3,
    STATE_READ_PAYLOAD_TRANSFER_WAIT = 4'd4,
    STATE_READ_PAYLOAD_TRANSFER_LAST = 4'd5,
    STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST = 4'd6,
    STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST_WAIT = 4'd7,
    STATE_WAIT_LAST = 4'd8;

reg [3:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_hdr;
reg store_hdr_word_0;
reg store_hdr_word_1;
reg store_hdr_word_2;

reg flush_save;
reg transfer_in_save;
reg transfer_save_out;
reg transfer_in_out;
reg transfer_in_temp;
reg transfer_temp_out;

reg assert_tlast;
reg assert_tuser;
reg [7:0] tkeep_mask;

reg [15:0] frame_ptr_reg = 0, frame_ptr_next;

reg [31:0] hdr_sum_temp;
reg [15:0] hdr_sum_reg = 0, hdr_sum_next;
reg [15:0] hdr_sum_temp_a_reg = 0, hdr_sum_temp_a_next;
reg [15:0] hdr_sum_temp_b_reg = 0, hdr_sum_temp_b_next;

reg input_eth_hdr_ready_reg = 0;
reg input_eth_payload_tready_reg = 0;

reg output_ip_hdr_valid_reg = 0, output_ip_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 0;
reg [47:0] output_eth_src_mac_reg = 0;
reg [15:0] output_eth_type_reg = 0;
reg [3:0] output_ip_version_reg = 0;
reg [3:0] output_ip_ihl_reg = 0;
reg [5:0] output_ip_dscp_reg = 0;
reg [1:0] output_ip_ecn_reg = 0;
reg [15:0] output_ip_length_reg = 0;
reg [15:0] output_ip_identification_reg = 0;
reg [2:0] output_ip_flags_reg = 0;
reg [12:0] output_ip_fragment_offset_reg = 0;
reg [7:0] output_ip_ttl_reg = 0;
reg [7:0] output_ip_protocol_reg = 0;
reg [15:0] output_ip_header_checksum_reg = 0;
reg [31:0] output_ip_source_ip_reg = 0;
reg [31:0] output_ip_dest_ip_reg = 0;
reg [63:0] output_ip_payload_tdata_reg = 0;
reg [7:0] output_ip_payload_tkeep_reg = 0;
reg output_ip_payload_tvalid_reg = 0;
reg output_ip_payload_tlast_reg = 0;
reg output_ip_payload_tuser_reg = 0;

reg busy_reg = 0;
reg error_header_early_termination_reg = 0, error_header_early_termination_next;
reg error_payload_early_termination_reg = 0, error_payload_early_termination_next;
reg error_invalid_header_reg = 0, error_invalid_header_next;
reg error_invalid_checksum_reg = 0, error_invalid_checksum_next;

reg [63:0] temp_ip_payload_tdata_reg = 0;
reg [7:0] temp_ip_payload_tkeep_reg = 0;
reg temp_ip_payload_tlast_reg = 0;
reg temp_ip_payload_tuser_reg = 0;

reg [63:0] save_eth_payload_tdata_reg = 0;
reg [7:0] save_eth_payload_tkeep_reg = 0;
reg save_eth_payload_tlast_reg = 0;
reg save_eth_payload_tuser_reg = 0;

reg [63:0] shift_eth_payload_tdata;
reg [7:0] shift_eth_payload_tkeep;
reg shift_eth_payload_tvalid;
reg shift_eth_payload_tlast;
reg shift_eth_payload_tuser;
reg shift_eth_payload_input_tready;
reg shift_eth_payload_extra_cycle;

assign input_eth_hdr_ready = input_eth_hdr_ready_reg;
assign input_eth_payload_tready = input_eth_payload_tready_reg;

assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;
assign output_ip_hdr_valid = output_ip_hdr_valid_reg;
assign output_ip_version = output_ip_version_reg;
assign output_ip_ihl = output_ip_ihl_reg;
assign output_ip_dscp = output_ip_dscp_reg;
assign output_ip_ecn = output_ip_ecn_reg;
assign output_ip_length = output_ip_length_reg;
assign output_ip_identification = output_ip_identification_reg;
assign output_ip_flags = output_ip_flags_reg;
assign output_ip_fragment_offset = output_ip_fragment_offset_reg;
assign output_ip_ttl = output_ip_ttl_reg;
assign output_ip_protocol = output_ip_protocol_reg;
assign output_ip_header_checksum = output_ip_header_checksum_reg;
assign output_ip_source_ip = output_ip_source_ip_reg;
assign output_ip_dest_ip = output_ip_dest_ip_reg;
assign output_ip_payload_tdata = output_ip_payload_tdata_reg;
assign output_ip_payload_tkeep = output_ip_payload_tkeep_reg;
assign output_ip_payload_tvalid = output_ip_payload_tvalid_reg;
assign output_ip_payload_tlast = output_ip_payload_tlast_reg;
assign output_ip_payload_tuser = output_ip_payload_tuser_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;
assign error_payload_early_termination = error_payload_early_termination_reg;
assign error_invalid_header = error_invalid_header_reg;
assign error_invalid_checksum = error_invalid_checksum_reg;

function [3:0] keep2count;
    input [7:0] k;
    case (k)
        8'b00000000: keep2count = 0;
        8'b00000001: keep2count = 1;
        8'b00000011: keep2count = 2;
        8'b00000111: keep2count = 3;
        8'b00001111: keep2count = 4;
        8'b00011111: keep2count = 5;
        8'b00111111: keep2count = 6;
        8'b01111111: keep2count = 7;
        8'b11111111: keep2count = 8;
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
    shift_eth_payload_tdata[31:0] = save_eth_payload_tdata_reg[63:32];
    shift_eth_payload_tkeep[3:0] = save_eth_payload_tkeep_reg[7:4];
    shift_eth_payload_extra_cycle = save_eth_payload_tlast_reg & (save_eth_payload_tkeep_reg[7:4] != 0);

    if (shift_eth_payload_extra_cycle) begin
        shift_eth_payload_tdata[63:32] = 0;
        shift_eth_payload_tkeep[7:4] = 0;
        shift_eth_payload_tvalid = 1;
        shift_eth_payload_tlast = save_eth_payload_tlast_reg;
        shift_eth_payload_tuser = save_eth_payload_tuser_reg;
        shift_eth_payload_input_tready = flush_save;
    end else begin
        shift_eth_payload_tdata[63:32] = input_eth_payload_tdata[31:0];
        shift_eth_payload_tkeep[7:4] = input_eth_payload_tkeep[3:0];
        shift_eth_payload_tvalid = input_eth_payload_tvalid;
        shift_eth_payload_tlast = (input_eth_payload_tlast & (input_eth_payload_tkeep[7:4] == 0));
        shift_eth_payload_tuser = (input_eth_payload_tuser & (input_eth_payload_tkeep[7:4] == 0));
        shift_eth_payload_input_tready = ~(input_eth_payload_tlast & input_eth_payload_tvalid & transfer_in_save);
    end
end

always @* begin
    state_next = 2'bz;

    flush_save = 0;
    transfer_in_save = 0;
    transfer_save_out = 0;
    transfer_in_out = 0;
    transfer_in_temp = 0;
    transfer_temp_out = 0;

    assert_tlast = 0;
    assert_tuser = 0;
    tkeep_mask = 8'hff;

    store_eth_hdr = 0;
    store_hdr_word_0 = 0;
    store_hdr_word_1 = 0;
    store_hdr_word_2 = 0;

    frame_ptr_next = frame_ptr_reg;

    hdr_sum_temp = 0;
    hdr_sum_next = hdr_sum_reg;
    hdr_sum_temp_a_next = hdr_sum_temp_a_reg;
    hdr_sum_temp_b_next = hdr_sum_temp_b_reg;

    output_ip_hdr_valid_next = output_ip_hdr_valid_reg & ~output_ip_hdr_ready;

    error_header_early_termination_next = 0;
    error_payload_early_termination_next = 0;
    error_invalid_header_next = 0;
    error_invalid_checksum_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for header
            frame_ptr_next = 0;
            hdr_sum_next = 0;
            flush_save = 1;

            if (input_eth_hdr_ready & input_eth_hdr_valid) begin
                frame_ptr_next = 0;
                store_eth_hdr = 1;
                state_next = STATE_READ_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_HEADER: begin
            // read header state
            if (input_eth_payload_tvalid) begin
                // word transfer in - store it
                frame_ptr_next = frame_ptr_reg+8;
                transfer_in_save = 1;
                state_next = STATE_READ_HEADER;

                case (frame_ptr_reg)
                    8'h00: begin
                        store_hdr_word_0 = 1;
                        hdr_sum_temp = input_eth_payload_tdata[15:0] +
                                       input_eth_payload_tdata[31:16] +
                                       input_eth_payload_tdata[47:32] +
                                       input_eth_payload_tdata[63:48];
                        hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[31:16];
                        hdr_sum_temp_a_next = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                    end
                    8'h08: begin
                        store_hdr_word_1 = 1;
                        hdr_sum_temp = input_eth_payload_tdata[15:0] +
                                       input_eth_payload_tdata[31:16] +
                                       input_eth_payload_tdata[47:32] +
                                       input_eth_payload_tdata[63:48];
                        hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[31:16];
                        hdr_sum_temp_b_next = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                    end
                    8'h10: begin
                        store_hdr_word_2 = 1;
                        hdr_sum_temp = input_eth_payload_tdata[15:0] +
                                       input_eth_payload_tdata[31:16] +
                                       hdr_sum_temp_a_reg +
                                       hdr_sum_temp_b_reg;
                        hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[31:16];
                        hdr_sum_next = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                        frame_ptr_next = frame_ptr_reg+4;
                        if (output_ip_version_reg != 4 || output_ip_ihl_reg != 5) begin
                            error_invalid_header_next = 1;
                            state_next = STATE_WAIT_LAST;
                        end else if (hdr_sum_next != 16'hffff) begin
                            error_invalid_checksum_next = 1;
                            state_next = STATE_WAIT_LAST;
                        end else begin
                            output_ip_hdr_valid_next = 1;
                            state_next = STATE_READ_PAYLOAD_IDLE;
                        end
                    end
                endcase

                if (shift_eth_payload_tlast) begin
                    state_next = STATE_IDLE;
                    output_ip_hdr_valid_next = 0;
                    error_header_early_termination_next = 1;
                    error_invalid_header_next = 0;
                    error_invalid_checksum_next = 0;
                end

            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_READ_PAYLOAD_IDLE: begin
            // idle; no data in registers
            if (shift_eth_payload_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_eth_payload_tkeep);
                if (frame_ptr_next >= output_ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = output_ip_length_reg;
                    tkeep_mask = count2keep(output_ip_length_reg - frame_ptr_reg);
                    if (shift_eth_payload_tlast) begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_eth_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_IDLE;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER: begin
            // read payload; data in output register
            if (shift_eth_payload_tvalid & output_ip_payload_tready) begin
                // word transfer through - update output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_eth_payload_tkeep);
                if (frame_ptr_next >= output_ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = output_ip_length_reg;
                    tkeep_mask = count2keep(output_ip_length_reg - frame_ptr_reg);
                    if (shift_eth_payload_tlast) begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_eth_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER;
                    end
                end
            end else if (~shift_eth_payload_tvalid & output_ip_payload_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_READ_PAYLOAD_IDLE;
            end else if (shift_eth_payload_tvalid & ~output_ip_payload_tready) begin
                // word transfer in - store in temp
                transfer_in_save = 1;
                transfer_in_temp = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_eth_payload_tkeep);
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT;
                if (frame_ptr_next >= output_ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = output_ip_length_reg;
                    tkeep_mask = count2keep(output_ip_length_reg - frame_ptr_reg);
                    if (~shift_eth_payload_tlast) begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST_WAIT;
                    end
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_WAIT: begin
            // read payload; data in both output and temp registers
            if (output_ip_payload_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                if (temp_ip_payload_tlast_reg) begin
                    if (frame_ptr_next < output_ip_length_reg) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                    end
                    state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                end else begin
                    if (frame_ptr_next >= output_ip_length_reg) begin
                        // not end of frame, but we have the entire payload
                        state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
                    end else begin
                        state_next = STATE_READ_PAYLOAD_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_LAST: begin
            // read last payload word; data in output register; do not accept new data
            if (output_ip_payload_tready) begin
                // word transfer out - done
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST: begin
            // wait for end of frame; data in output register; read and discard
            if (shift_eth_payload_tvalid) begin
                transfer_in_save = 1;
                if (shift_eth_payload_tlast) begin
                    // assert tlast and transfer tuser
                    assert_tlast = 1;
                    assert_tuser = shift_eth_payload_tuser;
                    state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST_WAIT: begin
            // wait for end of frame; data in both output and temp registers; read and discard
            if (output_ip_payload_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST;
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST_WAIT;
            end
        end
        STATE_WAIT_LAST: begin
            // wait for end of frame; read and discard
            if (shift_eth_payload_tvalid) begin
                transfer_in_save = 1;
                if (shift_eth_payload_tlast) begin
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

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        hdr_sum_reg <= 0;
        hdr_sum_temp_a_reg <= 0;
        hdr_sum_temp_b_reg <= 0;
        input_eth_hdr_ready_reg <= 0;
        input_eth_payload_tready_reg <= 0;
        output_ip_hdr_valid_reg <= 0;
        output_eth_dest_mac_reg <= 0;
        output_eth_src_mac_reg <= 0;
        output_eth_type_reg <= 0;
        output_ip_version_reg <= 0;
        output_ip_ihl_reg <= 0;
        output_ip_dscp_reg <= 0;
        output_ip_ecn_reg <= 0;
        output_ip_length_reg <= 0;
        output_ip_identification_reg <= 0;
        output_ip_flags_reg <= 0;
        output_ip_fragment_offset_reg <= 0;
        output_ip_ttl_reg <= 0;
        output_ip_protocol_reg <= 0;
        output_ip_header_checksum_reg <= 0;
        output_ip_source_ip_reg <= 0;
        output_ip_dest_ip_reg <= 0;
        output_ip_payload_tdata_reg <= 0;
        output_ip_payload_tvalid_reg <= 0;
        output_ip_payload_tlast_reg <= 0;
        output_ip_payload_tuser_reg <= 0;
        temp_ip_payload_tdata_reg <= 0;
        temp_ip_payload_tlast_reg <= 0;
        temp_ip_payload_tuser_reg <= 0;
        busy_reg <= 0;
        error_header_early_termination_reg <= 0;
        error_payload_early_termination_reg <= 0;
        error_invalid_header_reg <= 0;
        error_invalid_checksum_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        hdr_sum_reg <= hdr_sum_next;
        hdr_sum_temp_a_reg <= hdr_sum_temp_a_next;
        hdr_sum_temp_b_reg <= hdr_sum_temp_b_next;

        output_ip_hdr_valid_reg <= output_ip_hdr_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;
        error_payload_early_termination_reg <= error_payload_early_termination_next;
        error_invalid_header_reg <= error_invalid_header_next;
        error_invalid_checksum_reg <= error_invalid_checksum_next;

        busy_reg <= state_next != STATE_IDLE;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle; accept new data
                input_eth_hdr_ready_reg <= ~output_ip_hdr_valid;
                input_eth_payload_tready_reg <= 0;
                output_ip_payload_tvalid_reg <= 0;
            end
            STATE_READ_HEADER: begin
                // read header; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_ip_payload_tvalid_reg <= 0;
            end
            STATE_READ_PAYLOAD_IDLE: begin
                // read payload; no data in registers; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_ip_payload_tvalid_reg <= 0;
            end
            STATE_READ_PAYLOAD_TRANSFER: begin
                // read payload; data in output register; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_ip_payload_tvalid_reg <= 1;
            end
            STATE_READ_PAYLOAD_TRANSFER_WAIT: begin
                // read payload; data in output and temp registers; do not accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_ip_payload_tvalid_reg <= 1;
            end
            STATE_READ_PAYLOAD_TRANSFER_LAST: begin
                // read last payload word; data in output register; do not accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_ip_payload_tvalid_reg <= 1;
            end
            STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST: begin
                // wait for end of frame; data in output register; read and discard
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_ip_payload_tvalid_reg <= 0;
            end
            STATE_READ_PAYLOAD_TRANSFER_WAIT_LAST_WAIT: begin
                // wait for end of frame; data in output and temp registers; do not accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_ip_payload_tvalid_reg <= 1;
            end
            STATE_WAIT_LAST: begin
                // wait for end of frame; read and discard
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_ip_payload_tvalid_reg <= 0;
            end
        endcase

        // datapath
        if (store_eth_hdr) begin
            output_eth_dest_mac_reg <= input_eth_dest_mac;
            output_eth_src_mac_reg <= input_eth_src_mac;
            output_eth_type_reg <= input_eth_type;
        end

        if (store_hdr_word_0) begin
            {output_ip_version_reg, output_ip_ihl_reg} <= input_eth_payload_tdata[ 7: 0];
            {output_ip_dscp_reg, output_ip_ecn_reg} <= input_eth_payload_tdata[15: 8];
            output_ip_length_reg[15: 8] <= input_eth_payload_tdata[23:16];
            output_ip_length_reg[ 7: 0] <= input_eth_payload_tdata[31:24];
            output_ip_identification_reg[15: 8] <= input_eth_payload_tdata[39:32];
            output_ip_identification_reg[ 7: 0] <= input_eth_payload_tdata[47:40];
            {output_ip_flags_reg, output_ip_fragment_offset_reg[12:8]} <= input_eth_payload_tdata[55:48];
            output_ip_fragment_offset_reg[ 7:0] <= input_eth_payload_tdata[63:56];
        end

        if (store_hdr_word_1) begin
            output_ip_ttl_reg <= input_eth_payload_tdata[ 7: 0];
            output_ip_protocol_reg <= input_eth_payload_tdata[15: 8];
            output_ip_header_checksum_reg[15: 8] <= input_eth_payload_tdata[23:16];
            output_ip_header_checksum_reg[ 7: 0] <= input_eth_payload_tdata[31:24];
            output_ip_source_ip_reg[31:24] <= input_eth_payload_tdata[39:32];
            output_ip_source_ip_reg[23:16] <= input_eth_payload_tdata[47:40];
            output_ip_source_ip_reg[15: 8] <= input_eth_payload_tdata[55:48];
            output_ip_source_ip_reg[ 7: 0] <= input_eth_payload_tdata[63:56];
        end

        if (store_hdr_word_2) begin
            output_ip_dest_ip_reg[31:24] <= input_eth_payload_tdata[ 7: 0];
            output_ip_dest_ip_reg[23:16] <= input_eth_payload_tdata[15: 8];
            output_ip_dest_ip_reg[15: 8] <= input_eth_payload_tdata[23:16];
            output_ip_dest_ip_reg[ 7: 0] <= input_eth_payload_tdata[31:24];
        end

        if (transfer_in_out) begin
            output_ip_payload_tdata_reg <= shift_eth_payload_tdata;
            output_ip_payload_tkeep_reg <= shift_eth_payload_tkeep & tkeep_mask;
            output_ip_payload_tlast_reg <= shift_eth_payload_tlast;
            output_ip_payload_tuser_reg <= shift_eth_payload_tuser;
        end else if (transfer_in_temp) begin
            temp_ip_payload_tdata_reg <= shift_eth_payload_tdata;
            temp_ip_payload_tkeep_reg <= shift_eth_payload_tkeep & tkeep_mask;
            temp_ip_payload_tlast_reg <= shift_eth_payload_tlast;
            temp_ip_payload_tuser_reg <= shift_eth_payload_tuser;
        end else if (transfer_temp_out) begin
            output_ip_payload_tdata_reg <= temp_ip_payload_tdata_reg;
            output_ip_payload_tkeep_reg <= temp_ip_payload_tkeep_reg;
            output_ip_payload_tlast_reg <= temp_ip_payload_tlast_reg;
            output_ip_payload_tuser_reg <= temp_ip_payload_tuser_reg;
        end

        if (flush_save) begin
            save_eth_payload_tdata_reg <= 0;
            save_eth_payload_tkeep_reg <= 0;
            save_eth_payload_tlast_reg <= 0;
            save_eth_payload_tuser_reg <= 0;
        end else if (transfer_in_save & ~shift_eth_payload_extra_cycle) begin
            save_eth_payload_tdata_reg <= input_eth_payload_tdata;
            save_eth_payload_tkeep_reg <= input_eth_payload_tkeep;
            save_eth_payload_tlast_reg <= input_eth_payload_tlast;
            save_eth_payload_tuser_reg <= input_eth_payload_tuser;
        end

        if (assert_tlast) output_ip_payload_tlast_reg <= 1;
        if (assert_tuser) output_ip_payload_tuser_reg <= 1;
    end
end

endmodule
