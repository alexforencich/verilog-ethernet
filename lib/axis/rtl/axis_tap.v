/*

Copyright (c) 2015-2018 Alex Forencich

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
 * AXI4-Stream tap
 */
module axis_tap #
(
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
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI tap
     */
    input  wire [DATA_WIDTH-1:0]  tap_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  tap_axis_tkeep,
    input  wire                   tap_axis_tvalid,
    input  wire                   tap_axis_tready,
    input  wire                   tap_axis_tlast,
    input  wire [ID_WIDTH-1:0]    tap_axis_tid,
    input  wire [DEST_WIDTH-1:0]  tap_axis_tdest,
    input  wire [USER_WIDTH-1:0]  tap_axis_tuser,

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

// datapath control signals
reg store_last_word;

reg [ID_WIDTH-1:0]   last_word_id_reg   = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] last_word_dest_reg = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] last_word_user_reg = {USER_WIDTH{1'b0}};

// internal datapath
reg  [DATA_WIDTH-1:0] m_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] m_axis_tkeep_int;
reg                   m_axis_tvalid_int;
reg                   m_axis_tready_int_reg = 1'b0;
reg                   m_axis_tlast_int;
reg  [ID_WIDTH-1:0]   m_axis_tid_int;
reg  [DEST_WIDTH-1:0] m_axis_tdest_int;
reg  [USER_WIDTH-1:0] m_axis_tuser_int;
wire                  m_axis_tready_int_early;

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_TRANSFER = 2'd1,
    STATE_TRUNCATE = 2'd2,
    STATE_WAIT = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg frame_reg = 1'b0, frame_next;

always @* begin
    state_next = STATE_IDLE;

    store_last_word = 1'b0;

    frame_next = frame_reg;

    m_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    m_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int  = 1'b0;
    m_axis_tid_int    = {ID_WIDTH{1'b0}};
    m_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    m_axis_tuser_int  = {USER_WIDTH{1'b0}};

    if (tap_axis_tready && tap_axis_tvalid) begin
        frame_next = !tap_axis_tlast;
    end

    case (state_reg)
        STATE_IDLE: begin
            if (tap_axis_tready && tap_axis_tvalid) begin
                // start of frame
                if (m_axis_tready_int_reg) begin
                    m_axis_tdata_int  = tap_axis_tdata;
                    m_axis_tkeep_int  = tap_axis_tkeep;
                    m_axis_tvalid_int = tap_axis_tvalid && tap_axis_tready;
                    m_axis_tlast_int  = tap_axis_tlast;
                    m_axis_tid_int    = tap_axis_tid;
                    m_axis_tdest_int  = tap_axis_tdest;
                    m_axis_tuser_int  = tap_axis_tuser;
                    if (tap_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end else begin
                    state_next = STATE_WAIT;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_TRANSFER: begin
            if (tap_axis_tready && tap_axis_tvalid) begin
                // transfer data
                if (m_axis_tready_int_reg) begin
                    m_axis_tdata_int  = tap_axis_tdata;
                    m_axis_tkeep_int  = tap_axis_tkeep;
                    m_axis_tvalid_int = tap_axis_tvalid && tap_axis_tready;
                    m_axis_tlast_int  = tap_axis_tlast;
                    m_axis_tid_int    = tap_axis_tid;
                    m_axis_tdest_int  = tap_axis_tdest;
                    m_axis_tuser_int  = tap_axis_tuser;
                    if (tap_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end else begin
                    store_last_word = 1'b1;
                    state_next = STATE_TRUNCATE;
                end
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
        STATE_TRUNCATE: begin
            if (m_axis_tready_int_reg) begin
                m_axis_tdata_int  = {DATA_WIDTH{1'b0}};
                m_axis_tkeep_int  = {{KEEP_WIDTH-1{1'b0}}, 1'b1};
                m_axis_tvalid_int = 1'b1;
                m_axis_tlast_int  = 1'b1;
                m_axis_tid_int    = last_word_id_reg;
                m_axis_tdest_int  = last_word_dest_reg;
                m_axis_tuser_int  = (last_word_user_reg & ~USER_BAD_FRAME_MASK) | (USER_BAD_FRAME_VALUE & USER_BAD_FRAME_MASK);
                if (frame_next) begin
                    state_next = STATE_WAIT;
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_TRUNCATE;
            end
        end
        STATE_WAIT: begin
            if (tap_axis_tready && tap_axis_tvalid) begin
                if (tap_axis_tlast) begin
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WAIT;
                end
            end else begin
                state_next = STATE_WAIT;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        frame_reg <= frame_next;
    end

    if (store_last_word) begin
        last_word_id_reg   <= tap_axis_tid;
        last_word_dest_reg <= tap_axis_tdest;
        last_word_user_reg <= tap_axis_tuser;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tkeep  = KEEP_ENABLE ? m_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast  = m_axis_tlast_reg;
assign m_axis_tid    = ID_ENABLE   ? m_axis_tid_reg   : {ID_WIDTH{1'b0}};
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
