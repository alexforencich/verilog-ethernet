/*

Copyright (c) 2019 Alex Forencich

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
 * MII PHY interface
 */
module mii_phy_if #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-5, Virtex-6, 7-series
    // Use BUFG for Ultrascale
    // Use BUFIO2 for Spartan-6
    parameter CLOCK_INPUT_STYLE = "BUFIO2"
)
(
    input  wire        rst,

    /*
     * MII interface to MAC
     */
    output wire        mac_mii_rx_clk,
    output wire        mac_mii_rx_rst,
    output wire [3:0]  mac_mii_rxd,
    output wire        mac_mii_rx_dv,
    output wire        mac_mii_rx_er,
    output wire        mac_mii_tx_clk,
    output wire        mac_mii_tx_rst,
    input  wire [3:0]  mac_mii_txd,
    input  wire        mac_mii_tx_en,
    input  wire        mac_mii_tx_er,

    /*
     * MII interface to PHY
     */
    input  wire        phy_mii_rx_clk,
    input  wire [3:0]  phy_mii_rxd,
    input  wire        phy_mii_rx_dv,
    input  wire        phy_mii_rx_er,
    input  wire        phy_mii_tx_clk,
    output wire [3:0]  phy_mii_txd,
    output wire        phy_mii_tx_en,
    output wire        phy_mii_tx_er
);

ssio_sdr_in #
(
    .TARGET(TARGET),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .WIDTH(6)
)
rx_ssio_sdr_inst (
    .input_clk(phy_mii_rx_clk),
    .input_d({phy_mii_rxd, phy_mii_rx_dv, phy_mii_rx_er}),
    .output_clk(mac_mii_rx_clk),
    .output_q({mac_mii_rxd, mac_mii_rx_dv, mac_mii_rx_er})
);

(* IOB = "TRUE" *)
reg [3:0] phy_mii_txd_reg = 4'd0;
(* IOB = "TRUE" *)
reg phy_mii_tx_en_reg = 1'b0, phy_mii_tx_er_reg = 1'b0;

assign phy_mii_txd = phy_mii_txd_reg;
assign phy_mii_tx_en = phy_mii_tx_en_reg;
assign phy_mii_tx_er = phy_mii_tx_er_reg;

always @(posedge mac_mii_tx_clk) begin
    phy_mii_txd_reg <= mac_mii_txd;
    phy_mii_tx_en_reg <= mac_mii_tx_en;
    phy_mii_tx_er_reg <= mac_mii_tx_er;
end

generate

if (TARGET == "XILINX") begin
    BUFG
    mii_bufg_inst (
        .I(phy_mii_tx_clk),
        .O(mac_mii_tx_clk)
    );
end else begin
    assign mac_mii_tx_clk = phy_mii_tx_clk;
end

endgenerate

// reset sync
reg [3:0] tx_rst_reg = 4'hf;
assign mac_mii_tx_rst = tx_rst_reg[0];

always @(posedge mac_mii_tx_clk or posedge rst) begin
    if (rst) begin
        tx_rst_reg <= 4'hf;
    end else begin
        tx_rst_reg <= {1'b0, tx_rst_reg[3:1]};
    end
end

reg [3:0] rx_rst_reg = 4'hf;
assign mac_mii_rx_rst = rx_rst_reg[0];

always @(posedge mac_mii_rx_clk or posedge rst) begin
    if (rst) begin
        rx_rst_reg <= 4'hf;
    end else begin
        rx_rst_reg <= {1'b0, rx_rst_reg[3:1]};
    end
end

endmodule

`resetall
