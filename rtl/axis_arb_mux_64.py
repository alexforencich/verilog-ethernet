#!/usr/bin/env python
"""
Generates an arbitrated AXI Stream mux with the specified number of ports
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
        name = "axis_arb_mux_64_{0}".format(ports)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port AXI Stream arbitrated mux {1}...".format(ports, name))

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
 * AXI4-Stream {{n}} port arbitrated multiplexer (64 bit datapath)
 */
module {{name}} #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
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
{%- for p in ports %}
    input  wire [DATA_WIDTH-1:0]  input_{{p}}_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_{{p}}_axis_tkeep,
    input  wire                   input_{{p}}_axis_tvalid,
    output wire                   input_{{p}}_axis_tready,
    input  wire                   input_{{p}}_axis_tlast,
    input  wire                   input_{{p}}_axis_tuser,
{% endfor %}
    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,
    output wire                   output_axis_tuser
);

wire [{{n-1}}:0] request;
wire [{{n-1}}:0] acknowledge;
wire [{{n-1}}:0] grant;
wire grant_valid;
wire [{{w-1}}:0] grant_encoded;
{% for p in ports %}
assign acknowledge[{{p}}] = input_{{p}}_axis_tvalid & input_{{p}}_axis_tready & input_{{p}}_axis_tlast;
assign request[{{p}}] = input_{{p}}_axis_tvalid & ~acknowledge[{{p}}];
{%- endfor %}

// mux instance
axis_mux_64_{{n}} #(
    .DATA_WIDTH(DATA_WIDTH)
)
mux_inst (
    .clk(clk),
    .rst(rst),
{%- for p in ports %}
    .input_{{p}}_axis_tdata(input_{{p}}_axis_tdata),
    .input_{{p}}_axis_tkeep(input_{{p}}_axis_tkeep),
    .input_{{p}}_axis_tvalid(input_{{p}}_axis_tvalid & grant[{{p}}]),
    .input_{{p}}_axis_tready(input_{{p}}_axis_tready),
    .input_{{p}}_axis_tlast(input_{{p}}_axis_tlast),
    .input_{{p}}_axis_tuser(input_{{p}}_axis_tuser),
{%- endfor %}
    .output_axis_tdata(output_axis_tdata),
    .output_axis_tkeep(output_axis_tkeep),
    .output_axis_tvalid(output_axis_tvalid),
    .output_axis_tready(output_axis_tready),
    .output_axis_tlast(output_axis_tlast),
    .output_axis_tuser(output_axis_tuser),
    .enable(grant_valid),
    .select(grant_encoded)
);

// arbiter instance
arbiter #(
    .PORTS({{n}}),
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

