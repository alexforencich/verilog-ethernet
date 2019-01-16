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
module axis_xgmii_rx_64
(
    input  wire        clk,
    input  wire        rst,

    /*
     * XGMII input
     */
    input  wire [63:0] xgmii_rxd,
    input  wire [7:0]  xgmii_rxc,

    /*
     * AXI output
     */
    output wire [63:0] m_axis_tdata,
    output wire [7:0]  m_axis_tkeep,
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
    STATE_PAYLOAD = 3'd1,
    STATE_LAST = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [7:0] last_cycle_tkeep_reg = 8'd0, last_cycle_tkeep_next;

reg lanes_swapped = 1'b0;
reg [31:0] swap_rxd = 32'd0;
reg [3:0] swap_rxc = 4'd0;

reg [63:0] xgmii_rxd_d0 = 32'd0;
reg [63:0] xgmii_rxd_d1 = 32'd0;
reg [63:0] xgmii_rxd_crc = 32'd0;

reg [7:0] xgmii_rxc_d0 = 8'd0;
reg [7:0] xgmii_rxc_d1 = 8'd0;

reg [63:0] m_axis_tdata_reg = 64'd0, m_axis_tdata_next;
reg [7:0] m_axis_tkeep_reg = 8'd0, m_axis_tkeep_next;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg m_axis_tlast_reg = 1'b0, m_axis_tlast_next;
reg m_axis_tuser_reg = 1'b0, m_axis_tuser_next;

reg error_bad_frame_reg = 1'b0, error_bad_frame_next;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
reg [31:0] crc_state3 = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next7;

wire crc_valid0 = crc_next0 == ~32'h2144df1c;
wire crc_valid1 = crc_next1 == ~32'h2144df1c;
wire crc_valid2 = crc_next2 == ~32'h2144df1c;
wire crc_valid3 = crc_next3 == ~32'h2144df1c;
wire crc_valid7 = crc_next7 == ~32'h2144df1c;

reg crc_valid7_save = 1'b0;

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
    .data_in(xgmii_rxd_crc[7:0]),
    .state_in(last_cycle ? crc_state3 : crc_state),
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
    .data_in(xgmii_rxd_crc[15:0]),
    .state_in(last_cycle ? crc_state3 : crc_state),
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
    .data_in(xgmii_rxd_crc[23:0]),
    .state_in(last_cycle ? crc_state3 : crc_state),
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
    .data_in(xgmii_rxd_crc[31:0]),
    .state_in(last_cycle ? crc_state3 : crc_state),
    .data_out(),
    .state_out(crc_next3)
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
    .data_in(xgmii_rxd_d0[63:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next7)
);

// detect control characters
reg [7:0] detect_start;
reg [7:0] detect_term;
reg [7:0] detect_error;

reg [7:0] detect_term_save = 8'd0;

integer i;

always @* begin
    for (i = 0; i < 8; i = i + 1) begin
        detect_start[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_START);
        detect_term[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_TERM);
        detect_error[i] = xgmii_rxc_d0[i] && (xgmii_rxd_d0[i*8 +: 8] == XGMII_ERROR);
    end
end

// mask errors to within packet
reg [7:0] detect_error_masked;
reg [7:0] control_masked;
reg [7:0] tkeep_mask;

always @* begin
    casez (detect_term)
    8'b00000000: begin
        detect_error_masked = detect_error;
        control_masked = xgmii_rxc_d0;
        tkeep_mask = 8'b11111111;
    end
    8'bzzzzzzz1: begin
        detect_error_masked = 0;
        control_masked = 0;
        tkeep_mask = 8'b00000000;
    end
    8'bzzzzzz10: begin
        detect_error_masked = detect_error[0];
        control_masked = xgmii_rxc_d0[0];
        tkeep_mask = 8'b00000001;
    end
    8'bzzzzz100: begin
        detect_error_masked = detect_error[1:0];
        control_masked = xgmii_rxc_d0[1:0];
        tkeep_mask = 8'b00000011;
    end
    8'bzzzz1000: begin
        detect_error_masked = detect_error[2:0];
        control_masked = xgmii_rxc_d0[2:0];
        tkeep_mask = 8'b00000111;
    end
    8'bzzz10000: begin
        detect_error_masked = detect_error[3:0];
        control_masked = xgmii_rxc_d0[3:0];
        tkeep_mask = 8'b00001111;
    end
    8'bzz100000: begin
        detect_error_masked = detect_error[4:0];
        control_masked = xgmii_rxc_d0[4:0];
        tkeep_mask = 8'b00011111;
    end
    8'bz1000000: begin
        detect_error_masked = detect_error[5:0];
        control_masked = xgmii_rxc_d0[5:0];
        tkeep_mask = 8'b00111111;
    end
    8'b10000000: begin
        detect_error_masked = detect_error[6:0];
        control_masked = xgmii_rxc_d0[6:0];
        tkeep_mask = 8'b01111111;
    end
    default: begin
        detect_error_masked = detect_error;
        control_masked = xgmii_rxc_d0;
        tkeep_mask = 8'b11111111;
    end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    last_cycle_tkeep_next = last_cycle_tkeep_reg;

    m_axis_tdata_next = 64'd0;
    m_axis_tkeep_next = 8'd0;
    m_axis_tvalid_next = 1'b0;
    m_axis_tlast_next = 1'b0;
    m_axis_tuser_next = 1'b0;

    error_bad_frame_next = 1'b0;
    error_bad_fcs_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for packet
            reset_crc = 1'b1;

            if (xgmii_rxc_d1[0] && xgmii_rxd_d1[7:0] == XGMII_START) begin
                // start condition
                if (control_masked) begin
                    // control or error characters in first data word
                    m_axis_tdata_next = 64'd0;
                    m_axis_tkeep_next = 8'h01;
                    m_axis_tvalid_next = 1'b1;
                    m_axis_tlast_next = 1'b1;
                    m_axis_tuser_next = 1'b1;
                    error_bad_frame_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    reset_crc = 1'b0;
                    update_crc = 1'b1;
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // read payload
            update_crc = 1'b1;

            m_axis_tdata_next = xgmii_rxd_d1;
            m_axis_tkeep_next = ~xgmii_rxc_d1;
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
                if (detect_term[4:0]) begin
                    // end this cycle
                    reset_crc = 1'b1;
                    m_axis_tkeep_next = {tkeep_mask[3:0], 4'b1111};
                    m_axis_tlast_next = 1'b1;
                    if ((detect_term[0] && crc_valid7_save) ||
                        (detect_term[1] && crc_valid0) ||
                        (detect_term[2] && crc_valid1) ||
                        (detect_term[3] && crc_valid2) ||
                        (detect_term[4] && crc_valid3)) begin
                        // CRC valid
                    end else begin
                        m_axis_tuser_next = 1'b1;
                        error_bad_frame_next = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    // need extra cycle
                    last_cycle_tkeep_next = {4'b0000, tkeep_mask[7:4]};
                    state_next = STATE_LAST;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_LAST: begin
            // last cycle of packet
            m_axis_tdata_next = xgmii_rxd_d1;
            m_axis_tkeep_next = last_cycle_tkeep_reg;
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b1;
            m_axis_tuser_next = 1'b0;

            reset_crc = 1'b1;

            if ((detect_term_save[5] && crc_valid0) ||
                (detect_term_save[6] && crc_valid1) ||
                (detect_term_save[7] && crc_valid2)) begin
                // CRC valid
            end else begin
                m_axis_tuser_next = 1'b1;
                error_bad_frame_next = 1'b1;
                error_bad_fcs_next = 1'b1;
            end

            if (xgmii_rxc_d1[0] && xgmii_rxd_d1[7:0] == XGMII_START) begin
                // start condition
                if (control_masked) begin
                    // control or error characters in first data word
                    m_axis_tdata_next = 64'd0;
                    m_axis_tkeep_next = 8'h01;
                    m_axis_tvalid_next = 1'b1;
                    m_axis_tlast_next = 1'b1;
                    m_axis_tuser_next = 1'b1;
                    error_bad_frame_next = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    reset_crc = 1'b0;
                    update_crc = 1'b1;
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_IDLE;
            end
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
        crc_state3 <= 32'hFFFFFFFF;
        crc_valid7_save <= 1'b0;

        xgmii_rxc_d0 <= 8'd0;
        xgmii_rxc_d1 <= 8'd0;

        lanes_swapped <= 1'b0;
    end else begin
        state_reg <= state_next;

        m_axis_tvalid_reg <= m_axis_tvalid_next;

        error_bad_frame_reg <= error_bad_frame_next;
        error_bad_fcs_reg <= error_bad_fcs_next;

        if (xgmii_rxc[0] && xgmii_rxd[7:0] == XGMII_START) begin
            lanes_swapped <= 1'b0;
            xgmii_rxc_d0 <= xgmii_rxc;
        end else if (xgmii_rxc[4] && xgmii_rxd[39:32] == XGMII_START) begin
            lanes_swapped <= 1'b1;
            xgmii_rxc_d0 <= {xgmii_rxc[3:0], swap_rxc};
        end else if (lanes_swapped) begin
            xgmii_rxc_d0 <= {xgmii_rxc[3:0], swap_rxc};
        end else begin
            xgmii_rxc_d0 <= xgmii_rxc;
        end

        xgmii_rxc_d1 <= xgmii_rxc_d0;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
            crc_state3 <= 32'hFFFFFFFF;
            crc_valid7_save <= 1'b0;
        end else if (update_crc) begin
            crc_state <= crc_next7;
            crc_state3 <= crc_next3;
            crc_valid7_save <= crc_valid7;
        end
    end

    m_axis_tdata_reg <= m_axis_tdata_next;
    m_axis_tkeep_reg <= m_axis_tkeep_next;
    m_axis_tlast_reg <= m_axis_tlast_next;
    m_axis_tuser_reg <= m_axis_tuser_next;

    last_cycle_tkeep_reg <= last_cycle_tkeep_next;

    detect_term_save <= detect_term;

    swap_rxd <= xgmii_rxd[63:32];
    swap_rxc <= xgmii_rxc[7:4];

    if (xgmii_rxc[0] && xgmii_rxd[7:0] == XGMII_START) begin
        xgmii_rxd_d0 <= xgmii_rxd;
        xgmii_rxd_crc <= xgmii_rxd;
    end else if (xgmii_rxc[4] && xgmii_rxd[39:32] == XGMII_START) begin
        xgmii_rxd_d0 <= {xgmii_rxd[31:0], swap_rxd};
        xgmii_rxd_crc <= {xgmii_rxd[31:0], swap_rxd};
    end else if (lanes_swapped) begin
        xgmii_rxd_d0 <= {xgmii_rxd[31:0], swap_rxd};
        xgmii_rxd_crc <= {xgmii_rxd[31:0], swap_rxd};
    end else begin
        xgmii_rxd_d0 <= xgmii_rxd;
        xgmii_rxd_crc <= xgmii_rxd;
    end

    if (state_next == STATE_LAST) begin
        xgmii_rxd_crc[31:0] <= xgmii_rxd_crc[63:32];
    end

    xgmii_rxd_d1 <= xgmii_rxd_d0;
end

endmodule
