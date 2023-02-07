open_project fpga.xpr
open_run impl_1
set_property IDELAY_VALUE 0 [get_cells {phy_rx_ctl_idelay phy_rxd_idelay_*}]
set_property CLKOUT1_PHASE 90 [get_cells clk_mmcm_inst]
write_bitstream -force fpga.bit
exit
