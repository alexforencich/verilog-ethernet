/*

Copyright (c) 2018 Alex Forencich

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
 * AXI4-Stream demultiplexer
 */
module axis_demux #
(
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // output tdest signal width
    parameter M_DEST_WIDTH = 8,
    // input tdest signal width
    parameter S_DEST_WIDTH = M_DEST_WIDTH+$clog2(M_COUNT),
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // route via tdest
    parameter TDEST_ROUTE = 0
)
(
    input  wire                             clk,
    input  wire                             rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]            s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]            s_axis_tkeep,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire                             s_axis_tlast,
    input  wire [ID_WIDTH-1:0]              s_axis_tid,
    input  wire [S_DEST_WIDTH-1:0]          s_axis_tdest,
    input  wire [USER_WIDTH-1:0]            s_axis_tuser,

    /*
     * AXI outputs
     */
    output wire [M_COUNT*DATA_WIDTH-1:0]    m_axis_tdata,
    output wire [M_COUNT*KEEP_WIDTH-1:0]    m_axis_tkeep,
    output wire [M_COUNT-1:0]               m_axis_tvalid,
    input  wire [M_COUNT-1:0]               m_axis_tready,
    output wire [M_COUNT-1:0]               m_axis_tlast,
    output wire [M_COUNT*ID_WIDTH-1:0]      m_axis_tid,
    output wire [M_COUNT*M_DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0]    m_axis_tuser,

    /*
     * Control
     */
    input  wire                             enable,
    input  wire                             drop,
    input  wire [$clog2(M_COUNT)-1:0]       select
);

parameter CL_M_COUNT = $clog2(M_COUNT);

parameter M_DEST_WIDTH_INT = M_DEST_WIDTH > 0 ? M_DEST_WIDTH : 1;

// check configuration
initial begin
    if (TDEST_ROUTE) begin
        if (!DEST_ENABLE) begin
            $error("Error: TDEST_ROUTE set requires DEST_ENABLE set (instance %m)");
            $finish;
        end

        if (S_DEST_WIDTH < CL_M_COUNT) begin
            $error("Error: S_DEST_WIDTH too small for port count (instance %m)");
            $finish;
        end
    end
end

reg [CL_M_COUNT-1:0] select_reg = {CL_M_COUNT{1'b0}}, select_ctl, select_next;
reg drop_reg = 1'b0, drop_ctl, drop_next;
reg frame_reg = 1'b0, frame_ctl, frame_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

// internal datapath
reg  [DATA_WIDTH-1:0]    m_axis_tdata_int;
reg  [KEEP_WIDTH-1:0]    m_axis_tkeep_int;
reg  [M_COUNT-1:0]       m_axis_tvalid_int;
reg                      m_axis_tready_int_reg = 1'b0;
reg                      m_axis_tlast_int;
reg  [ID_WIDTH-1:0]      m_axis_tid_int;
reg  [M_DEST_WIDTH-1:0]  m_axis_tdest_int;
reg  [USER_WIDTH-1:0]    m_axis_tuser_int;
wire                     m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg && enable;

always @* begin
    select_next = select_reg;
    select_ctl = select_reg;
    drop_next = drop_reg;
    drop_ctl = drop_reg;
    frame_next = frame_reg;
    frame_ctl = frame_reg;

    s_axis_tready_next = 1'b0;

    if (s_axis_tvalid && s_axis_tready) begin
        // end of frame detection
        if (s_axis_tlast) begin
            frame_next = 1'b0;
            drop_next = 1'b0;
        end
    end

    if (!frame_reg && s_axis_tvalid && s_axis_tready) begin
        // start of frame, grab select value
        if (TDEST_ROUTE) begin
            if (M_COUNT > 1) begin
                select_ctl = s_axis_tdest[S_DEST_WIDTH-1:S_DEST_WIDTH-CL_M_COUNT];
                drop_ctl = s_axis_tdest[S_DEST_WIDTH-1:S_DEST_WIDTH-CL_M_COUNT] >= M_COUNT;
            end else begin
                select_ctl = 0;
                drop_ctl = 1'b0;
            end
        end else begin
            select_ctl = select;
            drop_ctl = drop || select >= M_COUNT;
        end
        frame_ctl = 1'b1;
        if (!(s_axis_tready && s_axis_tvalid && s_axis_tlast)) begin
            select_next = select_ctl;
            drop_next = drop_ctl;
            frame_next = 1'b1;
        end
    end

    s_axis_tready_next = (m_axis_tready_int_early || drop_ctl);

    m_axis_tdata_int  = s_axis_tdata;
    m_axis_tkeep_int  = s_axis_tkeep;
    m_axis_tvalid_int = (s_axis_tvalid && s_axis_tready && !drop_ctl) << select_ctl;
    m_axis_tlast_int  = s_axis_tlast;
    m_axis_tid_int    = s_axis_tid;
    m_axis_tdest_int  = s_axis_tdest;
    m_axis_tuser_int  = s_axis_tuser; 
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 2'd0;
        drop_reg <= 1'b0;
        frame_reg <= 1'b0;
        s_axis_tready_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        drop_reg <= drop_next;
        frame_reg <= frame_next;
        s_axis_tready_reg <= s_axis_tready_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0]    m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]    m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]       m_axis_tvalid_reg = {M_COUNT{1'b0}}, m_axis_tvalid_next;
reg                     m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]      m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [M_DEST_WIDTH-1:0]  m_axis_tdest_reg  = {M_DEST_WIDTH_INT{1'b0}};
reg [USER_WIDTH-1:0]    m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]    temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]    temp_m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]       temp_m_axis_tvalid_reg = {M_COUNT{1'b0}}, temp_m_axis_tvalid_next;
reg                     temp_m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]      temp_m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [M_DEST_WIDTH-1:0]  temp_m_axis_tdest_reg  = {M_DEST_WIDTH_INT{1'b0}};
reg [USER_WIDTH-1:0]    temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata  = {M_COUNT{m_axis_tdata_reg}};
assign m_axis_tkeep  = KEEP_ENABLE ? {M_COUNT{m_axis_tkeep_reg}} : {M_COUNT*KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = {M_COUNT{m_axis_tlast_reg}};
assign m_axis_tid    = ID_ENABLE   ? {M_COUNT{m_axis_tid_reg}}   : {M_COUNT*ID_WIDTH{1'b0}};
assign m_axis_tdest  = DEST_ENABLE ? {M_COUNT{m_axis_tdest_reg}} : {M_COUNT*M_DEST_WIDTH_INT{1'b0}};
assign m_axis_tuser  = USER_ENABLE ? {M_COUNT{m_axis_tuser_reg}} : {M_COUNT*USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_axis_tready_int_early = (m_axis_tready & m_axis_tvalid) || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid || !m_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (m_axis_tready_int_reg) begin
        // input is ready
        if ((m_axis_tready & m_axis_tvalid) || !m_axis_tvalid) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_axis_tready & m_axis_tvalid) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = {M_COUNT{1'b0}};
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_axis_tvalid_reg <= {M_COUNT{1'b0}};
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= {M_COUNT{1'b0}};
    end else begin
        m_axis_tvalid_reg <= m_axis_tvalid_next;
        m_axis_tready_int_reg <= m_axis_tready_int_early;
        temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= m_axis_tdata_int;
        m_axis_tkeep_reg <= m_axis_tkeep_int;
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tid_reg   <= m_axis_tid_int;
        m_axis_tdest_reg <= m_axis_tdest_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tid_reg   <= temp_m_axis_tid_reg;
        m_axis_tdest_reg <= temp_m_axis_tdest_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tid_reg   <= m_axis_tid_int;
        temp_m_axis_tdest_reg <= m_axis_tdest_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end
end

endmodule

`resetall
