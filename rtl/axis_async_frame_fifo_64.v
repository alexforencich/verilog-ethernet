/*

Copyright (c) 2014-2017 Alex Forencich

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
 * AXI4-Stream asynchronous frame FIFO (64 bit datapath)
 */
module axis_async_frame_fifo_64 #
(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter DROP_WHEN_FULL = 0
)
(
    /*
     * Common asynchronous reset
     */
    input  wire                   async_rst,

    /*
     * AXI input
     */
    input  wire                   input_clk,
    input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  input_axis_tkeep,
    input  wire                   input_axis_tvalid,
    output wire                   input_axis_tready,
    input  wire                   input_axis_tlast,
    input  wire                   input_axis_tuser,
    
    /*
     * AXI output
     */
    input  wire                   output_clk,
    output wire [DATA_WIDTH-1:0]  output_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  output_axis_tkeep,
    output wire                   output_axis_tvalid,
    input  wire                   output_axis_tready,
    output wire                   output_axis_tlast,

    /*
     * Status
     */
    output wire                   input_status_overflow,
    output wire                   input_status_bad_frame,
    output wire                   input_status_good_frame,
    output wire                   output_status_overflow,
    output wire                   output_status_bad_frame,
    output wire                   output_status_good_frame
);

reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_ptr_cur_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_cur_next;
reg [ADDR_WIDTH:0] wr_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_gray_next;
reg [ADDR_WIDTH:0] wr_addr_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_ptr_gray_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_gray_next;
reg [ADDR_WIDTH:0] rd_addr_reg = {ADDR_WIDTH+1{1'b0}};

reg [ADDR_WIDTH:0] wr_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2_reg = {ADDR_WIDTH+1{1'b0}};

reg input_rst_sync1_reg = 1'b1;
reg input_rst_sync2_reg = 1'b1;
reg input_rst_sync3_reg = 1'b1;
reg output_rst_sync1_reg = 1'b1;
reg output_rst_sync2_reg = 1'b1;
reg output_rst_sync3_reg = 1'b1;

reg [DATA_WIDTH+KEEP_WIDTH+1-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [DATA_WIDTH+KEEP_WIDTH+1-1:0] mem_read_data_reg = {DATA_WIDTH+KEEP_WIDTH+1{1'b0}};
reg mem_read_data_valid_reg = 1'b0, mem_read_data_valid_next;
wire [DATA_WIDTH+KEEP_WIDTH+1-1:0] mem_write_data;

reg [DATA_WIDTH+KEEP_WIDTH+1-1:0] output_data_reg = {DATA_WIDTH+KEEP_WIDTH+1{1'b0}};

reg output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;

// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
wire full = ((wr_ptr_gray_reg[ADDR_WIDTH] != rd_ptr_gray_sync2_reg[ADDR_WIDTH]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-1] != rd_ptr_gray_sync2_reg[ADDR_WIDTH-1]) &&
             (wr_ptr_gray_reg[ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_reg[ADDR_WIDTH-2:0]));
// empty when pointers match exactly
wire empty = rd_ptr_gray_reg == wr_ptr_gray_sync2_reg;
// overflow within packet
wire full_cur = ((wr_ptr_reg[ADDR_WIDTH] != wr_ptr_cur_reg[ADDR_WIDTH]) &&
                 (wr_ptr_reg[ADDR_WIDTH-1:0] == wr_ptr_cur_reg[ADDR_WIDTH-1:0]));

// control signals
reg write;
reg read;
reg store_output;

reg drop_frame_reg = 1'b0, drop_frame_next;
reg overflow_reg = 1'b0, overflow_next;
reg bad_frame_reg = 1'b0, bad_frame_next;
reg good_frame_reg = 1'b0, good_frame_next;

reg overflow_sync1_reg = 1'b0;
reg overflow_sync2_reg = 1'b0;
reg overflow_sync3_reg = 1'b0;
reg overflow_sync4_reg = 1'b0;
reg bad_frame_sync1_reg = 1'b0;
reg bad_frame_sync2_reg = 1'b0;
reg bad_frame_sync3_reg = 1'b0;
reg bad_frame_sync4_reg = 1'b0;
reg good_frame_sync1_reg = 1'b0;
reg good_frame_sync2_reg = 1'b0;
reg good_frame_sync3_reg = 1'b0;
reg good_frame_sync4_reg = 1'b0;

assign input_axis_tready = (~full | DROP_WHEN_FULL) & ~input_rst_sync3_reg;

assign output_axis_tvalid = output_axis_tvalid_reg;

assign mem_write_data = {input_axis_tlast, input_axis_tkeep, input_axis_tdata};
assign {output_axis_tlast, output_axis_tkeep, output_axis_tdata} = output_data_reg;

assign input_status_overflow = overflow_reg;
assign input_status_bad_frame = bad_frame_reg;
assign input_status_good_frame = good_frame_reg;

assign output_status_overflow = overflow_sync3_reg ^ overflow_sync4_reg;
assign output_status_bad_frame = bad_frame_sync3_reg ^ bad_frame_sync4_reg;
assign output_status_good_frame = good_frame_sync3_reg ^ good_frame_sync4_reg;

// reset synchronization
always @(posedge input_clk or posedge async_rst) begin
    if (async_rst) begin
        input_rst_sync1_reg <= 1'b1;
        input_rst_sync2_reg <= 1'b1;
        input_rst_sync3_reg <= 1'b1;
    end else begin
        input_rst_sync1_reg <= 1'b0;
        input_rst_sync2_reg <= input_rst_sync1_reg | output_rst_sync1_reg;
        input_rst_sync3_reg <= input_rst_sync2_reg;
    end
end

always @(posedge output_clk or posedge async_rst) begin
    if (async_rst) begin
        output_rst_sync1_reg <= 1'b1;
        output_rst_sync2_reg <= 1'b1;
        output_rst_sync3_reg <= 1'b1;
    end else begin
        output_rst_sync1_reg <= 1'b0;
        output_rst_sync2_reg <= input_rst_sync1_reg | output_rst_sync1_reg;
        output_rst_sync3_reg <= output_rst_sync2_reg;
    end
end

// Write logic
always @* begin
    write = 1'b0;

    drop_frame_next = 1'b0;
    overflow_next = 1'b0;
    bad_frame_next = 1'b0;
    good_frame_next = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_cur_next = wr_ptr_cur_reg;
    wr_ptr_gray_next = wr_ptr_gray_reg;

    if (input_axis_tvalid) begin
        // input data valid
        if (~full | DROP_WHEN_FULL) begin
            // not full, perform write
            if (full | full_cur | drop_frame_reg) begin
                // full, packet overflow, or currently dropping frame
                // drop frame
                drop_frame_next = 1'b1;
                if (input_axis_tlast) begin
                    // end of frame, reset write pointer
                    wr_ptr_cur_next = wr_ptr_reg;
                    drop_frame_next = 1'b0;
                    overflow_next = 1'b1;
                end
            end else begin
                write = 1'b1;
                wr_ptr_cur_next = wr_ptr_cur_reg + 1;
                if (input_axis_tlast) begin
                    // end of frame
                    if (input_axis_tuser) begin
                        // bad packet, reset write pointer
                        wr_ptr_cur_next = wr_ptr_reg;
                        bad_frame_next = 1'b1;
                    end else begin
                        // good packet, update write pointer
                        wr_ptr_next = wr_ptr_cur_reg + 1;
                        wr_ptr_gray_next = wr_ptr_next ^ (wr_ptr_next >> 1);
                        good_frame_next = 1'b1;
                    end
                end
            end
        end
    end
end

always @(posedge input_clk) begin
    if (input_rst_sync3_reg) begin
        wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};

        drop_frame_reg <= 1'b0;
        overflow_reg <= 1'b0;
        bad_frame_reg <= 1'b0;
        good_frame_reg <= 1'b0;
    end else begin
        wr_ptr_reg <= wr_ptr_next;
        wr_ptr_cur_reg <= wr_ptr_cur_next;
        wr_ptr_gray_reg <= wr_ptr_gray_next;

        drop_frame_reg <= drop_frame_next;
        overflow_reg <= overflow_next;
        bad_frame_reg <= bad_frame_next;
        good_frame_reg <= good_frame_next;
    end

    wr_addr_reg <= wr_ptr_cur_next;

    if (write) begin
        mem[wr_addr_reg[ADDR_WIDTH-1:0]] <= mem_write_data;
    end
end

// pointer synchronization
always @(posedge input_clk) begin
    if (input_rst_sync3_reg) begin
        rd_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg;
        rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg;
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        wr_ptr_gray_sync1_reg <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_sync2_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg;
        wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg;
    end
end

// status synchronization
always @(posedge input_clk) begin
    if (input_rst_sync3_reg) begin
        overflow_sync1_reg <= 1'b0;
        bad_frame_sync1_reg <= 1'b0;
        good_frame_sync1_reg <= 1'b0;
    end else begin
        overflow_sync1_reg <= overflow_sync1_reg ^ overflow_reg;
        bad_frame_sync1_reg <= bad_frame_sync1_reg ^ bad_frame_reg;
        good_frame_sync1_reg <= good_frame_sync1_reg ^ good_frame_reg;
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        overflow_sync2_reg <= 1'b0;
        overflow_sync3_reg <= 1'b0;
        bad_frame_sync2_reg <= 1'b0;
        bad_frame_sync3_reg <= 1'b0;
        good_frame_sync2_reg <= 1'b0;
        good_frame_sync3_reg <= 1'b0;
    end else begin
        overflow_sync2_reg <= overflow_sync1_reg;
        overflow_sync3_reg <= overflow_sync2_reg;
        overflow_sync4_reg <= overflow_sync3_reg;
        bad_frame_sync2_reg <= bad_frame_sync1_reg;
        bad_frame_sync3_reg <= bad_frame_sync2_reg;
        bad_frame_sync4_reg <= bad_frame_sync3_reg;
        good_frame_sync2_reg <= good_frame_sync1_reg;
        good_frame_sync3_reg <= good_frame_sync2_reg;
        good_frame_sync4_reg <= good_frame_sync3_reg;
    end
end

// Read logic
always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;
    rd_ptr_gray_next = rd_ptr_gray_reg;

    mem_read_data_valid_next = mem_read_data_valid_reg;

    if (store_output | ~mem_read_data_valid_reg) begin
        // output data not valid OR currently being transferred
        if (~empty) begin
            // not empty, perform read
            read = 1'b1;
            mem_read_data_valid_next = 1'b1;
            rd_ptr_next = rd_ptr_reg + 1;
            rd_ptr_gray_next = rd_ptr_next ^ (rd_ptr_next >> 1);
        end else begin
            // empty, invalidate
            mem_read_data_valid_next = 1'b0;
        end
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_reg <= {ADDR_WIDTH+1{1'b0}};
        mem_read_data_valid_reg <= 1'b0;
    end else begin
        rd_ptr_reg <= rd_ptr_next;
        rd_ptr_gray_reg <= rd_ptr_gray_next;
        mem_read_data_valid_reg <= mem_read_data_valid_next;
    end

    rd_addr_reg <= rd_ptr_next;

    if (read) begin
        mem_read_data_reg <= mem[rd_addr_reg[ADDR_WIDTH-1:0]];
    end
end

// Output register
always @* begin
    store_output = 1'b0;

    output_axis_tvalid_next = output_axis_tvalid_reg;

    if (output_axis_tready | ~output_axis_tvalid) begin
        store_output = 1'b1;
        output_axis_tvalid_next = mem_read_data_valid_reg;
    end
end

always @(posedge output_clk) begin
    if (output_rst_sync3_reg) begin
        output_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
    end

    if (store_output) begin
        output_data_reg <= mem_read_data_reg;
    end
end

endmodule
