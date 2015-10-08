#!/usr/bin/env python
"""axis_frame_join

Generates an AXI Stream frame join module with a specific number of input ports

Usage: axis_frame_join [OPTION]...
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
        name = "axis_frame_join_{0}".format(ports)
    
    if out_name is None:
        out_name = name + ".v"
    
    print("Opening file '%s'..." % out_name)
    
    try:
        out_file = open(out_name, 'w')
    except Exception as ex:
        print("Error opening \"%s\": %s" %(out_name, ex.strerror), file=sys.stderr)
        exit(1)
    
    print("Generating {0} port AXI Stream frame joiner {1}...".format(ports, name))
    
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
 * AXI4-Stream {{n}} port frame joiner
 */
module {{name}} #
(
    parameter TAG_ENABLE = 1,
    parameter TAG_WIDTH = 16
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI inputs
     */
{%- for p in ports %}
    input  wire [7:0]  input_{{p}}_axis_tdata,
    input  wire        input_{{p}}_axis_tvalid,
    output wire        input_{{p}}_axis_tready,
    input  wire        input_{{p}}_axis_tlast,
    input  wire        input_{{p}}_axis_tuser,
{% endfor %}
    /*
     * AXI output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Configuration
     */
    input  wire [TAG_WIDTH-1:0] tag,

    /*
     * Status signals
     */
    output wire        busy
);

localparam TAG_BYTE_WIDTH = (TAG_WIDTH + 7) / 8;

// state register
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_WRITE_TAG = 2'd1,
    STATE_TRANSFER = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [2:0] frame_ptr_reg = 0, frame_ptr_next;
reg [{{w-1}}:0] port_sel_reg = 0, port_sel_next;

reg busy_reg = 0, busy_next;

reg [7:0] input_tdata;
reg input_tvalid;
reg input_tlast;
reg input_tuser;

reg output_tuser_reg = 0, output_tuser_next;
{% for p in ports %}
reg input_{{p}}_axis_tready_reg = 0, input_{{p}}_axis_tready_next;
{%- endfor %}

// internal datapath
reg [7:0] output_axis_tdata_int;
reg       output_axis_tvalid_int;
reg       output_axis_tready_int = 0;
reg       output_axis_tlast_int;
reg       output_axis_tuser_int;
wire      output_axis_tready_int_early;
{% for p in ports %}
assign input_{{p}}_axis_tready = input_{{p}}_axis_tready_reg;
{%- endfor %}

assign busy = busy_reg;

always @* begin
    // input port mux
    case (port_sel_reg)
{%- for p in ports %}
        {{w}}'d{{p}}: begin
            input_tdata = input_{{p}}_axis_tdata;
            input_tvalid = input_{{p}}_axis_tvalid;
            input_tlast = input_{{p}}_axis_tlast;
            input_tuser = input_{{p}}_axis_tuser;
        end
{%- endfor %}
    endcase
end

integer offset, i;

always @* begin
    state_next = 2'bz;

    frame_ptr_next = frame_ptr_reg;
    port_sel_next = port_sel_reg;
{% for p in ports %}
    input_{{p}}_axis_tready_next = 0;
{%- endfor %}

    output_axis_tdata_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    output_tuser_next = output_tuser_reg;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            frame_ptr_next = 0;
            port_sel_next = 0;
            output_tuser_next = 0;

            if (TAG_ENABLE) begin
                // next cycle if started will send tag, so do not enable input
                input_0_axis_tready_next = 0;
            end else begin
                // next cycle if started will send data, so enable input
                input_0_axis_tready_next = output_axis_tready_int_early;
            end
            
            if (input_0_axis_tvalid) begin
                // input 0 valid; start transferring data
                if (TAG_ENABLE) begin
                    // tag enabled, so transmit it
                    if (output_axis_tready_int) begin
                        // output is ready, so short-circuit first tag byte
                        frame_ptr_next = 1;
                        output_axis_tdata_int = tag[(TAG_BYTE_WIDTH-1)*8 +: 8];
                        output_axis_tvalid_int = 1;
                    end
                    state_next = STATE_WRITE_TAG;
                end else begin
                    // tag disabled, so transmit data
                    if (output_axis_tready_int) begin
                        // output is ready, so short-circuit first data byte
                        output_axis_tdata_int = input_0_axis_tdata;
                        output_axis_tvalid_int = 1;
                    end
                    state_next = STATE_TRANSFER;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_WRITE_TAG: begin
            // write tag data
            if (output_axis_tready_int) begin
                // output ready, so send tag byte
                state_next = STATE_WRITE_TAG;
                frame_ptr_next = frame_ptr_reg + 1;
                output_axis_tvalid_int = 1;

                offset = 0;
                if (TAG_ENABLE) begin
                    for (i = TAG_BYTE_WIDTH-1; i >= 0; i = i - 1) begin
                        if (frame_ptr_reg == offset) begin
                            output_axis_tdata_int = tag[i*8 +: 8];
                        end
                        offset = offset + 1;
                    end
                end
                if (frame_ptr_reg == offset-1) begin
                    input_0_axis_tready_next = output_axis_tready_int_early;
                    state_next = STATE_TRANSFER;
                end
            end else begin
                state_next = STATE_WRITE_TAG;
            end
        end
        STATE_TRANSFER: begin
            // transfer input data

            // set ready for current input
            case (port_sel_reg)
{%- for p in ports %}
                {{w}}'d{{p}}: input_{{p}}_axis_tready_next = output_axis_tready_int_early;
{%- endfor %}
            endcase

            if (input_tvalid & output_axis_tready_int) begin
                // output ready, transfer byte
                state_next = STATE_TRANSFER;
                output_axis_tdata_int = input_tdata;
                output_axis_tvalid_int = input_tvalid;

                if (input_tlast) begin
                    // last flag received, switch to next port
                    port_sel_next = port_sel_reg + 1;
                    // save tuser - assert tuser out if ANY tuser asserts received
                    output_tuser_next = output_tuser_next | input_tuser;
                    // disable input
{%- for p in ports %}
                    input_{{p}}_axis_tready_next = 0;
{%- endfor %}

                    if (port_sel_reg == {{n-1}}) begin
                        // last port - send tlast and tuser and revert to idle
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = output_tuser_next;
                        state_next = STATE_IDLE;
                    end else begin
                        // otherwise, disable enable next port
                        case (port_sel_next)
{%- for p in ports %}
                            {{w}}'d{{p}}: input_{{p}}_axis_tready_next = output_axis_tready_int_early;
{%- endfor %}
                        endcase
                    end
                end
            end else begin
                state_next = STATE_TRANSFER;
            end 
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        frame_ptr_reg <= 0;
        port_sel_reg <= 0;
{%- for p in ports %}
        input_{{p}}_axis_tready_reg <= 0;
{%- endfor %}
        output_tuser_reg <= 0;
        busy_reg <= 0;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        port_sel_reg <= port_sel_next;
{% for p in ports %}
        input_{{p}}_axis_tready_reg <= input_{{p}}_axis_tready_next;
{%- endfor %}

        output_tuser_reg <= output_tuser_next;

        busy_reg <= state_next != STATE_IDLE;
    end
end

// output datapath logic
reg [7:0] output_axis_tdata_reg = 0;
reg       output_axis_tvalid_reg = 0;
reg       output_axis_tlast_reg = 0;
reg       output_axis_tuser_reg = 0;

reg [7:0] temp_axis_tdata_reg = 0;
reg       temp_axis_tvalid_reg = 0;
reg       temp_axis_tlast_reg = 0;
reg       temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
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
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
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

