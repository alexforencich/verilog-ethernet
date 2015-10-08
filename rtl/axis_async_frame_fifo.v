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
 * AXI4-Stream asynchronous frame FIFO
 */
module axis_async_frame_fifo #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 8,
    parameter DROP_WHEN_FULL = 0
)
(
    /*
     * Common asynchronous reset
     */
    input  wire                   async_rst,

    /*
     * AXI input
     */
    input  wire                   input_clk,
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI output
     */
    input  wire                   output_clk,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,

    /*
     * Status
     */
    output wire                   overflow,
    output wire                   bad_frame,
    output wire                   good_frame
);

reg [ADDR_WIDTH:0] wr_ptr = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_ptr_cur = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_ptr_gray = {ADDR_WIDTH+1{1'b0}};

reg [ADDR_WIDTH:0] wr_ptr_gray_sync1 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1 = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2 = {ADDR_WIDTH+1{1'b0}};

reg input_rst_sync1 = 1;
reg input_rst_sync2 = 1;
reg input_rst_sync3 = 1;
reg output_rst_sync1 = 1;
reg output_rst_sync2 = 1;
reg output_rst_sync3 = 1;

reg drop_frame = 1'b0;
reg overflow_reg = 1'b0;
reg bad_frame_reg = 1'b0;
reg good_frame_reg = 1'b0;

reg [DATA_WIDTH+2-1:0] data_out_reg = {1'b0, {DATA_WIDTH{1'b0}}};

//(* RAM_STYLE="BLOCK" *)
reg [DATA_WIDTH+2-1:0] mem[(2**ADDR_WIDTH)-1:0];

reg output_axis_tvalid_reg = 1'b0;

wire [DATA_WIDTH+2-1:0] data_in = {input_axis_tlast, input_axis_tdata};

// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
wire full = ((wr_ptr_gray[ADDR_WIDTH] != rd_ptr_gray_sync2[ADDR_WIDTH]) &&
             (wr_ptr_gray[ADDR_WIDTH-1] != rd_ptr_gray_sync2[ADDR_WIDTH-1]) &&
             (wr_ptr_gray[ADDR_WIDTH-2:0] == rd_ptr_gray_sync2[ADDR_WIDTH-2:0]));
// empty when pointers match exactly
wire empty = rd_ptr_gray == wr_ptr_gray_sync2;
// overflow in single packet
wire full_cur = ((wr_ptr[ADDR_WIDTH] != wr_ptr_cur[ADDR_WIDTH]) &&
                 (wr_ptr[ADDR_WIDTH-1:0] == wr_ptr_cur[ADDR_WIDTH-1:0]));

wire write = input_axis_tvalid & (~full | DROP_WHEN_FULL);
wire read = (output_axis_tready | ~output_axis_tvalid_reg) & ~empty;

assign {output_axis_tlast, output_axis_tdata} = data_out_reg;

assign input_axis_tready = (~full | DROP_WHEN_FULL);
assign output_axis_tvalid = output_axis_tvalid_reg;

assign overflow = overflow_reg;
assign bad_frame = bad_frame_reg;
assign good_frame = good_frame_reg;

// reset synchronization
always @(posedge input_clk or posedge async_rst) begin
    if (async_rst) begin
        input_rst_sync1 <= 1;
        input_rst_sync2 <= 1;
        input_rst_sync3 <= 1;
    end else begin
        input_rst_sync1 <= 0;
        input_rst_sync2 <= input_rst_sync1 | output_rst_sync1;
        input_rst_sync3 <= input_rst_sync2;
    end
end

always @(posedge output_clk or posedge async_rst) begin
    if (async_rst) begin
        output_rst_sync1 <= 1;
        output_rst_sync2 <= 1;
        output_rst_sync3 <= 1;
    end else begin
        output_rst_sync1 <= 0;
        output_rst_sync2 <= output_rst_sync1;
        output_rst_sync3 <= output_rst_sync2;
    end
end

// write
always @(posedge input_clk) begin
    if (input_rst_sync3) begin
        wr_ptr <= 0;
        wr_ptr_cur <= 0;
        wr_ptr_gray <= 0;
        drop_frame <= 0;
        overflow_reg <= 0;
        bad_frame_reg <= 0;
        good_frame_reg <= 0;
    end else if (write) begin
        overflow_reg <= 0;
        bad_frame_reg <= 0;
        good_frame_reg <= 0;
        if (full | full_cur | drop_frame) begin
            // buffer full, hold current pointer, drop packet at end
            drop_frame <= 1;
            if (input_axis_tlast) begin
                wr_ptr_cur <= wr_ptr;
                drop_frame <= 0;
                overflow_reg <= 1;
            end
        end else begin
            mem[wr_ptr_cur[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr_cur <= wr_ptr_cur + 1;
            if (input_axis_tlast) begin
                if (input_axis_tuser) begin
                    // bad packet, reset write pointer
                    wr_ptr_cur <= wr_ptr;
                    bad_frame_reg <= 1;
                end else begin
                    // good packet, push new write pointer
                    wr_ptr_next = wr_ptr_cur + 1;
                    wr_ptr <= wr_ptr_next;
                    wr_ptr_gray <= wr_ptr_next ^ (wr_ptr_next >> 1);
                    good_frame_reg <= 1;
                end
            end
        end
    end else begin
        overflow_reg <= 0;
        bad_frame_reg <= 0;
        good_frame_reg <= 0;
    end
end

// pointer synchronization
always @(posedge input_clk) begin
    if (input_rst_sync3) begin
        rd_ptr_gray_sync1 <= 0;
        rd_ptr_gray_sync2 <= 0;
    end else begin
        rd_ptr_gray_sync1 <= rd_ptr_gray;
        rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
end

// read
always @(posedge output_clk) begin
    if (output_rst_sync3) begin
        rd_ptr <= 0;
        rd_ptr_gray <= 0;
    end else if (read) begin
        data_out_reg <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr_next = rd_ptr + 1;
        rd_ptr <= rd_ptr_next;
        rd_ptr_gray <= rd_ptr_next ^ (rd_ptr_next >> 1);
    end
end

// pointer synchronization
always @(posedge output_clk) begin
    if (output_rst_sync3) begin
        wr_ptr_gray_sync1 <= 0;
        wr_ptr_gray_sync2 <= 0;
    end else begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
end

// source ready output
always @(posedge output_clk) begin
    if (output_rst_sync3) begin
        output_axis_tvalid_reg <= 1'b0;
    end else if (output_axis_tready | ~output_axis_tvalid_reg) begin
        output_axis_tvalid_reg <= ~empty;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_reg;
    end
end

endmodule
