/*

Copyright (c) 2016-2017 Alex Forencich

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
 * Parametrizable combinatorial parallel LFSR/CRC
 */
module lfsr #
(
    // width of LFSR
    parameter LFSR_WIDTH = 31,
    // LFSR polynomial
    parameter LFSR_POLY = 31'h10000001,
    // LFSR configuration: "GALOIS", "FIBONACCI"
    parameter LFSR_CONFIG = "FIBONACCI",
    // bit-reverse input and output
    parameter REVERSE = 0,
    // width of data input
    parameter DATA_WIDTH = 8,
    // width of CRC/LFSR output
    parameter OUTPUT_WIDTH = LFSR_WIDTH,
    // implementation style: "AUTO", "LOOP", "REDUCTION"
    parameter STYLE = "AUTO"
)
(
    input  wire [DATA_WIDTH-1:0]   data_in,
    input  wire [LFSR_WIDTH-1:0]   lfsr_in,
    output wire [OUTPUT_WIDTH-1:0] lfsr_out
);

/*

Fully parametrizable combinatorial parallel LFSR/CRC module.  Implements an unrolled LFSR
next state computation, shifting DATA_WIDTH bits per pass through the module.  Input data
is XORed with LFSR feedback path, tie data_in to zero if this is not required.

Works in two parts: statically computes a set of bit masks, then uses these bit masks to
select bits for XORing to compute the next state.  

Ports:

data_in

Data bits to be XORed with the LFSR feedback path (DATA_WIDTH bits)

lfsr_in

LFSR/CRC current state input (LFSR_WIDTH bits)

lfsr_out

LFSR/CRC next state output (OUTPUT_WIDTH bits)

Parameters:

LFSR_WIDTH

Specify width of LFSR/CRC register

LFSR_POLY

Specify the LFSR/CRC polynomial in hex format.  For example, the polynomial

x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1

would be represented as

32'h04c11db7

Note that the largest term (x^32) is suppressed.  This term is generated automatically based
on LFSR_WIDTH.

LFSR_CONFIG

Specify the LFSR configuration, either Fibonacci or Galois.  Fibonacci is generally used
for linear-feedback shift registers (LFSR) for pseudorandom binary sequence (PRBS) generators,
scramblers, and descrambers, while Galois is generally used for cyclic redundancy check
generators and checkers.

Fibonacci style (example for 64b66b scrambler, 0x8000000001)

    ,-----------------------------(+)<------------------------------,
    |                              ^                                |
    |  .----.  .----.       .----. |  .----.       .----.  .----.   |
    `->|  0 |->|  1 |->...->| 38 |-+->| 39 |->...->| 56 |->| 57 |->(+)<-DIN (MSB first)
       '----'  '----'       '----'    '----'       '----'  '----'

Galois style (example for CRC16, 0x8005)

    ,-------------------+---------------------------------+------------,
    |                   |                                 |            |
    |  .----.  .----.   V   .----.  .----.       .----.   V   .----.   |
    `->|  0 |->|  1 |->(+)->|  2 |->|  3 |->...->| 14 |->(+)->| 15 |->(+)<-DIN (MSB first)
       '----'  '----'       '----'  '----'       '----'       '----'

REVERSE

Bit-reverse LFSR input and output.

DATA_WIDTH

Specify width of input data bus.  The module will perform one shift per input data bit,
so if the input data bus is not required tie data_in to zero and set DATA_WIDTH to the
required number of shifts per clock cycle.  

OUTPUT_WIDTH

Specify width of output data bus.  Defaults to LFSR_WIDTH.  Mainly useful for extending
the output width for LFSRs.  Ensure that lfsr_out is properly shifted and truncated so
that feeding it back around to lfsr_in produces the expected result.  Note that if
OUTPUT_WIDTH is smaller than LFSR_WIDTH, it may not be possible to get the LFSR to
feed back correctly.

STYLE

Specify implementation style.  Can be "AUTO", "LOOP", or "REDUCTION".  When "AUTO"
is selected, implemenation will be "LOOP" or "REDUCTION" based on synthesis translate
directives.  "REDUCTION" and "LOOP" are functionally identical, however they simulate
and synthesize differently.  "REDUCTION" is implemented with a loop over a Verilog
reduction operator.  "LOOP" is implemented as a doubly-nested loop with no reduction
operator.  "REDUCTION" is very fast for simulation in iverilog and synthesizes well in
Quartus but synthesizes poorly in ISE, likely due to large inferred XOR gates causing
problems with the optimizer.  "LOOP" synthesizes will in both ISE and Quartus.  "AUTO"
will default to "REDUCTION" when simulating and "LOOP" for synthesizers that obey
synthesis translate directives.

Settings for common LFSR/CRC implementations:

Name        Configuration           Length  Polynomial      Initial value   Notes
CRC32       Galois, bit-reverse     32      32'h04c11db7    32'hffffffff    Ethernet FCS; invert final output
PRBS6       Fibonacci               6       6'h21           any
PRBS7       Fibonacci               7       7'h41           amy
PRBS9       Fibonacci               9       9'h021          any             ITU V.52
PRBS10      Fibonacci               10      10'h081         any             ITU
PRBS11      Fibonacci               11      11'h201         any             ITU O.152
PRBS15      Fibonacci               15      15'h4001        any             ITU O.152
PRBS17      Fibonacci               17      17'h04001       any
PRBS20      Fibonacci               20      20'h00009       any             ITU V.57
PRBS23      Fibonacci               23      23'h040001      any             ITU O.151
PRBS31      Fibonacci               31      31'h10000001    any
64b66b      Fibonacci               58      58'h8000000001  any             10G Ethernet
128b130b    Fibonacci               23      23'h210125      any             PCIe gen 3

*/

// STATE_WIDTH is OUTPUT_WIDTH or LFSR_WIDTH, whichever is larger
parameter STATE_WIDTH = OUTPUT_WIDTH > LFSR_WIDTH ? OUTPUT_WIDTH : LFSR_WIDTH;

reg [LFSR_WIDTH-1:0] lfsr_mask_state[STATE_WIDTH-1:0];
reg [DATA_WIDTH-1:0] lfsr_mask_data[STATE_WIDTH-1:0];

reg [LFSR_WIDTH-1:0] state_val = 0;
reg [DATA_WIDTH-1:0] data_val = 0;

integer i, j, k;

initial begin
    // init bit masks
    for (i = 0; i < STATE_WIDTH; i = i + 1) begin
        lfsr_mask_state[i] = {LFSR_WIDTH{1'b0}};
        if (i < LFSR_WIDTH) begin
            lfsr_mask_state[i][i] = 1'b1;
        end
        lfsr_mask_data[i] = {DATA_WIDTH{1'b0}};
    end

    // simulate shift register
    if (LFSR_CONFIG == "FIBONACCI") begin
        // Fibonacci configuration
        for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
            // determine shift in value
            // current value in last FF, XOR with input data bit (MSB first)
            state_val = lfsr_mask_state[LFSR_WIDTH-1];
            data_val = lfsr_mask_data[LFSR_WIDTH-1];
            data_val = data_val ^ (1 << i);

            // add XOR inputs from correct indicies
            for (j = 1; j < STATE_WIDTH; j = j + 1) begin
                if (LFSR_POLY & (1 << j)) begin
                    state_val = lfsr_mask_state[j-1] ^ state_val;
                    data_val = lfsr_mask_data[j-1] ^ data_val;
                end
            end

            // shift
            for (j = STATE_WIDTH-1; j > 0; j = j - 1) begin
                lfsr_mask_state[j] = lfsr_mask_state[j-1];
                lfsr_mask_data[j] = lfsr_mask_data[j-1];
            end
            lfsr_mask_state[0] = state_val;
            lfsr_mask_data[0] = data_val;
        end
    end else if (LFSR_CONFIG == "GALOIS") begin
        // Galois configuration
        for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
            // determine shift in value
            // current value in last FF, XOR with input data bit (MSB first)
            state_val = lfsr_mask_state[LFSR_WIDTH-1];
            data_val = lfsr_mask_data[LFSR_WIDTH-1];
            data_val = data_val ^ (1 << i);

            // shift
            for (j = STATE_WIDTH-1; j > 0; j = j - 1) begin
                lfsr_mask_state[j] = lfsr_mask_state[j-1];
                lfsr_mask_data[j] = lfsr_mask_data[j-1];
            end
            lfsr_mask_state[0] = state_val;
            lfsr_mask_data[0] = data_val;

            // add XOR inputs at correct indicies
            for (j = 1; j < STATE_WIDTH; j = j + 1) begin
                if (LFSR_POLY & (1 << j)) begin
                    lfsr_mask_state[j] = lfsr_mask_state[j] ^ state_val;
                    lfsr_mask_data[j] = lfsr_mask_data[j] ^ data_val;
                end
            end
        end
    end else begin
        $error("Error: unknown configuration setting!");
        $finish;
    end

    // reverse bits if selected
    if (REVERSE) begin
        // reverse order
        for (i = 0; i < OUTPUT_WIDTH/2; i = i + 1) begin
            state_val = lfsr_mask_state[i];
            data_val = lfsr_mask_data[i];
            lfsr_mask_state[i] = lfsr_mask_state[OUTPUT_WIDTH-i-1];
            lfsr_mask_data[i] = lfsr_mask_data[OUTPUT_WIDTH-i-1];
            lfsr_mask_state[OUTPUT_WIDTH-i-1] = state_val;
            lfsr_mask_data[OUTPUT_WIDTH-i-1] = data_val;
        end
        // reverse bits
        for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
            state_val = 0;
            for (j = 0; j < STATE_WIDTH; j = j + 1) begin
                state_val[j] = lfsr_mask_state[i][STATE_WIDTH-j-1];
            end
            lfsr_mask_state[i] = state_val;

            data_val = 0;
            for (j = 0; j < DATA_WIDTH; j = j + 1) begin
                data_val[j] = lfsr_mask_data[i][DATA_WIDTH-j-1];
            end
            lfsr_mask_data[i] = data_val;
        end
    end

    // for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
    //     $display("%b %b", lfsr_mask_state[i], lfsr_mask_data[i]);
    // end
end

// synthesis translate_off
`define SIMULATION
// synthesis translate_on

`ifdef SIMULATION
// "AUTO" style is "REDUCTION" for faster simulation
parameter STYLE_INT = (STYLE == "AUTO") ? "REDUCTION" : STYLE;
`else
// "AUTO" style is "LOOP" for better synthesis result
parameter STYLE_INT = (STYLE == "AUTO") ? "LOOP" : STYLE;
`endif

genvar n;

generate

if (STYLE_INT == "REDUCTION") begin

    // use Verilog reduction operator
    // fast in iverilog
    // significantly larger than generated code with ISE (inferred wide XORs may be tripping up optimizer)
    // slightly smaller than generated code with Quartus
    // --> better for simulation

    for (n = 0; n < OUTPUT_WIDTH; n = n + 1) begin : loop
        assign lfsr_out[n] = ^{(lfsr_in & lfsr_mask_state[n]), (data_in & lfsr_mask_data[n])};
    end

end else if (STYLE_INT == "LOOP") begin

    // use nested loops
    // very slow in iverilog
    // slightly smaller than generated code with ISE
    // same size as generated code with Quartus
    // --> better for synthesis

    reg [OUTPUT_WIDTH-1:0] lfsr_out_reg = 0;

    assign lfsr_out = lfsr_out_reg;

    always @* begin
        for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
            lfsr_out_reg[i] = 0;
            for (j = 0; j < STATE_WIDTH; j = j + 1) begin
                if (lfsr_mask_state[i][j]) begin
                    lfsr_out_reg[i] = lfsr_out_reg[i] ^ lfsr_in[j];
                end
            end
            for (j = 0; j < DATA_WIDTH; j = j + 1) begin
                if (lfsr_mask_data[i][j]) begin
                    lfsr_out_reg[i] = lfsr_out_reg[i] ^ data_in[j];
                end
            end
        end
    end

end else begin

    initial begin
        $error("Error: unknown style setting!");
        $finish;
    end

end

endgenerate

endmodule
