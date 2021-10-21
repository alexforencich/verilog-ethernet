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
 * AXI4-Stream Ethernet FCS checker
 */
module axis_eth_fcs_check
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [7:0]  s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire        s_axis_tuser,
    
    /*
     * AXI output
     */
    output wire [7:0]  m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast,
    output wire        m_axis_tuser,

    /*
     * Status
     */
    output wire        busy,
    output wire        error_bad_fcs
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;
reg shift_in;
reg shift_reset;

reg [7:0] s_axis_tdata_d0 = 8'd0;
reg [7:0] s_axis_tdata_d1 = 8'd0;
reg [7:0] s_axis_tdata_d2 = 8'd0;
reg [7:0] s_axis_tdata_d3 = 8'd0;

reg s_axis_tvalid_d0 = 1'b0;
reg s_axis_tvalid_d1 = 1'b0;
reg s_axis_tvalid_d2 = 1'b0;
reg s_axis_tvalid_d3 = 1'b0;

reg busy_reg = 1'b0;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
wire [31:0] crc_next;

// internal datapath
reg [7:0] m_axis_tdata_int;
reg       m_axis_tvalid_int;
reg       m_axis_tready_int_reg = 1'b0;
reg       m_axis_tlast_int;
reg       m_axis_tuser_int;
wire      m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg;

assign busy = busy_reg;
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
    .data_in(s_axis_tdata_d3),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;
    shift_in = 1'b0;
    shift_reset = 1'b0;

    s_axis_tready_next = 1'b0;

    m_axis_tdata_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    error_bad_fcs_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            s_axis_tready_next = m_axis_tready_int_early;
            reset_crc = 1'b1;

            m_axis_tdata_int = s_axis_tdata_d3;
            m_axis_tvalid_int = s_axis_tvalid_d3 && s_axis_tvalid;
            m_axis_tlast_int = 1'b0;
            m_axis_tuser_int = 1'b0;

            if (s_axis_tready && s_axis_tvalid) begin
                shift_in = 1'b1;

                if (s_axis_tvalid_d3) begin
                    reset_crc = 1'b0;
                    update_crc = 1'b1;
                    if (s_axis_tlast) begin
                        shift_reset = 1'b1;
                        reset_crc = 1'b1;
                        m_axis_tlast_int = 1'b1;
                        m_axis_tuser_int = s_axis_tuser;
                        if ({s_axis_tdata, s_axis_tdata_d0, s_axis_tdata_d1, s_axis_tdata_d2} != ~crc_next) begin
                            m_axis_tuser_int = 1'b1;
                            error_bad_fcs_next = 1'b1;
                        end
                        s_axis_tready_next = m_axis_tready_int_early;
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_PAYLOAD;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            s_axis_tready_next = m_axis_tready_int_early;

            m_axis_tdata_int = s_axis_tdata_d3;
            m_axis_tvalid_int = s_axis_tvalid_d3 && s_axis_tvalid;
            m_axis_tlast_int = 1'b0;
            m_axis_tuser_int = 1'b0;

            if (s_axis_tready && s_axis_tvalid) begin
                shift_in = 1'b1;
                update_crc = 1'b1;
                if (s_axis_tlast) begin
                    shift_reset = 1'b1;
                    reset_crc = 1'b1;
                    m_axis_tlast_int = 1'b1;
                    m_axis_tuser_int = s_axis_tuser;
                    if ({s_axis_tdata, s_axis_tdata_d0, s_axis_tdata_d1, s_axis_tdata_d2} != ~crc_next) begin
                        m_axis_tuser_int = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    s_axis_tready_next = m_axis_tready_int_early;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        s_axis_tready_reg <= 1'b0;

        busy_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;

        s_axis_tvalid_d0 <= 1'b0;
        s_axis_tvalid_d1 <= 1'b0;
        s_axis_tvalid_d2 <= 1'b0;
        s_axis_tvalid_d3 <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        s_axis_tready_reg <= s_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;
        error_bad_fcs_reg <= error_bad_fcs_next;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next;
        end

        if (shift_reset) begin
            s_axis_tvalid_d0 <= 1'b0;
            s_axis_tvalid_d1 <= 1'b0;
            s_axis_tvalid_d2 <= 1'b0;
            s_axis_tvalid_d3 <= 1'b0;
        end else if (shift_in) begin
            s_axis_tvalid_d0 <= s_axis_tvalid;
            s_axis_tvalid_d1 <= s_axis_tvalid_d0;
            s_axis_tvalid_d2 <= s_axis_tvalid_d1;
            s_axis_tvalid_d3 <= s_axis_tvalid_d2;
        end
    end

    if (shift_in) begin
        s_axis_tdata_d0 <= s_axis_tdata;
        s_axis_tdata_d1 <= s_axis_tdata_d0;
        s_axis_tdata_d2 <= s_axis_tdata_d1;
        s_axis_tdata_d3 <= s_axis_tdata_d2;
    end
end

// output datapath logic
reg [7:0] m_axis_tdata_reg = 8'd0;
reg       m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg       m_axis_tlast_reg = 1'b0;
reg       m_axis_tuser_reg = 1'b0;

reg [7:0] temp_m_axis_tdata_reg = 8'd0;
reg       temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg       temp_m_axis_tlast_reg = 1'b0;
reg       temp_m_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata = m_axis_tdata_reg;
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
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end
end

endmodule

`resetall
