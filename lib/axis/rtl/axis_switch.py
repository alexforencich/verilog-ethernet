#!/usr/bin/env python
"""
Generates an AXI Stream switch with the specified number of ports
"""

from __future__ import print_function

import argparse
import math
from jinja2 import Template

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=[4], nargs='+', help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(ports=4, name=None, output=None):
    if type(ports) is int:
        m = n = ports
    elif len(ports) == 1:
        m = n = ports[0]
    else:
        m, n = ports

    if name is None:
        name = "axis_switch_{0}x{1}".format(m, n)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0}x{1} port AXI Stream switch {2}...".format(m, n, name))

    cm = int(math.ceil(math.log(m, 2)))
    cn = int(math.ceil(math.log(n, 2)))

    t = Template(u"""/*

Copyright (c) 2016 Alex Forencich

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
 * AXI4-Stream {{m}}x{{n}} switch
 */
module {{name}} #
(
    parameter DATA_WIDTH = 8,
    parameter DEST_WIDTH = {{cn}},
{%- for p in range(n) %}
    parameter OUT_{{p}}_BASE = {{p}},
    parameter OUT_{{p}}_TOP = {{p}},
    parameter OUT_{{p}}_CONNECT = {{m}}'b{% for p in range(m) %}1{% endfor %},
{%- endfor %}
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter ARB_TYPE = "ROUND_ROBIN",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "HIGH"
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI Stream inputs
     */
{%- for p in range(m) %}
    input  wire [DATA_WIDTH-1:0]  input_{{p}}_axis_tdata,
    input  wire                   input_{{p}}_axis_tvalid,
    output wire                   input_{{p}}_axis_tready,
    input  wire                   input_{{p}}_axis_tlast,
    input  wire [DEST_WIDTH-1:0]  input_{{p}}_axis_tdest,
    input  wire                   input_{{p}}_axis_tuser,
{% endfor %}
    /*
     * AXI Stream outputs
     */
{%- for p in range(n) %}
    output wire [DATA_WIDTH-1:0]  output_{{p}}_axis_tdata,
    output wire                   output_{{p}}_axis_tvalid,
    input  wire                   output_{{p}}_axis_tready,
    output wire                   output_{{p}}_axis_tlast,
    output wire [DEST_WIDTH-1:0]  output_{{p}}_axis_tdest,
    output wire                   output_{{p}}_axis_tuser{% if not loop.last %},{% endif %}
{% endfor -%}
);

// check configuration
initial begin
    if (2**DEST_WIDTH < {{n}}) begin
        $error("Error: DEST_WIDTH too small for port count");
        $finish;
    end

    if ({%- for p in range(n) %}(OUT_{{p}}_BASE & 2**DEST_WIDTH-1) != OUT_{{p}}_BASE || (OUT_{{p}}_TOP & 2**DEST_WIDTH-1) != OUT_{{p}}_TOP{% if not loop.last %} ||
        {% endif %}{% endfor -%}) begin
        $error("Error: value out of range");
        $finish;
    end

    if ({%- for p in range(n) %}OUT_{{p}}_BASE > OUT_{{p}}_TOP{% if not loop.last %} ||
        {% endif %}{% endfor -%}) begin
        $error("Error: invalid range");
        $finish;
    end

    if ({%- for p in range(n-1) %}{% set outer_loop = loop %}{%- for q in range(p+1,n) %}(OUT_{{p}}_BASE <= OUT_{{q}}_TOP && OUT_{{q}}_BASE <= OUT_{{p}}_TOP){% if not (loop.last and outer_loop.last) %} ||
        {% endif %}{% endfor -%}{% endfor -%}) begin
        $error("Error: ranges overlap");
        $finish;
    end
end
{%- for p in range(m) %}

reg [{{n-1}}:0] input_{{p}}_request_reg = {{n}}'d0, input_{{p}}_request_next;
reg input_{{p}}_request_valid_reg = 1'b0, input_{{p}}_request_valid_next;
reg input_{{p}}_request_error_reg = 1'b0, input_{{p}}_request_error_next;
{%- endfor %}
{% for p in range(n) %}
reg [{{cm-1}}:0] select_{{p}}_reg = {{cm}}'d0, select_{{p}}_next;
{%- endfor %}
{% for p in range(n) %}
reg enable_{{p}}_reg = 1'b0, enable_{{p}}_next;
{%- endfor %}
{% for p in range(m) %}
reg input_{{p}}_axis_tready_reg = 1'b0, input_{{p}}_axis_tready_next;
{%- endfor %}

// internal datapath
{%- for p in range(n) %}
reg [DATA_WIDTH-1:0] output_{{p}}_axis_tdata_int;
reg                  output_{{p}}_axis_tvalid_int;
reg                  output_{{p}}_axis_tready_int_reg = 1'b0;
reg                  output_{{p}}_axis_tlast_int;
reg [DEST_WIDTH-1:0] output_{{p}}_axis_tdest_int;
reg                  output_{{p}}_axis_tuser_int;
wire                 output_{{p}}_axis_tready_int_early;
{% endfor %}
{%- for p in range(m) %}
assign input_{{p}}_axis_tready = input_{{p}}_axis_tready_reg;
{%- endfor %}

// mux for incoming packet
{% for p in range(n) %}
reg [DATA_WIDTH-1:0] current_input_{{p}}_axis_tdata;
reg current_input_{{p}}_axis_tvalid;
reg current_input_{{p}}_axis_tready;
reg current_input_{{p}}_axis_tlast;
reg [DEST_WIDTH-1:0] current_input_{{p}}_axis_tdest;
reg current_input_{{p}}_axis_tuser;

always @* begin
    case (select_{{p}}_reg)
{%- for q in range(m) %}
        {{cm}}'d{{q}}: begin
            current_input_{{p}}_axis_tdata = input_{{q}}_axis_tdata;
            current_input_{{p}}_axis_tvalid = input_{{q}}_axis_tvalid;
            current_input_{{p}}_axis_tready = input_{{q}}_axis_tready;
            current_input_{{p}}_axis_tlast = input_{{q}}_axis_tlast;
            current_input_{{p}}_axis_tdest = input_{{q}}_axis_tdest;
            current_input_{{p}}_axis_tuser = input_{{q}}_axis_tuser;
        end
{%- endfor %}
        default: begin
            current_input_{{p}}_axis_tdata = {DATA_WIDTH{1'b0}};
            current_input_{{p}}_axis_tvalid = 1'b0;
            current_input_{{p}}_axis_tready = 1'b0;
            current_input_{{p}}_axis_tlast = 1'b0;
            current_input_{{p}}_axis_tdest = {DEST_WIDTH{1'b0}};
            current_input_{{p}}_axis_tuser = 1'b0;
        end
    endcase
end
{% endfor %}
// arbiter instances
{% for p in range(n) %}
wire [{{m-1}}:0] request_{{p}};
wire [{{m-1}}:0] acknowledge_{{p}};
wire [{{m-1}}:0] grant_{{p}};
wire grant_valid_{{p}};
wire [{{cm-1}}:0] grant_encoded_{{p}};
{% endfor %}

{%- for p in range(n) %}
arbiter #(
    .PORTS({{m}}),
    .TYPE(ARB_TYPE),
    .BLOCK("ACKNOWLEDGE"),
    .LSB_PRIORITY(LSB_PRIORITY)
)
arb_{{p}}_inst (
    .clk(clk),
    .rst(rst),
    .request(request_{{p}}),
    .acknowledge(acknowledge_{{p}}),
    .grant(grant_{{p}}),
    .grant_valid(grant_valid_{{p}}),
    .grant_encoded(grant_encoded_{{p}})
);
{% endfor %}
// request generation
{%- for p in range(n) %}
{%- for q in range(m) %}
assign request_{{p}}[{{q}}] = input_{{q}}_request_reg[{{p}}] & ~acknowledge_{{p}}[{{q}}];
{%- endfor %}
{% endfor %}
// acknowledge generation
{%- for p in range(n) %}
{%- for q in range(m) %}
assign acknowledge_{{p}}[{{q}}] = grant_{{p}}[{{q}}] & input_{{q}}_axis_tvalid & input_{{q}}_axis_tready & input_{{q}}_axis_tlast;
{%- endfor %}
{% endfor %}
always @* begin
{%- for p in range(n) %}
    select_{{p}}_next = select_{{p}}_reg;
{%- endfor %}
{% for p in range(n) %}
    enable_{{p}}_next = enable_{{p}}_reg;
{%- endfor %}
{% for p in range(m) %}
    input_{{p}}_request_next = input_{{p}}_request_reg;
    input_{{p}}_request_valid_next = input_{{p}}_request_valid_reg;
    input_{{p}}_request_error_next = input_{{p}}_request_error_reg;
{% endfor %}
{%- for p in range(m) %}
    input_{{p}}_axis_tready_next = 1'b0;
{%- endfor %}
{% for p in range(n) %}
    output_{{p}}_axis_tdata_int = {DATA_WIDTH{1'b0}};
    output_{{p}}_axis_tvalid_int = 1'b0;
    output_{{p}}_axis_tlast_int = 1'b0;
    output_{{p}}_axis_tdest_int = {DEST_WIDTH{1'b0}};
    output_{{p}}_axis_tuser_int = 1'b0;
{% endfor %}
    // input decoding
{% for p in range(m) %}
    if (input_{{p}}_request_valid_reg | input_{{p}}_request_error_reg) begin
        if (input_{{p}}_axis_tvalid & input_{{p}}_axis_tready & input_{{p}}_axis_tlast) begin
            input_{{p}}_request_next = {DEST_WIDTH{1'b0}};
            input_{{p}}_request_valid_next = 1'b0;
            input_{{p}}_request_error_next = 1'b0;
        end
    end else if (input_{{p}}_axis_tvalid) begin
{%- for q in range(n) %}
        input_{{p}}_request_next[{{q}}] = (input_{{p}}_axis_tdest >= OUT_{{q}}_BASE) & (input_{{p}}_axis_tdest <= OUT_{{q}}_TOP) & OUT_{{q}}_CONNECT[{{p}}];
{%- endfor %}

        if (input_{{p}}_request_next) begin
            input_{{p}}_request_valid_next = 1'b1;
        end else begin
            input_{{p}}_request_error_next = 1'b1;
        end
    end
{% endfor %}
    // output control
{% for p in range(n) %}
    if (current_input_{{p}}_axis_tvalid & current_input_{{p}}_axis_tready) begin
        if (current_input_{{p}}_axis_tlast) begin
            enable_{{p}}_next = 1'b0;
        end
    end
    if (~enable_{{p}}_reg & grant_valid_{{p}}) begin
        enable_{{p}}_next = 1'b1;
        select_{{p}}_next = grant_encoded_{{p}};
    end
{% endfor %}
    // generate ready signal on selected port
{% for p in range(n) %}
    if (enable_{{p}}_next) begin
        case (select_{{p}}_next)
{%- for q in range(m) %}
            {{cm}}'d{{q}}: input_{{q}}_axis_tready_next = output_{{p}}_axis_tready_int_early;
{%- endfor %}
        endcase
    end
{% endfor %}

{%- for p in range(m) %}
    if (input_{{p}}_request_error_next)
        input_{{p}}_axis_tready_next = 1'b1;
{%- endfor %}

    // pass through selected packet data
{% for p in range(n) %}
    output_{{p}}_axis_tdata_int = current_input_{{p}}_axis_tdata;
    output_{{p}}_axis_tvalid_int = current_input_{{p}}_axis_tvalid & current_input_{{p}}_axis_tready & enable_{{p}}_reg;
    output_{{p}}_axis_tlast_int = current_input_{{p}}_axis_tlast;
    output_{{p}}_axis_tdest_int = current_input_{{p}}_axis_tdest;
    output_{{p}}_axis_tuser_int = current_input_{{p}}_axis_tuser;
{% endfor -%}
end

always @(posedge clk) begin
    if (rst) begin
{%- for p in range(m) %}
        input_{{p}}_request_reg <= {{n}}'d0;
        input_{{p}}_request_valid_reg <= 1'b0;
        input_{{p}}_request_error_reg <= 1'b0;
{%- endfor %}
{%- for p in range(n) %}
        select_{{p}}_reg <= 2'd0;
{%- endfor %}
{%- for p in range(n) %}
        enable_{{p}}_reg <= 1'b0;
{%- endfor %}
{%- for p in range(m) %}
        input_{{p}}_axis_tready_reg <= 1'b0;
{%- endfor %}
    end else begin
{%- for p in range(m) %}
        input_{{p}}_request_reg <= input_{{p}}_request_next;
        input_{{p}}_request_valid_reg <= input_{{p}}_request_valid_next;
        input_{{p}}_request_error_reg <= input_{{p}}_request_error_next;
{%- endfor %}
{%- for p in range(n) %}
        select_{{p}}_reg <= select_{{p}}_next;
{%- endfor %}
{%- for p in range(n) %}
        enable_{{p}}_reg <= enable_{{p}}_next;
{%- endfor %}
{%- for p in range(m) %}
        input_{{p}}_axis_tready_reg <= input_{{p}}_axis_tready_next;
{%- endfor %}
    end
end
{% for p in range(n) %}
// output {{p}} datapath logic
reg [DATA_WIDTH-1:0] output_{{p}}_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  output_{{p}}_axis_tvalid_reg = 1'b0, output_{{p}}_axis_tvalid_next;
reg                  output_{{p}}_axis_tlast_reg = 1'b0;
reg [DEST_WIDTH-1:0] output_{{p}}_axis_tdest_reg = {DEST_WIDTH{1'b0}};
reg                  output_{{p}}_axis_tuser_reg = 1'b0;

reg [DATA_WIDTH-1:0] temp_{{p}}_axis_tdata_reg = {DATA_WIDTH{1'b0}};
reg                  temp_{{p}}_axis_tvalid_reg = 1'b0, temp_{{p}}_axis_tvalid_next;
reg                  temp_{{p}}_axis_tlast_reg = 1'b0;
reg [DEST_WIDTH-1:0] temp_{{p}}_axis_tdest_reg = {DEST_WIDTH{1'b0}};
reg                  temp_{{p}}_axis_tuser_reg = 1'b0;

// datapath control
reg store_{{p}}_axis_int_to_output;
reg store_{{p}}_axis_int_to_temp;
reg store_{{p}}_axis_temp_to_output;

assign output_{{p}}_axis_tdata = output_{{p}}_axis_tdata_reg;
assign output_{{p}}_axis_tvalid = output_{{p}}_axis_tvalid_reg;
assign output_{{p}}_axis_tlast = output_{{p}}_axis_tlast_reg;
assign output_{{p}}_axis_tdest = output_{{p}}_axis_tdest_reg;
assign output_{{p}}_axis_tuser = output_{{p}}_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_{{p}}_axis_tready_int_early = output_{{p}}_axis_tready | (~temp_{{p}}_axis_tvalid_reg & (~output_{{p}}_axis_tvalid_reg | ~output_{{p}}_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_{{p}}_axis_tvalid_next = output_{{p}}_axis_tvalid_reg;
    temp_{{p}}_axis_tvalid_next = temp_{{p}}_axis_tvalid_reg;

    store_{{p}}_axis_int_to_output = 1'b0;
    store_{{p}}_axis_int_to_temp = 1'b0;
    store_{{p}}_axis_temp_to_output = 1'b0;
    
    if (output_{{p}}_axis_tready_int_reg) begin
        // input is ready
        if (output_{{p}}_axis_tready | ~output_{{p}}_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_{{p}}_axis_tvalid_next = output_{{p}}_axis_tvalid_int;
            store_{{p}}_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_{{p}}_axis_tvalid_next = output_{{p}}_axis_tvalid_int;
            store_{{p}}_axis_int_to_temp = 1'b1;
        end
    end else if (output_{{p}}_axis_tready) begin
        // input is not ready, but output is ready
        output_{{p}}_axis_tvalid_next = temp_{{p}}_axis_tvalid_reg;
        temp_{{p}}_axis_tvalid_next = 1'b0;
        store_{{p}}_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_{{p}}_axis_tvalid_reg <= 1'b0;
        output_{{p}}_axis_tready_int_reg <= 1'b0;
        temp_{{p}}_axis_tvalid_reg <= 1'b0;
    end else begin
        output_{{p}}_axis_tvalid_reg <= output_{{p}}_axis_tvalid_next;
        output_{{p}}_axis_tready_int_reg <= output_{{p}}_axis_tready_int_early;
        temp_{{p}}_axis_tvalid_reg <= temp_{{p}}_axis_tvalid_next;
    end

    // datapath
    if (store_{{p}}_axis_int_to_output) begin
        output_{{p}}_axis_tdata_reg <= output_{{p}}_axis_tdata_int;
        output_{{p}}_axis_tlast_reg <= output_{{p}}_axis_tlast_int;
        output_{{p}}_axis_tdest_reg <= output_{{p}}_axis_tdest_int;
        output_{{p}}_axis_tuser_reg <= output_{{p}}_axis_tuser_int;
    end else if (store_{{p}}_axis_temp_to_output) begin
        output_{{p}}_axis_tdata_reg <= temp_{{p}}_axis_tdata_reg;
        output_{{p}}_axis_tlast_reg <= temp_{{p}}_axis_tlast_reg;
        output_{{p}}_axis_tdest_reg <= temp_{{p}}_axis_tdest_reg;
        output_{{p}}_axis_tuser_reg <= temp_{{p}}_axis_tuser_reg;
    end

    if (store_{{p}}_axis_int_to_temp) begin
        temp_{{p}}_axis_tdata_reg <= output_{{p}}_axis_tdata_int;
        temp_{{p}}_axis_tlast_reg <= output_{{p}}_axis_tlast_int;
        temp_{{p}}_axis_tdest_reg <= output_{{p}}_axis_tdest_int;
        temp_{{p}}_axis_tuser_reg <= output_{{p}}_axis_tuser_int;
    end
end
{% endfor %}
endmodule

""")
    
    output_file.write(t.render(
        m=m,
        n=n,
        cm=cm,
        cn=cn,
        name=name
    ))
    
    print("Done")

if __name__ == "__main__":
    main()

