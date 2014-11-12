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
 * AXI4-Stream frame FIFO
 */
module axis_frame_fifo #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,
    
    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast
);

reg [ADDR_WIDTH:0] wr_ptr = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_cur = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr = {ADDR_WIDTH+1{1'b0}};

reg [DATA_WIDTH+2-1:0] data_out_reg = {1'b0, {DATA_WIDTH{1'b0}}};

//(* RAM_STYLE="BLOCK" *)
reg [DATA_WIDTH+2-1:0] mem[(2**ADDR_WIDTH)-1:0];

reg output_read = 1'b0;

reg output_axis_tvalid_reg = 1'b0;

wire [DATA_WIDTH+2-1:0] data_in = {input_axis_tlast, input_axis_tdata};

// full when first MSB different but rest same
wire full = ((wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
             (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]));
// empty when pointers match exactly
wire empty = wr_ptr == rd_ptr;
// overflow in single packet
wire full_cur = ((wr_ptr[ADDR_WIDTH] != wr_ptr_cur[ADDR_WIDTH]) &&
                 (wr_ptr[ADDR_WIDTH-1:0] == wr_ptr_cur[ADDR_WIDTH-1:0]));

wire write = input_axis_tvalid & ~full;
wire read = (output_axis_tready | ~output_axis_tvalid_reg) & ~empty;

assign {output_axis_tlast, output_axis_tdata} = data_out_reg;

assign input_axis_tready = ~full;
assign output_axis_tvalid = output_axis_tvalid_reg;

// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        wr_ptr <= 0;
    end else if (write) begin
        if (full_cur) begin
            // buffer full, hold current pointer, drop packet at end
            if (input_axis_tlast) begin
                wr_ptr_cur <= wr_ptr;
            end
        end else begin
            mem[wr_ptr_cur[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr_cur <= wr_ptr_cur + 1;
            if (input_axis_tlast) begin
                if (input_axis_tuser) begin
                    // bad packet, reset write pointer
                    wr_ptr_cur <= wr_ptr;
                end else begin
                    // good packet, push new write pointer
                    wr_ptr <= wr_ptr_cur + 1;
                end
            end
        end
    end
end

// read
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rd_ptr <= 0;
    end else if (read) begin
        data_out_reg <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
end

// source ready output
always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_axis_tvalid_reg <= 1'b0;
    end else if (output_axis_tready | ~output_axis_tvalid_reg) begin
        output_axis_tvalid_reg <= ~empty;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_reg;
    end
end

endmodule
