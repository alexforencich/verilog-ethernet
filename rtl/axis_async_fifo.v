/*

Copyright (c) 2014 Alex Forencich

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
 * AXI4-Stream asynchronous FIFO
 */
module axis_async_fifo #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8
)
(
    /*
     * AXI input
     */
    input  wire                   input_clk,
    input  wire                   input_rst,
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI output
     */
    input  wire                   output_clk,
    input  wire                   output_rst,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser
);

reg [ADDR_WIDTH:0] wr_ptr = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_ptr_gray = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_ptr_gray = {ADDR_WIDTH+1{1'b0}};

reg [ADDR_WIDTH:0] wr_ptr_gray_sync1 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync3 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync3 = {ADDR_WIDTH+1{1'b0}};

reg [DATA_WIDTH+2-1:0] data_out_reg = {1'b0, 1'b0, {DATA_WIDTH{1'b0}}};

//(* RAM_STYLE="BLOCK" *)
reg [DATA_WIDTH+2-1:0] mem[(2**ADDR_WIDTH)-1:0];

reg output_read = 1'b0;

reg output_axis_tvalid_reg = 1'b0;

wire [DATA_WIDTH+2-1:0] data_in = {input_axis_tlast, input_axis_tuser, input_axis_tdata};

// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
wire full = ((wr_ptr_gray[ADDR_WIDTH] != rd_ptr_gray_sync3[ADDR_WIDTH]) &&
             (wr_ptr_gray[ADDR_WIDTH-1] != rd_ptr_gray_sync3[ADDR_WIDTH-1]) &&
             (wr_ptr_gray[ADDR_WIDTH-2:0] == rd_ptr_gray_sync3[ADDR_WIDTH-2:0]));
// empty when pointers match exactly
wire empty = rd_ptr_gray == wr_ptr_gray_sync3;

wire write = input_axis_tvalid & ~full;
wire read = (output_axis_tready | ~output_axis_tvalid_reg) & ~empty;

assign {output_axis_tlast, output_axis_tuser, output_axis_tdata} = data_out_reg;

assign input_axis_tready = ~full;
assign output_axis_tvalid = output_axis_tvalid_reg;

// write
always @(posedge input_clk or posedge input_rst) begin
    if (input_rst) begin
        wr_ptr <= 0;
    end else if (write) begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
        wr_ptr_next = wr_ptr + 1;
        wr_ptr <= wr_ptr_next;
        wr_ptr_gray <= wr_ptr_next ^ (wr_ptr_next >> 1);
    end
end

// pointer synchronization in SRL16
always @(posedge input_clk) begin
    rd_ptr_gray_sync1 <= rd_ptr_gray;
    rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    rd_ptr_gray_sync3 <= rd_ptr_gray_sync2;
end

// read
always @(posedge output_clk or posedge output_rst) begin
    if (output_rst) begin
        rd_ptr <= 0;
    end else if (read) begin
        data_out_reg <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr_next = rd_ptr + 1;
        rd_ptr <= rd_ptr_next;
        rd_ptr_gray <= rd_ptr_next ^ (rd_ptr_next >> 1);
    end
end

// pointer synchronization in SRL16
always @(posedge output_clk) begin
    wr_ptr_gray_sync1 <= wr_ptr_gray;
    wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    wr_ptr_gray_sync3 <= wr_ptr_gray_sync2;
end

// source ready output
always @(posedge output_clk or posedge output_rst) begin
    if (output_rst) begin
        output_axis_tvalid_reg <= 1'b0;
    end else if (output_axis_tready | ~output_axis_tvalid_reg) begin
        output_axis_tvalid_reg <= ~empty;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_reg;
    end
end

endmodule
