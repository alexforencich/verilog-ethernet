/*

Copyright (c) 2019 Alex Forencich

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
 * AXI4-Stream 10GBASE-R frame transmitter (AXI in, 10GBASE-R out)
 */
module axis_baser_tx_64 #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2,
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter PTP_PERIOD_NS = 4'h6,
    parameter PTP_PERIOD_FNS = 16'h6666,
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_WIDTH = 96,
    parameter PTP_TAG_ENABLE = PTP_TS_ENABLE,
    parameter PTP_TAG_WIDTH = 16,
    parameter USER_WIDTH = (PTP_TAG_ENABLE ? PTP_TAG_WIDTH : 0) + 1
)
(
    input  wire                      clk,
    input  wire                      rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]     s_axis_tkeep,
    input  wire                      s_axis_tvalid,
    output wire                      s_axis_tready,
    input  wire                      s_axis_tlast,
    input  wire [USER_WIDTH-1:0]     s_axis_tuser,

    /*
     * 10GBASE-R encoded interface
     */
    output wire [DATA_WIDTH-1:0]     encoded_tx_data,
    output wire [HDR_WIDTH-1:0]      encoded_tx_hdr,

    /*
     * PTP
     */
    input  wire [PTP_TS_WIDTH-1:0]   ptp_ts,
    output wire [PTP_TS_WIDTH-1:0]   m_axis_ptp_ts,
    output wire [PTP_TAG_WIDTH-1:0]  m_axis_ptp_ts_tag,
    output wire                      m_axis_ptp_ts_valid,

    /*
     * Configuration
     */
    input  wire [7:0]                ifg_delay,

    /*
     * Status
     */
    output wire [1:0]                start_packet,
    output wire                      error_underflow
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (KEEP_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end

    if (HDR_WIDTH != 2) begin
        $error("Error: HDR_WIDTH must be 2");
        $finish;
    end
end

localparam MIN_FL_NOCRC = MIN_FRAME_LENGTH-4;
localparam MIN_FL_NOCRC_MS = MIN_FL_NOCRC & 16'hfff8;
localparam MIN_FL_NOCRC_LS = MIN_FL_NOCRC & 16'h0007;

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [6:0]
    CTRL_IDLE  = 7'h00,
    CTRL_LPI   = 7'h06,
    CTRL_ERROR = 7'h1e,
    CTRL_RES_0 = 7'h2d,
    CTRL_RES_1 = 7'h33,
    CTRL_RES_2 = 7'h4b,
    CTRL_RES_3 = 7'h55,
    CTRL_RES_4 = 7'h66,
    CTRL_RES_5 = 7'h78;

localparam [3:0]
    O_SEQ_OS = 4'h0,
    O_SIG_OS = 4'hf;

localparam [1:0]
    SYNC_DATA = 2'b10,
    SYNC_CTRL = 2'b01;

localparam [7:0]
    BLOCK_TYPE_CTRL     = 8'h1e, // C7 C6 C5 C4 C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_4     = 8'h2d, // D7 D6 D5 O4 C3 C2 C1 C0 BT
    BLOCK_TYPE_START_4  = 8'h33, // D7 D6 D5    C3 C2 C1 C0 BT
    BLOCK_TYPE_OS_START = 8'h66, // D7 D6 D5    O0 D3 D2 D1 BT
    BLOCK_TYPE_OS_04    = 8'h55, // D7 D6 D5 O4 O0 D3 D2 D1 BT
    BLOCK_TYPE_START_0  = 8'h78, // D7 D6 D5 D4 D3 D2 D1    BT
    BLOCK_TYPE_OS_0     = 8'h4b, // C7 C6 C5 C4 O0 D3 D2 D1 BT
    BLOCK_TYPE_TERM_0   = 8'h87, // C7 C6 C5 C4 C3 C2 C1    BT
    BLOCK_TYPE_TERM_1   = 8'h99, // C7 C6 C5 C4 C3 C2    D0 BT
    BLOCK_TYPE_TERM_2   = 8'haa, // C7 C6 C5 C4 C3    D1 D0 BT
    BLOCK_TYPE_TERM_3   = 8'hb4, // C7 C6 C5 C4    D2 D1 D0 BT
    BLOCK_TYPE_TERM_4   = 8'hcc, // C7 C6 C5    D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_5   = 8'hd2, // C7 C6    D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_6   = 8'he1, // C7    D5 D4 D3 D2 D1 D0 BT
    BLOCK_TYPE_TERM_7   = 8'hff; //    D6 D5 D4 D3 D2 D1 D0 BT

localparam [3:0]
    OUTPUT_TYPE_IDLE = 4'd0,
    OUTPUT_TYPE_ERROR = 4'd1,
    OUTPUT_TYPE_START_0 = 4'd2,
    OUTPUT_TYPE_START_4 = 4'd3,
    OUTPUT_TYPE_DATA = 4'd4,
    OUTPUT_TYPE_TERM_0 = 4'd8,
    OUTPUT_TYPE_TERM_1 = 4'd9,
    OUTPUT_TYPE_TERM_2 = 4'd10,
    OUTPUT_TYPE_TERM_3 = 4'd11,
    OUTPUT_TYPE_TERM_4 = 4'd12,
    OUTPUT_TYPE_TERM_5 = 4'd13,
    OUTPUT_TYPE_TERM_6 = 4'd14,
    OUTPUT_TYPE_TERM_7 = 4'd15;

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PAYLOAD = 3'd1,
    STATE_PAD = 3'd2,
    STATE_FCS_1 = 3'd3,
    STATE_FCS_2 = 3'd4,
    STATE_IFG = 3'd5,
    STATE_WAIT_END = 3'd6;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg swap_lanes;
reg unswap_lanes;

reg lanes_swapped = 1'b0;
reg [31:0] swap_data = 32'd0;

reg delay_type_valid = 1'b0;
reg [3:0] delay_type = OUTPUT_TYPE_IDLE;

reg [DATA_WIDTH-1:0] s_axis_tdata_masked;

reg [DATA_WIDTH-1:0] s_tdata_reg = {DATA_WIDTH{1'b0}}, s_tdata_next;
reg [7:0]  s_tkeep_reg = 8'd0, s_tkeep_next;

reg [DATA_WIDTH-1:0] fcs_output_data_0;
reg [DATA_WIDTH-1:0] fcs_output_data_1;
reg [3:0] fcs_output_type_0;
reg [3:0] fcs_output_type_1;

reg [7:0] ifg_offset;

reg extra_cycle;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [7:0] ifg_count_reg = 8'd0, ifg_count_next;
reg [1:0] deficit_idle_count_reg = 2'd0, deficit_idle_count_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [PTP_TS_WIDTH-1:0] m_axis_ptp_ts_reg = 0, m_axis_ptp_ts_next;
reg [PTP_TAG_WIDTH-1:0] m_axis_ptp_ts_tag_reg = 0, m_axis_ptp_ts_tag_next;
reg m_axis_ptp_ts_valid_reg = 1'b0, m_axis_ptp_ts_valid_next;
reg m_axis_ptp_ts_valid_int_reg = 1'b0, m_axis_ptp_ts_valid_int_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

reg [DATA_WIDTH-1:0] encoded_tx_data_reg = {{8{CTRL_IDLE}}, BLOCK_TYPE_CTRL};
reg [HDR_WIDTH-1:0] encoded_tx_hdr_reg = SYNC_CTRL;

reg [DATA_WIDTH-1:0] output_data_reg = {DATA_WIDTH{1'b0}}, output_data_next;
reg [3:0] output_type_reg = OUTPUT_TYPE_IDLE, output_type_next;

reg [1:0] start_packet_reg = 2'b00, start_packet_next;
reg error_underflow_reg = 1'b0, error_underflow_next;

assign s_axis_tready = s_axis_tready_reg;

assign encoded_tx_data = encoded_tx_data_reg;
assign encoded_tx_hdr = encoded_tx_hdr_reg;

assign m_axis_ptp_ts = PTP_TS_ENABLE ? m_axis_ptp_ts_reg : 0;
assign m_axis_ptp_ts_tag = PTP_TAG_ENABLE ? m_axis_ptp_ts_tag_reg : 0;
assign m_axis_ptp_ts_valid = PTP_TS_ENABLE || PTP_TAG_ENABLE ? m_axis_ptp_ts_valid_reg : 1'b0;

assign start_packet = start_packet_reg;
assign error_underflow = error_underflow_reg;

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
    .data_in(s_tdata_reg[7:0]),
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
    .data_in(s_tdata_reg[15:0]),
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
    .data_in(s_tdata_reg[23:0]),
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
    .data_in(s_tdata_reg[31:0]),
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
    .data_in(s_tdata_reg[39:0]),
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
    .data_in(s_tdata_reg[47:0]),
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
    .data_in(s_tdata_reg[55:0]),
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
    .data_in(s_tdata_reg[63:0]),
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

// Mask input data
integer j;

always @* begin
    for (j = 0; j < 8; j = j + 1) begin
        s_axis_tdata_masked[j*8 +: 8] = s_axis_tkeep[j] ? s_axis_tdata[j*8 +: 8] : 8'd0;
    end
end

// FCS cycle calculation
always @* begin
    casez (s_tkeep_reg)
        8'bzzzzzz01: begin
            fcs_output_data_0 = {24'd0, ~crc_next0[31:0], s_tdata_reg[7:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_5;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd3;
            extra_cycle = 1'b0;
        end
        8'bzzzzz011: begin
            fcs_output_data_0 = {16'd0, ~crc_next1[31:0], s_tdata_reg[15:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_6;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd2;
            extra_cycle = 1'b0;
        end
        8'bzzzz0111: begin
            fcs_output_data_0 = {8'd0, ~crc_next2[31:0], s_tdata_reg[23:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_7;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd1;
            extra_cycle = 1'b0;
        end
        8'bzzz01111: begin
            fcs_output_data_0 = {~crc_next3[31:0], s_tdata_reg[31:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_0;
            ifg_offset = 8'd8;
            extra_cycle = 1'b1;
        end
        8'bzz011111: begin
            fcs_output_data_0 = {~crc_next4[23:0], s_tdata_reg[39:0]};
            fcs_output_data_1 = {56'd0, ~crc_next4[31:24]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_1;
            ifg_offset = 8'd7;
            extra_cycle = 1'b1;
        end
        8'bz0111111: begin
            fcs_output_data_0 = {~crc_next5[15:0], s_tdata_reg[47:0]};
            fcs_output_data_1 = {48'd0, ~crc_next5[31:16]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_2;
            ifg_offset = 8'd6;
            extra_cycle = 1'b1;
        end
        8'b01111111: begin
            fcs_output_data_0 = {~crc_next6[7:0], s_tdata_reg[55:0]};
            fcs_output_data_1 = {40'd0, ~crc_next6[31:8]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_3;
            ifg_offset = 8'd5;
            extra_cycle = 1'b1;
        end
        8'b11111111: begin
            fcs_output_data_0 = s_tdata_reg;
            fcs_output_data_1 = {32'd0, ~crc_next7[31:0]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_4;
            ifg_offset = 8'd4;
            extra_cycle = 1'b1;
        end
        default: begin
            fcs_output_data_0 = 64'd0;
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_ERROR;
            fcs_output_type_1 = OUTPUT_TYPE_ERROR;
            ifg_offset = 8'd0;
            extra_cycle = 1'b1;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    swap_lanes = 1'b0;
    unswap_lanes = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    ifg_count_next = ifg_count_reg;
    deficit_idle_count_next = deficit_idle_count_reg;

    s_axis_tready_next = 1'b0;

    s_tdata_next = s_tdata_reg;
    s_tkeep_next = s_tkeep_reg;

    m_axis_ptp_ts_next = m_axis_ptp_ts_reg;
    m_axis_ptp_ts_tag_next = m_axis_ptp_ts_tag_reg;
    m_axis_ptp_ts_valid_next = 1'b0;
    m_axis_ptp_ts_valid_int_next = 1'b0;

    output_data_next = s_tdata_reg;
    output_type_next = OUTPUT_TYPE_IDLE;

    start_packet_next = 2'b00;
    error_underflow_next = 1'b0;

    if (m_axis_ptp_ts_valid_int_reg) begin
        m_axis_ptp_ts_valid_next = 1'b1;
        if (PTP_TS_WIDTH == 96 && $signed({1'b0, m_axis_ptp_ts_reg[45:16]}) - $signed(31'd1000000000) > 0) begin
            // ns field rollover
            m_axis_ptp_ts_next[45:16] = $signed({1'b0, m_axis_ptp_ts_reg[45:16]}) - $signed(31'd1000000000);
            m_axis_ptp_ts_next[95:48] = m_axis_ptp_ts_reg[95:48] + 1;
        end
    end

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 16'd8;
            reset_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_IDLE;

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                // XGMII start and preamble
                if (ifg_count_reg > 8'd0) begin
                    // need to send more idles - swap lanes
                    swap_lanes = 1'b1;
                    if (PTP_TS_WIDTH == 96) begin
                        m_axis_ptp_ts_next[45:0] = ptp_ts[45:0] + (((PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS) * 3) >> 1);
                        m_axis_ptp_ts_next[95:48] = ptp_ts[95:48];
                    end else begin
                        m_axis_ptp_ts_next = ptp_ts + (((PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS) * 3) >> 1);
                    end
                    m_axis_ptp_ts_tag_next = s_axis_tuser >> 1;
                    m_axis_ptp_ts_valid_int_next = 1'b1;
                    start_packet_next = 2'b10;
                end else begin
                    // no more idles - unswap
                    unswap_lanes = 1'b1;
                    if (PTP_TS_WIDTH == 96) begin
                        m_axis_ptp_ts_next[45:0] = ptp_ts[45:0] + (PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS);
                        m_axis_ptp_ts_next[95:48] = ptp_ts[95:48];
                    end else begin
                        m_axis_ptp_ts_next = ptp_ts + (PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS);
                    end
                    m_axis_ptp_ts_tag_next = s_axis_tuser >> 1;
                    m_axis_ptp_ts_valid_int_next = 1'b1;
                    start_packet_next = 2'b01;
                end
                output_data_next = {ETH_SFD, {7{ETH_PRE}}};
                output_type_next = OUTPUT_TYPE_START_0;
                s_axis_tready_next = 1'b1;
                state_next = STATE_PAYLOAD;
            end else begin
                ifg_count_next = 8'd0;
                deficit_idle_count_next = 2'd0;
                unswap_lanes = 1'b1;
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            update_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            frame_ptr_next = frame_ptr_reg + 16'd8;

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_DATA;

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                if (s_axis_tlast) begin
                    frame_ptr_next = frame_ptr_reg + keep2count(s_axis_tkeep);
                    s_axis_tready_next = 1'b0;
                    if (s_axis_tuser[0]) begin
                        output_type_next = OUTPUT_TYPE_ERROR;
                        frame_ptr_next = 16'd0;
                        ifg_count_next = 8'd8;
                        state_next = STATE_IFG;
                    end else begin
                        s_axis_tready_next = 1'b0;

                        if (ENABLE_PADDING && (frame_ptr_reg < MIN_FL_NOCRC_MS || (frame_ptr_reg == MIN_FL_NOCRC_MS && keep2count(s_axis_tkeep) < MIN_FL_NOCRC_LS))) begin
                            s_tkeep_next = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 16'd8;

                            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-8)) begin
                                state_next = STATE_PAD;
                            end else begin
                                s_tkeep_next = 8'hff >> ((8-MIN_FL_NOCRC_LS) % 8);

                                state_next = STATE_FCS_1;
                            end
                        end else begin
                            state_next = STATE_FCS_1;
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                // tvalid deassert, fail frame
                output_type_next = OUTPUT_TYPE_ERROR;
                frame_ptr_next = 16'd0;
                ifg_count_next = 8'd8;
                error_underflow_next = 1'b1;
                state_next = STATE_WAIT_END;
            end
        end
        STATE_PAD: begin
            // pad frame to MIN_FRAME_LENGTH
            s_axis_tready_next = 1'b0;

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_DATA;

            s_tdata_next = 64'd0;
            s_tkeep_next = 8'hff;

            update_crc = 1'b1;
            frame_ptr_next = frame_ptr_reg + 16'd8;

            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-8)) begin
                state_next = STATE_PAD;
            end else begin
                s_tkeep_next = 8'hff >> ((8-MIN_FL_NOCRC_LS) % 8);

                state_next = STATE_FCS_1;
            end
        end
        STATE_FCS_1: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            output_data_next = fcs_output_data_0;
            output_type_next = fcs_output_type_0;

            frame_ptr_next = 16'd0;

            ifg_count_next = (ifg_delay > 8'd12 ? ifg_delay : 8'd12) - ifg_offset + (lanes_swapped ? 8'd4 : 8'd0) + deficit_idle_count_reg;
            if (extra_cycle) begin
                state_next = STATE_FCS_2;
            end else begin
                state_next = STATE_IFG;
            end
        end
        STATE_FCS_2: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            output_data_next = fcs_output_data_1;
            output_type_next = fcs_output_type_1;

            reset_crc = 1'b1;
            frame_ptr_next = 16'd0;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_IFG: begin
            // send IFG
            if (ifg_count_reg > 8'd8) begin
                ifg_count_next = ifg_count_reg - 8'd8;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_WAIT_END: begin
            // wait for end of frame
            s_axis_tready_next = 1'b1;

            if (ifg_count_reg > 8'd4) begin
                ifg_count_next = ifg_count_reg - 8'd4;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (s_axis_tvalid) begin
                if (s_axis_tlast) begin
                    s_axis_tready_next = 1'b0;

                    if (ENABLE_DIC) begin
                        if (ifg_count_next > 8'd7) begin
                            state_next = STATE_IFG;
                        end else begin
                            if (ifg_count_next >= 8'd4) begin
                                deficit_idle_count_next = ifg_count_next - 8'd4;
                            end else begin
                                deficit_idle_count_next = ifg_count_next;
                                ifg_count_next = 8'd0;
                            end
                            s_axis_tready_next = 1'b1;
                            state_next = STATE_IDLE;
                        end
                    end else begin
                        if (ifg_count_next > 8'd4) begin
                            state_next = STATE_IFG;
                        end else begin
                            s_axis_tready_next = 1'b1;
                            state_next = STATE_IDLE;
                        end
                    end
                end else begin
                    state_next = STATE_WAIT_END;
                end
            end else begin
                state_next = STATE_WAIT_END;
            end
        end
    endcase
end

always @(posedge clk) begin
    state_reg <= state_next;

    frame_ptr_reg <= frame_ptr_next;

    ifg_count_reg <= ifg_count_next;
    deficit_idle_count_reg <= deficit_idle_count_next;

    s_tdata_reg <= s_tdata_next;
    s_tkeep_reg <= s_tkeep_next;

    s_axis_tready_reg <= s_axis_tready_next;

    m_axis_ptp_ts_reg <= m_axis_ptp_ts_next;
    m_axis_ptp_ts_tag_reg <= m_axis_ptp_ts_tag_next;
    m_axis_ptp_ts_valid_reg <= m_axis_ptp_ts_valid_next;
    m_axis_ptp_ts_valid_int_reg <= m_axis_ptp_ts_valid_int_next;

    start_packet_reg <= start_packet_next;
    error_underflow_reg <= error_underflow_next;

    delay_type_valid <= 1'b0;
    delay_type <= output_type_next ^ 4'd4;

    swap_data <= output_data_next[63:32];

    if (swap_lanes || (lanes_swapped && !unswap_lanes)) begin
        lanes_swapped <= 1'b1;
        output_data_reg <= {output_data_next[31:0], swap_data};
        if (delay_type_valid) begin
            output_type_reg <= delay_type;
        end else if (output_type_next == OUTPUT_TYPE_START_0) begin
            output_type_reg <= OUTPUT_TYPE_START_4;
        end else if (output_type_next[3]) begin
            // OUTPUT_TYPE_TERM_*
            if (output_type_next[2]) begin
                delay_type_valid <= 1'b1;
                output_type_reg <= OUTPUT_TYPE_DATA;
            end else begin
                output_type_reg <= output_type_next ^ 4'd4;
            end
        end else begin
            output_type_reg <= output_type_next;
        end
    end else begin
        lanes_swapped <= 1'b0;
        output_data_reg <= output_data_next;
        output_type_reg <= output_type_next;
    end

    case (output_type_reg)
        OUTPUT_TYPE_IDLE: begin
            encoded_tx_data_reg <= {{8{CTRL_IDLE}}, BLOCK_TYPE_CTRL};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_ERROR: begin
            encoded_tx_data_reg <= {{8{CTRL_ERROR}}, BLOCK_TYPE_CTRL};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_START_0: begin
            encoded_tx_data_reg <= {output_data_reg[63:8], BLOCK_TYPE_START_0};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_START_4: begin
            encoded_tx_data_reg <= {output_data_reg[63:40], 4'd0, {4{CTRL_IDLE}}, BLOCK_TYPE_START_4};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_DATA: begin
            encoded_tx_data_reg <= output_data_reg;
            encoded_tx_hdr_reg <= SYNC_DATA;
        end
        OUTPUT_TYPE_TERM_0: begin
            encoded_tx_data_reg <= {{7{CTRL_IDLE}}, 7'd0, BLOCK_TYPE_TERM_0};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_1: begin
            encoded_tx_data_reg <= {{6{CTRL_IDLE}}, 6'd0, output_data_reg[7:0], BLOCK_TYPE_TERM_1};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_2: begin
            encoded_tx_data_reg <= {{5{CTRL_IDLE}}, 5'd0, output_data_reg[15:0], BLOCK_TYPE_TERM_2};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_3: begin
            encoded_tx_data_reg <= {{4{CTRL_IDLE}}, 4'd0, output_data_reg[23:0], BLOCK_TYPE_TERM_3};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_4: begin
            encoded_tx_data_reg <= {{3{CTRL_IDLE}}, 3'd0, output_data_reg[31:0], BLOCK_TYPE_TERM_4};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_5: begin
            encoded_tx_data_reg <= {{2{CTRL_IDLE}}, 2'd0, output_data_reg[39:0], BLOCK_TYPE_TERM_5};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_6: begin
            encoded_tx_data_reg <= {{1{CTRL_IDLE}}, 1'd0, output_data_reg[47:0], BLOCK_TYPE_TERM_6};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        OUTPUT_TYPE_TERM_7: begin
            encoded_tx_data_reg <= {output_data_reg[55:0], BLOCK_TYPE_TERM_7};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
        default: begin
            encoded_tx_data_reg <= {{8{CTRL_ERROR}}, BLOCK_TYPE_CTRL};
            encoded_tx_hdr_reg <= SYNC_CTRL;
        end
    endcase

    if (reset_crc) begin
        crc_state <= 32'hFFFFFFFF;
    end else if (update_crc) begin
        crc_state <= crc_next7;
    end

    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_ptr_reg <= 16'd0;

        ifg_count_reg <= 8'd0;
        deficit_idle_count_reg <= 2'd0;

        s_axis_tready_reg <= 1'b0;

        m_axis_ptp_ts_valid_reg <= 1'b0;
        m_axis_ptp_ts_valid_int_reg <= 1'b0;

        encoded_tx_data_reg <= {{8{CTRL_IDLE}}, BLOCK_TYPE_CTRL};
        encoded_tx_hdr_reg <= SYNC_CTRL;

        output_data_reg <= {DATA_WIDTH{1'b0}};
        output_type_reg <= OUTPUT_TYPE_IDLE;

        start_packet_reg <= 2'b00;
        error_underflow_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;

        lanes_swapped <= 1'b0;

        delay_type_valid <= 1'b0;
        delay_type <= OUTPUT_TYPE_IDLE;
    end
end

endmodule

`resetall
