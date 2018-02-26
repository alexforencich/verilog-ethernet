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

This module receives an Ethernet frame with header fields in parallel along
with the payload in an AXI stream, combines the header with the payload, and
transmits the complete Ethernet frame on the output AXI stream interface.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_WRITE_HEADER = 3'd1,
    STATE_WRITE_HEADER_LAST = 3'd2,
    STATE_WRITE_PAYLOAD = 3'd3;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_eth_hdr;

reg flush_save;
reg transfer_in_save;

reg [7:0] frame_ptr_reg = 8'd0, frame_ptr_next;

reg [47:0] eth_dest_mac_reg = 48'd0;
reg [47:0] eth_src_mac_reg = 48'd0;
reg [15:0] eth_type_reg = 16'd0;

reg input_eth_hdr_ready_reg = 1'b0, input_eth_hdr_ready_next;
reg input_eth_payload_tready_reg = 1'b0, input_eth_payload_tready_next;

reg busy_reg = 1'b0;

reg [63:0] save_eth_payload_tdata_reg = 64'd0;
reg [7:0] save_eth_payload_tkeep_reg = 8'd0;
reg save_eth_payload_tlast_reg = 1'b0;
reg save_eth_payload_tuser_reg = 1'b0;

reg [63:0] shift_eth_payload_tdata;
reg [7:0] shift_eth_payload_tkeep;
reg shift_eth_payload_tvalid;
reg shift_eth_payload_tlast;
reg shift_eth_payload_tuser;
reg shift_eth_payload_input_tready;
reg shift_eth_payload_extra_cycle;

// internal datapath
reg [63:0] output_axis_tdata_int;
reg [7:0]  output_axis_tkeep_int;
reg        output_axis_tvalid_int;
reg        output_axis_tready_int_reg = 1'b0;
reg        output_axis_tlast_int;
reg        output_axis_tuser_int;
wire       output_axis_tready_int_early;

assign input_eth_hdr_ready = input_eth_hdr_ready_reg;
assign input_eth_payload_tready = input_eth_payload_tready_reg;

assign busy = busy_reg;

always @* begin
    shift_eth_payload_tdata[47:0] = save_eth_payload_tdata_reg[63:16];
    shift_eth_payload_tkeep[5:0] = save_eth_payload_tkeep_reg[7:2];
    shift_eth_payload_extra_cycle = save_eth_payload_tlast_reg & (save_eth_payload_tkeep_reg[7:2] != 0);

    if (shift_eth_payload_extra_cycle) begin
        shift_eth_payload_tdata[63:48] = 16'd0;
        shift_eth_payload_tkeep[7:6] = 2'd0;
        shift_eth_payload_tvalid = 1'b1;
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
    state_next = STATE_IDLE;

    input_eth_hdr_ready_next = 1'b0;
    input_eth_payload_tready_next = 1'b0;

    store_eth_hdr = 1'b0;

    flush_save = 1'b0;
    transfer_in_save = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    output_axis_tdata_int = 64'd0;
    output_axis_tkeep_int = 8'd0;
    output_axis_tvalid_int = 1'b0;
    output_axis_tlast_int = 1'b0;
    output_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 8'd0;
            flush_save = 1'b1;
            input_eth_hdr_ready_next = 1'b1;

            if (input_eth_hdr_ready & input_eth_hdr_valid) begin
                store_eth_hdr = 1'b1;
                input_eth_hdr_ready_next = 1'b0;
                state_next = STATE_WRITE_HEADER;
                if (output_axis_tready_int_reg) begin
                    output_axis_tvalid_int = 1'b1;
                    output_axis_tdata_int[ 7: 0] = input_eth_dest_mac[47:40];
                    output_axis_tdata_int[15: 8] = input_eth_dest_mac[39:32];
                    output_axis_tdata_int[23:16] = input_eth_dest_mac[31:24];
                    output_axis_tdata_int[31:24] = input_eth_dest_mac[23:16];
                    output_axis_tdata_int[39:32] = input_eth_dest_mac[15: 8];
                    output_axis_tdata_int[47:40] = input_eth_dest_mac[ 7: 0];
                    output_axis_tdata_int[55:48] = input_eth_src_mac[47:40];
                    output_axis_tdata_int[63:56] = input_eth_src_mac[39:32];
                    output_axis_tkeep_int = 8'hff;
                    frame_ptr_next = 8'd8;
                    input_eth_payload_tready_next = output_axis_tready_int_early;
                    state_next = STATE_WRITE_HEADER_LAST;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // write header
            if (output_axis_tready_int_reg) begin
                frame_ptr_next = frame_ptr_reg + 8'd8;
                output_axis_tvalid_int = 1'b1;
                state_next = STATE_WRITE_HEADER;
                case (frame_ptr_reg)
                    5'd00: begin
                        output_axis_tdata_int[ 7: 0] = input_eth_dest_mac[47:40];
                        output_axis_tdata_int[15: 8] = input_eth_dest_mac[39:32];
                        output_axis_tdata_int[23:16] = input_eth_dest_mac[31:24];
                        output_axis_tdata_int[31:24] = input_eth_dest_mac[23:16];
                        output_axis_tdata_int[39:32] = input_eth_dest_mac[15: 8];
                        output_axis_tdata_int[47:40] = input_eth_dest_mac[ 7: 0];
                        output_axis_tdata_int[55:48] = input_eth_src_mac[47:40];
                        output_axis_tdata_int[63:56] = input_eth_src_mac[39:32];
                        output_axis_tkeep_int = 8'hff;
                        input_eth_payload_tready_next = output_axis_tready_int_early & shift_eth_payload_input_tready;
                        state_next = STATE_WRITE_HEADER_LAST;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // last header word requires first payload word; process accordingly
            input_eth_payload_tready_next = output_axis_tready_int_early & shift_eth_payload_input_tready;

            if (input_eth_payload_tready & shift_eth_payload_tvalid) begin
                frame_ptr_next = frame_ptr_reg + 8'd8;
                output_axis_tvalid_int = 1'b1;
                transfer_in_save = 1'b1;
                
                output_axis_tdata_int[ 7: 0] = eth_src_mac_reg[31:24];
                output_axis_tdata_int[15: 8] = eth_src_mac_reg[23:16];
                output_axis_tdata_int[23:16] = eth_src_mac_reg[15: 8];
                output_axis_tdata_int[31:24] = eth_src_mac_reg[ 7: 0];
                output_axis_tdata_int[39:32] = eth_type_reg[15: 8];
                output_axis_tdata_int[47:40] = eth_type_reg[ 7: 0];
                output_axis_tdata_int[55:48] = shift_eth_payload_tdata[55:48];
                output_axis_tdata_int[63:56] = shift_eth_payload_tdata[63:56];
                output_axis_tkeep_int = {shift_eth_payload_tkeep[7:6], 6'h3F};
                output_axis_tlast_int = shift_eth_payload_tlast;
                output_axis_tuser_int = shift_eth_payload_tuser;

                if (shift_eth_payload_tlast) begin
                    input_eth_payload_tready_next = 1'b0;
                    flush_save = 1'b1;
                    input_eth_hdr_ready_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD;
                end
            end else begin
                state_next = STATE_WRITE_HEADER_LAST;
            end
        end
        STATE_WRITE_PAYLOAD: begin
            // write payload
            input_eth_payload_tready_next = output_axis_tready_int_early & shift_eth_payload_input_tready;

            output_axis_tdata_int = shift_eth_payload_tdata;
            output_axis_tkeep_int = shift_eth_payload_tkeep;
            output_axis_tvalid_int = shift_eth_payload_tvalid;
            output_axis_tlast_int = shift_eth_payload_tlast;
            output_axis_tuser_int = shift_eth_payload_tuser;

            if (output_axis_tready_int_reg & shift_eth_payload_tvalid) begin
                // word transfer through
                transfer_in_save = 1'b1;
                if (shift_eth_payload_tlast) begin
                    input_eth_payload_tready_next = 1'b0;
                    flush_save = 1'b1;
                    input_eth_hdr_ready_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WRITE_PAYLOAD;
                end
            end else begin
                state_next = STATE_WRITE_PAYLOAD;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 8'd0;
        input_eth_hdr_ready_reg <= 1'b0;
        input_eth_payload_tready_reg <= 1'b0;
        save_eth_payload_tlast_reg <= 1'b0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        input_eth_hdr_ready_reg <= input_eth_hdr_ready_next;

        input_eth_payload_tready_reg <= input_eth_payload_tready_next;

        busy_reg <= state_next != STATE_IDLE;

        // datapath
        if (store_eth_hdr) begin
            eth_dest_mac_reg <= input_eth_dest_mac;
            eth_src_mac_reg <= input_eth_src_mac;
            eth_type_reg <= input_eth_type;
        end

        if (flush_save) begin
            save_eth_payload_tlast_reg <= 1'b0;
        end else if (transfer_in_save) begin
            save_eth_payload_tlast_reg <= input_eth_payload_tlast;
        end
    end

    // datapath
    if (store_eth_hdr) begin
        eth_dest_mac_reg <= input_eth_dest_mac;
        eth_src_mac_reg <= input_eth_src_mac;
        eth_type_reg <= input_eth_type;
    end

    if (transfer_in_save) begin
        save_eth_payload_tdata_reg <= input_eth_payload_tdata;
        save_eth_payload_tkeep_reg <= input_eth_payload_tkeep;
        save_eth_payload_tuser_reg <= input_eth_payload_tuser;
    end
end

// output datapath logic
reg [63:0] output_axis_tdata_reg = 64'd0;
reg [7:0]  output_axis_tkeep_reg = 8'd0;
reg        output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg        output_axis_tlast_reg = 1'b0;
reg        output_axis_tuser_reg = 1'b0;

reg [63:0] temp_axis_tdata_reg = 64'd0;
reg [7:0]  temp_axis_tkeep_reg = 8'd0;
reg        temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg        temp_axis_tlast_reg = 1'b0;
reg        temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & (~output_axis_tvalid_reg | ~output_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_axis_tvalid_next = output_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;
    
    if (output_axis_tready_int_reg) begin
        // input is ready
        if (output_axis_tready | ~output_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (output_axis_tready) begin
        // input is not ready, but output is ready
        output_axis_tvalid_next = temp_axis_tvalid_reg;
        temp_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_axis_tvalid_reg <= 1'b0;
        output_axis_tready_int_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tready_int_reg <= output_axis_tready_int_early;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        output_axis_tdata_reg <= output_axis_tdata_int;
        output_axis_tkeep_reg <= output_axis_tkeep_int;
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tkeep_reg <= temp_axis_tkeep_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tkeep_reg <= output_axis_tkeep_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
