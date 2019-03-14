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
 * ARP ethernet frame transmitter (ARP frame in, Ethernet frame out, 64 bit datapath)
 */
module arp_eth_tx_64
(
    input  wire        clk,
    input  wire        rst,

    /*
     * ARP frame input
     */
    input  wire        s_frame_valid,
    output wire        s_frame_ready,
    input  wire [47:0] s_eth_dest_mac,
    input  wire [47:0] s_eth_src_mac,
    input  wire [15:0] s_eth_type,
    input  wire [15:0] s_arp_htype,
    input  wire [15:0] s_arp_ptype,
    input  wire [15:0] s_arp_oper,
    input  wire [47:0] s_arp_sha,
    input  wire [31:0] s_arp_spa,
    input  wire [47:0] s_arp_tha,
    input  wire [31:0] s_arp_tpa,

    /*
     * Ethernet frame output
     */
    output wire        m_eth_hdr_valid,
    input  wire        m_eth_hdr_ready,
    output wire [47:0] m_eth_dest_mac,
    output wire [47:0] m_eth_src_mac,
    output wire [15:0] m_eth_type,
    output wire [63:0] m_eth_payload_axis_tdata,
    output wire [7:0]  m_eth_payload_axis_tkeep,
    output wire        m_eth_payload_axis_tvalid,
    input  wire        m_eth_payload_axis_tready,
    output wire        m_eth_payload_axis_tlast,
    output wire        m_eth_payload_axis_tuser,

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

This module receives an ARP frame with header fields in parallel  and
transmits the complete Ethernet payload on an AXI interface.

*/

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_WRITE_HEADER = 2'd1;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_frame;

reg [7:0] frame_ptr_reg = 8'd0, frame_ptr_next;

reg [15:0] arp_htype_reg = 16'd0;
reg [15:0] arp_ptype_reg = 16'd0;
reg [15:0] arp_oper_reg = 16'd0;
reg [47:0] arp_sha_reg = 48'd0;
reg [31:0] arp_spa_reg = 32'd0;
reg [47:0] arp_tha_reg = 48'd0;
reg [31:0] arp_tpa_reg = 32'd0;

reg s_frame_ready_reg = 1'b0, s_frame_ready_next;

reg m_eth_hdr_valid_reg = 1'b0, m_eth_hdr_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0;
reg [47:0] m_eth_src_mac_reg = 48'd0;
reg [15:0] m_eth_type_reg = 16'd0;

reg busy_reg = 1'b0;

// internal datapath
reg [63:0] m_eth_payload_axis_tdata_int;
reg [7:0]  m_eth_payload_axis_tkeep_int;
reg        m_eth_payload_axis_tvalid_int;
reg        m_eth_payload_axis_tready_int_reg = 1'b0;
reg        m_eth_payload_axis_tlast_int;
reg        m_eth_payload_axis_tuser_int;
wire       m_eth_payload_axis_tready_int_early;

assign s_frame_ready = s_frame_ready_reg;

assign m_eth_hdr_valid = m_eth_hdr_valid_reg;
assign m_eth_dest_mac = m_eth_dest_mac_reg;
assign m_eth_src_mac = m_eth_src_mac_reg;
assign m_eth_type = m_eth_type_reg;

assign busy = busy_reg;

always @* begin
    state_next = STATE_IDLE;

    s_frame_ready_next = 1'b0;

    store_frame = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    m_eth_hdr_valid_next = m_eth_hdr_valid_reg && !m_eth_hdr_ready;

    m_eth_payload_axis_tdata_int = 64'd0;
    m_eth_payload_axis_tkeep_int = 8'd0;
    m_eth_payload_axis_tvalid_int = 1'b0;
    m_eth_payload_axis_tlast_int = 1'b0;
    m_eth_payload_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 8'd0;
            s_frame_ready_next = !m_eth_hdr_valid_next;

            if (s_frame_ready && s_frame_valid) begin
                store_frame = 1'b1;
                s_frame_ready_next = 1'b0;
                m_eth_hdr_valid_next = 1'b1;
                if (m_eth_payload_axis_tready_int_reg) begin
                    m_eth_payload_axis_tvalid_int = 1'b1;
                    m_eth_payload_axis_tdata_int[ 7: 0] = s_arp_htype[15: 8];
                    m_eth_payload_axis_tdata_int[15: 8] = s_arp_htype[ 7: 0];
                    m_eth_payload_axis_tdata_int[23:16] = s_arp_ptype[15: 8];
                    m_eth_payload_axis_tdata_int[31:24] = s_arp_ptype[ 7: 0];
                    m_eth_payload_axis_tdata_int[39:32] = 8'd6; // hlen
                    m_eth_payload_axis_tdata_int[47:40] = 8'd4; // plen
                    m_eth_payload_axis_tdata_int[55:48] = s_arp_oper[15: 8];
                    m_eth_payload_axis_tdata_int[63:56] = s_arp_oper[ 7: 0];
                    m_eth_payload_axis_tkeep_int = 8'hff;
                    frame_ptr_next = 8'd8;
                end
                state_next = STATE_WRITE_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // read header state
            if (m_eth_payload_axis_tready_int_reg) begin
                // word transfer out
                frame_ptr_next = frame_ptr_reg + 8'd8;
                m_eth_payload_axis_tvalid_int = 1'b1;
                state_next = STATE_WRITE_HEADER;
                case (frame_ptr_reg)
                    8'h00: begin
                        m_eth_payload_axis_tdata_int[ 7: 0] = arp_htype_reg[15: 8];
                        m_eth_payload_axis_tdata_int[15: 8] = arp_htype_reg[ 7: 0];
                        m_eth_payload_axis_tdata_int[23:16] = arp_ptype_reg[15: 8];
                        m_eth_payload_axis_tdata_int[31:24] = arp_ptype_reg[ 7: 0];
                        m_eth_payload_axis_tdata_int[39:32] = 8'd6; // hlen
                        m_eth_payload_axis_tdata_int[47:40] = 8'd4; // plen
                        m_eth_payload_axis_tdata_int[55:48] = arp_oper_reg[15: 8];
                        m_eth_payload_axis_tdata_int[63:56] = arp_oper_reg[ 7: 0];
                        m_eth_payload_axis_tkeep_int = 8'hff;
                    end
                    8'h08: begin
                        m_eth_payload_axis_tdata_int[ 7: 0] = arp_sha_reg[47:40];
                        m_eth_payload_axis_tdata_int[15: 8] = arp_sha_reg[39:32];
                        m_eth_payload_axis_tdata_int[23:16] = arp_sha_reg[31:24];
                        m_eth_payload_axis_tdata_int[31:24] = arp_sha_reg[23:16];
                        m_eth_payload_axis_tdata_int[39:32] = arp_sha_reg[15: 8];
                        m_eth_payload_axis_tdata_int[47:40] = arp_sha_reg[ 7: 0];
                        m_eth_payload_axis_tdata_int[55:48] = arp_spa_reg[31:24];
                        m_eth_payload_axis_tdata_int[63:56] = arp_spa_reg[23:16];
                        m_eth_payload_axis_tkeep_int = 8'hff;
                    end
                    8'h10: begin
                        m_eth_payload_axis_tdata_int[ 7: 0] = arp_spa_reg[15: 8];
                        m_eth_payload_axis_tdata_int[15: 8] = arp_spa_reg[ 7: 0];
                        m_eth_payload_axis_tdata_int[23:16] = arp_tha_reg[47:40];
                        m_eth_payload_axis_tdata_int[31:24] = arp_tha_reg[39:32];
                        m_eth_payload_axis_tdata_int[39:32] = arp_tha_reg[31:24];
                        m_eth_payload_axis_tdata_int[47:40] = arp_tha_reg[23:16];
                        m_eth_payload_axis_tdata_int[55:48] = arp_tha_reg[15: 8];
                        m_eth_payload_axis_tdata_int[63:56] = arp_tha_reg[ 7: 0];
                        m_eth_payload_axis_tkeep_int = 8'hff;
                    end
                    8'h18: begin
                        m_eth_payload_axis_tdata_int[ 7: 0] = arp_tpa_reg[31:24];
                        m_eth_payload_axis_tdata_int[15: 8] = arp_tpa_reg[23:16];
                        m_eth_payload_axis_tdata_int[23:16] = arp_tpa_reg[15: 8];
                        m_eth_payload_axis_tdata_int[31:24] = arp_tpa_reg[ 7: 0];
                        m_eth_payload_axis_tdata_int[39:32] = 0;
                        m_eth_payload_axis_tdata_int[47:40] = 0;
                        m_eth_payload_axis_tdata_int[55:48] = 0;
                        m_eth_payload_axis_tdata_int[63:56] = 0;
                        m_eth_payload_axis_tkeep_int = 8'h0f;
                        m_eth_payload_axis_tlast_int = 1'b1;
                        s_frame_ready_next = !m_eth_hdr_valid_next;
                        state_next = STATE_IDLE;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 8'd0;
        s_frame_ready_reg <= 1'b0;
        m_eth_hdr_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        s_frame_ready_reg <= s_frame_ready_next;

        m_eth_hdr_valid_reg <= m_eth_hdr_valid_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    if (store_frame) begin
        m_eth_dest_mac_reg <= s_eth_dest_mac;
        m_eth_src_mac_reg <= s_eth_src_mac;
        m_eth_type_reg <= s_eth_type;
        arp_htype_reg <= s_arp_htype;
        arp_ptype_reg <= s_arp_ptype;
        arp_oper_reg <= s_arp_oper;
        arp_sha_reg <= s_arp_sha;
        arp_spa_reg <= s_arp_spa;
        arp_tha_reg <= s_arp_tha;
        arp_tpa_reg <= s_arp_tpa;
    end
end

// output datapath logic
reg [63:0] m_eth_payload_axis_tdata_reg = 64'd0;
reg [7:0]  m_eth_payload_axis_tkeep_reg = 8'd0;
reg        m_eth_payload_axis_tvalid_reg = 1'b0, m_eth_payload_axis_tvalid_next;
reg        m_eth_payload_axis_tlast_reg = 1'b0;
reg        m_eth_payload_axis_tuser_reg = 1'b0;

reg [63:0] temp_m_eth_payload_axis_tdata_reg = 64'd0;
reg [7:0]  temp_m_eth_payload_axis_tkeep_reg = 8'd0;
reg        temp_m_eth_payload_axis_tvalid_reg = 1'b0, temp_m_eth_payload_axis_tvalid_next;
reg        temp_m_eth_payload_axis_tlast_reg = 1'b0;
reg        temp_m_eth_payload_axis_tuser_reg = 1'b0;

// datapath control
reg store_eth_payload_int_to_output;
reg store_eth_payload_int_to_temp;
reg store_eth_payload_axis_temp_to_output;

assign m_eth_payload_axis_tdata = m_eth_payload_axis_tdata_reg;
assign m_eth_payload_axis_tkeep = m_eth_payload_axis_tkeep_reg;
assign m_eth_payload_axis_tvalid = m_eth_payload_axis_tvalid_reg;
assign m_eth_payload_axis_tlast = m_eth_payload_axis_tlast_reg;
assign m_eth_payload_axis_tuser = m_eth_payload_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_eth_payload_axis_tready_int_early = m_eth_payload_axis_tready || (!temp_m_eth_payload_axis_tvalid_reg && (!m_eth_payload_axis_tvalid_reg || !m_eth_payload_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_reg;
    temp_m_eth_payload_axis_tvalid_next = temp_m_eth_payload_axis_tvalid_reg;

    store_eth_payload_int_to_output = 1'b0;
    store_eth_payload_int_to_temp = 1'b0;
    store_eth_payload_axis_temp_to_output = 1'b0;
    
    if (m_eth_payload_axis_tready_int_reg) begin
        // input is ready
        if (m_eth_payload_axis_tready || !m_eth_payload_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_int;
            store_eth_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_eth_payload_axis_tvalid_next = m_eth_payload_axis_tvalid_int;
            store_eth_payload_int_to_temp = 1'b1;
        end
    end else if (m_eth_payload_axis_tready) begin
        // input is not ready, but output is ready
        m_eth_payload_axis_tvalid_next = temp_m_eth_payload_axis_tvalid_reg;
        temp_m_eth_payload_axis_tvalid_next = 1'b0;
        store_eth_payload_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_eth_payload_axis_tvalid_reg <= 1'b0;
        m_eth_payload_axis_tready_int_reg <= 1'b0;
        temp_m_eth_payload_axis_tvalid_reg <= 1'b0;
    end else begin
        m_eth_payload_axis_tvalid_reg <= m_eth_payload_axis_tvalid_next;
        m_eth_payload_axis_tready_int_reg <= m_eth_payload_axis_tready_int_early;
        temp_m_eth_payload_axis_tvalid_reg <= temp_m_eth_payload_axis_tvalid_next;
    end

    // datapath
    if (store_eth_payload_int_to_output) begin
        m_eth_payload_axis_tdata_reg <= m_eth_payload_axis_tdata_int;
        m_eth_payload_axis_tkeep_reg <= m_eth_payload_axis_tkeep_int;
        m_eth_payload_axis_tlast_reg <= m_eth_payload_axis_tlast_int;
        m_eth_payload_axis_tuser_reg <= m_eth_payload_axis_tuser_int;
    end else if (store_eth_payload_axis_temp_to_output) begin
        m_eth_payload_axis_tdata_reg <= temp_m_eth_payload_axis_tdata_reg;
        m_eth_payload_axis_tkeep_reg <= temp_m_eth_payload_axis_tkeep_reg;
        m_eth_payload_axis_tlast_reg <= temp_m_eth_payload_axis_tlast_reg;
        m_eth_payload_axis_tuser_reg <= temp_m_eth_payload_axis_tuser_reg;
    end

    if (store_eth_payload_int_to_temp) begin
        temp_m_eth_payload_axis_tdata_reg <= m_eth_payload_axis_tdata_int;
        temp_m_eth_payload_axis_tkeep_reg <= m_eth_payload_axis_tkeep_int;
        temp_m_eth_payload_axis_tlast_reg <= m_eth_payload_axis_tlast_int;
        temp_m_eth_payload_axis_tuser_reg <= m_eth_payload_axis_tuser_int;
    end
end

endmodule
