# XDC constraints for the Xilinx VCU108 board
# part: xcvu095-ffva2104-2-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1      [current_design]
set_property CONFIG_MODE BPI16                         [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

# System clocks
# 300 MHz
#set_property -dict {LOC G31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_1_p]
#set_property -dict {LOC F31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_1_n]
#create_clock -period 3.333 -name clk_300mhz_1 [get_ports clk_300mhz_1_p]

#set_property -dict {LOC G22  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_2_p]
#set_property -dict {LOC G21  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_2_n]
#create_clock -period 3.333 -name clk_300mhz_2 [get_ports clk_300mhz_2_p]

# 125 MHz
set_property -dict {LOC BC9  IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC BC8  IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# 90 MHz
#set_property -dict {LOC AL20 IOSTANDARD LVCMOS18} [get_ports clk_90mhz]
#create_clock -period 11.111 -name clk_90mhz [get_ports clk_90mhz]

# User SMA clock J34/J35
#set_property -dict {LOC AR14 IOSTANDARD LVDS} [get_ports user_sma_clk_p]
#set_property -dict {LOC AT14 IOSTANDARD LVDS} [get_ports user_sma_clk_n]
#create_clock -period 8.000 -name user_sma_clk [get_ports user_sma_clk_p]

# LEDs
set_property -dict {LOC AT32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AV34 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AY30 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC BB32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC BF32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AV36 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AY35 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC BA37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC E36  IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC E34  IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC M22  IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC D9   IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC A10  IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC AW27 IOSTANDARD LVCMOS12} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC BC40 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC L19  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC C37  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC C38  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# PMOD0
#set_property -dict {LOC BC14 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[0]}]
#set_property -dict {LOC BA10 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[1]}]
#set_property -dict {LOC AW16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[2]}]
#set_property -dict {LOC BB16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[3]}]
#set_property -dict {LOC BC13 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[4]}]
#set_property -dict {LOC BF7  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[5]}]
#set_property -dict {LOC AW12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[6]}]
#set_property -dict {LOC BC16 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {pmod0[7]}]

#set_false_path -to [get_ports {pmod0[*]}]
#set_output_delay 0 [get_ports {pmod0[*]}]

# PMOD1
#set_property -dict {LOC P22  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[0]}]
#set_property -dict {LOC N22  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[1]}]
#set_property -dict {LOC J20  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[2]}]
#set_property -dict {LOC K24  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[3]}]
#set_property -dict {LOC J24  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[4]}]
#set_property -dict {LOC T23  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[5]}]
#set_property -dict {LOC R23  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[6]}]
#set_property -dict {LOC R22  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {pmod1[7]}]

#set_false_path -to [get_ports {pmod1[*]}]
#set_output_delay 0 [get_ports {pmod1[*]}]

# UART
set_property -dict {LOC BE24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC BC24 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC BF24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rts]
set_property -dict {LOC BD22 IOSTANDARD LVCMOS18} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_rts}]
set_output_delay 0 [get_ports {uart_txd uart_rts}]
set_false_path -from [get_ports {uart_rxd uart_cts}]
set_input_delay 0 [get_ports {uart_rxd uart_cts}]

# Gigabit Ethernet SGMII PHY
set_property -dict {LOC AR24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_rx_p]
set_property -dict {LOC AT24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_rx_n]
set_property -dict {LOC AR23 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_tx_p]
set_property -dict {LOC AR22 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_tx_n]
set_property -dict {LOC AT22 IOSTANDARD LVDS_25} [get_ports phy_sgmii_clk_p]
set_property -dict {LOC AU22 IOSTANDARD LVDS_25} [get_ports phy_sgmii_clk_n]
set_property -dict {LOC AU21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_reset_n]
set_property -dict {LOC AT21 IOSTANDARD LVCMOS18} [get_ports phy_int_n]
#set_property -dict {LOC AV24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdio]
#set_property -dict {LOC AV21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdc]

# 625 MHz ref clock from SGMII PHY
#create_clock -period 1.600 -name phy_sgmii_clk [get_ports phy_sgmii_clk_p]

set_false_path -to [get_ports {phy_reset_n}]
set_output_delay 0 [get_ports {phy_reset_n}]
set_false_path -from [get_ports {phy_int_n}]
set_input_delay 0 [get_ports {phy_int_n}]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]

# Bullseye GTY
#set_property -dict {LOC AR45} [get_ports {bullseye_rx_p[0]}] ;# MGTYRXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AR46} [get_ports {bullseye_rx_n[0]}] ;# MGTYRXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AT42} [get_ports {bullseye_tx_p[0]}] ;# MGTYTXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AT43} [get_ports {bullseye_tx_n[0]}] ;# MGTYTXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AN45} [get_ports {bullseye_rx_p[1]}] ;# MGTYRXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AN46} [get_ports {bullseye_rx_n[1]}] ;# MGTYRXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AP42} [get_ports {bullseye_tx_p[1]}] ;# MGTYTXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AP43} [get_ports {bullseye_tx_n[1]}] ;# MGTYTXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL45} [get_ports {bullseye_rx_p[2]}] ;# MGTYRXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL46} [get_ports {bullseye_rx_n[2]}] ;# MGTYRXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AM42} [get_ports {bullseye_tx_p[2]}] ;# MGTYTXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AM43} [get_ports {bullseye_tx_n[2]}] ;# MGTYTXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AJ45} [get_ports {bullseye_rx_p[3]}] ;# MGTYRXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AJ46} [get_ports {bullseye_rx_n[3]}] ;# MGTYRXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL40} [get_ports {bullseye_tx_p[3]}] ;# MGTYTXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL41} [get_ports {bullseye_tx_n[3]}] ;# MGTYTXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AK38} [get_ports bullseye_mgt_refclk_0_p] ;# MGTREFCLK0P_126 from J87 P19
#set_property -dict {LOC AK39} [get_ports bullseye_mgt_refclk_0_n] ;# MGTREFCLK0N_126 from J87 P20
#set_property -dict {LOC AH38} [get_ports bullseye_mgt_refclk_1_p] ;# MGTREFCLK1P_126 from U32 SI570 via U104 SI53340
#set_property -dict {LOC AH39} [get_ports bullseye_mgt_refclk_1_n] ;# MGTREFCLK1N_126 from U32 SI570 via U104 SI53340

# 156.25 MHz MGT reference clock
#create_clock -period 6.4 -name bullseye_mgt_refclk [get_ports bullseye_mgt_refclk_1_p]

# QSFP28 Interface
#set_property -dict {LOC AG45} [get_ports {qsfp_rx_p[0]}] ;# MGTYRXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AG46} [get_ports {qsfp_rx_n[0]}] ;# MGTYRXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AK42} [get_ports {qsfp_tx_p[0]}] ;# MGTYTXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AK43} [get_ports {qsfp_tx_n[0]}] ;# MGTYTXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AF43} [get_ports {qsfp_rx_p[1]}] ;# MGTYRXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AF44} [get_ports {qsfp_rx_n[1]}] ;# MGTYRXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AJ40} [get_ports {qsfp_tx_p[1]}] ;# MGTYTXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AJ41} [get_ports {qsfp_tx_n[1]}] ;# MGTYTXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE45} [get_ports {qsfp_rx_p[2]}] ;# MGTYRXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE46} [get_ports {qsfp_rx_n[2]}] ;# MGTYRXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AG40} [get_ports {qsfp_tx_p[2]}] ;# MGTYTXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AG41} [get_ports {qsfp_tx_n[2]}] ;# MGTYTXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AD43} [get_ports {qsfp_rx_p[3]}] ;# MGTYRXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AD44} [get_ports {qsfp_rx_n[3]}] ;# MGTYRXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE40} [get_ports {qsfp_tx_p[3]}] ;# MGTYTXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE41} [get_ports {qsfp_tx_n[3]}] ;# MGTYTXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AF38} [get_ports qsfp_mgt_refclk_0_p] ;# MGTREFCLK0P_127 from U32 SI570 via U102 SI53340
#set_property -dict {LOC AF39} [get_ports qsfp_mgt_refclk_0_n] ;# MGTREFCLK0N_127 from U32 SI570 via U102 SI53340
#set_property -dict {LOC AD38} [get_ports qsfp_mgt_refclk_1_p] ;# MGTREFCLK1P_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AD39} [get_ports qsfp_mgt_refclk_1_n] ;# MGTREFCLK1N_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AG34 IOSTANDARD LVDS} [get_ports qsfp_recclk_p] ;# to U57 CKIN1 SI5328
#set_property -dict {LOC AH35 IOSTANDARD LVDS} [get_ports qsfp_recclk_n] ;# to U57 CKIN1 SI5328
#set_property -dict {LOC AL24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_modsell]
#set_property -dict {LOC AM24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_resetl]
#set_property -dict {LOC AL25 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_modprsl]
#set_property -dict {LOC AL21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_intl]
#set_property -dict {LOC AM21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_lpmode]

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name qsfp_mgt_refclk_0 [get_ports qsfp_mgt_refclk_0_p]

#set_false_path -to [get_ports {qsfp_modsell qsfp_resetl qsfp_lpmode}]
#set_output_delay 0 [get_ports {qsfp_modsell qsfp_resetl qsfp_lpmode}]
#set_false_path -from [get_ports {qsfp_modprsl qsfp_intl}]
#set_input_delay 0 [get_ports {qsfp_modprsl qsfp_intl}]

# CFP2 GTY
#set_property -dict {LOC J45 } [get_ports {cfp2_rx_p[0]}] ;# MGTYRXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC J46 } [get_ports {cfp2_rx_n[0]}] ;# MGTYRXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC F42 } [get_ports {cfp2_tx_p[0]}] ;# MGTYTXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC F43 } [get_ports {cfp2_tx_n[0]}] ;# MGTYTXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC N45 } [get_ports {cfp2_rx_p[1]}] ;# MGTYRXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC N46 } [get_ports {cfp2_rx_n[1]}] ;# MGTYRXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC K42 } [get_ports {cfp2_tx_p[1]}] ;# MGTYTXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC K43 } [get_ports {cfp2_tx_n[1]}] ;# MGTYTXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC R45 } [get_ports {cfp2_rx_p[2]}] ;# MGTYRXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC R46 } [get_ports {cfp2_rx_n[2]}] ;# MGTYRXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC M42 } [get_ports {cfp2_tx_p[2]}] ;# MGTYTXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC M43 } [get_ports {cfp2_tx_n[2]}] ;# MGTYTXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC L45 } [get_ports {cfp2_rx_p[3]}] ;# MGTYRXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC L46 } [get_ports {cfp2_rx_n[3]}] ;# MGTYRXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC H42 } [get_ports {cfp2_tx_p[3]}] ;# MGTYTXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC H43 } [get_ports {cfp2_tx_n[3]}] ;# MGTYTXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC Y43 } [get_ports {cfp2_rx_p[4]}] ;# MGTYRXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC Y44 } [get_ports {cfp2_rx_n[4]}] ;# MGTYRXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U40 } [get_ports {cfp2_tx_p[4]}] ;# MGTYTXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U41 } [get_ports {cfp2_tx_n[4]}] ;# MGTYTXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U45 } [get_ports {cfp2_rx_p[5]}] ;# MGTYRXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC U46 } [get_ports {cfp2_rx_n[5]}] ;# MGTYRXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC P42 } [get_ports {cfp2_tx_p[5]}] ;# MGTYTXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC P43 } [get_ports {cfp2_tx_n[5]}] ;# MGTYTXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC W45 } [get_ports {cfp2_rx_p[6]}] ;# MGTYRXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC W46 } [get_ports {cfp2_rx_n[6]}] ;# MGTYRXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC T42 } [get_ports {cfp2_tx_p[6]}] ;# MGTYTXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC T43 } [get_ports {cfp2_tx_n[6]}] ;# MGTYTXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC AA45} [get_ports {cfp2_rx_p[7]}] ;# MGTYRXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA46} [get_ports {cfp2_rx_n[7]}] ;# MGTYRXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC W40 } [get_ports {cfp2_tx_p[7]}] ;# MGTYTXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC W41 } [get_ports {cfp2_tx_n[7]}] ;# MGTYTXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AB43} [get_ports {cfp2_rx_p[8]}] ;# MGTYRXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AB44} [get_ports {cfp2_rx_n[8]}] ;# MGTYRXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA40} [get_ports {cfp2_tx_p[8]}] ;# MGTYTXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA41} [get_ports {cfp2_tx_n[8]}] ;# MGTYTXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC45} [get_ports {cfp2_rx_p[9]}] ;# MGTYRXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC46} [get_ports {cfp2_rx_n[9]}] ;# MGTYRXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC40} [get_ports {cfp2_tx_p[9]}] ;# MGTYTXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC41} [get_ports {cfp2_tx_n[9]}] ;# MGTYTXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC V38 } [get_ports cfp2_mgt_refclk_0_p] ;# MGTREFCLK0P_129 from U32 SI570 via U104 SI53340
#set_property -dict {LOC V39 } [get_ports cfp2_mgt_refclk_0_n] ;# MGTREFCLK0N_129 from U32 SI570 via U104 SI53340
#set_property -dict {LOC T38 } [get_ports cfp2_mgt_refclk_1_p] ;# MGTREFCLK1P_129 from U57 CKOUT1 SI5328
#set_property -dict {LOC T39 } [get_ports cfp2_mgt_refclk_1_n] ;# MGTREFCLK1N_129 from U57 CKOUT1 SI5328
#set_property -dict {LOC BA21 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[0]}]
#set_property -dict {LOC AY24 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[1]}]
#set_property -dict {LOC AY23 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[2]}]
#set_property -dict {LOC BB24 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[0]}]
#set_property -dict {LOC BB23 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[1]}]
#set_property -dict {LOC BB22 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[2]}]
#set_property -dict {LOC BA22 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[0]}]
#set_property -dict {LOC AW25 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[1]}]
#set_property -dict {LOC AY25 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[2]}]
#set_property -dict {LOC AY22 IOSTANDARD LVCMOS18} [get_ports cfp2_tx_dis]
#set_property -dict {LOC BB21 IOSTANDARD LVCMOS18} [get_ports cfp2_rx_los]
#set_property -dict {LOC BC21 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_lopwr]
#set_property -dict {LOC BD21 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_rstn]
#set_property -dict {LOC BA25 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_abs]
#set_property -dict {LOC BA24 IOSTANDARD LVCMOS18} [get_ports cfp2_glb_alrmn]
#set_property -dict {LOC BE22 IOSTANDARD LVCMOS18} [get_ports cfp2_mdc]
#set_property -dict {LOC BF22 IOSTANDARD LVCMOS18} [get_ports cfp2_mdio]

# 156.25 MHz MGT reference clock
#create_clock -period 6.4 -name cfp2_mgt_refclk [get_ports cfp2_mgt_refclk_0_p]

# I2C interface
#set_property -dict {LOC AN21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
#set_property -dict {LOC AP21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

#set_false_path -to [get_ports {i2c_sda i2c_scl}]
#set_output_delay 0 [get_ports {i2c_sda i2c_scl}]
#set_false_path -from [get_ports {i2c_sda i2c_scl}]
#set_input_delay 0 [get_ports {i2c_sda i2c_scl}]

# PCIe Interface
#set_property -dict {LOC AJ4 } [get_ports {pcie_rx_p[0]}] ;# MGTHRXP3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AJ3 } [get_ports {pcie_rx_n[0]}] ;# MGTHRXN3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AP7 } [get_ports {pcie_tx_p[0]}] ;# MGTHTXP3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AP6 } [get_ports {pcie_tx_n[0]}] ;# MGTHTXN3_225 GTHE3_CHANNEL_X0Y7 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AK2 } [get_ports {pcie_rx_p[1]}] ;# MGTHRXP2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AK1 } [get_ports {pcie_rx_n[1]}] ;# MGTHRXN2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AR5 } [get_ports {pcie_tx_p[1]}] ;# MGTHTXP2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AR4 } [get_ports {pcie_tx_n[1]}] ;# MGTHTXN2_225 GTHE3_CHANNEL_X0Y6 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AM2 } [get_ports {pcie_rx_p[2]}] ;# MGTHRXP1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AM1 } [get_ports {pcie_rx_n[2]}] ;# MGTHRXN1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AT7 } [get_ports {pcie_tx_p[2]}] ;# MGTHTXP1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AT6 } [get_ports {pcie_tx_n[2]}] ;# MGTHTXN1_225 GTHE3_CHANNEL_X0Y5 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AP2 } [get_ports {pcie_rx_p[3]}] ;# MGTHRXP0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AP1 } [get_ports {pcie_rx_n[3]}] ;# MGTHRXN0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AU5 } [get_ports {pcie_tx_p[3]}] ;# MGTHTXP0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AU4 } [get_ports {pcie_tx_n[3]}] ;# MGTHTXN0_225 GTHE3_CHANNEL_X0Y4 / GTHE3_COMMON_X0Y1
#set_property -dict {LOC AT2 } [get_ports {pcie_rx_p[4]}] ;# MGTHRXP3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AT1 } [get_ports {pcie_rx_n[4]}] ;# MGTHRXN3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AW5 } [get_ports {pcie_tx_p[4]}] ;# MGTHTXP3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AW4 } [get_ports {pcie_tx_n[4]}] ;# MGTHTXN3_224 GTHE3_CHANNEL_X0Y3 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AV2 } [get_ports {pcie_rx_p[5]}] ;# MGTHRXP2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AV1 } [get_ports {pcie_rx_n[5]}] ;# MGTHRXN2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BA5 } [get_ports {pcie_tx_p[5]}] ;# MGTHTXP2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BA4 } [get_ports {pcie_tx_n[5]}] ;# MGTHTXN2_224 GTHE3_CHANNEL_X0Y2 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AY2 } [get_ports {pcie_rx_p[6]}] ;# MGTHRXP1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AY1 } [get_ports {pcie_rx_n[6]}] ;# MGTHRXN1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BC5 } [get_ports {pcie_tx_p[6]}] ;# MGTHTXP1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BC4 } [get_ports {pcie_tx_n[6]}] ;# MGTHTXN1_224 GTHE3_CHANNEL_X0Y1 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BB2 } [get_ports {pcie_rx_p[7]}] ;# MGTHRXP0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BB1 } [get_ports {pcie_rx_n[7]}] ;# MGTHRXN0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BE5 } [get_ports {pcie_tx_p[7]}] ;# MGTHTXP0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC BE4 } [get_ports {pcie_tx_n[7]}] ;# MGTHTXN0_224 GTHE3_CHANNEL_X0Y0 / GTHE3_COMMON_X0Y0
#set_property -dict {LOC AL9 } [get_ports pcie_mgt_refclk_p] ;# MGTREFCLK0P_225
#set_property -dict {LOC AL8 } [get_ports pcie_mgt_refclk_n] ;# MGTREFCLK0N_225
#set_property -dict {LOC AM17 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_mgt_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# FMC interface
# FMC HPC0 J22
#set_property -dict {LOC AY9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[0]"]  ;# J22.G9  LA00_P_CC
#set_property -dict {LOC BA9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[0]"]  ;# J22.G10 LA00_N_CC
#set_property -dict {LOC BC10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[1]"]  ;# J22.D8  LA01_P_CC
#set_property -dict {LOC BD10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[1]"]  ;# J22.D9  LA01_N_CC
#set_property -dict {LOC BA7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[2]"]  ;# J22.H7  LA02_P
#set_property -dict {LOC BB7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[2]"]  ;# J22.H8  LA02_N
#set_property -dict {LOC BD8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[3]"]  ;# J22.G12 LA03_P
#set_property -dict {LOC BD7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[3]"]  ;# J22.G13 LA03_N
#set_property -dict {LOC BE8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[4]"]  ;# J22.H10 LA04_P
#set_property -dict {LOC BE7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[4]"]  ;# J22.H11 LA04_N
#set_property -dict {LOC BF12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[5]"]  ;# J22.D11 LA05_P
#set_property -dict {LOC BF11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[5]"]  ;# J22.D12 LA05_N
#set_property -dict {LOC BE10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[6]"]  ;# J22.C10 LA06_P
#set_property -dict {LOC BE9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[6]"]  ;# J22.C11 LA06_N
#set_property -dict {LOC BD12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[7]"]  ;# J22.H13 LA07_P
#set_property -dict {LOC BE12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[7]"]  ;# J22.H14 LA07_N
#set_property -dict {LOC BF10 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[8]"]  ;# J22.G12 LA08_P
#set_property -dict {LOC BF9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[8]"]  ;# J22.G13 LA08_N
#set_property -dict {LOC BD13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[9]"]  ;# J22.D14 LA09_P
#set_property -dict {LOC BE13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[9]"]  ;# J22.D15 LA09_N
#set_property -dict {LOC BE14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[10]"] ;# J22.C14 LA10_P
#set_property -dict {LOC BF14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[10]"] ;# J22.C15 LA10_N
#set_property -dict {LOC BC11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[11]"] ;# J22.H16 LA11_P
#set_property -dict {LOC BD11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[11]"] ;# J22.H17 LA11_N
#set_property -dict {LOC BE15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[12]"] ;# J22.G15 LA12_P
#set_property -dict {LOC BF15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[12]"] ;# J22.G16 LA12_N
#set_property -dict {LOC BA14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[13]"] ;# J22.D17 LA13_P
#set_property -dict {LOC BB14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[13]"] ;# J22.D18 LA13_N
#set_property -dict {LOC BB13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[14]"] ;# J22.C18 LA14_P
#set_property -dict {LOC BB12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[14]"] ;# J22.C19 LA14_N
#set_property -dict {LOC AV9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[15]"] ;# J22.H19 LA15_P
#set_property -dict {LOC AV8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[15]"] ;# J22.H20 LA15_N
#set_property -dict {LOC AY8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[16]"] ;# J22.G18 LA16_P
#set_property -dict {LOC AY7  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[16]"] ;# J22.G19 LA16_N
#set_property -dict {LOC AV14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[17]"] ;# J22.D20 LA17_P_CC
#set_property -dict {LOC AV13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[17]"] ;# J22.D21 LA17_N_CC
#set_property -dict {LOC AP13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[18]"] ;# J22.C22 LA18_P_CC
#set_property -dict {LOC AR13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[18]"] ;# J22.C23 LA18_N_CC
#set_property -dict {LOC AV15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[19]"] ;# J22.H22 LA19_P
#set_property -dict {LOC AW15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[19]"] ;# J22.H23 LA19_N
#set_property -dict {LOC AY15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[20]"] ;# J22.G21 LA20_P
#set_property -dict {LOC AY14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[20]"] ;# J22.G22 LA20_N
#set_property -dict {LOC AN16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[21]"] ;# J22.H25 LA21_P
#set_property -dict {LOC AP16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[21]"] ;# J22.H26 LA21_N
#set_property -dict {LOC AN15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[22]"] ;# J22.G24 LA22_P
#set_property -dict {LOC AP15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[22]"] ;# J22.G25 LA22_N
#set_property -dict {LOC AT16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[23]"] ;# J22.D23 LA23_P
#set_property -dict {LOC AT15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[23]"] ;# J22.D24 LA23_N
#set_property -dict {LOC AK15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[24]"] ;# J22.H28 LA24_P
#set_property -dict {LOC AL15 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[24]"] ;# J22.H29 LA24_N
#set_property -dict {LOC AM13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[25]"] ;# J22.G27 LA25_P
#set_property -dict {LOC AM12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[25]"] ;# J22.G28 LA25_N
#set_property -dict {LOC AL14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[26]"] ;# J22.D26 LA26_P
#set_property -dict {LOC AM14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[26]"] ;# J22.D27 LA26_N
#set_property -dict {LOC AN14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[27]"] ;# J22.C26 LA27_P
#set_property -dict {LOC AN13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[27]"] ;# J22.C27 LA27_N
#set_property -dict {LOC AJ13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[28]"] ;# J22.H31 LA28_P
#set_property -dict {LOC AJ12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[28]"] ;# J22.H32 LA28_N
#set_property -dict {LOC AK14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[29]"] ;# J22.G30 LA29_P
#set_property -dict {LOC AK13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[29]"] ;# J22.G31 LA29_N
#set_property -dict {LOC AK12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[30]"] ;# J22.H34 LA30_P
#set_property -dict {LOC AL12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[30]"] ;# J22.H35 LA30_N
#set_property -dict {LOC AP12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[31]"] ;# J22.G33 LA31_P
#set_property -dict {LOC AR12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[31]"] ;# J22.G34 LA31_N
#set_property -dict {LOC AU11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[32]"] ;# J22.H37 LA32_P
#set_property -dict {LOC AV11 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[32]"] ;# J22.H38 LA32_N
#set_property -dict {LOC AU16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_p[33]"] ;# J22.G36 LA33_P
#set_property -dict {LOC AV16 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_la_n[33]"] ;# J22.G37 LA33_N

#set_property -dict {LOC N14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[0]"]  ;# J22.F4  HA00_P_CC
#set_property -dict {LOC N13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[0]"]  ;# J22.F5  HA00_N_CC
#set_property -dict {LOC T14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[1]"]  ;# J22.E2  HA01_P_CC
#set_property -dict {LOC R13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[1]"]  ;# J22.E3  HA01_N_CC
#set_property -dict {LOC T16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[2]"]  ;# J22.K7  HA02_P
#set_property -dict {LOC T15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[2]"]  ;# J22.K8  HA02_N
#set_property -dict {LOC K11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[3]"]  ;# J22.J6  HA03_P
#set_property -dict {LOC J11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[3]"]  ;# J22.J7  HA03_N
#set_property -dict {LOC AA13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[4]"]  ;# J22.F7  HA04_P
#set_property -dict {LOC Y13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[4]"]  ;# J22.F8  HA04_N
#set_property -dict {LOC AA12 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[5]"]  ;# J22.E6  HA05_P
#set_property -dict {LOC Y12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[5]"]  ;# J22.E7  HA05_N
#set_property -dict {LOC P15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[6]"]  ;# J22.K10 HA06_P
#set_property -dict {LOC N15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[6]"]  ;# J22.K11 HA06_N
#set_property -dict {LOC R12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[7]"]  ;# J22.J9  HA07_P
#set_property -dict {LOC P12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[7]"]  ;# J22.J10 HA07_N
#set_property -dict {LOC W12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[8]"]  ;# J22.F10 HA08_P
#set_property -dict {LOC V12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[8]"]  ;# J22.F11 HA08_N
#set_property -dict {LOC AA14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[9]"]  ;# J22.E9  HA09_P
#set_property -dict {LOC Y14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[9]"]  ;# J22.E10 HA09_N
#set_property -dict {LOC K12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[10]"] ;# J22.K13 HA10_P
#set_property -dict {LOC J12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[10]"] ;# J22.K14 HA10_N
#set_property -dict {LOC M11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[11]"] ;# J22.J12 HA11_P
#set_property -dict {LOC L11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[11]"] ;# J22.J13 HA11_N
#set_property -dict {LOC V15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[12]"] ;# J22.F13 HA12_P
#set_property -dict {LOC U15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[12]"] ;# J22.F14 HA12_N
#set_property -dict {LOC W14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[13]"] ;# J22.E12 HA13_P
#set_property -dict {LOC V14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[13]"] ;# J22.E13 HA13_N
#set_property -dict {LOC K14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[14]"] ;# J22.J15 HA14_P
#set_property -dict {LOC K13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[14]"] ;# J22.J16 HA14_N
#set_property -dict {LOC V13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[15]"] ;# J22.F14 HA15_P
#set_property -dict {LOC U12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[15]"] ;# J22.F16 HA15_N
#set_property -dict {LOC V16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[16]"] ;# J22.E15 HA16_P
#set_property -dict {LOC U16  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[16]"] ;# J22.E16 HA16_N
#set_property -dict {LOC U13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[17]"] ;# J22.K16 HA17_P_CC
#set_property -dict {LOC T13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[17]"] ;# J22.K17 HA17_N_CC
#set_property -dict {LOC L14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[18]"] ;# J22.J18 HA18_P_CC
#set_property -dict {LOC L13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[18]"] ;# J22.J19 HA18_N_CC
#set_property -dict {LOC R14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[19]"] ;# J22.F19 HA19_P
#set_property -dict {LOC P14  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[19]"] ;# J22.F20 HA19_N
#set_property -dict {LOC R11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[20]"] ;# J22.E18 HA20_P
#set_property -dict {LOC P11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[20]"] ;# J22.E19 HA20_N
#set_property -dict {LOC M13  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[21]"] ;# J22.K19 HA21_P
#set_property -dict {LOC M12  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[21]"] ;# J22.K20 HA21_N
#set_property -dict {LOC M15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[22]"] ;# J22.J21 HA22_P
#set_property -dict {LOC L15  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[22]"] ;# J22.J22 HA22_N
#set_property -dict {LOC U11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_p[23]"] ;# J22.K22 HA23_P
#set_property -dict {LOC T11  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_ha_n[23]"] ;# J22.K23 HA23_N

#set_property -dict {LOC BB9  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_clk0_m2c_p"] ;# J22.H4 CLK0_M2C_P
#set_property -dict {LOC BB8  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_clk0_m2c_n"] ;# J22.H5 CLK0_M2C_N
#set_property -dict {LOC AU14 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_clk1_m2c_p"] ;# J22.G2 CLK1_M2C_P
#set_property -dict {LOC AU13 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc0_clk1_m2c_n"] ;# J22.G3 CLK1_M2C_N

#set_property -dict {LOC AP22 IOSTANDARD LVCMOS18} [get_ports {fmc_hpc0_pg_m2c}]      ;# J22.F1 PG_M2C
#set_property -dict {LOC AL19 IOSTANDARD LVCMOS18} [get_ports {fmc_hpc0_prsnt_m2c_l}] ;# J22.H2 PRSNT_M2C_L

#set_property -dict {LOC G5  } [get_ports {fmc_hpc0_dp_c2m_p[0]}] ;# MGTHTXP0_230 GTHE3_CHANNEL_X0Y24 / GTHE3_COMMON_X0Y6 from J22.C2  DP0_C2M_P
#set_property -dict {LOC G4  } [get_ports {fmc_hpc0_dp_c2m_n[0]}] ;# MGTHTXN0_230 GTHE3_CHANNEL_X0Y24 / GTHE3_COMMON_X0Y6 from J22.C3  DP0_C2M_N
#set_property -dict {LOC K2  } [get_ports {fmc_hpc0_dp_m2c_p[0]}] ;# MGTHRXP0_230 GTHE3_CHANNEL_X0Y24 / GTHE3_COMMON_X0Y6 from J22.C6  DP0_M2C_P
#set_property -dict {LOC K1  } [get_ports {fmc_hpc0_dp_m2c_n[0]}] ;# MGTHRXN0_230 GTHE3_CHANNEL_X0Y24 / GTHE3_COMMON_X0Y6 from J22.C7  DP0_M2C_N
#set_property -dict {LOC F7  } [get_ports {fmc_hpc0_dp_c2m_p[1]}] ;# MGTHTXP1_230 GTHE3_CHANNEL_X0Y25 / GTHE3_COMMON_X0Y6 from J22.A22 DP1_C2M_P
#set_property -dict {LOC F6  } [get_ports {fmc_hpc0_dp_c2m_n[1]}] ;# MGTHTXN1_230 GTHE3_CHANNEL_X0Y25 / GTHE3_COMMON_X0Y6 from J22.A23 DP1_C2M_N
#set_property -dict {LOC H2  } [get_ports {fmc_hpc0_dp_m2c_p[1]}] ;# MGTHRXP1_230 GTHE3_CHANNEL_X0Y25 / GTHE3_COMMON_X0Y6 from J22.A2  DP1_M2C_P
#set_property -dict {LOC H1  } [get_ports {fmc_hpc0_dp_m2c_n[1]}] ;# MGTHRXN1_230 GTHE3_CHANNEL_X0Y25 / GTHE3_COMMON_X0Y6 from J22.A3  DP1_M2C_N
#set_property -dict {LOC E5  } [get_ports {fmc_hpc0_dp_c2m_p[2]}] ;# MGTHTXP2_230 GTHE3_CHANNEL_X0Y26 / GTHE3_COMMON_X0Y6 from J22.A26 DP2_C2M_P
#set_property -dict {LOC E4  } [get_ports {fmc_hpc0_dp_c2m_n[2]}] ;# MGTHTXN2_230 GTHE3_CHANNEL_X0Y26 / GTHE3_COMMON_X0Y6 from J22.A27 DP2_C2M_N
#set_property -dict {LOC F2  } [get_ports {fmc_hpc0_dp_m2c_p[2]}] ;# MGTHRXP2_230 GTHE3_CHANNEL_X0Y26 / GTHE3_COMMON_X0Y6 from J22.A6  DP2_M2C_P
#set_property -dict {LOC F1  } [get_ports {fmc_hpc0_dp_m2c_n[2]}] ;# MGTHRXN2_230 GTHE3_CHANNEL_X0Y26 / GTHE3_COMMON_X0Y6 from J22.A7  DP2_M2C_N
#set_property -dict {LOC C5  } [get_ports {fmc_hpc0_dp_c2m_p[3]}] ;# MGTHTXP3_230 GTHE3_CHANNEL_X0Y27 / GTHE3_COMMON_X0Y6 from J22.A30 DP3_C2M_P
#set_property -dict {LOC C4  } [get_ports {fmc_hpc0_dp_c2m_n[3]}] ;# MGTHTXN3_230 GTHE3_CHANNEL_X0Y27 / GTHE3_COMMON_X0Y6 from J22.A31 DP3_C2M_N
#set_property -dict {LOC D2  } [get_ports {fmc_hpc0_dp_m2c_p[3]}] ;# MGTHRXP3_230 GTHE3_CHANNEL_X0Y27 / GTHE3_COMMON_X0Y6 from J22.A10 DP3_M2C_P
#set_property -dict {LOC D1  } [get_ports {fmc_hpc0_dp_m2c_n[3]}] ;# MGTHRXN3_230 GTHE3_CHANNEL_X0Y27 / GTHE3_COMMON_X0Y6 from J22.A11 DP3_M2C_N

#set_property -dict {LOC L5  } [get_ports {fmc_hpc0_dp_c2m_p[4]}] ;# MGTHTXP0_229 GTHE3_CHANNEL_X0Y20 / GTHE3_COMMON_X0Y5 from J22.A34 DP4_C2M_P
#set_property -dict {LOC L4  } [get_ports {fmc_hpc0_dp_c2m_n[4]}] ;# MGTHTXN0_229 GTHE3_CHANNEL_X0Y20 / GTHE3_COMMON_X0Y5 from J22.A35 DP4_C2M_N
#set_property -dict {LOC T2  } [get_ports {fmc_hpc0_dp_m2c_p[4]}] ;# MGTHRXP0_229 GTHE3_CHANNEL_X0Y20 / GTHE3_COMMON_X0Y5 from J22.A14 DP4_M2C_P
#set_property -dict {LOC T1  } [get_ports {fmc_hpc0_dp_m2c_n[4]}] ;# MGTHRXN0_229 GTHE3_CHANNEL_X0Y20 / GTHE3_COMMON_X0Y5 from J22.A15 DP4_M2C_N
#set_property -dict {LOC K7  } [get_ports {fmc_hpc0_dp_c2m_p[5]}] ;# MGTHTXP1_229 GTHE3_CHANNEL_X0Y21 / GTHE3_COMMON_X0Y5 from J22.A38 DP5_C2M_P
#set_property -dict {LOC K6  } [get_ports {fmc_hpc0_dp_c2m_n[5]}] ;# MGTHTXN1_229 GTHE3_CHANNEL_X0Y21 / GTHE3_COMMON_X0Y5 from J22.A39 DP5_C2M_N
#set_property -dict {LOC R4  } [get_ports {fmc_hpc0_dp_m2c_p[5]}] ;# MGTHRXP1_229 GTHE3_CHANNEL_X0Y21 / GTHE3_COMMON_X0Y5 from J22.A18 DP5_M2C_P
#set_property -dict {LOC R3  } [get_ports {fmc_hpc0_dp_m2c_n[5]}] ;# MGTHRXN1_229 GTHE3_CHANNEL_X0Y21 / GTHE3_COMMON_X0Y5 from J22.A19 DP5_M2C_N
#set_property -dict {LOC J5  } [get_ports {fmc_hpc0_dp_c2m_p[6]}] ;# MGTHTXP2_229 GTHE3_CHANNEL_X0Y22 / GTHE3_COMMON_X0Y5 from J22.B36 DP6_C2M_P
#set_property -dict {LOC J4  } [get_ports {fmc_hpc0_dp_c2m_n[6]}] ;# MGTHTXN2_229 GTHE3_CHANNEL_X0Y22 / GTHE3_COMMON_X0Y5 from J22.B37 DP6_C2M_N
#set_property -dict {LOC P2  } [get_ports {fmc_hpc0_dp_m2c_p[6]}] ;# MGTHRXP2_229 GTHE3_CHANNEL_X0Y22 / GTHE3_COMMON_X0Y5 from J22.B16 DP6_M2C_P
#set_property -dict {LOC P1  } [get_ports {fmc_hpc0_dp_m2c_n[6]}] ;# MGTHRXN2_229 GTHE3_CHANNEL_X0Y22 / GTHE3_COMMON_X0Y5 from J22.B17 DP6_M2C_N
#set_property -dict {LOC H7  } [get_ports {fmc_hpc0_dp_c2m_p[7]}] ;# MGTHTXP3_229 GTHE3_CHANNEL_X0Y23 / GTHE3_COMMON_X0Y5 from J22.B32 DP7_C2M_P
#set_property -dict {LOC H6  } [get_ports {fmc_hpc0_dp_c2m_n[7]}] ;# MGTHTXN3_229 GTHE3_CHANNEL_X0Y23 / GTHE3_COMMON_X0Y5 from J22.B33 DP7_C2M_N
#set_property -dict {LOC M2  } [get_ports {fmc_hpc0_dp_m2c_p[7]}] ;# MGTHRXP3_229 GTHE3_CHANNEL_X0Y23 / GTHE3_COMMON_X0Y5 from J22.B12 DP7_M2C_P
#set_property -dict {LOC M1  } [get_ports {fmc_hpc0_dp_m2c_n[7]}] ;# MGTHRXN3_229 GTHE3_CHANNEL_X0Y23 / GTHE3_COMMON_X0Y5 from J22.B13 DP7_M2C_N
#set_property -dict {LOC R9  } [get_ports fmc_hpc0_mgt_refclk_0_p] ;# MGTREFCLK0P_229 from J22.D4 GBTCLK0_M2C_P
#set_property -dict {LOC R8  } [get_ports fmc_hpc0_mgt_refclk_0_n] ;# MGTREFCLK0N_229 from J22.D5 GBTCLK0_M2C_N
#set_property -dict {LOC N9  } [get_ports fmc_hpc0_mgt_refclk_1_p] ;# MGTREFCLK1P_229 from J22.B20 GBTCLK1_M2C_P
#set_property -dict {LOC N8  } [get_ports fmc_hpc0_mgt_refclk_1_n] ;# MGTREFCLK1N_229 from J22.B21 GBTCLK1_M2C_N

# reference clock
#create_clock -period 6.400 -name fmc_hpc0_mgt_refclk_0 [get_ports fmc_hpc0_mgt_refclk_0_p]
#create_clock -period 6.400 -name fmc_hpc0_mgt_refclk_1 [get_ports fmc_hpc0_mgt_refclk_1_p]

#set_property -dict {LOC V7  } [get_ports {fmc_hpc0_dp_c2m_p[8]}] ;# MGTHTXP0_228 GTHE3_CHANNEL_X0Y16 / GTHE3_COMMON_X0Y4 from J22.B28 DP8_C2M_P
#set_property -dict {LOC V6  } [get_ports {fmc_hpc0_dp_c2m_n[8]}] ;# MGTHTXN0_228 GTHE3_CHANNEL_X0Y16 / GTHE3_COMMON_X0Y4 from J22.B29 DP8_C2M_N
#set_property -dict {LOC Y2  } [get_ports {fmc_hpc0_dp_m2c_p[8]}] ;# MGTHRXP0_228 GTHE3_CHANNEL_X0Y16 / GTHE3_COMMON_X0Y4 from J22.B8  DP8_M2C_P
#set_property -dict {LOC Y1  } [get_ports {fmc_hpc0_dp_m2c_n[8]}] ;# MGTHRXN0_228 GTHE3_CHANNEL_X0Y16 / GTHE3_COMMON_X0Y4 from J22.B9  DP8_M2C_N
#set_property -dict {LOC T7  } [get_ports {fmc_hpc0_dp_c2m_p[9]}] ;# MGTHTXP1_228 GTHE3_CHANNEL_X0Y17 / GTHE3_COMMON_X0Y4 from J22.B24 DP9_C2M_P
#set_property -dict {LOC T6  } [get_ports {fmc_hpc0_dp_c2m_n[9]}] ;# MGTHTXN1_228 GTHE3_CHANNEL_X0Y17 / GTHE3_COMMON_X0Y4 from J22.B25 DP9_C2M_N
#set_property -dict {LOC W4  } [get_ports {fmc_hpc0_dp_m2c_p[9]}] ;# MGTHRXP1_228 GTHE3_CHANNEL_X0Y17 / GTHE3_COMMON_X0Y4 from J22.B4  DP9_M2C_P
#set_property -dict {LOC W3  } [get_ports {fmc_hpc0_dp_m2c_n[9]}] ;# MGTHRXN1_228 GTHE3_CHANNEL_X0Y17 / GTHE3_COMMON_X0Y4 from J22.B5  DP9_M2C_N
#set_property -dict {LOC W9  } [get_ports fmc_hpc0_mgt_refclk_2_p] ;# MGTREFCLK0P_228 from from J87 P1
#set_property -dict {LOC W8  } [get_ports fmc_hpc0_mgt_refclk_2_n] ;# MGTREFCLK0N_228 from from J87 P2

# reference clock
#create_clock -period 6.400 -name fmc_hpc0_mgt_refclk_2 [get_ports fmc_hpc0_mgt_refclk_2_p]

# FMC HPC1 J2
#set_property -dict {LOC T33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[0]"]  ;# J2.G9  LA00_P_CC
#set_property -dict {LOC R33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[0]"]  ;# J2.G10 LA00_N_CC
#set_property -dict {LOC P35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[1]"]  ;# J2.D8  LA01_P_CC
#set_property -dict {LOC P36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[1]"]  ;# J2.D9  LA01_N_CC
#set_property -dict {LOC N33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[2]"]  ;# J2.H7  LA02_P
#set_property -dict {LOC M33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[2]"]  ;# J2.H8  LA02_N
#set_property -dict {LOC N34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[3]"]  ;# J2.G12 LA03_P
#set_property -dict {LOC N35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[3]"]  ;# J2.G13 LA03_N
#set_property -dict {LOC M37  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[4]"]  ;# J2.H10 LA04_P
#set_property -dict {LOC L38  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[4]"]  ;# J2.H11 LA04_N
#set_property -dict {LOC N38  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[5]"]  ;# J2.D11 LA05_P
#set_property -dict {LOC M38  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[5]"]  ;# J2.D12 LA05_N
#set_property -dict {LOC P37  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[6]"]  ;# J2.C10 LA06_P
#set_property -dict {LOC N37  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[6]"]  ;# J2.C11 LA06_N
#set_property -dict {LOC L34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[7]"]  ;# J2.H13 LA07_P
#set_property -dict {LOC K34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[7]"]  ;# J2.H14 LA07_N
#set_property -dict {LOC M35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[8]"]  ;# J2.G12 LA08_P
#set_property -dict {LOC L35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[8]"]  ;# J2.G13 LA08_N
#set_property -dict {LOC M36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[9]"]  ;# J2.D14 LA09_P
#set_property -dict {LOC L36  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[9]"]  ;# J2.D15 LA09_N
#set_property -dict {LOC N32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[10]"] ;# J2.C14 LA10_P
#set_property -dict {LOC M32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[10]"] ;# J2.C15 LA10_N
#set_property -dict {LOC Y31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[11]"] ;# J2.H16 LA11_P
#set_property -dict {LOC W31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[11]"] ;# J2.H17 LA11_N
#set_property -dict {LOC R31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[12]"] ;# J2.G15 LA12_P
#set_property -dict {LOC P31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[12]"] ;# J2.G16 LA12_N
#set_property -dict {LOC T30  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[13]"] ;# J2.D17 LA13_P
#set_property -dict {LOC T31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[13]"] ;# J2.D18 LA13_N
#set_property -dict {LOC L33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[14]"] ;# J2.C18 LA14_P
#set_property -dict {LOC K33  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[14]"] ;# J2.C19 LA14_N
#set_property -dict {LOC T34  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[15]"] ;# J2.H19 LA15_P
#set_property -dict {LOC T35  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[15]"] ;# J2.H20 LA15_N
#set_property -dict {LOC U31  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[16]"] ;# J2.G18 LA16_P
#set_property -dict {LOC U32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[16]"] ;# J2.G19 LA16_N
#set_property -dict {LOC AJ32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[17]"] ;# J2.D20 LA17_P_CC
#set_property -dict {LOC AK32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[17]"] ;# J2.D21 LA17_N_CC
#set_property -dict {LOC AL32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[18]"] ;# J2.C22 LA18_P_CC
#set_property -dict {LOC AM32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[18]"] ;# J2.C23 LA18_N_CC
#set_property -dict {LOC AT39 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[19]"] ;# J2.H22 LA19_P
#set_property -dict {LOC AT40 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[19]"] ;# J2.H23 LA19_N
#set_property -dict {LOC AR37 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[20]"] ;# J2.G21 LA20_P
#set_property -dict {LOC AT37 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[20]"] ;# J2.G22 LA20_N
#set_property -dict {LOC AT35 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[21]"] ;# J2.H25 LA21_P
#set_property -dict {LOC AT36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[21]"] ;# J2.H26 LA21_N
#set_property -dict {LOC AL30 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[22]"] ;# J2.G24 LA22_P
#set_property -dict {LOC AL31 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[22]"] ;# J2.G25 LA22_N
#set_property -dict {LOC AN33 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[23]"] ;# J2.D23 LA23_P
#set_property -dict {LOC AP33 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[23]"] ;# J2.D24 LA23_N
#set_property -dict {LOC AM36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[24]"] ;# J2.H28 LA24_P
#set_property -dict {LOC AN36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[24]"] ;# J2.H29 LA24_N
#set_property -dict {LOC AP36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[25]"] ;# J2.G27 LA25_P
#set_property -dict {LOC AP37 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[25]"] ;# J2.G28 LA25_N
#set_property -dict {LOC AL29 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[26]"] ;# J2.D26 LA26_P
#set_property -dict {LOC AM29 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[26]"] ;# J2.D27 LA26_N
#set_property -dict {LOC AP35 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[27]"] ;# J2.C26 LA27_P
#set_property -dict {LOC AR35 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[27]"] ;# J2.C27 LA27_N
#set_property -dict {LOC AL35 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[28]"] ;# J2.H31 LA28_P
#set_property -dict {LOC AL36 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[28]"] ;# J2.H32 LA28_N
#set_property -dict {LOC AP38 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[29]"] ;# J2.G30 LA29_P
#set_property -dict {LOC AR38 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[29]"] ;# J2.G31 LA29_N
#set_property -dict {LOC AJ30 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[30]"] ;# J2.H34 LA30_P
#set_property -dict {LOC AJ31 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[30]"] ;# J2.H35 LA30_N
#set_property -dict {LOC AN34 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[31]"] ;# J2.G33 LA31_P
#set_property -dict {LOC AN35 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[31]"] ;# J2.G34 LA31_N
#set_property -dict {LOC AG31 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[32]"] ;# J2.H37 LA32_P
#set_property -dict {LOC AH31 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[32]"] ;# J2.H38 LA32_N
#set_property -dict {LOC AG32 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_p[33]"] ;# J2.G36 LA33_P
#set_property -dict {LOC AG33 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_la_n[33]"] ;# J2.G37 LA33_N

#set_property -dict {LOC R32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_clk0_m2c_p"] ;# J2.H4 CLK0_M2C_P
#set_property -dict {LOC P32  IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_clk0_m2c_n"] ;# J2.H5 CLK0_M2C_N
#set_property -dict {LOC AK34 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_clk1_m2c_p"] ;# J2.G2 CLK1_M2C_P
#set_property -dict {LOC AL34 IOSTANDARD LVDS DIFF_TERM TRUE} [get_ports "fmc_hpc1_clk1_m2c_n"] ;# J2.G3 CLK1_M2C_N

#set_property -dict {LOC AU24 IOSTANDARD LVCMOS18} [get_ports {fmc_hpc1_pg_m2c}]      ;# J2.F1 PG_M2C
#set_property -dict {LOC BD23 IOSTANDARD LVCMOS18} [get_ports {fmc_hpc1_prsnt_m2c_l}] ;# J2.H2 PRSNT_M2C_L

#set_property -dict {LOC AN5 } [get_ports {fmc_hpc1_dp_c2m_p[0]}] ;# MGTHTXP0_226 GTHE3_CHANNEL_X0Y8 / GTHE3_COMMON_X0Y2 from J2.C2  DP0_C2M_P
#set_property -dict {LOC AN4 } [get_ports {fmc_hpc1_dp_c2m_n[0]}] ;# MGTHTXN0_226 GTHE3_CHANNEL_X0Y8 / GTHE3_COMMON_X0Y2 from J2.C3  DP0_C2M_N
#set_property -dict {LOC AH2 } [get_ports {fmc_hpc1_dp_m2c_p[0]}] ;# MGTHRXP0_226 GTHE3_CHANNEL_X0Y8 / GTHE3_COMMON_X0Y2 from J2.C6  DP0_M2C_P
#set_property -dict {LOC AH1 } [get_ports {fmc_hpc1_dp_m2c_n[0]}] ;# MGTHRXN0_226 GTHE3_CHANNEL_X0Y8 / GTHE3_COMMON_X0Y2 from J2.C7  DP0_M2C_N
#set_property -dict {LOC AM7 } [get_ports {fmc_hpc1_dp_c2m_p[1]}] ;# MGTHTXP1_226 GTHE3_CHANNEL_X0Y9 / GTHE3_COMMON_X0Y2 from J2.A22 DP1_C2M_P
#set_property -dict {LOC AM6 } [get_ports {fmc_hpc1_dp_c2m_n[1]}] ;# MGTHTXN1_226 GTHE3_CHANNEL_X0Y9 / GTHE3_COMMON_X0Y2 from J2.A23 DP1_C2M_N
#set_property -dict {LOC AG4 } [get_ports {fmc_hpc1_dp_m2c_p[1]}] ;# MGTHRXP1_226 GTHE3_CHANNEL_X0Y9 / GTHE3_COMMON_X0Y2 from J2.A2  DP1_M2C_P
#set_property -dict {LOC AG3 } [get_ports {fmc_hpc1_dp_m2c_n[1]}] ;# MGTHRXN1_226 GTHE3_CHANNEL_X0Y9 / GTHE3_COMMON_X0Y2 from J2.A3  DP1_M2C_N
#set_property -dict {LOC AK7 } [get_ports {fmc_hpc1_dp_c2m_p[2]}] ;# MGTHTXP2_226 GTHE3_CHANNEL_X0Y10 / GTHE3_COMMON_X0Y2 from J2.A26 DP2_C2M_P
#set_property -dict {LOC AK6 } [get_ports {fmc_hpc1_dp_c2m_n[2]}] ;# MGTHTXN2_226 GTHE3_CHANNEL_X0Y10 / GTHE3_COMMON_X0Y2 from J2.A27 DP2_C2M_N
#set_property -dict {LOC AF2 } [get_ports {fmc_hpc1_dp_m2c_p[2]}] ;# MGTHRXP2_226 GTHE3_CHANNEL_X0Y10 / GTHE3_COMMON_X0Y2 from J2.A6  DP2_M2C_P
#set_property -dict {LOC AF1 } [get_ports {fmc_hpc1_dp_m2c_n[2]}] ;# MGTHRXN2_226 GTHE3_CHANNEL_X0Y10 / GTHE3_COMMON_X0Y2 from J2.A7  DP2_M2C_N
#set_property -dict {LOC AH7 } [get_ports {fmc_hpc1_dp_c2m_p[3]}] ;# MGTHTXP3_226 GTHE3_CHANNEL_X0Y11 / GTHE3_COMMON_X0Y2 from J2.A30 DP3_C2M_P
#set_property -dict {LOC AH6 } [get_ports {fmc_hpc1_dp_c2m_n[3]}] ;# MGTHTXN3_226 GTHE3_CHANNEL_X0Y11 / GTHE3_COMMON_X0Y2 from J2.A31 DP3_C2M_N
#set_property -dict {LOC AE4 } [get_ports {fmc_hpc1_dp_m2c_p[3]}] ;# MGTHRXP3_226 GTHE3_CHANNEL_X0Y11 / GTHE3_COMMON_X0Y2 from J2.A10 DP3_M2C_P
#set_property -dict {LOC AE3 } [get_ports {fmc_hpc1_dp_m2c_n[3]}] ;# MGTHRXN3_226 GTHE3_CHANNEL_X0Y11 / GTHE3_COMMON_X0Y2 from J2.A11 DP3_M2C_N

#set_property -dict {LOC AF7 } [get_ports {fmc_hpc1_dp_c2m_p[4]}] ;# MGTHTXP0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3 from J2.A34 DP4_C2M_P
#set_property -dict {LOC AF6 } [get_ports {fmc_hpc1_dp_c2m_n[4]}] ;# MGTHTXN0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3 from J2.A35 DP4_C2M_N
#set_property -dict {LOC AD2 } [get_ports {fmc_hpc1_dp_m2c_p[4]}] ;# MGTHRXP0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3 from J2.A14 DP4_M2C_P
#set_property -dict {LOC AD1 } [get_ports {fmc_hpc1_dp_m2c_n[4]}] ;# MGTHRXN0_227 GTHE3_CHANNEL_X0Y12 / GTHE3_COMMON_X0Y3 from J2.A15 DP4_M2C_N
#set_property -dict {LOC AD7 } [get_ports {fmc_hpc1_dp_c2m_p[5]}] ;# MGTHTXP1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3 from J2.A38 DP5_C2M_P
#set_property -dict {LOC AD6 } [get_ports {fmc_hpc1_dp_c2m_n[5]}] ;# MGTHTXN1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3 from J2.A39 DP5_C2M_N
#set_property -dict {LOC AC4 } [get_ports {fmc_hpc1_dp_m2c_p[5]}] ;# MGTHRXP1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3 from J2.A18 DP5_M2C_P
#set_property -dict {LOC AC3 } [get_ports {fmc_hpc1_dp_m2c_n[5]}] ;# MGTHRXN1_227 GTHE3_CHANNEL_X0Y13 / GTHE3_COMMON_X0Y3 from J2.A19 DP5_M2C_N
#set_property -dict {LOC AB7 } [get_ports {fmc_hpc1_dp_c2m_p[6]}] ;# MGTHTXP2_227 GTHE3_CHANNEL_X0Y14 / GTHE3_COMMON_X0Y3 from J2.B36 DP6_C2M_P
#set_property -dict {LOC AB6 } [get_ports {fmc_hpc1_dp_c2m_n[6]}] ;# MGTHTXN2_227 GTHE3_CHANNEL_X0Y14 / GTHE3_COMMON_X0Y3 from J2.B37 DP6_C2M_N
#set_property -dict {LOC AB2 } [get_ports {fmc_hpc1_dp_m2c_p[6]}] ;# MGTHRXP2_227 GTHE3_CHANNEL_X0Y14 / GTHE3_COMMON_X0Y3 from J2.B16 DP6_M2C_P
#set_property -dict {LOC AB1 } [get_ports {fmc_hpc1_dp_m2c_n[6]}] ;# MGTHRXN2_227 GTHE3_CHANNEL_X0Y14 / GTHE3_COMMON_X0Y3 from J2.B17 DP6_M2C_N
#set_property -dict {LOC Y7  } [get_ports {fmc_hpc1_dp_c2m_p[7]}] ;# MGTHTXP3_227 GTHE3_CHANNEL_X0Y15 / GTHE3_COMMON_X0Y3 from J2.B32 DP7_C2M_P
#set_property -dict {LOC Y6  } [get_ports {fmc_hpc1_dp_c2m_n[7]}] ;# MGTHTXN3_227 GTHE3_CHANNEL_X0Y15 / GTHE3_COMMON_X0Y3 from J2.B33 DP7_C2M_N
#set_property -dict {LOC AA4 } [get_ports {fmc_hpc1_dp_m2c_p[7]}] ;# MGTHRXP3_227 GTHE3_CHANNEL_X0Y15 / GTHE3_COMMON_X0Y3 from J2.B12 DP7_M2C_P
#set_property -dict {LOC AA3 } [get_ports {fmc_hpc1_dp_m2c_n[7]}] ;# MGTHRXN3_227 GTHE3_CHANNEL_X0Y15 / GTHE3_COMMON_X0Y3 from J2.B13 DP7_M2C_N
#set_property -dict {LOC AC9 } [get_ports fmc_hpc1_mgt_refclk_0_p] ;# MGTREFCLK0P_227 from J2.D4 GBTCLK0_M2C_P
#set_property -dict {LOC AC8 } [get_ports fmc_hpc1_mgt_refclk_0_n] ;# MGTREFCLK0N_227 from J2.D5 GBTCLK0_M2C_N
#set_property -dict {LOC AA9 } [get_ports fmc_hpc1_mgt_refclk_1_p] ;# MGTREFCLK1P_227 from J2.B20 GBTCLK1_M2C_P
#set_property -dict {LOC AA8 } [get_ports fmc_hpc1_mgt_refclk_1_n] ;# MGTREFCLK1N_227 from J2.B21 GBTCLK1_M2C_N

# reference clock
#create_clock -period 6.400 -name fmc_hpc0_mgt_refclk_0 [get_ports fmc_hpc0_mgt_refclk_0_p]
#create_clock -period 6.400 -name fmc_hpc0_mgt_refclk_1 [get_ports fmc_hpc0_mgt_refclk_1_p]

#set_property -dict {LOC P7  } [get_ports {fmc_hpc1_dp_c2m_p[8]}] ;# MGTHTXP2_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B28 DP8_C2M_P
#set_property -dict {LOC P6  } [get_ports {fmc_hpc1_dp_c2m_n[8]}] ;# MGTHTXN2_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B29 DP8_C2M_N
#set_property -dict {LOC V2  } [get_ports {fmc_hpc1_dp_m2c_p[8]}] ;# MGTHRXP2_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B8  DP8_M2C_P
#set_property -dict {LOC V1  } [get_ports {fmc_hpc1_dp_m2c_n[8]}] ;# MGTHRXN2_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B9  DP8_M2C_N
#set_property -dict {LOC M7  } [get_ports {fmc_hpc1_dp_c2m_p[9]}] ;# MGTHTXP3_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B24 DP9_C2M_P
#set_property -dict {LOC M6  } [get_ports {fmc_hpc1_dp_c2m_n[9]}] ;# MGTHTXN3_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B25 DP9_C2M_N
#set_property -dict {LOC U4  } [get_ports {fmc_hpc1_dp_m2c_p[9]}] ;# MGTHRXP3_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B4  DP9_M2C_P
#set_property -dict {LOC U3  } [get_ports {fmc_hpc1_dp_m2c_n[9]}] ;# MGTHRXN3_228 GTHE3_CHANNEL_X0Y18 / GTHE3_COMMON_X0Y4 from J2.B5  DP9_M2C_N
#set_property -dict {LOC W9  } [get_ports fmc_hpc1_mgt_refclk_2_p] ;# MGTREFCLK0P_228 from from J87 P1
#set_property -dict {LOC W8  } [get_ports fmc_hpc1_mgt_refclk_2_n] ;# MGTREFCLK0N_228 from from J87 P2

# reference clock
#create_clock -period 6.400 -name fmc_hpc1_mgt_refclk_2 [get_ports fmc_hpc1_mgt_refclk_2_p]

# DDR4 C1
# 5x MT40A256M16GE-075E
#set_property -dict {LOC C30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC D32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC B30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC C33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC E32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC A29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC C29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC E29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC A30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC C32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC A31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC A33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC F29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC B32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC D29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC B31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC B33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC G30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC F30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC F33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC E31  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t}]
#set_property -dict {LOC D31  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c}]
#set_property -dict {LOC K29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke}]
#set_property -dict {LOC D30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n}]
#set_property -dict {LOC E33  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC J31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt}]
#set_property -dict {LOC R29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC M28  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_reset_n}]
#set_property -dict {LOC J40  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_alert_n}]

#set_property -dict {LOC J37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[0]}]       ;# U60.G2 DQL0
#set_property -dict {LOC H40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[1]}]       ;# U60.F7 DQL1
#set_property -dict {LOC F38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[2]}]       ;# U60.H3 DQL2
#set_property -dict {LOC H39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[3]}]       ;# U60.H7 DQL3
#set_property -dict {LOC K37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[4]}]       ;# U60.H2 DQL4
#set_property -dict {LOC G40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[5]}]       ;# U60.H8 DQL5
#set_property -dict {LOC F39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[6]}]       ;# U60.J3 DQL6
#set_property -dict {LOC F40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[7]}]       ;# U60.J7 DQL7
#set_property -dict {LOC F36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[8]}]       ;# U60.A3 DQU0
#set_property -dict {LOC J36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[9]}]       ;# U60.B8 DQU1
#set_property -dict {LOC F35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[10]}]      ;# U60.C3 DQU2
#set_property -dict {LOC J35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[11]}]      ;# U60.C7 DQU3
#set_property -dict {LOC G37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[12]}]      ;# U60.C2 DQU4
#set_property -dict {LOC H35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[13]}]      ;# U60.C8 DQU5
#set_property -dict {LOC G36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[14]}]      ;# U60.D3 DQU6
#set_property -dict {LOC H37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[15]}]      ;# U60.D7 DQU7
#set_property -dict {LOC H38  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[0]}]    ;# U60.G3 DQSL_T
#set_property -dict {LOC G38  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[0]}]    ;# U60.F3 DQSL_C
#set_property -dict {LOC H34  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[1]}]    ;# U60.B7 DQSU_T
#set_property -dict {LOC G35  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[1]}]    ;# U60.A7 DQSU_C
#set_property -dict {LOC J39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[0]}] ;# U60.E7 DML_B/DBIL_B
#set_property -dict {LOC F34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[1]}] ;# U60.E2 DMU_B/DBIU_B

#set_property -dict {LOC C39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[16]}]      ;# U61.G2 DQL0
#set_property -dict {LOC A38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[17]}]      ;# U61.F7 DQL1
#set_property -dict {LOC B40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[18]}]      ;# U61.H3 DQL2
#set_property -dict {LOC D40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[19]}]      ;# U61.H7 DQL3
#set_property -dict {LOC E38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[20]}]      ;# U61.H2 DQL4
#set_property -dict {LOC B38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[21]}]      ;# U61.H8 DQL5
#set_property -dict {LOC E37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[22]}]      ;# U61.J3 DQL6
#set_property -dict {LOC C40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[23]}]      ;# U61.J7 DQL7
#set_property -dict {LOC C34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[24]}]      ;# U61.A3 DQU0
#set_property -dict {LOC A34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[25]}]      ;# U61.B8 DQU1
#set_property -dict {LOC D34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[26]}]      ;# U61.C3 DQU2
#set_property -dict {LOC A35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[27]}]      ;# U61.C7 DQU3
#set_property -dict {LOC A36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[28]}]      ;# U61.C2 DQU4
#set_property -dict {LOC C35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[29]}]      ;# U61.C8 DQU5
#set_property -dict {LOC B35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[30]}]      ;# U61.D3 DQU6
#set_property -dict {LOC D35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[31]}]      ;# U61.D7 DQU7
#set_property -dict {LOC A39  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[2]}]    ;# U61.G3 DQSL_T
#set_property -dict {LOC A40  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[2]}]    ;# U61.F3 DQSL_C
#set_property -dict {LOC B36  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[3]}]    ;# U61.B7 DQSU_T
#set_property -dict {LOC B37  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[3]}]    ;# U61.A7 DQSU_C
#set_property -dict {LOC E39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[2]}] ;# U61.E7 DML_B/DBIL_B
#set_property -dict {LOC D37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[3]}] ;# U61.E2 DMU_B/DBIU_B

#set_property -dict {LOC N27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[32]}]      ;# U62.G2 DQL0
#set_property -dict {LOC R27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[33]}]      ;# U62.F7 DQL1
#set_property -dict {LOC N24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[34]}]      ;# U62.H3 DQL2
#set_property -dict {LOC R24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[35]}]      ;# U62.H7 DQL3
#set_property -dict {LOC P24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[36]}]      ;# U62.H2 DQL4
#set_property -dict {LOC P26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[37]}]      ;# U62.H8 DQL5
#set_property -dict {LOC P27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[38]}]      ;# U62.J3 DQL6
#set_property -dict {LOC T24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[39]}]      ;# U62.J7 DQL7
#set_property -dict {LOC K27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[40]}]      ;# U62.A3 DQU0
#set_property -dict {LOC L26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[41]}]      ;# U62.B8 DQU1
#set_property -dict {LOC J27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[42]}]      ;# U62.C3 DQU2
#set_property -dict {LOC K28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[43]}]      ;# U62.C7 DQU3
#set_property -dict {LOC K26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[44]}]      ;# U62.C2 DQU4
#set_property -dict {LOC M25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[45]}]      ;# U62.C8 DQU5
#set_property -dict {LOC J26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[46]}]      ;# U62.D3 DQU6
#set_property -dict {LOC L28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[47]}]      ;# U62.D7 DQU7
#set_property -dict {LOC P25  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[4]}]    ;# U62.G3 DQSL_T
#set_property -dict {LOC N25  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[4]}]    ;# U62.F3 DQSL_C
#set_property -dict {LOC L24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[5]}]    ;# U62.B7 DQSU_T
#set_property -dict {LOC L25  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[5]}]    ;# U62.A7 DQSU_C
#set_property -dict {LOC T26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[4]}] ;# U62.E7 DML_B/DBIL_B
#set_property -dict {LOC M27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[5]}] ;# U62.E2 DMU_B/DBIU_B

#set_property -dict {LOC E27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[48]}]      ;# U63.G2 DQL0
#set_property -dict {LOC E28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[49]}]      ;# U63.F7 DQL1
#set_property -dict {LOC E26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[50]}]      ;# U63.H3 DQL2
#set_property -dict {LOC H27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[51]}]      ;# U63.H7 DQL3
#set_property -dict {LOC F25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[52]}]      ;# U63.H2 DQL4
#set_property -dict {LOC F28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[53]}]      ;# U63.H8 DQL5
#set_property -dict {LOC G25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[54]}]      ;# U63.J3 DQL6
#set_property -dict {LOC G27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[55]}]      ;# U63.J7 DQL7
#set_property -dict {LOC B28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[56]}]      ;# U63.A3 DQU0
#set_property -dict {LOC A28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[57]}]      ;# U63.B8 DQU1
#set_property -dict {LOC B25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[58]}]      ;# U63.C3 DQU2
#set_property -dict {LOC B27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[59]}]      ;# U63.C7 DQU3
#set_property -dict {LOC D25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[60]}]      ;# U63.C2 DQU4
#set_property -dict {LOC C27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[61]}]      ;# U63.C8 DQU5
#set_property -dict {LOC C25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[62]}]      ;# U63.D3 DQU6
#set_property -dict {LOC D26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[63]}]      ;# U63.D7 DQU7
#set_property -dict {LOC H28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[6]}]    ;# U63.G3 DQSL_T
#set_property -dict {LOC G28  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[6]}]    ;# U63.F3 DQSL_C
#set_property -dict {LOC B26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[7]}]    ;# U63.B7 DQSU_T
#set_property -dict {LOC A26  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[7]}]    ;# U63.A7 DQSU_C
#set_property -dict {LOC G26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[6]}] ;# U63.E7 DML_B/DBIL_B
#set_property -dict {LOC D27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[7]}] ;# U63.E2 DMU_B/DBIU_B

#set_property -dict {LOC N29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[64]}]      ;# U64.G2 DQL0
#set_property -dict {LOC M31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[65]}]      ;# U64.F7 DQL1
#set_property -dict {LOC P29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[66]}]      ;# U64.H3 DQL2
#set_property -dict {LOC L29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[67]}]      ;# U64.H7 DQL3
#set_property -dict {LOC P30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[68]}]      ;# U64.H2 DQL4
#set_property -dict {LOC N28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[69]}]      ;# U64.H8 DQL5
#set_property -dict {LOC L31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[70]}]      ;# U64.J3 DQL6
#set_property -dict {LOC L30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[71]}]      ;# U64.J7 DQL7
#set_property -dict {LOC H30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[72]}]      ;# U64.A3 DQU0
#set_property -dict {LOC J32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[73]}]      ;# U64.B8 DQU1
#set_property -dict {LOC H29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[74]}]      ;# U64.C3 DQU2
#set_property -dict {LOC H32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[75]}]      ;# U64.C7 DQU3
#set_property -dict {LOC J29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[76]}]      ;# U64.C2 DQU4
#set_property -dict {LOC K32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[77]}]      ;# U64.C8 DQU5
#set_property -dict {LOC J30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[78]}]      ;# U64.D3 DQU6
#set_property -dict {LOC G32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[79]}]      ;# U64.D7 DQU7
#set_property -dict {LOC N30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[8]}]    ;# U64.G3 DQSL_T
#set_property -dict {LOC M30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[8]}]    ;# U64.F3 DQSL_C
#set_property -dict {LOC H33  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[9]}]    ;# U64.B7 DQSU_T
#set_property -dict {LOC G33  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[9]}]    ;# U64.A7 DQSU_C
#set_property -dict {LOC R28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[8]}] ;# U64.E7 DML_B/DBIL_B
#set_property -dict {LOC K31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[9]}] ;# U64.E2 DMU_B/DBIU_B

# DDR4 C2
# 5x MT40A256M16GE-075E
#set_property -dict {LOC AM27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[0]}]
#set_property -dict {LOC AT25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[1]}]
#set_property -dict {LOC AN25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[2]}]
#set_property -dict {LOC AN26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[3]}]
#set_property -dict {LOC AR25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[4]}]
#set_property -dict {LOC AU28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[5]}]
#set_property -dict {LOC AU27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[6]}]
#set_property -dict {LOC AR28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[7]}]
#set_property -dict {LOC AP25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[8]}]
#set_property -dict {LOC AM26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[9]}]
#set_property -dict {LOC AP26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[10]}]
#set_property -dict {LOC AN28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[11]}]
#set_property -dict {LOC AR27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[12]}]
#set_property -dict {LOC AP28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[13]}]
#set_property -dict {LOC AL27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[14]}]
#set_property -dict {LOC AP27 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[15]}]
#set_property -dict {LOC AM28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[16]}]
#set_property -dict {LOC AU26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[0]}]
#set_property -dict {LOC AV26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[1]}]
#set_property -dict {LOC AV28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[0]}]
#set_property -dict {LOC AT26 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_t}]
#set_property -dict {LOC AT27 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_c}]
#set_property -dict {LOC AY29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cke}]
#set_property -dict {LOC AW26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n}]
#set_property -dict {LOC AW28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_act_n}]
#set_property -dict {LOC BB29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_odt}]
#set_property -dict {LOC BF29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_par}]
#set_property -dict {LOC BF40 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_reset_n}]
#set_property -dict {LOC AV25 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_alert_n}]

#set_property -dict {LOC BE30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[0]}]       ;# U135.G2 DQL0
#set_property -dict {LOC BE33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[1]}]       ;# U135.F7 DQL1
#set_property -dict {LOC BD30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[2]}]       ;# U135.H3 DQL2
#set_property -dict {LOC BD33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[3]}]       ;# U135.H7 DQL3
#set_property -dict {LOC BD31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[4]}]       ;# U135.H2 DQL4
#set_property -dict {LOC BC33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[5]}]       ;# U135.H8 DQL5
#set_property -dict {LOC BD32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[6]}]       ;# U135.J3 DQL6
#set_property -dict {LOC BC31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[7]}]       ;# U135.J7 DQL7
#set_property -dict {LOC BA31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[8]}]       ;# U135.A3 DQU0
#set_property -dict {LOC AY33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[9]}]       ;# U135.B8 DQU1
#set_property -dict {LOC BA30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[10]}]      ;# U135.C3 DQU2
#set_property -dict {LOC AW31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[11]}]      ;# U135.C7 DQU3
#set_property -dict {LOC AW32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[12]}]      ;# U135.C2 DQU4
#set_property -dict {LOC BB33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[13]}]      ;# U135.C8 DQU5
#set_property -dict {LOC AY32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[14]}]      ;# U135.D3 DQU6
#set_property -dict {LOC BA32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[15]}]      ;# U135.D7 DQU7
#set_property -dict {LOC BF30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[0]}]    ;# U135.G3 DQSL_T
#set_property -dict {LOC BF31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[0]}]    ;# U135.F3 DQSL_C
#set_property -dict {LOC AY34 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[1]}]    ;# U135.B7 DQSU_T
#set_property -dict {LOC BA34 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[1]}]    ;# U135.A7 DQSU_C
#set_property -dict {LOC BE32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[0]}] ;# U135.E7 DML_B/DBIL_B
#set_property -dict {LOC BB31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[1]}] ;# U135.E2 DMU_B/DBIU_B

#set_property -dict {LOC AT31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[16]}]      ;# U136.G2 DQL0
#set_property -dict {LOC AV31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[17]}]      ;# U136.F7 DQL1
#set_property -dict {LOC AV30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[18]}]      ;# U136.H3 DQL2
#set_property -dict {LOC AU33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[19]}]      ;# U136.H7 DQL3
#set_property -dict {LOC AU31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[20]}]      ;# U136.H2 DQL4
#set_property -dict {LOC AU32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[21]}]      ;# U136.H8 DQL5
#set_property -dict {LOC AW30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[22]}]      ;# U136.J3 DQL6
#set_property -dict {LOC AU34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[23]}]      ;# U136.J7 DQL7
#set_property -dict {LOC AT29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[24]}]      ;# U136.A3 DQU0
#set_property -dict {LOC AT34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[25]}]      ;# U136.B8 DQU1
#set_property -dict {LOC AT30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[26]}]      ;# U136.C3 DQU2
#set_property -dict {LOC AR33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[27]}]      ;# U136.C7 DQU3
#set_property -dict {LOC AR30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[28]}]      ;# U136.C2 DQU4
#set_property -dict {LOC AN30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[29]}]      ;# U136.C8 DQU5
#set_property -dict {LOC AP30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[30]}]      ;# U136.D3 DQU6
#set_property -dict {LOC AN31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[31]}]      ;# U136.D7 DQU7
#set_property -dict {LOC AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[2]}]    ;# U136.G3 DQSL_T
#set_property -dict {LOC AV29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[2]}]    ;# U136.F3 DQSL_C
#set_property -dict {LOC AP31 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[3]}]    ;# U136.B7 DQSU_T
#set_property -dict {LOC AP32 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[3]}]    ;# U136.A7 DQSU_C
#set_property -dict {LOC AV33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[2]}] ;# U136.E7 DML_B/DBIL_B
#set_property -dict {LOC AR32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[3]}] ;# U136.E2 DMU_B/DBIU_B

#set_property -dict {LOC BF34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[32]}]      ;# U137.G2 DQL0
#set_property -dict {LOC BF36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[33]}]      ;# U137.F7 DQL1
#set_property -dict {LOC BC35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[34]}]      ;# U137.H3 DQL2
#set_property -dict {LOC BE37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[35]}]      ;# U137.H7 DQL3
#set_property -dict {LOC BE34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[36]}]      ;# U137.H2 DQL4
#set_property -dict {LOC BD36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[37]}]      ;# U137.H8 DQL5
#set_property -dict {LOC BF37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[38]}]      ;# U137.J3 DQL6
#set_property -dict {LOC BC36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[39]}]      ;# U137.J7 DQL7
#set_property -dict {LOC BD37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[40]}]      ;# U137.A3 DQU0
#set_property -dict {LOC BE38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[41]}]      ;# U137.B8 DQU1
#set_property -dict {LOC BD38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[42]}]      ;# U137.C3 DQU2
#set_property -dict {LOC BD40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[43]}]      ;# U137.C7 DQU3
#set_property -dict {LOC BB38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[44]}]      ;# U137.C2 DQU4
#set_property -dict {LOC BB39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[45]}]      ;# U137.C8 DQU5
#set_property -dict {LOC BC39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[46]}]      ;# U137.D3 DQU6
#set_property -dict {LOC BC38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[47]}]      ;# U137.D7 DQU7
#set_property -dict {LOC BE35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[4]}]    ;# U137.G3 DQSL_T
#set_property -dict {LOC BF35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[4]}]    ;# U137.F3 DQSL_C
#set_property -dict {LOC BE39 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[5]}]    ;# U137.B7 DQSU_T
#set_property -dict {LOC BF39 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[5]}]    ;# U137.A7 DQSU_C
#set_property -dict {LOC BC34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[4]}] ;# U137.E7 DML_B/DBIL_B
#set_property -dict {LOC BE40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[5]}] ;# U137.E2 DMU_B/DBIU_B

#set_property -dict {LOC AW40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[48]}]      ;# U138.G2 DQL0
#set_property -dict {LOC BA40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[49]}]      ;# U138.F7 DQL1
#set_property -dict {LOC AY39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[50]}]      ;# U138.H3 DQL2
#set_property -dict {LOC AY38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[51]}]      ;# U138.H7 DQL3
#set_property -dict {LOC AY40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[52]}]      ;# U138.H2 DQL4
#set_property -dict {LOC BA39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[53]}]      ;# U138.H8 DQL5
#set_property -dict {LOC BB36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[54]}]      ;# U138.J3 DQL6
#set_property -dict {LOC BB37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[55]}]      ;# U138.J7 DQL7
#set_property -dict {LOC AV38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[56]}]      ;# U138.A3 DQU0
#set_property -dict {LOC AU38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[57]}]      ;# U138.B8 DQU1
#set_property -dict {LOC AU39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[58]}]      ;# U138.C3 DQU2
#set_property -dict {LOC AW35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[59]}]      ;# U138.C7 DQU3
#set_property -dict {LOC AU40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[60]}]      ;# U138.C2 DQU4
#set_property -dict {LOC AV40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[61]}]      ;# U138.C8 DQU5
#set_property -dict {LOC AW36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[62]}]      ;# U138.D3 DQU6
#set_property -dict {LOC AV39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[63]}]      ;# U138.D7 DQU7
#set_property -dict {LOC BA35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[6]}]    ;# U138.G3 DQSL_T
#set_property -dict {LOC BA36 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[6]}]    ;# U138.F3 DQSL_C
#set_property -dict {LOC AW37 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[7]}]    ;# U138.B7 DQSU_T
#set_property -dict {LOC AW38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[7]}]    ;# U138.A7 DQSU_C
#set_property -dict {LOC AY37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[6]}] ;# U138.E7 DML_B/DBIL_B
#set_property -dict {LOC AV35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[7]}] ;# U138.E2 DMU_B/DBIU_B

#set_property -dict {LOC BD25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[64]}]      ;# U139.G2 DQL0
#set_property -dict {LOC BD26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[65]}]      ;# U139.F7 DQL1
#set_property -dict {LOC BD27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[66]}]      ;# U139.H3 DQL2
#set_property -dict {LOC BE27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[67]}]      ;# U139.H7 DQL3
#set_property -dict {LOC BD28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[68]}]      ;# U139.H2 DQL4
#set_property -dict {LOC BE28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[69]}]      ;# U139.H8 DQL5
#set_property -dict {LOC BF26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[70]}]      ;# U139.J3 DQL6
#set_property -dict {LOC BF27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[71]}]      ;# U139.J7 DQL7
#set_property -dict {LOC AY27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[72]}]      ;# U139.A3 DQU0
#set_property -dict {LOC BC26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[73]}]      ;# U139.B8 DQU1
#set_property -dict {LOC BA27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[74]}]      ;# U139.C3 DQU2
#set_property -dict {LOC BB28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[75]}]      ;# U139.C7 DQU3
#set_property -dict {LOC AY28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[76]}]      ;# U139.C2 DQU4
#set_property -dict {LOC BB27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[77]}]      ;# U139.C8 DQU5
#set_property -dict {LOC BC25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[78]}]      ;# U139.D3 DQU6
#set_property -dict {LOC BC28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[79]}]      ;# U139.D7 DQU7
#set_property -dict {LOC BE25 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[8]}]    ;# U139.G3 DQSL_T
#set_property -dict {LOC BF25 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[8]}]    ;# U139.F3 DQSL_C
#set_property -dict {LOC BA26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[9]}]    ;# U139.B7 DQSU_T
#set_property -dict {LOC BB26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[9]}]    ;# U139.A7 DQSU_C
#set_property -dict {LOC BE29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[8]}] ;# U139.E7 DML_B/DBIL_B
#set_property -dict {LOC BA29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[9]}] ;# U139.E2 DMU_B/DBIU_B

# BPI flash
#set_property -dict {LOC AM19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[4]}]
#set_property -dict {LOC AM18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[5]}]
#set_property -dict {LOC AN20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[6]}]
#set_property -dict {LOC AP20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[7]}]
#set_property -dict {LOC AN19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[8]}]
#set_property -dict {LOC AN18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[9]}]
#set_property -dict {LOC AR18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[10]}]
#set_property -dict {LOC AR17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[11]}]
#set_property -dict {LOC AT20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[12]}]
#set_property -dict {LOC AT19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[13]}]
#set_property -dict {LOC AT17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[14]}]
#set_property -dict {LOC AU17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_dq[15]}]
#set_property -dict {LOC AR20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[0]}]
#set_property -dict {LOC AR19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[1]}]
#set_property -dict {LOC AV20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[2]}]
#set_property -dict {LOC AW20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[3]}]
#set_property -dict {LOC AU19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[4]}]
#set_property -dict {LOC AU18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[5]}]
#set_property -dict {LOC AV19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[6]}]
#set_property -dict {LOC AV18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[7]}]
#set_property -dict {LOC AW18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[8]}]
#set_property -dict {LOC AY18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[9]}]
#set_property -dict {LOC AY19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[10]}]
#set_property -dict {LOC BA19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[11]}]
#set_property -dict {LOC BA17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[12]}]
#set_property -dict {LOC BB17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[13]}]
#set_property -dict {LOC BB19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[14]}]
#set_property -dict {LOC BC19 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[15]}]
#set_property -dict {LOC BB18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[16]}]
#set_property -dict {LOC BC18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[17]}]
#set_property -dict {LOC AY20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[18]}]
#set_property -dict {LOC BA20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[19]}]
#set_property -dict {LOC BD18 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[20]}]
#set_property -dict {LOC BD17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[21]}]
#set_property -dict {LOC BC20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[22]}]
#set_property -dict {LOC BD20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_addr[23]}]
#set_property -dict {LOC BE20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_region[0]}]
#set_property -dict {LOC BF20 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_region[1]}]
#set_property -dict {LOC BF17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_oe_n}]
#set_property -dict {LOC BF16 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_we_n}]
#set_property -dict {LOC AW17 IOSTANDARD LVCMOS18 DRIVE 12} [get_ports {flash_adv_n}]
#set_property -dict {LOC BC23 IOSTANDARD LVCMOS18} [get_ports {flash_wait}]

#set_false_path -to [get_ports {flash_dq[*] flash_addr[*] flash_region[*] flash_oe_n flash_we_n flash_adv_n}]
#set_output_delay 0 [get_ports {flash_dq[*] flash_addr[*] flash_region[*] flash_oe_n flash_we_n flash_adv_n}]
#set_false_path -from [get_ports {flash_dq[*] flash_wait}]
#set_input_delay 0 [get_ports {flash_dq[*] flash_wait}]
