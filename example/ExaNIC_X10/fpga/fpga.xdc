# XDC constraints for the ExaNIC X10
# part: xcku035-fbva676-2-e

# General configuration
set_property CFGBVS GND                           [current_design]
set_property CONFIG_VOLTAGE 1.8                   [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup    [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50       [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type2 [current_design]
set_property CONFIG_MODE BPI16                    [current_design]

# 100 MHz system clock
set_property -dict {LOC D18  IOSTANDARD LVDS} [get_ports clk_100mhz_p]
set_property -dict {LOC C18  IOSTANDARD LVDS} [get_ports clk_100mhz_n]
create_clock -period 10 -name clk_100mhz [get_ports clk_100mhz_p]

# LEDs
set_property -dict {LOC A25 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led[0]}]
set_property -dict {LOC A24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led[1]}]
set_property -dict {LOC E23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led[0]}]
set_property -dict {LOC D26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led[1]}]
set_property -dict {LOC C23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sma_led[0]}]
set_property -dict {LOC D23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sma_led[1]}]

set_false_path -to [get_ports {sfp_1_led[*] sfp_2_led[*] sma_led[*]}]
set_output_delay 0 [get_ports {sfp_1_led[*] sfp_2_led[*] sma_led[*]}]

# GPIO
#set_property -dict {LOC W26  IOSTANDARD LVCMOS18} [get_ports gpio[0]]
#set_property -dict {LOC Y26  IOSTANDARD LVCMOS18} [get_ports gpio[1]]
#set_property -dict {LOC AB26 IOSTANDARD LVCMOS18} [get_ports gpio[2]]
#set_property -dict {LOC AC26 IOSTANDARD LVCMOS18} [get_ports gpio[3]]

# SMA
#set_property -dict {LOC B17  IOSTANDARD LVCMOS18} [get_ports sma_in]
#set_property -dict {LOC B16  IOSTANDARD LVCMOS18 SLEW FAST DRIVE 12} [get_ports sma_out]
#set_property -dict {LOC B19  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sma_out_en]
#set_property -dict {LOC C16  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sma_term_en]

#set_false_path -to [get_ports {sma_out sma_term sma_term_en}]
#set_output_delay 0 [get_ports {sma_out sma_term sma_term_en}]
#set_false_path -from [get_ports {sma_in}]
#set_input_delay 0 [get_ports {sma_in}]

# SFP+ Interfaces
set_property -dict {LOC D2  } [get_ports sfp_1_rx_p] ;# MGTHRXP0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3
set_property -dict {LOC D1  } [get_ports sfp_1_rx_n] ;# MGTHRXN0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3
set_property -dict {LOC E4  } [get_ports sfp_1_tx_p] ;# MGTHTXP0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3
set_property -dict {LOC E3  } [get_ports sfp_1_tx_n] ;# MGTHTXN0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3
set_property -dict {LOC C4  } [get_ports sfp_2_rx_p] ;# MGTHRXP1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3
set_property -dict {LOC C3  } [get_ports sfp_2_rx_n] ;# MGTHRXN1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3
set_property -dict {LOC D6  } [get_ports sfp_2_tx_p] ;# MGTHTXP1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3
set_property -dict {LOC D5  } [get_ports sfp_2_tx_n] ;# MGTHTXN1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3
set_property -dict {LOC H6  } [get_ports sfp_mgt_refclk_p] ;# MGTREFCLK0P_227 from X2
set_property -dict {LOC H5  } [get_ports sfp_mgt_refclk_n] ;# MGTREFCLK0N_227 from X2
set_property -dict {LOC AA12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]
set_property -dict {LOC W14  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_2_tx_disable]
set_property -dict {LOC C24  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_npres]
set_property -dict {LOC D24  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_npres]
set_property -dict {LOC W13  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_los]
set_property -dict {LOC AB12 IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_los]
set_property -dict {LOC B25  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_1_rs]
set_property -dict {LOC D25  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_2_rs]
#set_property -dict {LOC W11  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_i2c_scl]
#set_property -dict {LOC Y11  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_1_i2c_sda]
#set_property -dict {LOC Y13  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_2_i2c_sda]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]

set_false_path -to [get_ports {sfp_1_tx_disable sfp_2_tx_disable sfp_1_rs sfp_2_rs}]
set_output_delay 0 [get_ports {sfp_1_tx_disable sfp_2_tx_disable sfp_1_rs sfp_2_rs}]
set_false_path -from [get_ports {sfp_1_npres sfp_2_npres sfp_1_los sfp_2_los}]
set_input_delay 0 [get_ports {sfp_1_npres sfp_2_npres sfp_1_los sfp_2_los}]

#set_false_path -to [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_i2c_scl}]
#set_output_delay 0 [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_i2c_scl}]
#set_false_path -from [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_i2c_scl}]
#set_input_delay 0 [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_i2c_scl}]

# I2C interface
#set_property -dict {LOC B26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_scl]
#set_property -dict {LOC C26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_sda]

#set_false_path -to [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
#set_output_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
#set_false_path -from [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
#set_input_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]

# PCIe Interface
#set_property -dict {LOC P2  } [get_ports {pcie_rx_p[0]}] ;# MGTHRXP3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC P1  } [get_ports {pcie_rx_n[0]}] ;# MGTHRXN3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC R4  } [get_ports {pcie_tx_p[0]}] ;# MGTHTXP3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC R3  } [get_ports {pcie_tx_n[0]}] ;# MGTHTXN3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC T2  } [get_ports {pcie_rx_p[1]}] ;# MGTHRXP2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC T1  } [get_ports {pcie_rx_n[1]}] ;# MGTHRXN2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC U4  } [get_ports {pcie_tx_p[1]}] ;# MGTHTXP2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC U3  } [get_ports {pcie_tx_n[1]}] ;# MGTHTXN2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC V2  } [get_ports {pcie_rx_p[2]}] ;# MGTHRXP1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC V1  } [get_ports {pcie_rx_n[2]}] ;# MGTHRXN1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC W4  } [get_ports {pcie_tx_p[2]}] ;# MGTHTXP1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC W3  } [get_ports {pcie_tx_n[2]}] ;# MGTHTXN1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC Y2  } [get_ports {pcie_rx_p[3]}] ;# MGTHRXP0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC Y1  } [get_ports {pcie_rx_n[3]}] ;# MGTHRXN0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AA4 } [get_ports {pcie_tx_p[3]}] ;# MGTHTXP0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AA3 } [get_ports {pcie_tx_n[3]}] ;# MGTHTXN0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AB2 } [get_ports {pcie_rx_p[4]}] ;# MGTHRXP3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AB1 } [get_ports {pcie_rx_n[4]}] ;# MGTHRXN3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AB6 } [get_ports {pcie_tx_p[4]}] ;# MGTHTXP3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AB5 } [get_ports {pcie_tx_n[4]}] ;# MGTHTXN3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AD2 } [get_ports {pcie_rx_p[5]}] ;# MGTHRXP2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AD1 } [get_ports {pcie_rx_n[5]}] ;# MGTHRXN2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AC4 } [get_ports {pcie_tx_p[5]}] ;# MGTHTXP2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AC3 } [get_ports {pcie_tx_n[5]}] ;# MGTHTXN2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AE4 } [get_ports {pcie_rx_p[6]}] ;# MGTHRXP1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AE3 } [get_ports {pcie_rx_n[6]}] ;# MGTHRXN1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AD6 } [get_ports {pcie_tx_p[6]}] ;# MGTHTXP1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AD5 } [get_ports {pcie_tx_n[6]}] ;# MGTHTXN1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AF2 } [get_ports {pcie_rx_p[7]}] ;# MGTHRXP0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AF1 } [get_ports {pcie_rx_n[7]}] ;# MGTHRXN0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AF6 } [get_ports {pcie_tx_p[7]}] ;# MGTHTXP0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AF5 } [get_ports {pcie_tx_n[7]}] ;# MGTHTXN0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC T6  } [get_ports pcie_mgt_refclk_p] ;# MGTREFCLK0P_225
#set_property -dict {LOC T5  } [get_ports pcie_mgt_refclk_n] ;# MGTREFCLK0N_225
#set_property -dict {LOC AC22 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_mgt_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# BPI flash
#set_property -dict {LOC AE10 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[0]}]
#set_property -dict {LOC AC8  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[1]}]
#set_property -dict {LOC AD10 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[2]}]
#set_property -dict {LOC AD9  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[3]}]
#set_property -dict {LOC AC11 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[4]}]
#set_property -dict {LOC AF10 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[5]}]
#set_property -dict {LOC AF14 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[6]}]
#set_property -dict {LOC AE12 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[7]}]
#set_property -dict {LOC AD14 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[8]}]
#set_property -dict {LOC AF13 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[9]}]
#set_property -dict {LOC AE13 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[10]}]
#set_property -dict {LOC AD8  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[11]}]
#set_property -dict {LOC AC13 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[12]}]
#set_property -dict {LOC AD13 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[13]}]
#set_property -dict {LOC AA14 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[14]}]
#set_property -dict {LOC AB15 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_dq[15]}]
#set_property -dict {LOC AD11 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[0]}]
#set_property -dict {LOC AE11 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[1]}]
#set_property -dict {LOC AF12 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[2]}]
#set_property -dict {LOC AB11 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[3]}]
#set_property -dict {LOC AB9  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[4]}]
#set_property -dict {LOC AB14 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[5]}]
#set_property -dict {LOC AA10 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[6]}]
#set_property -dict {LOC AA9  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[7]}]
#set_property -dict {LOC W10  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[8]}]
#set_property -dict {LOC AA13 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[9]}]
#set_property -dict {LOC Y15  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[10]}]
#set_property -dict {LOC AC12 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[11]}]
#set_property -dict {LOC V12  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[12]}]
#set_property -dict {LOC V11  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[13]}]
#set_property -dict {LOC Y12  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[14]}]
#set_property -dict {LOC W9   IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[15]}]
#set_property -dict {LOC Y8   IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[16]}]
#set_property -dict {LOC W8   IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[17]}]
#set_property -dict {LOC W15  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[18]}]
#set_property -dict {LOC AA15 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[19]}]
#set_property -dict {LOC AE16 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[20]}]
#set_property -dict {LOC AF15 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[21]}]
#set_property -dict {LOC AE15 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_addr[22]}]
#set_property -dict {LOC AD15 IOSTANDARD LVCMOS18 PULLUP true} [get_ports {flash_region}]
#set_property -dict {LOC AC9  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_ce_n}]
#set_property -dict {LOC AC14 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_oe_n}]
#set_property -dict {LOC AB10 IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_we_n}]
#set_property -dict {LOC Y10  IOSTANDARD LVCMOS18 DRIVE 16} [get_ports {flash_adv_n}]

#set_false_path -to [get_ports {flash_dq[*] flash_addr[*] flash_region flash_ce_n flash_oe_n flash_we_n flash_adv_n}]
#set_output_delay 0 [get_ports {flash_dq[*] flash_addr[*] flash_region flash_ce_n flash_oe_n flash_we_n flash_adv_n}]
#set_false_path -from [get_ports {flash_dq[*]}]
#set_input_delay 0 [get_ports {flash_dq[*]}]
