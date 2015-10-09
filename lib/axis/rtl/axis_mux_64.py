#!/usr/bin/env python
"""axis_mux_64

Generates an AXI Stream mux with the specified number of ports

Usage: axis_mux_64 [OPTION]...
  -?, --help     display this help and exit
  -p, --ports    specify number of ports
  -n, --name     specify module name
  -o, --output   specify output file name
"""

from __future__ import print_function

import io
import sys
import getopt
import math
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
        name = "axis_mux_64_{0}".format(ports)

    if out_name is None:
        out_name = name + ".v"

    print("Opening file '%s'..." % out_name)

    try:
        out_file = open(out_name, 'w')
    except Exception as ex:
        print("Error opening \"%s\": %s" %(out_name, ex.strerror), file=sys.stderr)
        exit(1)

    print("Generating {0} port AXI Stream mux {1}...".format(ports, name))

    select_width = int(math.ceil(math.log(ports, 2)))

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
 * AXI4-Stream {{n}} port multiplexer (64 bit datapath)
 */
module {{name}} #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
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
    output wire                   output_axis_tuser,

    /*
     * Control
     */
    input  wire                   enable,
    input  wire [{{w-1}}:0]             select
);

reg [{{w-1}}:0] select_reg = 0, select_next;
reg frame_reg = 0, frame_next;
{% for p in ports %}
reg input_{{p}}_axis_tready_reg = 0, input_{{p}}_axis_tready_next;
{%- endfor %}

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int = 0;
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
    endcase
end

// mux for incoming packet
reg [DATA_WIDTH-1:0] current_input_tdata;
reg [KEEP_WIDTH-1:0] current_input_tkeep;
reg current_input_tvalid;
reg current_input_tready;
reg current_input_tlast;
reg current_input_tuser;
always @* begin
    case (select_reg)
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            current_input_tdata = input_{{p}}_axis_tdata;
            current_input_tkeep = input_{{p}}_axis_tkeep;
            current_input_tvalid = input_{{p}}_axis_tvalid;
            current_input_tready = input_{{p}}_axis_tready;
            current_input_tlast = input_{{p}}_axis_tlast;
            current_input_tuser = input_{{p}}_axis_tuser;
        end
{%- endfor %}
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;
{% for p in ports %}
    input_{{p}}_axis_tready_next = 0;
{%- endfor %}

    if (frame_reg) begin
        if (current_input_tvalid & current_input_tready) begin
            // end of frame detection
            frame_next = ~current_input_tlast;
        end
    end else if (enable & selected_input_tvalid) begin
        // start of frame, grab select value
        frame_next = 1;
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
    output_axis_tkeep_int = current_input_tkeep;
    output_axis_tvalid_int = current_input_tvalid & current_input_tready & frame_reg;
    output_axis_tlast_int = current_input_tlast;
    output_axis_tuser_int = current_input_tuser;
end

always @(posedge clk) begin
    if (rst) begin
        select_reg <= 0;
        frame_reg <= 0;
{%- for p in ports %}
        input_{{p}}_axis_tready_reg <= 0;
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
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg = 0;
reg                  output_axis_tvalid_reg = 0;
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg = 0;
reg                  temp_axis_tvalid_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tkeep_reg <= 0;
        temp_axis_tvalid_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
    end else begin
        // transfer sink ready state to source
        output_axis_tready_int <= output_axis_tready_int_early;

        if (output_axis_tready_int) begin
            // input is ready
            if (output_axis_tready | ~output_axis_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                output_axis_tdata_reg <= output_axis_tdata_int;
                output_axis_tkeep_reg <= output_axis_tkeep_int;
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tkeep_reg <= output_axis_tkeep_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
            temp_axis_tkeep_reg <= 0;
            temp_axis_tvalid_reg <= 0;
            temp_axis_tlast_reg <= 0;
            temp_axis_tuser_reg <= 0;
        end
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

