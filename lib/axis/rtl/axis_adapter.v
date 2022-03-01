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
    parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8),
    // Width of output AXI stream interface in bits
    parameter M_DATA_WIDTH = 8,
    // Propagate tkeep signal on output interface
    // If disabled, tkeep assumed to be 1'b1
    parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8),
    // tkeep signal width (words per cycle) on output interface
    parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8),
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
parameter S_KEEP_WIDTH_INT = S_KEEP_ENABLE ? S_KEEP_WIDTH : 1;
parameter M_KEEP_WIDTH_INT = M_KEEP_ENABLE ? M_KEEP_WIDTH : 1;

// bus word sizes (must be identical)
parameter S_DATA_WORD_SIZE = S_DATA_WIDTH / S_KEEP_WIDTH_INT;
parameter M_DATA_WORD_SIZE = M_DATA_WIDTH / M_KEEP_WIDTH_INT;
// output bus is wider
parameter EXPAND_BUS = M_KEEP_WIDTH_INT > S_KEEP_WIDTH_INT;
// total data and keep widths
parameter DATA_WIDTH = EXPAND_BUS ? M_DATA_WIDTH : S_DATA_WIDTH;
parameter KEEP_WIDTH = EXPAND_BUS ? M_KEEP_WIDTH_INT : S_KEEP_WIDTH_INT;
// required number of segments in wider bus
parameter SEGMENT_COUNT = EXPAND_BUS ? (M_KEEP_WIDTH_INT / S_KEEP_WIDTH_INT) : (S_KEEP_WIDTH_INT / M_KEEP_WIDTH_INT);
parameter SEGMENT_COUNT_WIDTH = SEGMENT_COUNT == 1 ? 1 : $clog2(SEGMENT_COUNT);
// data width and keep width per segment
parameter SEGMENT_DATA_WIDTH = DATA_WIDTH / SEGMENT_COUNT;
parameter SEGMENT_KEEP_WIDTH = KEEP_WIDTH / SEGMENT_COUNT;

// bus width assertions
initial begin
    if (S_DATA_WORD_SIZE * S_KEEP_WIDTH_INT != S_DATA_WIDTH) begin
        $error("Error: input data width not evenly divisble (instance %m)");
        $finish;
    end

    if (M_DATA_WORD_SIZE * M_KEEP_WIDTH_INT != M_DATA_WIDTH) begin
        $error("Error: output data width not evenly divisble (instance %m)");
        $finish;
    end

    if (S_DATA_WORD_SIZE != M_DATA_WORD_SIZE) begin
        $error("Error: word size mismatch (instance %m)");
        $finish;
    end
end

// state register
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_TRANSFER_IN = 3'd1,
    STATE_TRANSFER_OUT = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

reg [SEGMENT_COUNT_WIDTH-1:0] segment_count_reg = 0, segment_count_next;

reg last_segment;

reg [DATA_WIDTH-1:0] temp_tdata_reg = {DATA_WIDTH{1'b0}}, temp_tdata_next;
reg [KEEP_WIDTH-1:0] temp_tkeep_reg = {KEEP_WIDTH{1'b0}}, temp_tkeep_next;
reg                  temp_tlast_reg = 1'b0, temp_tlast_next;
reg [ID_WIDTH-1:0]   temp_tid_reg   = {ID_WIDTH{1'b0}}, temp_tid_next;
reg [DEST_WIDTH-1:0] temp_tdest_reg = {DEST_WIDTH{1'b0}}, temp_tdest_next;
reg [USER_WIDTH-1:0] temp_tuser_reg = {USER_WIDTH{1'b0}}, temp_tuser_next;

// internal datapath
reg  [M_DATA_WIDTH-1:0] m_axis_tdata_int;
reg  [M_KEEP_WIDTH-1:0] m_axis_tkeep_int;
reg                     m_axis_tvalid_int;
reg                     m_axis_tready_int_reg = 1'b0;
reg                     m_axis_tlast_int;
reg  [ID_WIDTH-1:0]     m_axis_tid_int;
reg  [DEST_WIDTH-1:0]   m_axis_tdest_int;
reg  [USER_WIDTH-1:0]   m_axis_tuser_int;
wire                    m_axis_tready_int_early;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

assign s_axis_tready = s_axis_tready_reg;

always @* begin
    state_next = STATE_IDLE;

    segment_count_next = segment_count_reg;

    last_segment = 0;

    temp_tdata_next = temp_tdata_reg;
    temp_tkeep_next = temp_tkeep_reg;
    temp_tlast_next = temp_tlast_reg;
    temp_tid_next   = temp_tid_reg;
    temp_tdest_next = temp_tdest_reg;
    temp_tuser_next = temp_tuser_reg;

    if (EXPAND_BUS) begin
        m_axis_tdata_int  = temp_tdata_reg;
        m_axis_tkeep_int  = temp_tkeep_reg;
        m_axis_tlast_int  = temp_tlast_reg;
    end else begin
        m_axis_tdata_int  = {M_DATA_WIDTH{1'b0}};
        m_axis_tkeep_int  = {M_KEEP_WIDTH{1'b0}};
        m_axis_tlast_int  = 1'b0;
    end
    m_axis_tvalid_int = 1'b0;
    m_axis_tid_int    = temp_tid_reg;
    m_axis_tdest_int  = temp_tdest_reg;
    m_axis_tuser_int  = temp_tuser_reg;

    s_axis_tready_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - no data in registers
            if (SEGMENT_COUNT == 1) begin
                // output and input same width - just act like a register

                // accept data next cycle if output register ready next cycle
                s_axis_tready_next = m_axis_tready_int_early;

                // transfer through
                m_axis_tdata_int  = s_axis_tdata;
                m_axis_tkeep_int  = S_KEEP_ENABLE ? s_axis_tkeep : 1'b1;
                m_axis_tvalid_int = s_axis_tvalid;
                m_axis_tlast_int  = s_axis_tlast;
                m_axis_tid_int    = s_axis_tid;
                m_axis_tdest_int  = s_axis_tdest;
                m_axis_tuser_int  = s_axis_tuser;

                state_next = STATE_IDLE;
            end else if (EXPAND_BUS) begin
                // output bus is wider

                // accept new data
                s_axis_tready_next = 1'b1;

                if (s_axis_tready && s_axis_tvalid) begin
                    // word transfer in - store it in data register

                    // pass complete input word, zero-extended to temp register
                    temp_tdata_next = s_axis_tdata;
                    temp_tkeep_next = S_KEEP_ENABLE ? s_axis_tkeep : 1'b1;
                    temp_tlast_next = s_axis_tlast;
                    temp_tid_next   = s_axis_tid;
                    temp_tdest_next = s_axis_tdest;
                    temp_tuser_next = s_axis_tuser;

                    // first input segment complete
                    segment_count_next = 1;

                    if (s_axis_tlast) begin
                        // got last signal on first segment, so output it
                        s_axis_tready_next = 1'b0;
                        state_next = STATE_TRANSFER_OUT;
                    end else begin
                        // otherwise, transfer in the rest of the words
                        s_axis_tready_next = 1'b1;
                        state_next = STATE_TRANSFER_IN;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                // output bus is narrower

                // accept new data
                s_axis_tready_next = 1'b1;

                if (s_axis_tready && s_axis_tvalid) begin
                    // word transfer in - store it in data register
                    segment_count_next = 0;

                    // is this the last segment?
                    if (SEGMENT_COUNT == 1) begin
                        // last segment by counter value
                        last_segment = 1'b1;
                    end else if (S_KEEP_ENABLE && s_axis_tkeep[SEGMENT_KEEP_WIDTH-1:0] != {SEGMENT_KEEP_WIDTH{1'b1}}) begin
                        // last segment by tkeep fall in current segment
                        last_segment = 1'b1;
                    end else if (S_KEEP_ENABLE && s_axis_tkeep[(SEGMENT_KEEP_WIDTH*2)-1:SEGMENT_KEEP_WIDTH] == {SEGMENT_KEEP_WIDTH{1'b0}}) begin
                        // last segment by tkeep fall at end of current segment
                        last_segment = 1'b1;
                    end else begin
                        last_segment = 1'b0;
                    end

                    // pass complete input word, zero-extended to temp register
                    temp_tdata_next = s_axis_tdata;
                    temp_tkeep_next = S_KEEP_ENABLE ? s_axis_tkeep : 1'b1;
                    temp_tlast_next = s_axis_tlast;
                    temp_tid_next   = s_axis_tid;
                    temp_tdest_next = s_axis_tdest;
                    temp_tuser_next = s_axis_tuser;

                    // short-circuit and get first word out the door
                    m_axis_tdata_int  = s_axis_tdata[SEGMENT_DATA_WIDTH-1:0];
                    m_axis_tkeep_int  = s_axis_tkeep[SEGMENT_KEEP_WIDTH-1:0];
                    m_axis_tvalid_int = 1'b1;
                    m_axis_tlast_int  = s_axis_tlast & last_segment;
                    m_axis_tid_int    = s_axis_tid;
                    m_axis_tdest_int  = s_axis_tdest;
                    m_axis_tuser_int  = s_axis_tuser;

                    if (m_axis_tready_int_reg) begin
                        // if output register is ready for first word, then move on to the next one
                        segment_count_next = 1;
                    end

                    if (!last_segment || !m_axis_tready_int_reg) begin
                        // continue outputting words
                        s_axis_tready_next = 1'b0;
                        state_next = STATE_TRANSFER_OUT;
                    end else begin
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_TRANSFER_IN: begin
            // transfer word to temp registers
            // only used when output is wider

            // accept new data
            s_axis_tready_next = 1'b1;

            if (s_axis_tready && s_axis_tvalid) begin
                // word transfer in - store in data register

                temp_tdata_next[segment_count_reg*SEGMENT_DATA_WIDTH +: SEGMENT_DATA_WIDTH] = s_axis_tdata;
                temp_tkeep_next[segment_count_reg*SEGMENT_KEEP_WIDTH +: SEGMENT_KEEP_WIDTH] = S_KEEP_ENABLE ? s_axis_tkeep : 1'b1;
                temp_tlast_next = s_axis_tlast;
                temp_tid_next   = s_axis_tid;
                temp_tdest_next = s_axis_tdest;
                temp_tuser_next = s_axis_tuser;

                segment_count_next = segment_count_reg + 1;

                if ((segment_count_reg == SEGMENT_COUNT-1) || s_axis_tlast) begin
                    // terminated by counter or tlast signal, output complete word
                    // read input word next cycle if output will be ready
                    s_axis_tready_next = m_axis_tready_int_early;
                    state_next = STATE_TRANSFER_OUT;
                end else begin
                    // more words to read
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_TRANSFER_IN;
                end
            end else begin
                state_next = STATE_TRANSFER_IN;
            end
        end
        STATE_TRANSFER_OUT: begin
            // transfer word to output registers

            if (EXPAND_BUS) begin
                // output bus is wider

                // do not accept new data
                s_axis_tready_next = 1'b0;

                // single-cycle output of entire stored word (output wider)
                m_axis_tdata_int  = temp_tdata_reg;
                m_axis_tkeep_int  = temp_tkeep_reg;
                m_axis_tvalid_int = 1'b1;
                m_axis_tlast_int  = temp_tlast_reg;
                m_axis_tid_int    = temp_tid_reg;
                m_axis_tdest_int  = temp_tdest_reg;
                m_axis_tuser_int  = temp_tuser_reg;

                if (m_axis_tready_int_reg) begin
                    // word transfer out

                    if (s_axis_tready && s_axis_tvalid) begin
                        // word transfer in

                        // pass complete input word, zero-extended to temp register
                        temp_tdata_next = s_axis_tdata;
                        temp_tkeep_next = S_KEEP_ENABLE ? s_axis_tkeep : 1'b1;
                        temp_tlast_next = s_axis_tlast;
                        temp_tid_next   = s_axis_tid;
                        temp_tdest_next = s_axis_tdest;
                        temp_tuser_next = s_axis_tuser;

                        // first input segment complete
                        segment_count_next = 1;

                        if (s_axis_tlast) begin
                            // got last signal on first segment, so output it
                            s_axis_tready_next = 1'b0;
                            state_next = STATE_TRANSFER_OUT;
                        end else begin
                            // otherwise, transfer in the rest of the words
                            s_axis_tready_next = 1'b1;
                            state_next = STATE_TRANSFER_IN;
                        end
                    end else begin
                        s_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_TRANSFER_OUT;
                end
            end else begin
                // output bus is narrower

                // do not accept new data
                s_axis_tready_next = 1'b0;

                // is this the last segment?
                if (segment_count_reg == SEGMENT_COUNT-1) begin
                    // last segment by counter value
                    last_segment = 1'b1;
                end else if (temp_tkeep_reg[segment_count_reg*SEGMENT_KEEP_WIDTH +: SEGMENT_KEEP_WIDTH] != {SEGMENT_KEEP_WIDTH{1'b1}}) begin
                    // last segment by tkeep fall in current segment
                    last_segment = 1'b1;
                end else if (temp_tkeep_reg[(segment_count_reg+1)*SEGMENT_KEEP_WIDTH +: SEGMENT_KEEP_WIDTH] == {SEGMENT_KEEP_WIDTH{1'b0}}) begin
                    // last segment by tkeep fall at end of current segment
                    last_segment = 1'b1;
                end else begin
                    last_segment = 1'b0;
                end

                // output current part of stored word (output narrower)
                m_axis_tdata_int  = temp_tdata_reg[segment_count_reg*SEGMENT_DATA_WIDTH +: SEGMENT_DATA_WIDTH];
                m_axis_tkeep_int  = temp_tkeep_reg[segment_count_reg*SEGMENT_KEEP_WIDTH +: SEGMENT_KEEP_WIDTH];
                m_axis_tvalid_int = 1'b1;
                m_axis_tlast_int  = temp_tlast_reg && last_segment;
                m_axis_tid_int    = temp_tid_reg;
                m_axis_tdest_int  = temp_tdest_reg;
                m_axis_tuser_int  = temp_tuser_reg;

                if (m_axis_tready_int_reg) begin
                    // word transfer out

                    segment_count_next = segment_count_reg + 1;

                    if (last_segment) begin
                        // terminated by counter or tlast signal

                        s_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end else begin
                        // more words to write
                        state_next = STATE_TRANSFER_OUT;
                    end
                end else begin
                    state_next = STATE_TRANSFER_OUT;
                end
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        s_axis_tready_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        s_axis_tready_reg <= s_axis_tready_next;
    end

    segment_count_reg <= segment_count_next;

    temp_tdata_reg <= temp_tdata_next;
    temp_tkeep_reg <= temp_tkeep_next;
    temp_tlast_reg <= temp_tlast_next;
    temp_tid_reg   <= temp_tid_next;
    temp_tdest_reg <= temp_tdest_next;
    temp_tuser_reg <= temp_tuser_next;
end

// output datapath logic
reg [M_DATA_WIDTH-1:0] m_axis_tdata_reg  = {M_DATA_WIDTH{1'b0}};
reg [M_KEEP_WIDTH-1:0] m_axis_tkeep_reg  = {M_KEEP_WIDTH{1'b0}};
reg                    m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                    m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]     m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]   m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]   m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [M_DATA_WIDTH-1:0] temp_m_axis_tdata_reg  = {M_DATA_WIDTH{1'b0}};
reg [M_KEEP_WIDTH-1:0] temp_m_axis_tkeep_reg  = {M_KEEP_WIDTH{1'b0}};
reg                    temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                    temp_m_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]     temp_m_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]   temp_m_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]   temp_m_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tkeep  = M_KEEP_ENABLE ? m_axis_tkeep_reg : {M_KEEP_WIDTH{1'b1}};
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
