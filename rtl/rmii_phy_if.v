/*

Copyright (c) 2026 Alex Forencich

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
 * RMII PHY interface
 *
 * Native RMII (2-bit @ 50 MHz REF_CLK) to/from the eth_mac_1g GMII core. The
 * FPGA/MAC sources the single 50 MHz reference clock. RMII transfers a byte as
 * four di-bits, least-significant di-bit first, with RXD[0]/TXD[0] the low bit
 * of each di-bit (RMII Rev 1.2 Figure 5). This module (de)serializes di-bits to
 * whole bytes and drives eth_mac_1g in GMII mode (mii_select=0) with a byte-rate
 * clock enable.
 *
 * speed selects 100 Mb/s (one di-bit per REF_CLK cycle) or 10 Mb/s (each di-bit
 * repeated for 10 REF_CLK cycles), per RMII Rev 1.2 sections 5.3/5.5.
 *
 * RX recovers RX_DV from CRS_DV per RMII Rev 1.2 section 5.2: after carrier ends
 * the PHY may toggle CRS_DV at 25 MHz (deasserted on the first di-bit of a nibble,
 * asserted on the second) while it drains remaining data. The frame is therefore
 * ended only when CRS_DV is sampled low on a *second* di-bit of a nibble, so the
 * trailing data is still captured.
 */
module rmii_phy_if #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    parameter CLOCK_INPUT_STYLE = "BUFG"
)
(
    input  wire        rst,

    /*
     * RMII reference clock (50 MHz, FPGA-sourced)
     */
    input  wire        ref_clk,

    /*
     * Link speed: 2'b00 = 10 Mb/s, 2'b01 = 100 Mb/s (cf. eth_mac_1g_* speed)
     */
    input  wire [1:0]  speed,

    /*
     * GMII-style byte interface to the MAC core (eth_mac_1g, mii_select=0)
     */
    output wire        mac_clk,
    output wire        mac_rst,
    output wire        mac_rx_clk_enable,
    output wire [7:0]  mac_gmii_rxd,
    output wire        mac_gmii_rx_dv,
    output wire        mac_gmii_rx_er,
    output wire        mac_tx_clk_enable,
    input  wire [7:0]  mac_gmii_txd,
    input  wire        mac_gmii_tx_en,
    input  wire        mac_gmii_tx_er,

    /*
     * RMII interface to PHY
     */
    input  wire        phy_rmii_crs_dv,
    input  wire [1:0]  phy_rmii_rxd,
    input  wire        phy_rmii_rx_er,
    output wire [1:0]  phy_rmii_txd,
    output wire        phy_rmii_tx_en
);

// number of REF_CLK cycles a di-bit occupies (1 at 100M, 10 at 10M)
localparam [3:0] DIBIT_LAST = 4'd9;     // 10 cycles, counts 0..9
localparam [3:0] DIBIT_MID  = 4'd5;     // sample point within a 10-cycle window

// 50 MHz reference clock buffer
generate

if (TARGET == "XILINX") begin
    BUFG
    rmii_bufg_inst (
        .I(ref_clk),
        .O(mac_clk)
    );
end else begin
    assign mac_clk = ref_clk;
end

endgenerate

// reset sync
reg [3:0] rst_reg = 4'hf;
assign mac_rst = rst_reg[0];

always @(posedge mac_clk or posedge rst) begin
    if (rst) begin
        rst_reg <= 4'hf;
    end else begin
        rst_reg <= {1'b0, rst_reg[3:1]};
    end
end

// register the RMII RX pins (pack into IOB)
(* IOB = "TRUE" *)
reg [1:0] rxd_reg = 2'd0;
(* IOB = "TRUE" *)
reg crs_dv_reg = 1'b0;
(* IOB = "TRUE" *)
reg rx_er_reg = 1'b0;

always @(posedge mac_clk) begin
    rxd_reg <= phy_rmii_rxd;
    crs_dv_reg <= phy_rmii_crs_dv;
    rx_er_reg <= phy_rmii_rx_er;
end

// -----------------------------------------------------------------------------
// RX: assemble 4 di-bits (LSB-first) into a byte. At 10M each di-bit is held for
// 10 cycles, sampled mid-window. RX_DV is recovered from CRS_DV per Rev 1.2 5.2
// (end only when CRS_DV is low on a second-di-bit-of-nibble cycle).
// -----------------------------------------------------------------------------
reg        rx_in_frame = 1'b0;
reg [1:0]  rx_idx = 2'd0;        // di-bit index within byte (0..3); odd = 2nd di-bit of a nibble
reg [3:0]  rx_cyc = 4'd0;        // cycle counter within a di-bit (10M)
reg [7:0]  rx_sr = 8'd0;
reg        rx_er_acc = 1'b0;

reg [7:0]  rx_data_reg = 8'd0;
reg        rx_dv_reg = 1'b0;
reg        rx_byte_er_reg = 1'b0;
reg        rx_ce_reg = 1'b0;

wire rx_sample = (speed == 2'b01) ? 1'b1 : (rx_cyc == DIBIT_MID);

always @(posedge mac_clk) begin
    rx_ce_reg <= 1'b0;
    rx_dv_reg <= 1'b0;

    if (mac_rst) begin
        rx_in_frame <= 1'b0;
        rx_idx <= 2'd0;
        rx_cyc <= 4'd0;
        rx_er_acc <= 1'b0;
    end else if (!rx_in_frame) begin
        rx_cyc <= 4'd0;
        if (crs_dv_reg && rxd_reg != 2'b00) begin
            // first di-bit of the preamble (nibble boundary) detected
            rx_in_frame <= 1'b1;
            rx_cyc <= 4'd0;
            if (speed == 2'b01) begin
                // 100M: this cycle carries di-bit 0; capture it now
                rx_sr <= {rxd_reg, 6'd0};
                rx_er_acc <= rx_er_reg;
                rx_idx <= 2'd1;
            end else begin
                // 10M: di-bit 0 is sampled mid-window below
                rx_idx <= 2'd0;
                rx_er_acc <= 1'b0;
            end
        end
    end else begin
        if (speed != 2'b01) rx_cyc <= (rx_cyc == DIBIT_LAST) ? 4'd0 : rx_cyc + 4'd1;

        if (rx_sample) begin
            if (rx_idx[0] && !crs_dv_reg) begin
                // CRS_DV low on a second di-bit of a nibble -> end of frame.
                // Emit a final enable with rx_dv=0 so axis_gmii_rx terminates.
                rx_in_frame <= 1'b0;
                rx_idx <= 2'd0;
                rx_er_acc <= 1'b0;
                rx_ce_reg <= 1'b1;
            end else if (rx_idx == 2'd3) begin
                rx_data_reg <= {rxd_reg, rx_sr[7:2]};
                rx_dv_reg <= 1'b1;
                rx_byte_er_reg <= rx_er_acc | rx_er_reg;
                rx_ce_reg <= 1'b1;
                rx_er_acc <= 1'b0;
                rx_idx <= 2'd0;
            end else begin
                rx_sr <= {rxd_reg, rx_sr[7:2]};
                rx_er_acc <= rx_er_acc | rx_er_reg;
                rx_idx <= rx_idx + 2'd1;
            end
        end
    end
end

assign mac_gmii_rxd = rx_data_reg;
assign mac_gmii_rx_dv = rx_dv_reg;
assign mac_gmii_rx_er = rx_byte_er_reg;
assign mac_rx_clk_enable = rx_ce_reg;

// -----------------------------------------------------------------------------
// TX: serialize each GMII byte into 4 di-bits (LSB-first). At 10M each di-bit is
// held for 10 cycles. The MAC presents a fresh byte the cycle after the byte
// clock enable, so the byte is captured at di-bit index 0 and emitted over 0..3.
// -----------------------------------------------------------------------------
reg [1:0]  tx_idx = 2'd0;
reg [3:0]  tx_cyc = 4'd0;
reg [7:0]  tx_byte = 8'd0;
reg        tx_en_lat = 1'b0;

// not IOB: the consumer (a falling-edge retime stage) owns the output register
reg [1:0]  txd_reg = 2'd0;
reg        tx_en_reg = 1'b0;

wire tx_tick = (speed == 2'b01) ? 1'b1 : (tx_cyc == DIBIT_LAST);

always @(posedge mac_clk) begin
    if (mac_rst) begin
        tx_idx <= 2'd0;
        tx_cyc <= 4'd0;
        tx_byte <= 8'd0;
        tx_en_lat <= 1'b0;
        txd_reg <= 2'd0;
        tx_en_reg <= 1'b0;
    end else begin
        if (speed != 2'b01) tx_cyc <= tx_tick ? 4'd0 : tx_cyc + 4'd1;

        if (tx_tick) begin
            if (tx_idx == 2'd0) begin
                // capture the byte the MAC produced for this enable window
                tx_byte <= mac_gmii_txd;
                tx_en_lat <= mac_gmii_tx_en;
                txd_reg <= mac_gmii_txd[1:0];
                tx_en_reg <= mac_gmii_tx_en;
            end else begin
                txd_reg <= tx_byte[{tx_idx, 1'b0} +: 2];
                tx_en_reg <= tx_en_lat;
            end
            tx_idx <= tx_idx + 2'd1;
        end
    end
end

// advance the MAC one byte per 4 di-bits, so the byte is ready at di-bit index 0
assign mac_tx_clk_enable = tx_tick && (tx_idx == 2'd3);

assign phy_rmii_txd = txd_reg;
assign phy_rmii_tx_en = tx_en_reg;

endmodule

`resetall
