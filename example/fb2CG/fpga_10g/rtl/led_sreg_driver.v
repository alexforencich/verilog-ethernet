/*

Copyright (c) 2020 Alex Forencich

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
 * LED shift register driver
 */
module led_sreg_driver #(
    // number of LEDs
    parameter COUNT = 8,
    // invert output
    parameter INVERT = 0,
    // clock prescale
    parameter PRESCALE = 31
)
(
    input  wire             clk,
    input  wire             rst,

    input  wire [COUNT-1:0] led,

    output wire             sreg_d,
    output wire             sreg_ld,
    output wire             sreg_clk
);

localparam CL_COUNT = $clog2(COUNT+1);
localparam CL_PRESCALE = $clog2(PRESCALE+1);

reg [CL_COUNT-1:0] count_reg = 0;
reg [CL_PRESCALE-1:0] prescale_count_reg = 0;
reg enable_reg = 1'b0;
reg update_reg = 1'b1;
reg cycle_reg = 1'b0;

reg [COUNT-1:0] led_sync_reg_1 = 0;
reg [COUNT-1:0] led_sync_reg_2 = 0;
reg [COUNT-1:0] led_reg = 0;

reg sreg_d_reg = 1'b0;
reg sreg_ld_reg = 1'b0;
reg sreg_clk_reg = 1'b0;

assign sreg_d = INVERT ? !sreg_d_reg : sreg_d_reg;
assign sreg_ld = sreg_ld_reg;
assign sreg_clk = sreg_clk_reg;

always @(posedge clk) begin
    led_sync_reg_1 <= led;
    led_sync_reg_2 <= led_sync_reg_1;

    enable_reg <= 1'b0;

    if (prescale_count_reg) begin
        prescale_count_reg <= prescale_count_reg - 1;
    end else begin
        enable_reg <= 1'b1;
        prescale_count_reg <= PRESCALE;
    end

    if (enable_reg) begin
        if (cycle_reg) begin
            cycle_reg <= 1'b0;
            sreg_clk_reg <= 1'b1;
        end else if (count_reg) begin
            sreg_clk_reg <= 1'b0;
            sreg_ld_reg <= 1'b0;

            if (count_reg < COUNT) begin
                count_reg <= count_reg + 1;
                cycle_reg <= 1'b1;
                sreg_d_reg <= led_reg[count_reg];
            end else begin
                count_reg <= 0;
                cycle_reg <= 1'b0;
                sreg_d_reg <= 1'b0;
                sreg_ld_reg <= 1'b1;
            end
        end else begin
            sreg_clk_reg <= 1'b0;
            sreg_ld_reg <= 1'b0;

            if (update_reg) begin
                update_reg <= 1'b0;

                count_reg <= 1;
                cycle_reg <= 1'b1;
                sreg_d_reg <= led_reg[0];
            end
        end
    end

    if (led_sync_reg_2 != led_reg) begin
        led_reg <= led_sync_reg_2;
        update_reg <= 1'b1;
    end

    if (rst) begin
        count_reg <= 0;
        prescale_count_reg <= 0;
        enable_reg <= 1'b0;
        update_reg <= 1'b1;
        cycle_reg <= 1'b0;
        led_reg <= 0;
        sreg_d_reg <= 1'b0;
        sreg_ld_reg <= 1'b0;
        sreg_clk_reg <= 1'b0;
    end
end

endmodule

`resetall
