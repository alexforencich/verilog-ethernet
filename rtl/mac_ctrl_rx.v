/*

Copyright (c) 2023 Alex Forencich

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
 * MAC control receive
 */
module mac_ctrl_rx #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = DATA_WIDTH>8,
    parameter KEEP_WIDTH = DATA_WIDTH/8,
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    parameter USE_READY = 0,
    parameter MCF_PARAMS_SIZE = 18
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI stream input
     */
    input  wire [DATA_WIDTH-1:0]         s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]         s_axis_tkeep,
    input  wire                          s_axis_tvalid,
    output wire                          s_axis_tready,
    input  wire                          s_axis_tlast,
    input  wire [ID_WIDTH-1:0]           s_axis_tid,
    input  wire [DEST_WIDTH-1:0]         s_axis_tdest,
    input  wire [USER_WIDTH-1:0]         s_axis_tuser,

    /*
     * AXI stream output
     */
    output wire [DATA_WIDTH-1:0]         m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]         m_axis_tkeep,
    output wire                          m_axis_tvalid,
    input  wire                          m_axis_tready,
    output wire                          m_axis_tlast,
    output wire [ID_WIDTH-1:0]           m_axis_tid,
    output wire [DEST_WIDTH-1:0]         m_axis_tdest,
    output wire [USER_WIDTH-1:0]         m_axis_tuser,

    /*
     * MAC control frame interface
     */
    output wire                          mcf_valid,
    output wire [47:0]                   mcf_eth_dst,
    output wire [47:0]                   mcf_eth_src,
    output wire [15:0]                   mcf_eth_type,
    output wire [15:0]                   mcf_opcode,
    output wire [MCF_PARAMS_SIZE*8-1:0]  mcf_params,
    output wire [ID_WIDTH-1:0]           mcf_id,
    output wire [DEST_WIDTH-1:0]         mcf_dest,
    output wire [USER_WIDTH-1:0]         mcf_user,

    /*
     * Configuration
     */
    input  wire [47:0]                   cfg_mcf_rx_eth_dst_mcast,
    input  wire                          cfg_mcf_rx_check_eth_dst_mcast,
    input  wire [47:0]                   cfg_mcf_rx_eth_dst_ucast,
    input  wire                          cfg_mcf_rx_check_eth_dst_ucast,
    input  wire [47:0]                   cfg_mcf_rx_eth_src,
    input  wire                          cfg_mcf_rx_check_eth_src,
    input  wire [15:0]                   cfg_mcf_rx_eth_type,
    input  wire [15:0]                   cfg_mcf_rx_opcode_lfc,
    input  wire                          cfg_mcf_rx_check_opcode_lfc,
    input  wire [15:0]                   cfg_mcf_rx_opcode_pfc,
    input  wire                          cfg_mcf_rx_check_opcode_pfc,
    input  wire                          cfg_mcf_rx_forward,
    input  wire                          cfg_mcf_rx_enable,

    /*
     * Status
     */
    output wire                          stat_rx_mcf
);

parameter BYTE_LANES = KEEP_ENABLE ? KEEP_WIDTH : 1;

parameter HDR_SIZE = 60;

parameter CYCLE_COUNT = (HDR_SIZE+BYTE_LANES-1)/BYTE_LANES;

parameter PTR_WIDTH = $clog2(CYCLE_COUNT);

parameter OFFSET = HDR_SIZE % BYTE_LANES;

// check configuration
initial begin
    if (BYTE_LANES * 8 != DATA_WIDTH) begin
        $error("Error: AXI stream interface requires byte (8-bit) granularity (instance %m)");
        $finish;
    end

    if (MCF_PARAMS_SIZE > 44) begin
        $error("Error: Maximum MCF_PARAMS_SIZE is 44 bytes (instance %m)");
        $finish;
    end
end

/*

MAC control frame

 Field                       Length
 Destination MAC address     6 octets [01:80:C2:00:00:01]
 Source MAC address          6 octets
 Ethertype                   2 octets [0x8808]
 Opcode                      2 octets
 Parameters                  0-44 octets

This module manages the reception of MAC control frames.  Incoming frames are
checked based on the ethertype and (optionally) MAC addresses.  Matching control
frames are marked by setting tuser[0] on the data output and forwarded through
a separate interface for processing.

*/

reg read_mcf_reg = 1'b1, read_mcf_next;
reg mcf_frame_reg = 1'b0, mcf_frame_next;
reg [PTR_WIDTH-1:0] ptr_reg = 0, ptr_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

// internal datapath
reg  [DATA_WIDTH-1:0] m_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] m_axis_tkeep_int;
reg                   m_axis_tvalid_int;
reg                   m_axis_tready_int_reg = 1'b0;
reg                   m_axis_tlast_int;
reg  [ID_WIDTH-1:0]   m_axis_tid_int;
reg  [DEST_WIDTH-1:0] m_axis_tdest_int;
reg  [USER_WIDTH-1:0] m_axis_tuser_int;
wire                  m_axis_tready_int_early;

reg                          mcf_valid_reg = 0, mcf_valid_next;
reg [47:0]                   mcf_eth_dst_reg = 0, mcf_eth_dst_next;
reg [47:0]                   mcf_eth_src_reg = 0, mcf_eth_src_next;
reg [15:0]                   mcf_eth_type_reg = 0, mcf_eth_type_next;
reg [15:0]                   mcf_opcode_reg = 0, mcf_opcode_next;
reg [MCF_PARAMS_SIZE*8-1:0]  mcf_params_reg = 0, mcf_params_next;
reg [ID_WIDTH-1:0]           mcf_id_reg = 0, mcf_id_next;
reg [DEST_WIDTH-1:0]         mcf_dest_reg = 0, mcf_dest_next;
reg [USER_WIDTH-1:0]         mcf_user_reg = 0, mcf_user_next;

reg stat_rx_mcf_reg = 1'b0, stat_rx_mcf_next;

assign s_axis_tready = s_axis_tready_reg;

assign mcf_valid = mcf_valid_reg;
assign mcf_eth_dst = mcf_eth_dst_reg;
assign mcf_eth_src = mcf_eth_src_reg;
assign mcf_eth_type = mcf_eth_type_reg;
assign mcf_opcode = mcf_opcode_reg;
assign mcf_params = mcf_params_reg;
assign mcf_id = mcf_id_reg;
assign mcf_dest = mcf_dest_reg;
assign mcf_user = mcf_user_reg;

assign stat_rx_mcf = stat_rx_mcf_reg;

wire mcf_eth_dst_mcast_match = mcf_eth_dst_next == cfg_mcf_rx_eth_dst_mcast;
wire mcf_eth_dst_ucast_match = mcf_eth_dst_next == cfg_mcf_rx_eth_dst_ucast;
wire mcf_eth_src_match = mcf_eth_src_next == cfg_mcf_rx_eth_src;
wire mcf_eth_type_match = mcf_eth_type_next == cfg_mcf_rx_eth_type;
wire mcf_opcode_lfc_match = mcf_opcode_next == cfg_mcf_rx_opcode_lfc;
wire mcf_opcode_pfc_match = mcf_opcode_next == cfg_mcf_rx_opcode_pfc;

wire mcf_eth_dst_match = ((mcf_eth_dst_mcast_match && cfg_mcf_rx_check_eth_dst_mcast) ||
    (mcf_eth_dst_ucast_match && cfg_mcf_rx_check_eth_dst_ucast) ||
    (!cfg_mcf_rx_check_eth_dst_mcast && !cfg_mcf_rx_check_eth_dst_ucast));

wire mcf_opcode_match = ((mcf_opcode_lfc_match && cfg_mcf_rx_check_opcode_lfc) ||
    (mcf_opcode_pfc_match && cfg_mcf_rx_check_opcode_pfc) ||
    (!cfg_mcf_rx_check_opcode_lfc && !cfg_mcf_rx_check_opcode_pfc));

wire mcf_match = (mcf_eth_dst_match &&
    (mcf_eth_src_match || !cfg_mcf_rx_check_eth_src) &&
    mcf_eth_type_match && mcf_opcode_match);

integer k;

always @* begin
    read_mcf_next = read_mcf_reg;
    mcf_frame_next = mcf_frame_reg;
    ptr_next = ptr_reg;

    // pass through data
    m_axis_tdata_int = s_axis_tdata;
    m_axis_tkeep_int = s_axis_tkeep;
    m_axis_tvalid_int = s_axis_tvalid;
    m_axis_tlast_int = s_axis_tlast;
    m_axis_tid_int = s_axis_tid;
    m_axis_tdest_int = s_axis_tdest;
    m_axis_tuser_int = s_axis_tuser;

    s_axis_tready_next = m_axis_tready_int_early || !USE_READY;

    mcf_valid_next = 1'b0;
    mcf_eth_dst_next = mcf_eth_dst_reg;
    mcf_eth_src_next = mcf_eth_src_reg;
    mcf_eth_type_next = mcf_eth_type_reg;
    mcf_opcode_next = mcf_opcode_reg;
    mcf_params_next = mcf_params_reg;
    mcf_id_next = mcf_id_reg;
    mcf_dest_next = mcf_dest_reg;
    mcf_user_next = mcf_user_reg;

    stat_rx_mcf_next = 1'b0;

    if ((s_axis_tready || !USE_READY) && s_axis_tvalid) begin
        if (read_mcf_reg) begin
            ptr_next = ptr_reg + 1;

            mcf_id_next = s_axis_tid;
            mcf_dest_next = s_axis_tdest;
            mcf_user_next = s_axis_tuser;

            `define _HEADER_FIELD_(offset, field) \
                if (ptr_reg == offset/BYTE_LANES) begin \
                    field = s_axis_tdata[(offset%BYTE_LANES)*8 +: 8]; \
                end

            `_HEADER_FIELD_(0,  mcf_eth_dst_next[5*8 +: 8])
            `_HEADER_FIELD_(1,  mcf_eth_dst_next[4*8 +: 8])
            `_HEADER_FIELD_(2,  mcf_eth_dst_next[3*8 +: 8])
            `_HEADER_FIELD_(3,  mcf_eth_dst_next[2*8 +: 8])
            `_HEADER_FIELD_(4,  mcf_eth_dst_next[1*8 +: 8])
            `_HEADER_FIELD_(5,  mcf_eth_dst_next[0*8 +: 8])
            `_HEADER_FIELD_(6,  mcf_eth_src_next[5*8 +: 8])
            `_HEADER_FIELD_(7,  mcf_eth_src_next[4*8 +: 8])
            `_HEADER_FIELD_(8,  mcf_eth_src_next[3*8 +: 8])
            `_HEADER_FIELD_(9,  mcf_eth_src_next[2*8 +: 8])
            `_HEADER_FIELD_(10, mcf_eth_src_next[1*8 +: 8])
            `_HEADER_FIELD_(11, mcf_eth_src_next[0*8 +: 8])
            `_HEADER_FIELD_(12, mcf_eth_type_next[1*8 +: 8])
            `_HEADER_FIELD_(13, mcf_eth_type_next[0*8 +: 8])
            `_HEADER_FIELD_(14, mcf_opcode_next[1*8 +: 8])
            `_HEADER_FIELD_(15, mcf_opcode_next[0*8 +: 8])

            if (ptr_reg == 0/BYTE_LANES) begin
                // ensure params field gets cleared
                mcf_params_next = 0;
            end

            for (k = 0; k < MCF_PARAMS_SIZE; k = k + 1) begin
                if (ptr_reg == (16+k)/BYTE_LANES) begin
                    mcf_params_next[k*8 +: 8] = s_axis_tdata[((16+k)%BYTE_LANES)*8 +: 8];
                end
            end

            if (ptr_reg == 15/BYTE_LANES && (!KEEP_ENABLE || s_axis_tkeep[13%BYTE_LANES])) begin
                // record match at end of opcode field
                mcf_frame_next = mcf_match && cfg_mcf_rx_enable;
            end

            if (ptr_reg == (HDR_SIZE-1)/BYTE_LANES) begin
                read_mcf_next = 1'b0;
            end

            `undef _HEADER_FIELD_
        end

        if (s_axis_tlast) begin
            if (s_axis_tuser[0]) begin
                // frame marked invalid
            end else if (mcf_frame_next) begin
                if (!cfg_mcf_rx_forward) begin
                    // mark frame invalid
                    m_axis_tuser_int[0] = 1'b1;
                end
                // transfer out MAC control frame
                mcf_valid_next = 1'b1;
                stat_rx_mcf_next = 1'b1;
            end

            read_mcf_next = 1'b1;
            mcf_frame_next = 1'b0;
            ptr_next = 0;
        end
    end
end

always @(posedge clk) begin
    read_mcf_reg <= read_mcf_next;
    mcf_frame_reg <= mcf_frame_next;
    ptr_reg <= ptr_next;

    s_axis_tready_reg <= s_axis_tready_next;

    mcf_valid_reg <= mcf_valid_next;
    mcf_eth_dst_reg <= mcf_eth_dst_next;
    mcf_eth_src_reg <= mcf_eth_src_next;
    mcf_eth_type_reg <= mcf_eth_type_next;
    mcf_opcode_reg <= mcf_opcode_next;
    mcf_params_reg <= mcf_params_next;
    mcf_id_reg <= mcf_id_next;
    mcf_dest_reg <= mcf_dest_next;
    mcf_user_reg <= mcf_user_next;

    stat_rx_mcf_reg <= stat_rx_mcf_next;

    if (rst) begin
        read_mcf_reg <= 1'b1;
        mcf_frame_reg <= 1'b0;
        ptr_reg <= 0;
        s_axis_tready_reg <= 1'b0;
        mcf_valid_reg <= 1'b0;
        stat_rx_mcf_reg <= 1'b0;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tkeep  = KEEP_ENABLE ? m_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = m_axis_tlast_reg;
assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_axis_tready_int_early = m_axis_tready || !USE_READY || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (m_axis_tready_int_reg) begin
        // input is ready
        if (m_axis_tready || !USE_READY || !m_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_axis_tready || !USE_READY) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tready_int_reg <= m_axis_tready_int_early;
    temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;

    // datapath
    if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= m_axis_tdata_int;
        m_axis_tkeep_reg <= m_axis_tkeep_int;
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tid_reg   <= m_axis_tid_int;
        m_axis_tdest_reg <= m_axis_tdest_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tid_reg   <= temp_m_axis_tid_reg;
        m_axis_tdest_reg <= temp_m_axis_tdest_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tid_reg   <= m_axis_tid_int;
        temp_m_axis_tdest_reg <= m_axis_tdest_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end

    if (rst) begin
        m_axis_tvalid_reg <= 1'b0;
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= 1'b0;
    end
end

endmodule

`resetall
