# XDC constraints for the Xilinx VC709
# part: xc7vx690tffg1761-2

# General configuration
set_property CFGBVS GND                              [current_design]
set_property CONFIG_VOLTAGE 1.8                      [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1    [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true         [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown     [current_design]
set_property CONFIG_MODE BPI16                       [current_design]

# 200 MHz system clock
set_property -dict {LOC H19  IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC G18  IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs 0-7
set_property -dict {LOC AM39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[0]}]
set_property -dict {LOC AN39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[1]}]
set_property -dict {LOC AR37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[2]}]
set_property -dict {LOC AT37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[3]}]
set_property -dict {LOC AR35 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[4]}]
set_property -dict {LOC AP41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[5]}]
set_property -dict {LOC AP42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[6]}]
set_property -dict {LOC AU39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {led[7]}]

# Push buttons
set_property -dict {LOC AU38 IOSTANDARD LVCMOS18} [get_ports {btn[0]}]
set_property -dict {LOC AW40 IOSTANDARD LVCMOS18} [get_ports {btn[1]}]

# SFP+ Interfaces
set_property -dict {LOC AM8  } [get_ports sfp_1_rx_p]
set_property -dict {LOC AN2  } [get_ports sfp_1_tx_p]
set_property -dict {LOC AN6  } [get_ports sfp_2_rx_p]
set_property -dict {LOC AP4  } [get_ports sfp_2_tx_p]
set_property -dict {LOC AL6  } [get_ports sfp_3_rx_p]
set_property -dict {LOC AM4  } [get_ports sfp_3_tx_p]
set_property -dict {LOC AJ6  } [get_ports sfp_4_rx_p]
set_property -dict {LOC AL2  } [get_ports sfp_4_tx_p]
set_property -dict {LOC AH8  } [get_ports sfp_mgt_refclk_p]
set_property -dict {LOC AH7  } [get_ports sfp_mgt_refclk_n]
set_property -dict {LOC AT36 IOSTANDARD LVCMOS18} [get_ports sfp_clk_rst_n]
set_property -dict {LOC AA42 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_mod_detect]
set_property -dict {LOC AB42 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_mod_detect]
set_property -dict {LOC AC39 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_3_mod_detect]
set_property -dict {LOC AC41 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_4_mod_detect]
set_property -dict {LOC W40  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_rs[0]}]
set_property -dict {LOC Y40  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_rs[1]}]
set_property -dict {LOC AB38 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_rs[0]}]
set_property -dict {LOC AB39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_rs[1]}]
set_property -dict {LOC AD42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_3_rs[0]}]
set_property -dict {LOC AE42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_3_rs[1]}]
set_property -dict {LOC AE39  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_4_rs[0]}]
set_property -dict {LOC AE40  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_4_rs[1]}]
set_property -dict {LOC AA40 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_los]
set_property -dict {LOC Y39  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_los]
set_property -dict {LOC AD38 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_3_los]
set_property -dict {LOC AD40 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_4_los]
set_property -dict {LOC Y42  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]
set_property -dict {LOC AB41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_2_tx_disable]
set_property -dict {LOC AC38 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_3_tx_disable]
set_property -dict {LOC AC40 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_4_tx_disable]
set_property -dict {LOC AA39 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_tx_fault]
set_property -dict {LOC Y38  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_tx_fault]
set_property -dict {LOC AA41 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_3_tx_fault]
set_property -dict {LOC AE38 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_4_tx_fault]

# I2C interface
set_property -dict {LOC AT35 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports i2c_scl]
set_property -dict {LOC AU32 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports i2c_sda]
set_property -dict {LOC AY42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports i2c_mux_reset_n]
