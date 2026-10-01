/*

Copyright (c) 2026 George Fedorov
Language: SystemVerilog

*/

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * MDIO init
 */
module mdio_init #(
    parameter PHY_ADDR_WIDTH = 5,
              REG_ADDR_WIDTH = 5,
              DATA_WIDTH = 16
) (
    input  wire                        clk,
    input  wire                        rst,

    /*
     * MDIO master interface
     */
    output wire [PHY_ADDR_WIDTH-1:0]   cmd_phy_addr,
    output wire [REG_ADDR_WIDTH-1:0]   cmd_reg_addr,
    output wire [DATA_WIDTH-1:0]       cmd_data,
    output wire                        cmd_write,
    output wire                        cmd_valid,
    input  wire                        cmd_ready,

    input  wire [DATA_WIDTH-1:0]       rsp_data,
    input  wire                        rsp_valid,
    output wire                        rsp_ready,

    /*
     * Status
     */
    output wire                        busy,

    /*
     * Configuration
     */
    input  wire                        start
);

/*

Generic module for MDIO PHY initialization. Good for use when PHYs must be
initialized on system start without intervention of a general-purpose processor.

Copy this file and change init_data and INIT_DATA_LEN as needed.

This module can be used in two modes: single PHY initialization, or multiple
PHY initialization. In multiple PHY mode, the same initialization sequence
can be performed on multiple different PHY addresses.

To use single PHY mode, only use write commands with explicit PHY addresses.
The module will generate the MDIO commands in sequential order. Terminate the
list with a 0 entry.

To use multiple PHY mode, use the start data and start address block commands
to set up lists of initialization data and PHY addresses. The module enters
multiple PHY mode upon seeing a start data block command. The module stores the
offset of the start of the data block and then skips ahead until it reaches a
start address block command. The module will store the offset to the address
block and read the first PHY address in the block. Then it will jump back to
the data block and execute it, substituting the stored PHY address for each
current PHY write command. Upon reaching the start address block command, the
module will read out the next PHY address and start again at the top of the
data block. If the module encounters a start data block command while looking
for a PHY address, then it will store a new data offset and then look for a
start address block command. Terminate the list with a 0 entry. Normal PHY
address commands will operate normally inside a data block.

Commands:

00 00 00000 00000 0000000000000000 : stop
00 00 00000 00001 0000000000000000 : exit multiple PHY mode
00 00 00000 00011 0000000000000000 : write to current PHY address
00 00 00000 01000 0000000000000000 : start address block
00 00 00000 01001 0000000000000000 : start data block
00 00 001dd ddddd 0000000000000000 : delay 2**(16+d) cycles
01 ppppp rrrrr dddddddddddddddd   : write data to PHY address p, register r

Examples

Write 0x1140 to register 0x00 (control) on PHY at address 0x01

01 00001 00000 0001000101000000  write 0x1140 to PHY 0x01 reg 0x00
00 00000 00000 0000000000000000  stop

Write 0x1140 to register 0x00 on PHYs at 0x00, 0x01, 0x02, and 0x03

00 00000 01001 0000000000000000  start data block
00 00000 00011 0000000000000000  write to current PHY
00 00000 00000 0001000101000000  register 0x00, data 0x1140
00 00000 01000 0000000000000000  start address block
01 00000 00000 0000000000000000  PHY address 0x00
01 00001 00000 0000000000000000  PHY address 0x01
01 00010 00000 0000000000000000  PHY address 0x02
01 00011 00000 0000000000000000  PHY address 0x03
00 00000 00001 0000000000000000  exit mode
00 00000 00000 0000000000000000  stop

*/

// init_data ROM
localparam INIT_DATA_LEN = 16;

reg [37:0] init_data [INIT_DATA_LEN-1:0];

initial begin
    // Single PHY example: write 0x1140 to control register on PHY 0x01
    init_data[0]  = {2'b01, 5'd1, 5'd0, 16'h1140}; // PHY 0x01, reg 0x00, data 0x1140
    init_data[1]  = {2'b01, 5'd1, 5'd4, 16'h01E1}; // PHY 0x01, reg 0x04, data 0x01E1

    // Multiple PHY example
    init_data[2]  = {2'b00, 5'd0, 5'b01001, 16'd0}; // start data block
    init_data[3]  = {2'b00, 5'd0, 5'b00011, 16'd0}; // write to current PHY
    init_data[4]  = {2'b00, 5'd0, 5'd0, 16'h1140};  // reg 0x00, data 0x1140
    init_data[5]  = {2'b00, 5'd0, 5'b00011, 16'd0}; // write to current PHY
    init_data[6]  = {2'b00, 5'd0, 5'd4, 16'h01E1};  // reg 0x04, data 0x01E1
    init_data[7]  = {2'b00, 5'd0, 5'b01000, 16'd0}; // start address block
    init_data[8]  = {2'b01, 5'd0, 5'd0, 16'd0};     // PHY address 0x00
    init_data[9]  = {2'b01, 5'd1, 5'd0, 16'd0};     // PHY address 0x01
    init_data[10] = {2'b01, 5'd2, 5'd0, 16'd0};     // PHY address 0x02
    init_data[11] = {2'b01, 5'd3, 5'd0, 16'd0};     // PHY address 0x03
    init_data[12] = {2'b00, 5'd0, 5'd1, 16'd0};     // exit mode
    init_data[13] = 38'd0;                          // stop
    init_data[14] = 38'd0;                          // padding
    init_data[15] = 38'd0;                          // padding
end

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_RUN = 3'd1,
    STATE_TABLE_1 = 3'd2,
    STATE_TABLE_2 = 3'd3,
    STATE_TABLE_3 = 3'd4;

reg [2:0] state_reg = STATE_IDLE, state_next;

parameter AW = $clog2(INIT_DATA_LEN);

reg [37:0] init_data_reg = 38'd0;

reg [AW-1:0] address_reg = {AW{1'b0}}, address_next;
reg [AW-1:0] address_ptr_reg = {AW{1'b0}}, address_ptr_next;
reg [AW-1:0] data_ptr_reg = {AW{1'b0}}, data_ptr_next;

reg [PHY_ADDR_WIDTH-1:0] cur_phy_addr_reg = {PHY_ADDR_WIDTH{1'b0}}, cur_phy_addr_next;
reg [REG_ADDR_WIDTH-1:0] cur_reg_addr_reg = {REG_ADDR_WIDTH{1'b0}}, cur_reg_addr_next;

reg [31:0] delay_counter_reg = 32'd0, delay_counter_next;

reg [PHY_ADDR_WIDTH-1:0] cmd_phy_addr_reg = {PHY_ADDR_WIDTH{1'b0}}, cmd_phy_addr_next;
reg [REG_ADDR_WIDTH-1:0] cmd_reg_addr_reg = {REG_ADDR_WIDTH{1'b0}}, cmd_reg_addr_next;
reg [DATA_WIDTH-1:0] cmd_data_reg = {DATA_WIDTH{1'b0}}, cmd_data_next;
reg cmd_write_reg = 1'b0, cmd_write_next;
reg cmd_valid_reg = 1'b0, cmd_valid_next;

reg rsp_ready_reg = 1'b1, rsp_ready_next;

reg start_flag_reg = 1'b0, start_flag_next;

reg busy_reg = 1'b0;

assign cmd_phy_addr = cmd_phy_addr_reg;
assign cmd_reg_addr = cmd_reg_addr_reg;
assign cmd_data = cmd_data_reg;
assign cmd_write = cmd_write_reg;
assign cmd_valid = cmd_valid_reg;

assign rsp_ready = rsp_ready_reg;

assign busy = busy_reg;

always_comb begin
    state_next = STATE_IDLE;

    address_next = address_reg;
    address_ptr_next = address_ptr_reg;
    data_ptr_next = data_ptr_reg;

    cur_phy_addr_next = cur_phy_addr_reg;
    cur_reg_addr_next = cur_reg_addr_reg;

    delay_counter_next = delay_counter_reg;

    cmd_phy_addr_next = cmd_phy_addr_reg;
    cmd_reg_addr_next = cmd_reg_addr_reg;
    cmd_data_next = cmd_data_reg;
    cmd_write_next = cmd_write_reg & ~(cmd_valid & cmd_ready);
    cmd_valid_next = cmd_valid_reg & ~cmd_ready;

    rsp_ready_next = 1'b1;

    start_flag_next = start_flag_reg;

    if (cmd_valid) begin
        // wait for output registers to clear
        state_next = state_reg;
    end else if (delay_counter_reg != 0) begin
        // delay
        delay_counter_next = delay_counter_reg - 1;
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // wait for start signal
                if (~start_flag_reg & start) begin
                    address_next = {AW{1'b0}};
                    start_flag_next = 1'b1;
                    state_next = STATE_RUN;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_RUN: begin
                // process commands
                if (init_data_reg[37:36] == 2'b01) begin
                    // write to PHY
                    cmd_phy_addr_next = init_data_reg[35:31];
                    cmd_reg_addr_next = init_data_reg[30:26];
                    cmd_data_next = init_data_reg[15:0];
                    cmd_write_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg[37:21] == 17'b00_00000_00001_00000) begin
                    // delay
                    delay_counter_next = 32'd1 << (init_data_reg[20:16]+16);

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 38'b00_00000_01001_0000000000000000) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 38'd0) begin
                    // stop
                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end
            end
            STATE_TABLE_1: begin
                // find address table start
                if (init_data_reg == 38'b00_00000_01000_0000000000000000) begin
                    // address table start
                    address_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 38'b00_00000_01001_0000000000000000) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 38'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 38'd0) begin
                    // stop
                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end
            end
            STATE_TABLE_2: begin
                // find next PHY address
                if (init_data_reg[37:36] == 2'b01) begin
                    // PHY address command
                    // store address and move to data table
                    cur_phy_addr_next = init_data_reg[35:31];
                    address_ptr_next = address_reg + 1;
                    address_next = data_ptr_reg;
                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 38'b00_00000_01001_0000000000000000) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 38'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 38'd0) begin
                    // stop
                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end
            end
            STATE_TABLE_3: begin
                // process data table with selected PHY address
                if (init_data_reg[37:36] == 2'b01) begin
                    // write to explicit PHY address
                    cmd_phy_addr_next = init_data_reg[35:31];
                    cmd_reg_addr_next = init_data_reg[30:26];
                    cmd_data_next = init_data_reg[15:0];
                    cmd_write_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 38'b00_00000_00011_0000000000000000) begin
                    // write to current PHY address - save register and data
                    cur_reg_addr_next = init_data_reg[30:26];
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_3;
                end else if (init_data_reg[37:16] == 22'b00_00000_00000_00000000) begin
                    // data for current PHY (follows cmd 0x03)
                    cmd_phy_addr_next = cur_phy_addr_reg;
                    cmd_reg_addr_next = init_data_reg[30:26];
                    cmd_data_next = init_data_reg[15:0];
                    cmd_write_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 38'b00_00000_01001_0000000000000000) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 38'b00_00000_01000_0000000000000000) begin
                    // address table start
                    address_next = address_ptr_reg;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 38'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 38'd0) begin
                    // stop
                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_3;
                end
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        init_data_reg <= 38'd0;

        address_reg <= {AW{1'b0}};
        address_ptr_reg <= {AW{1'b0}};
        data_ptr_reg <= {AW{1'b0}};

        cur_phy_addr_reg <= {PHY_ADDR_WIDTH{1'b0}};
        cur_reg_addr_reg <= {REG_ADDR_WIDTH{1'b0}};

        delay_counter_reg <= 32'd0;

        cmd_phy_addr_reg <= {PHY_ADDR_WIDTH{1'b0}};
        cmd_reg_addr_reg <= {REG_ADDR_WIDTH{1'b0}};
        cmd_data_reg <= {DATA_WIDTH{1'b0}};
        cmd_write_reg <= 1'b0;
        cmd_valid_reg <= 1'b0;

        rsp_ready_reg <= 1'b1;

        start_flag_reg <= 1'b0;

        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        // read init_data ROM
        init_data_reg <= init_data[address_next];

        address_reg <= address_next;
        address_ptr_reg <= address_ptr_next;
        data_ptr_reg <= data_ptr_next;

        cur_phy_addr_reg <= cur_phy_addr_next;
        cur_reg_addr_reg <= cur_reg_addr_next;

        delay_counter_reg <= delay_counter_next;

        cmd_phy_addr_reg <= cmd_phy_addr_next;
        cmd_reg_addr_reg <= cmd_reg_addr_next;
        cmd_data_reg <= cmd_data_next;
        cmd_write_reg <= cmd_write_next;
        cmd_valid_reg <= cmd_valid_next;

        rsp_ready_reg <= rsp_ready_next;

        start_flag_reg <= start & start_flag_next;

        busy_reg <= (state_reg != STATE_IDLE);
    end
end

endmodule

`resetall
