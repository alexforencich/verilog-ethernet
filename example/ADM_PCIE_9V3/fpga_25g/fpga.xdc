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
set_property -dict {LOC G38  } [get_ports qsfp_0_rx_0_p] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC G39  } [get_ports qsfp_0_rx_0_n] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC F35  } [get_ports qsfp_0_tx_0_p] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC F36  } [get_ports qsfp_0_tx_0_n] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC E38  } [get_ports qsfp_0_rx_1_p] ;# MGTYRXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC E39  } [get_ports qsfp_0_rx_1_n] ;# MGTYRXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC D35  } [get_ports qsfp_0_tx_1_p] ;# MGTYTXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC D36  } [get_ports qsfp_0_tx_1_n] ;# MGTYTXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C38  } [get_ports qsfp_0_rx_2_p] ;# MGTYRXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C39  } [get_ports qsfp_0_rx_2_n] ;# MGTYRXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C33  } [get_ports qsfp_0_tx_2_p] ;# MGTYTXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC C34  } [get_ports qsfp_0_tx_2_n] ;# MGTYTXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC B36  } [get_ports qsfp_0_rx_3_p] ;# MGTYRXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC B37  } [get_ports qsfp_0_rx_3_n] ;# MGTYRXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC A33  } [get_ports qsfp_0_tx_3_p] ;# MGTYTXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC A34  } [get_ports qsfp_0_tx_3_n] ;# MGTYTXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC N33  } [get_ports qsfp_0_mgt_refclk_p] ;# MGTREFCLK0P_128 from ?
set_property -dict {LOC N34  } [get_ports qsfp_0_mgt_refclk_n] ;# MGTREFCLK0N_128 from ?
set_property -dict {LOC F29  IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_0_modprs_l]
set_property -dict {LOC D31  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports qsfp_0_sel_l]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_0_mgt_refclk [get_ports qsfp_0_mgt_refclk_p]

set_property -dict {LOC R38  } [get_ports qsfp_1_rx_0_p] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC R39  } [get_ports qsfp_1_rx_0_n] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC P35  } [get_ports qsfp_1_tx_0_p] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC P36  } [get_ports qsfp_1_tx_0_n] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC N38  } [get_ports qsfp_1_rx_1_p] ;# MGTYRXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC N39  } [get_ports qsfp_1_rx_1_n] ;# MGTYRXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC M35  } [get_ports qsfp_1_tx_1_p] ;# MGTYTXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC M36  } [get_ports qsfp_1_tx_1_n] ;# MGTYTXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC L38  } [get_ports qsfp_1_rx_2_p] ;# MGTYRXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC L39  } [get_ports qsfp_1_rx_2_n] ;# MGTYRXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC K35  } [get_ports qsfp_1_tx_2_p] ;# MGTYTXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC K36  } [get_ports qsfp_1_tx_2_n] ;# MGTYTXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC J38  } [get_ports qsfp_1_rx_3_p] ;# MGTYRXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC J39  } [get_ports qsfp_1_rx_3_n] ;# MGTYRXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC H35  } [get_ports qsfp_1_tx_3_p] ;# MGTYTXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC H36  } [get_ports qsfp_1_tx_3_n] ;# MGTYTXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
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
