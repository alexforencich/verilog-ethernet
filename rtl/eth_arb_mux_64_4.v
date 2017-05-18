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
 * Ethernet 4 port arbitrated multiplexer (64 bit datapath)
 */
module eth_arb_mux_64_4 #
(
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "PRIORITY",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame inputs
     */
    input  wire        input_0_eth_hdr_valid,
    output wire        input_0_eth_hdr_ready,
    input  wire [47:0] input_0_eth_dest_mac,
    input  wire [47:0] input_0_eth_src_mac,
    input  wire [15:0] input_0_eth_type,
    input  wire [63:0] input_0_eth_payload_tdata,
    input  wire [7:0]  input_0_eth_payload_tkeep,
    input  wire        input_0_eth_payload_tvalid,
    output wire        input_0_eth_payload_tready,
    input  wire        input_0_eth_payload_tlast,
    input  wire        input_0_eth_payload_tuser,

    input  wire        input_1_eth_hdr_valid,
    output wire        input_1_eth_hdr_ready,
    input  wire [47:0] input_1_eth_dest_mac,
    input  wire [47:0] input_1_eth_src_mac,
    input  wire [15:0] input_1_eth_type,
    input  wire [63:0] input_1_eth_payload_tdata,
    input  wire [7:0]  input_1_eth_payload_tkeep,
    input  wire        input_1_eth_payload_tvalid,
    output wire        input_1_eth_payload_tready,
    input  wire        input_1_eth_payload_tlast,
    input  wire        input_1_eth_payload_tuser,

    input  wire        input_2_eth_hdr_valid,
    output wire        input_2_eth_hdr_ready,
    input  wire [47:0] input_2_eth_dest_mac,
    input  wire [47:0] input_2_eth_src_mac,
    input  wire [15:0] input_2_eth_type,
    input  wire [63:0] input_2_eth_payload_tdata,
    input  wire [7:0]  input_2_eth_payload_tkeep,
    input  wire        input_2_eth_payload_tvalid,
    output wire        input_2_eth_payload_tready,
    input  wire        input_2_eth_payload_tlast,
    input  wire        input_2_eth_payload_tuser,

    input  wire        input_3_eth_hdr_valid,
    output wire        input_3_eth_hdr_ready,
    input  wire [47:0] input_3_eth_dest_mac,
    input  wire [47:0] input_3_eth_src_mac,
    input  wire [15:0] input_3_eth_type,
    input  wire [63:0] input_3_eth_payload_tdata,
    input  wire [7:0]  input_3_eth_payload_tkeep,
    input  wire        input_3_eth_payload_tvalid,
    output wire        input_3_eth_payload_tready,
    input  wire        input_3_eth_payload_tlast,
    input  wire        input_3_eth_payload_tuser,

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
    output wire        output_eth_payload_tuser
);

wire [3:0] request;
wire [3:0] acknowledge;
wire [3:0] grant;
wire grant_valid;
wire [1:0] grant_encoded;

assign acknowledge[0] = input_0_eth_payload_tvalid & input_0_eth_payload_tready & input_0_eth_payload_tlast;
assign request[0] = input_0_eth_hdr_valid;
assign acknowledge[1] = input_1_eth_payload_tvalid & input_1_eth_payload_tready & input_1_eth_payload_tlast;
assign request[1] = input_1_eth_hdr_valid;
assign acknowledge[2] = input_2_eth_payload_tvalid & input_2_eth_payload_tready & input_2_eth_payload_tlast;
assign request[2] = input_2_eth_hdr_valid;
assign acknowledge[3] = input_3_eth_payload_tvalid & input_3_eth_payload_tready & input_3_eth_payload_tlast;
assign request[3] = input_3_eth_hdr_valid;

// mux instance
eth_mux_64_4
mux_inst (
    .clk(clk),
    .rst(rst),
    .input_0_eth_hdr_valid(input_0_eth_hdr_valid & grant[0]),
    .input_0_eth_hdr_ready(input_0_eth_hdr_ready),
    .input_0_eth_dest_mac(input_0_eth_dest_mac),
    .input_0_eth_src_mac(input_0_eth_src_mac),
    .input_0_eth_type(input_0_eth_type),
    .input_0_eth_payload_tdata(input_0_eth_payload_tdata),
    .input_0_eth_payload_tkeep(input_0_eth_payload_tkeep),
    .input_0_eth_payload_tvalid(input_0_eth_payload_tvalid & grant[0]),
    .input_0_eth_payload_tready(input_0_eth_payload_tready),
    .input_0_eth_payload_tlast(input_0_eth_payload_tlast),
    .input_0_eth_payload_tuser(input_0_eth_payload_tuser),
    .input_1_eth_hdr_valid(input_1_eth_hdr_valid & grant[1]),
    .input_1_eth_hdr_ready(input_1_eth_hdr_ready),
    .input_1_eth_dest_mac(input_1_eth_dest_mac),
    .input_1_eth_src_mac(input_1_eth_src_mac),
    .input_1_eth_type(input_1_eth_type),
    .input_1_eth_payload_tdata(input_1_eth_payload_tdata),
    .input_1_eth_payload_tkeep(input_1_eth_payload_tkeep),
    .input_1_eth_payload_tvalid(input_1_eth_payload_tvalid & grant[1]),
    .input_1_eth_payload_tready(input_1_eth_payload_tready),
    .input_1_eth_payload_tlast(input_1_eth_payload_tlast),
    .input_1_eth_payload_tuser(input_1_eth_payload_tuser),
    .input_2_eth_hdr_valid(input_2_eth_hdr_valid & grant[2]),
    .input_2_eth_hdr_ready(input_2_eth_hdr_ready),
    .input_2_eth_dest_mac(input_2_eth_dest_mac),
    .input_2_eth_src_mac(input_2_eth_src_mac),
    .input_2_eth_type(input_2_eth_type),
    .input_2_eth_payload_tdata(input_2_eth_payload_tdata),
    .input_2_eth_payload_tkeep(input_2_eth_payload_tkeep),
    .input_2_eth_payload_tvalid(input_2_eth_payload_tvalid & grant[2]),
    .input_2_eth_payload_tready(input_2_eth_payload_tready),
    .input_2_eth_payload_tlast(input_2_eth_payload_tlast),
    .input_2_eth_payload_tuser(input_2_eth_payload_tuser),
    .input_3_eth_hdr_valid(input_3_eth_hdr_valid & grant[3]),
    .input_3_eth_hdr_ready(input_3_eth_hdr_ready),
    .input_3_eth_dest_mac(input_3_eth_dest_mac),
    .input_3_eth_src_mac(input_3_eth_src_mac),
    .input_3_eth_type(input_3_eth_type),
    .input_3_eth_payload_tdata(input_3_eth_payload_tdata),
    .input_3_eth_payload_tkeep(input_3_eth_payload_tkeep),
    .input_3_eth_payload_tvalid(input_3_eth_payload_tvalid & grant[3]),
    .input_3_eth_payload_tready(input_3_eth_payload_tready),
    .input_3_eth_payload_tlast(input_3_eth_payload_tlast),
    .input_3_eth_payload_tuser(input_3_eth_payload_tuser),
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tkeep(output_eth_payload_tkeep),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
    .enable(grant_valid),
    .select(grant_encoded)
);

// arbiter instance
arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
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

endmodule
