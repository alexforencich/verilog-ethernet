# XDC constraints for the Digilent Arty board
# part: xc7a35t-csg324-1

# General configuration
set_property CFGBVS VCCO                               [current_design]
set_property CONFIG_VOLTAGE 3.3                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# 100 MHz clock
set_property -dict {LOC E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk [get_ports clk]

# LEDs
set_property -dict {LOC G6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_r]
set_property -dict {LOC F6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_g]
set_property -dict {LOC E1   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_b]
set_property -dict {LOC G3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_r]
set_property -dict {LOC J4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_g]
set_property -dict {LOC G4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_b]
set_property -dict {LOC J3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_r]
set_property -dict {LOC J2   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_g]
set_property -dict {LOC H4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_b]
set_property -dict {LOC K1   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_r]
set_property -dict {LOC H6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_g]
set_property -dict {LOC K2   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_b]
set_property -dict {LOC H5   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led4]
set_property -dict {LOC J5   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led5]
set_property -dict {LOC T9   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led6]
set_property -dict {LOC T10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led7]

# Reset button
set_property -dict {LOC C2   IOSTANDARD LVCMOS33} [get_ports reset_n]

# Push buttons
set_property -dict {LOC D9   IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {LOC C9   IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {LOC B9   IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {LOC B8   IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

# Toggle switches
set_property -dict {LOC A8   IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {LOC C11  IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {LOC C10  IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {LOC A10  IOSTANDARD LVCMOS33} [get_ports {sw[3]}]

# UART
set_property -dict {LOC D10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC A9   IOSTANDARD LVCMOS33} [get_ports uart_rxd]

# Ethernet MII PHY
set_property -dict {LOC F15  IOSTANDARD LVCMOS33} [get_ports phy_rx_clk]
set_property -dict {LOC D18  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[0]}]
set_property -dict {LOC E17  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[1]}]
set_property -dict {LOC E18  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[2]}]
set_property -dict {LOC G17  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[3]}]
set_property -dict {LOC G16  IOSTANDARD LVCMOS33} [get_ports phy_rx_dv]
set_property -dict {LOC C17  IOSTANDARD LVCMOS33} [get_ports phy_rx_er]
set_property -dict {LOC H16  IOSTANDARD LVCMOS33} [get_ports phy_tx_clk]
set_property -dict {LOC H14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[0]}]
set_property -dict {LOC J14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[1]}]
set_property -dict {LOC J13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[2]}]
set_property -dict {LOC H17  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[3]}]
set_property -dict {LOC H15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports phy_tx_en]
set_property -dict {LOC D17  IOSTANDARD LVCMOS33} [get_ports phy_col]
set_property -dict {LOC G14  IOSTANDARD LVCMOS33} [get_ports phy_crs]
set_property -dict {LOC G18  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_ref_clk]
set_property -dict {LOC C16  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
#set_property -dict {LOC K13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {LOC F16  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 40.000 -name phy_rx_clk [get_ports phy_rx_clk]
create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]

