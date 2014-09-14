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
 * AXI4-Stream register (64 bit datapath)
 */
module axis_register_64 #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_axis_tkeep,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,

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

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_TRANSFER = 2'd1,
    STATE_TRANSFER_WAIT = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg transfer_in_out;
reg transfer_in_temp;
reg transfer_temp_out;

// datapath registers
reg                  input_axis_tready_reg = 0;

reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg = 0;
reg                  output_axis_tvalid_reg = 0;
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;

assign input_axis_tready = input_axis_tready_reg;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

always @* begin
    state_next = 2'bz;

    transfer_in_out = 0;
    transfer_in_temp = 0;
    transfer_temp_out = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - no data in registers
            if (input_axis_tvalid) begin
                // word transfer in - store it in output register
                transfer_in_out = 1;
                state_next = STATE_TRANSFER;
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_TRANSFER: begin
            // transfer state - data in output register
            if (input_axis_tvalid & output_axis_tready) begin
                // word transfer through - update output register
                transfer_in_out = 1;
                state_next = STATE_TRANSFER;
            end else if (~input_axis_tvalid & output_axis_tready) begin
                // word transfer out - go back to idle
                state_next = STATE_IDLE;
            end else if (input_axis_tvalid & ~output_axis_tready) begin
                // word transfer in - store in temp
                transfer_in_temp = 1;
                state_next = STATE_TRANSFER_WAIT;
            end else begin
                state_next = STATE_TRANSFER;
            end
        end
        STATE_TRANSFER_WAIT: begin
            // transfer wait state - data in both output and temp registers
            if (output_axis_tready) begin
                // transfer out - move temp to output
                transfer_temp_out = 1;
                state_next = STATE_TRANSFER;
            end else begin
                state_next = STATE_TRANSFER_WAIT;
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        input_axis_tready_reg <= 0;
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tkeep_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
    end else begin
        state_reg <= state_next;

        // generate valid outputs
        case (state_next)
            STATE_IDLE: begin
                // idle state - no data in registers; accept new data
                input_axis_tready_reg <= 1;
                output_axis_tvalid_reg <= 0;
            end
            STATE_TRANSFER: begin
                // transfer state - data in output register; accept new data
                input_axis_tready_reg <= 1;
                output_axis_tvalid_reg <= 1;
            end
            STATE_TRANSFER_WAIT: begin
                // transfer wait state - data in output and temp registers; do not accept new data
                input_axis_tready_reg <= 0;
                output_axis_tvalid_reg <= 1;
            end
        endcase

        // datapath
        if (transfer_in_out) begin
            output_axis_tdata_reg <= input_axis_tdata;
            output_axis_tkeep_reg <= input_axis_tkeep;
            output_axis_tlast_reg <= input_axis_tlast;
            output_axis_tuser_reg <= input_axis_tuser;
        end else if (transfer_in_temp) begin
            temp_axis_tdata_reg <= input_axis_tdata;
            temp_axis_tkeep_reg <= input_axis_tkeep;
            temp_axis_tlast_reg <= input_axis_tlast;
            temp_axis_tuser_reg <= input_axis_tuser;
        end else if (transfer_temp_out) begin
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
        end
    end
end

endmodule
