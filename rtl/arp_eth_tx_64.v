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
 * ARP ethernet frame transmitter (ARP frame in, Ethernet frame out, 64 bit datapath)
 */
module arp_eth_tx_64
(
    input  wire        clk,
    input  wire        rst,

    /*
     * ARP frame input
     */
    input  wire        input_frame_valid,
    output wire        input_frame_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [15:0] input_arp_htype,
    input  wire [15:0] input_arp_ptype,
    input  wire [7:0]  input_arp_hlen,
    input  wire [7:0]  input_arp_plen,
    input  wire [15:0] input_arp_oper,
    input  wire [47:0] input_arp_sha,
    input  wire [31:0] input_arp_spa,
    input  wire [47:0] input_arp_tha,
    input  wire [31:0] input_arp_tpa,

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
    output wire        busy
);

/*

ARP Frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0806)          2 octets
 HTYPE (1)                   2 octets
 PTYPE (0x0800)              2 octets
 HLEN (6)                    1 octets
 PLEN (4)                    1 octets
 OPER                        2 octets
 SHA Sender MAC              6 octets
 SPA Sender IP               4 octets
 THA Target MAC              6 octets
 TPA Target IP               4 octets

This module receives an Ethernet frame with decoded fields and decodes
the ARP packet format.  If the Ethertype does not match, the packet is
discarded.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_WRITE_HEADER = 3'd1,
    STATE_WRITE_HEADER_LAST = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_frame;

reg [63:0] write_hdr_data;
reg [7:0] write_hdr_keep;
reg write_hdr_last;
reg write_hdr_out;

reg [7:0] frame_ptr_reg = 0, frame_ptr_next;

reg [47:0] output_eth_dest_mac_reg = 0;
reg [47:0] output_eth_src_mac_reg = 0;
reg [15:0] output_eth_type_reg = 0;
reg [15:0] arp_htype_reg = 0;
reg [15:0] arp_ptype_reg = 0;
reg [7:0]  arp_hlen_reg = 0;
reg [7:0]  arp_plen_reg = 0;
reg [15:0] arp_oper_reg = 0;
reg [47:0] arp_sha_reg = 0;
reg [31:0] arp_spa_reg = 0;
reg [47:0] arp_tha_reg = 0;
reg [31:0] arp_tpa_reg = 0;

reg input_frame_ready_reg = 0;

reg output_eth_hdr_valid_reg = 0, output_eth_hdr_valid_next;
reg [63:0] output_eth_payload_tdata_reg = 0;
reg [7:0] output_eth_payload_tkeep_reg = 0;
reg output_eth_payload_tvalid_reg = 0;
reg output_eth_payload_tlast_reg = 0;
reg output_eth_payload_tuser_reg = 0;

reg busy_reg = 0;

assign input_frame_ready = input_frame_ready_reg;

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

always @* begin
    state_next = 2'bz;

    store_frame = 0;

    write_hdr_data = 0;
    write_hdr_keep = 0;
    write_hdr_last = 0;
    write_hdr_out = 0;

    frame_ptr_next = frame_ptr_reg;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;

            if (input_frame_valid) begin
                store_frame = 1;
                write_hdr_out = 1;
                write_hdr_data[ 7: 0] = input_arp_htype[15: 8];
                write_hdr_data[15: 8] = input_arp_htype[ 7: 0];
                write_hdr_data[23:16] = input_arp_ptype[15: 8];
                write_hdr_data[31:24] = input_arp_ptype[ 7: 0];
                write_hdr_data[39:32] = input_arp_hlen;
                write_hdr_data[47:40] = input_arp_plen;
                write_hdr_data[55:48] = input_arp_oper[15: 8];
                write_hdr_data[63:56] = input_arp_oper[ 7: 0];
                write_hdr_keep = 8'hff;
                frame_ptr_next = 8;
                output_eth_hdr_valid_next = 1;
                state_next = STATE_WRITE_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // read header state
            if (output_eth_payload_tready) begin
                // word transfer out
                frame_ptr_next = frame_ptr_reg+8;
                state_next = STATE_WRITE_HEADER;
                write_hdr_out = 1;
                case (frame_ptr_reg)
                    8'h08: begin
                        write_hdr_data[ 7: 0] = arp_sha_reg[47:40];
                        write_hdr_data[15: 8] = arp_sha_reg[39:32];
                        write_hdr_data[23:16] = arp_sha_reg[31:24];
                        write_hdr_data[31:24] = arp_sha_reg[23:16];
                        write_hdr_data[39:32] = arp_sha_reg[15: 8];
                        write_hdr_data[47:40] = arp_sha_reg[ 7: 0];
                        write_hdr_data[55:48] = arp_spa_reg[31:24];
                        write_hdr_data[63:56] = arp_spa_reg[23:16];
                        write_hdr_keep = 8'hff;
                    end
                    8'h10: begin
                        write_hdr_data[ 7: 0] = arp_spa_reg[15: 8];
                        write_hdr_data[15: 8] = arp_spa_reg[ 7: 0];
                        write_hdr_data[23:16] = arp_tha_reg[47:40];
                        write_hdr_data[31:24] = arp_tha_reg[39:32];
                        write_hdr_data[39:32] = arp_tha_reg[31:24];
                        write_hdr_data[47:40] = arp_tha_reg[23:16];
                        write_hdr_data[55:48] = arp_tha_reg[15: 8];
                        write_hdr_data[63:56] = arp_tha_reg[ 7: 0];
                        write_hdr_keep = 8'hff;
                    end
                    8'h18: begin
                        write_hdr_data[ 7: 0] = arp_tpa_reg[31:24];
                        write_hdr_data[15: 8] = arp_tpa_reg[23:16];
                        write_hdr_data[23:16] = arp_tpa_reg[15: 8];
                        write_hdr_data[31:24] = arp_tpa_reg[ 7: 0];
                        write_hdr_data[39:32] = 0;
                        write_hdr_data[47:40] = 0;
                        write_hdr_data[55:48] = 0;
                        write_hdr_data[63:56] = 0;
                        write_hdr_keep = 8'h0f;
                        write_hdr_last = 1;
                        state_next = STATE_WRITE_HEADER_LAST;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // write last header word; data in output register
            if (output_eth_payload_tready) begin
                // word transfer out - done
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_WRITE_HEADER_LAST;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        input_frame_ready_reg <= 0;
        output_eth_dest_mac_reg <= 0;
        output_eth_src_mac_reg <= 0;
        output_eth_type_reg <= 0;
        arp_htype_reg <= 0;
        arp_ptype_reg <= 0;
        arp_hlen_reg <= 0;
        arp_plen_reg <= 0;
        arp_oper_reg <= 0;
        arp_sha_reg <= 0;
        arp_spa_reg <= 0;
        arp_tha_reg <= 0;
        arp_tpa_reg <= 0;
        output_eth_payload_tdata_reg <= 0;
        output_eth_payload_tkeep_reg <= 0;
        output_eth_payload_tvalid_reg <= 0;
        output_eth_payload_tlast_reg <= 0;
        output_eth_payload_tuser_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;

        busy_reg <= state_next != STATE_IDLE;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle; accept new data
                input_frame_ready_reg <= ~output_eth_hdr_valid;
                output_eth_payload_tvalid_reg <= 0;
            end
            STATE_WRITE_HEADER: begin
                // write header
                input_frame_ready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
            STATE_WRITE_HEADER_LAST: begin
                // write last header word; data in output register
                input_frame_ready_reg <= 0;
                output_eth_payload_tvalid_reg <= 1;
            end
        endcase

        if (store_frame) begin
            output_eth_dest_mac_reg <= input_eth_dest_mac;
            output_eth_src_mac_reg <= input_eth_src_mac;
            output_eth_type_reg <= input_eth_type;
            arp_htype_reg <= input_arp_htype;
            arp_ptype_reg <= input_arp_ptype;
            arp_hlen_reg <= input_arp_hlen;
            arp_plen_reg <= input_arp_plen;
            arp_oper_reg <= input_arp_oper;
            arp_sha_reg <= input_arp_sha;
            arp_spa_reg <= input_arp_spa;
            arp_tha_reg <= input_arp_tha;
            arp_tpa_reg <= input_arp_tpa;
        end

        if (write_hdr_out) begin
            output_eth_payload_tdata_reg <= write_hdr_data;
            output_eth_payload_tkeep_reg <= write_hdr_keep;
            output_eth_payload_tlast_reg <= write_hdr_last;
            output_eth_payload_tuser_reg <= 0;
        end
    end
end

endmodule
