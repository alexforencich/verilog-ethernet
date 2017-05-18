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
 * Ethernet 4 port demultiplexer (64 bit datapath)
 */
module eth_demux_64_4
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame input
     */
    input  wire        input_eth_hdr_valid,
    output wire        input_eth_hdr_ready,
    input  wire [47:0] input_eth_dest_mac,
    input  wire [47:0] input_eth_src_mac,
    input  wire [15:0] input_eth_type,
    input  wire [63:0] input_eth_payload_tdata,
    input  wire [7:0]  input_eth_payload_tkeep,
    input  wire        input_eth_payload_tvalid,
    output wire        input_eth_payload_tready,
    input  wire        input_eth_payload_tlast,
    input  wire        input_eth_payload_tuser,
    
    /*
     * Ethernet frame outputs
     */
    output wire        output_0_eth_hdr_valid,
    input  wire        output_0_eth_hdr_ready,
    output wire [47:0] output_0_eth_dest_mac,
    output wire [47:0] output_0_eth_src_mac,
    output wire [15:0] output_0_eth_type,
    output wire [63:0] output_0_eth_payload_tdata,
    output wire [7:0]  output_0_eth_payload_tkeep,
    output wire        output_0_eth_payload_tvalid,
    input  wire        output_0_eth_payload_tready,
    output wire        output_0_eth_payload_tlast,
    output wire        output_0_eth_payload_tuser,

    output wire        output_1_eth_hdr_valid,
    input  wire        output_1_eth_hdr_ready,
    output wire [47:0] output_1_eth_dest_mac,
    output wire [47:0] output_1_eth_src_mac,
    output wire [15:0] output_1_eth_type,
    output wire [63:0] output_1_eth_payload_tdata,
    output wire [7:0]  output_1_eth_payload_tkeep,
    output wire        output_1_eth_payload_tvalid,
    input  wire        output_1_eth_payload_tready,
    output wire        output_1_eth_payload_tlast,
    output wire        output_1_eth_payload_tuser,

    output wire        output_2_eth_hdr_valid,
    input  wire        output_2_eth_hdr_ready,
    output wire [47:0] output_2_eth_dest_mac,
    output wire [47:0] output_2_eth_src_mac,
    output wire [15:0] output_2_eth_type,
    output wire [63:0] output_2_eth_payload_tdata,
    output wire [7:0]  output_2_eth_payload_tkeep,
    output wire        output_2_eth_payload_tvalid,
    input  wire        output_2_eth_payload_tready,
    output wire        output_2_eth_payload_tlast,
    output wire        output_2_eth_payload_tuser,

    output wire        output_3_eth_hdr_valid,
    input  wire        output_3_eth_hdr_ready,
    output wire [47:0] output_3_eth_dest_mac,
    output wire [47:0] output_3_eth_src_mac,
    output wire [15:0] output_3_eth_type,
    output wire [63:0] output_3_eth_payload_tdata,
    output wire [7:0]  output_3_eth_payload_tkeep,
    output wire        output_3_eth_payload_tvalid,
    input  wire        output_3_eth_payload_tready,
    output wire        output_3_eth_payload_tlast,
    output wire        output_3_eth_payload_tuser,

    /*
     * Control
     */
    input  wire        enable,
    input  wire [1:0]  select
);

reg [1:0] select_reg = 2'd0, select_next;
reg frame_reg = 1'b0, frame_next;

reg input_eth_hdr_ready_reg = 1'b0, input_eth_hdr_ready_next;
reg input_eth_payload_tready_reg = 1'b0, input_eth_payload_tready_next;

reg output_0_eth_hdr_valid_reg = 1'b0, output_0_eth_hdr_valid_next;
reg output_1_eth_hdr_valid_reg = 1'b0, output_1_eth_hdr_valid_next;
reg output_2_eth_hdr_valid_reg = 1'b0, output_2_eth_hdr_valid_next;
reg output_3_eth_hdr_valid_reg = 1'b0, output_3_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 48'd0, output_eth_dest_mac_next;
reg [47:0] output_eth_src_mac_reg = 48'd0, output_eth_src_mac_next;
reg [15:0] output_eth_type_reg = 16'd0, output_eth_type_next;

// internal datapath
reg [63:0] output_eth_payload_tdata_int;
reg [7:0]  output_eth_payload_tkeep_int;
reg        output_eth_payload_tvalid_int;
reg        output_eth_payload_tready_int_reg = 1'b0;
reg        output_eth_payload_tlast_int;
reg        output_eth_payload_tuser_int;
wire       output_eth_payload_tready_int_early;

assign input_eth_hdr_ready = input_eth_hdr_ready_reg;
assign input_eth_payload_tready = input_eth_payload_tready_reg;

assign output_0_eth_hdr_valid = output_0_eth_hdr_valid_reg;
assign output_0_eth_dest_mac = output_eth_dest_mac_reg;
assign output_0_eth_src_mac = output_eth_src_mac_reg;
assign output_0_eth_type = output_eth_type_reg;

assign output_1_eth_hdr_valid = output_1_eth_hdr_valid_reg;
assign output_1_eth_dest_mac = output_eth_dest_mac_reg;
assign output_1_eth_src_mac = output_eth_src_mac_reg;
assign output_1_eth_type = output_eth_type_reg;

assign output_2_eth_hdr_valid = output_2_eth_hdr_valid_reg;
assign output_2_eth_dest_mac = output_eth_dest_mac_reg;
assign output_2_eth_src_mac = output_eth_src_mac_reg;
assign output_2_eth_type = output_eth_type_reg;

assign output_3_eth_hdr_valid = output_3_eth_hdr_valid_reg;
assign output_3_eth_dest_mac = output_eth_dest_mac_reg;
assign output_3_eth_src_mac = output_eth_src_mac_reg;
assign output_3_eth_type = output_eth_type_reg;

// mux for output control signals
reg current_output_eth_hdr_valid;
reg current_output_eth_hdr_ready;
reg current_output_tvalid;
reg current_output_tready;
always @* begin
    case (select_reg)
        2'd0: begin
            current_output_eth_hdr_valid = output_0_eth_hdr_valid;
            current_output_eth_hdr_ready = output_0_eth_hdr_ready;
            current_output_tvalid = output_0_eth_payload_tvalid;
            current_output_tready = output_0_eth_payload_tready;
        end
        2'd1: begin
            current_output_eth_hdr_valid = output_1_eth_hdr_valid;
            current_output_eth_hdr_ready = output_1_eth_hdr_ready;
            current_output_tvalid = output_1_eth_payload_tvalid;
            current_output_tready = output_1_eth_payload_tready;
        end
        2'd2: begin
            current_output_eth_hdr_valid = output_2_eth_hdr_valid;
            current_output_eth_hdr_ready = output_2_eth_hdr_ready;
            current_output_tvalid = output_2_eth_payload_tvalid;
            current_output_tready = output_2_eth_payload_tready;
        end
        2'd3: begin
            current_output_eth_hdr_valid = output_3_eth_hdr_valid;
            current_output_eth_hdr_ready = output_3_eth_hdr_ready;
            current_output_tvalid = output_3_eth_payload_tvalid;
            current_output_tready = output_3_eth_payload_tready;
        end
        default: begin
            current_output_eth_hdr_valid = 1'b0;
            current_output_eth_hdr_ready = 1'b0;
            current_output_tvalid = 1'b0;
            current_output_tready = 1'b0;
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_eth_hdr_ready_next = input_eth_hdr_ready_reg & ~input_eth_hdr_valid;
    input_eth_payload_tready_next = 1'b0;
    output_0_eth_hdr_valid_next = output_0_eth_hdr_valid_reg & ~output_0_eth_hdr_ready;
    output_1_eth_hdr_valid_next = output_1_eth_hdr_valid_reg & ~output_1_eth_hdr_ready;
    output_2_eth_hdr_valid_next = output_2_eth_hdr_valid_reg & ~output_2_eth_hdr_ready;
    output_3_eth_hdr_valid_next = output_3_eth_hdr_valid_reg & ~output_3_eth_hdr_ready;
    output_eth_dest_mac_next = output_eth_dest_mac_reg;
    output_eth_src_mac_next = output_eth_src_mac_reg;
    output_eth_type_next = output_eth_type_reg;

    if (input_eth_payload_tvalid & input_eth_payload_tready) begin
        // end of frame detection
        if (input_eth_payload_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (~frame_reg & enable & input_eth_hdr_valid & ~current_output_eth_hdr_valid & ~current_output_tvalid) begin
        // start of frame, grab select value
        frame_next = 1'b1;
        select_next = select;

        input_eth_hdr_ready_next = 1'b1;

        case (select)
            2'd0: output_0_eth_hdr_valid_next = 1'b1;
            2'd1: output_1_eth_hdr_valid_next = 1'b1;
            2'd2: output_2_eth_hdr_valid_next = 1'b1;
            2'd3: output_3_eth_hdr_valid_next = 1'b1;
        endcase
        output_eth_dest_mac_next = input_eth_dest_mac;
        output_eth_src_mac_next = input_eth_src_mac;
        output_eth_type_next = input_eth_type;
    end

    input_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;

    output_eth_payload_tdata_int = input_eth_payload_tdata;
    output_eth_payload_tkeep_int = input_eth_payload_tkeep;
    output_eth_payload_tvalid_int = input_eth_payload_tvalid & input_eth_payload_tready;
    output_eth_payload_tlast_int = input_eth_payload_tlast;
    output_eth_payload_tuser_int = input_eth_payload_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 2'd0;
        frame_reg <= 1'b0;
        input_eth_hdr_ready_reg <= 1'b0;
        input_eth_payload_tready_reg <= 1'b0;
        output_0_eth_hdr_valid_reg <= 1'b0;
        output_1_eth_hdr_valid_reg <= 1'b0;
        output_2_eth_hdr_valid_reg <= 1'b0;
        output_3_eth_hdr_valid_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_eth_hdr_ready_reg <= input_eth_hdr_ready_next;
        input_eth_payload_tready_reg <= input_eth_payload_tready_next;
        output_0_eth_hdr_valid_reg <= output_0_eth_hdr_valid_next;
        output_1_eth_hdr_valid_reg <= output_1_eth_hdr_valid_next;
        output_2_eth_hdr_valid_reg <= output_2_eth_hdr_valid_next;
        output_3_eth_hdr_valid_reg <= output_3_eth_hdr_valid_next;
    end

    output_eth_dest_mac_reg <= output_eth_dest_mac_next;
    output_eth_src_mac_reg <= output_eth_src_mac_next;
    output_eth_type_reg <= output_eth_type_next;
end

// output datapath logic
reg [63:0] output_eth_payload_tdata_reg = 64'd0;
reg [7:0]  output_eth_payload_tkeep_reg = 8'd0;
reg        output_0_eth_payload_tvalid_reg = 1'b0, output_0_eth_payload_tvalid_next;
reg        output_1_eth_payload_tvalid_reg = 1'b0, output_1_eth_payload_tvalid_next;
reg        output_2_eth_payload_tvalid_reg = 1'b0, output_2_eth_payload_tvalid_next;
reg        output_3_eth_payload_tvalid_reg = 1'b0, output_3_eth_payload_tvalid_next;
reg        output_eth_payload_tlast_reg = 1'b0;
reg        output_eth_payload_tuser_reg = 1'b0;

reg [63:0] temp_eth_payload_tdata_reg = 64'd0;
reg [7:0]  temp_eth_payload_tkeep_reg = 8'd0;
reg        temp_eth_payload_tvalid_reg = 1'b0, temp_eth_payload_tvalid_next;
reg        temp_eth_payload_tlast_reg = 1'b0;
reg        temp_eth_payload_tuser_reg = 1'b0;

// datapath control
reg store_eth_payload_int_to_output;
reg store_eth_payload_int_to_temp;
reg store_eth_payload_temp_to_output;

assign output_0_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_0_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_0_eth_payload_tvalid = output_0_eth_payload_tvalid_reg;
assign output_0_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_0_eth_payload_tuser = output_eth_payload_tuser_reg;

assign output_1_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_1_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_1_eth_payload_tvalid = output_1_eth_payload_tvalid_reg;
assign output_1_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_1_eth_payload_tuser = output_eth_payload_tuser_reg;

assign output_2_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_2_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_2_eth_payload_tvalid = output_2_eth_payload_tvalid_reg;
assign output_2_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_2_eth_payload_tuser = output_eth_payload_tuser_reg;

assign output_3_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_3_eth_payload_tkeep = output_eth_payload_tkeep_reg;
assign output_3_eth_payload_tvalid = output_3_eth_payload_tvalid_reg;
assign output_3_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_3_eth_payload_tuser = output_eth_payload_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_eth_payload_tready_int_early = current_output_tready | (~temp_eth_payload_tvalid_reg & (~current_output_tvalid | ~output_eth_payload_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_0_eth_payload_tvalid_next = output_0_eth_payload_tvalid_reg;
    output_1_eth_payload_tvalid_next = output_1_eth_payload_tvalid_reg;
    output_2_eth_payload_tvalid_next = output_2_eth_payload_tvalid_reg;
    output_3_eth_payload_tvalid_next = output_3_eth_payload_tvalid_reg;
    temp_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg;

    store_eth_payload_int_to_output = 1'b0;
    store_eth_payload_int_to_temp = 1'b0;
    store_eth_payload_temp_to_output = 1'b0;
    
    if (output_eth_payload_tready_int_reg) begin
        // input is ready
        if (current_output_tready | ~current_output_tvalid) begin
            // output is ready or currently not valid, transfer data to output
            output_0_eth_payload_tvalid_next = output_eth_payload_tvalid_int & (select_reg == 2'd0);
            output_1_eth_payload_tvalid_next = output_eth_payload_tvalid_int & (select_reg == 2'd1);
            output_2_eth_payload_tvalid_next = output_eth_payload_tvalid_int & (select_reg == 2'd2);
            output_3_eth_payload_tvalid_next = output_eth_payload_tvalid_int & (select_reg == 2'd3);
            store_eth_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_eth_payload_tvalid_next = output_eth_payload_tvalid_int;
            store_eth_payload_int_to_temp = 1'b1;
        end
    end else if (current_output_tready) begin
        // input is not ready, but output is ready
        output_0_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg & (select_reg == 2'd0);
        output_1_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg & (select_reg == 2'd1);
        output_2_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg & (select_reg == 2'd2);
        output_3_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg & (select_reg == 2'd3);
        temp_eth_payload_tvalid_next = 1'b0;
        store_eth_payload_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_0_eth_payload_tvalid_reg <= 1'b0;
        output_1_eth_payload_tvalid_reg <= 1'b0;
        output_2_eth_payload_tvalid_reg <= 1'b0;
        output_3_eth_payload_tvalid_reg <= 1'b0;
        output_eth_payload_tready_int_reg <= 1'b0;
        temp_eth_payload_tvalid_reg <= 1'b0;
    end else begin
        output_0_eth_payload_tvalid_reg <= output_0_eth_payload_tvalid_next;
        output_1_eth_payload_tvalid_reg <= output_1_eth_payload_tvalid_next;
        output_2_eth_payload_tvalid_reg <= output_2_eth_payload_tvalid_next;
        output_3_eth_payload_tvalid_reg <= output_3_eth_payload_tvalid_next;
        output_eth_payload_tready_int_reg <= output_eth_payload_tready_int_early;
        temp_eth_payload_tvalid_reg <= temp_eth_payload_tvalid_next;
    end

    // datapath
    if (store_eth_payload_int_to_output) begin
        output_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        output_eth_payload_tkeep_reg <= output_eth_payload_tkeep_int;
        output_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        output_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end else if (store_eth_payload_temp_to_output) begin
        output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
        output_eth_payload_tkeep_reg <= temp_eth_payload_tkeep_reg;
        output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
        output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
    end

    if (store_eth_payload_int_to_temp) begin
        temp_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        temp_eth_payload_tkeep_reg <= output_eth_payload_tkeep_int;
        temp_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        temp_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end
end

endmodule
