#!/usr/bin/env python
"""axis_crosspoint

Generates an AXI Stream crosspoint switch with the specified number of ports

Usage: axis_crosspoint [OPTION]...
  -?, --help     display this help and exit
  -p, --ports    specify number of ports
  -n, --name     specify module name
  -o, --output   specify output file name
"""

import io
import sys
import getopt
from math import *
from jinja2 import Template

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def main(argv=None):
    if argv is None:
        argv = sys.argv
    try:
        try:
            opts, args = getopt.getopt(argv[1:], "?n:p:o:", ["help", "name=", "ports=", "output="])
        except getopt.error as msg:
             raise Usage(msg)
        # more code, unchanged  
    except Usage as err:
        print(err.msg, file=sys.stderr)
        print("for help use --help", file=sys.stderr)
        return 2

    ports = 4
    name = None
    out_name = None

    # process options
    for o, a in opts:
        if o in ('-?', '--help'):
            print(__doc__)
            sys.exit(0)
        if o in ('-p', '--ports'):
            ports = int(a)
        if o in ('-n', '--name'):
            name = a
        if o in ('-o', '--output'):
            out_name = a

    if name is None:
        name = "axis_crosspoint_{0}x{0}".format(ports)

    if out_name is None:
        out_name = name + ".v"

    print("Opening file '%s'..." % out_name)

    try:
        out_file = open(out_name, 'w')
    except Exception as ex:
        print("Error opening \"%s\": %s" %(out_name, ex.strerror), file=sys.stderr)
        exit(1)

    print("Generating {0} port AXI Stream crosspoint {1}...".format(ports, name))

    select_width = ceil(log2(ports))

    t = Template(u"""/*

Copyright (c) 2014 Alex Forencich

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
 * AXI4-Stream {{n}}x{{n}} crosspoint
 */
module {{name}} #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI Stream inputs
     */
{%- for p in ports %}
    input  wire [DATA_WIDTH-1:0]  input_{{p}}_axis_tdata,
    input  wire                   input_{{p}}_axis_tvalid,
    input  wire                   input_{{p}}_axis_tlast,
    input  wire                   input_{{p}}_axis_tuser,
{% endfor %}
    /*
     * AXI Stream outputs
     */
{%- for p in ports %}
    output wire [DATA_WIDTH-1:0]  output_{{p}}_axis_tdata,
    output wire                   output_{{p}}_axis_tvalid,
    output wire                   output_{{p}}_axis_tlast,
    output wire                   output_{{p}}_axis_tuser,
{% endfor %}
    /*
     * Control
     */
{%- for p in ports %}
    input  wire [{{w-1}}:0]             output_{{p}}_select{% if not loop.last %},{% endif %}
{%- endfor %}
);
{% for p in ports %}
reg [DATA_WIDTH-1:0]  input_{{p}}_axis_tdata_reg = 0;
reg                   input_{{p}}_axis_tvalid_reg = 0;
reg                   input_{{p}}_axis_tlast_reg = 0;
reg                   input_{{p}}_axis_tuser_reg = 0;
{% endfor %}

{%- for p in ports %}
reg [DATA_WIDTH-1:0]  output_{{p}}_axis_tdata_reg = 0;
reg                   output_{{p}}_axis_tvalid_reg = 0;
reg                   output_{{p}}_axis_tlast_reg = 0;
reg                   output_{{p}}_axis_tuser_reg = 0;
{% endfor %}

{%- for p in ports %}
reg [{{w-1}}:0]             output_{{p}}_select_reg = 0;
{%- endfor %}
{% for p in ports %}
assign output_{{p}}_axis_tdata = output_{{p}}_axis_tdata_reg;
assign output_{{p}}_axis_tvalid = output_{{p}}_axis_tvalid_reg;
assign output_{{p}}_axis_tlast = output_{{p}}_axis_tlast_reg;
assign output_{{p}}_axis_tuser = output_{{p}}_axis_tuser_reg;
{% endfor %}

always @(posedge clk or posedge rst) begin
    if (rst) begin
{%- for p in ports %}
        output_{{p}}_select_reg <= 0;
{%- endfor %}
{% for p in ports %}
        input_{{p}}_axis_tdata_reg <= 0;
        input_{{p}}_axis_tvalid_reg <= 0;
        input_{{p}}_axis_tlast_reg <= 0;
        input_{{p}}_axis_tuser_reg <= 0;
{%- endfor %}
{% for p in ports %}
        output_{{p}}_axis_tdata_reg <= 0;
        output_{{p}}_axis_tvalid_reg <= 0;
        output_{{p}}_axis_tlast_reg <= 0;
        output_{{p}}_axis_tuser_reg <= 0;
{%- endfor %}
    end else begin
{%- for p in ports %}
        input_{{p}}_axis_tdata_reg <= input_{{p}}_axis_tdata;
        input_{{p}}_axis_tvalid_reg <= input_{{p}}_axis_tvalid;
        input_{{p}}_axis_tlast_reg <= input_{{p}}_axis_tlast;
        input_{{p}}_axis_tuser_reg <= input_{{p}}_axis_tuser;
{% endfor %}
{%- for p in ports %}
        output_{{p}}_select_reg <= output_{{p}}_select;
{%- endfor %}
{%- for p in ports %}

        case (output_{{p}}_select_reg)
{%- for q in ports %}
            {{w}}'d{{q}}: begin
                output_{{p}}_axis_tdata_reg <= input_{{q}}_axis_tdata_reg;
                output_{{p}}_axis_tvalid_reg <= input_{{q}}_axis_tvalid_reg;
                output_{{p}}_axis_tlast_reg <= input_{{q}}_axis_tlast_reg;
                output_{{p}}_axis_tuser_reg <= input_{{q}}_axis_tuser_reg;
            end
{%- endfor %}
        endcase
{%- endfor %}
    end
end

endmodule

""")
    
    out_file.write(t.render(
        n=ports,
        w=select_width,
        name=name,
        ports=range(ports)
    ))
    
    print("Done")

if __name__ == "__main__":
    sys.exit(main())

