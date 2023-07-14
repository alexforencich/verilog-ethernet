#!/usr/bin/env python
"""
Generates an I2C init module for an Si5341 PLL chip
"""

import argparse
from jinja2 import Template


def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-r', '--regs',  type=str, help="register list")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)


def generate(regs=None, name=None, output=None):
    if regs is None:
        raise Exception("Register list not specified")

    if name is None:
        name = "si5341_i2c_init"

    if output is None:
        output = name + ".v"

    print(f"Generating Si5341 I2C init module {name}...")

    cur_page = None
    cur_addr = None
    dev_addr = 0x77

    i = 0
    cmds = ""

    cmds += "    // Initial delay\n"
    cmds += f"    init_data[{i}] = 9'b000010110; // delay 30 ms\n"
    i += 1
    cmds += "    // Set muxes to select Si5341\n"
    cmds += f"    init_data[{i}] = {{2'b01, 7'h70}};\n"
    i += 1
    cmds += f"    init_data[{i}] = {{1'b1,  8'h00}};\n"
    i += 1
    cmds += f"    init_data[{i}] = 9'b001000001; // I2C stop\n"
    i += 1
    cmds += f"    init_data[{i}] = {{2'b01, 7'h71}};\n"
    i += 1
    cmds += f"    init_data[{i}] = {{1'b1,  8'h04}};\n"
    i += 1
    cmds += f"    init_data[{i}] = 9'b001000001; // I2C stop\n"
    i += 1

    with open(regs, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line == "Address,Data":
                continue
            if line[0] == '#':
                cmds += f"    // {line[1:].strip()}\n"

                if line.startswith("# Delay"):
                    cmds += f"    init_data[{i}] = 9'b000011010; // delay 300 ms\n"
                    i += 1
                    cur_addr = None

                continue

            d = line.split(",")
            addr = int(d[0], 0)
            page = (addr >> 8) & 0xff
            data = int(d[1], 0)

            if page != cur_page:
                cmds += f"    init_data[{i}] = {{2'b01, 7'h{dev_addr:02x}}};\n"
                i += 1
                cmds += f"    init_data[{i}] = {{1'b1,  8'h01}};\n"
                i += 1
                cmds += f"    init_data[{i}] = {{1'b1,  8'h{page:02x}}}; // set page {page:#04x}\n"
                i += 1
                cur_page = page
                cur_addr = None

            if addr != cur_addr:
                cmds += f"    init_data[{i}] = {{2'b01, 7'h{dev_addr:02x}}};\n"
                i += 1
                cmds += f"    init_data[{i}] = {{1'b1,  8'h{addr & 0xff:02x}}};\n"
                i += 1
                cur_addr = addr

            cmds += f"    init_data[{i}] = {{1'b1,  8'h{data:02x}}}; // write {data:#04x} to {addr:#06x}\n"
            i += 1
            cur_addr += 1

        cmds += f"    init_data[{i}] = 9'd0; // end\n"
        i += 1

    cmd_count = i

    t = Template(u"""/*

Copyright (c) 2015-2021 Alex Forencich

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
 * {{name}}
 */
module {{name}} (
    input  wire        clk,
    input  wire        rst,

    /*
     * I2C master interface
     */
    output wire [6:0]  m_axis_cmd_address,
    output wire        m_axis_cmd_start,
    output wire        m_axis_cmd_read,
    output wire        m_axis_cmd_write,
    output wire        m_axis_cmd_write_multiple,
    output wire        m_axis_cmd_stop,
    output wire        m_axis_cmd_valid,
    input  wire        m_axis_cmd_ready,

    output wire [7:0]  m_axis_data_tdata,
    output wire        m_axis_data_tvalid,
    input  wire        m_axis_data_tready,
    output wire        m_axis_data_tlast,

    /*
     * Status
     */
    output wire        busy,

    /*
     * Configuration
     */
    input  wire        start
);

/*

Generic module for I2C bus initialization.  Good for use when multiple devices
on an I2C bus must be initialized on system start without intervention of a
general-purpose processor.

Copy this file and change init_data and INIT_DATA_LEN as needed.

This module can be used in two modes: simple device initialization, or multiple
device initialization.  In multiple device mode, the same initialization sequence
can be performed on multiple different device addresses.

To use single device mode, only use the start write to address and write data commands.
The module will generate the I2C commands in sequential order.  Terminate the list
with a 0 entry.

To use the multiple device mode, use the start data and start address block commands
to set up lists of initialization data and device addresses.  The module enters
multiple device mode upon seeing a start data block command.  The module stores the
offset of the start of the data block and then skips ahead until it reaches a start
address block command.  The module will store the offset to the address block and
read the first address in the block.  Then it will jump back to the data block
and execute it, substituting the stored address for each current address write
command.  Upon reaching the start address block command, the module will read out the
next address and start again at the top of the data block.  If the module encounters
a start data block command while looking for an address, then it will store a new data
offset and then look for a start address block command.  Terminate the list with a 0
entry.  Normal address commands will operate normally inside a data block.

Commands:

00 0000000 : stop
00 0000001 : exit multiple device mode
00 0000011 : start write to current address
00 0001000 : start address block
00 0001001 : start data block
00 001dddd : delay 2**(16+d) cycles
00 1000001 : send I2C stop
01 aaaaaaa : start write to address
1 dddddddd : write 8-bit data

Examples

write 0x11223344 to register 0x0004 on device at 0x50

01 1010000  start write to 0x50
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
0 00000000  stop

write 0x11223344 to register 0x0004 on devices at 0x50, 0x51, 0x52, and 0x53

00 0001001  start data block
00 0000011  start write to current address
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
00 0001000  start address block
01 1010000  address 0x50
01 1010001  address 0x51
01 1010010  address 0x52
01 1010011  address 0x53
00 0000000  stop

*/

// init_data ROM
localparam INIT_DATA_LEN = {{cmd_count}};

reg [8:0] init_data [INIT_DATA_LEN-1:0];

initial begin
{{cmds-}}
end

localparam [3:0]
    STATE_IDLE = 3'd0,
    STATE_RUN = 3'd1,
    STATE_TABLE_1 = 3'd2,
    STATE_TABLE_2 = 3'd3,
    STATE_TABLE_3 = 3'd4;

reg [4:0] state_reg = STATE_IDLE, state_next;

parameter AW = $clog2(INIT_DATA_LEN);

reg [8:0] init_data_reg = 9'd0;

reg [AW-1:0] address_reg = {AW{1'b0}}, address_next;
reg [AW-1:0] address_ptr_reg = {AW{1'b0}}, address_ptr_next;
reg [AW-1:0] data_ptr_reg = {AW{1'b0}}, data_ptr_next;

reg [6:0] cur_address_reg = 7'd0, cur_address_next;

reg [31:0] delay_counter_reg = 32'd0, delay_counter_next;

reg [6:0] m_axis_cmd_address_reg = 7'd0, m_axis_cmd_address_next;
reg m_axis_cmd_start_reg = 1'b0, m_axis_cmd_start_next;
reg m_axis_cmd_write_reg = 1'b0, m_axis_cmd_write_next;
reg m_axis_cmd_stop_reg = 1'b0, m_axis_cmd_stop_next;
reg m_axis_cmd_valid_reg = 1'b0, m_axis_cmd_valid_next;

reg [7:0] m_axis_data_tdata_reg = 8'd0, m_axis_data_tdata_next;
reg m_axis_data_tvalid_reg = 1'b0, m_axis_data_tvalid_next;

reg start_flag_reg = 1'b0, start_flag_next;

reg busy_reg = 1'b0;

assign m_axis_cmd_address = m_axis_cmd_address_reg;
assign m_axis_cmd_start = m_axis_cmd_start_reg;
assign m_axis_cmd_read = 1'b0;
assign m_axis_cmd_write = m_axis_cmd_write_reg;
assign m_axis_cmd_write_multiple = 1'b0;
assign m_axis_cmd_stop = m_axis_cmd_stop_reg;
assign m_axis_cmd_valid = m_axis_cmd_valid_reg;

assign m_axis_data_tdata = m_axis_data_tdata_reg;
assign m_axis_data_tvalid = m_axis_data_tvalid_reg;
assign m_axis_data_tlast = 1'b1;

assign busy = busy_reg;

always @* begin
    state_next = STATE_IDLE;

    address_next = address_reg;
    address_ptr_next = address_ptr_reg;
    data_ptr_next = data_ptr_reg;

    cur_address_next = cur_address_reg;

    delay_counter_next = delay_counter_reg;

    m_axis_cmd_address_next = m_axis_cmd_address_reg;
    m_axis_cmd_start_next = m_axis_cmd_start_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_write_next = m_axis_cmd_write_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_stop_next = m_axis_cmd_stop_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_valid_next = m_axis_cmd_valid_reg & ~m_axis_cmd_ready;

    m_axis_data_tdata_next = m_axis_data_tdata_reg;
    m_axis_data_tvalid_next = m_axis_data_tvalid_reg & ~m_axis_data_tready;

    start_flag_next = start_flag_reg;

    if (m_axis_cmd_valid | m_axis_data_tvalid) begin
        // wait for output registers to clear
        state_next = state_reg;
    end else if (delay_counter_reg != 0) begin
        // delay
        delay_counter_next = delay_counter_reg - 1;
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // wait for start signal
                if (~start_flag_reg & start) begin
                    address_next = {AW{1'b0}};
                    start_flag_next = 1'b1;
                    state_next = STATE_RUN;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_RUN: begin
                // process commands
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    m_axis_cmd_write_next = 1'b1;
                    m_axis_cmd_stop_next = 1'b0;
                    m_axis_cmd_valid_next = 1'b1;

                    m_axis_data_tdata_next = init_data_reg[7:0];
                    m_axis_data_tvalid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    m_axis_cmd_address_next = init_data_reg[6:0];
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg[8:4] == 5'b00001) begin
                    // delay
                    delay_counter_next = 32'd1 << (init_data_reg[3:0]+16);

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end
            end
            STATE_TABLE_1: begin
                // find address table start
                if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end
            end
            STATE_TABLE_2: begin
                // find next address
                if (init_data_reg[8:7] == 2'b01) begin
                    // write address command
                    // store address and move to data table
                    cur_address_next = init_data_reg[6:0];
                    address_ptr_next = address_reg + 1;
                    address_next = data_ptr_reg;
                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end
            end
            STATE_TABLE_3: begin
                // process data table with selected address
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    m_axis_cmd_write_next = 1'b1;
                    m_axis_cmd_stop_next = 1'b0;
                    m_axis_cmd_valid_next = 1'b1;

                    m_axis_data_tdata_next = init_data_reg[7:0];
                    m_axis_data_tvalid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    m_axis_cmd_address_next = init_data_reg[6:0];
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000000011) begin
                    // write current address
                    m_axis_cmd_address_next = cur_address_reg;
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_next = address_ptr_reg;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_3;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    state_reg <= state_next;

    // read init_data ROM
    init_data_reg <= init_data[address_next];

    address_reg <= address_next;
    address_ptr_reg <= address_ptr_next;
    data_ptr_reg <= data_ptr_next;

    cur_address_reg <= cur_address_next;

    delay_counter_reg <= delay_counter_next;

    m_axis_cmd_address_reg <= m_axis_cmd_address_next;
    m_axis_cmd_start_reg <= m_axis_cmd_start_next;
    m_axis_cmd_write_reg <= m_axis_cmd_write_next;
    m_axis_cmd_stop_reg <= m_axis_cmd_stop_next;
    m_axis_cmd_valid_reg <= m_axis_cmd_valid_next;

    m_axis_data_tdata_reg <= m_axis_data_tdata_next;
    m_axis_data_tvalid_reg <= m_axis_data_tvalid_next;

    start_flag_reg <= start & start_flag_next;

    busy_reg <= (state_reg != STATE_IDLE);

    if (rst) begin
        state_reg <= STATE_IDLE;

        init_data_reg <= 9'd0;

        address_reg <= {AW{1'b0}};
        address_ptr_reg <= {AW{1'b0}};
        data_ptr_reg <= {AW{1'b0}};

        cur_address_reg <= 7'd0;

        delay_counter_reg <= 32'd0;

        m_axis_cmd_valid_reg <= 1'b0;

        m_axis_data_tvalid_reg <= 1'b0;

        start_flag_reg <= 1'b0;

        busy_reg <= 1'b0;
    end
end

endmodule

`resetall

""")

    print(f"Writing file '{output}'...")

    with open(output, 'w') as f:
        f.write(t.render(
            cmds=cmds,
            cmd_count=cmd_count,
            name=name
        ))
        f.flush()

    print("Done")


if __name__ == "__main__":
    main()
