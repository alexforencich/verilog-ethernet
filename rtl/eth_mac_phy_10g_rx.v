/*

Copyright (c) 2019 Alex Forencich

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
 * 10G Ethernet MAC/PHY combination
 */
module eth_mac_phy_10g_rx #
(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter CTRL_WIDTH = (DATA_WIDTH/8),
    parameter HDR_WIDTH = (DATA_WIDTH/32),
    parameter BIT_REVERSE = 0,
    parameter SCRAMBLER_DISABLE = 0,
    parameter SLIP_COUNT_WIDTH = 3,
    parameter COUNT_125US = 125000/6.4
)
(
    input  wire                  clk,
    input  wire                  rst,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m_axis_tkeep,
    output wire                  m_axis_tvalid,
    output wire                  m_axis_tlast,
    output wire                  m_axis_tuser,

    /*
     * SERDES interface
     */
    input  wire [DATA_WIDTH-1:0] serdes_rx_data,
    input  wire [HDR_WIDTH-1:0]  serdes_rx_hdr,
    output wire                  serdes_rx_bitslip,

    /*
     * Status
     */
    output wire                  rx_start_packet_0,
    output wire                  rx_start_packet_4,
    output wire                  rx_error_bad_frame,
    output wire                  rx_error_bad_fcs,
    output wire                  rx_block_lock,
    output wire                  rx_high_ber
);

// bus width assertions
initial begin
    if (DATA_WIDTH != 64) begin
        $error("Error: Interface width must be 64");
        $finish;
    end

    if (KEEP_WIDTH * 8 != DATA_WIDTH || CTRL_WIDTH * 8 != DATA_WIDTH) begin
        $error("Error: Interface requires byte (8-bit) granularity");
        $finish;
    end

    if (HDR_WIDTH * 32 != DATA_WIDTH) begin
        $error("Error: HDR_WIDTH must be equal to DATA_WIDTH/32");
        $finish;
    end
end

wire [DATA_WIDTH-1:0] serdes_rx_data_int;
wire [HDR_WIDTH-1:0]  serdes_rx_hdr_int;

generate
    genvar n;

    if (BIT_REVERSE) begin
        for (n = 0; n < DATA_WIDTH; n = n + 1) begin
            assign serdes_rx_data_int[n] = serdes_rx_data[DATA_WIDTH-n-1];
        end

        for (n = 0; n < HDR_WIDTH; n = n + 1) begin
            assign serdes_rx_hdr_int[n] = serdes_rx_hdr[HDR_WIDTH-n-1];
        end
    end else begin
        assign serdes_rx_data_int = serdes_rx_data;
        assign serdes_rx_hdr_int = serdes_rx_hdr;
    end
endgenerate

wire [DATA_WIDTH-1:0] descrambled_rx_data;

reg [DATA_WIDTH-1:0] encoded_rx_data_reg = {DATA_WIDTH{1'b0}};
reg [HDR_WIDTH-1:0] encoded_rx_hdr_reg = {HDR_WIDTH{1'b0}};

reg [57:0] scrambler_state_reg = {58{1'b1}};
wire [57:0] scrambler_state;

lfsr #(
    .LFSR_WIDTH(58),
    .LFSR_POLY(58'h8000000001),
    .LFSR_CONFIG("FIBONACCI"),
    .LFSR_FEED_FORWARD(1),
    .REVERSE(1),
    .DATA_WIDTH(DATA_WIDTH),
    .STYLE("AUTO")
)
descrambler_inst (
    .data_in(serdes_rx_data_int),
    .state_in(scrambler_state_reg),
    .data_out(descrambled_rx_data),
    .state_out(scrambler_state)
);

always @(posedge clk) begin
    scrambler_state_reg <= scrambler_state;

    encoded_rx_data_reg <= SCRAMBLER_DISABLE ? serdes_rx_data_int : descrambled_rx_data;
    encoded_rx_hdr_reg <= serdes_rx_hdr_int;
end

axis_baser_rx_64 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_WIDTH(KEEP_WIDTH),
    .HDR_WIDTH(HDR_WIDTH)
)
axis_baser_rx_inst (
    .clk(clk),
    .rst(rst),
    .encoded_rx_data(encoded_rx_data_reg),
    .encoded_rx_hdr(encoded_rx_hdr_reg),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tuser(m_axis_tuser),
    .start_packet_0(rx_start_packet_0),
    .start_packet_4(rx_start_packet_4),
    .error_bad_frame(rx_error_bad_frame),
    .error_bad_fcs(rx_error_bad_fcs)
);

eth_phy_10g_rx_frame_sync #(
    .HDR_WIDTH(HDR_WIDTH),
    .SLIP_COUNT_WIDTH(SLIP_COUNT_WIDTH)
)
eth_phy_10g_rx_frame_sync_inst (
    .clk(clk),
    .rst(rst),
    .serdes_rx_hdr(serdes_rx_hdr_int),
    .serdes_rx_bitslip(serdes_rx_bitslip),
    .rx_block_lock(rx_block_lock)
);

eth_phy_10g_rx_ber_mon #(
    .HDR_WIDTH(HDR_WIDTH),
    .COUNT_125US(COUNT_125US)
)
eth_phy_10g_rx_ber_mon_inst (
    .clk(clk),
    .rst(rst),
    .serdes_rx_hdr(serdes_rx_hdr_int),
    .rx_high_ber(rx_high_ber)
);

endmodule
