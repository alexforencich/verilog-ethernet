/*

Copyright (c) 2014-2023 Alex Forencich

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
 * AXI4-Stream bus width adapter
 */
module axis_adapter #
(
    // Width of input AXI stream interface in bits
    parameter S_DATA_WIDTH = 8,
    // Propagate tkeep signal on input interface
    // If disabled, tkeep assumed to be 1'b1
    parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8),
    // tkeep signal width (words per cycle) on input interface
    parameter S_KEEP_WIDTH = ((S_DATA_WIDTH+7)/8),
    // Width of output AXI stream interface in bits
    parameter M_DATA_WIDTH = 8,
    // Propagate tkeep signal on output interface
    // If disabled, tkeep assumed to be 1'b1
    parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8),
    // tkeep signal width (words per cycle) on output interface
    parameter M_KEEP_WIDTH = ((M_DATA_WIDTH+7)/8),
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
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI input
     */
    input  wire [S_DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [S_KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                     s_axis_tvalid,
    output wire                     s_axis_tready,
    input  wire                     s_axis_tlast,
    input  wire [ID_WIDTH-1:0]      s_axis_tid,
    input  wire [DEST_WIDTH-1:0]    s_axis_tdest,
    input  wire [USER_WIDTH-1:0]    s_axis_tuser,

    /*
     * AXI output
     */
    output wire [M_DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [M_KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast,
    output wire [ID_WIDTH-1:0]      m_axis_tid,
    output wire [DEST_WIDTH-1:0]    m_axis_tdest,
    output wire [USER_WIDTH-1:0]    m_axis_tuser
);

// force keep width to 1 when disabled
localparam S_BYTE_LANES = S_KEEP_ENABLE ? S_KEEP_WIDTH : 1;
localparam M_BYTE_LANES = M_KEEP_ENABLE ? M_KEEP_WIDTH : 1;

// bus byte sizes (must be identical)
localparam S_BYTE_SIZE = S_DATA_WIDTH / S_BYTE_LANES;
localparam M_BYTE_SIZE = M_DATA_WIDTH / M_BYTE_LANES;

// bus width assertions
initial begin
    if (S_BYTE_SIZE * S_BYTE_LANES != S_DATA_WIDTH) begin
        $error("Error: input data width not evenly divisible (instance %m)");
        $finish;
    end

    if (M_BYTE_SIZE * M_BYTE_LANES != M_DATA_WIDTH) begin
        $error("Error: output data width not evenly divisible (instance %m)");
        $finish;
    end

    if (S_BYTE_SIZE != M_BYTE_SIZE) begin
        $error("Error: byte size mismatch (instance %m)");
        $finish;
    end
end

generate

if (M_BYTE_LANES == S_BYTE_LANES) begin : bypass
    // same width; bypass

    assign s_axis_tready = m_axis_tready;

    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tkeep  = M_KEEP_ENABLE ? s_axis_tkeep : {M_KEEP_WIDTH{1'b1}};
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tlast  = s_axis_tlast;
    assign m_axis_tid    = ID_ENABLE   ? s_axis_tid   : {ID_WIDTH{1'b0}};
    assign m_axis_tdest  = DEST_ENABLE ? s_axis_tdest : {DEST_WIDTH{1'b0}};
    assign m_axis_tuser  = USER_ENABLE ? s_axis_tuser : {USER_WIDTH{1'b0}};

end else if (M_BYTE_LANES > S_BYTE_LANES) begin : upsize
    // output is wider; upsize

    // required number of segments in wider bus
    localparam SEG_COUNT = M_BYTE_LANES / S_BYTE_LANES;
    // data width and keep width per segment
    localparam SEG_DATA_WIDTH = M_DATA_WIDTH / SEG_COUNT;
    localparam SEG_KEEP_WIDTH = M_BYTE_LANES / SEG_COUNT;

    reg [$clog2(SEG_COUNT)-1:0] seg_reg = 0;

    reg [S_DATA_WIDTH-1:0] s_axis_tdata_reg = {S_DATA_WIDTH{1'b0}};
    reg [S_KEEP_WIDTH-1:0] s_axis_tkeep_reg = {S_KEEP_WIDTH{1'b0}};
    reg s_axis_tvalid_reg = 1'b0;
    reg s_axis_tlast_reg = 1'b0;
    reg [ID_WIDTH-1:0] s_axis_tid_reg = {ID_WIDTH{1'b0}};
    reg [DEST_WIDTH-1:0] s_axis_tdest_reg = {DEST_WIDTH{1'b0}};
    reg [USER_WIDTH-1:0] s_axis_tuser_reg = {USER_WIDTH{1'b0}};

    reg [M_DATA_WIDTH-1:0] m_axis_tdata_reg = {M_DATA_WIDTH{1'b0}};
    reg [M_KEEP_WIDTH-1:0] m_axis_tkeep_reg = {M_KEEP_WIDTH{1'b0}};
    reg m_axis_tvalid_reg = 1'b0;
    reg m_axis_tlast_reg = 1'b0;
    reg [ID_WIDTH-1:0] m_axis_tid_reg = {ID_WIDTH{1'b0}};
    reg [DEST_WIDTH-1:0] m_axis_tdest_reg = {DEST_WIDTH{1'b0}};
    reg [USER_WIDTH-1:0] m_axis_tuser_reg = {USER_WIDTH{1'b0}};

    assign s_axis_tready = !s_axis_tvalid_reg;

    assign m_axis_tdata  = m_axis_tdata_reg;
    assign m_axis_tkeep  = M_KEEP_ENABLE ? m_axis_tkeep_reg : {M_KEEP_WIDTH{1'b1}};
    assign m_axis_tvalid = m_axis_tvalid_reg;
    assign m_axis_tlast  = m_axis_tlast_reg;
    assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {ID_WIDTH{1'b0}};
    assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {DEST_WIDTH{1'b0}};
    assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {USER_WIDTH{1'b0}};

    always @(posedge clk) begin
        m_axis_tvalid_reg <= m_axis_tvalid_reg && !m_axis_tready;

        if (!m_axis_tvalid_reg || m_axis_tready) begin
            // output register empty

            if (seg_reg == 0) begin
                m_axis_tdata_reg[seg_reg*SEG_DATA_WIDTH +: SEG_DATA_WIDTH] <= s_axis_tvalid_reg ? s_axis_tdata_reg : s_axis_tdata;
                m_axis_tkeep_reg <= s_axis_tvalid_reg ? s_axis_tkeep_reg : s_axis_tkeep;
            end else begin
                m_axis_tdata_reg[seg_reg*SEG_DATA_WIDTH +: SEG_DATA_WIDTH] <= s_axis_tdata;
                m_axis_tkeep_reg[seg_reg*SEG_KEEP_WIDTH +: SEG_KEEP_WIDTH] <= s_axis_tkeep;
            end
            m_axis_tlast_reg <= s_axis_tvalid_reg ? s_axis_tlast_reg : s_axis_tlast;
            m_axis_tid_reg <= s_axis_tvalid_reg ? s_axis_tid_reg : s_axis_tid;
            m_axis_tdest_reg <= s_axis_tvalid_reg ? s_axis_tdest_reg : s_axis_tdest;
            m_axis_tuser_reg <= s_axis_tvalid_reg ? s_axis_tuser_reg : s_axis_tuser;

            if (s_axis_tvalid_reg) begin
                // consume data from buffer
                s_axis_tvalid_reg <= 1'b0;

                if (s_axis_tlast_reg || seg_reg == SEG_COUNT-1) begin
                    seg_reg <= 0;
                    m_axis_tvalid_reg <= 1'b1;
                end else begin
                    seg_reg <= seg_reg + 1;
                end
            end else if (s_axis_tvalid) begin
                // data direct from input
                if (s_axis_tlast || seg_reg == SEG_COUNT-1) begin
                    seg_reg <= 0;
                    m_axis_tvalid_reg <= 1'b1;
                end else begin
                    seg_reg <= seg_reg + 1;
                end
            end
        end else if (s_axis_tvalid && s_axis_tready) begin
            // store input data in skid buffer
            s_axis_tdata_reg <= s_axis_tdata;
            s_axis_tkeep_reg <= s_axis_tkeep;
            s_axis_tvalid_reg <= 1'b1;
            s_axis_tlast_reg <= s_axis_tlast;
            s_axis_tid_reg <= s_axis_tid;
            s_axis_tdest_reg <= s_axis_tdest;
            s_axis_tuser_reg <= s_axis_tuser;
        end

        if (rst) begin
            seg_reg <= 0;
            s_axis_tvalid_reg <= 1'b0;
            m_axis_tvalid_reg <= 1'b0;
        end
    end

end else begin : downsize
    // output is narrower; downsize

    // required number of segments in wider bus
    localparam SEG_COUNT = S_BYTE_LANES / M_BYTE_LANES;
    // data width and keep width per segment
    localparam SEG_DATA_WIDTH = S_DATA_WIDTH / SEG_COUNT;
    localparam SEG_KEEP_WIDTH = S_BYTE_LANES / SEG_COUNT;

    reg [S_DATA_WIDTH-1:0] s_axis_tdata_reg = {S_DATA_WIDTH{1'b0}};
    reg [S_KEEP_WIDTH-1:0] s_axis_tkeep_reg = {S_KEEP_WIDTH{1'b0}};
    reg s_axis_tvalid_reg = 1'b0;
    reg s_axis_tlast_reg = 1'b0;
    reg [ID_WIDTH-1:0] s_axis_tid_reg = {ID_WIDTH{1'b0}};
    reg [DEST_WIDTH-1:0] s_axis_tdest_reg = {DEST_WIDTH{1'b0}};
    reg [USER_WIDTH-1:0] s_axis_tuser_reg = {USER_WIDTH{1'b0}};

    reg [M_DATA_WIDTH-1:0] m_axis_tdata_reg = {M_DATA_WIDTH{1'b0}};
    reg [M_KEEP_WIDTH-1:0] m_axis_tkeep_reg = {M_KEEP_WIDTH{1'b0}};
    reg m_axis_tvalid_reg = 1'b0;
    reg m_axis_tlast_reg = 1'b0;
    reg [ID_WIDTH-1:0] m_axis_tid_reg = {ID_WIDTH{1'b0}};
    reg [DEST_WIDTH-1:0] m_axis_tdest_reg = {DEST_WIDTH{1'b0}};
    reg [USER_WIDTH-1:0] m_axis_tuser_reg = {USER_WIDTH{1'b0}};

    assign s_axis_tready = !s_axis_tvalid_reg;

    assign m_axis_tdata  = m_axis_tdata_reg;
    assign m_axis_tkeep  = M_KEEP_ENABLE ? m_axis_tkeep_reg : {M_KEEP_WIDTH{1'b1}};
    assign m_axis_tvalid = m_axis_tvalid_reg;
    assign m_axis_tlast  = m_axis_tlast_reg;
    assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {ID_WIDTH{1'b0}};
    assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {DEST_WIDTH{1'b0}};
    assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {USER_WIDTH{1'b0}};

    always @(posedge clk) begin
        m_axis_tvalid_reg <= m_axis_tvalid_reg && !m_axis_tready;

        if (!m_axis_tvalid_reg || m_axis_tready) begin
            // output register empty

            m_axis_tdata_reg <= s_axis_tvalid_reg ? s_axis_tdata_reg : s_axis_tdata;
            m_axis_tkeep_reg <= s_axis_tvalid_reg ? s_axis_tkeep_reg : s_axis_tkeep;
            m_axis_tlast_reg <= 1'b0;
            m_axis_tid_reg <= s_axis_tvalid_reg ? s_axis_tid_reg : s_axis_tid;
            m_axis_tdest_reg <= s_axis_tvalid_reg ? s_axis_tdest_reg : s_axis_tdest;
            m_axis_tuser_reg <= s_axis_tvalid_reg ? s_axis_tuser_reg : s_axis_tuser;

            if (s_axis_tvalid_reg) begin
                // buffer has data; shift out from buffer
                s_axis_tdata_reg <= s_axis_tdata_reg >> SEG_DATA_WIDTH;
                s_axis_tkeep_reg <= s_axis_tkeep_reg >> SEG_KEEP_WIDTH;

                m_axis_tvalid_reg <= 1'b1;

                if ((s_axis_tkeep_reg >> SEG_KEEP_WIDTH) == 0) begin
                    s_axis_tvalid_reg <= 1'b0;
                    m_axis_tlast_reg <= s_axis_tlast_reg;
                end
            end else if (s_axis_tvalid && s_axis_tready) begin
                // buffer is empty; store from input
                s_axis_tdata_reg <= s_axis_tdata >> SEG_DATA_WIDTH;
                s_axis_tkeep_reg <= s_axis_tkeep >> SEG_KEEP_WIDTH;
                s_axis_tlast_reg <= s_axis_tlast;
                s_axis_tid_reg <= s_axis_tid;
                s_axis_tdest_reg <= s_axis_tdest;
                s_axis_tuser_reg <= s_axis_tuser;

                m_axis_tvalid_reg <= 1'b1;

                if ((s_axis_tkeep >> SEG_KEEP_WIDTH) == 0) begin
                    s_axis_tvalid_reg <= 1'b0;
                    m_axis_tlast_reg <= s_axis_tlast;
                end else begin
                    s_axis_tvalid_reg <= 1'b1;
                end
            end
        end else if (s_axis_tvalid && s_axis_tready) begin
            // store input data
            s_axis_tdata_reg <= s_axis_tdata;
            s_axis_tkeep_reg <= s_axis_tkeep;
            s_axis_tvalid_reg <= 1'b1;
            s_axis_tlast_reg <= s_axis_tlast;
            s_axis_tid_reg <= s_axis_tid;
            s_axis_tdest_reg <= s_axis_tdest;
            s_axis_tuser_reg <= s_axis_tuser;
        end

        if (rst) begin
            s_axis_tvalid_reg <= 1'b0;
            m_axis_tvalid_reg <= 1'b0;
        end
    end

end

endgenerate

endmodule

`resetall
