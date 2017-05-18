/*

Copyright (c) 2015-2017 Alex Forencich

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
 * AXI4-Stream frame length adjuster with FIFO
 */
module axis_frame_length_adjust_fifo #
(
    parameter DATA_WIDTH = 8,
    parameter FRAME_FIFO_ADDR_WIDTH = 12,
    parameter HEADER_FIFO_ADDR_WIDTH = 3
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
    output wire                   output_axis_hdr_valid,
    input  wire                   output_axis_hdr_ready,
    output wire                   output_axis_hdr_pad,
    output wire                   output_axis_hdr_truncate,
    output wire [15:0]            output_axis_hdr_length,
    output wire [15:0]            output_axis_hdr_original_length,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser,

    /*
     * Configuration
     */
    input  wire [15:0]            length_min,
    input  wire [15:0]            length_max
);

wire [DATA_WIDTH-1:0] fifo_axis_tdata;
wire fifo_axis_tvalid;
wire fifo_axis_tready;
wire fifo_axis_tlast;
wire fifo_axis_tuser;

wire status_valid;
wire status_ready;
wire status_frame_pad;
wire status_frame_truncate;
wire [15:0] status_frame_length;
wire [15:0] status_frame_original_length;

axis_frame_length_adjust #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(1)
)
axis_frame_length_adjust_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(input_axis_tdata),
    .input_axis_tkeep(1),
    .input_axis_tvalid(input_axis_tvalid),
    .input_axis_tready(input_axis_tready),
    .input_axis_tlast(input_axis_tlast),
    .input_axis_tuser(input_axis_tuser),
    // AXI output
    .output_axis_tdata(fifo_axis_tdata),
    .output_axis_tkeep(),
    .output_axis_tvalid(fifo_axis_tvalid),
    .output_axis_tready(fifo_axis_tready),
    .output_axis_tlast(fifo_axis_tlast),
    .output_axis_tuser(fifo_axis_tuser),
    // Status
    .status_valid(status_valid),
    .status_ready(status_ready),
    .status_frame_pad(status_frame_pad),
    .status_frame_truncate(status_frame_truncate),
    .status_frame_length(status_frame_length),
    .status_frame_original_length(status_frame_original_length),
    // Configuration
    .length_min(length_min),
    .length_max(length_max)
);

axis_fifo #(
    .ADDR_WIDTH(FRAME_FIFO_ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
)
frame_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata(fifo_axis_tdata),
    .input_axis_tvalid(fifo_axis_tvalid),
    .input_axis_tready(fifo_axis_tready),
    .input_axis_tlast(fifo_axis_tlast),
    .input_axis_tuser(fifo_axis_tuser),
    // AXI output
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tuser(output_axis_tuser)
);

axis_fifo #(
    .ADDR_WIDTH(HEADER_FIFO_ADDR_WIDTH),
    .DATA_WIDTH(1+1+16+16)
)
header_fifo_inst (
    .clk(clk),
    .rst(rst),
    // AXI input
    .input_axis_tdata({status_frame_pad, status_frame_truncate, status_frame_length, status_frame_original_length}),
    .input_axis_tvalid(status_valid),
    .input_axis_tready(status_ready),
    .input_axis_tlast(0),
    .input_axis_tuser(0),
    // AXI output
    .output_axis_tdata({output_axis_hdr_pad, output_axis_hdr_truncate, output_axis_hdr_length, output_axis_hdr_original_length}),
    .output_axis_tvalid(output_axis_hdr_valid),
    .output_axis_tready(output_axis_hdr_ready),
    .output_axis_tlast(),
    .output_axis_tuser()
);


endmodule
