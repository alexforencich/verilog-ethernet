/*

Copyright (c) 2014 Alex Forencich

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
 * AXI4-Stream statistics counter
 */
module axis_stat_counter #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI monitor
     */
    input  wire [KEEP_WIDTH-1:0]  monitor_axis_tkeep,
    input  wire                   monitor_axis_tvalid,
    input  wire                   monitor_axis_tready,
    input  wire                   monitor_axis_tlast,

    /*
     * AXI status data output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Configuration
     */
    input  wire [15:0] tag,
    input  wire        trigger,

    /*
     * Status
     */
    output wire        busy
);

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_OUTPUT_DATA = 2'd1;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [31:0] tick_count_reg = 0, tick_count_next;
reg [31:0] byte_count_reg = 0, byte_count_next;
reg [31:0] frame_count_reg = 0, frame_count_next;
reg frame_reg = 0, frame_next;

reg store_output;
reg [5:0] frame_ptr_reg = 0, frame_ptr_next;

reg [31:0] tick_count_output_reg = 0;
reg [31:0] byte_count_output_reg = 0;
reg [31:0] frame_count_output_reg = 0;

reg busy_reg = 0;

// internal datapath
reg [7:0]  output_axis_tdata_int;
reg        output_axis_tvalid_int;
reg        output_axis_tready_int = 0;
reg        output_axis_tlast_int;
reg        output_axis_tuser_int;
wire       output_axis_tready_int_early;

assign busy = busy_reg;

function [3:0] keep2count;
    input [7:0] k;
    case (k)
        8'b00000000: keep2count = 0;
        8'b00000001: keep2count = 1;
        8'b00000011: keep2count = 2;
        8'b00000111: keep2count = 3;
        8'b00001111: keep2count = 4;
        8'b00011111: keep2count = 5;
        8'b00111111: keep2count = 6;
        8'b01111111: keep2count = 7;
        8'b11111111: keep2count = 8;
    endcase
endfunction

function [7:0] count2keep;
    input [3:0] k;
    case (k)
        4'd0: count2keep = 8'b00000000;
        4'd1: count2keep = 8'b00000001;
        4'd2: count2keep = 8'b00000011;
        4'd3: count2keep = 8'b00000111;
        4'd4: count2keep = 8'b00001111;
        4'd5: count2keep = 8'b00011111;
        4'd6: count2keep = 8'b00111111;
        4'd7: count2keep = 8'b01111111;
        4'd8: count2keep = 8'b11111111;
    endcase
endfunction

always @* begin
    state_next = 2'bz;

    tick_count_next = tick_count_reg;
    byte_count_next = byte_count_reg;
    frame_count_next = frame_count_reg;
    frame_next = frame_reg;

    output_axis_tdata_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    store_output = 0;

    frame_ptr_next = frame_ptr_reg;

    // data readout

    case (state_reg)
        STATE_IDLE: begin
            if (trigger) begin
                store_output = 1;
                tick_count_next = 0;
                byte_count_next = 0;
                frame_count_next = 0;
                frame_ptr_next = 0;

                if (output_axis_tready_int) begin
                    frame_ptr_next = 1;
                    output_axis_tdata_int = tag[15:8];
                    output_axis_tvalid_int = 1;
                end

                state_next = STATE_OUTPUT_DATA;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_OUTPUT_DATA: begin
            if (output_axis_tready_int) begin
                state_next = STATE_OUTPUT_DATA;
                frame_ptr_next = frame_ptr_reg + 1;
                output_axis_tvalid_int = 1;
                case (frame_ptr_reg)
                    5'd00: output_axis_tdata_int = tag[15:8];
                    5'd01: output_axis_tdata_int = tag[7:0];
                    5'd02: output_axis_tdata_int = tick_count_output_reg[31:24];
                    5'd03: output_axis_tdata_int = tick_count_output_reg[23:16];
                    5'd04: output_axis_tdata_int = tick_count_output_reg[15: 8];
                    5'd05: output_axis_tdata_int = tick_count_output_reg[ 7: 0];
                    5'd06: output_axis_tdata_int = byte_count_output_reg[31:24];
                    5'd07: output_axis_tdata_int = byte_count_output_reg[23:16];
                    5'd08: output_axis_tdata_int = byte_count_output_reg[15: 8];
                    5'd09: output_axis_tdata_int = byte_count_output_reg[ 7: 0];
                    5'd10: output_axis_tdata_int = frame_count_output_reg[31:24];
                    5'd11: output_axis_tdata_int = frame_count_output_reg[23:16];
                    5'd12: output_axis_tdata_int = frame_count_output_reg[15: 8];
                    5'd13: begin
                        output_axis_tdata_int = frame_count_output_reg[ 7: 0];
                        output_axis_tlast_int = 1;
                        state_next = STATE_IDLE;
                    end
                endcase
            end else begin
                state_next = STATE_OUTPUT_DATA;
            end
        end
    endcase

    // stats collection

    // increment tick count by number of words that can be transferred per cycle
    tick_count_next = tick_count_next + KEEP_WIDTH;

    if (monitor_axis_tready & monitor_axis_tvalid) begin
        // valid transfer cycle

        // increment byte count by number of words transferred
        byte_count_next = byte_count_next + keep2count(monitor_axis_tkeep);

        // count frames
        if (monitor_axis_tlast) begin
            // end of frame
            frame_next = 0;
        end else if (~frame_reg) begin
            // first word after end of frame
            frame_count_next = frame_count_next + 1;
            frame_next = 1;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        tick_count_reg <= 0;
        byte_count_reg <= 0;
        frame_count_reg <= 0;
        frame_reg <= 0;
        frame_ptr_reg <= 0;
        busy_reg <= 0;
        tick_count_output_reg <= 0;
        byte_count_output_reg <= 0;
        frame_count_output_reg <= 0;
    end else begin
        state_reg <= state_next;
        tick_count_reg <= tick_count_next;
        byte_count_reg <= byte_count_next;
        frame_count_reg <= frame_count_next;
        frame_reg <= frame_next;
        frame_ptr_reg <= frame_ptr_next;

        busy_reg <= state_next != STATE_IDLE;

        if (store_output) begin
            tick_count_output_reg <= tick_count_reg;
            byte_count_output_reg <= byte_count_reg;
            frame_count_output_reg <= frame_count_reg;
        end
    end
end

// output datapath logic
reg [7:0]  output_axis_tdata_reg = 0;
reg        output_axis_tvalid_reg = 0;
reg        output_axis_tlast_reg = 0;
reg        output_axis_tuser_reg = 0;

reg [7:0]  temp_axis_tdata_reg = 0;
reg        temp_axis_tvalid_reg = 0;
reg        temp_axis_tlast_reg = 0;
reg        temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tvalid_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
    end else begin
        // transfer sink ready state to source
        output_axis_tready_int <= output_axis_tready_int_early;

        if (output_axis_tready_int) begin
            // input is ready
            if (output_axis_tready | ~output_axis_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                output_axis_tdata_reg <= output_axis_tdata_int;
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
            temp_axis_tvalid_reg <= 0;
            temp_axis_tlast_reg <= 0;
            temp_axis_tuser_reg <= 0;
        end
    end
end

endmodule
