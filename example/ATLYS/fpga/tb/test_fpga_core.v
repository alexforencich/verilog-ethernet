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
 * Testbench for fpga_core
 */
module test_fpga_core;

// Parameters
parameter TARGET = "SIM";

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg btnu = 0;
reg btnl = 0;
reg btnd = 0;
reg btnr = 0;
reg btnc = 0;
reg [7:0] sw = 0;
reg phy_rx_clk = 0;
reg [7:0] phy_rxd = 0;
reg phy_rx_dv = 0;
reg phy_rx_er = 0;
reg phy_tx_clk = 0;
reg uart_rxd = 0;

// Outputs
wire [7:0] led;
wire phy_gtx_clk;
wire [7:0] phy_txd;
wire phy_tx_en;
wire phy_tx_er;
wire phy_reset_n;
wire uart_txd;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw,
        phy_rx_clk,
        phy_rxd,
        phy_rx_dv,
        phy_rx_er,
        phy_tx_clk,
        uart_rxd
    );
    $to_myhdl(
        led,
        phy_gtx_clk,
        phy_txd,
        phy_tx_en,
        phy_tx_er,
        phy_reset_n,
        uart_txd
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core #(
    .TARGET(TARGET)
)
UUT (
    .clk(clk),
    .rst(rst),
    .btnu(btnu),
    .btnl(btnl),
    .btnd(btnd),
    .btnr(btnr),
    .btnc(btnc),
    .sw(sw),
    .led(led),
    .phy_rx_clk(phy_rx_clk),
    .phy_rxd(phy_rxd),
    .phy_rx_dv(phy_rx_dv),
    .phy_rx_er(phy_rx_er),
    .phy_gtx_clk(phy_gtx_clk),
    .phy_tx_clk(phy_tx_clk),
    .phy_txd(phy_txd),
    .phy_tx_en(phy_tx_en),
    .phy_tx_er(phy_tx_er),
    .phy_reset_n(phy_reset_n),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd)
);

endmodule
