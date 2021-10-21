/*

Copyright (c) 2014-2020 Alex Forencich

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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream ethernet frame transmitter (Ethernet frame in, AXI out)
 */
module eth_axis_tx #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * Ethernet frame input
     */
    input  wire                  s_eth_hdr_valid,
    output wire                  s_eth_hdr_ready,
    input  wire [47:0]           s_eth_dest_mac,
    input  wire [47:0]           s_eth_src_mac,
    input  wire [15:0]           s_eth_type,
    input  wire [DATA_WIDTH-1:0] s_eth_payload_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] s_eth_payload_axis_tkeep,
    input  wire                  s_eth_payload_axis_tvalid,
    output wire                  s_eth_payload_axis_tready,
    input  wire                  s_eth_payload_axis_tlast,
    input  wire                  s_eth_payload_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m_axis_tkeep,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,
    output wire                  m_axis_tuser,

    /*
     * Status signals
     */
    output wire                  busy
);

parameter CYCLE_COUNT = (14+KEEP_WIDTH-1)/KEEP_WIDTH;

parameter PTR_WIDTH = $clog2(CYCLE_COUNT);

parameter OFFSET = 14 % KEEP_WIDTH;

// bus width assertions
initial begin
    if (KEEP_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: AXI stream interface requires byte (8-bit) granularity (instance %m)");
        $finish;
    end
end

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

// datapath control signals
reg store_eth_hdr;

reg send_eth_header_reg = 1'b0, send_eth_header_next;
reg send_eth_payload_reg = 1'b0, send_eth_payload_next;
reg [PTR_WIDTH-1:0] ptr_reg = 0, ptr_next;

reg flush_save;
reg transfer_in_save;

reg [47:0] eth_dest_mac_reg = 48'd0;
reg [47:0] eth_src_mac_reg = 48'd0;
reg [15:0] eth_type_reg = 16'd0;

reg s_eth_hdr_ready_reg = 1'b0, s_eth_hdr_ready_next;
reg s_eth_payload_axis_tready_reg = 1'b0, s_eth_payload_axis_tready_next;

reg busy_reg = 1'b0;

reg [DATA_WIDTH-1:0] save_eth_payload_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] save_eth_payload_axis_tkeep_reg = {KEEP_WIDTH{1'b0}};
reg save_eth_payload_axis_tlast_reg = 1'b0;
reg save_eth_payload_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] shift_eth_payload_axis_tdata;
reg [KEEP_WIDTH-1:0] shift_eth_payload_axis_tkeep;
reg shift_eth_payload_axis_tvalid;
reg shift_eth_payload_axis_tlast;
reg shift_eth_payload_axis_tuser;
reg shift_eth_payload_axis_input_tready;
reg shift_eth_payload_axis_extra_cycle_reg = 1'b0;

// internal datapath
reg [DATA_WIDTH-1:0] m_axis_tdata_int;
reg [KEEP_WIDTH-1:0] m_axis_tkeep_int;
reg                  m_axis_tvalid_int;
reg                  m_axis_tready_int_reg = 1'b0;
reg                  m_axis_tlast_int;
reg                  m_axis_tuser_int;
wire                 m_axis_tready_int_early;

assign s_eth_hdr_ready = s_eth_hdr_ready_reg;
assign s_eth_payload_axis_tready = s_eth_payload_axis_tready_reg;

assign busy = busy_reg;

always @* begin
    if (OFFSET == 0) begin
        // passthrough if no overlap
        shift_eth_payload_axis_tdata = s_eth_payload_axis_tdata;
        shift_eth_payload_axis_tkeep = s_eth_payload_axis_tkeep;
        shift_eth_payload_axis_tvalid = s_eth_payload_axis_tvalid;
        shift_eth_payload_axis_tlast = s_eth_payload_axis_tlast;
        shift_eth_payload_axis_tuser = s_eth_payload_axis_tuser;
        shift_eth_payload_axis_input_tready = 1'b1;
    end else if (shift_eth_payload_axis_extra_cycle_reg) begin
        shift_eth_payload_axis_tdata = {s_eth_payload_axis_tdata, save_eth_payload_axis_tdata_reg} >> ((KEEP_WIDTH-OFFSET)*8);
        shift_eth_payload_axis_tkeep = {{KEEP_WIDTH{1'b0}}, save_eth_payload_axis_tkeep_reg} >> (KEEP_WIDTH-OFFSET);
        shift_eth_payload_axis_tvalid = 1'b1;
        shift_eth_payload_axis_tlast = save_eth_payload_axis_tlast_reg;
        shift_eth_payload_axis_tuser = save_eth_payload_axis_tuser_reg;
        shift_eth_payload_axis_input_tready = flush_save;
    end else begin
        shift_eth_payload_axis_tdata = {s_eth_payload_axis_tdata, save_eth_payload_axis_tdata_reg} >> ((KEEP_WIDTH-OFFSET)*8);
        shift_eth_payload_axis_tkeep = {s_eth_payload_axis_tkeep, save_eth_payload_axis_tkeep_reg} >> (KEEP_WIDTH-OFFSET);
        shift_eth_payload_axis_tvalid = s_eth_payload_axis_tvalid;
        shift_eth_payload_axis_tlast = (s_eth_payload_axis_tlast && ((s_eth_payload_axis_tkeep & ({KEEP_WIDTH{1'b1}} << (KEEP_WIDTH-OFFSET))) == 0));
        shift_eth_payload_axis_tuser = (s_eth_payload_axis_tuser && ((s_eth_payload_axis_tkeep & ({KEEP_WIDTH{1'b1}} << (KEEP_WIDTH-OFFSET))) == 0));
        shift_eth_payload_axis_input_tready = !(s_eth_payload_axis_tlast && s_eth_payload_axis_tready && s_eth_payload_axis_tvalid);
    end
end

always @* begin
    send_eth_header_next = send_eth_header_reg;
    send_eth_payload_next = send_eth_payload_reg;
    ptr_next = ptr_reg;

    s_eth_hdr_ready_next = 1'b0;
    s_eth_payload_axis_tready_next = 1'b0;

    store_eth_hdr = 1'b0;

    flush_save = 1'b0;
    transfer_in_save = 1'b0;

    m_axis_tdata_int = {DATA_WIDTH{1'b0}};
    m_axis_tkeep_int = {KEEP_WIDTH{1'b0}};
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    if (s_eth_hdr_ready && s_eth_hdr_valid) begin
        store_eth_hdr = 1'b1;
        ptr_next = 0;
        send_eth_header_next = 1'b1;
        send_eth_payload_next = (OFFSET != 0) && (CYCLE_COUNT == 1);
        s_eth_payload_axis_tready_next = send_eth_payload_next && m_axis_tready_int_early;
    end

    if (send_eth_payload_reg) begin
        s_eth_payload_axis_tready_next = m_axis_tready_int_early && shift_eth_payload_axis_input_tready;

        if ((s_eth_payload_axis_tready && s_eth_payload_axis_tvalid) || (m_axis_tready_int_reg && shift_eth_payload_axis_extra_cycle_reg)) begin
            transfer_in_save = 1'b1;

            m_axis_tdata_int = shift_eth_payload_axis_tdata;
            m_axis_tkeep_int = shift_eth_payload_axis_tkeep;
            m_axis_tvalid_int = 1'b1;
            m_axis_tlast_int = shift_eth_payload_axis_tlast;
            m_axis_tuser_int = shift_eth_payload_axis_tuser;

            if (shift_eth_payload_axis_tlast) begin
                flush_save = 1'b1;
                s_eth_payload_axis_tready_next = 1'b0;
                ptr_next = 0;
                send_eth_payload_next = 1'b0;
            end
        end
    end

    if (m_axis_tready_int_reg && (!OFFSET || !send_eth_payload_reg || m_axis_tvalid_int)) begin
        if (send_eth_header_reg) begin
            ptr_next = ptr_reg + 1;

            if ((OFFSET != 0) && (CYCLE_COUNT == 1 || ptr_next == CYCLE_COUNT-1) && !send_eth_payload_reg) begin
                send_eth_payload_next = 1'b1;
                s_eth_payload_axis_tready_next = m_axis_tready_int_early && shift_eth_payload_axis_input_tready;
            end

            m_axis_tvalid_int = 1'b1;

            `define _HEADER_FIELD_(offset, field) \
                if (ptr_reg == offset/KEEP_WIDTH) begin \
                    m_axis_tdata_int[(offset%KEEP_WIDTH)*8 +: 8] = field; \
                    m_axis_tkeep_int[offset%KEEP_WIDTH] = 1'b1; \
                end

            `_HEADER_FIELD_(0,  eth_dest_mac_reg[5*8 +: 8])
            `_HEADER_FIELD_(1,  eth_dest_mac_reg[4*8 +: 8])
            `_HEADER_FIELD_(2,  eth_dest_mac_reg[3*8 +: 8])
            `_HEADER_FIELD_(3,  eth_dest_mac_reg[2*8 +: 8])
            `_HEADER_FIELD_(4,  eth_dest_mac_reg[1*8 +: 8])
            `_HEADER_FIELD_(5,  eth_dest_mac_reg[0*8 +: 8])
            `_HEADER_FIELD_(6,  eth_src_mac_reg[5*8 +: 8])
            `_HEADER_FIELD_(7,  eth_src_mac_reg[4*8 +: 8])
            `_HEADER_FIELD_(8,  eth_src_mac_reg[3*8 +: 8])
            `_HEADER_FIELD_(9,  eth_src_mac_reg[2*8 +: 8])
            `_HEADER_FIELD_(10, eth_src_mac_reg[1*8 +: 8])
            `_HEADER_FIELD_(11, eth_src_mac_reg[0*8 +: 8])
            `_HEADER_FIELD_(12, eth_type_reg[1*8 +: 8])
            `_HEADER_FIELD_(13, eth_type_reg[0*8 +: 8])

            if (ptr_reg == 13/KEEP_WIDTH) begin
                if (!send_eth_payload_reg) begin
                    s_eth_payload_axis_tready_next = m_axis_tready_int_early;
                    send_eth_payload_next = 1'b1;
                end
                send_eth_header_next = 1'b0;
            end

            `undef _HEADER_FIELD_
        end
    end

    s_eth_hdr_ready_next = !(send_eth_header_next || send_eth_payload_next);
end

always @(posedge clk) begin
    send_eth_header_reg <= send_eth_header_next;
    send_eth_payload_reg <= send_eth_payload_next;
    ptr_reg <= ptr_next;

    s_eth_hdr_ready_reg <= s_eth_hdr_ready_next;
    s_eth_payload_axis_tready_reg <= s_eth_payload_axis_tready_next;

    busy_reg <= send_eth_header_next || send_eth_payload_next;

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

    if (flush_save) begin
        save_eth_payload_axis_tlast_reg <= 1'b0;
        shift_eth_payload_axis_extra_cycle_reg <= 1'b0;
    end else if (transfer_in_save) begin
        save_eth_payload_axis_tlast_reg <= s_eth_payload_axis_tlast;
        shift_eth_payload_axis_extra_cycle_reg <= OFFSET ? s_eth_payload_axis_tlast && ((s_eth_payload_axis_tkeep & ({KEEP_WIDTH{1'b1}} << (KEEP_WIDTH-OFFSET))) != 0) : 1'b0;
    end

    if (rst) begin
        send_eth_header_reg <= 1'b0;
        send_eth_payload_reg <= 1'b0;
        ptr_reg <= 0;
        s_eth_hdr_ready_reg <= 1'b0;
        s_eth_payload_axis_tready_reg <= 1'b0;
        busy_reg <= 1'b0;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg = {KEEP_WIDTH{1'b0}};
reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg = 1'b0;
reg                  m_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg = {KEEP_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg = 1'b0;
reg                  temp_m_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = KEEP_ENABLE ? m_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
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

`resetall
