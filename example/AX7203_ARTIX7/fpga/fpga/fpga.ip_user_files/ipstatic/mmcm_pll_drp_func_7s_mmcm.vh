///////////////////////////////////////////////////////////////////////////////
//    
//    Company:          Xilinx
//    Engineer:         Jim Tatsukawa, Karl Kurbjun and Carl Ribbing
//    Date:             7/30/2014
//    Design Name:      MMCME2 DRP
//    Module Name:      mmcme2_drp_func.h
//    Version:          1.04
//    Target Devices:   7 Series || MMCM
//    Tool versions:    2014.3
//    Description:      This header provides the functions necessary to  
//                      calculate the DRP register values for the V6 MMCM.
//                      
//	Revision Notes:	3/12 - Updating lookup_low/lookup_high (CR)
//			4/13 - Fractional divide function in mmcm_frac_count_calc function. CRS610807
// 
//    Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                 INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                 PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                 PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                 ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                 APPLICATION OR STANDARD, XILINX IS MAKING NO
//                 REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                 FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                 RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                 REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                 EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                 RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                 INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                 FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                 PURPOSE.
// 
//                 (c) Copyright 2009-2010 Xilinx, Inc.
//                 All rights reserved.
// 
///////////////////////////////////////////////////////////////////////////////

// These are user functions that should not be modified.  Changes to the defines
// or code within the functions may alter the accuracy of the calculations.

// Define debug to provide extra messages durring elaboration
//`define DEBUG 1

// FRAC_PRECISION describes the width of the fractional portion of the fixed
//    point numbers.  These should not be modified, they are for development 
//    only
`define FRAC_PRECISION  10
// FIXED_WIDTH describes the total size for fixed point calculations(int+frac).
// Warning: L.50 and below will not calculate properly with FIXED_WIDTHs 
//    greater than 32
`define FIXED_WIDTH     32 

// This function takes a fixed point number and rounds it to the nearest
//    fractional precision bit.
function [`FIXED_WIDTH:1] round_frac
   (
      // Input is (FIXED_WIDTH-FRAC_PRECISION).FRAC_PRECISION fixed point number
      input [`FIXED_WIDTH:1] decimal,  

      // This describes the precision of the fraction, for example a value
      //    of 1 would modify the fractional so that instead of being a .16
      //    fractional, it would be a .1 (rounded to the nearest 0.5 in turn)
      input [`FIXED_WIDTH:1] precision 
   );

   begin
   
   `ifdef DEBUG
      $display("round_frac - decimal: %h, precision: %h", decimal, precision);
   `endif
      // If the fractional precision bit is high then round up
      if( decimal[(`FRAC_PRECISION-precision)] == 1'b1) begin
         round_frac = decimal + (1'b1 << (`FRAC_PRECISION-precision));
      end else begin
         round_frac = decimal;
      end
   `ifdef DEBUG
      $display("round_frac: %h", round_frac);
   `endif
   end
endfunction

// This function calculates high_time, low_time, w_edge, and no_count
//    of a non-fractional counter based on the divide and duty cycle
//
// NOTE: high_time and low_time are returned as integers between 0 and 63 
//    inclusive.  64 should equal 6'b000000 (in other words it is okay to 
//    ignore the overflow)
function [13:0] mmcm_pll_divider
   (
      input [7:0] divide,        // Max divide is 128
      input [31:0] duty_cycle    // Duty cycle is multiplied by 100,000
   );

   reg [`FIXED_WIDTH:1]    duty_cycle_fix;
   
   // High/Low time is initially calculated with a wider integer to prevent a
   // calculation error when it overflows to 64.
   reg [6:0]               high_time;
   reg [6:0]               low_time;
   reg                     w_edge;
   reg                     no_count;

   reg [`FIXED_WIDTH:1]    temp;

   begin
      // Duty Cycle must be between 0 and 1,000
      if(duty_cycle <=0 || duty_cycle >= 100000) begin
`ifndef SYNTHESIS
         $display("ERROR: duty_cycle: %d is invalid", duty_cycle);
   `endif
         $finish;
      end

      // Convert to FIXED_WIDTH-FRAC_PRECISION.FRAC_PRECISION fixed point
      duty_cycle_fix = (duty_cycle << `FRAC_PRECISION) / 100_000;
      
   `ifdef DEBUG
      $display("duty_cycle_fix: %h", duty_cycle_fix);
   `endif

      // If the divide is 1 nothing needs to be set except the no_count bit.
      //    Other values are dummies
      if(divide == 7'h01) begin
         high_time   = 7'h01;
         w_edge      = 1'b0;
         low_time    = 7'h01;
         no_count    = 1'b1;
      end else begin
         temp = round_frac(duty_cycle_fix*divide, 1);

         // comes from above round_frac
         high_time   = temp[`FRAC_PRECISION+7:`FRAC_PRECISION+1]; 
         // If the duty cycle * divide rounded is .5 or greater then this bit
         //    is set.
         w_edge      = temp[`FRAC_PRECISION]; // comes from round_frac
         
         // If the high time comes out to 0, it needs to be set to at least 1
         // and w_edge set to 0
         if(high_time == 7'h00) begin
            high_time   = 7'h01;
            w_edge      = 1'b0;
         end

         if(high_time == divide) begin
            high_time   = divide - 1;
            w_edge      = 1'b1;
         end
         
         // Calculate low_time based on the divide setting and set no_count to
         //    0 as it is only used when divide is 1.
         low_time    = divide - high_time; 
         no_count    = 1'b0;
      end

      // Set the return value.
      mmcm_pll_divider = {w_edge,no_count,high_time[5:0],low_time[5:0]};
   end
endfunction

// This function calculates mx, delay_time, and phase_mux 
//  of a non-fractional counter based on the divide and phase
//
// NOTE: The only valid value for the MX bits is 2'b00 to ensure the coarse mux
//    is used.
function [10:0] mmcm_pll_phase
   (
      // divide must be an integer (use fractional if not)
      //  assumed that divide already checked to be valid
      input [7:0] divide, // Max divide is 128

      // Phase is given in degrees (-360,000 to 360,000)
      input signed [31:0] phase
   );

   reg [`FIXED_WIDTH:1] phase_in_cycles;
   reg [`FIXED_WIDTH:1] phase_fixed;
   reg [1:0]            mx;
   reg [5:0]            delay_time;
   reg [2:0]            phase_mux;

   reg [`FIXED_WIDTH:1] temp;

   begin
`ifdef DEBUG
      $display("mmcm_pll_phase-divide:%d,phase:%d",
         divide, phase);
`endif
   
      if ((phase < -360000) || (phase > 360000)) begin
`ifndef SYNTHESIS
      $display("ERROR: phase of $phase is not between -360000 and 360000");
	`endif
         $finish;
      end

      // If phase is less than 0, convert it to a positive phase shift
      // Convert to (FIXED_WIDTH-FRAC_PRECISION).FRAC_PRECISION fixed point
      if(phase < 0) begin
         phase_fixed = ( (phase + 360000) << `FRAC_PRECISION ) / 1000;
      end else begin
         phase_fixed = ( phase << `FRAC_PRECISION ) / 1000;
      end

      // Put phase in terms of decimal number of vco clock cycles
      phase_in_cycles = ( phase_fixed * divide ) / 360;

`ifdef DEBUG
      $display("phase_in_cycles: %h", phase_in_cycles);
`endif  
      

	 temp  =  round_frac(phase_in_cycles, 3);

	 // set mx to 2'b00 that the phase mux from the VCO is enabled
	 mx    			=  2'b00; 
	 phase_mux      =  temp[`FRAC_PRECISION:`FRAC_PRECISION-2];
	 delay_time     =  temp[`FRAC_PRECISION+6:`FRAC_PRECISION+1];
      
   `ifdef DEBUG
      $display("temp: %h", temp);
   `endif

      // Setup the return value
      mmcm_pll_phase={mx, phase_mux, delay_time};
   end
endfunction

// This function takes the divide value and outputs the necessary lock values
function [39:0] mmcm_pll_lock_lookup
   (
      input [6:0] divide // Max divide is 64
   );
   
   reg [2559:0]   lookup;
   
   begin
      lookup = {
         // This table is composed of:
         // LockRefDly_LockFBDly_LockCnt_LockSatHigh_UnlockCnt
         40'b00110_00110_1111101000_1111101001_0000000001,
         40'b00110_00110_1111101000_1111101001_0000000001,
         40'b01000_01000_1111101000_1111101001_0000000001,
         40'b01011_01011_1111101000_1111101001_0000000001,
         40'b01110_01110_1111101000_1111101001_0000000001,
         40'b10001_10001_1111101000_1111101001_0000000001,
         40'b10011_10011_1111101000_1111101001_0000000001,
         40'b10110_10110_1111101000_1111101001_0000000001,
         40'b11001_11001_1111101000_1111101001_0000000001,
         40'b11100_11100_1111101000_1111101001_0000000001,
         40'b11111_11111_1110000100_1111101001_0000000001,
         40'b11111_11111_1100111001_1111101001_0000000001,
         40'b11111_11111_1011101110_1111101001_0000000001,
         40'b11111_11111_1010111100_1111101001_0000000001,
         40'b11111_11111_1010001010_1111101001_0000000001,
         40'b11111_11111_1001110001_1111101001_0000000001,
         40'b11111_11111_1000111111_1111101001_0000000001,
         40'b11111_11111_1000100110_1111101001_0000000001,
         40'b11111_11111_1000001101_1111101001_0000000001,
         40'b11111_11111_0111110100_1111101001_0000000001,
         40'b11111_11111_0111011011_1111101001_0000000001,
         40'b11111_11111_0111000010_1111101001_0000000001,
         40'b11111_11111_0110101001_1111101001_0000000001,
         40'b11111_11111_0110010000_1111101001_0000000001,
         40'b11111_11111_0110010000_1111101001_0000000001,
         40'b11111_11111_0101110111_1111101001_0000000001,
         40'b11111_11111_0101011110_1111101001_0000000001,
         40'b11111_11111_0101011110_1111101001_0000000001,
         40'b11111_11111_0101000101_1111101001_0000000001,
         40'b11111_11111_0101000101_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001
      };
      
      // Set lookup_entry with the explicit bits from lookup with a part select
      mmcm_pll_lock_lookup = lookup[ ((64-divide)*40) +: 40];
   `ifdef DEBUG
      $display("lock_lookup: %b", mmcm_pll_lock_lookup);
   `endif
   end
endfunction

// This function takes the divide value and the bandwidth setting of the MMCM
//  and outputs the digital filter settings necessary.
function [9:0] mmcm_pll_filter_lookup
   (
      input [6:0] divide, // Max divide is 64
      input [8*9:0] BANDWIDTH
   );
   
   reg [639:0] lookup_low;
   reg [639:0] lookup_high;
   
   reg [9:0] lookup_entry;
   
   begin
      lookup_low = {
         // CP_RES_LFHF
         10'b0010_1111_00,
         10'b0010_1111_00,
         10'b0010_1111_00,
         10'b0010_1111_00,
         10'b0010_0111_00,
         10'b0010_1011_00,
         10'b0010_1101_00,
         10'b0010_0011_00,
         10'b0010_0101_00,
         10'b0010_0101_00,
         10'b0010_1001_00,
         10'b0010_1110_00,
         10'b0010_1110_00,
         10'b0010_1110_00,
         10'b0010_1110_00,
         10'b0010_0001_00,
         10'b0010_0001_00,
         10'b0010_0001_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_0110_00,
         10'b0010_1010_00,
         10'b0010_1010_00,
         10'b0010_1010_00,
         10'b0010_1010_00,
         10'b0010_1010_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_1100_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00,
         10'b0010_0010_00
      };
      
      lookup_high = {
         // CP_RES_LFHF
         10'b0010_1111_00,
         10'b0100_1111_00,
         10'b0101_1011_00,
         10'b0111_0111_00,
         10'b1101_0111_00,
         10'b1110_1011_00,
         10'b1110_1101_00,
         10'b1111_0011_00,
         10'b1110_0101_00,
         10'b1111_0101_00,
         10'b1111_1001_00,
         10'b1101_0001_00,
         10'b1111_1001_00,
         10'b1111_1001_00,
         10'b1111_1001_00,
         10'b1111_1001_00,
         10'b1111_0101_00,
         10'b1111_0101_00,
         10'b1100_0001_00,
         10'b1100_0001_00,
         10'b1100_0001_00,
         10'b0101_1100_00,
         10'b0101_1100_00,
         10'b0101_1100_00,
         10'b0101_1100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0011_0100_00,
         10'b0010_1000_00,
         10'b0010_1000_00,
         10'b0010_1000_00,
         10'b0010_1000_00,
         10'b0010_1000_00,
         10'b0111_0001_00,
         10'b0111_0001_00,
         10'b0100_1100_00,
         10'b0100_1100_00,
         10'b0100_1100_00,
         10'b0100_1100_00,
         10'b0110_0001_00,
         10'b0110_0001_00,
         10'b0101_0110_00,
         10'b0101_0110_00,
         10'b0101_0110_00,
         10'b0010_0100_00,
         10'b0010_0100_00,
         10'b0010_0100_00,
         10'b0010_0100_00,
         10'b0100_1010_00,
         10'b0011_1100_00,
         10'b0011_1100_00
      };
      
      // Set lookup_entry with the explicit bits from lookup with a part select
      if(BANDWIDTH == "LOW") begin
         // Low Bandwidth
         mmcm_pll_filter_lookup = lookup_low[ ((64-divide)*10) +: 10];
      end else begin
         // High or optimized bandwidth
         mmcm_pll_filter_lookup = lookup_high[ ((64-divide)*10) +: 10];
      end
      
   `ifdef DEBUG
      $display("filter_lookup: %b", mmcm_pll_filter_lookup);
   `endif
   end
endfunction

// This function takes in the divide, phase, and duty cycle
// setting to calculate the upper and lower counter registers.
function [37:0] mmcm_pll_count_calc
   (
      input [7:0] divide, // Max divide is 128
      input signed [31:0] phase,
      input [31:0] duty_cycle // Multiplied by 100,000
   );
   
   reg [13:0] div_calc;
   reg [16:0] phase_calc;
   
   begin
   `ifdef DEBUG
      $display("mmcm_pll_count_calc- divide:%h, phase:%d, duty_cycle:%d",
         divide, phase, duty_cycle);
   `endif
   
      // w_edge[13], no_count[12], high_time[11:6], low_time[5:0]
      div_calc = mmcm_pll_divider(divide, duty_cycle);
      // mx[10:9], pm[8:6], dt[5:0]
      phase_calc = mmcm_pll_phase(divide, phase);

      // Return value is the upper and lower address of counter
      //    Upper address is:
      //       RESERVED    [31:26]
      //       MX          [25:24]
      //       EDGE        [23]
      //       NOCOUNT     [22]
      //       DELAY_TIME  [21:16]
      //    Lower Address is:
      //       PHASE_MUX   [15:13]
      //       RESERVED    [12]
      //       HIGH_TIME   [11:6]
      //       LOW_TIME    [5:0]
      
   `ifdef DEBUG
      $display("div:%d dc:%d phase:%d ht:%d lt:%d ed:%d nc:%d mx:%d dt:%d pm:%d",
         divide, duty_cycle, phase, div_calc[11:6], div_calc[5:0], 
         div_calc[13], div_calc[12], 
         phase_calc[16:15], phase_calc[5:0], phase_calc[14:12]);
   `endif
      
      mmcm_pll_count_calc =
         {
            // Upper Address
            6'h00, phase_calc[10:9], div_calc[13:12], phase_calc[5:0], 
            // Lower Address
            phase_calc[8:6], 1'b0, div_calc[11:0]
         };
   end
endfunction


// This function takes in the divide, phase, and duty cycle
// setting to calculate the upper and lower counter registers.
// for fractional multiply/divide functions.
//
// 
function [37:0] mmcm_frac_count_calc
   (
      input [7:0] divide, // Max divide is 128
      input signed [31:0] phase,
      input [31:0] duty_cycle, // Multiplied by 1,000
      input [9:0] frac // Multiplied by 1000
   );
   
	//Required for fractional divide calculations
			  reg	[7:0]			lt_frac;
			  reg	[7:0]			ht_frac;
			
			  reg	/*[7:0]*/			wf_fall_frac;
			  reg	/*[7:0]*/			wf_rise_frac;

			  reg [31:0] a;
			  reg	[7:0]			pm_rise_frac_filtered ;
			  reg	[7:0]			pm_fall_frac_filtered ;	
			  reg [7:0]			clkout0_divide_int;
			  reg [2:0]			clkout0_divide_frac;
			  reg	[7:0]			even_part_high;
			  reg	[7:0]			even_part_low;

			  reg	[7:0]			odd;
			  reg	[7:0]			odd_and_frac;

			  reg	[7:0]			pm_fall;
			  reg	[7:0]			pm_rise;
			  reg	[7:0]			dt;
			  reg	[7:0]			dt_int; 
			  reg [63:0]		dt_calc;

			  reg	[7:0]			pm_rise_frac; 
			  reg	[7:0]			pm_fall_frac;
	 
			  reg [31:0] a_per_in_octets;
			  reg [31:0] a_phase_in_cycles;

				parameter precision = 0.125;

			  reg [31:0] phase_fixed; // changed to 31:0 from 32:1 jt 5/2/11
			  reg [31: 0] phase_pos;
			  reg [31: 0] phase_vco;
			  reg [31:0] temp;// changed to 31:0 from 32:1 jt 5/2/11
			  reg [13:0] div_calc;
			  reg [16:0] phase_calc;

   begin
	`ifdef DEBUG
			$display("mmcm_frac_count_calc- divide:%h, phase:%d, duty_cycle:%d",
				divide, phase, duty_cycle);
	`endif
   
   //convert phase to fixed
   if ((phase < -360000) || (phase > 360000)) begin
`ifndef SYNTHESIS
      $display("ERROR: phase of $phase is not between -360000 and 360000");
	`endif
      $finish;
   end


      // Return value is
      //    Transfer data
      //       RESERVED     [37:36]
      //       FRAC_TIME    [35:33]
      //       FRAC_WF_FALL [32]
      //    Upper address is:
      //       RESERVED     [31:26]
      //       MX           [25:24]
      //       EDGE         [23]
      //       NOCOUNT      [22]
      //       DELAY_TIME   [21:16]
      //    Lower Address is:
      //       PHASE_MUX    [15:13]
      //       RESERVED     [12]
      //       HIGH_TIME    [11:6]
      //       LOW_TIME     [5:0]
      
      

	clkout0_divide_frac = frac / 125;
	clkout0_divide_int = divide;

	even_part_high = clkout0_divide_int >> 1;//$rtoi(clkout0_divide_int / 2);
	even_part_low = even_part_high;
									
	odd = clkout0_divide_int - even_part_high - even_part_low;
	odd_and_frac = (8*odd) + clkout0_divide_frac;

	lt_frac = even_part_high - (odd_and_frac <= 9);//IF(odd_and_frac>9,even_part_high, even_part_high - 1)
	ht_frac = even_part_low  - (odd_and_frac <= 8);//IF(odd_and_frac>8,even_part_low, even_part_low- 1)

	pm_fall =  {odd[6:0],2'b00} + {6'h00, clkout0_divide_frac[2:1]}; // using >> instead of clkout0_divide_frac / 2 
	pm_rise = 0; //0
    
	wf_fall_frac = ((odd_and_frac >=2) && (odd_and_frac <=9)) || ((clkout0_divide_frac == 1) && (clkout0_divide_int == 2));//CRS610807
	wf_rise_frac = (odd_and_frac >=1) && (odd_and_frac <=8);//IF(odd_and_frac>=1,IF(odd_and_frac <= 8,1,0),0)



	//Calculate phase in fractional cycles
	a_per_in_octets		= (8 * divide) + (frac / 125) ;
	a_phase_in_cycles	= (phase+10) * a_per_in_octets / 360000 ;//Adding 1 due to rounding errors
	pm_rise_frac		= (a_phase_in_cycles[7:0] ==8'h00)?8'h00:a_phase_in_cycles[7:0] - {a_phase_in_cycles[7:3],3'b000};

	dt_calc 	= ((phase+10) * a_per_in_octets / 8 )/360000 ;//TRUNC(phase* divide / 360); //or_simply (a_per_in_octets / 8)
	dt 	= dt_calc[7:0];

	pm_rise_frac_filtered = (pm_rise_frac >=8) ? (pm_rise_frac ) - 8: pm_rise_frac ;				//((phase_fixed * (divide + frac / 1000)) / 360) - {pm_rise_frac[7:3],3'b000};//$rtoi(clkout0_phase * clkout0_divide / 45);//a;

	dt_int			= dt + (& pm_rise_frac[7:4]); //IF(pm_rise_overwriting>7,dt+1,dt)
	pm_fall_frac		= pm_fall + pm_rise_frac;
	pm_fall_frac_filtered	= pm_fall + pm_rise_frac - {pm_fall_frac[7:3], 3'b000};

	div_calc	= mmcm_pll_divider(divide, duty_cycle); //Use to determine edge[7], no count[6]
	phase_calc	= mmcm_pll_phase(divide, phase);// returns{mx[1:0], phase_mux[2:0], delay_time[5:0]}
		
      mmcm_frac_count_calc[37:0] =
         {		2'b00, pm_fall_frac_filtered[2:0], wf_fall_frac,
			1'b0, clkout0_divide_frac[2:0], 1'b1, wf_rise_frac, phase_calc[10:9], div_calc[13:12], dt[5:0], 
			pm_rise_frac_filtered[2], pm_rise_frac_filtered[1], pm_rise_frac_filtered[0], 1'b0, ht_frac[5:0], lt_frac[5:0]
		} ;

   `ifdef DEBUG
      $display("-%d.%d p%d>>  :DADDR_9_15 frac30to28.frac_en.wf_r_frac.dt:%b%d%d_%b:DADDR_7_13 pm_f_frac_filtered_29to27.wf_f_frac_26:%b%d:DADDR_8_14.pm_r_frac_filt_15to13.ht_frac.lt_frac:%b%b%b:", divide, frac, phase, clkout0_divide_frac, 1, wf_rise_frac, dt, pm_fall_frac_filtered, wf_fall_frac, pm_rise_frac_filtered, ht_frac, lt_frac);
   `endif

   end
endfunction

