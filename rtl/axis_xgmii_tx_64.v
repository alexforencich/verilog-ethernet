/*

Copyright (c) 2015-2017 Alex Forencich

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
 * AXI4-Stream XGMII frame transmitter (AXI in, XGMII out)
 */
module axis_xgmii_tx_64 #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
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
     * XGMII output
     */
    output wire [DATA_WIDTH-1:0]     xgmii_txd,
    output wire [CTRL_WIDTH-1:0]     xgmii_txc,

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
parameter MIN_LEN_WIDTH = $clog2(MIN_FRAME_LENGTH-4-CTRL_WIDTH+1);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (KEEP_WIDTH * 8 != DATA_WIDTH || CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end
end

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [7:0]
    XGMII_IDLE = 8'h07,
    XGMII_START = 8'hfb,
    XGMII_TERM = 8'hfd,
    XGMII_ERROR = 8'hfe;

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
reg [31:0] swap_txd = 32'd0;
reg [3:0] swap_txc = 4'd0;

reg [DATA_WIDTH-1:0] s_axis_tdata_masked;

reg [DATA_WIDTH-1:0] s_tdata_reg = 0, s_tdata_next;
reg [EMPTY_WIDTH-1:0] s_empty_reg = 0, s_empty_next;

reg [DATA_WIDTH-1:0] fcs_output_txd_0;
reg [DATA_WIDTH-1:0] fcs_output_txd_1;
reg [CTRL_WIDTH-1:0] fcs_output_txc_0;
reg [CTRL_WIDTH-1:0] fcs_output_txc_1;

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

reg [4+16-1:0] last_ts_reg = 0;
reg [4+16-1:0] ts_inc_reg = 0;

reg [DATA_WIDTH-1:0] xgmii_txd_reg = {CTRL_WIDTH{XGMII_IDLE}}, xgmii_txd_next;
reg [CTRL_WIDTH-1:0] xgmii_txc_reg = {CTRL_WIDTH{1'b1}}, xgmii_txc_next;

reg start_packet_reg = 2'b00;
reg error_underflow_reg = 1'b0, error_underflow_next;

assign s_axis_tready = s_axis_tready_reg;

assign xgmii_txd = xgmii_txd_reg;
assign xgmii_txc = xgmii_txc_reg;

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
            fcs_output_txd_0 = {{2{XGMII_IDLE}}, XGMII_TERM, ~crc_state_next[0][31:0], s_tdata_reg[7:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b11100000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd3;
        end
        3'd6: begin
            fcs_output_txd_0 = {XGMII_IDLE, XGMII_TERM, ~crc_state_next[1][31:0], s_tdata_reg[15:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b11000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd2;
        end
        3'd5: begin
            fcs_output_txd_0 = {XGMII_TERM, ~crc_state_next[2][31:0], s_tdata_reg[23:0]};
            fcs_output_txd_1 = {8{XGMII_IDLE}};
            fcs_output_txc_0 = 8'b10000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd1;
        end
        3'd4: begin
            fcs_output_txd_0 = {~crc_state_next[3][31:0], s_tdata_reg[31:0]};
            fcs_output_txd_1 = {{7{XGMII_IDLE}}, XGMII_TERM};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111111;
            ifg_offset = 8'd8;
        end
        3'd3: begin
            fcs_output_txd_0 = {~crc_state_next[4][23:0], s_tdata_reg[39:0]};
            fcs_output_txd_1 = {{6{XGMII_IDLE}}, XGMII_TERM, ~crc_state_reg[4][31:24]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111110;
            ifg_offset = 8'd7;
        end
        3'd2: begin
            fcs_output_txd_0 = {~crc_state_next[5][15:0], s_tdata_reg[47:0]};
            fcs_output_txd_1 = {{5{XGMII_IDLE}}, XGMII_TERM, ~crc_state_reg[5][31:16]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111100;
            ifg_offset = 8'd6;
        end
        3'd1: begin
            fcs_output_txd_0 = {~crc_state_next[6][7:0], s_tdata_reg[55:0]};
            fcs_output_txd_1 = {{4{XGMII_IDLE}}, XGMII_TERM, ~crc_state_reg[6][31:8]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11111000;
            ifg_offset = 8'd5;
        end
        3'd0: begin
            fcs_output_txd_0 = s_tdata_reg;
            fcs_output_txd_1 = {{3{XGMII_IDLE}}, XGMII_TERM, ~crc_state_reg[7][31:0]};
            fcs_output_txc_0 = 8'b00000000;
            fcs_output_txc_1 = 8'b11110000;
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

    // XGMII idle
    xgmii_txd_next = {CTRL_WIDTH{XGMII_IDLE}};
    xgmii_txc_next = {CTRL_WIDTH{1'b1}};

    error_underflow_next = 1'b0;

    if (s_axis_tvalid && s_axis_tready) begin
        frame_next = !s_axis_tlast;
    end

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_error_next = 1'b0;
            frame_min_count_next = MIN_FRAME_LENGTH-4-CTRL_WIDTH;
            reset_crc = 1'b1;
            s_axis_tready_next = cfg_tx_enable;

            // XGMII idle
            xgmii_txd_next = {CTRL_WIDTH{XGMII_IDLE}};
            xgmii_txc_next = {CTRL_WIDTH{1'b1}};

            s_tdata_next = s_axis_tdata_masked;
            s_empty_next = keep2empty(s_axis_tkeep);

            if (s_axis_tvalid && s_axis_tready) begin
                // XGMII start, preamble, and SFD
                xgmii_txd_next = {ETH_SFD, {6{ETH_PRE}}, XGMII_START};
                xgmii_txc_next = 8'b00000001;
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

            if (frame_min_count_reg > CTRL_WIDTH) begin
                frame_min_count_next = frame_min_count_reg - CTRL_WIDTH;
            end else begin
                frame_min_count_next = 0;
            end

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = {CTRL_WIDTH{1'b0}};

            s_tdata_next = s_axis_tdata_masked;
            s_empty_next = keep2empty(s_axis_tkeep);

            if (!s_axis_tvalid || s_axis_tlast) begin
                s_axis_tready_next = frame_next; // drop frame
                frame_error_next = !s_axis_tvalid || s_axis_tuser[0];
                error_underflow_next = !s_axis_tvalid;

                if (ENABLE_PADDING && frame_min_count_reg) begin
                    if (frame_min_count_reg > CTRL_WIDTH) begin
                        s_empty_next = 0;
                        state_next = STATE_PAD;
                    end else begin
                        if (keep2empty(s_axis_tkeep) > CTRL_WIDTH-frame_min_count_reg) begin
                            s_empty_next = CTRL_WIDTH-frame_min_count_reg;
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

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = {CTRL_WIDTH{1'b0}};

            s_tdata_next = 64'd0;
            s_empty_next = 0;

            update_crc = 1'b1;

            if (frame_min_count_reg > CTRL_WIDTH) begin
                frame_min_count_next = frame_min_count_reg - CTRL_WIDTH;
                state_next = STATE_PAD;
            end else begin
                frame_min_count_next = 0;
                s_empty_next = CTRL_WIDTH-frame_min_count_reg;
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

            xgmii_txd_next = fcs_output_txd_0;
            xgmii_txc_next = fcs_output_txc_0;

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

            xgmii_txd_next = fcs_output_txd_1;
            xgmii_txc_next = fcs_output_txc_1;

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
                    s_axis_tready_next = cfg_tx_enable;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = cfg_tx_enable;
                    swap_lanes_next = ifg_count_next != 0;
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_ERR: begin
            // terminate packet with error
            s_axis_tready_next = frame_next; // drop frame

            // XGMII error
            xgmii_txd_next = {XGMII_TERM, {7{XGMII_ERROR}}};
            xgmii_txc_next = {CTRL_WIDTH{1'b1}};

            ifg_count_next = 8'd12;

            state_next = STATE_IFG;
        end
        STATE_IFG: begin
            // send IFG
            s_axis_tready_next = frame_next; // drop frame

            // XGMII idle
            xgmii_txd_next = {CTRL_WIDTH{XGMII_IDLE}};
            xgmii_txc_next = {CTRL_WIDTH{1'b1}};

            if (ifg_count_reg > 8'd8) begin
                ifg_count_next = ifg_count_reg - 8'd8;
            end else begin
                ifg_count_next = 8'd0;
            end

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
                    s_axis_tready_next = cfg_tx_enable;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd4 || frame_reg) begin
                    state_next = STATE_IFG;
                end else begin
                    s_axis_tready_next = cfg_tx_enable;
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

    swap_txd <= xgmii_txd_next[63:32];
    swap_txc <= xgmii_txc_next[7:4];

    if (swap_lanes_reg) begin
        xgmii_txd_reg <= {xgmii_txd_next[31:0], swap_txd};
        xgmii_txc_reg <= {xgmii_txc_next[3:0], swap_txc};
    end else begin
        xgmii_txd_reg <= xgmii_txd_next;
        xgmii_txc_reg <= xgmii_txc_next;
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

        xgmii_txd_reg <= {CTRL_WIDTH{XGMII_IDLE}};
        xgmii_txc_reg <= {CTRL_WIDTH{1'b1}};

        start_packet_reg <= 2'b00;
        error_underflow_reg <= 1'b0;
    end
end

endmodule

`resetall
