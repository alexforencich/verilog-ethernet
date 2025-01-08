// (c) Copyright 1995-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
// DO NOT MODIFY THIS FILE.


// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

ila your_instance_name (
	.clk(clk), // input wire clk
	.trig_out(trig_out),// output wire trig_out 
	.trig_out_ack(trig_out_ack),// input wire trig_out_ack 
	.trig_in(trig_in),// input wire trig_in 
	.trig_in_ack(trig_in_ack),// output wire trig_in_ack 
	.probe0(probe0), // input wire [3:0]  probe0  
	.probe1(probe1), // input wire [3:0]  probe1 
	.probe2(probe2), // input wire [0:0]  probe2 
	.probe3(probe3), // input wire [0:0]  probe3 
	.probe4(probe4), // input wire [0:0]  probe4 
	.probe5(probe5), // input wire [0:0]  probe5 
	.probe6(probe6), // input wire [0:0]  probe6 
	.probe7(probe7), // input wire [0:0]  probe7 
	.probe8(probe8) // input wire [0:0]  probe8
);

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file ila when simulating
// the core, ila. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.


