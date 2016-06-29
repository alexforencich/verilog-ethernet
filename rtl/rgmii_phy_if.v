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
 * RGMII PHY interface
 */
module rgmii_phy_if #
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
    parameter CLOCK_INPUT_STYLE = "BUFIO2",
    // Use 90 degree clock for RGMII transmit ("TRUE", "FALSE")
    parameter USE_CLK90 = "TRUE"
)
(
    input  wire        clk,
    input  wire        clk90,
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
     * RGMII interface to PHY
     */
    input  wire        phy_rgmii_rx_clk,
    input  wire [3:0]  phy_rgmii_rxd,
    input  wire        phy_rgmii_rx_ctl,
    output wire        phy_rgmii_tx_clk,
    output wire [3:0]  phy_rgmii_txd,
    output wire        phy_rgmii_tx_ctl
);

wire phy_rgmii_rx_clk_int;
wire phy_rgmii_rx_clk_io;
wire phy_rgmii_tx_clk_int;
wire phy_rgmii_tx_ref_clk_int;

generate

if (TARGET == "XILINX") begin

    // use Xilinx clocking primitives

    if (CLOCK_INPUT_STYLE == "BUFG") begin

        // buffer RX clock
        BUFG
        phy_rgmii_rx_clk_bufg (
            .I(phy_rgmii_rx_clk),
            .O(phy_rgmii_rx_clk_int)
        );

        // pass through RX clock to MAC and input buffers
        assign phy_rgmii_rx_clk_io = phy_rgmii_rx_clk_int;
        assign mac_gmii_rx_clk = phy_rgmii_rx_clk_int;

    end else if (CLOCK_INPUT_STYLE == "BUFR") begin

        assign phy_rgmii_rx_clk_int = phy_rgmii_rx_clk;

        // pass through RX clock to input buffers
        BUFIO
        phy_rgmii_rx_clk_bufio (
            .I(phy_rgmii_rx_clk_int),
            .O(phy_rgmii_rx_clk_io)
        );

        // pass through RX clock to MAC
        BUFR #(
            .BUFR_DIVIDE("BYPASS")
        )
        phy_rgmii_rx_clk_bufr (
            .I(phy_rgmii_rx_clk_int),
            .O(mac_gmii_rx_clk),
            .CE(1'b1),
            .CLR(1'b0)
        );
        
    end else if (CLOCK_INPUT_STYLE == "BUFIO") begin

        assign phy_rgmii_rx_clk_int = phy_rgmii_rx_clk;

        // pass through RX clock to input buffers
        BUFIO
        phy_rgmii_rx_clk_bufio (
            .I(phy_rgmii_rx_clk_int),
            .O(phy_rgmii_rx_clk_io)
        );

        // pass through RX clock to MAC
        BUFG
        phy_rgmii_rx_clk_bufg (
            .I(phy_rgmii_rx_clk_int),
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
        phy_rgmii_rx_clk_bufio (
            .I(phy_rgmii_rx_clk),
            .DIVCLK(phy_rgmii_rx_clk_int),
            .IOCLK(phy_rgmii_rx_clk_io),
            .SERDESSTROBE()
        );

        // pass through RX clock to MAC
        BUFG
        phy_rgmii_rx_clk_bufg (
            .I(phy_rgmii_rx_clk_int),
            .O(mac_gmii_rx_clk)
        );
        
    end

    // pass through clock to MAC
    assign mac_gmii_tx_clk = clk;

    // pass through clock to PHY
    assign phy_rgmii_tx_clk_int = clk;
    assign phy_rgmii_tx_ref_clk_int = USE_CLK90 == "TRUE" ? clk90 : phy_rgmii_tx_clk_int;
    
    // pass through clock to PHY
    if (IODDR_STYLE == "IODDR") begin
        ODDR
        phy_gmii_tx_clk_oddr (
            .Q(phy_rgmii_tx_clk),
            .C(phy_rgmii_tx_ref_clk_int),
            .CE(1'b1),
            .D1(1'b1),
            .D2(1'b0),
            .R(1'b0),
            .S(1'b0)
        );
    end else if (IODDR_STYLE == "IODDR2") begin
        ODDR2
        phy_gmii_tx_clk_oddr (
            .Q(phy_rgmii_tx_clk),
            .C0(phy_rgmii_tx_ref_clk_int),
            .C1(~phy_rgmii_tx_ref_clk_int),
            .C0(clk90),
            .C1(~clk90),
            .CE(1'b1),
            .D0(1'b1),
            .D1(1'b0),
            .R(1'b0),
            .S(1'b0)
        );
    end

end else begin

    // pass through RX clock to input buffers
    assign phy_rgmii_rx_clk_io = phy_rgmii_rx_clk;

    // pass through RX clock to MAC
    assign phy_rgmii_rx_clk_int = phy_rgmii_rx_clk;
    assign mac_gmii_rx_clk = phy_rgmii_rx_clk_int;

    // pass through clock to MAC
    assign mac_gmii_tx_clk = clk;

    // pass through clock to PHY
    assign phy_rgmii_tx_clk_int = clk;
    assign phy_rgmii_tx_ref_clk_int = USE_CLK90 == "TRUE" ? clk90 : phy_rgmii_tx_clk_int;

    // pass through clock to phy
    assign phy_rgmii_tx_clk = phy_rgmii_tx_ref_clk_int;

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

generate

if (TARGET == "XILINX") begin
    // register RX data from PHY to MAC
    wire rgmii_rx_ctl_1;
    wire rgmii_rx_ctl_2;

    if (IODDR_STYLE == "IODDR") begin
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
        )
        phy_rgmii_rxd_iddr_0 (
            .Q1(mac_gmii_rxd[0]),
            .Q2(mac_gmii_rxd[4]),
            .C(phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[0]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
        )
        phy_rgmii_rxd_iddr_1 (
            .Q1(mac_gmii_rxd[1]),
            .Q2(mac_gmii_rxd[5]),
            .C(phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[1]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
        )
        phy_rgmii_rxd_iddr_2 (
            .Q1(mac_gmii_rxd[2]),
            .Q2(mac_gmii_rxd[6]),
            .C(phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[2]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
        )
        phy_rgmii_rxd_iddr_3 (
            .Q1(mac_gmii_rxd[3]),
            .Q2(mac_gmii_rxd[7]),
            .C(phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[3]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED")
        )
        phy_rgmii_rx_ctl_iddr (
            .Q1(rgmii_rx_ctl_1),
            .Q2(rgmii_rx_ctl_2),
            .C(phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rx_ctl),
            .R(1'b0),
            .S(1'b0)
        );
    end else if (IODDR_STYLE == "IODDR2") begin
        IDDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_rxd_iddr_0 (
            .Q0(mac_gmii_rxd[0]),
            .Q1(mac_gmii_rxd[4]),
            .C0(phy_rgmii_rx_clk_io),
            .C1(~phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[0]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_rxd_iddr_1 (
            .Q0(mac_gmii_rxd[1]),
            .Q1(mac_gmii_rxd[5]),
            .C0(phy_rgmii_rx_clk_io),
            .C1(~phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[1]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_rxd_iddr_2 (
            .Q0(mac_gmii_rxd[2]),
            .Q1(mac_gmii_rxd[6]),
            .C0(phy_rgmii_rx_clk_io),
            .C1(~phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[2]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_rxd_iddr_3 (
            .Q0(mac_gmii_rxd[3]),
            .Q1(mac_gmii_rxd[7]),
            .C0(phy_rgmii_rx_clk_io),
            .C1(~phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rxd[3]),
            .R(1'b0),
            .S(1'b0)
        );
        IDDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_rx_ctl_iddr (
            .Q0(rgmii_rx_ctl_1),
            .Q1(rgmii_rx_ctl_2),
            .C0(phy_rgmii_rx_clk_io),
            .C1(~phy_rgmii_rx_clk_io),
            .CE(1'b1),
            .D(phy_rgmii_rx_ctl),
            .R(1'b0),
            .S(1'b0)
        );
    end

    assign mac_gmii_rx_dv = rgmii_rx_ctl_1;
    assign mac_gmii_rx_er = rgmii_rx_ctl_1 ^ rgmii_rx_ctl_2;

    // register TX data from MAC to PHY
    if (IODDR_STYLE == "IODDR") begin
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE")
        )
        phy_rgmii_txd_oddr_0 (
            .Q(phy_rgmii_txd[0]),
            .C(phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D1(mac_gmii_txd[0]),
            .D2(mac_gmii_txd[4]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE")
        )
        phy_rgmii_txd_oddr_1 (
            .Q(phy_rgmii_txd[1]),
            .C(phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D1(mac_gmii_txd[1]),
            .D2(mac_gmii_txd[5]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE")
        )
        phy_rgmii_txd_oddr_2 (
            .Q(phy_rgmii_txd[2]),
            .C(phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D1(mac_gmii_txd[2]),
            .D2(mac_gmii_txd[6]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE")
        )
        phy_rgmii_txd_oddr_3 (
            .Q(phy_rgmii_txd[3]),
            .C(phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D1(mac_gmii_txd[3]),
            .D2(mac_gmii_txd[7]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE")
        )
        phy_rgmii_tx_ctl_oddr (
            .Q(phy_rgmii_tx_ctl),
            .C(phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D1(mac_gmii_tx_en),
            .D2(mac_gmii_tx_en ^ mac_gmii_tx_er),
            .R(1'b0),
            .S(1'b0)
        );
    end else if (IODDR_STYLE == "IODDR2") begin
        ODDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_txd_oddr_0 (
            .Q(phy_rgmii_txd[0]),
            .C0(phy_rgmii_tx_clk_int),
            .C1(~phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D0(mac_gmii_txd[0]),
            .D1(mac_gmii_txd[4]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_txd_oddr_1 (
            .Q(phy_rgmii_txd[1]),
            .C0(phy_rgmii_tx_clk_int),
            .C1(~phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D0(mac_gmii_txd[1]),
            .D1(mac_gmii_txd[5]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_txd_oddr_2 (
            .Q(phy_rgmii_txd[2]),
            .C0(phy_rgmii_tx_clk_int),
            .C1(~phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D0(mac_gmii_txd[2]),
            .D1(mac_gmii_txd[6]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_txd_oddr_3 (
            .Q(phy_rgmii_txd[3]),
            .C0(phy_rgmii_tx_clk_int),
            .C1(~phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D0(mac_gmii_txd[3]),
            .D1(mac_gmii_txd[7]),
            .R(1'b0),
            .S(1'b0)
        );
        ODDR2 #(
            .DDR_ALIGNMENT("C0")
        )
        phy_rgmii_tx_ctl_oddr (
            .Q(phy_rgmii_tx_ctl),
            .C0(phy_rgmii_tx_clk_int),
            .C1(~phy_rgmii_tx_clk_int),
            .CE(1'b1),
            .D0(mac_gmii_tx_en),
            .D1(mac_gmii_tx_en ^ mac_gmii_tx_er),
            .R(1'b0),
            .S(1'b0)
        );
    end

end else if (TARGET == "ALTERA") begin

end else begin
    // register RX data from PHY to MAC
    reg [7:0] gmii_rxd_reg = 8'd0;
    reg gmii_rx_dv_reg = 1'b0;
    reg gmii_rx_er_reg = 1'b0;

    reg [3:0] rgmii_rxd_reg_1 = 4'd0;
    reg [3:0] rgmii_rxd_reg_2 = 4'd0;
    reg rgmii_rx_ctl_reg_1 = 1'b0;
    reg rgmii_rx_ctl_reg_2 = 1'b0;

    always @(posedge phy_rgmii_rx_clk_io) begin
        rgmii_rxd_reg_1 <= phy_rgmii_rxd;
        rgmii_rx_ctl_reg_1 <= phy_rgmii_rx_ctl;
    end

    always @(negedge phy_rgmii_rx_clk_io) begin
        rgmii_rxd_reg_2 <= phy_rgmii_rxd;
        rgmii_rx_ctl_reg_2 <= phy_rgmii_rx_ctl;
    end

    always @(posedge phy_rgmii_rx_clk_io) begin
        gmii_rxd_reg <= {rgmii_rxd_reg_2, rgmii_rxd_reg_1};
        gmii_rx_dv_reg <= rgmii_rx_ctl_reg_1;
        gmii_rx_er_reg <= rgmii_rx_ctl_reg_1 ^ rgmii_rx_ctl_reg_2;
    end

    assign mac_gmii_rxd = gmii_rxd_reg;
    assign mac_gmii_rx_dv = gmii_rx_dv_reg;
    assign mac_gmii_rx_er = gmii_rx_er_reg;

    // register TX data from MAC to PHY
    reg [7:0] gmii_txd_reg = 8'd0;
    reg gmii_tx_en_reg = 1'b0;
    reg gmii_tx_er_reg = 1'b0;

    reg [3:0] rgmii_txd_reg = 4'd0;
    reg rgmii_tx_ctl_reg = 1'b0;

    always @(posedge phy_rgmii_tx_clk_int) begin
        rgmii_txd_reg <= mac_gmii_txd[3:0];
        rgmii_tx_ctl_reg <= mac_gmii_tx_en;
    end

    always @(negedge phy_rgmii_tx_clk_int) begin
        rgmii_txd_reg <= gmii_txd_reg[7:4];
        rgmii_tx_ctl_reg <= gmii_tx_en_reg ^ gmii_tx_er_reg;
    end

    always @(posedge phy_rgmii_tx_clk_int) begin
        gmii_txd_reg <= mac_gmii_txd;
        gmii_tx_en_reg <= mac_gmii_tx_en;
        gmii_tx_er_reg <= mac_gmii_tx_er;
    end

    assign phy_rgmii_txd = rgmii_txd_reg;
    assign phy_rgmii_tx_ctl = rgmii_tx_ctl_reg;
end

endgenerate

endmodule
