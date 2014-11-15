#!/usr/bin/env python
"""axis_demux_64

Generates an AXI Stream demux with the specified number of ports

Usage: axis_demux_64 [OPTION]...
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
        name = "axis_demux_64_{0}".format(ports)

    if out_name is None:
        out_name = name + ".v"

    print("Opening file '%s'..." % out_name)

    try:
        out_file = open(out_name, 'w')
    except Exception as ex:
        print("Error opening \"%s\": %s" %(out_name, ex.strerror), file=sys.stderr)
        exit(1)

    print("Generating {0} port AXI Stream demux {1}...".format(ports, name))

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
 * AXI4-Stream {{n}} port demultiplexer (64 bit datapath)
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
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_axis_tkeep,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI outputs
     */
{%- for p in ports %}
    output wire [DATA_WIDTH-1:0]  output_{{p}}_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_{{p}}_axis_tkeep,
    output wire                   output_{{p}}_axis_tvalid,
    input  wire                   output_{{p}}_axis_tready,
    output wire                   output_{{p}}_axis_tlast,
    output wire                   output_{{p}}_axis_tuser,
{% endfor %}
    /*
     * Control
     */
    input  wire [{{w-1}}:0]             select
);

reg [{{w-1}}:0] select_reg = 0, select_next;
reg frame_reg = 0, frame_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;

// internal datapath
reg [DATA_WIDTH-1:0] output_axis_tdata_int;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                  output_axis_tvalid_int;
reg                  output_axis_tready_int = 0;
reg                  output_axis_tlast_int;
reg                  output_axis_tuser_int;
wire                 output_axis_tready_int_early;

assign input_axis_tready = input_axis_tready_reg;

// mux for output control signals
reg current_output_tready;
reg current_output_tvalid;
always @* begin
    case (select_reg)
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            current_output_tvalid = output_{{p}}_axis_tvalid;
            current_output_tready = output_{{p}}_axis_tready;
        end
{%- endfor %}
    endcase
end

always @* begin
    select_next = select_reg;
    frame_next = frame_reg;

    input_axis_tready_next = 0;

    if (frame_reg) begin
        if (input_axis_tvalid & input_axis_tready) begin
            // end of frame detection
            frame_next = ~input_axis_tlast;
        end
    end else if (input_axis_tvalid & ~current_output_tvalid) begin
        // start of frame, grab select value
        frame_next = 1;
        select_next = select;
    end

    input_axis_tready_next = output_axis_tready_int_early & frame_next;

    output_axis_tdata_int = input_axis_tdata;
    output_axis_tkeep_int = input_axis_tkeep;
    output_axis_tvalid_int = input_axis_tvalid & input_axis_tready;
    output_axis_tlast_int = input_axis_tlast;
    output_axis_tuser_int = input_axis_tuser;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        select_reg <= 0;
        frame_reg <= 0;
        input_axis_tready_reg <= 0;
    end else begin
        select_reg <= select_next;
        frame_reg <= frame_next;
        input_axis_tready_reg <= input_axis_tready_next;
    end
end

// output datapath logic
reg [DATA_WIDTH-1:0] output_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] output_axis_tkeep_reg = 0;
{%- for p in ports %}
reg                  output_{{p}}_axis_tvalid_reg = 0;
{%- endfor %}
reg                  output_axis_tlast_reg = 0;
reg                  output_axis_tuser_reg = 0;

reg [DATA_WIDTH-1:0] temp_axis_tdata_reg = 0;
reg [KEEP_WIDTH-1:0] temp_axis_tkeep_reg = 0;
reg                  temp_axis_tvalid_reg = 0;
reg                  temp_axis_tlast_reg = 0;
reg                  temp_axis_tuser_reg = 0;
{% for p in ports %}
assign output_{{p}}_axis_tdata = output_axis_tdata_reg;
assign output_{{p}}_axis_tkeep = output_axis_tkeep_reg;
assign output_{{p}}_axis_tvalid = output_{{p}}_axis_tvalid_reg;
assign output_{{p}}_axis_tlast = output_axis_tlast_reg;
assign output_{{p}}_axis_tuser = output_axis_tuser_reg;
{% endfor %}
// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = current_output_tready | (~temp_axis_tvalid_reg & ~current_output_tvalid) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
{%- for p in ports %}
        output_{{p}}_axis_tvalid_reg <= 0;
{%- endfor %}
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
            if (current_output_tready | ~current_output_tvalid) begin
                // output is ready or currently not valid, transfer data to output
                output_axis_tdata_reg <= output_axis_tdata_int;
                output_axis_tkeep_reg <= output_axis_tkeep_int;
                case (select_reg)
{%- for p in ports %}
                    {{w}}'d{{p}}: output_{{p}}_axis_tvalid_reg <= output_axis_tvalid_int;
{%- endfor %}
                endcase
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
        end else if (current_output_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            case (select_reg)
{%- for p in ports %}
                {{w}}'d{{p}}: output_{{p}}_axis_tvalid_reg <= temp_axis_tvalid_reg;
{%- endfor %}
            endcase
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

