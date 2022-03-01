/*

Copyright (c) 2021 Alex Forencich

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
 * Transceiver control
 */
module xcvr_ctrl (
    input  wire        reconfig_clk,
    input  wire        reconfig_rst,

    input  wire        pll_locked_in,

    output wire [18:0] xcvr_reconfig_address,
    output wire        xcvr_reconfig_read,
    output wire        xcvr_reconfig_write,
    input  wire [7:0]  xcvr_reconfig_readdata,
    output wire [7:0]  xcvr_reconfig_writedata,
    input  wire        xcvr_reconfig_waitrequest
);

localparam [3:0]
    STATE_IDLE = 4'd0,
    STATE_LOAD_PMA_1 = 4'd1,
    STATE_LOAD_PMA_2 = 4'd2,
    STATE_INIT_ADAPT_1 = 4'd3,
    STATE_INIT_ADAPT_2 = 4'd4,
    STATE_INIT_ADAPT_3 = 4'd5,
    STATE_INIT_ADAPT_4 = 4'd6,
    STATE_CONT_ADAPT_1 = 4'd7,
    STATE_CONT_ADAPT_2 = 4'd8,
    STATE_CONT_ADAPT_3 = 4'd9,
    STATE_CONT_ADAPT_4 = 4'd10,
    STATE_DONE = 4'd11;

reg [3:0] state_reg = STATE_IDLE, state_next;

reg [18:0] xcvr_reconfig_address_reg = 19'd0, xcvr_reconfig_address_next;
reg xcvr_reconfig_read_reg = 1'b0, xcvr_reconfig_read_next;
reg xcvr_reconfig_write_reg = 1'b0, xcvr_reconfig_write_next;
reg [7:0] xcvr_reconfig_writedata_reg = 8'd0, xcvr_reconfig_writedata_next;

reg [7:0] read_data_reg = 8'd0, read_data_next;
reg read_data_valid_reg = 1'b0, read_data_valid_next;

reg [15:0] delay_count_reg = 0, delay_count_next;

reg pll_locked_sync_1_reg = 0;
reg pll_locked_sync_2_reg = 0;
reg pll_locked_sync_3_reg = 0;

assign xcvr_reconfig_address = xcvr_reconfig_address_reg;
assign xcvr_reconfig_read = xcvr_reconfig_read_reg;
assign xcvr_reconfig_write = xcvr_reconfig_write_reg;
assign xcvr_reconfig_writedata = xcvr_reconfig_writedata_reg;

always @(posedge reconfig_clk) begin
    pll_locked_sync_1_reg <= pll_locked_in;
    pll_locked_sync_2_reg <= pll_locked_sync_1_reg;
    pll_locked_sync_3_reg <= pll_locked_sync_2_reg;
end

always @* begin
    state_next = STATE_IDLE;

    xcvr_reconfig_address_next = xcvr_reconfig_address_reg;
    xcvr_reconfig_read_next = 1'b0;
    xcvr_reconfig_write_next = 1'b0;
    xcvr_reconfig_writedata_next = xcvr_reconfig_writedata_reg;

    read_data_next = read_data_reg;
    read_data_valid_next = read_data_valid_reg;

    delay_count_next = delay_count_reg;

    if (xcvr_reconfig_read_reg || xcvr_reconfig_write_reg) begin
        // operation in progress
        if (xcvr_reconfig_waitrequest) begin
            // wait state, hold command
            xcvr_reconfig_read_next = xcvr_reconfig_read_reg;
            xcvr_reconfig_write_next = xcvr_reconfig_write_reg;
        end else begin
            // release command
            xcvr_reconfig_read_next = 1'b0;
            xcvr_reconfig_write_next = 1'b0;

            if (xcvr_reconfig_read_reg) begin
                // latch read data
                read_data_next = xcvr_reconfig_readdata;
                read_data_valid_next = 1'b1;
            end
        end
        state_next = state_reg;
    end else if (delay_count_reg != 0) begin
        // stall for delay
        delay_count_next = delay_count_reg - 1;
        state_next = state_reg;
    end else begin
        read_data_valid_next = 1'b0;

        case (state_reg)
            STATE_IDLE: begin
                // wait for PLL to lock
                if (pll_locked_sync_3_reg) begin
                    delay_count_next = 16'hffff;
                    state_next = STATE_LOAD_PMA_1;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_LOAD_PMA_1: begin
                // load PMA config
                xcvr_reconfig_address_next = 19'h40143;
                xcvr_reconfig_writedata_next = 8'h80;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_LOAD_PMA_2;
            end
            STATE_LOAD_PMA_2: begin
                // check status
                if (read_data_valid_reg && read_data_reg[0]) begin
                    // start initial adaptation
                    xcvr_reconfig_address_next = 19'h200;
                    xcvr_reconfig_writedata_next = 8'hD2;
                    xcvr_reconfig_write_next = 1'b1;
                    state_next = STATE_INIT_ADAPT_1;
                end else begin
                    // read status
                    xcvr_reconfig_address_next = 19'h40144;
                    xcvr_reconfig_read_next = 1'b1;
                    state_next = STATE_LOAD_PMA_2;
                end
            end
            STATE_INIT_ADAPT_1: begin
                // start initial adaptation
                xcvr_reconfig_address_next = 19'h201;
                xcvr_reconfig_writedata_next = 8'h02;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_INIT_ADAPT_2;
            end
            STATE_INIT_ADAPT_2: begin
                // start initial adaptation
                xcvr_reconfig_address_next = 19'h202;
                xcvr_reconfig_writedata_next = 8'h01;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_INIT_ADAPT_3;
            end
            STATE_INIT_ADAPT_3: begin
                // start initial adaptation
                xcvr_reconfig_address_next = 19'h203;
                xcvr_reconfig_writedata_next = 8'h96;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_INIT_ADAPT_4;
            end
            STATE_INIT_ADAPT_4: begin
                // check status
                if (read_data_valid_reg && read_data_reg == 8'h80) begin
                    // start continuous adaptation
                    xcvr_reconfig_address_next = 19'h200;
                    xcvr_reconfig_writedata_next = 8'hF6;
                    xcvr_reconfig_write_next = 1'b1;
                    state_next = STATE_CONT_ADAPT_1;
                end else begin
                    // read status
                    xcvr_reconfig_address_next = 19'h207;
                    xcvr_reconfig_read_next = 1'b1;
                    state_next = STATE_INIT_ADAPT_4;
                end
            end
            STATE_CONT_ADAPT_1: begin
                // start continuous adaptation
                xcvr_reconfig_address_next = 19'h201;
                xcvr_reconfig_writedata_next = 8'h01;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_CONT_ADAPT_2;
            end
            STATE_CONT_ADAPT_2: begin
                // start continuous adaptation
                xcvr_reconfig_address_next = 19'h202;
                xcvr_reconfig_writedata_next = 8'h03;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_CONT_ADAPT_3;
            end
            STATE_CONT_ADAPT_3: begin
                // start continuous adaptation
                xcvr_reconfig_address_next = 19'h203;
                xcvr_reconfig_writedata_next = 8'h96;
                xcvr_reconfig_write_next = 1'b1;
                state_next = STATE_CONT_ADAPT_4;
            end
            STATE_CONT_ADAPT_4: begin
                // check status
                if (read_data_valid_reg && read_data_reg == 8'h80) begin
                    // done
                    state_next = STATE_DONE;
                end else begin
                    // read status
                    xcvr_reconfig_address_next = 19'h207;
                    xcvr_reconfig_read_next = 1'b1;
                    state_next = STATE_CONT_ADAPT_4;
                end
            end
            STATE_DONE: begin
                // done with operation
                state_next = STATE_DONE;
            end
        endcase
    end

    if (!pll_locked_sync_3_reg) begin
        // go back to idle if PLL is unlocked
        state_next = STATE_IDLE;
    end
end

always @(posedge reconfig_clk) begin
    state_reg <= state_next;

    xcvr_reconfig_address_reg <= xcvr_reconfig_address_next;
    xcvr_reconfig_read_reg <= xcvr_reconfig_read_next;
    xcvr_reconfig_write_reg <= xcvr_reconfig_write_next;
    xcvr_reconfig_writedata_reg <= xcvr_reconfig_writedata_next;

    read_data_reg <= read_data_next;
    read_data_valid_reg <= read_data_valid_next;

    delay_count_reg <= delay_count_next;

    if (reconfig_rst) begin
        state_reg <= STATE_IDLE;

        xcvr_reconfig_read_reg <= 1'b0;
        xcvr_reconfig_write_reg <= 1'b0;

        read_data_valid_reg <= 1'b0;

        delay_count_reg <= 0;
    end
end

endmodule

`resetall
