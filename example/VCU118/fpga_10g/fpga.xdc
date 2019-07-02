# XDC constraints for the Xilinx VCU118 board
# part: xcvu9p-flga2104-2L-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]

# System clocks
# 300 MHz
#set_property -dict {LOC G31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_p]
#set_property -dict {LOC F31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_n]
#create_clock -period 3.333 -name clk_300mhz [get_ports clk_300mhz_p]

# 250 MHz
#set_property -dict {LOC E12  IOSTANDARD DIFF_SSTL12} [get_ports clk_250mhz_1_p]
#set_property -dict {LOC D12  IOSTANDARD DIFF_SSTL12} [get_ports clk_250mhz_1_n]
#create_clock -period 4 -name clk_250mhz_1 [get_ports clk_250mhz_1_p]

#set_property -dict {LOC AW26 IOSTANDARD DIFF_SSTL12} [get_ports clk_250mhz_2_p]
#set_property -dict {LOC AW27 IOSTANDARD DIFF_SSTL12} [get_ports clk_250mhz_2_n]
#create_clock -period 4 -name clk_250mhz_2 [get_ports clk_250mhz_2_p]

# 125 MHz
set_property -dict {LOC AY24 IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC AY23 IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# 90 MHz
#set_property -dict {LOC AL20 IOSTANDARD LVCMOS18} [get_ports clk_90mhz]
#create_clock -period 11.111 -name clk_90mhz [get_ports clk_90mhz]

# LEDs
set_property -dict {LOC AT32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AV34 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AY30 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC BB32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC BF32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AU37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AV36 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC BA37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

# Reset button
set_property -dict {LOC L19  IOSTANDARD LVCMOS12} [get_ports reset]

# Push buttons
set_property -dict {LOC BB24 IOSTANDARD LVCMOS18} [get_ports btnu]
set_property -dict {LOC BF22 IOSTANDARD LVCMOS18} [get_ports btnl]
set_property -dict {LOC BE22 IOSTANDARD LVCMOS18} [get_ports btnd]
set_property -dict {LOC BE23 IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict {LOC BD23 IOSTANDARD LVCMOS18} [get_ports btnc]

# DIP switches
set_property -dict {LOC B17  IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC G16  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC J16  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC D21  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

# UART
set_property -dict {LOC BB21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC AW25 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC BB22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rts]
set_property -dict {LOC AY25 IOSTANDARD LVCMOS18} [get_ports uart_cts]

# Gigabit Ethernet SGMII PHY
set_property -dict {LOC AU24 IOSTANDARD LVDS} [get_ports phy_sgmii_rx_p]
set_property -dict {LOC AV24 IOSTANDARD LVDS} [get_ports phy_sgmii_rx_n]
set_property -dict {LOC AU21 IOSTANDARD LVDS} [get_ports phy_sgmii_tx_p]
set_property -dict {LOC AV21 IOSTANDARD LVDS} [get_ports phy_sgmii_tx_n]
set_property -dict {LOC AT22 IOSTANDARD LVDS} [get_ports phy_sgmii_clk_p]
set_property -dict {LOC AU22 IOSTANDARD LVDS} [get_ports phy_sgmii_clk_n]
set_property -dict {LOC BA21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_reset_n]
set_property -dict {LOC AR24 IOSTANDARD LVCMOS18} [get_ports phy_int_n]
set_property -dict {LOC AR23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdio]
set_property -dict {LOC AV23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdc]

# 625 MHz ref clock from SGMII PHY
#create_clock -period 1.600 -name phy_sgmii_clk [get_ports phy_sgmii_clk_p]

# QSFP28 Interfaces
set_property -dict {LOC V7  } [get_ports qsfp1_tx1_p] ;# MGTYTXN0_231 GTYE3_CHANNEL_X1Y48 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC V6  } [get_ports qsfp1_tx1_n] ;# MGTYTXP0_231 GTYE3_CHANNEL_X1Y48 / GTYE3_COMMON_X1Y12
set_property -dict {LOC Y2  } [get_ports qsfp1_rx1_p] ;# MGTYTXN1_231 GTYE3_CHANNEL_X1Y48 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC Y1  } [get_ports qsfp1_rx1_n] ;# MGTYTXP1_231 GTYE3_CHANNEL_X1Y48 / GTYE3_COMMON_X1Y12
set_property -dict {LOC T7  } [get_ports qsfp1_tx2_p] ;# MGTYTXN2_231 GTYE3_CHANNEL_X1Y49 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC T6  } [get_ports qsfp1_tx2_n] ;# MGTYTXP2_231 GTYE3_CHANNEL_X1Y49 / GTYE3_COMMON_X1Y12
set_property -dict {LOC W4  } [get_ports qsfp1_rx2_p] ;# MGTYTXN3_231 GTYE3_CHANNEL_X1Y49 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC W3  } [get_ports qsfp1_rx2_n] ;# MGTYTXP3_231 GTYE3_CHANNEL_X1Y49 / GTYE3_COMMON_X1Y12
set_property -dict {LOC P7  } [get_ports qsfp1_tx3_p] ;# MGTYTXN0_231 GTYE3_CHANNEL_X1Y50 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC P6  } [get_ports qsfp1_tx3_n] ;# MGTYTXP0_231 GTYE3_CHANNEL_X1Y50 / GTYE3_COMMON_X1Y12
set_property -dict {LOC V2  } [get_ports qsfp1_rx3_p] ;# MGTYTXN1_231 GTYE3_CHANNEL_X1Y50 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC V1  } [get_ports qsfp1_rx3_n] ;# MGTYTXP1_231 GTYE3_CHANNEL_X1Y50 / GTYE3_COMMON_X1Y12
set_property -dict {LOC M7  } [get_ports qsfp1_tx4_p] ;# MGTYTXN2_231 GTYE3_CHANNEL_X1Y51 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC M6  } [get_ports qsfp1_tx4_n] ;# MGTYTXP2_231 GTYE3_CHANNEL_X1Y51 / GTYE3_COMMON_X1Y12
set_property -dict {LOC U4  } [get_ports qsfp1_rx4_p] ;# MGTYTXN3_231 GTYE3_CHANNEL_X1Y51 / GTYE3_COMMON_X1Y12
#set_property -dict {LOC U3  } [get_ports qsfp1_rx4_n] ;# MGTYTXP3_231 GTYE3_CHANNEL_X1Y51 / GTYE3_COMMON_X1Y12
set_property -dict {LOC W9  } [get_ports qsfp1_mgt_refclk_0_p] ;# MGTREFCLK0P_231 from U38.4
#set_property -dict {LOC W8  } [get_ports qsfp1_mgt_refclk_0_n] ;# MGTREFCLK0N_231 from U38.5
#set_property -dict {LOC U9  } [get_ports qsfp1_mgt_refclk_1_p] ;# MGTREFCLK1P_231 from U57.28
#set_property -dict {LOC U8  } [get_ports qsfp1_mgt_refclk_1_n] ;# MGTREFCLK1N_231 from U57.29
#set_property -dict {LOC AM23 IOSTANDARD LVDS} [get_ports qsfp1_recclk_p] ;# to U57.16
#set_property -dict {LOC AM22 IOSTANDARD LVDS} [get_ports qsfp1_recclk_n] ;# to U57.17
set_property -dict {LOC AM21 IOSTANDARD LVCMOS18} [get_ports qsfp1_modsell]
set_property -dict {LOC BA22 IOSTANDARD LVCMOS18} [get_ports qsfp1_resetl]
set_property -dict {LOC AL21 IOSTANDARD LVCMOS18} [get_ports qsfp1_modprsl]
set_property -dict {LOC AP21 IOSTANDARD LVCMOS18} [get_ports qsfp1_intl]
set_property -dict {LOC AN21 IOSTANDARD LVCMOS18} [get_ports qsfp1_lpmode]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name qsfp1_mgt_refclk_0 [get_ports qsfp1_mgt_refclk_0_p]

set_property -dict {LOC L5  } [get_ports qsfp2_tx1_p] ;# MGTYTXN0_232 GTYE3_CHANNEL_X1Y52 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC L4  } [get_ports qsfp2_tx1_n] ;# MGTYTXP0_232 GTYE3_CHANNEL_X1Y52 / GTYE3_COMMON_X1Y13
set_property -dict {LOC T2  } [get_ports qsfp2_rx1_p] ;# MGTYTXN1_232 GTYE3_CHANNEL_X1Y52 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC T1  } [get_ports qsfp2_rx1_n] ;# MGTYTXP1_232 GTYE3_CHANNEL_X1Y52 / GTYE3_COMMON_X1Y13
set_property -dict {LOC K7  } [get_ports qsfp2_tx2_p] ;# MGTYTXN2_232 GTYE3_CHANNEL_X1Y53 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC K6  } [get_ports qsfp2_tx2_n] ;# MGTYTXP2_232 GTYE3_CHANNEL_X1Y53 / GTYE3_COMMON_X1Y13
set_property -dict {LOC R4  } [get_ports qsfp2_rx2_p] ;# MGTYTXN3_232 GTYE3_CHANNEL_X1Y53 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC R3  } [get_ports qsfp2_rx2_n] ;# MGTYTXP3_232 GTYE3_CHANNEL_X1Y53 / GTYE3_COMMON_X1Y13
set_property -dict {LOC J5  } [get_ports qsfp2_tx3_p] ;# MGTYTXN0_232 GTYE3_CHANNEL_X1Y54 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC J4  } [get_ports qsfp2_tx3_n] ;# MGTYTXP0_232 GTYE3_CHANNEL_X1Y54 / GTYE3_COMMON_X1Y13
set_property -dict {LOC P2  } [get_ports qsfp2_rx3_p] ;# MGTYTXN1_232 GTYE3_CHANNEL_X1Y54 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC P1  } [get_ports qsfp2_rx3_n] ;# MGTYTXP1_232 GTYE3_CHANNEL_X1Y54 / GTYE3_COMMON_X1Y13
set_property -dict {LOC H7  } [get_ports qsfp2_tx4_p] ;# MGTYTXN2_232 GTYE3_CHANNEL_X1Y55 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC H6  } [get_ports qsfp2_tx4_n] ;# MGTYTXP2_232 GTYE3_CHANNEL_X1Y55 / GTYE3_COMMON_X1Y13
set_property -dict {LOC M2  } [get_ports qsfp2_rx4_p] ;# MGTYTXN3_232 GTYE3_CHANNEL_X1Y55 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC M1  } [get_ports qsfp2_rx4_n] ;# MGTYTXP3_232 GTYE3_CHANNEL_X1Y55 / GTYE3_COMMON_X1Y13
#set_property -dict {LOC R9  } [get_ports qsfp2_mgt_refclk_0_p] ;# MGTREFCLK0P_232 from U104.13
#set_property -dict {LOC R8  } [get_ports qsfp2_mgt_refclk_0_n] ;# MGTREFCLK0N_232 from U104.14
#set_property -dict {LOC N9  } [get_ports qsfp2_mgt_refclk_1_p] ;# MGTREFCLK1P_232 from U57.35
#set_property -dict {LOC N8  } [get_ports qsfp2_mgt_refclk_1_n] ;# MGTREFCLK1N_232 from U57.34
#set_property -dict {LOC AP23 IOSTANDARD LVDS} [get_ports qsfp2_recclk_p] ;# to U57.12
#set_property -dict {LOC AP22 IOSTANDARD LVDS} [get_ports qsfp2_recclk_n] ;# to U57.13
set_property -dict {LOC AN23 IOSTANDARD LVCMOS18} [get_ports qsfp2_modsell]
set_property -dict {LOC AY22 IOSTANDARD LVCMOS18} [get_ports qsfp2_resetl]
set_property -dict {LOC AN24 IOSTANDARD LVCMOS18} [get_ports qsfp2_modprsl]
set_property -dict {LOC AT21 IOSTANDARD LVCMOS18} [get_ports qsfp2_intl]
set_property -dict {LOC AT24 IOSTANDARD LVCMOS18} [get_ports qsfp2_lpmode]

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name qsfp2_mgt_refclk_0 [get_ports qsfp2_mgt_refclk_0_p]

# I2C interface
set_property -dict {LOC AM24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC AL24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_sda]


