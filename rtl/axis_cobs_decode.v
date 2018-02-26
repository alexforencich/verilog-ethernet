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

`timescale 1ns / 1ps

/*
 * AXI4-Stream consistent overhead byte stuffing (COBS) decoder
 */
module axis_cobs_decode
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [7:0]  input_axis_tdata,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,

    /*
     * AXI output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser
);

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_SEGMENT = 2'd1,
    STATE_NEXT_SEGMENT = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [7:0] count_reg = 8'd0, count_next;
reg suppress_zero_reg = 1'b0, suppress_zero_next;

reg [7:0] temp_tdata_reg = 8'd0, temp_tdata_next;
reg temp_tvalid_reg = 1'b0, temp_tvalid_next;

// internal datapath
reg [7:0] output_axis_tdata_int;
reg       output_axis_tvalid_int;
reg       output_axis_tready_int_reg = 1'b0;
reg       output_axis_tlast_int;
reg       output_axis_tuser_int;
wire      output_axis_tready_int_early;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

assign input_axis_tready = input_axis_tready_reg;

always @* begin
    state_next = STATE_IDLE;

    count_next = count_reg;
    suppress_zero_next = suppress_zero_reg;

    temp_tdata_next = temp_tdata_reg;
    temp_tvalid_next = temp_tvalid_reg;

    output_axis_tdata_int = 8'd0;
    output_axis_tvalid_int = 1'b0;
    output_axis_tlast_int = 1'b0;
    output_axis_tuser_int = 1'b0;

    input_axis_tready_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state
            input_axis_tready_next = output_axis_tready_int_early | ~temp_tvalid_reg;

            // output final word
            output_axis_tdata_int = temp_tdata_reg;
            output_axis_tvalid_int = temp_tvalid_reg;
            output_axis_tlast_int = temp_tvalid_reg;
            temp_tvalid_next = temp_tvalid_reg & ~output_axis_tready_int_reg;

            if (input_axis_tready & input_axis_tvalid) begin
                // valid input data
                // skip any leading zeros
                if (input_axis_tdata != 8'd0) begin
                    // store count value and zero suppress
                    count_next = input_axis_tdata-1;
                    suppress_zero_next = (input_axis_tdata == 8'd255);
                    input_axis_tready_next = output_axis_tready_int_early;
                    if (input_axis_tdata == 8'd1) begin
                        // next byte will be count value
                        state_next = STATE_NEXT_SEGMENT;
                    end else begin
                        // next byte will be data
                        state_next = STATE_SEGMENT;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_SEGMENT: begin
            // receive segment
            input_axis_tready_next = output_axis_tready_int_early;

            if (input_axis_tready & input_axis_tvalid) begin
                // valid input data
                // store in temp register
                temp_tdata_next = input_axis_tdata;
                temp_tvalid_next = 1'b1;
                // move temp to output
                output_axis_tdata_int = temp_tdata_reg;
                output_axis_tvalid_int = temp_tvalid_reg;
                // decrement count
                count_next = count_reg - 1;
                if (input_axis_tdata == 8'd0) begin
                    // got a zero byte in a frame - mark it as an error and re-sync
                    temp_tvalid_next = 1'b0;
                    output_axis_tvalid_int = 1'b1;
                    output_axis_tuser_int = 1'b1;
                    output_axis_tlast_int = 1'b1;
                    input_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end else if (input_axis_tlast) begin
                    // end of frame
                    if (count_reg == 8'd1 && ~input_axis_tuser) begin
                        // end of frame indication at correct time, go to idle to output final byte
                        state_next = STATE_IDLE;
                    end else begin
                        // end of frame indication at invalid time or tuser assert, so mark as an error and re-sync
                        temp_tvalid_next = 1'b0;
                        output_axis_tvalid_int = 1'b1;
                        output_axis_tuser_int = 1'b1;
                        output_axis_tlast_int = 1'b1;
                        input_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end
                end else if (count_reg == 8'd1) begin
                    // next byte will be count value
                    state_next = STATE_NEXT_SEGMENT;
                end else begin
                    // next byte will be data
                    state_next = STATE_SEGMENT;
                end
            end else begin
                state_next = STATE_SEGMENT;
            end
        end
        STATE_NEXT_SEGMENT: begin
            // next segment
            input_axis_tready_next = output_axis_tready_int_early;

            if (input_axis_tready & input_axis_tvalid) begin
                // valid input data
                // store zero in temp if not suppressed
                temp_tdata_next = 8'd0;
                temp_tvalid_next = ~suppress_zero_reg;
                // move temp to output
                output_axis_tdata_int = temp_tdata_reg;
                output_axis_tvalid_int = temp_tvalid_reg;
                if (input_axis_tdata == 8'd0) begin
                    // got a zero byte delineating the end of the frame, so mark as such and re-sync
                    temp_tvalid_next = 1'b0;
                    output_axis_tuser_int = input_axis_tuser;
                    output_axis_tlast_int = 1'b1;
                    input_axis_tready_next = 1'b1;
                    state_next = STATE_IDLE;
                end else if (input_axis_tlast) begin
                    if (input_axis_tdata == 8'd1 && ~input_axis_tuser) begin
                        // end of frame indication at correct time, go to idle to output final byte
                        state_next = STATE_IDLE;
                    end else begin
                        // end of frame indication at invalid time or tuser assert, so mark as an error and re-sync
                        temp_tvalid_next = 1'b0;
                        output_axis_tvalid_int = 1'b1;
                        output_axis_tuser_int = 1'b1;
                        output_axis_tlast_int = 1'b1;
                        input_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end
                end else begin
                    // otherwise, store count value and zero suppress
                    count_next = input_axis_tdata-1;
                    suppress_zero_next = (input_axis_tdata == 8'd255);
                    input_axis_tready_next = output_axis_tready_int_early;
                    if (input_axis_tdata == 8'd1) begin
                        // next byte will be count value
                        state_next = STATE_NEXT_SEGMENT;
                    end else begin
                        // next byte will be data
                        state_next = STATE_SEGMENT;
                    end
                end
            end else begin
                state_next = STATE_NEXT_SEGMENT;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        temp_tvalid_reg <= 1'b0;
        input_axis_tready_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        temp_tvalid_reg <= temp_tvalid_next;
        input_axis_tready_reg <= input_axis_tready_next;
    end

    temp_tdata_reg <= temp_tdata_next;

    count_reg <= count_next;
    suppress_zero_reg <= suppress_zero_next;
end

// output datapath logic
reg [7:0] output_axis_tdata_reg = 8'd0;
reg       output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg       output_axis_tlast_reg = 1'b0;
reg       output_axis_tuser_reg = 1'b0;

reg [7:0] temp_axis_tdata_reg = 8'd0;
reg       temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg       temp_axis_tlast_reg = 1'b0;
reg       temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & (~output_axis_tvalid_reg | ~output_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_axis_tvalid_next = output_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (output_axis_tready_int_reg) begin
        // input is ready
        if (output_axis_tready | ~output_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (output_axis_tready) begin
        // input is not ready, but output is ready
        output_axis_tvalid_next = temp_axis_tvalid_reg;
        temp_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_axis_tvalid_reg <= 1'b0;
        output_axis_tready_int_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tready_int_reg <= output_axis_tready_int_early;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        output_axis_tdata_reg <= output_axis_tdata_int;
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
