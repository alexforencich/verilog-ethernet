# XDC constraints for the Xilinx Alveo U55C/Alveo U55N/Varium C1100 board
# U55C       part: xcu55c-fsvh2892-2L-e
# U55N/C1100 part: xcu55n-fsvh2892-2L-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE    [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE           [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DISABLE [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP         [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

#set_operating_conditions -design_power_budget 63

# System clocks
# 100 MHz
#set_property -dict {LOC BK10 IOSTANDARD LVDS} [get_ports clk_100mhz_0_p]
#set_property -dict {LOC BL10 IOSTANDARD LVDS} [get_ports clk_100mhz_0_n]
#create_clock -period 10 -name clk_100mhz_0 [get_ports clk_100mhz_0_p]

# 100 MHz
#set_property -dict {LOC BK43 IOSTANDARD LVDS} [get_ports clk_100mhz_1_p]
#set_property -dict {LOC BK44 IOSTANDARD LVDS} [get_ports clk_100mhz_1_n]
#create_clock -period 10 -name clk_100mhz_1 [get_ports clk_100mhz_1_p]

# 100 MHz
#set_property -dict {LOC F24  IOSTANDARD LVDS} [get_ports clk_100mhz_2_p]
#set_property -dict {LOC F23  IOSTANDARD LVDS} [get_ports clk_100mhz_2_n]
#create_clock -period 10 -name clk_100mhz_2 [get_ports clk_100mhz_2_p]

# Reset button
set_property -dict {LOC BG45 IOSTANDARD LVCMOS18} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# LEDs
set_property -dict {LOC BL13 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_act[0]}]
set_property -dict {LOC BK11 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_stat_g[0]}]
set_property -dict {LOC BJ11 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_stat_y[0]}]
set_property -dict {LOC BK14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_act[1]}]
set_property -dict {LOC BK15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_stat_g[1]}]
set_property -dict {LOC BL12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {qsfp_led_stat_y[1]}]

set_false_path -to [get_ports {qsfp_led_act[*] qsfp_led_stat_g[*] qsfp_led_stat_y[*]}]
set_output_delay 0 [get_ports {qsfp_led_act[*] qsfp_led_stat_g[*] qsfp_led_stat_y[*]}]

# UART
set_property -dict {LOC BJ41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_txd[0]}]
set_property -dict {LOC BK41 IOSTANDARD LVCMOS18} [get_ports {uart_rxd[0]}]
set_property -dict {LOC BN47 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_txd[1]}]
set_property -dict {LOC BP47 IOSTANDARD LVCMOS18} [get_ports {uart_rxd[1]}]
set_property -dict {LOC BL45 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_txd[2]}]
set_property -dict {LOC BL46 IOSTANDARD LVCMOS18} [get_ports {uart_rxd[2]}]

#set_false_path -to [get_ports {uart_txd[*]}]
#set_output_delay 0 [get_ports {uart_txd[*]}]
#set_false_path -from [get_ports {uart_rxd[*]}]
#set_input_delay 0 [get_ports {uart_rxd[*]}]

# BMC
#set_property -dict {LOC BE46 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[0]}]
#set_property -dict {LOC BH46 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[1]}]
#set_property -dict {LOC BF45 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[2]}]
#set_property -dict {LOC BF46 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {msp_gpio[3]}]
#set_property -dict {LOC BH42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports {msp_uart_txd}]
#set_property -dict {LOC BJ42 IOSTANDARD LVCMOS18} [get_ports {msp_uart_rxd}]

#set_false_path -to [get_ports {msp_uart_txd}]
#set_output_delay 0 [get_ports {msp_uart_txd}]
#set_false_path -from [get_ports {msp_gpio[*] msp_uart_rxd}]
#set_input_delay 0 [get_ports {msp_gpio[*] msp_uart_rxd}]

# HBM overtemp
set_property -dict {LOC BE45 IOSTANDARD LVCMOS18} [get_ports hbm_cattrip]

set_false_path -to [get_ports {hbm_cattrip}]
set_output_delay 0 [get_ports {hbm_cattrip}]

# SI5394 (SI5394B-A10605-GM)
# I2C address 0x68
# IN0: 161.1328125 MHz from qsfp_recclk
# OUT0: 161.1328125 MHz to qsfp0_mgt_refclk
# OUT1: 161.1328125 MHz to qsfp1_mgt_refclk
# OUT3: 100 MHz to clk_100mhz_0, clk_100mhz_1, pcie_refclk_2, pcie_refclk_3
#set_property -dict {LOC BM8  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports si5394_rst_b]
#set_property -dict {LOC BM9  IOSTANDARD LVCMOS18 PULLUP true} [get_ports si5394_int_b]
#set_property -dict {LOC BN10 IOSTANDARD LVCMOS18 PULLUP true} [get_ports si5394_lol_b]
#set_property -dict {LOC BM10 IOSTANDARD LVCMOS18 PULLUP true} [get_ports si5394_los_b]
#set_property -dict {LOC BN14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8 PULLUP true} [get_ports si5394_sda]
#set_property -dict {LOC BM14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8 PULLUP true} [get_ports si5394_scl]

#set_false_path -to [get_ports {si5394_rst_b}]
#set_output_delay 0 [get_ports {si5394_rst_b}]
#set_false_path -from [get_ports {si5394_int_b si5394_lol_b si5394_los_b}]
#set_input_delay 0 [get_ports {si5394_int_b si5394_lol_b si5394_los_b}]

#set_false_path -to [get_ports {si5394_i2c_sda si5394_i2c_scl}]
#set_output_delay 0 [get_ports {si5394_i2c_sda si5394_i2c_scl}]
#set_false_path -from [get_ports {si5394_i2c_sda si5394_i2c_scl}]
#set_input_delay 0 [get_ports {si5394_i2c_sda si5394_i2c_scl}]

# QSFP28 Interfaces
set_property -dict {LOC AD51} [get_ports {qsfp0_rx_p[0]}] ;# MGTYRXP0_130 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AD52} [get_ports {qsfp0_rx_n[0]}] ;# MGTYRXN0_130 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AD46} [get_ports {qsfp0_tx_p[0]}] ;# MGTYTXP0_130 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AD47} [get_ports {qsfp0_tx_n[0]}] ;# MGTYTXN0_130 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC53} [get_ports {qsfp0_rx_p[1]}] ;# MGTYRXP1_130 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC54} [get_ports {qsfp0_rx_n[1]}] ;# MGTYRXN1_130 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC44} [get_ports {qsfp0_tx_p[1]}] ;# MGTYTXP1_130 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC45} [get_ports {qsfp0_tx_n[1]}] ;# MGTYTXN1_130 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC49} [get_ports {qsfp0_rx_p[2]}] ;# MGTYRXP2_130 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AC50} [get_ports {qsfp0_rx_n[2]}] ;# MGTYRXN2_130 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AB46} [get_ports {qsfp0_tx_p[2]}] ;# MGTYTXP2_130 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AB47} [get_ports {qsfp0_tx_n[2]}] ;# MGTYTXN2_130 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AB51} [get_ports {qsfp0_rx_p[3]}] ;# MGTYRXP3_130 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AB52} [get_ports {qsfp0_rx_n[3]}] ;# MGTYRXN3_130 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AA48} [get_ports {qsfp0_tx_p[3]}] ;# MGTYTXP3_130 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AA49} [get_ports {qsfp0_tx_n[3]}] ;# MGTYTXN3_130 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AD42} [get_ports qsfp0_mgt_refclk_p] ;# MGTREFCLK0P_130 from SI5394 OUT0
set_property -dict {LOC AD43} [get_ports qsfp0_mgt_refclk_n] ;# MGTREFCLK0N_130 from SI5394 OUT0

# 161.1328125 MHz MGT reference clock (SI5394 OUT0)
create_clock -period 6.206 -name qsfp0_mgt_refclk [get_ports qsfp0_mgt_refclk_p]

set_property -dict {LOC AA53} [get_ports {qsfp1_rx_p[0]}] ;# MGTYRXP0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AA54} [get_ports {qsfp1_rx_n[0]}] ;# MGTYRXN0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AA44} [get_ports {qsfp1_tx_p[0]}] ;# MGTYTXP0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AA45} [get_ports {qsfp1_tx_n[0]}] ;# MGTYTXN0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC Y51 } [get_ports {qsfp1_rx_p[1]}] ;# MGTYRXP1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC Y52 } [get_ports {qsfp1_rx_n[1]}] ;# MGTYRXN1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC Y46 } [get_ports {qsfp1_tx_p[1]}] ;# MGTYTXP1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC Y47 } [get_ports {qsfp1_tx_n[1]}] ;# MGTYTXN1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W53 } [get_ports {qsfp1_rx_p[2]}] ;# MGTYRXP2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W54 } [get_ports {qsfp1_rx_n[2]}] ;# MGTYRXN2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W48 } [get_ports {qsfp1_tx_p[2]}] ;# MGTYTXP2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W49 } [get_ports {qsfp1_tx_n[2]}] ;# MGTYTXN2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC V51 } [get_ports {qsfp1_rx_p[3]}] ;# MGTYRXP3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC V52 } [get_ports {qsfp1_rx_n[3]}] ;# MGTYRXN3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W44 } [get_ports {qsfp1_tx_p[3]}] ;# MGTYTXP3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W45 } [get_ports {qsfp1_tx_n[3]}] ;# MGTYTXN3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC AB42} [get_ports qsfp1_mgt_refclk_p] ;# MGTREFCLK0P_131 from SI5394 OUT1
set_property -dict {LOC AB43} [get_ports qsfp1_mgt_refclk_n] ;# MGTREFCLK0N_131 from SI5394 OUT1

# 161.1328125 MHz MGT reference clock (SI5394 OUT1)
create_clock -period 6.206 -name qsfp1_mgt_refclk [get_ports qsfp1_mgt_refclk_p]

# PCIe Interface
#set_property -dict {LOC AL2 } [get_ports {pcie_rx_p[0]}]  ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AL1 } [get_ports {pcie_rx_n[0]}]  ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AL11} [get_ports {pcie_tx_p[0]}]  ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AL10} [get_ports {pcie_tx_n[0]}]  ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y15 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AM4 } [get_ports {pcie_rx_p[1]}]  ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AM3 } [get_ports {pcie_rx_n[1]}]  ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AM9 } [get_ports {pcie_tx_p[1]}]  ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AM8 } [get_ports {pcie_tx_n[1]}]  ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y14 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN6 } [get_ports {pcie_rx_p[2]}]  ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN5 } [get_ports {pcie_rx_n[2]}]  ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN11} [get_ports {pcie_tx_p[2]}]  ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN10} [get_ports {pcie_tx_n[2]}]  ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y13 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN2 } [get_ports {pcie_rx_p[3]}]  ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AN1 } [get_ports {pcie_rx_n[3]}]  ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AP9 } [get_ports {pcie_tx_p[3]}]  ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AP8 } [get_ports {pcie_tx_n[3]}]  ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y12 / GTYE4_COMMON_X1Y3
#set_property -dict {LOC AP4 } [get_ports {pcie_rx_p[4]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AP3 } [get_ports {pcie_rx_n[4]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR11} [get_ports {pcie_tx_p[4]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR10} [get_ports {pcie_tx_n[4]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y11 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR2 } [get_ports {pcie_rx_p[5]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR1 } [get_ports {pcie_rx_n[5]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR7 } [get_ports {pcie_tx_p[5]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AR6 } [get_ports {pcie_tx_n[5]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y10 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AT4 } [get_ports {pcie_rx_p[6]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AT3 } [get_ports {pcie_rx_n[6]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AT9 } [get_ports {pcie_tx_p[6]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AT8 } [get_ports {pcie_tx_n[6]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y9 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AU2 } [get_ports {pcie_rx_p[7]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AU1 } [get_ports {pcie_rx_n[7]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AU11} [get_ports {pcie_tx_p[7]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AU10} [get_ports {pcie_tx_n[7]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y8 / GTYE4_COMMON_X1Y2
#set_property -dict {LOC AV4 } [get_ports {pcie_rx_p[8]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AV3 } [get_ports {pcie_rx_n[8]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AU7 } [get_ports {pcie_tx_p[8]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AU6 } [get_ports {pcie_tx_n[8]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y7 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW6 } [get_ports {pcie_rx_p[9]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW5 } [get_ports {pcie_rx_n[9]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AV9 } [get_ports {pcie_tx_p[9]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AV8 } [get_ports {pcie_tx_n[9]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y6 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW2 } [get_ports {pcie_rx_p[10]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW1 } [get_ports {pcie_rx_n[10]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW11} [get_ports {pcie_tx_p[10]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AW10} [get_ports {pcie_tx_n[10]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y5 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AY4 } [get_ports {pcie_rx_p[11]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AY3 } [get_ports {pcie_rx_n[11]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AY9 } [get_ports {pcie_tx_p[11]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC AY8 } [get_ports {pcie_tx_n[11]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y4 / GTYE4_COMMON_X1Y1
#set_property -dict {LOC BA6 } [get_ports {pcie_rx_p[12]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BA5 } [get_ports {pcie_rx_n[12]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BA11} [get_ports {pcie_tx_p[12]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BA10} [get_ports {pcie_tx_n[12]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y3 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BA2 } [get_ports {pcie_rx_p[13]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BA1 } [get_ports {pcie_rx_n[13]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BB9 } [get_ports {pcie_tx_p[13]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BB8 } [get_ports {pcie_tx_n[13]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y2 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BB4 } [get_ports {pcie_rx_p[14]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BB3 } [get_ports {pcie_rx_n[14]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC11} [get_ports {pcie_tx_p[14]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC10} [get_ports {pcie_tx_n[14]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y1 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC2 } [get_ports {pcie_rx_p[15]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC1 } [get_ports {pcie_rx_n[15]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC7 } [get_ports {pcie_tx_p[15]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC BC6 } [get_ports {pcie_tx_n[15]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y0 / GTYE4_COMMON_X1Y0
#set_property -dict {LOC AL15} [get_ports pcie_refclk_0_p] ;# MGTREFCLK0P_227 (for x8 bifurcated lanes 0-7)
#set_property -dict {LOC AL14} [get_ports pcie_refclk_0_n] ;# MGTREFCLK0N_227 (for x8 bifurcated lanes 0-7)
#set_property -dict {LOC AK13} [get_ports pcie_refclk_2_p] ;# MGTREFCLK1P_227 (for async x8 bifurcated lanes 0-7)
#set_property -dict {LOC AK12} [get_ports pcie_refclk_2_n] ;# MGTREFCLK1N_227 (for async x8 bifurcated lanes 0-7)
#set_property -dict {LOC AR15} [get_ports pcie_refclk_1_p] ;# MGTREFCLK0P_225 (for x16 or x8 bifurcated lanes 8-16)
#set_property -dict {LOC AR14} [get_ports pcie_refclk_1_n] ;# MGTREFCLK0N_225 (for x16 or x8 bifurcated lanes 8-16)
#set_property -dict {LOC AP13} [get_ports pcie_refclk_3_p] ;# MGTREFCLK1P_225 (for async x16 or x8 bifurcated lanes 8-16)
#set_property -dict {LOC AP12} [get_ports pcie_refclk_3_n] ;# MGTREFCLK1N_225 (for async x16 or x8 bifurcated lanes 8-16)
#set_property -dict {LOC BF41 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_0 [get_ports pcie_refclk_0_p]
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_1_p]
#create_clock -period 10 -name pcie_mgt_refclk_2 [get_ports pcie_refclk_2_p]
#create_clock -period 10 -name pcie_mgt_refclk_3 [get_ports pcie_refclk_3_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]
