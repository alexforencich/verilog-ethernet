# XDC constraints for the Xilinx VCU108 board
# part: xcvu095-ffva2104-2-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1      [current_design]
set_property CONFIG_MODE BPI16                         [current_design]

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
#set_property -dict {LOC AR45} [get_ports bullseye_rx0_p] ;# MGTYRXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AR46} [get_ports bullseye_rx0_n] ;# MGTYRXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AT42} [get_ports bullseye_tx0_p] ;# MGTYTXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AT43} [get_ports bullseye_tx0_n] ;# MGTYTXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AN45} [get_ports bullseye_rx1_p] ;# MGTYRXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AN46} [get_ports bullseye_rx1_n] ;# MGTYRXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AP42} [get_ports bullseye_tx1_p] ;# MGTYTXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AP43} [get_ports bullseye_tx1_n] ;# MGTYTXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL45} [get_ports bullseye_rx2_p] ;# MGTYRXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL46} [get_ports bullseye_rx2_n] ;# MGTYRXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AM42} [get_ports bullseye_tx2_p] ;# MGTYTXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AM43} [get_ports bullseye_tx2_n] ;# MGTYTXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AJ45} [get_ports bullseye_rx3_p] ;# MGTYRXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AJ46} [get_ports bullseye_rx3_n] ;# MGTYRXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL40} [get_ports bullseye_tx3_p] ;# MGTYTXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AL41} [get_ports bullseye_tx3_n] ;# MGTYTXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y2
#set_property -dict {LOC AK38} [get_ports bullseye_mgt_refclk_0_p] ;# MGTREFCLK0P_126 from J87 P19
#set_property -dict {LOC AK39} [get_ports bullseye_mgt_refclk_0_n] ;# MGTREFCLK0N_126 from J87 P20
#set_property -dict {LOC AH38} [get_ports bullseye_mgt_refclk_1_p] ;# MGTREFCLK1P_126 from U32 SI570 via U104 SI53340
#set_property -dict {LOC AH39} [get_ports bullseye_mgt_refclk_1_n] ;# MGTREFCLK1N_126 from U32 SI570 via U104 SI53340

# 156.25 MHz MGT reference clock
#create_clock -period 6.4 -name bullseye_mgt_refclk [get_ports bullseye_mgt_refclk_1_p]

# QSFP28 Interface
set_property -dict {LOC AG45} [get_ports qsfp_rx1_p] ;# MGTYRXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AG46} [get_ports qsfp_rx1_n] ;# MGTYRXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AK42} [get_ports qsfp_tx1_p] ;# MGTYTXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AK43} [get_ports qsfp_tx1_n] ;# MGTYTXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AF43} [get_ports qsfp_rx2_p] ;# MGTYRXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AF44} [get_ports qsfp_rx2_n] ;# MGTYRXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AJ40} [get_ports qsfp_tx2_p] ;# MGTYTXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AJ41} [get_ports qsfp_tx2_n] ;# MGTYTXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE45} [get_ports qsfp_rx3_p] ;# MGTYRXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE46} [get_ports qsfp_rx3_n] ;# MGTYRXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AG40} [get_ports qsfp_tx3_p] ;# MGTYTXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AG41} [get_ports qsfp_tx3_n] ;# MGTYTXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AD43} [get_ports qsfp_rx4_p] ;# MGTYRXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AD44} [get_ports qsfp_rx4_n] ;# MGTYRXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE40} [get_ports qsfp_tx4_p] ;# MGTYTXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE41} [get_ports qsfp_tx4_n] ;# MGTYTXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AF38} [get_ports qsfp_mgt_refclk_0_p] ;# MGTREFCLK0P_127 from U32 SI570 via U102 SI53340
set_property -dict {LOC AF39} [get_ports qsfp_mgt_refclk_0_n] ;# MGTREFCLK0N_127 from U32 SI570 via U102 SI53340
#set_property -dict {LOC AD38} [get_ports qsfp_mgt_refclk_1_p] ;# MGTREFCLK1P_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AD39} [get_ports qsfp_mgt_refclk_1_n] ;# MGTREFCLK1N_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AG34 IOSTANDARD LVDS} [get_ports qsfp_recclk_p] ;# to U57 CKIN1 SI5328
#set_property -dict {LOC AH35 IOSTANDARD LVDS} [get_ports qsfp_recclk_n] ;# to U57 CKIN1 SI5328
set_property -dict {LOC AL24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_modsell]
set_property -dict {LOC AM24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_resetl]
set_property -dict {LOC AL25 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_modprsl]
set_property -dict {LOC AL21 IOSTANDARD LVCMOS18 PULLUP true} [get_ports qsfp_intl]
set_property -dict {LOC AM21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports qsfp_lpmode]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name qsfp_mgt_refclk_0 [get_ports qsfp_mgt_refclk_0_p]

set_false_path -to [get_ports {qsfp_modsell qsfp_resetl qsfp_lpmode}]
set_output_delay 0 [get_ports {qsfp_modsell qsfp_resetl qsfp_lpmode}]
set_false_path -from [get_ports {qsfp_modprsl qsfp_intl}]
set_input_delay 0 [get_ports {qsfp_modprsl qsfp_intl}]

# CFP2 GTY
#set_property -dict {LOC J45 } [get_ports cfp2_rx0_p] ;# MGTYRXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC J46 } [get_ports cfp2_rx0_n] ;# MGTYRXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC F42 } [get_ports cfp2_tx0_p] ;# MGTYTXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC F43 } [get_ports cfp2_tx0_n] ;# MGTYTXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC N45 } [get_ports cfp2_rx1_p] ;# MGTYRXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC N46 } [get_ports cfp2_rx1_n] ;# MGTYRXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC K42 } [get_ports cfp2_tx1_p] ;# MGTYTXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC K43 } [get_ports cfp2_tx1_n] ;# MGTYTXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC R45 } [get_ports cfp2_rx2_p] ;# MGTYRXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC R46 } [get_ports cfp2_rx2_n] ;# MGTYRXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC M42 } [get_ports cfp2_tx2_p] ;# MGTYTXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC M43 } [get_ports cfp2_tx2_n] ;# MGTYTXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC L45 } [get_ports cfp2_rx3_p] ;# MGTYRXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC L46 } [get_ports cfp2_rx3_n] ;# MGTYRXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC H42 } [get_ports cfp2_tx3_p] ;# MGTYTXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC H43 } [get_ports cfp2_tx3_n] ;# MGTYTXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC Y43 } [get_ports cfp2_rx4_p] ;# MGTYRXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC Y44 } [get_ports cfp2_rx4_n] ;# MGTYRXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U40 } [get_ports cfp2_tx4_p] ;# MGTYTXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U41 } [get_ports cfp2_tx4_n] ;# MGTYTXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U45 } [get_ports cfp2_rx5_p] ;# MGTYRXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC U46 } [get_ports cfp2_rx5_n] ;# MGTYRXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC P42 } [get_ports cfp2_tx5_p] ;# MGTYTXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC P43 } [get_ports cfp2_tx5_n] ;# MGTYTXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC W45 } [get_ports cfp2_rx6_p] ;# MGTYRXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC W46 } [get_ports cfp2_rx6_n] ;# MGTYRXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC T42 } [get_ports cfp2_tx6_p] ;# MGTYTXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC T43 } [get_ports cfp2_tx6_n] ;# MGTYTXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC AA45} [get_ports cfp2_rx7_p] ;# MGTYRXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA46} [get_ports cfp2_rx7_n] ;# MGTYRXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC W40 } [get_ports cfp2_tx7_p] ;# MGTYTXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC W41 } [get_ports cfp2_tx7_n] ;# MGTYTXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AB43} [get_ports cfp2_rx8_p] ;# MGTYRXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AB44} [get_ports cfp2_rx8_n] ;# MGTYRXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA40} [get_ports cfp2_tx8_p] ;# MGTYTXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA41} [get_ports cfp2_tx8_n] ;# MGTYTXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC45} [get_ports cfp2_rx9_p] ;# MGTYRXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC46} [get_ports cfp2_rx9_n] ;# MGTYRXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC40} [get_ports cfp2_tx9_p] ;# MGTYTXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC41} [get_ports cfp2_tx9_n] ;# MGTYTXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
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
set_property -dict {LOC AN21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC AP21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

set_false_path -to [get_ports {i2c_sda i2c_scl}]
set_output_delay 0 [get_ports {i2c_sda i2c_scl}]
set_false_path -from [get_ports {i2c_sda i2c_scl}]
set_input_delay 0 [get_ports {i2c_sda i2c_scl}]

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
