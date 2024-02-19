# XDC constraints for the Digilent Nexys Video board
# part: xc7a200tsbg484-1

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# 200 MHz clock
set_property -dict { PACKAGE_PIN AD11  IOSTANDARD LVDS     } [get_ports { sysclk_n }]; #IO_L12N_T1_MRCC_33 Sch=sysclk_n
set_property -dict { PACKAGE_PIN AD12  IOSTANDARD LVDS     } [get_ports { sysclk_p }]; #IO_L12P_T1_MRCC_33 Sch=sysclk_p
#Comment this out if you use clock wizard
#create_clock -period 5.000 -name clk [get_ports sysclk_p]
set_clock_groups -asynchronous -group [get_clocks clk -include_generated_clocks]

# LEDs 
set_property -dict {LOC T28 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC V19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC U30 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC U29 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC V20 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC V26 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC W24 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC W23 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

# Reset button
set_property -dict {LOC R19 IOSTANDARD LVCMOS33} [get_ports reset_n]

# Push buttons
set_property -dict {LOC B19 IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC M20 IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC M19 IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC C19 IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC E18 IOSTANDARD LVCMOS12} [get_ports btnc]

# Toggle switches
set_property -dict {LOC G19 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC G25 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC H24 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC K19 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property -dict {LOC N19 IOSTANDARD LVCMOS12} [get_ports {sw[4]}]
set_property -dict {LOC P19 IOSTANDARD LVCMOS12} [get_ports {sw[5]}]
set_property -dict {LOC P26 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {LOC P27 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]

# UART
set_property -dict {LOC Y23 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC Y20 IOSTANDARD LVCMOS33} [get_ports uart_rxd]

# Gigabit Ethernet RGMII PHY
set_property -dict {LOC AG10 IOSTANDARD LVCMOS15} [get_ports phy_rx_clk]
set_property -dict {LOC AJ14 IOSTANDARD LVCMOS15} [get_ports {phy_rxd[0]}]
set_property -dict {LOC AH14 IOSTANDARD LVCMOS15} [get_ports {phy_rxd[1]}]
set_property -dict {LOC AK13 IOSTANDARD LVCMOS15} [get_ports {phy_rxd[2]}]
set_property -dict {LOC AJ13 IOSTANDARD LVCMOS15} [get_ports {phy_rxd[3]}]
set_property -dict {LOC AH11 IOSTANDARD LVCMOS15} [get_ports phy_rx_ctl]
set_property -dict {LOC AE10 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports phy_tx_clk]
set_property -dict {LOC AJ12 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
set_property -dict {LOC AK11 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
set_property -dict {LOC AJ11 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}]
set_property -dict {LOC AK10 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}]
set_property -dict {LOC AK14 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports phy_tx_ctl]
set_property -dict {LOC AH24 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
set_property -dict {LOC AK16 IOSTANDARD LVCMOS18} [get_ports phy_int_n]
set_property -dict {LOC AK15 IOSTANDARD LVCMOS18} [get_ports phy_pme_n]
set_property -dict {LOC AG12 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
set_property -dict {LOC AF12 IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]
set_clock_groups -asynchronous -group [get_clocks phy_rx_clk -include_generated_clocks]

