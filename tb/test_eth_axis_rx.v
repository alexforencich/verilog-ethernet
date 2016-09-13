/*

Copyright (c) 2014-2016 Alex Forencich

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
 * Testbench for eth_axis_rx
 */
module test_eth_axis_rx;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [7:0] input_axis_tdata = 0;
reg input_axis_tvalid = 0;
reg input_axis_tlast = 0;
reg input_axis_tuser = 0;
reg output_eth_hdr_ready = 0;
reg output_eth_payload_tready = 0;

// Outputs
wire input_axis_tready;
wire output_eth_hdr_valid;
wire [47:0] output_eth_dest_mac;
wire [47:0] output_eth_src_mac;
wire [15:0] output_eth_type;
wire [7:0] output_eth_payload_tdata;
wire output_eth_payload_tvalid;
wire output_eth_payload_tlast;
wire output_eth_payload_tuser;
wire busy;
wire error_header_early_termination;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_axis_tdata,
        input_axis_tvalid,
        input_axis_tlast,
        input_axis_tuser,
        output_eth_hdr_ready,
        output_eth_payload_tready
    );
    $to_myhdl(
        input_axis_tready,
        output_eth_hdr_valid,
        output_eth_dest_mac,
        output_eth_src_mac,
        output_eth_type,
        output_eth_payload_tdata,
        output_eth_payload_tvalid,
        output_eth_payload_tlast,
        output_eth_payload_tuser,
        busy,
        error_header_early_termination
    );

    // dump file
    $dumpfile("test_eth_axis_rx.lxt");
    $dumpvars(0, test_eth_axis_rx);
end

eth_axis_rx
UUT (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    // Ethernet frame output
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
    // Status signals
    .busy(busy),
    .error_header_early_termination(error_header_early_termination)
);

endmodule
