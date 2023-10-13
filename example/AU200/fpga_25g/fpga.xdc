# XDC constraints for Xilinx AU200/AU250/VCU1525
# AU200 part: xcu200-fsgd2104-2-e
# AU250 part: xcu250-figd2104-2-e
# VCU1525 part: xcvu9p-fsgd2104-2L-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE    [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DISABLE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8          [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP         [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

set_operating_conditions -design_power_budget 160

# System clocks
# 300 MHz (DDR 0)
#set_property -dict {LOC AY37 IOSTANDARD LVDS} [get_ports clk_300mhz_0_p]
#set_property -dict {LOC AY38 IOSTANDARD LVDS} [get_ports clk_300mhz_0_n]
#create_clock -period 3.333 -name clk_300mhz_0 [get_ports clk_300mhz_0_p]

# 300 MHz (DDR 1)
#set_property -dict {LOC AW20 IOSTANDARD LVDS} [get_ports clk_300mhz_1_p]
#set_property -dict {LOC AW19 IOSTANDARD LVDS} [get_ports clk_300mhz_1_n]
#create_clock -period 3.333 -name clk_300mhz_1 [get_ports clk_300mhz_1_p]

# 300 MHz (DDR 2)
#set_property -dict {LOC F32  IOSTANDARD LVDS} [get_ports clk_300mhz_2_p]
#set_property -dict {LOC E32  IOSTANDARD LVDS} [get_ports clk_300mhz_2_n]
#create_clock -period 3.333 -name clk_300mhz_2 [get_ports clk_300mhz_2_p]

# 300 MHz (DDR 3)
#set_property -dict {LOC J16  IOSTANDARD LVDS} [get_ports clk_300mhz_3_p]
#set_property -dict {LOC H16  IOSTANDARD LVDS} [get_ports clk_300mhz_3_n]
#create_clock -period 3.333 -name clk_300mhz_3 [get_ports clk_300mhz_3_p]

# SI570 user clock
#set_property -dict {LOC AU19 IOSTANDARD LVDS} [get_ports clk_user_p]
#set_property -dict {LOC AV19 IOSTANDARD LVDS} [get_ports clk_user_n]
#create_clock -period 6.400 -name clk_user [get_ports clk_user_p]

# LEDs
set_property -dict {LOC BC21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC BB21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC BA20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AL20 IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# DIP switches
set_property -dict {LOC AN22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC AM19 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC AL19 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC AP20 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC BF18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC BB20 IOSTANDARD LVCMOS12} [get_ports uart_rxd]

#set_false_path -to [get_ports {uart_txd}]
#set_output_delay 0 [get_ports {uart_txd}]
#set_false_path -from [get_ports {uart_rxd}]
#set_input_delay 0 [get_ports {uart_rxd}]

# BMC
#set_property -dict {LOC AR20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[0]}]
#set_property -dict {LOC AM20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[1]}]
#set_property -dict {LOC AM21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[2]}]
#set_property -dict {LOC AN21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[3]}]
#set_property -dict {LOC BB19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 4} [get_ports {msp_uart_txd}]
#set_property -dict {LOC BA19 IOSTANDARD LVCMOS12} [get_ports {msp_uart_rxd}]

#set_false_path -to [get_ports {msp_uart_txd}]
#set_output_delay 0 [get_ports {msp_uart_txd}]
#set_false_path -from [get_ports {msp_gpio[*] msp_uart_rxd}]
#set_input_delay 0 [get_ports {msp_gpio[*] msp_uart_rxd}]

# QSFP28 Interfaces
set_property -dict {LOC N4  } [get_ports {qsfp0_rx_p[0]}] ;# MGTYRXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N3  } [get_ports {qsfp0_rx_n[0]}] ;# MGTYRXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N9  } [get_ports {qsfp0_tx_p[0]}] ;# MGTYTXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N8  } [get_ports {qsfp0_tx_n[0]}] ;# MGTYTXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M2  } [get_ports {qsfp0_rx_p[1]}] ;# MGTYRXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M1  } [get_ports {qsfp0_rx_n[1]}] ;# MGTYRXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M7  } [get_ports {qsfp0_tx_p[1]}] ;# MGTYTXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M6  } [get_ports {qsfp0_tx_n[1]}] ;# MGTYTXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L4  } [get_ports {qsfp0_rx_p[2]}] ;# MGTYRXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L3  } [get_ports {qsfp0_rx_n[2]}] ;# MGTYRXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L9  } [get_ports {qsfp0_tx_p[2]}] ;# MGTYTXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L8  } [get_ports {qsfp0_tx_n[2]}] ;# MGTYTXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K2  } [get_ports {qsfp0_rx_p[3]}] ;# MGTYRXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K1  } [get_ports {qsfp0_rx_n[3]}] ;# MGTYRXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K7  } [get_ports {qsfp0_tx_p[3]}] ;# MGTYTXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K6  } [get_ports {qsfp0_tx_n[3]}] ;# MGTYTXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M11 } [get_ports qsfp0_mgt_refclk_0_p] ;# MGTREFCLK0P_231 from U14.4 via U43.13
#set_property -dict {LOC M10 } [get_ports qsfp0_mgt_refclk_0_n] ;# MGTREFCLK0N_231 from U14.5 via U43.14
set_property -dict {LOC K11 } [get_ports qsfp0_mgt_refclk_1_p] ;# MGTREFCLK1P_231 from U9.18
set_property -dict {LOC K10 } [get_ports qsfp0_mgt_refclk_1_n] ;# MGTREFCLK1N_231 from U9.17
set_property -dict {LOC BE16 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_modsell]
set_property -dict {LOC BE17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_resetl]
set_property -dict {LOC BE20 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_modprsl]
set_property -dict {LOC BE21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp0_intl]
set_property -dict {LOC BD18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_lpmode]
set_property -dict {LOC AT22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp0_refclk_reset]
set_property -dict {LOC AT20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[0]}]
set_property -dict {LOC AU22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp0_fs[1]}]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_0 [get_ports qsfp0_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI5335, FS = 0b01)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI5335, FS = 0b10)
create_clock -period 6.206 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp0_modsell qsfp0_resetl qsfp0_lpmode qsfp0_refclk_reset qsfp0_fs[*]}]
set_output_delay 0 [get_ports {qsfp0_modsell qsfp0_resetl qsfp0_lpmode qsfp0_refclk_reset qsfp0_fs[*]}]
set_false_path -from [get_ports {qsfp0_modprsl qsfp0_intl}]
set_input_delay 0 [get_ports {qsfp0_modprsl qsfp0_intl}]

set_property -dict {LOC U4  } [get_ports {qsfp1_rx_p[0]}] ;# MGTYRXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U3  } [get_ports {qsfp1_rx_n[0]}] ;# MGTYRXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U9  } [get_ports {qsfp1_tx_p[0]}] ;# MGTYTXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U8  } [get_ports {qsfp1_tx_n[0]}] ;# MGTYTXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T2  } [get_ports {qsfp1_rx_p[1]}] ;# MGTYRXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T1  } [get_ports {qsfp1_rx_n[1]}] ;# MGTYRXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T7  } [get_ports {qsfp1_tx_p[1]}] ;# MGTYTXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T6  } [get_ports {qsfp1_tx_n[1]}] ;# MGTYTXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R4  } [get_ports {qsfp1_rx_p[2]}] ;# MGTYRXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R3  } [get_ports {qsfp1_rx_n[2]}] ;# MGTYRXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R9  } [get_ports {qsfp1_tx_p[2]}] ;# MGTYTXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R8  } [get_ports {qsfp1_tx_n[2]}] ;# MGTYTXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P2  } [get_ports {qsfp1_rx_p[3]}] ;# MGTYRXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P1  } [get_ports {qsfp1_rx_n[3]}] ;# MGTYRXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P7  } [get_ports {qsfp1_tx_p[3]}] ;# MGTYTXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P6  } [get_ports {qsfp1_tx_n[3]}] ;# MGTYTXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T11 } [get_ports qsfp1_mgt_refclk_0_p] ;# MGTREFCLK0P_230 from U14.4 via U43.15
#set_property -dict {LOC T10 } [get_ports qsfp1_mgt_refclk_0_n] ;# MGTREFCLK0N_230 from U14.5 via U43.16
set_property -dict {LOC P11 } [get_ports qsfp1_mgt_refclk_1_p] ;# MGTREFCLK1P_230 from U12.18
set_property -dict {LOC P10 } [get_ports qsfp1_mgt_refclk_1_n] ;# MGTREFCLK1N_230 from U12.17
set_property -dict {LOC AY20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_modsell]
set_property -dict {LOC BC18 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_resetl]
set_property -dict {LOC BC19 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_modprsl]
set_property -dict {LOC AV21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports qsfp1_intl]
set_property -dict {LOC AV22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_lpmode]
set_property -dict {LOC AR21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports qsfp1_refclk_reset]
set_property -dict {LOC AR22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[0]}]
set_property -dict {LOC AU20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {qsfp1_fs[1]}]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_0 [get_ports qsfp1_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI5335, FS = 0b01)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI5335, FS = 0b10)
create_clock -period 6.206 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode qsfp1_refclk_reset qsfp1_fs[*]}]
set_output_delay 0 [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode qsfp1_refclk_reset qsfp1_fs[*]}]
set_false_path -from [get_ports {qsfp1_modprsl qsfp1_intl}]
set_input_delay 0 [get_ports {qsfp1_modprsl qsfp1_intl}]

# I2C interface
#set_property -dict {LOC BF19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_mux_reset]
set_property -dict {LOC BF20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC BF17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

set_false_path -to [get_ports {i2c_sda i2c_scl}]
set_output_delay 0 [get_ports {i2c_sda i2c_scl}]
set_false_path -from [get_ports {i2c_sda i2c_scl}]
set_input_delay 0 [get_ports {i2c_sda i2c_scl}]

# PCIe Interface
#set_property -dict {LOC AF2  } [get_ports {pcie_rx_p[0]}]  ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF1  } [get_ports {pcie_rx_n[0]}]  ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF7  } [get_ports {pcie_tx_p[0]}]  ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF6  } [get_ports {pcie_tx_n[0]}]  ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG4  } [get_ports {pcie_rx_p[1]}]  ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG3  } [get_ports {pcie_rx_n[1]}]  ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG9  } [get_ports {pcie_tx_p[1]}]  ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG8  } [get_ports {pcie_tx_n[1]}]  ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH2  } [get_ports {pcie_rx_p[2]}]  ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH1  } [get_ports {pcie_rx_n[2]}]  ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH7  } [get_ports {pcie_tx_p[2]}]  ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH6  } [get_ports {pcie_tx_n[2]}]  ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ4  } [get_ports {pcie_rx_p[3]}]  ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ3  } [get_ports {pcie_rx_n[3]}]  ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ9  } [get_ports {pcie_tx_p[3]}]  ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ8  } [get_ports {pcie_tx_n[3]}]  ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AK2  } [get_ports {pcie_rx_p[4]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK1  } [get_ports {pcie_rx_n[4]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK7  } [get_ports {pcie_tx_p[4]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK6  } [get_ports {pcie_tx_n[4]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL4  } [get_ports {pcie_rx_p[5]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL3  } [get_ports {pcie_rx_n[5]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL9  } [get_ports {pcie_tx_p[5]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AL8  } [get_ports {pcie_tx_n[5]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM2  } [get_ports {pcie_rx_p[6]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM1  } [get_ports {pcie_rx_n[6]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM7  } [get_ports {pcie_tx_p[6]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM6  } [get_ports {pcie_tx_n[6]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN4  } [get_ports {pcie_rx_p[7]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN3  } [get_ports {pcie_rx_n[7]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN9  } [get_ports {pcie_tx_p[7]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN8  } [get_ports {pcie_tx_n[7]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AP2  } [get_ports {pcie_rx_p[8]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP1  } [get_ports {pcie_rx_n[8]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP7  } [get_ports {pcie_tx_p[8]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP6  } [get_ports {pcie_tx_n[8]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR4  } [get_ports {pcie_rx_p[9]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR3  } [get_ports {pcie_rx_n[9]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR9  } [get_ports {pcie_tx_p[9]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR8  } [get_ports {pcie_tx_n[9]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT2  } [get_ports {pcie_rx_p[10]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT1  } [get_ports {pcie_rx_n[10]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT7  } [get_ports {pcie_tx_p[10]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT6  } [get_ports {pcie_tx_n[10]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU4  } [get_ports {pcie_rx_p[11]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU3  } [get_ports {pcie_rx_n[11]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU9  } [get_ports {pcie_tx_p[11]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU8  } [get_ports {pcie_tx_n[11]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AV2  } [get_ports {pcie_rx_p[12]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV1  } [get_ports {pcie_rx_n[12]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV7  } [get_ports {pcie_tx_p[12]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV6  } [get_ports {pcie_tx_n[12]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW4  } [get_ports {pcie_rx_p[13]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW3  } [get_ports {pcie_rx_n[13]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB5  } [get_ports {pcie_tx_p[13]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB4  } [get_ports {pcie_tx_n[13]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA2  } [get_ports {pcie_rx_p[14]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA1  } [get_ports {pcie_rx_n[14]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD5  } [get_ports {pcie_tx_p[14]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD4  } [get_ports {pcie_tx_n[14]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC2  } [get_ports {pcie_rx_p[15]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC1  } [get_ports {pcie_rx_n[15]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF5  } [get_ports {pcie_tx_p[15]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF4  } [get_ports {pcie_tx_n[15]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM11 } [get_ports pcie_refclk_p] ;# MGTREFCLK0P_226
#set_property -dict {LOC AM10 } [get_ports pcie_refclk_n] ;# MGTREFCLK0N_226
#set_property -dict {LOC BD21 IOSTANDARD LVCMOS12 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# DDR4 C0
#set_property -dict {LOC AT36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[0]}]
#set_property -dict {LOC AV36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[1]}]
#set_property -dict {LOC AV37 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[2]}]
#set_property -dict {LOC AW35 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[3]}]
#set_property -dict {LOC AW36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[4]}]
#set_property -dict {LOC AY36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[5]}]
#set_property -dict {LOC AY35 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[6]}]
#set_property -dict {LOC BA40 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[7]}]
#set_property -dict {LOC BA37 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[8]}]
#set_property -dict {LOC BB37 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[9]}]
#set_property -dict {LOC AR35 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[10]}]
#set_property -dict {LOC BA39 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[11]}]
#set_property -dict {LOC BB40 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[12]}]
#set_property -dict {LOC AN36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[13]}]
#set_property -dict {LOC AP35 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[14]}]
#set_property -dict {LOC AP36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[15]}]
#set_property -dict {LOC AR36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[16]}]
#set_property -dict {LOC AT35 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[0]}]
#set_property -dict {LOC AT34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[1]}]
#set_property -dict {LOC BC37 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[0]}]
#set_property -dict {LOC BC39 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[1]}]
#set_property -dict {LOC AV38 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_t[0]}]
#set_property -dict {LOC AW38 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_c[0]}]
#set_property -dict {LOC AU34 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_t[1]}]
#set_property -dict {LOC AU35 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_c[1]}]
#set_property -dict {LOC BC38 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cke[0]}]
#set_property -dict {LOC BC40 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cke[1]}]
#set_property -dict {LOC AR33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n[0]}]
#set_property -dict {LOC AP33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n[1]}]
#set_property -dict {LOC AN33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n[2]}]
#set_property -dict {LOC AM34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n[3]}]
#set_property -dict {LOC BB39 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_act_n}]
#set_property -dict {LOC AP34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_odt[0]}]
#set_property -dict {LOC AN34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_odt[1]}]
#set_property -dict {LOC AU36 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_par}]
#set_property -dict {LOC AU31 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_reset_n}]

#set_property -dict {LOC AW28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[0]}]
#set_property -dict {LOC AW29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[1]}]
#set_property -dict {LOC BA28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[2]}]
#set_property -dict {LOC BA27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[3]}]
#set_property -dict {LOC BB29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[4]}]
#set_property -dict {LOC BA29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[5]}]
#set_property -dict {LOC BC27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[6]}]
#set_property -dict {LOC BB27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[7]}]
#set_property -dict {LOC BE28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[8]}]
#set_property -dict {LOC BF28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[9]}]
#set_property -dict {LOC BE30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[10]}]
#set_property -dict {LOC BD30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[11]}]
#set_property -dict {LOC BF27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[12]}]
#set_property -dict {LOC BE27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[13]}]
#set_property -dict {LOC BF30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[14]}]
#set_property -dict {LOC BF29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[15]}]
#set_property -dict {LOC BB31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[16]}]
#set_property -dict {LOC BB32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[17]}]
#set_property -dict {LOC AY32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[18]}]
#set_property -dict {LOC AY33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[19]}]
#set_property -dict {LOC BC32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[20]}]
#set_property -dict {LOC BC33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[21]}]
#set_property -dict {LOC BB34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[22]}]
#set_property -dict {LOC BC34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[23]}]
#set_property -dict {LOC AV31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[24]}]
#set_property -dict {LOC AV32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[25]}]
#set_property -dict {LOC AV34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[26]}]
#set_property -dict {LOC AW34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[27]}]
#set_property -dict {LOC AW31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[28]}]
#set_property -dict {LOC AY31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[29]}]
#set_property -dict {LOC BA35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[30]}]
#set_property -dict {LOC BA34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[31]}]
#set_property -dict {LOC AL30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[32]}]
#set_property -dict {LOC AM30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[33]}]
#set_property -dict {LOC AU32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[34]}]
#set_property -dict {LOC AT32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[35]}]
#set_property -dict {LOC AN31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[36]}]
#set_property -dict {LOC AN32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[37]}]
#set_property -dict {LOC AR32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[38]}]
#set_property -dict {LOC AR31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[39]}]
#set_property -dict {LOC AP29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[40]}]
#set_property -dict {LOC AP28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[41]}]
#set_property -dict {LOC AN27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[42]}]
#set_property -dict {LOC AM27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[43]}]
#set_property -dict {LOC AN29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[44]}]
#set_property -dict {LOC AM29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[45]}]
#set_property -dict {LOC AR27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[46]}]
#set_property -dict {LOC AR28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[47]}]
#set_property -dict {LOC AT28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[48]}]
#set_property -dict {LOC AV27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[49]}]
#set_property -dict {LOC AU27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[50]}]
#set_property -dict {LOC AT27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[51]}]
#set_property -dict {LOC AV29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[52]}]
#set_property -dict {LOC AY30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[53]}]
#set_property -dict {LOC AW30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[54]}]
#set_property -dict {LOC AV28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[55]}]
#set_property -dict {LOC BD34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[56]}]
#set_property -dict {LOC BD33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[57]}]
#set_property -dict {LOC BE33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[58]}]
#set_property -dict {LOC BD35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[59]}]
#set_property -dict {LOC BF32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[60]}]
#set_property -dict {LOC BF33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[61]}]
#set_property -dict {LOC BF34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[62]}]
#set_property -dict {LOC BF35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[63]}]
#set_property -dict {LOC BD40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[64]}]
#set_property -dict {LOC BD39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[65]}]
#set_property -dict {LOC BF43 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[66]}]
#set_property -dict {LOC BF42 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[67]}]
#set_property -dict {LOC BF37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[68]}]
#set_property -dict {LOC BE37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[69]}]
#set_property -dict {LOC BE40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[70]}]
#set_property -dict {LOC BF41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[71]}]
#set_property -dict {LOC BA30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[0]}]
#set_property -dict {LOC BB30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[0]}]
#set_property -dict {LOC BB26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[1]}]
#set_property -dict {LOC BC26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[1]}]
#set_property -dict {LOC BD28 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[2]}]
#set_property -dict {LOC BD29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[2]}]
#set_property -dict {LOC BD26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[3]}]
#set_property -dict {LOC BE26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[3]}]
#set_property -dict {LOC BB35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[4]}]
#set_property -dict {LOC BB36 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[4]}]
#set_property -dict {LOC BC31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[5]}]
#set_property -dict {LOC BD31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[5]}]
#set_property -dict {LOC AV33 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[6]}]
#set_property -dict {LOC AW33 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[6]}]
#set_property -dict {LOC BA32 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[7]}]
#set_property -dict {LOC BA33 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[7]}]
#set_property -dict {LOC AM31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[8]}]
#set_property -dict {LOC AM32 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[8]}]
#set_property -dict {LOC AP30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[9]}]
#set_property -dict {LOC AP31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[9]}]
#set_property -dict {LOC AL28 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[10]}]
#set_property -dict {LOC AL29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[10]}]
#set_property -dict {LOC AR30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[11]}]
#set_property -dict {LOC AT30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[11]}]
#set_property -dict {LOC AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[12]}]
#set_property -dict {LOC AU30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[12]}]
#set_property -dict {LOC AY27 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[13]}]
#set_property -dict {LOC AY28 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[13]}]
#set_property -dict {LOC BE35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[14]}]
#set_property -dict {LOC BE36 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[14]}]
#set_property -dict {LOC BE31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[15]}]
#set_property -dict {LOC BE32 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[15]}]
#set_property -dict {LOC BE38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[16]}]
#set_property -dict {LOC BF38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[16]}]
#set_property -dict {LOC BF39 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[17]}]
#set_property -dict {LOC BF40 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[17]}]

# DDR4 C1
#set_property -dict {LOC AN24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC AT24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC AW24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC AN26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC AY22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC AY23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC AV24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC BA22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC AY25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC BA23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC AM26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC BA25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC BB22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC AL24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC AL25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC AM25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC AN23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC AU24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC AP26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC BC22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC AW26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[1]}]
#set_property -dict {LOC AT25 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t[0]}]
#set_property -dict {LOC AU25 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c[0]}]
#set_property -dict {LOC AU26 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t[1]}]
#set_property -dict {LOC AV26 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c[1]}]
#set_property -dict {LOC BB25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke[0]}]
#set_property -dict {LOC BB24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke[1]}]
#set_property -dict {LOC AV23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n[0]}]
#set_property -dict {LOC AP25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n[1]}]
#set_property -dict {LOC AR23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n[2]}]
#set_property -dict {LOC AP23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n[3]}]
#set_property -dict {LOC AW25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC AW23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt[0]}]
#set_property -dict {LOC AP24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt[1]}]
#set_property -dict {LOC AT23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC AR17 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_reset_n}]

#set_property -dict {LOC BD9  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[0]}]
#set_property -dict {LOC BD7  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[1]}]
#set_property -dict {LOC BC7  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[2]}]
#set_property -dict {LOC BD8  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[3]}]
#set_property -dict {LOC BD10 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[4]}]
#set_property -dict {LOC BE10 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[5]}]
#set_property -dict {LOC BE7  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[6]}]
#set_property -dict {LOC BF7  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[7]}]
#set_property -dict {LOC AU13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[8]}]
#set_property -dict {LOC AV13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[9]}]
#set_property -dict {LOC AW13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[10]}]
#set_property -dict {LOC AW14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[11]}]
#set_property -dict {LOC AU14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[12]}]
#set_property -dict {LOC AY11 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[13]}]
#set_property -dict {LOC AV14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[14]}]
#set_property -dict {LOC BA11 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[15]}]
#set_property -dict {LOC BA12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[16]}]
#set_property -dict {LOC BB12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[17]}]
#set_property -dict {LOC BA13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[18]}]
#set_property -dict {LOC BA14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[19]}]
#set_property -dict {LOC BC9  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[20]}]
#set_property -dict {LOC BB9  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[21]}]
#set_property -dict {LOC BA7  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[22]}]
#set_property -dict {LOC BA8  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[23]}]
#set_property -dict {LOC AN13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[24]}]
#set_property -dict {LOC AR13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[25]}]
#set_property -dict {LOC AM13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[26]}]
#set_property -dict {LOC AP13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[27]}]
#set_property -dict {LOC AM14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[28]}]
#set_property -dict {LOC AR15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[29]}]
#set_property -dict {LOC AL14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[30]}]
#set_property -dict {LOC AT15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[31]}]
#set_property -dict {LOC BE13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[32]}]
#set_property -dict {LOC BD14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[33]}]
#set_property -dict {LOC BF12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[34]}]
#set_property -dict {LOC BD13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[35]}]
#set_property -dict {LOC BD15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[36]}]
#set_property -dict {LOC BD16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[37]}]
#set_property -dict {LOC BF14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[38]}]
#set_property -dict {LOC BF13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[39]}]
#set_property -dict {LOC AY17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[40]}]
#set_property -dict {LOC BA17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[41]}]
#set_property -dict {LOC AY18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[42]}]
#set_property -dict {LOC BA18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[43]}]
#set_property -dict {LOC BA15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[44]}]
#set_property -dict {LOC BB15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[45]}]
#set_property -dict {LOC BC11 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[46]}]
#set_property -dict {LOC BD11 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[47]}]
#set_property -dict {LOC AV16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[48]}]
#set_property -dict {LOC AV17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[49]}]
#set_property -dict {LOC AU16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[50]}]
#set_property -dict {LOC AU17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[51]}]
#set_property -dict {LOC BB17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[52]}]
#set_property -dict {LOC BB16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[53]}]
#set_property -dict {LOC AT18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[54]}]
#set_property -dict {LOC AT17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[55]}]
#set_property -dict {LOC AM15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[56]}]
#set_property -dict {LOC AL15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[57]}]
#set_property -dict {LOC AN17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[58]}]
#set_property -dict {LOC AN16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[59]}]
#set_property -dict {LOC AR18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[60]}]
#set_property -dict {LOC AP18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[61]}]
#set_property -dict {LOC AL17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[62]}]
#set_property -dict {LOC AL16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[63]}]
#set_property -dict {LOC BF25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[64]}]
#set_property -dict {LOC BF24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[65]}]
#set_property -dict {LOC BD25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[66]}]
#set_property -dict {LOC BE25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[67]}]
#set_property -dict {LOC BD23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[68]}]
#set_property -dict {LOC BC23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[69]}]
#set_property -dict {LOC BF23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[70]}]
#set_property -dict {LOC BE23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[71]}]
#set_property -dict {LOC BF10 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[0]}]
#set_property -dict {LOC BF9  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[0]}]
#set_property -dict {LOC BE8  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[1]}]
#set_property -dict {LOC BF8  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[1]}]
#set_property -dict {LOC AW15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[2]}]
#set_property -dict {LOC AY15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[2]}]
#set_property -dict {LOC AY13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[3]}]
#set_property -dict {LOC AY12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[3]}]
#set_property -dict {LOC BB11 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[4]}]
#set_property -dict {LOC BB10 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[4]}]
#set_property -dict {LOC BA10 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[5]}]
#set_property -dict {LOC BA9  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[5]}]
#set_property -dict {LOC AT14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[6]}]
#set_property -dict {LOC AT13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[6]}]
#set_property -dict {LOC AN14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[7]}]
#set_property -dict {LOC AP14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[7]}]
#set_property -dict {LOC BE12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[8]}]
#set_property -dict {LOC BE11 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[8]}]
#set_property -dict {LOC BE15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[9]}]
#set_property -dict {LOC BF15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[9]}]
#set_property -dict {LOC BC13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[10]}]
#set_property -dict {LOC BC12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[10]}]
#set_property -dict {LOC BB14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[11]}]
#set_property -dict {LOC BC14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[11]}]
#set_property -dict {LOC AV18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[12]}]
#set_property -dict {LOC AW18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[12]}]
#set_property -dict {LOC AW16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[13]}]
#set_property -dict {LOC AY16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[13]}]
#set_property -dict {LOC AP16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[14]}]
#set_property -dict {LOC AR16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[14]}]
#set_property -dict {LOC AM17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[15]}]
#set_property -dict {LOC AM16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[15]}]
#set_property -dict {LOC BC24 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[16]}]
#set_property -dict {LOC BD24 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[16]}]
#set_property -dict {LOC BE22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[17]}]
#set_property -dict {LOC BF22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[17]}]

# DDR4 C2
#set_property -dict {LOC L29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[0]}]
#set_property -dict {LOC A33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[1]}]
#set_property -dict {LOC C33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[2]}]
#set_property -dict {LOC J29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[3]}]
#set_property -dict {LOC H31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[4]}]
#set_property -dict {LOC G31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[5]}]
#set_property -dict {LOC C32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[6]}]
#set_property -dict {LOC B32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[7]}]
#set_property -dict {LOC A32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[8]}]
#set_property -dict {LOC D31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[9]}]
#set_property -dict {LOC A34  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[10]}]
#set_property -dict {LOC E31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[11]}]
#set_property -dict {LOC M30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[12]}]
#set_property -dict {LOC F33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[13]}]
#set_property -dict {LOC A35  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[14]}]
#set_property -dict {LOC G32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[15]}]
#set_property -dict {LOC K30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[16]}]
#set_property -dict {LOC D33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[0]}]
#set_property -dict {LOC B36  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[1]}]
#set_property -dict {LOC C31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[0]}]
#set_property -dict {LOC J30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[1]}]
#set_property -dict {LOC C34  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_t[0]}]
#set_property -dict {LOC B34  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_c[0]}]
#set_property -dict {LOC D34  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_t[1]}]
#set_property -dict {LOC D35  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_c[1]}]
#set_property -dict {LOC G30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cke[0]}]
#set_property -dict {LOC E30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cke[1]}]
#set_property -dict {LOC B35  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n[0]}]
#set_property -dict {LOC J31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n[1]}]
#set_property -dict {LOC L30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n[2]}]
#set_property -dict {LOC K31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n[3]}]
#set_property -dict {LOC B31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_act_n}]
#set_property -dict {LOC E33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_odt[0]}]
#set_property -dict {LOC F34  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_odt[1]}]
#set_property -dict {LOC M29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_par}]
#set_property -dict {LOC D36  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_reset_n}]

#set_property -dict {LOC R25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[0]}]
#set_property -dict {LOC P25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[1]}]
#set_property -dict {LOC M25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[2]}]
#set_property -dict {LOC L25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[3]}]
#set_property -dict {LOC P26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[4]}]
#set_property -dict {LOC R26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[5]}]
#set_property -dict {LOC N27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[6]}]
#set_property -dict {LOC N28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[7]}]
#set_property -dict {LOC J28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[8]}]
#set_property -dict {LOC H29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[9]}]
#set_property -dict {LOC H28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[10]}]
#set_property -dict {LOC G29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[11]}]
#set_property -dict {LOC K25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[12]}]
#set_property -dict {LOC L27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[13]}]
#set_property -dict {LOC K26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[14]}]
#set_property -dict {LOC K27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[15]}]
#set_property -dict {LOC F27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[16]}]
#set_property -dict {LOC E27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[17]}]
#set_property -dict {LOC E28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[18]}]
#set_property -dict {LOC D28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[19]}]
#set_property -dict {LOC G27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[20]}]
#set_property -dict {LOC G26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[21]}]
#set_property -dict {LOC F28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[22]}]
#set_property -dict {LOC F29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[23]}]
#set_property -dict {LOC D26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[24]}]
#set_property -dict {LOC C26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[25]}]
#set_property -dict {LOC B27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[26]}]
#set_property -dict {LOC B26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[27]}]
#set_property -dict {LOC A29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[28]}]
#set_property -dict {LOC A30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[29]}]
#set_property -dict {LOC C27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[30]}]
#set_property -dict {LOC C28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[31]}]
#set_property -dict {LOC F35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[32]}]
#set_property -dict {LOC E38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[33]}]
#set_property -dict {LOC D38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[34]}]
#set_property -dict {LOC E35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[35]}]
#set_property -dict {LOC E36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[36]}]
#set_property -dict {LOC E37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[37]}]
#set_property -dict {LOC F38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[38]}]
#set_property -dict {LOC G38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[39]}]
#set_property -dict {LOC P30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[40]}]
#set_property -dict {LOC R30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[41]}]
#set_property -dict {LOC P29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[42]}]
#set_property -dict {LOC N29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[43]}]
#set_property -dict {LOC L32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[44]}]
#set_property -dict {LOC M32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[45]}]
#set_property -dict {LOC P31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[46]}]
#set_property -dict {LOC N32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[47]}]
#set_property -dict {LOC J35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[48]}]
#set_property -dict {LOC K35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[49]}]
#set_property -dict {LOC L33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[50]}]
#set_property -dict {LOC K33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[51]}]
#set_property -dict {LOC J34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[52]}]
#set_property -dict {LOC J33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[53]}]
#set_property -dict {LOC N34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[54]}]
#set_property -dict {LOC P34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[55]}]
#set_property -dict {LOC H36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[56]}]
#set_property -dict {LOC G36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[57]}]
#set_property -dict {LOC H37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[58]}]
#set_property -dict {LOC J36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[59]}]
#set_property -dict {LOC K37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[60]}]
#set_property -dict {LOC K38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[61]}]
#set_property -dict {LOC G35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[62]}]
#set_property -dict {LOC G34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[63]}]
#set_property -dict {LOC C36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[64]}]
#set_property -dict {LOC B37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[65]}]
#set_property -dict {LOC A37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[66]}]
#set_property -dict {LOC A38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[67]}]
#set_property -dict {LOC C39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[68]}]
#set_property -dict {LOC D39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[69]}]
#set_property -dict {LOC A40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[70]}]
#set_property -dict {LOC B40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[71]}]
#set_property -dict {LOC N26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[0]}]
#set_property -dict {LOC M26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[0]}]
#set_property -dict {LOC R28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[1]}]
#set_property -dict {LOC P28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[1]}]
#set_property -dict {LOC J25  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[2]}]
#set_property -dict {LOC J26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[2]}]
#set_property -dict {LOC M27  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[3]}]
#set_property -dict {LOC L28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[3]}]
#set_property -dict {LOC D29  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[4]}]
#set_property -dict {LOC D30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[4]}]
#set_property -dict {LOC H26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[5]}]
#set_property -dict {LOC H27  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[5]}]
#set_property -dict {LOC A27  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[6]}]
#set_property -dict {LOC A28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[6]}]
#set_property -dict {LOC C29  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[7]}]
#set_property -dict {LOC B29  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[7]}]
#set_property -dict {LOC E39  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[8]}]
#set_property -dict {LOC E40  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[8]}]
#set_property -dict {LOC G37  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[9]}]
#set_property -dict {LOC F37  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[9]}]
#set_property -dict {LOC N31  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[10]}]
#set_property -dict {LOC M31  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[10]}]
#set_property -dict {LOC T30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[11]}]
#set_property -dict {LOC R31  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[11]}]
#set_property -dict {LOC L35  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[12]}]
#set_property -dict {LOC L36  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[12]}]
#set_property -dict {LOC M34  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[13]}]
#set_property -dict {LOC L34  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[13]}]
#set_property -dict {LOC J38  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[14]}]
#set_property -dict {LOC H38  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[14]}]
#set_property -dict {LOC H33  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[15]}]
#set_property -dict {LOC H34  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[15]}]
#set_property -dict {LOC B39  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[16]}]
#set_property -dict {LOC A39  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[16]}]
#set_property -dict {LOC C37  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[17]}]
#set_property -dict {LOC C38  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[17]}]

# DDR4 C3
#set_property -dict {LOC K15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[0]}]
#set_property -dict {LOC B15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[1]}]
#set_property -dict {LOC F14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[2]}]
#set_property -dict {LOC A15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[3]}]
#set_property -dict {LOC C14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[4]}]
#set_property -dict {LOC A14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[5]}]
#set_property -dict {LOC B14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[6]}]
#set_property -dict {LOC E13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[7]}]
#set_property -dict {LOC F13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[8]}]
#set_property -dict {LOC A13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[9]}]
#set_property -dict {LOC D14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[10]}]
#set_property -dict {LOC C13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[11]}]
#set_property -dict {LOC B13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[12]}]
#set_property -dict {LOC K16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[13]}]
#set_property -dict {LOC D15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[14]}]
#set_property -dict {LOC E15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[15]}]
#set_property -dict {LOC F15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[16]}]
#set_property -dict {LOC J15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_ba[0]}]
#set_property -dict {LOC H14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_ba[1]}]
#set_property -dict {LOC D13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_bg[0]}]
#set_property -dict {LOC J13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_bg[1]}]
#set_property -dict {LOC L14  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_t[0]}]
#set_property -dict {LOC L13  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_c[0]}]
#set_property -dict {LOC G14  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_t[1]}]
#set_property -dict {LOC G13  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_c[1]}]
#set_property -dict {LOC K13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cke[0]}]
#set_property -dict {LOC L15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cke[1]}]
#set_property -dict {LOC B16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cs_n[0]}]
#set_property -dict {LOC D16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cs_n[1]}]
#set_property -dict {LOC M14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cs_n[2]}]
#set_property -dict {LOC M13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cs_n[3]}]
#set_property -dict {LOC H13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_act_n}]
#set_property -dict {LOC C16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_odt[0]}]
#set_property -dict {LOC E16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_odt[1]}]
#set_property -dict {LOC J14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_par}]
#set_property -dict {LOC D21  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c3_reset_n}]

#set_property -dict {LOC P24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[0]}]
#set_property -dict {LOC N24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[1]}]
#set_property -dict {LOC T24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[2]}]
#set_property -dict {LOC R23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[3]}]
#set_property -dict {LOC N23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[4]}]
#set_property -dict {LOC P21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[5]}]
#set_property -dict {LOC P23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[6]}]
#set_property -dict {LOC R21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[7]}]
#set_property -dict {LOC J24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[8]}]
#set_property -dict {LOC J23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[9]}]
#set_property -dict {LOC H24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[10]}]
#set_property -dict {LOC G24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[11]}]
#set_property -dict {LOC L24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[12]}]
#set_property -dict {LOC L23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[13]}]
#set_property -dict {LOC K22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[14]}]
#set_property -dict {LOC K21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[15]}]
#set_property -dict {LOC G20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[16]}]
#set_property -dict {LOC H17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[17]}]
#set_property -dict {LOC F19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[18]}]
#set_property -dict {LOC G17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[19]}]
#set_property -dict {LOC J20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[20]}]
#set_property -dict {LOC L19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[21]}]
#set_property -dict {LOC L18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[22]}]
#set_property -dict {LOC J19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[23]}]
#set_property -dict {LOC M19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[24]}]
#set_property -dict {LOC M20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[25]}]
#set_property -dict {LOC R18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[26]}]
#set_property -dict {LOC R17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[27]}]
#set_property -dict {LOC R20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[28]}]
#set_property -dict {LOC T20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[29]}]
#set_property -dict {LOC N18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[30]}]
#set_property -dict {LOC N19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[31]}]
#set_property -dict {LOC A23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[32]}]
#set_property -dict {LOC A22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[33]}]
#set_property -dict {LOC B24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[34]}]
#set_property -dict {LOC B25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[35]}]
#set_property -dict {LOC B22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[36]}]
#set_property -dict {LOC C22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[37]}]
#set_property -dict {LOC C24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[38]}]
#set_property -dict {LOC C23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[39]}]
#set_property -dict {LOC C19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[40]}]
#set_property -dict {LOC C18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[41]}]
#set_property -dict {LOC C21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[42]}]
#set_property -dict {LOC B21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[43]}]
#set_property -dict {LOC A18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[44]}]
#set_property -dict {LOC A17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[45]}]
#set_property -dict {LOC A20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[46]}]
#set_property -dict {LOC B20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[47]}]
#set_property -dict {LOC E17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[48]}]
#set_property -dict {LOC F20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[49]}]
#set_property -dict {LOC E18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[50]}]
#set_property -dict {LOC E20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[51]}]
#set_property -dict {LOC D19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[52]}]
#set_property -dict {LOC D20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[53]}]
#set_property -dict {LOC H18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[54]}]
#set_property -dict {LOC J18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[55]}]
#set_property -dict {LOC F22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[56]}]
#set_property -dict {LOC E22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[57]}]
#set_property -dict {LOC G22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[58]}]
#set_property -dict {LOC G21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[59]}]
#set_property -dict {LOC F24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[60]}]
#set_property -dict {LOC E25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[61]}]
#set_property -dict {LOC F25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[62]}]
#set_property -dict {LOC G25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[63]}]
#set_property -dict {LOC M16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[64]}]
#set_property -dict {LOC N16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[65]}]
#set_property -dict {LOC N13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[66]}]
#set_property -dict {LOC N14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[67]}]
#set_property -dict {LOC T15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[68]}]
#set_property -dict {LOC R15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[69]}]
#set_property -dict {LOC P13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[70]}]
#set_property -dict {LOC P14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[71]}]
#set_property -dict {LOC T22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[0]}]
#set_property -dict {LOC R22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[0]}]
#set_property -dict {LOC N22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[1]}]
#set_property -dict {LOC N21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[1]}]
#set_property -dict {LOC J21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[2]}]
#set_property -dict {LOC H21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[2]}]
#set_property -dict {LOC M22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[3]}]
#set_property -dict {LOC L22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[3]}]
#set_property -dict {LOC L20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[4]}]
#set_property -dict {LOC K20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[4]}]
#set_property -dict {LOC K18  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[5]}]
#set_property -dict {LOC K17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[5]}]
#set_property -dict {LOC P19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[6]}]
#set_property -dict {LOC P18  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[6]}]
#set_property -dict {LOC N17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[7]}]
#set_property -dict {LOC M17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[7]}]
#set_property -dict {LOC A25  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[8]}]
#set_property -dict {LOC A24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[8]}]
#set_property -dict {LOC D24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[9]}]
#set_property -dict {LOC D23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[9]}]
#set_property -dict {LOC C17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[10]}]
#set_property -dict {LOC B17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[10]}]
#set_property -dict {LOC B19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[11]}]
#set_property -dict {LOC A19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[11]}]
#set_property -dict {LOC F18  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[12]}]
#set_property -dict {LOC F17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[12]}]
#set_property -dict {LOC H19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[13]}]
#set_property -dict {LOC G19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[13]}]
#set_property -dict {LOC F23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[14]}]
#set_property -dict {LOC E23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[14]}]
#set_property -dict {LOC H23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[15]}]
#set_property -dict {LOC H22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[15]}]
#set_property -dict {LOC R16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[16]}]
#set_property -dict {LOC P15  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[16]}]
#set_property -dict {LOC T13  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[17]}]
#set_property -dict {LOC R13  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[17]}]
