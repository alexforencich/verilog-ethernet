# XDC constraints for the Xilinx Kintex UltraScale+ KCU116
# part: xcku5p-ffvb676-2-e

# General configuration
set_property CFGBVS GND                                      [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true                 [current_design]

# 300MHz sysclk
set_property -dict {LOC K22 IOSTANDARD DIFF_SSTL12 } [get_ports clk_300mhz_p];
set_property -dict {LOC K23 IOSTANDARD DIFF_SSTL12 } [get_ports clk_300mhz_n];

# LEDs
set_property -dict {LOC C9  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[0]}]
set_property -dict {LOC D9  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[1]}]
set_property -dict {LOC E10 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[2]}]
set_property -dict {LOC E11 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[3]}]
set_property -dict {LOC F9  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[4]}]
set_property -dict {LOC F10 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[5]}]
set_property -dict {LOC G9  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[6]}]
set_property -dict {LOC G10 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {user_led[7]}]

set_false_path -to [get_ports {user_led[*]}]
set_output_delay 0 [get_ports {user_led[*]}]

# SFP Interfaces
set_property -dict {LOC M2  } [get_ports sfp_0_rx_p];
set_property -dict {LOC M1  } [get_ports sfp_0_rx_n];
set_property -dict {LOC N5  } [get_ports sfp_0_tx_p];
set_property -dict {LOC N4  } [get_ports sfp_0_tx_n];
set_property -dict {LOC AB14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_0_tx_disable_n]

set_property -dict {LOC K2  } [get_ports sfp_1_rx_p];
set_property -dict {LOC K1  } [get_ports sfp_1_rx_n];
set_property -dict {LOC L5  } [get_ports sfp_1_tx_p];
set_property -dict {LOC L4  } [get_ports sfp_1_tx_n];
set_property -dict {LOC AA14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable_n]

set_property -dict {LOC H2  } [get_ports sfp_2_rx_p];
set_property -dict {LOC H1  } [get_ports sfp_2_rx_n];
set_property -dict {LOC J5  } [get_ports sfp_2_tx_p];
set_property -dict {LOC J4  } [get_ports sfp_2_tx_n];
set_property -dict {LOC AA15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_2_tx_disable_n]

set_property -dict {LOC F2  } [get_ports sfp_3_rx_p];
set_property -dict {LOC F1  } [get_ports sfp_3_rx_n];
set_property -dict {LOC G5  } [get_ports sfp_3_tx_p];
set_property -dict {LOC G4  } [get_ports sfp_3_tx_n];
set_property -dict {LOC Y15  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports sfp_3_tx_disable_n]

set_property -dict {LOC P7  } [get_ports sfp_mgt_refclk_p]; # Bank 226 - MGTREFCLK0P_226
set_property -dict {LOC P6  } [get_ports sfp_mgt_refclk_n]; # Bank 226 - MGTREFCLK0N_226

# 156.25 MHz MGT reference clock
create_clock -period 6.4 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]

set_false_path -to [get_ports { \
  sfp_3_tx_disable_n \
  sfp_2_tx_disable_n \
  sfp_1_tx_disable_n \
  sfp_0_tx_disable_n \
}]
set_output_delay 0 [get_ports { \
  sfp_3_tx_disable_n \
  sfp_2_tx_disable_n \
  sfp_1_tx_disable_n \
  sfp_0_tx_disable_n \
}]
