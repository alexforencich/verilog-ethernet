/*

Copyright (c) 2018 Alex Forencich

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
 * Testbench for xgmii_baser_enc_64
 */
module test_xgmii_baser_enc_64;

// Parameters
parameter DATA_WIDTH = 64;
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter HDR_WIDTH = 2;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [DATA_WIDTH-1:0] xgmii_txd = 0;
reg [CTRL_WIDTH-1:0] xgmii_txc = 0;

// Outputs
wire [DATA_WIDTH-1:0] encoded_tx_data;
wire [HDR_WIDTH-1:0] encoded_tx_hdr;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        xgmii_txd,
        xgmii_txc
    );
    $to_myhdl(
        encoded_tx_data,
        encoded_tx_hdr
    );

    // dump file
    $dumpfile("test_xgmii_baser_enc_64.lxt");
    $dumpvars(0, test_xgmii_baser_enc_64);
end

xgmii_baser_enc_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .encoded_tx_data(encoded_tx_data),
    .encoded_tx_hdr(encoded_tx_hdr)
);

endmodule
