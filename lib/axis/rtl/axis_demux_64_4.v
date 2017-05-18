/*

Copyright (c) 2014-2017 Alex Forencich

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
 * AXI4-Stream 4 port demultiplexer (64 bit datapath)
 */
module axis_demux_64_4 #
(
    parameter DATA_WIDTH = 64,
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
     * AXI outputs
     */
    output wire [DATA_WIDTH-1:0]  output_0_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_0_axis_tkeep,
    output wire                   output_0_axis_tvalid,
    input  wire                   output_0_axis_tready,
    output wire                   output_0_axis_tlast,
    output wire                   output_0_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_1_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_1_axis_tkeep,
    output wire                   output_1_axis_tvalid,
    input  wire                   output_1_axis_tready,
    output wire                   output_1_axis_tlast,
    output wire                   output_1_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_2_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_2_axis_tkeep,
    output wire                   output_2_axis_tvalid,
    input  wire                   output_2_axis_tready,
    output wire                   output_2_axis_tlast,
    output wire                   output_2_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_3_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_3_axis_tkeep,
    output wire                   output_3_axis_tvalid,
    input  wire                   output_3_axis_tready,
    output wire                   output_3_axis_tlast,
    output wire                   output_3_axis_tuser,

    /*
     * Control
     */
    input  wire                   enable,
    input  wire [1:0]             select
);

reg [1:0] select_reg = 2'd0, select_next;
reg frame_reg = 1'b0, frame_next;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int_reg = 1'b0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;

assign input_axis_tready = input_axis_tready_reg;

// mux for output control signals
reg current_output_tready;
reg current_output_tvalid;
always @* begin
    case (select_reg)
        2'd0: begin
            current_output_tvalid = output_0_axis_tvalid;
            current_output_tready = output_0_axis_tready;
        end
        2'd1: begin
            current_output_tvalid = output_1_axis_tvalid;
            current_output_tready = output_1_axis_tready;
        end
        2'd2: begin
            current_output_tvalid = output_2_axis_tvalid;
            current_output_tready = output_2_axis_tready;
        end
        2'd3: begin
            current_output_tvalid = output_3_axis_tvalid;
            current_output_tready = output_3_axis_tready;
        end
        default: begin
            current_output_tvalid = 1'b0;
            current_output_tready = 1'b0;
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_axis_tready_next = 1'b0;

    if (input_axis_tvalid & input_axis_tready) begin
        // end of frame detection
        if (input_axis_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (~frame_reg & enable & input_axis_tvalid & ~current_output_tvalid) begin
        // start of frame, grab select value
        frame_next = 1'b1;
        select_next = select;
    end

    input_axis_tready_next = output_axis_tready_int_early & frame_next;

    output_axis_tdata_int = input_axis_tdata;
    output_axis_tkeep_int = input_axis_tkeep;
    output_axis_tvalid_int = input_axis_tvalid & input_axis_tready;
    output_axis_tlast_int = input_axis_tlast;
    output_axis_tuser_int = input_axis_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 2'd0;
        frame_reg <= 1'b0;
        input_axis_tready_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_axis_tready_reg <= input_axis_tready_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg = {KEEP_WIDTH{1'b0}};
reg                  output_0_axis_tvalid_reg = 1'b0, output_0_axis_tvalid_next;
reg                  output_1_axis_tvalid_reg = 1'b0, output_1_axis_tvalid_next;
reg                  output_2_axis_tvalid_reg = 1'b0, output_2_axis_tvalid_next;
reg                  output_3_axis_tvalid_reg = 1'b0, output_3_axis_tvalid_next;
reg                  output_axis_tlast_reg = 1'b0;
reg                  output_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg = {KEEP_WIDTH{1'b0}};
reg                  temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg                  temp_axis_tlast_reg = 1'b0;
reg                  temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_0_axis_tdata = output_axis_tdata_reg;
assign output_0_axis_tkeep = output_axis_tkeep_reg;
assign output_0_axis_tvalid = output_0_axis_tvalid_reg;
assign output_0_axis_tlast = output_axis_tlast_reg;
assign output_0_axis_tuser = output_axis_tuser_reg;

assign output_1_axis_tdata = output_axis_tdata_reg;
assign output_1_axis_tkeep = output_axis_tkeep_reg;
assign output_1_axis_tvalid = output_1_axis_tvalid_reg;
assign output_1_axis_tlast = output_axis_tlast_reg;
assign output_1_axis_tuser = output_axis_tuser_reg;

assign output_2_axis_tdata = output_axis_tdata_reg;
assign output_2_axis_tkeep = output_axis_tkeep_reg;
assign output_2_axis_tvalid = output_2_axis_tvalid_reg;
assign output_2_axis_tlast = output_axis_tlast_reg;
assign output_2_axis_tuser = output_axis_tuser_reg;

assign output_3_axis_tdata = output_axis_tdata_reg;
assign output_3_axis_tkeep = output_axis_tkeep_reg;
assign output_3_axis_tvalid = output_3_axis_tvalid_reg;
assign output_3_axis_tlast = output_axis_tlast_reg;
assign output_3_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_axis_tready_int_early = current_output_tready | (~temp_axis_tvalid_reg & (~current_output_tvalid | ~output_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_0_axis_tvalid_next = output_0_axis_tvalid_reg;
    output_1_axis_tvalid_next = output_1_axis_tvalid_reg;
    output_2_axis_tvalid_next = output_2_axis_tvalid_reg;
    output_3_axis_tvalid_next = output_3_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;
    
    if (output_axis_tready_int_reg) begin
        // input is ready
        if (current_output_tready | ~current_output_tvalid) begin
            // output is ready or currently not valid, transfer data to output
            output_0_axis_tvalid_next = output_axis_tvalid_int & (select_reg == 2'd0);
            output_1_axis_tvalid_next = output_axis_tvalid_int & (select_reg == 2'd1);
            output_2_axis_tvalid_next = output_axis_tvalid_int & (select_reg == 2'd2);
            output_3_axis_tvalid_next = output_axis_tvalid_int & (select_reg == 2'd3);
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (current_output_tready) begin
        // input is not ready, but output is ready
        output_0_axis_tvalid_next = temp_axis_tvalid_reg & (select_reg == 2'd0);
        output_1_axis_tvalid_next = temp_axis_tvalid_reg & (select_reg == 2'd1);
        output_2_axis_tvalid_next = temp_axis_tvalid_reg & (select_reg == 2'd2);
        output_3_axis_tvalid_next = temp_axis_tvalid_reg & (select_reg == 2'd3);
        temp_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_0_axis_tvalid_reg <= 1'b0;
        output_1_axis_tvalid_reg <= 1'b0;
        output_2_axis_tvalid_reg <= 1'b0;
        output_3_axis_tvalid_reg <= 1'b0;
        output_axis_tready_int_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        output_0_axis_tvalid_reg <= output_0_axis_tvalid_next;
        output_1_axis_tvalid_reg <= output_1_axis_tvalid_next;
        output_2_axis_tvalid_reg <= output_2_axis_tvalid_next;
        output_3_axis_tvalid_reg <= output_3_axis_tvalid_next;
        output_axis_tready_int_reg <= output_axis_tready_int_early;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        output_axis_tdata_reg <= output_axis_tdata_int;
        output_axis_tkeep_reg <= output_axis_tkeep_int;
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tkeep_reg <= temp_axis_tkeep_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tkeep_reg <= output_axis_tkeep_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
