/*

Copyright (c) 2024 Alex Forencich

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
`timescale 1ns / 1fs
`default_nettype none

/*
 * PTP time distribution ToD timestamp reconstruction module
 */
module ptp_td_rel2tod #
(
    parameter TS_FNS_W = 16,
    parameter TS_REL_NS_W = 32,
    parameter TS_TOD_S_W = 48,
    parameter TS_REL_W = TS_REL_NS_W + TS_FNS_W,
    parameter TS_TOD_W = TS_TOD_S_W + 32 + TS_FNS_W,
    parameter TS_TAG_W = 8,
    parameter TD_SDI_PIPELINE = 2
)
(
    input  wire                 clk,
    input  wire                 rst,

    /*
     * PTP clock interface
     */
    input  wire                 ptp_clk,
    input  wire                 ptp_rst,
    input  wire                 ptp_td_sdi,

    /*
     * Timestamp conversion
     */
    input  wire [TS_REL_W-1:0]  input_ts_rel,
    input  wire [TS_TAG_W-1:0]  input_ts_tag,
    input  wire                 input_ts_valid,
    output wire [TS_TOD_W-1:0]  output_ts_tod,
    output wire [TS_TAG_W-1:0]  output_ts_tag,
    output wire                 output_ts_valid
);

localparam TS_TOD_NS_W = 30;
localparam TS_NS_W = TS_TOD_NS_W+1;

localparam [30:0] NS_PER_S = 31'd1_000_000_000;

// pipeline to facilitate long input path
wire ptp_td_sdi_pipe[0:TD_SDI_PIPELINE];

assign ptp_td_sdi_pipe[0] = ptp_td_sdi;

generate

genvar n;

for (n = 0; n < TD_SDI_PIPELINE; n = n + 1) begin : pipe_stage

    (* shreg_extract = "no" *)
    reg ptp_td_sdi_reg = 0;

    assign ptp_td_sdi_pipe[n+1] = ptp_td_sdi_reg;

    always @(posedge ptp_clk) begin
        ptp_td_sdi_reg <= ptp_td_sdi_pipe[n];
    end

end

endgenerate

// deserialize data
reg [15:0] td_shift_reg = 0;
reg [4:0] bit_cnt_reg = 0;
reg td_valid_reg = 1'b0;
reg [3:0] td_index_reg = 0;
reg [3:0] td_msg_reg = 0;

reg [15:0] td_tdata_reg = 0;
reg td_tvalid_reg = 1'b0;
reg td_tlast_reg = 1'b0;
reg [7:0] td_tid_reg = 0;
reg td_sync_reg = 1'b0;

always @(posedge ptp_clk) begin
    td_shift_reg <= {ptp_td_sdi_pipe[TD_SDI_PIPELINE], td_shift_reg[15:1]};

    td_tvalid_reg <= 1'b0;

    if (bit_cnt_reg) begin
        bit_cnt_reg <= bit_cnt_reg - 1;
    end else begin
        td_valid_reg <= 1'b0;
        if (td_valid_reg) begin
            td_tdata_reg <= td_shift_reg;
            td_tvalid_reg <= 1'b1;
            td_tlast_reg <= ptp_td_sdi_pipe[TD_SDI_PIPELINE];
            td_tid_reg <= {td_msg_reg, td_index_reg};
            if (td_index_reg == 0) begin
                td_msg_reg <= td_shift_reg[3:0];
                td_tid_reg[7:4] <= td_shift_reg[3:0];
            end
            td_index_reg <= td_index_reg + 1;
            td_sync_reg = !td_sync_reg;
        end
        if (ptp_td_sdi_pipe[TD_SDI_PIPELINE] == 0) begin
            bit_cnt_reg <= 16;
            td_valid_reg <= 1'b1;
        end else begin
            td_index_reg <= 0;
        end
    end

    if (ptp_rst) begin
        bit_cnt_reg <= 0;
        td_valid_reg <= 1'b0;

        td_tvalid_reg <= 1'b0;
    end
end

// sync TD data
reg [15:0] dst_td_tdata_reg = 0;
reg dst_td_tvalid_reg = 1'b0;
reg [7:0] dst_td_tid_reg = 0;

(* shreg_extract = "no" *)
reg td_sync_sync1_reg = 1'b0;
(* shreg_extract = "no" *)
reg td_sync_sync2_reg = 1'b0;
(* shreg_extract = "no" *)
reg td_sync_sync3_reg = 1'b0;

always @(posedge clk) begin
    td_sync_sync1_reg <= td_sync_reg;
    td_sync_sync2_reg <= td_sync_sync1_reg;
    td_sync_sync3_reg <= td_sync_sync2_reg;
end

always @(posedge clk) begin
    dst_td_tvalid_reg <= 1'b0;

    if (td_sync_sync3_reg ^ td_sync_sync2_reg) begin
        dst_td_tdata_reg <= td_tdata_reg;
        dst_td_tvalid_reg <= 1'b1;
        dst_td_tid_reg <= td_tid_reg;
    end

    if (rst) begin
        dst_td_tvalid_reg <= 1'b0;
    end
end

reg ts_sel_reg = 0;

reg [47:0] ts_tod_s_0_reg = 0;
reg [31:0] ts_tod_offset_ns_0_reg = 0;
reg [47:0] ts_tod_s_1_reg = 0;
reg [31:0] ts_tod_offset_ns_1_reg = 0;

reg [TS_TOD_S_W-1:0] output_ts_tod_s_reg = 0, output_ts_tod_s_next;
reg [TS_TOD_NS_W-1:0] output_ts_tod_ns_reg = 0, output_ts_tod_ns_next;
reg [TS_FNS_W-1:0] output_ts_fns_reg = 0, output_ts_fns_next;
reg [TS_TAG_W-1:0] output_ts_tag_reg = 0, output_ts_tag_next;
reg output_ts_valid_reg = 0, output_ts_valid_next;

reg [TS_NS_W-1:0] ts_tod_ns_0;
reg [TS_NS_W-1:0] ts_tod_ns_1;

assign output_ts_tod = {output_ts_tod_s_reg, 2'b00, output_ts_tod_ns_reg, output_ts_fns_reg};
assign output_ts_tag = output_ts_tag_reg;
assign output_ts_valid = output_ts_valid_reg;

always @* begin
    // reconstruct timestamp
    // apply both offsets
    ts_tod_ns_0 = (input_ts_rel >> TS_FNS_W) + ts_tod_offset_ns_0_reg;
    ts_tod_ns_1 = (input_ts_rel >> TS_FNS_W) + ts_tod_offset_ns_1_reg;

    // pick the correct result
    // 2 MSB clear = lower half of range (0-536,870,911)
    // 1 MSB clear = upper half of range, but could also be over 1 billion (536,870,912-1,073,741,823)
    // 1 MSB set = overflow or underflow
    // prefer 2 MSB clear over 1 MSB clear if neither result was overflow or underflow
    if (ts_tod_ns_0[30:29] == 0 || (ts_tod_ns_0[30] == 0 && ts_tod_ns_1[30:29] != 0)) begin
        output_ts_tod_s_next = ts_tod_s_0_reg;
        output_ts_tod_ns_next = ts_tod_ns_0;
    end else begin
        output_ts_tod_s_next = ts_tod_s_1_reg;
        output_ts_tod_ns_next = ts_tod_ns_1;
    end
    output_ts_fns_next = input_ts_rel;
    output_ts_tag_next = input_ts_tag;
    output_ts_valid_next = input_ts_valid;
end

always @(posedge clk) begin
    // extract data
    if (dst_td_tvalid_reg) begin
        if (dst_td_tid_reg[3:0] == 4'd0) begin
            ts_sel_reg <= dst_td_tdata_reg[9];
        end
        // current
        if (dst_td_tid_reg == {4'd1, 4'd1}) begin
            if (ts_sel_reg) begin
                ts_tod_offset_ns_1_reg[15:0] <= dst_td_tdata_reg;
            end else begin
                ts_tod_offset_ns_0_reg[15:0] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd1, 4'd2}) begin
            if (ts_sel_reg) begin
                ts_tod_offset_ns_1_reg[31:16] <= dst_td_tdata_reg;
            end else begin
                ts_tod_offset_ns_0_reg[31:16] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd0, 4'd3}) begin
            if (ts_sel_reg) begin
                ts_tod_s_1_reg[15:0] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_0_reg[15:0] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd0, 4'd4}) begin
            if (ts_sel_reg) begin
                ts_tod_s_1_reg[31:16] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_0_reg[31:16] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd0, 4'd5}) begin
            if (ts_sel_reg) begin
                ts_tod_s_1_reg[47:32] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_0_reg[47:32] <= dst_td_tdata_reg;
            end
        end
        // alternate
        if (dst_td_tid_reg == {4'd2, 4'd1}) begin
            if (ts_sel_reg) begin
                ts_tod_offset_ns_0_reg[15:0] <= dst_td_tdata_reg;
            end else begin
                ts_tod_offset_ns_1_reg[15:0] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd2, 4'd2}) begin
            if (ts_sel_reg) begin
                ts_tod_offset_ns_0_reg[31:16] <= dst_td_tdata_reg;
            end else begin
                ts_tod_offset_ns_1_reg[31:16] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd2, 4'd3}) begin
            if (ts_sel_reg) begin
                ts_tod_s_0_reg[15:0] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_1_reg[15:0] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd2, 4'd4}) begin
            if (ts_sel_reg) begin
                ts_tod_s_0_reg[31:16] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_1_reg[31:16] <= dst_td_tdata_reg;
            end
        end
        if (dst_td_tid_reg == {4'd2, 4'd5}) begin
            if (ts_sel_reg) begin
                ts_tod_s_0_reg[47:32] <= dst_td_tdata_reg;
            end else begin
                ts_tod_s_1_reg[47:32] <= dst_td_tdata_reg;
            end
        end
    end

    output_ts_tod_s_reg <= output_ts_tod_s_next;
    output_ts_tod_ns_reg <= output_ts_tod_ns_next;
    output_ts_fns_reg <= output_ts_fns_next;
    output_ts_tag_reg <= output_ts_tag_next;
    output_ts_valid_reg <= output_ts_valid_next;

    if (rst) begin
        output_ts_valid_reg <= 1'b0;
    end
end

endmodule

`resetall
