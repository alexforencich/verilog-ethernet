/*

Copyright (c) 2015-2017 Alex Forencich

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
 * AXI4-Stream Ethernet FCS checker
 */
module axis_eth_fcs_check
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [7:0]  input_axis_tdata,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,
    
    /*
     * AXI output
     */
    output wire [7:0]  output_axis_tdata,
    output wire        output_axis_tvalid,
    input  wire        output_axis_tready,
    output wire        output_axis_tlast,
    output wire        output_axis_tuser,

    /*
     * Status
     */
    output wire        busy,
    output wire        error_bad_fcs
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;
reg shift_in;
reg shift_reset;

reg [7:0] input_axis_tdata_d0 = 8'd0;
reg [7:0] input_axis_tdata_d1 = 8'd0;
reg [7:0] input_axis_tdata_d2 = 8'd0;
reg [7:0] input_axis_tdata_d3 = 8'd0;

reg input_axis_tvalid_d0 = 1'b0;
reg input_axis_tvalid_d1 = 1'b0;
reg input_axis_tvalid_d2 = 1'b0;
reg input_axis_tvalid_d3 = 1'b0;

reg busy_reg = 1'b0;
reg error_bad_fcs_reg = 1'b0, error_bad_fcs_next;

reg input_axis_tready_reg = 1'b0, input_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
wire [31:0] crc_next;

// internal datapath
reg [7:0] output_axis_tdata_int;
reg       output_axis_tvalid_int;
reg       output_axis_tready_int_reg = 1'b0;
reg       output_axis_tlast_int;
reg       output_axis_tuser_int;
wire      output_axis_tready_int_early;

assign input_axis_tready = input_axis_tready_reg;

assign busy = busy_reg;
assign error_bad_fcs = error_bad_fcs_reg;

lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .REVERSE(1),
    .DATA_WIDTH(8),
    .OUTPUT_WIDTH(32),
    .STYLE("AUTO")
)
eth_crc_8 (
    .data_in(input_axis_tdata_d3),
    .lfsr_in(crc_state),
    .lfsr_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;
    shift_in = 1'b0;
    shift_reset = 1'b0;

    input_axis_tready_next = 1'b0;

    output_axis_tdata_int = 8'd0;
    output_axis_tvalid_int = 1'b0;
    output_axis_tlast_int = 1'b0;
    output_axis_tuser_int = 1'b0;

    error_bad_fcs_next = 1'b0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            input_axis_tready_next = output_axis_tready_int_early;
            reset_crc = 1'b1;

            output_axis_tdata_int = input_axis_tdata_d3;
            output_axis_tvalid_int = input_axis_tvalid_d3 & input_axis_tvalid;
            output_axis_tlast_int = 1'b0;
            output_axis_tuser_int = 1'b0;

            if (input_axis_tready & input_axis_tvalid) begin
                shift_in = 1'b1;

                if (input_axis_tvalid_d3) begin
                    reset_crc = 1'b0;
                    update_crc = 1'b1;
                    if (input_axis_tlast) begin
                        shift_reset = 1'b1;
                        reset_crc = 1'b1;
                        output_axis_tlast_int = 1'b1;
                        output_axis_tuser_int = input_axis_tuser;
                        if ({input_axis_tdata, input_axis_tdata_d0, input_axis_tdata_d1, input_axis_tdata_d2} != ~crc_next) begin
                            output_axis_tuser_int = 1'b1;
                            error_bad_fcs_next = 1'b1;
                        end
                        input_axis_tready_next = output_axis_tready_int_early;
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_PAYLOAD;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            input_axis_tready_next = output_axis_tready_int_early;

            output_axis_tdata_int = input_axis_tdata_d3;
            output_axis_tvalid_int = input_axis_tvalid_d3 & input_axis_tvalid;
            output_axis_tlast_int = 1'b0;
            output_axis_tuser_int = 1'b0;

            if (input_axis_tready & input_axis_tvalid) begin
                shift_in = 1'b1;
                update_crc = 1'b1;
                if (input_axis_tlast) begin
                    shift_reset = 1'b1;
                    reset_crc = 1'b1;
                    output_axis_tlast_int = 1'b1;
                    output_axis_tuser_int = input_axis_tuser;
                    if ({input_axis_tdata, input_axis_tdata_d0, input_axis_tdata_d1, input_axis_tdata_d2} != ~crc_next) begin
                        output_axis_tuser_int = 1'b1;
                        error_bad_fcs_next = 1'b1;
                    end
                    input_axis_tready_next = output_axis_tready_int_early;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        input_axis_tready_reg <= 1'b0;

        busy_reg <= 1'b0;
        error_bad_fcs_reg <= 1'b0;

        input_axis_tvalid_d0 <= 1'b0;
        input_axis_tvalid_d1 <= 1'b0;
        input_axis_tvalid_d2 <= 1'b0;
        input_axis_tvalid_d3 <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        input_axis_tready_reg <= input_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;
        error_bad_fcs_reg <= error_bad_fcs_next;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next;
        end

        if (shift_reset) begin
            input_axis_tvalid_d0 <= 1'b0;
            input_axis_tvalid_d1 <= 1'b0;
            input_axis_tvalid_d2 <= 1'b0;
            input_axis_tvalid_d3 <= 1'b0;
        end else if (shift_in) begin
            input_axis_tvalid_d0 <= input_axis_tvalid;
            input_axis_tvalid_d1 <= input_axis_tvalid_d0;
            input_axis_tvalid_d2 <= input_axis_tvalid_d1;
            input_axis_tvalid_d3 <= input_axis_tvalid_d2;
        end
    end

    if (shift_in) begin
        input_axis_tdata_d0 <= input_axis_tdata;
        input_axis_tdata_d1 <= input_axis_tdata_d0;
        input_axis_tdata_d2 <= input_axis_tdata_d1;
        input_axis_tdata_d3 <= input_axis_tdata_d2;
    end
end

// output datapath logic
reg [7:0] output_axis_tdata_reg = 8'd0;
reg       output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;
reg       output_axis_tlast_reg = 1'b0;
reg       output_axis_tuser_reg = 1'b0;

reg [7:0] temp_axis_tdata_reg = 8'd0;
reg       temp_axis_tvalid_reg = 1'b0, temp_axis_tvalid_next;
reg       temp_axis_tlast_reg = 1'b0;
reg       temp_axis_tuser_reg = 1'b0;

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign output_axis_tdata = output_axis_tdata_reg;
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
        output_axis_tlast_reg <= output_axis_tlast_int;
        output_axis_tuser_reg <= output_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        output_axis_tdata_reg <= temp_axis_tdata_reg;
        output_axis_tlast_reg <= temp_axis_tlast_reg;
        output_axis_tuser_reg <= temp_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_axis_tdata_reg <= output_axis_tdata_int;
        temp_axis_tlast_reg <= output_axis_tlast_int;
        temp_axis_tuser_reg <= output_axis_tuser_int;
    end
end

endmodule
