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
 * AXI4-Stream statistics counter
 */
module axis_stat_counter #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 64,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Prepend data with tag
    parameter TAG_ENABLE = 1,
    // Tag field width
    parameter TAG_WIDTH = 16,
    // Count cycles
    parameter TICK_COUNT_ENABLE = 1,
    // Cycle counter width
    parameter TICK_COUNT_WIDTH = 32,
    // Count bytes
    parameter BYTE_COUNT_ENABLE = 1,
    // Byte counter width
    parameter BYTE_COUNT_WIDTH = 32,
    // Count frames
    parameter FRAME_COUNT_ENABLE = 1,
    // Frame counter width
    parameter FRAME_COUNT_WIDTH = 32
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI monitor
     */
    input  wire [KEEP_WIDTH-1:0]  monitor_axis_tkeep,
    input  wire                   monitor_axis_tvalid,
    input  wire                   monitor_axis_tready,
    input  wire                   monitor_axis_tlast,

    /*
     * AXI status data output
     */
    output wire [7:0]             m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire                   m_axis_tuser,

    /*
     * Configuration
     */
    input  wire [TAG_WIDTH-1:0]   tag,
    input  wire                   trigger,

    /*
     * Status
     */
    output wire                   busy
);

localparam TAG_BYTE_WIDTH = (TAG_WIDTH + 7) / 8;
localparam TICK_COUNT_BYTE_WIDTH = (TICK_COUNT_WIDTH + 7) / 8;
localparam BYTE_COUNT_BYTE_WIDTH = (BYTE_COUNT_WIDTH + 7) / 8;
localparam FRAME_COUNT_BYTE_WIDTH = (FRAME_COUNT_WIDTH + 7) / 8;
localparam TOTAL_LENGTH = TAG_BYTE_WIDTH + TICK_COUNT_BYTE_WIDTH + BYTE_COUNT_BYTE_WIDTH + FRAME_COUNT_BYTE_WIDTH;

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_OUTPUT_DATA = 2'd1;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [TICK_COUNT_WIDTH-1:0] tick_count_reg = 0, tick_count_next;
reg [BYTE_COUNT_WIDTH-1:0] byte_count_reg = 0, byte_count_next;
reg [FRAME_COUNT_WIDTH-1:0] frame_count_reg = 0, frame_count_next;
reg frame_reg = 1'b0, frame_next;

reg store_output;
reg [$clog2(TOTAL_LENGTH)-1:0] frame_ptr_reg = 0, frame_ptr_next;

reg [TICK_COUNT_WIDTH-1:0] tick_count_output_reg = 0;
reg [BYTE_COUNT_WIDTH-1:0] byte_count_output_reg = 0;
reg [FRAME_COUNT_WIDTH-1:0] frame_count_output_reg = 0;

reg busy_reg = 1'b0;

// internal datapath
reg [7:0]  m_axis_tdata_int;
reg        m_axis_tvalid_int;
reg        m_axis_tready_int_reg = 1'b0;
reg        m_axis_tlast_int;
reg        m_axis_tuser_int;
wire       m_axis_tready_int_early;

assign busy = busy_reg;

integer offset, i, bit_cnt;

always @* begin
    state_next = STATE_IDLE;

    tick_count_next = tick_count_reg;
    byte_count_next = byte_count_reg;
    frame_count_next = frame_count_reg;
    frame_next = frame_reg;

    m_axis_tdata_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    store_output = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    // data readout

    case (state_reg)
        STATE_IDLE: begin
            if (trigger) begin
                store_output = 1'b1;
                tick_count_next = 0;
                byte_count_next = 0;
                frame_count_next = 0;
                frame_ptr_next = 0;

                if (m_axis_tready_int_reg) begin
                    frame_ptr_next = 1;
                    if (TAG_ENABLE) begin
                        m_axis_tdata_int = tag[(TAG_BYTE_WIDTH-1)*8 +: 8];
                    end else if (TICK_COUNT_ENABLE) begin
                        m_axis_tdata_int = tick_count_reg[(TICK_COUNT_BYTE_WIDTH-1)*8 +: 8];
                    end else if (BYTE_COUNT_ENABLE) begin
                        m_axis_tdata_int = byte_count_reg[(BYTE_COUNT_BYTE_WIDTH-1)*8 +: 8];
                    end else if (FRAME_COUNT_ENABLE) begin
                        m_axis_tdata_int = frame_count_reg[(FRAME_COUNT_BYTE_WIDTH-1)*8 +: 8];
                    end
                    m_axis_tvalid_int = 1'b1;
                end

                state_next = STATE_OUTPUT_DATA;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_OUTPUT_DATA: begin
            if (m_axis_tready_int_reg) begin
                state_next = STATE_OUTPUT_DATA;
                frame_ptr_next = frame_ptr_reg + 1;
                m_axis_tvalid_int = 1'b1;

                offset = 0;
                if (TAG_ENABLE) begin
                    for (i = TAG_BYTE_WIDTH-1; i >= 0; i = i - 1) begin
                        if (frame_ptr_reg == offset) begin
                            m_axis_tdata_int = tag[i*8 +: 8];
                        end
                        offset = offset + 1;
                    end
                end
                if (TICK_COUNT_ENABLE) begin
                    for (i = TICK_COUNT_BYTE_WIDTH-1; i >= 0; i = i - 1) begin
                        if (frame_ptr_reg == offset) begin
                            m_axis_tdata_int = tick_count_output_reg[i*8 +: 8];
                        end
                        offset = offset + 1;
                    end
                end
                if (BYTE_COUNT_ENABLE) begin
                    for (i = BYTE_COUNT_BYTE_WIDTH-1; i >= 0; i = i - 1) begin
                        if (frame_ptr_reg == offset) begin
                            m_axis_tdata_int = byte_count_output_reg[i*8 +: 8];
                        end
                        offset = offset + 1;
                    end
                end
                if (FRAME_COUNT_ENABLE) begin
                    for (i = FRAME_COUNT_BYTE_WIDTH-1; i >= 0; i = i - 1) begin
                        if (frame_ptr_reg == offset) begin
                            m_axis_tdata_int = frame_count_output_reg[i*8 +: 8];
                        end
                        offset = offset + 1;
                    end
                end
                if (frame_ptr_reg == offset-1) begin
                    m_axis_tlast_int = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_OUTPUT_DATA;
            end
        end
    endcase

    // stats collection

    // increment tick count by number of words that can be transferred per cycle
    tick_count_next = tick_count_next + (KEEP_ENABLE ? KEEP_WIDTH : 1);

    if (monitor_axis_tready && monitor_axis_tvalid) begin
        // valid transfer cycle

        // increment byte count by number of words transferred
        if (KEEP_ENABLE) begin
            bit_cnt = 0;
            for (i = 0; i <= KEEP_WIDTH; i = i + 1) begin
                //bit_cnt = bit_cnt + monitor_axis_tkeep[i];
                if (monitor_axis_tkeep == ({KEEP_WIDTH{1'b1}}) >> (KEEP_WIDTH-i)) bit_cnt = i;
            end
            byte_count_next = byte_count_next + bit_cnt;
        end else begin
            byte_count_next = byte_count_next + 1;
        end

        // count frames
        if (monitor_axis_tlast) begin
            // end of frame
            frame_next = 1'b0;
        end else if (!frame_reg) begin
            // first word after end of frame
            frame_count_next = frame_count_next + 1;
            frame_next = 1'b1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        tick_count_reg <= 0;
        byte_count_reg <= 0;
        frame_count_reg <= 0;
        frame_reg <= 1'b0;
        frame_ptr_reg <= 0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        tick_count_reg <= tick_count_next;
        byte_count_reg <= byte_count_next;
        frame_count_reg <= frame_count_next;
        frame_reg <= frame_next;
        frame_ptr_reg <= frame_ptr_next;

        busy_reg <= state_next != STATE_IDLE;
    end

    if (store_output) begin
        tick_count_output_reg <= tick_count_reg;
        byte_count_output_reg <= byte_count_reg;
        frame_count_output_reg <= frame_count_reg;
    end
end

// output datapath logic
reg [7:0] m_axis_tdata_reg = 8'd0;
reg       m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg       m_axis_tlast_reg = 1'b0;
reg       m_axis_tuser_reg = 1'b0;

reg [7:0] temp_m_axis_tdata_reg = 8'd0;
reg       temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg       temp_m_axis_tlast_reg = 1'b0;
reg       temp_m_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tuser = m_axis_tuser_reg;

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
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end
end

endmodule

`resetall
