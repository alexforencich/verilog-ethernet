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
 * AXI4-Stream XGMII frame receiver (XGMII in, AXI out)
 */
module axis_xgmii_rx_32 #
(
    parameter DATA_WIDTH = 32,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_WIDTH = 96,
    parameter USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * XGMII input
     */
    input  wire [DATA_WIDTH-1:0]    xgmii_rxd,
    input  wire [CTRL_WIDTH-1:0]    xgmii_rxc,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]    m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]    m_axis_tkeep,
    output wire                     m_axis_tvalid,
    output wire                     m_axis_tlast,
    output wire [USER_WIDTH-1:0]    m_axis_tuser,

    /*
     * PTP
     */
    input  wire [PTP_TS_WIDTH-1:0]  ptp_ts,

    /*
     * Configuration
     */
    input  wire                     cfg_rx_enable,

    /*
     * Status
     */
    output wire                     start_packet,
    output wire                     error_bad_frame,
    output wire                     error_bad_fcs
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 32) begin
        $error("Error: Interface width must be 32");
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

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PREAMBLE = 2'd1,
    STATE_PAYLOAD = 2'd2,
    STATE_LAST = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;

reg [1:0] term_lane_reg = 0, term_lane_d0_reg = 0;
reg term_present_reg = 1'b0;
reg framing_error_reg = 1'b0;

reg [DATA_WIDTH-1:0] xgmii_rxd_d0 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] xgmii_rxd_d1 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] xgmii_rxd_d2 = {DATA_WIDTH{1'b0}};

reg [CTRL_WIDTH-1:0] xgmii_rxc_d0 = {CTRL_WIDTH{1'b0}};

reg xgmii_start_d0 = 1'b0;
reg xgmii_start_d1 = 1'b0;
reg xgmii_start_d2 = 1'b0;

reg [DATA_WIDTH-1:0] m_axis_tdata_reg = {DATA_WIDTH{1'b0}}, m_axis_tdata_next;
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg = {KEEP_WIDTH{1'b0}}, m_axis_tkeep_next;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg m_axis_tlast_reg = 1'b0, m_axis_tlast_next;
reg [USER_WIDTH-1:0] m_axis_tuser_reg = {USER_WIDTH{1'b0}}, m_axis_tuser_next;

reg start_packet_reg = 1'b0, start_packet_next;
reg error_bad_frame_reg = 1'b0, error_bad_frame_next;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next;

wire [3:0] crc_valid;
reg [3:0] crc_valid_save;

assign crc_valid[3] = crc_next == ~32'h2144df1c;
assign crc_valid[2] = crc_next == ~32'hc622f71d;
assign crc_valid[1] = crc_next == ~32'hb1c2a1a3;
assign crc_valid[0] = crc_next == ~32'h9d6cdf7e;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = m_axis_tkeep_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tuser = m_axis_tuser_reg;

assign start_packet = start_packet_reg;
assign error_bad_frame = error_bad_frame_reg;
assign error_bad_fcs = error_bad_fcs_reg;

wire last_cycle = state_reg == STATE_LAST;

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(32),
    .STYLE("AUTO")
)
eth_crc (
    .data_in(xgmii_rxd_d0),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;

    m_axis_tdata_next = xgmii_rxd_d2;
    m_axis_tkeep_next = {KEEP_WIDTH{1'b1}};
    m_axis_tvalid_next = 1'b0;
    m_axis_tlast_next = 1'b0;
    m_axis_tuser_next = m_axis_tuser_reg;
    m_axis_tuser_next[0] = 1'b0;

    start_packet_next = 1'b0;
    error_bad_frame_next = 1'b0;
    error_bad_fcs_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for packet
            reset_crc = 1'b1;

            if (xgmii_start_d2 && cfg_rx_enable) begin
                // start condition
                if (framing_error_reg) begin
                    // control or error characters in first data word
                    m_axis_tdata_next = xgmii_rxd_d2;
                    m_axis_tkeep_next = 4'h1;
                    m_axis_tvalid_next = 1'b1;
                    m_axis_tlast_next = 1'b1;
                    m_axis_tuser_next[0] = 1'b1;
                    error_bad_frame_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    reset_crc = 1'b0;
                    state_next = STATE_PREAMBLE;
                end
            end else begin
                if (PTP_TS_ENABLE) begin
                    m_axis_tuser_next[1 +: PTP_TS_WIDTH] = ptp_ts;
                end
                state_next = STATE_IDLE;
            end
        end
        STATE_PREAMBLE: begin
            // drop preamble
            start_packet_next = 1'b1;
            state_next = STATE_PAYLOAD;
        end
        STATE_PAYLOAD: begin
            // read payload
            m_axis_tdata_next = xgmii_rxd_d2;
            m_axis_tkeep_next = {KEEP_WIDTH{1'b1}};
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b0;
            m_axis_tuser_next[0] = 1'b0;

            if (framing_error_reg) begin
                // control or error characters in packet
                m_axis_tlast_next = 1'b1;
                m_axis_tuser_next[0] = 1'b1;
                error_bad_frame_next = 1'b1;
                reset_crc = 1'b1;
                state_next = STATE_IDLE;
            end else if (term_present_reg) begin
                reset_crc = 1'b1;
                if (term_lane_reg == 0) begin
                    // end this cycle
                    m_axis_tkeep_next = 4'b1111;
                    m_axis_tlast_next = 1'b1;
                    if (term_lane_reg == 0 && crc_valid_save[3]) begin
                        // CRC valid
                    end else begin
                        m_axis_tuser_next[0] = 1'b1;
                        error_bad_frame_next = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    // need extra cycle
                    state_next = STATE_LAST;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_LAST: begin
            // last cycle of packet
            m_axis_tdata_next = xgmii_rxd_d2;
            m_axis_tkeep_next = {KEEP_WIDTH{1'b1}} >> (CTRL_WIDTH-term_lane_d0_reg);
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b1;
            m_axis_tuser_next[0] = 1'b0;

            reset_crc = 1'b1;

            if ((term_lane_d0_reg == 1 && crc_valid_save[0]) ||
                (term_lane_d0_reg == 2 && crc_valid_save[1]) ||
                (term_lane_d0_reg == 3 && crc_valid_save[2])) begin
                // CRC valid
            end else begin
                m_axis_tuser_next[0] = 1'b1;
                error_bad_frame_next = 1'b1;
                error_bad_fcs_next = 1'b1;
            end

            state_next = STATE_IDLE;
        end
    endcase
end

integer i;

always @(posedge clk) begin
    state_reg <= state_next;

    m_axis_tdata_reg <= m_axis_tdata_next;
    m_axis_tkeep_reg <= m_axis_tkeep_next;
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tlast_reg <= m_axis_tlast_next;
    m_axis_tuser_reg <= m_axis_tuser_next;

    start_packet_reg <= start_packet_next;
    error_bad_frame_reg <= error_bad_frame_next;
    error_bad_fcs_reg <= error_bad_fcs_next;

    term_lane_reg <= 0;
    term_present_reg <= 1'b0;
    framing_error_reg <= xgmii_rxc != 0;

    for (i = CTRL_WIDTH-1; i >= 0; i = i - 1) begin
        if (xgmii_rxc[i] && (xgmii_rxd[i*8 +: 8] == XGMII_TERM)) begin
            term_lane_reg <= i;
            term_present_reg <= 1'b1;
            framing_error_reg <= (xgmii_rxc & ({CTRL_WIDTH{1'b1}} >> (CTRL_WIDTH-i))) != 0;
        end
    end

    term_lane_d0_reg <= term_lane_reg;

    if (reset_crc) begin
        crc_state <= 32'hFFFFFFFF;
    end else begin
        crc_state <= crc_next;
    end

    crc_valid_save <= crc_valid;

    for (i = 0; i < CTRL_WIDTH; i = i + 1) begin
        xgmii_rxd_d0[i*8 +: 8] <= xgmii_rxc[i] ? 8'd0 : xgmii_rxd[i*8 +: 8];
    end
    xgmii_rxc_d0 <= xgmii_rxc;
    xgmii_rxd_d1 <= xgmii_rxd_d0;
    xgmii_rxd_d2 <= xgmii_rxd_d1;

    xgmii_start_d0 <= xgmii_rxc[0] && xgmii_rxd[7:0] == XGMII_START;
    xgmii_start_d1 <= xgmii_start_d0;
    xgmii_start_d2 <= xgmii_start_d1;

    if (rst) begin
        state_reg <= STATE_IDLE;

        m_axis_tvalid_reg <= 1'b0;

        start_packet_reg <= 1'b0;
        error_bad_frame_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;

        xgmii_rxc_d0 <= {CTRL_WIDTH{1'b0}};

        xgmii_start_d0 <= 1'b0;
        xgmii_start_d1 <= 1'b0;
        xgmii_start_d2 <= 1'b0;
    end
end

endmodule

`resetall
