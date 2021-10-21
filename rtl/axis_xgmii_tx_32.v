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
module axis_xgmii_tx_32 #
(
    parameter DATA_WIDTH = 32,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
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
    input  wire [7:0]                ifg_delay,

    /*
     * Status
     */
    output wire                      start_packet,
    output wire                      error_underflow
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

localparam MIN_FL_NOCRC = MIN_FRAME_LENGTH-4;
localparam MIN_FL_NOCRC_MS = MIN_FL_NOCRC & 16'hfffc;
localparam MIN_FL_NOCRC_LS = MIN_FL_NOCRC & 16'h0003;

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [7:0]
    XGMII_IDLE = 8'h07,
    XGMII_START = 8'hfb,
    XGMII_TERM = 8'hfd,
    XGMII_ERROR = 8'hfe;

localparam [3:0]
    STATE_IDLE = 4'd0,
    STATE_PREAMBLE = 4'd1,
    STATE_PAYLOAD = 4'd2,
    STATE_PAD = 4'd3,
    STATE_FCS_1 = 4'd4,
    STATE_FCS_2 = 4'd5,
    STATE_FCS_3 = 4'd6,
    STATE_IFG = 4'd7,
    STATE_WAIT_END = 4'd8;

reg [3:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [DATA_WIDTH-1:0] s_axis_tdata_masked;

reg [DATA_WIDTH-1:0] s_tdata_reg ={DATA_WIDTH{1'b0}}, s_tdata_next;
reg [KEEP_WIDTH-1:0] s_tkeep_reg = {KEEP_WIDTH{1'b0}}, s_tkeep_next;

reg [DATA_WIDTH-1:0] fcs_output_txd_0;
reg [DATA_WIDTH-1:0] fcs_output_txd_1;
reg [CTRL_WIDTH-1:0] fcs_output_txc_0;
reg [CTRL_WIDTH-1:0] fcs_output_txc_1;

reg [7:0] ifg_offset;

reg extra_cycle;

reg [15:0] frame_ptr_reg = 16'd0, frame_ptr_next;

reg [7:0] ifg_count_reg = 8'd0, ifg_count_next;
reg [1:0] deficit_idle_count_reg = 2'd0, deficit_idle_count_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [PTP_TS_WIDTH-1:0] m_axis_ptp_ts_reg = 0, m_axis_ptp_ts_next;
reg [PTP_TAG_WIDTH-1:0] m_axis_ptp_ts_tag_reg = 0, m_axis_ptp_ts_tag_next;
reg m_axis_ptp_ts_valid_reg = 1'b0, m_axis_ptp_ts_valid_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;

reg [DATA_WIDTH-1:0] xgmii_txd_reg = {CTRL_WIDTH{XGMII_IDLE}}, xgmii_txd_next;
reg [CTRL_WIDTH-1:0] xgmii_txc_reg = {CTRL_WIDTH{1'b1}}, xgmii_txc_next;

reg start_packet_reg = 1'b0, start_packet_next;
reg error_underflow_reg = 1'b0, error_underflow_next;

assign s_axis_tready = s_axis_tready_reg;

assign xgmii_txd = xgmii_txd_reg;
assign xgmii_txc = xgmii_txc_reg;

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

function [2:0] keep2count;
    input [3:0] k;
    casez (k)
        4'bzzz0: keep2count = 3'd0;
        4'bzz01: keep2count = 3'd1;
        4'bz011: keep2count = 3'd2;
        4'b0111: keep2count = 3'd3;
        4'b1111: keep2count = 3'd4;
    endcase
endfunction

// Mask input data
integer j;

always @* begin
    for (j = 0; j < 4; j = j + 1) begin
        s_axis_tdata_masked[j*8 +: 8] = s_axis_tkeep[j] ? s_axis_tdata[j*8 +: 8] : 8'd0;
    end
end

// FCS cycle calculation
always @* begin
    casez (s_tkeep_reg)
        4'bzz01: begin
            fcs_output_txd_0 = {~crc_next0[23:0], s_tdata_reg[7:0]};
            fcs_output_txd_1 = {{2{XGMII_IDLE}}, XGMII_TERM, ~crc_next0[31:24]};
            fcs_output_txc_0 = 4'b0000;
            fcs_output_txc_1 = 4'b1110;
            ifg_offset = 8'd3;
            extra_cycle = 1'b0;
        end
        4'bz011: begin
            fcs_output_txd_0 = {~crc_next1[15:0], s_tdata_reg[15:0]};
            fcs_output_txd_1 = {XGMII_IDLE, XGMII_TERM, ~crc_next1[31:16]};
            fcs_output_txc_0 = 4'b0000;
            fcs_output_txc_1 = 4'b1100;
            ifg_offset = 8'd2;
            extra_cycle = 1'b0;
        end
        4'b0111: begin
            fcs_output_txd_0 = {~crc_next2[7:0], s_tdata_reg[23:0]};
            fcs_output_txd_1 = {XGMII_TERM, ~crc_next2[31:8]};
            fcs_output_txc_0 = 4'b0000;
            fcs_output_txc_1 = 4'b1000;
            ifg_offset = 8'd1;
            extra_cycle = 1'b0;
        end
        4'b1111: begin
            fcs_output_txd_0 = s_tdata_reg;
            fcs_output_txd_1 = ~crc_next3;
            fcs_output_txc_0 = 4'b0000;
            fcs_output_txc_1 = 4'b0000;
            ifg_offset = 8'd4;
            extra_cycle = 1'b1;
        end
        default: begin
            fcs_output_txd_0 = {CTRL_WIDTH{XGMII_ERROR}};
            fcs_output_txd_1 = {CTRL_WIDTH{XGMII_ERROR}};
            fcs_output_txc_0 = {CTRL_WIDTH{1'b1}};
            fcs_output_txc_1 = {CTRL_WIDTH{1'b1}};
            ifg_offset = 8'd0;
            extra_cycle = 1'b0;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    frame_ptr_next = frame_ptr_reg;

    ifg_count_next = ifg_count_reg;
    deficit_idle_count_next = deficit_idle_count_reg;

    s_axis_tready_next = 1'b0;

    s_tdata_next = s_tdata_reg;
    s_tkeep_next = s_tkeep_reg;

    m_axis_ptp_ts_next = m_axis_ptp_ts_reg;
    m_axis_ptp_ts_tag_next = m_axis_ptp_ts_tag_reg;
    m_axis_ptp_ts_valid_next = 1'b0;

    // XGMII idle
    xgmii_txd_next = {CTRL_WIDTH{XGMII_IDLE}};
    xgmii_txc_next = {CTRL_WIDTH{1'b1}};

    start_packet_next = 1'b0;
    error_underflow_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 16'd4;
            reset_crc = 1'b1;

            // XGMII idle
            xgmii_txd_next = {CTRL_WIDTH{XGMII_IDLE}};
            xgmii_txc_next = {CTRL_WIDTH{1'b1}};

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                // XGMII start and preamble
                xgmii_txd_next = {{3{ETH_PRE}}, XGMII_START};
                xgmii_txc_next = 4'b0001;
                s_axis_tready_next = 1'b1;
                state_next = STATE_PREAMBLE;
            end else begin
                ifg_count_next = 8'd0;
                deficit_idle_count_next = 2'd0;
                state_next = STATE_IDLE;
            end
        end
        STATE_PREAMBLE: begin
            // send preamble

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            xgmii_txd_next = {ETH_SFD, {3{ETH_PRE}}};
            xgmii_txc_next = 4'b0000;
            s_axis_tready_next = 1'b1;
            m_axis_ptp_ts_next = ptp_ts;
            m_axis_ptp_ts_tag_next = s_axis_tuser >> 1;
            m_axis_ptp_ts_valid_next = 1'b1;
            start_packet_next = 1'b1;
            state_next = STATE_PAYLOAD;
        end
        STATE_PAYLOAD: begin
            // transfer payload
            update_crc = 1'b1;
            s_axis_tready_next = 1'b1;

            frame_ptr_next = frame_ptr_reg + 16'd4;

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = 4'b0000;

            s_tdata_next = s_axis_tdata_masked;
            s_tkeep_next = s_axis_tkeep;

            if (s_axis_tvalid) begin
                if (s_axis_tlast) begin
                    frame_ptr_next = frame_ptr_reg + keep2count(s_axis_tkeep);
                    s_axis_tready_next = 1'b0;
                    if (s_axis_tuser[0]) begin
                        xgmii_txd_next = {XGMII_TERM, {3{XGMII_ERROR}}};
                        xgmii_txc_next = 4'b1111;
                        frame_ptr_next = 16'd0;
                        ifg_count_next = 8'd10;
                        state_next = STATE_IFG;
                    end else begin
                        s_axis_tready_next = 1'b0;

                        if (ENABLE_PADDING && (frame_ptr_reg < MIN_FL_NOCRC_MS || (frame_ptr_reg == MIN_FL_NOCRC_MS && keep2count(s_axis_tkeep) < MIN_FL_NOCRC_LS))) begin
                            s_tkeep_next = 4'hf;
                            frame_ptr_next = frame_ptr_reg + 16'd4;

                            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-4)) begin
                                state_next = STATE_PAD;
                            end else begin
                                s_tkeep_next = 4'hf >> ((4-MIN_FL_NOCRC_LS) % 4);

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
                xgmii_txd_next = {XGMII_TERM, {3{XGMII_ERROR}}};
                xgmii_txc_next = 4'b1111;
                frame_ptr_next = 16'd0;
                ifg_count_next = 8'd10;
                error_underflow_next = 1'b1;
                state_next = STATE_WAIT_END;
            end
        end
        STATE_PAD: begin
            // pad frame to MIN_FRAME_LENGTH
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = s_tdata_reg;
            xgmii_txc_next = {CTRL_WIDTH{1'b0}};

            s_tdata_next = 32'd0;
            s_tkeep_next = 4'hf;

            update_crc = 1'b1;
            frame_ptr_next = frame_ptr_reg + 16'd4;

            if (frame_ptr_reg < (MIN_FL_NOCRC_LS > 0 ? MIN_FL_NOCRC_MS : MIN_FL_NOCRC_MS-4)) begin
                state_next = STATE_PAD;
            end else begin
                s_tkeep_next = 4'hf >> ((4-MIN_FL_NOCRC_LS) % 4);

                state_next = STATE_FCS_1;
            end
        end
        STATE_FCS_1: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = fcs_output_txd_0;
            xgmii_txc_next = fcs_output_txc_0;

            frame_ptr_next = 16'd0;

            ifg_count_next = (ifg_delay > 8'd12 ? ifg_delay : 8'd12) - ifg_offset + deficit_idle_count_reg;
            state_next = STATE_FCS_2;
        end
        STATE_FCS_2: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = fcs_output_txd_1;
            xgmii_txc_next = fcs_output_txc_1;

            frame_ptr_next = 16'd0;

            if (extra_cycle) begin
                state_next = STATE_FCS_3;
            end else begin
                state_next = STATE_IFG;
            end
        end
        STATE_FCS_3: begin
            // last cycle
            s_axis_tready_next = 1'b0;

            xgmii_txd_next = {{3{XGMII_IDLE}}, XGMII_TERM};
            xgmii_txc_next = 4'b1111;

            reset_crc = 1'b1;
            frame_ptr_next = 16'd0;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd3) begin
                    state_next = STATE_IFG;
                end else begin
                    deficit_idle_count_next = ifg_count_next;
                    ifg_count_next = 8'd0;
                    s_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd0) begin
                    state_next = STATE_IFG;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_IFG: begin
            // send IFG
            if (ifg_count_reg > 8'd4) begin
                ifg_count_next = ifg_count_reg - 8'd4;
            end else begin
                ifg_count_next = 8'd0;
            end

            reset_crc = 1'b1;

            if (ENABLE_DIC) begin
                if (ifg_count_next > 8'd3) begin
                    state_next = STATE_IFG;
                end else begin
                    deficit_idle_count_next = ifg_count_next;
                    ifg_count_next = 8'd0;
                    state_next = STATE_IDLE;
                end
            end else begin
                if (ifg_count_next > 8'd0) begin
                    state_next = STATE_IFG;
                end else begin
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
                        if (ifg_count_next > 8'd3) begin
                            state_next = STATE_IFG;
                        end else begin
                            deficit_idle_count_next = ifg_count_next;
                            ifg_count_next = 8'd0;
                            state_next = STATE_IDLE;
                        end
                    end else begin
                        if (ifg_count_next > 8'd0) begin
                            state_next = STATE_IFG;
                        end else begin
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

    if (reset_crc) begin
        crc_state <= 32'hFFFFFFFF;
    end else if (update_crc) begin
        crc_state <= crc_next3;
    end

    xgmii_txd_reg <= xgmii_txd_next;
    xgmii_txc_reg <= xgmii_txc_next;

    start_packet_reg <= start_packet_next;
    error_underflow_reg <= error_underflow_next;

    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_ptr_reg <= 16'd0;

        ifg_count_reg <= 8'd0;
        deficit_idle_count_reg <= 2'd0;

        s_axis_tready_reg <= 1'b0;

        m_axis_ptp_ts_valid_reg <= 1'b0;

        xgmii_txd_reg <= {CTRL_WIDTH{XGMII_IDLE}};
        xgmii_txc_reg <= {CTRL_WIDTH{1'b1}};

        start_packet_reg <= 1'b0;
        error_underflow_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
    end
end

endmodule

`resetall
