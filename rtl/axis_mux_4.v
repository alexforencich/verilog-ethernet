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
 * AXI4-Stream 4 port multiplexer
 */
module axis_mux_4 #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
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
    output wire [USER_WIDTH-1:0]  output_axis_tuser,

    /*
     * Control
     */
    input  wire                   enable,
    input  wire [1:0]             select
);

reg [1:0] select_reg = 2'd0, select_next;
reg frame_reg = 1'b0, frame_next;

reg input_0_axis_tready_reg = 1'b0, input_0_axis_tready_next;
reg input_1_axis_tready_reg = 1'b0, input_1_axis_tready_next;
reg input_2_axis_tready_reg = 1'b0, input_2_axis_tready_next;
reg input_3_axis_tready_reg = 1'b0, input_3_axis_tready_next;

// internal datapath
reg  [DATA_WIDTH-1:0] output_axis_tdata_int;
reg  [KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                   output_axis_tvalid_int;
reg                   output_axis_tready_int_reg = 1'b0;
reg                   output_axis_tlast_int;
reg  [ID_WIDTH-1:0]   output_axis_tid_int;
reg  [DEST_WIDTH-1:0] output_axis_tdest_int;
reg  [USER_WIDTH-1:0] output_axis_tuser_int;
wire                  output_axis_tready_int_early;

assign input_0_axis_tready = input_0_axis_tready_reg;
assign input_1_axis_tready = input_1_axis_tready_reg;
assign input_2_axis_tready = input_2_axis_tready_reg;
assign input_3_axis_tready = input_3_axis_tready_reg;

// mux for start of packet detection
reg selected_input_tvalid;
always @* begin
    case (select)
        2'd0: selected_input_tvalid = input_0_axis_tvalid;
        2'd1: selected_input_tvalid = input_1_axis_tvalid;
        2'd2: selected_input_tvalid = input_2_axis_tvalid;
        2'd3: selected_input_tvalid = input_3_axis_tvalid;
        default: selected_input_tvalid = 1'b0;
    endcase
end

// mux for incoming packet
reg [DATA_WIDTH-1:0] current_input_tdata;
reg [KEEP_WIDTH-1:0] current_input_tkeep;
reg                  current_input_tvalid;
reg                  current_input_tready;
reg                  current_input_tlast;
reg [ID_WIDTH-1:0]   current_input_tid;
reg [DEST_WIDTH-1:0] current_input_tdest;
reg [USER_WIDTH-1:0] current_input_tuser;
always @* begin
    case (select_reg)
        2'd0: begin
            current_input_tdata  = input_0_axis_tdata;
            current_input_tkeep  = input_0_axis_tkeep;
            current_input_tvalid = input_0_axis_tvalid;
            current_input_tready = input_0_axis_tready;
            current_input_tlast  = input_0_axis_tlast;
            current_input_tid    = input_0_axis_tid;
            current_input_tdest  = input_0_axis_tdest;
            current_input_tuser  = input_0_axis_tuser;
        end
        2'd1: begin
            current_input_tdata  = input_1_axis_tdata;
            current_input_tkeep  = input_1_axis_tkeep;
            current_input_tvalid = input_1_axis_tvalid;
            current_input_tready = input_1_axis_tready;
            current_input_tlast  = input_1_axis_tlast;
            current_input_tid    = input_1_axis_tid;
            current_input_tdest  = input_1_axis_tdest;
            current_input_tuser  = input_1_axis_tuser;
        end
        2'd2: begin
            current_input_tdata  = input_2_axis_tdata;
            current_input_tkeep  = input_2_axis_tkeep;
            current_input_tvalid = input_2_axis_tvalid;
            current_input_tready = input_2_axis_tready;
            current_input_tlast  = input_2_axis_tlast;
            current_input_tid    = input_2_axis_tid;
            current_input_tdest  = input_2_axis_tdest;
            current_input_tuser  = input_2_axis_tuser;
        end
        2'd3: begin
            current_input_tdata  = input_3_axis_tdata;
            current_input_tkeep  = input_3_axis_tkeep;
            current_input_tvalid = input_3_axis_tvalid;
            current_input_tready = input_3_axis_tready;
            current_input_tlast  = input_3_axis_tlast;
            current_input_tid    = input_3_axis_tid;
            current_input_tdest  = input_3_axis_tdest;
            current_input_tuser  = input_3_axis_tuser;
        end
        default: begin
            current_input_tdata  = {DATA_WIDTH{1'b0}};
            current_input_tkeep  = {KEEP_WIDTH{1'b0}};
            current_input_tvalid = 1'b0;
            current_input_tready = 1'b0;
            current_input_tlast  = 1'b0;
            current_input_tid    = {ID_WIDTH{1'b0}};
            current_input_tdest  = {DEST_WIDTH{1'b0}};
            current_input_tuser  = {USER_WIDTH{1'b0}};
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_0_axis_tready_next = 1'b0;
    input_1_axis_tready_next = 1'b0;
    input_2_axis_tready_next = 1'b0;
    input_3_axis_tready_next = 1'b0;

    if (current_input_tvalid & current_input_tready) begin
        // end of frame detection
        if (current_input_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (~frame_reg & enable & selected_input_tvalid) begin
        // start of frame, grab select value
        frame_next = 1'b1;
        select_next = select;
    end

    // generate ready signal on selected port
    case (select_next)
        2'd0: input_0_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd1: input_1_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd2: input_2_axis_tready_next = output_axis_tready_int_early & frame_next;
        2'd3: input_3_axis_tready_next = output_axis_tready_int_early & frame_next;
    endcase

    // pass through selected packet data
    output_axis_tdata_int  = current_input_tdata;
    output_axis_tkeep_int  = current_input_tkeep;
    output_axis_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_axis_tlast_int  = current_input_tlast;
    output_axis_tid_int    = current_input_tid;
    output_axis_tdest_int  = current_input_tdest;
    output_axis_tuser_int  = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 2'd0;
        frame_reg <= 1'b0;
        input_0_axis_tready_reg <= 1'b0;
        input_1_axis_tready_reg <= 1'b0;
        input_2_axis_tready_reg <= 1'b0;
        input_3_axis_tready_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_0_axis_tready_reg <= input_0_axis_tready_next;
        input_1_axis_tready_reg <= input_1_axis_tready_next;
        input_2_axis_tready_reg <= input_2_axis_tready_next;
        input_3_axis_tready_reg <= input_3_axis_tready_next;
    end
end

// output datapath logic
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
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata  = output_axis_tdata_reg;
assign output_axis_tkeep  = KEEP_ENABLE ? output_axis_tkeep_reg : {KEEP_WIDTH{1'b1}};
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast  = output_axis_tlast_reg;
assign output_axis_tid    = ID_ENABLE   ? output_axis_tid_reg   : {ID_WIDTH{1'b0}};
assign output_axis_tdest  = DEST_ENABLE ? output_axis_tdest_reg : {DEST_WIDTH{1'b0}};
assign output_axis_tuser  = USER_ENABLE ? output_axis_tuser_reg : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & (~output_axis_tvalid_reg | ~output_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_axis_tvalid_next = output_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (output_axis_tready_int_reg) begin
        // input is ready
        if (output_axis_tready | ~output_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
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
        output_axis_tvalid_reg <= 1'b0;
        output_axis_tready_int_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tready_int_reg <= output_axis_tready_int_early;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        output_axis_tdata_reg <= output_axis_tdata_int;
        output_axis_tkeep_reg <= output_axis_tkeep_int;
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tid_reg   <= output_axis_tid_int;
        output_axis_tdest_reg <= output_axis_tdest_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tkeep_reg <= temp_axis_tkeep_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tid_reg   <= temp_axis_tid_reg;
        output_axis_tdest_reg <= temp_axis_tdest_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tkeep_reg <= output_axis_tkeep_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tid_reg   <= output_axis_tid_int;
        temp_axis_tdest_reg <= output_axis_tdest_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
