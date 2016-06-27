/*

Copyright (c) 2014-2016 Alex Forencich

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
 * AXI4-Stream bus width adapter
 */
module axis_adapter #
(
    parameter INPUT_DATA_WIDTH = 8,
    parameter INPUT_KEEP_WIDTH = (INPUT_DATA_WIDTH/8),
    parameter OUTPUT_DATA_WIDTH = 8,
    parameter OUTPUT_KEEP_WIDTH = (OUTPUT_DATA_WIDTH/8)
)
(
    input  wire                          clk,
    input  wire                          rst,

    /*
     * AXI input
     */
    input  wire [INPUT_DATA_WIDTH-1:0]   input_axis_tdata,
    input  wire [INPUT_KEEP_WIDTH-1:0]   input_axis_tkeep,
    input  wire                          input_axis_tvalid,
    output wire                          input_axis_tready,
    input  wire                          input_axis_tlast,
    input  wire                          input_axis_tuser,

    /*
     * AXI output
     */
    output wire [OUTPUT_DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [OUTPUT_KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                          output_axis_tvalid,
    input  wire                          output_axis_tready,
    output wire                          output_axis_tlast,
    output wire                          output_axis_tuser
);

// bus word sizes (must be identical)
localparam INPUT_DATA_WORD_SIZE = INPUT_DATA_WIDTH / INPUT_KEEP_WIDTH;
localparam OUTPUT_DATA_WORD_SIZE = OUTPUT_DATA_WIDTH / OUTPUT_KEEP_WIDTH;
// output bus is wider
localparam EXPAND_BUS = OUTPUT_KEEP_WIDTH > INPUT_KEEP_WIDTH;
// total data and keep widths
localparam DATA_WIDTH = EXPAND_BUS ? OUTPUT_DATA_WIDTH : INPUT_DATA_WIDTH;
localparam KEEP_WIDTH = EXPAND_BUS ? OUTPUT_KEEP_WIDTH : INPUT_KEEP_WIDTH;
// required number of cycles to match widths
localparam CYCLE_COUNT = EXPAND_BUS ? (OUTPUT_KEEP_WIDTH / INPUT_KEEP_WIDTH) : (INPUT_KEEP_WIDTH / OUTPUT_KEEP_WIDTH);
// data width and keep width per cycle
localparam CYCLE_DATA_WIDTH = DATA_WIDTH / CYCLE_COUNT;
localparam CYCLE_KEEP_WIDTH = KEEP_WIDTH / CYCLE_COUNT;

// bus width assertions
initial begin
    if (INPUT_DATA_WORD_SIZE * INPUT_KEEP_WIDTH != INPUT_DATA_WIDTH) begin
        $error("Error: input data width not evenly divisble");
        $finish;
    end

    if (OUTPUT_DATA_WORD_SIZE * OUTPUT_KEEP_WIDTH != OUTPUT_DATA_WIDTH) begin
        $error("Error: output data width not evenly divisble");
        $finish;
    end

    if (INPUT_DATA_WORD_SIZE != OUTPUT_DATA_WORD_SIZE) begin
        $error("Error: word size mismatch");
        $finish;
    end
end

// state register
localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_TRANSFER_IN = 3'd1,
    STATE_TRANSFER_OUT = 3'd2;

reg [2:0] state_reg = STATE_IDLE, state_next;

reg [7:0] cycle_count_reg = 8'd0, cycle_count_next;

reg last_cycle;

reg [DATA_WIDTH-1:0] temp_tdata_reg = {DATA_WIDTH{1'b0}}, temp_tdata_next;
reg [KEEP_WIDTH-1:0] temp_tkeep_reg = {KEEP_WIDTH{1'b0}}, temp_tkeep_next;
reg                  temp_tlast_reg = 1'b0, temp_tlast_next;
reg                  temp_tuser_reg = 1'b0, temp_tuser_next;

// internal datapath
reg [OUTPUT_DATA_WIDTH-1:0] output_axis_tdata_int;
reg [OUTPUT_KEEP_WIDTH-1:0] output_axis_tkeep_int;
reg                         output_axis_tvalid_int;
reg                         output_axis_tready_int_reg = 1'b0;
reg                         output_axis_tlast_int;
reg                         output_axis_tuser_int;
wire                        output_axis_tready_int_early;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

assign input_axis_tready = input_axis_tready_reg;

always @* begin
    state_next = STATE_IDLE;

    cycle_count_next = cycle_count_reg;

    temp_tdata_next = temp_tdata_reg;
    temp_tkeep_next = temp_tkeep_reg;
    temp_tlast_next = temp_tlast_reg;
    temp_tuser_next = temp_tuser_reg;

    output_axis_tdata_int = {OUTPUT_DATA_WIDTH{1'b0}};
    output_axis_tkeep_int = {OUTPUT_KEEP_WIDTH{1'b0}};
    output_axis_tvalid_int = 1'b0;
    output_axis_tlast_int = 1'b0;
    output_axis_tuser_int = 1'b0;

    input_axis_tready_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - no data in registers
            if (CYCLE_COUNT == 1) begin
                // output and input same width - just act like a register

                // accept data next cycle if output register ready next cycle
                input_axis_tready_next = output_axis_tready_int_early;

                // transfer through
                output_axis_tdata_int = input_axis_tdata;
                output_axis_tkeep_int = input_axis_tkeep;
                output_axis_tvalid_int = input_axis_tvalid;
                output_axis_tlast_int = input_axis_tlast;
                output_axis_tuser_int = input_axis_tuser;

                state_next = STATE_IDLE;
            end else if (EXPAND_BUS) begin
                // output bus is wider

                // accept new data
                input_axis_tready_next = 1'b1;

                if (input_axis_tready & input_axis_tvalid) begin
                    // word transfer in - store it in data register
                    
                    // pass complete input word, zero-extended to temp register
                    temp_tdata_next = input_axis_tdata;
                    temp_tkeep_next = input_axis_tkeep;
                    temp_tlast_next = input_axis_tlast;
                    temp_tuser_next = input_axis_tuser;

                    // first input cycle complete
                    cycle_count_next = 8'd1;

                    if (input_axis_tlast) begin
                        // got last signal on first cycle, so output it
                        input_axis_tready_next = 1'b0;
                        state_next = STATE_TRANSFER_OUT;
                    end else begin
                        // otherwise, transfer in the rest of the words
                        input_axis_tready_next = 1'b1;
                        state_next = STATE_TRANSFER_IN;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                // output bus is narrower

                // accept new data
                input_axis_tready_next = 1'b1;

                if (input_axis_tready & input_axis_tvalid) begin
                    // word transfer in - store it in data register
                    cycle_count_next = 8'd0;

                    // is this the last cycle?
                    if (CYCLE_COUNT == 1) begin
                        // last cycle by counter value
                        last_cycle = 1'b1;
                    end else if (input_axis_tkeep[CYCLE_KEEP_WIDTH-1:0] != {CYCLE_KEEP_WIDTH{1'b1}}) begin
                        // last cycle by tkeep fall in current cycle
                        last_cycle = 1'b1;
                    end else if (input_axis_tkeep[(CYCLE_KEEP_WIDTH*2)-1:CYCLE_KEEP_WIDTH] == {CYCLE_KEEP_WIDTH{1'b0}}) begin
                        // last cycle by tkeep fall at end of current cycle
                        last_cycle = 1'b1;
                    end else begin
                        last_cycle = 1'b0;
                    end

                    // pass complete input word, zero-extended to temp register
                    temp_tdata_next = input_axis_tdata;
                    temp_tkeep_next = input_axis_tkeep;
                    temp_tlast_next = input_axis_tlast;
                    temp_tuser_next = input_axis_tuser;

                    // short-circuit and get first word out the door
                    output_axis_tdata_int = input_axis_tdata[CYCLE_DATA_WIDTH-1:0];
                    output_axis_tkeep_int = input_axis_tkeep[CYCLE_KEEP_WIDTH-1:0];
                    output_axis_tvalid_int = 1'b1;
                    output_axis_tlast_int = input_axis_tlast & last_cycle;
                    output_axis_tuser_int = input_axis_tuser & last_cycle;

                    if (output_axis_tready_int_reg) begin
                        // if output register is ready for first word, then move on to the next one
                        cycle_count_next = 8'd1;
                    end

                    if (!last_cycle || !output_axis_tready_int_reg) begin
                        // continue outputting words
                        input_axis_tready_next = 1'b0;
                        state_next = STATE_TRANSFER_OUT;
                    end else begin
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        end
        STATE_TRANSFER_IN: begin
            // transfer word to temp registers
            // only used when output is wider

            // accept new data
            input_axis_tready_next = 1'b1;

            if (input_axis_tready & input_axis_tvalid) begin
                // word transfer in - store in data register
                
                temp_tdata_next[cycle_count_reg*CYCLE_DATA_WIDTH +: CYCLE_DATA_WIDTH] = input_axis_tdata;
                temp_tkeep_next[cycle_count_reg*CYCLE_KEEP_WIDTH +: CYCLE_KEEP_WIDTH] = input_axis_tkeep;
                temp_tlast_next = input_axis_tlast;
                temp_tuser_next = input_axis_tuser;

                cycle_count_next = cycle_count_reg + 1;
                
                if ((cycle_count_reg == CYCLE_COUNT-1) | input_axis_tlast) begin
                    // terminated by counter or tlast signal, output complete word
                    // read input word next cycle if output will be ready
                    input_axis_tready_next = output_axis_tready_int_early;
                    state_next = STATE_TRANSFER_OUT;
                end else begin
                    // more words to read
                    input_axis_tready_next = 1'b1;
                    state_next = STATE_TRANSFER_IN;
                end
            end else begin
                state_next = STATE_TRANSFER_IN;
            end
        end
        STATE_TRANSFER_OUT: begin
            // transfer word to output registers

            if (EXPAND_BUS) begin
                // output bus is wider
                
                // do not accept new data
                input_axis_tready_next = 1'b0;

                // single-cycle output of entire stored word (output wider)
                output_axis_tdata_int = temp_tdata_reg;
                output_axis_tkeep_int = temp_tkeep_reg;
                output_axis_tvalid_int = 1'b1;
                output_axis_tlast_int = temp_tlast_reg;
                output_axis_tuser_int = temp_tuser_reg;
            
                if (output_axis_tready_int_reg) begin
                    // word transfer out

                    if (input_axis_tready & input_axis_tvalid) begin
                        // word transfer in

                        // pass complete input word, zero-extended to temp register
                        temp_tdata_next = input_axis_tdata;
                        temp_tkeep_next = input_axis_tkeep;
                        temp_tlast_next = input_axis_tlast;
                        temp_tuser_next = input_axis_tuser;

                        // first input cycle complete
                        cycle_count_next = 8'd1;

                        if (input_axis_tlast) begin
                            // got last signal on first cycle, so output it
                            input_axis_tready_next = 1'b0;
                            state_next = STATE_TRANSFER_OUT;
                        end else begin
                            // otherwise, transfer in the rest of the words
                            input_axis_tready_next = 1'b1;
                            state_next = STATE_TRANSFER_IN;
                        end
                    end else begin
                        input_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_TRANSFER_OUT;
                end
            end else begin
                // output bus is narrower

                // do not accept new data
                input_axis_tready_next = 1'b0;

                // is this the last cycle?
                if (cycle_count_reg == CYCLE_COUNT-1) begin
                    // last cycle by counter value
                    last_cycle = 1'b1;
                end else if (temp_tkeep_reg[cycle_count_reg*CYCLE_KEEP_WIDTH +: CYCLE_KEEP_WIDTH] != {CYCLE_KEEP_WIDTH{1'b1}}) begin
                    // last cycle by tkeep fall in current cycle
                    last_cycle = 1'b1;
                end else if (temp_tkeep_reg[(cycle_count_reg+1)*CYCLE_KEEP_WIDTH +: CYCLE_KEEP_WIDTH] == {CYCLE_KEEP_WIDTH{1'b0}}) begin
                    // last cycle by tkeep fall at end of current cycle
                    last_cycle = 1'b1;
                end else begin
                    last_cycle = 1'b0;
                end

                // output current part of stored word (output narrower)
                output_axis_tdata_int = temp_tdata_reg[cycle_count_reg*CYCLE_DATA_WIDTH +: CYCLE_DATA_WIDTH];
                output_axis_tkeep_int = temp_tkeep_reg[cycle_count_reg*CYCLE_KEEP_WIDTH +: CYCLE_KEEP_WIDTH];
                output_axis_tvalid_int = 1'b1;
                output_axis_tlast_int = temp_tlast_reg & last_cycle;
                output_axis_tuser_int = temp_tuser_reg & last_cycle;

                if (output_axis_tready_int_reg) begin
                    // word transfer out

                    cycle_count_next = cycle_count_reg + 1;

                    if (last_cycle) begin
                        // terminated by counter or tlast signal
                        
                        input_axis_tready_next = 1'b1;
                        state_next = STATE_IDLE;
                    end else begin
                        // more words to write
                        state_next = STATE_TRANSFER_OUT;
                    end
                end else begin
                    state_next = STATE_TRANSFER_OUT;
                end 
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        cycle_count_reg <= 8'd0;
        input_axis_tready_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        input_axis_tready_reg <= input_axis_tready_next;

        cycle_count_reg <= cycle_count_next;
    end

    temp_tdata_reg <= temp_tdata_next;
    temp_tkeep_reg <= temp_tkeep_next;
    temp_tlast_reg <= temp_tlast_next;
    temp_tuser_reg <= temp_tuser_next;    
end

// output datapath logic
reg [OUTPUT_DATA_WIDTH-1:0] output_axis_tdata_reg = {OUTPUT_DATA_WIDTH{1'b0}};
reg [OUTPUT_KEEP_WIDTH-1:0] output_axis_tkeep_reg = {OUTPUT_KEEP_WIDTH{1'b0}};
reg                         output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg                         output_axis_tlast_reg = 1'b0;
reg                         output_axis_tuser_reg = 1'b0;

reg [OUTPUT_DATA_WIDTH-1:0] temp_axis_tdata_reg = {OUTPUT_DATA_WIDTH{1'b0}};
reg [OUTPUT_KEEP_WIDTH-1:0] temp_axis_tkeep_reg = {OUTPUT_KEEP_WIDTH{1'b0}};
reg                         temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg                         temp_axis_tlast_reg = 1'b0;
reg                         temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & (~output_axis_tvalid_reg | ~output_axis_tvalid_int));

always @* begin
    // transfer sink ready state to source
    output_axis_tvalid_next = output_axis_tvalid_reg;
    temp_axis_tvalid_next = temp_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;
    
    if (output_axis_tready_int_reg) begin
        // input is ready
        if (output_axis_tready | ~output_axis_tvalid_reg) begin
            // output is ready or currently not valid, transfer data to output
            output_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_axis_tvalid_next = output_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if (output_axis_tready) begin
        // input is not ready, but output is ready
        output_axis_tvalid_next = temp_axis_tvalid_reg;
        temp_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_axis_tvalid_reg <= 1'b0;
        output_axis_tready_int_reg <= 1'b0;
        temp_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
        output_axis_tready_int_reg <= output_axis_tready_int_early;
        temp_axis_tvalid_reg <= temp_axis_tvalid_next;
    end

    // datapath
    if (store_axis_int_to_output) begin
        output_axis_tdata_reg <= output_axis_tdata_int;
        output_axis_tkeep_reg <= output_axis_tkeep_int;
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tkeep_reg <= temp_axis_tkeep_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tkeep_reg <= output_axis_tkeep_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
