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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * IP arbitrated multiplexer
 */
module ip_arb_mux #
(
    parameter S_COUNT = 4,
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * IP frame inputs
     */
    input  wire [S_COUNT-1:0]            s_ip_hdr_valid,
    output wire [S_COUNT-1:0]            s_ip_hdr_ready,
    input  wire [S_COUNT*48-1:0]         s_eth_dest_mac,
    input  wire [S_COUNT*48-1:0]         s_eth_src_mac,
    input  wire [S_COUNT*16-1:0]         s_eth_type,
    input  wire [S_COUNT*4-1:0]          s_ip_version,
    input  wire [S_COUNT*4-1:0]          s_ip_ihl,
    input  wire [S_COUNT*6-1:0]          s_ip_dscp,
    input  wire [S_COUNT*2-1:0]          s_ip_ecn,
    input  wire [S_COUNT*16-1:0]         s_ip_length,
    input  wire [S_COUNT*16-1:0]         s_ip_identification,
    input  wire [S_COUNT*3-1:0]          s_ip_flags,
    input  wire [S_COUNT*13-1:0]         s_ip_fragment_offset,
    input  wire [S_COUNT*8-1:0]          s_ip_ttl,
    input  wire [S_COUNT*8-1:0]          s_ip_protocol,
    input  wire [S_COUNT*16-1:0]         s_ip_header_checksum,
    input  wire [S_COUNT*32-1:0]         s_ip_source_ip,
    input  wire [S_COUNT*32-1:0]         s_ip_dest_ip,
    input  wire [S_COUNT*DATA_WIDTH-1:0] s_ip_payload_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0] s_ip_payload_axis_tkeep,
    input  wire [S_COUNT-1:0]            s_ip_payload_axis_tvalid,
    output wire [S_COUNT-1:0]            s_ip_payload_axis_tready,
    input  wire [S_COUNT-1:0]            s_ip_payload_axis_tlast,
    input  wire [S_COUNT*ID_WIDTH-1:0]   s_ip_payload_axis_tid,
    input  wire [S_COUNT*DEST_WIDTH-1:0] s_ip_payload_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0] s_ip_payload_axis_tuser,

    /*
     * IP frame output
     */
    output wire                          m_ip_hdr_valid,
    input  wire                          m_ip_hdr_ready,
    output wire [47:0]                   m_eth_dest_mac,
    output wire [47:0]                   m_eth_src_mac,
    output wire [15:0]                   m_eth_type,
    output wire [3:0]                    m_ip_version,
    output wire [3:0]                    m_ip_ihl,
    output wire [5:0]                    m_ip_dscp,
    output wire [1:0]                    m_ip_ecn,
    output wire [15:0]                   m_ip_length,
    output wire [15:0]                   m_ip_identification,
    output wire [2:0]                    m_ip_flags,
    output wire [12:0]                   m_ip_fragment_offset,
    output wire [7:0]                    m_ip_ttl,
    output wire [7:0]                    m_ip_protocol,
    output wire [15:0]                   m_ip_header_checksum,
    output wire [31:0]                   m_ip_source_ip,
    output wire [31:0]                   m_ip_dest_ip,
    output wire [DATA_WIDTH-1:0]         m_ip_payload_axis_tdata,
    output wire [KEEP_WIDTH-1:0]         m_ip_payload_axis_tkeep,
    output wire                          m_ip_payload_axis_tvalid,
    input  wire                          m_ip_payload_axis_tready,
    output wire                          m_ip_payload_axis_tlast,
    output wire [ID_WIDTH-1:0]           m_ip_payload_axis_tid,
    output wire [DEST_WIDTH-1:0]         m_ip_payload_axis_tdest,
    output wire [USER_WIDTH-1:0]         m_ip_payload_axis_tuser
);

parameter CL_S_COUNT = $clog2(S_COUNT);

reg frame_reg = 1'b0, frame_next;

reg [S_COUNT-1:0] s_ip_hdr_ready_reg = {S_COUNT{1'b0}}, s_ip_hdr_ready_next;

reg m_ip_hdr_valid_reg = 1'b0, m_ip_hdr_valid_next;
reg [47:0] m_eth_dest_mac_reg = 48'd0, m_eth_dest_mac_next;
reg [47:0] m_eth_src_mac_reg = 48'd0, m_eth_src_mac_next;
reg [15:0] m_eth_type_reg = 16'd0, m_eth_type_next;
reg [3:0]  m_ip_version_reg = 4'd0, m_ip_version_next;
reg [3:0]  m_ip_ihl_reg = 4'd0, m_ip_ihl_next;
reg [5:0]  m_ip_dscp_reg = 6'd0, m_ip_dscp_next;
reg [1:0]  m_ip_ecn_reg = 2'd0, m_ip_ecn_next;
reg [15:0] m_ip_length_reg = 16'd0, m_ip_length_next;
reg [15:0] m_ip_identification_reg = 16'd0, m_ip_identification_next;
reg [2:0]  m_ip_flags_reg = 3'd0, m_ip_flags_next;
reg [12:0] m_ip_fragment_offset_reg = 13'd0, m_ip_fragment_offset_next;
reg [7:0]  m_ip_ttl_reg = 8'd0, m_ip_ttl_next;
reg [7:0]  m_ip_protocol_reg = 8'd0, m_ip_protocol_next;
reg [15:0] m_ip_header_checksum_reg = 16'd0, m_ip_header_checksum_next;
reg [31:0] m_ip_source_ip_reg = 32'd0, m_ip_source_ip_next;
reg [31:0] m_ip_dest_ip_reg = 32'd0, m_ip_dest_ip_next;

wire [S_COUNT-1:0] request;
wire [S_COUNT-1:0] acknowledge;
wire [S_COUNT-1:0] grant;
wire grant_valid;
wire [CL_S_COUNT-1:0] grant_encoded;

// internal datapath
reg  [DATA_WIDTH-1:0] m_ip_payload_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] m_ip_payload_axis_tkeep_int;
reg                   m_ip_payload_axis_tvalid_int;
reg                   m_ip_payload_axis_tready_int_reg = 1'b0;
reg                   m_ip_payload_axis_tlast_int;
reg  [ID_WIDTH-1:0]   m_ip_payload_axis_tid_int;
reg  [DEST_WIDTH-1:0] m_ip_payload_axis_tdest_int;
reg  [USER_WIDTH-1:0] m_ip_payload_axis_tuser_int;
wire                  m_ip_payload_axis_tready_int_early;

assign s_ip_hdr_ready = s_ip_hdr_ready_reg;

assign s_ip_payload_axis_tready = (m_ip_payload_axis_tready_int_reg && grant_valid) << grant_encoded;

assign m_ip_hdr_valid = m_ip_hdr_valid_reg;
assign m_eth_dest_mac = m_eth_dest_mac_reg;
assign m_eth_src_mac = m_eth_src_mac_reg;
assign m_eth_type = m_eth_type_reg;
assign m_ip_version = m_ip_version_reg;
assign m_ip_ihl = m_ip_ihl_reg;
assign m_ip_dscp = m_ip_dscp_reg;
assign m_ip_ecn = m_ip_ecn_reg;
assign m_ip_length = m_ip_length_reg;
assign m_ip_identification = m_ip_identification_reg;
assign m_ip_flags = m_ip_flags_reg;
assign m_ip_fragment_offset = m_ip_fragment_offset_reg;
assign m_ip_ttl = m_ip_ttl_reg;
assign m_ip_protocol = m_ip_protocol_reg;
assign m_ip_header_checksum = m_ip_header_checksum_reg;
assign m_ip_source_ip = m_ip_source_ip_reg;
assign m_ip_dest_ip = m_ip_dest_ip_reg;

// mux for incoming packet
wire [DATA_WIDTH-1:0] current_s_tdata  = s_ip_payload_axis_tdata[grant_encoded*DATA_WIDTH +: DATA_WIDTH];
wire [KEEP_WIDTH-1:0] current_s_tkeep  = s_ip_payload_axis_tkeep[grant_encoded*KEEP_WIDTH +: KEEP_WIDTH];
wire                  current_s_tvalid = s_ip_payload_axis_tvalid[grant_encoded];
wire                  current_s_tready = s_ip_payload_axis_tready[grant_encoded];
wire                  current_s_tlast  = s_ip_payload_axis_tlast[grant_encoded];
wire [ID_WIDTH-1:0]   current_s_tid    = s_ip_payload_axis_tid[grant_encoded*ID_WIDTH +: ID_WIDTH];
wire [DEST_WIDTH-1:0] current_s_tdest  = s_ip_payload_axis_tdest[grant_encoded*DEST_WIDTH +: DEST_WIDTH];
wire [USER_WIDTH-1:0] current_s_tuser  = s_ip_payload_axis_tuser[grant_encoded*USER_WIDTH +: USER_WIDTH];

// arbiter instance
arbiter #(
    .PORTS(S_COUNT),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_BLOCK(1),
    .ARB_BLOCK_ACK(1),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
)
arb_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

assign request = s_ip_hdr_valid & ~grant;
assign acknowledge = grant & s_ip_payload_axis_tvalid & s_ip_payload_axis_tready & s_ip_payload_axis_tlast;

always @* begin
    frame_next = frame_reg;

    s_ip_hdr_ready_next = {S_COUNT{1'b0}};

    m_ip_hdr_valid_next = m_ip_hdr_valid_reg && !m_ip_hdr_ready;
    m_eth_dest_mac_next = m_eth_dest_mac_reg;
    m_eth_src_mac_next = m_eth_src_mac_reg;
    m_eth_type_next = m_eth_type_reg;
    m_ip_version_next = m_ip_version_reg;
    m_ip_ihl_next = m_ip_ihl_reg;
    m_ip_dscp_next = m_ip_dscp_reg;
    m_ip_ecn_next = m_ip_ecn_reg;
    m_ip_length_next = m_ip_length_reg;
    m_ip_identification_next = m_ip_identification_reg;
    m_ip_flags_next = m_ip_flags_reg;
    m_ip_fragment_offset_next = m_ip_fragment_offset_reg;
    m_ip_ttl_next = m_ip_ttl_reg;
    m_ip_protocol_next = m_ip_protocol_reg;
    m_ip_header_checksum_next = m_ip_header_checksum_reg;
    m_ip_source_ip_next = m_ip_source_ip_reg;
    m_ip_dest_ip_next = m_ip_dest_ip_reg;

    if (s_ip_payload_axis_tvalid[grant_encoded] && s_ip_payload_axis_tready[grant_encoded]) begin
        // end of frame detection
        if (s_ip_payload_axis_tlast[grant_encoded]) begin
            frame_next = 1'b0;
        end
    end

    if (!frame_reg && grant_valid && (m_ip_hdr_ready || !m_ip_hdr_valid)) begin
        // start of frame
        frame_next = 1'b1;

        s_ip_hdr_ready_next = grant;

        m_ip_hdr_valid_next = 1'b1;
        m_eth_dest_mac_next = s_eth_dest_mac[grant_encoded*48 +: 48];
        m_eth_src_mac_next = s_eth_src_mac[grant_encoded*48 +: 48];
        m_eth_type_next = s_eth_type[grant_encoded*16 +: 16];
        m_ip_version_next = s_ip_version[grant_encoded*4 +: 4];
        m_ip_ihl_next = s_ip_ihl[grant_encoded*4 +: 4];
        m_ip_dscp_next = s_ip_dscp[grant_encoded*6 +: 6];
        m_ip_ecn_next = s_ip_ecn[grant_encoded*2 +: 2];
        m_ip_length_next = s_ip_length[grant_encoded*16 +: 16];
        m_ip_identification_next = s_ip_identification[grant_encoded*16 +: 16];
        m_ip_flags_next = s_ip_flags[grant_encoded*3 +: 3];
        m_ip_fragment_offset_next = s_ip_fragment_offset[grant_encoded*13 +: 13];
        m_ip_ttl_next = s_ip_ttl[grant_encoded*8 +: 8];
        m_ip_protocol_next = s_ip_protocol[grant_encoded*8 +: 8];
        m_ip_header_checksum_next = s_ip_header_checksum[grant_encoded*16 +: 16];
        m_ip_source_ip_next = s_ip_source_ip[grant_encoded*32 +: 32];
        m_ip_dest_ip_next = s_ip_dest_ip[grant_encoded*32 +: 32];
    end

    // pass through selected packet data
    m_ip_payload_axis_tdata_int  = current_s_tdata;
    m_ip_payload_axis_tkeep_int  = current_s_tkeep;
    m_ip_payload_axis_tvalid_int = current_s_tvalid && m_ip_payload_axis_tready_int_reg && grant_valid;
    m_ip_payload_axis_tlast_int  = current_s_tlast;
    m_ip_payload_axis_tid_int    = current_s_tid;
    m_ip_payload_axis_tdest_int  = current_s_tdest;
    m_ip_payload_axis_tuser_int  = current_s_tuser;
end

always @(posedge clk) begin
    frame_reg <= frame_next;

    s_ip_hdr_ready_reg <= s_ip_hdr_ready_next;

    m_ip_hdr_valid_reg <= m_ip_hdr_valid_next;
    m_eth_dest_mac_reg <= m_eth_dest_mac_next;
    m_eth_src_mac_reg <= m_eth_src_mac_next;
    m_eth_type_reg <= m_eth_type_next;
    m_ip_version_reg <= m_ip_version_next;
    m_ip_ihl_reg <= m_ip_ihl_next;
    m_ip_dscp_reg <= m_ip_dscp_next;
    m_ip_ecn_reg <= m_ip_ecn_next;
    m_ip_length_reg <= m_ip_length_next;
    m_ip_identification_reg <= m_ip_identification_next;
    m_ip_flags_reg <= m_ip_flags_next;
    m_ip_fragment_offset_reg <= m_ip_fragment_offset_next;
    m_ip_ttl_reg <= m_ip_ttl_next;
    m_ip_protocol_reg <= m_ip_protocol_next;
    m_ip_header_checksum_reg <= m_ip_header_checksum_next;
    m_ip_source_ip_reg <= m_ip_source_ip_next;
    m_ip_dest_ip_reg <= m_ip_dest_ip_next;

    if (rst) begin
        frame_reg <= 1'b0;
        s_ip_hdr_ready_reg <= {S_COUNT{1'b0}};
        m_ip_hdr_valid_reg <= 1'b0;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_ip_payload_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_ip_payload_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  m_ip_payload_axis_tvalid_reg = 1'b0, m_ip_payload_axis_tvalid_next;
reg                  m_ip_payload_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   m_ip_payload_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_ip_payload_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_ip_payload_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_m_ip_payload_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_ip_payload_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_ip_payload_axis_tvalid_reg = 1'b0, temp_m_ip_payload_axis_tvalid_next;
reg                  temp_m_ip_payload_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_m_ip_payload_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_ip_payload_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_ip_payload_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_ip_payload_axis_temp_to_output;

assign m_ip_payload_axis_tdata  = m_ip_payload_axis_tdata_reg;
assign m_ip_payload_axis_tkeep  = KEEP_ENABLE ? m_ip_payload_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign m_ip_payload_axis_tvalid = m_ip_payload_axis_tvalid_reg;
assign m_ip_payload_axis_tlast  = m_ip_payload_axis_tlast_reg;
assign m_ip_payload_axis_tid    = ID_ENABLE   ? m_ip_payload_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign m_ip_payload_axis_tdest  = DEST_ENABLE ? m_ip_payload_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign m_ip_payload_axis_tuser  = USER_ENABLE ? m_ip_payload_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_ip_payload_axis_tready_int_early = m_ip_payload_axis_tready || (!temp_m_ip_payload_axis_tvalid_reg && (!m_ip_payload_axis_tvalid_reg || !m_ip_payload_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_reg;
    temp_m_ip_payload_axis_tvalid_next = temp_m_ip_payload_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_ip_payload_axis_temp_to_output = 1'b0;

    if (m_ip_payload_axis_tready_int_reg) begin
        // input is ready
        if (m_ip_payload_axis_tready || !m_ip_payload_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_ip_payload_axis_tvalid_next = m_ip_payload_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_ip_payload_axis_tready) begin
        // input is not ready, but output is ready
        m_ip_payload_axis_tvalid_next = temp_m_ip_payload_axis_tvalid_reg;
        temp_m_ip_payload_axis_tvalid_next = 1'b0;
        store_ip_payload_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_ip_payload_axis_tvalid_reg <= 1'b0;
        m_ip_payload_axis_tready_int_reg <= 1'b0;
        temp_m_ip_payload_axis_tvalid_reg <= 1'b0;
    end else begin
        m_ip_payload_axis_tvalid_reg <= m_ip_payload_axis_tvalid_next;
        m_ip_payload_axis_tready_int_reg <= m_ip_payload_axis_tready_int_early;
        temp_m_ip_payload_axis_tvalid_reg <= temp_m_ip_payload_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        m_ip_payload_axis_tdata_reg <= m_ip_payload_axis_tdata_int;
        m_ip_payload_axis_tkeep_reg <= m_ip_payload_axis_tkeep_int;
        m_ip_payload_axis_tlast_reg <= m_ip_payload_axis_tlast_int;
        m_ip_payload_axis_tid_reg   <= m_ip_payload_axis_tid_int;
        m_ip_payload_axis_tdest_reg <= m_ip_payload_axis_tdest_int;
        m_ip_payload_axis_tuser_reg <= m_ip_payload_axis_tuser_int;
    end else if (store_ip_payload_axis_temp_to_output) begin
        m_ip_payload_axis_tdata_reg <= temp_m_ip_payload_axis_tdata_reg;
        m_ip_payload_axis_tkeep_reg <= temp_m_ip_payload_axis_tkeep_reg;
        m_ip_payload_axis_tlast_reg <= temp_m_ip_payload_axis_tlast_reg;
        m_ip_payload_axis_tid_reg   <= temp_m_ip_payload_axis_tid_reg;
        m_ip_payload_axis_tdest_reg <= temp_m_ip_payload_axis_tdest_reg;
        m_ip_payload_axis_tuser_reg <= temp_m_ip_payload_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_ip_payload_axis_tdata_reg <= m_ip_payload_axis_tdata_int;
        temp_m_ip_payload_axis_tkeep_reg <= m_ip_payload_axis_tkeep_int;
        temp_m_ip_payload_axis_tlast_reg <= m_ip_payload_axis_tlast_int;
        temp_m_ip_payload_axis_tid_reg   <= m_ip_payload_axis_tid_int;
        temp_m_ip_payload_axis_tdest_reg <= m_ip_payload_axis_tdest_int;
        temp_m_ip_payload_axis_tuser_reg <= m_ip_payload_axis_tuser_int;
    end
end

endmodule

`resetall
