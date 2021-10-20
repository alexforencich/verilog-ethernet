/*

Copyright (c) 2016-2018 Alex Forencich

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
 * AXI4-Stream consistent overhead byte stuffing (COBS) encoder
 */
module axis_cobs_encode #
(
    // append zero for in band framing
    parameter APPEND_ZERO = 1
)
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
    output wire        m_axis_tuser
);

// state register
localparam [1:0]
    INPUT_STATE_IDLE = 2'd0,
    INPUT_STATE_SEGMENT = 2'd1,
    INPUT_STATE_FINAL_ZERO = 2'd2,
    INPUT_STATE_APPEND_ZERO = 2'd3;

reg [1:0] input_state_reg = INPUT_STATE_IDLE, input_state_next;

localparam [0:0]
    OUTPUT_STATE_IDLE = 1'd0,
    OUTPUT_STATE_SEGMENT = 1'd1;

reg [0:0] output_state_reg = OUTPUT_STATE_IDLE, output_state_next;

reg [7:0] input_count_reg = 8'd0, input_count_next;
reg [7:0] output_count_reg = 8'd0, output_count_next;
reg fail_frame_reg = 1'b0, fail_frame_next;

// internal datapath
reg [7:0] m_axis_tdata_int;
reg       m_axis_tvalid_int;
reg       m_axis_tready_int_reg = 1'b0;
reg       m_axis_tlast_int;
reg       m_axis_tuser_int;
wire      m_axis_tready_int_early;

reg s_axis_tready_mask;

reg [7:0] code_fifo_in_tdata;
reg code_fifo_in_tvalid;
reg code_fifo_in_tlast;
reg code_fifo_in_tuser;
wire code_fifo_in_tready;

wire [7:0] code_fifo_out_tdata;
wire code_fifo_out_tvalid;
wire code_fifo_out_tlast;
wire code_fifo_out_tuser;
reg code_fifo_out_tready;

reg [7:0] data_fifo_in_tdata;
reg data_fifo_in_tvalid;
reg data_fifo_in_tlast;
wire data_fifo_in_tready;

wire [7:0] data_fifo_out_tdata;
wire data_fifo_out_tvalid;
wire data_fifo_out_tlast;
reg data_fifo_out_tready;

assign s_axis_tready = code_fifo_in_tready && data_fifo_in_tready && s_axis_tready_mask;

axis_fifo #(
    .DEPTH(256),
    .DATA_WIDTH(8),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(1),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(1),
    .FRAME_FIFO(0)
)
code_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(code_fifo_in_tdata),
    .s_axis_tkeep(0),
    .s_axis_tvalid(code_fifo_in_tvalid),
    .s_axis_tready(code_fifo_in_tready),
    .s_axis_tlast(code_fifo_in_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(code_fifo_in_tuser),
    // AXI output
    .m_axis_tdata(code_fifo_out_tdata),
    .m_axis_tkeep(),
    .m_axis_tvalid(code_fifo_out_tvalid),
    .m_axis_tready(code_fifo_out_tready),
    .m_axis_tlast(code_fifo_out_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(code_fifo_out_tuser),
    // Status
    .status_overflow(),
    .status_bad_frame(),
    .status_good_frame()
);

axis_fifo #(
    .DEPTH(256),
    .DATA_WIDTH(8),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(1),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0),
    .FRAME_FIFO(0)
)
data_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(data_fifo_in_tdata),
    .s_axis_tkeep(0),
    .s_axis_tvalid(data_fifo_in_tvalid),
    .s_axis_tready(data_fifo_in_tready),
    .s_axis_tlast(data_fifo_in_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0),
    // AXI output
    .m_axis_tdata(data_fifo_out_tdata),
    .m_axis_tkeep(),
    .m_axis_tvalid(data_fifo_out_tvalid),
    .m_axis_tready(data_fifo_out_tready),
    .m_axis_tlast(data_fifo_out_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    // Status
    .status_overflow(),
    .status_bad_frame(),
    .status_good_frame()
);

always @* begin
    input_state_next = INPUT_STATE_IDLE;

    input_count_next = input_count_reg;

    fail_frame_next = fail_frame_reg;

    s_axis_tready_mask = 1'b0;

    code_fifo_in_tdata = 8'd0;
    code_fifo_in_tvalid = 1'b0;
    code_fifo_in_tlast = 1'b0;
    code_fifo_in_tuser = 1'b0;

    data_fifo_in_tdata = s_axis_tdata;
    data_fifo_in_tvalid = 1'b0;
    data_fifo_in_tlast = 1'b0;

    case (input_state_reg)
        INPUT_STATE_IDLE: begin
            // idle state
            s_axis_tready_mask = 1'b1;
            fail_frame_next = 1'b0;

            if (s_axis_tready && s_axis_tvalid) begin
                // valid input data

                if (s_axis_tdata == 8'd0 || (s_axis_tlast && s_axis_tuser)) begin
                    // got a zero or propagated error, so store a zero code
                    code_fifo_in_tdata = 8'd1;
                    code_fifo_in_tvalid = 1'b1;
                    if (s_axis_tlast) begin
                        // last byte, so close out the frame
                        fail_frame_next = s_axis_tuser;
                        input_state_next = INPUT_STATE_FINAL_ZERO;
                    end else begin
                        // return to idle to await next segment
                        input_state_next = INPUT_STATE_IDLE;
                    end
                end else begin
                    // got something other than a zero, so store it and init the segment counter
                    input_count_next = 8'd2;
                    data_fifo_in_tdata = s_axis_tdata;
                    data_fifo_in_tvalid = 1'b1;
                    if (s_axis_tlast) begin
                        // last byte, so store the code and close out the frame
                        code_fifo_in_tdata = 8'd2;
                        code_fifo_in_tvalid = 1'b1;
                        if (APPEND_ZERO) begin
                            // zero frame mode, need to add a zero code to end the frame
                            input_state_next = INPUT_STATE_APPEND_ZERO;
                        end else begin
                            // normal frame mode, close out the frame
                            data_fifo_in_tlast = 1'b1;
                            input_state_next = INPUT_STATE_IDLE;
                        end
                    end else begin
                        // await more segment data
                        input_state_next = INPUT_STATE_SEGMENT;
                    end
                end
            end else begin
                input_state_next = INPUT_STATE_IDLE;
            end
        end
        INPUT_STATE_SEGMENT: begin
            // encode segment
            s_axis_tready_mask = 1'b1;
            fail_frame_next = 1'b0;

            if (s_axis_tready && s_axis_tvalid) begin
                // valid input data

                if (s_axis_tdata == 8'd0 || (s_axis_tlast && s_axis_tuser)) begin
                    // got a zero or propagated error, so store the code
                    code_fifo_in_tdata = input_count_reg;
                    code_fifo_in_tvalid = 1'b1;
                    if (s_axis_tlast) begin
                        // last byte, so close out the frame
                        fail_frame_next = s_axis_tuser;
                        input_state_next = INPUT_STATE_FINAL_ZERO;
                    end else begin
                        // return to idle to await next segment
                        input_state_next = INPUT_STATE_IDLE;
                    end
                end else begin
                    // got something other than a zero, so store it and increment the segment counter
                    input_count_next = input_count_reg+1;
                    data_fifo_in_tdata = s_axis_tdata;
                    data_fifo_in_tvalid = 1'b1;
                    if (input_count_reg == 8'd254) begin
                        // 254 bytes in frame, so dump and reset counter
                        code_fifo_in_tdata = input_count_reg+1;
                        code_fifo_in_tvalid = 1'b1;
                        input_count_next = 8'd1;
                    end
                    if (s_axis_tlast) begin
                        // last byte, so store the code and close out the frame
                        code_fifo_in_tdata = input_count_reg+1;
                        code_fifo_in_tvalid = 1'b1;
                        if (APPEND_ZERO) begin
                            // zero frame mode, need to add a zero code to end the frame
                            input_state_next = INPUT_STATE_APPEND_ZERO;
                        end else begin
                            // normal frame mode, close out the frame
                            data_fifo_in_tlast = 1'b1;
                            input_state_next = INPUT_STATE_IDLE;
                        end
                    end else begin
                        // await more segment data
                        input_state_next = INPUT_STATE_SEGMENT;
                    end
                end
            end else begin
                input_state_next = INPUT_STATE_SEGMENT;
            end
        end
        INPUT_STATE_FINAL_ZERO: begin
            // final zero code required
            s_axis_tready_mask = 1'b0;

            if (code_fifo_in_tready) begin
                // push a zero code and close out frame
                if (fail_frame_reg) begin
                    code_fifo_in_tdata = 8'd2;
                    code_fifo_in_tuser = 1'b1;
                end else begin
                    code_fifo_in_tdata = 8'd1;
                end
                code_fifo_in_tvalid = 1'b1;
                if (APPEND_ZERO) begin
                    // zero frame mode, need to add a zero code to end the frame
                    input_state_next = INPUT_STATE_APPEND_ZERO;
                end else begin
                    // normal frame mode, close out the frame
                    code_fifo_in_tlast = 1'b1;
                    fail_frame_next = 1'b0;
                    input_state_next = INPUT_STATE_IDLE;
                end
            end else begin
                input_state_next = INPUT_STATE_FINAL_ZERO;
            end
        end
        INPUT_STATE_APPEND_ZERO: begin
            // append zero for zero framing
            s_axis_tready_mask = 1'b0;

            if (code_fifo_in_tready) begin
                // push frame termination code and close out frame
                code_fifo_in_tdata = 8'd0;
                code_fifo_in_tlast = 1'b1;
                code_fifo_in_tuser = fail_frame_reg;
                code_fifo_in_tvalid = 1'b1;
                fail_frame_next = 1'b0;
                input_state_next = INPUT_STATE_IDLE;
            end else begin
                input_state_next = INPUT_STATE_APPEND_ZERO;
            end
        end
    endcase
end

always @* begin
    output_state_next = OUTPUT_STATE_IDLE;

    output_count_next = output_count_reg;

    m_axis_tdata_int = 8'd0;
    m_axis_tvalid_int = 1'b0;
    m_axis_tlast_int = 1'b0;
    m_axis_tuser_int = 1'b0;

    code_fifo_out_tready = 1'b0;

    data_fifo_out_tready = 1'b0;

    case (output_state_reg)
        OUTPUT_STATE_IDLE: begin
            // idle state

            if (m_axis_tready_int_reg && code_fifo_out_tvalid) begin
                // transfer out code byte and load counter
                m_axis_tdata_int = code_fifo_out_tdata;
                m_axis_tlast_int = code_fifo_out_tlast;
                m_axis_tuser_int = code_fifo_out_tuser && code_fifo_out_tlast;
                output_count_next = code_fifo_out_tdata-1;
                m_axis_tvalid_int = 1'b1;
                code_fifo_out_tready = 1'b1;
                if (code_fifo_out_tdata == 8'd0 || code_fifo_out_tdata == 8'd1 || code_fifo_out_tuser) begin
                    // frame termination and zero codes will be followed by codes
                    output_state_next = OUTPUT_STATE_IDLE;
                end else begin
                    // transfer out data
                    output_state_next = OUTPUT_STATE_SEGMENT;
                end
            end else begin
                output_state_next = OUTPUT_STATE_IDLE;
            end
        end
        OUTPUT_STATE_SEGMENT: begin
            // segment output

            if (m_axis_tready_int_reg && data_fifo_out_tvalid) begin
                // transfer out data byte and decrement counter
                m_axis_tdata_int = data_fifo_out_tdata;
                m_axis_tlast_int = data_fifo_out_tlast;
                output_count_next = output_count_reg - 1;
                m_axis_tvalid_int = 1'b1;
                data_fifo_out_tready = 1'b1;
                if (output_count_reg == 1'b1) begin
                    // done with segment, get a code byte next
                    output_state_next = OUTPUT_STATE_IDLE;
                end else begin
                    // more data to transfer
                    output_state_next = OUTPUT_STATE_SEGMENT;
                end
            end else begin
                output_state_next = OUTPUT_STATE_SEGMENT;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        input_state_reg <= INPUT_STATE_IDLE;
        output_state_reg <= OUTPUT_STATE_IDLE;
    end else begin
        input_state_reg <= input_state_next;
        output_state_reg <= output_state_next;
    end

    input_count_reg <= input_count_next;
    output_count_reg <= output_count_next;
    fail_frame_reg <= fail_frame_next;
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
