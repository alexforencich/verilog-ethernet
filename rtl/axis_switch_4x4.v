/*

Copyright (c) 2016-2018 Alex Forencich

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
 * AXI4-Stream 4x4 switch
 */
module axis_switch_4x4 #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_WIDTH = 2,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    parameter OUT_0_BASE = 0,
    parameter OUT_0_TOP = 0,
    parameter OUT_0_CONNECT = 4'b1111,
    parameter OUT_1_BASE = 1,
    parameter OUT_1_TOP = 1,
    parameter OUT_1_CONNECT = 4'b1111,
    parameter OUT_2_BASE = 2,
    parameter OUT_2_TOP = 2,
    parameter OUT_2_CONNECT = 4'b1111,
    parameter OUT_3_BASE = 3,
    parameter OUT_3_TOP = 3,
    parameter OUT_3_CONNECT = 4'b1111,
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "ROUND_ROBIN",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI Stream inputs
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
     * AXI Stream outputs
     */
    output wire [DATA_WIDTH-1:0]  output_0_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_0_axis_tkeep,
    output wire                   output_0_axis_tvalid,
    input  wire                   output_0_axis_tready,
    output wire                   output_0_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_0_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_0_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_0_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_1_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_1_axis_tkeep,
    output wire                   output_1_axis_tvalid,
    input  wire                   output_1_axis_tready,
    output wire                   output_1_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_1_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_1_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_1_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_2_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_2_axis_tkeep,
    output wire                   output_2_axis_tvalid,
    input  wire                   output_2_axis_tready,
    output wire                   output_2_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_2_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_2_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_2_axis_tuser,

    output wire [DATA_WIDTH-1:0]  output_3_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_3_axis_tkeep,
    output wire                   output_3_axis_tvalid,
    input  wire                   output_3_axis_tready,
    output wire                   output_3_axis_tlast,
    output wire [ID_WIDTH-1:0]    output_3_axis_tid,
    output wire [DEST_WIDTH-1:0]  output_3_axis_tdest,
    output wire [USER_WIDTH-1:0]  output_3_axis_tuser
);

// check configuration
initial begin
    if (2**DEST_WIDTH < 4) begin
        $error("Error: DEST_WIDTH too small for port count");
        $finish;
    end

    if ((OUT_0_BASE & 2**DEST_WIDTH-1) != OUT_0_BASE || (OUT_0_TOP & 2**DEST_WIDTH-1) != OUT_0_TOP ||
        (OUT_1_BASE & 2**DEST_WIDTH-1) != OUT_1_BASE || (OUT_1_TOP & 2**DEST_WIDTH-1) != OUT_1_TOP ||
        (OUT_2_BASE & 2**DEST_WIDTH-1) != OUT_2_BASE || (OUT_2_TOP & 2**DEST_WIDTH-1) != OUT_2_TOP ||
        (OUT_3_BASE & 2**DEST_WIDTH-1) != OUT_3_BASE || (OUT_3_TOP & 2**DEST_WIDTH-1) != OUT_3_TOP) begin
        $error("Error: value out of range");
        $finish;
    end

    if (OUT_0_BASE > OUT_0_TOP ||
        OUT_1_BASE > OUT_1_TOP ||
        OUT_2_BASE > OUT_2_TOP ||
        OUT_3_BASE > OUT_3_TOP) begin
        $error("Error: invalid range");
        $finish;
    end

    if ((OUT_0_BASE <= OUT_1_TOP && OUT_1_BASE <= OUT_0_TOP) ||
        (OUT_0_BASE <= OUT_2_TOP && OUT_2_BASE <= OUT_0_TOP) ||
        (OUT_0_BASE <= OUT_3_TOP && OUT_3_BASE <= OUT_0_TOP) ||
        (OUT_1_BASE <= OUT_2_TOP && OUT_2_BASE <= OUT_1_TOP) ||
        (OUT_1_BASE <= OUT_3_TOP && OUT_3_BASE <= OUT_1_TOP) ||
        (OUT_2_BASE <= OUT_3_TOP && OUT_3_BASE <= OUT_2_TOP)) begin
        $error("Error: ranges overlap");
        $finish;
    end
end

reg [3:0] input_0_request_reg = 4'd0, input_0_request_next;
reg input_0_request_valid_reg = 1'b0, input_0_request_valid_next;
reg input_0_request_error_reg = 1'b0, input_0_request_error_next;

reg [3:0] input_1_request_reg = 4'd0, input_1_request_next;
reg input_1_request_valid_reg = 1'b0, input_1_request_valid_next;
reg input_1_request_error_reg = 1'b0, input_1_request_error_next;

reg [3:0] input_2_request_reg = 4'd0, input_2_request_next;
reg input_2_request_valid_reg = 1'b0, input_2_request_valid_next;
reg input_2_request_error_reg = 1'b0, input_2_request_error_next;

reg [3:0] input_3_request_reg = 4'd0, input_3_request_next;
reg input_3_request_valid_reg = 1'b0, input_3_request_valid_next;
reg input_3_request_error_reg = 1'b0, input_3_request_error_next;

reg [1:0] select_0_reg = 2'd0, select_0_next;
reg [1:0] select_1_reg = 2'd0, select_1_next;
reg [1:0] select_2_reg = 2'd0, select_2_next;
reg [1:0] select_3_reg = 2'd0, select_3_next;

reg enable_0_reg = 1'b0, enable_0_next;
reg enable_1_reg = 1'b0, enable_1_next;
reg enable_2_reg = 1'b0, enable_2_next;
reg enable_3_reg = 1'b0, enable_3_next;

reg input_0_axis_tready_reg = 1'b0, input_0_axis_tready_next;
reg input_1_axis_tready_reg = 1'b0, input_1_axis_tready_next;
reg input_2_axis_tready_reg = 1'b0, input_2_axis_tready_next;
reg input_3_axis_tready_reg = 1'b0, input_3_axis_tready_next;

// internal datapath
reg  [DATA_WIDTH-1:0] output_0_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] output_0_axis_tkeep_int;
reg                   output_0_axis_tvalid_int;
reg                   output_0_axis_tready_int_reg = 1'b0;
reg                   output_0_axis_tlast_int;
reg  [ID_WIDTH-1:0]   output_0_axis_tid_int;
reg  [DEST_WIDTH-1:0] output_0_axis_tdest_int;
reg  [USER_WIDTH-1:0] output_0_axis_tuser_int;
wire                  output_0_axis_tready_int_early;

reg  [DATA_WIDTH-1:0] output_1_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] output_1_axis_tkeep_int;
reg                   output_1_axis_tvalid_int;
reg                   output_1_axis_tready_int_reg = 1'b0;
reg                   output_1_axis_tlast_int;
reg  [ID_WIDTH-1:0]   output_1_axis_tid_int;
reg  [DEST_WIDTH-1:0] output_1_axis_tdest_int;
reg  [USER_WIDTH-1:0] output_1_axis_tuser_int;
wire                  output_1_axis_tready_int_early;

reg  [DATA_WIDTH-1:0] output_2_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] output_2_axis_tkeep_int;
reg                   output_2_axis_tvalid_int;
reg                   output_2_axis_tready_int_reg = 1'b0;
reg                   output_2_axis_tlast_int;
reg  [ID_WIDTH-1:0]   output_2_axis_tid_int;
reg  [DEST_WIDTH-1:0] output_2_axis_tdest_int;
reg  [USER_WIDTH-1:0] output_2_axis_tuser_int;
wire                  output_2_axis_tready_int_early;

reg  [DATA_WIDTH-1:0] output_3_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] output_3_axis_tkeep_int;
reg                   output_3_axis_tvalid_int;
reg                   output_3_axis_tready_int_reg = 1'b0;
reg                   output_3_axis_tlast_int;
reg  [ID_WIDTH-1:0]   output_3_axis_tid_int;
reg  [DEST_WIDTH-1:0] output_3_axis_tdest_int;
reg  [USER_WIDTH-1:0] output_3_axis_tuser_int;
wire                  output_3_axis_tready_int_early;

assign input_0_axis_tready = input_0_axis_tready_reg;
assign input_1_axis_tready = input_1_axis_tready_reg;
assign input_2_axis_tready = input_2_axis_tready_reg;
assign input_3_axis_tready = input_3_axis_tready_reg;

// mux for incoming packet

reg [DATA_WIDTH-1:0] current_input_0_axis_tdata;
reg [DATA_WIDTH-1:0] current_input_0_axis_tkeep;
reg                  current_input_0_axis_tvalid;
reg                  current_input_0_axis_tready;
reg                  current_input_0_axis_tlast;
reg [ID_WIDTH-1:0]   current_input_0_axis_tid;
reg [DEST_WIDTH-1:0] current_input_0_axis_tdest;
reg [USER_WIDTH-1:0] current_input_0_axis_tuser;

always @* begin
    case (select_0_reg)
        2'd0: begin
            current_input_0_axis_tdata  = input_0_axis_tdata;
            current_input_0_axis_tkeep  = input_0_axis_tkeep;
            current_input_0_axis_tvalid = input_0_axis_tvalid;
            current_input_0_axis_tready = input_0_axis_tready;
            current_input_0_axis_tlast  = input_0_axis_tlast;
            current_input_0_axis_tid    = input_0_axis_tid;
            current_input_0_axis_tdest  = input_0_axis_tdest;
            current_input_0_axis_tuser  = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_0_axis_tdata  = input_1_axis_tdata;
            current_input_0_axis_tkeep  = input_1_axis_tkeep;
            current_input_0_axis_tvalid = input_1_axis_tvalid;
            current_input_0_axis_tready = input_1_axis_tready;
            current_input_0_axis_tlast  = input_1_axis_tlast;
            current_input_0_axis_tid    = input_1_axis_tid;
            current_input_0_axis_tdest  = input_1_axis_tdest;
            current_input_0_axis_tuser  = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_0_axis_tdata  = input_2_axis_tdata;
            current_input_0_axis_tkeep  = input_2_axis_tkeep;
            current_input_0_axis_tvalid = input_2_axis_tvalid;
            current_input_0_axis_tready = input_2_axis_tready;
            current_input_0_axis_tlast  = input_2_axis_tlast;
            current_input_0_axis_tid    = input_2_axis_tid;
            current_input_0_axis_tdest  = input_2_axis_tdest;
            current_input_0_axis_tuser  = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_0_axis_tdata  = input_3_axis_tdata;
            current_input_0_axis_tkeep  = input_3_axis_tkeep;
            current_input_0_axis_tvalid = input_3_axis_tvalid;
            current_input_0_axis_tready = input_3_axis_tready;
            current_input_0_axis_tlast  = input_3_axis_tlast;
            current_input_0_axis_tid    = input_3_axis_tid;
            current_input_0_axis_tdest  = input_3_axis_tdest;
            current_input_0_axis_tuser  = input_3_axis_tuser;
        end
        default: begin
            current_input_0_axis_tdata  = {DATA_WIDTH{1'b0}};
            current_input_0_axis_tkeep  = {KEEP_WIDTH{1'b0}};
            current_input_0_axis_tvalid = 1'b0;
            current_input_0_axis_tready = 1'b0;
            current_input_0_axis_tlast  = 1'b0;
            current_input_0_axis_tid    = {ID_WIDTH{1'b0}};
            current_input_0_axis_tdest  = {DEST_WIDTH{1'b0}};
            current_input_0_axis_tuser  = {USER_WIDTH{1'b0}};
        end
    endcase
end

reg [DATA_WIDTH-1:0] current_input_1_axis_tdata;
reg [DATA_WIDTH-1:0] current_input_1_axis_tkeep;
reg                  current_input_1_axis_tvalid;
reg                  current_input_1_axis_tready;
reg                  current_input_1_axis_tlast;
reg [ID_WIDTH-1:0]   current_input_1_axis_tid;
reg [DEST_WIDTH-1:0] current_input_1_axis_tdest;
reg [USER_WIDTH-1:0] current_input_1_axis_tuser;

always @* begin
    case (select_1_reg)
        2'd0: begin
            current_input_1_axis_tdata  = input_0_axis_tdata;
            current_input_1_axis_tkeep  = input_0_axis_tkeep;
            current_input_1_axis_tvalid = input_0_axis_tvalid;
            current_input_1_axis_tready = input_0_axis_tready;
            current_input_1_axis_tlast  = input_0_axis_tlast;
            current_input_1_axis_tid    = input_0_axis_tid;
            current_input_1_axis_tdest  = input_0_axis_tdest;
            current_input_1_axis_tuser  = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_1_axis_tdata  = input_1_axis_tdata;
            current_input_1_axis_tkeep  = input_1_axis_tkeep;
            current_input_1_axis_tvalid = input_1_axis_tvalid;
            current_input_1_axis_tready = input_1_axis_tready;
            current_input_1_axis_tlast  = input_1_axis_tlast;
            current_input_1_axis_tid    = input_1_axis_tid;
            current_input_1_axis_tdest  = input_1_axis_tdest;
            current_input_1_axis_tuser  = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_1_axis_tdata  = input_2_axis_tdata;
            current_input_1_axis_tkeep  = input_2_axis_tkeep;
            current_input_1_axis_tvalid = input_2_axis_tvalid;
            current_input_1_axis_tready = input_2_axis_tready;
            current_input_1_axis_tlast  = input_2_axis_tlast;
            current_input_1_axis_tid    = input_2_axis_tid;
            current_input_1_axis_tdest  = input_2_axis_tdest;
            current_input_1_axis_tuser  = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_1_axis_tdata  = input_3_axis_tdata;
            current_input_1_axis_tkeep  = input_3_axis_tkeep;
            current_input_1_axis_tvalid = input_3_axis_tvalid;
            current_input_1_axis_tready = input_3_axis_tready;
            current_input_1_axis_tlast  = input_3_axis_tlast;
            current_input_1_axis_tid    = input_3_axis_tid;
            current_input_1_axis_tdest  = input_3_axis_tdest;
            current_input_1_axis_tuser  = input_3_axis_tuser;
        end
        default: begin
            current_input_1_axis_tdata  = {DATA_WIDTH{1'b0}};
            current_input_1_axis_tkeep  = {KEEP_WIDTH{1'b0}};
            current_input_1_axis_tvalid = 1'b0;
            current_input_1_axis_tready = 1'b0;
            current_input_1_axis_tlast  = 1'b0;
            current_input_1_axis_tid    = {ID_WIDTH{1'b0}};
            current_input_1_axis_tdest  = {DEST_WIDTH{1'b0}};
            current_input_1_axis_tuser  = {USER_WIDTH{1'b0}};
        end
    endcase
end

reg [DATA_WIDTH-1:0] current_input_2_axis_tdata;
reg [DATA_WIDTH-1:0] current_input_2_axis_tkeep;
reg                  current_input_2_axis_tvalid;
reg                  current_input_2_axis_tready;
reg                  current_input_2_axis_tlast;
reg [ID_WIDTH-1:0]   current_input_2_axis_tid;
reg [DEST_WIDTH-1:0] current_input_2_axis_tdest;
reg [USER_WIDTH-1:0] current_input_2_axis_tuser;

always @* begin
    case (select_2_reg)
        2'd0: begin
            current_input_2_axis_tdata  = input_0_axis_tdata;
            current_input_2_axis_tkeep  = input_0_axis_tkeep;
            current_input_2_axis_tvalid = input_0_axis_tvalid;
            current_input_2_axis_tready = input_0_axis_tready;
            current_input_2_axis_tlast  = input_0_axis_tlast;
            current_input_2_axis_tid    = input_0_axis_tid;
            current_input_2_axis_tdest  = input_0_axis_tdest;
            current_input_2_axis_tuser  = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_2_axis_tdata  = input_1_axis_tdata;
            current_input_2_axis_tkeep  = input_1_axis_tkeep;
            current_input_2_axis_tvalid = input_1_axis_tvalid;
            current_input_2_axis_tready = input_1_axis_tready;
            current_input_2_axis_tlast  = input_1_axis_tlast;
            current_input_2_axis_tid    = input_1_axis_tid;
            current_input_2_axis_tdest  = input_1_axis_tdest;
            current_input_2_axis_tuser  = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_2_axis_tdata  = input_2_axis_tdata;
            current_input_2_axis_tkeep  = input_2_axis_tkeep;
            current_input_2_axis_tvalid = input_2_axis_tvalid;
            current_input_2_axis_tready = input_2_axis_tready;
            current_input_2_axis_tlast  = input_2_axis_tlast;
            current_input_2_axis_tid    = input_2_axis_tid;
            current_input_2_axis_tdest  = input_2_axis_tdest;
            current_input_2_axis_tuser  = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_2_axis_tdata  = input_3_axis_tdata;
            current_input_2_axis_tkeep  = input_3_axis_tkeep;
            current_input_2_axis_tvalid = input_3_axis_tvalid;
            current_input_2_axis_tready = input_3_axis_tready;
            current_input_2_axis_tlast  = input_3_axis_tlast;
            current_input_2_axis_tid    = input_3_axis_tid;
            current_input_2_axis_tdest  = input_3_axis_tdest;
            current_input_2_axis_tuser  = input_3_axis_tuser;
        end
        default: begin
            current_input_2_axis_tdata  = {DATA_WIDTH{1'b0}};
            current_input_2_axis_tkeep  = {KEEP_WIDTH{1'b0}};
            current_input_2_axis_tvalid = 1'b0;
            current_input_2_axis_tready = 1'b0;
            current_input_2_axis_tlast  = 1'b0;
            current_input_2_axis_tid    = {ID_WIDTH{1'b0}};
            current_input_2_axis_tdest  = {DEST_WIDTH{1'b0}};
            current_input_2_axis_tuser  = {USER_WIDTH{1'b0}};
        end
    endcase
end

reg [DATA_WIDTH-1:0] current_input_3_axis_tdata;
reg [DATA_WIDTH-1:0] current_input_3_axis_tkeep;
reg                  current_input_3_axis_tvalid;
reg                  current_input_3_axis_tready;
reg                  current_input_3_axis_tlast;
reg [ID_WIDTH-1:0]   current_input_3_axis_tid;
reg [DEST_WIDTH-1:0] current_input_3_axis_tdest;
reg [USER_WIDTH-1:0] current_input_3_axis_tuser;

always @* begin
    case (select_3_reg)
        2'd0: begin
            current_input_3_axis_tdata  = input_0_axis_tdata;
            current_input_3_axis_tkeep  = input_0_axis_tkeep;
            current_input_3_axis_tvalid = input_0_axis_tvalid;
            current_input_3_axis_tready = input_0_axis_tready;
            current_input_3_axis_tlast  = input_0_axis_tlast;
            current_input_3_axis_tid    = input_0_axis_tid;
            current_input_3_axis_tdest  = input_0_axis_tdest;
            current_input_3_axis_tuser  = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_3_axis_tdata  = input_1_axis_tdata;
            current_input_3_axis_tkeep  = input_1_axis_tkeep;
            current_input_3_axis_tvalid = input_1_axis_tvalid;
            current_input_3_axis_tready = input_1_axis_tready;
            current_input_3_axis_tlast  = input_1_axis_tlast;
            current_input_3_axis_tid    = input_1_axis_tid;
            current_input_3_axis_tdest  = input_1_axis_tdest;
            current_input_3_axis_tuser  = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_3_axis_tdata  = input_2_axis_tdata;
            current_input_3_axis_tkeep  = input_2_axis_tkeep;
            current_input_3_axis_tvalid = input_2_axis_tvalid;
            current_input_3_axis_tready = input_2_axis_tready;
            current_input_3_axis_tlast  = input_2_axis_tlast;
            current_input_3_axis_tid    = input_2_axis_tid;
            current_input_3_axis_tdest  = input_2_axis_tdest;
            current_input_3_axis_tuser  = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_3_axis_tdata  = input_3_axis_tdata;
            current_input_3_axis_tkeep  = input_3_axis_tkeep;
            current_input_3_axis_tvalid = input_3_axis_tvalid;
            current_input_3_axis_tready = input_3_axis_tready;
            current_input_3_axis_tlast  = input_3_axis_tlast;
            current_input_3_axis_tid    = input_3_axis_tid;
            current_input_3_axis_tdest  = input_3_axis_tdest;
            current_input_3_axis_tuser  = input_3_axis_tuser;
        end
        default: begin
            current_input_3_axis_tdata  = {DATA_WIDTH{1'b0}};
            current_input_3_axis_tkeep  = {KEEP_WIDTH{1'b0}};
            current_input_3_axis_tvalid = 1'b0;
            current_input_3_axis_tready = 1'b0;
            current_input_3_axis_tlast  = 1'b0;
            current_input_3_axis_tid    = {ID_WIDTH{1'b0}};
            current_input_3_axis_tdest  = {DEST_WIDTH{1'b0}};
            current_input_3_axis_tuser  = {USER_WIDTH{1'b0}};
        end
    endcase
end

// arbiter instances

wire [3:0] request_0;
wire [3:0] acknowledge_0;
wire [3:0] grant_0;
wire grant_valid_0;
wire [1:0] grant_encoded_0;

wire [3:0] request_1;
wire [3:0] acknowledge_1;
wire [3:0] grant_1;
wire grant_valid_1;
wire [1:0] grant_encoded_1;

wire [3:0] request_2;
wire [3:0] acknowledge_2;
wire [3:0] grant_2;
wire grant_valid_2;
wire [1:0] grant_encoded_2;

wire [3:0] request_3;
wire [3:0] acknowledge_3;
wire [3:0] grant_3;
wire grant_valid_3;
wire [1:0] grant_encoded_3;

arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_0_inst (
    .clk(clk),
    .rst(rst),
    .request(request_0),
    .acknowledge(acknowledge_0),
    .grant(grant_0),
    .grant_valid(grant_valid_0),
    .grant_encoded(grant_encoded_0)
);

arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_1_inst (
    .clk(clk),
    .rst(rst),
    .request(request_1),
    .acknowledge(acknowledge_1),
    .grant(grant_1),
    .grant_valid(grant_valid_1),
    .grant_encoded(grant_encoded_1)
);

arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_2_inst (
    .clk(clk),
    .rst(rst),
    .request(request_2),
    .acknowledge(acknowledge_2),
    .grant(grant_2),
    .grant_valid(grant_valid_2),
    .grant_encoded(grant_encoded_2)
);

arbiter #(
    .PORTS(4),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_3_inst (
    .clk(clk),
    .rst(rst),
    .request(request_3),
    .acknowledge(acknowledge_3),
    .grant(grant_3),
    .grant_valid(grant_valid_3),
    .grant_encoded(grant_encoded_3)
);

// request generation
assign request_0[0] = input_0_request_reg[0] & ~acknowledge_0[0];
assign request_0[1] = input_1_request_reg[0] & ~acknowledge_0[1];
assign request_0[2] = input_2_request_reg[0] & ~acknowledge_0[2];
assign request_0[3] = input_3_request_reg[0] & ~acknowledge_0[3];

assign request_1[0] = input_0_request_reg[1] & ~acknowledge_1[0];
assign request_1[1] = input_1_request_reg[1] & ~acknowledge_1[1];
assign request_1[2] = input_2_request_reg[1] & ~acknowledge_1[2];
assign request_1[3] = input_3_request_reg[1] & ~acknowledge_1[3];

assign request_2[0] = input_0_request_reg[2] & ~acknowledge_2[0];
assign request_2[1] = input_1_request_reg[2] & ~acknowledge_2[1];
assign request_2[2] = input_2_request_reg[2] & ~acknowledge_2[2];
assign request_2[3] = input_3_request_reg[2] & ~acknowledge_2[3];

assign request_3[0] = input_0_request_reg[3] & ~acknowledge_3[0];
assign request_3[1] = input_1_request_reg[3] & ~acknowledge_3[1];
assign request_3[2] = input_2_request_reg[3] & ~acknowledge_3[2];
assign request_3[3] = input_3_request_reg[3] & ~acknowledge_3[3];

// acknowledge generation
assign acknowledge_0[0] = grant_0[0] & input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast;
assign acknowledge_0[1] = grant_0[1] & input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast;
assign acknowledge_0[2] = grant_0[2] & input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast;
assign acknowledge_0[3] = grant_0[3] & input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast;

assign acknowledge_1[0] = grant_1[0] & input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast;
assign acknowledge_1[1] = grant_1[1] & input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast;
assign acknowledge_1[2] = grant_1[2] & input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast;
assign acknowledge_1[3] = grant_1[3] & input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast;

assign acknowledge_2[0] = grant_2[0] & input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast;
assign acknowledge_2[1] = grant_2[1] & input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast;
assign acknowledge_2[2] = grant_2[2] & input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast;
assign acknowledge_2[3] = grant_2[3] & input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast;

assign acknowledge_3[0] = grant_3[0] & input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast;
assign acknowledge_3[1] = grant_3[1] & input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast;
assign acknowledge_3[2] = grant_3[2] & input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast;
assign acknowledge_3[3] = grant_3[3] & input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast;

always @* begin
    select_0_next = select_0_reg;
    select_1_next = select_1_reg;
    select_2_next = select_2_reg;
    select_3_next = select_3_reg;

    enable_0_next = enable_0_reg;
    enable_1_next = enable_1_reg;
    enable_2_next = enable_2_reg;
    enable_3_next = enable_3_reg;

    input_0_request_next = input_0_request_reg;
    input_0_request_valid_next = input_0_request_valid_reg;
    input_0_request_error_next = input_0_request_error_reg;

    input_1_request_next = input_1_request_reg;
    input_1_request_valid_next = input_1_request_valid_reg;
    input_1_request_error_next = input_1_request_error_reg;

    input_2_request_next = input_2_request_reg;
    input_2_request_valid_next = input_2_request_valid_reg;
    input_2_request_error_next = input_2_request_error_reg;

    input_3_request_next = input_3_request_reg;
    input_3_request_valid_next = input_3_request_valid_reg;
    input_3_request_error_next = input_3_request_error_reg;

    input_0_axis_tready_next = 1'b0;
    input_1_axis_tready_next = 1'b0;
    input_2_axis_tready_next = 1'b0;
    input_3_axis_tready_next = 1'b0;

    output_0_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    output_0_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    output_0_axis_tvalid_int = 1'b0;
    output_0_axis_tlast_int  = 1'b0;
    output_0_axis_tid_int    = {ID_WIDTH{1'b0}};
    output_0_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    output_0_axis_tuser_int  = {USER_WIDTH{1'b0}};

    output_1_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    output_1_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    output_1_axis_tvalid_int = 1'b0;
    output_1_axis_tlast_int  = 1'b0;
    output_1_axis_tid_int    = {ID_WIDTH{1'b0}};
    output_1_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    output_1_axis_tuser_int  = {USER_WIDTH{1'b0}};

    output_2_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    output_2_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    output_2_axis_tvalid_int = 1'b0;
    output_2_axis_tlast_int  = 1'b0;
    output_2_axis_tid_int    = {ID_WIDTH{1'b0}};
    output_2_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    output_2_axis_tuser_int  = {USER_WIDTH{1'b0}};

    output_3_axis_tdata_int  = {DATA_WIDTH{1'b0}};
    output_3_axis_tkeep_int  = {KEEP_WIDTH{1'b0}};
    output_3_axis_tvalid_int = 1'b0;
    output_3_axis_tlast_int  = 1'b0;
    output_3_axis_tid_int    = {ID_WIDTH{1'b0}};
    output_3_axis_tdest_int  = {DEST_WIDTH{1'b0}};
    output_3_axis_tuser_int  = {USER_WIDTH{1'b0}};

    // input decoding

    if (input_0_request_valid_reg | input_0_request_error_reg) begin
        if (input_0_axis_tvalid & input_0_axis_tready & input_0_axis_tlast) begin
            input_0_request_next = {DEST_WIDTH{1'b0}};
            input_0_request_valid_next = 1'b0;
            input_0_request_error_next = 1'b0;
        end
    end else if (input_0_axis_tvalid) begin
        input_0_request_next[0] = (input_0_axis_tdest >= OUT_0_BASE) & (input_0_axis_tdest <= OUT_0_TOP) & OUT_0_CONNECT[0];
        input_0_request_next[1] = (input_0_axis_tdest >= OUT_1_BASE) & (input_0_axis_tdest <= OUT_1_TOP) & OUT_1_CONNECT[0];
        input_0_request_next[2] = (input_0_axis_tdest >= OUT_2_BASE) & (input_0_axis_tdest <= OUT_2_TOP) & OUT_2_CONNECT[0];
        input_0_request_next[3] = (input_0_axis_tdest >= OUT_3_BASE) & (input_0_axis_tdest <= OUT_3_TOP) & OUT_3_CONNECT[0];

        if (input_0_request_next) begin
            input_0_request_valid_next = 1'b1;
        end else begin
            input_0_request_error_next = 1'b1;
        end
    end

    if (input_1_request_valid_reg | input_1_request_error_reg) begin
        if (input_1_axis_tvalid & input_1_axis_tready & input_1_axis_tlast) begin
            input_1_request_next = {DEST_WIDTH{1'b0}};
            input_1_request_valid_next = 1'b0;
            input_1_request_error_next = 1'b0;
        end
    end else if (input_1_axis_tvalid) begin
        input_1_request_next[0] = (input_1_axis_tdest >= OUT_0_BASE) & (input_1_axis_tdest <= OUT_0_TOP) & OUT_0_CONNECT[1];
        input_1_request_next[1] = (input_1_axis_tdest >= OUT_1_BASE) & (input_1_axis_tdest <= OUT_1_TOP) & OUT_1_CONNECT[1];
        input_1_request_next[2] = (input_1_axis_tdest >= OUT_2_BASE) & (input_1_axis_tdest <= OUT_2_TOP) & OUT_2_CONNECT[1];
        input_1_request_next[3] = (input_1_axis_tdest >= OUT_3_BASE) & (input_1_axis_tdest <= OUT_3_TOP) & OUT_3_CONNECT[1];

        if (input_1_request_next) begin
            input_1_request_valid_next = 1'b1;
        end else begin
            input_1_request_error_next = 1'b1;
        end
    end

    if (input_2_request_valid_reg | input_2_request_error_reg) begin
        if (input_2_axis_tvalid & input_2_axis_tready & input_2_axis_tlast) begin
            input_2_request_next = {DEST_WIDTH{1'b0}};
            input_2_request_valid_next = 1'b0;
            input_2_request_error_next = 1'b0;
        end
    end else if (input_2_axis_tvalid) begin
        input_2_request_next[0] = (input_2_axis_tdest >= OUT_0_BASE) & (input_2_axis_tdest <= OUT_0_TOP) & OUT_0_CONNECT[2];
        input_2_request_next[1] = (input_2_axis_tdest >= OUT_1_BASE) & (input_2_axis_tdest <= OUT_1_TOP) & OUT_1_CONNECT[2];
        input_2_request_next[2] = (input_2_axis_tdest >= OUT_2_BASE) & (input_2_axis_tdest <= OUT_2_TOP) & OUT_2_CONNECT[2];
        input_2_request_next[3] = (input_2_axis_tdest >= OUT_3_BASE) & (input_2_axis_tdest <= OUT_3_TOP) & OUT_3_CONNECT[2];

        if (input_2_request_next) begin
            input_2_request_valid_next = 1'b1;
        end else begin
            input_2_request_error_next = 1'b1;
        end
    end

    if (input_3_request_valid_reg | input_3_request_error_reg) begin
        if (input_3_axis_tvalid & input_3_axis_tready & input_3_axis_tlast) begin
            input_3_request_next = {DEST_WIDTH{1'b0}};
            input_3_request_valid_next = 1'b0;
            input_3_request_error_next = 1'b0;
        end
    end else if (input_3_axis_tvalid) begin
        input_3_request_next[0] = (input_3_axis_tdest >= OUT_0_BASE) & (input_3_axis_tdest <= OUT_0_TOP) & OUT_0_CONNECT[3];
        input_3_request_next[1] = (input_3_axis_tdest >= OUT_1_BASE) & (input_3_axis_tdest <= OUT_1_TOP) & OUT_1_CONNECT[3];
        input_3_request_next[2] = (input_3_axis_tdest >= OUT_2_BASE) & (input_3_axis_tdest <= OUT_2_TOP) & OUT_2_CONNECT[3];
        input_3_request_next[3] = (input_3_axis_tdest >= OUT_3_BASE) & (input_3_axis_tdest <= OUT_3_TOP) & OUT_3_CONNECT[3];

        if (input_3_request_next) begin
            input_3_request_valid_next = 1'b1;
        end else begin
            input_3_request_error_next = 1'b1;
        end
    end

    // output control

    if (current_input_0_axis_tvalid & current_input_0_axis_tready) begin
        if (current_input_0_axis_tlast) begin
            enable_0_next = 1'b0;
        end
    end
    if (~enable_0_reg & grant_valid_0) begin
        enable_0_next = 1'b1;
        select_0_next = grant_encoded_0;
    end

    if (current_input_1_axis_tvalid & current_input_1_axis_tready) begin
        if (current_input_1_axis_tlast) begin
            enable_1_next = 1'b0;
        end
    end
    if (~enable_1_reg & grant_valid_1) begin
        enable_1_next = 1'b1;
        select_1_next = grant_encoded_1;
    end

    if (current_input_2_axis_tvalid & current_input_2_axis_tready) begin
        if (current_input_2_axis_tlast) begin
            enable_2_next = 1'b0;
        end
    end
    if (~enable_2_reg & grant_valid_2) begin
        enable_2_next = 1'b1;
        select_2_next = grant_encoded_2;
    end

    if (current_input_3_axis_tvalid & current_input_3_axis_tready) begin
        if (current_input_3_axis_tlast) begin
            enable_3_next = 1'b0;
        end
    end
    if (~enable_3_reg & grant_valid_3) begin
        enable_3_next = 1'b1;
        select_3_next = grant_encoded_3;
    end

    // generate ready signal on selected port

    if (enable_0_next) begin
        case (select_0_next)
            2'd0: input_0_axis_tready_next = output_0_axis_tready_int_early;
            2'd1: input_1_axis_tready_next = output_0_axis_tready_int_early;
            2'd2: input_2_axis_tready_next = output_0_axis_tready_int_early;
            2'd3: input_3_axis_tready_next = output_0_axis_tready_int_early;
        endcase
    end

    if (enable_1_next) begin
        case (select_1_next)
            2'd0: input_0_axis_tready_next = output_1_axis_tready_int_early;
            2'd1: input_1_axis_tready_next = output_1_axis_tready_int_early;
            2'd2: input_2_axis_tready_next = output_1_axis_tready_int_early;
            2'd3: input_3_axis_tready_next = output_1_axis_tready_int_early;
        endcase
    end

    if (enable_2_next) begin
        case (select_2_next)
            2'd0: input_0_axis_tready_next = output_2_axis_tready_int_early;
            2'd1: input_1_axis_tready_next = output_2_axis_tready_int_early;
            2'd2: input_2_axis_tready_next = output_2_axis_tready_int_early;
            2'd3: input_3_axis_tready_next = output_2_axis_tready_int_early;
        endcase
    end

    if (enable_3_next) begin
        case (select_3_next)
            2'd0: input_0_axis_tready_next = output_3_axis_tready_int_early;
            2'd1: input_1_axis_tready_next = output_3_axis_tready_int_early;
            2'd2: input_2_axis_tready_next = output_3_axis_tready_int_early;
            2'd3: input_3_axis_tready_next = output_3_axis_tready_int_early;
        endcase
    end

    if (input_0_request_error_next)
        input_0_axis_tready_next = 1'b1;
    if (input_1_request_error_next)
        input_1_axis_tready_next = 1'b1;
    if (input_2_request_error_next)
        input_2_axis_tready_next = 1'b1;
    if (input_3_request_error_next)
        input_3_axis_tready_next = 1'b1;

    // pass through selected packet data

    output_0_axis_tdata_int  = current_input_0_axis_tdata;
    output_0_axis_tkeep_int  = current_input_0_axis_tkeep;
    output_0_axis_tvalid_int = current_input_0_axis_tvalid & current_input_0_axis_tready & enable_0_reg;
    output_0_axis_tlast_int  = current_input_0_axis_tlast;
    output_0_axis_tid_int    = current_input_0_axis_tid;
    output_0_axis_tdest_int  = current_input_0_axis_tdest;
    output_0_axis_tuser_int  = current_input_0_axis_tuser;

    output_1_axis_tdata_int  = current_input_1_axis_tdata;
    output_1_axis_tkeep_int  = current_input_1_axis_tkeep;
    output_1_axis_tvalid_int = current_input_1_axis_tvalid & current_input_1_axis_tready & enable_1_reg;
    output_1_axis_tlast_int  = current_input_1_axis_tlast;
    output_1_axis_tid_int    = current_input_1_axis_tid;
    output_1_axis_tdest_int  = current_input_1_axis_tdest;
    output_1_axis_tuser_int  = current_input_1_axis_tuser;

    output_2_axis_tdata_int  = current_input_2_axis_tdata;
    output_2_axis_tkeep_int  = current_input_2_axis_tkeep;
    output_2_axis_tvalid_int = current_input_2_axis_tvalid & current_input_2_axis_tready & enable_2_reg;
    output_2_axis_tlast_int  = current_input_2_axis_tlast;
    output_2_axis_tid_int    = current_input_2_axis_tid;
    output_2_axis_tdest_int  = current_input_2_axis_tdest;
    output_2_axis_tuser_int  = current_input_2_axis_tuser;

    output_3_axis_tdata_int  = current_input_3_axis_tdata;
    output_3_axis_tkeep_int  = current_input_3_axis_tkeep;
    output_3_axis_tvalid_int = current_input_3_axis_tvalid & current_input_3_axis_tready & enable_3_reg;
    output_3_axis_tlast_int  = current_input_3_axis_tlast;
    output_3_axis_tid_int    = current_input_3_axis_tid;
    output_3_axis_tdest_int  = current_input_3_axis_tdest;
    output_3_axis_tuser_int  = current_input_3_axis_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        input_0_request_reg <= 4'd0;
        input_0_request_valid_reg <= 1'b0;
        input_0_request_error_reg <= 1'b0;
        input_1_request_reg <= 4'd0;
        input_1_request_valid_reg <= 1'b0;
        input_1_request_error_reg <= 1'b0;
        input_2_request_reg <= 4'd0;
        input_2_request_valid_reg <= 1'b0;
        input_2_request_error_reg <= 1'b0;
        input_3_request_reg <= 4'd0;
        input_3_request_valid_reg <= 1'b0;
        input_3_request_error_reg <= 1'b0;
        select_0_reg <= 2'd0;
        select_1_reg <= 2'd0;
        select_2_reg <= 2'd0;
        select_3_reg <= 2'd0;
        enable_0_reg <= 1'b0;
        enable_1_reg <= 1'b0;
        enable_2_reg <= 1'b0;
        enable_3_reg <= 1'b0;
        input_0_axis_tready_reg <= 1'b0;
        input_1_axis_tready_reg <= 1'b0;
        input_2_axis_tready_reg <= 1'b0;
        input_3_axis_tready_reg <= 1'b0;
    end else begin
        input_0_request_reg <= input_0_request_next;
        input_0_request_valid_reg <= input_0_request_valid_next;
        input_0_request_error_reg <= input_0_request_error_next;
        input_1_request_reg <= input_1_request_next;
        input_1_request_valid_reg <= input_1_request_valid_next;
        input_1_request_error_reg <= input_1_request_error_next;
        input_2_request_reg <= input_2_request_next;
        input_2_request_valid_reg <= input_2_request_valid_next;
        input_2_request_error_reg <= input_2_request_error_next;
        input_3_request_reg <= input_3_request_next;
        input_3_request_valid_reg <= input_3_request_valid_next;
        input_3_request_error_reg <= input_3_request_error_next;
        select_0_reg <= select_0_next;
        select_1_reg <= select_1_next;
        select_2_reg <= select_2_next;
        select_3_reg <= select_3_next;
        enable_0_reg <= enable_0_next;
        enable_1_reg <= enable_1_next;
        enable_2_reg <= enable_2_next;
        enable_3_reg <= enable_3_next;
        input_0_axis_tready_reg <= input_0_axis_tready_next;
        input_1_axis_tready_reg <= input_1_axis_tready_next;
        input_2_axis_tready_reg <= input_2_axis_tready_next;
        input_3_axis_tready_reg <= input_3_axis_tready_next;
    end
end

// output 0 datapath logic
reg [DATA_WIDTH-1:0] output_0_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_0_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  output_0_axis_tvalid_reg = 1'b0, output_0_axis_tvalid_next;
reg                  output_0_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   output_0_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] output_0_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] output_0_axis_tuser_reg  = 1'b0;

reg [DATA_WIDTH-1:0] temp_0_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_0_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_0_axis_tvalid_reg = 1'b0, temp_0_axis_tvalid_next;
reg                  temp_0_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_0_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_0_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_0_axis_tuser_reg  = 1'b0;

// datapath control
reg store_0_axis_int_to_output;
reg store_0_axis_int_to_temp;
reg store_0_axis_temp_to_output;

assign output_0_axis_tdata  = output_0_axis_tdata_reg;
assign output_0_axis_tkeep  = KEEP_ENABLE ? output_0_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_0_axis_tvalid = output_0_axis_tvalid_reg;
assign output_0_axis_tlast  = output_0_axis_tlast_reg;
assign output_0_axis_tid    = ID_ENABLE   ? output_0_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_0_axis_tdest  = output_0_axis_tdest_reg;
assign output_0_axis_tuser  = USER_ENABLE ? output_0_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_0_axis_tready_int_early = output_0_axis_tready | (~temp_0_axis_tvalid_reg & (~output_0_axis_tvalid_reg | ~output_0_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_0_axis_tvalid_next = output_0_axis_tvalid_reg;
    temp_0_axis_tvalid_next = temp_0_axis_tvalid_reg;

    store_0_axis_int_to_output = 1'b0;
    store_0_axis_int_to_temp = 1'b0;
    store_0_axis_temp_to_output = 1'b0;

    if (output_0_axis_tready_int_reg) begin
        // input is ready
        if (output_0_axis_tready | ~output_0_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_0_axis_tvalid_next = output_0_axis_tvalid_int;
            store_0_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_0_axis_tvalid_next = output_0_axis_tvalid_int;
            store_0_axis_int_to_temp = 1'b1;
        end
    end else if (output_0_axis_tready) begin
        // input is not ready, but output is ready
        output_0_axis_tvalid_next = temp_0_axis_tvalid_reg;
        temp_0_axis_tvalid_next = 1'b0;
        store_0_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_0_axis_tvalid_reg <= 1'b0;
        output_0_axis_tready_int_reg <= 1'b0;
        temp_0_axis_tvalid_reg <= 1'b0;
    end else begin
        output_0_axis_tvalid_reg <= output_0_axis_tvalid_next;
        output_0_axis_tready_int_reg <= output_0_axis_tready_int_early;
        temp_0_axis_tvalid_reg <= temp_0_axis_tvalid_next;
    end

    // datapath
    if (store_0_axis_int_to_output) begin
        output_0_axis_tdata_reg <= output_0_axis_tdata_int;
        output_0_axis_tkeep_reg <= output_0_axis_tkeep_int;
        output_0_axis_tlast_reg <= output_0_axis_tlast_int;
        output_0_axis_tid_reg   <= output_0_axis_tid_int;
        output_0_axis_tdest_reg <= output_0_axis_tdest_int;
        output_0_axis_tuser_reg <= output_0_axis_tuser_int;
    end else if (store_0_axis_temp_to_output) begin
        output_0_axis_tdata_reg <= temp_0_axis_tdata_reg;
        output_0_axis_tkeep_reg <= temp_0_axis_tkeep_reg;
        output_0_axis_tlast_reg <= temp_0_axis_tlast_reg;
        output_0_axis_tid_reg   <= temp_0_axis_tid_reg;
        output_0_axis_tdest_reg <= temp_0_axis_tdest_reg;
        output_0_axis_tuser_reg <= temp_0_axis_tuser_reg;
    end

    if (store_0_axis_int_to_temp) begin
        temp_0_axis_tdata_reg <= output_0_axis_tdata_int;
        temp_0_axis_tkeep_reg <= output_0_axis_tkeep_int;
        temp_0_axis_tlast_reg <= output_0_axis_tlast_int;
        temp_0_axis_tid_reg   <= output_0_axis_tid_int;
        temp_0_axis_tdest_reg <= output_0_axis_tdest_int;
        temp_0_axis_tuser_reg <= output_0_axis_tuser_int;
    end
end

// output 1 datapath logic
reg [DATA_WIDTH-1:0] output_1_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_1_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  output_1_axis_tvalid_reg = 1'b0, output_1_axis_tvalid_next;
reg                  output_1_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   output_1_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] output_1_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] output_1_axis_tuser_reg  = 1'b0;

reg [DATA_WIDTH-1:0] temp_1_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_1_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_1_axis_tvalid_reg = 1'b0, temp_1_axis_tvalid_next;
reg                  temp_1_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_1_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_1_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_1_axis_tuser_reg  = 1'b0;

// datapath control
reg store_1_axis_int_to_output;
reg store_1_axis_int_to_temp;
reg store_1_axis_temp_to_output;

assign output_1_axis_tdata  = output_1_axis_tdata_reg;
assign output_1_axis_tkeep  = KEEP_ENABLE ? output_1_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_1_axis_tvalid = output_1_axis_tvalid_reg;
assign output_1_axis_tlast  = output_1_axis_tlast_reg;
assign output_1_axis_tid    = ID_ENABLE   ? output_1_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_1_axis_tdest  = output_1_axis_tdest_reg;
assign output_1_axis_tuser  = USER_ENABLE ? output_1_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_1_axis_tready_int_early = output_1_axis_tready | (~temp_1_axis_tvalid_reg & (~output_1_axis_tvalid_reg | ~output_1_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_1_axis_tvalid_next = output_1_axis_tvalid_reg;
    temp_1_axis_tvalid_next = temp_1_axis_tvalid_reg;

    store_1_axis_int_to_output = 1'b0;
    store_1_axis_int_to_temp = 1'b0;
    store_1_axis_temp_to_output = 1'b0;

    if (output_1_axis_tready_int_reg) begin
        // input is ready
        if (output_1_axis_tready | ~output_1_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_1_axis_tvalid_next = output_1_axis_tvalid_int;
            store_1_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_1_axis_tvalid_next = output_1_axis_tvalid_int;
            store_1_axis_int_to_temp = 1'b1;
        end
    end else if (output_1_axis_tready) begin
        // input is not ready, but output is ready
        output_1_axis_tvalid_next = temp_1_axis_tvalid_reg;
        temp_1_axis_tvalid_next = 1'b0;
        store_1_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_1_axis_tvalid_reg <= 1'b0;
        output_1_axis_tready_int_reg <= 1'b0;
        temp_1_axis_tvalid_reg <= 1'b0;
    end else begin
        output_1_axis_tvalid_reg <= output_1_axis_tvalid_next;
        output_1_axis_tready_int_reg <= output_1_axis_tready_int_early;
        temp_1_axis_tvalid_reg <= temp_1_axis_tvalid_next;
    end

    // datapath
    if (store_1_axis_int_to_output) begin
        output_1_axis_tdata_reg <= output_1_axis_tdata_int;
        output_1_axis_tkeep_reg <= output_1_axis_tkeep_int;
        output_1_axis_tlast_reg <= output_1_axis_tlast_int;
        output_1_axis_tid_reg   <= output_1_axis_tid_int;
        output_1_axis_tdest_reg <= output_1_axis_tdest_int;
        output_1_axis_tuser_reg <= output_1_axis_tuser_int;
    end else if (store_1_axis_temp_to_output) begin
        output_1_axis_tdata_reg <= temp_1_axis_tdata_reg;
        output_1_axis_tkeep_reg <= temp_1_axis_tkeep_reg;
        output_1_axis_tlast_reg <= temp_1_axis_tlast_reg;
        output_1_axis_tid_reg   <= temp_1_axis_tid_reg;
        output_1_axis_tdest_reg <= temp_1_axis_tdest_reg;
        output_1_axis_tuser_reg <= temp_1_axis_tuser_reg;
    end

    if (store_1_axis_int_to_temp) begin
        temp_1_axis_tdata_reg <= output_1_axis_tdata_int;
        temp_1_axis_tkeep_reg <= output_1_axis_tkeep_int;
        temp_1_axis_tlast_reg <= output_1_axis_tlast_int;
        temp_1_axis_tid_reg   <= output_1_axis_tid_int;
        temp_1_axis_tdest_reg <= output_1_axis_tdest_int;
        temp_1_axis_tuser_reg <= output_1_axis_tuser_int;
    end
end

// output 2 datapath logic
reg [DATA_WIDTH-1:0] output_2_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_2_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  output_2_axis_tvalid_reg = 1'b0, output_2_axis_tvalid_next;
reg                  output_2_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   output_2_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] output_2_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] output_2_axis_tuser_reg  = 1'b0;

reg [DATA_WIDTH-1:0] temp_2_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_2_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_2_axis_tvalid_reg = 1'b0, temp_2_axis_tvalid_next;
reg                  temp_2_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_2_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_2_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_2_axis_tuser_reg  = 1'b0;

// datapath control
reg store_2_axis_int_to_output;
reg store_2_axis_int_to_temp;
reg store_2_axis_temp_to_output;

assign output_2_axis_tdata  = output_2_axis_tdata_reg;
assign output_2_axis_tkeep  = KEEP_ENABLE ? output_2_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_2_axis_tvalid = output_2_axis_tvalid_reg;
assign output_2_axis_tlast  = output_2_axis_tlast_reg;
assign output_2_axis_tid    = ID_ENABLE   ? output_2_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_2_axis_tdest  = output_2_axis_tdest_reg;
assign output_2_axis_tuser  = USER_ENABLE ? output_2_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_2_axis_tready_int_early = output_2_axis_tready | (~temp_2_axis_tvalid_reg & (~output_2_axis_tvalid_reg | ~output_2_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_2_axis_tvalid_next = output_2_axis_tvalid_reg;
    temp_2_axis_tvalid_next = temp_2_axis_tvalid_reg;

    store_2_axis_int_to_output = 1'b0;
    store_2_axis_int_to_temp = 1'b0;
    store_2_axis_temp_to_output = 1'b0;

    if (output_2_axis_tready_int_reg) begin
        // input is ready
        if (output_2_axis_tready | ~output_2_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_2_axis_tvalid_next = output_2_axis_tvalid_int;
            store_2_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_2_axis_tvalid_next = output_2_axis_tvalid_int;
            store_2_axis_int_to_temp = 1'b1;
        end
    end else if (output_2_axis_tready) begin
        // input is not ready, but output is ready
        output_2_axis_tvalid_next = temp_2_axis_tvalid_reg;
        temp_2_axis_tvalid_next = 1'b0;
        store_2_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_2_axis_tvalid_reg <= 1'b0;
        output_2_axis_tready_int_reg <= 1'b0;
        temp_2_axis_tvalid_reg <= 1'b0;
    end else begin
        output_2_axis_tvalid_reg <= output_2_axis_tvalid_next;
        output_2_axis_tready_int_reg <= output_2_axis_tready_int_early;
        temp_2_axis_tvalid_reg <= temp_2_axis_tvalid_next;
    end

    // datapath
    if (store_2_axis_int_to_output) begin
        output_2_axis_tdata_reg <= output_2_axis_tdata_int;
        output_2_axis_tkeep_reg <= output_2_axis_tkeep_int;
        output_2_axis_tlast_reg <= output_2_axis_tlast_int;
        output_2_axis_tid_reg   <= output_2_axis_tid_int;
        output_2_axis_tdest_reg <= output_2_axis_tdest_int;
        output_2_axis_tuser_reg <= output_2_axis_tuser_int;
    end else if (store_2_axis_temp_to_output) begin
        output_2_axis_tdata_reg <= temp_2_axis_tdata_reg;
        output_2_axis_tkeep_reg <= temp_2_axis_tkeep_reg;
        output_2_axis_tlast_reg <= temp_2_axis_tlast_reg;
        output_2_axis_tid_reg   <= temp_2_axis_tid_reg;
        output_2_axis_tdest_reg <= temp_2_axis_tdest_reg;
        output_2_axis_tuser_reg <= temp_2_axis_tuser_reg;
    end

    if (store_2_axis_int_to_temp) begin
        temp_2_axis_tdata_reg <= output_2_axis_tdata_int;
        temp_2_axis_tkeep_reg <= output_2_axis_tkeep_int;
        temp_2_axis_tlast_reg <= output_2_axis_tlast_int;
        temp_2_axis_tid_reg   <= output_2_axis_tid_int;
        temp_2_axis_tdest_reg <= output_2_axis_tdest_int;
        temp_2_axis_tuser_reg <= output_2_axis_tuser_int;
    end
end

// output 3 datapath logic
reg [DATA_WIDTH-1:0] output_3_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] output_3_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  output_3_axis_tvalid_reg = 1'b0, output_3_axis_tvalid_next;
reg                  output_3_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   output_3_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] output_3_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] output_3_axis_tuser_reg  = 1'b0;

reg [DATA_WIDTH-1:0] temp_3_axis_tdata_reg  = {DATA_WIDTH{1'b0}};
reg [KEEP_WIDTH-1:0] temp_3_axis_tkeep_reg  = {KEEP_WIDTH{1'b0}};
reg                  temp_3_axis_tvalid_reg = 1'b0, temp_3_axis_tvalid_next;
reg                  temp_3_axis_tlast_reg  = 1'b0;
reg [ID_WIDTH-1:0]   temp_3_axis_tid_reg    = {ID_WIDTH{1'b0}};
reg [DEST_WIDTH-1:0] temp_3_axis_tdest_reg  = {DEST_WIDTH{1'b0}};
reg [USER_WIDTH-1:0] temp_3_axis_tuser_reg  = 1'b0;

// datapath control
reg store_3_axis_int_to_output;
reg store_3_axis_int_to_temp;
reg store_3_axis_temp_to_output;

assign output_3_axis_tdata  = output_3_axis_tdata_reg;
assign output_3_axis_tkeep  = KEEP_ENABLE ? output_3_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_3_axis_tvalid = output_3_axis_tvalid_reg;
assign output_3_axis_tlast  = output_3_axis_tlast_reg;
assign output_3_axis_tid    = ID_ENABLE   ? output_3_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_3_axis_tdest  = output_3_axis_tdest_reg;
assign output_3_axis_tuser  = USER_ENABLE ? output_3_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_3_axis_tready_int_early = output_3_axis_tready | (~temp_3_axis_tvalid_reg & (~output_3_axis_tvalid_reg | ~output_3_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_3_axis_tvalid_next = output_3_axis_tvalid_reg;
    temp_3_axis_tvalid_next = temp_3_axis_tvalid_reg;

    store_3_axis_int_to_output = 1'b0;
    store_3_axis_int_to_temp = 1'b0;
    store_3_axis_temp_to_output = 1'b0;

    if (output_3_axis_tready_int_reg) begin
        // input is ready
        if (output_3_axis_tready | ~output_3_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_3_axis_tvalid_next = output_3_axis_tvalid_int;
            store_3_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_3_axis_tvalid_next = output_3_axis_tvalid_int;
            store_3_axis_int_to_temp = 1'b1;
        end
    end else if (output_3_axis_tready) begin
        // input is not ready, but output is ready
        output_3_axis_tvalid_next = temp_3_axis_tvalid_reg;
        temp_3_axis_tvalid_next = 1'b0;
        store_3_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_3_axis_tvalid_reg <= 1'b0;
        output_3_axis_tready_int_reg <= 1'b0;
        temp_3_axis_tvalid_reg <= 1'b0;
    end else begin
        output_3_axis_tvalid_reg <= output_3_axis_tvalid_next;
        output_3_axis_tready_int_reg <= output_3_axis_tready_int_early;
        temp_3_axis_tvalid_reg <= temp_3_axis_tvalid_next;
    end

    // datapath
    if (store_3_axis_int_to_output) begin
        output_3_axis_tdata_reg <= output_3_axis_tdata_int;
        output_3_axis_tkeep_reg <= output_3_axis_tkeep_int;
        output_3_axis_tlast_reg <= output_3_axis_tlast_int;
        output_3_axis_tid_reg   <= output_3_axis_tid_int;
        output_3_axis_tdest_reg <= output_3_axis_tdest_int;
        output_3_axis_tuser_reg <= output_3_axis_tuser_int;
    end else if (store_3_axis_temp_to_output) begin
        output_3_axis_tdata_reg <= temp_3_axis_tdata_reg;
        output_3_axis_tkeep_reg <= temp_3_axis_tkeep_reg;
        output_3_axis_tlast_reg <= temp_3_axis_tlast_reg;
        output_3_axis_tid_reg   <= temp_3_axis_tid_reg;
        output_3_axis_tdest_reg <= temp_3_axis_tdest_reg;
        output_3_axis_tuser_reg <= temp_3_axis_tuser_reg;
    end

    if (store_3_axis_int_to_temp) begin
        temp_3_axis_tdata_reg <= output_3_axis_tdata_int;
        temp_3_axis_tkeep_reg <= output_3_axis_tkeep_int;
        temp_3_axis_tlast_reg <= output_3_axis_tlast_int;
        temp_3_axis_tid_reg   <= output_3_axis_tid_int;
        temp_3_axis_tdest_reg <= output_3_axis_tdest_int;
        temp_3_axis_tuser_reg <= output_3_axis_tuser_int;
    end
end

endmodule
