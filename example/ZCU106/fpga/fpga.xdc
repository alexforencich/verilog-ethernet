# XDC constraints for the Xilinx ZCU106 board
# part: xczu7ev-ffvc1156-2-e

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
# 125 MHz
set_property -dict {LOC H9  IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC G9  IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# LEDs
set_property -dict {LOC AL11 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AL13 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AK13 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC AE15 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC AM8  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AM9  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AM10 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC AM11 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC G13  IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC AG13 IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC AK12 IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC AP20 IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC AC14 IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC AL10 IOSTANDARD LVCMOS12} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC A17  IOSTANDARD LVCMOS18} [get_ports {sw[0]}]
set_property -dict {LOC A16  IOSTANDARD LVCMOS18} [get_ports {sw[1]}]
set_property -dict {LOC B16  IOSTANDARD LVCMOS18} [get_ports {sw[2]}]
set_property -dict {LOC B15  IOSTANDARD LVCMOS18} [get_ports {sw[3]}]
set_property -dict {LOC A15  IOSTANDARD LVCMOS18} [get_ports {sw[4]}]
set_property -dict {LOC A14  IOSTANDARD LVCMOS18} [get_ports {sw[5]}]
set_property -dict {LOC B14  IOSTANDARD LVCMOS18} [get_ports {sw[6]}]
set_property -dict {LOC B13  IOSTANDARD LVCMOS18} [get_ports {sw[7]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC AL17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC AH17 IOSTANDARD LVCMOS12} [get_ports uart_rxd]
set_property -dict {LOC AM15 IOSTANDARD LVCMOS12} [get_ports uart_rts]
set_property -dict {LOC AP17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_cts}]
set_output_delay 0 [get_ports {uart_txd uart_cts}]
set_false_path -from [get_ports {uart_rxd uart_rts}]
set_input_delay 0 [get_ports {uart_rxd uart_rts}]

# I2C interfaces
#set_property -dict {LOC AE19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c0_scl]
#set_property -dict {LOC AH23 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c0_sda]
#set_property -dict {LOC AH19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c1_scl]
#set_property -dict {LOC AL21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c1_sda]

#set_false_path -to [get_ports {i2c1_sda i2c1_scl}]
#set_output_delay 0 [get_ports {i2c1_sda i2c1_scl}]
#set_false_path -from [get_ports {i2c1_sda i2c1_scl}]
#set_input_delay 0 [get_ports {i2c1_sda i2c1_scl}]

# SFP+ Interface
set_property -dict {LOC AA2 } [get_ports sfp0_rx_p] ;# MGTHRXP2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC AA1 } [get_ports sfp0_rx_n] ;# MGTHRXN2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC Y4  } [get_ports sfp0_tx_p] ;# MGTHTXP2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC Y3  } [get_ports sfp0_tx_n] ;# MGTHTXN2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W2  } [get_ports sfp1_rx_p] ;# MGTHRXP3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W1  } [get_ports sfp1_rx_n] ;# MGTHRXN3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W6  } [get_ports sfp1_tx_p] ;# MGTHTXP3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W5  } [get_ports sfp1_tx_n] ;# MGTHTXN3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC U10 } [get_ports sfp_mgt_refclk_0_p] ;# MGTREFCLK1P_226 from U56 SI570 via U51 SI53340
set_property -dict {LOC U9  } [get_ports sfp_mgt_refclk_0_n] ;# MGTREFCLK1N_226 from U56 SI570 via U51 SI53340
#set_property -dict {LOC W10 } [get_ports sfp_mgt_refclk_1_p] ;# MGTREFCLK1P_225 from U20 CKOUT2 SI5328
#set_property -dict {LOC W9  } [get_ports sfp_mgt_refclk_1_n] ;# MGTREFCLK1N_225 from U20 CKOUT2 SI5328
#set_property -dict {LOC H11 IOSTANDARD LVDS} [get_ports sfp_recclk_p] ;# to U20 CKIN1 SI5328
#set_property -dict {LOC G11 IOSTANDARD LVDS} [get_ports sfp_recclk_n] ;# to U20 CKIN1 SI5328
set_property -dict {LOC AE22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports sfp0_tx_disable_b]
set_property -dict {LOC AF20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports sfp1_tx_disable_b]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name sfp_mgt_refclk_0 [get_ports sfp_mgt_refclk_0_p]

set_false_path -to [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b}]
set_output_delay 0 [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b}]

# PCIe Interface
#set_property -dict {LOC AE2 } [get_ports {pcie_rx_p[0]}] ;# MGTHRXP3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE1 } [get_ports {pcie_rx_n[0]}] ;# MGTHRXN3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AD4 } [get_ports {pcie_tx_p[0]}] ;# MGTHTXP3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AD3 } [get_ports {pcie_tx_n[0]}] ;# MGTHTXN3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AF4 } [get_ports {pcie_rx_p[1]}] ;# MGTHRXP2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AF3 } [get_ports {pcie_rx_n[1]}] ;# MGTHRXN2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE6 } [get_ports {pcie_tx_p[1]}] ;# MGTHTXP2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE5 } [get_ports {pcie_tx_n[1]}] ;# MGTHTXN2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG2 } [get_ports {pcie_rx_p[2]}] ;# MGTHRXP1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG1 } [get_ports {pcie_rx_n[2]}] ;# MGTHRXN1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG6 } [get_ports {pcie_tx_p[2]}] ;# MGTHTXP1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG5 } [get_ports {pcie_tx_n[2]}] ;# MGTHTXN1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AJ2 } [get_ports {pcie_rx_p[3]}] ;# MGTHRXP0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AJ1 } [get_ports {pcie_rx_n[3]}] ;# MGTHRXN0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AH4 } [get_ports {pcie_tx_p[3]}] ;# MGTHTXP0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AH3 } [get_ports {pcie_tx_n[3]}] ;# MGTHTXN0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AB8 } [get_ports pcie_mgt_refclk_p] ;# MGTREFCLK0P_224
#set_property -dict {LOC AB7 } [get_ports pcie_mgt_refclk_n] ;# MGTREFCLK0N_224
#set_property -dict {LOC L8  IOSTANDARD LVCMOS33 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_mgt_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]


