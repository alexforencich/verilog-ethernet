# XDC constraints for the Xilinx ZCU102 board
# part: xczu9eg-ffvb1156-2-e

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
# 125 MHz
set_property -dict {LOC G21  IOSTANDARD LVDS_25} [get_ports clk_125mhz_p]
set_property -dict {LOC F21  IOSTANDARD LVDS_25} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# LEDs
set_property -dict {LOC AG14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AF13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AE13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC AJ14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC AJ15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AH13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AH14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC AL12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC AM13 IOSTANDARD LVCMOS33} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC AG15 IOSTANDARD LVCMOS33} [get_ports btnu]
set_property -dict {LOC AF15 IOSTANDARD LVCMOS33} [get_ports btnl]
set_property -dict {LOC AE15 IOSTANDARD LVCMOS33} [get_ports btnd]
set_property -dict {LOC AE14 IOSTANDARD LVCMOS33} [get_ports btnr]
set_property -dict {LOC AG13 IOSTANDARD LVCMOS33} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC AN14 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {LOC AP14 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {LOC AM14 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {LOC AN13 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {LOC AN12 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {LOC AP12 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {LOC AL13 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {LOC AK13 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC F13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC E13  IOSTANDARD LVCMOS33} [get_ports uart_rxd]
set_property -dict {LOC D12  IOSTANDARD LVCMOS33} [get_ports uart_rts]
set_property -dict {LOC E12  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_cts}]
set_output_delay 0 [get_ports {uart_txd uart_cts}]
set_false_path -from [get_ports {uart_rxd uart_rts}]
set_input_delay 0 [get_ports {uart_rxd uart_rts}]


# I2C interfaces
#set_property -dict {LOC J10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c0_scl]
#set_property -dict {LOC J11  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c0_sda]
#set_property -dict {LOC K20  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c1_scl]
#set_property -dict {LOC L20  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c1_sda]

#set_false_path -to [get_ports {i2c1_sda i2c1_scl}]
#set_output_delay 0 [get_ports {i2c1_sda i2c1_scl}]
#set_false_path -from [get_ports {i2c1_sda i2c1_scl}]
#set_input_delay 0 [get_ports {i2c1_sda i2c1_scl}]

# SFP+ Interface
set_property -dict {LOC D2  } [get_ports sfp0_rx_p] ;# MGTHRXP0_230 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC D1  } [get_ports sfp0_rx_n] ;# MGTHRXN0_230 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC E4  } [get_ports sfp0_tx_p] ;# MGTHTXP0_230 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC E3  } [get_ports sfp0_tx_n] ;# MGTHTXN0_230 GTHE4_CHANNEL_X1Y12 / GTHE4_COMMON_X1Y3
set_property -dict {LOC C4  } [get_ports sfp1_rx_p] ;# MGTHRXP1_230 GTHE4_CHANNEL_X1Y13 / GTHE4_COMMON_X1Y3
set_property -dict {LOC C3  } [get_ports sfp1_rx_n] ;# MGTHRXN1_230 GTHE4_CHANNEL_X1Y13 / GTHE4_COMMON_X1Y3
set_property -dict {LOC D6  } [get_ports sfp1_tx_p] ;# MGTHTXP1_230 GTHE4_CHANNEL_X1Y13 / GTHE4_COMMON_X1Y3
set_property -dict {LOC D5  } [get_ports sfp1_tx_n] ;# MGTHTXN1_230 GTHE4_CHANNEL_X1Y13 / GTHE4_COMMON_X1Y3
set_property -dict {LOC B2  } [get_ports sfp2_rx_p] ;# MGTHRXP2_230 GTHE4_CHANNEL_X1Y14 / GTHE4_COMMON_X1Y3
set_property -dict {LOC B1  } [get_ports sfp2_rx_n] ;# MGTHRXN2_230 GTHE4_CHANNEL_X1Y14 / GTHE4_COMMON_X1Y3
set_property -dict {LOC B6  } [get_ports sfp2_tx_p] ;# MGTHTXP2_230 GTHE4_CHANNEL_X1Y14 / GTHE4_COMMON_X1Y3
set_property -dict {LOC B5  } [get_ports sfp2_tx_n] ;# MGTHTXN2_230 GTHE4_CHANNEL_X1Y14 / GTHE4_COMMON_X1Y3
set_property -dict {LOC A4  } [get_ports sfp3_rx_p] ;# MGTHRXP3_230 GTHE4_CHANNEL_X1Y15 / GTHE4_COMMON_X1Y3
set_property -dict {LOC A3  } [get_ports sfp3_rx_n] ;# MGTHRXN3_230 GTHE4_CHANNEL_X1Y15 / GTHE4_COMMON_X1Y3
set_property -dict {LOC A8  } [get_ports sfp3_tx_p] ;# MGTHTXP3_230 GTHE4_CHANNEL_X1Y15 / GTHE4_COMMON_X1Y3
set_property -dict {LOC A7  } [get_ports sfp3_tx_n] ;# MGTHTXN3_230 GTHE4_CHANNEL_X1Y15 / GTHE4_COMMON_X1Y3
set_property -dict {LOC C8  } [get_ports sfp_mgt_refclk_0_p] ;# MGTREFCLK0P_230 from U56 SI570 via U51 SI53340
set_property -dict {LOC C7  } [get_ports sfp_mgt_refclk_0_n] ;# MGTREFCLK0N_230 from U56 SI570 via U51 SI53340
#set_property -dict {LOC B10 } [get_ports sfp_mgt_refclk_1_p] ;# MGTREFCLK1P_230 from U20 CKOUT2 SI5328
#set_property -dict {LOC B9  } [get_ports sfp_mgt_refclk_1_n] ;# MGTREFCLK1N_230 from U20 CKOUT2 SI5328
#set_property -dict {LOC R10  IOSTANDARD LVDS} [get_ports sfp_recclk_p] ;# to U20 CKIN1 SI5328
#set_property -dict {LOC R9   IOSTANDARD LVDS} [get_ports sfp_recclk_n] ;# to U20 CKIN1 SI5328
set_property -dict {LOC A12  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp0_tx_disable_b]
set_property -dict {LOC A13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp1_tx_disable_b]
set_property -dict {LOC B13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp2_tx_disable_b]
set_property -dict {LOC C13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports sfp3_tx_disable_b]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name sfp_mgt_refclk_0 [get_ports sfp_mgt_refclk_0_p]

set_false_path -to [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b sfp2_tx_disable_b sfp3_tx_disable_b}]
set_output_delay 0 [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b sfp2_tx_disable_b sfp3_tx_disable_b}]

# DDR4
# 1x MT40A256M16GE-075E
#set_property -dict {LOC AM8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[0]}]
#set_property -dict {LOC AM9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[1]}]
#set_property -dict {LOC AP8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[2]}]
#set_property -dict {LOC AN8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[3]}]
#set_property -dict {LOC AK10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[4]}]
#set_property -dict {LOC AJ10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[5]}]
#set_property -dict {LOC AP9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[6]}]
#set_property -dict {LOC AN9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[7]}]
#set_property -dict {LOC AP10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[8]}]
#set_property -dict {LOC AP11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[9]}]
#set_property -dict {LOC AM10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[10]}]
#set_property -dict {LOC AL10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[11]}]
#set_property -dict {LOC AM11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[12]}]
#set_property -dict {LOC AL11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[13]}]
#set_property -dict {LOC AJ7  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[14]}]
#set_property -dict {LOC AL5  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[15]}]
#set_property -dict {LOC AJ9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[16]}]
#set_property -dict {LOC AK12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_ba[0]}]
#set_property -dict {LOC AJ12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_ba[1]}]
#set_property -dict {LOC AK7  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_bg[0]}]
#set_property -dict {LOC AN7  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_ck_t}]
#set_property -dict {LOC AP7  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_ck_c}]
#set_property -dict {LOC AM3  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_cke}]
#set_property -dict {LOC AP2  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_cs_n}]
#set_property -dict {LOC AK8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_act_n}]
#set_property -dict {LOC AK9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_odt}]
#set_property -dict {LOC AP1  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_par}]
#set_property -dict {LOC AH9  IOSTANDARD LVCMOS12       } [get_ports {ddr4_reset_n}]

#set_property -dict {LOC AK4  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[0]}]       ;# U2.G2 DQL0
#set_property -dict {LOC AK5  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[1]}]       ;# U2.F7 DQL1
#set_property -dict {LOC AN4  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[2]}]       ;# U2.H3 DQL2
#set_property -dict {LOC AM4  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[3]}]       ;# U2.H7 DQL3
#set_property -dict {LOC AP4  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[4]}]       ;# U2.H2 DQL4
#set_property -dict {LOC AP5  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[5]}]       ;# U2.H8 DQL5
#set_property -dict {LOC AM5  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[6]}]       ;# U2.J3 DQL6
#set_property -dict {LOC AM6  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[7]}]       ;# U2.J7 DQL7
#set_property -dict {LOC AK2  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[8]}]       ;# U2.A3 DQU0
#set_property -dict {LOC AK3  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[9]}]       ;# U2.B8 DQU1
#set_property -dict {LOC AL1  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[10]}]      ;# U2.C3 DQU2
#set_property -dict {LOC AK1  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[11]}]      ;# U2.C7 DQU3
#set_property -dict {LOC AN1  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[12]}]      ;# U2.C2 DQU4
#set_property -dict {LOC AM1  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[13]}]      ;# U2.C8 DQU5
#set_property -dict {LOC AP3  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[14]}]      ;# U2.D3 DQU6
#set_property -dict {LOC AN3  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[15]}]      ;# U2.D7 DQU7
#set_property -dict {LOC AN6  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[0]}]    ;# U2.G3 DQSL_T
#set_property -dict {LOC AP6  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[0]}]    ;# U2.F3 DQSL_C
#set_property -dict {LOC AL3  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[1]}]    ;# U2.B7 DQSU_T
#set_property -dict {LOC AL2  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[1]}]    ;# U2.A7 DQSU_C
#set_property -dict {LOC AL6  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[0]}] ;# U2.E7 DML_B/DBIL_B
#set_property -dict {LOC AN2  IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[1]}] ;# U2.E2 DMU_B/DBIU_B
