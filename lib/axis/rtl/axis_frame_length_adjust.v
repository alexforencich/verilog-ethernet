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
 * AXI4-Stream frame length adjuster
 */
module axis_frame_length_adjust #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
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
    parameter USER_WIDTH = 1
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
    output wire [USER_WIDTH-1:0]  m_axis_tuser,

    /*
     * Status
     */
    output wire                   status_valid,
    input  wire                   status_ready,
    output wire                   status_frame_pad,
    output wire                   status_frame_truncate,
    output wire [15:0]            status_frame_length,
    output wire [15:0]            status_frame_original_length,

    /*
     * Configuration
     */
    input  wire [15:0]            length_min,
    input  wire [15:0]            length_max
);

// bus word width
localparam DATA_WORD_WIDTH = DATA_WIDTH / KEEP_WIDTH;

// bus width assertions
initial begin
    if (DATA_WORD_WIDTH * KEEP_WIDTH != DATA_WIDTH) begin
        $error("Error: data width not evenly divisble (instance %m)");
        $finish;
    end
end

// state register
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_TRANSFER = 3'd1,
    STATE_PAD = 3'd2,
    STATE_TRUNCATE = 3'd3;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg store_last_word;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [DATA_WIDTH-1:0] s_axis_tdata_masked;

// frame length counters
reg [15:0] short_counter_reg = 16'd0, short_counter_next = 16'd0;
reg [15:0] long_counter_reg = 16'd0, long_counter_next = 16'd0;

reg [DATA_WIDTH-1:0] last_word_data_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] last_word_keep_reg = {KEEP_WIDTH{1'b0}};
reg [ID_WIDTH-1:0]   last_word_id_reg   = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] last_word_dest_reg = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] last_word_user_reg = {USER_WIDTH{1'b0}};

reg status_valid_reg = 1'b0, status_valid_next;
reg status_frame_pad_reg = 1'b0, status_frame_pad_next;
reg status_frame_truncate_reg = 1'b0, status_frame_truncate_next;
reg [15:0] status_frame_length_reg = 16'd0, status_frame_length_next;
reg [15:0] status_frame_original_length_reg = 16'd0, status_frame_original_length_next;

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

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;
assign s_axis_tready = s_axis_tready_reg;

assign status_valid = status_valid_reg;
assign status_frame_pad = status_frame_pad_reg;
assign status_frame_truncate = status_frame_truncate_reg;
assign status_frame_length = status_frame_length_reg;
assign status_frame_original_length = status_frame_original_length_reg;

integer i, word_cnt;

always @* begin
    state_next = STATE_IDLE;

    store_last_word = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    short_counter_next = short_counter_reg;
    long_counter_next = long_counter_reg;

    m_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    m_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int  = 1'b0;
    m_axis_tid_int    = {ID_WIDTH{1'b0}};
    m_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    m_axis_tuser_int  = {USER_WIDTH{1'b0}};

    s_axis_tready_next = 1'b0;

    status_valid_next = status_valid_reg && !status_ready;
    status_frame_pad_next = status_frame_pad_reg;
    status_frame_truncate_next = status_frame_truncate_reg;
    status_frame_length_next = status_frame_length_reg;
    status_frame_original_length_next = status_frame_original_length_reg;

    if (KEEP_ENABLE) begin
        for (i = 0; i < KEEP_WIDTH; i = i + 1) begin
            s_axis_tdata_masked[i*DATA_WORD_WIDTH +: DATA_WORD_WIDTH] = s_axis_tkeep[i] ? s_axis_tdata[i*DATA_WORD_WIDTH +: DATA_WORD_WIDTH] : {DATA_WORD_WIDTH{1'b0}};
        end
    end else begin
        s_axis_tdata_masked = s_axis_tdata;
    end

    case (state_reg)
        STATE_IDLE: begin
            // idle state
            // accept data next cycle if output register ready next cycle
            s_axis_tready_next = m_axis_tready_int_early && (!status_valid_reg || status_ready);

            m_axis_tdata_int = s_axis_tdata_masked;
            m_axis_tkeep_int = s_axis_tkeep;
            m_axis_tvalid_int = s_axis_tvalid;
            m_axis_tlast_int = s_axis_tlast;
            m_axis_tid_int = s_axis_tid;
            m_axis_tdest_int = s_axis_tdest;
            m_axis_tuser_int = s_axis_tuser;

            short_counter_next = length_min;
            long_counter_next = length_max;

            if (s_axis_tready && s_axis_tvalid) begin
                // transfer through
                word_cnt = 0;
                for (i = 0; i <= KEEP_WIDTH; i = i + 1) begin
                    //bit_cnt = bit_cnt + monitor_axis_tkeep[i];
                    if (s_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) word_cnt = i;
                end
                frame_ptr_next = frame_ptr_reg+KEEP_WIDTH;

                if (short_counter_reg > KEEP_WIDTH) begin
                    short_counter_next = short_counter_reg - KEEP_WIDTH;
                end else begin
                    short_counter_next = 16'd0;
                end

                if (long_counter_reg > KEEP_WIDTH) begin
                    long_counter_next = long_counter_reg - KEEP_WIDTH;
                end else begin
                    long_counter_next = 16'd0;
                end

                if (long_counter_reg <= word_cnt) begin
                    m_axis_tkeep_int = ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-long_counter_reg);
                    if (s_axis_tlast) begin
                        status_valid_next = 1'b1;
                        status_frame_pad_next = 1'b0;
                        status_frame_truncate_next = word_cnt > long_counter_reg;
                        status_frame_length_next = length_max;
                        status_frame_original_length_next = frame_ptr_reg+word_cnt;
                        s_axis_tready_next = m_axis_tready_int_early && status_ready;
                        frame_ptr_next = 16'd0;
                        short_counter_next = length_min;
                        long_counter_next = length_max;
                        state_next = STATE_IDLE;
                    end else begin
                        m_axis_tvalid_int = 1'b0;
                        store_last_word = 1'b1;
                        state_next = STATE_TRUNCATE;
                    end
                end else begin
                    if (s_axis_tlast) begin
                        status_frame_original_length_next = frame_ptr_reg+word_cnt;
                        if (short_counter_reg > word_cnt) begin
                            if (short_counter_reg > KEEP_WIDTH) begin
                                frame_ptr_next = frame_ptr_reg + KEEP_WIDTH;
                                s_axis_tready_next = 1'b0;
                                m_axis_tkeep_int = {KEEP_WIDTH{1'b1}};
                                m_axis_tlast_int = 1'b0;
                                store_last_word = 1'b1;
                                state_next = STATE_PAD;
                            end else begin
                                status_valid_next = 1'b1;
                                status_frame_pad_next = 1'b1;
                                status_frame_truncate_next = 1'b0;
                                status_frame_length_next = length_min;
                                s_axis_tready_next = m_axis_tready_int_early && status_ready;
                                m_axis_tkeep_int = ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-(length_min - frame_ptr_reg));
                                frame_ptr_next = 16'd0;
                                short_counter_next = length_min;
                                long_counter_next = length_max;
                                state_next = STATE_IDLE;
                            end
                        end else begin
                            status_valid_next = 1'b1;
                            status_frame_pad_next = 1'b0;
                            status_frame_truncate_next = 1'b0;
                            status_frame_length_next = frame_ptr_reg+word_cnt;
                            status_frame_original_length_next = frame_ptr_reg+word_cnt;
                            s_axis_tready_next = m_axis_tready_int_early && status_ready;
                            frame_ptr_next = 16'd0;
                            short_counter_next = length_min;
                            long_counter_next = length_max;
                            state_next = STATE_IDLE;
                        end
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_TRANSFER: begin
            // transfer data
            // accept data next cycle if output register ready next cycle
            s_axis_tready_next = m_axis_tready_int_early;

            m_axis_tdata_int = s_axis_tdata_masked;
            m_axis_tkeep_int = s_axis_tkeep;
            m_axis_tvalid_int = s_axis_tvalid;
            m_axis_tlast_int = s_axis_tlast;
            m_axis_tid_int = s_axis_tid;
            m_axis_tdest_int = s_axis_tdest;
            m_axis_tuser_int = s_axis_tuser;

            if (s_axis_tready && s_axis_tvalid) begin
                // transfer through
                word_cnt = 1;
                for (i = 1; i <= KEEP_WIDTH; i = i + 1) begin
                    //bit_cnt = bit_cnt + monitor_axis_tkeep[i];
                    if (s_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) word_cnt = i;
                end
                frame_ptr_next = frame_ptr_reg+KEEP_WIDTH;

                if (short_counter_reg > KEEP_WIDTH) begin
                    short_counter_next = short_counter_reg - KEEP_WIDTH;
                end else begin
                    short_counter_next = 16'd0;
                end

                if (long_counter_reg > KEEP_WIDTH) begin
                    long_counter_next = long_counter_reg - KEEP_WIDTH;
                end else begin
                    long_counter_next = 16'd0;
                end

                if (long_counter_reg <= word_cnt) begin
                    m_axis_tkeep_int = ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-long_counter_reg);
                    if (s_axis_tlast) begin
                        status_valid_next = 1'b1;
                        status_frame_pad_next = 1'b0;
                        status_frame_truncate_next = word_cnt > long_counter_reg;
                        status_frame_length_next = length_max;
                        status_frame_original_length_next = frame_ptr_reg+word_cnt;
                        s_axis_tready_next = m_axis_tready_int_early && status_ready;
                        frame_ptr_next = 16'd0;
                        short_counter_next = length_min;
                        long_counter_next = length_max;
                        state_next = STATE_IDLE;
                    end else begin
                        m_axis_tvalid_int = 1'b0;
                        store_last_word = 1'b1;
                        state_next = STATE_TRUNCATE;
                    end
                end else begin
                    if (s_axis_tlast) begin
                        status_frame_original_length_next = frame_ptr_reg+word_cnt;
                        if (short_counter_reg > word_cnt) begin
                            if (short_counter_reg > KEEP_WIDTH) begin
                                frame_ptr_next = frame_ptr_reg + KEEP_WIDTH;
                                s_axis_tready_next = 1'b0;
                                m_axis_tkeep_int = {KEEP_WIDTH{1'b1}};
                                m_axis_tlast_int = 1'b0;
                                store_last_word = 1'b1;
                                state_next = STATE_PAD;
                            end else begin
                                status_valid_next = 1'b1;
                                status_frame_pad_next = 1'b1;
                                status_frame_truncate_next = 1'b0;
                                status_frame_length_next = length_min;
                                s_axis_tready_next = m_axis_tready_int_early && status_ready;
                                m_axis_tkeep_int = ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-short_counter_reg);
                                frame_ptr_next = 16'd0;
                                short_counter_next = length_min;
                                long_counter_next = length_max;
                                state_next = STATE_IDLE;
                            end
                        end else begin
                            status_valid_next = 1'b1;
                            status_frame_pad_next = 1'b0;
                            status_frame_truncate_next = 1'b0;
                            status_frame_length_next = frame_ptr_reg+word_cnt;
                            status_frame_original_length_next = frame_ptr_reg+word_cnt;
                            s_axis_tready_next = m_axis_tready_int_early && status_ready;
                            frame_ptr_next = 16'd0;
                            short_counter_next = length_min;
                            long_counter_next = length_max;
                            state_next = STATE_IDLE;
                        end
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
        STATE_PAD: begin
            // pad to minimum length
            s_axis_tready_next = 1'b0;

            m_axis_tdata_int = {DATA_WIDTH{1'b0}};
            m_axis_tkeep_int = {KEEP_WIDTH{1'b1}};
            m_axis_tvalid_int = 1'b1;
            m_axis_tlast_int = 1'b0;
            m_axis_tid_int = last_word_id_reg;
            m_axis_tdest_int = last_word_dest_reg;
            m_axis_tuser_int = last_word_user_reg;

            if (m_axis_tready_int_reg) begin
                frame_ptr_next = frame_ptr_reg + KEEP_WIDTH;

                if (short_counter_reg > KEEP_WIDTH) begin
                    short_counter_next = short_counter_reg - KEEP_WIDTH;
                end else begin
                    short_counter_next = 16'd0;
                end

                if (long_counter_reg > KEEP_WIDTH) begin
                    long_counter_next = long_counter_reg - KEEP_WIDTH;
                end else begin
                    long_counter_next = 16'd0;
                end

                if (short_counter_reg <= KEEP_WIDTH) begin
                    status_valid_next = 1'b1;
                    status_frame_pad_next = 1'b1;
                    status_frame_truncate_next = 1'b0;
                    status_frame_length_next = length_min;
                    s_axis_tready_next = m_axis_tready_int_early && status_ready;
                    m_axis_tkeep_int = ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-short_counter_reg);
                    m_axis_tlast_int = 1'b1;
                    frame_ptr_next = 16'd0;
                    short_counter_next = length_min;
                    long_counter_next = length_max;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_PAD;
                end
            end else begin
                state_next = STATE_PAD;
            end
        end
        STATE_TRUNCATE: begin
            // drop after maximum length
            s_axis_tready_next = m_axis_tready_int_early;

            m_axis_tdata_int = last_word_data_reg;
            m_axis_tkeep_int = last_word_keep_reg;
            m_axis_tvalid_int = s_axis_tvalid && s_axis_tlast;
            m_axis_tlast_int = s_axis_tlast;
            m_axis_tid_int = last_word_id_reg;
            m_axis_tdest_int = last_word_dest_reg;
            m_axis_tuser_int = s_axis_tuser;

            if (s_axis_tready && s_axis_tvalid) begin
                word_cnt = 0;
                for (i = 0; i <= KEEP_WIDTH; i = i + 1) begin
                    //bit_cnt = bit_cnt + monitor_axis_tkeep[i];
                    if (s_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) word_cnt = i;
                end
                frame_ptr_next = frame_ptr_reg+KEEP_WIDTH;

                if (s_axis_tlast) begin
                    status_valid_next = 1'b1;
                    status_frame_pad_next = 1'b0;
                    status_frame_truncate_next = 1'b1;
                    status_frame_length_next = length_max;
                    status_frame_original_length_next = frame_ptr_reg+word_cnt;
                    s_axis_tready_next = m_axis_tready_int_early && status_ready;
                    frame_ptr_next = 16'd0;
                    short_counter_next = length_min;
                    long_counter_next = length_max;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_TRUNCATE;
                end
            end else begin
                state_next = STATE_TRUNCATE;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 16'd0;
        short_counter_reg <= 16'd0;
        long_counter_reg <= 16'd0;
        s_axis_tready_reg <= 1'b0;
        status_valid_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        short_counter_reg <= short_counter_next;
        long_counter_reg <= long_counter_next;

        s_axis_tready_reg <= s_axis_tready_next;

        status_valid_reg <= status_valid_next;
    end

    status_frame_pad_reg <= status_frame_pad_next;
    status_frame_truncate_reg <= status_frame_truncate_next;
    status_frame_length_reg <= status_frame_length_next;
    status_frame_original_length_reg <= status_frame_original_length_next;

    if (store_last_word) begin
        last_word_data_reg <= m_axis_tdata_int;
        last_word_keep_reg <= m_axis_tkeep_int;
        last_word_id_reg   <= m_axis_tid_int;
        last_word_dest_reg <= m_axis_tdest_int;
        last_word_user_reg <= m_axis_tuser_int;
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
