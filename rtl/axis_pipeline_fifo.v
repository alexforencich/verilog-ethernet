/*

Copyright (c) 2021-2023 Alex Forencich

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
 * AXI4-Stream pipeline FIFO
 */
module axis_pipeline_fifo #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
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
    // Number of registers in pipeline
    parameter LENGTH = 2
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,
    input  wire [ID_WIDTH-1:0]    s_axis_tid,
    input  wire [DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire [ID_WIDTH-1:0]    m_axis_tid,
    output wire [DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [USER_WIDTH-1:0]  m_axis_tuser
);

parameter FIFO_ADDR_WIDTH = LENGTH < 2 ? 3 : $clog2(LENGTH*4+1);

wire [DATA_WIDTH-1:0] axis_tdata_pipe[0:LENGTH];
wire [KEEP_WIDTH-1:0] axis_tkeep_pipe[0:LENGTH];
wire                  axis_tvalid_pipe[0:LENGTH];
wire                  axis_tready_pipe[0:LENGTH];
wire                  axis_tlast_pipe[0:LENGTH];
wire [ID_WIDTH-1:0]   axis_tid_pipe[0:LENGTH];
wire [DEST_WIDTH-1:0] axis_tdest_pipe[0:LENGTH];
wire [USER_WIDTH-1:0] axis_tuser_pipe[0:LENGTH];

generate

genvar n;

for (n = 0; n < LENGTH; n = n + 1) begin : stage

    (* shreg_extract = "no" *)
    reg [DATA_WIDTH-1:0]  axis_tdata_reg = 0;
    (* shreg_extract = "no" *)
    reg [KEEP_WIDTH-1:0]  axis_tkeep_reg = 0;
    (* shreg_extract = "no" *)
    reg                   axis_tvalid_reg = 0;
    (* shreg_extract = "no" *)
    reg                   axis_tready_reg = 0;
    (* shreg_extract = "no" *)
    reg                   axis_tlast_reg = 0;
    (* shreg_extract = "no" *)
    reg [ID_WIDTH-1:0]    axis_tid_reg = 0;
    (* shreg_extract = "no" *)
    reg [DEST_WIDTH-1:0]  axis_tdest_reg = 0;
    (* shreg_extract = "no" *)
    reg [USER_WIDTH-1:0]  axis_tuser_reg = 0;

    assign axis_tdata_pipe[n+1] = axis_tdata_reg;
    assign axis_tkeep_pipe[n+1] = axis_tkeep_reg;
    assign axis_tvalid_pipe[n+1] = axis_tvalid_reg;
    assign axis_tlast_pipe[n+1] = axis_tlast_reg;
    assign axis_tid_pipe[n+1] = axis_tid_reg;
    assign axis_tdest_pipe[n+1] = axis_tdest_reg;
    assign axis_tuser_pipe[n+1] = axis_tuser_reg;

    assign axis_tready_pipe[n] = axis_tready_reg;

    always @(posedge clk) begin
        axis_tdata_reg <= axis_tdata_pipe[n];
        axis_tkeep_reg <= axis_tkeep_pipe[n];
        axis_tvalid_reg <= axis_tvalid_pipe[n];
        axis_tlast_reg <= axis_tlast_pipe[n];
        axis_tid_reg <= axis_tid_pipe[n];
        axis_tdest_reg <= axis_tdest_pipe[n];
        axis_tuser_reg <= axis_tuser_pipe[n];

        axis_tready_reg <= axis_tready_pipe[n+1];

        if (rst) begin
            axis_tvalid_reg <= 1'b0;
            axis_tready_reg <= 1'b0;
        end
    end

end

if (LENGTH > 0) begin : fifo

    assign axis_tdata_pipe[0] = s_axis_tdata;
    assign axis_tkeep_pipe[0] = s_axis_tkeep;
    assign axis_tvalid_pipe[0] = s_axis_tvalid & s_axis_tready;
    assign axis_tlast_pipe[0] = s_axis_tlast;
    assign axis_tid_pipe[0] = s_axis_tid;
    assign axis_tdest_pipe[0] = s_axis_tdest;
    assign axis_tuser_pipe[0] = s_axis_tuser;
    assign s_axis_tready = axis_tready_pipe[0];

    wire [DATA_WIDTH-1:0] m_axis_tdata_int = axis_tdata_pipe[LENGTH];
    wire [KEEP_WIDTH-1:0] m_axis_tkeep_int = axis_tkeep_pipe[LENGTH];
    wire                  m_axis_tvalid_int = axis_tvalid_pipe[LENGTH];
    wire                  m_axis_tready_int;
    wire                  m_axis_tlast_int = axis_tlast_pipe[LENGTH];
    wire [ID_WIDTH-1:0]   m_axis_tid_int = axis_tid_pipe[LENGTH];
    wire [DEST_WIDTH-1:0] m_axis_tdest_int = axis_tdest_pipe[LENGTH];
    wire [USER_WIDTH-1:0] m_axis_tuser_int = axis_tuser_pipe[LENGTH];

    assign axis_tready_pipe[LENGTH] = m_axis_tready_int;

    // output datapath logic
    reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
    reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
    reg                  m_axis_tvalid_reg = 1'b0;
    reg                  m_axis_tlast_reg  = 1'b0;
    reg [ID_WIDTH-1:0]   m_axis_tid_reg    = {ID_WIDTH{1'b0}};
    reg [DEST_WIDTH-1:0] m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
    reg [USER_WIDTH-1:0] m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

    reg [FIFO_ADDR_WIDTH+1-1:0] out_fifo_wr_ptr_reg = 0;
    reg [FIFO_ADDR_WIDTH+1-1:0] out_fifo_rd_ptr_reg = 0;
    reg out_fifo_half_full_reg = 1'b0;

    wire out_fifo_full = out_fifo_wr_ptr_reg == (out_fifo_rd_ptr_reg ^ {1'b1, {FIFO_ADDR_WIDTH{1'b0}}});
    wire out_fifo_empty = out_fifo_wr_ptr_reg == out_fifo_rd_ptr_reg;

    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg [DATA_WIDTH-1:0] out_fifo_tdata[2**FIFO_ADDR_WIDTH-1:0];
    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg [KEEP_WIDTH-1:0] out_fifo_tkeep[2**FIFO_ADDR_WIDTH-1:0];
    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg                  out_fifo_tlast[2**FIFO_ADDR_WIDTH-1:0];
    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg [ID_WIDTH-1:0]   out_fifo_tid[2**FIFO_ADDR_WIDTH-1:0];
    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg [DEST_WIDTH-1:0] out_fifo_tdest[2**FIFO_ADDR_WIDTH-1:0];
    (* ram_style = "distributed", ramstyle = "no_rw_check, mlab" *)
    reg [USER_WIDTH-1:0] out_fifo_tuser[2**FIFO_ADDR_WIDTH-1:0];

    assign m_axis_tready_int = !out_fifo_half_full_reg;

    assign m_axis_tdata  = m_axis_tdata_reg;
    assign m_axis_tkeep  = KEEP_ENABLE ? m_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
    assign m_axis_tvalid = m_axis_tvalid_reg;
    assign m_axis_tlast  = LAST_ENABLE ? m_axis_tlast_reg : 1'b1;
    assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {ID_WIDTH{1'b0}};
    assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {DEST_WIDTH{1'b0}};
    assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {USER_WIDTH{1'b0}};

    always @(posedge clk) begin
        m_axis_tvalid_reg <= m_axis_tvalid_reg && !m_axis_tready;

        out_fifo_half_full_reg <= $unsigned(out_fifo_wr_ptr_reg - out_fifo_rd_ptr_reg) >= 2**(FIFO_ADDR_WIDTH-1);

        if (!out_fifo_full && m_axis_tvalid_int) begin
            out_fifo_tdata[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tdata_int;
            out_fifo_tkeep[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tkeep_int;
            out_fifo_tlast[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tlast_int;
            out_fifo_tid[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tid_int;
            out_fifo_tdest[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tdest_int;
            out_fifo_tuser[out_fifo_wr_ptr_reg[FIFO_ADDR_WIDTH-1:0]] <= m_axis_tuser_int;
            out_fifo_wr_ptr_reg <= out_fifo_wr_ptr_reg + 1;
        end

        if (!out_fifo_empty && (!m_axis_tvalid_reg || m_axis_tready)) begin
            m_axis_tdata_reg <= out_fifo_tdata[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            m_axis_tkeep_reg <= out_fifo_tkeep[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            m_axis_tvalid_reg <= 1'b1;
            m_axis_tlast_reg <= out_fifo_tlast[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            m_axis_tid_reg <= out_fifo_tid[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            m_axis_tdest_reg <= out_fifo_tdest[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            m_axis_tuser_reg <= out_fifo_tuser[out_fifo_rd_ptr_reg[FIFO_ADDR_WIDTH-1:0]];
            out_fifo_rd_ptr_reg <= out_fifo_rd_ptr_reg + 1;
        end

        if (rst) begin
            out_fifo_wr_ptr_reg <= 0;
            out_fifo_rd_ptr_reg <= 0;
            m_axis_tvalid_reg <= 1'b0;
        end
    end

end else begin
    // bypass

    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tkeep  = KEEP_ENABLE ? s_axis_tkeep : {KEEP_WIDTH{1'b1}};
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tlast  = LAST_ENABLE ? s_axis_tlast : 1'b1;
    assign m_axis_tid    = ID_ENABLE   ? s_axis_tid   : {ID_WIDTH{1'b0}};
    assign m_axis_tdest  = DEST_ENABLE ? s_axis_tdest : {DEST_WIDTH{1'b0}};
    assign m_axis_tuser  = USER_ENABLE ? s_axis_tuser : {USER_WIDTH{1'b0}};

    assign s_axis_tready = m_axis_tready;

end

endgenerate

endmodule

`resetall
