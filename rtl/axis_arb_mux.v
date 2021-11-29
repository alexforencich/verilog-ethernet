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
 * AXI4-Stream arbitrated multiplexer
 */
module axis_arb_mux #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // input tid signal width
    parameter S_ID_WIDTH = 8,
    // output tid signal width
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(S_COUNT),
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Update tid with routing information
    parameter UPDATE_TID = 0,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI Stream inputs
     */
    input  wire [S_COUNT*DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire [S_COUNT-1:0]             s_axis_tvalid,
    output wire [S_COUNT-1:0]             s_axis_tready,
    input  wire [S_COUNT-1:0]             s_axis_tlast,
    input  wire [S_COUNT*S_ID_WIDTH-1:0]  s_axis_tid,
    input  wire [S_COUNT*DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0]  s_axis_tuser,

    /*
     * AXI Stream output
     */
    output wire [DATA_WIDTH-1:0]          m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]          m_axis_tkeep,
    output wire                           m_axis_tvalid,
    input  wire                           m_axis_tready,
    output wire                           m_axis_tlast,
    output wire [M_ID_WIDTH-1:0]          m_axis_tid,
    output wire [DEST_WIDTH-1:0]          m_axis_tdest,
    output wire [USER_WIDTH-1:0]          m_axis_tuser
);

parameter CL_S_COUNT = $clog2(S_COUNT);

parameter S_ID_WIDTH_INT = S_ID_WIDTH > 0 ? S_ID_WIDTH : 1;

// check configuration
initial begin
    if (UPDATE_TID) begin
        if (!ID_ENABLE) begin
            $error("Error: UPDATE_TID set requires ID_ENABLE set (instance %m)");
            $finish;
        end

        if (M_ID_WIDTH < CL_S_COUNT) begin
            $error("Error: M_ID_WIDTH too small for port count (instance %m)");
            $finish;
        end
    end
end

wire [S_COUNT-1:0] request;
wire [S_COUNT-1:0] acknowledge;
wire [S_COUNT-1:0] grant;
wire grant_valid;
wire [CL_S_COUNT-1:0] grant_encoded;

// internal datapath
reg  [DATA_WIDTH-1:0] m_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] m_axis_tkeep_int;
reg                   m_axis_tvalid_int;
reg                   m_axis_tready_int_reg = 1'b0;
reg                   m_axis_tlast_int;
reg  [M_ID_WIDTH-1:0] m_axis_tid_int;
reg  [DEST_WIDTH-1:0] m_axis_tdest_int;
reg  [USER_WIDTH-1:0] m_axis_tuser_int;
wire                  m_axis_tready_int_early;

assign s_axis_tready = (m_axis_tready_int_reg && grant_valid) << grant_encoded;

// mux for incoming packet
wire [DATA_WIDTH-1:0] current_s_tdata  = s_axis_tdata[grant_encoded*DATA_WIDTH +: DATA_WIDTH];
wire [KEEP_WIDTH-1:0] current_s_tkeep  = s_axis_tkeep[grant_encoded*KEEP_WIDTH +: KEEP_WIDTH];
wire                  current_s_tvalid = s_axis_tvalid[grant_encoded];
wire                  current_s_tready = s_axis_tready[grant_encoded];
wire                  current_s_tlast  = s_axis_tlast[grant_encoded];
wire [S_ID_WIDTH-1:0] current_s_tid    = s_axis_tid[grant_encoded*S_ID_WIDTH +: S_ID_WIDTH_INT];
wire [DEST_WIDTH-1:0] current_s_tdest  = s_axis_tdest[grant_encoded*DEST_WIDTH +: DEST_WIDTH];
wire [USER_WIDTH-1:0] current_s_tuser  = s_axis_tuser[grant_encoded*USER_WIDTH +: USER_WIDTH];

// arbiter instance
arbiter #(
    .PORTS(S_COUNT),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_BLOCK(1),
    .ARB_BLOCK_ACK(1),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
)
arb_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

assign request = s_axis_tvalid & ~grant;
assign acknowledge = grant & s_axis_tvalid & s_axis_tready & (LAST_ENABLE ? s_axis_tlast : {S_COUNT{1'b1}});

always @* begin
    // pass through selected packet data
    m_axis_tdata_int  = current_s_tdata;
    m_axis_tkeep_int  = current_s_tkeep;
    m_axis_tvalid_int = current_s_tvalid && m_axis_tready_int_reg && grant_valid;
    m_axis_tlast_int  = current_s_tlast;
    m_axis_tid_int    = current_s_tid;
    if (UPDATE_TID && S_COUNT > 1) begin
        m_axis_tid_int[M_ID_WIDTH-1:M_ID_WIDTH-CL_S_COUNT] = grant_encoded;
    end
    m_axis_tdest_int  = current_s_tdest;
    m_axis_tuser_int  = current_s_tuser;
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg  = 1'b0;
reg [M_ID_WIDTH-1:0] m_axis_tid_reg    = {M_ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg  = 1'b0;
reg [M_ID_WIDTH-1:0] temp_m_axis_tid_reg    = {M_ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tkeep  = KEEP_ENABLE ? m_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = LAST_ENABLE ? m_axis_tlast_reg : 1'b1;
assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {M_ID_WIDTH{1'b0}};
assign m_axis_tdest  = DEST_ENABLE ? m_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign m_axis_tuser  = USER_ENABLE ? m_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign m_axis_tready_int_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (m_axis_tready_int_reg) begin
        // input is ready
        if (m_axis_tready || !m_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (m_axis_tready) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        m_axis_tvalid_reg <= 1'b0;
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= 1'b0;
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
