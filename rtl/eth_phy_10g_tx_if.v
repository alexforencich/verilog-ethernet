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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * 10G Ethernet PHY TX IF
 */
module eth_phy_10g_tx_if #
(
    parameter DATA_WIDTH = 64,
    parameter HDR_WIDTH = 2,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0,
    parameter PRBS31_ENABLE = 0,
    parameter SERDES_PIPELINE = 0
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * 10GBASE-R encoded interface
     */
    input  wire [DATA_WIDTH-1:0] encoded_tx_data,
    input  wire [HDR_WIDTH-1:0]  encoded_tx_hdr,

    /*
     * SERDES interface
     */
    output wire [DATA_WIDTH-1:0] serdes_tx_data,
    output wire [HDR_WIDTH-1:0]  serdes_tx_hdr,

    /*
     * Configuration
     */
    input  wire                  tx_prbs31_enable
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (HDR_WIDTH != 2) begin
        $error("Error: HDR_WIDTH must be 2");
        $finish;
    end
end

reg [57:0] scrambler_state_reg = {58{1'b1}};
wire [57:0] scrambler_state;
wire [DATA_WIDTH-1:0] scrambled_data;

reg [30:0] prbs31_state_reg = 31'h7fffffff;
wire [30:0] prbs31_state;
wire [DATA_WIDTH+HDR_WIDTH-1:0] prbs31_data;

reg [DATA_WIDTH-1:0] serdes_tx_data_reg = {DATA_WIDTH{1'b0}};
reg [HDR_WIDTH-1:0] serdes_tx_hdr_reg = {HDR_WIDTH{1'b0}};

wire [DATA_WIDTH-1:0] serdes_tx_data_int;
wire [HDR_WIDTH-1:0]  serdes_tx_hdr_int;

generate
    genvar n;

    if (BIT_REVERSE) begin
        for (n = 0; n < DATA_WIDTH; n = n + 1) begin
            assign serdes_tx_data_int[n] = serdes_tx_data_reg[DATA_WIDTH-n-1];
        end

        for (n = 0; n < HDR_WIDTH; n = n + 1) begin
            assign serdes_tx_hdr_int[n] = serdes_tx_hdr_reg[HDR_WIDTH-n-1];
        end
    end else begin
        assign serdes_tx_data_int = serdes_tx_data_reg;
        assign serdes_tx_hdr_int = serdes_tx_hdr_reg;
    end

    if (SERDES_PIPELINE > 0) begin
        (* srl_style = "register" *)
        reg [DATA_WIDTH-1:0] serdes_tx_data_pipe_reg[SERDES_PIPELINE-1:0];
        (* srl_style = "register" *)
        reg [HDR_WIDTH-1:0]  serdes_tx_hdr_pipe_reg[SERDES_PIPELINE-1:0];

        for (n = 0; n < SERDES_PIPELINE; n = n + 1) begin
            initial begin
                serdes_tx_data_pipe_reg[n] <= {DATA_WIDTH{1'b0}};
                serdes_tx_hdr_pipe_reg[n] <= {HDR_WIDTH{1'b0}};
            end

            always @(posedge clk) begin
                serdes_tx_data_pipe_reg[n] <= n == 0 ? serdes_tx_data_int : serdes_tx_data_pipe_reg[n-1];
                serdes_tx_hdr_pipe_reg[n] <= n == 0 ? serdes_tx_hdr_int : serdes_tx_hdr_pipe_reg[n-1];
            end
        end

        assign serdes_tx_data = serdes_tx_data_pipe_reg[SERDES_PIPELINE-1];
        assign serdes_tx_hdr = serdes_tx_hdr_pipe_reg[SERDES_PIPELINE-1];
    end else begin
        assign serdes_tx_data = serdes_tx_data_int;
        assign serdes_tx_hdr = serdes_tx_hdr_int;
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

lfsr #(
    .LFSR_WIDTH(31),
    .LFSR_POLY(31'h10000001),
    .LFSR_CONFIG("FIBONACCI"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(DATA_WIDTH+HDR_WIDTH),
    .STYLE("AUTO")
)
prbs31_gen_inst (
    .data_in({DATA_WIDTH+HDR_WIDTH{1'b0}}),
    .state_in(prbs31_state_reg),
    .data_out(prbs31_data),
    .state_out(prbs31_state)
);

always @(posedge clk) begin
    scrambler_state_reg <= scrambler_state;

    if (PRBS31_ENABLE && tx_prbs31_enable) begin
        prbs31_state_reg <= prbs31_state;

        serdes_tx_data_reg <= ~prbs31_data[DATA_WIDTH+HDR_WIDTH-1:HDR_WIDTH];
        serdes_tx_hdr_reg <= ~prbs31_data[HDR_WIDTH-1:0];
    end else begin
        serdes_tx_data_reg <= SCRAMBLER_DISABLE ? encoded_tx_data : scrambled_data;
        serdes_tx_hdr_reg <= encoded_tx_hdr;
    end
end

endmodule

`resetall
