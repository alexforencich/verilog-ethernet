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
 * Testbench for eth_axis_tx
 */
module test_eth_axis_tx;

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
reg m_axis_tready = 0;

// Outputs
wire s_eth_payload_axis_tready;
wire s_eth_hdr_ready;
wire [DATA_WIDTH-1:0] m_axis_tdata;
wire [KEEP_WIDTH-1:0] m_axis_tkeep;
wire m_axis_tvalid;
wire m_axis_tlast;
wire m_axis_tuser;
wire busy;

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
        m_axis_tready
    );
    $to_myhdl(
        s_eth_hdr_ready,
        s_eth_payload_axis_tready,
        m_axis_tdata,
        m_axis_tkeep,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tuser,
        busy
    );

    // dump file
    $dumpfile("test_eth_axis_tx.lxt");
    $dumpvars(0, test_eth_axis_tx);
end

eth_axis_tx #(
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
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    // Status signals
    .busy(busy)
);

endmodule
