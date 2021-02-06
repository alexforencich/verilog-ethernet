# XDC constraints for the NetFPGA SUME
# part: xc7vx690tffg1761-3

# General configuration
set_property CFGBVS GND                           [current_design]
set_property CONFIG_VOLTAGE 1.8                   [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup    [current_design]

# 200 MHz system clock
set_property -dict {LOC H19  IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC G18  IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5 -name clk_200mhz [get_ports clk_200mhz_p]

# 200 MHz QDRII A/B MIG clock
# set_property -dict {LOC AD32 IOSTANDARD LVDS} [get_ports clk_qdrii_200mhz_p]
# set_property -dict {LOC AD33 IOSTANDARD LVDS} [get_ports clk_qdrii_200mhz_n]
# create_clock -period 5 -name clk_qdrii_200mhz [get_ports clk_qdrii_200mhz_p]

# 200 MHz QDRII C MIG clock
# set_property -dict {LOC AU14 IOSTANDARD LVDS} [get_ports clk_qdriic_200mhz_p]
# set_property -dict {LOC AU13 IOSTANDARD LVDS} [get_ports clk_qdriic_200mhz_n]
# create_clock -period 5 -name clk_qdriic_200mhz [get_ports clk_qdriic_200mhz_p]

# 233.33 MHz DDR3 MIG clock
# set_property -dict {LOC E34  IOSTANDARD LVDS} [get_ports clk_ddr_233mhz_p]
# set_property -dict {LOC E35  IOSTANDARD LVDS} [get_ports clk_ddr_233mhz_n]
# create_clock -period 4.286 -name clk_ddr_233mhz [get_ports clk_ddr_233mhz_p]

# LEDs
set_property -dict {LOC G13  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led[0]}]
set_property -dict {LOC L15  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led[1]}]
set_property -dict {LOC AL22 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led[0]}]
set_property -dict {LOC BA20 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led[1]}]
set_property -dict {LOC AY18 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_3_led[0]}]
set_property -dict {LOC AY17 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_3_led[1]}]
set_property -dict {LOC P31  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_4_led[0]}]
set_property -dict {LOC K32  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_4_led[1]}]
set_property -dict {LOC AR22 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC AR23 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[1]}]

set_false_path -to [get_ports {sfp_1_led[*] sfp_2_led[*] sfp_3_led[*] sfp_4_led[*] led[*]}]
set_output_delay 0 [get_ports {sfp_1_led[*] sfp_2_led[*] sfp_3_led[*] sfp_4_led[*] led[*]}]

# Push buttons
set_property -dict {LOC AR13 IOSTANDARD LVCMOS15} [get_ports {btn[0]}]
set_property -dict {LOC BB12 IOSTANDARD LVCMOS15} [get_ports {btn[1]}]

set_false_path -from [get_ports {btn[*]}]
set_input_delay 0 [get_ports {btn[*]}]

# SFP+ Interfaces
set_property -dict {LOC A6   } [get_ports sfp_1_rx_p] ;# MGTHRXP3_119 GTHE2_CHANNEL_X1Y39 / GTHE2_COMMON_X1Y9
set_property -dict {LOC A5   } [get_ports sfp_1_rx_n] ;# MGTHRXN3_119 GTHE2_CHANNEL_X1Y39 / GTHE2_COMMON_X1Y9
set_property -dict {LOC B4   } [get_ports sfp_1_tx_p] ;# MGTHTXP3_119 GTHE2_CHANNEL_X1Y39 / GTHE2_COMMON_X1Y9
set_property -dict {LOC B3   } [get_ports sfp_1_tx_n] ;# MGTHTXN3_119 GTHE2_CHANNEL_X1Y39 / GTHE2_COMMON_X1Y9
set_property -dict {LOC B8   } [get_ports sfp_2_rx_p] ;# MGTHRXP2_119 GTHE2_CHANNEL_X1Y38 / GTHE2_COMMON_X1Y9
set_property -dict {LOC B7   } [get_ports sfp_2_rx_n] ;# MGTHRXN2_119 GTHE2_CHANNEL_X1Y38 / GTHE2_COMMON_X1Y9
set_property -dict {LOC C2   } [get_ports sfp_2_tx_p] ;# MGTHTXP2_119 GTHE2_CHANNEL_X1Y38 / GTHE2_COMMON_X1Y9
set_property -dict {LOC C1   } [get_ports sfp_2_tx_n] ;# MGTHTXN2_119 GTHE2_CHANNEL_X1Y38 / GTHE2_COMMON_X1Y9
set_property -dict {LOC C6   } [get_ports sfp_3_rx_p] ;# MGTHRXP1_119 GTHE2_CHANNEL_X1Y37 / GTHE2_COMMON_X1Y9
set_property -dict {LOC C5   } [get_ports sfp_3_rx_n] ;# MGTHRXN1_119 GTHE2_CHANNEL_X1Y37 / GTHE2_COMMON_X1Y9
set_property -dict {LOC D4   } [get_ports sfp_3_tx_p] ;# MGTHTXP1_119 GTHE2_CHANNEL_X1Y37 / GTHE2_COMMON_X1Y9
set_property -dict {LOC D3   } [get_ports sfp_3_tx_n] ;# MGTHTXN1_119 GTHE2_CHANNEL_X1Y37 / GTHE2_COMMON_X1Y9
set_property -dict {LOC D8   } [get_ports sfp_4_rx_p] ;# MGTHRXP0_119 GTHE2_CHANNEL_X1Y36 / GTHE2_COMMON_X1Y9
set_property -dict {LOC D7   } [get_ports sfp_4_rx_n] ;# MGTHRXN0_119 GTHE2_CHANNEL_X1Y36 / GTHE2_COMMON_X1Y9
set_property -dict {LOC E2   } [get_ports sfp_4_tx_p] ;# MGTHTXP0_119 GTHE2_CHANNEL_X1Y36 / GTHE2_COMMON_X1Y9
set_property -dict {LOC E1   } [get_ports sfp_4_tx_n] ;# MGTHTXN0_119 GTHE2_CHANNEL_X1Y36 / GTHE2_COMMON_X1Y9
set_property -dict {LOC E10  } [get_ports sfp_mgt_refclk_p] ;# MGTREFCLK0P_118 from IC20.28
set_property -dict {LOC E9   } [get_ports sfp_mgt_refclk_n] ;# MGTREFCLK0N_118 from IC20.29
#set_property -dict {LOC AW32 IOSTANDARD LVDS} [get_ports sfp_recclk_p] ;# to IC20.16
#set_property -dict {LOC AW33 IOSTANDARD LVDS} [get_ports sfp_recclk_n] ;# to IC20.17
set_property -dict {LOC BA29 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_clk_rst]
#set_property -dict {LOC AM29 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_clk_alarm_b]
set_property -dict {LOC N18  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_1_mod_detect]
set_property -dict {LOC L19  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_2_mod_detect]
set_property -dict {LOC J37  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_3_mod_detect]
set_property -dict {LOC H36  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_4_mod_detect]
set_property -dict {LOC N19  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_1_rs[0]}]
set_property -dict {LOC P18  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_1_rs[1]}]
set_property -dict {LOC P20  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_2_rs[0]}]
set_property -dict {LOC N20  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_2_rs[1]}]
set_property -dict {LOC F39  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_3_rs[0]}]
set_property -dict {LOC G36  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_3_rs[1]}]
set_property -dict {LOC H38  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_4_rs[0]}]
set_property -dict {LOC G38  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {sfp_4_rs[1]}]
set_property -dict {LOC L17  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_1_los]
set_property -dict {LOC L20  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_2_los]
set_property -dict {LOC G37  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_3_los]
set_property -dict {LOC J36  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_4_los]
set_property -dict {LOC M18  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]
set_property -dict {LOC B31  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports sfp_2_tx_disable]
set_property -dict {LOC J38  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports sfp_3_tx_disable]
set_property -dict {LOC L21  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports sfp_4_tx_disable]
set_property -dict {LOC M19  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_1_tx_fault]
set_property -dict {LOC C26  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_2_tx_fault]
set_property -dict {LOC E39  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_3_tx_fault]
set_property -dict {LOC J26  IOSTANDARD LVCMOS15 PULLUP true} [get_ports sfp_4_tx_fault]

# 156.25 MHz MGT reference clock
#create_clock -period 6.4 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]

set_false_path -to [get_ports {sfp_clk_rst}]
set_output_delay 0 [get_ports {sfp_clk_rst}]
#set_false_path -from [get_ports {sfp_clk_alarm_b}]
#set_input_delay 0 [get_ports {sfp_clk_alarm_b}]
set_false_path -from [get_ports {sfp_1_mod_detect sfp_2_mod_detect sfp_3_mod_detect sfp_4_mod_detect}]
set_input_delay 0 [get_ports {sfp_1_mod_detect sfp_2_mod_detect sfp_3_mod_detect sfp_4_mod_detect}]
set_false_path -to [get_ports {sfp_1_rs[*] sfp_2_rs[*] sfp_3_rs[*] sfp_4_rs[*]}]
set_output_delay 0 [get_ports {sfp_1_rs[*] sfp_2_rs[*] sfp_3_rs[*] sfp_4_rs[*]}]
set_false_path -from [get_ports {get_ports sfp_1_los sfp_2_los sfp_3_los sfp_4_los}]
set_input_delay 0 [get_ports {get_ports sfp_1_los sfp_2_los sfp_3_los sfp_4_los}]
set_false_path -to [get_ports {get_ports sfp_1_tx_disable sfp_2_tx_disable sfp_3_tx_disable sfp_4_tx_disable}]
set_output_delay 0 [get_ports {get_ports sfp_1_tx_disable sfp_2_tx_disable sfp_3_tx_disable sfp_4_tx_disable}]
set_false_path -from [get_ports {get_ports sfp_1_tx_fault sfp_2_tx_fault sfp_3_tx_fault get_ports sfp_4_tx_fault}]
set_input_delay 0 [get_ports {get_ports sfp_1_tx_fault sfp_2_tx_fault sfp_3_tx_fault get_ports sfp_4_tx_fault}]

# I2C interface
set_property -dict {LOC AK24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports i2c_scl]
set_property -dict {LOC AK25 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports i2c_sda]
set_property -dict {LOC AM39 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports i2c_mux_reset]

set_false_path -to [get_ports {i2c_sda i2c_scl i2c_mux_reset}]
set_output_delay 0 [get_ports {i2c_sda i2c_scl i2c_mux_reset}]
set_false_path -from [get_ports {i2c_sda i2c_scl}]
set_input_delay 0 [get_ports {i2c_sda i2c_scl}]

# PCIe Interface
#set_property -dict {LOC Y4   } [get_ports {pcie_rx_p[0]}] ;# MGTHTXP3_115 GTHE2_CHANNEL_X1Y23 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC Y3   } [get_ports {pcie_rx_n[0]}] ;# MGTHTXN3_115 GTHE2_CHANNEL_X1Y23 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC W2   } [get_ports {pcie_tx_p[0]}] ;# MGTHTXP3_115 GTHE2_CHANNEL_X1Y23 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC W1   } [get_ports {pcie_tx_n[0]}] ;# MGTHTXN3_115 GTHE2_CHANNEL_X1Y23 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AA6  } [get_ports {pcie_rx_p[1]}] ;# MGTHTXP2_115 GTHE2_CHANNEL_X1Y22 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AA5  } [get_ports {pcie_rx_n[1]}] ;# MGTHTXN2_115 GTHE2_CHANNEL_X1Y22 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AA2  } [get_ports {pcie_tx_p[1]}] ;# MGTHTXP2_115 GTHE2_CHANNEL_X1Y22 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AA1  } [get_ports {pcie_tx_n[1]}] ;# MGTHTXN2_115 GTHE2_CHANNEL_X1Y22 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AB4  } [get_ports {pcie_rx_p[2]}] ;# MGTHTXP1_115 GTHE2_CHANNEL_X1Y21 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AB3  } [get_ports {pcie_rx_n[2]}] ;# MGTHTXN1_115 GTHE2_CHANNEL_X1Y21 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AC2  } [get_ports {pcie_tx_p[2]}] ;# MGTHTXP1_115 GTHE2_CHANNEL_X1Y21 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AC1  } [get_ports {pcie_tx_n[2]}] ;# MGTHTXN1_115 GTHE2_CHANNEL_X1Y21 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AC6  } [get_ports {pcie_rx_p[3]}] ;# MGTHTXP0_115 GTHE2_CHANNEL_X1Y20 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AC5  } [get_ports {pcie_rx_n[3]}] ;# MGTHTXN0_115 GTHE2_CHANNEL_X1Y20 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AE2  } [get_ports {pcie_tx_p[3]}] ;# MGTHTXP0_115 GTHE2_CHANNEL_X1Y20 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AE1  } [get_ports {pcie_tx_n[3]}] ;# MGTHTXN0_115 GTHE2_CHANNEL_X1Y20 / GTHE2_COMMON_X1Y5
#set_property -dict {LOC AD4  } [get_ports {pcie_rx_p[4]}] ;# MGTHTXP3_114 GTHE2_CHANNEL_X1Y19 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AD3  } [get_ports {pcie_rx_n[4]}] ;# MGTHTXN3_114 GTHE2_CHANNEL_X1Y19 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AG2  } [get_ports {pcie_tx_p[4]}] ;# MGTHTXP3_114 GTHE2_CHANNEL_X1Y19 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AG1  } [get_ports {pcie_tx_n[4]}] ;# MGTHTXN3_114 GTHE2_CHANNEL_X1Y19 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AE6  } [get_ports {pcie_rx_p[5]}] ;# MGTHTXP2_114 GTHE2_CHANNEL_X1Y18 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AE5  } [get_ports {pcie_rx_n[5]}] ;# MGTHTXN2_114 GTHE2_CHANNEL_X1Y18 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AH4  } [get_ports {pcie_tx_p[5]}] ;# MGTHTXP2_114 GTHE2_CHANNEL_X1Y18 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AH3  } [get_ports {pcie_tx_n[5]}] ;# MGTHTXN2_114 GTHE2_CHANNEL_X1Y18 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AF4  } [get_ports {pcie_rx_p[6]}] ;# MGTHTXP1_114 GTHE2_CHANNEL_X1Y17 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AF3  } [get_ports {pcie_rx_n[6]}] ;# MGTHTXN1_114 GTHE2_CHANNEL_X1Y17 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AJ2  } [get_ports {pcie_tx_p[6]}] ;# MGTHTXP1_114 GTHE2_CHANNEL_X1Y17 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AJ1  } [get_ports {pcie_tx_n[6]}] ;# MGTHTXN1_114 GTHE2_CHANNEL_X1Y17 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AG6  } [get_ports {pcie_rx_p[7]}] ;# MGTHTXP0_114 GTHE2_CHANNEL_X1Y16 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AG5  } [get_ports {pcie_rx_n[7]}] ;# MGTHTXN0_114 GTHE2_CHANNEL_X1Y16 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AK4  } [get_ports {pcie_tx_p[7]}] ;# MGTHTXP0_114 GTHE2_CHANNEL_X1Y16 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AK3  } [get_ports {pcie_tx_n[7]}] ;# MGTHTXN0_114 GTHE2_CHANNEL_X1Y16 / GTHE2_COMMON_X1Y4
#set_property -dict {LOC AB8  } [get_ports pcie_mgt_refclk_p] ;# MGTREFCLK1P_115
#set_property -dict {LOC AB7  } [get_ports pcie_mgt_refclk_n] ;# MGTREFCLK1N_115
#set_property -dict {LOC AY35 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_mgt_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

