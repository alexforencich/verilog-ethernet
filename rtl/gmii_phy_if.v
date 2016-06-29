/*

Copyright (c) 2015-2016 Alex Forencich

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
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR2",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-5, Virtex-6, 7-series
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
    output wire        phy_gmii_tx_clk,
    output wire [7:0]  phy_gmii_txd,
    output wire        phy_gmii_tx_en,
    output wire        phy_gmii_tx_er
);

wire phy_gmii_rx_clk_int;
wire phy_gmii_rx_clk_io;
wire phy_gmii_tx_clk_int;

generate

if (TARGET == "XILINX") begin

    // use Xilinx clocking primitives

    if (CLOCK_INPUT_STYLE == "BUFG") begin

        // buffer RX clock
        BUFG
        phy_gmii_rx_clk_bufg (
            .I(phy_gmii_rx_clk),
            .O(phy_gmii_rx_clk_int)
        );

        // pass through RX clock to MAC and input buffers
        assign phy_gmii_rx_clk_io = phy_gmii_rx_clk_int;
        assign mac_gmii_rx_clk = phy_gmii_rx_clk_int;
        
    end else if (CLOCK_INPUT_STYLE == "BUFR") begin

        assign phy_gmii_rx_clk_int = phy_gmii_rx_clk;

        // pass through RX clock to input buffers
        BUFIO
        phy_gmii_rx_clk_bufio (
            .I(phy_gmii_rx_clk_int),
            .O(phy_gmii_rx_clk_io)
        );

        // pass through RX clock to MAC
        BUFR #(
            .BUFR_DIVIDE("BYPASS")
        )
        phy_gmii_rx_clk_bufr (
            .I(phy_gmii_rx_clk_int),
            .O(mac_gmii_rx_clk),
            .CE(1'b1),
            .CLR(1'b0)
        );
        
    end else if (CLOCK_INPUT_STYLE == "BUFIO") begin

        assign phy_gmii_rx_clk_int = phy_gmii_rx_clk;

        // pass through RX clock to input buffers
        BUFIO
        phy_gmii_rx_clk_bufio (
            .I(phy_gmii_rx_clk_int),
            .O(phy_gmii_rx_clk_io)
        );

        // pass through RX clock to MAC
        BUFG
        phy_gmii_rx_clk_bufg (
            .I(phy_gmii_rx_clk_int),
            .O(mac_gmii_rx_clk)
        );

    end else if (CLOCK_INPUT_STYLE == "BUFIO2") begin

        // pass through RX clock to input buffers
        BUFIO2 #(
            .DIVIDE(1),
            .DIVIDE_BYPASS("TRUE"),
            .I_INVERT("FALSE"),
            .USE_DOUBLER("FALSE")
        )
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
        
    end

    // pass through clock to MAC
    assign mac_gmii_tx_clk = clk;

    // pass through clock to PHY
    assign phy_gmii_tx_clk_int = clk;
    
    // invert to center clock edge in valid window
    if (IODDR_STYLE == "IODDR") begin
        ODDR
        phy_gmii_tx_clk_oddr (
            .Q(phy_gmii_tx_clk),
            .C(phy_gmii_tx_clk_int),
            .CE(1'b1),
            .D1(1'b0),
            .D2(1'b1),
            .R(1'b0),
            .S(1'b0)
        );
    end else if (IODDR_STYLE == "IODDR2") begin
        ODDR2
        phy_gmii_tx_clk_oddr (
            .Q(phy_gmii_tx_clk),
            .C0(phy_gmii_tx_clk_int),
            .C1(~phy_gmii_tx_clk_int),
            .CE(1'b1),
            .D0(1'b0),
            .D1(1'b1),
            .R(1'b0),
            .S(1'b0)
        );
    end

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
reg [7:0] gmii_rxd_reg = 8'd0;
(* IOB = "TRUE" *)
reg gmii_rx_dv_reg = 1'b0;
(* IOB = "TRUE" *)
reg gmii_rx_er_reg = 1'b0;

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
reg [7:0] gmii_txd_reg = 8'd0;
(* IOB = "TRUE" *)
reg gmii_tx_en_reg = 1'b0;
(* IOB = "TRUE" *)
reg gmii_tx_er_reg = 1'b0;

always @(posedge phy_gmii_tx_clk_int) begin
    gmii_txd_reg <= mac_gmii_txd;
    gmii_tx_en_reg <= mac_gmii_tx_en;
    gmii_tx_er_reg <= mac_gmii_tx_er;
end

assign phy_gmii_txd = gmii_txd_reg;
assign phy_gmii_tx_en = gmii_tx_en_reg;
assign phy_gmii_tx_er = gmii_tx_er_reg;

endmodule
