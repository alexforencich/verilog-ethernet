# XDC constraints for the Digilent Nexys Video board
# part: xc7a200tfbg484-2

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# differential clock
set_property -dict {PACKAGE_PIN R4 IOSTANDARD DIFF_SSTL15} [get_ports clk_p]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD DIFF_SSTL15} [get_ports clk_n]
create_clock -period 5.000 -name clk [get_ports clk_p]

# Reset button
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS15} [get_ports reset_n]

set_false_path -from [get_ports reset_n]
set_input_delay 0.000 [get_ports reset_n]


# Gigabit Ethernet RGMII PHY
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports phy_rx_clk]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[0]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[1]}]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[2]}]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[3]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports phy_rx_ctl]

set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports phy_tx_clk]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports phy_tx_ctl]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdc]
#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0.000 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports phy_mdio]
#set_input_delay 0.000 [get_ports phy_mdio]
#set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS25} [get_ports phy_int_n]
#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS25} [get_ports phy_pme_n]
#set_false_path -from [get_ports {phy_int_n phy_pme_n}]
#set_input_delay 0 [get_ports {phy_int_n phy_pme_n}]

set_false_path -to [get_ports phy_reset_n]
set_output_delay 0.000 [get_ports phy_reset_n]


#new

