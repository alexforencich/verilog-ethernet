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
    input  wire        s_eth_hdr_valid,
    output wire        s_eth_hdr_ready,
    input  wire [47:0] s_eth_dest_mac,
    input  wire [47:0] s_eth_src_mac,
    input  wire [15:0] s_eth_type,
    input  wire [63:0] s_eth_payload_axis_tdata,
    input  wire [7:0]  s_eth_payload_axis_tkeep,
    input  wire        s_eth_payload_axis_tvalid,
    output wire        s_eth_payload_axis_tready,
    input  wire        s_eth_payload_axis_tlast,
    input  wire        s_eth_payload_axis_tuser,

    /*
     * AXI output
     */
    output wire [63:0] m_axis_tdata,
    output wire [7:0]  m_axis_tkeep,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast,
    output wire        m_axis_tuser,

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

reg s_eth_hdr_ready_reg = 1'b0, s_eth_hdr_ready_next;
reg s_eth_payload_axis_tready_reg = 1'b0, s_eth_payload_axis_tready_next;

reg busy_reg = 1'b0;

reg [63:0] save_eth_payload_axis_tdata_reg = 64'd0;
reg [7:0] save_eth_payload_axis_tkeep_reg = 8'd0;
reg save_eth_payload_axis_tlast_reg = 1'b0;
reg save_eth_payload_axis_tuser_reg = 1'b0;

reg [63:0] shift_eth_payload_axis_tdata;
reg [7:0] shift_eth_payload_axis_tkeep;
reg shift_eth_payload_axis_tvalid;
reg shift_eth_payload_axis_tlast;
reg shift_eth_payload_axis_tuser;
reg shift_eth_payload_s_tready;
reg shift_eth_payload_extra_cycle_reg = 1'b0;

// internal datapath
reg [63:0] m_axis_tdata_int;
reg [7:0]  m_axis_tkeep_int;
reg        m_axis_tvalid_int;
reg        m_axis_tready_int_reg = 1'b0;
reg        m_axis_tlast_int;
reg        m_axis_tuser_int;
wire       m_axis_tready_int_early;

assign s_eth_hdr_ready = s_eth_hdr_ready_reg;
assign s_eth_payload_axis_tready = s_eth_payload_axis_tready_reg;

assign busy = busy_reg;

always @* begin
    shift_eth_payload_axis_tdata[47:0] = save_eth_payload_axis_tdata_reg[63:16];
    shift_eth_payload_axis_tkeep[5:0] = save_eth_payload_axis_tkeep_reg[7:2];

    if (shift_eth_payload_extra_cycle_reg) begin
        shift_eth_payload_axis_tdata[63:48] = 16'd0;
        shift_eth_payload_axis_tkeep[7:6] = 2'd0;
        shift_eth_payload_axis_tvalid = 1'b1;
        shift_eth_payload_axis_tlast = save_eth_payload_axis_tlast_reg;
        shift_eth_payload_axis_tuser = save_eth_payload_axis_tuser_reg;
        shift_eth_payload_s_tready = flush_save;
    end else begin
        shift_eth_payload_axis_tdata[63:48] = s_eth_payload_axis_tdata[15:0];
        shift_eth_payload_axis_tkeep[7:6] = s_eth_payload_axis_tkeep[1:0];
        shift_eth_payload_axis_tvalid = s_eth_payload_axis_tvalid;
        shift_eth_payload_axis_tlast = (s_eth_payload_axis_tlast && (s_eth_payload_axis_tkeep[7:2] == 0));
        shift_eth_payload_axis_tuser = (s_eth_payload_axis_tuser && (s_eth_payload_axis_tkeep[7:2] == 0));
        shift_eth_payload_s_tready = !(s_eth_payload_axis_tlast && s_eth_payload_axis_tvalid && transfer_in_save);
    end
end

always @* begin
    state_next = STATE_IDLE;

    s_eth_hdr_ready_next = 1'b0;
    s_eth_payload_axis_tready_next = 1'b0;

    store_eth_hdr = 1'b0;

    flush_save = 1'b0;
    transfer_in_save = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    m_axis_tdata_int = 64'd0;
    m_axis_tkeep_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 8'd0;
            flush_save = 1'b1;
            s_eth_hdr_ready_next = 1'b1;

            if (s_eth_hdr_ready && s_eth_hdr_valid) begin
                store_eth_hdr = 1'b1;
                s_eth_hdr_ready_next = 1'b0;
                state_next = STATE_WRITE_HEADER;
                if (m_axis_tready_int_reg) begin
                    m_axis_tvalid_int = 1'b1;
                    m_axis_tdata_int[ 7: 0] = s_eth_dest_mac[47:40];
                    m_axis_tdata_int[15: 8] = s_eth_dest_mac[39:32];
                    m_axis_tdata_int[23:16] = s_eth_dest_mac[31:24];
                    m_axis_tdata_int[31:24] = s_eth_dest_mac[23:16];
                    m_axis_tdata_int[39:32] = s_eth_dest_mac[15: 8];
                    m_axis_tdata_int[47:40] = s_eth_dest_mac[ 7: 0];
                    m_axis_tdata_int[55:48] = s_eth_src_mac[47:40];
                    m_axis_tdata_int[63:56] = s_eth_src_mac[39:32];
                    m_axis_tkeep_int = 8'hff;
                    frame_ptr_next = 8'd8;
                    s_eth_payload_axis_tready_next = m_axis_tready_int_early;
                    state_next = STATE_WRITE_HEADER_LAST;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_HEADER: begin
            // write header
            if (m_axis_tready_int_reg) begin
                frame_ptr_next = frame_ptr_reg + 8'd8;
                m_axis_tvalid_int = 1'b1;
                state_next = STATE_WRITE_HEADER;
                case (frame_ptr_reg)
                    5'd00: begin
                        m_axis_tdata_int[ 7: 0] = eth_dest_mac_reg[47:40];
                        m_axis_tdata_int[15: 8] = eth_dest_mac_reg[39:32];
                        m_axis_tdata_int[23:16] = eth_dest_mac_reg[31:24];
                        m_axis_tdata_int[31:24] = eth_dest_mac_reg[23:16];
                        m_axis_tdata_int[39:32] = eth_dest_mac_reg[15: 8];
                        m_axis_tdata_int[47:40] = eth_dest_mac_reg[ 7: 0];
                        m_axis_tdata_int[55:48] = eth_src_mac_reg[47:40];
                        m_axis_tdata_int[63:56] = eth_src_mac_reg[39:32];
                        m_axis_tkeep_int = 8'hff;
                        s_eth_payload_axis_tready_next = m_axis_tready_int_early && shift_eth_payload_s_tready;
                        state_next = STATE_WRITE_HEADER_LAST;
                    end
                endcase
            end else begin
                state_next = STATE_WRITE_HEADER;
            end
        end
        STATE_WRITE_HEADER_LAST: begin
            // last header word requires first payload word; process accordingly
            s_eth_payload_axis_tready_next = m_axis_tready_int_early && shift_eth_payload_s_tready;

            if (s_eth_payload_axis_tready && shift_eth_payload_axis_tvalid) begin
                frame_ptr_next = frame_ptr_reg + 8'd8;
                m_axis_tvalid_int = 1'b1;
                transfer_in_save = 1'b1;
                
                m_axis_tdata_int[ 7: 0] = eth_src_mac_reg[31:24];
                m_axis_tdata_int[15: 8] = eth_src_mac_reg[23:16];
                m_axis_tdata_int[23:16] = eth_src_mac_reg[15: 8];
                m_axis_tdata_int[31:24] = eth_src_mac_reg[ 7: 0];
                m_axis_tdata_int[39:32] = eth_type_reg[15: 8];
                m_axis_tdata_int[47:40] = eth_type_reg[ 7: 0];
                m_axis_tdata_int[55:48] = shift_eth_payload_axis_tdata[55:48];
                m_axis_tdata_int[63:56] = shift_eth_payload_axis_tdata[63:56];
                m_axis_tkeep_int = {shift_eth_payload_axis_tkeep[7:6], 6'h3F};
                m_axis_tlast_int = shift_eth_payload_axis_tlast;
                m_axis_tuser_int = shift_eth_payload_axis_tuser;

                if (shift_eth_payload_axis_tlast) begin
                    s_eth_payload_axis_tready_next = 1'b0;
                    flush_save = 1'b1;
                    s_eth_hdr_ready_next = 1'b1;
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
            s_eth_payload_axis_tready_next = m_axis_tready_int_early && shift_eth_payload_s_tready;

            m_axis_tdata_int = shift_eth_payload_axis_tdata;
            m_axis_tkeep_int = shift_eth_payload_axis_tkeep;
            m_axis_tvalid_int = shift_eth_payload_axis_tvalid;
            m_axis_tlast_int = shift_eth_payload_axis_tlast;
            m_axis_tuser_int = shift_eth_payload_axis_tuser;

            if (m_axis_tready_int_reg && shift_eth_payload_axis_tvalid) begin
                // word transfer through
                transfer_in_save = 1'b1;
                if (shift_eth_payload_axis_tlast) begin
                    s_eth_payload_axis_tready_next = 1'b0;
                    flush_save = 1'b1;
                    s_eth_hdr_ready_next = 1'b1;
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
        s_eth_hdr_ready_reg <= 1'b0;
        s_eth_payload_axis_tready_reg <= 1'b0;
        save_eth_payload_axis_tlast_reg <= 1'b0;
        shift_eth_payload_extra_cycle_reg <= 1'b0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;

        s_eth_payload_axis_tready_reg <= s_eth_payload_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;

        // datapath
        if (store_eth_hdr) begin
            eth_dest_mac_reg <= s_eth_dest_mac;
            eth_src_mac_reg <= s_eth_src_mac;
            eth_type_reg <= s_eth_type;
        end

        if (flush_save) begin
            save_eth_payload_axis_tlast_reg <= 1'b0;
            shift_eth_payload_extra_cycle_reg <= 1'b0;
        end else if (transfer_in_save) begin
            save_eth_payload_axis_tlast_reg <= s_eth_payload_axis_tlast;
            shift_eth_payload_extra_cycle_reg <= s_eth_payload_axis_tlast && (s_eth_payload_axis_tkeep[7:2] != 0);
        end
    end

    // datapath
    if (store_eth_hdr) begin
        eth_dest_mac_reg <= s_eth_dest_mac;
        eth_src_mac_reg <= s_eth_src_mac;
        eth_type_reg <= s_eth_type;
    end

    if (transfer_in_save) begin
        save_eth_payload_axis_tdata_reg <= s_eth_payload_axis_tdata;
        save_eth_payload_axis_tkeep_reg <= s_eth_payload_axis_tkeep;
        save_eth_payload_axis_tuser_reg <= s_eth_payload_axis_tuser;
    end
end

// output datapath logic
reg [63:0] m_axis_tdata_reg = 64'd0;
reg [7:0]  m_axis_tkeep_reg = 8'd0;
reg        m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg        m_axis_tlast_reg = 1'b0;
reg        m_axis_tuser_reg = 1'b0;

reg [63:0] temp_m_axis_tdata_reg = 64'd0;
reg [7:0]  temp_m_axis_tkeep_reg = 8'd0;
reg        temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg        temp_m_axis_tlast_reg = 1'b0;
reg        temp_m_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = m_axis_tkeep_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tuser = m_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_axis_tready_int_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;
    
    if (m_axis_tready_int_reg) begin
        // input is ready
        if (m_axis_tready || !m_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_axis_tready) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_axis_tvalid_reg <= 1'b0;
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= 1'b0;
    end else begin
        m_axis_tvalid_reg <= m_axis_tvalid_next;
        m_axis_tready_int_reg <= m_axis_tready_int_early;
        temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= m_axis_tdata_int;
        m_axis_tkeep_reg <= m_axis_tkeep_int;
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end
end

endmodule
