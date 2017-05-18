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
 * Testbench for arp_eth_tx_64
 */
module test_arp_eth_tx_64;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg input_frame_valid = 0;
reg [47:0] input_eth_dest_mac = 0;
reg [47:0] input_eth_src_mac = 0;
reg [15:0] input_eth_type = 0;
reg [15:0] input_arp_htype = 0;
reg [15:0] input_arp_ptype = 0;
reg [15:0] input_arp_oper = 0;
reg [47:0] input_arp_sha = 0;
reg [31:0] input_arp_spa = 0;
reg [47:0] input_arp_tha = 0;
reg [31:0] input_arp_tpa = 0;
reg output_eth_hdr_ready = 0;
reg output_eth_payload_tready = 0;

// Outputs
wire input_frame_ready;
wire output_eth_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [63:0] output_eth_payload_tdata;
wire [7:0] output_eth_payload_tkeep;
wire output_eth_payload_tvalid;
wire output_eth_payload_tlast;
wire output_eth_payload_tuser;
wire busy;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_frame_valid,
        input_eth_dest_mac,
        input_eth_src_mac,
        input_eth_type,
        input_arp_htype,
        input_arp_ptype,
        input_arp_oper,
        input_arp_sha,
        input_arp_spa,
        input_arp_tha,
        input_arp_tpa,
        output_eth_hdr_ready,
        output_eth_payload_tready
    );
    $to_myhdl(
        input_frame_ready,
        output_eth_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_eth_payload_tdata,
        output_eth_payload_tkeep,
        output_eth_payload_tvalid,
        output_eth_payload_tlast,
        output_eth_payload_tuser,
        busy
    );

    // dump file
    $dumpfile("test_arp_eth_tx_64.lxt");
    $dumpvars(0, test_arp_eth_tx_64);
end

arp_eth_tx_64
UUT (
    .clk(clk),
    .rst(rst),
    // ARP frame input
    .input_frame_valid(input_frame_valid),
    .input_frame_ready(input_frame_ready),
    .input_eth_dest_mac(input_eth_dest_mac),
    .input_eth_src_mac(input_eth_src_mac),
    .input_eth_type(input_eth_type),
    .input_arp_htype(input_arp_htype),
    .input_arp_ptype(input_arp_ptype),
    .input_arp_oper(input_arp_oper),
    .input_arp_sha(input_arp_sha),
    .input_arp_spa(input_arp_spa),
    .input_arp_tha(input_arp_tha),
    .input_arp_tpa(input_arp_tpa),
    // Ethernet frame output
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
    // Status signals
    .busy(busy)
);

endmodule
