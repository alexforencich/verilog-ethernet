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
 * Ethernet 4 port multiplexer
 */
module eth_mux_4
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame inputs
     */
    input  wire        input_0_eth_hdr_valid,
    output wire        input_0_eth_hdr_ready,
    input  wire [47:0] input_0_eth_dest_mac,
    input  wire [47:0] input_0_eth_src_mac,
    input  wire [15:0] input_0_eth_type,
    input  wire [7:0]  input_0_eth_payload_tdata,
    input  wire        input_0_eth_payload_tvalid,
    output wire        input_0_eth_payload_tready,
    input  wire        input_0_eth_payload_tlast,
    input  wire        input_0_eth_payload_tuser,

    input  wire        input_1_eth_hdr_valid,
    output wire        input_1_eth_hdr_ready,
    input  wire [47:0] input_1_eth_dest_mac,
    input  wire [47:0] input_1_eth_src_mac,
    input  wire [15:0] input_1_eth_type,
    input  wire [7:0]  input_1_eth_payload_tdata,
    input  wire        input_1_eth_payload_tvalid,
    output wire        input_1_eth_payload_tready,
    input  wire        input_1_eth_payload_tlast,
    input  wire        input_1_eth_payload_tuser,

    input  wire        input_2_eth_hdr_valid,
    output wire        input_2_eth_hdr_ready,
    input  wire [47:0] input_2_eth_dest_mac,
    input  wire [47:0] input_2_eth_src_mac,
    input  wire [15:0] input_2_eth_type,
    input  wire [7:0]  input_2_eth_payload_tdata,
    input  wire        input_2_eth_payload_tvalid,
    output wire        input_2_eth_payload_tready,
    input  wire        input_2_eth_payload_tlast,
    input  wire        input_2_eth_payload_tuser,

    input  wire        input_3_eth_hdr_valid,
    output wire        input_3_eth_hdr_ready,
    input  wire [47:0] input_3_eth_dest_mac,
    input  wire [47:0] input_3_eth_src_mac,
    input  wire [15:0] input_3_eth_type,
    input  wire [7:0]  input_3_eth_payload_tdata,
    input  wire        input_3_eth_payload_tvalid,
    output wire        input_3_eth_payload_tready,
    input  wire        input_3_eth_payload_tlast,
    input  wire        input_3_eth_payload_tuser,

    /*
     * Ethernet frame output
     */
    output wire        output_eth_hdr_valid,
    input  wire        output_eth_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
    output wire [7:0]  output_eth_payload_tdata,
    output wire        output_eth_payload_tvalid,
    input  wire        output_eth_payload_tready,
    output wire        output_eth_payload_tlast,
    output wire        output_eth_payload_tuser,

    /*
     * Control
     */
    input  wire        enable,
    input  wire [1:0]  select
);

reg [1:0] select_reg = 2'd0, select_next;
reg frame_reg = 1'b0, frame_next;

reg input_0_eth_hdr_ready_reg = 1'b0, input_0_eth_hdr_ready_next;
reg input_1_eth_hdr_ready_reg = 1'b0, input_1_eth_hdr_ready_next;
reg input_2_eth_hdr_ready_reg = 1'b0, input_2_eth_hdr_ready_next;
reg input_3_eth_hdr_ready_reg = 1'b0, input_3_eth_hdr_ready_next;

reg input_0_eth_payload_tready_reg = 1'b0, input_0_eth_payload_tready_next;
reg input_1_eth_payload_tready_reg = 1'b0, input_1_eth_payload_tready_next;
reg input_2_eth_payload_tready_reg = 1'b0, input_2_eth_payload_tready_next;
reg input_3_eth_payload_tready_reg = 1'b0, input_3_eth_payload_tready_next;

reg output_eth_hdr_valid_reg = 1'b0, output_eth_hdr_valid_next;
reg [47:0] output_eth_dest_mac_reg = 48'd0, output_eth_dest_mac_next;
reg [47:0] output_eth_src_mac_reg = 48'd0, output_eth_src_mac_next;
reg [15:0] output_eth_type_reg = 16'd0, output_eth_type_next;

// internal datapath
reg [7:0] output_eth_payload_tdata_int;
reg       output_eth_payload_tvalid_int;
reg       output_eth_payload_tready_int_reg = 1'b0;
reg       output_eth_payload_tlast_int;
reg       output_eth_payload_tuser_int;
wire      output_eth_payload_tready_int_early;

assign input_0_eth_hdr_ready = input_0_eth_hdr_ready_reg;
assign input_1_eth_hdr_ready = input_1_eth_hdr_ready_reg;
assign input_2_eth_hdr_ready = input_2_eth_hdr_ready_reg;
assign input_3_eth_hdr_ready = input_3_eth_hdr_ready_reg;

assign input_0_eth_payload_tready = input_0_eth_payload_tready_reg;
assign input_1_eth_payload_tready = input_1_eth_payload_tready_reg;
assign input_2_eth_payload_tready = input_2_eth_payload_tready_reg;
assign input_3_eth_payload_tready = input_3_eth_payload_tready_reg;

assign output_eth_hdr_valid = output_eth_hdr_valid_reg;
assign output_eth_dest_mac = output_eth_dest_mac_reg;
assign output_eth_src_mac = output_eth_src_mac_reg;
assign output_eth_type = output_eth_type_reg;

// mux for start of packet detection
reg selected_input_eth_hdr_valid;
reg [47:0] selected_input_eth_dest_mac;
reg [47:0] selected_input_eth_src_mac;
reg [15:0] selected_input_eth_type;
always @* begin
    case (select)
        2'd0: begin
            selected_input_eth_hdr_valid = input_0_eth_hdr_valid;
            selected_input_eth_dest_mac = input_0_eth_dest_mac;
            selected_input_eth_src_mac = input_0_eth_src_mac;
            selected_input_eth_type = input_0_eth_type;
        end
        2'd1: begin
            selected_input_eth_hdr_valid = input_1_eth_hdr_valid;
            selected_input_eth_dest_mac = input_1_eth_dest_mac;
            selected_input_eth_src_mac = input_1_eth_src_mac;
            selected_input_eth_type = input_1_eth_type;
        end
        2'd2: begin
            selected_input_eth_hdr_valid = input_2_eth_hdr_valid;
            selected_input_eth_dest_mac = input_2_eth_dest_mac;
            selected_input_eth_src_mac = input_2_eth_src_mac;
            selected_input_eth_type = input_2_eth_type;
        end
        2'd3: begin
            selected_input_eth_hdr_valid = input_3_eth_hdr_valid;
            selected_input_eth_dest_mac = input_3_eth_dest_mac;
            selected_input_eth_src_mac = input_3_eth_src_mac;
            selected_input_eth_type = input_3_eth_type;
        end
        default: begin
            selected_input_eth_hdr_valid = 1'b0;
            selected_input_eth_dest_mac = 48'd0;
            selected_input_eth_src_mac = 48'd0;
            selected_input_eth_type = 16'd0;
        end
    endcase
end

// mux for incoming packet
reg [7:0] current_input_tdata;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
        2'd0: begin
            current_input_tdata = input_0_eth_payload_tdata;
            current_input_tvalid = input_0_eth_payload_tvalid;
            current_input_tready = input_0_eth_payload_tready;
            current_input_tlast = input_0_eth_payload_tlast;
            current_input_tuser = input_0_eth_payload_tuser;
        end
        2'd1: begin
            current_input_tdata = input_1_eth_payload_tdata;
            current_input_tvalid = input_1_eth_payload_tvalid;
            current_input_tready = input_1_eth_payload_tready;
            current_input_tlast = input_1_eth_payload_tlast;
            current_input_tuser = input_1_eth_payload_tuser;
        end
        2'd2: begin
            current_input_tdata = input_2_eth_payload_tdata;
            current_input_tvalid = input_2_eth_payload_tvalid;
            current_input_tready = input_2_eth_payload_tready;
            current_input_tlast = input_2_eth_payload_tlast;
            current_input_tuser = input_2_eth_payload_tuser;
        end
        2'd3: begin
            current_input_tdata = input_3_eth_payload_tdata;
            current_input_tvalid = input_3_eth_payload_tvalid;
            current_input_tready = input_3_eth_payload_tready;
            current_input_tlast = input_3_eth_payload_tlast;
            current_input_tuser = input_3_eth_payload_tuser;
        end
        default: begin
            current_input_tdata = 8'd0;
            current_input_tvalid = 1'b0;
            current_input_tready = 1'b0;
            current_input_tlast = 1'b0;
            current_input_tuser = 1'b0;
        end
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_0_eth_hdr_ready_next = input_0_eth_hdr_ready_reg & ~input_0_eth_hdr_valid;
    input_1_eth_hdr_ready_next = input_1_eth_hdr_ready_reg & ~input_1_eth_hdr_valid;
    input_2_eth_hdr_ready_next = input_2_eth_hdr_ready_reg & ~input_2_eth_hdr_valid;
    input_3_eth_hdr_ready_next = input_3_eth_hdr_ready_reg & ~input_3_eth_hdr_valid;

    input_0_eth_payload_tready_next = 1'b0;
    input_1_eth_payload_tready_next = 1'b0;
    input_2_eth_payload_tready_next = 1'b0;
    input_3_eth_payload_tready_next = 1'b0;

    output_eth_hdr_valid_next = output_eth_hdr_valid_reg & ~output_eth_hdr_ready;
    output_eth_dest_mac_next = output_eth_dest_mac_reg;
    output_eth_src_mac_next = output_eth_src_mac_reg;
    output_eth_type_next = output_eth_type_reg;

    if (current_input_tvalid & current_input_tready) begin
        // end of frame detection
        if (current_input_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (~frame_reg & enable & ~output_eth_hdr_valid & selected_input_eth_hdr_valid) begin
        // start of frame, grab select value
        frame_next = 1'b1;
        select_next = select;

        case (select_next)
            2'd0: input_0_eth_hdr_ready_next = 1'b1;
            2'd1: input_1_eth_hdr_ready_next = 1'b1;
            2'd2: input_2_eth_hdr_ready_next = 1'b1;
            2'd3: input_3_eth_hdr_ready_next = 1'b1;
        endcase

        output_eth_hdr_valid_next = 1'b1;
        output_eth_dest_mac_next = selected_input_eth_dest_mac;
        output_eth_src_mac_next = selected_input_eth_src_mac;
        output_eth_type_next = selected_input_eth_type;
    end

    // generate ready signal on selected port
    case (select_next)
        2'd0: input_0_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;
        2'd1: input_1_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;
        2'd2: input_2_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;
        2'd3: input_3_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;
    endcase

    // pass through selected packet data
    output_eth_payload_tdata_int = current_input_tdata;
    output_eth_payload_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_eth_payload_tlast_int = current_input_tlast;
    output_eth_payload_tuser_int = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 2'd0;
        frame_reg <= 1'b0;
        input_0_eth_hdr_ready_reg <= 1'b0;
        input_1_eth_hdr_ready_reg <= 1'b0;
        input_2_eth_hdr_ready_reg <= 1'b0;
        input_3_eth_hdr_ready_reg <= 1'b0;
        input_0_eth_payload_tready_reg <= 1'b0;
        input_1_eth_payload_tready_reg <= 1'b0;
        input_2_eth_payload_tready_reg <= 1'b0;
        input_3_eth_payload_tready_reg <= 1'b0;
        output_eth_hdr_valid_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_0_eth_hdr_ready_reg <= input_0_eth_hdr_ready_next;
        input_1_eth_hdr_ready_reg <= input_1_eth_hdr_ready_next;
        input_2_eth_hdr_ready_reg <= input_2_eth_hdr_ready_next;
        input_3_eth_hdr_ready_reg <= input_3_eth_hdr_ready_next;
        input_0_eth_payload_tready_reg <= input_0_eth_payload_tready_next;
        input_1_eth_payload_tready_reg <= input_1_eth_payload_tready_next;
        input_2_eth_payload_tready_reg <= input_2_eth_payload_tready_next;
        input_3_eth_payload_tready_reg <= input_3_eth_payload_tready_next;
        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;
    end

    output_eth_dest_mac_reg <= output_eth_dest_mac_next;
    output_eth_src_mac_reg <= output_eth_src_mac_next;
    output_eth_type_reg <= output_eth_type_next;
end

// output datapath logic
reg [7:0] output_eth_payload_tdata_reg = 8'd0;
reg       output_eth_payload_tvalid_reg = 1'b0, output_eth_payload_tvalid_next;
reg       output_eth_payload_tlast_reg = 1'b0;
reg       output_eth_payload_tuser_reg = 1'b0;

reg [7:0] temp_eth_payload_tdata_reg = 8'd0;
reg       temp_eth_payload_tvalid_reg = 1'b0, temp_eth_payload_tvalid_next;
reg       temp_eth_payload_tlast_reg = 1'b0;
reg       temp_eth_payload_tuser_reg = 1'b0;

// datapath control
reg store_eth_payload_int_to_output;
reg store_eth_payload_int_to_temp;
reg store_eth_payload_temp_to_output;

assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_eth_payload_tvalid = output_eth_payload_tvalid_reg;
assign output_eth_payload_tlast = output_eth_payload_tlast_reg;
assign output_eth_payload_tuser = output_eth_payload_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_eth_payload_tready_int_early = output_eth_payload_tready | (~temp_eth_payload_tvalid_reg & (~output_eth_payload_tvalid_reg | ~output_eth_payload_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_eth_payload_tvalid_next = output_eth_payload_tvalid_reg;
    temp_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg;

    store_eth_payload_int_to_output = 1'b0;
    store_eth_payload_int_to_temp = 1'b0;
    store_eth_payload_temp_to_output = 1'b0;
    
    if (output_eth_payload_tready_int_reg) begin
        // input is ready
        if (output_eth_payload_tready | ~output_eth_payload_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_eth_payload_tvalid_next = output_eth_payload_tvalid_int;
            store_eth_payload_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_eth_payload_tvalid_next = output_eth_payload_tvalid_int;
            store_eth_payload_int_to_temp = 1'b1;
        end
    end else if (output_eth_payload_tready) begin
        // input is not ready, but output is ready
        output_eth_payload_tvalid_next = temp_eth_payload_tvalid_reg;
        temp_eth_payload_tvalid_next = 1'b0;
        store_eth_payload_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_eth_payload_tvalid_reg <= 1'b0;
        output_eth_payload_tready_int_reg <= 1'b0;
        temp_eth_payload_tvalid_reg <= 1'b0;
    end else begin
        output_eth_payload_tvalid_reg <= output_eth_payload_tvalid_next;
        output_eth_payload_tready_int_reg <= output_eth_payload_tready_int_early;
        temp_eth_payload_tvalid_reg <= temp_eth_payload_tvalid_next;
    end

    // datapath
    if (store_eth_payload_int_to_output) begin
        output_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        output_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        output_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end else if (store_eth_payload_temp_to_output) begin
        output_eth_payload_tdata_reg <= temp_eth_payload_tdata_reg;
        output_eth_payload_tlast_reg <= temp_eth_payload_tlast_reg;
        output_eth_payload_tuser_reg <= temp_eth_payload_tuser_reg;
    end

    if (store_eth_payload_int_to_temp) begin
        temp_eth_payload_tdata_reg <= output_eth_payload_tdata_int;
        temp_eth_payload_tlast_reg <= output_eth_payload_tlast_int;
        temp_eth_payload_tuser_reg <= output_eth_payload_tuser_int;
    end
end

endmodule
