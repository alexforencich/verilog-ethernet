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
 * Testbench for arp_eth_tx
 */
module test_arp_eth_tx_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg s_frame_valid = 0;
reg [47:0] s_eth_dest_mac = 0;
reg [47:0] s_eth_src_mac = 0;
reg [15:0] s_eth_type = 0;
reg [15:0] s_arp_htype = 0;
reg [15:0] s_arp_ptype = 0;
reg [15:0] s_arp_oper = 0;
reg [47:0] s_arp_sha = 0;
reg [31:0] s_arp_spa = 0;
reg [47:0] s_arp_tha = 0;
reg [31:0] s_arp_tpa = 0;
reg m_eth_hdr_ready = 0;
reg m_eth_payload_axis_tready = 0;

// Outputs
wire s_frame_ready;
wire m_eth_hdr_valid;
wire [47:0] m_eth_dest_mac;
wire [47:0] m_eth_src_mac;
wire [15:0] m_eth_type;
wire [DATA_WIDTH-1:0] m_eth_payload_axis_tdata;
wire [KEEP_WIDTH-1:0] m_eth_payload_axis_tkeep;
wire m_eth_payload_axis_tvalid;
wire m_eth_payload_axis_tlast;
wire m_eth_payload_axis_tuser;
wire busy;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_frame_valid,
        s_eth_dest_mac,
        s_eth_src_mac,
        s_eth_type,
        s_arp_htype,
        s_arp_ptype,
        s_arp_oper,
        s_arp_sha,
        s_arp_spa,
        s_arp_tha,
        s_arp_tpa,
        m_eth_hdr_ready,
        m_eth_payload_axis_tready
    );
    $to_myhdl(
        s_frame_ready,
        m_eth_hdr_valid,
        m_eth_dest_mac,
        m_eth_src_mac,
        m_eth_type,
        m_eth_payload_axis_tdata,
        m_eth_payload_axis_tkeep,
        m_eth_payload_axis_tvalid,
        m_eth_payload_axis_tlast,
        m_eth_payload_axis_tuser,
        busy
    );

    // dump file
    $dumpfile("test_arp_eth_tx_64.lxt");
    $dumpvars(0, test_arp_eth_tx_64);
end

arp_eth_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // ARP frame input
    .s_frame_valid(s_frame_valid),
    .s_frame_ready(s_frame_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_arp_htype(s_arp_htype),
    .s_arp_ptype(s_arp_ptype),
    .s_arp_oper(s_arp_oper),
    .s_arp_sha(s_arp_sha),
    .s_arp_spa(s_arp_spa),
    .s_arp_tha(s_arp_tha),
    .s_arp_tpa(s_arp_tpa),
    // Ethernet frame output
    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(m_eth_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(m_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(m_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),
    // Status signals
    .busy(busy)
);

endmodule
