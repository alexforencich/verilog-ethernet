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

`timescale 1ns / 1ps

/*
 * AXI4-Stream XGMII frame receiver (XGMII in, AXI out)
 */
module axis_xgmii_rx_32
(
    input  wire        clk,
    input  wire        rst,

    /*
     * XGMII input
     */
    input  wire [31:0] xgmii_rxd,
    input  wire [3:0]  xgmii_rxc,

    /*
     * AXI output
     */
    output wire [31:0] m_axis_tdata,
    output wire [3:0]  m_axis_tkeep,
    output wire        m_axis_tvalid,
    output wire        m_axis_tlast,
    output wire        m_axis_tuser,

    /*
     * Status
     */
    output wire        error_bad_frame,
    output wire        error_bad_fcs
);

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
    STATE_PREAMBLE = 3'd1,
    STATE_PAYLOAD = 3'd2,
    STATE_LAST = 3'd3;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [3:0] last_cycle_tkeep_reg = 4'd0, last_cycle_tkeep_next;

reg [31:0] xgmii_rxd_d0 = 32'd0;
reg [31:0] xgmii_rxd_d1 = 32'd0;
reg [31:0] xgmii_rxd_d2 = 32'd0;

reg [3:0] xgmii_rxc_d0 = 4'd0;
reg [3:0] xgmii_rxc_d1 = 4'd0;
reg [3:0] xgmii_rxc_d2 = 4'd0;

reg [31:0] m_axis_tdata_reg = 32'd0, m_axis_tdata_next;
reg [3:0] m_axis_tkeep_reg = 4'd0, m_axis_tkeep_next;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg m_axis_tlast_reg = 1'b0, m_axis_tlast_next;
reg m_axis_tuser_reg = 1'b0, m_axis_tuser_next;

reg error_bad_frame_reg = 1'b0, error_bad_frame_next;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;

wire crc_valid0 = crc_next0 == ~32'h2144df1c;
wire crc_valid1 = crc_next1 == ~32'h2144df1c;
wire crc_valid2 = crc_next2 == ~32'h2144df1c;
wire crc_valid3 = crc_next3 == ~32'h2144df1c;

reg crc_valid0_save = 1'b0;
reg crc_valid1_save = 1'b0;
reg crc_valid2_save = 1'b0;
reg crc_valid3_save = 1'b0;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = m_axis_tkeep_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tuser = m_axis_tuser_reg;

assign error_bad_frame = error_bad_frame_reg;
assign error_bad_fcs = error_bad_fcs_reg;

wire last_cycle = state_reg == STATE_LAST;

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
    .data_in(xgmii_rxd_d0[7:0]),
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
    .data_in(xgmii_rxd_d0[15:0]),
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
    .data_in(xgmii_rxd_d0[23:0]),
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
    .data_in(xgmii_rxd_d0[31:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next3)
);

// detect control characters
reg [3:0] detect_start;
reg [3:0] detect_term;
reg [3:0] detect_error;

reg [3:0] detect_term_save;

integer i;

always @* begin
    for (i = 0; i < 4; i = i + 1) begin
        detect_start[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_START);
        detect_term[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_TERM);
        detect_error[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_ERROR);
    end
end

// mask errors to within packet
reg [3:0] detect_error_masked;
reg [3:0] control_masked;
reg [3:0] tkeep_mask;

always @* begin
    casez (detect_term)
    4'b0000: begin
        detect_error_masked = detect_error;
        control_masked = xgmii_rxc_d0;
        tkeep_mask = 4'b1111;
    end
    4'bzzz1: begin
        detect_error_masked = 0;
        control_masked = 0;
        tkeep_mask = 4'b0000;   
    end
    4'bzz10: begin
        detect_error_masked = detect_error[0];
        control_masked = xgmii_rxc_d0[0];
        tkeep_mask = 4'b0001;
    end
    4'bz100: begin
        detect_error_masked = detect_error[1:0];
        control_masked = xgmii_rxc_d0[1:0];
        tkeep_mask = 4'b0011;
    end
    4'b1000: begin
        detect_error_masked = detect_error[2:0];
        control_masked = xgmii_rxc_d0[2:0];
        tkeep_mask = 4'b0111;
    end
    default: begin
        detect_error_masked = detect_error;
        control_masked = xgmii_rxc_d0;
        tkeep_mask = 4'b1111;
    end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    last_cycle_tkeep_next = last_cycle_tkeep_reg;

    m_axis_tdata_next = 32'd0;
    m_axis_tkeep_next = 4'd0;
    m_axis_tvalid_next = 1'b0;
    m_axis_tlast_next = 1'b0;
    m_axis_tuser_next = 1'b0;

    error_bad_frame_next = 1'b0;
    error_bad_fcs_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for packet
            reset_crc = 1'b1;

            if (xgmii_rxc_d2[0] && xgmii_rxd_d2[7:0] == XGMII_START) begin
                // start condition
                if (control_masked) begin
                    // control or error characters in first data word
                    m_axis_tdata_next = 32'd0;
                    m_axis_tkeep_next = 4'h1;
                    m_axis_tvalid_next = 1'b1;
                    m_axis_tlast_next = 1'b1;
                    m_axis_tuser_next = 1'b1;
                    error_bad_frame_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    reset_crc = 1'b0;
                    update_crc = 1'b1;
                    state_next = STATE_PREAMBLE;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PREAMBLE: begin
            // drop preamble
            update_crc = 1'b1;
            state_next = STATE_PAYLOAD;
        end
        STATE_PAYLOAD: begin
            // read payload
            update_crc = 1'b1;

            m_axis_tdata_next = xgmii_rxd_d2;
            m_axis_tkeep_next = ~xgmii_rxc_d2;
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b0;
            m_axis_tuser_next = 1'b0;

            if (control_masked) begin
                // control or error characters in packet
                m_axis_tlast_next = 1'b1;
                m_axis_tuser_next = 1'b1;
                error_bad_frame_next = 1'b1;
                reset_crc = 1'b1;
                state_next = STATE_IDLE;
            end else if (detect_term) begin
                if (detect_term[0]) begin
                    // end this cycle
                    reset_crc = 1'b1;
                    m_axis_tkeep_next = 4'b1111;
                    m_axis_tlast_next = 1'b1;
                    if (detect_term[0] && crc_valid3_save) begin
                        // CRC valid
                    end else begin
                        m_axis_tuser_next = 1'b1;
                        error_bad_frame_next = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    // need extra cycle
                    last_cycle_tkeep_next = tkeep_mask;
                    state_next = STATE_LAST;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_LAST: begin
            // last cycle of packet
            m_axis_tdata_next = xgmii_rxd_d2;
            m_axis_tkeep_next = last_cycle_tkeep_reg;
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b1;
            m_axis_tuser_next = 1'b0;

            reset_crc = 1'b1;

            if ((detect_term_save[1] && crc_valid0_save) ||
                (detect_term_save[2] && crc_valid1_save) ||
                (detect_term_save[3] && crc_valid2_save)) begin
                // CRC valid
            end else begin
                m_axis_tuser_next = 1'b1;
                error_bad_frame_next = 1'b1;
                error_bad_fcs_next = 1'b1;
            end

            state_next = STATE_IDLE;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        m_axis_tvalid_reg <= 1'b0;

        error_bad_frame_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
        crc_valid0_save <= 1'b0;
        crc_valid1_save <= 1'b0;
        crc_valid2_save <= 1'b0;
        crc_valid3_save <= 1'b0;

        xgmii_rxc_d0 <= 4'd0;
        xgmii_rxc_d1 <= 4'd0;
    end else begin
        state_reg <= state_next;

        m_axis_tvalid_reg <= m_axis_tvalid_next;

        error_bad_frame_reg <= error_bad_frame_next;
        error_bad_fcs_reg <= error_bad_fcs_next;

        xgmii_rxc_d0 <= xgmii_rxc;
        xgmii_rxc_d1 <= xgmii_rxc_d0;
        xgmii_rxc_d2 <= xgmii_rxc_d1;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
            crc_valid0_save <= 1'b0;
            crc_valid1_save <= 1'b0;
            crc_valid2_save <= 1'b0;
            crc_valid3_save <= 1'b0;
        end else if (update_crc) begin
            crc_state <= crc_next3;
            crc_valid0_save <= crc_valid0;
            crc_valid1_save <= crc_valid1;
            crc_valid2_save <= crc_valid2;
            crc_valid3_save <= crc_valid3;
        end
    end

    m_axis_tdata_reg <= m_axis_tdata_next;
    m_axis_tkeep_reg <= m_axis_tkeep_next;
    m_axis_tlast_reg <= m_axis_tlast_next;
    m_axis_tuser_reg <= m_axis_tuser_next;

    last_cycle_tkeep_reg <= last_cycle_tkeep_next;

    detect_term_save <= detect_term;

    xgmii_rxd_d0 <= xgmii_rxd;
    xgmii_rxd_d1 <= xgmii_rxd_d0;
    xgmii_rxd_d2 <= xgmii_rxd_d1;
end

endmodule
