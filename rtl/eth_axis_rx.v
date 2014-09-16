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
 * AXI4-Stream ethernet frame receiver (AXI in, Ethernet frame out)
 */
module eth_axis_rx
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [7:0]  input_axis_tdata,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,

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
     * Status signals
     */
    output wire        busy,
    output wire        error_header_early_termination
);

/*

Ethernet frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype                   2 octets

This module receives an Ethernet frame on an 8 bit wide AXI interface,
separates the dest MAC, source MAC, and eth type into separate parallel
outputs, and forwards the payload data out through a separate AXI interface.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_READ_HEADER = 3'd1,
    STATE_READ_PAYLOAD_IDLE = 3'd2,
    STATE_READ_PAYLOAD_TRANSFER = 3'd3,
    STATE_READ_PAYLOAD_TRANSFER_WAIT = 3'd4,
    STATE_READ_PAYLOAD_TRANSFER_LAST = 3'd5;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_dest_mac_0;
reg store_eth_dest_mac_1;
reg store_eth_dest_mac_2;
reg store_eth_dest_mac_3;
reg store_eth_dest_mac_4;
reg store_eth_dest_mac_5;
reg store_eth_src_mac_0;
reg store_eth_src_mac_1;
reg store_eth_src_mac_2;
reg store_eth_src_mac_3;
reg store_eth_src_mac_4;
reg store_eth_src_mac_5;
reg store_eth_type_0;
reg store_eth_type_1;

reg transfer_in_out;
reg transfer_in_temp;
reg transfer_temp_out;

reg [7:0] frame_ptr_reg = 0, frame_ptr_next;

reg input_axis_tready_reg = 0;

reg output_eth_hdr_valid_reg = 0, output_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 0;
reg [47:0] output_eth_src_mac_reg = 0;
reg [15:0] output_eth_type_reg = 0;
reg [7:0]  output_eth_payload_tdata_reg = 0;
reg output_eth_payload_tvalid_reg = 0;
reg output_eth_payload_tlast_reg = 0;
reg output_eth_payload_tuser_reg = 0;

reg busy_reg = 0, busy_next;
reg error_header_early_termination_reg = 0, error_header_early_termination_next;

reg [7:0] temp_eth_payload_tdata_reg = 0;
reg temp_eth_payload_tlast_reg = 0;
reg temp_eth_payload_tuser_reg = 0;

assign input_axis_tready = input_axis_tready_reg;

assign output_eth_hdr_valid = output_eth_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;
assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_eth_payload_tvalid = output_eth_payload_tvalid_reg;
assign output_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_eth_payload_tuser = output_eth_payload_tuser_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;

always @* begin
    state_next = 2'bz;

    transfer_in_out = 0;
    transfer_in_temp = 0;
    transfer_temp_out = 0;

    store_eth_dest_mac_0 = 0;
    store_eth_dest_mac_1 = 0;
    store_eth_dest_mac_2 = 0;
    store_eth_dest_mac_3 = 0;
    store_eth_dest_mac_4 = 0;
    store_eth_dest_mac_5 = 0;
    store_eth_src_mac_0 = 0;
    store_eth_src_mac_1 = 0;
    store_eth_src_mac_2 = 0;
    store_eth_src_mac_3 = 0;
    store_eth_src_mac_4 = 0;
    store_eth_src_mac_5 = 0;
    store_eth_type_0 = 0;
    store_eth_type_1 = 0;

    frame_ptr_next = frame_ptr_reg;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;

    error_header_early_termination_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;

            if (input_axis_tready & input_axis_tvalid) begin
                frame_ptr_next = 1;
                store_eth_dest_mac_5 = 1;
                state_next = STATE_READ_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_HEADER: begin
            // read header state
            if (input_axis_tvalid) begin
                // word transfer in - store it
                frame_ptr_next = frame_ptr_reg+1;
                state_next = STATE_READ_HEADER;
                case (frame_ptr_reg)
                    8'h00: store_eth_dest_mac_5 = 1;
                    8'h01: store_eth_dest_mac_4 = 1;
                    8'h02: store_eth_dest_mac_3 = 1;
                    8'h03: store_eth_dest_mac_2 = 1;
                    8'h04: store_eth_dest_mac_1 = 1;
                    8'h05: store_eth_dest_mac_0 = 1;
                    8'h06: store_eth_src_mac_5 = 1;
                    8'h07: store_eth_src_mac_4 = 1;
                    8'h08: store_eth_src_mac_3 = 1;
                    8'h09: store_eth_src_mac_2 = 1;
                    8'h0A: store_eth_src_mac_1 = 1;
                    8'h0B: store_eth_src_mac_0 = 1;
                    8'h0C: store_eth_type_1 = 1;
                    8'h0D: begin
                        store_eth_type_0 = 1;
                        output_eth_hdr_valid_next = 1;
                        state_next = STATE_READ_PAYLOAD_IDLE;
                    end
                endcase
                if (input_axis_tlast) begin
                    state_next = STATE_IDLE;
                    error_header_early_termination_next = 1;
                end
            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_READ_PAYLOAD_IDLE: begin
            // idle; no data in registers
            if (input_axis_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_out = 1;
                if (input_axis_tlast) begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_IDLE;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER: begin
            // read payload; data in output register
            if (input_axis_tvalid & output_eth_payload_tready) begin
                // word transfer through - update output register
                transfer_in_out = 1;
                if (input_axis_tlast) begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER;
                end
            end else if (~input_axis_tvalid & output_eth_payload_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_READ_PAYLOAD_IDLE;
            end else if (input_axis_tvalid & ~output_eth_payload_tready) begin
                // word transfer in - store in temp
                transfer_in_temp = 1;
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT;
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_WAIT: begin
            // read payload; data in both output and temp registers
            if (output_eth_payload_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                if (temp_eth_payload_tlast_reg) begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_READ_PAYLOAD_TRANSFER;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_WAIT;
            end
        end
        STATE_READ_PAYLOAD_TRANSFER_LAST: begin
            // read last payload word; data in output register; do not accept new data
            if (output_eth_payload_tready) begin
                // word transfer out - done
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_READ_PAYLOAD_TRANSFER_LAST;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        input_axis_tready_reg <= 0;
        output_eth_hdr_valid_reg <= 0;
        output_eth_dest_mac_reg <= 0;
        output_eth_src_mac_reg <= 0;
        output_eth_type_reg <= 0;
        output_eth_payload_tdata_reg <= 0;
        output_eth_payload_tvalid_reg <= 0;
        output_eth_payload_tlast_reg <= 0;
        output_eth_payload_tuser_reg <= 0;
        temp_eth_payload_tdata_reg <= 0;
        temp_eth_payload_tlast_reg <= 0;
        temp_eth_payload_tuser_reg <= 0;
        busy_reg <= 0;
        error_header_early_termination_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;

        busy_reg <= state_next != STATE_IDLE;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle; accept new data
                input_axis_tready_reg <= ~output_eth_hdr_valid;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_READ_HEADER: begin
                // read header; accept new data
                input_axis_tready_reg <= 1;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_READ_PAYLOAD_IDLE: begin
                // read payload; no data in registers; accept new data
                input_axis_tready_reg <= 1;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_READ_PAYLOAD_TRANSFER: begin
                // read payload; data in output register; accept new data
                input_axis_tready_reg <= 1;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_READ_PAYLOAD_TRANSFER_WAIT: begin
                // read payload; data in output and temp registers; do not accept new data
                input_axis_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_READ_PAYLOAD_TRANSFER_LAST: begin
                // read last payload word; data in output register; do not accept new data
                input_axis_tready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
        endcase

        // datapath
        if (store_eth_dest_mac_0) output_eth_dest_mac_reg[ 7: 0] <= input_axis_tdata;
        if (store_eth_dest_mac_1) output_eth_dest_mac_reg[15: 8] <= input_axis_tdata;
        if (store_eth_dest_mac_2) output_eth_dest_mac_reg[23:16] <= input_axis_tdata;
        if (store_eth_dest_mac_3) output_eth_dest_mac_reg[31:24] <= input_axis_tdata;
        if (store_eth_dest_mac_4) output_eth_dest_mac_reg[39:32] <= input_axis_tdata;
        if (store_eth_dest_mac_5) output_eth_dest_mac_reg[47:40] <= input_axis_tdata;
        if (store_eth_src_mac_0) output_eth_src_mac_reg[ 7: 0] <= input_axis_tdata;
        if (store_eth_src_mac_1) output_eth_src_mac_reg[15: 8] <= input_axis_tdata;
        if (store_eth_src_mac_2) output_eth_src_mac_reg[23:16] <= input_axis_tdata;
        if (store_eth_src_mac_3) output_eth_src_mac_reg[31:24] <= input_axis_tdata;
        if (store_eth_src_mac_4) output_eth_src_mac_reg[39:32] <= input_axis_tdata;
        if (store_eth_src_mac_5) output_eth_src_mac_reg[47:40] <= input_axis_tdata;
        if (store_eth_type_0) output_eth_type_reg[ 7: 0] <= input_axis_tdata;
        if (store_eth_type_1) output_eth_type_reg[15: 8] <= input_axis_tdata;

        if (transfer_in_out) begin
            output_eth_payload_tdata_reg <= input_axis_tdata;
            output_eth_payload_tlast_reg <= input_axis_tlast;
            output_eth_payload_tuser_reg <= input_axis_tuser;
        end else if (transfer_in_temp) begin
            temp_eth_payload_tdata_reg <= input_axis_tdata;
            temp_eth_payload_tlast_reg <= input_axis_tlast;
            temp_eth_payload_tuser_reg <= input_axis_tuser;
        end else if (transfer_temp_out) begin
            output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
            output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
            output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
        end
    end
end

endmodule
