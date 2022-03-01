/*

Copyright (c) 2014-2018 Alex Forencich

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
 * AXI4-Stream frame joiner
 */
module axis_frame_join #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Prepend data with tag
    parameter TAG_ENABLE = 1,
    // Tag field width
    parameter TAG_WIDTH = 16
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI inputs
     */
    input  wire [S_COUNT*DATA_WIDTH-1:0] s_axis_tdata,
    input  wire [S_COUNT-1:0]            s_axis_tvalid,
    output wire [S_COUNT-1:0]            s_axis_tready,
    input  wire [S_COUNT-1:0]            s_axis_tlast,
    input  wire [S_COUNT-1:0]            s_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]         m_axis_tdata,
    output wire                          m_axis_tvalid,
    input  wire                          m_axis_tready,
    output wire                          m_axis_tlast,
    output wire                          m_axis_tuser,

    /*
     * Configuration
     */
    input  wire [TAG_WIDTH-1:0]          tag,

    /*
     * Status signals
     */
    output wire                          busy
);

parameter CL_S_COUNT = $clog2(S_COUNT);

parameter TAG_WORD_WIDTH = (TAG_WIDTH + DATA_WIDTH - 1) / DATA_WIDTH;
parameter CL_TAG_WORD_WIDTH = $clog2(TAG_WORD_WIDTH);

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_WRITE_TAG = 2'd1,
    STATE_TRANSFER = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [CL_TAG_WORD_WIDTH-1:0] frame_ptr_reg = {CL_TAG_WORD_WIDTH{1'b0}}, frame_ptr_next;
reg [CL_S_COUNT-1:0] port_sel_reg = {CL_S_COUNT{1'b0}}, port_sel_next;

reg busy_reg = 1'b0, busy_next;

reg output_tuser_reg = 1'b0, output_tuser_next;

reg [S_COUNT-1:0] s_axis_tready_reg = {S_COUNT{1'b0}}, s_axis_tready_next;

// internal datapath
reg [DATA_WIDTH-1:0] m_axis_tdata_int;
reg                  m_axis_tvalid_int;
reg                  m_axis_tready_int_reg = 1'b0;
reg                  m_axis_tlast_int;
reg                  m_axis_tuser_int;
wire                 m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg;

assign busy = busy_reg;

wire [DATA_WIDTH-1:0] input_tdata  = s_axis_tdata[port_sel_reg*DATA_WIDTH +: DATA_WIDTH];
wire                  input_tvalid = s_axis_tvalid[port_sel_reg];
wire                  input_tlast  = s_axis_tlast[port_sel_reg];
wire                  input_tuser  = s_axis_tuser[port_sel_reg];

always @* begin
    state_next = STATE_IDLE;

    frame_ptr_next = frame_ptr_reg;
    port_sel_next = port_sel_reg;

    s_axis_tready_next = {S_COUNT{1'b0}};

    m_axis_tdata_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    output_tuser_next = output_tuser_reg;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = {CL_TAG_WORD_WIDTH{1'b0}};
            port_sel_next = {CL_S_COUNT{1'b0}};
            output_tuser_next = 1'b0;

            if (TAG_ENABLE) begin
                // next cycle if started will send tag, so do not enable input
                s_axis_tready_next = 1'b0;
            end else begin
                // next cycle if started will send data, so enable input
                s_axis_tready_next = m_axis_tready_int_early;
            end

            if (s_axis_tvalid) begin
                // input 0 valid; start transferring data
                if (TAG_ENABLE) begin
                    // tag enabled, so transmit it
                    if (m_axis_tready_int_reg) begin
                        // output is ready, so short-circuit first tag word
                        frame_ptr_next = 1;
                        m_axis_tdata_int = tag;
                        m_axis_tvalid_int = 1'b1;
                    end
                    state_next = STATE_WRITE_TAG;
                end else begin
                    // tag disabled, so transmit data
                    if (m_axis_tready_int_reg) begin
                        // output is ready, so short-circuit first data word
                        m_axis_tdata_int = s_axis_tdata;
                        m_axis_tvalid_int = 1'b1;
                    end
                    state_next = STATE_TRANSFER;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_TAG: begin
            // write tag data
            if (m_axis_tready_int_reg) begin
                // output ready, so send tag word
                state_next = STATE_WRITE_TAG;
                frame_ptr_next = frame_ptr_reg + 1;
                m_axis_tvalid_int = 1'b1;

                m_axis_tdata_int = tag >> frame_ptr_reg*DATA_WIDTH;
                if (frame_ptr_reg == TAG_WORD_WIDTH-1) begin
                    s_axis_tready_next = m_axis_tready_int_early << 0;
                    state_next = STATE_TRANSFER;
                end
            end else begin
                state_next = STATE_WRITE_TAG;
            end
        end
        STATE_TRANSFER: begin
            // transfer input data

            // set ready for current input
            s_axis_tready_next = m_axis_tready_int_early << port_sel_reg;

            if (input_tvalid && m_axis_tready_int_reg) begin
                // output ready, transfer byte
                state_next = STATE_TRANSFER;
                m_axis_tdata_int = input_tdata;
                m_axis_tvalid_int = input_tvalid;

                if (input_tlast) begin
                    // last flag received, switch to next port
                    port_sel_next = port_sel_reg + 1;
                    // save tuser - assert tuser out if ANY tuser asserts received
                    output_tuser_next = output_tuser_next | input_tuser;
                    // disable input
                    s_axis_tready_next = {S_COUNT{1'b0}};

                    if (S_COUNT == 1 || port_sel_reg == S_COUNT-1) begin
                        // last port - send tlast and tuser and revert to idle
                        m_axis_tlast_int = 1'b1;
                        m_axis_tuser_int = output_tuser_next;
                        state_next = STATE_IDLE;
                    end else begin
                        // otherwise, disable enable next port
                        s_axis_tready_next = m_axis_tready_int_early << port_sel_next;
                    end
                end
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= {CL_TAG_WORD_WIDTH{1'b0}};
        port_sel_reg <= {CL_S_COUNT{1'b0}};
        s_axis_tready_reg <= {S_COUNT{1'b0}};
        output_tuser_reg <= 1'b0;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        port_sel_reg <= port_sel_next;

        s_axis_tready_reg <= s_axis_tready_next;

        output_tuser_reg <= output_tuser_next;

        busy_reg <= state_next != STATE_IDLE;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] m_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next;
reg                  m_axis_tlast_reg = 1'b0;
reg                  m_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_m_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg                  temp_m_axis_tlast_reg = 1'b0;
reg                  temp_m_axis_tuser_reg = 1'b0;

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
