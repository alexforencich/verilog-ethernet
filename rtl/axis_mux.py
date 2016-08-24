#!/usr/bin/env python
"""
Generates an AXI Stream mux with the specified number of ports
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
        name = "axis_mux_{0}".format(ports)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port AXI Stream mux {1}...".format(ports, name))

    select_width = int(math.ceil(math.log(ports, 2)))

    t = Template(u"""/*

Copyright (c) 2014-2016 Alex Forencich

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
 * AXI4-Stream {{n}} port multiplexer
 */
module {{name}} #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,
    
    /*
     * AXI inputs
     */
{%- for p in ports %}
    input  wire [DATA_WIDTH-1:0]  input_{{p}}_axis_tdata,
    input  wire                   input_{{p}}_axis_tvalid,
    output wire                   input_{{p}}_axis_tready,
    input  wire                   input_{{p}}_axis_tlast,
    input  wire                   input_{{p}}_axis_tuser,
{% endfor %}
    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser,

    /*
     * Control
     */
    input  wire                   enable,
    input  wire [{{w-1}}:0]             select
);

reg [{{w-1}}:0] select_reg = {{w}}'d0, select_next;
reg frame_reg = 1'b0, frame_next;
{% for p in ports %}
reg input_{{p}}_axis_tready_reg = 1'b0, input_{{p}}_axis_tready_next;
{%- endfor %}

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int_reg = 1'b0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;
{% for p in ports %}
assign input_{{p}}_axis_tready = input_{{p}}_axis_tready_reg;
{%- endfor %}

// mux for start of packet detection
reg selected_input_tvalid;
always @* begin
    case (select)
{%- for p in ports %}
        {{w}}'d{{p}}: selected_input_tvalid = input_{{p}}_axis_tvalid;
{%- endfor %}
        default: selected_input_tvalid = 1'b0;
    endcase
end

// mux for incoming packet
reg [DATA_WIDTH-1:0] current_input_tdata;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            current_input_tdata = input_{{p}}_axis_tdata;
            current_input_tvalid = input_{{p}}_axis_tvalid;
            current_input_tready = input_{{p}}_axis_tready;
            current_input_tlast = input_{{p}}_axis_tlast;
            current_input_tuser = input_{{p}}_axis_tuser;
        end
{%- endfor %}
        default: begin
            current_input_tdata = {DATA_WIDTH{1'b0}};
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
    input_{{p}}_axis_tready_next = 1'b0;
{%- endfor %}

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
{%- for p in ports %}
        {{w}}'d{{p}}: input_{{p}}_axis_tready_next = output_axis_tready_int_early & frame_next;
{%- endfor %}
    endcase

    // pass through selected packet data
    output_axis_tdata_int = current_input_tdata;
    output_axis_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_axis_tlast_int = current_input_tlast;
    output_axis_tuser_int = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= {{w}}'d0;
        frame_reg <= 1'b0;
{%- for p in ports %}
        input_{{p}}_axis_tready_reg <= 1'b0;
{%- endfor %}
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
{%- for p in ports %}
        input_{{p}}_axis_tready_reg <= input_{{p}}_axis_tready_next;
{%- endfor %}
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg                  output_axis_tlast_reg = 1'b0;
reg                  output_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg                  temp_axis_tlast_reg = 1'b0;
reg                  temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

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
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
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

