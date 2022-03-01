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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream SRL-based FIFO
 */
module axis_srl_fifo #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // FIFO depth in cycles
    parameter DEPTH = 16
)
(
    input  wire                       clk,
    input  wire                       rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]      s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]      s_axis_tkeep,
    input  wire                       s_axis_tvalid,
    output wire                       s_axis_tready,
    input  wire                       s_axis_tlast,
    input  wire [ID_WIDTH-1:0]        s_axis_tid,
    input  wire [DEST_WIDTH-1:0]      s_axis_tdest,
    input  wire [USER_WIDTH-1:0]      s_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]      m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]      m_axis_tkeep,
    output wire                       m_axis_tvalid,
    input  wire                       m_axis_tready,
    output wire                       m_axis_tlast,
    output wire [ID_WIDTH-1:0]        m_axis_tid,
    output wire [DEST_WIDTH-1:0]      m_axis_tdest,
    output wire [USER_WIDTH-1:0]      m_axis_tuser,

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
reg full_reg = 1'b0, full_next;
reg empty_reg = 1'b1, empty_next;

wire [WIDTH-1:0] s_axis;

wire [WIDTH-1:0] m_axis = data_reg[ptr_reg-1];

assign s_axis_tready = !full_reg;

generate
    assign s_axis[DATA_WIDTH-1:0] = s_axis_tdata;
    if (KEEP_ENABLE) assign s_axis[KEEP_OFFSET +: KEEP_WIDTH] = s_axis_tkeep;
    if (LAST_ENABLE) assign s_axis[LAST_OFFSET]               = s_axis_tlast;
    if (ID_ENABLE)   assign s_axis[ID_OFFSET   +: ID_WIDTH]   = s_axis_tid;
    if (DEST_ENABLE) assign s_axis[DEST_OFFSET +: DEST_WIDTH] = s_axis_tdest;
    if (USER_ENABLE) assign s_axis[USER_OFFSET +: USER_WIDTH] = s_axis_tuser;
endgenerate

assign m_axis_tvalid = !empty_reg;

assign m_axis_tdata = m_axis[DATA_WIDTH-1:0];
assign m_axis_tkeep = KEEP_ENABLE ? m_axis[KEEP_OFFSET +: KEEP_WIDTH] : {KEEP_WIDTH{1'b1}};
assign m_axis_tlast = LAST_ENABLE ? m_axis[LAST_OFFSET]               : 1'b1;
assign m_axis_tid   = ID_ENABLE   ? m_axis[ID_OFFSET   +: ID_WIDTH]   : {ID_WIDTH{1'b0}};
assign m_axis_tdest = DEST_ENABLE ? m_axis[DEST_OFFSET +: DEST_WIDTH] : {DEST_WIDTH{1'b0}};
assign m_axis_tuser = USER_ENABLE ? m_axis[USER_OFFSET +: USER_WIDTH] : {USER_WIDTH{1'b0}};

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
    shift = 1'b0;
    inc = 1'b0;
    dec = 1'b0;
    full_next = full_reg;
    empty_next = empty_reg;

    if (m_axis_tready && s_axis_tvalid && s_axis_tready) begin
        shift = 1'b1;
        inc = ptr_empty;
        empty_next = 1'b0;
    end else if (m_axis_tready && m_axis_tvalid) begin
        dec = 1'b1;
        full_next = 1'b0;
        empty_next = ptr_empty1;
    end else if (s_axis_tvalid && s_axis_tready) begin
        shift = 1'b1;
        inc = 1'b1;
        full_next = ptr_full1;
        empty_next = 1'b0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
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
        data_reg[0] <= s_axis;
        for (i = 0; i < DEPTH-1; i = i + 1) begin
            data_reg[i+1] <= data_reg[i];
        end
    end
end

endmodule

`resetall
