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
 * AXI4-Stream rate limiter
 */
module axis_rate_limit #
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
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser,

    /*
     * Configuration
     */
    input  wire [7:0]             rate_num,
    input  wire [7:0]             rate_denom,
    input  wire                   rate_by_frame
);

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int = 0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early = output_axis_tready;

reg [23:0] acc_reg = 0, acc_next;
reg pause;
reg frame_reg = 0, frame_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;
assign input_axis_tready = input_axis_tready_reg;

always @* begin
    acc_next = acc_reg;
    pause = 0;
    frame_next = frame_reg & ~input_axis_tlast;

    if (acc_reg >= rate_num) begin
        acc_next = acc_reg - rate_num;
    end

    if (input_axis_tready & input_axis_tvalid) begin
        // read input
        frame_next = ~input_axis_tlast;
        acc_next = acc_reg + (rate_denom - rate_num);
    end

    if (acc_next >= rate_num) begin
        if (rate_by_frame) begin
            pause = ~frame_next;
        end else begin
            pause = 1;
        end
    end

    input_axis_tready_next = output_axis_tready_int_early & ~pause;

    output_axis_tdata_int = input_axis_tdata;
    output_axis_tvalid_int = input_axis_tvalid & input_axis_tready;
    output_axis_tlast_int = input_axis_tlast;
    output_axis_tuser_int = input_axis_tuser;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        acc_reg <= 0;
        frame_reg <= 0;
        input_axis_tready_reg <= 0;
    end else begin
        acc_reg <= acc_next;
        frame_reg <= frame_next;
        input_axis_tready_reg <= input_axis_tready_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg                  output_axis_tvalid_reg = 0;
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg                  temp_axis_tvalid_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

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
        // also enable ready input next cycle if output is currently not valid and will not become valid next cycle
        output_axis_tready_int <= output_axis_tready | (~output_axis_tvalid_reg & ~output_axis_tvalid_int);

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
        end
    end
end

endmodule
