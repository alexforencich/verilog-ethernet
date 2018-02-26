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

`timescale 1ns / 1ps

/*
 * AXI4-Stream register
 */
module axis_register #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter LAST_ENABLE = 1,
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1
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
    input  wire [ID_WIDTH-1:0]    input_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_axis_tuser
);

// datapath registers
reg                  input_axis_tready_reg = 1'b0;

reg [DATA_WIDTH-1:0] output_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg                  output_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   output_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] output_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] output_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg                  temp_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_axis_tuser_reg  = {USER_WIDTH{1'b0}};

// datapath control
reg store_axis_input_to_output;
reg store_axis_input_to_temp;
reg store_axis_temp_to_output;

assign input_axis_tready = input_axis_tready_reg;

assign output_axis_tdata  = output_axis_tdata_reg;
assign output_axis_tkeep  = KEEP_ENABLE ? output_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast  = LAST_ENABLE ? output_axis_tlast_reg : 1'b1;
assign output_axis_tid    = ID_ENABLE   ? output_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_axis_tdest  = DEST_ENABLE ? output_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_axis_tuser  = USER_ENABLE ? output_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
wire input_axis_tready_early = output_axis_tready | (~temp_axis_tvalid_reg & (~output_axis_tvalid_reg | ~input_axis_tvalid));

always @* begin
    // transfer sink ready state to source
    output_axis_tvalid_next = output_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_input_to_output = 1'b0;
    store_axis_input_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (input_axis_tready_reg) begin
        // input is ready
        if (output_axis_tready | ~output_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_axis_tvalid_next = input_axis_tvalid;
            store_axis_input_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = input_axis_tvalid;
            store_axis_input_to_temp = 1'b1;
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
        input_axis_tready_reg <= 1'b0;
        output_axis_tvalid_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        input_axis_tready_reg <= input_axis_tready_early;
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_input_to_output) begin
        output_axis_tdata_reg <= input_axis_tdata;
        output_axis_tkeep_reg <= input_axis_tkeep;
        output_axis_tlast_reg <= input_axis_tlast;
        output_axis_tid_reg   <= input_axis_tid;
        output_axis_tdest_reg <= input_axis_tdest;
        output_axis_tuser_reg <= input_axis_tuser;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tkeep_reg <= temp_axis_tkeep_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tid_reg   <= temp_axis_tid_reg;
        output_axis_tdest_reg <= temp_axis_tdest_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_input_to_temp) begin
        temp_axis_tdata_reg <= input_axis_tdata;
        temp_axis_tkeep_reg <= input_axis_tkeep;
        temp_axis_tlast_reg <= input_axis_tlast;
        temp_axis_tid_reg   <= input_axis_tid;
        temp_axis_tdest_reg <= input_axis_tdest;
        temp_axis_tuser_reg <= input_axis_tuser;
    end
end

endmodule
