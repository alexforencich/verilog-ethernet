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
 * 10G Ethernet PHY RX IF
 */
module eth_phy_10g_rx_if #
(
    parameter DATA_WIDTH = 64,
    parameter HDR_WIDTH = 2,
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0,
    parameter PRBS31_ENABLE = 0,
    parameter SERDES_PIPELINE = 0,
    parameter BITSLIP_HIGH_CYCLES = 1,
    parameter BITSLIP_LOW_CYCLES = 8,
    parameter COUNT_125US = 125000/6.4
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * 10GBASE-R encoded interface
     */
    output wire [DATA_WIDTH-1:0] encoded_rx_data,
    output wire [HDR_WIDTH-1:0]  encoded_rx_hdr,

    /*
     * SERDES interface
     */
    input  wire [DATA_WIDTH-1:0] serdes_rx_data,
    input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
    output wire                  serdes_rx_bitslip,
    output wire                  serdes_rx_reset_req,

    /*
     * Status
     */
    input  wire                  rx_bad_block,
    input  wire                  rx_sequence_error,
    output wire [6:0]            rx_error_count,
    output wire                  rx_block_lock,
    output wire                  rx_high_ber,

    /*
     * Configuration
     */
    input  wire                  rx_prbs31_enable
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

wire [DATA_WIDTH-1:0] serdes_rx_data_rev, serdes_rx_data_int;
wire [HDR_WIDTH-1:0]  serdes_rx_hdr_rev, serdes_rx_hdr_int;

generate
    genvar n;

    if (BIT_REVERSE) begin
        for (n = 0; n < DATA_WIDTH; n = n + 1) begin
            assign serdes_rx_data_rev[n] = serdes_rx_data[DATA_WIDTH-n-1];
        end

        for (n = 0; n < HDR_WIDTH; n = n + 1) begin
            assign serdes_rx_hdr_rev[n] = serdes_rx_hdr[HDR_WIDTH-n-1];
        end
    end else begin
        assign serdes_rx_data_rev = serdes_rx_data;
        assign serdes_rx_hdr_rev = serdes_rx_hdr;
    end

    if (SERDES_PIPELINE > 0) begin
        (* srl_style = "register" *)
        reg [DATA_WIDTH-1:0] serdes_rx_data_pipe_reg[SERDES_PIPELINE-1:0];
        (* srl_style = "register" *)
        reg [HDR_WIDTH-1:0]  serdes_rx_hdr_pipe_reg[SERDES_PIPELINE-1:0];

        for (n = 0; n < SERDES_PIPELINE; n = n + 1) begin
            initial begin
                serdes_rx_data_pipe_reg[n] <= {DATA_WIDTH{1'b0}};
                serdes_rx_hdr_pipe_reg[n] <= {HDR_WIDTH{1'b0}};
            end

            always @(posedge clk) begin
                serdes_rx_data_pipe_reg[n] <= n == 0 ? serdes_rx_data_rev : serdes_rx_data_pipe_reg[n-1];
                serdes_rx_hdr_pipe_reg[n] <= n == 0 ? serdes_rx_hdr_rev : serdes_rx_hdr_pipe_reg[n-1];
            end
        end

        assign serdes_rx_data_int = serdes_rx_data_pipe_reg[SERDES_PIPELINE-1];
        assign serdes_rx_hdr_int = serdes_rx_hdr_pipe_reg[SERDES_PIPELINE-1];
    end else begin
        assign serdes_rx_data_int = serdes_rx_data_rev;
        assign serdes_rx_hdr_int = serdes_rx_hdr_rev;
    end

endgenerate

wire [DATA_WIDTH-1:0] descrambled_rx_data;

reg [DATA_WIDTH-1:0] encoded_rx_data_reg = {DATA_WIDTH{1'b0}};
reg [HDR_WIDTH-1:0] encoded_rx_hdr_reg = {HDR_WIDTH{1'b0}};

reg [57:0] scrambler_state_reg = {58{1'b1}};
wire [57:0] scrambler_state;

reg [30:0] prbs31_state_reg = 31'h7fffffff;
wire [30:0] prbs31_state;
wire [DATA_WIDTH+HDR_WIDTH-1:0] prbs31_data;

reg [6:0] rx_error_count_reg = 0;
reg [5:0] rx_error_count_1_reg = 0;
reg [5:0] rx_error_count_2_reg = 0;
reg [5:0] rx_error_count_1_temp = 0;
reg [5:0] rx_error_count_2_temp = 0;

lfsr #(
    .LFSR_WIDTH(58),
    .LFSR_POLY(58'h8000000001),
    .LFSR_CONFIG("FIBONACCI"),
    .LFSR_FEED_FORWARD(1),
    .REVERSE(1),
    .DATA_WIDTH(DATA_WIDTH),
    .STYLE("AUTO")
)
descrambler_inst (
    .data_in(serdes_rx_data_int),
    .state_in(scrambler_state_reg),
    .data_out(descrambled_rx_data),
    .state_out(scrambler_state)
);

lfsr #(
    .LFSR_WIDTH(31),
    .LFSR_POLY(31'h10000001),
    .LFSR_CONFIG("FIBONACCI"),
    .LFSR_FEED_FORWARD(1),
    .REVERSE(1),
    .DATA_WIDTH(DATA_WIDTH+HDR_WIDTH),
    .STYLE("AUTO")
)
prbs31_check_inst (
    .data_in(~{serdes_rx_data_int, serdes_rx_hdr_int}),
    .state_in(prbs31_state_reg),
    .data_out(prbs31_data),
    .state_out(prbs31_state)
);

integer i;

always @* begin
    rx_error_count_1_temp = 0;
    rx_error_count_2_temp = 0;
    for (i = 0; i < DATA_WIDTH+HDR_WIDTH; i = i + 1) begin
        if (i & 1) begin
            rx_error_count_1_temp = rx_error_count_1_temp + prbs31_data[i];
        end else begin
            rx_error_count_2_temp = rx_error_count_2_temp + prbs31_data[i];
        end
    end
end

always @(posedge clk) begin
    scrambler_state_reg <= scrambler_state;

    encoded_rx_data_reg <= SCRAMBLER_DISABLE ? serdes_rx_data_int : descrambled_rx_data;
    encoded_rx_hdr_reg <= serdes_rx_hdr_int;

    if (PRBS31_ENABLE && rx_prbs31_enable) begin
        prbs31_state_reg <= prbs31_state;

        rx_error_count_1_reg <= rx_error_count_1_temp;
        rx_error_count_2_reg <= rx_error_count_2_temp;
        rx_error_count_reg <= rx_error_count_1_reg + rx_error_count_2_reg;
    end
end

assign encoded_rx_data = encoded_rx_data_reg;
assign encoded_rx_hdr = encoded_rx_hdr_reg;

assign rx_error_count = rx_error_count_reg;

wire serdes_rx_bitslip_int;
wire serdes_rx_reset_req_int;
assign serdes_rx_bitslip = serdes_rx_bitslip_int && !(PRBS31_ENABLE && rx_prbs31_enable);
assign serdes_rx_reset_req = serdes_rx_reset_req_int && !(PRBS31_ENABLE && rx_prbs31_enable);

eth_phy_10g_rx_frame_sync #(
    .HDR_WIDTH(HDR_WIDTH),
    .BITSLIP_HIGH_CYCLES(BITSLIP_HIGH_CYCLES),
    .BITSLIP_LOW_CYCLES(BITSLIP_LOW_CYCLES)
)
eth_phy_10g_rx_frame_sync_inst (
    .clk(clk),
    .rst(rst),
    .serdes_rx_hdr(serdes_rx_hdr_int),
    .serdes_rx_bitslip(serdes_rx_bitslip_int),
    .rx_block_lock(rx_block_lock)
);

eth_phy_10g_rx_ber_mon #(
    .HDR_WIDTH(HDR_WIDTH),
    .COUNT_125US(COUNT_125US)
)
eth_phy_10g_rx_ber_mon_inst (
    .clk(clk),
    .rst(rst),
    .serdes_rx_hdr(serdes_rx_hdr_int),
    .rx_high_ber(rx_high_ber)
);

eth_phy_10g_rx_watchdog #(
    .HDR_WIDTH(HDR_WIDTH),
    .COUNT_125US(COUNT_125US)
)
eth_phy_10g_rx_watchdog_inst (
    .clk(clk),
    .rst(rst),
    .serdes_rx_hdr(serdes_rx_hdr_int),
    .serdes_rx_reset_req(serdes_rx_reset_req_int),
    .rx_bad_block(rx_bad_block),
    .rx_sequence_error(rx_sequence_error),
    .rx_block_lock(rx_block_lock),
    .rx_high_ber(rx_high_ber)
);

endmodule

`resetall
