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
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_FMT_TOD = 1,
    parameter PTP_TS_WIDTH = PTP_TS_FMT_TOD ? 96 : 64,
    parameter PTP_TS_CTRL_IN_TUSER = 0,
    parameter PTP_TAG_ENABLE = PTP_TS_ENABLE,
    parameter PTP_TAG_WIDTH = 16,
    parameter USER_WIDTH = (PTP_TS_ENABLE ? (PTP_TAG_ENABLE ? PTP_TAG_WIDTH : 0) + (PTP_TS_CTRL_IN_TUSER ? 1 : 0) : 0) + 1
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
    input  wire [7:0]                cfg_ifg,
    input  wire                      cfg_tx_enable,

    /*
     * Status
     */
    output wire [1:0]                start_packet,
    output wire                      error_underflow
);

parameter EMPTY_WIDTH = $clog2(KEEP_WIDTH);
parameter MIN_LEN_WIDTH = $clog2(MIN_FRAME_LENGTH-4-KEEP_WIDTH+1);

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
    STATE_ERR = 3'd5,
    STATE_IFG = 3'd6;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg swap_lanes_reg = 1'b0, swap_lanes_next;
reg [31:0] swap_data = 32'd0;

reg delay_type_valid = 1'b0;
reg [3:0] delay_type = OUTPUT_TYPE_IDLE;

reg [DATA_WIDTH-1:0] s_axis_tdata_masked;

reg [DATA_WIDTH-1:0] s_tdata_reg = 0, s_tdata_next;
reg [EMPTY_WIDTH-1:0] s_empty_reg = 0, s_empty_next;

reg [DATA_WIDTH-1:0] fcs_output_data_0;
reg [DATA_WIDTH-1:0] fcs_output_data_1;
reg [3:0] fcs_output_type_0;
reg [3:0] fcs_output_type_1;

reg [7:0] ifg_offset;

reg frame_start_reg = 1'b0, frame_start_next;
reg frame_reg = 1'b0, frame_next;
reg frame_error_reg = 1'b0, frame_error_next;
reg [MIN_LEN_WIDTH-1:0] frame_min_count_reg = 0, frame_min_count_next;

reg [7:0] ifg_count_reg = 8'd0, ifg_count_next;
reg [1:0] deficit_idle_count_reg = 2'd0, deficit_idle_count_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [PTP_TS_WIDTH-1:0] m_axis_ptp_ts_reg = 0;
reg [PTP_TS_WIDTH-1:0] m_axis_ptp_ts_adj_reg = 0;
reg [PTP_TAG_WIDTH-1:0] m_axis_ptp_ts_tag_reg = 0;
reg m_axis_ptp_ts_valid_reg = 1'b0;
reg m_axis_ptp_ts_valid_int_reg = 1'b0;
reg m_axis_ptp_ts_borrow_reg = 1'b0;

reg [31:0] crc_state_reg[7:0];
wire [31:0] crc_state_next[7:0];

reg [DATA_WIDTH-1:0] encoded_tx_data_reg = {{8{CTRL_IDLE}}, BLOCK_TYPE_CTRL};
reg [HDR_WIDTH-1:0] encoded_tx_hdr_reg = SYNC_CTRL;

reg [DATA_WIDTH-1:0] output_data_reg = {DATA_WIDTH{1'b0}}, output_data_next;
reg [3:0] output_type_reg = OUTPUT_TYPE_IDLE, output_type_next;

reg [1:0] start_packet_reg = 2'b00;
reg error_underflow_reg = 1'b0, error_underflow_next;

reg [4+16-1:0] last_ts_reg = 0;
reg [4+16-1:0] ts_inc_reg = 0;

assign s_axis_tready = s_axis_tready_reg;

assign encoded_tx_data = encoded_tx_data_reg;
assign encoded_tx_hdr = encoded_tx_hdr_reg;

assign m_axis_ptp_ts = PTP_TS_ENABLE ? ((!PTP_TS_FMT_TOD || m_axis_ptp_ts_borrow_reg) ? m_axis_ptp_ts_reg : m_axis_ptp_ts_adj_reg) : 0;
assign m_axis_ptp_ts_tag = PTP_TAG_ENABLE ? m_axis_ptp_ts_tag_reg : 0;
assign m_axis_ptp_ts_valid = PTP_TS_ENABLE || PTP_TAG_ENABLE ? m_axis_ptp_ts_valid_reg : 1'b0;

assign start_packet = start_packet_reg;
assign error_underflow = error_underflow_reg;

generate
    genvar n;

    for (n = 0; n < 8; n = n + 1) begin : crc
        lfsr #(
            .LFSR_WIDTH(32),
            .LFSR_POLY(32'h4c11db7),
            .LFSR_CONFIG("GALOIS"),
            .LFSR_FEED_FORWARD(0),
            .REVERSE(1),
            .DATA_WIDTH(8*(n+1)),
            .STYLE("AUTO")
        )
        eth_crc (
            .data_in(s_tdata_reg[0 +: 8*(n+1)]),
            .state_in(crc_state_reg[7]),
            .data_out(),
            .state_out(crc_state_next[n])
        );
    end

endgenerate

function [2:0] keep2empty;
    input [7:0] k;
    casez (k)
        8'bzzzzzzz0: keep2empty = 3'd7;
        8'bzzzzzz01: keep2empty = 3'd7;
        8'bzzzzz011: keep2empty = 3'd6;
        8'bzzzz0111: keep2empty = 3'd5;
        8'bzzz01111: keep2empty = 3'd4;
        8'bzz011111: keep2empty = 3'd3;
        8'bz0111111: keep2empty = 3'd2;
        8'b01111111: keep2empty = 3'd1;
        8'b11111111: keep2empty = 3'd0;
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
    casez (s_empty_reg)
        3'd7: begin
            fcs_output_data_0 = {24'd0, ~crc_state_next[0][31:0], s_tdata_reg[7:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_5;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd3;
        end
        3'd6: begin
            fcs_output_data_0 = {16'd0, ~crc_state_next[1][31:0], s_tdata_reg[15:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_6;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd2;
        end
        3'd5: begin
            fcs_output_data_0 = {8'd0, ~crc_state_next[2][31:0], s_tdata_reg[23:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_TERM_7;
            fcs_output_type_1 = OUTPUT_TYPE_IDLE;
            ifg_offset = 8'd1;
        end
        3'd4: begin
            fcs_output_data_0 = {~crc_state_next[3][31:0], s_tdata_reg[31:0]};
            fcs_output_data_1 = 64'd0;
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_0;
            ifg_offset = 8'd8;
        end
        3'd3: begin
            fcs_output_data_0 = {~crc_state_next[4][23:0], s_tdata_reg[39:0]};
            fcs_output_data_1 = {56'd0, ~crc_state_reg[4][31:24]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_1;
            ifg_offset = 8'd7;
        end
        3'd2: begin
            fcs_output_data_0 = {~crc_state_next[5][15:0], s_tdata_reg[47:0]};
            fcs_output_data_1 = {48'd0, ~crc_state_reg[5][31:16]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_2;
            ifg_offset = 8'd6;
        end
        3'd1: begin
            fcs_output_data_0 = {~crc_state_next[6][7:0], s_tdata_reg[55:0]};
            fcs_output_data_1 = {40'd0, ~crc_state_reg[6][31:8]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_3;
            ifg_offset = 8'd5;
        end
        3'd0: begin
            fcs_output_data_0 = s_tdata_reg;
            fcs_output_data_1 = {32'd0, ~crc_state_reg[7][31:0]};
            fcs_output_type_0 = OUTPUT_TYPE_DATA;
            fcs_output_type_1 = OUTPUT_TYPE_TERM_4;
            ifg_offset = 8'd4;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    swap_lanes_next = swap_lanes_reg;

    frame_start_next = 1'b0;
    frame_next = frame_reg;
    frame_error_next = frame_error_reg;
    frame_min_count_next = frame_min_count_reg;

    ifg_count_next = ifg_count_reg;
    deficit_idle_count_next = deficit_idle_count_reg;

    s_axis_tready_next = 1'b0;

    s_tdata_next = s_tdata_reg;
    s_empty_next = s_empty_reg;

    output_data_next = s_tdata_reg;
    output_type_next = OUTPUT_TYPE_IDLE;

    error_underflow_next = 1'b0;

    if (s_axis_tvalid && s_axis_tready) begin
        frame_next = !s_axis_tlast;
    end

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_error_next = 1'b0;
            frame_min_count_next = MIN_FRAME_LENGTH-4-KEEP_WIDTH;
            reset_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_IDLE;

            s_tdata_next = s_axis_tdata_masked;
            s_empty_next = keep2empty(s_axis_tkeep);

            if (s_axis_tvalid && cfg_tx_enable) begin
                // Preamble and SFD
                output_data_next = {ETH_SFD, {7{ETH_PRE}}};
                output_type_next = OUTPUT_TYPE_START_0;
                frame_start_next = 1'b1;
                s_axis_tready_next = 1'b1;
                state_next = STATE_PAYLOAD;
            end else begin
                swap_lanes_next = 1'b0;
                ifg_count_next = 8'd0;
                deficit_idle_count_next = 2'd0;
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            update_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            if (frame_min_count_reg > KEEP_WIDTH) begin
                frame_min_count_next = frame_min_count_reg - KEEP_WIDTH;
            end else begin
                frame_min_count_next = 0;
            end

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_DATA;

            s_tdata_next = s_axis_tdata_masked;
            s_empty_next = keep2empty(s_axis_tkeep);

            if (!s_axis_tvalid || s_axis_tlast) begin
                s_axis_tready_next = frame_next; // drop frame
                frame_error_next = !s_axis_tvalid || s_axis_tuser[0];
                error_underflow_next = !s_axis_tvalid;

                if (ENABLE_PADDING && frame_min_count_reg) begin
                    if (frame_min_count_reg > KEEP_WIDTH) begin
                        s_empty_next = 0;
                        state_next = STATE_PAD;
                    end else begin
                        if (keep2empty(s_axis_tkeep) > KEEP_WIDTH-frame_min_count_reg) begin
                            s_empty_next = KEEP_WIDTH-frame_min_count_reg;
                        end
                        if (frame_error_next) begin
                            state_next = STATE_ERR;
                        end else begin
                            state_next = STATE_FCS_1;
                        end
                    end
                end else begin
                    if (frame_error_next) begin
                        state_next = STATE_ERR;
                    end else begin
                        state_next = STATE_FCS_1;
                    end
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_PAD: begin
            // pad frame to MIN_FRAME_LENGTH
            s_axis_tready_next = frame_next; // drop frame

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_DATA;

            s_tdata_next = 64'd0;
            s_empty_next = 0;

            update_crc = 1'b1;

            if (frame_min_count_reg > KEEP_WIDTH) begin
                frame_min_count_next = frame_min_count_reg - KEEP_WIDTH;
                state_next = STATE_PAD;
            end else begin
                frame_min_count_next = 0;
                s_empty_next = KEEP_WIDTH-frame_min_count_reg;
                if (frame_error_reg) begin
                    state_next = STATE_ERR;
                end else begin
                    state_next = STATE_FCS_1;
                end
            end
        end
        STATE_FCS_1: begin
            // last cycle
            s_axis_tready_next = frame_next; // drop frame

            output_data_next = fcs_output_data_0;
            output_type_next = fcs_output_type_0;

            update_crc = 1'b1;

            ifg_count_next = (cfg_ifg > 8'd12 ? cfg_ifg : 8'd12) - ifg_offset + (swap_lanes_reg ? 8'd4 : 8'd0) + deficit_idle_count_reg;
            if (s_empty_reg <= 4) begin
                state_next = STATE_FCS_2;
            end else begin
                state_next = STATE_IFG;
            end
        end
        STATE_FCS_2: begin
            // last cycle
            s_axis_tready_next = frame_next; // drop frame

            output_data_next = fcs_output_data_1;
            output_type_next = fcs_output_type_1;

            reset_crc = 1'b1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                        swap_lanes_next = 1'b1;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                        swap_lanes_next = 1'b0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    swap_lanes_next = ifg_count_next != 0;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_ERR: begin
            // terminate packet with error
            s_axis_tready_next = frame_next; // drop frame

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_ERROR;

            ifg_count_next = 8'd12;

            state_next = STATE_IFG;
        end
        STATE_IFG: begin
            // send IFG
            s_axis_tready_next = frame_next; // drop frame

            output_data_next = s_tdata_reg;
            output_type_next = OUTPUT_TYPE_IDLE;

            if (ifg_count_reg > 8'd8) begin
                ifg_count_next = ifg_count_reg - 8'd8;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd7 || frame_reg) begin
                    state_next = STATE_IFG;
                end else begin
                    if (ifg_count_next >= 8'd4) begin
                        deficit_idle_count_next = ifg_count_next - 8'd4;
                        swap_lanes_next = 1'b1;
                    end else begin
                        deficit_idle_count_next = ifg_count_next;
                        ifg_count_next = 8'd0;
                        swap_lanes_next = 1'b0;
                    end
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4 || frame_reg) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = 1'b1;
                    swap_lanes_next = ifg_count_next != 0;
                    state_next = STATE_IDLE;
                end
            end
        end
    endcase
end

always @(posedge clk) begin
    state_reg <= state_next;

    swap_lanes_reg <= swap_lanes_next;

    frame_start_reg <= frame_start_next;
    frame_reg <= frame_next;
    frame_error_reg <= frame_error_next;
    frame_min_count_reg <= frame_min_count_next;

    ifg_count_reg <= ifg_count_next;
    deficit_idle_count_reg <= deficit_idle_count_next;

    s_tdata_reg <= s_tdata_next;
    s_empty_reg <= s_empty_next;

    s_axis_tready_reg <= s_axis_tready_next;

    m_axis_ptp_ts_valid_reg <= 1'b0;
    m_axis_ptp_ts_valid_int_reg <= 1'b0;

    start_packet_reg <= 2'b00;
    error_underflow_reg <= error_underflow_next;

    delay_type_valid <= 1'b0;
    delay_type <= output_type_next ^ 4'd4;

    swap_data <= output_data_next[63:32];

    if (swap_lanes_reg) begin
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
        output_data_reg <= output_data_next;
        output_type_reg <= output_type_next;
    end

    if (PTP_TS_ENABLE && PTP_TS_FMT_TOD) begin
        m_axis_ptp_ts_valid_reg <= m_axis_ptp_ts_valid_int_reg;
        m_axis_ptp_ts_adj_reg[15:0] <= m_axis_ptp_ts_reg[15:0];
        {m_axis_ptp_ts_borrow_reg, m_axis_ptp_ts_adj_reg[45:16]} <= $signed({1'b0, m_axis_ptp_ts_reg[45:16]}) - $signed(31'd1000000000);
        m_axis_ptp_ts_adj_reg[47:46] <= 0;
        m_axis_ptp_ts_adj_reg[95:48] <= m_axis_ptp_ts_reg[95:48] + 1;
    end

    if (frame_start_reg) begin
        if (swap_lanes_reg) begin
            if (PTP_TS_ENABLE) begin
                if (PTP_TS_FMT_TOD) begin
                    m_axis_ptp_ts_reg[45:0] <= ptp_ts[45:0] + (ts_inc_reg >> 1);
                    m_axis_ptp_ts_reg[95:48] <= ptp_ts[95:48];
                end else begin
                    m_axis_ptp_ts_reg <= ptp_ts + (ts_inc_reg >> 1);
                end
            end
            start_packet_reg <= 2'b10;
        end else begin
            if (PTP_TS_ENABLE) begin
                m_axis_ptp_ts_reg <= ptp_ts;
            end
            start_packet_reg <= 2'b01;
        end
        if (PTP_TS_ENABLE) begin
            if (PTP_TS_CTRL_IN_TUSER) begin
                m_axis_ptp_ts_tag_reg <= s_axis_tuser >> 2;
                if (PTP_TS_FMT_TOD) begin
                    m_axis_ptp_ts_valid_int_reg <= s_axis_tuser[1];
                end else begin
                    m_axis_ptp_ts_valid_reg <= s_axis_tuser[1];
                end
            end else begin
                m_axis_ptp_ts_tag_reg <= s_axis_tuser >> 1;
                if (PTP_TS_FMT_TOD) begin
                    m_axis_ptp_ts_valid_int_reg <= 1'b1;
                end else begin
                    m_axis_ptp_ts_valid_reg <= 1'b1;
                end
            end
        end
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

    crc_state_reg[0] <= crc_state_next[0];
    crc_state_reg[1] <= crc_state_next[1];
    crc_state_reg[2] <= crc_state_next[2];
    crc_state_reg[3] <= crc_state_next[3];
    crc_state_reg[4] <= crc_state_next[4];
    crc_state_reg[5] <= crc_state_next[5];
    crc_state_reg[6] <= crc_state_next[6];

    if (update_crc) begin
        crc_state_reg[7] <= crc_state_next[7];
    end

    if (reset_crc) begin
        crc_state_reg[7] <= 32'hFFFFFFFF;
    end

    last_ts_reg <= ptp_ts;
    ts_inc_reg <= ptp_ts - last_ts_reg;

    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_start_reg <= 1'b0;
        frame_reg <= 1'b0;

        swap_lanes_reg <= 1'b0;

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

        delay_type_valid <= 1'b0;
        delay_type <= OUTPUT_TYPE_IDLE;
    end
end

endmodule

`resetall
