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
 * IP 4 port multiplexer
 */
module ip_mux_4
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * IP frame inputs
     */
    input  wire        input_0_ip_hdr_valid,
    output wire        input_0_ip_hdr_ready,
    input  wire [47:0] input_0_eth_dest_mac,
    input  wire [47:0] input_0_eth_src_mac,
    input  wire [15:0] input_0_eth_type,
    input  wire [3:0]  input_0_ip_version,
    input  wire [3:0]  input_0_ip_ihl,
    input  wire [5:0]  input_0_ip_dscp,
    input  wire [1:0]  input_0_ip_ecn,
    input  wire [15:0] input_0_ip_length,
    input  wire [15:0] input_0_ip_identification,
    input  wire [2:0]  input_0_ip_flags,
    input  wire [12:0] input_0_ip_fragment_offset,
    input  wire [7:0]  input_0_ip_ttl,
    input  wire [7:0]  input_0_ip_protocol,
    input  wire [15:0] input_0_ip_header_checksum,
    input  wire [31:0] input_0_ip_source_ip,
    input  wire [31:0] input_0_ip_dest_ip,
    input  wire [7:0]  input_0_ip_payload_tdata,
    input  wire        input_0_ip_payload_tvalid,
    output wire        input_0_ip_payload_tready,
    input  wire        input_0_ip_payload_tlast,
    input  wire        input_0_ip_payload_tuser,

    input  wire        input_1_ip_hdr_valid,
    output wire        input_1_ip_hdr_ready,
    input  wire [47:0] input_1_eth_dest_mac,
    input  wire [47:0] input_1_eth_src_mac,
    input  wire [15:0] input_1_eth_type,
    input  wire [3:0]  input_1_ip_version,
    input  wire [3:0]  input_1_ip_ihl,
    input  wire [5:0]  input_1_ip_dscp,
    input  wire [1:0]  input_1_ip_ecn,
    input  wire [15:0] input_1_ip_length,
    input  wire [15:0] input_1_ip_identification,
    input  wire [2:0]  input_1_ip_flags,
    input  wire [12:0] input_1_ip_fragment_offset,
    input  wire [7:0]  input_1_ip_ttl,
    input  wire [7:0]  input_1_ip_protocol,
    input  wire [15:0] input_1_ip_header_checksum,
    input  wire [31:0] input_1_ip_source_ip,
    input  wire [31:0] input_1_ip_dest_ip,
    input  wire [7:0]  input_1_ip_payload_tdata,
    input  wire        input_1_ip_payload_tvalid,
    output wire        input_1_ip_payload_tready,
    input  wire        input_1_ip_payload_tlast,
    input  wire        input_1_ip_payload_tuser,

    input  wire        input_2_ip_hdr_valid,
    output wire        input_2_ip_hdr_ready,
    input  wire [47:0] input_2_eth_dest_mac,
    input  wire [47:0] input_2_eth_src_mac,
    input  wire [15:0] input_2_eth_type,
    input  wire [3:0]  input_2_ip_version,
    input  wire [3:0]  input_2_ip_ihl,
    input  wire [5:0]  input_2_ip_dscp,
    input  wire [1:0]  input_2_ip_ecn,
    input  wire [15:0] input_2_ip_length,
    input  wire [15:0] input_2_ip_identification,
    input  wire [2:0]  input_2_ip_flags,
    input  wire [12:0] input_2_ip_fragment_offset,
    input  wire [7:0]  input_2_ip_ttl,
    input  wire [7:0]  input_2_ip_protocol,
    input  wire [15:0] input_2_ip_header_checksum,
    input  wire [31:0] input_2_ip_source_ip,
    input  wire [31:0] input_2_ip_dest_ip,
    input  wire [7:0]  input_2_ip_payload_tdata,
    input  wire        input_2_ip_payload_tvalid,
    output wire        input_2_ip_payload_tready,
    input  wire        input_2_ip_payload_tlast,
    input  wire        input_2_ip_payload_tuser,

    input  wire        input_3_ip_hdr_valid,
    output wire        input_3_ip_hdr_ready,
    input  wire [47:0] input_3_eth_dest_mac,
    input  wire [47:0] input_3_eth_src_mac,
    input  wire [15:0] input_3_eth_type,
    input  wire [3:0]  input_3_ip_version,
    input  wire [3:0]  input_3_ip_ihl,
    input  wire [5:0]  input_3_ip_dscp,
    input  wire [1:0]  input_3_ip_ecn,
    input  wire [15:0] input_3_ip_length,
    input  wire [15:0] input_3_ip_identification,
    input  wire [2:0]  input_3_ip_flags,
    input  wire [12:0] input_3_ip_fragment_offset,
    input  wire [7:0]  input_3_ip_ttl,
    input  wire [7:0]  input_3_ip_protocol,
    input  wire [15:0] input_3_ip_header_checksum,
    input  wire [31:0] input_3_ip_source_ip,
    input  wire [31:0] input_3_ip_dest_ip,
    input  wire [7:0]  input_3_ip_payload_tdata,
    input  wire        input_3_ip_payload_tvalid,
    output wire        input_3_ip_payload_tready,
    input  wire        input_3_ip_payload_tlast,
    input  wire        input_3_ip_payload_tuser,

    /*
     * IP frame output
     */
    output wire        output_ip_hdr_valid,
    input  wire        output_ip_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
    output wire [3:0]  output_ip_version,
    output wire [3:0]  output_ip_ihl,
    output wire [5:0]  output_ip_dscp,
    output wire [1:0]  output_ip_ecn,
    output wire [15:0] output_ip_length,
    output wire [15:0] output_ip_identification,
    output wire [2:0]  output_ip_flags,
    output wire [12:0] output_ip_fragment_offset,
    output wire [7:0]  output_ip_ttl,
    output wire [7:0]  output_ip_protocol,
    output wire [15:0] output_ip_header_checksum,
    output wire [31:0] output_ip_source_ip,
    output wire [31:0] output_ip_dest_ip,
    output wire [7:0]  output_ip_payload_tdata,
    output wire        output_ip_payload_tvalid,
    input  wire        output_ip_payload_tready,
    output wire        output_ip_payload_tlast,
    output wire        output_ip_payload_tuser,

    /*
     * Control
     */
    input  wire        enable,
    input  wire [1:0]  select
);

reg [1:0] select_reg = 0, select_next;
reg frame_reg = 0, frame_next;

reg input_0_ip_hdr_ready_reg = 0, input_0_ip_hdr_ready_next;
reg input_1_ip_hdr_ready_reg = 0, input_1_ip_hdr_ready_next;
reg input_2_ip_hdr_ready_reg = 0, input_2_ip_hdr_ready_next;
reg input_3_ip_hdr_ready_reg = 0, input_3_ip_hdr_ready_next;

reg input_0_ip_payload_tready_reg = 0, input_0_ip_payload_tready_next;
reg input_1_ip_payload_tready_reg = 0, input_1_ip_payload_tready_next;
reg input_2_ip_payload_tready_reg = 0, input_2_ip_payload_tready_next;
reg input_3_ip_payload_tready_reg = 0, input_3_ip_payload_tready_next;

reg output_ip_hdr_valid_reg = 0, output_ip_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 0, output_eth_dest_mac_next;
reg [47:0] output_eth_src_mac_reg = 0, output_eth_src_mac_next;
reg [15:0] output_eth_type_reg = 0, output_eth_type_next;
reg [3:0]  output_ip_version_reg = 0, output_ip_version_next;
reg [3:0]  output_ip_ihl_reg = 0, output_ip_ihl_next;
reg [5:0]  output_ip_dscp_reg = 0, output_ip_dscp_next;
reg [1:0]  output_ip_ecn_reg = 0, output_ip_ecn_next;
reg [15:0] output_ip_length_reg = 0, output_ip_length_next;
reg [15:0] output_ip_identification_reg = 0, output_ip_identification_next;
reg [2:0]  output_ip_flags_reg = 0, output_ip_flags_next;
reg [12:0] output_ip_fragment_offset_reg = 0, output_ip_fragment_offset_next;
reg [7:0]  output_ip_ttl_reg = 0, output_ip_ttl_next;
reg [7:0]  output_ip_protocol_reg = 0, output_ip_protocol_next;
reg [15:0] output_ip_header_checksum_reg = 0, output_ip_header_checksum_next;
reg [31:0] output_ip_source_ip_reg = 0, output_ip_source_ip_next;
reg [31:0] output_ip_dest_ip_reg = 0, output_ip_dest_ip_next;

// internal datapath
reg [7:0] output_ip_payload_tdata_int;
reg       output_ip_payload_tvalid_int;
reg       output_ip_payload_tready_int = 0;
reg       output_ip_payload_tlast_int;
reg       output_ip_payload_tuser_int;
wire      output_ip_payload_tready_int_early;

assign input_0_ip_hdr_ready = input_0_ip_hdr_ready_reg;
assign input_1_ip_hdr_ready = input_1_ip_hdr_ready_reg;
assign input_2_ip_hdr_ready = input_2_ip_hdr_ready_reg;
assign input_3_ip_hdr_ready = input_3_ip_hdr_ready_reg;

assign input_0_ip_payload_tready = input_0_ip_payload_tready_reg;
assign input_1_ip_payload_tready = input_1_ip_payload_tready_reg;
assign input_2_ip_payload_tready = input_2_ip_payload_tready_reg;
assign input_3_ip_payload_tready = input_3_ip_payload_tready_reg;

assign output_ip_hdr_valid = output_ip_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;
assign output_ip_version = output_ip_version_reg;
assign output_ip_ihl = output_ip_ihl_reg;
assign output_ip_dscp = output_ip_dscp_reg;
assign output_ip_ecn = output_ip_ecn_reg;
assign output_ip_length = output_ip_length_reg;
assign output_ip_identification = output_ip_identification_reg;
assign output_ip_flags = output_ip_flags_reg;
assign output_ip_fragment_offset = output_ip_fragment_offset_reg;
assign output_ip_ttl = output_ip_ttl_reg;
assign output_ip_protocol = output_ip_protocol_reg;
assign output_ip_header_checksum = output_ip_header_checksum_reg;
assign output_ip_source_ip = output_ip_source_ip_reg;
assign output_ip_dest_ip = output_ip_dest_ip_reg;

// mux for start of packet detection
reg selected_input_ip_hdr_valid;
reg [47:0] selected_input_eth_dest_mac;
reg [47:0] selected_input_eth_src_mac;
reg [15:0] selected_input_eth_type;
reg [3:0]  selected_input_ip_version;
reg [3:0]  selected_input_ip_ihl;
reg [5:0]  selected_input_ip_dscp;
reg [1:0]  selected_input_ip_ecn;
reg [15:0] selected_input_ip_length;
reg [15:0] selected_input_ip_identification;
reg [2:0]  selected_input_ip_flags;
reg [12:0] selected_input_ip_fragment_offset;
reg [7:0]  selected_input_ip_ttl;
reg [7:0]  selected_input_ip_protocol;
reg [15:0] selected_input_ip_header_checksum;
reg [31:0] selected_input_ip_source_ip;
reg [31:0] selected_input_ip_dest_ip;
always @* begin
    case (select)
        2'd0: begin
            selected_input_ip_hdr_valid = input_0_ip_hdr_valid;
            selected_input_eth_dest_mac = input_0_eth_dest_mac;
            selected_input_eth_src_mac = input_0_eth_src_mac;
            selected_input_eth_type = input_0_eth_type;
            selected_input_ip_version = input_0_ip_version;
            selected_input_ip_ihl = input_0_ip_ihl;
            selected_input_ip_dscp = input_0_ip_dscp;
            selected_input_ip_ecn = input_0_ip_ecn;
            selected_input_ip_length = input_0_ip_length;
            selected_input_ip_identification = input_0_ip_identification;
            selected_input_ip_flags = input_0_ip_flags;
            selected_input_ip_fragment_offset = input_0_ip_fragment_offset;
            selected_input_ip_ttl = input_0_ip_ttl;
            selected_input_ip_protocol = input_0_ip_protocol;
            selected_input_ip_header_checksum = input_0_ip_header_checksum;
            selected_input_ip_source_ip = input_0_ip_source_ip;
            selected_input_ip_dest_ip = input_0_ip_dest_ip;
        end
        2'd1: begin
            selected_input_ip_hdr_valid = input_1_ip_hdr_valid;
            selected_input_eth_dest_mac = input_1_eth_dest_mac;
            selected_input_eth_src_mac = input_1_eth_src_mac;
            selected_input_eth_type = input_1_eth_type;
            selected_input_ip_version = input_1_ip_version;
            selected_input_ip_ihl = input_1_ip_ihl;
            selected_input_ip_dscp = input_1_ip_dscp;
            selected_input_ip_ecn = input_1_ip_ecn;
            selected_input_ip_length = input_1_ip_length;
            selected_input_ip_identification = input_1_ip_identification;
            selected_input_ip_flags = input_1_ip_flags;
            selected_input_ip_fragment_offset = input_1_ip_fragment_offset;
            selected_input_ip_ttl = input_1_ip_ttl;
            selected_input_ip_protocol = input_1_ip_protocol;
            selected_input_ip_header_checksum = input_1_ip_header_checksum;
            selected_input_ip_source_ip = input_1_ip_source_ip;
            selected_input_ip_dest_ip = input_1_ip_dest_ip;
        end
        2'd2: begin
            selected_input_ip_hdr_valid = input_2_ip_hdr_valid;
            selected_input_eth_dest_mac = input_2_eth_dest_mac;
            selected_input_eth_src_mac = input_2_eth_src_mac;
            selected_input_eth_type = input_2_eth_type;
            selected_input_ip_version = input_2_ip_version;
            selected_input_ip_ihl = input_2_ip_ihl;
            selected_input_ip_dscp = input_2_ip_dscp;
            selected_input_ip_ecn = input_2_ip_ecn;
            selected_input_ip_length = input_2_ip_length;
            selected_input_ip_identification = input_2_ip_identification;
            selected_input_ip_flags = input_2_ip_flags;
            selected_input_ip_fragment_offset = input_2_ip_fragment_offset;
            selected_input_ip_ttl = input_2_ip_ttl;
            selected_input_ip_protocol = input_2_ip_protocol;
            selected_input_ip_header_checksum = input_2_ip_header_checksum;
            selected_input_ip_source_ip = input_2_ip_source_ip;
            selected_input_ip_dest_ip = input_2_ip_dest_ip;
        end
        2'd3: begin
            selected_input_ip_hdr_valid = input_3_ip_hdr_valid;
            selected_input_eth_dest_mac = input_3_eth_dest_mac;
            selected_input_eth_src_mac = input_3_eth_src_mac;
            selected_input_eth_type = input_3_eth_type;
            selected_input_ip_version = input_3_ip_version;
            selected_input_ip_ihl = input_3_ip_ihl;
            selected_input_ip_dscp = input_3_ip_dscp;
            selected_input_ip_ecn = input_3_ip_ecn;
            selected_input_ip_length = input_3_ip_length;
            selected_input_ip_identification = input_3_ip_identification;
            selected_input_ip_flags = input_3_ip_flags;
            selected_input_ip_fragment_offset = input_3_ip_fragment_offset;
            selected_input_ip_ttl = input_3_ip_ttl;
            selected_input_ip_protocol = input_3_ip_protocol;
            selected_input_ip_header_checksum = input_3_ip_header_checksum;
            selected_input_ip_source_ip = input_3_ip_source_ip;
            selected_input_ip_dest_ip = input_3_ip_dest_ip;
        end
    endcase
end

// mux for incoming packet
reg [7:0] current_input_tdata;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
        2'd0: begin
            current_input_tdata = input_0_ip_payload_tdata;
            current_input_tvalid = input_0_ip_payload_tvalid;
            current_input_tready = input_0_ip_payload_tready;
            current_input_tlast = input_0_ip_payload_tlast;
            current_input_tuser = input_0_ip_payload_tuser;
        end
        2'd1: begin
            current_input_tdata = input_1_ip_payload_tdata;
            current_input_tvalid = input_1_ip_payload_tvalid;
            current_input_tready = input_1_ip_payload_tready;
            current_input_tlast = input_1_ip_payload_tlast;
            current_input_tuser = input_1_ip_payload_tuser;
        end
        2'd2: begin
            current_input_tdata = input_2_ip_payload_tdata;
            current_input_tvalid = input_2_ip_payload_tvalid;
            current_input_tready = input_2_ip_payload_tready;
            current_input_tlast = input_2_ip_payload_tlast;
            current_input_tuser = input_2_ip_payload_tuser;
        end
        2'd3: begin
            current_input_tdata = input_3_ip_payload_tdata;
            current_input_tvalid = input_3_ip_payload_tvalid;
            current_input_tready = input_3_ip_payload_tready;
            current_input_tlast = input_3_ip_payload_tlast;
            current_input_tuser = input_3_ip_payload_tuser;
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_0_ip_hdr_ready_next = input_0_ip_hdr_ready_reg & ~input_0_ip_hdr_valid;
    input_1_ip_hdr_ready_next = input_1_ip_hdr_ready_reg & ~input_1_ip_hdr_valid;
    input_2_ip_hdr_ready_next = input_2_ip_hdr_ready_reg & ~input_2_ip_hdr_valid;
    input_3_ip_hdr_ready_next = input_3_ip_hdr_ready_reg & ~input_3_ip_hdr_valid;

    input_0_ip_payload_tready_next = 0;
    input_1_ip_payload_tready_next = 0;
    input_2_ip_payload_tready_next = 0;
    input_3_ip_payload_tready_next = 0;

    output_ip_hdr_valid_next = output_ip_hdr_valid_reg & ~output_ip_hdr_ready;
    output_eth_dest_mac_next = output_eth_dest_mac_reg;
    output_eth_src_mac_next = output_eth_src_mac_reg;
    output_eth_type_next = output_eth_type_reg;
    output_ip_version_next = output_ip_version_reg;
    output_ip_ihl_next = output_ip_ihl_reg;
    output_ip_dscp_next = output_ip_dscp_reg;
    output_ip_ecn_next = output_ip_ecn_reg;
    output_ip_length_next = output_ip_length_reg;
    output_ip_identification_next = output_ip_identification_reg;
    output_ip_flags_next = output_ip_flags_reg;
    output_ip_fragment_offset_next = output_ip_fragment_offset_reg;
    output_ip_ttl_next = output_ip_ttl_reg;
    output_ip_protocol_next = output_ip_protocol_reg;
    output_ip_header_checksum_next = output_ip_header_checksum_reg;
    output_ip_source_ip_next = output_ip_source_ip_reg;
    output_ip_dest_ip_next = output_ip_dest_ip_reg;

    if (frame_reg) begin
        if (current_input_tvalid & current_input_tready) begin
            // end of frame detection
            frame_next = ~current_input_tlast;
        end
    end else if (enable & ~output_ip_hdr_valid & selected_input_ip_hdr_valid) begin
        // start of frame, grab select value
        frame_next = 1;
        select_next = select;

        case (select_next)
            2'd0: input_0_ip_hdr_ready_next = 1;
            2'd1: input_1_ip_hdr_ready_next = 1;
            2'd2: input_2_ip_hdr_ready_next = 1;
            2'd3: input_3_ip_hdr_ready_next = 1;
        endcase

        output_ip_hdr_valid_next = 1;
        output_eth_dest_mac_next = selected_input_eth_dest_mac;
        output_eth_src_mac_next = selected_input_eth_src_mac;
        output_eth_type_next = selected_input_eth_type;
        output_ip_version_next = selected_input_ip_version;
        output_ip_ihl_next = selected_input_ip_ihl;
        output_ip_dscp_next = selected_input_ip_dscp;
        output_ip_ecn_next = selected_input_ip_ecn;
        output_ip_length_next = selected_input_ip_length;
        output_ip_identification_next = selected_input_ip_identification;
        output_ip_flags_next = selected_input_ip_flags;
        output_ip_fragment_offset_next = selected_input_ip_fragment_offset;
        output_ip_ttl_next = selected_input_ip_ttl;
        output_ip_protocol_next = selected_input_ip_protocol;
        output_ip_header_checksum_next = selected_input_ip_header_checksum;
        output_ip_source_ip_next = selected_input_ip_source_ip;
        output_ip_dest_ip_next = selected_input_ip_dest_ip;
    end

    // generate ready signal on selected port
    case (select_next)
        2'd0: input_0_ip_payload_tready_next = output_ip_payload_tready_int_early & frame_next;
        2'd1: input_1_ip_payload_tready_next = output_ip_payload_tready_int_early & frame_next;
        2'd2: input_2_ip_payload_tready_next = output_ip_payload_tready_int_early & frame_next;
        2'd3: input_3_ip_payload_tready_next = output_ip_payload_tready_int_early & frame_next;
    endcase

    // pass through selected packet data
    output_ip_payload_tdata_int = current_input_tdata;
    output_ip_payload_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_ip_payload_tlast_int = current_input_tlast;
    output_ip_payload_tuser_int = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 0;
        frame_reg <= 0;
        input_0_ip_hdr_ready_reg <= 0;
        input_1_ip_hdr_ready_reg <= 0;
        input_2_ip_hdr_ready_reg <= 0;
        input_3_ip_hdr_ready_reg <= 0;
        input_0_ip_payload_tready_reg <= 0;
        input_1_ip_payload_tready_reg <= 0;
        input_2_ip_payload_tready_reg <= 0;
        input_3_ip_payload_tready_reg <= 0;
        output_ip_hdr_valid_reg <= 0;
        output_eth_dest_mac_reg <= 0;
        output_eth_src_mac_reg <= 0;
        output_eth_type_reg <= 0;
        output_ip_version_reg <= 0;
        output_ip_ihl_reg <= 0;
        output_ip_dscp_reg <= 0;
        output_ip_ecn_reg <= 0;
        output_ip_length_reg <= 0;
        output_ip_identification_reg <= 0;
        output_ip_flags_reg <= 0;
        output_ip_fragment_offset_reg <= 0;
        output_ip_ttl_reg <= 0;
        output_ip_protocol_reg <= 0;
        output_ip_header_checksum_reg <= 0;
        output_ip_source_ip_reg <= 0;
        output_ip_dest_ip_reg <= 0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_0_ip_hdr_ready_reg <= input_0_ip_hdr_ready_next;
        input_1_ip_hdr_ready_reg <= input_1_ip_hdr_ready_next;
        input_2_ip_hdr_ready_reg <= input_2_ip_hdr_ready_next;
        input_3_ip_hdr_ready_reg <= input_3_ip_hdr_ready_next;
        input_0_ip_payload_tready_reg <= input_0_ip_payload_tready_next;
        input_1_ip_payload_tready_reg <= input_1_ip_payload_tready_next;
        input_2_ip_payload_tready_reg <= input_2_ip_payload_tready_next;
        input_3_ip_payload_tready_reg <= input_3_ip_payload_tready_next;
        output_ip_hdr_valid_reg <= output_ip_hdr_valid_next;
        output_eth_dest_mac_reg <= output_eth_dest_mac_next;
        output_eth_src_mac_reg <= output_eth_src_mac_next;
        output_eth_type_reg <= output_eth_type_next;
        output_ip_version_reg <= output_ip_version_next;
        output_ip_ihl_reg <= output_ip_ihl_next;
        output_ip_dscp_reg <= output_ip_dscp_next;
        output_ip_ecn_reg <= output_ip_ecn_next;
        output_ip_length_reg <= output_ip_length_next;
        output_ip_identification_reg <= output_ip_identification_next;
        output_ip_flags_reg <= output_ip_flags_next;
        output_ip_fragment_offset_reg <= output_ip_fragment_offset_next;
        output_ip_ttl_reg <= output_ip_ttl_next;
        output_ip_protocol_reg <= output_ip_protocol_next;
        output_ip_header_checksum_reg <= output_ip_header_checksum_next;
        output_ip_source_ip_reg <= output_ip_source_ip_next;
        output_ip_dest_ip_reg <= output_ip_dest_ip_next;
    end
end

// output datapath logic
reg [7:0] output_ip_payload_tdata_reg = 0;
reg       output_ip_payload_tvalid_reg = 0;
reg       output_ip_payload_tlast_reg = 0;
reg       output_ip_payload_tuser_reg = 0;

reg [7:0] temp_ip_payload_tdata_reg = 0;
reg       temp_ip_payload_tvalid_reg = 0;
reg       temp_ip_payload_tlast_reg = 0;
reg       temp_ip_payload_tuser_reg = 0;

assign output_ip_payload_tdata = output_ip_payload_tdata_reg;
assign output_ip_payload_tvalid = output_ip_payload_tvalid_reg;
assign output_ip_payload_tlast = output_ip_payload_tlast_reg;
assign output_ip_payload_tuser = output_ip_payload_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_ip_payload_tready_int_early = output_ip_payload_tready | (~temp_ip_payload_tvalid_reg & ~output_ip_payload_tvalid_reg) | (~temp_ip_payload_tvalid_reg & ~output_ip_payload_tvalid_int);

always @(posedge clk) begin
    if (rst) begin
        output_ip_payload_tdata_reg <= 0;
        output_ip_payload_tvalid_reg <= 0;
        output_ip_payload_tlast_reg <= 0;
        output_ip_payload_tuser_reg <= 0;
        output_ip_payload_tready_int <= 0;
        temp_ip_payload_tdata_reg <= 0;
        temp_ip_payload_tvalid_reg <= 0;
        temp_ip_payload_tlast_reg <= 0;
        temp_ip_payload_tuser_reg <= 0;
    end else begin
        // transfer sink ready state to source
        output_ip_payload_tready_int <= output_ip_payload_tready_int_early;

        if (output_ip_payload_tready_int) begin
            // input is ready
            if (output_ip_payload_tready | ~output_ip_payload_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                output_ip_payload_tdata_reg <= output_ip_payload_tdata_int;
                output_ip_payload_tvalid_reg <= output_ip_payload_tvalid_int;
                output_ip_payload_tlast_reg <= output_ip_payload_tlast_int;
                output_ip_payload_tuser_reg <= output_ip_payload_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_ip_payload_tdata_reg <= output_ip_payload_tdata_int;
                temp_ip_payload_tvalid_reg <= output_ip_payload_tvalid_int;
                temp_ip_payload_tlast_reg <= output_ip_payload_tlast_int;
                temp_ip_payload_tuser_reg <= output_ip_payload_tuser_int;
            end
        end else if (output_ip_payload_tready) begin
            // input is not ready, but output is ready
            output_ip_payload_tdata_reg <= temp_ip_payload_tdata_reg;
            output_ip_payload_tvalid_reg <= temp_ip_payload_tvalid_reg;
            output_ip_payload_tlast_reg <= temp_ip_payload_tlast_reg;
            output_ip_payload_tuser_reg <= temp_ip_payload_tuser_reg;
            temp_ip_payload_tdata_reg <= 0;
            temp_ip_payload_tvalid_reg <= 0;
            temp_ip_payload_tlast_reg <= 0;
            temp_ip_payload_tuser_reg <= 0;
        end
    end
end

endmodule
