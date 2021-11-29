#!/usr/bin/env python
"""
Generates an AXI Stream switch wrapper with the specified number of ports
"""

import argparse
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
        name = "axis_ram_switch_wrap_{0}x{1}".format(m, n)

    if output is None:
        output = name + ".v"

    print("Generating {0}x{1} port AXI stream RAM switch wrapper {2}...".format(m, n, name))

    cm = (m-1).bit_length()
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
 * AXI4-Stream {{m}}x{{n}} RAM switch (wrapper)
 */
module {{name}} #
(
    // FIFO depth in words (each virtual FIFO)
    // KEEP_WIDTH words per cycle if KEEP_ENABLE set
    // Rounded up to nearest power of 2 cycles
    parameter FIFO_DEPTH = 4096,
    // Command FIFO depth (each virtual FIFO)
    // Rounded up to nearest power of 2
    parameter CMD_FIFO_DEPTH = 32,
    // Speedup factor (internal data width scaling factor)
    // Speedup of 0 scales internal width to provide maximum bandwidth
    parameter SPEEDUP = 0,
    // Width of input AXI stream interfaces in bits
    parameter S_DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8),
    // Width of output AXI stream interfaces in bits
    parameter M_DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // input tid signal width
    parameter S_ID_WIDTH = 8,
    // output tid signal width
    parameter M_ID_WIDTH = S_ID_WIDTH+{{cm}},
    // output tdest signal width
    parameter M_DEST_WIDTH = 1,
    // input tdest signal width
    // must be wide enough to uniquely address outputs
    parameter S_DEST_WIDTH = M_DEST_WIDTH+{{cn}},
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1,
    // Drop frames marked bad
    parameter DROP_BAD_FRAME = 0,
    // Drop incoming frames when full
    // When set, s_axis_tready is always asserted
    parameter DROP_WHEN_FULL = 0,
{%- for p in range(n) %}
    // Output interface routing base tdest selection
    // Port selected if M_BASE <= tdest <= M_TOP
    parameter M{{'%02d'%p}}_BASE = {{p}},
    // Output interface routing top tdest selection
    // Port selected if M_BASE <= tdest <= M_TOP
    parameter M{{'%02d'%p}}_TOP = {{p}},
    // Interface connection control
    parameter M{{'%02d'%p}}_CONNECT = {{m}}'b{% for p in range(m) %}1{% endfor %},
{%- endfor %}
    // Update tid with routing information
    parameter UPDATE_TID = 0,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 1,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1,
    // RAM read data output pipeline stages
    parameter RAM_PIPELINE = 2
)
(
    input  wire                    clk,
    input  wire                    rst,

    /*
     * AXI Stream inputs
     */
{%- for p in range(m) %}
    input  wire [S_DATA_WIDTH-1:0]  s{{'%02d'%p}}_axis_tdata,
    input  wire [S_KEEP_WIDTH-1:0]  s{{'%02d'%p}}_axis_tkeep,
    input  wire                     s{{'%02d'%p}}_axis_tvalid,
    output wire                     s{{'%02d'%p}}_axis_tready,
    input  wire                     s{{'%02d'%p}}_axis_tlast,
    input  wire [S_ID_WIDTH-1:0]    s{{'%02d'%p}}_axis_tid,
    input  wire [S_DEST_WIDTH-1:0]  s{{'%02d'%p}}_axis_tdest,
    input  wire [USER_WIDTH-1:0]    s{{'%02d'%p}}_axis_tuser,
{% endfor %}
    /*
     * AXI Stream outputs
     */
{%- for p in range(n) %}
    output wire [M_DATA_WIDTH-1:0]  m{{'%02d'%p}}_axis_tdata,
    output wire [M_KEEP_WIDTH-1:0]  m{{'%02d'%p}}_axis_tkeep,
    output wire                     m{{'%02d'%p}}_axis_tvalid,
    input  wire                     m{{'%02d'%p}}_axis_tready,
    output wire                     m{{'%02d'%p}}_axis_tlast,
    output wire [M_ID_WIDTH-1:0]    m{{'%02d'%p}}_axis_tid,
    output wire [M_DEST_WIDTH-1:0]  m{{'%02d'%p}}_axis_tdest,
    output wire [USER_WIDTH-1:0]    m{{'%02d'%p}}_axis_tuser,
{% endfor %}
    /*
     * Status
     */
    output wire [{{m-1}}:0]              status_overflow,
    output wire [{{m-1}}:0]              status_bad_frame,
    output wire [{{m-1}}:0]              status_good_frame
);

// parameter sizing helpers
function [S_DEST_WIDTH-1:0] w_dw(input [S_DEST_WIDTH-1:0] val);
    w_dw = val;
endfunction

function [{{m-1}}:0] w_s(input [{{m-1}}:0] val);
    w_s = val;
endfunction

axis_ram_switch #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .CMD_FIFO_DEPTH(CMD_FIFO_DEPTH),
    .SPEEDUP(SPEEDUP),
    .S_COUNT({{m}}),
    .M_COUNT({{n}}),
    .S_DATA_WIDTH(S_DATA_WIDTH),
    .S_KEEP_ENABLE(S_KEEP_ENABLE),
    .S_KEEP_WIDTH(S_KEEP_WIDTH),
    .M_DATA_WIDTH(M_DATA_WIDTH),
    .M_KEEP_ENABLE(M_KEEP_ENABLE),
    .M_KEEP_WIDTH(M_KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .S_ID_WIDTH(S_ID_WIDTH),
    .M_ID_WIDTH(M_ID_WIDTH),
    .S_DEST_WIDTH(S_DEST_WIDTH),
    .M_DEST_WIDTH(M_DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .USER_BAD_FRAME_VALUE(USER_BAD_FRAME_VALUE),
    .USER_BAD_FRAME_MASK(USER_BAD_FRAME_MASK),
    .DROP_BAD_FRAME(DROP_BAD_FRAME),
    .DROP_WHEN_FULL(DROP_WHEN_FULL),
    .M_BASE({ {% for p in range(n-1,-1,-1) %}w_dw(M{{'%02d'%p}}_BASE){% if not loop.last %}, {% endif %}{% endfor %} }),
    .M_TOP({ {% for p in range(n-1,-1,-1) %}w_dw(M{{'%02d'%p}}_TOP){% if not loop.last %}, {% endif %}{% endfor %} }),
    .M_CONNECT({ {% for p in range(n-1,-1,-1) %}w_s(M{{'%02d'%p}}_CONNECT){% if not loop.last %}, {% endif %}{% endfor %} }),
    .UPDATE_TID(UPDATE_TID),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY),
    .RAM_PIPELINE(RAM_PIPELINE)
)
axis_ram_switch_inst (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tdata({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tkeep({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tkeep{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tvalid({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tready({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tlast({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tid({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tdest({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tdest{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tuser({ {% for p in range(m-1,-1,-1) %}s{{'%02d'%p}}_axis_tuser{% if not loop.last %}, {% endif %}{% endfor %} }),
    // AXI outputs
    .m_axis_tdata({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tkeep({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tkeep{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tvalid({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tready({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tlast({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tid({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tdest({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tdest{% if not loop.last %}, {% endif %}{% endfor %} }),
    .m_axis_tuser({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tuser{% if not loop.last %}, {% endif %}{% endfor %} }),
    // Status
    .status_overflow(status_overflow),
    .status_bad_frame(status_bad_frame),
    .status_good_frame(status_good_frame)
);

endmodule

`resetall

""")

    print(f"Writing file '{output}'...")

    with open(output, 'w') as f:
        f.write(t.render(
            m=m,
            n=n,
            cm=cm,
            cn=cn,
            name=name
        ))
        f.flush()

    print("Done")


if __name__ == "__main__":
    main()
