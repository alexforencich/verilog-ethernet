/*

Copyright (c) 2015 Alex Forencich

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
 * GMII PHY interface
 */
module gmii_phy_if #
(
    parameter TARGET_XILINX = 0
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
    output wire        phy_gmii_tx_clk,
    output wire [7:0]  phy_gmii_txd,
    output wire        phy_gmii_tx_en,
    output wire        phy_gmii_tx_er
);

wire phy_gmii_rx_clk_int;
wire phy_gmii_rx_clk_io;
wire phy_gmii_tx_clk_int;

generate

if (TARGET_XILINX) begin

    // use Xilinx clocking primitives

    // pass through RX clock to input buffers
    BUFIO2
    phy_gmii_rx_clk_bufio (
        .I(phy_gmii_rx_clk),
        .DIVCLK(phy_gmii_rx_clk_int),
        .IOCLK(phy_gmii_rx_clk_io),
        .SERDESSTROBE()
    );

    // pass through RX clock to MAC
    BUFG
    phy_gmii_rx_clk_bufg (
        .I(phy_gmii_rx_clk_int),
        .O(mac_gmii_rx_clk)
    );

    // pass through clock to MAC
    assign mac_gmii_tx_clk = clk;

    // pass through clock to PHY
    assign phy_gmii_tx_clk_int = clk;
    
    // invert to center clock edge in valid window
    ODDR2
    phy_gmii_tx_clk_oddr (
        .Q(phy_gmii_tx_clk),
        .C0(phy_gmii_tx_clk_int),
        .C1(~phy_gmii_tx_clk_int),
        .CE(1),
        .D0(0),
        .D1(1),
        .R(0),
        .S(0)
    );

end else begin

    // pass through RX clock to input buffers
    assign phy_gmii_rx_clk_io = phy_gmii_rx_clk;

    // pass through RX clock to MAC
    assign phy_gmii_rx_clk_int = phy_gmii_rx_clk;
    assign mac_gmii_rx_clk = phy_gmii_rx_clk_int;

    // pass through clock to MAC
    assign mac_gmii_tx_clk = clk;

    // pass through clock to PHY
    assign phy_gmii_tx_clk_int = clk;

    // invert to center clock edge in valid window
    assign phy_gmii_tx_clk = ~phy_gmii_tx_clk_int;

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

// register RX data from PHY to MAC
(* IOB = "TRUE" *)
reg [7:0] gmii_rxd_reg = 0;
(* IOB = "TRUE" *)
reg gmii_rx_dv_reg = 0;
(* IOB = "TRUE" *)
reg gmii_rx_er_reg = 0;

always @(posedge phy_gmii_rx_clk_io) begin
    gmii_rxd_reg <= phy_gmii_rxd;
    gmii_rx_dv_reg <= phy_gmii_rx_dv;
    gmii_rx_er_reg <= phy_gmii_rx_er;
end

assign mac_gmii_rxd = gmii_rxd_reg;
assign mac_gmii_rx_dv = gmii_rx_dv_reg;
assign mac_gmii_rx_er = gmii_rx_er_reg;

// register TX data from MAC to PHY
(* IOB = "TRUE" *)
reg [7:0] gmii_txd_reg = 0;
(* IOB = "TRUE" *)
reg gmii_tx_en_reg = 0;
(* IOB = "TRUE" *)
reg gmii_tx_er_reg = 0;

always @(posedge phy_gmii_tx_clk_int) begin
    gmii_txd_reg <= mac_gmii_txd;
    gmii_tx_en_reg <= mac_gmii_tx_en;
    gmii_tx_er_reg <= mac_gmii_tx_er;
end

assign phy_gmii_txd = gmii_txd_reg;
assign phy_gmii_tx_en = gmii_tx_en_reg;
assign phy_gmii_tx_er = gmii_tx_er_reg;

endmodule
