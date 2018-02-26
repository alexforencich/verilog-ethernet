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
 * Testbench for arp_eth_rx_64
 */
module test_arp_eth_rx_64;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_eth_hdr_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [63:0] input_eth_payload_tdata = 0;
reg [7:0] input_eth_payload_tkeep = 0;
reg input_eth_payload_tvalid = 0;
reg input_eth_payload_tlast = 0;
reg input_eth_payload_tuser = 0;
reg output_frame_ready = 0;

// Outputs
wire input_eth_hdr_ready;
wire input_eth_payload_tready;
wire output_frame_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [15:0] output_arp_htype;
wire [15:0] output_arp_ptype;
wire [7:0]  output_arp_hlen;
wire [7:0]  output_arp_plen;
wire [15:0] output_arp_oper;
wire [47:0] output_arp_sha;
wire [31:0] output_arp_spa;
wire [47:0] output_arp_tha;
wire [31:0] output_arp_tpa;
wire busy;
wire error_header_early_termination;
wire error_invalid_header;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_eth_hdr_valid,
        input_eth_dest_mac,
        input_eth_src_mac,
        input_eth_type,
        input_eth_payload_tdata,
        input_eth_payload_tkeep,
        input_eth_payload_tvalid,
        input_eth_payload_tlast,
        input_eth_payload_tuser,
        output_frame_ready
    );
    $to_myhdl(
        input_eth_hdr_ready,
        input_eth_payload_tready,
        output_frame_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_arp_htype,
        output_arp_ptype,
        output_arp_hlen,
        output_arp_plen,
        output_arp_oper,
        output_arp_sha,
        output_arp_spa,
        output_arp_tha,
        output_arp_tpa,
        busy,
        error_header_early_termination,
        error_invalid_header
    );

    // dump file
    $dumpfile("test_arp_eth_rx_64.lxt");
    $dumpvars(0, test_arp_eth_rx_64);
end

arp_eth_rx_64
UUT (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .input_eth_hdr_valid(input_eth_hdr_valid),
    .input_eth_hdr_ready(input_eth_hdr_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_eth_payload_tdata(input_eth_payload_tdata),
    .input_eth_payload_tkeep(input_eth_payload_tkeep),
    .input_eth_payload_tvalid(input_eth_payload_tvalid),
    .input_eth_payload_tready(input_eth_payload_tready),
    .input_eth_payload_tlast(input_eth_payload_tlast),
    .input_eth_payload_tuser(input_eth_payload_tuser),
    // ARP frame output
    .output_frame_valid(output_frame_valid),
    .output_frame_ready(output_frame_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_arp_htype(output_arp_htype),
    .output_arp_ptype(output_arp_ptype),
    .output_arp_hlen(output_arp_hlen),
    .output_arp_plen(output_arp_plen),
    .output_arp_oper(output_arp_oper),
    .output_arp_sha(output_arp_sha),
    .output_arp_spa(output_arp_spa),
    .output_arp_tha(output_arp_tha),
    .output_arp_tpa(output_arp_tpa),
    // Status signals
    .busy(busy),
    .error_header_early_termination(error_header_early_termination),
    .error_invalid_header(error_invalid_header)
);

endmodule
