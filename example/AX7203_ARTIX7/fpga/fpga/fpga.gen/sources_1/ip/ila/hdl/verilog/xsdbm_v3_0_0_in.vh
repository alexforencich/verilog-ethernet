/*----------------------------------------------------------------------------
 * Copyright (c) 2008 Xilinx, Inc.
 * This design is confidential and proprietary of Xilinx, All Rights Reserved.
 *-----------------------------------------------------------------------------
 *   ____  ____
 *  /   /\/   /
 * /___/  \  /   Vendor: Xilinx
 * \   \   \/    Date Created: 2008/08/18
 *  \   \        
 *  /   /        
 * /___/   /\    
 * \   \  /  \ 
 *  \___\/\___\
 * 
 *Device: All
 *Purpose:
 *  Define values for Verilog instatiation of labtools ip
 *
 *----------------------------------------------------------------------------*/
 
/*-----------------------------------------------------------------------------
 *-- C O N S T A N T S
 *-----------------------------------------------------------------------------*/

  //
  //  Core type (non-negative integers from 0 to 255)
  //
`define RESERVED_MFG_ID           0
`define XILINX_MFG_ID             1
`define XILINX_AND_AGILENT_MFG_ID 2
`define GC_XILINX_MFG_ID          `XILINX_MFG_ID

  //
  //  Core type (non-negative integers from 0 to 255)
  //
`define RESERVED_CORE_TYPE       0
`define ICON_CORE_TYPE           1
`define ILA_CORE_TYPE            2
`define IBA_GENERIC_CORE_TYPE    3
`define IBA_OPB_CORE_TYPE        4
`define IBA_PLB_CORE_TYPE        5
`define ILA_ATC_CORE_TYPE        6
`define IBA_OPB_ATC_CORE_TYPE    7
`define IBA_PLB_ATC_CORE_TYPE    8
`define VIO_CORE_TYPE            9
`define ATC2_CORE_TYPE           10
`define ATC3_CORE_TYPE           11
`define GC_RESERVED_CORE_TYPE2   12
`define IBERT_CORE_TYPE          13
`define GC_XSDB_MASTER_V1_0      14
`define GC_ICON_NULL_CORE_TYPE   15

  //
  //  Width of the ChipScope Pro Core CONTROL port
  //
`define CONTROL_WIDTH             36

  // Match unit type
`define MATCH_UNIT_TYPEA_ALLX      0
//`define MATCH_UNIT_TYPE_GANDOR    2
//`define MATCH_UNIT_TYPE_GANDORX   3



  //
  // Device family constants
  //
`define FAMILY_NAME_LENGTH        15 //leave room for radhard/automotive and low power part names
`define FAMILY_VIRTEX6            "virtex6"
`define FAMILY_VIRTEX7            "virtex7"
`define FAMILY_VIRTEX7_LENGTH     7
`define FAMILY_KINTEX7            "kintex7"
`define FAMILY_KINTEX7_LENGTH     7
`define FAMILY_ARTIX7             "artix7"
`define FAMILY_ARTIX7_LENGTH      6
`define FAMILY_ZYNQ               "zynq"
`define FAMILY_ZYNQ_LENGTH        4
`define FAMILY_KINTEXU            "kintexu"
`define FAMILY_KINTEXUPLUS        "kintexuplus"
`define FAMILY_ARTIXUPLUS         "artixuplus"
`define FAMILY_AARTIXUPLUS        "aartixuplus"
`define FAMILY_VIRTEXU            "virtexu"
`define FAMILY_VIRTEXUPLUS        "virtexuplus"
`define FAMILY_VIRTEXUPLUSHBM     "virtexuplusHBM"
`define FAMILY_VIRTEXUPLUS58G     "virtexuplus58g"
`define FAMILY_ZYNQUPLUS          "zynquplus"
`define FAMILY_ZYNQUPLUSRFSOC     "zynquplusRFSOC"

  //
  // Architecture match type constants, start at 100 so that code can't incorrectly mix up family and match unit type
  //
`define ARCH_MATCH_TYPE_A         100

//
// Device JTAG Stuff
//
`define GC_SBT_IR_W               10;
`define GC_SBT_IR_ID_INSTR        10'b1111001001
`define GC_SBT_IR_USER1_INSTR     10'b11_1100_0010
`define GC_CHIP_ID_CHIPSCOPE_SBT  32'b0000_1010_0000_0000_0011_0000_1001_0011  
// 0a00_3093
  
////////////////////////////////////////////////////////////////////////////////
// Virtex7
//
// IR Info
`define GC_V7_IR_W                6
`define GC_V7_IR_ID_INSTR         6'b00_1001
`define GC_V7_IR_USER1_INSTR      6'b00_0010
`define GC_V7_IR_USER2_INSTR      6'b00_0011
`define GC_V7_IR_USER3_INSTR      6'b10_0010
`define GC_V7_IR_USER4_INSTR      6'b10_0011
// Chip IDs
`define GC_CHIP_ID_XC7V285T       32'b0000_0011_1010_0110_0100_0000_1001_0011 
// 0424a093  


