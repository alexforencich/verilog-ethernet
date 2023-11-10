# XDC constraints for the Xilinx Alveo U280 board
# part: xcu280-fsvh2892-2L-e

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

set_operating_conditions -design_power_budget 160

# System clocks
# 100 MHz (DDR4)
#set_property -dict {LOC BJ43 IOSTANDARD LVDS} [get_ports clk_100mhz_0_p]
#set_property -dict {LOC BJ44 IOSTANDARD LVDS} [get_ports clk_100mhz_0_n]
#create_clock -period 10 -name clk_100mhz_0 [get_ports clk_100mhz_0_p]

# 100 MHz (DDR4)
#set_property -dict {LOC BH6 IOSTANDARD LVDS} [get_ports clk_100mhz_1_p]
#set_property -dict {LOC BJ6 IOSTANDARD LVDS} [get_ports clk_100mhz_1_n]
#create_clock -period 10 -name clk_100mhz_1 [get_ports clk_100mhz_1_p]

# 100 MHz
#set_property -dict {LOC G31 IOSTANDARD LVDS} [get_ports clk_100mhz_2_p]
#set_property -dict {LOC F31 IOSTANDARD LVDS} [get_ports clk_100mhz_2_n]
#create_clock -period 10 -name clk_100mhz_2 [get_ports clk_100mhz_2_p]

# SI570 user clock
#set_property -dict {LOC G30 IOSTANDARD LVDS} [get_ports clk_si570_p]
#set_property -dict {LOC F30 IOSTANDARD LVDS} [get_ports clk_si570_n]
#create_clock -period 6.4 -name clk_si570 [get_ports clk_si570_p]

# Reset button
set_property -dict {LOC L30 IOSTANDARD LVCMOS18} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# UART
set_property -dict {LOC A28 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC B33 IOSTANDARD LVCMOS18} [get_ports uart_rxd]

#set_false_path -to [get_ports {uart_txd}]
#set_output_delay 0 [get_ports {uart_txd}]
#set_false_path -from [get_ports {uart_rxd}]
#set_input_delay 0 [get_ports {uart_rxd}]

# HBM overtemp
set_property -dict {LOC D32 IOSTANDARD LVCMOS18} [get_ports hbm_cattrip]

set_false_path -to [get_ports {hbm_cattrip}]
set_output_delay 0 [get_ports {hbm_cattrip}]

# QSFP28 Interfaces
set_property -dict {LOC L53 } [get_ports {qsfp0_rx_p[0]}] ;# MGTYRXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L54 } [get_ports {qsfp0_rx_n[0]}] ;# MGTYRXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L48 } [get_ports {qsfp0_tx_p[0]}] ;# MGTYTXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L49 } [get_ports {qsfp0_tx_n[0]}] ;# MGTYTXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K51 } [get_ports {qsfp0_rx_p[1]}] ;# MGTYRXP1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K52 } [get_ports {qsfp0_rx_n[1]}] ;# MGTYRXN1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L44 } [get_ports {qsfp0_tx_p[1]}] ;# MGTYTXP1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L45 } [get_ports {qsfp0_tx_n[1]}] ;# MGTYTXN1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J53 } [get_ports {qsfp0_rx_p[2]}] ;# MGTYRXP2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J54 } [get_ports {qsfp0_rx_n[2]}] ;# MGTYRXN2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K46 } [get_ports {qsfp0_tx_p[2]}] ;# MGTYTXP2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K47 } [get_ports {qsfp0_tx_n[2]}] ;# MGTYTXN2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC H51 } [get_ports {qsfp0_rx_p[3]}] ;# MGTYRXP3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC H52 } [get_ports {qsfp0_rx_n[3]}] ;# MGTYRXN3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J48 } [get_ports {qsfp0_tx_p[3]}] ;# MGTYTXP3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J49 } [get_ports {qsfp0_tx_n[3]}] ;# MGTYTXN3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
#set_property -dict {LOC T42 } [get_ports qsfp0_mgt_refclk_0_p] ;# MGTREFCLK0P_134 from SI570
#set_property -dict {LOC T43 } [get_ports qsfp0_mgt_refclk_0_n] ;# MGTREFCLK0N_134 from SI570
set_property -dict {LOC R40 } [get_ports qsfp0_mgt_refclk_1_p] ;# MGTREFCLK1P_134 from SI546
set_property -dict {LOC R41 } [get_ports qsfp0_mgt_refclk_1_n] ;# MGTREFCLK1N_134 from SI546
set_property -dict {LOC H32 IOSTANDARD LVCMOS18} [get_ports qsfp0_refclk_oe_b]
set_property -dict {LOC G32 IOSTANDARD LVCMOS18} [get_ports qsfp0_refclk_fs]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_0 [get_ports qsfp0_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI546, fs = 0)
#create_clock -period 6.400 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI546, fs = 1)
create_clock -period 6.206 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp0_refclk_oe_b qsfp0_refclk_fs}]
set_output_delay 0 [get_ports {qsfp0_refclk_oe_b qsfp0_refclk_fs}]

set_property -dict {LOC G53 } [get_ports {qsfp1_rx_p[0]}] ;# MGTYRXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G54 } [get_ports {qsfp1_rx_n[0]}] ;# MGTYRXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G48 } [get_ports {qsfp1_tx_p[0]}] ;# MGTYTXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G49 } [get_ports {qsfp1_tx_n[0]}] ;# MGTYTXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC F51 } [get_ports {qsfp1_rx_p[1]}] ;# MGTYRXP1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC F52 } [get_ports {qsfp1_rx_n[1]}] ;# MGTYRXN1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E48 } [get_ports {qsfp1_tx_p[1]}] ;# MGTYTXP1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E49 } [get_ports {qsfp1_tx_n[1]}] ;# MGTYTXN1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E53 } [get_ports {qsfp1_rx_p[2]}] ;# MGTYRXP2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E54 } [get_ports {qsfp1_rx_n[2]}] ;# MGTYRXN2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC C48 } [get_ports {qsfp1_tx_p[2]}] ;# MGTYTXP2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC C49 } [get_ports {qsfp1_tx_n[2]}] ;# MGTYTXN2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC D51 } [get_ports {qsfp1_rx_p[3]}] ;# MGTYRXP3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC D52 } [get_ports {qsfp1_rx_n[3]}] ;# MGTYRXN3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC A49 } [get_ports {qsfp1_tx_p[3]}] ;# MGTYTXP3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC A50 } [get_ports {qsfp1_tx_n[3]}] ;# MGTYTXN3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
#set_property -dict {LOC P42 } [get_ports qsfp1_mgt_refclk_0_p] ;# MGTREFCLK0P_135 from SI570
#set_property -dict {LOC P43 } [get_ports qsfp1_mgt_refclk_0_n] ;# MGTREFCLK0N_135 from SI570
set_property -dict {LOC M42 } [get_ports qsfp1_mgt_refclk_1_p] ;# MGTREFCLK1P_135 from SI546
set_property -dict {LOC M43 } [get_ports qsfp1_mgt_refclk_1_n] ;# MGTREFCLK1N_135 from SI546
set_property -dict {LOC H30 IOSTANDARD LVCMOS18} [get_ports qsfp1_refclk_oe_b]
set_property -dict {LOC G33 IOSTANDARD LVCMOS18} [get_ports qsfp1_refclk_fs]

# 156.25 MHz MGT reference clock (from SI570)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_0 [get_ports qsfp1_mgt_refclk_0_p]

# 156.25 MHz MGT reference clock (from SI546, fs = 0)
#create_clock -period 6.400 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

# 161.1328125 MHz MGT reference clock (from SI546, fs = 1)
create_clock -period 6.206 -name qsfp1_mgt_refclk_1 [get_ports qsfp1_mgt_refclk_1_p]

set_false_path -to [get_ports {qsfp1_refclk_oe_b qsfp1_refclk_fs}]
set_output_delay 0 [get_ports {qsfp1_refclk_oe_b qsfp1_refclk_fs}]

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
#set_property -dict {LOC BH26 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_0 [get_ports pcie_refclk_0_p]
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_1_p]
#create_clock -period 10 -name pcie_mgt_refclk_2 [get_ports pcie_refclk_2_p]
#create_clock -period 10 -name pcie_mgt_refclk_3 [get_ports pcie_refclk_3_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# DDR4 C0
#set_property -dict {LOC BF46 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[0]}]
#set_property -dict {LOC BG43 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[1]}]
#set_property -dict {LOC BK45 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[2]}]
#set_property -dict {LOC BF42 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[3]}]
#set_property -dict {LOC BL45 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[4]}]
#set_property -dict {LOC BF43 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[5]}]
#set_property -dict {LOC BG42 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[6]}]
#set_property -dict {LOC BL43 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[7]}]
#set_property -dict {LOC BK43 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[8]}]
#set_property -dict {LOC BM42 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[9]}]
#set_property -dict {LOC BG45 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[10]}]
#set_property -dict {LOC BD41 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[11]}]
#set_property -dict {LOC BL42 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[12]}]
#set_property -dict {LOC BE44 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[13]}]
#set_property -dict {LOC BE43 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[14]}]
#set_property -dict {LOC BL46 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[15]}]
#set_property -dict {LOC BH44 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_adr[16]}]
#set_property -dict {LOC BH45 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_ba[0]}]
#set_property -dict {LOC BM47 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_ba[1]}]
#set_property -dict {LOC BF41 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_bg[0]}]
#set_property -dict {LOC BE41 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_bg[1]}]
#set_property -dict {LOC BH46 IOSTANDARD DIFF_SSTL12_DCI } [get_ports {ddr4_c0_ck_t}]
#set_property -dict {LOC BJ46 IOSTANDARD DIFF_SSTL12_DCI } [get_ports {ddr4_c0_ck_c}]
#set_property -dict {LOC BH42 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_cke}]
#set_property -dict {LOC BK46 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_cs_n}]
#set_property -dict {LOC BH41 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_act_n}]
#set_property -dict {LOC BG44 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_odt}]
#set_property -dict {LOC BF45 IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c0_par}]
#set_property -dict {LOC BG33 IOSTANDARD LVCMOS12 DRIVE 8} [get_ports {ddr4_c0_reset_n}]

#set_property -dict {LOC BN32 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[0]}]
#set_property -dict {LOC BP32 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[1]}]
#set_property -dict {LOC BL30 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[2]}]
#set_property -dict {LOC BM30 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[3]}]
#set_property -dict {LOC BP29 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[4]}]
#set_property -dict {LOC BP28 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[5]}]
#set_property -dict {LOC BP31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[6]}]
#set_property -dict {LOC BN31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[7]}]
#set_property -dict {LOC BJ31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[8]}]
#set_property -dict {LOC BH31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[9]}]
#set_property -dict {LOC BF32 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[10]}]
#set_property -dict {LOC BF33 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[11]}]
#set_property -dict {LOC BH29 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[12]}]
#set_property -dict {LOC BH30 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[13]}]
#set_property -dict {LOC BF31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[14]}]
#set_property -dict {LOC BG32 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[15]}]
#set_property -dict {LOC BK31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[16]}]
#set_property -dict {LOC BL31 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[17]}]
#set_property -dict {LOC BK33 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[18]}]
#set_property -dict {LOC BL33 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[19]}]
#set_property -dict {LOC BL32 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[20]}]
#set_property -dict {LOC BM33 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[21]}]
#set_property -dict {LOC BN34 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[22]}]
#set_property -dict {LOC BP34 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[23]}]
#set_property -dict {LOC BH34 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[24]}]
#set_property -dict {LOC BH35 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[25]}]
#set_property -dict {LOC BF35 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[26]}]
#set_property -dict {LOC BF36 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[27]}]
#set_property -dict {LOC BJ33 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[28]}]
#set_property -dict {LOC BJ34 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[29]}]
#set_property -dict {LOC BG34 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[30]}]
#set_property -dict {LOC BG35 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[31]}]
#set_property -dict {LOC BM52 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[32]}]
#set_property -dict {LOC BL53 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[33]}]
#set_property -dict {LOC BL52 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[34]}]
#set_property -dict {LOC BL51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[35]}]
#set_property -dict {LOC BN50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[36]}]
#set_property -dict {LOC BN51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[37]}]
#set_property -dict {LOC BN49 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[38]}]
#set_property -dict {LOC BM48 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[39]}]
#set_property -dict {LOC BE50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[40]}]
#set_property -dict {LOC BE49 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[41]}]
#set_property -dict {LOC BE51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[42]}]
#set_property -dict {LOC BD51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[43]}]
#set_property -dict {LOC BF52 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[44]}]
#set_property -dict {LOC BF51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[45]}]
#set_property -dict {LOC BG50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[46]}]
#set_property -dict {LOC BF50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[47]}]
#set_property -dict {LOC BH50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[48]}]
#set_property -dict {LOC BJ51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[49]}]
#set_property -dict {LOC BH51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[50]}]
#set_property -dict {LOC BH49 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[51]}]
#set_property -dict {LOC BK50 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[52]}]
#set_property -dict {LOC BK51 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[53]}]
#set_property -dict {LOC BJ49 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[54]}]
#set_property -dict {LOC BJ48 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[55]}]
#set_property -dict {LOC BN44 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[56]}]
#set_property -dict {LOC BN45 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[57]}]
#set_property -dict {LOC BM44 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[58]}]
#set_property -dict {LOC BM45 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[59]}]
#set_property -dict {LOC BP43 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[60]}]
#set_property -dict {LOC BP44 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[61]}]
#set_property -dict {LOC BN47 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[62]}]
#set_property -dict {LOC BP47 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[63]}]
#set_property -dict {LOC BG54 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[64]}]
#set_property -dict {LOC BG53 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[65]}]
#set_property -dict {LOC BE53 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[66]}]
#set_property -dict {LOC BE54 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[67]}]
#set_property -dict {LOC BH52 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[68]}]
#set_property -dict {LOC BG52 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[69]}]
#set_property -dict {LOC BK54 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[70]}]
#set_property -dict {LOC BK53 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c0_dq[71]}]
#set_property -dict {LOC BN29 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[0]}]
#set_property -dict {LOC BN30 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[0]}]
#set_property -dict {LOC BM28 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[1]}]
#set_property -dict {LOC BM29 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[1]}]
#set_property -dict {LOC BJ29 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[2]}]
#set_property -dict {LOC BK30 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[2]}]
#set_property -dict {LOC BG29 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[3]}]
#set_property -dict {LOC BG30 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[3]}]
#set_property -dict {LOC BL35 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[4]}]
#set_property -dict {LOC BM35 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[4]}]
#set_property -dict {LOC BM34 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[5]}]
#set_property -dict {LOC BN35 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[5]}]
#set_property -dict {LOC BK34 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[6]}]
#set_property -dict {LOC BK35 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[6]}]
#set_property -dict {LOC BH32 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[7]}]
#set_property -dict {LOC BJ32 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[7]}]
#set_property -dict {LOC BM49 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[8]}]
#set_property -dict {LOC BM50 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[8]}]
#set_property -dict {LOC BP48 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[9]}]
#set_property -dict {LOC BP49 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[9]}]
#set_property -dict {LOC BF47 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[10]}]
#set_property -dict {LOC BF48 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[10]}]
#set_property -dict {LOC BG48 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[11]}]
#set_property -dict {LOC BG49 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[11]}]
#set_property -dict {LOC BH47 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[12]}]
#set_property -dict {LOC BJ47 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[12]}]
#set_property -dict {LOC BK48 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[13]}]
#set_property -dict {LOC BK49 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[13]}]
#set_property -dict {LOC BN46 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[14]}]
#set_property -dict {LOC BP46 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[14]}]
#set_property -dict {LOC BN42 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[15]}]
#set_property -dict {LOC BP42 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[15]}]
#set_property -dict {LOC BH54 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[16]}]
#set_property -dict {LOC BJ54 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[16]}]
#set_property -dict {LOC BJ52 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_t[17]}]
#set_property -dict {LOC BJ53 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c0_dqs_c[17]}]

# DDR4 C1
#set_property -dict {LOC BF7  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC BK1  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC BF6  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC BF5  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC BE3  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC BE6  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC BE5  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC BG7  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC BJ1  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC BG2  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC BJ8  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC BE4  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC BL2  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC BK5  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC BK8  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC BJ4  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC BF8  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC BG8  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC BK4  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC BF3  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC BF2  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_bg[1]}]
#set_property -dict {LOC BJ3  IOSTANDARD DIFF_SSTL12_DCI } [get_ports {ddr4_c1_ck_t}]
#set_property -dict {LOC BJ2  IOSTANDARD DIFF_SSTL12_DCI } [get_ports {ddr4_c1_ck_c}]
#set_property -dict {LOC BE1  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_cke}]
#set_property -dict {LOC BL3  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_cs_n}]
#set_property -dict {LOC BG3  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC BH2  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_odt}]
#set_property -dict {LOC BH1  IOSTANDARD SSTL12_DCI      } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC BH12 IOSTANDARD LVCMOS12 DRIVE 8} [get_ports {ddr4_c1_reset_n}]

#set_property -dict {LOC A11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[0]}]
#set_property -dict {LOC A10  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[1]}]
#set_property -dict {LOC A9   IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[2]}]
#set_property -dict {LOC A8   IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[3]}]
#set_property -dict {LOC B12  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[4]}]
#set_property -dict {LOC B10  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[5]}]
#set_property -dict {LOC C12  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[6]}]
#set_property -dict {LOC B11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[7]}]
#set_property -dict {LOC E11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[8]}]
#set_property -dict {LOC D11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[9]}]
#set_property -dict {LOC E12  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[10]}]
#set_property -dict {LOC F11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[11]}]
#set_property -dict {LOC F10  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[12]}]
#set_property -dict {LOC E9   IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[13]}]
#set_property -dict {LOC F9   IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[14]}]
#set_property -dict {LOC G11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[15]}]
#set_property -dict {LOC H12  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[16]}]
#set_property -dict {LOC G13  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[17]}]
#set_property -dict {LOC H13  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[18]}]
#set_property -dict {LOC H14  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[19]}]
#set_property -dict {LOC J11  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[20]}]
#set_property -dict {LOC J12  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[21]}]
#set_property -dict {LOC J15  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[22]}]
#set_property -dict {LOC J14  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[23]}]
#set_property -dict {LOC A14  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[24]}]
#set_property -dict {LOC C15  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[25]}]
#set_property -dict {LOC A15  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[26]}]
#set_property -dict {LOC B15  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[27]}]
#set_property -dict {LOC F15  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[28]}]
#set_property -dict {LOC E14  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[29]}]
#set_property -dict {LOC F14  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[30]}]
#set_property -dict {LOC F13  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[31]}]
#set_property -dict {LOC BM3  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[32]}]
#set_property -dict {LOC BM4  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[33]}]
#set_property -dict {LOC BM5  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[34]}]
#set_property -dict {LOC BL6  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[35]}]
#set_property -dict {LOC BN4  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[36]}]
#set_property -dict {LOC BN5  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[37]}]
#set_property -dict {LOC BN6  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[38]}]
#set_property -dict {LOC BN7  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[39]}]
#set_property -dict {LOC BJ9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[40]}]
#set_property -dict {LOC BK9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[41]}]
#set_property -dict {LOC BK10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[42]}]
#set_property -dict {LOC BL10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[43]}]
#set_property -dict {LOC BM9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[44]}]
#set_property -dict {LOC BN9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[45]}]
#set_property -dict {LOC BN10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[46]}]
#set_property -dict {LOC BM10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[47]}]
#set_property -dict {LOC BM15 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[48]}]
#set_property -dict {LOC BM14 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[49]}]
#set_property -dict {LOC BL15 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[50]}]
#set_property -dict {LOC BM13 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[51]}]
#set_property -dict {LOC BN12 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[52]}]
#set_property -dict {LOC BM12 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[53]}]
#set_property -dict {LOC BP13 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[54]}]
#set_property -dict {LOC BP14 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[55]}]
#set_property -dict {LOC BJ13 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[56]}]
#set_property -dict {LOC BJ12 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[57]}]
#set_property -dict {LOC BH15 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[58]}]
#set_property -dict {LOC BH14 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[59]}]
#set_property -dict {LOC BK14 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[60]}]
#set_property -dict {LOC BK15 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[61]}]
#set_property -dict {LOC BL12 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[62]}]
#set_property -dict {LOC BL13 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[63]}]
#set_property -dict {LOC BE9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[64]}]
#set_property -dict {LOC BE10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[65]}]
#set_property -dict {LOC BF10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[66]}]
#set_property -dict {LOC BE11 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[67]}]
#set_property -dict {LOC BG13 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[68]}]
#set_property -dict {LOC BG12 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[69]}]
#set_property -dict {LOC BG9  IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[70]}]
#set_property -dict {LOC BG10 IOSTANDARD POD12_DCI       } [get_ports {ddr4_c1_dq[71]}]
#set_property -dict {LOC B13  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[0]}]
#set_property -dict {LOC A13  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[0]}]
#set_property -dict {LOC C10  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[1]}]
#set_property -dict {LOC C9   IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[1]}]
#set_property -dict {LOC D10  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[2]}]
#set_property -dict {LOC D9   IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[2]}]
#set_property -dict {LOC H10  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[3]}]
#set_property -dict {LOC G10  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[3]}]
#set_property -dict {LOC H15  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[4]}]
#set_property -dict {LOC G15  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[4]}]
#set_property -dict {LOC K14  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[5]}]
#set_property -dict {LOC K13  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[5]}]
#set_property -dict {LOC D15  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[6]}]
#set_property -dict {LOC D14  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[6]}]
#set_property -dict {LOC E13  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[7]}]
#set_property -dict {LOC D12  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[7]}]
#set_property -dict {LOC BL7  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[8]}]
#set_property -dict {LOC BM7  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[8]}]
#set_property -dict {LOC BP7  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[9]}]
#set_property -dict {LOC BP6  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[9]}]
#set_property -dict {LOC BL8  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[10]}]
#set_property -dict {LOC BM8  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[10]}]
#set_property -dict {LOC BP9  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[11]}]
#set_property -dict {LOC BP8  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[11]}]
#set_property -dict {LOC BN15 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[12]}]
#set_property -dict {LOC BN14 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[12]}]
#set_property -dict {LOC BP12 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[13]}]
#set_property -dict {LOC BP11 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[13]}]
#set_property -dict {LOC BJ14 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[14]}]
#set_property -dict {LOC BK13 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[14]}]
#set_property -dict {LOC BJ11 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[15]}]
#set_property -dict {LOC BK11 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[15]}]
#set_property -dict {LOC BF12 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[16]}]
#set_property -dict {LOC BF11 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[16]}]
#set_property -dict {LOC BH10 IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_t[17]}]
#set_property -dict {LOC BH9  IOSTANDARD DIFF_POD12_DCI  } [get_ports {ddr4_c1_dqs_c[17]}]
