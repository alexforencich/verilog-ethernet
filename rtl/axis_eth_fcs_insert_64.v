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
 * AXI4-Stream Ethernet FCS inserter (64 bit datapath)
 */
module axis_eth_fcs_insert_64 #
(
    parameter ENABLE_PADDING = 0,
    parameter MIN_FRAME_LENGTH = 64
)
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
    output wire        busy
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_PAYLOAD = 2'd1,
    STATE_PAD = 2'd2,
    STATE_FCS = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [63:0] input_axis_tdata_masked;

reg [63:0] fcs_input_tdata;
reg [7:0]  fcs_input_tkeep;

reg [63:0] fcs_output_tdata_0;
reg [63:0] fcs_output_tdata_1;
reg [7:0] fcs_output_tkeep_0;
reg [7:0] fcs_output_tkeep_1;

reg [7:0] frame_ptr_reg = 0, frame_ptr_next;

reg [63:0] last_cycle_tdata_reg = 0, last_cycle_tdata_next;
reg [7:0] last_cycle_tkeep_reg = 0, last_cycle_tkeep_next;

reg busy_reg = 0;

reg input_axis_tready_reg = 0, input_axis_tready_next;

reg [31:0] crc_state = 32'hFFFFFFFF;

wire [31:0] crc_next0;
wire [31:0] crc_next1;
wire [31:0] crc_next2;
wire [31:0] crc_next3;
wire [31:0] crc_next4;
wire [31:0] crc_next5;
wire [31:0] crc_next6;
wire [31:0] crc_next7;

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

eth_crc_8
eth_crc_8_inst (
    .data_in(fcs_input_tdata[7:0]),
    .crc_state(crc_state),
    .crc_next(crc_next0)
);

eth_crc_16
eth_crc_16_inst (
    .data_in(fcs_input_tdata[15:0]),
    .crc_state(crc_state),
    .crc_next(crc_next1)
);

eth_crc_24
eth_crc_24_inst (
    .data_in(fcs_input_tdata[23:0]),
    .crc_state(crc_state),
    .crc_next(crc_next2)
);

eth_crc_32
eth_crc_32_inst (
    .data_in(fcs_input_tdata[31:0]),
    .crc_state(crc_state),
    .crc_next(crc_next3)
);

eth_crc_40
eth_crc_40_inst (
    .data_in(fcs_input_tdata[39:0]),
    .crc_state(crc_state),
    .crc_next(crc_next4)
);

eth_crc_48
eth_crc_48_inst (
    .data_in(fcs_input_tdata[47:0]),
    .crc_state(crc_state),
    .crc_next(crc_next5)
);

eth_crc_56
eth_crc_56_inst (
    .data_in(fcs_input_tdata[55:0]),
    .crc_state(crc_state),
    .crc_next(crc_next6)
);

eth_crc_64
eth_crc_64_inst (
    .data_in(fcs_input_tdata[63:0]),
    .crc_state(crc_state),
    .crc_next(crc_next7)
);

function [3:0] keep2count;
    input [7:0] k;
    case (k)
        8'b00000000: keep2count = 0;
        8'b00000001: keep2count = 1;
        8'b00000011: keep2count = 2;
        8'b00000111: keep2count = 3;
        8'b00001111: keep2count = 4;
        8'b00011111: keep2count = 5;
        8'b00111111: keep2count = 6;
        8'b01111111: keep2count = 7;
        8'b11111111: keep2count = 8;
    endcase
endfunction

function [7:0] count2keep;
    input [3:0] k;
    case (k)
        4'd0: count2keep = 8'b00000000;
        4'd1: count2keep = 8'b00000001;
        4'd2: count2keep = 8'b00000011;
        4'd3: count2keep = 8'b00000111;
        4'd4: count2keep = 8'b00001111;
        4'd5: count2keep = 8'b00011111;
        4'd6: count2keep = 8'b00111111;
        4'd7: count2keep = 8'b01111111;
        4'd8: count2keep = 8'b11111111;
    endcase
endfunction

// Mask input data
always @* begin
    input_axis_tdata_masked[ 7: 0] = input_axis_tkeep[0] ? input_axis_tdata[ 7: 0] : 8'd0;
    input_axis_tdata_masked[15: 8] = input_axis_tkeep[1] ? input_axis_tdata[15: 8] : 8'd0;
    input_axis_tdata_masked[23:16] = input_axis_tkeep[2] ? input_axis_tdata[23:16] : 8'd0;
    input_axis_tdata_masked[31:24] = input_axis_tkeep[3] ? input_axis_tdata[31:24] : 8'd0;
    input_axis_tdata_masked[39:32] = input_axis_tkeep[4] ? input_axis_tdata[39:32] : 8'd0;
    input_axis_tdata_masked[47:40] = input_axis_tkeep[5] ? input_axis_tdata[47:40] : 8'd0;
    input_axis_tdata_masked[55:48] = input_axis_tkeep[6] ? input_axis_tdata[55:48] : 8'd0;
    input_axis_tdata_masked[63:56] = input_axis_tkeep[7] ? input_axis_tdata[63:56] : 8'd0;
end

// FCS cycle calculation
always @* begin
    case (fcs_input_tkeep)
        8'b00000001: begin
            fcs_output_tdata_0 = {24'd0, ~crc_next0[31:0], fcs_input_tdata[7:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00011111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b00000011: begin
            fcs_output_tdata_0 = {16'd0, ~crc_next1[31:0], fcs_input_tdata[15:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b00111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b00000111: begin
            fcs_output_tdata_0 = {8'd0, ~crc_next2[31:0], fcs_input_tdata[23:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b01111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b00001111: begin
            fcs_output_tdata_0 = {~crc_next3[31:0], fcs_input_tdata[31:0]};
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00000000;
        end
        8'b00011111: begin
            fcs_output_tdata_0 = {~crc_next4[23:0], fcs_input_tdata[39:0]};
            fcs_output_tdata_1 = {56'd0, ~crc_next4[31:24]};
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00000001;
        end
        8'b00111111: begin
            fcs_output_tdata_0 = {~crc_next5[15:0], fcs_input_tdata[47:0]};
            fcs_output_tdata_1 = {48'd0, ~crc_next5[31:16]};
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00000011;
        end
        8'b01111111: begin
            fcs_output_tdata_0 = {~crc_next6[7:0], fcs_input_tdata[55:0]};
            fcs_output_tdata_1 = {40'd0, ~crc_next6[31:8]};
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00000111;
        end
        8'b11111111: begin
            fcs_output_tdata_0 = fcs_input_tdata;
            fcs_output_tdata_1 = {32'd0, ~crc_next7[31:0]};
            fcs_output_tkeep_0 = 8'b11111111;
            fcs_output_tkeep_1 = 8'b00001111;
        end
        default: begin
            fcs_output_tdata_0 = 0;
            fcs_output_tdata_1 = 0;
            fcs_output_tkeep_0 = 0;
            fcs_output_tkeep_1 = 0;
        end
    endcase
end

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 0;
    update_crc = 0;

    frame_ptr_next = frame_ptr_reg;

    last_cycle_tdata_next = last_cycle_tdata_reg;
    last_cycle_tkeep_next = last_cycle_tkeep_reg;

    input_axis_tready_next = 0;

    fcs_input_tdata = 0;
    fcs_input_tkeep = 0;

    output_axis_tdata_int = 0;
    output_axis_tkeep_int = 0;
    output_axis_tvalid_int = 0;
    output_axis_tlast_int = 0;
    output_axis_tuser_int = 0;

    case (state_reg)
        STATE_IDLE: begin
            // idle state - wait for data
            input_axis_tready_next = output_axis_tready_int_early;
            frame_ptr_next = 0;
            reset_crc = 1;

            output_axis_tdata_int = input_axis_tdata_masked;
            output_axis_tkeep_int = input_axis_tkeep;
            output_axis_tvalid_int = input_axis_tvalid;
            output_axis_tlast_int = 0;
            output_axis_tuser_int = 0;

            fcs_input_tdata = input_axis_tdata_masked;
            fcs_input_tkeep = input_axis_tkeep;

            if (input_axis_tready & input_axis_tvalid) begin
                reset_crc = 0;
                update_crc = 1;
                frame_ptr_next = keep2count(input_axis_tkeep);
                if (input_axis_tlast) begin
                    if (input_axis_tuser) begin
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = 1;
                        reset_crc = 1;
                        frame_ptr_next = 0;
                        state_next = STATE_IDLE;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                            output_axis_tkeep_int = 8'hff;
                            fcs_input_tkeep = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 8;

                            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                                input_axis_tready_next = 0;
                                state_next = STATE_PAD;
                            end else begin
                                output_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                                fcs_input_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                                output_axis_tdata_int = fcs_output_tdata_0;
                                last_cycle_tdata_next = fcs_output_tdata_1;
                                output_axis_tkeep_int = fcs_output_tkeep_0;
                                last_cycle_tkeep_next = fcs_output_tkeep_1;

                                reset_crc = 1;

                                if (fcs_output_tkeep_1 == 0) begin
                                    output_axis_tlast_int = 1;
                                    input_axis_tready_next = output_axis_tready_int_early;
                                    frame_ptr_next = 0;
                                    state_next = STATE_IDLE;
                                end else begin
                                    input_axis_tready_next = 0;
                                    state_next = STATE_FCS;
                                end
                            end
                        end else begin
                            output_axis_tdata_int = fcs_output_tdata_0;
                            last_cycle_tdata_next = fcs_output_tdata_1;
                            output_axis_tkeep_int = fcs_output_tkeep_0;
                            last_cycle_tkeep_next = fcs_output_tkeep_1;

                            reset_crc = 1;

                            if (fcs_output_tkeep_1 == 0) begin
                                output_axis_tlast_int = 1;
                                input_axis_tready_next = output_axis_tready_int_early;
                                frame_ptr_next = 0;
                                state_next = STATE_IDLE;
                            end else begin
                                input_axis_tready_next = 0;
                                state_next = STATE_FCS;
                            end
                        end
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

            output_axis_tdata_int = input_axis_tdata_masked;
            output_axis_tkeep_int = input_axis_tkeep;
            output_axis_tvalid_int = input_axis_tvalid;
            output_axis_tlast_int = 0;
            output_axis_tuser_int = 0;

            fcs_input_tdata = input_axis_tdata_masked;
            fcs_input_tkeep = input_axis_tkeep;

            if (input_axis_tready & input_axis_tvalid) begin
                update_crc = 1;
                frame_ptr_next = frame_ptr_reg + keep2count(input_axis_tkeep);
                if (input_axis_tlast) begin
                    if (input_axis_tuser) begin
                        output_axis_tlast_int = 1;
                        output_axis_tuser_int = 1;
                        reset_crc = 1;
                        frame_ptr_next = 0;
                        state_next = STATE_IDLE;
                    end else begin
                        if (ENABLE_PADDING && frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                            output_axis_tkeep_int = 8'hff;
                            fcs_input_tkeep = 8'hff;
                            frame_ptr_next = frame_ptr_reg + 8;

                            if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                                input_axis_tready_next = 0;
                                state_next = STATE_PAD;
                            end else begin
                                output_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                                fcs_input_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                                output_axis_tdata_int = fcs_output_tdata_0;
                                last_cycle_tdata_next = fcs_output_tdata_1;
                                output_axis_tkeep_int = fcs_output_tkeep_0;
                                last_cycle_tkeep_next = fcs_output_tkeep_1;

                                reset_crc = 1;

                                if (fcs_output_tkeep_1 == 0) begin
                                    output_axis_tlast_int = 1;
                                    input_axis_tready_next = output_axis_tready_int_early;
                                    frame_ptr_next = 0;
                                    state_next = STATE_IDLE;
                                end else begin
                                    input_axis_tready_next = 0;
                                    state_next = STATE_FCS;
                                end
                            end
                        end else begin
                            output_axis_tdata_int = fcs_output_tdata_0;
                            last_cycle_tdata_next = fcs_output_tdata_1;
                            output_axis_tkeep_int = fcs_output_tkeep_0;
                            last_cycle_tkeep_next = fcs_output_tkeep_1;

                            reset_crc = 1;

                            if (fcs_output_tkeep_1 == 0) begin
                                output_axis_tlast_int = 1;
                                input_axis_tready_next = output_axis_tready_int_early;
                                frame_ptr_next = 0;
                                state_next = STATE_IDLE;
                            end else begin
                                input_axis_tready_next = 0;
                                state_next = STATE_FCS;
                            end
                        end
                    end
                end else begin
                    state_next = STATE_PAYLOAD;
                end
            end else begin
                state_next = STATE_PAYLOAD;
            end
        end
        STATE_PAD: begin
            input_axis_tready_next = 0;

            output_axis_tdata_int = 0;
            output_axis_tkeep_int = 8'hff;
            output_axis_tvalid_int = 1;
            output_axis_tlast_int = 0;
            output_axis_tuser_int = 0;

            fcs_input_tdata = 0;
            fcs_input_tkeep = 8'hff;

            if (output_axis_tready_int) begin
                update_crc = 1;
                frame_ptr_next = frame_ptr_reg + 8;

                if (frame_ptr_next < MIN_FRAME_LENGTH-4) begin
                    state_next = STATE_PAD;
                end else begin
                    output_axis_tkeep_int = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));
                    fcs_input_tkeep = 8'hff >> (8-((MIN_FRAME_LENGTH-4) & 7));

                    output_axis_tdata_int = fcs_output_tdata_0;
                    last_cycle_tdata_next = fcs_output_tdata_1;
                    output_axis_tkeep_int = fcs_output_tkeep_0;
                    last_cycle_tkeep_next = fcs_output_tkeep_1;

                    reset_crc = 1;

                    if (fcs_output_tkeep_1 == 0) begin
                        output_axis_tlast_int = 1;
                        input_axis_tready_next = output_axis_tready_int_early;
                        frame_ptr_next = 0;
                        state_next = STATE_IDLE;
                    end else begin
                        input_axis_tready_next = 0;
                        state_next = STATE_FCS;
                    end
                end
            end else begin
                state_next = STATE_PAD;
            end
        end
        STATE_FCS: begin
            // last cycle
            input_axis_tready_next = 0;

            output_axis_tdata_int = last_cycle_tdata_reg;
            output_axis_tkeep_int = last_cycle_tkeep_reg;
            output_axis_tvalid_int = 1;
            output_axis_tlast_int = 1;
            output_axis_tuser_int = 0;

            if (output_axis_tready_int) begin
                reset_crc = 1;
                input_axis_tready_next = output_axis_tready_int_early;
                frame_ptr_next = 0;
                state_next = STATE_IDLE;
            end else begin
                state_next = STATE_FCS;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        
        frame_ptr_reg <= 0;

        last_cycle_tdata_reg <= 0;
        last_cycle_tkeep_reg <= 0;
        
        input_axis_tready_reg <= 0;

        busy_reg <= 0;

        crc_state <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        last_cycle_tdata_reg <= last_cycle_tdata_next;
        last_cycle_tkeep_reg <= last_cycle_tkeep_next;

        input_axis_tready_reg <= input_axis_tready_next;

        busy_reg <= state_next != STATE_IDLE;

        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next7;
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
