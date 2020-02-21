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
 * Testbench for arp_eth_rx
 */
module test_arp_eth_rx;

// Parameters
parameter DATA_WIDTH = 8;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg s_eth_hdr_valid = 0;
reg [47:0] s_eth_dest_mac = 0;
reg [47:0] s_eth_src_mac = 0;
reg [15:0] s_eth_type = 0;
reg [DATA_WIDTH-1:0] s_eth_payload_axis_tdata = 0;
reg [KEEP_WIDTH-1:0] s_eth_payload_axis_tkeep = 0;
reg s_eth_payload_axis_tvalid = 0;
reg s_eth_payload_axis_tlast = 0;
reg s_eth_payload_axis_tuser = 0;
reg m_frame_ready = 0;

// Outputs
wire s_eth_hdr_ready;
wire s_eth_payload_axis_tready;
wire m_frame_valid;
wire [47:0] m_eth_dest_mac;
wire [47:0] m_eth_src_mac;
wire [15:0] m_eth_type;
wire [15:0] m_arp_htype;
wire [15:0] m_arp_ptype;
wire [7:0]  m_arp_hlen;
wire [7:0]  m_arp_plen;
wire [15:0] m_arp_oper;
wire [47:0] m_arp_sha;
wire [31:0] m_arp_spa;
wire [47:0] m_arp_tha;
wire [31:0] m_arp_tpa;
wire busy;
wire error_header_early_termination;
wire error_invalid_header;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_eth_hdr_valid,
        s_eth_dest_mac,
        s_eth_src_mac,
        s_eth_type,
        s_eth_payload_axis_tdata,
        s_eth_payload_axis_tkeep,
        s_eth_payload_axis_tvalid,
        s_eth_payload_axis_tlast,
        s_eth_payload_axis_tuser,
        m_frame_ready
    );
    $to_myhdl(
        s_eth_hdr_ready,
        s_eth_payload_axis_tready,
        m_frame_valid,
        m_eth_dest_mac,
        m_eth_src_mac,
        m_eth_type,
        m_arp_htype,
        m_arp_ptype,
        m_arp_hlen,
        m_arp_plen,
        m_arp_oper,
        m_arp_sha,
        m_arp_spa,
        m_arp_tha,
        m_arp_tpa,
        busy,
        error_header_early_termination,
        error_invalid_header
    );

    // dump file
    $dumpfile("test_arp_eth_rx.lxt");
    $dumpvars(0, test_arp_eth_rx);
end

arp_eth_rx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // Ethernet frame input
    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(s_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),
    // ARP frame output
    .m_frame_valid(m_frame_valid),
    .m_frame_ready(m_frame_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_arp_htype(m_arp_htype),
    .m_arp_ptype(m_arp_ptype),
    .m_arp_hlen(m_arp_hlen),
    .m_arp_plen(m_arp_plen),
    .m_arp_oper(m_arp_oper),
    .m_arp_sha(m_arp_sha),
    .m_arp_spa(m_arp_spa),
    .m_arp_tha(m_arp_tha),
    .m_arp_tpa(m_arp_tpa),
    // Status signals
    .busy(busy),
    .error_header_early_termination(error_header_early_termination),
    .error_invalid_header(error_invalid_header)
);

endmodule
