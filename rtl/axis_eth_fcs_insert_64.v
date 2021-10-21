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
 * AXI4-Stream Ethernet FCS inserter (64 bit datapath)
 */
module axis_eth_fcs_insert_64 #
(
    parameter ENABLE_PADDING = 0,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [63:0] s_axis_tdata,
    input  wire [7:0]  s_axis_tkeep,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire        s_axis_tuser,
    
    /*
     * AXI output
     */
    output wire [63:0] m_axis_tdata,
    output wire [7:0]  m_axis_tkeep,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast,
    output wire        m_axis_tuser,

    /*
     * Status
     */
    output wire        busy
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1,
    STATE_PAD = 2'd2,
    STATE_FCS = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [63:0] s_axis_tdata_masked;

reg [63:0] fcs_s_tdata;
reg [7:0]  fcs_s_tkeep;

reg [63:0] fcs_m_tdata_0;
reg [63:0] fcs_m_tdata_1;
reg [7:0] fcs_m_tkeep_0;
reg [7:0] fcs_m_tkeep_1;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [63:0] last_cycle_tdata_reg = 64'd0, last_cycle_tdata_next;
reg [7:0] last_cycle_tkeep_reg = 8'd0, last_cycle_tkeep_next;

reg busy_reg = 1'b0;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

// internal datapath
reg [63:0] m_axis_tdata_int;
reg [7:0]  m_axis_tkeep_int;
reg        m_axis_tvalid_int;
reg        m_axis_tready_int_reg = 1'b0;
reg        m_axis_tlast_int;
reg        m_axis_tuser_int;
wire       m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg;

assign busy = busy_reg;

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(8),
    .STYLE("AUTO")
)
eth_crc_8 (
    .data_in(fcs_s_tdata[7:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next0)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(16),
    .STYLE("AUTO")
)
eth_crc_16 (
    .data_in(fcs_s_tdata[15:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next1)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(24),
    .STYLE("AUTO")
)
eth_crc_24 (
    .data_in(fcs_s_tdata[23:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next2)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(32),
    .STYLE("AUTO")
)
eth_crc_32 (
    .data_in(fcs_s_tdata[31:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next3)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(40),
    .STYLE("AUTO")
)
eth_crc_40 (
    .data_in(fcs_s_tdata[39:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next4)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(48),
    .STYLE("AUTO")
)
eth_crc_48 (
    .data_in(fcs_s_tdata[47:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next5)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(56),
    .STYLE("AUTO")
)
eth_crc_56 (
    .data_in(fcs_s_tdata[55:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next6)
);

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(64),
    .STYLE("AUTO")
)
eth_crc_64 (
    .data_in(fcs_s_tdata[63:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next7)
);

function [3:0] keep2count;
    input [7:0] k;
    casez (k)
        8'bzzzzzzz0: keep2count = 4'd0;
        8'bzzzzzz01: keep2count = 4'd1;
        8'bzzzzz011: keep2count = 4'd2;
        8'bzzzz0111: keep2count = 4'd3;
        8'bzzz01111: keep2count = 4'd4;
        8'bzz011111: keep2count = 4'd5;
        8'bz0111111: keep2count = 4'd6;
        8'b01111111: keep2count = 4'd7;
        8'b11111111: keep2count = 4'd8;
    endcase
endfunction

function [7:0] count2keep;
    input [3:0] k;
    case (k)
        4'd0: count2keep = 8'b00000000;
        4'd1: count2keep = 8'b00000001;
        4'd2: count2keep = 8'b00000011;
        4'd3: count2keep = 8'b00000111;
        4'd4: count2keep = 8'b00001111;
        4'd5: count2keep = 8'b00011111;
        4'd6: count2keep = 8'b00111111;
        4'd7: count2keep = 8'b01111111;
        4'd8: count2keep = 8'b11111111;
    endcase
endfunction

// Mask input data
integer j;

always @* begin
    for (j = 0; j < 8; j = j + 1) begin
        s_axis_tdata_masked[j*8 +: 8] = s_axis_tkeep[j] ? s_axis_tdata[j*8 +: 8] : 8'd0;
    end
end

// FCS cycle calculation
always @* begin
    casez (fcs_s_tkeep)
        8'bzzzzzz01: begin
            fcs_m_tdata_0 = {24'd0, ~crc_next0[31:0], fcs_s_tdata[7:0]};
            fcs_m_tdata_1 = 64'd0;
            fcs_m_tkeep_0 = 8'b00011111;
            fcs_m_tkeep_1 = 8'b00000000;
        end
        8'bzzzzz011: begin
            fcs_m_tdata_0 = {16'd0, ~crc_next1[31:0], fcs_s_tdata[15:0]};
            fcs_m_tdata_1 = 64'd0;
            fcs_m_tkeep_0 = 8'b00111111;
            fcs_m_tkeep_1 = 8'b00000000;
        end
        8'bzzzz0111: begin
            fcs_m_tdata_0 = {8'd0, ~crc_next2[31:0], fcs_s_tdata[23:0]};
            fcs_m_tdata_1 = 64'd0;
            fcs_m_tkeep_0 = 8'b01111111;
            fcs_m_tkeep_1 = 8'b00000000;
        end
        8'bzzz01111: begin
            fcs_m_tdata_0 = {~crc_next3[31:0], fcs_s_tdata[31:0]};
            fcs_m_tdata_1 = 64'd0;
            fcs_m_tkeep_0 = 8'b11111111;
            fcs_m_tkeep_1 = 8'b00000000;
        end
        8'bzz011111: begin
            fcs_m_tdata_0 = {~crc_next4[23:0], fcs_s_tdata[39:0]};
            fcs_m_tdata_1 = {56'd0, ~crc_next4[31:24]};
            fcs_m_tkeep_0 = 8'b11111111;
            fcs_m_tkeep_1 = 8'b00000001;
        end
        8'bz0111111: begin
            fcs_m_tdata_0 = {~crc_next5[15:0], fcs_s_tdata[47:0]};
            fcs_m_tdata_1 = {48'd0, ~crc_next5[31:16]};
            fcs_m_tkeep_0 = 8'b11111111;
            fcs_m_tkeep_1 = 8'b00000011;
        end
        8'b01111111: begin
            fcs_m_tdata_0 = {~crc_next6[7:0], fcs_s_tdata[55:0]};
            fcs_m_tdata_1 = {40'd0, ~crc_next6[31:8]};
            fcs_m_tkeep_0 = 8'b11111111;
            fcs_m_tkeep_1 = 8'b00000111;
        end
        8'b11111111: begin
            fcs_m_tdata_0 = fcs_s_tdata;
            fcs_m_tdata_1 = {32'd0, ~crc_next7[31:0]};
            fcs_m_tkeep_0 = 8'b11111111;
            fcs_m_tkeep_1 = 8'b00001111;
        end
        default: begin
            fcs_m_tdata_0 = 64'd0;
            fcs_m_tdata_1 = 64'd0;
            fcs_m_tkeep_0 = 8'd0;
            fcs_m_tkeep_1 = 8'd0;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    last_cycle_tdata_next = last_cycle_tdata_reg;
    last_cycle_tkeep_next = last_cycle_tkeep_reg;

    s_axis_tready_next = 1'b0;

    fcs_s_tdata = 64'd0;
    fcs_s_tkeep = 8'd0;

    m_axis_tdata_int = 64'd0;
    m_axis_tkeep_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            s_axis_tready_next = m_axis_tready_int_early;
            frame_ptr_next = 16'd0;
            reset_crc = 1'b1;

            m_axis_tdata_int = s_axis_tdata_masked;
            m_axis_tkeep_int = s_axis_tkeep;
            m_axis_tvalid_int = s_axis_tvalid;
            m_axis_tlast_int = 1'b0;
            m_axis_tuser_int = 1'b0;

            fcs_s_tdata = s_axis_tdata_masked;
            fcs_s_tkeep = s_axis_tkeep;

            if (s_axis_tready && s_axis_tvalid) begin
                reset_crc = 1'b0;
                update_crc = 1'b1;
                frame_ptr_next = keep2count(s_axis_tkeep);
                if (s_axis_tlast) begin
                    if (s_axis_tuser) begin
                        m_axis_tlast_int = 1'b1;
                        m_axis_tuser_int = 1'b1;
                        reset_crc = 1'b1;
                        frame_ptr_next = 16'd0;
                        state_next = STATE_IDLE;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                            m_axis_tkeep_int = 8'hff;
                            fcs_s_tkeep = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 16'd8;

                            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                                s_axis_tready_next = 1'b0;
                                state_next = STATE_PAD;
                            end else begin
                                m_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                                fcs_s_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                                m_axis_tdata_int = fcs_m_tdata_0;
                                last_cycle_tdata_next = fcs_m_tdata_1;
                                m_axis_tkeep_int = fcs_m_tkeep_0;
                                last_cycle_tkeep_next = fcs_m_tkeep_1;

                                reset_crc = 1'b1;

                                if (fcs_m_tkeep_1 == 8'd0) begin
                                    m_axis_tlast_int = 1'b1;
                                    s_axis_tready_next = m_axis_tready_int_early;
                                    frame_ptr_next = 1'b0;
                                    state_next = STATE_IDLE;
                                end else begin
                                    s_axis_tready_next = 1'b0;
                                    state_next = STATE_FCS;
                                end
                            end
                        end else begin
                            m_axis_tdata_int = fcs_m_tdata_0;
                            last_cycle_tdata_next = fcs_m_tdata_1;
                            m_axis_tkeep_int = fcs_m_tkeep_0;
                            last_cycle_tkeep_next = fcs_m_tkeep_1;

                            reset_crc = 1'b1;

                            if (fcs_m_tkeep_1 == 8'd0) begin
                                m_axis_tlast_int = 1'b1;
                                s_axis_tready_next = m_axis_tready_int_early;
                                frame_ptr_next = 16'd0;
                                state_next = STATE_IDLE;
                            end else begin
                                s_axis_tready_next = 1'b0;
                                state_next = STATE_FCS;
                            end
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            s_axis_tready_next = m_axis_tready_int_early;

            m_axis_tdata_int = s_axis_tdata_masked;
            m_axis_tkeep_int = s_axis_tkeep;
            m_axis_tvalid_int = s_axis_tvalid;
            m_axis_tlast_int = 1'b0;
            m_axis_tuser_int = 1'b0;

            fcs_s_tdata = s_axis_tdata_masked;
            fcs_s_tkeep = s_axis_tkeep;

            if (s_axis_tready && s_axis_tvalid) begin
                update_crc = 1'b1;
                frame_ptr_next = frame_ptr_reg + keep2count(s_axis_tkeep);
                if (s_axis_tlast) begin
                    if (s_axis_tuser) begin
                        m_axis_tlast_int = 1'b1;
                        m_axis_tuser_int = 1'b1;
                        reset_crc = 1'b1;
                        frame_ptr_next = 16'd0;
                        state_next = STATE_IDLE;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                            m_axis_tkeep_int = 8'hff;
                            fcs_s_tkeep = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 16'd8;

                            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                                s_axis_tready_next = 1'b0;
                                state_next = STATE_PAD;
                            end else begin
                                m_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                                fcs_s_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                                m_axis_tdata_int = fcs_m_tdata_0;
                                last_cycle_tdata_next = fcs_m_tdata_1;
                                m_axis_tkeep_int = fcs_m_tkeep_0;
                                last_cycle_tkeep_next = fcs_m_tkeep_1;

                                reset_crc = 1'b1;

                                if (fcs_m_tkeep_1 == 8'd0) begin
                                    m_axis_tlast_int = 1'b1;
                                    s_axis_tready_next = m_axis_tready_int_early;
                                    frame_ptr_next = 16'd0;
                                    state_next = STATE_IDLE;
                                end else begin
                                    s_axis_tready_next = 1'b0;
                                    state_next = STATE_FCS;
                                end
                            end
                        end else begin
                            m_axis_tdata_int = fcs_m_tdata_0;
                            last_cycle_tdata_next = fcs_m_tdata_1;
                            m_axis_tkeep_int = fcs_m_tkeep_0;
                            last_cycle_tkeep_next = fcs_m_tkeep_1;

                            reset_crc = 1'b1;

                            if (fcs_m_tkeep_1 == 8'd0) begin
                                m_axis_tlast_int = 1'b1;
                                s_axis_tready_next = m_axis_tready_int_early;
                                frame_ptr_next = 16'd0;
                                state_next = STATE_IDLE;
                            end else begin
                                s_axis_tready_next = 1'b0;
                                state_next = STATE_FCS;
                            end
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_PAD: begin
            s_axis_tready_next = 1'b0;

            m_axis_tdata_int = 64'd0;
            m_axis_tkeep_int = 8'hff;
            m_axis_tvalid_int = 1'b1;
            m_axis_tlast_int = 1'b0;
            m_axis_tuser_int = 1'b0;

            fcs_s_tdata = 64'd0;
            fcs_s_tkeep = 8'hff;

            if (m_axis_tready_int_reg) begin
                update_crc = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd8;

                if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                    state_next = STATE_PAD;
                end else begin
                    m_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                    fcs_s_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                    m_axis_tdata_int = fcs_m_tdata_0;
                    last_cycle_tdata_next = fcs_m_tdata_1;
                    m_axis_tkeep_int = fcs_m_tkeep_0;
                    last_cycle_tkeep_next = fcs_m_tkeep_1;

                    reset_crc = 1'b1;

                    if (fcs_m_tkeep_1 == 8'd0) begin
                        m_axis_tlast_int = 1'b1;
                        s_axis_tready_next = m_axis_tready_int_early;
                        frame_ptr_next = 16'd0;
                        state_next = STATE_IDLE;
                    end else begin
                        s_axis_tready_next = 1'b0;
                        state_next = STATE_FCS;
                    end
                end
            end else begin
                state_next = STATE_PAD;
            end
        end
        STATE_FCS: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            m_axis_tdata_int = last_cycle_tdata_reg;
            m_axis_tkeep_int = last_cycle_tkeep_reg;
            m_axis_tvalid_int = 1'b1;
            m_axis_tlast_int = 1'b1;
            m_axis_tuser_int = 1'b0;

            if (m_axis_tready_int_reg) begin
                reset_crc = 1'b1;
                s_axis_tready_next = m_axis_tready_int_early;
                frame_ptr_next = 1'b0;
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_FCS;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        
        frame_ptr_reg <= 1'b0;

        s_axis_tready_reg <= 1'b0;

        busy_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        s_axis_tready_reg <= s_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next7;
        end
    end

    last_cycle_tdata_reg <= last_cycle_tdata_next;
    last_cycle_tkeep_reg <= last_cycle_tkeep_next;
end

// output datapath logic
reg [63:0] m_axis_tdata_reg = 64'd0;
reg [7:0]  m_axis_tkeep_reg = 8'd0;
reg        m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg        m_axis_tlast_reg = 1'b0;
reg        m_axis_tuser_reg = 1'b0;

reg [63:0] temp_m_axis_tdata_reg = 64'd0;
reg [7:0]  temp_m_axis_tkeep_reg = 8'd0;
reg        temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg        temp_m_axis_tlast_reg = 1'b0;
reg        temp_m_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = m_axis_tkeep_reg;
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
        m_axis_tkeep_reg <= m_axis_tkeep_int;
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end
end

endmodule

`resetall
