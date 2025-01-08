/*----------------------------------------------------------------------------
 * Copyright (c) 2011 Xilinx, Inc.
 * This design is confidential and proprietary of Xilinx, All Rights Reserved.
 *-----------------------------------------------------------------------------
 *   ____  ____
 *  /   /\/   /
 * /___/  \  /   Vendor: Xilinx
 * \   \   \/    Date Created: 2011/04/26
 *  \   \        
 *  /   /        
 * /___/   /\    
 * \   \  /  \ 
 *  \___\/\___\
 * 
 *Device: All
 *Purpose:
 *  General functions used by other Labtools IP cores. Functions will
 *  be added as needed.
 *
 *Notes:
 *  Include the file inside the Verilog module after the module and port
 *  section. Do not include at the top of the module.  
 *
 *----------------------------------------------------------------------------*/

`include "ltlib_v1_0_0_ver.vh"

  function integer clogb2;
    input integer depth;
    integer d;
    begin 
      if (depth == 0)
        clogb2 = 1;
      else
      begin
        d = depth;
        for (clogb2=0; d > 0; clogb2 = clogb2+1)
          d = d >> 1;
      end
    end 
  endfunction  

  function string_contains;
    input [`FAMILY_NAME_LENGTH*8-1:0] familyName;
    input [`FAMILY_NAME_LENGTH*8-1:0] expectedName;
    input integer expectedLength;
    integer i;
    integer j;
    reg temp_contain;
    begin
      string_contains = 1;
      temp_contain = 0;
      for (i=0; i<`FAMILY_NAME_LENGTH; i=i+1)
      begin
        if (familyName[(8*i)+:8] == expectedName[0+:8])
        begin
          temp_contain = 1;
          for (j=0; j<expectedLength; j=j+1)
          begin
            if (familyName[((8*i)+(8*j))+:8] != expectedName[(8*j)+:8])
            begin
              temp_contain = 0;
            end
          end
        end    
      end
      if (temp_contain == 1)
      begin
        string_contains = 1;
        i = `FAMILY_NAME_LENGTH;
      end
    end
  endfunction
  
  function integer supports_bscane2;
    input [`FAMILY_NAME_LENGTH-1:0] familyName;
    begin
      if (string_contains(familyName,`FAMILY_VIRTEX7,`FAMILY_VIRTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_KINTEX7,`FAMILY_KINTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ARTIX7,`FAMILY_ARTIX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ZYNQ,`FAMILY_ZYNQ_LENGTH) == 1)
        supports_bscane2 = 1;
      else
        supports_bscane2 = 0;
    end
  endfunction
  
  function integer supports_series7_bufr;
    input [`FAMILY_NAME_LENGTH-1:0] familyName;
    begin
      if (string_contains(familyName,`FAMILY_VIRTEX7,`FAMILY_VIRTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_KINTEX7,`FAMILY_KINTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ARTIX7,`FAMILY_ARTIX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ZYNQ,`FAMILY_ZYNQ_LENGTH) == 1)
        supports_series7_bufr = 1;
      else
        supports_series7_bufr = 0;
    end
  endfunction
  
  function integer supports_series7_startup;
    input [`FAMILY_NAME_LENGTH-1:0] familyName;
    begin
      if (string_contains(familyName,`FAMILY_VIRTEX7,`FAMILY_VIRTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_KINTEX7,`FAMILY_KINTEX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ARTIX7,`FAMILY_ARTIX7_LENGTH) == 1 || string_contains(familyName,`FAMILY_ZYNQ,`FAMILY_ZYNQ_LENGTH) == 1)
        supports_series7_startup = 1;
      else
        supports_series7_startup = 0;
    end
  endfunction

