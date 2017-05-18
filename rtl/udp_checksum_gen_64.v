/*

Copyright (c) 2016-2017 Alex Forencich

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
 * UDP checksum calculation module (64 bit datapath)
 */
module udp_checksum_gen_64 #
(
    parameter PAYLOAD_FIFO_ADDR_WIDTH = 8,
    parameter HEADER_FIFO_ADDR_WIDTH = 3
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * UDP frame input
     */
    input  wire        input_udp_hdr_valid,
    output wire        input_udp_hdr_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [3:0]  input_ip_version,
    input  wire [3:0]  input_ip_ihl,
    input  wire [5:0]  input_ip_dscp,
    input  wire [1:0]  input_ip_ecn,
    input  wire [15:0] input_ip_identification,
    input  wire [2:0]  input_ip_flags,
    input  wire [12:0] input_ip_fragment_offset,
    input  wire [7:0]  input_ip_ttl,
    input  wire [15:0] input_ip_header_checksum,
    input  wire [31:0] input_ip_source_ip,
    input  wire [31:0] input_ip_dest_ip,
    input  wire [15:0] input_udp_source_port,
    input  wire [15:0] input_udp_dest_port,
    input  wire [63:0] input_udp_payload_tdata,
    input  wire [7:0]  input_udp_payload_tkeep,
    input  wire        input_udp_payload_tvalid,
    output wire        input_udp_payload_tready,
    input  wire        input_udp_payload_tlast,
    input  wire        input_udp_payload_tuser,
    
    /*
     * UDP frame output
     */
    output wire        output_udp_hdr_valid,
    input  wire        output_udp_hdr_ready,
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
    output wire [15:0] output_udp_source_port,
    output wire [15:0] output_udp_dest_port,
    output wire [15:0] output_udp_length,
    output wire [15:0] output_udp_checksum,
    output wire [63:0] output_udp_payload_tdata,
    output wire [7:0]  output_udp_payload_tkeep,
    output wire        output_udp_payload_tvalid,
    input  wire        output_udp_payload_tready,
    output wire        output_udp_payload_tlast,
    output wire        output_udp_payload_tuser,
    
    /*
     * Status signals
     */
    output wire        busy
);

/*

UDP Frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0800)          2 octets
 Version (4)                 4 bits
 IHL (5-15)                  4 bits
 DSCP (0)                    6 bits
 ECN (0)                     2 bits
 length                      2 octets
 identification (0?)         2 octets
 flags (010)                 3 bits
 fragment offset (0)         13 bits
 time to live (64?)          1 octet
 protocol                    1 octet
 header checksum             2 octets
 source IP                   4 octets
 destination IP              4 octets
 options                     (IHL-5)*4 octets

 source port                 2 octets
 desination port             2 octets
 length                      2 octets
 checksum                    2 octets

 payload                     length octets

This module receives a UDP frame with header fields in parallel and payload on
an AXI stream interface, calculates the length and checksum, then produces the
header fields in parallel along with the UDP payload in a separate AXI stream.

*/

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_SUM_HEADER = 3'd1,
    STATE_SUM_PAYLOAD = 3'd2,
    STATE_FINISH_SUM_1 = 3'd3,
    STATE_FINISH_SUM_2 = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_udp_hdr;
reg shift_payload_in;
reg [31:0] checksum_part;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [31:0] checksum_reg = 32'd0, checksum_next;
reg [16:0] checksum_temp1_reg = 17'd0, checksum_temp1_next;
reg [16:0] checksum_temp2_reg = 17'd0, checksum_temp2_next;

reg [47:0] eth_dest_mac_reg = 48'd0;
reg [47:0] eth_src_mac_reg = 48'd0;
reg [15:0] eth_type_reg = 16'd0;
reg [3:0]  ip_version_reg = 4'd0;
reg [3:0]  ip_ihl_reg = 4'd0;
reg [5:0]  ip_dscp_reg = 6'd0;
reg [1:0]  ip_ecn_reg = 2'd0;
reg [15:0] ip_identification_reg = 16'd0;
reg [2:0]  ip_flags_reg = 3'd0;
reg [12:0] ip_fragment_offset_reg = 13'd0;
reg [7:0]  ip_ttl_reg = 8'd0;
reg [15:0] ip_header_checksum_reg = 16'd0;
reg [31:0] ip_source_ip_reg = 32'd0;
reg [31:0] ip_dest_ip_reg = 32'd0;
reg [15:0] udp_source_port_reg = 16'd0;
reg [15:0] udp_dest_port_reg = 16'd0;

reg hdr_valid_reg = 0, hdr_valid_next;

reg input_udp_hdr_ready_reg = 1'b0, input_udp_hdr_ready_next;
reg input_udp_payload_tready_reg = 1'b0, input_udp_payload_tready_next;

reg busy_reg = 1'b0;

/*
 * UDP Payload FIFO
 */
wire [63:0] input_udp_payload_fifo_tdata;
wire [7:0] input_udp_payload_fifo_tkeep;
wire input_udp_payload_fifo_tvalid;
wire input_udp_payload_fifo_tready;
wire input_udp_payload_fifo_tlast;
wire input_udp_payload_fifo_tuser;

wire [63:0] output_udp_payload_fifo_tdata;
wire [7:0] output_udp_payload_fifo_tkeep;
wire output_udp_payload_fifo_tvalid;
wire output_udp_payload_fifo_tready;
wire output_udp_payload_fifo_tlast;
wire output_udp_payload_fifo_tuser;

axis_fifo_64 #(
    .DATA_WIDTH(64),
    .ADDR_WIDTH(PAYLOAD_FIFO_ADDR_WIDTH)
)
payload_fifo (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(input_udp_payload_fifo_tdata),
    .input_axis_tkeep(input_udp_payload_fifo_tkeep),
    .input_axis_tvalid(input_udp_payload_fifo_tvalid),
    .input_axis_tready(input_udp_payload_fifo_tready),
    .input_axis_tlast(input_udp_payload_fifo_tlast),
    .input_axis_tuser(input_udp_payload_fifo_tuser),
    // AXI output
    .output_axis_tdata(output_udp_payload_fifo_tdata),
    .output_axis_tkeep(output_udp_payload_fifo_tkeep),
    .output_axis_tvalid(output_udp_payload_fifo_tvalid),
    .output_axis_tready(output_udp_payload_fifo_tready),
    .output_axis_tlast(output_udp_payload_fifo_tlast),
    .output_axis_tuser(output_udp_payload_fifo_tuser)
);

assign input_udp_payload_fifo_tdata = input_udp_payload_tdata;
assign input_udp_payload_fifo_tkeep = input_udp_payload_tkeep;
assign input_udp_payload_fifo_tvalid = input_udp_payload_tvalid & shift_payload_in;
assign input_udp_payload_tready = input_udp_payload_fifo_tready & shift_payload_in;
assign input_udp_payload_fifo_tlast = input_udp_payload_tlast;
assign input_udp_payload_fifo_tuser = input_udp_payload_tuser;

assign output_udp_payload_tdata = output_udp_payload_fifo_tdata;
assign output_udp_payload_tkeep = output_udp_payload_fifo_tkeep;
assign output_udp_payload_tvalid = output_udp_payload_fifo_tvalid;
assign output_udp_payload_fifo_tready = output_udp_payload_tready;
assign output_udp_payload_tlast = output_udp_payload_fifo_tlast;
assign output_udp_payload_tuser = output_udp_payload_fifo_tuser;

/*
 * UDP Header FIFO
 */
reg [HEADER_FIFO_ADDR_WIDTH:0] header_fifo_wr_ptr_reg = {HEADER_FIFO_ADDR_WIDTH+1{1'b0}}, header_fifo_wr_ptr_next;
reg [HEADER_FIFO_ADDR_WIDTH:0] header_fifo_rd_ptr_reg = {HEADER_FIFO_ADDR_WIDTH+1{1'b0}}, header_fifo_rd_ptr_next;

reg [47:0] eth_dest_mac_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [47:0] eth_src_mac_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] eth_type_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [3:0] ip_version_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [3:0] ip_ihl_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [5:0] ip_dscp_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [1:0] ip_ecn_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] ip_identification_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [2:0] ip_flags_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [12:0] ip_fragment_offset_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [7:0] ip_ttl_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] ip_header_checksum_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [31:0] ip_source_ip_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [31:0] ip_dest_ip_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] udp_source_port_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] udp_dest_port_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] udp_length_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];
reg [15:0] udp_checksum_mem[(2**HEADER_FIFO_ADDR_WIDTH)-1:0];

reg [47:0] output_eth_dest_mac_reg = 48'd0;
reg [47:0] output_eth_src_mac_reg = 48'd0;
reg [15:0] output_eth_type_reg = 16'd0;
reg [3:0]  output_ip_version_reg = 4'd0;
reg [3:0]  output_ip_ihl_reg = 4'd0;
reg [5:0]  output_ip_dscp_reg = 6'd0;
reg [1:0]  output_ip_ecn_reg = 2'd0;
reg [15:0] output_ip_identification_reg = 16'd0;
reg [2:0]  output_ip_flags_reg = 3'd0;
reg [12:0] output_ip_fragment_offset_reg = 13'd0;
reg [7:0]  output_ip_ttl_reg = 8'd0;
reg [15:0] output_ip_header_checksum_reg = 16'd0;
reg [31:0] output_ip_source_ip_reg = 32'd0;
reg [31:0] output_ip_dest_ip_reg = 32'd0;
reg [15:0] output_udp_source_port_reg = 16'd0;
reg [15:0] output_udp_dest_port_reg = 16'd0;
reg [15:0] output_udp_length_reg = 16'd0;
reg [15:0] output_udp_checksum_reg = 16'd0;

reg output_udp_hdr_valid_reg = 1'b0, output_udp_hdr_valid_next;

// full when first MSB different but rest same
wire header_fifo_full = ((header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH] != header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH]) &&
                         (header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0] == header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]));
// empty when pointers match exactly
wire header_fifo_empty = header_fifo_wr_ptr_reg == header_fifo_rd_ptr_reg;

// control signals
reg header_fifo_write;
reg header_fifo_read;

wire header_fifo_ready = ~header_fifo_full;

assign output_udp_hdr_valid = output_udp_hdr_valid_reg;

assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;
assign output_ip_version = output_ip_version_reg;
assign output_ip_ihl = output_ip_ihl_reg;
assign output_ip_dscp = output_ip_dscp_reg;
assign output_ip_ecn = output_ip_ecn_reg;
assign output_ip_length = output_udp_length_reg + 16'd20;
assign output_ip_identification = output_ip_identification_reg;
assign output_ip_flags = output_ip_flags_reg;
assign output_ip_fragment_offset = output_ip_fragment_offset_reg;
assign output_ip_ttl = output_ip_ttl_reg;
assign output_ip_protocol = 8'h11;
assign output_ip_header_checksum = output_ip_header_checksum_reg;
assign output_ip_source_ip = output_ip_source_ip_reg;
assign output_ip_dest_ip = output_ip_dest_ip_reg;
assign output_udp_source_port = output_udp_source_port_reg;
assign output_udp_dest_port = output_udp_dest_port_reg;
assign output_udp_length = output_udp_length_reg;
assign output_udp_checksum = output_udp_checksum_reg;

// Write logic
always @* begin
    header_fifo_write = 1'b0;

    header_fifo_wr_ptr_next = header_fifo_wr_ptr_reg;

    if (hdr_valid_reg) begin
        // input data valid
        if (~header_fifo_full) begin
            // not full, perform write
            header_fifo_write = 1'b1;
            header_fifo_wr_ptr_next = header_fifo_wr_ptr_reg + 1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        header_fifo_wr_ptr_reg <= {HEADER_FIFO_ADDR_WIDTH+1{1'b0}};
    end else begin
        header_fifo_wr_ptr_reg <= header_fifo_wr_ptr_next;
    end

    if (header_fifo_write) begin
        eth_dest_mac_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= eth_dest_mac_reg;
        eth_src_mac_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= eth_src_mac_reg;
        eth_type_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= eth_type_reg;
        ip_version_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_version_reg;
        ip_ihl_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_ihl_reg;
        ip_dscp_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_dscp_reg;
        ip_ecn_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_ecn_reg;
        ip_identification_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_identification_reg;
        ip_flags_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_flags_reg;
        ip_fragment_offset_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_fragment_offset_reg;
        ip_ttl_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_ttl_reg;
        ip_header_checksum_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_header_checksum_reg;
        ip_source_ip_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_source_ip_reg;
        ip_dest_ip_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= ip_dest_ip_reg;
        udp_source_port_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= udp_source_port_reg;
        udp_dest_port_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= udp_dest_port_reg;
        udp_length_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= frame_ptr_reg;
        udp_checksum_mem[header_fifo_wr_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]] <= checksum_reg[15:0];
    end
end

// Read logic
always @* begin
    header_fifo_read = 1'b0;

    header_fifo_rd_ptr_next = header_fifo_rd_ptr_reg;

    output_udp_hdr_valid_next = output_udp_hdr_valid_reg;

    if (output_udp_hdr_ready | ~output_udp_hdr_valid) begin
        // output data not valid OR currently being transferred
        if (~header_fifo_empty) begin
            // not empty, perform read
            header_fifo_read = 1'b1;
            output_udp_hdr_valid_next = 1'b1;
            header_fifo_rd_ptr_next = header_fifo_rd_ptr_reg + 1;
        end else begin
            // empty, invalidate
            output_udp_hdr_valid_next = 1'b0;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        header_fifo_rd_ptr_reg <= {HEADER_FIFO_ADDR_WIDTH+1{1'b0}};
        output_udp_hdr_valid_reg <= 1'b0;
    end else begin
        header_fifo_rd_ptr_reg <= header_fifo_rd_ptr_next;
        output_udp_hdr_valid_reg <= output_udp_hdr_valid_next;
    end

    if (header_fifo_read) begin
        output_eth_dest_mac_reg <= eth_dest_mac_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_eth_src_mac_reg <= eth_src_mac_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_eth_type_reg <= eth_type_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_version_reg <= ip_version_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_ihl_reg <= ip_ihl_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_dscp_reg <= ip_dscp_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_ecn_reg <= ip_ecn_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_identification_reg <= ip_identification_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_flags_reg <= ip_flags_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_fragment_offset_reg <= ip_fragment_offset_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_ttl_reg <= ip_ttl_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_header_checksum_reg <= ip_header_checksum_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_source_ip_reg <= ip_source_ip_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_ip_dest_ip_reg <= ip_dest_ip_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_udp_source_port_reg <= udp_source_port_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_udp_dest_port_reg <= udp_dest_port_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_udp_length_reg <= udp_length_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
        output_udp_checksum_reg <= udp_checksum_mem[header_fifo_rd_ptr_reg[HEADER_FIFO_ADDR_WIDTH-1:0]];
    end
end

assign input_udp_hdr_ready = input_udp_hdr_ready_reg;

assign busy = busy_reg;

integer i, word_cnt;

always @* begin
    state_next = STATE_IDLE;

    input_udp_hdr_ready_next = 1'b0;
    input_udp_payload_tready_next = 1'b0;

    store_udp_hdr = 1'b0;
    shift_payload_in = 1'b0;

    frame_ptr_next = frame_ptr_reg;
    checksum_next = checksum_reg;
    checksum_temp1_next = checksum_temp1_reg;
    checksum_temp2_next = checksum_temp2_reg;

    hdr_valid_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state
            input_udp_hdr_ready_next = header_fifo_ready;

            if (input_udp_hdr_ready & input_udp_hdr_valid) begin
                store_udp_hdr = 1'b1;
                frame_ptr_next = 0;
                // 16'h0011 = zero padded type field
                // 16'h0010 = header length times two
                checksum_next = 16'h0011 + 16'h0010;
                checksum_temp1_next = input_ip_source_ip[31:16];
                checksum_temp2_next = input_ip_source_ip[15:0];
                input_udp_hdr_ready_next = 1'b0;
                state_next = STATE_SUM_HEADER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_SUM_HEADER: begin
            // sum pseudo header and header
            checksum_next = checksum_reg + checksum_temp1_reg + checksum_temp2_reg;
            checksum_temp1_next = ip_dest_ip_reg[31:16] + ip_dest_ip_reg[15:0];
            checksum_temp2_next = udp_source_port_reg + udp_dest_port_reg;
            frame_ptr_next = 8;
            state_next = STATE_SUM_PAYLOAD;
        end
        STATE_SUM_PAYLOAD: begin
            // sum payload
            shift_payload_in = 1'b1;

            if (input_udp_payload_tready & input_udp_payload_tvalid) begin
                word_cnt = 1;
                for (i = 1; i <= 8; i = i + 1) begin
                    if (input_udp_payload_tkeep == 8'hff >> (8-i)) word_cnt = i;
                end

                checksum_temp1_next = 0;
                checksum_temp2_next = 0;

                for (i = 0; i < 4; i = i + 1) begin
                    if (input_udp_payload_tkeep[i]) begin
                        if (i & 1) begin
                            checksum_temp1_next = checksum_temp1_next + {8'h00, input_udp_payload_tdata[i*8 +: 8]};
                        end else begin
                            checksum_temp1_next = checksum_temp1_next + {input_udp_payload_tdata[i*8 +: 8], 8'h00};
                        end
                    end
                end

                for (i = 4; i < 8; i = i + 1) begin
                    if (input_udp_payload_tkeep[i]) begin
                        if (i & 1) begin
                            checksum_temp2_next = checksum_temp2_next + {8'h00, input_udp_payload_tdata[i*8 +: 8]};
                        end else begin
                            checksum_temp2_next = checksum_temp2_next + {input_udp_payload_tdata[i*8 +: 8], 8'h00};
                        end
                    end
                end

                // add length * 2 (two copies of length field in pseudo header)
                checksum_next = checksum_reg + checksum_temp1_reg + checksum_temp2_reg + (word_cnt << 1);

                frame_ptr_next = frame_ptr_reg + word_cnt;

                if (input_udp_payload_tlast) begin
                    state_next = STATE_FINISH_SUM_1;
                end else begin
                    state_next = STATE_SUM_PAYLOAD;
                end
            end else begin
                state_next = STATE_SUM_PAYLOAD;
            end
        end
        STATE_FINISH_SUM_1: begin
            // empty pipeline
            checksum_next = checksum_reg + checksum_temp1_reg + checksum_temp2_reg;
            state_next = STATE_FINISH_SUM_2;
        end
        STATE_FINISH_SUM_2: begin
            // add MSW (twice!) for proper ones complement sum
            checksum_part = checksum_reg[15:0] + checksum_reg[31:16];
            checksum_next = ~(checksum_part[15:0] + checksum_part[16]);
            hdr_valid_next = 1;
            state_next = STATE_IDLE;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        input_udp_hdr_ready_reg <= 1'b0;
        input_udp_payload_tready_reg <= 1'b0;
        hdr_valid_reg <= 1'b0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        input_udp_hdr_ready_reg <= input_udp_hdr_ready_next;
        input_udp_payload_tready_reg <= input_udp_payload_tready_next;

        hdr_valid_reg <= hdr_valid_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    frame_ptr_reg <= frame_ptr_next;
    checksum_reg <= checksum_next;
    checksum_temp1_reg <= checksum_temp1_next;
    checksum_temp2_reg <= checksum_temp2_next;

    // datapath
    if (store_udp_hdr) begin
        eth_dest_mac_reg <= input_eth_dest_mac;
        eth_src_mac_reg <= input_eth_src_mac;
        eth_type_reg <= input_eth_type;
        ip_version_reg <= input_ip_version;
        ip_ihl_reg <= input_ip_ihl;
        ip_dscp_reg <= input_ip_dscp;
        ip_ecn_reg <= input_ip_ecn;
        ip_identification_reg <= input_ip_identification;
        ip_flags_reg <= input_ip_flags;
        ip_fragment_offset_reg <= input_ip_fragment_offset;
        ip_ttl_reg <= input_ip_ttl;
        ip_header_checksum_reg <= input_ip_header_checksum;
        ip_source_ip_reg <= input_ip_source_ip;
        ip_dest_ip_reg <= input_ip_dest_ip;
        udp_source_port_reg <= input_udp_source_port;
        udp_dest_port_reg <= input_udp_dest_port;
    end
end

endmodule
