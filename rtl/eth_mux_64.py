#!/usr/bin/env python
"""
Generates an Ethernet mux with the specified number of ports
"""

from __future__ import print_function

import argparse
import math
from jinja2 import Template

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=4, help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(ports=4, name=None, output=None):
    if name is None:
        name = "eth_mux_64_{0}".format(ports)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port Ethernet mux {1}...".format(ports, name))

    select_width = int(math.ceil(math.log(ports, 2)))

    t = Template(u"""/*

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
 * Ethernet {{n}} port multiplexer (64 bit datapath)
 */
module {{name}}
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * Ethernet frame inputs
     */
{%- for p in ports %}
    input  wire        input_{{p}}_eth_hdr_valid,
    output wire        input_{{p}}_eth_hdr_ready,
    input  wire [47:0] input_{{p}}_eth_dest_mac,
    input  wire [47:0] input_{{p}}_eth_src_mac,
    input  wire [15:0] input_{{p}}_eth_type,
    input  wire [63:0] input_{{p}}_eth_payload_tdata,
    input  wire [7:0]  input_{{p}}_eth_payload_tkeep,
    input  wire        input_{{p}}_eth_payload_tvalid,
    output wire        input_{{p}}_eth_payload_tready,
    input  wire        input_{{p}}_eth_payload_tlast,
    input  wire        input_{{p}}_eth_payload_tuser,
{% endfor %}
    /*
     * Ethernet frame output
     */
    output wire        output_eth_hdr_valid,
    input  wire        output_eth_hdr_ready,
    output wire [47:0] output_eth_dest_mac,
    output wire [47:0] output_eth_src_mac,
    output wire [15:0] output_eth_type,
    output wire [63:0] output_eth_payload_tdata,
    output wire [7:0]  output_eth_payload_tkeep,
    output wire        output_eth_payload_tvalid,
    input  wire        output_eth_payload_tready,
    output wire        output_eth_payload_tlast,
    output wire        output_eth_payload_tuser,

    /*
     * Control
     */
    input  wire        enable,
    input  wire [{{w-1}}:0]  select
);

reg [{{w-1}}:0] select_reg = {{w}}'d0, select_next;
reg frame_reg = 1'b0, frame_next;
{% for p in ports %}
reg input_{{p}}_eth_hdr_ready_reg = 1'b0, input_{{p}}_eth_hdr_ready_next;
{%- endfor %}
{% for p in ports %}
reg input_{{p}}_eth_payload_tready_reg = 1'b0, input_{{p}}_eth_payload_tready_next;
{%- endfor %}

reg output_eth_hdr_valid_reg = 1'b0, output_eth_hdr_valid_next;
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
{% for p in ports %}
assign input_{{p}}_eth_hdr_ready = input_{{p}}_eth_hdr_ready_reg;
{%- endfor %}
{% for p in ports %}
assign input_{{p}}_eth_payload_tready = input_{{p}}_eth_payload_tready_reg;
{%- endfor %}

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
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            selected_input_eth_hdr_valid = input_{{p}}_eth_hdr_valid;
            selected_input_eth_dest_mac = input_{{p}}_eth_dest_mac;
            selected_input_eth_src_mac = input_{{p}}_eth_src_mac;
            selected_input_eth_type = input_{{p}}_eth_type;
        end
{%- endfor %}
        default: begin
            selected_input_eth_hdr_valid = 1'b0;
            selected_input_eth_dest_mac = 48'd0;
            selected_input_eth_src_mac = 48'd0;
            selected_input_eth_type = 16'd0;
        end
    endcase
end

// mux for incoming packet
reg [63:0] current_input_tdata;
reg [7:0]  current_input_tkeep;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            current_input_tdata = input_{{p}}_eth_payload_tdata;
            current_input_tkeep = input_{{p}}_eth_payload_tkeep;
            current_input_tvalid = input_{{p}}_eth_payload_tvalid;
            current_input_tready = input_{{p}}_eth_payload_tready;
            current_input_tlast = input_{{p}}_eth_payload_tlast;
            current_input_tuser = input_{{p}}_eth_payload_tuser;
        end
{%- endfor %}
        default: begin
            current_input_tdata = 64'd0;
            current_input_tkeep = 8'd0;
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
{% for p in ports %}
    input_{{p}}_eth_hdr_ready_next = input_{{p}}_eth_hdr_ready_reg & ~input_{{p}}_eth_hdr_valid;
{%- endfor %}
{% for p in ports %}
    input_{{p}}_eth_payload_tready_next = 1'b0;
{%- endfor %}

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
{%- for p in ports %}
            {{w}}'d{{p}}: input_{{p}}_eth_hdr_ready_next = 1'b1;
{%- endfor %}
        endcase

        output_eth_hdr_valid_next = 1'b1;
        output_eth_dest_mac_next = selected_input_eth_dest_mac;
        output_eth_src_mac_next = selected_input_eth_src_mac;
        output_eth_type_next = selected_input_eth_type;
    end

    // generate ready signal on selected port
    case (select_next)
{%- for p in ports %}
        {{w}}'d{{p}}: input_{{p}}_eth_payload_tready_next = output_eth_payload_tready_int_early & frame_next;
{%- endfor %}
    endcase

    // pass through selected packet data
    output_eth_payload_tdata_int = current_input_tdata;
    output_eth_payload_tkeep_int = current_input_tkeep;
    output_eth_payload_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_eth_payload_tlast_int = current_input_tlast;
    output_eth_payload_tuser_int = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= {{w}}'d0;
        frame_reg <= 1'b0;
{%- for p in ports %}
        input_{{p}}_eth_hdr_ready_reg <= 1'b0;
{%- endfor %}
{%- for p in ports %}
        input_{{p}}_eth_payload_tready_reg <= 1'b0;
{%- endfor %}
        output_eth_hdr_valid_reg <= 1'b0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
{%- for p in ports %}
        input_{{p}}_eth_hdr_ready_reg <= input_{{p}}_eth_hdr_ready_next;
{%- endfor %}
{%- for p in ports %}
        input_{{p}}_eth_payload_tready_reg <= input_{{p}}_eth_payload_tready_next;
{%- endfor %}
        output_eth_hdr_valid_reg <= output_eth_hdr_valid_next;
    end

    output_eth_dest_mac_reg <= output_eth_dest_mac_next;
    output_eth_src_mac_reg <= output_eth_src_mac_next;
    output_eth_type_reg <= output_eth_type_next;
end

// output datapath logic
reg [63:0] output_eth_payload_tdata_reg = 64'd0;
reg [7:0]  output_eth_payload_tkeep_reg = 8'd0;
reg        output_eth_payload_tvalid_reg = 1'b0, output_eth_payload_tvalid_next;
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

assign output_eth_payload_tdata = output_eth_payload_tdata_reg;
assign output_eth_payload_tkeep = output_eth_payload_tkeep_reg;
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

""")
    
    output_file.write(t.render(
        n=ports,
        w=select_width,
        name=name,
        ports=range(ports)
    ))
    
    print("Done")

if __name__ == "__main__":
    main()

