/*

Copyright (c) 2015-2018 Alex Forencich

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
 * MDIO master
 */
module mdio_master (
    input  wire        clk,
    input  wire        rst,

    /*
     * Host interface
     */
    input  wire [4:0]  cmd_phy_addr,
    input  wire [4:0]  cmd_reg_addr,
    input  wire [15:0] cmd_data,
    input  wire [1:0]  cmd_opcode,
    input  wire        cmd_valid,
    output wire        cmd_ready,

    output wire [15:0] data_out,
    output wire        data_out_valid,
    input  wire        data_out_ready,

    /*
     * MDIO to PHY
     */
    output wire        mdc_o,
    input  wire        mdio_i,
    output wire        mdio_o,
    output wire        mdio_t,

    /*
     * Status
     */
    output wire        busy,

    /*
     * Configuration
     */
    input  wire [7:0]  prescale
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PREAMBLE = 2'd1,
    STATE_TRANSFER = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

reg [16:0] count_reg = 16'd0, count_next;
reg [6:0] bit_count_reg = 6'd0, bit_count_next;
reg cycle_reg = 1'b0, cycle_next;

reg [31:0] data_reg = 32'd0, data_next;

reg [1:0] op_reg = 2'b00, op_next;

reg cmd_ready_reg = 1'b0, cmd_ready_next;

reg [15:0] data_out_reg = 15'd0, data_out_next;
reg data_out_valid_reg = 1'b0, data_out_valid_next;

reg mdio_i_reg = 1'b1;

reg mdc_o_reg = 1'b0, mdc_o_next;
reg mdio_o_reg = 1'b0, mdio_o_next;
reg mdio_t_reg = 1'b1, mdio_t_next;

reg busy_reg = 1'b0;

assign cmd_ready = cmd_ready_reg;

assign data_out = data_out_reg;
assign data_out_valid = data_out_valid_reg;

assign mdc_o = mdc_o_reg;
assign mdio_o = mdio_o_reg;
assign mdio_t = mdio_t_reg;

assign busy = busy_reg;

always @* begin
    state_next = STATE_IDLE;

    count_next = count_reg;
    bit_count_next = bit_count_reg;
    cycle_next = cycle_reg;

    data_next = data_reg;

    op_next = op_reg;

    cmd_ready_next = 1'b0;

    data_out_next = data_out_reg;
    data_out_valid_next = data_out_valid_reg & ~data_out_ready;

    mdc_o_next = mdc_o_reg;
    mdio_o_next = mdio_o_reg;
    mdio_t_next = mdio_t_reg;

    if (count_reg > 16'd0) begin
        count_next = count_reg - 16'd1;
        state_next = state_reg;
    end else if (cycle_reg) begin
        cycle_next = 1'b0;
        mdc_o_next = 1'b1;
        count_next = prescale;
        state_next = state_reg;
    end else begin
        mdc_o_next = 1'b0;
        case (state_reg)
            STATE_IDLE: begin
                // idle - accept new command
                cmd_ready_next = ~data_out_valid;

                if (cmd_ready & cmd_valid) begin
                    cmd_ready_next = 1'b0;
                    data_next = {2'b01, cmd_opcode, cmd_phy_addr, cmd_reg_addr, 2'b10, cmd_data};
                    op_next = cmd_opcode;
                    mdio_t_next = 1'b0;
                    mdio_o_next = 1'b1;
                    bit_count_next = 6'd32;
                    cycle_next = 1'b1;
                    count_next = prescale;
                    state_next = STATE_PREAMBLE;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_PREAMBLE: begin
                cycle_next = 1'b1;
                count_next = prescale;
                if (bit_count_reg > 6'd1) begin
                    bit_count_next = bit_count_reg - 6'd1;
                    state_next = STATE_PREAMBLE;
                end else begin
                    bit_count_next = 6'd32;
                    {mdio_o_next, data_next} = {data_reg, mdio_i_reg};
                    state_next = STATE_TRANSFER;
                end
            end
            STATE_TRANSFER: begin
                cycle_next = 1'b1;
                count_next = prescale;
                if ((op_reg == 2'b10 || op_reg == 2'b11) && bit_count_reg == 6'd19) begin
                    mdio_t_next = 1'b1;
                end
                if (bit_count_reg > 6'd1) begin
                    bit_count_next = bit_count_reg - 6'd1;
                    {mdio_o_next, data_next} = {data_reg, mdio_i_reg};
                    state_next = STATE_TRANSFER;
                end else begin
                    if (op_reg == 2'b10 || op_reg == 2'b11) begin
                        data_out_next = data_reg[15:0];
                        data_out_valid_next = 1'b1;
                    end
                    mdio_t_next = 1'b1;
                    state_next = STATE_IDLE;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        count_reg <= 16'd0;
        bit_count_reg <= 6'd0;
        cycle_reg <= 1'b0;
        cmd_ready_reg <= 1'b0;
        data_out_valid_reg <= 1'b0;
        mdc_o_reg <= 1'b0;
        mdio_o_reg <= 1'b0;
        mdio_t_reg <= 1'b1;
        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        count_reg <= count_next;
        bit_count_reg <= bit_count_next;
        cycle_reg <= cycle_next;
        cmd_ready_reg <= cmd_ready_next;
        data_out_valid_reg <= data_out_valid_next;
        mdc_o_reg <= mdc_o_next;
        mdio_o_reg <= mdio_o_next;
        mdio_t_reg <= mdio_t_next;
        busy_reg <= (state_next != STATE_IDLE || count_reg != 0 || cycle_reg || mdc_o);
    end

    data_reg <= data_next;
    op_reg <= op_next;

    data_out_reg <= data_out_next;

    mdio_i_reg <= mdio_i;
end

endmodule

`resetall
