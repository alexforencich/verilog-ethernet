/*

Copyright (c) 2015-2021 Alex Forencich

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
 * si5341_i2c_init
 */
module si5341_i2c_init (
    input  wire        clk,
    input  wire        rst,

    /*
     * I2C master interface
     */
    output wire [6:0]  m_axis_cmd_address,
    output wire        m_axis_cmd_start,
    output wire        m_axis_cmd_read,
    output wire        m_axis_cmd_write,
    output wire        m_axis_cmd_write_multiple,
    output wire        m_axis_cmd_stop,
    output wire        m_axis_cmd_valid,
    input  wire        m_axis_cmd_ready,

    output wire [7:0]  m_axis_data_tdata,
    output wire        m_axis_data_tvalid,
    input  wire        m_axis_data_tready,
    output wire        m_axis_data_tlast,

    /*
     * Status
     */
    output wire        busy,

    /*
     * Configuration
     */
    input  wire        start
);

/*

Generic module for I2C bus initialization.  Good for use when multiple devices
on an I2C bus must be initialized on system start without intervention of a
general-purpose processor.

Copy this file and change init_data and INIT_DATA_LEN as needed.

This module can be used in two modes: simple device initialization, or multiple
device initialization.  In multiple device mode, the same initialization sequence
can be performed on multiple different device addresses.

To use single device mode, only use the start write to address and write data commands.
The module will generate the I2C commands in sequential order.  Terminate the list
with a 0 entry.

To use the multiple device mode, use the start data and start address block commands
to set up lists of initialization data and device addresses.  The module enters
multiple device mode upon seeing a start data block command.  The module stores the
offset of the start of the data block and then skips ahead until it reaches a start
address block command.  The module will store the offset to the address block and
read the first address in the block.  Then it will jump back to the data block
and execute it, substituting the stored address for each current address write
command.  Upon reaching the start address block command, the module will read out the
next address and start again at the top of the data block.  If the module encounters
a start data block command while looking for an address, then it will store a new data
offset and then look for a start address block command.  Terminate the list with a 0
entry.  Normal address commands will operate normally inside a data block.

Commands:

00 0000000 : stop
00 0000001 : exit multiple device mode
00 0000011 : start write to current address
00 0001000 : start address block
00 0001001 : start data block
00 001dddd : delay 2**(16+d) cycles
00 1000001 : send I2C stop
01 aaaaaaa : start write to address
1 dddddddd : write 8-bit data

Examples

write 0x11223344 to register 0x0004 on device at 0x50

01 1010000  start write to 0x50
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
0 00000000  stop

write 0x11223344 to register 0x0004 on devices at 0x50, 0x51, 0x52, and 0x53

00 0001001  start data block
00 0000011  start write to current address
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
00 0001000  start address block
01 1010000  address 0x50
01 1010001  address 0x51
01 1010010  address 0x52
01 1010011  address 0x53
00 0000000  stop

*/

// init_data ROM
localparam INIT_DATA_LEN = 536;

reg [8:0] init_data [INIT_DATA_LEN-1:0];

initial begin
    // Initial delay
    init_data[0] = 9'b000010110; // delay 30 ms
    // Set muxes to select Si5341
    init_data[1] = {2'b01, 7'h70};
    init_data[2] = {1'b1,  8'h00};
    init_data[3] = 9'b001000001; // I2C stop
    init_data[4] = {2'b01, 7'h71};
    init_data[5] = {1'b1,  8'h04};
    init_data[6] = 9'b001000001; // I2C stop
    // Si534x/7x/8x/9x Registers Script
    // 
    // Part: Si5341
    // Project File: C:\Users\Alex\Documents\Si5341-RevD-fpga-161-osc-Project.slabtimeproj
    // Design ID: fpga
    // Includes Pre/Post Download Control Register Writes: Yes
    // Die Revision: B1
    // Creator: ClockBuilder Pro v3.1 [2021-01-18]
    // Created On: 2021-03-14 17:21:45 GMT-07:00
    // 
    // Start configuration preamble
    init_data[7] = {2'b01, 7'h77};
    init_data[8] = {1'b1,  8'h01};
    init_data[9] = {1'b1,  8'h0b}; // set page 0x0b
    init_data[10] = {2'b01, 7'h77};
    init_data[11] = {1'b1,  8'h24};
    init_data[12] = {1'b1,  8'hc0}; // write 0xc0 to 0x0b24
    init_data[13] = {1'b1,  8'h00}; // write 0x00 to 0x0b25
    // Rev D stuck divider fix
    init_data[14] = {2'b01, 7'h77};
    init_data[15] = {1'b1,  8'h01};
    init_data[16] = {1'b1,  8'h05}; // set page 0x05
    init_data[17] = {2'b01, 7'h77};
    init_data[18] = {1'b1,  8'h02};
    init_data[19] = {1'b1,  8'h01}; // write 0x01 to 0x0502
    init_data[20] = {2'b01, 7'h77};
    init_data[21] = {1'b1,  8'h05};
    init_data[22] = {1'b1,  8'h03}; // write 0x03 to 0x0505
    init_data[23] = {2'b01, 7'h77};
    init_data[24] = {1'b1,  8'h01};
    init_data[25] = {1'b1,  8'h09}; // set page 0x09
    init_data[26] = {2'b01, 7'h77};
    init_data[27] = {1'b1,  8'h57};
    init_data[28] = {1'b1,  8'h17}; // write 0x17 to 0x0957
    init_data[29] = {2'b01, 7'h77};
    init_data[30] = {1'b1,  8'h01};
    init_data[31] = {1'b1,  8'h0b}; // set page 0x0b
    init_data[32] = {2'b01, 7'h77};
    init_data[33] = {1'b1,  8'h4e};
    init_data[34] = {1'b1,  8'h1a}; // write 0x1a to 0x0b4e
    // End configuration preamble
    // 
    // Delay 300 msec
    init_data[35] = 9'b000011010; // delay 300 ms
    // Delay is worst case time for device to complete any calibration
    // that is running due to device state change previous to this script
    // being processed.
    // 
    // Start configuration registers
    init_data[36] = {2'b01, 7'h77};
    init_data[37] = {1'b1,  8'h01};
    init_data[38] = {1'b1,  8'h00}; // set page 0x00
    init_data[39] = {2'b01, 7'h77};
    init_data[40] = {1'b1,  8'h06};
    init_data[41] = {1'b1,  8'h00}; // write 0x00 to 0x0006
    init_data[42] = {1'b1,  8'h00}; // write 0x00 to 0x0007
    init_data[43] = {1'b1,  8'h00}; // write 0x00 to 0x0008
    init_data[44] = {2'b01, 7'h77};
    init_data[45] = {1'b1,  8'h0b};
    init_data[46] = {1'b1,  8'h74}; // write 0x74 to 0x000b
    init_data[47] = {2'b01, 7'h77};
    init_data[48] = {1'b1,  8'h17};
    init_data[49] = {1'b1,  8'hd0}; // write 0xd0 to 0x0017
    init_data[50] = {1'b1,  8'hfc}; // write 0xfc to 0x0018
    init_data[51] = {2'b01, 7'h77};
    init_data[52] = {1'b1,  8'h21};
    init_data[53] = {1'b1,  8'h0b}; // write 0x0b to 0x0021
    init_data[54] = {1'b1,  8'h00}; // write 0x00 to 0x0022
    init_data[55] = {2'b01, 7'h77};
    init_data[56] = {1'b1,  8'h2b};
    init_data[57] = {1'b1,  8'h02}; // write 0x02 to 0x002b
    init_data[58] = {1'b1,  8'h33}; // write 0x33 to 0x002c
    init_data[59] = {1'b1,  8'h05}; // write 0x05 to 0x002d
    init_data[60] = {1'b1,  8'hae}; // write 0xae to 0x002e
    init_data[61] = {1'b1,  8'h00}; // write 0x00 to 0x002f
    init_data[62] = {1'b1,  8'hae}; // write 0xae to 0x0030
    init_data[63] = {1'b1,  8'h00}; // write 0x00 to 0x0031
    init_data[64] = {1'b1,  8'h00}; // write 0x00 to 0x0032
    init_data[65] = {1'b1,  8'h00}; // write 0x00 to 0x0033
    init_data[66] = {1'b1,  8'h00}; // write 0x00 to 0x0034
    init_data[67] = {1'b1,  8'h00}; // write 0x00 to 0x0035
    init_data[68] = {1'b1,  8'hae}; // write 0xae to 0x0036
    init_data[69] = {1'b1,  8'h00}; // write 0x00 to 0x0037
    init_data[70] = {1'b1,  8'hae}; // write 0xae to 0x0038
    init_data[71] = {1'b1,  8'h00}; // write 0x00 to 0x0039
    init_data[72] = {1'b1,  8'h00}; // write 0x00 to 0x003a
    init_data[73] = {1'b1,  8'h00}; // write 0x00 to 0x003b
    init_data[74] = {1'b1,  8'h00}; // write 0x00 to 0x003c
    init_data[75] = {1'b1,  8'h00}; // write 0x00 to 0x003d
    init_data[76] = {2'b01, 7'h77};
    init_data[77] = {1'b1,  8'h41};
    init_data[78] = {1'b1,  8'h07}; // write 0x07 to 0x0041
    init_data[79] = {1'b1,  8'h07}; // write 0x07 to 0x0042
    init_data[80] = {1'b1,  8'h00}; // write 0x00 to 0x0043
    init_data[81] = {1'b1,  8'h00}; // write 0x00 to 0x0044
    init_data[82] = {2'b01, 7'h77};
    init_data[83] = {1'b1,  8'h9e};
    init_data[84] = {1'b1,  8'h00}; // write 0x00 to 0x009e
    init_data[85] = {2'b01, 7'h77};
    init_data[86] = {1'b1,  8'h01};
    init_data[87] = {1'b1,  8'h01}; // set page 0x01
    init_data[88] = {2'b01, 7'h77};
    init_data[89] = {1'b1,  8'h02};
    init_data[90] = {1'b1,  8'h01}; // write 0x01 to 0x0102
    init_data[91] = {2'b01, 7'h77};
    init_data[92] = {1'b1,  8'h08};
    init_data[93] = {1'b1,  8'h06}; // write 0x06 to 0x0108
    init_data[94] = {1'b1,  8'h09}; // write 0x09 to 0x0109
    init_data[95] = {1'b1,  8'h3b}; // write 0x3b to 0x010a
    init_data[96] = {1'b1,  8'h28}; // write 0x28 to 0x010b
    init_data[97] = {2'b01, 7'h77};
    init_data[98] = {1'b1,  8'h0d};
    init_data[99] = {1'b1,  8'h06}; // write 0x06 to 0x010d
    init_data[100] = {1'b1,  8'h09}; // write 0x09 to 0x010e
    init_data[101] = {1'b1,  8'h3b}; // write 0x3b to 0x010f
    init_data[102] = {1'b1,  8'h28}; // write 0x28 to 0x0110
    init_data[103] = {2'b01, 7'h77};
    init_data[104] = {1'b1,  8'h12};
    init_data[105] = {1'b1,  8'h02}; // write 0x02 to 0x0112
    init_data[106] = {1'b1,  8'h09}; // write 0x09 to 0x0113
    init_data[107] = {1'b1,  8'h3b}; // write 0x3b to 0x0114
    init_data[108] = {1'b1,  8'h2c}; // write 0x2c to 0x0115
    init_data[109] = {2'b01, 7'h77};
    init_data[110] = {1'b1,  8'h17};
    init_data[111] = {1'b1,  8'h06}; // write 0x06 to 0x0117
    init_data[112] = {1'b1,  8'h09}; // write 0x09 to 0x0118
    init_data[113] = {1'b1,  8'h3b}; // write 0x3b to 0x0119
    init_data[114] = {1'b1,  8'h29}; // write 0x29 to 0x011a
    init_data[115] = {2'b01, 7'h77};
    init_data[116] = {1'b1,  8'h1c};
    init_data[117] = {1'b1,  8'h06}; // write 0x06 to 0x011c
    init_data[118] = {1'b1,  8'h09}; // write 0x09 to 0x011d
    init_data[119] = {1'b1,  8'h3b}; // write 0x3b to 0x011e
    init_data[120] = {1'b1,  8'h29}; // write 0x29 to 0x011f
    init_data[121] = {2'b01, 7'h77};
    init_data[122] = {1'b1,  8'h21};
    init_data[123] = {1'b1,  8'h06}; // write 0x06 to 0x0121
    init_data[124] = {1'b1,  8'h09}; // write 0x09 to 0x0122
    init_data[125] = {1'b1,  8'h3b}; // write 0x3b to 0x0123
    init_data[126] = {1'b1,  8'h2a}; // write 0x2a to 0x0124
    init_data[127] = {2'b01, 7'h77};
    init_data[128] = {1'b1,  8'h26};
    init_data[129] = {1'b1,  8'h06}; // write 0x06 to 0x0126
    init_data[130] = {1'b1,  8'h09}; // write 0x09 to 0x0127
    init_data[131] = {1'b1,  8'h3b}; // write 0x3b to 0x0128
    init_data[132] = {1'b1,  8'h2a}; // write 0x2a to 0x0129
    init_data[133] = {2'b01, 7'h77};
    init_data[134] = {1'b1,  8'h2b};
    init_data[135] = {1'b1,  8'h06}; // write 0x06 to 0x012b
    init_data[136] = {1'b1,  8'h09}; // write 0x09 to 0x012c
    init_data[137] = {1'b1,  8'h3b}; // write 0x3b to 0x012d
    init_data[138] = {1'b1,  8'h2b}; // write 0x2b to 0x012e
    init_data[139] = {2'b01, 7'h77};
    init_data[140] = {1'b1,  8'h30};
    init_data[141] = {1'b1,  8'h06}; // write 0x06 to 0x0130
    init_data[142] = {1'b1,  8'h09}; // write 0x09 to 0x0131
    init_data[143] = {1'b1,  8'h3b}; // write 0x3b to 0x0132
    init_data[144] = {1'b1,  8'h2b}; // write 0x2b to 0x0133
    init_data[145] = {2'b01, 7'h77};
    init_data[146] = {1'b1,  8'h3a};
    init_data[147] = {1'b1,  8'h06}; // write 0x06 to 0x013a
    init_data[148] = {1'b1,  8'h09}; // write 0x09 to 0x013b
    init_data[149] = {1'b1,  8'h3b}; // write 0x3b to 0x013c
    init_data[150] = {1'b1,  8'h2b}; // write 0x2b to 0x013d
    init_data[151] = {2'b01, 7'h77};
    init_data[152] = {1'b1,  8'h3f};
    init_data[153] = {1'b1,  8'h00}; // write 0x00 to 0x013f
    init_data[154] = {1'b1,  8'h00}; // write 0x00 to 0x0140
    init_data[155] = {1'b1,  8'h40}; // write 0x40 to 0x0141
    init_data[156] = {2'b01, 7'h77};
    init_data[157] = {1'b1,  8'h01};
    init_data[158] = {1'b1,  8'h02}; // set page 0x02
    init_data[159] = {2'b01, 7'h77};
    init_data[160] = {1'b1,  8'h06};
    init_data[161] = {1'b1,  8'h00}; // write 0x00 to 0x0206
    init_data[162] = {2'b01, 7'h77};
    init_data[163] = {1'b1,  8'h08};
    init_data[164] = {1'b1,  8'h02}; // write 0x02 to 0x0208
    init_data[165] = {1'b1,  8'h00}; // write 0x00 to 0x0209
    init_data[166] = {1'b1,  8'h00}; // write 0x00 to 0x020a
    init_data[167] = {1'b1,  8'h00}; // write 0x00 to 0x020b
    init_data[168] = {1'b1,  8'h00}; // write 0x00 to 0x020c
    init_data[169] = {1'b1,  8'h00}; // write 0x00 to 0x020d
    init_data[170] = {1'b1,  8'h01}; // write 0x01 to 0x020e
    init_data[171] = {1'b1,  8'h00}; // write 0x00 to 0x020f
    init_data[172] = {1'b1,  8'h00}; // write 0x00 to 0x0210
    init_data[173] = {1'b1,  8'h00}; // write 0x00 to 0x0211
    init_data[174] = {1'b1,  8'h02}; // write 0x02 to 0x0212
    init_data[175] = {1'b1,  8'h00}; // write 0x00 to 0x0213
    init_data[176] = {1'b1,  8'h00}; // write 0x00 to 0x0214
    init_data[177] = {1'b1,  8'h00}; // write 0x00 to 0x0215
    init_data[178] = {1'b1,  8'h00}; // write 0x00 to 0x0216
    init_data[179] = {1'b1,  8'h00}; // write 0x00 to 0x0217
    init_data[180] = {1'b1,  8'h01}; // write 0x01 to 0x0218
    init_data[181] = {1'b1,  8'h00}; // write 0x00 to 0x0219
    init_data[182] = {1'b1,  8'h00}; // write 0x00 to 0x021a
    init_data[183] = {1'b1,  8'h00}; // write 0x00 to 0x021b
    init_data[184] = {1'b1,  8'h00}; // write 0x00 to 0x021c
    init_data[185] = {1'b1,  8'h00}; // write 0x00 to 0x021d
    init_data[186] = {1'b1,  8'h00}; // write 0x00 to 0x021e
    init_data[187] = {1'b1,  8'h00}; // write 0x00 to 0x021f
    init_data[188] = {1'b1,  8'h00}; // write 0x00 to 0x0220
    init_data[189] = {1'b1,  8'h00}; // write 0x00 to 0x0221
    init_data[190] = {1'b1,  8'h00}; // write 0x00 to 0x0222
    init_data[191] = {1'b1,  8'h00}; // write 0x00 to 0x0223
    init_data[192] = {1'b1,  8'h00}; // write 0x00 to 0x0224
    init_data[193] = {1'b1,  8'h00}; // write 0x00 to 0x0225
    init_data[194] = {1'b1,  8'h00}; // write 0x00 to 0x0226
    init_data[195] = {1'b1,  8'h00}; // write 0x00 to 0x0227
    init_data[196] = {1'b1,  8'h00}; // write 0x00 to 0x0228
    init_data[197] = {1'b1,  8'h00}; // write 0x00 to 0x0229
    init_data[198] = {1'b1,  8'h00}; // write 0x00 to 0x022a
    init_data[199] = {1'b1,  8'h00}; // write 0x00 to 0x022b
    init_data[200] = {1'b1,  8'h00}; // write 0x00 to 0x022c
    init_data[201] = {1'b1,  8'h00}; // write 0x00 to 0x022d
    init_data[202] = {1'b1,  8'h00}; // write 0x00 to 0x022e
    init_data[203] = {1'b1,  8'h00}; // write 0x00 to 0x022f
    init_data[204] = {2'b01, 7'h77};
    init_data[205] = {1'b1,  8'h35};
    init_data[206] = {1'b1,  8'h00}; // write 0x00 to 0x0235
    init_data[207] = {1'b1,  8'h00}; // write 0x00 to 0x0236
    init_data[208] = {1'b1,  8'h00}; // write 0x00 to 0x0237
    init_data[209] = {1'b1,  8'h90}; // write 0x90 to 0x0238
    init_data[210] = {1'b1,  8'h54}; // write 0x54 to 0x0239
    init_data[211] = {1'b1,  8'h00}; // write 0x00 to 0x023a
    init_data[212] = {1'b1,  8'h00}; // write 0x00 to 0x023b
    init_data[213] = {1'b1,  8'h00}; // write 0x00 to 0x023c
    init_data[214] = {1'b1,  8'h00}; // write 0x00 to 0x023d
    init_data[215] = {1'b1,  8'h80}; // write 0x80 to 0x023e
    init_data[216] = {2'b01, 7'h77};
    init_data[217] = {1'b1,  8'h4a};
    init_data[218] = {1'b1,  8'h00}; // write 0x00 to 0x024a
    init_data[219] = {1'b1,  8'h00}; // write 0x00 to 0x024b
    init_data[220] = {1'b1,  8'h00}; // write 0x00 to 0x024c
    init_data[221] = {1'b1,  8'h00}; // write 0x00 to 0x024d
    init_data[222] = {1'b1,  8'h00}; // write 0x00 to 0x024e
    init_data[223] = {1'b1,  8'h00}; // write 0x00 to 0x024f
    init_data[224] = {1'b1,  8'h03}; // write 0x03 to 0x0250
    init_data[225] = {1'b1,  8'h00}; // write 0x00 to 0x0251
    init_data[226] = {1'b1,  8'h00}; // write 0x00 to 0x0252
    init_data[227] = {1'b1,  8'h00}; // write 0x00 to 0x0253
    init_data[228] = {1'b1,  8'h00}; // write 0x00 to 0x0254
    init_data[229] = {1'b1,  8'h00}; // write 0x00 to 0x0255
    init_data[230] = {1'b1,  8'h00}; // write 0x00 to 0x0256
    init_data[231] = {1'b1,  8'h00}; // write 0x00 to 0x0257
    init_data[232] = {1'b1,  8'h00}; // write 0x00 to 0x0258
    init_data[233] = {1'b1,  8'h00}; // write 0x00 to 0x0259
    init_data[234] = {1'b1,  8'h00}; // write 0x00 to 0x025a
    init_data[235] = {1'b1,  8'h00}; // write 0x00 to 0x025b
    init_data[236] = {1'b1,  8'h00}; // write 0x00 to 0x025c
    init_data[237] = {1'b1,  8'h00}; // write 0x00 to 0x025d
    init_data[238] = {1'b1,  8'h00}; // write 0x00 to 0x025e
    init_data[239] = {1'b1,  8'h00}; // write 0x00 to 0x025f
    init_data[240] = {1'b1,  8'h00}; // write 0x00 to 0x0260
    init_data[241] = {1'b1,  8'h00}; // write 0x00 to 0x0261
    init_data[242] = {1'b1,  8'h00}; // write 0x00 to 0x0262
    init_data[243] = {1'b1,  8'h00}; // write 0x00 to 0x0263
    init_data[244] = {1'b1,  8'h00}; // write 0x00 to 0x0264
    init_data[245] = {2'b01, 7'h77};
    init_data[246] = {1'b1,  8'h68};
    init_data[247] = {1'b1,  8'h00}; // write 0x00 to 0x0268
    init_data[248] = {1'b1,  8'h00}; // write 0x00 to 0x0269
    init_data[249] = {1'b1,  8'h00}; // write 0x00 to 0x026a
    init_data[250] = {1'b1,  8'h66}; // write 0x66 to 0x026b
    init_data[251] = {1'b1,  8'h70}; // write 0x70 to 0x026c
    init_data[252] = {1'b1,  8'h67}; // write 0x67 to 0x026d
    init_data[253] = {1'b1,  8'h61}; // write 0x61 to 0x026e
    init_data[254] = {1'b1,  8'h00}; // write 0x00 to 0x026f
    init_data[255] = {1'b1,  8'h00}; // write 0x00 to 0x0270
    init_data[256] = {1'b1,  8'h00}; // write 0x00 to 0x0271
    init_data[257] = {1'b1,  8'h00}; // write 0x00 to 0x0272
    init_data[258] = {2'b01, 7'h77};
    init_data[259] = {1'b1,  8'h01};
    init_data[260] = {1'b1,  8'h03}; // set page 0x03
    init_data[261] = {2'b01, 7'h77};
    init_data[262] = {1'b1,  8'h02};
    init_data[263] = {1'b1,  8'h00}; // write 0x00 to 0x0302
    init_data[264] = {1'b1,  8'h00}; // write 0x00 to 0x0303
    init_data[265] = {1'b1,  8'h00}; // write 0x00 to 0x0304
    init_data[266] = {1'b1,  8'h80}; // write 0x80 to 0x0305
    init_data[267] = {1'b1,  8'h14}; // write 0x14 to 0x0306
    init_data[268] = {1'b1,  8'h00}; // write 0x00 to 0x0307
    init_data[269] = {1'b1,  8'h00}; // write 0x00 to 0x0308
    init_data[270] = {1'b1,  8'h00}; // write 0x00 to 0x0309
    init_data[271] = {1'b1,  8'h00}; // write 0x00 to 0x030a
    init_data[272] = {1'b1,  8'h80}; // write 0x80 to 0x030b
    init_data[273] = {1'b1,  8'h00}; // write 0x00 to 0x030c
    init_data[274] = {1'b1,  8'h00}; // write 0x00 to 0x030d
    init_data[275] = {1'b1,  8'h00}; // write 0x00 to 0x030e
    init_data[276] = {1'b1,  8'h00}; // write 0x00 to 0x030f
    init_data[277] = {1'b1,  8'h80}; // write 0x80 to 0x0310
    init_data[278] = {1'b1,  8'h14}; // write 0x14 to 0x0311
    init_data[279] = {1'b1,  8'h00}; // write 0x00 to 0x0312
    init_data[280] = {1'b1,  8'h00}; // write 0x00 to 0x0313
    init_data[281] = {1'b1,  8'h00}; // write 0x00 to 0x0314
    init_data[282] = {1'b1,  8'h00}; // write 0x00 to 0x0315
    init_data[283] = {1'b1,  8'h80}; // write 0x80 to 0x0316
    init_data[284] = {1'b1,  8'h00}; // write 0x00 to 0x0317
    init_data[285] = {1'b1,  8'h00}; // write 0x00 to 0x0318
    init_data[286] = {1'b1,  8'h00}; // write 0x00 to 0x0319
    init_data[287] = {1'b1,  8'h00}; // write 0x00 to 0x031a
    init_data[288] = {1'b1,  8'h80}; // write 0x80 to 0x031b
    init_data[289] = {1'b1,  8'h14}; // write 0x14 to 0x031c
    init_data[290] = {1'b1,  8'h00}; // write 0x00 to 0x031d
    init_data[291] = {1'b1,  8'h00}; // write 0x00 to 0x031e
    init_data[292] = {1'b1,  8'h00}; // write 0x00 to 0x031f
    init_data[293] = {1'b1,  8'h00}; // write 0x00 to 0x0320
    init_data[294] = {1'b1,  8'h80}; // write 0x80 to 0x0321
    init_data[295] = {1'b1,  8'h00}; // write 0x00 to 0x0322
    init_data[296] = {1'b1,  8'h00}; // write 0x00 to 0x0323
    init_data[297] = {1'b1,  8'h00}; // write 0x00 to 0x0324
    init_data[298] = {1'b1,  8'h00}; // write 0x00 to 0x0325
    init_data[299] = {1'b1,  8'h80}; // write 0x80 to 0x0326
    init_data[300] = {1'b1,  8'h14}; // write 0x14 to 0x0327
    init_data[301] = {1'b1,  8'h00}; // write 0x00 to 0x0328
    init_data[302] = {1'b1,  8'h00}; // write 0x00 to 0x0329
    init_data[303] = {1'b1,  8'h00}; // write 0x00 to 0x032a
    init_data[304] = {1'b1,  8'h00}; // write 0x00 to 0x032b
    init_data[305] = {1'b1,  8'h80}; // write 0x80 to 0x032c
    init_data[306] = {1'b1,  8'h00}; // write 0x00 to 0x032d
    init_data[307] = {1'b1,  8'h00}; // write 0x00 to 0x032e
    init_data[308] = {1'b1,  8'h00}; // write 0x00 to 0x032f
    init_data[309] = {1'b1,  8'h10}; // write 0x10 to 0x0330
    init_data[310] = {1'b1,  8'h42}; // write 0x42 to 0x0331
    init_data[311] = {1'b1,  8'h08}; // write 0x08 to 0x0332
    init_data[312] = {1'b1,  8'h00}; // write 0x00 to 0x0333
    init_data[313] = {1'b1,  8'h00}; // write 0x00 to 0x0334
    init_data[314] = {1'b1,  8'h00}; // write 0x00 to 0x0335
    init_data[315] = {1'b1,  8'h00}; // write 0x00 to 0x0336
    init_data[316] = {1'b1,  8'h80}; // write 0x80 to 0x0337
    init_data[317] = {1'b1,  8'h00}; // write 0x00 to 0x0338
    init_data[318] = {1'b1,  8'h1f}; // write 0x1f to 0x0339
    init_data[319] = {2'b01, 7'h77};
    init_data[320] = {1'b1,  8'h3b};
    init_data[321] = {1'b1,  8'h00}; // write 0x00 to 0x033b
    init_data[322] = {1'b1,  8'h00}; // write 0x00 to 0x033c
    init_data[323] = {1'b1,  8'h00}; // write 0x00 to 0x033d
    init_data[324] = {1'b1,  8'h00}; // write 0x00 to 0x033e
    init_data[325] = {1'b1,  8'h00}; // write 0x00 to 0x033f
    init_data[326] = {1'b1,  8'h00}; // write 0x00 to 0x0340
    init_data[327] = {1'b1,  8'h00}; // write 0x00 to 0x0341
    init_data[328] = {1'b1,  8'h00}; // write 0x00 to 0x0342
    init_data[329] = {1'b1,  8'h00}; // write 0x00 to 0x0343
    init_data[330] = {1'b1,  8'h00}; // write 0x00 to 0x0344
    init_data[331] = {1'b1,  8'h00}; // write 0x00 to 0x0345
    init_data[332] = {1'b1,  8'h00}; // write 0x00 to 0x0346
    init_data[333] = {1'b1,  8'h00}; // write 0x00 to 0x0347
    init_data[334] = {1'b1,  8'h00}; // write 0x00 to 0x0348
    init_data[335] = {1'b1,  8'h00}; // write 0x00 to 0x0349
    init_data[336] = {1'b1,  8'h00}; // write 0x00 to 0x034a
    init_data[337] = {1'b1,  8'h00}; // write 0x00 to 0x034b
    init_data[338] = {1'b1,  8'h00}; // write 0x00 to 0x034c
    init_data[339] = {1'b1,  8'h00}; // write 0x00 to 0x034d
    init_data[340] = {1'b1,  8'h00}; // write 0x00 to 0x034e
    init_data[341] = {1'b1,  8'h00}; // write 0x00 to 0x034f
    init_data[342] = {1'b1,  8'h00}; // write 0x00 to 0x0350
    init_data[343] = {1'b1,  8'h00}; // write 0x00 to 0x0351
    init_data[344] = {1'b1,  8'h00}; // write 0x00 to 0x0352
    init_data[345] = {1'b1,  8'h00}; // write 0x00 to 0x0353
    init_data[346] = {1'b1,  8'h00}; // write 0x00 to 0x0354
    init_data[347] = {1'b1,  8'h00}; // write 0x00 to 0x0355
    init_data[348] = {1'b1,  8'h00}; // write 0x00 to 0x0356
    init_data[349] = {1'b1,  8'h00}; // write 0x00 to 0x0357
    init_data[350] = {1'b1,  8'h00}; // write 0x00 to 0x0358
    init_data[351] = {1'b1,  8'h00}; // write 0x00 to 0x0359
    init_data[352] = {1'b1,  8'h00}; // write 0x00 to 0x035a
    init_data[353] = {1'b1,  8'h00}; // write 0x00 to 0x035b
    init_data[354] = {1'b1,  8'h00}; // write 0x00 to 0x035c
    init_data[355] = {1'b1,  8'h00}; // write 0x00 to 0x035d
    init_data[356] = {1'b1,  8'h00}; // write 0x00 to 0x035e
    init_data[357] = {1'b1,  8'h00}; // write 0x00 to 0x035f
    init_data[358] = {1'b1,  8'h00}; // write 0x00 to 0x0360
    init_data[359] = {1'b1,  8'h00}; // write 0x00 to 0x0361
    init_data[360] = {1'b1,  8'h00}; // write 0x00 to 0x0362
    init_data[361] = {2'b01, 7'h77};
    init_data[362] = {1'b1,  8'h01};
    init_data[363] = {1'b1,  8'h08}; // set page 0x08
    init_data[364] = {2'b01, 7'h77};
    init_data[365] = {1'b1,  8'h02};
    init_data[366] = {1'b1,  8'h00}; // write 0x00 to 0x0802
    init_data[367] = {1'b1,  8'h00}; // write 0x00 to 0x0803
    init_data[368] = {1'b1,  8'h00}; // write 0x00 to 0x0804
    init_data[369] = {1'b1,  8'h00}; // write 0x00 to 0x0805
    init_data[370] = {1'b1,  8'h00}; // write 0x00 to 0x0806
    init_data[371] = {1'b1,  8'h00}; // write 0x00 to 0x0807
    init_data[372] = {1'b1,  8'h00}; // write 0x00 to 0x0808
    init_data[373] = {1'b1,  8'h00}; // write 0x00 to 0x0809
    init_data[374] = {1'b1,  8'h00}; // write 0x00 to 0x080a
    init_data[375] = {1'b1,  8'h00}; // write 0x00 to 0x080b
    init_data[376] = {1'b1,  8'h00}; // write 0x00 to 0x080c
    init_data[377] = {1'b1,  8'h00}; // write 0x00 to 0x080d
    init_data[378] = {1'b1,  8'h00}; // write 0x00 to 0x080e
    init_data[379] = {1'b1,  8'h00}; // write 0x00 to 0x080f
    init_data[380] = {1'b1,  8'h00}; // write 0x00 to 0x0810
    init_data[381] = {1'b1,  8'h00}; // write 0x00 to 0x0811
    init_data[382] = {1'b1,  8'h00}; // write 0x00 to 0x0812
    init_data[383] = {1'b1,  8'h00}; // write 0x00 to 0x0813
    init_data[384] = {1'b1,  8'h00}; // write 0x00 to 0x0814
    init_data[385] = {1'b1,  8'h00}; // write 0x00 to 0x0815
    init_data[386] = {1'b1,  8'h00}; // write 0x00 to 0x0816
    init_data[387] = {1'b1,  8'h00}; // write 0x00 to 0x0817
    init_data[388] = {1'b1,  8'h00}; // write 0x00 to 0x0818
    init_data[389] = {1'b1,  8'h00}; // write 0x00 to 0x0819
    init_data[390] = {1'b1,  8'h00}; // write 0x00 to 0x081a
    init_data[391] = {1'b1,  8'h00}; // write 0x00 to 0x081b
    init_data[392] = {1'b1,  8'h00}; // write 0x00 to 0x081c
    init_data[393] = {1'b1,  8'h00}; // write 0x00 to 0x081d
    init_data[394] = {1'b1,  8'h00}; // write 0x00 to 0x081e
    init_data[395] = {1'b1,  8'h00}; // write 0x00 to 0x081f
    init_data[396] = {1'b1,  8'h00}; // write 0x00 to 0x0820
    init_data[397] = {1'b1,  8'h00}; // write 0x00 to 0x0821
    init_data[398] = {1'b1,  8'h00}; // write 0x00 to 0x0822
    init_data[399] = {1'b1,  8'h00}; // write 0x00 to 0x0823
    init_data[400] = {1'b1,  8'h00}; // write 0x00 to 0x0824
    init_data[401] = {1'b1,  8'h00}; // write 0x00 to 0x0825
    init_data[402] = {1'b1,  8'h00}; // write 0x00 to 0x0826
    init_data[403] = {1'b1,  8'h00}; // write 0x00 to 0x0827
    init_data[404] = {1'b1,  8'h00}; // write 0x00 to 0x0828
    init_data[405] = {1'b1,  8'h00}; // write 0x00 to 0x0829
    init_data[406] = {1'b1,  8'h00}; // write 0x00 to 0x082a
    init_data[407] = {1'b1,  8'h00}; // write 0x00 to 0x082b
    init_data[408] = {1'b1,  8'h00}; // write 0x00 to 0x082c
    init_data[409] = {1'b1,  8'h00}; // write 0x00 to 0x082d
    init_data[410] = {1'b1,  8'h00}; // write 0x00 to 0x082e
    init_data[411] = {1'b1,  8'h00}; // write 0x00 to 0x082f
    init_data[412] = {1'b1,  8'h00}; // write 0x00 to 0x0830
    init_data[413] = {1'b1,  8'h00}; // write 0x00 to 0x0831
    init_data[414] = {1'b1,  8'h00}; // write 0x00 to 0x0832
    init_data[415] = {1'b1,  8'h00}; // write 0x00 to 0x0833
    init_data[416] = {1'b1,  8'h00}; // write 0x00 to 0x0834
    init_data[417] = {1'b1,  8'h00}; // write 0x00 to 0x0835
    init_data[418] = {1'b1,  8'h00}; // write 0x00 to 0x0836
    init_data[419] = {1'b1,  8'h00}; // write 0x00 to 0x0837
    init_data[420] = {1'b1,  8'h00}; // write 0x00 to 0x0838
    init_data[421] = {1'b1,  8'h00}; // write 0x00 to 0x0839
    init_data[422] = {1'b1,  8'h00}; // write 0x00 to 0x083a
    init_data[423] = {1'b1,  8'h00}; // write 0x00 to 0x083b
    init_data[424] = {1'b1,  8'h00}; // write 0x00 to 0x083c
    init_data[425] = {1'b1,  8'h00}; // write 0x00 to 0x083d
    init_data[426] = {1'b1,  8'h00}; // write 0x00 to 0x083e
    init_data[427] = {1'b1,  8'h00}; // write 0x00 to 0x083f
    init_data[428] = {1'b1,  8'h00}; // write 0x00 to 0x0840
    init_data[429] = {1'b1,  8'h00}; // write 0x00 to 0x0841
    init_data[430] = {1'b1,  8'h00}; // write 0x00 to 0x0842
    init_data[431] = {1'b1,  8'h00}; // write 0x00 to 0x0843
    init_data[432] = {1'b1,  8'h00}; // write 0x00 to 0x0844
    init_data[433] = {1'b1,  8'h00}; // write 0x00 to 0x0845
    init_data[434] = {1'b1,  8'h00}; // write 0x00 to 0x0846
    init_data[435] = {1'b1,  8'h00}; // write 0x00 to 0x0847
    init_data[436] = {1'b1,  8'h00}; // write 0x00 to 0x0848
    init_data[437] = {1'b1,  8'h00}; // write 0x00 to 0x0849
    init_data[438] = {1'b1,  8'h00}; // write 0x00 to 0x084a
    init_data[439] = {1'b1,  8'h00}; // write 0x00 to 0x084b
    init_data[440] = {1'b1,  8'h00}; // write 0x00 to 0x084c
    init_data[441] = {1'b1,  8'h00}; // write 0x00 to 0x084d
    init_data[442] = {1'b1,  8'h00}; // write 0x00 to 0x084e
    init_data[443] = {1'b1,  8'h00}; // write 0x00 to 0x084f
    init_data[444] = {1'b1,  8'h00}; // write 0x00 to 0x0850
    init_data[445] = {1'b1,  8'h00}; // write 0x00 to 0x0851
    init_data[446] = {1'b1,  8'h00}; // write 0x00 to 0x0852
    init_data[447] = {1'b1,  8'h00}; // write 0x00 to 0x0853
    init_data[448] = {1'b1,  8'h00}; // write 0x00 to 0x0854
    init_data[449] = {1'b1,  8'h00}; // write 0x00 to 0x0855
    init_data[450] = {1'b1,  8'h00}; // write 0x00 to 0x0856
    init_data[451] = {1'b1,  8'h00}; // write 0x00 to 0x0857
    init_data[452] = {1'b1,  8'h00}; // write 0x00 to 0x0858
    init_data[453] = {1'b1,  8'h00}; // write 0x00 to 0x0859
    init_data[454] = {1'b1,  8'h00}; // write 0x00 to 0x085a
    init_data[455] = {1'b1,  8'h00}; // write 0x00 to 0x085b
    init_data[456] = {1'b1,  8'h00}; // write 0x00 to 0x085c
    init_data[457] = {1'b1,  8'h00}; // write 0x00 to 0x085d
    init_data[458] = {1'b1,  8'h00}; // write 0x00 to 0x085e
    init_data[459] = {1'b1,  8'h00}; // write 0x00 to 0x085f
    init_data[460] = {1'b1,  8'h00}; // write 0x00 to 0x0860
    init_data[461] = {1'b1,  8'h00}; // write 0x00 to 0x0861
    init_data[462] = {2'b01, 7'h77};
    init_data[463] = {1'b1,  8'h01};
    init_data[464] = {1'b1,  8'h09}; // set page 0x09
    init_data[465] = {2'b01, 7'h77};
    init_data[466] = {1'b1,  8'h0e};
    init_data[467] = {1'b1,  8'h00}; // write 0x00 to 0x090e
    init_data[468] = {2'b01, 7'h77};
    init_data[469] = {1'b1,  8'h1c};
    init_data[470] = {1'b1,  8'h04}; // write 0x04 to 0x091c
    init_data[471] = {2'b01, 7'h77};
    init_data[472] = {1'b1,  8'h43};
    init_data[473] = {1'b1,  8'h00}; // write 0x00 to 0x0943
    init_data[474] = {2'b01, 7'h77};
    init_data[475] = {1'b1,  8'h49};
    init_data[476] = {1'b1,  8'h03}; // write 0x03 to 0x0949
    init_data[477] = {1'b1,  8'h30}; // write 0x30 to 0x094a
    init_data[478] = {2'b01, 7'h77};
    init_data[479] = {1'b1,  8'h4e};
    init_data[480] = {1'b1,  8'h49}; // write 0x49 to 0x094e
    init_data[481] = {1'b1,  8'h02}; // write 0x02 to 0x094f
    init_data[482] = {2'b01, 7'h77};
    init_data[483] = {1'b1,  8'h5e};
    init_data[484] = {1'b1,  8'h00}; // write 0x00 to 0x095e
    init_data[485] = {2'b01, 7'h77};
    init_data[486] = {1'b1,  8'h01};
    init_data[487] = {1'b1,  8'h0a}; // set page 0x0a
    init_data[488] = {2'b01, 7'h77};
    init_data[489] = {1'b1,  8'h02};
    init_data[490] = {1'b1,  8'h00}; // write 0x00 to 0x0a02
    init_data[491] = {1'b1,  8'h1f}; // write 0x1f to 0x0a03
    init_data[492] = {1'b1,  8'h0f}; // write 0x0f to 0x0a04
    init_data[493] = {1'b1,  8'h1f}; // write 0x1f to 0x0a05
    init_data[494] = {2'b01, 7'h77};
    init_data[495] = {1'b1,  8'h14};
    init_data[496] = {1'b1,  8'h00}; // write 0x00 to 0x0a14
    init_data[497] = {2'b01, 7'h77};
    init_data[498] = {1'b1,  8'h1a};
    init_data[499] = {1'b1,  8'h00}; // write 0x00 to 0x0a1a
    init_data[500] = {2'b01, 7'h77};
    init_data[501] = {1'b1,  8'h20};
    init_data[502] = {1'b1,  8'h00}; // write 0x00 to 0x0a20
    init_data[503] = {2'b01, 7'h77};
    init_data[504] = {1'b1,  8'h26};
    init_data[505] = {1'b1,  8'h00}; // write 0x00 to 0x0a26
    init_data[506] = {2'b01, 7'h77};
    init_data[507] = {1'b1,  8'h2c};
    init_data[508] = {1'b1,  8'h00}; // write 0x00 to 0x0a2c
    init_data[509] = {2'b01, 7'h77};
    init_data[510] = {1'b1,  8'h01};
    init_data[511] = {1'b1,  8'h0b}; // set page 0x0b
    init_data[512] = {2'b01, 7'h77};
    init_data[513] = {1'b1,  8'h44};
    init_data[514] = {1'b1,  8'h0f}; // write 0x0f to 0x0b44
    init_data[515] = {2'b01, 7'h77};
    init_data[516] = {1'b1,  8'h4a};
    init_data[517] = {1'b1,  8'h00}; // write 0x00 to 0x0b4a
    init_data[518] = {2'b01, 7'h77};
    init_data[519] = {1'b1,  8'h57};
    init_data[520] = {1'b1,  8'ha5}; // write 0xa5 to 0x0b57
    init_data[521] = {1'b1,  8'h00}; // write 0x00 to 0x0b58
    // End configuration registers
    // 
    // Start configuration postamble
    init_data[522] = {2'b01, 7'h77};
    init_data[523] = {1'b1,  8'h01};
    init_data[524] = {1'b1,  8'h00}; // set page 0x00
    init_data[525] = {2'b01, 7'h77};
    init_data[526] = {1'b1,  8'h1c};
    init_data[527] = {1'b1,  8'h01}; // write 0x01 to 0x001c
    init_data[528] = {2'b01, 7'h77};
    init_data[529] = {1'b1,  8'h01};
    init_data[530] = {1'b1,  8'h0b}; // set page 0x0b
    init_data[531] = {2'b01, 7'h77};
    init_data[532] = {1'b1,  8'h24};
    init_data[533] = {1'b1,  8'hc3}; // write 0xc3 to 0x0b24
    init_data[534] = {1'b1,  8'h02}; // write 0x02 to 0x0b25
    // End configuration postamble
    init_data[535] = 9'd0; // end
end

localparam [3:0]
    STATE_IDLE = 3'd0,
    STATE_RUN = 3'd1,
    STATE_TABLE_1 = 3'd2,
    STATE_TABLE_2 = 3'd3,
    STATE_TABLE_3 = 3'd4;

reg [4:0] state_reg = STATE_IDLE, state_next;

parameter AW = $clog2(INIT_DATA_LEN);

reg [8:0] init_data_reg = 9'd0;

reg [AW-1:0] address_reg = {AW{1'b0}}, address_next;
reg [AW-1:0] address_ptr_reg = {AW{1'b0}}, address_ptr_next;
reg [AW-1:0] data_ptr_reg = {AW{1'b0}}, data_ptr_next;

reg [6:0] cur_address_reg = 7'd0, cur_address_next;

reg [31:0] delay_counter_reg = 32'd0, delay_counter_next;

reg [6:0] m_axis_cmd_address_reg = 7'd0, m_axis_cmd_address_next;
reg m_axis_cmd_start_reg = 1'b0, m_axis_cmd_start_next;
reg m_axis_cmd_write_reg = 1'b0, m_axis_cmd_write_next;
reg m_axis_cmd_stop_reg = 1'b0, m_axis_cmd_stop_next;
reg m_axis_cmd_valid_reg = 1'b0, m_axis_cmd_valid_next;

reg [7:0] m_axis_data_tdata_reg = 8'd0, m_axis_data_tdata_next;
reg m_axis_data_tvalid_reg = 1'b0, m_axis_data_tvalid_next;

reg start_flag_reg = 1'b0, start_flag_next;

reg busy_reg = 1'b0;

assign m_axis_cmd_address = m_axis_cmd_address_reg;
assign m_axis_cmd_start = m_axis_cmd_start_reg;
assign m_axis_cmd_read = 1'b0;
assign m_axis_cmd_write = m_axis_cmd_write_reg;
assign m_axis_cmd_write_multiple = 1'b0;
assign m_axis_cmd_stop = m_axis_cmd_stop_reg;
assign m_axis_cmd_valid = m_axis_cmd_valid_reg;

assign m_axis_data_tdata = m_axis_data_tdata_reg;
assign m_axis_data_tvalid = m_axis_data_tvalid_reg;
assign m_axis_data_tlast = 1'b1;

assign busy = busy_reg;

always @* begin
    state_next = STATE_IDLE;

    address_next = address_reg;
    address_ptr_next = address_ptr_reg;
    data_ptr_next = data_ptr_reg;

    cur_address_next = cur_address_reg;

    delay_counter_next = delay_counter_reg;

    m_axis_cmd_address_next = m_axis_cmd_address_reg;
    m_axis_cmd_start_next = m_axis_cmd_start_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_write_next = m_axis_cmd_write_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_stop_next = m_axis_cmd_stop_reg & ~(m_axis_cmd_valid & m_axis_cmd_ready);
    m_axis_cmd_valid_next = m_axis_cmd_valid_reg & ~m_axis_cmd_ready;

    m_axis_data_tdata_next = m_axis_data_tdata_reg;
    m_axis_data_tvalid_next = m_axis_data_tvalid_reg & ~m_axis_data_tready;

    start_flag_next = start_flag_reg;

    if (m_axis_cmd_valid | m_axis_data_tvalid) begin
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
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    m_axis_cmd_write_next = 1'b1;
                    m_axis_cmd_stop_next = 1'b0;
                    m_axis_cmd_valid_next = 1'b1;

                    m_axis_data_tdata_next = init_data_reg[7:0];
                    m_axis_data_tvalid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    m_axis_cmd_address_next = init_data_reg[6:0];
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg[8:4] == 5'b00001) begin
                    // delay
                    delay_counter_next = 32'd1 << (init_data_reg[3:0]+16);

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end
            end
            STATE_TABLE_1: begin
                // find address table start
                if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end
            end
            STATE_TABLE_2: begin
                // find next address
                if (init_data_reg[8:7] == 2'b01) begin
                    // write address command
                    // store address and move to data table
                    cur_address_next = init_data_reg[6:0];
                    address_ptr_next = address_reg + 1;
                    address_next = data_ptr_reg;
                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_2;
                end
            end
            STATE_TABLE_3: begin
                // process data table with selected address
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    m_axis_cmd_write_next = 1'b1;
                    m_axis_cmd_stop_next = 1'b0;
                    m_axis_cmd_valid_next = 1'b1;

                    m_axis_data_tdata_next = init_data_reg[7:0];
                    m_axis_data_tvalid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    m_axis_cmd_address_next = init_data_reg[6:0];
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000000011) begin
                    // write current address
                    m_axis_cmd_address_next = cur_address_reg;
                    m_axis_cmd_start_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

                    address_next = address_reg + 1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 1;
                    address_next = address_reg + 1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_next = address_ptr_reg;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    m_axis_cmd_start_next = 1'b0;
                    m_axis_cmd_write_next = 1'b0;
                    m_axis_cmd_stop_next = 1'b1;
                    m_axis_cmd_valid_next = 1'b1;

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

always @(posedge clk) begin
    state_reg <= state_next;

    // read init_data ROM
    init_data_reg <= init_data[address_next];

    address_reg <= address_next;
    address_ptr_reg <= address_ptr_next;
    data_ptr_reg <= data_ptr_next;

    cur_address_reg <= cur_address_next;

    delay_counter_reg <= delay_counter_next;

    m_axis_cmd_address_reg <= m_axis_cmd_address_next;
    m_axis_cmd_start_reg <= m_axis_cmd_start_next;
    m_axis_cmd_write_reg <= m_axis_cmd_write_next;
    m_axis_cmd_stop_reg <= m_axis_cmd_stop_next;
    m_axis_cmd_valid_reg <= m_axis_cmd_valid_next;

    m_axis_data_tdata_reg <= m_axis_data_tdata_next;
    m_axis_data_tvalid_reg <= m_axis_data_tvalid_next;

    start_flag_reg <= start & start_flag_next;

    busy_reg <= (state_reg != STATE_IDLE);

    if (rst) begin
        state_reg <= STATE_IDLE;

        init_data_reg <= 9'd0;

        address_reg <= {AW{1'b0}};
        address_ptr_reg <= {AW{1'b0}};
        data_ptr_reg <= {AW{1'b0}};

        cur_address_reg <= 7'd0;

        delay_counter_reg <= 32'd0;

        m_axis_cmd_valid_reg <= 1'b0;

        m_axis_data_tvalid_reg <= 1'b0;

        start_flag_reg <= 1'b0;

        busy_reg <= 1'b0;
    end
end

endmodule

`resetall
