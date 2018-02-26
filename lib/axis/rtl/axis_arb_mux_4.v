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
 * AXI4-Stream 4 port arbitrated multiplexer
 */
module axis_arb_mux_4 #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "PRIORITY",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI inputs
     */
    input  wire [DATA_WIDTH-1:0]  input_0_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_0_axis_tkeep,
    input  wire                   input_0_axis_tvalid,
    output wire                   input_0_axis_tready,
    input  wire                   input_0_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_0_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_0_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_0_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_1_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_1_axis_tkeep,
    input  wire                   input_1_axis_tvalid,
    output wire                   input_1_axis_tready,
    input  wire                   input_1_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_1_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_1_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_1_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_2_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_2_axis_tkeep,
    input  wire                   input_2_axis_tvalid,
    output wire                   input_2_axis_tready,
    input  wire                   input_2_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_2_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_2_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_2_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_3_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_3_axis_tkeep,
    input  wire                   input_3_axis_tvalid,
    output wire                   input_3_axis_tready,
    input  wire                   input_3_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_3_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_3_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_3_axis_tuser,

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

wire [3:0] request;
wire [3:0] acknowledge;
wire [3:0] grant;
wire grant_valid;
wire [1:0] grant_encoded;

assign acknowledge[0] = input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast;
assign request[0] = input_0_axis_tvalid & ~acknowledge[0];
assign acknowledge[1] = input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast;
assign request[1] = input_1_axis_tvalid & ~acknowledge[1];
assign acknowledge[2] = input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast;
assign request[2] = input_2_axis_tvalid & ~acknowledge[2];
assign acknowledge[3] = input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast;
assign request[3] = input_3_axis_tvalid & ~acknowledge[3];

// mux instance
axis_mux_4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
)
mux_inst (
    .clk(clk),
    .rst(rst),
    .input_0_axis_tdata(input_0_axis_tdata),
    .input_0_axis_tkeep(input_0_axis_tkeep),
    .input_0_axis_tvalid(input_0_axis_tvalid & grant[0]),
    .input_0_axis_tready(input_0_axis_tready),
    .input_0_axis_tlast(input_0_axis_tlast),
    .input_0_axis_tid(input_0_axis_tid),
    .input_0_axis_tdest(input_0_axis_tdest),
    .input_0_axis_tuser(input_0_axis_tuser),
    .input_1_axis_tdata(input_1_axis_tdata),
    .input_1_axis_tkeep(input_1_axis_tkeep),
    .input_1_axis_tvalid(input_1_axis_tvalid & grant[1]),
    .input_1_axis_tready(input_1_axis_tready),
    .input_1_axis_tlast(input_1_axis_tlast),
    .input_1_axis_tid(input_1_axis_tid),
    .input_1_axis_tdest(input_1_axis_tdest),
    .input_1_axis_tuser(input_1_axis_tuser),
    .input_2_axis_tdata(input_2_axis_tdata),
    .input_2_axis_tkeep(input_2_axis_tkeep),
    .input_2_axis_tvalid(input_2_axis_tvalid & grant[2]),
    .input_2_axis_tready(input_2_axis_tready),
    .input_2_axis_tlast(input_2_axis_tlast),
    .input_2_axis_tid(input_2_axis_tid),
    .input_2_axis_tdest(input_2_axis_tdest),
    .input_2_axis_tuser(input_2_axis_tuser),
    .input_3_axis_tdata(input_3_axis_tdata),
    .input_3_axis_tkeep(input_3_axis_tkeep),
    .input_3_axis_tvalid(input_3_axis_tvalid & grant[3]),
    .input_3_axis_tready(input_3_axis_tready),
    .input_3_axis_tlast(input_3_axis_tlast),
    .input_3_axis_tid(input_3_axis_tid),
    .input_3_axis_tdest(input_3_axis_tdest),
    .input_3_axis_tuser(input_3_axis_tuser),
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tid(output_axis_tid),
    .output_axis_tdest(output_axis_tdest),
    .output_axis_tuser(output_axis_tuser),
    .enable(grant_valid),
    .select(grant_encoded)
);

// arbiter instance
arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

endmodule
