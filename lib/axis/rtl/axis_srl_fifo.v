/*

Copyright (c) 2014-2018 Alex Forencich

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
 * AXI4-Stream SRL-based FIFO
 */
module axis_srl_fifo #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter LAST_ENABLE = 1,
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    parameter DEPTH = 16
)
(
    input  wire                       clk,
    input  wire                       rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_axis_tkeep,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_axis_tuser,

    /*
     * Status
     */
    output wire [$clog2(DEPTH+1)-1:0] count
);

localparam KEEP_OFFSET = DATA_WIDTH;
localparam LAST_OFFSET = KEEP_OFFSET + (KEEP_ENABLE ? KEEP_WIDTH : 0);
localparam ID_OFFSET   = LAST_OFFSET + (LAST_ENABLE ? 1          : 0);
localparam DEST_OFFSET = ID_OFFSET   + (ID_ENABLE   ? ID_WIDTH   : 0);
localparam USER_OFFSET = DEST_OFFSET + (DEST_ENABLE ? DEST_WIDTH : 0);
localparam WIDTH       = USER_OFFSET + (USER_ENABLE ? USER_WIDTH : 0);

reg [WIDTH-1:0] data_reg[DEPTH-1:0];
reg [$clog2(DEPTH+1)-1:0] ptr_reg = 0;
reg full_reg = 0, full_next;
reg empty_reg = 1, empty_next;

wire [WIDTH-1:0] input_axis;

wire [WIDTH-1:0] output_axis = data_reg[ptr_reg-1];

assign input_axis_tready = ~full_reg;

generate
    assign input_axis[DATA_WIDTH-1:0] = input_axis_tdata;
    if (KEEP_ENABLE) assign input_axis[KEEP_OFFSET +: KEEP_WIDTH] = input_axis_tkeep;
    if (LAST_ENABLE) assign input_axis[LAST_OFFSET]               = input_axis_tlast;
    if (ID_ENABLE)   assign input_axis[ID_OFFSET   +: ID_WIDTH]   = input_axis_tid;
    if (DEST_ENABLE) assign input_axis[DEST_OFFSET +: DEST_WIDTH] = input_axis_tdest;
    if (USER_ENABLE) assign input_axis[USER_OFFSET +: USER_WIDTH] = input_axis_tuser;
endgenerate

assign output_axis_tvalid = ~empty_reg;

assign output_axis_tdata = output_axis[DATA_WIDTH-1:0];
assign output_axis_tkeep = KEEP_ENABLE ? output_axis[KEEP_OFFSET +: KEEP_WIDTH] : {KEEP_WIDTH{1'b1}};
assign output_axis_tlast = LAST_ENABLE ? output_axis[LAST_OFFSET]               : 1'b1;
assign output_axis_tid   = ID_ENABLE   ? output_axis[ID_OFFSET   +: ID_WIDTH]   : {ID_WIDTH{1'b0}};
assign output_axis_tdest = DEST_ENABLE ? output_axis[DEST_OFFSET +: DEST_WIDTH] : {DEST_WIDTH{1'b0}};
assign output_axis_tuser = USER_ENABLE ? output_axis[USER_OFFSET +: USER_WIDTH] : {USER_WIDTH{1'b0}};

assign count = ptr_reg;

wire ptr_empty = ptr_reg == 0;
wire ptr_empty1 = ptr_reg == 1;
wire ptr_full = ptr_reg == DEPTH;
wire ptr_full1 = ptr_reg == DEPTH-1;

reg shift;
reg inc;
reg dec;

integer i;

initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
        data_reg[i] <= 0;
    end
end

always @* begin
    shift = 0;
    inc = 0;
    dec = 0;
    full_next = full_reg;
    empty_next = empty_reg;

    if (output_axis_tready & input_axis_tvalid & ~full_reg) begin
        shift = 1;
        inc = ptr_empty;
        empty_next = 0;
    end else if (output_axis_tready & output_axis_tvalid) begin
        dec = 1;
        full_next = 0;
        empty_next = ptr_empty1;
    end else if (input_axis_tvalid & input_axis_tready) begin
        shift = 1;
        inc = 1;
        full_next = ptr_full1;
        empty_next = 0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ptr_reg <= 0;
        full_reg <= 0;
        empty_reg <= 1;
    end else begin
        if (inc) begin
            ptr_reg <= ptr_reg + 1;
        end else if (dec) begin
            ptr_reg <= ptr_reg - 1;
        end else begin
            ptr_reg <= ptr_reg;
        end

        full_reg <= full_next;
        empty_reg <= empty_next;
    end

    if (shift) begin
        data_reg[0] <= input_axis;
        for (i = 0; i < DEPTH-1; i = i + 1) begin
            data_reg[i+1] <= data_reg[i];
        end
    end
end

endmodule
