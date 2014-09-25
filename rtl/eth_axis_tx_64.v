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
 * AXI4-Stream ethernet frame transmitter (Ethernet frame in, AXI out, 64 bit datapath)
 */
module eth_axis_tx_64
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
     * AXI output
     */
    output wire [63:0] output_axis_tdata,
    output wire [7:0]  output_axis_tkeep,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Status signals
     */
    output wire        busy
);

/*

Ethernet frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype                   2 octets

This module receives an Ethernet frame with parallel field input
and an AXI interface for the payload data and produces an AXI
output stream.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_WRITE_HEADER = 3'd1,
    STATE_WRITE_HEADER_LAST = 3'd2,
    STATE_WRITE_HEADER_LAST_WAIT = 3'd3,
    STATE_WRITE_PAYLOAD_IDLE = 3'd4,
    STATE_WRITE_PAYLOAD_TRANSFER = 3'd5,
    STATE_WRITE_PAYLOAD_TRANSFER_WAIT = 3'd6,
    STATE_WRITE_PAYLOAD_TRANSFER_LAST = 3'd7;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_hdr;

reg [63:0] write_hdr_data;
reg [7:0] write_hdr_keep;
reg write_hdr_last;
reg write_hdr_user;
reg write_hdr_out;
reg write_hdr_temp;

reg flush_save;
reg transfer_in_save;
reg transfer_in_out;
reg transfer_in_temp;
reg transfer_temp_out;

reg [7:0] frame_ptr_reg = 0, frame_ptr_next;

reg [47:0] eth_dest_mac_reg = 0;
reg [47:0] eth_src_mac_reg = 0;
reg [15:0] eth_type_reg = 0;

reg input_eth_hdr_ready_reg = 0;
reg input_eth_payload_tready_reg = 0;

reg [63:0] output_axis_tdata_reg = 0;
reg [7:0] output_axis_tkeep_reg = 0;
reg output_axis_tvalid_reg = 0;
reg output_axis_tlast_reg = 0;
reg output_axis_tuser_reg = 0;

reg busy_reg = 0;

reg [63:0] temp_axis_tdata_reg = 0;
reg [7:0] temp_axis_tkeep_reg = 0;
reg temp_axis_tlast_reg = 0;
reg temp_axis_tuser_reg = 0;

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

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

assign busy = busy_reg;

always @* begin
    shift_eth_payload_tdata[47:0] = save_eth_payload_tdata_reg[63:16];
    shift_eth_payload_tkeep[5:0] = save_eth_payload_tkeep_reg[7:2];
    shift_eth_payload_extra_cycle = save_eth_payload_tlast_reg & (save_eth_payload_tkeep_reg[7:2] != 0);

    if (shift_eth_payload_extra_cycle) begin
        shift_eth_payload_tdata[63:48] = 0;
        shift_eth_payload_tkeep[7:6] = 0;
        shift_eth_payload_tvalid = 1;
        shift_eth_payload_tlast = save_eth_payload_tlast_reg;
        shift_eth_payload_tuser = save_eth_payload_tuser_reg;
        shift_eth_payload_input_tready = flush_save;
    end else begin
        shift_eth_payload_tdata[63:48] = input_eth_payload_tdata[15:0];
        shift_eth_payload_tkeep[7:6] = input_eth_payload_tkeep[1:0];
        shift_eth_payload_tvalid = input_eth_payload_tvalid;
        shift_eth_payload_tlast = (input_eth_payload_tlast & (input_eth_payload_tkeep[7:2] == 0));
        shift_eth_payload_tuser = (input_eth_payload_tuser & (input_eth_payload_tkeep[7:2] == 0));
        shift_eth_payload_input_tready = ~(input_eth_payload_tlast & input_eth_payload_tvalid & transfer_in_save);
    end
end

always @* begin
    state_next = 2'bz;

    store_eth_hdr = 0;

    write_hdr_data = 0;
    write_hdr_keep = 0;
    write_hdr_last = 0;
    write_hdr_user = 0;
    write_hdr_out = 0;
    write_hdr_temp = 0;

    flush_save = 0;
    transfer_in_save = 0;
    transfer_in_out = 0;
    transfer_in_temp = 0;
    transfer_temp_out = 0;

    frame_ptr_next = frame_ptr_reg;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;
            flush_save = 1;

            if (input_eth_hdr_valid) begin
                store_eth_hdr = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = input_eth_dest_mac[47:40];
                write_hdr_data[15: 8] = input_eth_dest_mac[39:32];
                write_hdr_data[23:16] = input_eth_dest_mac[31:24];
                write_hdr_data[31:24] = input_eth_dest_mac[23:16];
                write_hdr_data[39:32] = input_eth_dest_mac[15: 8];
                write_hdr_data[47:40] = input_eth_dest_mac[ 7: 0];
                write_hdr_data[55:48] = input_eth_src_mac[47:40];
                write_hdr_data[63:56] = input_eth_src_mac[39:32];
                write_hdr_keep = 8'hff;
                frame_ptr_next = 8;
                state_next = STATE_WRITE_HEADER_LAST;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // last header word requires first payload word; process accordingly
            if (shift_eth_payload_tvalid & output_axis_tready) begin
                // word transfer through - update output register
                transfer_in_save = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = eth_src_mac_reg[31:24];
                write_hdr_data[15: 8] = eth_src_mac_reg[23:16];
                write_hdr_data[23:16] = eth_src_mac_reg[15: 8];
                write_hdr_data[31:24] = eth_src_mac_reg[ 7: 0];
                write_hdr_data[39:32] = eth_type_reg[15: 8];
                write_hdr_data[47:40] = eth_type_reg[ 7: 0];
                write_hdr_data[55:48] = shift_eth_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_eth_payload_tdata[63:56];
                write_hdr_keep = {shift_eth_payload_tkeep[7:6], 6'h3F};
                write_hdr_last = shift_eth_payload_tlast;
                write_hdr_user = shift_eth_payload_tuser;
                if (shift_eth_payload_tlast) begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                end
            end else if (~shift_eth_payload_tvalid & output_axis_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_WRITE_HEADER_LAST_WAIT;
            end else if (shift_eth_payload_tvalid & ~output_axis_tready) begin
                // word transfer in - store in temp
                transfer_in_save = 1;
                write_hdr_temp = 1;
                write_hdr_data[ 7: 0] = eth_src_mac_reg[31:24];
                write_hdr_data[15: 8] = eth_src_mac_reg[23:16];
                write_hdr_data[23:16] = eth_src_mac_reg[15: 8];
                write_hdr_data[31:24] = eth_src_mac_reg[ 7: 0];
                write_hdr_data[39:32] = eth_type_reg[15: 8];
                write_hdr_data[47:40] = eth_type_reg[ 7: 0];
                write_hdr_data[55:48] = shift_eth_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_eth_payload_tdata[63:56];
                write_hdr_keep = {shift_eth_payload_tkeep[7:6], 6'h3F};
                write_hdr_last = shift_eth_payload_tlast;
                write_hdr_user = shift_eth_payload_tuser;
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER;
            end
        end
        STATE_WRITE_HEADER_LAST_WAIT: begin
            // last header word requires first payload word; no data in registers
            if (shift_eth_payload_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_save = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = eth_src_mac_reg[31:24];
                write_hdr_data[15: 8] = eth_src_mac_reg[23:16];
                write_hdr_data[23:16] = eth_src_mac_reg[15: 8];
                write_hdr_data[31:24] = eth_src_mac_reg[ 7: 0];
                write_hdr_data[39:32] = eth_type_reg[15: 8];
                write_hdr_data[47:40] = eth_type_reg[ 7: 0];
                write_hdr_data[55:48] = shift_eth_payload_tdata[55:48];
                write_hdr_data[63:56] = shift_eth_payload_tdata[63:56];
                write_hdr_keep = {shift_eth_payload_tkeep[7:6], 6'h3F};
                write_hdr_last = shift_eth_payload_tlast;
                write_hdr_user = shift_eth_payload_tuser;
                if (shift_eth_payload_tlast) begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                end
            end else begin
                state_next = STATE_WRITE_HEADER_LAST_WAIT;
            end
        end
        STATE_WRITE_PAYLOAD_IDLE: begin
            // idle; no data in registers
            if (shift_eth_payload_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                if (shift_eth_payload_tlast) begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_IDLE;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER: begin
            // write payload; data in output register
            if (shift_eth_payload_tvalid & output_axis_tready) begin
                // word transfer through - update output register
                transfer_in_save = 1;
                transfer_in_out = 1;
                if (shift_eth_payload_tlast) begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                end
            end else if (~shift_eth_payload_tvalid & output_axis_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_WRITE_PAYLOAD_IDLE;
            end else if (shift_eth_payload_tvalid & ~output_axis_tready) begin
                // word transfer in - store in temp
                transfer_in_save = 1;
                transfer_in_temp = 1;
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_WAIT: begin
            // write payload; data in both output and temp registers
            if (output_axis_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                if (temp_axis_tlast_reg) begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD_TRANSFER;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_WAIT;
            end
        end
        STATE_WRITE_PAYLOAD_TRANSFER_LAST: begin
            // write last payload word; data in output register; do not accept new data
            if (output_axis_tready) begin
                // word transfer out - done
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_WRITE_PAYLOAD_TRANSFER_LAST;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        input_eth_hdr_ready_reg <= 0;
        input_eth_payload_tready_reg <= 0;
        eth_dest_mac_reg <= 0;
        eth_src_mac_reg <= 0;
        eth_type_reg <= 0;
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tkeep_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
        save_eth_payload_tdata_reg <= 0;
        save_eth_payload_tkeep_reg <= 0;
        save_eth_payload_tlast_reg <= 0;
        save_eth_payload_tuser_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        busy_reg <= state_next != STATE_IDLE;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle; accept new data
                input_eth_hdr_ready_reg <= 1;
                input_eth_payload_tready_reg <= 0;
                output_axis_tvalid_reg <= 0;
            end
            STATE_WRITE_HEADER: begin
                // read header; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_axis_tvalid_reg <= 1;
            end
            STATE_WRITE_HEADER_LAST: begin
                // write last header word; need first data word
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_axis_tvalid_reg <= 1;
            end
            STATE_WRITE_HEADER_LAST_WAIT: begin
                // last header word requires first payload word; no data in registers
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_axis_tvalid_reg <= 0;
            end
            STATE_WRITE_PAYLOAD_IDLE: begin
                // write payload; no data in registers; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_axis_tvalid_reg <= 0;
            end
            STATE_WRITE_PAYLOAD_TRANSFER: begin
                // write payload; data in output register; accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= shift_eth_payload_input_tready;
                output_axis_tvalid_reg <= 1;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_WAIT: begin
                // write payload; data in output and temp registers; do not accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_axis_tvalid_reg <= 1;
            end
            STATE_WRITE_PAYLOAD_TRANSFER_LAST: begin
                // write last payload word; data in output register; do not accept new data
                input_eth_hdr_ready_reg <= 0;
                input_eth_payload_tready_reg <= 0;
                output_axis_tvalid_reg <= 1;
            end
        endcase

        if (store_eth_hdr) begin
            eth_dest_mac_reg <= input_eth_dest_mac;
            eth_src_mac_reg <= input_eth_src_mac;
            eth_type_reg <= input_eth_type;
        end

        if (write_hdr_out) begin
            output_axis_tdata_reg <= write_hdr_data;
            output_axis_tkeep_reg <= write_hdr_keep;
            output_axis_tlast_reg <= write_hdr_last;
            output_axis_tuser_reg <= write_hdr_user;
        end else if (write_hdr_temp) begin
            temp_axis_tdata_reg <= write_hdr_data;
            temp_axis_tkeep_reg <= write_hdr_keep;
            temp_axis_tlast_reg <= write_hdr_last;
            temp_axis_tuser_reg <= write_hdr_user;
        end else if (transfer_in_out) begin
            output_axis_tdata_reg <= shift_eth_payload_tdata;
            output_axis_tkeep_reg <= shift_eth_payload_tkeep;
            output_axis_tlast_reg <= shift_eth_payload_tlast;
            output_axis_tuser_reg <= shift_eth_payload_tuser;
        end else if (transfer_in_temp) begin
            temp_axis_tdata_reg <= shift_eth_payload_tdata;
            temp_axis_tkeep_reg <= shift_eth_payload_tkeep;
            temp_axis_tlast_reg <= shift_eth_payload_tlast;
            temp_axis_tuser_reg <= shift_eth_payload_tuser;
        end else if (transfer_temp_out) begin
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
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
    end
end

endmodule
