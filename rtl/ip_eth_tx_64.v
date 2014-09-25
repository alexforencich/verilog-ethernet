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

This module receives an Ethernet frame with decoded fields and decodes
the AXI packet format.  If the Ethertype does not match, the packet is
discarded.

*/

localparam [3:0]
    STATE_IDLE = 4'd0,
    STATE_WRITE_HEADER = 4'd1,
    STATE_WRITE_HEADER_LAST = 4'd2,
    STATE_WRITE_HEADER_LAST_WAIT = 4'd3,
    STATE_WRITE_PAYLOAD_IDLE = 4'd4,
    STATE_WRITE_PAYLOAD_TRANSFER = 4'd5,
    STATE_WRITE_PAYLOAD_TRANSFER_WAIT = 4'd6,
    STATE_WRITE_PAYLOAD_TRANSFER_LAST = 4'd7,
    STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST = 4'd8,
    STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT = 4'd9,
    STATE_WAIT_LAST = 4'd10;

reg [3:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_ip_hdr;

reg [63:0] write_hdr_data;
reg [7:0] write_hdr_keep;
reg write_hdr_last;
reg write_hdr_user;
reg write_hdr_out;
reg write_hdr_temp;

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

reg [5:0] ip_dscp_reg = 0;
reg [1:0] ip_ecn_reg = 0;
reg [15:0] ip_length_reg = 0;
reg [15:0] ip_identification_reg = 0;
reg [2:0] ip_flags_reg = 0;
reg [12:0] ip_fragment_offset_reg = 0;
reg [7:0] ip_ttl_reg = 0;
reg [7:0] ip_protocol_reg = 0;
reg [31:0] ip_source_ip_reg = 0;
reg [31:0] ip_dest_ip_reg = 0;

reg input_ip_hdr_ready_reg = 0;
reg input_ip_payload_tready_reg = 0;

reg output_eth_hdr_valid_reg = 0, output_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 0;
reg [47:0] output_eth_src_mac_reg = 0;
reg [15:0] output_eth_type_reg = 0;
reg [63:0] output_eth_payload_tdata_reg = 0;
reg [7:0] output_eth_payload_tkeep_reg = 0;
reg output_eth_payload_tvalid_reg = 0;
reg output_eth_payload_tlast_reg = 0;
reg output_eth_payload_tuser_reg = 0;

reg busy_reg = 0;
reg error_payload_early_termination_reg = 0, error_payload_early_termination_next;

reg [63:0] temp_eth_payload_tdata_reg = 0;
reg [7:0] temp_eth_payload_tkeep_reg = 0;
reg temp_eth_payload_tlast_reg = 0;
reg temp_eth_payload_tuser_reg = 0;

reg [63:0] save_ip_payload_tdata_reg = 0;
reg [7:0] save_ip_payload_tkeep_reg = 0;
reg save_ip_payload_tlast_reg = 0;
reg save_ip_payload_tuser_reg = 0;

reg [63:0] shift_ip_payload_tdata;
reg [7:0] shift_ip_payload_tkeep;
reg shift_ip_payload_tvalid;
reg shift_ip_payload_tlast;
reg shift_ip_payload_tuser;
reg shift_ip_payload_input_tready;
reg shift_ip_payload_extra_cycle;

assign input_ip_hdr_ready = input_ip_hdr_ready_reg;
assign input_ip_payload_tready = input_ip_payload_tready_reg;

assign output_eth_hdr_valid = output_eth_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;
assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_eth_payload_tvalid = output_eth_payload_tvalid_reg;
assign output_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_eth_payload_tuser = output_eth_payload_tuser_reg;

assign busy = busy_reg;
assign error_payload_early_termination = error_payload_early_termination_reg;

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
    shift_ip_payload_tdata[31:0] = save_ip_payload_tdata_reg[63:32];
    shift_ip_payload_tkeep[3:0] = save_ip_payload_tkeep_reg[7:4];
    shift_ip_payload_extra_cycle = save_ip_payload_tlast_reg & (save_ip_payload_tkeep_reg[7:4] != 0);

    if (shift_ip_payload_extra_cycle) begin
        shift_ip_payload_tdata[63:32] = 0;
        shift_ip_payload_tkeep[7:4] = 0;
        shift_ip_payload_tvalid = 1;
        shift_ip_payload_tlast = save_ip_payload_tlast_reg;
        shift_ip_payload_tuser = save_ip_payload_tuser_reg;
        shift_ip_payload_input_tready = flush_save;
    end else begin
        shift_ip_payload_tdata[63:32] = input_ip_payload_tdata[31:0];
        shift_ip_payload_tkeep[7:4] = input_ip_payload_tkeep[3:0];
        shift_ip_payload_tvalid = input_ip_payload_tvalid;
        shift_ip_payload_tlast = (input_ip_payload_tlast & (input_ip_payload_tkeep[7:4] == 0));
        shift_ip_payload_tuser = (input_ip_payload_tuser & (input_ip_payload_tkeep[7:4] == 0));
        shift_ip_payload_input_tready = ~(input_ip_payload_tlast & input_ip_payload_tvalid & transfer_in_save);
    end
end

always @* begin
    state_next = 2'bz;

    store_ip_hdr = 0;

    write_hdr_data = 0;
    write_hdr_keep = 0;
    write_hdr_last = 0;
    write_hdr_user = 0;
    write_hdr_out = 0;
    write_hdr_temp = 0;

    flush_save = 0;
    transfer_in_save = 0;
    transfer_save_out = 0;
    transfer_in_out = 0;
    transfer_in_temp = 0;
    transfer_temp_out = 0;

    assert_tlast = 0;
    assert_tuser = 0;
    tkeep_mask = 8'hff;

    frame_ptr_next = frame_ptr_reg;

    hdr_sum_temp = 0;
    hdr_sum_next = hdr_sum_reg;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;

    error_payload_early_termination_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;
            flush_save = 1;

            if (input_ip_hdr_valid & input_ip_hdr_ready) begin
                store_ip_hdr = 1;
                hdr_sum_temp = {4'd4, 4'd5, input_ip_dscp, input_ip_ecn} +
                               input_ip_length +
                               input_ip_identification +
                               {input_ip_flags, input_ip_fragment_offset} +
                               {input_ip_ttl, input_ip_protocol};
                hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[31:16];
                hdr_sum_next = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = {4'd4, 4'd5}; // ip_version, ip_ihl
                write_hdr_data[15: 8] = {input_ip_dscp, input_ip_ecn};
                write_hdr_data[23:16] = input_ip_length[15: 8];
                write_hdr_data[31:24] = input_ip_length[ 7: 0];
                write_hdr_data[39:32] = input_ip_identification[15: 8];
                write_hdr_data[47:40] = input_ip_identification[ 7: 0];
                write_hdr_data[55:48] = {input_ip_flags, input_ip_fragment_offset[12: 8]};
                write_hdr_data[63:56] = input_ip_fragment_offset[ 7: 0];
                write_hdr_keep = 8'hff;
                output_eth_hdr_valid_next = 1;
                frame_ptr_next = 8;
                state_next = STATE_WRITE_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // write header state
            if (output_eth_payload_tready) begin
                // word transfer out
                frame_ptr_next = frame_ptr_reg+8;
                state_next = STATE_WRITE_HEADER;
                write_hdr_out = 1;
                case (frame_ptr_reg)
                    8'h08: begin
                        hdr_sum_temp = hdr_sum_reg +
                                    ip_source_ip_reg[31:16] +
                                    ip_source_ip_reg[15: 0] +
                                    ip_dest_ip_reg[31:16] +
                                    ip_dest_ip_reg[15: 0];
                        hdr_sum_temp = hdr_sum_temp[15:0] + hdr_sum_temp[31:16];
                        hdr_sum_next = hdr_sum_temp[15:0] + hdr_sum_temp[16];
                        write_hdr_data[ 7: 0] = ip_ttl_reg;
                        write_hdr_data[15: 8] = ip_protocol_reg;
                        write_hdr_data[23:16] = ~hdr_sum_next[15: 8];
                        write_hdr_data[31:24] = ~hdr_sum_next[ 7: 0];
                        write_hdr_data[39:32] = ip_source_ip_reg[31:24];
                        write_hdr_data[47:40] = ip_source_ip_reg[23:16];
                        write_hdr_data[55:48] = ip_source_ip_reg[15: 8];
                        write_hdr_data[63:56] = ip_source_ip_reg[ 7: 0];
                        write_hdr_keep = 8'hff;
                        state_next = STATE_WRITE_HEADER_LAST;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // last header word requires first payload word; process accordingly
            if (shift_ip_payload_tvalid & output_eth_payload_tready) begin
                // word transfer through - update output register
                transfer_in_save = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = ip_dest_ip_reg[31:24];
                write_hdr_data[15: 8] = ip_dest_ip_reg[23:16];
                write_hdr_data[23:16] = ip_dest_ip_reg[15: 8];
                write_hdr_data[31:24] = ip_dest_ip_reg[ 7: 0];
                write_hdr_data[39:32] = shift_ip_payload_tdata[39:32];
                write_hdr_data[47:40] = shift_ip_payload_tdata[47:40];
                write_hdr_data[55:48] = shift_ip_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_ip_payload_tdata[63:56];
                write_hdr_keep = {shift_ip_payload_tkeep[7:4], 4'hF};
                frame_ptr_next = frame_ptr_reg+keep2count(write_hdr_keep);
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    write_hdr_keep = tkeep_mask;
                    assert_tlast = 1;
                    assert_tuser = input_ip_payload_tuser;
                    if (shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                    end
                end
            end else if (~shift_ip_payload_tvalid & output_eth_payload_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_WRITE_HEADER_LAST_WAIT;
            end else if (shift_ip_payload_tvalid & ~output_eth_payload_tready) begin
                // word transfer in - store in temp
                transfer_in_save = 1;
                write_hdr_temp = 1;
                write_hdr_data[ 7: 0] = ip_dest_ip_reg[31:24];
                write_hdr_data[15: 8] = ip_dest_ip_reg[23:16];
                write_hdr_data[23:16] = ip_dest_ip_reg[15: 8];
                write_hdr_data[31:24] = ip_dest_ip_reg[ 7: 0];
                write_hdr_data[39:32] = shift_ip_payload_tdata[39:32];
                write_hdr_data[47:40] = shift_ip_payload_tdata[47:40];
                write_hdr_data[55:48] = shift_ip_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_ip_payload_tdata[63:56];
                write_hdr_keep = {shift_ip_payload_tkeep[7:4], 4'hF};
                frame_ptr_next = frame_ptr_reg+keep2count(write_hdr_keep);
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    write_hdr_keep = tkeep_mask;
                    write_hdr_last = 1;
                    write_hdr_user = shift_ip_payload_tuser;
                    if (shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        write_hdr_last = 1;
                        write_hdr_user = 1;
                        error_payload_early_termination_next = 1;
                    end
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER;
            end
        end
        STATE_WRITE_HEADER_LAST_WAIT: begin
            // last header word requires first payload word; no data in registers
            if (shift_ip_payload_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_save = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = ip_dest_ip_reg[31:24];
                write_hdr_data[15: 8] = ip_dest_ip_reg[23:16];
                write_hdr_data[23:16] = ip_dest_ip_reg[15: 8];
                write_hdr_data[31:24] = ip_dest_ip_reg[ 7: 0];
                write_hdr_data[39:32] = shift_ip_payload_tdata[39:32];
                write_hdr_data[47:40] = shift_ip_payload_tdata[47:40];
                write_hdr_data[55:48] = shift_ip_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_ip_payload_tdata[63:56];
                write_hdr_keep = {shift_ip_payload_tkeep[7:4], 4'hF};
                frame_ptr_next = frame_ptr_reg+keep2count(write_hdr_keep);
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    write_hdr_keep = tkeep_mask;
                    assert_tlast = 1;
                    assert_tuser = shift_ip_payload_tuser;
                    if (shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_WRITE_HEADER_LAST_WAIT;
            end
        end
        STATE_WRITE_PAYLOAD_IDLE: begin
            // idle; no data in registers
            if (shift_ip_payload_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_ip_payload_tkeep);
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    if (shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_IDLE;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER: begin
            // write payload; data in output register
            if (shift_ip_payload_tvalid & output_eth_payload_tready) begin
                // word transfer through - update output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_ip_payload_tkeep);
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    if (shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                    end
                end else begin
                    if (shift_ip_payload_tlast) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                    end
                end
            end else if (~shift_ip_payload_tvalid & output_eth_payload_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_WRITE_PAYLOAD_IDLE;
            end else if (shift_ip_payload_tvalid & ~output_eth_payload_tready) begin
                // word transfer in - store in temp
                transfer_in_save = 1;
                transfer_in_temp = 1;
                frame_ptr_next = frame_ptr_reg+keep2count(shift_ip_payload_tkeep);
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
                if (frame_ptr_next >= ip_length_reg) begin
                    // have entire payload
                    frame_ptr_next = ip_length_reg;
                    tkeep_mask = count2keep(ip_length_reg - frame_ptr_reg);
                    if (~shift_ip_payload_tlast) begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT;
                    end
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_WAIT: begin
            // write payload; data in both output and temp registers
            if (output_eth_payload_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                if (temp_eth_payload_tlast_reg) begin
                    if (frame_ptr_next < ip_length_reg) begin
                        // end of frame, but length does not match
                        assert_tuser = 1;
                        assert_tlast = 1;
                        error_payload_early_termination_next = 1;
                    end
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    if (frame_ptr_next >= ip_length_reg) begin
                        // not end of frame, but we have the entire payload
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                    end else begin
                        state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_LAST: begin
            // write last payload word; data in output register; do not accept new data
            if (output_eth_payload_tready) begin
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST: begin
            // wait for end of frame; data in output register; read and discard
            if (shift_ip_payload_tvalid) begin
                transfer_in_save = 1;
                if (shift_ip_payload_tlast) begin
                    // assert tlast and transfer tuser
                    assert_tlast = 1;
                    assert_tuser = shift_ip_payload_tuser;
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT: begin
            // wait for end of frame; data in both output and temp registers; read and discard
            if (output_eth_payload_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST;
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT;
            end
        end
        STATE_WAIT_LAST: begin
            // wait for end of frame; read and discard
            if (shift_ip_payload_tvalid) begin
                transfer_in_save = 1;
                if (shift_ip_payload_tlast) begin
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
        input_ip_hdr_ready_reg <= 0;
        input_ip_payload_tready_reg <= 0;
        ip_dscp_reg <= 0;
        ip_ecn_reg <= 0;
        ip_length_reg <= 0;
        ip_identification_reg <= 0;
        ip_flags_reg <= 0;
        ip_fragment_offset_reg <= 0;
        ip_ttl_reg <= 0;
        ip_protocol_reg <= 0;
        ip_source_ip_reg <= 0;
        ip_dest_ip_reg <= 0;
        output_eth_hdr_valid_reg <= 0;
        output_eth_dest_mac_reg <= 0;
        output_eth_src_mac_reg <= 0;
        output_eth_type_reg <= 0;
        output_eth_payload_tdata_reg <= 0;
        output_eth_payload_tvalid_reg <= 0;
        output_eth_payload_tlast_reg <= 0;
        output_eth_payload_tuser_reg <= 0;
        temp_eth_payload_tdata_reg <= 0;
        temp_eth_payload_tkeep_reg <= 0;
        temp_eth_payload_tlast_reg <= 0;
        temp_eth_payload_tuser_reg <= 0;
        save_ip_payload_tdata_reg <= 0;
        save_ip_payload_tkeep_reg <= 0;
        save_ip_payload_tlast_reg <= 0;
        save_ip_payload_tuser_reg <= 0;
        busy_reg <= 0;
        error_payload_early_termination_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        hdr_sum_reg <= hdr_sum_next;

        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;

        busy_reg <= state_next != STATE_IDLE;

        error_payload_early_termination_reg <= error_payload_early_termination_next;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle; accept new data
                input_ip_hdr_ready_reg <= 1;
                input_ip_payload_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_WRITE_HEADER: begin
                // write header
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_HEADER_LAST: begin
                // write last header word; need first data word
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_HEADER_LAST_WAIT: begin
                // last header word requires first payload word; no data in registers
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_WRITE_PAYLOAD_IDLE: begin
                // write payload; no data in registers; accept new data
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_WRITE_PAYLOAD_TRANSFER: begin
                // write payload; data in output register; accept new data
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_WAIT: begin
                // write payload; data in output and temp registers; do not accept new data
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_LAST: begin
                // write last payload word; data in output register; do not accept new data
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST: begin
                // wait for end of frame; data in output register; read and discard
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_WAIT_LAST_WAIT: begin
                // wait for end of frame; data in output and temp registers; do not accept new data
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WAIT_LAST: begin
                // wait for end of frame; read and discard
                input_ip_hdr_ready_reg <= 0;
                input_ip_payload_tready_reg <= shift_ip_payload_input_tready;
                output_eth_payload_tvalid_reg <= 0;
            end
        endcase

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

        if (write_hdr_out) begin
            output_eth_payload_tdata_reg <= write_hdr_data;
            output_eth_payload_tkeep_reg <= write_hdr_keep & tkeep_mask;
            output_eth_payload_tlast_reg <= write_hdr_last;
            output_eth_payload_tuser_reg <= write_hdr_user;
        end else if (write_hdr_temp) begin
            temp_eth_payload_tdata_reg <= write_hdr_data;
            temp_eth_payload_tkeep_reg <= write_hdr_keep & tkeep_mask;
            temp_eth_payload_tlast_reg <= write_hdr_last;
            temp_eth_payload_tuser_reg <= write_hdr_user;
        end else if (transfer_in_out) begin
            output_eth_payload_tdata_reg <= shift_ip_payload_tdata;
            output_eth_payload_tkeep_reg <= shift_ip_payload_tkeep & tkeep_mask;
            output_eth_payload_tlast_reg <= shift_ip_payload_tlast;
            output_eth_payload_tuser_reg <= shift_ip_payload_tuser;
        end else if (transfer_in_temp) begin
            temp_eth_payload_tdata_reg <= shift_ip_payload_tdata;
            temp_eth_payload_tkeep_reg <= shift_ip_payload_tkeep & tkeep_mask;
            temp_eth_payload_tlast_reg <= shift_ip_payload_tlast;
            temp_eth_payload_tuser_reg <= shift_ip_payload_tuser;
        end else if (transfer_temp_out) begin
            output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
            output_eth_payload_tkeep_reg <= temp_eth_payload_tkeep_reg;
            output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
            output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
        end

        if (flush_save) begin
            save_ip_payload_tdata_reg <= 0;
            save_ip_payload_tkeep_reg <= 0;
            save_ip_payload_tlast_reg <= 0;
            save_ip_payload_tuser_reg <= 0;
        end else if (transfer_in_save & ~shift_ip_payload_extra_cycle) begin
            save_ip_payload_tdata_reg <= input_ip_payload_tdata;
            save_ip_payload_tkeep_reg <= input_ip_payload_tkeep;
            save_ip_payload_tlast_reg <= input_ip_payload_tlast;
            save_ip_payload_tuser_reg <= input_ip_payload_tuser;
        end

        if (assert_tlast) output_eth_payload_tlast_reg <= 1;
        if (assert_tuser) output_eth_payload_tuser_reg <= 1;
    end
end

endmodule
