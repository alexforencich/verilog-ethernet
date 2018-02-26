/*

Copyright (c) 2015-2018 Alex Forencich

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
 * Testbench for eth_mac_10g_tx
 */
module test_eth_mac_10g_tx;

// Parameters
parameter ENABLE_PADDING = 1;
parameter MIN_FRAME_LENGTH = 64;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [63:0] input_axis_tdata = 0;
reg [7:0] input_axis_tkeep = 0;
reg input_axis_tvalid = 0;
reg input_axis_tlast = 0;
reg input_axis_tuser = 0;
reg [7:0] ifg_delay = 0;

// Outputs
wire input_axis_tready;
wire [63:0] xgmii_txd;
wire [7:0] xgmii_txc;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        input_axis_tdata,
        input_axis_tkeep,
        input_axis_tvalid,
        input_axis_tlast,
        input_axis_tuser,
        ifg_delay
    );
    $to_myhdl(
        input_axis_tready,
        xgmii_txd,
        xgmii_txc
    );

    // dump file
    $dumpfile("test_eth_mac_10g_tx.lxt");
    $dumpvars(0, test_eth_mac_10g_tx);
end

eth_mac_10g_tx #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tkeep(input_axis_tkeep),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .ifg_delay(ifg_delay)
);

endmodule
