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
 * MAC control transmit
 */
module mac_ctrl_tx #
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
    input  wire                          mcf_valid,
    output wire                          mcf_ready,
    input  wire [47:0]                   mcf_eth_dst,
    input  wire [47:0]                   mcf_eth_src,
    input  wire [15:0]                   mcf_eth_type,
    input  wire [15:0]                   mcf_opcode,
    input  wire [MCF_PARAMS_SIZE*8-1:0]  mcf_params,
    input  wire [ID_WIDTH-1:0]           mcf_id,
    input  wire [DEST_WIDTH-1:0]         mcf_dest,
    input  wire [USER_WIDTH-1:0]         mcf_user,

    /*
     * Pause interface
     */
    input  wire                          tx_pause_req,
    output wire                          tx_pause_ack,

    /*
     * Status
     */
    output wire                          stat_tx_mcf
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

This module manages the transmission of MAC control frames.  Control frames
are accepted in parallel, serialized, and merged at a higher priority with
data traffic.

*/

reg send_data_reg = 1'b0, send_data_next;
reg send_mcf_reg = 1'b0, send_mcf_next;
reg [PTR_WIDTH-1:0] ptr_reg = 0, ptr_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;
reg mcf_ready_reg = 1'b0, mcf_ready_next;
reg tx_pause_ack_reg = 1'b0, tx_pause_ack_next;
reg stat_tx_mcf_reg = 1'b0, stat_tx_mcf_next;

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

assign s_axis_tready = s_axis_tready_reg;
assign mcf_ready = mcf_ready_reg;
assign tx_pause_ack = tx_pause_ack_reg;
assign stat_tx_mcf = stat_tx_mcf_reg;

integer k;

always @* begin
    send_data_next = send_data_reg;
    send_mcf_next = send_mcf_reg;
    ptr_next = ptr_reg;

    s_axis_tready_next = 1'b0;
    mcf_ready_next = 1'b0;
    tx_pause_ack_next = tx_pause_ack_reg;
    stat_tx_mcf_next = 1'b0;

    m_axis_tdata_int = 0;
    m_axis_tkeep_int = 0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tid_int = 0;
    m_axis_tdest_int = 0;
    m_axis_tuser_int = 0;

    if (!send_data_reg && !send_mcf_reg) begin
        m_axis_tdata_int = s_axis_tdata;
        m_axis_tkeep_int = s_axis_tkeep;
        m_axis_tvalid_int = 1'b0;
        m_axis_tlast_int = s_axis_tlast;
        m_axis_tid_int = s_axis_tid;
        m_axis_tdest_int = s_axis_tdest;
        m_axis_tuser_int = s_axis_tuser;
        s_axis_tready_next = m_axis_tready_int_early && !tx_pause_req;
        tx_pause_ack_next = tx_pause_req;
        if (s_axis_tvalid && s_axis_tready) begin
            s_axis_tready_next = m_axis_tready_int_early;
            tx_pause_ack_next = 1'b0;
            m_axis_tvalid_int = 1'b1;
            if (s_axis_tlast) begin
                s_axis_tready_next = m_axis_tready_int_early && !mcf_valid && !mcf_ready;
                send_data_next = 1'b0;
            end else begin
                send_data_next = 1'b1;
            end
        end else if (mcf_valid) begin
            s_axis_tready_next = 1'b0;
            ptr_next = 0;
            send_mcf_next = 1'b1;
            mcf_ready_next = (CYCLE_COUNT == 1) && m_axis_tready_int_early;
        end
    end

    if (send_data_reg) begin
        m_axis_tdata_int = s_axis_tdata;
        m_axis_tkeep_int = s_axis_tkeep;
        m_axis_tvalid_int = 1'b0;
        m_axis_tlast_int = s_axis_tlast;
        m_axis_tid_int = s_axis_tid;
        m_axis_tdest_int = s_axis_tdest;
        m_axis_tuser_int = s_axis_tuser;
        s_axis_tready_next = m_axis_tready_int_early;
        if (s_axis_tvalid && s_axis_tready) begin
            m_axis_tvalid_int = 1'b1;
            if (s_axis_tlast) begin
                s_axis_tready_next = m_axis_tready_int_early && !tx_pause_req;
                send_data_next = 1'b0;
                if (mcf_valid) begin
                    s_axis_tready_next = 1'b0;
                    ptr_next = 0;
                    send_mcf_next = 1'b1;
                    mcf_ready_next = (CYCLE_COUNT == 1) && m_axis_tready_int_early;
                end
            end else begin
                send_data_next = 1'b1;
            end
        end
    end

    if (send_mcf_reg) begin
        mcf_ready_next = (CYCLE_COUNT == 1 || ptr_reg == CYCLE_COUNT-1) && m_axis_tready_int_early;
        if (m_axis_tready_int_reg) begin
            ptr_next = ptr_reg + 1;

            m_axis_tvalid_int = 1'b1;
            m_axis_tid_int = mcf_id;
            m_axis_tdest_int = mcf_dest;
            m_axis_tuser_int = mcf_user;

            `define _HEADER_FIELD_(offset, field) \
                if (ptr_reg == offset/BYTE_LANES) begin \
                    m_axis_tdata_int[(offset%BYTE_LANES)*8 +: 8] = field; \
                    m_axis_tkeep_int[offset%BYTE_LANES] = 1'b1; \
                end

            `_HEADER_FIELD_(0,  mcf_eth_dst[5*8 +: 8])
            `_HEADER_FIELD_(1,  mcf_eth_dst[4*8 +: 8])
            `_HEADER_FIELD_(2,  mcf_eth_dst[3*8 +: 8])
            `_HEADER_FIELD_(3,  mcf_eth_dst[2*8 +: 8])
            `_HEADER_FIELD_(4,  mcf_eth_dst[1*8 +: 8])
            `_HEADER_FIELD_(5,  mcf_eth_dst[0*8 +: 8])
            `_HEADER_FIELD_(6,  mcf_eth_src[5*8 +: 8])
            `_HEADER_FIELD_(7,  mcf_eth_src[4*8 +: 8])
            `_HEADER_FIELD_(8,  mcf_eth_src[3*8 +: 8])
            `_HEADER_FIELD_(9,  mcf_eth_src[2*8 +: 8])
            `_HEADER_FIELD_(10, mcf_eth_src[1*8 +: 8])
            `_HEADER_FIELD_(11, mcf_eth_src[0*8 +: 8])
            `_HEADER_FIELD_(12, mcf_eth_type[1*8 +: 8])
            `_HEADER_FIELD_(13, mcf_eth_type[0*8 +: 8])
            `_HEADER_FIELD_(14, mcf_opcode[1*8 +: 8])
            `_HEADER_FIELD_(15, mcf_opcode[0*8 +: 8])

            for (k = 0; k < HDR_SIZE-16; k = k + 1) begin
                if (ptr_reg == (16+k)/BYTE_LANES) begin
                    if (k < MCF_PARAMS_SIZE) begin
                        m_axis_tdata_int[((16+k)%BYTE_LANES)*8 +: 8] = mcf_params[k*8 +: 8];
                    end else begin
                        m_axis_tdata_int[((16+k)%BYTE_LANES)*8 +: 8] = 0;
                    end
                    m_axis_tkeep_int[(16+k)%BYTE_LANES] = 1'b1;
                end
            end

            if (ptr_reg == (HDR_SIZE-1)/BYTE_LANES) begin
                s_axis_tready_next = m_axis_tready_int_early && !tx_pause_req;
                mcf_ready_next = 1'b0;
                m_axis_tlast_int = 1'b1;
                send_mcf_next = 1'b0;
                stat_tx_mcf_next = 1'b1;
            end else begin
                mcf_ready_next = (ptr_next == CYCLE_COUNT-1) && m_axis_tready_int_early;
            end

            `undef _HEADER_FIELD_
        end
    end
end

always @(posedge clk) begin
    send_data_reg <= send_data_next;
    send_mcf_reg <= send_mcf_next;
    ptr_reg <= ptr_next;

    s_axis_tready_reg <= s_axis_tready_next;
    mcf_ready_reg <= mcf_ready_next;
    tx_pause_ack_reg <= tx_pause_ack_next;
    stat_tx_mcf_reg <= stat_tx_mcf_next;

    if (rst) begin
        send_data_reg <= 1'b0;
        send_mcf_reg <= 1'b0;
        ptr_reg <= 0;
        s_axis_tready_reg <= 1'b0;
        mcf_ready_reg <= 1'b0;
        tx_pause_ack_reg <= 1'b0;
        stat_tx_mcf_reg <= 1'b0;
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
