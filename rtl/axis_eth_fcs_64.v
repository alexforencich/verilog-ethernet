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
 * AXI4-Stream Ethernet FCS Generator (64 bit datapath)
 */
module axis_eth_fcs_64
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [63:0] input_axis_tdata,
    input  wire [7:0]  input_axis_tkeep,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,
    
    /*
     * FCS output
     */
    output wire [31:0] output_fcs,
    output wire        output_fcs_valid
);

reg [31:0] crc_state = 32'hFFFFFFFF;
reg [31:0] fcs_reg = 0;
reg fcs_valid_reg = 0;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

assign input_axis_tready = 1;
assign output_fcs = fcs_reg;
assign output_fcs_valid = fcs_valid_reg;

eth_crc_8
eth_crc_8_inst (
    .data_in(input_axis_tdata[7:0]),
    .crc_state(crc_state),
    .crc_next(crc_next0)
);

eth_crc_16
eth_crc_16_inst (
    .data_in(input_axis_tdata[15:0]),
    .crc_state(crc_state),
    .crc_next(crc_next1)
);

eth_crc_24
eth_crc_24_inst (
    .data_in(input_axis_tdata[23:0]),
    .crc_state(crc_state),
    .crc_next(crc_next2)
);

eth_crc_32
eth_crc_32_inst (
    .data_in(input_axis_tdata[31:0]),
    .crc_state(crc_state),
    .crc_next(crc_next3)
);

eth_crc_40
eth_crc_40_inst (
    .data_in(input_axis_tdata[39:0]),
    .crc_state(crc_state),
    .crc_next(crc_next4)
);

eth_crc_48
eth_crc_48_inst (
    .data_in(input_axis_tdata[47:0]),
    .crc_state(crc_state),
    .crc_next(crc_next5)
);

eth_crc_56
eth_crc_56_inst (
    .data_in(input_axis_tdata[55:0]),
    .crc_state(crc_state),
    .crc_next(crc_next6)
);

eth_crc_64
eth_crc_64_inst (
    .data_in(input_axis_tdata[63:0]),
    .crc_state(crc_state),
    .crc_next(crc_next7)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        crc_state <= 32'hFFFFFFFF;
        fcs_reg <= 0;
        fcs_valid_reg <= 0;
    end else begin
        fcs_valid_reg <= 0;
        if (input_axis_tvalid) begin
            if (input_axis_tlast) begin
                crc_state <= 32'hFFFFFFFF;
                case (input_axis_tkeep)
                    8'b00000001: fcs_reg <= ~crc_next0;
                    8'b00000011: fcs_reg <= ~crc_next1;
                    8'b00000111: fcs_reg <= ~crc_next2;
                    8'b00001111: fcs_reg <= ~crc_next3;
                    8'b00011111: fcs_reg <= ~crc_next4;
                    8'b00111111: fcs_reg <= ~crc_next5;
                    8'b01111111: fcs_reg <= ~crc_next6;
                    8'b11111111: fcs_reg <= ~crc_next7;
                endcase
                fcs_valid_reg <= 1;
            end else begin
                crc_state <= crc_next7;
            end
        end
    end
end

endmodule
