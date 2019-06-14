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
 * Testbench for arp_cache
 */
module test_arp_cache;

// Parameters
parameter CACHE_ADDR_WIDTH = 2;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg query_request_valid = 0;
reg [31:0] query_request_ip = 0;

reg query_response_ready = 0;

reg write_request_valid = 0;
reg [31:0] write_request_ip = 0;
reg [47:0] write_request_mac = 0;

reg clear_cache = 0;

// Outputs
wire query_request_ready;

wire query_response_valid;
wire query_response_error;
wire [47:0] query_response_mac;

wire write_request_ready;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        query_request_valid,
        query_request_ip,
        query_response_ready,
        write_request_valid,
        write_request_ip,
        write_request_mac,
        clear_cache
    );
    $to_myhdl(
        query_request_ready,
        query_response_valid,
        query_response_error,
        query_response_mac,
        write_request_ready
    );

    // dump file
    $dumpfile("test_arp_cache.lxt");
    $dumpvars(0, test_arp_cache);
end

arp_cache #(
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH)
)
UUT (
    .clk(clk),
    .rst(rst),
    // Query cache
    .query_request_valid(query_request_valid),
    .query_request_ready(query_request_ready),
    .query_request_ip(query_request_ip),
    .query_response_valid(query_response_valid),
    .query_response_ready(query_response_ready),
    .query_response_error(query_response_error),
    .query_response_mac(query_response_mac),
    // Write cache
    .write_request_valid(write_request_valid),
    .write_request_ready(write_request_ready),
    .write_request_ip(write_request_ip),
    .write_request_mac(write_request_mac),
    // Configuration
    .clear_cache(clear_cache)
);

endmodule
