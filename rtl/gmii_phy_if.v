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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * GMII PHY interface
 */
module gmii_phy_if #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR2",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-5, Virtex-6, 7-series
    // Use BUFG for Ultrascale
    // Use BUFIO2 for Spartan-6
    parameter CLOCK_INPUT_STYLE = "BUFIO2"
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * GMII interface to MAC
     */
    output wire        mac_gmii_rx_clk,
    output wire        mac_gmii_rx_rst,
    output wire [7:0]  mac_gmii_rxd,
    output wire        mac_gmii_rx_dv,
    output wire        mac_gmii_rx_er,
    output wire        mac_gmii_tx_clk,
    output wire        mac_gmii_tx_rst,
    input  wire [7:0]  mac_gmii_txd,
    input  wire        mac_gmii_tx_en,
    input  wire        mac_gmii_tx_er,

    /*
     * GMII interface to PHY
     */
    input  wire        phy_gmii_rx_clk,
    input  wire [7:0]  phy_gmii_rxd,
    input  wire        phy_gmii_rx_dv,
    input  wire        phy_gmii_rx_er,
    input  wire        phy_mii_tx_clk,
    output wire        phy_gmii_tx_clk,
    output wire [7:0]  phy_gmii_txd,
    output wire        phy_gmii_tx_en,
    output wire        phy_gmii_tx_er,

    /*
     * Control
     */
    input  wire        mii_select
);

ssio_sdr_in #
(
    .TARGET(TARGET),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .WIDTH(10)
)
rx_ssio_sdr_inst (
    .input_clk(phy_gmii_rx_clk),
    .input_d({phy_gmii_rxd, phy_gmii_rx_dv, phy_gmii_rx_er}),
    .output_clk(mac_gmii_rx_clk),
    .output_q({mac_gmii_rxd, mac_gmii_rx_dv, mac_gmii_rx_er})
);

ssio_sdr_out #
(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .WIDTH(10)
)
tx_ssio_sdr_inst (
    .clk(mac_gmii_tx_clk),
    .input_d({mac_gmii_txd, mac_gmii_tx_en, mac_gmii_tx_er}),
    .output_clk(phy_gmii_tx_clk),
    .output_q({phy_gmii_txd, phy_gmii_tx_en, phy_gmii_tx_er})
);

generate

if (TARGET == "XILINX") begin
    BUFGMUX
    gmii_bufgmux_inst (
        .I0(clk),
        .I1(phy_mii_tx_clk),
        .S(mii_select),
        .O(mac_gmii_tx_clk)
    );
end else begin
    assign mac_gmii_tx_clk = mii_select ? phy_mii_tx_clk : clk;
end

endgenerate

// reset sync
reg [3:0] tx_rst_reg = 4'hf;
assign mac_gmii_tx_rst = tx_rst_reg[0];

always @(posedge mac_gmii_tx_clk or posedge rst) begin
    if (rst) begin
        tx_rst_reg <= 4'hf;
    end else begin
        tx_rst_reg <= {1'b0, tx_rst_reg[3:1]};
    end
end

reg [3:0] rx_rst_reg = 4'hf;
assign mac_gmii_rx_rst = rx_rst_reg[0];

always @(posedge mac_gmii_rx_clk or posedge rst) begin
    if (rst) begin
        rx_rst_reg <= 4'hf;
    end else begin
        rx_rst_reg <= {1'b0, rx_rst_reg[3:1]};
    end
end

endmodule

`resetall
