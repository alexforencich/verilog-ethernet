# XDC constraints for the Xilinx KC705 board
# part: xc7k325tffg900-2

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
#set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

# System clocks
# 200 MHz
set_property -dict {LOC E19 IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC E18 IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs
set_property -dict {LOC AM39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC AN39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC AR37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC AT37 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC AR35 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC AP41 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC AP42 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC AU39 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AV40 IOSTANDARD LVCMOS18} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# UART
set_property -dict {LOC AU36 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC AU33 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC AT32 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports uart_rts]
set_property -dict {LOC AR34 IOSTANDARD LVCMOS18} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0 [get_ports {uart_rxd uart_cts}]

set_property -dict {LOC AM8  } [get_ports phy_sgmii_rx_p] ;# MGTXRXP1_117 GTXE2_CHANNEL_X0Y9 / GTXE2_COMMON_X0Y2 from U37.A7 SOUT_P
#set_property -dict {LOC AM7  } [get_ports phy_sgmii_rx_n] ;# MGTXRXN1_117 GTXE2_CHANNEL_X0Y9 / GTXE2_COMMON_X0Y2 from U37.A8 SOUT_N
set_property -dict {LOC AN2  } [get_ports phy_sgmii_tx_p] ;# MGTXTXP1_117 GTXE2_CHANNEL_X0Y9 / GTXE2_COMMON_X0Y2 from U37.A3 SIN_P
#set_property -dict {LOC AN1   } [get_ports phy_sgmii_tx_n] ;# MGTXTXN1_117 GTXE2_CHANNEL_X0Y9 / GTXE2_COMMON_X0Y2 from U37.A4 SIN_N
set_property -dict {LOC AH8  } [get_ports phy_sgmii_clk_p] ;# MGTREFCLK0P_117 from U2.7
#set_property -dict {LOC AH7   } [get_ports phy_sgmii_clk_n] ;# MGTREFCLK0N_117 from U2.6
set_property -dict {LOC AJ33 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports phy_reset_n] ;# from U37.K3 RESET_B
set_property -dict {LOC AL31  IOSTANDARD LVCMOS18} [get_ports phy_int_n] ;# from U37.L1 INT_B
#set_property -dict {LOC AK33  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports phy_mdio] ;# from U37.M1 MDIO
#set_property -dict {LOC AH31  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports phy_mdc] ;# from U37.L3 MDC

#create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]
#create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]
create_clock -period 8.000 -name phy_sgmii_clk [get_ports phy_sgmii_clk_p]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]
set_false_path -from [get_ports {phy_int_n}]
set_input_delay 0 [get_ports {phy_int_n}]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]
