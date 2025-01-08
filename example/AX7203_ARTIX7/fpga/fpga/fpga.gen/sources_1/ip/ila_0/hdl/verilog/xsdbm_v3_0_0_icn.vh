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
 *  Define Values for Verilog instatiation of icn2xsdb_mstrbr_ver
 *
 *----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
 *-- C O N S T A N T S
 *-----------------------------------------------------------------------------*/
 
 `define TARGET_HIGH_INDEX                  15   
 `define TARGET_CORE_ID_HIGH_INDEX          15
 `define TARGET_CORE_ID_LOW_INDEX           12
 `define TARGET_COMMAND_HIGH_INDEX          11
 `define TARGET_COMMAND_LOW_INDEX           8
 `define TARGET_COMMAND_GROUP_HIGH_INDEX    7
 `define TARGET_COMMAND_GROUP_LOW_INDEX     6
 `define TARGET_LOW_INDEX                   6
 
 `define TARGET_CORE_ID_WIDTH               `TARGET_CORE_ID_HIGH_INDEX - `TARGET_CORE_ID_LOW_INDEX + 1
 `define TARGET_COMMAND_WIDTH               `TARGET_COMMAND_HIGH_INDEX - `TARGET_COMMAND_LOW_INDEX + 1
 
 `define ICON_READ_STAT_CMD                 0
 

