/*

Copyright (c) 2015 Alex Forencich

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
 * AXI4-Stream Ethernet FCS checker (64 bit datapath)
 */
module axis_eth_fcs_check_64
(
    input  wire        clk,
    input  wire        rst,
    
    /*
     * AXI input
     */
    input  wire [63:0] input_axis_tdata,
    input  wire [7:0]  input_axis_tkeep,
    input  wire        input_axis_tvalid,
    output wire        input_axis_tready,
    input  wire        input_axis_tlast,
    input  wire        input_axis_tuser,
    
    /*
     * AXI output
     */
    output wire [63:0] output_axis_tdata,
    output wire [7:0]  output_axis_tkeep,
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
    STATE_PAYLOAD = 2'd1,
    STATE_LAST = 2'd2;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;
reg shift_in;
reg shift_reset;

reg [7:0] last_cycle_tkeep_reg = 0, last_cycle_tkeep_next;
reg last_cycle_tuser_reg = 0, last_cycle_tuser_next;

reg [63:0] input_axis_tdata_d0 = 0;
reg [7:0] input_axis_tkeep_d0 = 0;
reg input_axis_tvalid_d0 = 0;
reg input_axis_tuser_d0 = 0;

reg busy_reg = 0;
reg error_bad_fcs_reg = 0, error_bad_fcs_next;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;
reg [31:0] crc_state3 = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next7;

wire crc_valid0 = crc_next0 == ~32'h2144df1c;
wire crc_valid1 = crc_next1 == ~32'h2144df1c;
wire crc_valid2 = crc_next2 == ~32'h2144df1c;
wire crc_valid3 = crc_next3 == ~32'h2144df1c;

reg [31:0] crc_check = 0;

// internal datapath
reg [63:0] output_axis_tdata_int;
reg [7:0]  output_axis_tkeep_int;
reg        output_axis_tvalid_int;
reg        output_axis_tready_int = 0;
reg        output_axis_tlast_int;
reg        output_axis_tuser_int;
wire       output_axis_tready_int_early;

assign input_axis_tready = input_axis_tready_reg;

assign busy = busy_reg;
assign error_bad_fcs = error_bad_fcs_reg;

wire last_cycle = state_reg == STATE_LAST;

eth_crc_8
eth_crc_8_inst (
    .data_in(last_cycle ? input_axis_tdata_d0[39:32] : input_axis_tdata[7:0]),
    .crc_state(last_cycle ? crc_state3 : crc_state),
    .crc_next(crc_next0)
);

eth_crc_16
eth_crc_16_inst (
    .data_in(last_cycle ? input_axis_tdata_d0[47:32] : input_axis_tdata[15:0]),
    .crc_state(last_cycle ? crc_state3 : crc_state),
    .crc_next(crc_next1)
);

eth_crc_24
eth_crc_24_inst (
    .data_in(last_cycle ? input_axis_tdata_d0[55:32] : input_axis_tdata[23:0]),
    .crc_state(last_cycle ? crc_state3 : crc_state),
    .crc_next(crc_next2)
);

eth_crc_32
eth_crc_32_inst (
    .data_in(last_cycle ? input_axis_tdata_d0[63:32] : input_axis_tdata[31:0]),
    .crc_state(last_cycle ? crc_state3 : crc_state),
    .crc_next(crc_next3)
);

eth_crc_64
eth_crc_64_inst (
    .data_in(input_axis_tdata[63:0]),
    .crc_state(crc_state),
    .crc_next(crc_next7)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 0;
    update_crc = 0;
    shift_in = 0;
    shift_reset = 0;

    last_cycle_tkeep_next = last_cycle_tkeep_reg;
    last_cycle_tuser_next = last_cycle_tuser_reg;

    input_axis_tready_next = 0;

    output_axis_tdata_int = 0;
    output_axis_tkeep_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    error_bad_fcs_next = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            input_axis_tready_next = output_axis_tready_int_early;
            reset_crc = 1;

            output_axis_tdata_int = input_axis_tdata_d0;
            output_axis_tkeep_int = input_axis_tkeep_d0;
            output_axis_tvalid_int = input_axis_tvalid_d0 & input_axis_tvalid;
            output_axis_tlast_int = 0;
            output_axis_tuser_int = 0;

            if (input_axis_tready & input_axis_tvalid) begin
                shift_in = 1;
                reset_crc = 0;
                update_crc = 1;
                if (input_axis_tlast) begin
                    if (input_axis_tkeep[7:4] == 0) begin
                        shift_reset = 1;
                        reset_crc = 1;
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = input_axis_tuser;
                        output_axis_tkeep_int = {input_axis_tkeep[3:0], 4'b1111};
                        if ((input_axis_tkeep[3:0] == 4'b0001 & crc_valid0) ||
                            (input_axis_tkeep[3:0] == 4'b0011 & crc_valid1) ||
                            (input_axis_tkeep[3:0] == 4'b0111 & crc_valid2) ||
                            (input_axis_tkeep[3:0] == 4'b1111 & crc_valid3)) begin
                            // CRC valid
                        end else begin
                            output_axis_tuser_int = 1;
                            error_bad_fcs_next = 1;
                        end
                        input_axis_tready_next = output_axis_tready_int_early;
                        state_next = STATE_IDLE;
                    end else begin
                        last_cycle_tkeep_next = {4'b0000, input_axis_tkeep[7:4]};
                        last_cycle_tuser_next = input_axis_tuser;
                        input_axis_tready_next = 0;
                        state_next = STATE_LAST;
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_IDLE;
            end
        end
        STATE_PAYLOAD: begin
            // transfer payload
            input_axis_tready_next = output_axis_tready_int_early;

            output_axis_tdata_int = input_axis_tdata_d0;
            output_axis_tkeep_int = input_axis_tkeep_d0;
            output_axis_tvalid_int = input_axis_tvalid_d0 & input_axis_tvalid;
            output_axis_tlast_int = 0;
            output_axis_tuser_int = 0;

            if (input_axis_tready & input_axis_tvalid) begin
                shift_in = 1;
                update_crc = 1;
                if (input_axis_tlast) begin
                    if (input_axis_tkeep[7:4] == 0) begin
                        shift_reset = 1;
                        reset_crc = 1;
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = input_axis_tuser;
                        output_axis_tkeep_int = {input_axis_tkeep[3:0], 4'b1111};
                        if ((input_axis_tkeep[3:0] == 4'b0001 & crc_valid0) ||
                            (input_axis_tkeep[3:0] == 4'b0011 & crc_valid1) ||
                            (input_axis_tkeep[3:0] == 4'b0111 & crc_valid2) ||
                            (input_axis_tkeep[3:0] == 4'b1111 & crc_valid3)) begin
                            // CRC valid
                        end else begin
                            output_axis_tuser_int = 1;
                            error_bad_fcs_next = 1;
                        end
                        input_axis_tready_next = output_axis_tready_int_early;
                        state_next = STATE_IDLE;
                    end else begin
                        last_cycle_tkeep_next = {4'b0000, input_axis_tkeep[7:4]};
                        last_cycle_tuser_next = input_axis_tuser;
                        input_axis_tready_next = 0;
                        state_next = STATE_LAST;
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_LAST: begin
            // last cycle
            input_axis_tready_next = 0;

            output_axis_tdata_int = input_axis_tdata_d0;
            output_axis_tkeep_int = last_cycle_tkeep_reg;
            output_axis_tvalid_int = input_axis_tvalid_d0;
            output_axis_tlast_int = 1;
            output_axis_tuser_int = last_cycle_tuser_reg;

            if ((input_axis_tkeep_d0[7:4] == 4'b0001 & crc_valid0) ||
                (input_axis_tkeep_d0[7:4] == 4'b0011 & crc_valid1) ||
                (input_axis_tkeep_d0[7:4] == 4'b0111 & crc_valid2) ||
                (input_axis_tkeep_d0[7:4] == 4'b1111 & crc_valid3)) begin
                // CRC valid
            end else begin
                output_axis_tuser_int = 1;
                error_bad_fcs_next = 1;
            end

            if (output_axis_tready_int) begin
                shift_reset = 1;
                reset_crc = 1;
                input_axis_tready_next = output_axis_tready_int_early;
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_LAST;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        last_cycle_tkeep_reg <= 0;
        last_cycle_tuser_reg <= 0;
        
        input_axis_tready_reg <= 0;

        busy_reg <= 0;
        error_bad_fcs_reg <= 0;

        crc_state <= 32'hFFFFFFFF;
        crc_state3 <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        last_cycle_tkeep_reg <= last_cycle_tkeep_next;
        last_cycle_tuser_reg <= last_cycle_tuser_next;

        input_axis_tready_reg <= input_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;
        error_bad_fcs_reg <= error_bad_fcs_next;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
            crc_state3 <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next7;
            crc_state3 <= crc_next3;
        end

        if (shift_reset) begin
            input_axis_tvalid_d0 <= 0;
        end else if (shift_in) begin
            input_axis_tdata_d0 <= input_axis_tdata;
            input_axis_tkeep_d0 <= input_axis_tkeep;
            input_axis_tvalid_d0 <= input_axis_tvalid;
            input_axis_tuser_d0 <= input_axis_tuser;
        end
    end
end

// output datapath logic
reg [63:0] output_axis_tdata_reg = 0;
reg [7:0]  output_axis_tkeep_reg = 0;
reg        output_axis_tvalid_reg = 0;
reg        output_axis_tlast_reg = 0;
reg        output_axis_tuser_reg = 0;

reg [63:0] temp_axis_tdata_reg = 0;
reg [7:0]  temp_axis_tkeep_reg = 0;
reg        temp_axis_tvalid_reg = 0;
reg        temp_axis_tlast_reg = 0;
reg        temp_axis_tuser_reg = 0;

assign output_axis_tdata = output_axis_tdata_reg;
assign output_axis_tkeep = output_axis_tkeep_reg;
assign output_axis_tvalid = output_axis_tvalid_reg;
assign output_axis_tlast = output_axis_tlast_reg;
assign output_axis_tuser = output_axis_tuser_reg;

// enable ready input next cycle if output is ready or if there is space in both output registers or if there is space in the temp register that will not be filled next cycle
assign output_axis_tready_int_early = output_axis_tready | (~temp_axis_tvalid_reg & ~output_axis_tvalid_reg) | (~temp_axis_tvalid_reg & ~output_axis_tvalid_int);

always @(posedge clk) begin
    if (rst) begin
        output_axis_tdata_reg <= 0;
        output_axis_tkeep_reg <= 0;
        output_axis_tvalid_reg <= 0;
        output_axis_tlast_reg <= 0;
        output_axis_tuser_reg <= 0;
        output_axis_tready_int <= 0;
        temp_axis_tdata_reg <= 0;
        temp_axis_tkeep_reg <= 0;
        temp_axis_tvalid_reg <= 0;
        temp_axis_tlast_reg <= 0;
        temp_axis_tuser_reg <= 0;
    end else begin
        // transfer sink ready state to source
        output_axis_tready_int <= output_axis_tready_int_early;

        if (output_axis_tready_int) begin
            // input is ready
            if (output_axis_tready | ~output_axis_tvalid_reg) begin
                // output is ready or currently not valid, transfer data to output
                output_axis_tdata_reg <= output_axis_tdata_int;
                output_axis_tkeep_reg <= output_axis_tkeep_int;
                output_axis_tvalid_reg <= output_axis_tvalid_int;
                output_axis_tlast_reg <= output_axis_tlast_int;
                output_axis_tuser_reg <= output_axis_tuser_int;
            end else begin
                // output is not ready and currently valid, store input in temp
                temp_axis_tdata_reg <= output_axis_tdata_int;
                temp_axis_tkeep_reg <= output_axis_tkeep_int;
                temp_axis_tvalid_reg <= output_axis_tvalid_int;
                temp_axis_tlast_reg <= output_axis_tlast_int;
                temp_axis_tuser_reg <= output_axis_tuser_int;
            end
        end else if (output_axis_tready) begin
            // input is not ready, but output is ready
            output_axis_tdata_reg <= temp_axis_tdata_reg;
            output_axis_tkeep_reg <= temp_axis_tkeep_reg;
            output_axis_tvalid_reg <= temp_axis_tvalid_reg;
            output_axis_tlast_reg <= temp_axis_tlast_reg;
            output_axis_tuser_reg <= temp_axis_tuser_reg;
            temp_axis_tdata_reg <= 0;
            temp_axis_tkeep_reg <= 0;
            temp_axis_tvalid_reg <= 0;
            temp_axis_tlast_reg <= 0;
            temp_axis_tuser_reg <= 0;
        end
    end
end

endmodule
