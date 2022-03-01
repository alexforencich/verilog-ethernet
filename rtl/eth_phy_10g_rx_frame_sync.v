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
 * 10G Ethernet PHY frame sync
 */
module eth_phy_10g_rx_frame_sync #
(
    parameter HDR_WIDTH = 2,
    parameter BITSLIP_HIGH_CYCLES = 1,
    parameter BITSLIP_LOW_CYCLES = 8
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * SERDES interface
     */
    input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
    output wire                  serdes_rx_bitslip,

    /*
     * Status
     */
    output wire                  rx_block_lock
);

parameter BITSLIP_MAX_CYCLES = BITSLIP_HIGH_CYCLES > BITSLIP_LOW_CYCLES ? BITSLIP_HIGH_CYCLES : BITSLIP_LOW_CYCLES;
parameter BITSLIP_COUNT_WIDTH = $clog2(BITSLIP_MAX_CYCLES);

// bus width assertions
initial begin
    if (HDR_WIDTH != 2) begin
        $error("Error: HDR_WIDTH must be 2");
        $finish;
    end
end

localparam [1:0]
    SYNC_DATA = 2'b10,
    SYNC_CTRL = 2'b01;

reg [5:0] sh_count_reg = 6'd0, sh_count_next;
reg [3:0] sh_invalid_count_reg = 4'd0, sh_invalid_count_next;
reg [BITSLIP_COUNT_WIDTH-1:0] bitslip_count_reg = 0, bitslip_count_next;

reg serdes_rx_bitslip_reg = 1'b0, serdes_rx_bitslip_next;

reg rx_block_lock_reg = 1'b0, rx_block_lock_next;

assign serdes_rx_bitslip = serdes_rx_bitslip_reg;
assign rx_block_lock = rx_block_lock_reg;

always @* begin
    sh_count_next = sh_count_reg;
    sh_invalid_count_next = sh_invalid_count_reg;
    bitslip_count_next = bitslip_count_reg;

    serdes_rx_bitslip_next = serdes_rx_bitslip_reg;

    rx_block_lock_next = rx_block_lock_reg;

    if (bitslip_count_reg) begin
        bitslip_count_next = bitslip_count_reg-1;
    end else if (serdes_rx_bitslip_reg) begin
        serdes_rx_bitslip_next = 1'b0;
        bitslip_count_next = BITSLIP_LOW_CYCLES > 0 ? BITSLIP_LOW_CYCLES-1 : 0;
    end else if (serdes_rx_hdr == SYNC_CTRL || serdes_rx_hdr == SYNC_DATA) begin
        // valid header
        sh_count_next = sh_count_reg + 1;
        if (&sh_count_reg) begin
            // valid count overflow, reset
            sh_count_next = 0;
            sh_invalid_count_next = 0;
            if (!sh_invalid_count_reg) begin
                rx_block_lock_next = 1'b1;
            end
        end
    end else begin
        // invalid header
        sh_count_next = sh_count_reg + 1;
        sh_invalid_count_next = sh_invalid_count_reg + 1;
        if (!rx_block_lock_reg || &sh_invalid_count_reg) begin
            // invalid count overflow, lost block lock
            sh_count_next = 0;
            sh_invalid_count_next = 0;
            rx_block_lock_next = 1'b0;

            // slip one bit
            serdes_rx_bitslip_next = 1'b1;
            bitslip_count_next = BITSLIP_HIGH_CYCLES > 0 ? BITSLIP_HIGH_CYCLES-1 : 0;
        end else if (&sh_count_reg) begin
            // valid count overflow, reset
            sh_count_next = 0;
            sh_invalid_count_next = 0;
        end
    end
end

always @(posedge clk) begin
    sh_count_reg <= sh_count_next;
    sh_invalid_count_reg <= sh_invalid_count_next;
    bitslip_count_reg <= bitslip_count_next;
    serdes_rx_bitslip_reg <= serdes_rx_bitslip_next;
    rx_block_lock_reg <= rx_block_lock_next;

    if (rst) begin
        sh_count_reg <= 6'd0;
        sh_invalid_count_reg <= 4'd0;
        bitslip_count_reg <= 0;
        serdes_rx_bitslip_reg <= 1'b0;
        rx_block_lock_reg <= 1'b0;
    end
end

endmodule

`resetall
