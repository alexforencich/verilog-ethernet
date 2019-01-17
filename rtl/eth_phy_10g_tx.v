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
 * 10G Ethernet PHY
 */
module eth_phy_10g_tx #
(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * XGMII interface
     */
    input  wire [DATA_WIDTH-1:0] xgmii_txd,
    input  wire [CTRL_WIDTH-1:0] xgmii_txc,

    /*
     * SERDES interface
     */
    output wire [DATA_WIDTH-1:0] serdes_tx_data,
    output wire [HDR_WIDTH-1:0]  serdes_tx_hdr
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end

    if (HDR_WIDTH != 2) begin
        $error("Error: HDR_WIDTH must be 2");
        $finish;
    end
end

wire [DATA_WIDTH-1:0] encoded_tx_data;
wire [HDR_WIDTH-1:0]  encoded_tx_hdr;

xgmii_baser_enc_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .CTRL_WIDTH(CTRL_WIDTH),
    .HDR_WIDTH(HDR_WIDTH)
)
xgmii_baser_enc_inst (
    .clk(clk),
    .rst(rst),
    .xgmii_txd(xgmii_txd),
    .xgmii_txc(xgmii_txc),
    .encoded_tx_data(encoded_tx_data),
    .encoded_tx_hdr(encoded_tx_hdr)
);

reg [57:0] scrambler_state_reg = {58{1'b1}};
wire [57:0] scrambler_state;
wire [DATA_WIDTH-1:0] scrambled_data;

reg [DATA_WIDTH-1:0] serdes_tx_data_reg = {DATA_WIDTH{1'b0}};
reg [HDR_WIDTH-1:0] serdes_tx_hdr_reg = {HDR_WIDTH{1'b0}};

generate
    genvar n;

    if (BIT_REVERSE) begin
        for (n = 0; n < DATA_WIDTH; n = n + 1) begin
            assign serdes_tx_data[n] = serdes_tx_data_reg[DATA_WIDTH-n-1];
        end

        for (n = 0; n < HDR_WIDTH; n = n + 1) begin
            assign serdes_tx_hdr[n] = serdes_tx_hdr_reg[HDR_WIDTH-n-1];
        end
    end else begin
        assign serdes_tx_data = serdes_tx_data_reg;
        assign serdes_tx_hdr = serdes_tx_hdr_reg;
    end
endgenerate

lfsr #(
    .LFSR_WIDTH(58),
    .LFSR_POLY(58'h8000000001),
    .LFSR_CONFIG("FIBONACCI"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(DATA_WIDTH),
    .STYLE("AUTO")
)
scrambler_inst (
    .data_in(encoded_tx_data),
    .state_in(scrambler_state_reg),
    .data_out(scrambled_data),
    .state_out(scrambler_state)
);

always @(posedge clk) begin
    scrambler_state_reg <= scrambler_state;

    serdes_tx_data_reg <= SCRAMBLER_DISABLE ? encoded_tx_data : scrambled_data;
    serdes_tx_hdr_reg <= encoded_tx_hdr;
end

endmodule
