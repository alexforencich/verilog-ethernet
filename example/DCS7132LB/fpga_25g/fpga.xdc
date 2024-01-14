# XDC constraints for the Arista 7132LB
# part: xcvu9p-flgb2104-3-e

# General configuration
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8          [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

# System clocks
# User refclk 0 156.26 MHz
set_property -dict {LOC AY13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_NONE} [get_ports {refclk_user_p[0]}]
set_property -dict {LOC BA13 IOSTANDARD LVDS DIFF_TERM_ADV TERM_NONE} [get_ports {refclk_user_n[0]}]
create_clock -period 6.400 -name refclk_user_0 [get_ports {refclk_user_p[0]}]

# User refclk 1 156.26 MHz
set_property -dict {LOC AW28 IOSTANDARD DIFF_SSTL12} [get_ports {refclk_user_p[1]}]
set_property -dict {LOC AY28 IOSTANDARD DIFF_SSTL12} [get_ports {refclk_user_n[1]}]
create_clock -period 6.400 -name refclk_user_1 [get_ports {refclk_user_p[1]}]

# DDR4 DIMM 0 refclk
#set_property -dict {LOC N32  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm0_refclk_p]
#set_property -dict {LOC N33  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm0_refclk_n]
#create_clock -period 3.333 -name clk_ddr4_dimm0_refclk [get_ports clk_ddr4_dimm0_refclk_p]

# DDR4 DIMM 1 refclk
#set_property -dict {LOC BA35 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm1_refclk_p]
#set_property -dict {LOC BB35 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm1_refclk_n]
#create_clock -period 3.333 -name clk_ddr4_dimm1_refclk [get_ports clk_ddr4_dimm1_refclk_p]

# DDR4 DIMM 2 refclk
#set_property -dict {LOC AV19 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm2_refclk_p]
#set_property -dict {LOC AW19 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm2_refclk_n]
#create_clock -period 3.333 -name clk_ddr4_dimm2_refclk [get_ports clk_ddr4_dimm2_refclk_p]

# DDR4 DIMM 3 refclk
#set_property -dict {LOC J16  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm3_refclk_p]
#set_property -dict {LOC J15  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_dimm3_refclk_n]
#create_clock -period 3.333 -name clk_ddr4_dimm3_refclk [get_ports clk_ddr4_dimm3_refclk_p]

# Ethernet interfaces

# GTY quad 122
# 7132LB-48Y4C: SFP 1, 2, 3, 4
set_property -dict {LOC AN45} [get_ports {eth_gt_ch_rx_p[0]}] ;# MGTYRXP0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN46} [get_ports {eth_gt_ch_rx_n[0]}] ;# MGTYRXN0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN40} [get_ports {eth_gt_ch_tx_p[0]}] ;# MGTYTXP0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN41} [get_ports {eth_gt_ch_tx_n[0]}] ;# MGTYTXN0_122 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM43} [get_ports {eth_gt_ch_rx_p[1]}] ;# MGTYRXP1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM44} [get_ports {eth_gt_ch_rx_n[1]}] ;# MGTYRXN1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM38} [get_ports {eth_gt_ch_tx_p[1]}] ;# MGTYTXP1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM39} [get_ports {eth_gt_ch_tx_n[1]}] ;# MGTYTXN1_122 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL45} [get_ports {eth_gt_ch_rx_p[2]}] ;# MGTYRXP2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL46} [get_ports {eth_gt_ch_rx_n[2]}] ;# MGTYRXN2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL40} [get_ports {eth_gt_ch_tx_p[2]}] ;# MGTYTXP2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL41} [get_ports {eth_gt_ch_tx_n[2]}] ;# MGTYTXN2_122 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK43} [get_ports {eth_gt_ch_rx_p[3]}] ;# MGTYRXP3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK44} [get_ports {eth_gt_ch_rx_n[3]}] ;# MGTYRXN3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK38} [get_ports {eth_gt_ch_tx_p[3]}] ;# MGTYTXP3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK39} [get_ports {eth_gt_ch_tx_n[3]}] ;# MGTYTXN3_122 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AR36} [get_ports {eth_gt_pri_refclk_p[0]}] ;# MGTREFCLK0P_122
set_property -dict {LOC AR37} [get_ports {eth_gt_pri_refclk_n[0]}] ;# MGTREFCLK0N_122
#set_property -dict {LOC AN36} [get_ports {eth_gt_sec_refclk_p[4]}] ;# MGTREFCLK1P_122
#set_property -dict {LOC AN37} [get_ports {eth_gt_sec_refclk_n[4]}] ;# MGTREFCLK1N_122

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_0 [get_ports {eth_gt_pri_refclk_p[0]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_4 [get_ports {eth_gt_sec_refclk_p[4]}]

# GTY quad 123
# 7132LB-48Y4C: SFP 5, 6, 7, 8
set_property -dict {LOC AJ45} [get_ports {eth_gt_ch_rx_p[4]}] ;# MGTYRXP0_123 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ46} [get_ports {eth_gt_ch_rx_n[4]}] ;# MGTYRXN0_123 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ40} [get_ports {eth_gt_ch_tx_p[4]}] ;# MGTYTXP0_123 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ41} [get_ports {eth_gt_ch_tx_n[4]}] ;# MGTYTXN0_123 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH43} [get_ports {eth_gt_ch_rx_p[5]}] ;# MGTYRXP1_123 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH44} [get_ports {eth_gt_ch_rx_n[5]}] ;# MGTYRXN1_123 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH38} [get_ports {eth_gt_ch_tx_p[5]}] ;# MGTYTXP1_123 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH39} [get_ports {eth_gt_ch_tx_n[5]}] ;# MGTYTXN1_123 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG45} [get_ports {eth_gt_ch_rx_p[6]}] ;# MGTYRXP2_123 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG46} [get_ports {eth_gt_ch_rx_n[6]}] ;# MGTYRXN2_123 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG40} [get_ports {eth_gt_ch_tx_p[6]}] ;# MGTYTXP2_123 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG41} [get_ports {eth_gt_ch_tx_n[6]}] ;# MGTYTXN2_123 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF43} [get_ports {eth_gt_ch_rx_p[7]}] ;# MGTYRXP3_123 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF44} [get_ports {eth_gt_ch_rx_n[7]}] ;# MGTYRXN3_123 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF38} [get_ports {eth_gt_ch_tx_p[7]}] ;# MGTYTXP3_123 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF39} [get_ports {eth_gt_ch_tx_n[7]}] ;# MGTYTXN3_123 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AL36} [get_ports {eth_gt_pri_refclk_p[1]}] ;# MGTREFCLK0P_123
set_property -dict {LOC AL37} [get_ports {eth_gt_pri_refclk_n[1]}] ;# MGTREFCLK0N_123

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_1 [get_ports {eth_gt_pri_refclk_p[1]}]

# GTY quad 124
# 7132LB-48Y4C: SFP 9, 10, 11, 12
set_property -dict {LOC AE45} [get_ports {eth_gt_ch_rx_p[8]}] ;# MGTYRXP0_124 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE46} [get_ports {eth_gt_ch_rx_n[8]}] ;# MGTYRXN0_124 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE40} [get_ports {eth_gt_ch_tx_p[8]}] ;# MGTYTXP0_124 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE41} [get_ports {eth_gt_ch_tx_n[8]}] ;# MGTYTXN0_124 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD43} [get_ports {eth_gt_ch_rx_p[9]}] ;# MGTYRXP1_124 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD44} [get_ports {eth_gt_ch_rx_n[9]}] ;# MGTYRXN1_124 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD38} [get_ports {eth_gt_ch_tx_p[9]}] ;# MGTYTXP1_124 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD39} [get_ports {eth_gt_ch_tx_n[9]}] ;# MGTYTXN1_124 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC45} [get_ports {eth_gt_ch_rx_p[10]}] ;# MGTYRXP2_124 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC46} [get_ports {eth_gt_ch_rx_n[10]}] ;# MGTYRXN2_124 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC40} [get_ports {eth_gt_ch_tx_p[10]}] ;# MGTYTXP2_124 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC41} [get_ports {eth_gt_ch_tx_n[10]}] ;# MGTYTXN2_124 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB43} [get_ports {eth_gt_ch_rx_p[11]}] ;# MGTYRXP3_124 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB44} [get_ports {eth_gt_ch_rx_n[11]}] ;# MGTYRXN3_124 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB38} [get_ports {eth_gt_ch_tx_p[11]}] ;# MGTYTXP3_124 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB39} [get_ports {eth_gt_ch_tx_n[11]}] ;# MGTYTXN3_124 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AG36} [get_ports {eth_gt_pri_refclk_p[2]}] ;# MGTREFCLK0P_124
set_property -dict {LOC AG37} [get_ports {eth_gt_pri_refclk_n[2]}] ;# MGTREFCLK0N_124

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_2 [get_ports {eth_gt_pri_refclk_p[2]}]

# GTY quad 125
# 7132LB-48Y4C: SFP 13, 14, 15, 16
set_property -dict {LOC AA45} [get_ports {eth_gt_ch_rx_p[12]}] ;# MGTYRXP0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA46} [get_ports {eth_gt_ch_rx_n[12]}] ;# MGTYRXN0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA40} [get_ports {eth_gt_ch_tx_p[12]}] ;# MGTYTXP0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA41} [get_ports {eth_gt_ch_tx_n[12]}] ;# MGTYTXN0_125 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y43 } [get_ports {eth_gt_ch_rx_p[13]}] ;# MGTYRXP1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y44 } [get_ports {eth_gt_ch_rx_n[13]}] ;# MGTYRXN1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y38 } [get_ports {eth_gt_ch_tx_p[13]}] ;# MGTYTXP1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y39 } [get_ports {eth_gt_ch_tx_n[13]}] ;# MGTYTXN1_125 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W45 } [get_ports {eth_gt_ch_rx_p[14]}] ;# MGTYRXP2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W46 } [get_ports {eth_gt_ch_rx_n[14]}] ;# MGTYRXN2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W40 } [get_ports {eth_gt_ch_tx_p[14]}] ;# MGTYTXP2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W41 } [get_ports {eth_gt_ch_tx_n[14]}] ;# MGTYTXN2_125 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V43 } [get_ports {eth_gt_ch_rx_p[15]}] ;# MGTYRXP3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V44 } [get_ports {eth_gt_ch_rx_n[15]}] ;# MGTYRXN3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V38 } [get_ports {eth_gt_ch_tx_p[15]}] ;# MGTYTXP3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V39 } [get_ports {eth_gt_ch_tx_n[15]}] ;# MGTYTXN3_125 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AC36} [get_ports {eth_gt_pri_refclk_p[3]}] ;# MGTREFCLK0P_125
set_property -dict {LOC AC37} [get_ports {eth_gt_pri_refclk_n[3]}] ;# MGTREFCLK0N_125

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_3 [get_ports {eth_gt_pri_refclk_p[3]}]

# GTY quad 126
# 7132LB-48Y4C: SFP 17, 18, 19, 20
set_property -dict {LOC U45 } [get_ports {eth_gt_ch_rx_p[16]}] ;# MGTYRXP0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U46 } [get_ports {eth_gt_ch_rx_n[16]}] ;# MGTYRXN0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U40 } [get_ports {eth_gt_ch_tx_p[16]}] ;# MGTYTXP0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U41 } [get_ports {eth_gt_ch_tx_n[16]}] ;# MGTYTXN0_126 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T43 } [get_ports {eth_gt_ch_rx_p[17]}] ;# MGTYRXP1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T44 } [get_ports {eth_gt_ch_rx_n[17]}] ;# MGTYRXN1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T38 } [get_ports {eth_gt_ch_tx_p[17]}] ;# MGTYTXP1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T39 } [get_ports {eth_gt_ch_tx_n[17]}] ;# MGTYTXN1_126 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R45 } [get_ports {eth_gt_ch_rx_p[18]}] ;# MGTYRXP2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R46 } [get_ports {eth_gt_ch_rx_n[18]}] ;# MGTYRXN2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R40 } [get_ports {eth_gt_ch_tx_p[18]}] ;# MGTYTXP2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R41 } [get_ports {eth_gt_ch_tx_n[18]}] ;# MGTYTXN2_126 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P43 } [get_ports {eth_gt_ch_rx_p[19]}] ;# MGTYRXP3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P44 } [get_ports {eth_gt_ch_rx_n[19]}] ;# MGTYRXN3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P38 } [get_ports {eth_gt_ch_tx_p[19]}] ;# MGTYTXP3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P39 } [get_ports {eth_gt_ch_tx_n[19]}] ;# MGTYTXN3_126 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W36 } [get_ports {eth_gt_pri_refclk_p[4]}] ;# MGTREFCLK0P_126
set_property -dict {LOC W37 } [get_ports {eth_gt_pri_refclk_n[4]}] ;# MGTREFCLK0N_126
#set_property -dict {LOC U36 } [get_ports {eth_gt_sec_refclk_p[5]}] ;# MGTREFCLK1P_126
#set_property -dict {LOC U37 } [get_ports {eth_gt_sec_refclk_n[5]}] ;# MGTREFCLK1N_126

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_4 [get_ports {eth_gt_pri_refclk_p[4]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_5 [get_ports {eth_gt_sec_refclk_p[5]}]

# GTY quad 127
# 7132LB-48Y4C: SFP 21, 22, 23, 24
set_property -dict {LOC N45 } [get_ports {eth_gt_ch_rx_p[20]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N46 } [get_ports {eth_gt_ch_rx_n[20]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N40 } [get_ports {eth_gt_ch_tx_p[20]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N41 } [get_ports {eth_gt_ch_tx_n[20]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M43 } [get_ports {eth_gt_ch_rx_p[21]}] ;# MGTYRXP1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M44 } [get_ports {eth_gt_ch_rx_n[21]}] ;# MGTYRXN1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M38 } [get_ports {eth_gt_ch_tx_p[21]}] ;# MGTYTXP1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M39 } [get_ports {eth_gt_ch_tx_n[21]}] ;# MGTYTXN1_127 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L45 } [get_ports {eth_gt_ch_rx_p[22]}] ;# MGTYRXP2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L46 } [get_ports {eth_gt_ch_rx_n[22]}] ;# MGTYRXN2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L40 } [get_ports {eth_gt_ch_tx_p[22]}] ;# MGTYTXP2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L41 } [get_ports {eth_gt_ch_tx_n[22]}] ;# MGTYTXN2_127 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC K43 } [get_ports {eth_gt_ch_rx_p[23]}] ;# MGTYRXP3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC K44 } [get_ports {eth_gt_ch_rx_n[23]}] ;# MGTYRXN3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC J40 } [get_ports {eth_gt_ch_tx_p[23]}] ;# MGTYTXP3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC J41 } [get_ports {eth_gt_ch_tx_n[23]}] ;# MGTYTXN3_127 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC R36 } [get_ports {eth_gt_pri_refclk_p[5]}] ;# MGTREFCLK0P_127
set_property -dict {LOC R37 } [get_ports {eth_gt_pri_refclk_n[5]}] ;# MGTREFCLK0N_127

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_5 [get_ports {eth_gt_pri_refclk_p[5]}]

# GTY quad 232
# 7132LB-48Y4C: SFP 28, 27, 26, 25
set_property -dict {LOC F2  } [get_ports {eth_gt_ch_rx_p[24]}] ;# MGTYRXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC F1  } [get_ports {eth_gt_ch_rx_n[24]}] ;# MGTYRXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC F7  } [get_ports {eth_gt_ch_tx_p[24]}] ;# MGTYTXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC F6  } [get_ports {eth_gt_ch_tx_n[24]}] ;# MGTYTXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
set_property -dict {LOC G4  } [get_ports {eth_gt_ch_rx_p[25]}] ;# MGTYRXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC G3  } [get_ports {eth_gt_ch_rx_n[25]}] ;# MGTYRXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC G9  } [get_ports {eth_gt_ch_tx_p[25]}] ;# MGTYTXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC G8  } [get_ports {eth_gt_ch_tx_n[25]}] ;# MGTYTXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H2  } [get_ports {eth_gt_ch_rx_p[26]}] ;# MGTYRXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H1  } [get_ports {eth_gt_ch_rx_n[26]}] ;# MGTYRXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H7  } [get_ports {eth_gt_ch_tx_p[26]}] ;# MGTYTXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H6  } [get_ports {eth_gt_ch_tx_n[26]}] ;# MGTYTXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J4  } [get_ports {eth_gt_ch_rx_p[27]}] ;# MGTYRXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J3  } [get_ports {eth_gt_ch_rx_n[27]}] ;# MGTYRXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J9  } [get_ports {eth_gt_ch_tx_p[27]}] ;# MGTYTXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC J8  } [get_ports {eth_gt_ch_tx_n[27]}] ;# MGTYTXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
set_property -dict {LOC H11 } [get_ports {eth_gt_pri_refclk_p[6]}] ;# MGTREFCLK0P_232
set_property -dict {LOC H10 } [get_ports {eth_gt_pri_refclk_n[6]}] ;# MGTREFCLK0N_232

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_6 [get_ports {eth_gt_pri_refclk_p[6]}]

# GTY quad 231
# 7132LB-48Y4C: SFP 32, 31, 30, 29
set_property -dict {LOC K2  } [get_ports {eth_gt_ch_rx_p[28]}] ;# MGTYRXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K1  } [get_ports {eth_gt_ch_rx_n[28]}] ;# MGTYRXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K7  } [get_ports {eth_gt_ch_tx_p[28]}] ;# MGTYTXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC K6  } [get_ports {eth_gt_ch_tx_n[28]}] ;# MGTYTXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L4  } [get_ports {eth_gt_ch_rx_p[29]}] ;# MGTYRXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L3  } [get_ports {eth_gt_ch_rx_n[29]}] ;# MGTYRXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L9  } [get_ports {eth_gt_ch_tx_p[29]}] ;# MGTYTXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC L8  } [get_ports {eth_gt_ch_tx_n[29]}] ;# MGTYTXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M2  } [get_ports {eth_gt_ch_rx_p[30]}] ;# MGTYRXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M1  } [get_ports {eth_gt_ch_rx_n[30]}] ;# MGTYRXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M7  } [get_ports {eth_gt_ch_tx_p[30]}] ;# MGTYTXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M6  } [get_ports {eth_gt_ch_tx_n[30]}] ;# MGTYTXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N4  } [get_ports {eth_gt_ch_rx_p[31]}] ;# MGTYRXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N3  } [get_ports {eth_gt_ch_rx_n[31]}] ;# MGTYRXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N9  } [get_ports {eth_gt_ch_tx_p[31]}] ;# MGTYTXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC N8  } [get_ports {eth_gt_ch_tx_n[31]}] ;# MGTYTXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
set_property -dict {LOC M11 } [get_ports {eth_gt_pri_refclk_p[7]}] ;# MGTREFCLK0P_231
set_property -dict {LOC M10 } [get_ports {eth_gt_pri_refclk_n[7]}] ;# MGTREFCLK0N_231
#set_property -dict {LOC K11 } [get_ports {eth_gt_sec_refclk_p[2]}] ;# MGTREFCLK1P_231
#set_property -dict {LOC K10 } [get_ports {eth_gt_sec_refclk_n[2]}] ;# MGTREFCLK1N_231

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_7 [get_ports {eth_gt_pri_refclk_p[7]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_2 [get_ports {eth_gt_sec_refclk_p[2]}]

# GTY quad 230
# 7132LB-48Y4C: SFP 36, 35, 34, 33
set_property -dict {LOC P2  } [get_ports {eth_gt_ch_rx_p[32]}] ;# MGTYRXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P1  } [get_ports {eth_gt_ch_rx_n[32]}] ;# MGTYRXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P7  } [get_ports {eth_gt_ch_tx_p[32]}] ;# MGTYTXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC P6  } [get_ports {eth_gt_ch_tx_n[32]}] ;# MGTYTXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R4  } [get_ports {eth_gt_ch_rx_p[33]}] ;# MGTYRXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R3  } [get_ports {eth_gt_ch_rx_n[33]}] ;# MGTYRXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R9  } [get_ports {eth_gt_ch_tx_p[33]}] ;# MGTYTXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC R8  } [get_ports {eth_gt_ch_tx_n[33]}] ;# MGTYTXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T2  } [get_ports {eth_gt_ch_rx_p[34]}] ;# MGTYRXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T1  } [get_ports {eth_gt_ch_rx_n[34]}] ;# MGTYRXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T7  } [get_ports {eth_gt_ch_tx_p[34]}] ;# MGTYTXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T6  } [get_ports {eth_gt_ch_tx_n[34]}] ;# MGTYTXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U4  } [get_ports {eth_gt_ch_rx_p[35]}] ;# MGTYRXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U3  } [get_ports {eth_gt_ch_rx_n[35]}] ;# MGTYRXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U9  } [get_ports {eth_gt_ch_tx_p[35]}] ;# MGTYTXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC U8  } [get_ports {eth_gt_ch_tx_n[35]}] ;# MGTYTXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
set_property -dict {LOC T11 } [get_ports {eth_gt_pri_refclk_p[8]}] ;# MGTREFCLK0P_230
set_property -dict {LOC T10 } [get_ports {eth_gt_pri_refclk_n[8]}] ;# MGTREFCLK0N_230

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_8 [get_ports {eth_gt_pri_refclk_p[8]}]

# GTY quad 229
# 7132LB-48Y4C: SFP 40, 39, 38, 37
set_property -dict {LOC V2  } [get_ports {eth_gt_ch_rx_p[36]}] ;# MGTYRXP3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
set_property -dict {LOC V1  } [get_ports {eth_gt_ch_rx_n[36]}] ;# MGTYRXN3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
set_property -dict {LOC V7  } [get_ports {eth_gt_ch_tx_p[36]}] ;# MGTYTXP3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
set_property -dict {LOC V6  } [get_ports {eth_gt_ch_tx_n[36]}] ;# MGTYTXN3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
set_property -dict {LOC W4  } [get_ports {eth_gt_ch_rx_p[37]}] ;# MGTYRXP2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
set_property -dict {LOC W3  } [get_ports {eth_gt_ch_rx_n[37]}] ;# MGTYRXN2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
set_property -dict {LOC W9  } [get_ports {eth_gt_ch_tx_p[37]}] ;# MGTYTXP2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
set_property -dict {LOC W8  } [get_ports {eth_gt_ch_tx_n[37]}] ;# MGTYTXN2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
set_property -dict {LOC Y2  } [get_ports {eth_gt_ch_rx_p[38]}] ;# MGTYRXP1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
set_property -dict {LOC Y1  } [get_ports {eth_gt_ch_rx_n[38]}] ;# MGTYRXN1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
set_property -dict {LOC Y7  } [get_ports {eth_gt_ch_tx_p[38]}] ;# MGTYTXP1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
set_property -dict {LOC Y6  } [get_ports {eth_gt_ch_tx_n[38]}] ;# MGTYTXN1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
set_property -dict {LOC AA4 } [get_ports {eth_gt_ch_rx_p[39]}] ;# MGTYRXP0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
set_property -dict {LOC AA3 } [get_ports {eth_gt_ch_rx_n[39]}] ;# MGTYRXNN_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
set_property -dict {LOC AA9 } [get_ports {eth_gt_ch_tx_p[39]}] ;# MGTYTXP0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
set_property -dict {LOC AA8 } [get_ports {eth_gt_ch_tx_n[39]}] ;# MGTYTXNN_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
set_property -dict {LOC Y11 } [get_ports {eth_gt_pri_refclk_p[9]}] ;# MGTREFCLK0P_229
set_property -dict {LOC Y10 } [get_ports {eth_gt_pri_refclk_n[9]}] ;# MGTREFCLK0N_229
#set_property -dict {LOC V11 } [get_ports {eth_gt_sec_refclk_p[1]}] ;# MGTREFCLK1P_229
#set_property -dict {LOC V10 } [get_ports {eth_gt_sec_refclk_n[1]}] ;# MGTREFCLK1N_229

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_9 [get_ports {eth_gt_pri_refclk_p[9]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_1 [get_ports {eth_gt_sec_refclk_p[1]}]

# GTY quad 228
# 7132LB-48Y4C: SFP 44, 43, 42, 41
set_property -dict {LOC AB2 } [get_ports {eth_gt_ch_rx_p[40]}] ;# MGTYRXP3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AB1 } [get_ports {eth_gt_ch_rx_n[40]}] ;# MGTYRXN3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AB7 } [get_ports {eth_gt_ch_tx_p[40]}] ;# MGTYTXP3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AB6 } [get_ports {eth_gt_ch_tx_n[40]}] ;# MGTYTXN3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AC4 } [get_ports {eth_gt_ch_rx_p[41]}] ;# MGTYRXP2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AC3 } [get_ports {eth_gt_ch_rx_n[41]}] ;# MGTYRXN2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AC9 } [get_ports {eth_gt_ch_tx_p[41]}] ;# MGTYTXP2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AC8 } [get_ports {eth_gt_ch_tx_n[41]}] ;# MGTYTXN2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AD2 } [get_ports {eth_gt_ch_rx_p[42]}] ;# MGTYRXP1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AD1 } [get_ports {eth_gt_ch_rx_n[42]}] ;# MGTYRXN1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AD7 } [get_ports {eth_gt_ch_tx_p[42]}] ;# MGTYTXP1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AD6 } [get_ports {eth_gt_ch_tx_n[42]}] ;# MGTYTXN1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AE4 } [get_ports {eth_gt_ch_rx_p[43]}] ;# MGTYRXP0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AE3 } [get_ports {eth_gt_ch_rx_n[43]}] ;# MGTYRXN0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AE9 } [get_ports {eth_gt_ch_tx_p[43]}] ;# MGTYTXP0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AE8 } [get_ports {eth_gt_ch_tx_n[43]}] ;# MGTYTXN0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
set_property -dict {LOC AD11} [get_ports {eth_gt_pri_refclk_p[10]}] ;# MGTREFCLK0P_228
set_property -dict {LOC AD10} [get_ports {eth_gt_pri_refclk_n[10]}] ;# MGTREFCLK0N_228

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_10 [get_ports {eth_gt_pri_refclk_p[10]}]

# GTY quad 227
# 7132LB-48Y4C: SFP 48, 47, 46, 45
set_property -dict {LOC AF2 } [get_ports {eth_gt_ch_rx_p[44]}] ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AF1 } [get_ports {eth_gt_ch_rx_n[44]}] ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AF7 } [get_ports {eth_gt_ch_tx_p[44]}] ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AF6 } [get_ports {eth_gt_ch_tx_n[44]}] ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AG4 } [get_ports {eth_gt_ch_rx_p[45]}] ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AG3 } [get_ports {eth_gt_ch_rx_n[45]}] ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AG9 } [get_ports {eth_gt_ch_tx_p[45]}] ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AG8 } [get_ports {eth_gt_ch_tx_n[45]}] ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AH2 } [get_ports {eth_gt_ch_rx_p[46]}] ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AH1 } [get_ports {eth_gt_ch_rx_n[46]}] ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AH7 } [get_ports {eth_gt_ch_tx_p[46]}] ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AH6 } [get_ports {eth_gt_ch_tx_n[46]}] ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AJ4 } [get_ports {eth_gt_ch_rx_p[47]}] ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AJ3 } [get_ports {eth_gt_ch_rx_n[47]}] ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AJ9 } [get_ports {eth_gt_ch_tx_p[47]}] ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AJ8 } [get_ports {eth_gt_ch_tx_n[47]}] ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
set_property -dict {LOC AH11} [get_ports {eth_gt_pri_refclk_p[11]}] ;# MGTREFCLK0P_227
set_property -dict {LOC AH10} [get_ports {eth_gt_pri_refclk_n[11]}] ;# MGTREFCLK0N_227
#set_property -dict {LOC AF11} [get_ports {eth_gt_sec_refclk_p[0]}] ;# MGTREFCLK1P_227
#set_property -dict {LOC AF10} [get_ports {eth_gt_sec_refclk_n[0]}] ;# MGTREFCLK1N_227

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_11 [get_ports {eth_gt_pri_refclk_p[11]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_0 [get_ports {eth_gt_sec_refclk_p[0]}]

# GTY quad 120
# 7132LB-48Y4C: QSFP 49 lanes 1, 2, 3, 4
set_property -dict {LOC BC45} [get_ports {eth_gt_ch_rx_p[48]}] ;# MGTYRXP0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BC46} [get_ports {eth_gt_ch_rx_n[48]}] ;# MGTYRXN0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BF42} [get_ports {eth_gt_ch_tx_p[48]}] ;# MGTYTXP0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BF43} [get_ports {eth_gt_ch_tx_n[48]}] ;# MGTYTXN0_120 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA45} [get_ports {eth_gt_ch_rx_p[49]}] ;# MGTYRXP1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA46} [get_ports {eth_gt_ch_rx_n[49]}] ;# MGTYRXN1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BD42} [get_ports {eth_gt_ch_tx_p[49]}] ;# MGTYTXP1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BD43} [get_ports {eth_gt_ch_tx_n[49]}] ;# MGTYTXN1_120 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW45} [get_ports {eth_gt_ch_rx_p[50]}] ;# MGTYRXP2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW46} [get_ports {eth_gt_ch_rx_n[50]}] ;# MGTYRXN2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BB42} [get_ports {eth_gt_ch_tx_p[50]}] ;# MGTYTXP2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BB43} [get_ports {eth_gt_ch_tx_n[50]}] ;# MGTYTXN2_120 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AV43} [get_ports {eth_gt_ch_rx_p[51]}] ;# MGTYRXP3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AV44} [get_ports {eth_gt_ch_rx_n[51]}] ;# MGTYRXN3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW40} [get_ports {eth_gt_ch_tx_p[51]}] ;# MGTYTXP3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW41} [get_ports {eth_gt_ch_tx_n[51]}] ;# MGTYTXN3_120 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA40} [get_ports {eth_gt_pri_refclk_p[12]}] ;# MGTREFCLK0P_120
set_property -dict {LOC BA41} [get_ports {eth_gt_pri_refclk_n[12]}] ;# MGTREFCLK0N_120

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_12 [get_ports {eth_gt_pri_refclk_p[12]}]

# GTY quad 128
# 7132LB-48Y4C: QSFP 50 lanes 1, 2, 3, 4
set_property -dict {LOC J45 } [get_ports {eth_gt_ch_rx_p[52]}] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC J46 } [get_ports {eth_gt_ch_rx_n[52]}] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC G40 } [get_ports {eth_gt_ch_tx_p[52]}] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC G41 } [get_ports {eth_gt_ch_tx_n[52]}] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC H43 } [get_ports {eth_gt_ch_rx_p[53]}] ;# MGTYRXP1_128 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC H44 } [get_ports {eth_gt_ch_rx_n[53]}] ;# MGTYRXN1_128 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC E42 } [get_ports {eth_gt_ch_tx_p[53]}] ;# MGTYTXP1_128 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC E43 } [get_ports {eth_gt_ch_tx_n[53]}] ;# MGTYTXN1_128 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC F45 } [get_ports {eth_gt_ch_rx_p[54]}] ;# MGTYRXP2_128 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC F46 } [get_ports {eth_gt_ch_rx_n[54]}] ;# MGTYRXN2_128 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC C42 } [get_ports {eth_gt_ch_tx_p[54]}] ;# MGTYTXP2_128 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC C43 } [get_ports {eth_gt_ch_tx_n[54]}] ;# MGTYTXN2_128 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC D45 } [get_ports {eth_gt_ch_rx_p[55]}] ;# MGTYRXP3_128 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC D46 } [get_ports {eth_gt_ch_rx_n[55]}] ;# MGTYRXN3_128 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC A42 } [get_ports {eth_gt_ch_tx_p[55]}] ;# MGTYTXP3_128 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC A43 } [get_ports {eth_gt_ch_tx_n[55]}] ;# MGTYTXN3_128 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC L36 } [get_ports {eth_gt_pri_refclk_p[13]}] ;# MGTREFCLK0P_128
set_property -dict {LOC L37 } [get_ports {eth_gt_pri_refclk_n[13]}] ;# MGTREFCLK0N_128
#set_property -dict {LOC K38 } [get_ports {eth_gt_sec_refclk_p[6]}] ;# MGTREFCLK1P_128
#set_property -dict {LOC K39 } [get_ports {eth_gt_sec_refclk_n[6]}] ;# MGTREFCLK1N_128

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_13 [get_ports {eth_gt_pri_refclk_p[13]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_6 [get_ports {eth_gt_sec_refclk_p[6]}]

# GTY quad 233
# 7132LB-48Y4C: QSFP 51 lanes 1, 2, 3, 4
set_property -dict {LOC E4  } [get_ports {eth_gt_ch_rx_p[56]}] ;# MGTYRXP0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
set_property -dict {LOC E3  } [get_ports {eth_gt_ch_rx_n[56]}] ;# MGTYRXN0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
set_property -dict {LOC E9  } [get_ports {eth_gt_ch_tx_p[56]}] ;# MGTYTXP0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
set_property -dict {LOC E8  } [get_ports {eth_gt_ch_tx_n[56]}] ;# MGTYTXN0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
set_property -dict {LOC D2  } [get_ports {eth_gt_ch_rx_p[57]}] ;# MGTYRXP1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
set_property -dict {LOC D1  } [get_ports {eth_gt_ch_rx_n[57]}] ;# MGTYRXN1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
set_property -dict {LOC D7  } [get_ports {eth_gt_ch_tx_p[57]}] ;# MGTYTXP1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
set_property -dict {LOC D6  } [get_ports {eth_gt_ch_tx_n[57]}] ;# MGTYTXN1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
set_property -dict {LOC C4  } [get_ports {eth_gt_ch_rx_p[58]}] ;# MGTYRXP2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
set_property -dict {LOC C3  } [get_ports {eth_gt_ch_rx_n[58]}] ;# MGTYRXN2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
set_property -dict {LOC C9  } [get_ports {eth_gt_ch_tx_p[58]}] ;# MGTYTXP2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
set_property -dict {LOC C8  } [get_ports {eth_gt_ch_tx_n[58]}] ;# MGTYTXN2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
set_property -dict {LOC A5  } [get_ports {eth_gt_ch_rx_p[59]}] ;# MGTYRXP3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
set_property -dict {LOC A4  } [get_ports {eth_gt_ch_rx_n[59]}] ;# MGTYRXN3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
set_property -dict {LOC A9  } [get_ports {eth_gt_ch_tx_p[59]}] ;# MGTYTXP3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
set_property -dict {LOC A8  } [get_ports {eth_gt_ch_tx_n[59]}] ;# MGTYTXN3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
set_property -dict {LOC D11 } [get_ports {eth_gt_pri_refclk_p[14]}] ;# MGTREFCLK0P_233
set_property -dict {LOC D10 } [get_ports {eth_gt_pri_refclk_n[14]}] ;# MGTREFCLK0N_233
#set_property -dict {LOC B11 } [get_ports {eth_gt_sec_refclk_p[3]}] ;# MGTREFCLK1P_233
#set_property -dict {LOC B10 } [get_ports {eth_gt_sec_refclk_n[3]}] ;# MGTREFCLK1N_233

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_14 [get_ports {eth_gt_pri_refclk_p[14]}]

# 125 MHz MGT secondary reference clock
#create_clock -period 8.000 -name eth_gt_sec_refclk_3 [get_ports {eth_gt_sec_refclk_p[3]}]

# GTY quad 226
# 7132LB-48Y4C: QSFP 52 lanes 1, 2, 3, 4
set_property -dict {LOC AN4 } [get_ports {eth_gt_ch_rx_p[60]}] ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AN3 } [get_ports {eth_gt_ch_rx_n[60]}] ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AN9 } [get_ports {eth_gt_ch_tx_p[60]}] ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AN8 } [get_ports {eth_gt_ch_tx_n[60]}] ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AM2 } [get_ports {eth_gt_ch_rx_p[61]}] ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AM1 } [get_ports {eth_gt_ch_rx_n[61]}] ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AM7 } [get_ports {eth_gt_ch_tx_p[61]}] ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AM6 } [get_ports {eth_gt_ch_tx_n[61]}] ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AL4 } [get_ports {eth_gt_ch_rx_p[62]}] ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AL3 } [get_ports {eth_gt_ch_rx_n[62]}] ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AL9 } [get_ports {eth_gt_ch_tx_p[62]}] ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AL8 } [get_ports {eth_gt_ch_tx_n[62]}] ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AK2 } [get_ports {eth_gt_ch_rx_p[63]}] ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AK1 } [get_ports {eth_gt_ch_rx_n[63]}] ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AK7 } [get_ports {eth_gt_ch_tx_p[63]}] ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AK6 } [get_ports {eth_gt_ch_tx_n[63]}] ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
set_property -dict {LOC AM11} [get_ports {eth_gt_pri_refclk_p[15]}] ;# MGTREFCLK0P_226
set_property -dict {LOC AM10} [get_ports {eth_gt_pri_refclk_n[15]}] ;# MGTREFCLK0N_226

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_15 [get_ports {eth_gt_pri_refclk_p[15]}]

# GTY quad 121
# 7132LB-48Y4C: CPU ports
set_property -dict {LOC AU45} [get_ports {eth_gt_ch_rx_p[64]}] ;# MGTYRXP0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU46} [get_ports {eth_gt_ch_rx_n[64]}] ;# MGTYRXN0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU40} [get_ports {eth_gt_ch_tx_p[64]}] ;# MGTYTXP0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU41} [get_ports {eth_gt_ch_tx_n[64]}] ;# MGTYTXN0_121 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT43} [get_ports {eth_gt_ch_rx_p[65]}] ;# MGTYRXP1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT44} [get_ports {eth_gt_ch_rx_n[65]}] ;# MGTYRXN1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT38} [get_ports {eth_gt_ch_tx_p[65]}] ;# MGTYTXP1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT39} [get_ports {eth_gt_ch_tx_n[65]}] ;# MGTYTXN1_121 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR45} [get_ports {eth_gt_ch_rx_p[66]}] ;# MGTYRXP2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR46} [get_ports {eth_gt_ch_rx_n[66]}] ;# MGTYRXN2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR40} [get_ports {eth_gt_ch_tx_p[66]}] ;# MGTYTXP2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR41} [get_ports {eth_gt_ch_tx_n[66]}] ;# MGTYTXN2_121 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP43} [get_ports {eth_gt_ch_rx_p[67]}] ;# MGTYRXP3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP44} [get_ports {eth_gt_ch_rx_n[67]}] ;# MGTYRXN3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP38} [get_ports {eth_gt_ch_tx_p[67]}] ;# MGTYTXP3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP39} [get_ports {eth_gt_ch_tx_n[67]}] ;# MGTYTXN3_121 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AV38} [get_ports {eth_gt_pri_refclk_p[16]}] ;# MGTREFCLK0P_121
set_property -dict {LOC AV39} [get_ports {eth_gt_pri_refclk_n[16]}] ;# MGTREFCLK0N_121

# 156.25 MHz MGT primary reference clock
create_clock -period 6.400 -name eth_gt_pri_refclk_16 [get_ports {eth_gt_pri_refclk_p[16]}]

# PCIe Interface
#set_property -dict {LOC AP2 } [get_ports {pcie_rx_p[0]}] ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP1 } [get_ports {pcie_rx_n[0]}] ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP7 } [get_ports {pcie_tx_p[0]}] ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP6 } [get_ports {pcie_tx_n[0]}] ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR4 } [get_ports {pcie_rx_p[1]}] ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR3 } [get_ports {pcie_rx_n[1]}] ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR9 } [get_ports {pcie_tx_p[1]}] ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR8 } [get_ports {pcie_tx_n[1]}] ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT2 } [get_ports {pcie_rx_p[2]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT1 } [get_ports {pcie_rx_n[2]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT7 } [get_ports {pcie_tx_p[2]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT6 } [get_ports {pcie_tx_n[2]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU4 } [get_ports {pcie_rx_p[3]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU3 } [get_ports {pcie_rx_n[3]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU9 } [get_ports {pcie_tx_p[3]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU8 } [get_ports {pcie_tx_n[3]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AV2 } [get_ports {pcie_rx_p[4]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV1 } [get_ports {pcie_rx_n[4]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV7 } [get_ports {pcie_tx_p[4]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AV6 } [get_ports {pcie_tx_n[4]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW4 } [get_ports {pcie_rx_p[5]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AW3 } [get_ports {pcie_rx_n[5]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB5 } [get_ports {pcie_tx_p[5]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BB4 } [get_ports {pcie_tx_n[5]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA2 } [get_ports {pcie_rx_p[6]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BA1 } [get_ports {pcie_rx_n[6]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD5 } [get_ports {pcie_tx_p[6]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BD4 } [get_ports {pcie_tx_n[6]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC2 } [get_ports {pcie_rx_p[7]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BC1 } [get_ports {pcie_rx_n[7]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF5 } [get_ports {pcie_tx_p[7]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC BF4 } [get_ports {pcie_tx_n[7]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AT11} [get_ports pcie_refclk_p]  ;# MGTREFCLK0P_225
#set_property -dict {LOC AT10} [get_ports pcie_refclk_n]  ;# MGTREFCLK0P_225
#set_property -dict {LOC AR26 IOSTANDARD LVCMOS12} [get_ports pcie_rst_n]
#set_property -dict {LOC BF8  IOSTANDARD LVCMOS18} [get_ports pcie_wake_n]

# 100 MHz MGT reference clock
#create_clock -period 10.000 -name pcie_mgt_refclk [get_ports pcie_refclk_p]

#set_false_path -from [get_ports {pcie_rst_n pcie_wake_n}]
#set_input_delay 0 [get_ports {pcie_rst_n pcie_wake_n}]
