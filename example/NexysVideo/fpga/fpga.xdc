# XDC constraints for the Digilent Nexys Video board
# part: xc7a200tsbg484-1

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# 100 MHz clock
set_property -dict {LOC R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk [get_ports clk]

# LEDs
set_property -dict {LOC T14 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC T15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC T16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC U16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC V15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC W16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC W15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC Y13 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC G4 IOSTANDARD LVCMOS15} [get_ports reset_n]

set_false_path -from [get_ports {reset_n}]
set_input_delay 0 [get_ports {reset_n}]

# Push buttons
set_property -dict {LOC F15 IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC C22 IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC D22 IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC D14 IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC B22 IOSTANDARD LVCMOS12} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# Toggle switches
set_property -dict {LOC E22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC F21 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC G21 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC G22 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property -dict {LOC H17 IOSTANDARD LVCMOS12} [get_ports {sw[4]}]
set_property -dict {LOC J16 IOSTANDARD LVCMOS12} [get_ports {sw[5]}]
set_property -dict {LOC K13 IOSTANDARD LVCMOS12} [get_ports {sw[6]}]
set_property -dict {LOC M17 IOSTANDARD LVCMOS12} [get_ports {sw[7]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC AA19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]

set_false_path -to [get_ports {uart_txd}]
set_output_delay 0 [get_ports {uart_txd}]
set_false_path -from [get_ports {uart_rxd}]
set_input_delay 0 [get_ports {uart_rxd}]

# Gigabit Ethernet RGMII PHY
set_property -dict {LOC V13 IOSTANDARD LVCMOS25} [get_ports phy_rx_clk]
set_property -dict {LOC AB16 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[0]}]
set_property -dict {LOC AA15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[1]}]
set_property -dict {LOC AB15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[2]}]
set_property -dict {LOC AB11 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[3]}]
set_property -dict {LOC W10 IOSTANDARD LVCMOS25} [get_ports phy_rx_ctl]
set_property -dict {LOC AA14 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_clk]
set_property -dict {LOC Y12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
set_property -dict {LOC W12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
set_property -dict {LOC W11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}]
set_property -dict {LOC Y11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}]
set_property -dict {LOC V10 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_ctl]
set_property -dict {LOC U7 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
set_property -dict {LOC Y14 IOSTANDARD LVCMOS25} [get_ports phy_int_n]
set_property -dict {LOC W14 IOSTANDARD LVCMOS25} [get_ports phy_pme_n]
#set_property -dict {LOC Y16  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {LOC AA16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]
set_false_path -from [get_ports {phy_int_n phy_pme_n}]
set_input_delay 0 [get_ports {phy_int_n phy_pme_n}]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]
