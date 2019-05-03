# XDC constraints for the Xilinx KC705 board
# part: xc7k325tffg900-2

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# System clocks
# 200 MHz
set_property -dict {LOC AD12 IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC AD11 IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs
set_property -dict {LOC AB8  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC AA8  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC AC9  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC AB9  IOSTANDARD LVCMOS15 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC AE26 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC G19  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC E18  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC F16  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

# Reset button
set_property -dict {LOC AB7  IOSTANDARD LVCMOS15} [get_ports reset]

# Push buttons
set_property -dict {LOC AA12 IOSTANDARD LVCMOS15} [get_ports btnu]
set_property -dict {LOC AC6  IOSTANDARD LVCMOS15} [get_ports btnl]
set_property -dict {LOC AB12 IOSTANDARD LVCMOS15} [get_ports btnd]
set_property -dict {LOC AG5  IOSTANDARD LVCMOS15} [get_ports btnr]
set_property -dict {LOC G12  IOSTANDARD LVCMOS25} [get_ports btnc]

# Toggle switches
set_property -dict {LOC Y29  IOSTANDARD LVCMOS25} [get_ports {sw[0]}]
set_property -dict {LOC W29  IOSTANDARD LVCMOS25} [get_ports {sw[1]}]
set_property -dict {LOC AA28 IOSTANDARD LVCMOS25} [get_ports {sw[2]}]
set_property -dict {LOC Y28  IOSTANDARD LVCMOS25} [get_ports {sw[3]}]

# UART
set_property -dict {LOC K24  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC M19  IOSTANDARD LVCMOS25} [get_ports uart_rxd]
set_property -dict {LOC L27  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports uart_rts]
set_property -dict {LOC K23  IOSTANDARD LVCMOS25} [get_ports uart_cts]

# Gigabit Ethernet GMII PHY
set_property -dict {LOC U27  IOSTANDARD LVCMOS25} [get_ports phy_rx_clk]
set_property -dict {LOC U30  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[0]}]
set_property -dict {LOC U25  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[1]}]
set_property -dict {LOC T25  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[2]}]
set_property -dict {LOC U28  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[3]}]
set_property -dict {LOC R19  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[4]}]
set_property -dict {LOC T27  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[5]}]
set_property -dict {LOC T26  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[6]}]
set_property -dict {LOC T28  IOSTANDARD LVCMOS25} [get_ports {phy_rxd[7]}]
set_property -dict {LOC R28  IOSTANDARD LVCMOS25} [get_ports phy_rx_dv]
set_property -dict {LOC V26  IOSTANDARD LVCMOS25} [get_ports phy_rx_er]
set_property -dict {LOC K30  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_gtx_clk]
set_property -dict {LOC M28  IOSTANDARD LVCMOS25} [get_ports phy_tx_clk]
set_property -dict {LOC N27  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
set_property -dict {LOC N25  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
set_property -dict {LOC M29  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}]
set_property -dict {LOC L28  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}]
set_property -dict {LOC J26  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[4]}]
set_property -dict {LOC K26  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[5]}]
set_property -dict {LOC L30  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[6]}]
set_property -dict {LOC J28  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[7]}]
set_property -dict {LOC M27  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_en]
set_property -dict {LOC N29  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_er]
set_property -dict {LOC L20  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
set_property -dict {LOC N30  IOSTANDARD LVCMOS25} [get_ports phy_int_n]
#set_property -dict {LOC J21  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {LOC R23  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]
create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

