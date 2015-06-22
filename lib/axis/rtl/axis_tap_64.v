/*

Copyright (c) 2015 Alex Forencich

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
 * AXI4-Stream tap (64 bit datapath)
 */
module axis_tap_64 #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI tap
     */
    input  wire [DATA_WIDTH-1:0]  tap_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  tap_axis_tkeep,
    input  wire                   tap_axis_tvalid,
    input  wire                   tap_axis_tready,
    input  wire                   tap_axis_tlast,
    input  wire                   tap_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser
);

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int = 0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_TRANSFER = 2'd1,
    STATE_TRUNCATE = 2'd2,
    STATE_WAIT = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg frame_reg = 0, frame_next;

always @* begin
    state_next = STATE_IDLE;

    frame_next = frame_reg;

    output_axis_tdata_int = 0;
    output_axis_tkeep_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    if (tap_axis_tready & tap_axis_tvalid) begin
        frame_next = ~tap_axis_tlast;
    end

    case (state_reg)
        STATE_IDLE: begin
            if (tap_axis_tready & tap_axis_tvalid) begin
                // start of frame
                if (output_axis_tready_int) begin
                    output_axis_tdata_int = tap_axis_tdata;
                    output_axis_tkeep_int = tap_axis_tkeep;
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
                if (output_axis_tready_int) begin
                    output_axis_tdata_int = tap_axis_tdata;
                    output_axis_tkeep_int = tap_axis_tkeep;
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
            if (output_axis_tready_int) begin
                output_axis_tdata_int = 0;
                output_axis_tkeep_int = 1;
                output_axis_tvalid_int = 1;
                output_axis_tlast_int = 1;
                output_axis_tuser_int = 1;
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

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_reg <= 0;
    end else begin
        state_reg <= state_next;
        frame_reg <= frame_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg = 0;
reg                  output_axis_tvalid_reg = 0;
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg = 0;
reg                  temp_axis_tvalid_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tkeep_reg <= 0;
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
                output_axis_tkeep_reg <= output_axis_tkeep_int;
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tkeep_reg <= output_axis_tkeep_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
            temp_axis_tkeep_reg <= 0;
            temp_axis_tvalid_reg <= 0;
            temp_axis_tlast_reg <= 0;
            temp_axis_tuser_reg <= 0;
        end
    end
end

endmodule
