/*

Copyright (c) 2015-2016 Alex Forencich

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
 * AXI4-Stream tap
 */
module axis_tap #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI tap
     */
    input  wire [DATA_WIDTH-1:0]  tap_axis_tdata,
    input  wire                   tap_axis_tvalid,
    input  wire                   tap_axis_tready,
    input  wire                   tap_axis_tlast,
    input  wire                   tap_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser
);

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int_reg = 1'b0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_TRANSFER = 2'd1,
    STATE_TRUNCATE = 2'd2,
    STATE_WAIT = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg frame_reg = 1'b0, frame_next;

always @* begin
    state_next = STATE_IDLE;

    frame_next = frame_reg;

    output_axis_tdata_int = {DATA_WIDTH{1'b0}};
    output_axis_tvalid_int = 1'b0;
    output_axis_tlast_int = 1'b0;
    output_axis_tuser_int = 1'b0;

    if (tap_axis_tready & tap_axis_tvalid) begin
        frame_next = ~tap_axis_tlast;
    end

    case (state_reg)
        STATE_IDLE: begin
            if (tap_axis_tready & tap_axis_tvalid) begin
                // start of frame
                if (output_axis_tready_int_reg) begin
                    output_axis_tdata_int = tap_axis_tdata;
                    output_axis_tvalid_int = tap_axis_tvalid & tap_axis_tready;
                    output_axis_tlast_int = tap_axis_tlast;
                    output_axis_tuser_int = tap_axis_tuser;
                    if (tap_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end else begin
                    state_next = STATE_WAIT;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_TRANSFER: begin
            if (tap_axis_tready & tap_axis_tvalid) begin
                // transfer data
                if (output_axis_tready_int_reg) begin
                    output_axis_tdata_int = tap_axis_tdata;
                    output_axis_tvalid_int = tap_axis_tvalid & tap_axis_tready;
                    output_axis_tlast_int = tap_axis_tlast;
                    output_axis_tuser_int = tap_axis_tuser;
                    if (tap_axis_tlast) begin
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_TRANSFER;
                    end
                end else begin
                    state_next = STATE_TRUNCATE;
                end
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
        STATE_TRUNCATE: begin
            if (output_axis_tready_int_reg) begin
                output_axis_tdata_int = {DATA_WIDTH{1'b0}};
                output_axis_tvalid_int = 1'b1;
                output_axis_tlast_int = 1'b1;
                output_axis_tuser_int = 1'b1;
                if (frame_next) begin
                    state_next = STATE_WAIT;
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_TRUNCATE;
            end
        end
        STATE_WAIT: begin
            if (tap_axis_tready & tap_axis_tvalid) begin
                if (tap_axis_tlast) begin
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_WAIT;
                end
            end else begin
                state_next = STATE_WAIT;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        frame_reg <= frame_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg                  output_axis_tlast_reg = 1'b0;
reg                  output_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg                  temp_axis_tlast_reg = 1'b0;
reg                  temp_axis_tuser_reg = 1'b0;

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
