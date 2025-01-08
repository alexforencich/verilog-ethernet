/*******************************************************************************
 * Copyright (c) 2011 Xilinx, Inc.
 * This design is confidential and proprietary of Xilinx, All Rights Reserved.
 *******************************************************************************
 *   ____  ____
 *  /   /\/   /
 * /___/  \  /   Vendor: Xilinx
 * \   \   \/    Date Created: 2011/10/14
 *  \   \       
 *  /   /       
 * /___/   /\    
 * \   \  /  \ 
 *  \___\/\___\
 * 
 *Device: All
 *Purpose:
 *  Verilog functions required by ila_lib 
 * 
 *******************************************************************************/

 function integer size_of_data;
  input integer num_match_units;
  input [`GC_TRIG_WIDTH_VEC_ARRAY_W-1:0] match_width_string;
  input [`GC_TRIG_TYPEID_VEC_ARRAY_W-1:0] match_tpid_string;
  integer i;
  begin
    size_of_data = match_width_string[0+:16]+1;
    for (i=1; i<num_match_units; i=i+1)
    begin
      if (match_tpid_string[(16*(i))+:16] > match_tpid_string[(16*(i-1))+:16])
        size_of_data = size_of_data + match_width_string[(match_tpid_string[(i*`GC_TRIG_TYPEID_VEC_W)+:16]*16)+:16]+1;
    end
  end
  
endfunction

 function integer match_units_count;
  input integer num_probes;
  input [`GC_MU_CNT_VEC_ARRAY_W-1:0] match_cnt_string;
  integer i;
  begin
    match_units_count = match_cnt_string[0+:4]+1;
    for (i=1; i<num_probes; i=i+1)
    begin
      match_units_count = match_units_count + match_cnt_string[(4*i)+:4]+1;
    end
  end
endfunction

 function [255:0] match_tpid;
  // Cast as bit16. Replace with null_value if not qualified.
      input [15:0] arg_ddr;
      input [15:0] arg;
      input        qual;
      input [15:0] val;
      integer i;
      integer j;
      integer arg_temp;
    begin
      arg_temp = qual ? arg_ddr : arg;

      for (i=0; i<arg_temp; i=i+1)
      begin
        match_tpid[i*16+:16] = val[15:0];
      end
      for (j=arg_temp; j<16; j=j+1)
      begin
        match_tpid[j*16+:16] = 16'h0000;
      end
    end
  endfunction

 function integer match_units_count_en;
  input integer num_mu;
  input [1023:0] is_string;
  integer i;
  begin
    //match_units_count = match_cnt_string[0+:2]+1;
    match_units_count_en = 0;
    for (i=0; i<num_mu; i=i+1)
    begin
      if (is_string[i] == 1'b1) begin
        match_units_count_en = match_units_count_en + 1;
      end  
    end
  end 
endfunction

 function integer size_of_data_less;
  input integer num_match_units;
  input [`GC_TRIG_WIDTH_VEC_ARRAY_W-1:0] match_width_string;
  input [`GC_TRIG_TYPEID_VEC_ARRAY_W-1:0] match_tpid_string;
  input [1023:0] is_string;
  integer i;
  begin
    if (is_string[0] == 1'b1) begin
      size_of_data_less = match_width_string[0+:16]+1;
    end else begin
      size_of_data_less = 0 ;
    end
    for (i=1; i<num_match_units; i=i+1)
    begin
      if (is_string[i] == 1'b1) begin
        size_of_data_less = size_of_data_less + match_width_string[i*16+:16]+1;
      end  
    end
  end
endfunction

 function integer size_of_data_full;
  input integer num_match_units;
  input [`GC_TRIG_WIDTH_VEC_ARRAY_W-1:0] match_width_string;
  input [`GC_TRIG_TYPEID_VEC_ARRAY_W-1:0] match_tpid_string;
  input [1023:0] is_string;
  integer i;
  begin
      size_of_data_full = match_width_string[0+:16]+1;
    for (i=1; i<num_match_units; i=i+1)
    begin
        size_of_data_full = size_of_data_full + match_width_string[i*16+:16]+1;
    end
  end
endfunction

