#!/usr/bin/env python
"""
Generates an AXI Stream frame joiner wrapper with the specified number of ports
"""

import argparse
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
    n = ports

    if name is None:
        name = "axis_frame_join_wrap_{0}".format(n)

    if output is None:
        output = name + ".v"

    print("Generating {0} port AXI stream frame joiner wrapper {1}...".format(n, name))

    cn = (n-1).bit_length()

    t = Template(u"""/*

Copyright (c) 2018-2021 Alex Forencich

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

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4-Stream {{n}} port frame joiner (wrapper)
 */
module {{name}} #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Prepend data with tag
    parameter TAG_ENABLE = 1,
    // Tag field width
    parameter TAG_WIDTH = 16
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * AXI Stream inputs
     */
{%- for p in range(n) %}
    input  wire [DATA_WIDTH-1:0] s{{'%02d'%p}}_axis_tdata,
    input  wire                  s{{'%02d'%p}}_axis_tvalid,
    output wire                  s{{'%02d'%p}}_axis_tready,
    input  wire                  s{{'%02d'%p}}_axis_tlast,
    input  wire                  s{{'%02d'%p}}_axis_tuser,
{% endfor %}
    /*
     * AXI Stream output
     */
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,
    output wire                  m_axis_tuser,

    /*
     * Configuration
     */
    input  wire [TAG_WIDTH-1:0]  tag,

    /*
     * Status signals
     */
    output wire                  busy
);

axis_frame_join #(
    .S_COUNT({{n}}),
    .DATA_WIDTH(DATA_WIDTH),
    .TAG_ENABLE(TAG_ENABLE),
    .TAG_WIDTH(TAG_WIDTH)
)
axis_frame_join_inst (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tdata({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tvalid({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tready({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tlast({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tuser({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tuser{% if not loop.last %}, {% endif %}{% endfor %} }),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    // Configuration
    .tag(tag),
    // Status
    .busy(busy)
);

endmodule

`resetall

""")

    print(f"Writing file '{output}'...")

    with open(output, 'w') as f:
        f.write(t.render(
            n=n,
            cn=cn,
            name=name
        ))
        f.flush()

    print("Done")


if __name__ == "__main__":
    main()
