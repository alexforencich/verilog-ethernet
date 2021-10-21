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
 * AXI4-Stream GMII frame receiver (GMII in, AXI out)
 */
module axis_gmii_rx #
(
    parameter DATA_WIDTH = 8,
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_WIDTH = 96,
    parameter USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * GMII input
     */
    input  wire [DATA_WIDTH-1:0]    gmii_rxd,
    input  wire                     gmii_rx_dv,
    input  wire                     gmii_rx_er,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]    m_axis_tdata,
    output wire                     m_axis_tvalid,
    output wire                     m_axis_tlast,
    output wire [USER_WIDTH-1:0]    m_axis_tuser,

    /*
     * PTP
     */
    input  wire [PTP_TS_WIDTH-1:0]  ptp_ts,

    /*
     * Control
     */
    input  wire                     clk_enable,
    input  wire                     mii_select,

    /*
     * Status
     */
    output wire                     start_packet,
    output wire                     error_bad_frame,
    output wire                     error_bad_fcs
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 8) begin
        $error("Error: Interface width must be 8");
        $finish;
    end
end

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PAYLOAD = 3'd1,
    STATE_WAIT_LAST = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg mii_odd = 1'b0;
reg mii_locked = 1'b0;

reg [DATA_WIDTH-1:0] gmii_rxd_d0 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] gmii_rxd_d1 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] gmii_rxd_d2 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] gmii_rxd_d3 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] gmii_rxd_d4 = {DATA_WIDTH{1'b0}};

reg gmii_rx_dv_d0 = 1'b0;
reg gmii_rx_dv_d1 = 1'b0;
reg gmii_rx_dv_d2 = 1'b0;
reg gmii_rx_dv_d3 = 1'b0;
reg gmii_rx_dv_d4 = 1'b0;

reg gmii_rx_er_d0 = 1'b0;
reg gmii_rx_er_d1 = 1'b0;
reg gmii_rx_er_d2 = 1'b0;
reg gmii_rx_er_d3 = 1'b0;
reg gmii_rx_er_d4 = 1'b0;

reg [DATA_WIDTH-1:0] m_axis_tdata_reg = {DATA_WIDTH{1'b0}}, m_axis_tdata_next;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg m_axis_tlast_reg = 1'b0, m_axis_tlast_next;
reg m_axis_tuser_reg = 1'b0, m_axis_tuser_next;

reg start_packet_reg = 1'b0, start_packet_next;
reg error_bad_frame_reg = 1'b0, error_bad_frame_next;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg [PTP_TS_WIDTH-1:0] ptp_ts_reg = 0, ptp_ts_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
wire [31:0] crc_next;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tuser = PTP_TS_ENABLE ? {ptp_ts_reg, m_axis_tuser_reg} : m_axis_tuser_reg;

assign start_packet = start_packet_reg;
assign error_bad_frame = error_bad_frame_reg;
assign error_bad_fcs = error_bad_fcs_reg;

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
    .data_in(gmii_rxd_d4),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    m_axis_tdata_next = {DATA_WIDTH{1'b0}};
    m_axis_tvalid_next = 1'b0;
    m_axis_tlast_next = 1'b0;
    m_axis_tuser_next = 1'b0;

    start_packet_next = 1'b0;
    error_bad_frame_next = 1'b0;
    error_bad_fcs_next = 1'b0;

    ptp_ts_next = ptp_ts_reg;

    if (!clk_enable) begin
        // clock disabled - hold state
        state_next = state_reg;
    end else if (mii_select && !mii_odd) begin
        // MII even cycle - hold state
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // idle state - wait for packet
                reset_crc = 1'b1;

                if (gmii_rx_dv_d4 && !gmii_rx_er_d4 && gmii_rxd_d4 == ETH_SFD) begin
                    ptp_ts_next = ptp_ts;
                    start_packet_next = 1'b1;
                    state_next = STATE_PAYLOAD;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_PAYLOAD: begin
                // read payload
                update_crc = 1'b1;

                m_axis_tdata_next = gmii_rxd_d4;
                m_axis_tvalid_next = 1'b1;

                if (gmii_rx_dv_d4 && gmii_rx_er_d4) begin
                    // error
                    m_axis_tlast_next = 1'b1;
                    m_axis_tuser_next = 1'b1;
                    error_bad_frame_next = 1'b1;
                    state_next = STATE_WAIT_LAST;
                end else if (!gmii_rx_dv) begin
                    // end of packet
                    m_axis_tlast_next = 1'b1;
                    if (gmii_rx_er_d0 || gmii_rx_er_d1 || gmii_rx_er_d2 || gmii_rx_er_d3) begin
                        // error received in FCS bytes
                        m_axis_tuser_next = 1'b1;
                        error_bad_frame_next = 1'b1;
                    end else if ({gmii_rxd_d0, gmii_rxd_d1, gmii_rxd_d2, gmii_rxd_d3} == ~crc_next) begin
                        // FCS good
                        m_axis_tuser_next = 1'b0;
                    end else begin
                        // FCS bad
                        m_axis_tuser_next = 1'b1;
                        error_bad_frame_next = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end
            STATE_WAIT_LAST: begin
                // wait for end of packet

                if (~gmii_rx_dv) begin
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WAIT_LAST;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    state_reg <= state_next;

    ptp_ts_reg <= ptp_ts_next;

    m_axis_tdata_reg <= m_axis_tdata_next;
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tlast_reg <= m_axis_tlast_next;
    m_axis_tuser_reg <= m_axis_tuser_next;

    if (clk_enable) begin
        if (mii_select) begin
            mii_odd <= !mii_odd;

            if (mii_locked) begin
                mii_locked <= gmii_rx_dv;
            end else if (gmii_rx_dv && {gmii_rxd[3:0], gmii_rxd_d0[7:4]} == ETH_SFD) begin
                mii_locked <= 1'b1;
                mii_odd <= 1'b1;
            end

            gmii_rxd_d0 <= {gmii_rxd[3:0], gmii_rxd_d0[7:4]};

            if (mii_odd) begin
                gmii_rxd_d1 <= gmii_rxd_d0;
                gmii_rxd_d2 <= gmii_rxd_d1;
                gmii_rxd_d3 <= gmii_rxd_d2;
                gmii_rxd_d4 <= gmii_rxd_d3;

                gmii_rx_dv_d0 <= gmii_rx_dv & gmii_rx_dv_d0;
                gmii_rx_dv_d1 <= gmii_rx_dv_d0 & gmii_rx_dv;
                gmii_rx_dv_d2 <= gmii_rx_dv_d1 & gmii_rx_dv;
                gmii_rx_dv_d3 <= gmii_rx_dv_d2 & gmii_rx_dv;
                gmii_rx_dv_d4 <= gmii_rx_dv_d3 & gmii_rx_dv;

                gmii_rx_er_d0 <= gmii_rx_er | gmii_rx_er_d0;
                gmii_rx_er_d1 <= gmii_rx_er_d0;
                gmii_rx_er_d2 <= gmii_rx_er_d1;
                gmii_rx_er_d3 <= gmii_rx_er_d2;
                gmii_rx_er_d4 <= gmii_rx_er_d3;
            end else begin
                gmii_rx_dv_d0 <= gmii_rx_dv;
                gmii_rx_er_d0 <= gmii_rx_er;
            end
        end else begin
            gmii_rxd_d0 <= gmii_rxd;
            gmii_rxd_d1 <= gmii_rxd_d0;
            gmii_rxd_d2 <= gmii_rxd_d1;
            gmii_rxd_d3 <= gmii_rxd_d2;
            gmii_rxd_d4 <= gmii_rxd_d3;

            gmii_rx_dv_d0 <= gmii_rx_dv;
            gmii_rx_dv_d1 <= gmii_rx_dv_d0 & gmii_rx_dv;
            gmii_rx_dv_d2 <= gmii_rx_dv_d1 & gmii_rx_dv;
            gmii_rx_dv_d3 <= gmii_rx_dv_d2 & gmii_rx_dv;
            gmii_rx_dv_d4 <= gmii_rx_dv_d3 & gmii_rx_dv;

            gmii_rx_er_d0 <= gmii_rx_er;
            gmii_rx_er_d1 <= gmii_rx_er_d0;
            gmii_rx_er_d2 <= gmii_rx_er_d1;
            gmii_rx_er_d3 <= gmii_rx_er_d2;
            gmii_rx_er_d4 <= gmii_rx_er_d3;
        end
    end

    if (reset_crc) begin
        crc_state <= 32'hFFFFFFFF;
    end else if (update_crc) begin
        crc_state <= crc_next;
    end

    start_packet_reg <= start_packet_next;
    error_bad_frame_reg <= error_bad_frame_next;
    error_bad_fcs_reg <= error_bad_fcs_next;

    if (rst) begin
        state_reg <= STATE_IDLE;

        m_axis_tvalid_reg <= 1'b0;

        start_packet_reg <= 1'b0;
        error_bad_frame_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;

        mii_locked <= 1'b0;
        mii_odd <= 1'b0;

        gmii_rx_dv_d0 <= 1'b0;
        gmii_rx_dv_d1 <= 1'b0;
        gmii_rx_dv_d2 <= 1'b0;
        gmii_rx_dv_d3 <= 1'b0;
        gmii_rx_dv_d4 <= 1'b0;
    end
end

endmodule

`resetall
