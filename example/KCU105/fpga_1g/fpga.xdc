# XDC constraints for the Xilinx KCU105 board
# part: xcku040-ffva1156-2-e

# General configuration
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# 125 MHz
set_property -dict {LOC G10  IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC F10  IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]


# LEDs
set_property -dict {LOC AP8 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC H23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC P20 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC P21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC N22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC M22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC R23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC P23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AN8  IOSTANDARD LVCMOS18} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC AF8  IOSTANDARD LVCMOS18} [get_ports btnu]
set_property -dict {LOC AF9  IOSTANDARD LVCMOS18} [get_ports btnl]
set_property -dict {LOC AD10  IOSTANDARD LVCMOS18} [get_ports btnd]
set_property -dict {LOC AE8  IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict {LOC AE10 IOSTANDARD LVCMOS18} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC AN16  IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC AN19  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC AP18  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC AN14  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC K26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC G25 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC K27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rts]
set_property -dict {LOC L23 IOSTANDARD LVCMOS18} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0 [get_ports {uart_rxd uart_cts}]

# Gigabit Ethernet SGMII PHY
set_property -dict {LOC P24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_rx_p]
set_property -dict {LOC N24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_tx_p]
set_property -dict {LOC P26 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_clk_p]
set_property -dict {LOC J23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_reset_n]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]