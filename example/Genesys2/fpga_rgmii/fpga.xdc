# XDC constraints for the Digilent Genesys 2 Rev. H board
# part: xc7k325tffg900-2

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# System clocks
# 200 MHz
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs
set_property -dict {PACKAGE_PIN T28  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN V19  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN U30  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN U29  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN V20  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN V26  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN W24  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN W23  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {PACKAGE_PIN R19   IOSTANDARD LVCMOS33} [get_ports reset_n]

set_false_path -from [get_ports {reset_n}]
set_input_delay 0 [get_ports {reset_n}]

# Push buttons
set_property -dict {PACKAGE_PIN B19   IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {PACKAGE_PIN M20   IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {PACKAGE_PIN M19   IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {PACKAGE_PIN C19   IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {PACKAGE_PIN E18   IOSTANDARD LVCMOS12} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# Toggle switches
set_property -dict {PACKAGE_PIN G19   IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN G25   IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN H24   IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN K19   IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {PACKAGE_PIN Y23   IOSTANDARD LVCMOS33} [get_ports uart_txd]
set_property -dict {PACKAGE_PIN Y20   IOSTANDARD LVCMOS33} [get_ports uart_rxd]

# Gigabit Ethernet GMII PHY
set_property -dict {PACKAGE_PIN AG10  IOSTANDARD LVCMOS15                   } [get_ports { phy_rx_clk }]
set_property -dict {PACKAGE_PIN AJ14  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[0] }]
set_property -dict {PACKAGE_PIN AH14  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[1] }]
set_property -dict {PACKAGE_PIN AK13  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[2] }]
set_property -dict {PACKAGE_PIN AJ13  IOSTANDARD LVCMOS15                   } [get_ports { phy_rxd[3] }]
set_property -dict {PACKAGE_PIN AH11  IOSTANDARD LVCMOS15                   } [get_ports { phy_rx_ctl }]
set_property -dict {PACKAGE_PIN AE10  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_tx_clk }]
set_property -dict {PACKAGE_PIN AJ12  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[0] }]
set_property -dict {PACKAGE_PIN AK11  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[1] }]
set_property -dict {PACKAGE_PIN AJ11  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[2] }]
set_property -dict {PACKAGE_PIN AK10  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_txd[3] }]
set_property -dict {PACKAGE_PIN AK14  IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports { phy_tx_ctl }]
set_property -dict {PACKAGE_PIN AH24  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports { phy_reset_n }]
set_property -dict {PACKAGE_PIN AK16  IOSTANDARD LVCMOS18                   } [get_ports { phy_int_n }]
#set_property -dict {PACKAGE_PIN AK15 IOSTANDARD LVCMOS18} [get_ports phy_pme_n]
#set_property -dict {PACKAGE_PIN AG12  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {PACKAGE_PIN AF12  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

#create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]
create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]
set_false_path -from [get_ports {phy_int_n}]
set_input_delay 0 [get_ports {phy_int_n}]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]
