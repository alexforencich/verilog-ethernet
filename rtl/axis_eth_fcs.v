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
 * AXI4-Stream Ethernet FCS Generator
 */
module axis_eth_fcs
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [7:0]  s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire        s_axis_tuser,
    
    /*
     * FCS output
     */
    output wire [31:0] output_fcs,
    output wire        output_fcs_valid
);

reg [31:0] crc_state = 32'hFFFFFFFF;
reg [31:0] fcs_reg = 32'h00000000;
reg fcs_valid_reg = 1'b0;

wire [31:0] crc_next;

assign s_axis_tready = 1;
assign output_fcs = fcs_reg;
assign output_fcs_valid = fcs_valid_reg;

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(8),
    .STYLE("AUTO")
)
eth_crc_8 (
    .data_in(s_axis_tdata),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @(posedge clk) begin
    if (rst) begin
        crc_state <= 32'hFFFFFFFF;
        fcs_reg <= 32'h00000000;
        fcs_valid_reg <= 1'b0;
    end else begin
        fcs_valid_reg <= 1'b0;
        if (s_axis_tvalid) begin
            if (s_axis_tlast) begin
                crc_state <= 32'hFFFFFFFF;
                fcs_reg <= ~crc_next;
                fcs_valid_reg <= 1'b1;
            end else begin
                crc_state <= crc_next;
            end
        end
    end
end

endmodule
