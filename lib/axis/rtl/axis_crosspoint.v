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
 * AXI4-Stream crosspoint
 */
module axis_crosspoint #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
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
    parameter USER_WIDTH = 1
)
(
    input  wire                               clk,
    input  wire                               rst,

    /*
     * AXI Stream inputs
     */
    input  wire [S_COUNT*DATA_WIDTH-1:0]      s_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0]      s_axis_tkeep,
    input  wire [S_COUNT-1:0]                 s_axis_tvalid,
    input  wire [S_COUNT-1:0]                 s_axis_tlast,
    input  wire [S_COUNT*ID_WIDTH-1:0]        s_axis_tid,
    input  wire [S_COUNT*DEST_WIDTH-1:0]      s_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0]      s_axis_tuser,

    /*
     * AXI Stream outputs
     */
    output wire [M_COUNT*DATA_WIDTH-1:0]      m_axis_tdata,
    output wire [M_COUNT*KEEP_WIDTH-1:0]      m_axis_tkeep,
    output wire [M_COUNT-1:0]                 m_axis_tvalid,
    output wire [M_COUNT-1:0]                 m_axis_tlast,
    output wire [M_COUNT*ID_WIDTH-1:0]        m_axis_tid,
    output wire [M_COUNT*DEST_WIDTH-1:0]      m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0]      m_axis_tuser,

    /*
     * Control
     */
    input  wire [M_COUNT*$clog2(S_COUNT)-1:0] select
);

parameter CL_S_COUNT = $clog2(S_COUNT);

reg [S_COUNT*DATA_WIDTH-1:0] s_axis_tdata_reg = {S_COUNT*DATA_WIDTH{1'b0}};
reg [S_COUNT*KEEP_WIDTH-1:0] s_axis_tkeep_reg = {S_COUNT*KEEP_WIDTH{1'b0}};
reg [S_COUNT-1:0]            s_axis_tvalid_reg = {S_COUNT{1'b0}};
reg [S_COUNT-1:0]            s_axis_tlast_reg = {S_COUNT{1'b0}};
reg [S_COUNT*ID_WIDTH-1:0]   s_axis_tid_reg = {S_COUNT*ID_WIDTH{1'b0}};
reg [S_COUNT*DEST_WIDTH-1:0] s_axis_tdest_reg = {S_COUNT*DEST_WIDTH{1'b0}};
reg [S_COUNT*USER_WIDTH-1:0] s_axis_tuser_reg = {S_COUNT*USER_WIDTH{1'b0}};

reg [M_COUNT*DATA_WIDTH-1:0] m_axis_tdata_reg = {M_COUNT*DATA_WIDTH{1'b0}};
reg [M_COUNT*KEEP_WIDTH-1:0] m_axis_tkeep_reg = {M_COUNT*KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]            m_axis_tvalid_reg = {M_COUNT{1'b0}};
reg [M_COUNT-1:0]            m_axis_tlast_reg = {M_COUNT{1'b0}};
reg [M_COUNT*ID_WIDTH-1:0]   m_axis_tid_reg = {M_COUNT*ID_WIDTH{1'b0}};
reg [M_COUNT*DEST_WIDTH-1:0] m_axis_tdest_reg = {M_COUNT*DEST_WIDTH{1'b0}};
reg [M_COUNT*USER_WIDTH-1:0] m_axis_tuser_reg = {M_COUNT*USER_WIDTH{1'b0}};

reg [M_COUNT*CL_S_COUNT-1:0] select_reg = {M_COUNT*CL_S_COUNT{1'b0}};

assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tkeep  = KEEP_ENABLE ? m_axis_tkeep_reg : {M_COUNT*KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = LAST_ENABLE ? m_axis_tlast_reg : {M_COUNT{1'b1}};
assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {M_COUNT*ID_WIDTH{1'b0}};
assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {M_COUNT*DEST_WIDTH{1'b0}};
assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {M_COUNT*USER_WIDTH{1'b0}};

integer i;

always @(posedge clk) begin
    if (rst) begin
        s_axis_tvalid_reg <= {S_COUNT{1'b0}};
        m_axis_tvalid_reg <= {S_COUNT{1'b0}};
        select_reg <= {M_COUNT*CL_S_COUNT{1'b0}};
    end else begin
        s_axis_tvalid_reg <= s_axis_tvalid;
        for (i = 0; i < M_COUNT; i = i + 1) begin
            m_axis_tvalid_reg[i] <= s_axis_tvalid_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]];
        end
        select_reg <= select;
    end

    s_axis_tdata_reg <= s_axis_tdata;
    s_axis_tkeep_reg <= s_axis_tkeep;
    s_axis_tlast_reg <= s_axis_tlast;
    s_axis_tid_reg   <= s_axis_tid;
    s_axis_tdest_reg <= s_axis_tdest;
    s_axis_tuser_reg <= s_axis_tuser;

    for (i = 0; i < M_COUNT; i = i + 1) begin
        m_axis_tdata_reg[i*DATA_WIDTH +: DATA_WIDTH] <= s_axis_tdata_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]*DATA_WIDTH +: DATA_WIDTH];
        m_axis_tkeep_reg[i*KEEP_WIDTH +: KEEP_WIDTH] <= s_axis_tkeep_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]*KEEP_WIDTH +: KEEP_WIDTH];
        m_axis_tlast_reg[i]                          <= s_axis_tlast_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]];
        m_axis_tid_reg[i*ID_WIDTH +: ID_WIDTH]       <= s_axis_tid_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]*ID_WIDTH +: ID_WIDTH];
        m_axis_tdest_reg[i*DEST_WIDTH +: DEST_WIDTH] <= s_axis_tdest_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]*DEST_WIDTH +: DEST_WIDTH];
        m_axis_tuser_reg[i*USER_WIDTH +: USER_WIDTH] <= s_axis_tuser_reg[select_reg[i*CL_S_COUNT +: CL_S_COUNT]*USER_WIDTH +: USER_WIDTH];
    end
end

endmodule

`resetall
