/*

Copyright (c) 2021 Alex Forencich

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
`timescale 1ns / 1ps
`default_nettype none

/*
 * Quad Ethernet MAC wrapper
 */
module eth_mac_quad_wrapper (
    input  wire        ctrl_clk,
    input  wire        ctrl_rst,

    output wire [3:0]  tx_serial_data_p,
    output wire [3:0]  tx_serial_data_n,
    input  wire [3:0]  rx_serial_data_p,
    input  wire [3:0]  rx_serial_data_n,
    input  wire        ref_clk,

    output wire        mac_1_clk,
    output wire        mac_1_rst,

    output wire [63:0] mac_1_rx_axis_tdata,
    output wire [7:0]  mac_1_rx_axis_tkeep,
    output wire        mac_1_rx_axis_tvalid,
    output wire        mac_1_rx_axis_tlast,
    output wire        mac_1_rx_axis_tuser,

    input  wire [63:0] mac_1_tx_axis_tdata,
    input  wire [7:0]  mac_1_tx_axis_tkeep,
    input  wire        mac_1_tx_axis_tvalid,
    output wire        mac_1_tx_axis_tready,
    input  wire        mac_1_tx_axis_tlast,
    input  wire        mac_1_tx_axis_tuser,

    output wire        mac_2_clk,
    output wire        mac_2_rst,

    output wire [63:0] mac_2_rx_axis_tdata,
    output wire [7:0]  mac_2_rx_axis_tkeep,
    output wire        mac_2_rx_axis_tvalid,
    output wire        mac_2_rx_axis_tlast,
    output wire        mac_2_rx_axis_tuser,

    input  wire [63:0] mac_2_tx_axis_tdata,
    input  wire [7:0]  mac_2_tx_axis_tkeep,
    input  wire        mac_2_tx_axis_tvalid,
    output wire        mac_2_tx_axis_tready,
    input  wire        mac_2_tx_axis_tlast,
    input  wire        mac_2_tx_axis_tuser,

    output wire        mac_3_clk,
    output wire        mac_3_rst,

    output wire [63:0] mac_3_rx_axis_tdata,
    output wire [7:0]  mac_3_rx_axis_tkeep,
    output wire        mac_3_rx_axis_tvalid,
    output wire        mac_3_rx_axis_tlast,
    output wire        mac_3_rx_axis_tuser,

    input  wire [63:0] mac_3_tx_axis_tdata,
    input  wire [7:0]  mac_3_tx_axis_tkeep,
    input  wire        mac_3_tx_axis_tvalid,
    output wire        mac_3_tx_axis_tready,
    input  wire        mac_3_tx_axis_tlast,
    input  wire        mac_3_tx_axis_tuser,

    output wire        mac_4_clk,
    output wire        mac_4_rst,

    output wire [63:0] mac_4_rx_axis_tdata,
    output wire [7:0]  mac_4_rx_axis_tkeep,
    output wire        mac_4_rx_axis_tvalid,
    output wire        mac_4_rx_axis_tlast,
    output wire        mac_4_rx_axis_tuser,

    input  wire [63:0] mac_4_tx_axis_tdata,
    input  wire [7:0]  mac_4_tx_axis_tkeep,
    input  wire        mac_4_tx_axis_tvalid,
    output wire        mac_4_tx_axis_tready,
    input  wire        mac_4_tx_axis_tlast,
    input  wire        mac_4_tx_axis_tuser
);

parameter N_CH = 4;

wire [N_CH-1:0]  mac_clk;
wire [N_CH-1:0]  mac_rst;

wire [N_CH-1:0]  mac_tx_pll_locked;

wire [N_CH*19-1:0]  xcvr_reconfig_address;
wire [N_CH-1:0]     xcvr_reconfig_read;
wire [N_CH-1:0]     xcvr_reconfig_write;
wire [N_CH*8-1:0]   xcvr_reconfig_readdata;
wire [N_CH*8-1:0]   xcvr_reconfig_writedata;
wire [N_CH-1:0]     xcvr_reconfig_waitrequest;

wire [N_CH-1:0]     mac_tx_ready;
wire [N_CH-1:0]     mac_tx_valid;
wire [N_CH*64-1:0]  mac_tx_data;
wire [N_CH-1:0]     mac_tx_error;
wire [N_CH-1:0]     mac_tx_startofpacket;
wire [N_CH-1:0]     mac_tx_endofpacket;
wire [N_CH*3-1:0]   mac_tx_empty;

wire [N_CH-1:0]     mac_rx_valid;
wire [N_CH*64-1:0]  mac_rx_data;
wire [N_CH-1:0]     mac_rx_startofpacket;
wire [N_CH-1:0]     mac_rx_endofpacket;
wire [N_CH*3-1:0]   mac_rx_empty;
wire [N_CH*6-1:0]   mac_rx_error;

mac mac_inst (
    .o_cdr_lock                       (),
    .o_tx_pll_locked                  (mac_tx_pll_locked),
    .i_clk_ref                        ({4{ref_clk}}),
    .o_clk_pll_div64                  (mac_clk),
    .o_clk_pll_div66                  (),
    .o_clk_rec_div64                  (),
    .o_clk_rec_div66                  (),
    .o_tx_serial                      (tx_serial_data_p),
    .i_rx_serial                      (rx_serial_data_p),
    .o_tx_serial_n                    (tx_serial_data_n),
    .i_rx_serial_n                    (rx_serial_data_n),
    .i_reconfig_clk                   (ctrl_clk),
    .i_reconfig_reset                 (ctrl_rst),
    .i_xcvr_reconfig_address          (xcvr_reconfig_address),
    .i_xcvr_reconfig_read             (xcvr_reconfig_read),
    .i_xcvr_reconfig_write            (xcvr_reconfig_write),
    .o_xcvr_reconfig_readdata         (xcvr_reconfig_readdata),
    .i_xcvr_reconfig_writedata        (xcvr_reconfig_writedata),
    .o_xcvr_reconfig_waitrequest      (xcvr_reconfig_waitrequest),
    .i_sl_stats_snapshot              ({4{1'b0}}),
    .o_sl_rx_hi_ber                   (),
    .i_sl_eth_reconfig_addr           ({4{19'd0}}),
    .i_sl_eth_reconfig_read           ({4{1'b0}}),
    .i_sl_eth_reconfig_write          ({4{1'b0}}),
    .o_sl_eth_reconfig_readdata       (),
    .o_sl_eth_reconfig_readdata_valid (),
    .i_sl_eth_reconfig_writedata      ({4{32'd0}}),
    .o_sl_eth_reconfig_waitrequest    (),
    .o_sl_tx_lanes_stable             (),
    .o_sl_rx_pcs_ready                (),
    .o_sl_ehip_ready                  (),
    .o_sl_rx_block_lock               (),
    .o_sl_local_fault_status          (),
    .o_sl_remote_fault_status         (),
    .i_sl_clk_tx                      (mac_clk),
    .i_sl_clk_rx                      (mac_clk),
    .i_sl_csr_rst_n                   (~mac_rst),
    .i_sl_tx_rst_n                    (~mac_rst),
    .i_sl_rx_rst_n                    (~mac_rst),
    .o_sl_txfifo_pfull                (),
    .o_sl_txfifo_pempty               (),
    .o_sl_txfifo_overflow             (),
    .o_sl_txfifo_underflow            (),
    .o_sl_tx_ready                    (mac_tx_ready),
    .o_sl_rx_valid                    (mac_rx_valid),
    .i_sl_tx_valid                    (mac_tx_valid),
    .i_sl_tx_data                     (mac_tx_data),
    .o_sl_rx_data                     (mac_rx_data),
    .i_sl_tx_error                    (mac_tx_error),
    .i_sl_tx_startofpacket            (mac_tx_startofpacket),
    .i_sl_tx_endofpacket              (mac_tx_endofpacket),
    .i_sl_tx_empty                    (mac_tx_empty),
    .i_sl_tx_skip_crc                 ({4{1'b0}}),
    .o_sl_rx_startofpacket            (mac_rx_startofpacket),
    .o_sl_rx_endofpacket              (mac_rx_endofpacket),
    .o_sl_rx_empty                    (mac_rx_empty),
    .o_sl_rx_error                    (mac_rx_error),
    .o_sl_rxstatus_data               (),
    .o_sl_rxstatus_valid              (),
    .i_sl_tx_pfc                      ({4{8'd0}}),
    .o_sl_rx_pfc                      (),
    .i_sl_tx_pause                    ({4{1'b0}}),
    .o_sl_rx_pause                    ()
);

wire [N_CH*64-1:0]  mac_rx_axis_tdata;
wire [N_CH*8-1:0]   mac_rx_axis_tkeep;
wire [N_CH-1:0]     mac_rx_axis_tvalid;
wire [N_CH-1:0]     mac_rx_axis_tlast;
wire [N_CH-1:0]     mac_rx_axis_tuser;

wire [N_CH*64-1:0]  mac_tx_axis_tdata;
wire [N_CH*8-1:0]   mac_tx_axis_tkeep;
wire [N_CH-1:0]     mac_tx_axis_tvalid;
wire [N_CH-1:0]     mac_tx_axis_tready;
wire [N_CH-1:0]     mac_tx_axis_tlast;
wire [N_CH-1:0]     mac_tx_axis_tuser;

assign mac_1_clk = mac_clk[0];
assign mac_1_rst = mac_rst[0];

assign mac_1_rx_axis_tdata = mac_rx_axis_tdata[0*64 +: 64];
assign mac_1_rx_axis_tkeep = mac_rx_axis_tkeep[0*8 +: 8];
assign mac_1_rx_axis_tvalid = mac_rx_axis_tvalid[0];
assign mac_1_rx_axis_tlast = mac_rx_axis_tlast[0];
assign mac_1_rx_axis_tuser = mac_rx_axis_tuser[0];

assign mac_tx_axis_tdata[0*64 +: 64] = mac_1_tx_axis_tdata;
assign mac_tx_axis_tkeep[0*8 +: 8] = mac_1_tx_axis_tkeep;
assign mac_tx_axis_tvalid[0] = mac_1_tx_axis_tvalid;
assign mac_1_tx_axis_tready = mac_tx_axis_tready[0];
assign mac_tx_axis_tlast[0] = mac_1_tx_axis_tlast;
assign mac_tx_axis_tuser[0] = mac_1_tx_axis_tuser;

assign mac_2_clk = mac_clk[1];
assign mac_2_rst = mac_rst[1];

assign mac_2_rx_axis_tdata = mac_rx_axis_tdata[1*64 +: 64];
assign mac_2_rx_axis_tkeep = mac_rx_axis_tkeep[1*8 +: 8];
assign mac_2_rx_axis_tvalid = mac_rx_axis_tvalid[1];
assign mac_2_rx_axis_tlast = mac_rx_axis_tlast[1];
assign mac_2_rx_axis_tuser = mac_rx_axis_tuser[1];

assign mac_tx_axis_tdata[1*64 +: 64] = mac_2_tx_axis_tdata;
assign mac_tx_axis_tkeep[1*8 +: 8] = mac_2_tx_axis_tkeep;
assign mac_tx_axis_tvalid[1] = mac_2_tx_axis_tvalid;
assign mac_2_tx_axis_tready = mac_tx_axis_tready[1];
assign mac_tx_axis_tlast[1] = mac_2_tx_axis_tlast;
assign mac_tx_axis_tuser[1] = mac_2_tx_axis_tuser;

assign mac_3_clk = mac_clk[2];
assign mac_3_rst = mac_rst[2];

assign mac_3_rx_axis_tdata = mac_rx_axis_tdata[2*64 +: 64];
assign mac_3_rx_axis_tkeep = mac_rx_axis_tkeep[2*8 +: 8];
assign mac_3_rx_axis_tvalid = mac_rx_axis_tvalid[2];
assign mac_3_rx_axis_tlast = mac_rx_axis_tlast[2];
assign mac_3_rx_axis_tuser = mac_rx_axis_tuser[2];

assign mac_tx_axis_tdata[2*64 +: 64] = mac_3_tx_axis_tdata;
assign mac_tx_axis_tkeep[2*8 +: 8] = mac_3_tx_axis_tkeep;
assign mac_tx_axis_tvalid[2] = mac_3_tx_axis_tvalid;
assign mac_3_tx_axis_tready = mac_tx_axis_tready[2];
assign mac_tx_axis_tlast[2] = mac_3_tx_axis_tlast;
assign mac_tx_axis_tuser[2] = mac_3_tx_axis_tuser;

assign mac_4_clk = mac_clk[3];
assign mac_4_rst = mac_rst[3];

assign mac_4_rx_axis_tdata = mac_rx_axis_tdata[3*64 +: 64];
assign mac_4_rx_axis_tkeep = mac_rx_axis_tkeep[3*8 +: 8];
assign mac_4_rx_axis_tvalid = mac_rx_axis_tvalid[3];
assign mac_4_rx_axis_tlast = mac_rx_axis_tlast[3];
assign mac_4_rx_axis_tuser = mac_rx_axis_tuser[3];

assign mac_tx_axis_tdata[3*64 +: 64] = mac_4_tx_axis_tdata;
assign mac_tx_axis_tkeep[3*8 +: 8] = mac_4_tx_axis_tkeep;
assign mac_tx_axis_tvalid[3] = mac_4_tx_axis_tvalid;
assign mac_4_tx_axis_tready = mac_tx_axis_tready[3];
assign mac_tx_axis_tlast[3] = mac_4_tx_axis_tlast;
assign mac_tx_axis_tuser[3] = mac_4_tx_axis_tuser;

generate

genvar n;

for (n = 0; n < 4; n = n + 1) begin : mac_ch

    sync_reset #(
        .N(4)
    )
    mac_rst_reset_sync_inst (
        .clk(mac_clk[n]),
        .rst(ctrl_rst || !mac_tx_pll_locked[n]),
        .out(mac_rst[n])
    );

    xcvr_ctrl xcvr_ctrl_inst (
        .reconfig_clk(ctrl_clk),
        .reconfig_rst(ctrl_rst),

        .pll_locked_in(mac_tx_pll_locked[n]),

        .xcvr_reconfig_address(xcvr_reconfig_address[n*19 +: 19]),
        .xcvr_reconfig_read(xcvr_reconfig_read[n]),
        .xcvr_reconfig_write(xcvr_reconfig_write[n]),
        .xcvr_reconfig_readdata(xcvr_reconfig_readdata[n*8 +: 8]),
        .xcvr_reconfig_writedata(xcvr_reconfig_writedata[n*8 +: 8]),
        .xcvr_reconfig_waitrequest(xcvr_reconfig_waitrequest[n])
    );

    axis2avst #(
        .DATA_WIDTH(64),
        .KEEP_WIDTH(8),
        .KEEP_ENABLE(1),
        .EMPTY_WIDTH(3),
        .BYTE_REVERSE(1)
    )
    mac_tx_axis2avst (
        .clk(mac_clk[n]),
        .rst(mac_rst[n]),

        .axis_tdata(mac_tx_axis_tdata[n*64 +: 64]),
        .axis_tkeep(mac_tx_axis_tkeep[n*8 +: 8]),
        .axis_tvalid(mac_tx_axis_tvalid[n]),
        .axis_tready(mac_tx_axis_tready[n]),
        .axis_tlast(mac_tx_axis_tlast[n]),
        .axis_tuser(mac_tx_axis_tuser[n]),

        .avst_ready(mac_tx_ready[n]),
        .avst_valid(mac_tx_valid[n]),
        .avst_data(mac_tx_data[n*64 +: 64]),
        .avst_startofpacket(mac_tx_startofpacket[n]),
        .avst_endofpacket(mac_tx_endofpacket[n]),
        .avst_empty(mac_tx_empty[n*3 +: 3]),
        .avst_error(mac_tx_error[n])
    );

    avst2axis #(
        .DATA_WIDTH(64),
        .KEEP_WIDTH(8),
        .KEEP_ENABLE(1),
        .EMPTY_WIDTH(3),
        .BYTE_REVERSE(1)
    )
    mac_rx_avst2axis (
        .clk(mac_clk[n]),
        .rst(mac_rst[n]),

        .avst_ready(),
        .avst_valid(mac_rx_valid[n]),
        .avst_data(mac_rx_data[n*64 +: 64]),
        .avst_startofpacket(mac_rx_startofpacket[n]),
        .avst_endofpacket(mac_rx_endofpacket[n]),
        .avst_empty(mac_rx_empty[n*3 +: 3]),
        .avst_error(mac_rx_error[n*6 +: 6] != 0),

        .axis_tdata(mac_rx_axis_tdata[n*64 +: 64]),
        .axis_tkeep(mac_rx_axis_tkeep[n*8 +: 8]),
        .axis_tvalid(mac_rx_axis_tvalid[n]),
        .axis_tready(1'b1),
        .axis_tlast(mac_rx_axis_tlast[n]),
        .axis_tuser(mac_rx_axis_tuser[n])
    );

end

endgenerate

endmodule

`resetall
