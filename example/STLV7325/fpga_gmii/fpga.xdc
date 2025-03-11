# XDC constraints for the Xilinx KC705 board
# part: xc7k325tffg676-2

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets phy_tx_clk_IBUF]

# System clocks
# 200 MHz
set_property -dict {LOC AB11 IOSTANDARD LVDS} [get_ports clk_200mhz_p]
set_property -dict {LOC AC11 IOSTANDARD LVDS} [get_ports clk_200mhz_n]
create_clock -period 5.000 -name clk_200mhz [get_ports clk_200mhz_p]

# LEDs
set_property -dict {PACKAGE_PIN AA2  IOSTANDARD LVCMOS15} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN AD5  IOSTANDARD LVCMOS15} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN W10  IOSTANDARD LVCMOS15} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS15} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS15} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN W11  IOSTANDARD LVCMOS15} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN V11  IOSTANDARD LVCMOS15} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS15} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AC16 IOSTANDARD LVCMOS15} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# UART
set_property -dict {LOC M25 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC L25 IOSTANDARD LVCMOS25} [get_ports uart_rxd]

# Gigabit Ethernet GMII PHY
set_property -dict {LOC C12 IOSTANDARD LVCMOS25} [get_ports phy_rx_clk] ;# from U37.C1 RXCLK
set_property -dict {LOC H14 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[0]}] ;# from U37.B2 RXD0
set_property -dict {LOC J14 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[1]}] ;# from U37.D3 RXD1
set_property -dict {LOC J13 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[2]}] ;# from U37.C3 RXD2
set_property -dict {LOC H13 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[3]}] ;# from U37.B3 RXD3
set_property -dict {LOC B15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[4]}] ;# from U37.C4 RXD4
set_property -dict {LOC A15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[5]}] ;# from U37.A1 RXD5
set_property -dict {LOC B14 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[6]}] ;# from U37.A2 RXD6
set_property -dict {LOC A14 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[7]}] ;# from U37.C5 RXD7
set_property -dict {LOC G14 IOSTANDARD LVCMOS25} [get_ports phy_rx_dv] ;# from U37.B1 RXCTL_RXDV
set_property -dict {LOC F14 IOSTANDARD LVCMOS25} [get_ports phy_rx_er] ;# from U37.D4 RXER
set_property -dict {LOC F13 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_gtx_clk] ;# from U37.E2 TXC_GTXCLK
set_property -dict {LOC E12 IOSTANDARD LVCMOS25} [get_ports phy_tx_clk] ;# from U37.D1 TXCLK
set_property -dict {LOC G12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}] ;# from U37.F1 TXD0
set_property -dict {LOC E11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}] ;# from U37.G2 TXD1
set_property -dict {LOC G11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}] ;# from U37.G3 TXD2
set_property -dict {LOC C14 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}] ;# from U37.H1 TXD3
set_property -dict {LOC D14 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[4]}] ;# from U37.H2 TXD4
set_property -dict {LOC C13 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[5]}] ;# from U37.H3 TXD5
set_property -dict {LOC C11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[6]}] ;# from U37.J1 TXD6
set_property -dict {LOC D13 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[7]}] ;# from U37.J2 TXD7
set_property -dict {LOC F12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_en] ;# from U37.E1 TXCTL_TXEN
set_property -dict {LOC E13 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_er] ;# from U37.F2 TXER
set_property -dict {LOC D11  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_reset_n] ;# from U37.K3 RESET_B

create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]
create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]
