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
 * AXI4-Stream 16x16 crosspoint
 */
module axis_crosspoint_16x16 #
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
     * AXI Stream inputs
     */
    input  wire [DATA_WIDTH-1:0]  input_0_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_0_axis_tkeep,
    input  wire                   input_0_axis_tvalid,
    input  wire                   input_0_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_0_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_0_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_0_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_1_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_1_axis_tkeep,
    input  wire                   input_1_axis_tvalid,
    input  wire                   input_1_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_1_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_1_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_1_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_2_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_2_axis_tkeep,
    input  wire                   input_2_axis_tvalid,
    input  wire                   input_2_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_2_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_2_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_2_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_3_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_3_axis_tkeep,
    input  wire                   input_3_axis_tvalid,
    input  wire                   input_3_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_3_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_3_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_3_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_4_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_4_axis_tkeep,
    input  wire                   input_4_axis_tvalid,
    input  wire                   input_4_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_4_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_4_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_4_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_5_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_5_axis_tkeep,
    input  wire                   input_5_axis_tvalid,
    input  wire                   input_5_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_5_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_5_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_5_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_6_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_6_axis_tkeep,
    input  wire                   input_6_axis_tvalid,
    input  wire                   input_6_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_6_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_6_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_6_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_7_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_7_axis_tkeep,
    input  wire                   input_7_axis_tvalid,
    input  wire                   input_7_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_7_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_7_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_7_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_8_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_8_axis_tkeep,
    input  wire                   input_8_axis_tvalid,
    input  wire                   input_8_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_8_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_8_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_8_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_9_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_9_axis_tkeep,
    input  wire                   input_9_axis_tvalid,
    input  wire                   input_9_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_9_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_9_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_9_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_10_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_10_axis_tkeep,
    input  wire                   input_10_axis_tvalid,
    input  wire                   input_10_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_10_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_10_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_10_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_11_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_11_axis_tkeep,
    input  wire                   input_11_axis_tvalid,
    input  wire                   input_11_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_11_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_11_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_11_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_12_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_12_axis_tkeep,
    input  wire                   input_12_axis_tvalid,
    input  wire                   input_12_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_12_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_12_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_12_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_13_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_13_axis_tkeep,
    input  wire                   input_13_axis_tvalid,
    input  wire                   input_13_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_13_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_13_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_13_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_14_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_14_axis_tkeep,
    input  wire                   input_14_axis_tvalid,
    input  wire                   input_14_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_14_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_14_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_14_axis_tuser,

    input  wire [DATA_WIDTH-1:0]  input_15_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_15_axis_tkeep,
    input  wire                   input_15_axis_tvalid,
    input  wire                   input_15_axis_tlast,
    input  wire [ID_WIDTH-1:0]    input_15_axis_tid,
    input  wire [DEST_WIDTH-1:0]  input_15_axis_tdest,
    input  wire [USER_WIDTH-1:0]  input_15_axis_tuser,

    /*
     * AXI Stream outputs
     */
    output wire [DATA_WIDTH-1:0]  output_0_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_0_axis_tkeep,
    output wire                   output_0_axis_tvalid,
    output wire                   output_0_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_0_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_0_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_0_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_1_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_1_axis_tkeep,
    output wire                   output_1_axis_tvalid,
    output wire                   output_1_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_1_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_1_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_1_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_2_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_2_axis_tkeep,
    output wire                   output_2_axis_tvalid,
    output wire                   output_2_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_2_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_2_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_2_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_3_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_3_axis_tkeep,
    output wire                   output_3_axis_tvalid,
    output wire                   output_3_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_3_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_3_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_3_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_4_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_4_axis_tkeep,
    output wire                   output_4_axis_tvalid,
    output wire                   output_4_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_4_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_4_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_4_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_5_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_5_axis_tkeep,
    output wire                   output_5_axis_tvalid,
    output wire                   output_5_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_5_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_5_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_5_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_6_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_6_axis_tkeep,
    output wire                   output_6_axis_tvalid,
    output wire                   output_6_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_6_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_6_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_6_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_7_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_7_axis_tkeep,
    output wire                   output_7_axis_tvalid,
    output wire                   output_7_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_7_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_7_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_7_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_8_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_8_axis_tkeep,
    output wire                   output_8_axis_tvalid,
    output wire                   output_8_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_8_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_8_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_8_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_9_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_9_axis_tkeep,
    output wire                   output_9_axis_tvalid,
    output wire                   output_9_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_9_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_9_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_9_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_10_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_10_axis_tkeep,
    output wire                   output_10_axis_tvalid,
    output wire                   output_10_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_10_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_10_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_10_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_11_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_11_axis_tkeep,
    output wire                   output_11_axis_tvalid,
    output wire                   output_11_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_11_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_11_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_11_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_12_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_12_axis_tkeep,
    output wire                   output_12_axis_tvalid,
    output wire                   output_12_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_12_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_12_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_12_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_13_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_13_axis_tkeep,
    output wire                   output_13_axis_tvalid,
    output wire                   output_13_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_13_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_13_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_13_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_14_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_14_axis_tkeep,
    output wire                   output_14_axis_tvalid,
    output wire                   output_14_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_14_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_14_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_14_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_15_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_15_axis_tkeep,
    output wire                   output_15_axis_tvalid,
    output wire                   output_15_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_15_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_15_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_15_axis_tuser,

    /*
     * Control
     */
    input  wire [3:0]             output_0_select,
    input  wire [3:0]             output_1_select,
    input  wire [3:0]             output_2_select,
    input  wire [3:0]             output_3_select,
    input  wire [3:0]             output_4_select,
    input  wire [3:0]             output_5_select,
    input  wire [3:0]             output_6_select,
    input  wire [3:0]             output_7_select,
    input  wire [3:0]             output_8_select,
    input  wire [3:0]             output_9_select,
    input  wire [3:0]             output_10_select,
    input  wire [3:0]             output_11_select,
    input  wire [3:0]             output_12_select,
    input  wire [3:0]             output_13_select,
    input  wire [3:0]             output_14_select,
    input  wire [3:0]             output_15_select
);

reg [DATA_WIDTH-1:0]  input_0_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_0_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_0_axis_tvalid_reg = 1'b0;
reg                   input_0_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_0_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_0_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_0_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_1_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_1_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_1_axis_tvalid_reg = 1'b0;
reg                   input_1_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_1_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_1_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_1_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_2_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_2_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_2_axis_tvalid_reg = 1'b0;
reg                   input_2_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_2_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_2_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_2_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_3_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_3_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_3_axis_tvalid_reg = 1'b0;
reg                   input_3_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_3_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_3_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_3_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_4_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_4_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_4_axis_tvalid_reg = 1'b0;
reg                   input_4_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_4_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_4_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_4_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_5_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_5_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_5_axis_tvalid_reg = 1'b0;
reg                   input_5_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_5_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_5_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_5_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_6_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_6_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_6_axis_tvalid_reg = 1'b0;
reg                   input_6_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_6_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_6_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_6_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_7_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_7_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_7_axis_tvalid_reg = 1'b0;
reg                   input_7_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_7_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_7_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_7_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_8_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_8_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_8_axis_tvalid_reg = 1'b0;
reg                   input_8_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_8_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_8_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_8_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_9_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_9_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_9_axis_tvalid_reg = 1'b0;
reg                   input_9_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_9_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_9_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_9_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_10_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_10_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_10_axis_tvalid_reg = 1'b0;
reg                   input_10_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_10_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_10_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_10_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_11_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_11_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_11_axis_tvalid_reg = 1'b0;
reg                   input_11_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_11_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_11_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_11_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_12_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_12_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_12_axis_tvalid_reg = 1'b0;
reg                   input_12_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_12_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_12_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_12_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_13_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_13_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_13_axis_tvalid_reg = 1'b0;
reg                   input_13_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_13_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_13_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_13_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_14_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_14_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_14_axis_tvalid_reg = 1'b0;
reg                   input_14_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_14_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_14_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_14_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  input_15_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  input_15_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   input_15_axis_tvalid_reg = 1'b0;
reg                   input_15_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    input_15_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  input_15_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  input_15_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_0_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_0_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_0_axis_tvalid_reg = 1'b0;
reg                   output_0_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_0_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_0_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_0_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_1_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_1_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_1_axis_tvalid_reg = 1'b0;
reg                   output_1_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_1_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_1_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_1_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_2_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_2_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_2_axis_tvalid_reg = 1'b0;
reg                   output_2_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_2_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_2_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_2_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_3_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_3_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_3_axis_tvalid_reg = 1'b0;
reg                   output_3_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_3_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_3_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_3_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_4_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_4_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_4_axis_tvalid_reg = 1'b0;
reg                   output_4_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_4_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_4_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_4_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_5_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_5_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_5_axis_tvalid_reg = 1'b0;
reg                   output_5_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_5_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_5_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_5_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_6_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_6_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_6_axis_tvalid_reg = 1'b0;
reg                   output_6_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_6_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_6_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_6_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_7_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_7_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_7_axis_tvalid_reg = 1'b0;
reg                   output_7_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_7_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_7_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_7_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_8_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_8_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_8_axis_tvalid_reg = 1'b0;
reg                   output_8_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_8_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_8_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_8_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_9_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_9_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_9_axis_tvalid_reg = 1'b0;
reg                   output_9_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_9_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_9_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_9_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_10_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_10_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_10_axis_tvalid_reg = 1'b0;
reg                   output_10_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_10_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_10_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_10_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_11_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_11_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_11_axis_tvalid_reg = 1'b0;
reg                   output_11_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_11_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_11_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_11_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_12_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_12_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_12_axis_tvalid_reg = 1'b0;
reg                   output_12_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_12_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_12_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_12_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_13_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_13_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_13_axis_tvalid_reg = 1'b0;
reg                   output_13_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_13_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_13_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_13_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_14_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_14_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_14_axis_tvalid_reg = 1'b0;
reg                   output_14_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_14_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_14_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_14_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0]  output_15_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0]  output_15_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                   output_15_axis_tvalid_reg = 1'b0;
reg                   output_15_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]    output_15_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0]  output_15_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0]  output_15_axis_tuser_reg  = {USER_WIDTH{1'b0}};

reg [3:0]             output_0_select_reg = 4'd0;
reg [3:0]             output_1_select_reg = 4'd0;
reg [3:0]             output_2_select_reg = 4'd0;
reg [3:0]             output_3_select_reg = 4'd0;
reg [3:0]             output_4_select_reg = 4'd0;
reg [3:0]             output_5_select_reg = 4'd0;
reg [3:0]             output_6_select_reg = 4'd0;
reg [3:0]             output_7_select_reg = 4'd0;
reg [3:0]             output_8_select_reg = 4'd0;
reg [3:0]             output_9_select_reg = 4'd0;
reg [3:0]             output_10_select_reg = 4'd0;
reg [3:0]             output_11_select_reg = 4'd0;
reg [3:0]             output_12_select_reg = 4'd0;
reg [3:0]             output_13_select_reg = 4'd0;
reg [3:0]             output_14_select_reg = 4'd0;
reg [3:0]             output_15_select_reg = 4'd0;

assign output_0_axis_tdata  = output_0_axis_tdata_reg;
assign output_0_axis_tkeep  = KEEP_ENABLE ? output_0_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_0_axis_tvalid = output_0_axis_tvalid_reg;
assign output_0_axis_tlast  = LAST_ENABLE ? output_0_axis_tlast_reg : 1'b1;
assign output_0_axis_tid    = ID_ENABLE   ? output_0_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_0_axis_tdest  = DEST_ENABLE ? output_0_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_0_axis_tuser  = USER_ENABLE ? output_0_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_1_axis_tdata  = output_1_axis_tdata_reg;
assign output_1_axis_tkeep  = KEEP_ENABLE ? output_1_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_1_axis_tvalid = output_1_axis_tvalid_reg;
assign output_1_axis_tlast  = LAST_ENABLE ? output_1_axis_tlast_reg : 1'b1;
assign output_1_axis_tid    = ID_ENABLE   ? output_1_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_1_axis_tdest  = DEST_ENABLE ? output_1_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_1_axis_tuser  = USER_ENABLE ? output_1_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_2_axis_tdata  = output_2_axis_tdata_reg;
assign output_2_axis_tkeep  = KEEP_ENABLE ? output_2_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_2_axis_tvalid = output_2_axis_tvalid_reg;
assign output_2_axis_tlast  = LAST_ENABLE ? output_2_axis_tlast_reg : 1'b1;
assign output_2_axis_tid    = ID_ENABLE   ? output_2_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_2_axis_tdest  = DEST_ENABLE ? output_2_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_2_axis_tuser  = USER_ENABLE ? output_2_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_3_axis_tdata  = output_3_axis_tdata_reg;
assign output_3_axis_tkeep  = KEEP_ENABLE ? output_3_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_3_axis_tvalid = output_3_axis_tvalid_reg;
assign output_3_axis_tlast  = LAST_ENABLE ? output_3_axis_tlast_reg : 1'b1;
assign output_3_axis_tid    = ID_ENABLE   ? output_3_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_3_axis_tdest  = DEST_ENABLE ? output_3_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_3_axis_tuser  = USER_ENABLE ? output_3_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_4_axis_tdata  = output_4_axis_tdata_reg;
assign output_4_axis_tkeep  = KEEP_ENABLE ? output_4_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_4_axis_tvalid = output_4_axis_tvalid_reg;
assign output_4_axis_tlast  = LAST_ENABLE ? output_4_axis_tlast_reg : 1'b1;
assign output_4_axis_tid    = ID_ENABLE   ? output_4_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_4_axis_tdest  = DEST_ENABLE ? output_4_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_4_axis_tuser  = USER_ENABLE ? output_4_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_5_axis_tdata  = output_5_axis_tdata_reg;
assign output_5_axis_tkeep  = KEEP_ENABLE ? output_5_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_5_axis_tvalid = output_5_axis_tvalid_reg;
assign output_5_axis_tlast  = LAST_ENABLE ? output_5_axis_tlast_reg : 1'b1;
assign output_5_axis_tid    = ID_ENABLE   ? output_5_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_5_axis_tdest  = DEST_ENABLE ? output_5_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_5_axis_tuser  = USER_ENABLE ? output_5_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_6_axis_tdata  = output_6_axis_tdata_reg;
assign output_6_axis_tkeep  = KEEP_ENABLE ? output_6_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_6_axis_tvalid = output_6_axis_tvalid_reg;
assign output_6_axis_tlast  = LAST_ENABLE ? output_6_axis_tlast_reg : 1'b1;
assign output_6_axis_tid    = ID_ENABLE   ? output_6_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_6_axis_tdest  = DEST_ENABLE ? output_6_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_6_axis_tuser  = USER_ENABLE ? output_6_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_7_axis_tdata  = output_7_axis_tdata_reg;
assign output_7_axis_tkeep  = KEEP_ENABLE ? output_7_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_7_axis_tvalid = output_7_axis_tvalid_reg;
assign output_7_axis_tlast  = LAST_ENABLE ? output_7_axis_tlast_reg : 1'b1;
assign output_7_axis_tid    = ID_ENABLE   ? output_7_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_7_axis_tdest  = DEST_ENABLE ? output_7_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_7_axis_tuser  = USER_ENABLE ? output_7_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_8_axis_tdata  = output_8_axis_tdata_reg;
assign output_8_axis_tkeep  = KEEP_ENABLE ? output_8_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_8_axis_tvalid = output_8_axis_tvalid_reg;
assign output_8_axis_tlast  = LAST_ENABLE ? output_8_axis_tlast_reg : 1'b1;
assign output_8_axis_tid    = ID_ENABLE   ? output_8_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_8_axis_tdest  = DEST_ENABLE ? output_8_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_8_axis_tuser  = USER_ENABLE ? output_8_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_9_axis_tdata  = output_9_axis_tdata_reg;
assign output_9_axis_tkeep  = KEEP_ENABLE ? output_9_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_9_axis_tvalid = output_9_axis_tvalid_reg;
assign output_9_axis_tlast  = LAST_ENABLE ? output_9_axis_tlast_reg : 1'b1;
assign output_9_axis_tid    = ID_ENABLE   ? output_9_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_9_axis_tdest  = DEST_ENABLE ? output_9_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_9_axis_tuser  = USER_ENABLE ? output_9_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_10_axis_tdata  = output_10_axis_tdata_reg;
assign output_10_axis_tkeep  = KEEP_ENABLE ? output_10_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_10_axis_tvalid = output_10_axis_tvalid_reg;
assign output_10_axis_tlast  = LAST_ENABLE ? output_10_axis_tlast_reg : 1'b1;
assign output_10_axis_tid    = ID_ENABLE   ? output_10_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_10_axis_tdest  = DEST_ENABLE ? output_10_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_10_axis_tuser  = USER_ENABLE ? output_10_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_11_axis_tdata  = output_11_axis_tdata_reg;
assign output_11_axis_tkeep  = KEEP_ENABLE ? output_11_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_11_axis_tvalid = output_11_axis_tvalid_reg;
assign output_11_axis_tlast  = LAST_ENABLE ? output_11_axis_tlast_reg : 1'b1;
assign output_11_axis_tid    = ID_ENABLE   ? output_11_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_11_axis_tdest  = DEST_ENABLE ? output_11_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_11_axis_tuser  = USER_ENABLE ? output_11_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_12_axis_tdata  = output_12_axis_tdata_reg;
assign output_12_axis_tkeep  = KEEP_ENABLE ? output_12_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_12_axis_tvalid = output_12_axis_tvalid_reg;
assign output_12_axis_tlast  = LAST_ENABLE ? output_12_axis_tlast_reg : 1'b1;
assign output_12_axis_tid    = ID_ENABLE   ? output_12_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_12_axis_tdest  = DEST_ENABLE ? output_12_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_12_axis_tuser  = USER_ENABLE ? output_12_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_13_axis_tdata  = output_13_axis_tdata_reg;
assign output_13_axis_tkeep  = KEEP_ENABLE ? output_13_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_13_axis_tvalid = output_13_axis_tvalid_reg;
assign output_13_axis_tlast  = LAST_ENABLE ? output_13_axis_tlast_reg : 1'b1;
assign output_13_axis_tid    = ID_ENABLE   ? output_13_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_13_axis_tdest  = DEST_ENABLE ? output_13_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_13_axis_tuser  = USER_ENABLE ? output_13_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_14_axis_tdata  = output_14_axis_tdata_reg;
assign output_14_axis_tkeep  = KEEP_ENABLE ? output_14_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_14_axis_tvalid = output_14_axis_tvalid_reg;
assign output_14_axis_tlast  = LAST_ENABLE ? output_14_axis_tlast_reg : 1'b1;
assign output_14_axis_tid    = ID_ENABLE   ? output_14_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_14_axis_tdest  = DEST_ENABLE ? output_14_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_14_axis_tuser  = USER_ENABLE ? output_14_axis_tuser_reg : {USER_WIDTH{1'b0}};

assign output_15_axis_tdata  = output_15_axis_tdata_reg;
assign output_15_axis_tkeep  = KEEP_ENABLE ? output_15_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_15_axis_tvalid = output_15_axis_tvalid_reg;
assign output_15_axis_tlast  = LAST_ENABLE ? output_15_axis_tlast_reg : 1'b1;
assign output_15_axis_tid    = ID_ENABLE   ? output_15_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_15_axis_tdest  = DEST_ENABLE ? output_15_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_15_axis_tuser  = USER_ENABLE ? output_15_axis_tuser_reg : {USER_WIDTH{1'b0}};

always @(posedge clk) begin
    if (rst) begin
        output_0_select_reg <= 4'd0;
        output_1_select_reg <= 4'd0;
        output_2_select_reg <= 4'd0;
        output_3_select_reg <= 4'd0;
        output_4_select_reg <= 4'd0;
        output_5_select_reg <= 4'd0;
        output_6_select_reg <= 4'd0;
        output_7_select_reg <= 4'd0;
        output_8_select_reg <= 4'd0;
        output_9_select_reg <= 4'd0;
        output_10_select_reg <= 4'd0;
        output_11_select_reg <= 4'd0;
        output_12_select_reg <= 4'd0;
        output_13_select_reg <= 4'd0;
        output_14_select_reg <= 4'd0;
        output_15_select_reg <= 4'd0;

        input_0_axis_tvalid_reg <= 1'b0;
        input_1_axis_tvalid_reg <= 1'b0;
        input_2_axis_tvalid_reg <= 1'b0;
        input_3_axis_tvalid_reg <= 1'b0;
        input_4_axis_tvalid_reg <= 1'b0;
        input_5_axis_tvalid_reg <= 1'b0;
        input_6_axis_tvalid_reg <= 1'b0;
        input_7_axis_tvalid_reg <= 1'b0;
        input_8_axis_tvalid_reg <= 1'b0;
        input_9_axis_tvalid_reg <= 1'b0;
        input_10_axis_tvalid_reg <= 1'b0;
        input_11_axis_tvalid_reg <= 1'b0;
        input_12_axis_tvalid_reg <= 1'b0;
        input_13_axis_tvalid_reg <= 1'b0;
        input_14_axis_tvalid_reg <= 1'b0;
        input_15_axis_tvalid_reg <= 1'b0;

        output_0_axis_tvalid_reg <= 1'b0;
        output_1_axis_tvalid_reg <= 1'b0;
        output_2_axis_tvalid_reg <= 1'b0;
        output_3_axis_tvalid_reg <= 1'b0;
        output_4_axis_tvalid_reg <= 1'b0;
        output_5_axis_tvalid_reg <= 1'b0;
        output_6_axis_tvalid_reg <= 1'b0;
        output_7_axis_tvalid_reg <= 1'b0;
        output_8_axis_tvalid_reg <= 1'b0;
        output_9_axis_tvalid_reg <= 1'b0;
        output_10_axis_tvalid_reg <= 1'b0;
        output_11_axis_tvalid_reg <= 1'b0;
        output_12_axis_tvalid_reg <= 1'b0;
        output_13_axis_tvalid_reg <= 1'b0;
        output_14_axis_tvalid_reg <= 1'b0;
        output_15_axis_tvalid_reg <= 1'b0;
    end else begin
        input_0_axis_tvalid_reg <= input_0_axis_tvalid;
        input_1_axis_tvalid_reg <= input_1_axis_tvalid;
        input_2_axis_tvalid_reg <= input_2_axis_tvalid;
        input_3_axis_tvalid_reg <= input_3_axis_tvalid;
        input_4_axis_tvalid_reg <= input_4_axis_tvalid;
        input_5_axis_tvalid_reg <= input_5_axis_tvalid;
        input_6_axis_tvalid_reg <= input_6_axis_tvalid;
        input_7_axis_tvalid_reg <= input_7_axis_tvalid;
        input_8_axis_tvalid_reg <= input_8_axis_tvalid;
        input_9_axis_tvalid_reg <= input_9_axis_tvalid;
        input_10_axis_tvalid_reg <= input_10_axis_tvalid;
        input_11_axis_tvalid_reg <= input_11_axis_tvalid;
        input_12_axis_tvalid_reg <= input_12_axis_tvalid;
        input_13_axis_tvalid_reg <= input_13_axis_tvalid;
        input_14_axis_tvalid_reg <= input_14_axis_tvalid;
        input_15_axis_tvalid_reg <= input_15_axis_tvalid;

        output_0_select_reg <= output_0_select;
        output_1_select_reg <= output_1_select;
        output_2_select_reg <= output_2_select;
        output_3_select_reg <= output_3_select;
        output_4_select_reg <= output_4_select;
        output_5_select_reg <= output_5_select;
        output_6_select_reg <= output_6_select;
        output_7_select_reg <= output_7_select;
        output_8_select_reg <= output_8_select;
        output_9_select_reg <= output_9_select;
        output_10_select_reg <= output_10_select;
        output_11_select_reg <= output_11_select;
        output_12_select_reg <= output_12_select;
        output_13_select_reg <= output_13_select;
        output_14_select_reg <= output_14_select;
        output_15_select_reg <= output_15_select;

        case (output_0_select_reg)
            4'd0: output_0_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_0_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_0_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_0_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_0_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_0_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_0_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_0_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_0_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_0_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_0_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_0_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_0_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_0_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_0_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_0_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_1_select_reg)
            4'd0: output_1_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_1_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_1_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_1_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_1_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_1_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_1_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_1_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_1_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_1_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_1_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_1_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_1_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_1_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_1_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_1_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_2_select_reg)
            4'd0: output_2_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_2_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_2_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_2_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_2_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_2_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_2_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_2_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_2_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_2_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_2_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_2_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_2_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_2_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_2_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_2_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_3_select_reg)
            4'd0: output_3_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_3_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_3_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_3_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_3_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_3_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_3_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_3_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_3_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_3_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_3_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_3_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_3_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_3_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_3_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_3_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_4_select_reg)
            4'd0: output_4_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_4_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_4_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_4_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_4_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_4_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_4_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_4_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_4_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_4_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_4_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_4_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_4_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_4_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_4_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_4_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_5_select_reg)
            4'd0: output_5_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_5_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_5_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_5_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_5_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_5_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_5_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_5_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_5_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_5_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_5_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_5_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_5_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_5_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_5_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_5_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_6_select_reg)
            4'd0: output_6_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_6_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_6_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_6_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_6_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_6_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_6_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_6_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_6_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_6_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_6_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_6_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_6_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_6_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_6_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_6_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_7_select_reg)
            4'd0: output_7_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_7_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_7_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_7_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_7_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_7_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_7_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_7_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_7_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_7_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_7_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_7_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_7_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_7_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_7_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_7_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_8_select_reg)
            4'd0: output_8_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_8_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_8_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_8_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_8_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_8_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_8_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_8_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_8_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_8_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_8_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_8_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_8_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_8_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_8_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_8_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_9_select_reg)
            4'd0: output_9_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_9_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_9_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_9_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_9_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_9_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_9_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_9_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_9_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_9_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_9_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_9_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_9_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_9_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_9_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_9_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_10_select_reg)
            4'd0: output_10_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_10_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_10_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_10_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_10_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_10_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_10_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_10_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_10_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_10_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_10_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_10_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_10_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_10_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_10_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_10_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_11_select_reg)
            4'd0: output_11_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_11_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_11_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_11_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_11_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_11_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_11_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_11_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_11_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_11_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_11_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_11_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_11_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_11_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_11_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_11_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_12_select_reg)
            4'd0: output_12_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_12_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_12_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_12_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_12_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_12_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_12_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_12_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_12_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_12_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_12_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_12_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_12_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_12_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_12_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_12_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_13_select_reg)
            4'd0: output_13_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_13_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_13_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_13_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_13_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_13_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_13_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_13_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_13_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_13_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_13_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_13_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_13_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_13_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_13_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_13_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_14_select_reg)
            4'd0: output_14_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_14_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_14_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_14_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_14_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_14_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_14_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_14_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_14_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_14_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_14_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_14_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_14_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_14_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_14_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_14_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase

        case (output_15_select_reg)
            4'd0: output_15_axis_tvalid_reg <= input_0_axis_tvalid_reg;
            4'd1: output_15_axis_tvalid_reg <= input_1_axis_tvalid_reg;
            4'd2: output_15_axis_tvalid_reg <= input_2_axis_tvalid_reg;
            4'd3: output_15_axis_tvalid_reg <= input_3_axis_tvalid_reg;
            4'd4: output_15_axis_tvalid_reg <= input_4_axis_tvalid_reg;
            4'd5: output_15_axis_tvalid_reg <= input_5_axis_tvalid_reg;
            4'd6: output_15_axis_tvalid_reg <= input_6_axis_tvalid_reg;
            4'd7: output_15_axis_tvalid_reg <= input_7_axis_tvalid_reg;
            4'd8: output_15_axis_tvalid_reg <= input_8_axis_tvalid_reg;
            4'd9: output_15_axis_tvalid_reg <= input_9_axis_tvalid_reg;
            4'd10: output_15_axis_tvalid_reg <= input_10_axis_tvalid_reg;
            4'd11: output_15_axis_tvalid_reg <= input_11_axis_tvalid_reg;
            4'd12: output_15_axis_tvalid_reg <= input_12_axis_tvalid_reg;
            4'd13: output_15_axis_tvalid_reg <= input_13_axis_tvalid_reg;
            4'd14: output_15_axis_tvalid_reg <= input_14_axis_tvalid_reg;
            4'd15: output_15_axis_tvalid_reg <= input_15_axis_tvalid_reg;
        endcase
    end

    input_0_axis_tdata_reg <= input_0_axis_tdata;
    input_0_axis_tkeep_reg <= input_0_axis_tkeep;
    input_0_axis_tlast_reg <= input_0_axis_tlast;
    input_0_axis_tid_reg   <= input_0_axis_tid;
    input_0_axis_tdest_reg <= input_0_axis_tdest;
    input_0_axis_tuser_reg <= input_0_axis_tuser;

    input_1_axis_tdata_reg <= input_1_axis_tdata;
    input_1_axis_tkeep_reg <= input_1_axis_tkeep;
    input_1_axis_tlast_reg <= input_1_axis_tlast;
    input_1_axis_tid_reg   <= input_1_axis_tid;
    input_1_axis_tdest_reg <= input_1_axis_tdest;
    input_1_axis_tuser_reg <= input_1_axis_tuser;

    input_2_axis_tdata_reg <= input_2_axis_tdata;
    input_2_axis_tkeep_reg <= input_2_axis_tkeep;
    input_2_axis_tlast_reg <= input_2_axis_tlast;
    input_2_axis_tid_reg   <= input_2_axis_tid;
    input_2_axis_tdest_reg <= input_2_axis_tdest;
    input_2_axis_tuser_reg <= input_2_axis_tuser;

    input_3_axis_tdata_reg <= input_3_axis_tdata;
    input_3_axis_tkeep_reg <= input_3_axis_tkeep;
    input_3_axis_tlast_reg <= input_3_axis_tlast;
    input_3_axis_tid_reg   <= input_3_axis_tid;
    input_3_axis_tdest_reg <= input_3_axis_tdest;
    input_3_axis_tuser_reg <= input_3_axis_tuser;

    input_4_axis_tdata_reg <= input_4_axis_tdata;
    input_4_axis_tkeep_reg <= input_4_axis_tkeep;
    input_4_axis_tlast_reg <= input_4_axis_tlast;
    input_4_axis_tid_reg   <= input_4_axis_tid;
    input_4_axis_tdest_reg <= input_4_axis_tdest;
    input_4_axis_tuser_reg <= input_4_axis_tuser;

    input_5_axis_tdata_reg <= input_5_axis_tdata;
    input_5_axis_tkeep_reg <= input_5_axis_tkeep;
    input_5_axis_tlast_reg <= input_5_axis_tlast;
    input_5_axis_tid_reg   <= input_5_axis_tid;
    input_5_axis_tdest_reg <= input_5_axis_tdest;
    input_5_axis_tuser_reg <= input_5_axis_tuser;

    input_6_axis_tdata_reg <= input_6_axis_tdata;
    input_6_axis_tkeep_reg <= input_6_axis_tkeep;
    input_6_axis_tlast_reg <= input_6_axis_tlast;
    input_6_axis_tid_reg   <= input_6_axis_tid;
    input_6_axis_tdest_reg <= input_6_axis_tdest;
    input_6_axis_tuser_reg <= input_6_axis_tuser;

    input_7_axis_tdata_reg <= input_7_axis_tdata;
    input_7_axis_tkeep_reg <= input_7_axis_tkeep;
    input_7_axis_tlast_reg <= input_7_axis_tlast;
    input_7_axis_tid_reg   <= input_7_axis_tid;
    input_7_axis_tdest_reg <= input_7_axis_tdest;
    input_7_axis_tuser_reg <= input_7_axis_tuser;

    input_8_axis_tdata_reg <= input_8_axis_tdata;
    input_8_axis_tkeep_reg <= input_8_axis_tkeep;
    input_8_axis_tlast_reg <= input_8_axis_tlast;
    input_8_axis_tid_reg   <= input_8_axis_tid;
    input_8_axis_tdest_reg <= input_8_axis_tdest;
    input_8_axis_tuser_reg <= input_8_axis_tuser;

    input_9_axis_tdata_reg <= input_9_axis_tdata;
    input_9_axis_tkeep_reg <= input_9_axis_tkeep;
    input_9_axis_tlast_reg <= input_9_axis_tlast;
    input_9_axis_tid_reg   <= input_9_axis_tid;
    input_9_axis_tdest_reg <= input_9_axis_tdest;
    input_9_axis_tuser_reg <= input_9_axis_tuser;

    input_10_axis_tdata_reg <= input_10_axis_tdata;
    input_10_axis_tkeep_reg <= input_10_axis_tkeep;
    input_10_axis_tlast_reg <= input_10_axis_tlast;
    input_10_axis_tid_reg   <= input_10_axis_tid;
    input_10_axis_tdest_reg <= input_10_axis_tdest;
    input_10_axis_tuser_reg <= input_10_axis_tuser;

    input_11_axis_tdata_reg <= input_11_axis_tdata;
    input_11_axis_tkeep_reg <= input_11_axis_tkeep;
    input_11_axis_tlast_reg <= input_11_axis_tlast;
    input_11_axis_tid_reg   <= input_11_axis_tid;
    input_11_axis_tdest_reg <= input_11_axis_tdest;
    input_11_axis_tuser_reg <= input_11_axis_tuser;

    input_12_axis_tdata_reg <= input_12_axis_tdata;
    input_12_axis_tkeep_reg <= input_12_axis_tkeep;
    input_12_axis_tlast_reg <= input_12_axis_tlast;
    input_12_axis_tid_reg   <= input_12_axis_tid;
    input_12_axis_tdest_reg <= input_12_axis_tdest;
    input_12_axis_tuser_reg <= input_12_axis_tuser;

    input_13_axis_tdata_reg <= input_13_axis_tdata;
    input_13_axis_tkeep_reg <= input_13_axis_tkeep;
    input_13_axis_tlast_reg <= input_13_axis_tlast;
    input_13_axis_tid_reg   <= input_13_axis_tid;
    input_13_axis_tdest_reg <= input_13_axis_tdest;
    input_13_axis_tuser_reg <= input_13_axis_tuser;

    input_14_axis_tdata_reg <= input_14_axis_tdata;
    input_14_axis_tkeep_reg <= input_14_axis_tkeep;
    input_14_axis_tlast_reg <= input_14_axis_tlast;
    input_14_axis_tid_reg   <= input_14_axis_tid;
    input_14_axis_tdest_reg <= input_14_axis_tdest;
    input_14_axis_tuser_reg <= input_14_axis_tuser;

    input_15_axis_tdata_reg <= input_15_axis_tdata;
    input_15_axis_tkeep_reg <= input_15_axis_tkeep;
    input_15_axis_tlast_reg <= input_15_axis_tlast;
    input_15_axis_tid_reg   <= input_15_axis_tid;
    input_15_axis_tdest_reg <= input_15_axis_tdest;
    input_15_axis_tuser_reg <= input_15_axis_tuser;

    case (output_0_select_reg)
        4'd0: begin
            output_0_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_0_axis_tid_reg;
            output_0_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_0_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_1_axis_tid_reg;
            output_0_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_0_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_2_axis_tid_reg;
            output_0_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_0_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_3_axis_tid_reg;
            output_0_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_0_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_4_axis_tid_reg;
            output_0_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_0_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_5_axis_tid_reg;
            output_0_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_0_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_6_axis_tid_reg;
            output_0_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_0_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_7_axis_tid_reg;
            output_0_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_0_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_8_axis_tid_reg;
            output_0_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_0_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_9_axis_tid_reg;
            output_0_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_0_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_10_axis_tid_reg;
            output_0_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_0_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_11_axis_tid_reg;
            output_0_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_0_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_12_axis_tid_reg;
            output_0_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_0_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_13_axis_tid_reg;
            output_0_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_0_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_14_axis_tid_reg;
            output_0_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_0_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_0_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_0_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_0_axis_tid_reg   <= input_15_axis_tid_reg;
            output_0_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_0_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_1_select_reg)
        4'd0: begin
            output_1_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_0_axis_tid_reg;
            output_1_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_1_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_1_axis_tid_reg;
            output_1_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_1_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_2_axis_tid_reg;
            output_1_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_1_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_3_axis_tid_reg;
            output_1_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_1_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_4_axis_tid_reg;
            output_1_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_1_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_5_axis_tid_reg;
            output_1_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_1_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_6_axis_tid_reg;
            output_1_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_1_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_7_axis_tid_reg;
            output_1_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_1_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_8_axis_tid_reg;
            output_1_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_1_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_9_axis_tid_reg;
            output_1_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_1_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_10_axis_tid_reg;
            output_1_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_1_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_11_axis_tid_reg;
            output_1_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_1_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_12_axis_tid_reg;
            output_1_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_1_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_13_axis_tid_reg;
            output_1_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_1_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_14_axis_tid_reg;
            output_1_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_1_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_1_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_1_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_1_axis_tid_reg   <= input_15_axis_tid_reg;
            output_1_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_1_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_2_select_reg)
        4'd0: begin
            output_2_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_0_axis_tid_reg;
            output_2_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_2_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_1_axis_tid_reg;
            output_2_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_2_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_2_axis_tid_reg;
            output_2_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_2_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_3_axis_tid_reg;
            output_2_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_2_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_4_axis_tid_reg;
            output_2_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_2_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_5_axis_tid_reg;
            output_2_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_2_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_6_axis_tid_reg;
            output_2_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_2_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_7_axis_tid_reg;
            output_2_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_2_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_8_axis_tid_reg;
            output_2_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_2_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_9_axis_tid_reg;
            output_2_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_2_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_10_axis_tid_reg;
            output_2_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_2_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_11_axis_tid_reg;
            output_2_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_2_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_12_axis_tid_reg;
            output_2_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_2_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_13_axis_tid_reg;
            output_2_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_2_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_14_axis_tid_reg;
            output_2_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_2_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_2_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_2_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_2_axis_tid_reg   <= input_15_axis_tid_reg;
            output_2_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_2_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_3_select_reg)
        4'd0: begin
            output_3_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_0_axis_tid_reg;
            output_3_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_3_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_1_axis_tid_reg;
            output_3_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_3_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_2_axis_tid_reg;
            output_3_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_3_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_3_axis_tid_reg;
            output_3_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_3_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_4_axis_tid_reg;
            output_3_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_3_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_5_axis_tid_reg;
            output_3_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_3_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_6_axis_tid_reg;
            output_3_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_3_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_7_axis_tid_reg;
            output_3_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_3_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_8_axis_tid_reg;
            output_3_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_3_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_9_axis_tid_reg;
            output_3_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_3_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_10_axis_tid_reg;
            output_3_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_3_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_11_axis_tid_reg;
            output_3_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_3_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_12_axis_tid_reg;
            output_3_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_3_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_13_axis_tid_reg;
            output_3_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_3_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_14_axis_tid_reg;
            output_3_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_3_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_3_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_3_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_3_axis_tid_reg   <= input_15_axis_tid_reg;
            output_3_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_3_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_4_select_reg)
        4'd0: begin
            output_4_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_0_axis_tid_reg;
            output_4_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_4_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_1_axis_tid_reg;
            output_4_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_4_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_2_axis_tid_reg;
            output_4_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_4_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_3_axis_tid_reg;
            output_4_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_4_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_4_axis_tid_reg;
            output_4_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_4_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_5_axis_tid_reg;
            output_4_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_4_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_6_axis_tid_reg;
            output_4_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_4_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_7_axis_tid_reg;
            output_4_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_4_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_8_axis_tid_reg;
            output_4_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_4_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_9_axis_tid_reg;
            output_4_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_4_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_10_axis_tid_reg;
            output_4_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_4_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_11_axis_tid_reg;
            output_4_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_4_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_12_axis_tid_reg;
            output_4_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_4_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_13_axis_tid_reg;
            output_4_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_4_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_14_axis_tid_reg;
            output_4_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_4_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_4_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_4_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_4_axis_tid_reg   <= input_15_axis_tid_reg;
            output_4_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_4_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_5_select_reg)
        4'd0: begin
            output_5_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_0_axis_tid_reg;
            output_5_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_5_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_1_axis_tid_reg;
            output_5_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_5_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_2_axis_tid_reg;
            output_5_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_5_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_3_axis_tid_reg;
            output_5_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_5_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_4_axis_tid_reg;
            output_5_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_5_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_5_axis_tid_reg;
            output_5_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_5_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_6_axis_tid_reg;
            output_5_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_5_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_7_axis_tid_reg;
            output_5_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_5_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_8_axis_tid_reg;
            output_5_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_5_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_9_axis_tid_reg;
            output_5_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_5_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_10_axis_tid_reg;
            output_5_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_5_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_11_axis_tid_reg;
            output_5_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_5_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_12_axis_tid_reg;
            output_5_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_5_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_13_axis_tid_reg;
            output_5_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_5_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_14_axis_tid_reg;
            output_5_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_5_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_5_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_5_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_5_axis_tid_reg   <= input_15_axis_tid_reg;
            output_5_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_5_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_6_select_reg)
        4'd0: begin
            output_6_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_0_axis_tid_reg;
            output_6_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_6_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_1_axis_tid_reg;
            output_6_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_6_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_2_axis_tid_reg;
            output_6_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_6_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_3_axis_tid_reg;
            output_6_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_6_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_4_axis_tid_reg;
            output_6_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_6_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_5_axis_tid_reg;
            output_6_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_6_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_6_axis_tid_reg;
            output_6_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_6_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_7_axis_tid_reg;
            output_6_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_6_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_8_axis_tid_reg;
            output_6_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_6_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_9_axis_tid_reg;
            output_6_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_6_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_10_axis_tid_reg;
            output_6_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_6_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_11_axis_tid_reg;
            output_6_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_6_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_12_axis_tid_reg;
            output_6_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_6_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_13_axis_tid_reg;
            output_6_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_6_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_14_axis_tid_reg;
            output_6_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_6_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_6_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_6_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_6_axis_tid_reg   <= input_15_axis_tid_reg;
            output_6_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_6_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_7_select_reg)
        4'd0: begin
            output_7_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_0_axis_tid_reg;
            output_7_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_7_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_1_axis_tid_reg;
            output_7_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_7_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_2_axis_tid_reg;
            output_7_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_7_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_3_axis_tid_reg;
            output_7_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_7_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_4_axis_tid_reg;
            output_7_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_7_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_5_axis_tid_reg;
            output_7_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_7_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_6_axis_tid_reg;
            output_7_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_7_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_7_axis_tid_reg;
            output_7_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_7_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_8_axis_tid_reg;
            output_7_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_7_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_9_axis_tid_reg;
            output_7_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_7_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_10_axis_tid_reg;
            output_7_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_7_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_11_axis_tid_reg;
            output_7_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_7_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_12_axis_tid_reg;
            output_7_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_7_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_13_axis_tid_reg;
            output_7_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_7_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_14_axis_tid_reg;
            output_7_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_7_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_7_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_7_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_7_axis_tid_reg   <= input_15_axis_tid_reg;
            output_7_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_7_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_8_select_reg)
        4'd0: begin
            output_8_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_0_axis_tid_reg;
            output_8_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_8_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_1_axis_tid_reg;
            output_8_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_8_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_2_axis_tid_reg;
            output_8_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_8_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_3_axis_tid_reg;
            output_8_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_8_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_4_axis_tid_reg;
            output_8_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_8_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_5_axis_tid_reg;
            output_8_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_8_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_6_axis_tid_reg;
            output_8_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_8_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_7_axis_tid_reg;
            output_8_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_8_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_8_axis_tid_reg;
            output_8_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_8_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_9_axis_tid_reg;
            output_8_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_8_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_10_axis_tid_reg;
            output_8_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_8_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_11_axis_tid_reg;
            output_8_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_8_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_12_axis_tid_reg;
            output_8_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_8_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_13_axis_tid_reg;
            output_8_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_8_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_14_axis_tid_reg;
            output_8_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_8_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_8_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_8_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_8_axis_tid_reg   <= input_15_axis_tid_reg;
            output_8_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_8_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_9_select_reg)
        4'd0: begin
            output_9_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_0_axis_tid_reg;
            output_9_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_9_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_1_axis_tid_reg;
            output_9_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_9_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_2_axis_tid_reg;
            output_9_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_9_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_3_axis_tid_reg;
            output_9_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_9_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_4_axis_tid_reg;
            output_9_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_9_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_5_axis_tid_reg;
            output_9_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_9_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_6_axis_tid_reg;
            output_9_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_9_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_7_axis_tid_reg;
            output_9_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_9_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_8_axis_tid_reg;
            output_9_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_9_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_9_axis_tid_reg;
            output_9_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_9_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_10_axis_tid_reg;
            output_9_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_9_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_11_axis_tid_reg;
            output_9_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_9_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_12_axis_tid_reg;
            output_9_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_9_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_13_axis_tid_reg;
            output_9_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_9_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_14_axis_tid_reg;
            output_9_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_9_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_9_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_9_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_9_axis_tid_reg   <= input_15_axis_tid_reg;
            output_9_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_9_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_10_select_reg)
        4'd0: begin
            output_10_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_0_axis_tid_reg;
            output_10_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_10_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_1_axis_tid_reg;
            output_10_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_10_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_2_axis_tid_reg;
            output_10_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_10_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_3_axis_tid_reg;
            output_10_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_10_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_4_axis_tid_reg;
            output_10_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_10_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_5_axis_tid_reg;
            output_10_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_10_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_6_axis_tid_reg;
            output_10_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_10_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_7_axis_tid_reg;
            output_10_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_10_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_8_axis_tid_reg;
            output_10_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_10_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_9_axis_tid_reg;
            output_10_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_10_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_10_axis_tid_reg;
            output_10_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_10_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_11_axis_tid_reg;
            output_10_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_10_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_12_axis_tid_reg;
            output_10_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_10_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_13_axis_tid_reg;
            output_10_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_10_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_14_axis_tid_reg;
            output_10_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_10_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_10_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_10_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_10_axis_tid_reg   <= input_15_axis_tid_reg;
            output_10_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_10_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_11_select_reg)
        4'd0: begin
            output_11_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_0_axis_tid_reg;
            output_11_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_11_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_1_axis_tid_reg;
            output_11_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_11_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_2_axis_tid_reg;
            output_11_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_11_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_3_axis_tid_reg;
            output_11_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_11_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_4_axis_tid_reg;
            output_11_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_11_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_5_axis_tid_reg;
            output_11_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_11_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_6_axis_tid_reg;
            output_11_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_11_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_7_axis_tid_reg;
            output_11_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_11_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_8_axis_tid_reg;
            output_11_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_11_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_9_axis_tid_reg;
            output_11_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_11_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_10_axis_tid_reg;
            output_11_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_11_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_11_axis_tid_reg;
            output_11_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_11_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_12_axis_tid_reg;
            output_11_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_11_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_13_axis_tid_reg;
            output_11_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_11_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_14_axis_tid_reg;
            output_11_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_11_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_11_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_11_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_11_axis_tid_reg   <= input_15_axis_tid_reg;
            output_11_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_11_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_12_select_reg)
        4'd0: begin
            output_12_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_0_axis_tid_reg;
            output_12_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_12_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_1_axis_tid_reg;
            output_12_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_12_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_2_axis_tid_reg;
            output_12_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_12_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_3_axis_tid_reg;
            output_12_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_12_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_4_axis_tid_reg;
            output_12_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_12_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_5_axis_tid_reg;
            output_12_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_12_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_6_axis_tid_reg;
            output_12_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_12_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_7_axis_tid_reg;
            output_12_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_12_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_8_axis_tid_reg;
            output_12_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_12_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_9_axis_tid_reg;
            output_12_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_12_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_10_axis_tid_reg;
            output_12_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_12_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_11_axis_tid_reg;
            output_12_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_12_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_12_axis_tid_reg;
            output_12_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_12_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_13_axis_tid_reg;
            output_12_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_12_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_14_axis_tid_reg;
            output_12_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_12_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_12_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_12_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_12_axis_tid_reg   <= input_15_axis_tid_reg;
            output_12_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_12_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_13_select_reg)
        4'd0: begin
            output_13_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_0_axis_tid_reg;
            output_13_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_13_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_1_axis_tid_reg;
            output_13_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_13_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_2_axis_tid_reg;
            output_13_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_13_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_3_axis_tid_reg;
            output_13_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_13_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_4_axis_tid_reg;
            output_13_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_13_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_5_axis_tid_reg;
            output_13_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_13_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_6_axis_tid_reg;
            output_13_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_13_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_7_axis_tid_reg;
            output_13_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_13_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_8_axis_tid_reg;
            output_13_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_13_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_9_axis_tid_reg;
            output_13_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_13_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_10_axis_tid_reg;
            output_13_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_13_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_11_axis_tid_reg;
            output_13_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_13_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_12_axis_tid_reg;
            output_13_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_13_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_13_axis_tid_reg;
            output_13_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_13_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_14_axis_tid_reg;
            output_13_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_13_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_13_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_13_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_13_axis_tid_reg   <= input_15_axis_tid_reg;
            output_13_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_13_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_14_select_reg)
        4'd0: begin
            output_14_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_0_axis_tid_reg;
            output_14_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_14_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_1_axis_tid_reg;
            output_14_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_14_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_2_axis_tid_reg;
            output_14_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_14_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_3_axis_tid_reg;
            output_14_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_14_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_4_axis_tid_reg;
            output_14_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_14_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_5_axis_tid_reg;
            output_14_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_14_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_6_axis_tid_reg;
            output_14_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_14_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_7_axis_tid_reg;
            output_14_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_14_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_8_axis_tid_reg;
            output_14_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_14_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_9_axis_tid_reg;
            output_14_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_14_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_10_axis_tid_reg;
            output_14_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_14_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_11_axis_tid_reg;
            output_14_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_14_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_12_axis_tid_reg;
            output_14_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_14_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_13_axis_tid_reg;
            output_14_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_14_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_14_axis_tid_reg;
            output_14_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_14_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_14_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_14_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_14_axis_tid_reg   <= input_15_axis_tid_reg;
            output_14_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_14_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase

    case (output_15_select_reg)
        4'd0: begin
            output_15_axis_tdata_reg <= input_0_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_0_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_0_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_0_axis_tid_reg;
            output_15_axis_tdest_reg <= input_0_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_0_axis_tuser_reg;
        end
        4'd1: begin
            output_15_axis_tdata_reg <= input_1_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_1_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_1_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_1_axis_tid_reg;
            output_15_axis_tdest_reg <= input_1_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_1_axis_tuser_reg;
        end
        4'd2: begin
            output_15_axis_tdata_reg <= input_2_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_2_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_2_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_2_axis_tid_reg;
            output_15_axis_tdest_reg <= input_2_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_2_axis_tuser_reg;
        end
        4'd3: begin
            output_15_axis_tdata_reg <= input_3_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_3_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_3_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_3_axis_tid_reg;
            output_15_axis_tdest_reg <= input_3_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_3_axis_tuser_reg;
        end
        4'd4: begin
            output_15_axis_tdata_reg <= input_4_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_4_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_4_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_4_axis_tid_reg;
            output_15_axis_tdest_reg <= input_4_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_4_axis_tuser_reg;
        end
        4'd5: begin
            output_15_axis_tdata_reg <= input_5_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_5_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_5_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_5_axis_tid_reg;
            output_15_axis_tdest_reg <= input_5_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_5_axis_tuser_reg;
        end
        4'd6: begin
            output_15_axis_tdata_reg <= input_6_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_6_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_6_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_6_axis_tid_reg;
            output_15_axis_tdest_reg <= input_6_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_6_axis_tuser_reg;
        end
        4'd7: begin
            output_15_axis_tdata_reg <= input_7_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_7_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_7_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_7_axis_tid_reg;
            output_15_axis_tdest_reg <= input_7_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_7_axis_tuser_reg;
        end
        4'd8: begin
            output_15_axis_tdata_reg <= input_8_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_8_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_8_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_8_axis_tid_reg;
            output_15_axis_tdest_reg <= input_8_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_8_axis_tuser_reg;
        end
        4'd9: begin
            output_15_axis_tdata_reg <= input_9_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_9_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_9_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_9_axis_tid_reg;
            output_15_axis_tdest_reg <= input_9_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_9_axis_tuser_reg;
        end
        4'd10: begin
            output_15_axis_tdata_reg <= input_10_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_10_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_10_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_10_axis_tid_reg;
            output_15_axis_tdest_reg <= input_10_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_10_axis_tuser_reg;
        end
        4'd11: begin
            output_15_axis_tdata_reg <= input_11_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_11_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_11_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_11_axis_tid_reg;
            output_15_axis_tdest_reg <= input_11_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_11_axis_tuser_reg;
        end
        4'd12: begin
            output_15_axis_tdata_reg <= input_12_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_12_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_12_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_12_axis_tid_reg;
            output_15_axis_tdest_reg <= input_12_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_12_axis_tuser_reg;
        end
        4'd13: begin
            output_15_axis_tdata_reg <= input_13_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_13_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_13_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_13_axis_tid_reg;
            output_15_axis_tdest_reg <= input_13_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_13_axis_tuser_reg;
        end
        4'd14: begin
            output_15_axis_tdata_reg <= input_14_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_14_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_14_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_14_axis_tid_reg;
            output_15_axis_tdest_reg <= input_14_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_14_axis_tuser_reg;
        end
        4'd15: begin
            output_15_axis_tdata_reg <= input_15_axis_tdata_reg;
            output_15_axis_tkeep_reg <= input_15_axis_tkeep_reg;
            output_15_axis_tlast_reg <= input_15_axis_tlast_reg;
            output_15_axis_tid_reg   <= input_15_axis_tid_reg;
            output_15_axis_tdest_reg <= input_15_axis_tdest_reg;
            output_15_axis_tuser_reg <= input_15_axis_tuser_reg;
        end
    endcase
end

endmodule
