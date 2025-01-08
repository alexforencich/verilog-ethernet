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

`define GC_XSDB_MSI_SL_SEL_WIDTH        8   /* Slave Select Width */
`define GC_XSDB_MSI_ADDR_WIDTH          17  /* Address Width */
`define GC_XSDB_MSI_BRST_WD_LEN_WIDTH   17
`define GC_XSDB_MSI_DATA_WIDTH          16  /* Data Width */
`define GC_XSDB_MSI_BRST_CNT_WIDTH      16  /* Burst Count Width */
`define GC_XSDB_S_IPORT_WIDTH           37  /* Slave Port input interface width */

`define GC_XSDB_S_OPORT_WIDTH           17  /* Slave Port output interface width */

`define GC_XSDB_S_ADDR_WIDTH            `GC_XSDB_MSI_ADDR_WIDTH  /* Slave Addr width */
`define GC_XSDB_S_DATA_WIDTH            `GC_XSDB_MSI_DATA_WIDTH  /* Slave Data width */

`define GC_IPORT_RST_IDX                0
`define GC_IPORT_DCLK_IDX               1
`define GC_IPORT_DEN_IDX                2
`define GC_IPORT_DWE_IDX                3
`define GC_IPORT_DADDR_IDX              4
`define GC_IPORT_DI_IDX                 `GC_IPORT_DADDR_IDX+`GC_XSDB_S_ADDR_WIDTH
`define GC_OPORT_RDY_IDX                0
`define GC_OPORT_DO_IDX                 1      

`define GC_ICN_CTL_WIDTH                36
`define GC_ICN_CMD4_WIDTH               3 + `GC_XSDB_MSI_SL_SEL_WIDTH+ `GC_XSDB_MSI_BRST_WD_LEN_WIDTH
`define GC_ICN_CMD5_WIDTH               1 + `GC_XSDB_MSI_ADDR_WIDTH
`define GC_ICN_CMD6_WIDTH               `GC_XSDB_MSI_DATA_WIDTH

