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

This module receives an Ethernet frame on an AXI stream interface, decodes
and strips the headers, then produces the header fields in parallel along
with the payload in a separate AXI stream.

*/

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_READ_HEADER = 2'd1,
    STATE_READ_PAYLOAD = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

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

reg [7:0] frame_ptr_reg = 8'd0, frame_ptr_next;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

reg output_eth_hdr_valid_reg = 1'b0, output_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 48'd0;
reg [47:0] output_eth_src_mac_reg = 48'd0;
reg [15:0] output_eth_type_reg = 16'd0;

reg busy_reg = 1'b0;
reg error_header_early_termination_reg = 1'b0, error_header_early_termination_next;

// internal datapath
reg [7:0] output_eth_payload_tdata_int;
reg       output_eth_payload_tvalid_int;
reg       output_eth_payload_tready_int_reg = 1'b0;
reg       output_eth_payload_tlast_int;
reg       output_eth_payload_tuser_int;
wire      output_eth_payload_tready_int_early;

assign input_axis_tready = input_axis_tready_reg;

assign output_eth_hdr_valid = output_eth_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;

assign busy = busy_reg;
assign error_header_early_termination = error_header_early_termination_reg;

always @* begin
    state_next = STATE_IDLE;

    input_axis_tready_next = 1'b0;

    store_eth_dest_mac_0 = 1'b0;
    store_eth_dest_mac_1 = 1'b0;
    store_eth_dest_mac_2 = 1'b0;
    store_eth_dest_mac_3 = 1'b0;
    store_eth_dest_mac_4 = 1'b0;
    store_eth_dest_mac_5 = 1'b0;
    store_eth_src_mac_0 = 1'b0;
    store_eth_src_mac_1 = 1'b0;
    store_eth_src_mac_2 = 1'b0;
    store_eth_src_mac_3 = 1'b0;
    store_eth_src_mac_4 = 1'b0;
    store_eth_src_mac_5 = 1'b0;
    store_eth_type_0 = 1'b0;
    store_eth_type_1 = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;

    error_header_early_termination_next = 1'b0;

    output_eth_payload_tdata_int = 8'd0;
    output_eth_payload_tvalid_int = 1'b0;
    output_eth_payload_tlast_int = 1'b0;
    output_eth_payload_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 8'd0;
            input_axis_tready_next = ~output_eth_hdr_valid_reg;

            if (input_axis_tready & input_axis_tvalid) begin
                // got first word of packet
                if (input_axis_tlast) begin
                    // tlast asserted on first word
                    error_header_early_termination_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    // move to read header state
                    frame_ptr_next = 1'b1;
                    store_eth_dest_mac_5 = 1'b1;
                    state_next = STATE_READ_HEADER;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_READ_HEADER: begin
            // read header
            input_axis_tready_next = 1'b1;

            if (input_axis_tready & input_axis_tvalid) begin
                // word transfer in - store it
                frame_ptr_next = frame_ptr_reg + 8'd1;
                state_next = STATE_READ_HEADER;
                case (frame_ptr_reg)
                    8'h00: store_eth_dest_mac_5 = 1'b1;
                    8'h01: store_eth_dest_mac_4 = 1'b1;
                    8'h02: store_eth_dest_mac_3 = 1'b1;
                    8'h03: store_eth_dest_mac_2 = 1'b1;
                    8'h04: store_eth_dest_mac_1 = 1'b1;
                    8'h05: store_eth_dest_mac_0 = 1'b1;
                    8'h06: store_eth_src_mac_5 = 1'b1;
                    8'h07: store_eth_src_mac_4 = 1'b1;
                    8'h08: store_eth_src_mac_3 = 1'b1;
                    8'h09: store_eth_src_mac_2 = 1'b1;
                    8'h0A: store_eth_src_mac_1 = 1'b1;
                    8'h0B: store_eth_src_mac_0 = 1'b1;
                    8'h0C: store_eth_type_1 = 1'b1;
                    8'h0D: begin
                        store_eth_type_0 = 1'b1;
                        output_eth_hdr_valid_next = 1'b1;
                        input_axis_tready_next = output_eth_payload_tready_int_early;
                        state_next = STATE_READ_PAYLOAD;
                    end
                endcase
                if (input_axis_tlast) begin
                    error_header_early_termination_next = 1'b1;
                    input_axis_tready_next = ~output_eth_hdr_valid_reg;
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_READ_HEADER;
            end
        end
        STATE_READ_PAYLOAD: begin
            // read payload
            input_axis_tready_next = output_eth_payload_tready_int_early;

            output_eth_payload_tdata_int = input_axis_tdata;
            output_eth_payload_tvalid_int = input_axis_tvalid;
            output_eth_payload_tlast_int = input_axis_tlast;
            output_eth_payload_tuser_int = input_axis_tuser;

            if (input_axis_tready & input_axis_tvalid) begin
                // word transfer through
                if (input_axis_tlast) begin
                    input_axis_tready_next = ~output_eth_hdr_valid_reg;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_READ_PAYLOAD;
                end
            end else begin
                state_next = STATE_READ_PAYLOAD;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 8'd0;
        input_axis_tready_reg <= 1'b0;
        output_eth_hdr_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
        error_header_early_termination_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        input_axis_tready_reg <= input_axis_tready_next;

        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;

        error_header_early_termination_reg <= error_header_early_termination_next;

        busy_reg <= state_next != STATE_IDLE;
    end

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
end

// output datapath logic
reg [7:0] output_eth_payload_tdata_reg = 8'd0;
reg       output_eth_payload_tvalid_reg = 1'b0, output_eth_payload_tvalid_next;
reg       output_eth_payload_tlast_reg = 1'b0;
reg       output_eth_payload_tuser_reg = 1'b0;

reg [7:0] temp_eth_payload_tdata_reg = 8'd0;
reg       temp_eth_payload_tvalid_reg = 1'b0, temp_eth_payload_tvalid_next;
reg       temp_eth_payload_tlast_reg = 1'b0;
reg       temp_eth_payload_tuser_reg = 1'b0;

// datapath control
reg store_eth_payload_int_to_output;
reg store_eth_payload_int_to_temp;
reg store_eth_payload_temp_to_output;

assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
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
        output_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        output_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end else if (store_eth_payload_temp_to_output) begin
        output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
        output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
        output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
    end

    if (store_eth_payload_int_to_temp) begin
        temp_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        temp_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        temp_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end
end

endmodule
