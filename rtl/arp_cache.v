/*

Copyright (c) 2014-2018 Alex Forencich

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
 * ARP cache block
 */
module arp_cache #(
    parameter CACHE_ADDR_WIDTH = 2
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * Query cache
     */
    input  wire        query_request_valid,
    input  wire [31:0] query_request_ip,
    output wire        query_response_valid,
    output wire        query_response_error,
    output wire [47:0] query_response_mac,

    /*
     * Write cache
     */
    input  wire        write_request_valid,
    input  wire [31:0] write_request_ip,
    input  wire [47:0] write_request_mac,
    output wire        write_in_progress,
    output wire        write_complete,

    /*
     * Configuration
     */
    input  wire        clear_cache
);

// bit LRU cache

reg [31:0] ip_addr_mem[(2**CACHE_ADDR_WIDTH)-1:0];
reg [47:0] mac_addr_mem[(2**CACHE_ADDR_WIDTH)-1:0];
reg [(2**CACHE_ADDR_WIDTH)-1:0] lru_bit = 0;

reg query_response_valid_reg = 0;
reg query_response_error_reg = 0;
reg [47:0] query_response_mac_reg = 0;

reg write_complete_reg = 0;

localparam [2:0]
    WRITE_STATE_IDLE = 0,
    WRITE_STATE_SEARCH = 1,
    WRITE_STATE_NOTFOUND = 2;

reg [2:0] write_state = WRITE_STATE_IDLE;
reg [31:0] write_ip_reg = 0;
reg [47:0] write_mac_reg = 0;
reg [CACHE_ADDR_WIDTH-1:0] write_addr = 0;
reg [CACHE_ADDR_WIDTH-1:0] write_ptr = 0;

wire write_state_idle = (write_state == WRITE_STATE_IDLE);
wire write_state_search = (write_state == WRITE_STATE_SEARCH);
wire write_state_notfound = (write_state == WRITE_STATE_NOTFOUND);

reg clear_cache_operation = 0;

assign query_response_valid = query_response_valid_reg;
assign query_response_error = query_response_error_reg;
assign query_response_mac = query_response_mac_reg;

assign write_in_progress = ~write_state_idle;
assign write_complete = write_complete_reg;

wire lru_full = &lru_bit;

integer i;

always @(posedge clk) begin
    if (rst) begin
        query_response_valid_reg <= 0;
        query_response_error_reg <= 0;
        write_complete_reg <= 0;
        write_state <= WRITE_STATE_IDLE;
        write_addr <= 0;
        write_ptr <= 0;
        clear_cache_operation <= 1;
        lru_bit <= 0;
    end else begin
        write_complete_reg <= 0;
        query_response_valid_reg <= 0;
        query_response_error_reg <= 0;

        // clear LRU bits when full
        if (lru_full) begin
            lru_bit <= 0;
        end

        // fast IP match and readout
        if (query_request_valid) begin
            query_response_valid_reg <= 1;
            query_response_error_reg <= 1;
            for (i = 0; i < 2**CACHE_ADDR_WIDTH; i = i + 1) begin
                if (ip_addr_mem[i] == query_request_ip) begin
                    query_response_error_reg <= 0;
                    query_response_mac_reg <= mac_addr_mem[i];
                    lru_bit[i] <= 1'b1;
                end
            end
        end

        // manage writes
        if (write_state_idle) begin
            if (write_request_valid) begin
                write_state <= WRITE_STATE_SEARCH;
                write_ip_reg <= write_request_ip;
                write_mac_reg <= write_request_mac;
            end
            write_addr <= 0;
        end else if (write_state_search) begin
            write_addr <= write_addr + 1;
            if (&write_addr) begin
                write_state <= WRITE_STATE_NOTFOUND;
            end
            if (ip_addr_mem[write_addr] == write_ip_reg) begin
                write_state <= WRITE_STATE_IDLE;
                mac_addr_mem[write_addr] <= write_mac_reg;
                write_complete_reg <= 1;
            end
        end else if (write_state_notfound) begin
            write_ptr <= write_ptr + 1;
            if (~lru_bit[write_ptr]) begin
                ip_addr_mem[write_ptr] <= write_ip_reg;
                mac_addr_mem[write_ptr] <= write_mac_reg;
                write_state <= WRITE_STATE_IDLE;
                write_complete_reg <= 1;
            end
        end

        // clear cache
        if (clear_cache & ~clear_cache_operation) begin
            clear_cache_operation <= 1;
            write_addr <= 0;
        end
        if (clear_cache_operation) begin
            write_addr <= write_addr + 1;
            ip_addr_mem[write_addr] <= 0;
            mac_addr_mem[write_addr] <= 0;
            clear_cache_operation <= ~&write_addr;
        end
    end
end

endmodule
