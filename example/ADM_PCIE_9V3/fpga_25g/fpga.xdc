# XDC constraints for the ADM-PCIE-9V3
# part: xcvu3p-ffvc1517-2-i

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN {Pullnone}     [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

# 300 MHz system clock
set_property -dict {LOC AP26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports clk_300mhz_p]
set_property -dict {LOC AP27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports clk_300mhz_n]
create_clock -period 3.333 -name clk_300mhz [get_ports clk_300mhz_p]

# LEDs
set_property -dict {LOC AT27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {user_led_g[0]}]
set_property -dict {LOC AU27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {user_led_g[1]}]
set_property -dict {LOC AU23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {user_led_r}]
set_property -dict {LOC AH24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {front_led[0]}]
set_property -dict {LOC AJ23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {front_led[1]}]

set_false_path -to [get_ports {user_led_g[*] user_led_r front_led[*]}]
set_output_delay 0 [get_ports {user_led_g[*] user_led_r front_led[*]}]

# Switches
set_property -dict {LOC AV27 IOSTANDARD LVCMOS18} [get_ports {user_sw[0]}]
set_property -dict {LOC AW27 IOSTANDARD LVCMOS18} [get_ports {user_sw[1]}]

set_false_path -from [get_ports {user_sw[*]}]
set_input_delay 0 [get_ports {user_sw[*]}]

# GPIO
#set_property -dict {LOC G30  IOSTANDARD LVCMOS18} [get_ports gpio_p[0]]
#set_property -dict {LOC F30  IOSTANDARD LVCMOS18} [get_ports gpio_n[0]]
#set_property -dict {LOC J31  IOSTANDARD LVCMOS18} [get_ports gpio_p[1]]
#set_property -dict {LOC H31  IOSTANDARD LVCMOS18} [get_ports gpio_n[1]]

# QSFP28 Interfaces
set_property -dict {LOC G38  } [get_ports {qsfp_0_rx_p[0]}] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC G39  } [get_ports {qsfp_0_rx_n[0]}] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC F35  } [get_ports {qsfp_0_tx_p[0]}] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC F36  } [get_ports {qsfp_0_tx_n[0]}] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC E38  } [get_ports {qsfp_0_rx_p[1]}] ;# MGTYRXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC E39  } [get_ports {qsfp_0_rx_n[1]}] ;# MGTYRXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC D35  } [get_ports {qsfp_0_tx_p[1]}] ;# MGTYTXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC D36  } [get_ports {qsfp_0_tx_n[1]}] ;# MGTYTXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C38  } [get_ports {qsfp_0_rx_p[2]}] ;# MGTYRXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C39  } [get_ports {qsfp_0_rx_n[2]}] ;# MGTYRXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C33  } [get_ports {qsfp_0_tx_p[2]}] ;# MGTYTXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C34  } [get_ports {qsfp_0_tx_n[2]}] ;# MGTYTXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC B36  } [get_ports {qsfp_0_rx_p[3]}] ;# MGTYRXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC B37  } [get_ports {qsfp_0_rx_n[3]}] ;# MGTYRXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC A33  } [get_ports {qsfp_0_tx_p[3]}] ;# MGTYTXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC A34  } [get_ports {qsfp_0_tx_n[3]}] ;# MGTYTXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC N33  } [get_ports qsfp_0_mgt_refclk_p] ;# MGTREFCLK0P_128 from ?
set_property -dict {LOC N34  } [get_ports qsfp_0_mgt_refclk_n] ;# MGTREFCLK0N_128 from ?
set_property -dict {LOC F29  IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_0_modprs_l]
set_property -dict {LOC D31  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports qsfp_0_sel_l]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_0_mgt_refclk [get_ports qsfp_0_mgt_refclk_p]

set_property -dict {LOC R38  } [get_ports {qsfp_1_rx_p[0]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC R39  } [get_ports {qsfp_1_rx_n[0]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC P35  } [get_ports {qsfp_1_tx_p[0]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC P36  } [get_ports {qsfp_1_tx_n[0]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC N38  } [get_ports {qsfp_1_rx_p[1]}] ;# MGTYRXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC N39  } [get_ports {qsfp_1_rx_n[1]}] ;# MGTYRXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC M35  } [get_ports {qsfp_1_tx_p[1]}] ;# MGTYTXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC M36  } [get_ports {qsfp_1_tx_n[1]}] ;# MGTYTXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC L38  } [get_ports {qsfp_1_rx_p[2]}] ;# MGTYRXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC L39  } [get_ports {qsfp_1_rx_n[2]}] ;# MGTYRXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC K35  } [get_ports {qsfp_1_tx_p[2]}] ;# MGTYTXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC K36  } [get_ports {qsfp_1_tx_n[2]}] ;# MGTYTXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC J38  } [get_ports {qsfp_1_rx_p[3]}] ;# MGTYRXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC J39  } [get_ports {qsfp_1_rx_n[3]}] ;# MGTYRXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC H35  } [get_ports {qsfp_1_tx_p[3]}] ;# MGTYTXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC H36  } [get_ports {qsfp_1_tx_n[3]}] ;# MGTYTXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U33  } [get_ports qsfp_1_mgt_refclk_p] ;# MGTREFCLK0P_127 from ?
set_property -dict {LOC U34  } [get_ports qsfp_1_mgt_refclk_n] ;# MGTREFCLK0N_127 from ?
set_property -dict {LOC F33  IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_1_modprs_l]
set_property -dict {LOC D30  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports qsfp_1_sel_l]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_1_mgt_refclk [get_ports qsfp_1_mgt_refclk_p]

set_property -dict {LOC B29  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports qsfp_reset_l]
set_property -dict {LOC C29  IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_int_l]
#set_property -dict {LOC A28  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports qsfp_i2c_scl]
#set_property -dict {LOC A29  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports qsfp_i2c_sda]

set_false_path -to [get_ports {qsfp_0_sel_l qsfp_1_sel_l qsfp_reset_l}]
set_output_delay 0 [get_ports {qsfp_0_sel_l qsfp_1_sel_l qsfp_reset_l}]
set_false_path -from [get_ports {qsfp_0_modprs_l qsfp_1_modprs_l qsfp_int_l}]
set_input_delay 0 [get_ports {qsfp_0_modprs_l qsfp_1_modprs_l qsfp_int_l}]

#set_false_path -to [get_ports {qsfp_i2c_sda qsfp_i2c_scl}]
#set_output_delay 0 [get_ports {qsfp_i2c_sda qsfp_i2c_scl}]
#set_false_path -from [get_ports {qsfp_i2c_sda qsfp_i2c_scl}]
#set_input_delay 0 [get_ports {qsfp_i2c_sda qsfp_i2c_scl}]

# I2C interface
#set_property -dict {LOC AT25 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_scl]
#set_property -dict {LOC AT26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_sda]
#set_property -dict {LOC AP23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_wp]

#set_false_path -to [get_ports {eeprom_i2c_sda eeprom_i2c_scl eeprom_wp}]
#set_output_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl eeprom_wp}]
#set_false_path -from [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
#set_input_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]

# PCIe Interface
#set_property -dict {LOC J2   } [get_ports {pcie_rx_p[0]}]  ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC J1   } [get_ports {pcie_rx_n[0]}]  ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC H5   } [get_ports {pcie_tx_p[0]}]  ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC H4   } [get_ports {pcie_tx_n[0]}]  ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC L2   } [get_ports {pcie_rx_p[1]}]  ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC L1   } [get_ports {pcie_rx_n[1]}]  ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC K5   } [get_ports {pcie_tx_p[1]}]  ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC K4   } [get_ports {pcie_tx_n[1]}]  ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC N2   } [get_ports {pcie_rx_p[2]}]  ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC N1   } [get_ports {pcie_rx_n[2]}]  ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC M5   } [get_ports {pcie_tx_p[2]}]  ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC M4   } [get_ports {pcie_tx_n[2]}]  ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC R2   } [get_ports {pcie_rx_p[3]}]  ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC R1   } [get_ports {pcie_rx_n[3]}]  ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC P5   } [get_ports {pcie_tx_p[3]}]  ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC P4   } [get_ports {pcie_tx_n[3]}]  ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC U2   } [get_ports {pcie_rx_p[4]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC U1   } [get_ports {pcie_rx_n[4]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC T5   } [get_ports {pcie_tx_p[4]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC T4   } [get_ports {pcie_tx_n[4]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC W2   } [get_ports {pcie_rx_p[5]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC W1   } [get_ports {pcie_rx_n[5]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC V5   } [get_ports {pcie_tx_p[5]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC V4   } [get_ports {pcie_tx_n[5]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AA2  } [get_ports {pcie_rx_p[6]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AA1  } [get_ports {pcie_rx_n[6]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AB5  } [get_ports {pcie_tx_p[6]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AB4  } [get_ports {pcie_tx_n[6]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AC2  } [get_ports {pcie_rx_p[7]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AC1  } [get_ports {pcie_rx_n[7]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AD5  } [get_ports {pcie_tx_p[7]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AD4  } [get_ports {pcie_tx_n[7]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AE2  } [get_ports {pcie_rx_p[8]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AE1  } [get_ports {pcie_rx_n[8]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AF5  } [get_ports {pcie_tx_p[8]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AF4  } [get_ports {pcie_tx_n[8]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AG2  } [get_ports {pcie_rx_p[9]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AG1  } [get_ports {pcie_rx_n[9]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AH5  } [get_ports {pcie_tx_p[9]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AH4  } [get_ports {pcie_tx_n[9]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AJ2  } [get_ports {pcie_rx_p[10]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AJ1  } [get_ports {pcie_rx_n[10]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AK5  } [get_ports {pcie_tx_p[10]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AK4  } [get_ports {pcie_tx_n[10]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AL2  } [get_ports {pcie_rx_p[11]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AL1  } [get_ports {pcie_rx_n[11]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AM5  } [get_ports {pcie_tx_p[11]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AM4  } [get_ports {pcie_tx_n[11]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AN2  } [get_ports {pcie_rx_p[12]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AN1  } [get_ports {pcie_rx_n[12]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AP5  } [get_ports {pcie_tx_p[12]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AP4  } [get_ports {pcie_tx_n[12]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AR2  } [get_ports {pcie_rx_p[13]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AR1  } [get_ports {pcie_rx_n[13]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AT5  } [get_ports {pcie_tx_p[13]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AT4  } [get_ports {pcie_tx_n[13]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AU2  } [get_ports {pcie_rx_p[14]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AU1  } [get_ports {pcie_rx_n[14]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AU7  } [get_ports {pcie_tx_p[14]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AU6  } [get_ports {pcie_tx_n[14]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AV4  } [get_ports {pcie_rx_p[15]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AV3  } [get_ports {pcie_rx_n[15]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AW7  } [get_ports {pcie_tx_p[15]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AW6  } [get_ports {pcie_tx_n[15]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AA7  } [get_ports pcie_refclk_1_p] ;# MGTREFCLK0P_226
#set_property -dict {LOC AA6  } [get_ports pcie_refclk_1_n] ;# MGTREFCLK0N_226
#set_property -dict {LOC AJ7  } [get_ports pcie_refclk_2_p] ;# MGTREFCLK0P_224
#set_property -dict {LOC AJ6  } [get_ports pcie_refclk_2_n] ;# MGTREFCLK0N_224
#set_property -dict {LOC AJ31 IOSTANDARD LVCMOS18 PULLUP true} [get_ports perst_0]
#set_property -dict {LOC AH29 IOSTANDARD LVCMOS18 PULLUP true} [get_ports perst_1]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_1_p]
#create_clock -period 10 -name pcie_mgt_refclk_2 [get_ports pcie_refclk_2_p]

#set_false_path -from [get_ports {perst_0}]
#set_input_delay 0 [get_ports {perst_0}]

# DDR4 C0
# 5x K4A8G085WB-RC
#set_property -dict {LOC F9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[0]}]
#set_property -dict {LOC G9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[1]}]
#set_property -dict {LOC G11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[2]}]
#set_property -dict {LOC D11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[3]}]
#set_property -dict {LOC E12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[4]}]
#set_property -dict {LOC G10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[5]}]
#set_property -dict {LOC F10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[6]}]
#set_property -dict {LOC J9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[7]}]
#set_property -dict {LOC J8   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[8]}]
#set_property -dict {LOC F12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[9]}]
#set_property -dict {LOC D9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[10]}]
#set_property -dict {LOC H11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[11]}]
#set_property -dict {LOC E8   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[12]}]
#set_property -dict {LOC J11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[13]}]
#set_property -dict {LOC C9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[14]}]
#set_property -dict {LOC B11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[15]}]
#set_property -dict {LOC K12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[16]}]
#set_property -dict {LOC H9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[17]}]
#set_property -dict {LOC F8   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[0]}]
#set_property -dict {LOC H8   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[1]}]
#set_property -dict {LOC D10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[0]}]
#set_property -dict {LOC E11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[1]}]
#set_property -dict {LOC B10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_c[0]}]
#set_property -dict {LOC C11  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_c[1]}]
#set_property -dict {LOC A9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_c[2]}]
#set_property -dict {LOC H12  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_t}]
#set_property -dict {LOC G12  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_c}]
#set_property -dict {LOC B9   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cke}]
#set_property -dict {LOC E10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n}]
#set_property -dict {LOC C12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_act_n}]
#set_property -dict {LOC A10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_odt}]
#set_property -dict {LOC G7   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_par}]
#set_property -dict {LOC F7   IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_reset_n}]
#set_property -dict {LOC H7   IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_alert_n}]
#set_property -dict {LOC J10  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_ten}]

#set_property -dict {LOC L10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[0]}]
#set_property -dict {LOC L9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[1]}]
#set_property -dict {LOC N9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[2]}]
#set_property -dict {LOC M9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[3]}]
#set_property -dict {LOC M10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[4]}]
#set_property -dict {LOC K11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[5]}]
#set_property -dict {LOC M11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[6]}]
#set_property -dict {LOC K10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[7]}]
#set_property -dict {LOC L17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[8]}]
#set_property -dict {LOC M16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[9]}]
#set_property -dict {LOC M15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[10]}]
#set_property -dict {LOC M17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[11]}]
#set_property -dict {LOC M14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[12]}]
#set_property -dict {LOC N18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[13]}]
#set_property -dict {LOC N16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[14]}]
#set_property -dict {LOC N17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[15]}]
#set_property -dict {LOC F15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[16]}]
#set_property -dict {LOC E16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[17]}]
#set_property -dict {LOC F14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[18]}]
#set_property -dict {LOC E17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[19]}]
#set_property -dict {LOC G16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[20]}]
#set_property -dict {LOC F17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[21]}]
#set_property -dict {LOC E15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[22]}]
#set_property -dict {LOC G17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[23]}]
#set_property -dict {LOC A17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[24]}]
#set_property -dict {LOC C16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[25]}]
#set_property -dict {LOC B16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[26]}]
#set_property -dict {LOC A14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[27]}]
#set_property -dict {LOC B17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[28]}]
#set_property -dict {LOC B14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[29]}]
#set_property -dict {LOC D16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[30]}]
#set_property -dict {LOC D15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[31]}]
#set_property -dict {LOC F18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[32]}]
#set_property -dict {LOC F20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[33]}]
#set_property -dict {LOC F19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[34]}]
#set_property -dict {LOC D21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[35]}]
#set_property -dict {LOC E18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[36]}]
#set_property -dict {LOC G19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[37]}]
#set_property -dict {LOC E21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[38]}]
#set_property -dict {LOC G20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[39]}]
#set_property -dict {LOC D18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[40]}]
#set_property -dict {LOC B22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[41]}]
#set_property -dict {LOC A19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[42]}]
#set_property -dict {LOC A18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[43]}]
#set_property -dict {LOC C19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[44]}]
#set_property -dict {LOC B19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[45]}]
#set_property -dict {LOC A22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[46]}]
#set_property -dict {LOC C18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[47]}]
#set_property -dict {LOC G22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[48]}]
#set_property -dict {LOC J20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[49]}]
#set_property -dict {LOC H19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[50]}]
#set_property -dict {LOC J19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[51]}]
#set_property -dict {LOC H18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[52]}]
#set_property -dict {LOC J18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[53]}]
#set_property -dict {LOC G21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[54]}]
#set_property -dict {LOC K18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[55]}]
#set_property -dict {LOC L20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[56]}]
#set_property -dict {LOC L18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[57]}]
#set_property -dict {LOC N19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[58]}]
#set_property -dict {LOC M21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[59]}]
#set_property -dict {LOC M19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[60]}]
#set_property -dict {LOC M22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[61]}]
#set_property -dict {LOC L19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[62]}]
#set_property -dict {LOC M20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[63]}]
#set_property -dict {LOC H16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[64]}]
#set_property -dict {LOC K15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[65]}]
#set_property -dict {LOC J16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[66]}]
#set_property -dict {LOC J14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[67]}]
#set_property -dict {LOC K13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[68]}]
#set_property -dict {LOC L13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[69]}]
#set_property -dict {LOC H14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[70]}]
#set_property -dict {LOC J15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[71]}]
#set_property -dict {LOC M12  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[0]}]
#set_property -dict {LOC L12  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[0]}]
#set_property -dict {LOC L15  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[1]}]
#set_property -dict {LOC L14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[1]}]
#set_property -dict {LOC F13  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[2]}]
#set_property -dict {LOC E13  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[2]}]
#set_property -dict {LOC B15  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[3]}]
#set_property -dict {LOC A15  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[3]}]
#set_property -dict {LOC F22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[4]}]
#set_property -dict {LOC E22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[4]}]
#set_property -dict {LOC C21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[5]}]
#set_property -dict {LOC B21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[5]}]
#set_property -dict {LOC K21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[6]}]
#set_property -dict {LOC K20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[6]}]
#set_property -dict {LOC L22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[7]}]
#set_property -dict {LOC K22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[7]}]
#set_property -dict {LOC K17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[8]}]
#set_property -dict {LOC K16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[8]}]
#set_property -dict {LOC N12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[0]}]
#set_property -dict {LOC P14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[1]}]
#set_property -dict {LOC G15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[2]}]
#set_property -dict {LOC D14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[3]}]
#set_property -dict {LOC E20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[4]}]
#set_property -dict {LOC B20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[5]}]
#set_property -dict {LOC H22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[6]}]
#set_property -dict {LOC N22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[7]}]
#set_property -dict {LOC J13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[8]}]

# DDR4 C1
# 5x K4A8G085WB-RC
#set_property -dict {LOC AN9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC AM9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC AP11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC AU9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC AT10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC AL12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC AM12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC AM10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC AL11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC AP7  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC AR8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC AL10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC AP8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC AK11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC AP9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC AV10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC AT11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC AL8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[17]}]
#set_property -dict {LOC AN11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC AR9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC AP12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC AN10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[1]}]
#set_property -dict {LOC AW13 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_c[0]}]
#set_property -dict {LOC AU10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_c[1]}]
#set_property -dict {LOC AW11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_c[2]}]
#set_property -dict {LOC AM7  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t}]
#set_property -dict {LOC AN7  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c}]
#set_property -dict {LOC AU12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke}]
#set_property -dict {LOC AT12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n}]
#set_property -dict {LOC AV9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC AR11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt}]
#set_property -dict {LOC AM8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC AN12 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_reset_n}]
#set_property -dict {LOC AR10 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_alert_n}]
#set_property -dict {LOC AV11 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_ten}]

#set_property -dict {LOC AK9  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[0]}]
#set_property -dict {LOC AK10 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[1]}]
#set_property -dict {LOC AH10 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[2]}]
#set_property -dict {LOC AJ11 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[3]}]
#set_property -dict {LOC AJ9  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[4]}]
#set_property -dict {LOC AH12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[5]}]
#set_property -dict {LOC AG10 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[6]}]
#set_property -dict {LOC AJ12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[7]}]
#set_property -dict {LOC AM15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[8]}]
#set_property -dict {LOC AN14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[9]}]
#set_property -dict {LOC AL13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[10]}]
#set_property -dict {LOC AM14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[11]}]
#set_property -dict {LOC AL15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[12]}]
#set_property -dict {LOC AM17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[13]}]
#set_property -dict {LOC AL17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[14]}]
#set_property -dict {LOC AM13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[15]}]
#set_property -dict {LOC AR15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[16]}]
#set_property -dict {LOC AP14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[17]}]
#set_property -dict {LOC AT15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[18]}]
#set_property -dict {LOC AR14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[19]}]
#set_property -dict {LOC AP17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[20]}]
#set_property -dict {LOC AN16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[21]}]
#set_property -dict {LOC AN17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[22]}]
#set_property -dict {LOC AN15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[23]}]
#set_property -dict {LOC AU15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[24]}]
#set_property -dict {LOC AT17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[25]}]
#set_property -dict {LOC AV15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[26]}]
#set_property -dict {LOC AT16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[27]}]
#set_property -dict {LOC AV14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[28]}]
#set_property -dict {LOC AW17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[29]}]
#set_property -dict {LOC AW14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[30]}]
#set_property -dict {LOC AW18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[31]}]
#set_property -dict {LOC AP19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[32]}]
#set_property -dict {LOC AT20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[33]}]
#set_property -dict {LOC AN21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[34]}]
#set_property -dict {LOC AR19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[35]}]
#set_property -dict {LOC AN20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[36]}]
#set_property -dict {LOC AR18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[37]}]
#set_property -dict {LOC AR20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[38]}]
#set_property -dict {LOC AP18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[39]}]
#set_property -dict {LOC AW19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[40]}]
#set_property -dict {LOC AU22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[41]}]
#set_property -dict {LOC AV19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[42]}]
#set_property -dict {LOC AW22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[43]}]
#set_property -dict {LOC AU18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[44]}]
#set_property -dict {LOC AT22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[45]}]
#set_property -dict {LOC AW21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[46]}]
#set_property -dict {LOC AU19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[47]}]
#set_property -dict {LOC AH19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[48]}]
#set_property -dict {LOC AJ22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[49]}]
#set_property -dict {LOC AF21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[50]}]
#set_property -dict {LOC AH22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[51]}]
#set_property -dict {LOC AF20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[52]}]
#set_property -dict {LOC AJ19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[53]}]
#set_property -dict {LOC AH21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[54]}]
#set_property -dict {LOC AJ21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[55]}]
#set_property -dict {LOC AM19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[56]}]
#set_property -dict {LOC AK20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[57]}]
#set_property -dict {LOC AM22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[58]}]
#set_property -dict {LOC AL22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[59]}]
#set_property -dict {LOC AM20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[60]}]
#set_property -dict {LOC AK19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[61]}]
#set_property -dict {LOC AN19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[62]}]
#set_property -dict {LOC AL20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[63]}]
#set_property -dict {LOC AF15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[64]}]
#set_property -dict {LOC AJ17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[65]}]
#set_property -dict {LOC AH17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[66]}]
#set_property -dict {LOC AJ14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[67]}]
#set_property -dict {LOC AG15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[68]}]
#set_property -dict {LOC AJ13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[69]}]
#set_property -dict {LOC AG17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[70]}]
#set_property -dict {LOC AJ16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[71]}]
#set_property -dict {LOC AG9  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[0]}]
#set_property -dict {LOC AH9  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[0]}]
#set_property -dict {LOC AK16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[1]}]
#set_property -dict {LOC AL16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[1]}]
#set_property -dict {LOC AR13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[2]}]
#set_property -dict {LOC AT13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[2]}]
#set_property -dict {LOC AU17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[3]}]
#set_property -dict {LOC AV17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[3]}]
#set_property -dict {LOC AN22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[4]}]
#set_property -dict {LOC AP22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[4]}]
#set_property -dict {LOC AV22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[5]}]
#set_property -dict {LOC AV21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[5]}]
#set_property -dict {LOC AG20 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[6]}]
#set_property -dict {LOC AH20 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[6]}]
#set_property -dict {LOC AK21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[7]}]
#set_property -dict {LOC AL21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[7]}]
#set_property -dict {LOC AH16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[8]}]
#set_property -dict {LOC AH15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[8]}]
#set_property -dict {LOC AG12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[0]}]
#set_property -dict {LOC AK15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[1]}]
#set_property -dict {LOC AP16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[2]}]
#set_property -dict {LOC AV16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[3]}]
#set_property -dict {LOC AP21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[4]}]
#set_property -dict {LOC AU20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[5]}]
#set_property -dict {LOC AG19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[6]}]
#set_property -dict {LOC AL18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[7]}]
#set_property -dict {LOC AG14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[8]}]

# QSPI flash
#set_property -dict {LOC AF30 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[0]}]
#set_property -dict {LOC AG30 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[1]}]
#set_property -dict {LOC AF28 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[2]}]
#set_property -dict {LOC AG28 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[3]}]
#set_property -dict {LOC AV30 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_cs}]

#set_false_path -to [get_ports {qspi_1_dq[*] qspi_1_cs}]
#set_output_delay 0 [get_ports {qspi_1_dq[*] qspi_1_cs}]
#set_false_path -from [get_ports {qspi_1_dq}]
#set_input_delay 0 [get_ports {qspi_1_dq}]
