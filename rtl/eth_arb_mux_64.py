#!/usr/bin/env python
"""
Generates an arbitrated Ethernet mux with the specified number of ports
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
        name = "eth_arb_mux_64_{0}".format(ports)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port Ethernet arbitrated mux {1}...".format(ports, name))

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
 * Ethernet {{n}} port arbitrated multiplexer (64 bit datapath)
 */
module {{name}} #
(
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "PRIORITY",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
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
    output wire        output_eth_payload_tuser
);

wire [{{n-1}}:0] request;
wire [{{n-1}}:0] acknowledge;
wire [{{n-1}}:0] grant;
wire grant_valid;
wire [{{w-1}}:0] grant_encoded;
{% for p in ports %}
assign acknowledge[{{p}}] = input_{{p}}_eth_payload_tvalid & input_{{p}}_eth_payload_tready & input_{{p}}_eth_payload_tlast;
assign request[{{p}}] = input_{{p}}_eth_hdr_valid;
{%- endfor %}

// mux instance
eth_mux_64_{{n}}
mux_inst (
    .clk(clk),
    .rst(rst),
{%- for p in ports %}
    .input_{{p}}_eth_hdr_valid(input_{{p}}_eth_hdr_valid & grant[{{p}}]),
    .input_{{p}}_eth_hdr_ready(input_{{p}}_eth_hdr_ready),
    .input_{{p}}_eth_dest_mac(input_{{p}}_eth_dest_mac),
    .input_{{p}}_eth_src_mac(input_{{p}}_eth_src_mac),
    .input_{{p}}_eth_type(input_{{p}}_eth_type),
    .input_{{p}}_eth_payload_tdata(input_{{p}}_eth_payload_tdata),
    .input_{{p}}_eth_payload_tkeep(input_{{p}}_eth_payload_tkeep),
    .input_{{p}}_eth_payload_tvalid(input_{{p}}_eth_payload_tvalid & grant[{{p}}]),
    .input_{{p}}_eth_payload_tready(input_{{p}}_eth_payload_tready),
    .input_{{p}}_eth_payload_tlast(input_{{p}}_eth_payload_tlast),
    .input_{{p}}_eth_payload_tuser(input_{{p}}_eth_payload_tuser),
{%- endfor %}
    .output_eth_hdr_valid(output_eth_hdr_valid),
    .output_eth_hdr_ready(output_eth_hdr_ready),
    .output_eth_dest_mac(output_eth_dest_mac),
    .output_eth_src_mac(output_eth_src_mac),
    .output_eth_type(output_eth_type),
    .output_eth_payload_tdata(output_eth_payload_tdata),
    .output_eth_payload_tkeep(output_eth_payload_tkeep),
    .output_eth_payload_tvalid(output_eth_payload_tvalid),
    .output_eth_payload_tready(output_eth_payload_tready),
    .output_eth_payload_tlast(output_eth_payload_tlast),
    .output_eth_payload_tuser(output_eth_payload_tuser),
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

