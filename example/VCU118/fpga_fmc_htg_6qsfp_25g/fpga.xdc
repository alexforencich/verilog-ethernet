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
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

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

# User SMA clock J34/J35
#set_property -dict {LOC R32 IOSTANDARD LVDS} [get_ports user_sma_clk_p]
#set_property -dict {LOC P32 IOSTANDARD LVDS} [get_ports user_sma_clk_n]
#create_clock -period 8.000 -name user_sma_clk [get_ports user_sma_clk_p]

# LEDs
set_property -dict {LOC AT32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AV34 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AY30 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC BB32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC BF32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AU37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AV36 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC BA37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC L19  IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC BB24 IOSTANDARD LVCMOS18} [get_ports btnu]
set_property -dict {LOC BF22 IOSTANDARD LVCMOS18} [get_ports btnl]
set_property -dict {LOC BE22 IOSTANDARD LVCMOS18} [get_ports btnd]
set_property -dict {LOC BE23 IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict {LOC BD23 IOSTANDARD LVCMOS18} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC B17  IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC G16  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC J16  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC D21  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# PMOD0
#set_property -dict {LOC AY14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[0]}]
#set_property -dict {LOC AY15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[1]}]
#set_property -dict {LOC AW15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[2]}]
#set_property -dict {LOC AV15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[3]}]
#set_property -dict {LOC AV16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[4]}]
#set_property -dict {LOC AU16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[5]}]
#set_property -dict {LOC AT15 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[6]}]
#set_property -dict {LOC AT16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[7]}]

#set_false_path -to [get_ports {pmod0[*]}]
#set_output_delay 0 [get_ports {pmod0[*]}]

# PMOD1
#set_property -dict {LOC N28  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[0]}]
#set_property -dict {LOC M30  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[1]}]
#set_property -dict {LOC N30  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[2]}]
#set_property -dict {LOC P30  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[3]}]
#set_property -dict {LOC P29  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[4]}]
#set_property -dict {LOC L31  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[5]}]
#set_property -dict {LOC M31  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[6]}]
#set_property -dict {LOC R29  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[7]}]

#set_false_path -to [get_ports {pmod1[*]}]
#set_output_delay 0 [get_ports {pmod1[*]}]

# UART
set_property -dict {LOC BB21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC AW25 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC BB22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rts]
set_property -dict {LOC AY25 IOSTANDARD LVCMOS18} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0 [get_ports {uart_rxd uart_cts}]

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

set_false_path -to [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_output_delay 0 [get_ports {phy_reset_n phy_mdio phy_mdc}]
set_false_path -from [get_ports {phy_int_n phy_mdio}]
set_input_delay 0 [get_ports {phy_int_n phy_mdio}]

# QSFP28 Interfaces
set_property -dict {LOC Y2  } [get_ports {qsfp1_rx_p[0]}] ;# MGTYRXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC Y1  } [get_ports {qsfp1_rx_n[0]}] ;# MGTYRXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC V7  } [get_ports {qsfp1_tx_p[0]}] ;# MGTYTXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC V6  } [get_ports {qsfp1_tx_n[0]}] ;# MGTYTXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC W4  } [get_ports {qsfp1_rx_p[1]}] ;# MGTYRXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC W3  } [get_ports {qsfp1_rx_n[1]}] ;# MGTYRXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC T7  } [get_ports {qsfp1_tx_p[1]}] ;# MGTYTXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC T6  } [get_ports {qsfp1_tx_n[1]}] ;# MGTYTXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC V2  } [get_ports {qsfp1_rx_p[2]}] ;# MGTYRXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC V1  } [get_ports {qsfp1_rx_n[2]}] ;# MGTYRXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC P7  } [get_ports {qsfp1_tx_p[2]}] ;# MGTYTXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC P6  } [get_ports {qsfp1_tx_n[2]}] ;# MGTYTXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC U4  } [get_ports {qsfp1_rx_p[3]}] ;# MGTYRXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC U3  } [get_ports {qsfp1_rx_n[3]}] ;# MGTYRXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M7  } [get_ports {qsfp1_tx_p[3]}] ;# MGTYTXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M6  } [get_ports {qsfp1_tx_n[3]}] ;# MGTYTXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC W9  } [get_ports qsfp1_mgt_refclk_0_p] ;# MGTREFCLK0P_231 from U38.4
set_property -dict {LOC W8  } [get_ports qsfp1_mgt_refclk_0_n] ;# MGTREFCLK0N_231 from U38.5
#set_property -dict {LOC U9  } [get_ports qsfp1_mgt_refclk_1_p] ;# MGTREFCLK1P_231 from U57.28
#set_property -dict {LOC U8  } [get_ports qsfp1_mgt_refclk_1_n] ;# MGTREFCLK1N_231 from U57.29
#set_property -dict {LOC AM23 IOSTANDARD LVDS} [get_ports qsfp1_recclk_p] ;# to U57.16
#set_property -dict {LOC AM22 IOSTANDARD LVDS} [get_ports qsfp1_recclk_n] ;# to U57.17
set_property -dict {LOC AM21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp1_modsell]
set_property -dict {LOC BA22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp1_resetl]
set_property -dict {LOC AL21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp1_modprsl]
set_property -dict {LOC AP21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp1_intl]
set_property -dict {LOC AN21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp1_lpmode]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name qsfp1_mgt_refclk_0 [get_ports qsfp1_mgt_refclk_0_p]

set_false_path -to [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode}]
set_output_delay 0 [get_ports {qsfp1_modsell qsfp1_resetl qsfp1_lpmode}]
set_false_path -from [get_ports {qsfp1_modprsl qsfp1_intl}]
set_input_delay 0 [get_ports {qsfp1_modprsl qsfp1_intl}]

set_property -dict {LOC T2  } [get_ports {qsfp2_rx_p[0]}] ;# MGTYRXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC T1  } [get_ports {qsfp2_rx_n[0]}] ;# MGTYRXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC L5  } [get_ports {qsfp2_tx_p[0]}] ;# MGTYTXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC L4  } [get_ports {qsfp2_tx_n[0]}] ;# MGTYTXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC R4  } [get_ports {qsfp2_rx_p[1]}] ;# MGTYRXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC R3  } [get_ports {qsfp2_rx_n[1]}] ;# MGTYRXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC K7  } [get_ports {qsfp2_tx_p[1]}] ;# MGTYTXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC K6  } [get_ports {qsfp2_tx_n[1]}] ;# MGTYTXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC P2  } [get_ports {qsfp2_rx_p[2]}] ;# MGTYRXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC P1  } [get_ports {qsfp2_rx_n[2]}] ;# MGTYRXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J5  } [get_ports {qsfp2_tx_p[2]}] ;# MGTYTXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J4  } [get_ports {qsfp2_tx_n[2]}] ;# MGTYTXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC M2  } [get_ports {qsfp2_rx_p[3]}] ;# MGTYRXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC M1  } [get_ports {qsfp2_rx_n[3]}] ;# MGTYRXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H7  } [get_ports {qsfp2_tx_p[3]}] ;# MGTYTXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H6  } [get_ports {qsfp2_tx_n[3]}] ;# MGTYTXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC R9  } [get_ports qsfp2_mgt_refclk_0_p] ;# MGTREFCLK0P_232 from U104.13
#set_property -dict {LOC R8  } [get_ports qsfp2_mgt_refclk_0_n] ;# MGTREFCLK0N_232 from U104.14
#set_property -dict {LOC N9  } [get_ports qsfp2_mgt_refclk_1_p] ;# MGTREFCLK1P_232 from U57.35
#set_property -dict {LOC N8  } [get_ports qsfp2_mgt_refclk_1_n] ;# MGTREFCLK1N_232 from U57.34
#set_property -dict {LOC AP23 IOSTANDARD LVDS} [get_ports qsfp2_recclk_p] ;# to U57.12
#set_property -dict {LOC AP22 IOSTANDARD LVDS} [get_ports qsfp2_recclk_n] ;# to U57.13
set_property -dict {LOC AN23 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp2_modsell]
set_property -dict {LOC AY22 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp2_resetl]
set_property -dict {LOC AN24 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp2_modprsl]
set_property -dict {LOC AT21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp2_intl]
set_property -dict {LOC AT24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp2_lpmode]

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name qsfp2_mgt_refclk_0 [get_ports qsfp2_mgt_refclk_0_p]

set_false_path -to [get_ports {qsfp2_modsell qsfp2_resetl qsfp2_lpmode}]
set_output_delay 0 [get_ports {qsfp2_modsell qsfp2_resetl qsfp2_lpmode}]
set_false_path -from [get_ports {qsfp2_modprsl qsfp2_intl}]
set_input_delay 0 [get_ports {qsfp2_modprsl qsfp2_intl}]

# I2C interface
set_property -dict {LOC AM24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC AL24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

set_false_path -to [get_ports {i2c_sda i2c_scl}]
set_output_delay 0 [get_ports {i2c_sda i2c_scl}]
set_false_path -from [get_ports {i2c_sda i2c_scl}]
set_input_delay 0 [get_ports {i2c_sda i2c_scl}]

# PCIe Interface
#set_property -dict {LOC AA4  } [get_ports {pcie_rx_p[0]}]  ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AA3  } [get_ports {pcie_rx_n[0]}]  ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC Y7   } [get_ports {pcie_tx_p[0]}]  ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC Y6   } [get_ports {pcie_tx_n[0]}]  ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AB2  } [get_ports {pcie_rx_p[1]}]  ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AB1  } [get_ports {pcie_rx_n[1]}]  ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AB7  } [get_ports {pcie_tx_p[1]}]  ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AB6  } [get_ports {pcie_tx_n[1]}]  ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AC4  } [get_ports {pcie_rx_p[2]}]  ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AC3  } [get_ports {pcie_rx_n[2]}]  ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AD7  } [get_ports {pcie_tx_p[2]}]  ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AD6  } [get_ports {pcie_tx_n[2]}]  ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AD2  } [get_ports {pcie_rx_p[3]}]  ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AD1  } [get_ports {pcie_rx_n[3]}]  ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF7  } [get_ports {pcie_tx_p[3]}]  ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF6  } [get_ports {pcie_tx_n[3]}]  ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AE4  } [get_ports {pcie_rx_p[4]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AE3  } [get_ports {pcie_rx_n[4]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AH7  } [get_ports {pcie_tx_p[4]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AH6  } [get_ports {pcie_tx_n[4]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AF2  } [get_ports {pcie_rx_p[5]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AF1  } [get_ports {pcie_rx_n[5]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK7  } [get_ports {pcie_tx_p[5]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AK6  } [get_ports {pcie_tx_n[5]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AG4  } [get_ports {pcie_rx_p[6]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AG3  } [get_ports {pcie_rx_n[6]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM7  } [get_ports {pcie_tx_p[6]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AM6  } [get_ports {pcie_tx_n[6]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AH2  } [get_ports {pcie_rx_p[7]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AH1  } [get_ports {pcie_rx_n[7]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN5  } [get_ports {pcie_tx_p[7]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AN4  } [get_ports {pcie_tx_n[7]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AJ4  } [get_ports {pcie_rx_p[8]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AJ3  } [get_ports {pcie_rx_n[8]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP7  } [get_ports {pcie_tx_p[8]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP6  } [get_ports {pcie_tx_n[8]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AK2  } [get_ports {pcie_rx_p[9]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AK1  } [get_ports {pcie_rx_n[9]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR5  } [get_ports {pcie_tx_p[9]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR4  } [get_ports {pcie_tx_n[9]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AM2  } [get_ports {pcie_rx_p[10]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AM1  } [get_ports {pcie_rx_n[10]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT7  } [get_ports {pcie_tx_p[10]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT6  } [get_ports {pcie_tx_n[10]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP2  } [get_ports {pcie_rx_p[11]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP1  } [get_ports {pcie_rx_n[11]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU5  } [get_ports {pcie_tx_p[11]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU4  } [get_ports {pcie_tx_n[11]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT2  } [get_ports {pcie_rx_p[12]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AT1  } [get_ports {pcie_rx_n[12]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW5  } [get_ports {pcie_tx_p[12]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW4  } [get_ports {pcie_tx_n[12]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV2  } [get_ports {pcie_rx_p[13]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV1  } [get_ports {pcie_rx_n[13]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA5  } [get_ports {pcie_tx_p[13]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA4  } [get_ports {pcie_tx_n[13]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AY2  } [get_ports {pcie_rx_p[14]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AY1  } [get_ports {pcie_rx_n[14]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC5  } [get_ports {pcie_tx_p[14]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC4  } [get_ports {pcie_tx_n[14]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB2  } [get_ports {pcie_rx_p[15]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB1  } [get_ports {pcie_rx_n[15]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BE5  } [get_ports {pcie_tx_p[15]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BE4  } [get_ports {pcie_tx_n[15]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AC9  } [get_ports pcie_refclk_1_p] ;# MGTREFCLK0P_227
#set_property -dict {LOC AC8  } [get_ports pcie_refclk_1_n] ;# MGTREFCLK0N_227
#set_property -dict {LOC AL9  } [get_ports pcie_refclk_2_p] ;# MGTREFCLK0P_225
#set_property -dict {LOC AL8  } [get_ports pcie_refclk_2_n] ;# MGTREFCLK0N_225
#set_property -dict {LOC AM17 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk_1 [get_ports pcie_refclk_1_p]
#create_clock -period 10 -name pcie_mgt_refclk_2 [get_ports pcie_refclk_2_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# FMC+ J22
set_property -dict {LOC AL35 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp1_lpmode]  ;# J22.G9  LA00_P_CC
set_property -dict {LOC AL36 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp6_resetl]  ;# J22.G10 LA00_N_CC
set_property -dict {LOC AL30 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp1_modprsl]  ;# J22.D8  LA01_P_CC
set_property -dict {LOC AL31 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp1_intl]  ;# J22.D9  LA01_N_CC
set_property -dict {LOC AJ32 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp6_modsell]  ;# J22.H7  LA02_P
set_property -dict {LOC AK32 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp6_modprsl]  ;# J22.H8  LA02_N
set_property -dict {LOC AT39 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp6_intl]  ;# J22.G12 LA03_P
set_property -dict {LOC AT40 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp5_modsell]  ;# J22.G13 LA03_N
set_property -dict {LOC AR37 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp6_lpmode]  ;# J22.H10 LA04_P
set_property -dict {LOC AT37 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp5_resetl]  ;# J22.H11 LA04_N
set_property -dict {LOC AP38 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp1_modsell]  ;# J22.D11 LA05_P
set_property -dict {LOC AR38 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp2_intl]  ;# J22.D12 LA05_N
set_property -dict {LOC AT35 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp1_resetl]  ;# J22.C10 LA06_P
set_property -dict {LOC AT36 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp2_lpmode]  ;# J22.C11 LA06_N
set_property -dict {LOC AP36 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp4_modprsl]  ;# J22.H13 LA07_P
set_property -dict {LOC AP37 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp4_modsell]  ;# J22.H14 LA07_N
set_property -dict {LOC AK29 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp4_lpmode]  ;# J22.G12 LA08_P
set_property -dict {LOC AK30 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp4_intl]  ;# J22.G13 LA08_N
set_property -dict {LOC AJ33 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp2_modprsl]  ;# J22.D14 LA09_P
set_property -dict {LOC AK33 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp2_modsell]  ;# J22.D15 LA09_N
set_property -dict {LOC AP35 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp2_resetl] ;# J22.C14 LA10_P
set_property -dict {LOC AR35 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp3_lpmode] ;# J22.C15 LA10_N
set_property -dict {LOC AJ30 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp5_intl] ;# J22.H16 LA11_P
set_property -dict {LOC AJ31 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp5_modprsl] ;# J22.H17 LA11_N
set_property -dict {LOC AH33 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp4_resetl] ;# J22.G15 LA12_P
set_property -dict {LOC AH34 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp5_lpmode] ;# J22.G16 LA12_N
set_property -dict {LOC AJ35 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp3_intl] ;# J22.D17 LA13_P
set_property -dict {LOC AJ36 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp3_modprsl] ;# J22.D18 LA13_N
set_property -dict {LOC AG31 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp3_modsell] ;# J22.C18 LA14_P
set_property -dict {LOC AH31 IOSTANDARD LVCMOS18} [get_ports fmcp_qsfp3_resetl] ;# J22.C19 LA14_N
set_property -dict {LOC AG32 IOSTANDARD LVCMOS18} [get_ports fmcp_clk_finc] ;# J22.H19 LA15_P
set_property -dict {LOC AG33 IOSTANDARD LVCMOS18} [get_ports fmcp_clk_fdec] ;# J22.H20 LA15_N
set_property -dict {LOC AG34 IOSTANDARD LVCMOS18} [get_ports fmcp_clk_rst_n] ;# J22.G18 LA16_P
set_property -dict {LOC AH35 IOSTANDARD LVCMOS18} [get_ports fmcp_clk_lol_n] ;# J22.G19 LA16_N
set_property -dict {LOC R34  IOSTANDARD LVCMOS18} [get_ports fmcp_clk_sync_n] ;# J22.D20 LA17_P_CC
set_property -dict {LOC P34  IOSTANDARD LVCMOS18} [get_ports fmcp_clk_intr_n] ;# J22.D21 LA17_N_CC
#set_property -dict {LOC R31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[18]}] ;# J22.C22 LA18_P_CC
#set_property -dict {LOC P31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[18]}] ;# J22.C23 LA18_N_CC
#set_property -dict {LOC N33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[19]}] ;# J22.H22 LA19_P
#set_property -dict {LOC M33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[19]}] ;# J22.H23 LA19_N
#set_property -dict {LOC N32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[20]}] ;# J22.G21 LA20_P
#set_property -dict {LOC M32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[20]}] ;# J22.G22 LA20_N
#set_property -dict {LOC M35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[21]}] ;# J22.H25 LA21_P
#set_property -dict {LOC L35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[21]}] ;# J22.H26 LA21_N
#set_property -dict {LOC N34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[22]}] ;# J22.G24 LA22_P
#set_property -dict {LOC N35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[22]}] ;# J22.G25 LA22_N
#set_property -dict {LOC Y32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[23]}] ;# J22.D23 LA23_P
#set_property -dict {LOC W32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[23]}] ;# J22.D24 LA23_N
#set_property -dict {LOC T34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[24]}] ;# J22.H28 LA24_P
#set_property -dict {LOC T35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[24]}] ;# J22.H29 LA24_N
#set_property -dict {LOC Y34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[25]}] ;# J22.G27 LA25_P
#set_property -dict {LOC W34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[25]}] ;# J22.G28 LA25_N
#set_property -dict {LOC V32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[26]}] ;# J22.D26 LA26_P
#set_property -dict {LOC U33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[26]}] ;# J22.D27 LA26_N
#set_property -dict {LOC V33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[27]}] ;# J22.C26 LA27_P
#set_property -dict {LOC V34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[27]}] ;# J22.C27 LA27_N
#set_property -dict {LOC M36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[28]}] ;# J22.H31 LA28_P
#set_property -dict {LOC L36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[28]}] ;# J22.H32 LA28_N
#set_property -dict {LOC U35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[29]}] ;# J22.G30 LA29_P
#set_property -dict {LOC T36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[29]}] ;# J22.G31 LA29_N
#set_property -dict {LOC N38  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[30]}] ;# J22.H34 LA30_P
#set_property -dict {LOC M38  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[30]}] ;# J22.H35 LA30_N
#set_property -dict {LOC P37  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[31]}] ;# J22.G33 LA31_P
#set_property -dict {LOC N37  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[31]}] ;# J22.G34 LA31_N
#set_property -dict {LOC L33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[32]}] ;# J22.H37 LA32_P
#set_property -dict {LOC K33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[32]}] ;# J22.H38 LA32_N
#set_property -dict {LOC L34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_p[33]}] ;# J22.G36 LA33_P
#set_property -dict {LOC K34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_la_n[33]}] ;# J22.G37 LA33_N

#set_property -dict {LOC N14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[0]}]  ;# J22.F4  HA00_P_CC
#set_property -dict {LOC N13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[0]}]  ;# J22.F5  HA00_N_CC
#set_property -dict {LOC V15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[1]}]  ;# J22.E2  HA01_P_CC
#set_property -dict {LOC U15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[1]}]  ;# J22.E3  HA01_N_CC
#set_property -dict {LOC AA12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[2]}]  ;# J22.K7  HA02_P
#set_property -dict {LOC Y12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[2]}]  ;# J22.K8  HA02_N
#set_property -dict {LOC W12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[3]}]  ;# J22.J6  HA03_P
#set_property -dict {LOC V12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[3]}]  ;# J22.J7  HA03_N
#set_property -dict {LOC AA13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[4]}]  ;# J22.F7  HA04_P
#set_property -dict {LOC Y13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[4]}]  ;# J22.F8  HA04_N
#set_property -dict {LOC R14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[5]}]  ;# J22.E6  HA05_P
#set_property -dict {LOC P14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[5]}]  ;# J22.E7  HA05_N
#set_property -dict {LOC U13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[6]}]  ;# J22.K10 HA06_P
#set_property -dict {LOC T13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[6]}]  ;# J22.K11 HA06_N
#set_property -dict {LOC AA14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[7]}]  ;# J22.J9  HA07_P
#set_property -dict {LOC Y14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[7]}]  ;# J22.J10 HA07_N
#set_property -dict {LOC U11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[8]}]  ;# J22.F10 HA08_P
#set_property -dict {LOC T11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[8]}]  ;# J22.F11 HA08_N
#set_property -dict {LOC W14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[9]}]  ;# J22.E9  HA09_P
#set_property -dict {LOC V14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[9]}]  ;# J22.E10 HA09_N
#set_property -dict {LOC V16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[10]}] ;# J22.K13 HA10_P
#set_property -dict {LOC U16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[10]}] ;# J22.K14 HA10_N
#set_property -dict {LOC R12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[11]}] ;# J22.J12 HA11_P
#set_property -dict {LOC P12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[11]}] ;# J22.J13 HA11_N
#set_property -dict {LOC T16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[12]}] ;# J22.F13 HA12_P
#set_property -dict {LOC T15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[12]}] ;# J22.F14 HA12_N
#set_property -dict {LOC V13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[13]}] ;# J22.E12 HA13_P
#set_property -dict {LOC U12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[13]}] ;# J22.E13 HA13_N
#set_property -dict {LOC M11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[14]}] ;# J22.J15 HA14_P
#set_property -dict {LOC L11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[14]}] ;# J22.J16 HA14_N
#set_property -dict {LOC M13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[15]}] ;# J22.F14 HA15_P
#set_property -dict {LOC M12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[15]}] ;# J22.F16 HA15_N
#set_property -dict {LOC T14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[16]}] ;# J22.E15 HA16_P
#set_property -dict {LOC R13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[16]}] ;# J22.E16 HA16_N
#set_property -dict {LOC R11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[17]}] ;# J22.K16 HA17_P_CC
#set_property -dict {LOC P11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[17]}] ;# J22.K17 HA17_N_CC
#set_property -dict {LOC P15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[18]}] ;# J22.J18 HA18_P_CC
#set_property -dict {LOC N15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[18]}] ;# J22.J19 HA18_N_CC
#set_property -dict {LOC L14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[19]}] ;# J22.F19 HA19_P
#set_property -dict {LOC L13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[19]}] ;# J22.F20 HA19_N
#set_property -dict {LOC M15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[20]}] ;# J22.E18 HA20_P
#set_property -dict {LOC L15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[20]}] ;# J22.E19 HA20_N
#set_property -dict {LOC K14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[21]}] ;# J22.K19 HA21_P
#set_property -dict {LOC K13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[21]}] ;# J22.K20 HA21_N
#set_property -dict {LOC K12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[22]}] ;# J22.J21 HA22_P
#set_property -dict {LOC J12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[22]}] ;# J22.J22 HA22_N
#set_property -dict {LOC K11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_p[23]}] ;# J22.K22 HA23_P
#set_property -dict {LOC J11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_ha_n[23]}] ;# J22.K23 HA23_N

#set_property -dict {LOC AL32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_clk0_m2c_p}] ;# J22.H4 CLK0_M2C_P
#set_property -dict {LOC AM32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_clk0_m2c_n}] ;# J22.H5 CLK0_M2C_N
#set_property -dict {LOC P35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_clk1_m2c_p}] ;# J22.G2 CLK1_M2C_P
#set_property -dict {LOC P36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_clk1_m2c_n}] ;# J22.G3 CLK1_M2C_N

#set_property -dict {LOC AN33 IOSTANDARD LVDS               } [get_ports {fmcp_hspc_refclk_c2m_p}] ;# J22.L20 REFCLK_C2M_P
#set_property -dict {LOC AP33 IOSTANDARD LVDS               } [get_ports {fmcp_hspc_refclk_c2m_n}] ;# J22.L21 REFCLK_C2M_N
#set_property -dict {LOC AK34 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_refclk_m2c_p}] ;# J22.L24 REFCLK_M2C_P
#set_property -dict {LOC AL34 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_refclk_m2c_n}] ;# J22.L25 REFCLK_M2C_N
set_property -dict {LOC AN34 IOSTANDARD LVDS               } [get_ports {fmcp_hspc_sync_c2m_p}]   ;# J22.L16 SYNC_C2M_P
set_property -dict {LOC AN35 IOSTANDARD LVDS               } [get_ports {fmcp_hspc_sync_c2m_n}]   ;# J22.L17 SYNC_C2M_N
#set_property -dict {LOC AM36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_sync_m2c_p}]   ;# J22.L28 SYNC_M2C_P
#set_property -dict {LOC AN36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmcp_hspc_sync_m2c_n}]   ;# J22.L29 SYNC_M2C_N

#set_property -dict {LOC AL36 IOSTANDARD LVCMOS18} [get_ports {fmcp_hspc_pg_m2c}]        ;# J22.F1 PG_M2C
#set_property -dict {LOC AM33 IOSTANDARD LVCMOS18} [get_ports {fmcp_hspc_h_prsnt_m2c_l}] ;# J22.H2 PRSNT_M2C_L
#set_property -dict {LOC AM29 IOSTANDARD LVCMOS18} [get_ports {fmcp_hspc_z_prsnt_m2c_l}] ;# J22.Z1 HSPC_PRSNT_M2C_L

set_property -dict {LOC AT42} [get_ports {fmcp_qsfp1_tx_p[0]}] ;# MGTYTXP0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2 from J22.C2  DP0_C2M_P
set_property -dict {LOC AT43} [get_ports {fmcp_qsfp1_tx_n[0]}] ;# MGTYTXN0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2 from J22.C3  DP0_C2M_N
set_property -dict {LOC AR45} [get_ports {fmcp_qsfp1_rx_p[0]}] ;# MGTYRXP0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2 from J22.C6  DP0_M2C_P
set_property -dict {LOC AR46} [get_ports {fmcp_qsfp1_rx_n[0]}] ;# MGTYRXN0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2 from J22.C7  DP0_M2C_N
set_property -dict {LOC AP42} [get_ports {fmcp_qsfp1_tx_p[2]}] ;# MGTYTXP1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2 from J22.A22 DP1_C2M_P
set_property -dict {LOC AP43} [get_ports {fmcp_qsfp1_tx_n[2]}] ;# MGTYTXN1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2 from J22.A23 DP1_C2M_N
set_property -dict {LOC AN45} [get_ports {fmcp_qsfp1_rx_p[2]}] ;# MGTYRXP1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2 from J22.A2  DP1_M2C_P
set_property -dict {LOC AN46} [get_ports {fmcp_qsfp1_rx_n[2]}] ;# MGTYRXN1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2 from J22.A3  DP1_M2C_N
set_property -dict {LOC AM42} [get_ports {fmcp_qsfp1_tx_p[1]}] ;# MGTYTXP2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2 from J22.A26 DP2_C2M_P
set_property -dict {LOC AM43} [get_ports {fmcp_qsfp1_tx_n[1]}] ;# MGTYTXN2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2 from J22.A27 DP2_C2M_N
set_property -dict {LOC AL45} [get_ports {fmcp_qsfp1_rx_p[1]}] ;# MGTYRXP2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2 from J22.A6  DP2_M2C_P
set_property -dict {LOC AL46} [get_ports {fmcp_qsfp1_rx_n[1]}] ;# MGTYRXN2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2 from J22.A7  DP2_M2C_N
set_property -dict {LOC AL40} [get_ports {fmcp_qsfp1_tx_p[3]}] ;# MGTYTXP3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2 from J22.A30 DP3_C2M_P
set_property -dict {LOC AL41} [get_ports {fmcp_qsfp1_tx_n[3]}] ;# MGTYTXN3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2 from J22.A31 DP3_C2M_N
set_property -dict {LOC AJ45} [get_ports {fmcp_qsfp1_rx_p[3]}] ;# MGTYRXP3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2 from J22.A10 DP3_M2C_P
set_property -dict {LOC AJ46} [get_ports {fmcp_qsfp1_rx_n[3]}] ;# MGTYRXN3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2 from J22.A11 DP3_M2C_N
set_property -dict {LOC AK38} [get_ports fmcp_qsfp1_mgt_refclk_p] ;# MGTREFCLK0P_121 from U40.1 Q0 from J22.D4 GBTCLK0_M2C_P
set_property -dict {LOC AK39} [get_ports fmcp_qsfp1_mgt_refclk_n] ;# MGTREFCLK0N_121 from U40.2 NQ0 from J22.D5 GBTCLK0_M2C_N
#set_property -dict {LOC AH38} [get_ports fmcp_hspc_mgt_refclk_0_1_p] ;# MGTREFCLK1P_121 from U39.5 Q0_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC AH39} [get_ports fmcp_hspc_mgt_refclk_0_1_n] ;# MGTREFCLK1N_121 from U39.6 Q0_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp1_mgt_refclk [get_ports fmcp_qsfp1_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_0_1 [get_ports fmcp_hspc_mgt_refclk_0_1_p]

set_property -dict {LOC T42 } [get_ports {fmcp_qsfp6_tx_p[1]}] ;# MGTYTXP0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7 from J22.A34 DP4_C2M_P
set_property -dict {LOC T43 } [get_ports {fmcp_qsfp6_tx_n[1]}] ;# MGTYTXN0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7 from J22.A35 DP4_C2M_N
set_property -dict {LOC W45 } [get_ports {fmcp_qsfp6_rx_p[1]}] ;# MGTYRXP0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7 from J22.A14 DP4_M2C_P
set_property -dict {LOC W46 } [get_ports {fmcp_qsfp6_rx_n[1]}] ;# MGTYRXN0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7 from J22.A15 DP4_M2C_N
set_property -dict {LOC P42 } [get_ports {fmcp_qsfp6_tx_p[0]}] ;# MGTYTXP1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7 from J22.A38 DP5_C2M_P
set_property -dict {LOC P43 } [get_ports {fmcp_qsfp6_tx_n[0]}] ;# MGTYTXN1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7 from J22.A39 DP5_C2M_N
set_property -dict {LOC U45 } [get_ports {fmcp_qsfp6_rx_p[0]}] ;# MGTYRXP1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7 from J22.A18 DP5_M2C_P
set_property -dict {LOC U46 } [get_ports {fmcp_qsfp6_rx_n[0]}] ;# MGTYRXN1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7 from J22.A19 DP5_M2C_N
set_property -dict {LOC M42 } [get_ports {fmcp_qsfp6_tx_p[2]}] ;# MGTYTXP2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7 from J22.B36 DP6_C2M_P
set_property -dict {LOC M43 } [get_ports {fmcp_qsfp6_tx_n[2]}] ;# MGTYTXN2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7 from J22.B37 DP6_C2M_N
set_property -dict {LOC R45 } [get_ports {fmcp_qsfp6_rx_p[2]}] ;# MGTYRXP2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7 from J22.B16 DP6_M2C_P
set_property -dict {LOC R46 } [get_ports {fmcp_qsfp6_rx_n[2]}] ;# MGTYRXN2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7 from J22.B17 DP6_M2C_N
set_property -dict {LOC K42 } [get_ports {fmcp_qsfp6_tx_p[3]}] ;# MGTYTXP3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7 from J22.B32 DP7_C2M_P
set_property -dict {LOC K43 } [get_ports {fmcp_qsfp6_tx_n[3]}] ;# MGTYTXN3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7 from J22.B33 DP7_C2M_N
set_property -dict {LOC N45 } [get_ports {fmcp_qsfp6_rx_p[3]}] ;# MGTYRXP3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7 from J22.B12 DP7_M2C_P
set_property -dict {LOC N46 } [get_ports {fmcp_qsfp6_rx_n[3]}] ;# MGTYRXN3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7 from J22.B13 DP7_M2C_N
set_property -dict {LOC V38 } [get_ports fmcp_qsfp6_mgt_refclk_p] ;# MGTREFCLK0P_126 from U40.3 Q1 from J22.D4 GBTCLK0_M2C_P
set_property -dict {LOC V39 } [get_ports fmcp_qsfp6_mgt_refclk_n] ;# MGTREFCLK0N_126 from U40.4 NQ1 from J22.D5 GBTCLK0_M2C_N
#set_property -dict {LOC T38 } [get_ports fmcp_hspc_mgt_refclk_1_1_p] ;# MGTREFCLK1P_126 from U39.8 Q1_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC T39 } [get_ports fmcp_hspc_mgt_refclk_1_1_n] ;# MGTREFCLK1N_126 from U39.9 Q1_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp6_mgt_refclk [get_ports fmcp_qsfp6_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_1_1 [get_ports fmcp_hspc_mgt_refclk_1_1_p]

set_property -dict {LOC AK42} [get_ports {fmcp_qsfp4_tx_p[3]}] ;# MGTYTXP0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3 from J22.B28 DP8_C2M_P
set_property -dict {LOC AK43} [get_ports {fmcp_qsfp4_tx_n[3]}] ;# MGTYTXN0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3 from J22.B29 DP8_C2M_N
set_property -dict {LOC AG45} [get_ports {fmcp_qsfp4_rx_p[3]}] ;# MGTYRXP0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3 from J22.B8  DP8_M2C_P
set_property -dict {LOC AG46} [get_ports {fmcp_qsfp4_rx_n[3]}] ;# MGTYRXN0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3 from J22.B9  DP8_M2C_N
set_property -dict {LOC AJ40} [get_ports {fmcp_qsfp4_tx_p[2]}] ;# MGTYTXP1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3 from J22.B24 DP9_C2M_P
set_property -dict {LOC AJ41} [get_ports {fmcp_qsfp4_tx_n[2]}] ;# MGTYTXN1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3 from J22.B25 DP9_C2M_N
set_property -dict {LOC AF43} [get_ports {fmcp_qsfp4_rx_p[2]}] ;# MGTYRXP1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3 from J22.B4  DP9_M2C_P
set_property -dict {LOC AF44} [get_ports {fmcp_qsfp4_rx_n[2]}] ;# MGTYRXN1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3 from J22.B5  DP9_M2C_N
set_property -dict {LOC AG40} [get_ports {fmcp_qsfp4_tx_p[1]}] ;# MGTYTXP2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3 from J22.Z24 DP10_C2M_P
set_property -dict {LOC AG41} [get_ports {fmcp_qsfp4_tx_n[1]}] ;# MGTYTXN2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3 from J22.Z25 DP10_C2M_N
set_property -dict {LOC AE45} [get_ports {fmcp_qsfp4_rx_p[1]}] ;# MGTYRXP2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3 from J22.Y10 DP10_M2C_P
set_property -dict {LOC AE46} [get_ports {fmcp_qsfp4_rx_n[1]}] ;# MGTYRXN2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3 from J22.Y11 DP10_M2C_N
set_property -dict {LOC AE40} [get_ports {fmcp_qsfp4_tx_p[0]}] ;# MGTYTXP3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3 from J22.Y26 DP11_C2M_P
set_property -dict {LOC AE41} [get_ports {fmcp_qsfp4_tx_n[0]}] ;# MGTYTXN3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3 from J22.Y27 DP11_C2M_N
set_property -dict {LOC AD43} [get_ports {fmcp_qsfp4_rx_p[0]}] ;# MGTYRXP3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3 from J22.Z12 DP11_M2C_P
set_property -dict {LOC AD44} [get_ports {fmcp_qsfp4_rx_n[0]}] ;# MGTYRXN3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3 from J22.Z13 DP11_M2C_N
set_property -dict {LOC AF38} [get_ports fmcp_qsfp4_mgt_refclk_p] ;# MGTREFCLK0P_122 from J22.L12 GBTCLK2_M2C_P
set_property -dict {LOC AF39} [get_ports fmcp_qsfp4_mgt_refclk_n] ;# MGTREFCLK0N_122 from J22.L13 GBTCLK2_M2C_N
#set_property -dict {LOC AD38} [get_ports fmcp_hspc_mgt_refclk_2_1_p] ;# MGTREFCLK1P_122 from U39.11 Q2_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC AD39} [get_ports fmcp_hspc_mgt_refclk_2_1_n] ;# MGTREFCLK1N_122 from U39.12 Q2_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp4_mgt_refclk [get_ports fmcp_qsfp4_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_2_1 [get_ports fmcp_hspc_mgt_refclk_2_1_p]

set_property -dict {LOC AC40} [get_ports {fmcp_qsfp3_tx_p[2]}] ;# MGTYTXP0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6 from J22.Z28 DP12_C2M_P
set_property -dict {LOC AC41} [get_ports {fmcp_qsfp3_tx_n[2]}] ;# MGTYTXN0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6 from J22.Z29 DP12_C2M_N
set_property -dict {LOC AC45} [get_ports {fmcp_qsfp3_rx_p[2]}] ;# MGTYRXP0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6 from J22.Y14 DP12_M2C_P
set_property -dict {LOC AC46} [get_ports {fmcp_qsfp3_rx_n[2]}] ;# MGTYRXN0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6 from J22.Y15 DP12_M2C_N
set_property -dict {LOC AA40} [get_ports {fmcp_qsfp3_tx_p[3]}] ;# MGTYTXP1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6 from J22.Y30 DP13_C2M_P
set_property -dict {LOC AA41} [get_ports {fmcp_qsfp3_tx_n[3]}] ;# MGTYTXN1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6 from J22.Y31 DP13_C2M_N
set_property -dict {LOC AB43} [get_ports {fmcp_qsfp3_rx_p[3]}] ;# MGTYRXP1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6 from J22.Z16 DP13_M2C_P
set_property -dict {LOC AB44} [get_ports {fmcp_qsfp3_rx_n[3]}] ;# MGTYRXN1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6 from J22.Z17 DP13_M2C_N
set_property -dict {LOC W40 } [get_ports {fmcp_qsfp3_tx_p[1]}] ;# MGTYTXP2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6 from J22.M18 DP14_C2M_P
set_property -dict {LOC W41 } [get_ports {fmcp_qsfp3_tx_n[1]}] ;# MGTYTXN2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6 from J22.M19 DP14_C2M_N
set_property -dict {LOC AA45} [get_ports {fmcp_qsfp3_rx_p[1]}] ;# MGTYRXP2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6 from J22.Y18 DP14_M2C_P
set_property -dict {LOC AA46} [get_ports {fmcp_qsfp3_rx_n[1]}] ;# MGTYRXN2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6 from J22.Y19 DP14_M2C_N
set_property -dict {LOC U40 } [get_ports {fmcp_qsfp3_tx_p[0]}] ;# MGTYTXP3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6 from J22.M22 DP15_C2M_P
set_property -dict {LOC U41 } [get_ports {fmcp_qsfp3_tx_n[0]}] ;# MGTYTXN3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6 from J22.M23 DP15_C2M_N
set_property -dict {LOC Y43 } [get_ports {fmcp_qsfp3_rx_p[0]}] ;# MGTYRXP3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6 from J22.Y22 DP15_M2C_P
set_property -dict {LOC Y44 } [get_ports {fmcp_qsfp3_rx_n[0]}] ;# MGTYRXN3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6 from J22.Y23 DP15_M2C_N
set_property -dict {LOC AB38} [get_ports fmcp_qsfp3_mgt_refclk_p] ;# MGTREFCLK0P_125 from J22.L8 GBTCLK3_M2C_P
set_property -dict {LOC AB39} [get_ports fmcp_qsfp3_mgt_refclk_n] ;# MGTREFCLK0N_125 from J22.L9 GBTCLK3_M2C_N
#set_property -dict {LOC Y38 } [get_ports fmcp_hspc_mgt_refclk_3_1_p] ;# MGTREFCLK1P_125 from U39.13 Q3_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC Y39 } [get_ports fmcp_hspc_mgt_refclk_3_1_n] ;# MGTREFCLK1N_125 from U39.14 Q3_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp3_mgt_refclk [get_ports fmcp_qsfp3_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_3_1 [get_ports fmcp_hspc_mgt_refclk_3_1_p]

set_property -dict {LOC H42 } [get_ports {fmcp_qsfp5_tx_p[3]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8 from J22.M26 DP16_C2M_P
set_property -dict {LOC H43 } [get_ports {fmcp_qsfp5_tx_n[3]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8 from J22.M27 DP16_C2M_N
set_property -dict {LOC L45 } [get_ports {fmcp_qsfp5_rx_p[3]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8 from J22.Z32 DP16_M2C_P
set_property -dict {LOC L46 } [get_ports {fmcp_qsfp5_rx_n[3]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8 from J22.Z33 DP16_M2C_N
set_property -dict {LOC F42 } [get_ports {fmcp_qsfp5_tx_p[1]}] ;# MGTYTXP1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8 from J22.M30 DP17_C2M_P
set_property -dict {LOC F43 } [get_ports {fmcp_qsfp5_tx_n[1]}] ;# MGTYTXN1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8 from J22.M31 DP17_C2M_N
set_property -dict {LOC J45 } [get_ports {fmcp_qsfp5_rx_p[1]}] ;# MGTYRXP1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8 from J22.Y34 DP17_M2C_P
set_property -dict {LOC J46 } [get_ports {fmcp_qsfp5_rx_n[1]}] ;# MGTYRXN1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8 from J22.Y35 DP17_M2C_N
set_property -dict {LOC D42 } [get_ports {fmcp_qsfp5_tx_p[2]}] ;# MGTYTXP2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8 from J22.M34 DP18_C2M_P
set_property -dict {LOC D43 } [get_ports {fmcp_qsfp5_tx_n[2]}] ;# MGTYTXN2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8 from J22.M35 DP18_C2M_N
set_property -dict {LOC G45 } [get_ports {fmcp_qsfp5_rx_p[2]}] ;# MGTYRXP2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8 from J22.Z36 DP18_M2C_P
set_property -dict {LOC G46 } [get_ports {fmcp_qsfp5_rx_n[2]}] ;# MGTYRXN2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8 from J22.Z37 DP18_M2C_N
set_property -dict {LOC B42 } [get_ports {fmcp_qsfp5_tx_p[0]}] ;# MGTYTXP3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8 from J22.M38 DP19_C2M_P
set_property -dict {LOC B43 } [get_ports {fmcp_qsfp5_tx_n[0]}] ;# MGTYTXN3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8 from J22.M39 DP19_C2M_N
set_property -dict {LOC E45 } [get_ports {fmcp_qsfp5_rx_p[0]}] ;# MGTYRXP3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8 from J22.Y38 DP19_M2C_P
set_property -dict {LOC E46 } [get_ports {fmcp_qsfp5_rx_n[0]}] ;# MGTYRXN3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8 from J22.Y39 DP19_M2C_N
set_property -dict {LOC R40 } [get_ports fmcp_qsfp5_mgt_refclk_p] ;# MGTREFCLK0P_127 from J22.L4 GBTCLK4_M2C_P
set_property -dict {LOC R41 } [get_ports fmcp_qsfp5_mgt_refclk_n] ;# MGTREFCLK0N_127 from J22.L5 GBTCLK4_M2C_N
#set_property -dict {LOC N40 } [get_ports fmcp_hspc_mgt_refclk_4_1_p] ;# MGTREFCLK1P_127 from U39.16 Q4_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC N41 } [get_ports fmcp_hspc_mgt_refclk_4_1_n] ;# MGTREFCLK1N_127 from U39.17 Q4_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp5_mgt_refclk [get_ports fmcp_qsfp5_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_4_1 [get_ports fmcp_hspc_mgt_refclk_4_1_p]

set_property -dict {LOC BD42} [get_ports {fmcp_qsfp2_tx_p[3]}] ;# MGTYTXP0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1 from J22.Z8  DP20_C2M_P
set_property -dict {LOC BD43} [get_ports {fmcp_qsfp2_tx_n[3]}] ;# MGTYTXN0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1 from J22.Z9  DP20_C2M_N
set_property -dict {LOC BC45} [get_ports {fmcp_qsfp2_rx_p[3]}] ;# MGTYRXP0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1 from J22.M14 DP20_M2C_P
set_property -dict {LOC BC46} [get_ports {fmcp_qsfp2_rx_n[3]}] ;# MGTYRXN0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1 from J22.M15 DP20_M2C_N
set_property -dict {LOC BB42} [get_ports {fmcp_qsfp2_tx_p[2]}] ;# MGTYTXP1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1 from J22.Y6  DP21_C2M_P
set_property -dict {LOC BB43} [get_ports {fmcp_qsfp2_tx_n[2]}] ;# MGTYTXN1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1 from J22.Y7  DP21_C2M_N
set_property -dict {LOC BA45} [get_ports {fmcp_qsfp2_rx_p[2]}] ;# MGTYRXP1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1 from J22.M10 DP21_M2C_P
set_property -dict {LOC BA46} [get_ports {fmcp_qsfp2_rx_n[2]}] ;# MGTYRXN1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1 from J22.M11 DP21_M2C_N
set_property -dict {LOC AY42} [get_ports {fmcp_qsfp2_tx_p[0]}] ;# MGTYTXP2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1 from J22.Z4  DP22_C2M_P
set_property -dict {LOC AY43} [get_ports {fmcp_qsfp2_tx_n[0]}] ;# MGTYTXN2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1 from J22.Z5  DP22_C2M_N
set_property -dict {LOC AW45} [get_ports {fmcp_qsfp2_rx_p[0]}] ;# MGTYRXP2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1 from J22.M6  DP22_M2C_P
set_property -dict {LOC AW46} [get_ports {fmcp_qsfp2_rx_n[0]}] ;# MGTYRXN2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1 from J22.M7  DP22_M2C_N
set_property -dict {LOC AV42} [get_ports {fmcp_qsfp2_tx_p[1]}] ;# MGTYTXP3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1 from J22.Y2  DP23_C2M_P
set_property -dict {LOC AV43} [get_ports {fmcp_qsfp2_tx_n[1]}] ;# MGTYTXN3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1 from J22.Y3  DP23_C2M_N
set_property -dict {LOC AU45} [get_ports {fmcp_qsfp2_rx_p[1]}] ;# MGTYRXP3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1 from J22.M2  DP23_M2C_P
set_property -dict {LOC AU46} [get_ports {fmcp_qsfp2_rx_n[1]}] ;# MGTYRXN3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1 from J22.M3  DP23_M2C_N
set_property -dict {LOC AN40} [get_ports fmcp_qsfp2_mgt_refclk_p] ;# MGTREFCLK0P_120 from J22.Z20 GBTCLK5_M2C_P
set_property -dict {LOC AN41} [get_ports fmcp_qsfp2_mgt_refclk_n] ;# MGTREFCLK0N_120 from J22.Z21 GBTCLK5_M2C_N
#set_property -dict {LOC AM38} [get_ports fmcp_hspc_mgt_refclk_5_1_p] ;# MGTREFCLK1P_120 from U39.19 Q5_P from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC AM39} [get_ports fmcp_hspc_mgt_refclk_5_1_n] ;# MGTREFCLK1N_120 from U39.20 Q5_N from J22.B21 GBTCLK1_M2C_N

# reference clock
create_clock -period 6.400 -name fmcp_qsfp2_mgt_refclk [get_ports fmcp_qsfp2_mgt_refclk_p]
#create_clock -period 6.400 -name fmcp_hspc_mgt_refclk_5_1 [get_ports fmcp_hspc_mgt_refclk_5_1_p]

# FMC HPC1 J2
#set_property -dict {LOC AY9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[0]}]  ;# J2.G9  LA00_P_CC
#set_property -dict {LOC BA9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[0]}]  ;# J2.G10 LA00_N_CC
#set_property -dict {LOC BF10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[1]}]  ;# J2.D8  LA01_P_CC
#set_property -dict {LOC BF9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[1]}]  ;# J2.D9  LA01_N_CC
#set_property -dict {LOC BC11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[2]}]  ;# J2.H7  LA02_P
#set_property -dict {LOC BD11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[2]}]  ;# J2.H8  LA02_N
#set_property -dict {LOC BD12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[3]}]  ;# J2.G12 LA03_P
#set_property -dict {LOC BE12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[3]}]  ;# J2.G13 LA03_N
#set_property -dict {LOC BD12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[4]}]  ;# J2.H10 LA04_P
#set_property -dict {LOC BF11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[4]}]  ;# J2.H11 LA04_N
#set_property -dict {LOC BE14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[5]}]  ;# J2.D11 LA05_P
#set_property -dict {LOC BF14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[5]}]  ;# J2.D12 LA05_N
#set_property -dict {LOC BD13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[6]}]  ;# J2.C10 LA06_P
#set_property -dict {LOC BE13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[6]}]  ;# J2.C11 LA06_N
#set_property -dict {LOC BC15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[7]}]  ;# J2.H13 LA07_P
#set_property -dict {LOC BD15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[7]}]  ;# J2.H14 LA07_N
#set_property -dict {LOC BE15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[8]}]  ;# J2.G12 LA08_P
#set_property -dict {LOC BF15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[8]}]  ;# J2.G13 LA08_N
#set_property -dict {LOC BA14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[9]}]  ;# J2.D14 LA09_P
#set_property -dict {LOC BB14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[9]}]  ;# J2.D15 LA09_N
#set_property -dict {LOC BB13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[10]}] ;# J2.C14 LA10_P
#set_property -dict {LOC BB12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[10]}] ;# J2.C15 LA10_N
#set_property -dict {LOC BA16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[11]}] ;# J2.H16 LA11_P
#set_property -dict {LOC BA15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[11]}] ;# J2.H17 LA11_N
#set_property -dict {LOC BC14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[12]}] ;# J2.G15 LA12_P
#set_property -dict {LOC BC13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[12]}] ;# J2.G16 LA12_N
#set_property -dict {LOC AY8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[13]}] ;# J2.D17 LA13_P
#set_property -dict {LOC AY7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[13]}] ;# J2.D18 LA13_N
#set_property -dict {LOC AW8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[14]}] ;# J2.C18 LA14_P
#set_property -dict {LOC AW7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[14]}] ;# J2.C19 LA14_N
#set_property -dict {LOC BB16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[15]}] ;# J2.H19 LA15_P
#set_property -dict {LOC BC16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[15]}] ;# J2.H20 LA15_N
#set_property -dict {LOC AV9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[16]}] ;# J2.G18 LA16_P
#set_property -dict {LOC AB8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[16]}] ;# J2.G19 LA16_N
#set_property -dict {LOC AR14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[17]}] ;# J2.D20 LA17_P_CC
#set_property -dict {LOC AT14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[17]}] ;# J2.D21 LA17_N_CC
#set_property -dict {LOC AP12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[18]}] ;# J2.C22 LA18_P_CC
#set_property -dict {LOC AR12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[18]}] ;# J2.C23 LA18_N_CC
#set_property -dict {LOC AW12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[19]}] ;# J2.H22 LA19_P
#set_property -dict {LOC AY12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[19]}] ;# J2.H23 LA19_N
#set_property -dict {LOC AW11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[20]}] ;# J2.G21 LA20_P
#set_property -dict {LOC AY10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[20]}] ;# J2.G22 LA20_N
#set_property -dict {LOC AU11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[21]}] ;# J2.H25 LA21_P
#set_property -dict {LOC AV11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[21]}] ;# J2.H26 LA21_N
#set_property -dict {LOC AW13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[22]}] ;# J2.G24 LA22_P
#set_property -dict {LOC AY13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[22]}] ;# J2.G25 LA22_N
#set_property -dict {LOC AN16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[23]}] ;# J2.D23 LA23_P
#set_property -dict {LOC AP16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[23]}] ;# J2.D24 LA23_N
#set_property -dict {LOC AP13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[24]}] ;# J2.H28 LA24_P
#set_property -dict {LOC AR13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[24]}] ;# J2.H29 LA24_N
#set_property -dict {LOC AT12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[25]}] ;# J2.G27 LA25_P
#set_property -dict {LOC AU12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[25]}] ;# J2.G28 LA25_N
#set_property -dict {LOC AK15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[26]}] ;# J2.D26 LA26_P
#set_property -dict {LOC AL15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[26]}] ;# J2.D27 LA26_N
#set_property -dict {LOC AL14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[27]}] ;# J2.C26 LA27_P
#set_property -dict {LOC AM14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[27]}] ;# J2.C27 LA27_N
#set_property -dict {LOC AV10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[28]}] ;# J2.H31 LA28_P
#set_property -dict {LOC AW10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[28]}] ;# J2.H32 LA28_N
#set_property -dict {LOC AN15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[29]}] ;# J2.G30 LA29_P
#set_property -dict {LOC AP15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[29]}] ;# J2.G31 LA29_N
#set_property -dict {LOC AK12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[30]}] ;# J2.H34 LA30_P
#set_property -dict {LOC AL12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[30]}] ;# J2.H35 LA30_N
#set_property -dict {LOC AM13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[31]}] ;# J2.G33 LA31_P
#set_property -dict {LOC AM12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[31]}] ;# J2.G34 LA31_N
#set_property -dict {LOC AJ13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[32]}] ;# J2.H37 LA32_P
#set_property -dict {LOC AJ12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[32]}] ;# J2.H38 LA32_N
#set_property -dict {LOC AK14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_p[33]}] ;# J2.G36 LA33_P
#set_property -dict {LOC AK13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_la_n[33]}] ;# J2.G37 LA33_N

#set_property -dict {LOC BC9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_clk0_m2c_p}] ;# J2.H4 CLK0_M2C_P
#set_property -dict {LOC BC8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_clk0_m2c_n}] ;# J2.H5 CLK0_M2C_N
#set_property -dict {LOC AV14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_clk1_m2c_p}] ;# J2.G2 CLK1_M2C_P
#set_property -dict {LOC AV13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports {fmc_hpc1_clk1_m2c_n}] ;# J2.G3 CLK1_M2C_N

#set_property -dict {LOC BA7  IOSTANDARD LVCMOS18} [get_ports {fmc_hpc1_pg_m2c}]      ;# J2.F1 PG_M2C
#set_property -dict {LOC BB7  IOSTANDARD LVCMOS18} [get_ports {fmc_hpc1_prsnt_m2c_l}] ;# J2.H2 PRSNT_M2C_L

# DDR4 C1
# 5x MT40A256M16GE-075E
#set_property -dict {LOC D14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC B15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC B16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC C14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC C15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC A13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC A14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC A15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC A16  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC B12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC C12  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC B13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC C13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC D15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC H14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC H15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC F15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC G15  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC G13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC H13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC F14  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t}]
#set_property -dict {LOC E14  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c}]
#set_property -dict {LOC A10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke}]
#set_property -dict {LOC F13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n}]
#set_property -dict {LOC E13  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC C8   IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt}]
#set_property -dict {LOC G10  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC N20  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_reset_n}]
#set_property -dict {LOC R17  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_alert_n}]
#set_property -dict {LOC A20  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_ten}]

#set_property -dict {LOC F11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[0]}]       ;# U60.G2 DQL0
#set_property -dict {LOC E11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[1]}]       ;# U60.F7 DQL1
#set_property -dict {LOC F10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[2]}]       ;# U60.H3 DQL2
#set_property -dict {LOC F9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[3]}]       ;# U60.H7 DQL3
#set_property -dict {LOC H12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[4]}]       ;# U60.H2 DQL4
#set_property -dict {LOC G12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[5]}]       ;# U60.H8 DQL5
#set_property -dict {LOC E9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[6]}]       ;# U60.J3 DQL6
#set_property -dict {LOC D9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[7]}]       ;# U60.J7 DQL7
#set_property -dict {LOC R19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[8]}]       ;# U60.A3 DQU0
#set_property -dict {LOC P19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[9]}]       ;# U60.B8 DQU1
#set_property -dict {LOC M18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[10]}]      ;# U60.C3 DQU2
#set_property -dict {LOC M17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[11]}]      ;# U60.C7 DQU3
#set_property -dict {LOC N19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[12]}]      ;# U60.C2 DQU4
#set_property -dict {LOC N18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[13]}]      ;# U60.C8 DQU5
#set_property -dict {LOC N17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[14]}]      ;# U60.D3 DQU6
#set_property -dict {LOC M16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[15]}]      ;# U60.D7 DQU7
#set_property -dict {LOC D11  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[0]}]    ;# U60.G3 DQSL_T
#set_property -dict {LOC D10  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[0]}]    ;# U60.F3 DQSL_C
#set_property -dict {LOC P17  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[1]}]    ;# U60.B7 DQSU_T
#set_property -dict {LOC P16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[1]}]    ;# U60.A7 DQSU_C
#set_property -dict {LOC G11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[0]}] ;# U60.E7 DML_B/DBIL_B
#set_property -dict {LOC R18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[1]}] ;# U60.E2 DMU_B/DBIU_B

#set_property -dict {LOC L16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[16]}]      ;# U61.G2 DQL0
#set_property -dict {LOC K16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[17]}]      ;# U61.F7 DQL1
#set_property -dict {LOC L18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[18]}]      ;# U61.H3 DQL2
#set_property -dict {LOC K18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[19]}]      ;# U61.H7 DQL3
#set_property -dict {LOC J17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[20]}]      ;# U61.H2 DQL4
#set_property -dict {LOC H17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[21]}]      ;# U61.H8 DQL5
#set_property -dict {LOC H19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[22]}]      ;# U61.J3 DQL6
#set_property -dict {LOC H18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[23]}]      ;# U61.J7 DQL7
#set_property -dict {LOC F19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[24]}]      ;# U61.A3 DQU0
#set_property -dict {LOC F18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[25]}]      ;# U61.B8 DQU1
#set_property -dict {LOC E19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[26]}]      ;# U61.C3 DQU2
#set_property -dict {LOC E18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[27]}]      ;# U61.C7 DQU3
#set_property -dict {LOC G20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[28]}]      ;# U61.C2 DQU4
#set_property -dict {LOC F20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[29]}]      ;# U61.C8 DQU5
#set_property -dict {LOC E17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[30]}]      ;# U61.D3 DQU6
#set_property -dict {LOC D16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[31]}]      ;# U61.D7 DQU7
#set_property -dict {LOC K19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[2]}]    ;# U61.G3 DQSL_T
#set_property -dict {LOC J19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[2]}]    ;# U61.F3 DQSL_C
#set_property -dict {LOC F16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[3]}]    ;# U61.B7 DQSU_T
#set_property -dict {LOC E16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[3]}]    ;# U61.A7 DQSU_C
#set_property -dict {LOC K17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[2]}] ;# U61.E7 DML_B/DBIL_B
#set_property -dict {LOC G18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[3]}] ;# U61.E2 DMU_B/DBIU_B

#set_property -dict {LOC D17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[32]}]      ;# U62.G2 DQL0
#set_property -dict {LOC C17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[33]}]      ;# U62.F7 DQL1
#set_property -dict {LOC C19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[34]}]      ;# U62.H3 DQL2
#set_property -dict {LOC C18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[35]}]      ;# U62.H7 DQL3
#set_property -dict {LOC D20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[36]}]      ;# U62.H2 DQL4
#set_property -dict {LOC D19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[37]}]      ;# U62.H8 DQL5
#set_property -dict {LOC C20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[38]}]      ;# U62.J3 DQL6
#set_property -dict {LOC B20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[39]}]      ;# U62.J7 DQL7
#set_property -dict {LOC N23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[40]}]      ;# U62.A3 DQU0
#set_property -dict {LOC M23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[41]}]      ;# U62.B8 DQU1
#set_property -dict {LOC R21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[42]}]      ;# U62.C3 DQU2
#set_property -dict {LOC P21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[43]}]      ;# U62.C7 DQU3
#set_property -dict {LOC R22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[44]}]      ;# U62.C2 DQU4
#set_property -dict {LOC P22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[45]}]      ;# U62.C8 DQU5
#set_property -dict {LOC T23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[46]}]      ;# U62.D3 DQU6
#set_property -dict {LOC R23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[47]}]      ;# U62.D7 DQU7
#set_property -dict {LOC A19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[4]}]    ;# U62.G3 DQSL_T
#set_property -dict {LOC A18  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[4]}]    ;# U62.F3 DQSL_C
#set_property -dict {LOC N22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[5]}]    ;# U62.B7 DQSU_T
#set_property -dict {LOC M22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[5]}]    ;# U62.A7 DQSU_C
#set_property -dict {LOC B18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[4]}] ;# U62.E7 DML_B/DBIL_B
#set_property -dict {LOC P20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[5]}] ;# U62.E2 DMU_B/DBIU_B

#set_property -dict {LOC K24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[48]}]      ;# U63.G2 DQL0
#set_property -dict {LOC J24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[49]}]      ;# U63.F7 DQL1
#set_property -dict {LOC M21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[50]}]      ;# U63.H3 DQL2
#set_property -dict {LOC L21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[51]}]      ;# U63.H7 DQL3
#set_property -dict {LOC K21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[52]}]      ;# U63.H2 DQL4
#set_property -dict {LOC J21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[53]}]      ;# U63.H8 DQL5
#set_property -dict {LOC K22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[54]}]      ;# U63.J3 DQL6
#set_property -dict {LOC J22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[55]}]      ;# U63.J7 DQL7
#set_property -dict {LOC H23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[56]}]      ;# U63.A3 DQU0
#set_property -dict {LOC H22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[57]}]      ;# U63.B8 DQU1
#set_property -dict {LOC E23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[58]}]      ;# U63.C3 DQU2
#set_property -dict {LOC E22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[59]}]      ;# U63.C7 DQU3
#set_property -dict {LOC F21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[60]}]      ;# U63.C2 DQU4
#set_property -dict {LOC E21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[61]}]      ;# U63.C8 DQU5
#set_property -dict {LOC F24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[62]}]      ;# U63.D3 DQU6
#set_property -dict {LOC F23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[63]}]      ;# U63.D7 DQU7
#set_property -dict {LOC M20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[6]}]    ;# U63.G3 DQSL_T
#set_property -dict {LOC L20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[6]}]    ;# U63.F3 DQSL_C
#set_property -dict {LOC H24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[7]}]    ;# U63.B7 DQSU_T
#set_property -dict {LOC G23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[7]}]    ;# U63.A7 DQSU_C
#set_property -dict {LOC L23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[6]}] ;# U63.E7 DML_B/DBIL_B
#set_property -dict {LOC G22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[7]}] ;# U63.E2 DMU_B/DBIU_B

#set_property -dict {LOC A24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[64]}]      ;# U64.G2 DQL0
#set_property -dict {LOC A23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[65]}]      ;# U64.F7 DQL1
#set_property -dict {LOC C24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[66]}]      ;# U64.H3 DQL2
#set_property -dict {LOC C23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[67]}]      ;# U64.H7 DQL3
#set_property -dict {LOC B23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[68]}]      ;# U64.H2 DQL4
#set_property -dict {LOC B22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[69]}]      ;# U64.H8 DQL5
#set_property -dict {LOC B21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[70]}]      ;# U64.J3 DQL6
#set_property -dict {LOC A21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[71]}]      ;# U64.J7 DQL7
#set_property -dict {LOC D7   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[72]}]      ;# U64.A3 DQU0
#set_property -dict {LOC C7   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[73]}]      ;# U64.B8 DQU1
#set_property -dict {LOC B8   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[74]}]      ;# U64.C3 DQU2
#set_property -dict {LOC B7   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[75]}]      ;# U64.C7 DQU3
#set_property -dict {LOC C10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[76]}]      ;# U64.C2 DQU4
#set_property -dict {LOC B10  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[77]}]      ;# U64.C8 DQU5
#set_property -dict {LOC B11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[78]}]      ;# U64.D3 DQU6
#set_property -dict {LOC A11  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[79]}]      ;# U64.D7 DQU7
#set_property -dict {LOC D22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[8]}]    ;# U64.G3 DQSL_T
#set_property -dict {LOC C22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[8]}]    ;# U64.F3 DQSL_C
#set_property -dict {LOC A9   IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[9]}]    ;# U64.B7 DQSU_T
#set_property -dict {LOC A8   IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[9]}]    ;# U64.A7 DQSU_C
#set_property -dict {LOC E24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[8]}] ;# U64.E7 DML_B/DBIL_B
#set_property -dict {LOC C9   IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[9]}] ;# U64.E2 DMU_B/DBIU_B

# DDR4 C2
# 5x MT40A256M16GE-075E
#set_property -dict {LOC AM27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[0]}]
#set_property -dict {LOC AL27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[1]}]
#set_property -dict {LOC AP26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[2]}]
#set_property -dict {LOC AP25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[3]}]
#set_property -dict {LOC AN28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[4]}]
#set_property -dict {LOC AM28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[5]}]
#set_property -dict {LOC AP28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[6]}]
#set_property -dict {LOC AP27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[7]}]
#set_property -dict {LOC AN26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[8]}]
#set_property -dict {LOC AM26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[9]}]
#set_property -dict {LOC AR28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[10]}]
#set_property -dict {LOC AR27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[11]}]
#set_property -dict {LOC AV25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[12]}]
#set_property -dict {LOC AT25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[13]}]
#set_property -dict {LOC AV28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[14]}]
#set_property -dict {LOC AU26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[15]}]
#set_property -dict {LOC AV26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[16]}]
#set_property -dict {LOC AR25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[0]}]
#set_property -dict {LOC AU28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[1]}]
#set_property -dict {LOC AU27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[0]}]
#set_property -dict {LOC AT26 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_t}]
#set_property -dict {LOC AT27 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_c}]
#set_property -dict {LOC AW28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cke}]
#set_property -dict {LOC AY29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n}]
#set_property -dict {LOC AN25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_act_n}]
#set_property -dict {LOC BB29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_odt}]
#set_property -dict {LOC BF29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_par}]
#set_property -dict {LOC BD35 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_reset_n}]
#set_property -dict {LOC AR29 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_alert_n}]
#set_property -dict {LOC AY35 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_ten}]

#set_property -dict {LOC BD30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[0]}]       ;# U135.G2 DQL0
#set_property -dict {LOC BE30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[1]}]       ;# U135.F7 DQL1
#set_property -dict {LOC BD32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[2]}]       ;# U135.H3 DQL2
#set_property -dict {LOC BE33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[3]}]       ;# U135.H7 DQL3
#set_property -dict {LOC BC33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[4]}]       ;# U135.H2 DQL4
#set_property -dict {LOC BD33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[5]}]       ;# U135.H8 DQL5
#set_property -dict {LOC BC31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[6]}]       ;# U135.J3 DQL6
#set_property -dict {LOC BD31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[7]}]       ;# U135.J7 DQL7
#set_property -dict {LOC BA32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[8]}]       ;# U135.A3 DQU0
#set_property -dict {LOC BB33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[9]}]       ;# U135.B8 DQU1
#set_property -dict {LOC BA30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[10]}]      ;# U135.C3 DQU2
#set_property -dict {LOC BA31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[11]}]      ;# U135.C7 DQU3
#set_property -dict {LOC AW31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[12]}]      ;# U135.C2 DQU4
#set_property -dict {LOC AW32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[13]}]      ;# U135.C8 DQU5
#set_property -dict {LOC AY32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[14]}]      ;# U135.D3 DQU6
#set_property -dict {LOC AY33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[15]}]      ;# U135.D7 DQU7
#set_property -dict {LOC BF30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[0]}]    ;# U135.G3 DQSL_T
#set_property -dict {LOC BF31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[0]}]    ;# U135.F3 DQSL_C
#set_property -dict {LOC AY34 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[1]}]    ;# U135.B7 DQSU_T
#set_property -dict {LOC BA34 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[1]}]    ;# U135.A7 DQSU_C
#set_property -dict {LOC BE32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[0]}] ;# U135.E7 DML_B/DBIL_B
#set_property -dict {LOC BB31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[1]}] ;# U135.E2 DMU_B/DBIU_B

#set_property -dict {LOC AV30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[16]}]      ;# U136.G2 DQL0
#set_property -dict {LOC AW30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[17]}]      ;# U136.F7 DQL1
#set_property -dict {LOC AU33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[18]}]      ;# U136.H3 DQL2
#set_property -dict {LOC AU34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[19]}]      ;# U136.H7 DQL3
#set_property -dict {LOC AT31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[20]}]      ;# U136.H2 DQL4
#set_property -dict {LOC AU32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[21]}]      ;# U136.H8 DQL5
#set_property -dict {LOC AU31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[22]}]      ;# U136.J3 DQL6
#set_property -dict {LOC AV31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[23]}]      ;# U136.J7 DQL7
#set_property -dict {LOC AR33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[24]}]      ;# U136.A3 DQU0
#set_property -dict {LOC AT34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[25]}]      ;# U136.B8 DQU1
#set_property -dict {LOC AT29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[26]}]      ;# U136.C3 DQU2
#set_property -dict {LOC AT30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[27]}]      ;# U136.C7 DQU3
#set_property -dict {LOC AP30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[28]}]      ;# U136.C2 DQU4
#set_property -dict {LOC AR30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[29]}]      ;# U136.C8 DQU5
#set_property -dict {LOC AN30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[30]}]      ;# U136.D3 DQU6
#set_property -dict {LOC AN31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[31]}]      ;# U136.D7 DQU7
#set_property -dict {LOC AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[2]}]    ;# U136.G3 DQSL_T
#set_property -dict {LOC AV29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[2]}]    ;# U136.F3 DQSL_C
#set_property -dict {LOC AP31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[3]}]    ;# U136.B7 DQSU_T
#set_property -dict {LOC AP32 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[3]}]    ;# U136.A7 DQSU_C
#set_property -dict {LOC AV33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[2]}] ;# U136.E7 DML_B/DBIL_B
#set_property -dict {LOC AR32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[3]}] ;# U136.E2 DMU_B/DBIU_B

#set_property -dict {LOC BE34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[32]}]      ;# U137.G2 DQL0
#set_property -dict {LOC BF34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[33]}]      ;# U137.F7 DQL1
#set_property -dict {LOC BC35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[34]}]      ;# U137.H3 DQL2
#set_property -dict {LOC BC36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[35]}]      ;# U137.H7 DQL3
#set_property -dict {LOC BD36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[36]}]      ;# U137.H2 DQL4
#set_property -dict {LOC BE37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[37]}]      ;# U137.H8 DQL5
#set_property -dict {LOC BF36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[38]}]      ;# U137.J3 DQL6
#set_property -dict {LOC BF37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[39]}]      ;# U137.J7 DQL7
#set_property -dict {LOC BD37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[40]}]      ;# U137.A3 DQU0
#set_property -dict {LOC BE38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[41]}]      ;# U137.B8 DQU1
#set_property -dict {LOC BC39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[42]}]      ;# U137.C3 DQU2
#set_property -dict {LOC BD40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[43]}]      ;# U137.C7 DQU3
#set_property -dict {LOC BB38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[44]}]      ;# U137.C2 DQU4
#set_property -dict {LOC BB39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[45]}]      ;# U137.C8 DQU5
#set_property -dict {LOC BC38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[46]}]      ;# U137.D3 DQU6
#set_property -dict {LOC BD38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[47]}]      ;# U137.D7 DQU7
#set_property -dict {LOC BE35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[4]}]    ;# U137.G3 DQSL_T
#set_property -dict {LOC BF35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[4]}]    ;# U137.F3 DQSL_C
#set_property -dict {LOC BE39 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[5]}]    ;# U137.B7 DQSU_T
#set_property -dict {LOC BF39 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[5]}]    ;# U137.A7 DQSU_C
#set_property -dict {LOC BC34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[4]}] ;# U137.E7 DML_B/DBIL_B
#set_property -dict {LOC BE40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[5]}] ;# U137.E2 DMU_B/DBIU_B

#set_property -dict {LOC BB36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[48]}]      ;# U138.G2 DQL0
#set_property -dict {LOC BB37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[49]}]      ;# U138.F7 DQL1
#set_property -dict {LOC BA39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[50]}]      ;# U138.H3 DQL2
#set_property -dict {LOC BA40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[51]}]      ;# U138.H7 DQL3
#set_property -dict {LOC AW40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[52]}]      ;# U138.H2 DQL4
#set_property -dict {LOC AY40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[53]}]      ;# U138.H8 DQL5
#set_property -dict {LOC AY38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[54]}]      ;# U138.J3 DQL6
#set_property -dict {LOC AY39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[55]}]      ;# U138.J7 DQL7
#set_property -dict {LOC AW35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[56]}]      ;# U138.A3 DQU0
#set_property -dict {LOC AW36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[57]}]      ;# U138.B8 DQU1
#set_property -dict {LOC AU40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[58]}]      ;# U138.C3 DQU2
#set_property -dict {LOC AV40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[59]}]      ;# U138.C7 DQU3
#set_property -dict {LOC AU38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[60]}]      ;# U138.C2 DQU4
#set_property -dict {LOC AU39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[61]}]      ;# U138.C8 DQU5
#set_property -dict {LOC AV38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[62]}]      ;# U138.D3 DQU6
#set_property -dict {LOC AV39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[63]}]      ;# U138.D7 DQU7
#set_property -dict {LOC BA35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[6]}]    ;# U138.G3 DQSL_T
#set_property -dict {LOC BA36 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[6]}]    ;# U138.F3 DQSL_C
#set_property -dict {LOC AW37 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[7]}]    ;# U138.B7 DQSU_T
#set_property -dict {LOC AW38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[7]}]    ;# U138.A7 DQSU_C
#set_property -dict {LOC AY37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[6]}] ;# U138.E7 DML_B/DBIL_B
#set_property -dict {LOC AV35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[7]}] ;# U138.E2 DMU_B/DBIU_B

#set_property -dict {LOC BF26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[64]}]      ;# U139.G2 DQL0
#set_property -dict {LOC BF27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[65]}]      ;# U139.F7 DQL1
#set_property -dict {LOC BD28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[66]}]      ;# U139.H3 DQL2
#set_property -dict {LOC BE28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[67]}]      ;# U139.H7 DQL3
#set_property -dict {LOC BD27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[68]}]      ;# U139.H2 DQL4
#set_property -dict {LOC BE27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[69]}]      ;# U139.H8 DQL5
#set_property -dict {LOC BD25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[70]}]      ;# U139.J3 DQL6
#set_property -dict {LOC BD26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[71]}]      ;# U139.J7 DQL7
#set_property -dict {LOC BC25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[72]}]      ;# U139.A3 DQU0
#set_property -dict {LOC BC26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[73]}]      ;# U139.B8 DQU1
#set_property -dict {LOC BB28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[74]}]      ;# U139.C3 DQU2
#set_property -dict {LOC BC28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[75]}]      ;# U139.C7 DQU3
#set_property -dict {LOC AY27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[76]}]      ;# U139.C2 DQU4
#set_property -dict {LOC AY28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[77]}]      ;# U139.C8 DQU5
#set_property -dict {LOC BA27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[78]}]      ;# U139.D3 DQU6
#set_property -dict {LOC BB27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[79]}]      ;# U139.D7 DQU7
#set_property -dict {LOC BE25 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[8]}]    ;# U139.G3 DQSL_T
#set_property -dict {LOC BF25 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[8]}]    ;# U139.F3 DQSL_C
#set_property -dict {LOC BA26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[9]}]    ;# U139.B7 DQSU_T
#set_property -dict {LOC BB26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[9]}]    ;# U139.A7 DQSU_C
#set_property -dict {LOC BE29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[8]}] ;# U139.E7 DML_B/DBIL_B
#set_property -dict {LOC BA29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[9]}] ;# U139.E2 DMU_B/DBIU_B

# QSPI flash
#set_property -dict {LOC AM19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[0]}]
#set_property -dict {LOC AM18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[1]}]
#set_property -dict {LOC AN20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[2]}]
#set_property -dict {LOC AP20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_dq[3]}]
#set_property -dict {LOC BF16 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {qspi_1_cs}]

#set_false_path -to [get_ports {qspi_1_dq[*] qspi_1_cs}]
#set_output_delay 0 [get_ports {qspi_1_dq[*] qspi_1_cs}]
#set_false_path -from [get_ports {qspi_1_dq}]
#set_input_delay 0 [get_ports {qspi_1_dq}]
