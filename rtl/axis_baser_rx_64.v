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
 * AXI4-Stream 10GBASE-R frame receiver (10GBASE-R in, AXI out)
 */
module axis_baser_rx_64 #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = 2,
    parameter PTP_PERIOD_NS = 4'h6,
    parameter PTP_PERIOD_FNS = 16'h6666,
    parameter PTP_TS_ENABLE = 0,
    parameter PTP_TS_WIDTH = 96,
    parameter USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * 10GBASE-R encoded input
     */
    input  wire [DATA_WIDTH-1:0]    encoded_rx_data,
    input  wire [HDR_WIDTH-1:0]     encoded_rx_hdr,

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
     * Status
     */
    output wire [1:0]               start_packet,
    output wire                     error_bad_frame,
    output wire                     error_bad_fcs,
    output wire                     rx_bad_block
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

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [7:0]
    XGMII_IDLE = 8'h07,
    XGMII_START = 8'hfb,
    XGMII_TERM = 8'hfd,
    XGMII_ERROR = 8'hfe;

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
    INPUT_TYPE_IDLE = 4'd0,
    INPUT_TYPE_ERROR = 4'd1,
    INPUT_TYPE_START_0 = 4'd2,
    INPUT_TYPE_START_4 = 4'd3,
    INPUT_TYPE_DATA = 4'd4,
    INPUT_TYPE_TERM_0 = 4'd8,
    INPUT_TYPE_TERM_1 = 4'd9,
    INPUT_TYPE_TERM_2 = 4'd10,
    INPUT_TYPE_TERM_3 = 4'd11,
    INPUT_TYPE_TERM_4 = 4'd12,
    INPUT_TYPE_TERM_5 = 4'd13,
    INPUT_TYPE_TERM_6 = 4'd14,
    INPUT_TYPE_TERM_7 = 4'd15;

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1,
    STATE_LAST = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc_last;

reg lanes_swapped = 1'b0;
reg [31:0] swap_data = 32'd0;

reg delay_type_valid = 1'b0;
reg [3:0] delay_type = INPUT_TYPE_IDLE;

reg [DATA_WIDTH-1:0] input_data_d0 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] input_data_d1 = {DATA_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0] input_data_crc = {DATA_WIDTH{1'b0}};

reg [3:0] input_type_d0 = INPUT_TYPE_IDLE;
reg [3:0] input_type_d1 = INPUT_TYPE_IDLE;

reg [DATA_WIDTH-1:0] m_axis_tdata_reg = {DATA_WIDTH{1'b0}}, m_axis_tdata_next;
reg [KEEP_WIDTH-1:0] m_axis_tkeep_reg = {KEEP_WIDTH{1'b0}}, m_axis_tkeep_next;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg m_axis_tlast_reg = 1'b0, m_axis_tlast_next;
reg m_axis_tuser_reg = 1'b0, m_axis_tuser_next;

reg [1:0] start_packet_reg = 2'b00;
reg error_bad_frame_reg = 1'b0, error_bad_frame_next;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;
reg rx_bad_block_reg = 1'b0;

reg [PTP_TS_WIDTH-1:0] ptp_ts_reg = 0;

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
assign m_axis_tuser = PTP_TS_ENABLE ? {ptp_ts_reg, m_axis_tuser_reg} : m_axis_tuser_reg;

assign start_packet = start_packet_reg;
assign error_bad_frame = error_bad_frame_reg;
assign error_bad_fcs = error_bad_fcs_reg;
assign rx_bad_block = rx_bad_block_reg;

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
    .data_in(input_data_crc[7:0]),
    .state_in(crc_state3),
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
    .data_in(input_data_crc[15:0]),
    .state_in(crc_state3),
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
    .data_in(input_data_crc[23:0]),
    .state_in(crc_state3),
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
    .data_in(input_data_crc[31:0]),
    .state_in(crc_state3),
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
    .data_in(input_data_d0[63:0]),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next7)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc_last = 1'b0;

    m_axis_tdata_next = input_data_d1;
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

            if (input_type_d1 == INPUT_TYPE_START_0) begin
                // start condition
                reset_crc = 1'b0;
                state_next = STATE_PAYLOAD;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // read payload
            m_axis_tdata_next = input_data_d1;
            m_axis_tkeep_next = 8'hff;
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b0;
            m_axis_tuser_next = 1'b0;

            if (input_type_d0 == INPUT_TYPE_DATA) begin
                state_next = STATE_PAYLOAD;
            end else if (input_type_d0[3]) begin
                // INPUT_TYPE_TERM_*
                if (input_type_d0 <= INPUT_TYPE_TERM_4) begin
                    // end this cycle
                    reset_crc = 1'b1;
                    case (input_type_d0)
                        INPUT_TYPE_TERM_0: m_axis_tkeep_next = 8'b00001111;
                        INPUT_TYPE_TERM_1: m_axis_tkeep_next = 8'b00011111;
                        INPUT_TYPE_TERM_2: m_axis_tkeep_next = 8'b00111111;
                        INPUT_TYPE_TERM_3: m_axis_tkeep_next = 8'b01111111;
                        INPUT_TYPE_TERM_4: m_axis_tkeep_next = 8'b11111111;
                    endcase
                    m_axis_tlast_next = 1'b1;
                    if ((input_type_d0 == INPUT_TYPE_TERM_0 && crc_valid7_save) ||
                        (input_type_d0 == INPUT_TYPE_TERM_1 && crc_valid0) ||
                        (input_type_d0 == INPUT_TYPE_TERM_2 && crc_valid1) ||
                        (input_type_d0 == INPUT_TYPE_TERM_3 && crc_valid2) ||
                        (input_type_d0 == INPUT_TYPE_TERM_4 && crc_valid3)) begin
                        // CRC valid
                    end else begin
                        m_axis_tuser_next = 1'b1;
                        error_bad_frame_next = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    state_next = STATE_IDLE;
                end else begin
                    // need extra cycle
                    update_crc_last = 1'b1;
                    state_next = STATE_LAST;
                end
            end else begin
                // control or error characters in packet
                m_axis_tlast_next = 1'b1;
                m_axis_tuser_next = 1'b1;
                error_bad_frame_next = 1'b1;
                reset_crc = 1'b1;
                state_next = STATE_IDLE;
            end
        end
        STATE_LAST: begin
            // last cycle of packet
            m_axis_tdata_next = input_data_d1;
            m_axis_tkeep_next = 8'hff;
            m_axis_tvalid_next = 1'b1;
            m_axis_tlast_next = 1'b1;
            m_axis_tuser_next = 1'b0;

            reset_crc = 1'b1;

            case (input_type_d1)
                INPUT_TYPE_TERM_5: m_axis_tkeep_next = 8'b00000001;
                INPUT_TYPE_TERM_6: m_axis_tkeep_next = 8'b00000011;
                INPUT_TYPE_TERM_7: m_axis_tkeep_next = 8'b00000111;
            endcase

            if ((input_type_d1 == INPUT_TYPE_TERM_5 && crc_valid0) ||
                (input_type_d1 == INPUT_TYPE_TERM_6 && crc_valid1) ||
                (input_type_d1 == INPUT_TYPE_TERM_7 && crc_valid2)) begin
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
    state_reg <= state_next;

    m_axis_tdata_reg <= m_axis_tdata_next;
    m_axis_tkeep_reg <= m_axis_tkeep_next;
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tlast_reg <= m_axis_tlast_next;
    m_axis_tuser_reg <= m_axis_tuser_next;

    start_packet_reg <= 2'b00;
    error_bad_frame_reg <= error_bad_frame_next;
    error_bad_fcs_reg <= error_bad_fcs_next;
    rx_bad_block_reg <= 1'b0;

    delay_type_valid <= 1'b0;

    if (encoded_rx_hdr == SYNC_DATA) begin
        swap_data <= encoded_rx_data[63:32];
    end else begin
        swap_data <= {8'd0, encoded_rx_data[63:40]};
    end

    if (PTP_TS_WIDTH == 96 && $signed({1'b0, ptp_ts_reg[45:16]}) - $signed(31'd1000000000) > 0) begin
        // ns field rollover
        ptp_ts_reg[45:16] <= $signed({1'b0, ptp_ts_reg[45:16]}) - $signed(31'd1000000000);
        ptp_ts_reg[95:48] <= ptp_ts_reg[95:48] + 1;
    end

    if (encoded_rx_hdr == SYNC_CTRL && encoded_rx_data[7:0] == BLOCK_TYPE_START_0) begin
        lanes_swapped <= 1'b0;
        start_packet_reg <= 2'b01;
        input_type_d0 <= INPUT_TYPE_START_0;
        input_data_d0 <= encoded_rx_data;
        input_data_crc <= encoded_rx_data;

        if (PTP_TS_WIDTH == 96) begin
            ptp_ts_reg[45:0] <= ptp_ts[45:0] + (PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS);
            ptp_ts_reg[95:48] <= ptp_ts[95:48];
        end else begin
            ptp_ts_reg <= ptp_ts + (PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS);
        end
    end else if (encoded_rx_hdr == SYNC_CTRL && (encoded_rx_data[7:0] == BLOCK_TYPE_START_4 || encoded_rx_data[7:0] == BLOCK_TYPE_OS_START)) begin
        lanes_swapped <= 1'b1;
        start_packet_reg <= 2'b10;
        delay_type_valid <= 1'b1;

        if (delay_type_valid) begin
            input_type_d0 <= delay_type;
        end else begin
            input_type_d0 <= INPUT_TYPE_IDLE;
        end
        input_data_d0 <= {encoded_rx_data[31:0], swap_data};
        input_data_crc <= {encoded_rx_data[31:0], swap_data};

        if (PTP_TS_WIDTH == 96) begin
            ptp_ts_reg[45:0] <= ptp_ts[45:0] + (((PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS) * 3) >> 1);
            ptp_ts_reg[95:48] <= ptp_ts[95:48];
        end else begin
            ptp_ts_reg <= ptp_ts + (((PTP_PERIOD_NS * 2**16 + PTP_PERIOD_FNS) * 3) >> 1);
        end
    end else if (lanes_swapped) begin
        if (delay_type_valid) begin
            input_type_d0 <= delay_type;
        end else if (encoded_rx_hdr == SYNC_DATA) begin
            input_type_d0 <= INPUT_TYPE_DATA;
        end else if (encoded_rx_hdr == SYNC_CTRL) begin
            case (encoded_rx_data[7:0])
                BLOCK_TYPE_TERM_0: input_type_d0 <= INPUT_TYPE_TERM_4;
                BLOCK_TYPE_TERM_1: input_type_d0 <= INPUT_TYPE_TERM_5;
                BLOCK_TYPE_TERM_2: input_type_d0 <= INPUT_TYPE_TERM_6;
                BLOCK_TYPE_TERM_3: input_type_d0 <= INPUT_TYPE_TERM_7;
                BLOCK_TYPE_TERM_4: begin
                    delay_type_valid <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_DATA;
                end
                BLOCK_TYPE_TERM_5: begin
                    delay_type_valid <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_DATA;
                end
                BLOCK_TYPE_TERM_6: begin
                    delay_type_valid <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_DATA;
                end
                BLOCK_TYPE_TERM_7: begin
                    delay_type_valid <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_DATA;
                end
                default: begin
                    rx_bad_block_reg <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_ERROR;
                end
            endcase
        end else begin
            rx_bad_block_reg <= 1'b1;
            input_type_d0 <= INPUT_TYPE_ERROR;
        end
        if (encoded_rx_hdr == SYNC_DATA) begin
            input_data_d0 <= {encoded_rx_data[31:0], swap_data};
            input_data_crc <= {encoded_rx_data[31:0], swap_data};
        end else begin
            input_data_d0 <= {encoded_rx_data[39:8], swap_data};
            input_data_crc <= {encoded_rx_data[39:8], swap_data};
        end
    end else begin
        if (encoded_rx_hdr == SYNC_DATA) begin
            input_type_d0 <= INPUT_TYPE_DATA;
        end else if (encoded_rx_hdr == SYNC_CTRL) begin
            case (encoded_rx_data[7:0])
                BLOCK_TYPE_TERM_0: input_type_d0 <= INPUT_TYPE_TERM_0;
                BLOCK_TYPE_TERM_1: input_type_d0 <= INPUT_TYPE_TERM_1;
                BLOCK_TYPE_TERM_2: input_type_d0 <= INPUT_TYPE_TERM_2;
                BLOCK_TYPE_TERM_3: input_type_d0 <= INPUT_TYPE_TERM_3;
                BLOCK_TYPE_TERM_4: input_type_d0 <= INPUT_TYPE_TERM_4;
                BLOCK_TYPE_TERM_5: input_type_d0 <= INPUT_TYPE_TERM_5;
                BLOCK_TYPE_TERM_6: input_type_d0 <= INPUT_TYPE_TERM_6;
                BLOCK_TYPE_TERM_7: input_type_d0 <= INPUT_TYPE_TERM_7;
                default: begin
                    rx_bad_block_reg <= 1'b1;
                    input_type_d0 <= INPUT_TYPE_ERROR;
                end
            endcase
        end else begin
            rx_bad_block_reg <= 1'b1;
            input_type_d0 <= INPUT_TYPE_ERROR;
        end
        if (encoded_rx_hdr == SYNC_DATA) begin
            input_data_d0 <= encoded_rx_data;
            input_data_crc <= encoded_rx_data;
        end else begin
            input_data_d0 <= {8'd0, encoded_rx_data[63:8]};
            input_data_crc <= {8'd0, encoded_rx_data[63:8]};
        end
    end

    if (encoded_rx_hdr == SYNC_DATA) begin
        delay_type <= INPUT_TYPE_DATA;
    end else if (encoded_rx_hdr == SYNC_CTRL) begin
        case (encoded_rx_data[7:0])
            BLOCK_TYPE_START_4: delay_type <= INPUT_TYPE_START_0;
            BLOCK_TYPE_TERM_0: delay_type <= INPUT_TYPE_TERM_4;
            BLOCK_TYPE_TERM_1: delay_type <= INPUT_TYPE_TERM_5;
            BLOCK_TYPE_TERM_2: delay_type <= INPUT_TYPE_TERM_6;
            BLOCK_TYPE_TERM_3: delay_type <= INPUT_TYPE_TERM_7;
            BLOCK_TYPE_TERM_4: delay_type <= INPUT_TYPE_TERM_0;
            BLOCK_TYPE_TERM_5: delay_type <= INPUT_TYPE_TERM_1;
            BLOCK_TYPE_TERM_6: delay_type <= INPUT_TYPE_TERM_2;
            BLOCK_TYPE_TERM_7: delay_type <= INPUT_TYPE_TERM_3;
            default: delay_type <= INPUT_TYPE_ERROR;
        endcase
    end else begin
        delay_type <= INPUT_TYPE_ERROR;
    end

    input_type_d1 <= input_type_d0;
    input_data_d1 <= input_data_d0;

    if (reset_crc) begin
        crc_state <= 32'hFFFFFFFF;
    end else begin
        crc_state <= crc_next7;
    end

    if (update_crc_last) begin
        crc_state3 <= crc_next3;
    end else begin
        crc_state3 <= crc_next7;
    end

    crc_valid7_save <= crc_valid7;

    if (state_next == STATE_LAST) begin
        input_data_crc[31:0] <= input_data_crc[63:32];
    end

    if (rst) begin
        state_reg <= STATE_IDLE;

        m_axis_tvalid_reg <= 1'b0;

        start_packet_reg <= 2'b00;
        error_bad_frame_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;
        rx_bad_block_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
        crc_state3 <= 32'hFFFFFFFF;

        input_type_d0 <= INPUT_TYPE_IDLE;
        input_type_d1 <= INPUT_TYPE_IDLE;

        lanes_swapped <= 1'b0;

        delay_type_valid <= 1'b0;
        delay_type <= INPUT_TYPE_IDLE;
    end
end

endmodule

`resetall
