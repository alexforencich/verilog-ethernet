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
#set_property -dict {LOC A28 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports usb_uart_txd]
#set_property -dict {LOC B33 IOSTANDARD LVCMOS18} [get_ports usb_uart_rxd]

#set_false_path -to [get_ports {uart_txd}]
#set_output_delay 0 [get_ports {uart_txd}]
#set_false_path -from [get_ports {uart_rxd}]
#set_input_delay 0 [get_ports {uart_rxd}]

# HBM overtemp
set_property -dict {LOC D32 IOSTANDARD LVCMOS18} [get_ports hbm_cattrip]

set_false_path -to [get_ports {hbm_cattrip}]
set_output_delay 0 [get_ports {hbm_cattrip}]

# QSFP28 Interfaces
set_property -dict {LOC L53 } [get_ports qsfp0_rx1_p] ;# MGTYRXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L54 } [get_ports qsfp0_rx1_n] ;# MGTYRXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L48 } [get_ports qsfp0_tx1_p] ;# MGTYTXP0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L49 } [get_ports qsfp0_tx1_n] ;# MGTYTXN0_134 GTYE4_CHANNEL_X0Y40 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K51 } [get_ports qsfp0_rx2_p] ;# MGTYRXP1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K52 } [get_ports qsfp0_rx2_n] ;# MGTYRXN1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L44 } [get_ports qsfp0_tx2_p] ;# MGTYTXP1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC L45 } [get_ports qsfp0_tx2_n] ;# MGTYTXN1_134 GTYE4_CHANNEL_X0Y41 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J53 } [get_ports qsfp0_rx3_p] ;# MGTYRXP2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J54 } [get_ports qsfp0_rx3_n] ;# MGTYRXN2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K46 } [get_ports qsfp0_tx3_p] ;# MGTYTXP2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC K47 } [get_ports qsfp0_tx3_n] ;# MGTYTXN2_134 GTYE4_CHANNEL_X0Y42 / GTYE4_COMMON_X0Y10
set_property -dict {LOC H51 } [get_ports qsfp0_rx4_p] ;# MGTYRXP3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC H52 } [get_ports qsfp0_rx4_n] ;# MGTYRXN3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J48 } [get_ports qsfp0_tx4_p] ;# MGTYTXP3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
set_property -dict {LOC J49 } [get_ports qsfp0_tx4_n] ;# MGTYTXN3_134 GTYE4_CHANNEL_X0Y43 / GTYE4_COMMON_X0Y10
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

set_property -dict {LOC G53 } [get_ports qsfp1_rx1_p] ;# MGTYRXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G54 } [get_ports qsfp1_rx1_n] ;# MGTYRXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G48 } [get_ports qsfp1_tx1_p] ;# MGTYTXP0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC G49 } [get_ports qsfp1_tx1_n] ;# MGTYTXN0_135 GTYE4_CHANNEL_X0Y44 / GTYE4_COMMON_X0Y11
set_property -dict {LOC F51 } [get_ports qsfp1_rx2_p] ;# MGTYRXP1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC F52 } [get_ports qsfp1_rx2_n] ;# MGTYRXN1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E48 } [get_ports qsfp1_tx2_p] ;# MGTYTXP1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E49 } [get_ports qsfp1_tx2_n] ;# MGTYTXN1_135 GTYE4_CHANNEL_X0Y45 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E53 } [get_ports qsfp1_rx3_p] ;# MGTYRXP2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC E54 } [get_ports qsfp1_rx3_n] ;# MGTYRXN2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC C48 } [get_ports qsfp1_tx3_p] ;# MGTYTXP2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC C49 } [get_ports qsfp1_tx3_n] ;# MGTYTXN2_135 GTYE4_CHANNEL_X0Y46 / GTYE4_COMMON_X0Y11
set_property -dict {LOC D51 } [get_ports qsfp1_rx4_p] ;# MGTYRXP3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC D52 } [get_ports qsfp1_rx4_n] ;# MGTYRXN3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC A49 } [get_ports qsfp1_tx4_p] ;# MGTYTXP3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
set_property -dict {LOC A50 } [get_ports qsfp1_tx4_n] ;# MGTYTXN3_135 GTYE4_CHANNEL_X0Y47 / GTYE4_COMMON_X0Y11
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
