# XDC constraints for the Xilinx ZCU106 board
# part: xczu7ev-ffvc1156-2-e

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
# 125 MHz
set_property -dict {LOC H9  IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC G9  IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# LEDs
set_property -dict {LOC AL11 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AL13 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AK13 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC AE15 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC AM8  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AM9  IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AM10 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC AM11 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Reset button
set_property -dict {LOC G13  IOSTANDARD LVCMOS12} [get_ports reset]

set_false_path -from [get_ports {reset}]
set_input_delay 0 [get_ports {reset}]

# Push buttons
set_property -dict {LOC AG13 IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC AK12 IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC AP20 IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC AC14 IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC AL10 IOSTANDARD LVCMOS12} [get_ports btnc]

set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# DIP switches
set_property -dict {LOC A17  IOSTANDARD LVCMOS18} [get_ports {sw[0]}]
set_property -dict {LOC A16  IOSTANDARD LVCMOS18} [get_ports {sw[1]}]
set_property -dict {LOC B16  IOSTANDARD LVCMOS18} [get_ports {sw[2]}]
set_property -dict {LOC B15  IOSTANDARD LVCMOS18} [get_ports {sw[3]}]
set_property -dict {LOC A15  IOSTANDARD LVCMOS18} [get_ports {sw[4]}]
set_property -dict {LOC A14  IOSTANDARD LVCMOS18} [get_ports {sw[5]}]
set_property -dict {LOC B14  IOSTANDARD LVCMOS18} [get_ports {sw[6]}]
set_property -dict {LOC B13  IOSTANDARD LVCMOS18} [get_ports {sw[7]}]

set_false_path -from [get_ports {sw[*]}]
set_input_delay 0 [get_ports {sw[*]}]

# UART
set_property -dict {LOC AL17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC AH17 IOSTANDARD LVCMOS12} [get_ports uart_rxd]
set_property -dict {LOC AM15 IOSTANDARD LVCMOS12} [get_ports uart_rts]
set_property -dict {LOC AP17 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports uart_cts]

set_false_path -to [get_ports {uart_txd uart_cts}]
set_output_delay 0 [get_ports {uart_txd uart_cts}]
set_false_path -from [get_ports {uart_rxd uart_rts}]
set_input_delay 0 [get_ports {uart_rxd uart_rts}]

# I2C interfaces
#set_property -dict {LOC AE19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c0_scl]
#set_property -dict {LOC AH23 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c0_sda]
#set_property -dict {LOC AH19 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c1_scl]
#set_property -dict {LOC AL21 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports i2c1_sda]

#set_false_path -to [get_ports {i2c1_sda i2c1_scl}]
#set_output_delay 0 [get_ports {i2c1_sda i2c1_scl}]
#set_false_path -from [get_ports {i2c1_sda i2c1_scl}]
#set_input_delay 0 [get_ports {i2c1_sda i2c1_scl}]

# SFP+ Interface
set_property -dict {LOC AA2 } [get_ports sfp0_rx_p] ;# MGTHRXP2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC AA1 } [get_ports sfp0_rx_n] ;# MGTHRXN2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC Y4  } [get_ports sfp0_tx_p] ;# MGTHTXP2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC Y3  } [get_ports sfp0_tx_n] ;# MGTHTXN2_225 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W2  } [get_ports sfp1_rx_p] ;# MGTHRXP3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W1  } [get_ports sfp1_rx_n] ;# MGTHRXN3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W6  } [get_ports sfp1_tx_p] ;# MGTHTXP3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC W5  } [get_ports sfp1_tx_n] ;# MGTHTXN3_225 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
set_property -dict {LOC U10 } [get_ports sfp_mgt_refclk_0_p] ;# MGTREFCLK1P_226 from U56 SI570 via U51 SI53340
set_property -dict {LOC U9  } [get_ports sfp_mgt_refclk_0_n] ;# MGTREFCLK1N_226 from U56 SI570 via U51 SI53340
#set_property -dict {LOC W10 } [get_ports sfp_mgt_refclk_1_p] ;# MGTREFCLK1P_225 from U20 CKOUT2 SI5328
#set_property -dict {LOC W9  } [get_ports sfp_mgt_refclk_1_n] ;# MGTREFCLK1N_225 from U20 CKOUT2 SI5328
#set_property -dict {LOC H11 IOSTANDARD LVDS} [get_ports sfp_recclk_p] ;# to U20 CKIN1 SI5328
#set_property -dict {LOC G11 IOSTANDARD LVDS} [get_ports sfp_recclk_n] ;# to U20 CKIN1 SI5328
set_property -dict {LOC AE22 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports sfp0_tx_disable_b]
set_property -dict {LOC AF20 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports sfp1_tx_disable_b]

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name sfp_mgt_refclk_0 [get_ports sfp_mgt_refclk_0_p]

set_false_path -to [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b}]
set_output_delay 0 [get_ports {sfp0_tx_disable_b sfp1_tx_disable_b}]

# PCIe Interface
#set_property -dict {LOC AE2 } [get_ports {pcie_rx_p[0]}] ;# MGTHRXP3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE1 } [get_ports {pcie_rx_n[0]}] ;# MGTHRXN3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AD4 } [get_ports {pcie_tx_p[0]}] ;# MGTHTXP3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AD3 } [get_ports {pcie_tx_n[0]}] ;# MGTHTXN3_224 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AF4 } [get_ports {pcie_rx_p[1]}] ;# MGTHRXP2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AF3 } [get_ports {pcie_rx_n[1]}] ;# MGTHRXN2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE6 } [get_ports {pcie_tx_p[1]}] ;# MGTHTXP2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AE5 } [get_ports {pcie_tx_n[1]}] ;# MGTHTXN2_224 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG2 } [get_ports {pcie_rx_p[2]}] ;# MGTHRXP1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG1 } [get_ports {pcie_rx_n[2]}] ;# MGTHRXN1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG6 } [get_ports {pcie_tx_p[2]}] ;# MGTHTXP1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AG5 } [get_ports {pcie_tx_n[2]}] ;# MGTHTXN1_224 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AJ2 } [get_ports {pcie_rx_p[3]}] ;# MGTHRXP0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AJ1 } [get_ports {pcie_rx_n[3]}] ;# MGTHRXN0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AH4 } [get_ports {pcie_tx_p[3]}] ;# MGTHTXP0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AH3 } [get_ports {pcie_tx_n[3]}] ;# MGTHTXN0_224 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AB8 } [get_ports pcie_mgt_refclk_p] ;# MGTREFCLK0P_224
#set_property -dict {LOC AB7 } [get_ports pcie_mgt_refclk_n] ;# MGTREFCLK0N_224
#set_property -dict {LOC L8  IOSTANDARD LVCMOS33 PULLUP true} [get_ports pcie_reset_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_mgt_refclk_p]

#set_false_path -from [get_ports {pcie_reset_n}]
#set_input_delay 0 [get_ports {pcie_reset_n}]

# DDR4
# 4x MT40A256M16GE-075E
#set_property -dict {LOC AK9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[0]}]
#set_property -dict {LOC AG11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[1]}]
#set_property -dict {LOC AJ10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[2]}]
#set_property -dict {LOC AL8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[3]}]
#set_property -dict {LOC AK10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[4]}]
#set_property -dict {LOC AH8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[5]}]
#set_property -dict {LOC AJ9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[6]}]
#set_property -dict {LOC AG8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[7]}]
#set_property -dict {LOC AH9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[8]}]
#set_property -dict {LOC AG10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[9]}]
#set_property -dict {LOC AH13 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[10]}]
#set_property -dict {LOC AG9  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[11]}]
#set_property -dict {LOC AM13 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[12]}]
#set_property -dict {LOC AF8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[13]}]
#set_property -dict {LOC AC12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[14]}]
#set_property -dict {LOC AE12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[15]}]
#set_property -dict {LOC AF11 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_adr[16]}]
#set_property -dict {LOC AK8  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_ba[0]}]
#set_property -dict {LOC AL12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_ba[1]}]
#set_property -dict {LOC AE14 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_bg[0]}]
#set_property -dict {LOC AH11 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_ck_t}]
#set_property -dict {LOC AJ11 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_ck_c}]
#set_property -dict {LOC AB13 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_cke}]
#set_property -dict {LOC AD12 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_cs_n}]
#set_property -dict {LOC AD14 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_act_n}]
#set_property -dict {LOC AF10 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_odt}]
#set_property -dict {LOC AC13 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_par}]
#set_property -dict {LOC AF12 IOSTANDARD LVCMOS12       } [get_ports {ddr4_reset_n}]

#set_property -dict {LOC AF16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[0]}]       ;# U101.G2 DQL0
#set_property -dict {LOC AF18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[1]}]       ;# U101.F7 DQL1
#set_property -dict {LOC AG15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[2]}]       ;# U101.H3 DQL2
#set_property -dict {LOC AF17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[3]}]       ;# U101.H7 DQL3
#set_property -dict {LOC AF15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[4]}]       ;# U101.H2 DQL4
#set_property -dict {LOC AG18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[5]}]       ;# U101.H8 DQL5
#set_property -dict {LOC AG14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[6]}]       ;# U101.J3 DQL6
#set_property -dict {LOC AE17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[7]}]       ;# U101.J7 DQL7
#set_property -dict {LOC AA14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[8]}]       ;# U101.A3 DQU0
#set_property -dict {LOC AC16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[9]}]       ;# U101.B8 DQU1
#set_property -dict {LOC AB15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[10]}]      ;# U101.C3 DQU2
#set_property -dict {LOC AD16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[11]}]      ;# U101.C7 DQU3
#set_property -dict {LOC AB16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[12]}]      ;# U101.C2 DQU4
#set_property -dict {LOC AC17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[13]}]      ;# U101.C8 DQU5
#set_property -dict {LOC AB14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[14]}]      ;# U101.D3 DQU6
#set_property -dict {LOC AD17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[15]}]      ;# U101.D7 DQU7
#set_property -dict {LOC AH14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[0]}]    ;# U101.G3 DQSL_T
#set_property -dict {LOC AJ14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[0]}]    ;# U101.F3 DQSL_C
#set_property -dict {LOC AA16 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[1]}]    ;# U101.B7 DQSU_T
#set_property -dict {LOC AA15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[1]}]    ;# U101.A7 DQSU_C
#set_property -dict {LOC AH18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[0]}] ;# U101.E7 DML_B/DBIL_B
#set_property -dict {LOC AD15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[1]}] ;# U101.E2 DMU_B/DBIU_B

#set_property -dict {LOC AJ16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[16]}]      ;# U99.G2 DQL0
#set_property -dict {LOC AJ17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[17]}]      ;# U99.F7 DQL1
#set_property -dict {LOC AL15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[18]}]      ;# U99.H3 DQL2
#set_property -dict {LOC AK17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[19]}]      ;# U99.H7 DQL3
#set_property -dict {LOC AJ15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[20]}]      ;# U99.H2 DQL4
#set_property -dict {LOC AK18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[21]}]      ;# U99.H8 DQL5
#set_property -dict {LOC AL16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[22]}]      ;# U99.J3 DQL6
#set_property -dict {LOC AL18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[23]}]      ;# U99.J7 DQL7
#set_property -dict {LOC AP13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[24]}]      ;# U99.A3 DQU0
#set_property -dict {LOC AP16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[25]}]      ;# U99.B8 DQU1
#set_property -dict {LOC AP15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[26]}]      ;# U99.C3 DQU2
#set_property -dict {LOC AN16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[27]}]      ;# U99.C7 DQU3
#set_property -dict {LOC AN13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[28]}]      ;# U99.C2 DQU4
#set_property -dict {LOC AM18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[29]}]      ;# U99.C8 DQU5
#set_property -dict {LOC AN17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[30]}]      ;# U99.D3 DQU6
#set_property -dict {LOC AN18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[31]}]      ;# U99.D7 DQU7
#set_property -dict {LOC AK15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[2]}]    ;# U99.G3 DQSL_T
#set_property -dict {LOC AK14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[2]}]    ;# U99.F3 DQSL_C
#set_property -dict {LOC AM14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[3]}]    ;# U99.B7 DQSU_T
#set_property -dict {LOC AN14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[3]}]    ;# U99.A7 DQSU_C
#set_property -dict {LOC AM16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[2]}] ;# U99.E7 DML_B/DBIL_B
#set_property -dict {LOC AP18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[3]}] ;# U99.E2 DMU_B/DBIU_B

#set_property -dict {LOC AB19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[32]}]      ;# U100.G2 DQL0
#set_property -dict {LOC AD19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[33]}]      ;# U100.F7 DQL1
#set_property -dict {LOC AC18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[34]}]      ;# U100.H3 DQL2
#set_property -dict {LOC AC19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[35]}]      ;# U100.H7 DQL3
#set_property -dict {LOC AA20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[36]}]      ;# U100.H2 DQL4
#set_property -dict {LOC AE20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[37]}]      ;# U100.H8 DQL5
#set_property -dict {LOC AA19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[38]}]      ;# U100.J3 DQL6
#set_property -dict {LOC AD20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[39]}]      ;# U100.J7 DQL7
#set_property -dict {LOC AF22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[40]}]      ;# U100.A3 DQU0
#set_property -dict {LOC AH21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[41]}]      ;# U100.B8 DQU1
#set_property -dict {LOC AG19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[42]}]      ;# U100.C3 DQU2
#set_property -dict {LOC AG21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[43]}]      ;# U100.C7 DQU3
#set_property -dict {LOC AE24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[44]}]      ;# U100.C2 DQU4
#set_property -dict {LOC AG20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[45]}]      ;# U100.C8 DQU5
#set_property -dict {LOC AE23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[46]}]      ;# U100.D3 DQU6
#set_property -dict {LOC AF21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[47]}]      ;# U100.D7 DQU7
#set_property -dict {LOC AA18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[4]}]    ;# U100.G3 DQSL_T
#set_property -dict {LOC AB18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[4]}]    ;# U100.F3 DQSL_C
#set_property -dict {LOC AF23 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[5]}]    ;# U100.B7 DQSU_T
#set_property -dict {LOC AG23 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[5]}]    ;# U100.A7 DQSU_C
#set_property -dict {LOC AE18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[4]}] ;# U100.E7 DML_B/DBIL_B
#set_property -dict {LOC AH22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[5]}] ;# U100.E2 DMU_B/DBIU_B

#set_property -dict {LOC AL22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[48]}]      ;# U2.G2 DQL0
#set_property -dict {LOC AJ22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[49]}]      ;# U2.F7 DQL1
#set_property -dict {LOC AL23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[50]}]      ;# U2.H3 DQL2
#set_property -dict {LOC AJ21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[51]}]      ;# U2.H7 DQL3
#set_property -dict {LOC AK20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[52]}]      ;# U2.H2 DQL4
#set_property -dict {LOC AJ19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[53]}]      ;# U2.H8 DQL5
#set_property -dict {LOC AK19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[54]}]      ;# U2.J3 DQL6
#set_property -dict {LOC AJ20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[55]}]      ;# U2.J7 DQL7
#set_property -dict {LOC AP22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[56]}]      ;# U2.A3 DQU0
#set_property -dict {LOC AN22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[57]}]      ;# U2.B8 DQU1
#set_property -dict {LOC AP21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[58]}]      ;# U2.C3 DQU2
#set_property -dict {LOC AP23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[59]}]      ;# U2.C7 DQU3
#set_property -dict {LOC AM19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[60]}]      ;# U2.C2 DQU4
#set_property -dict {LOC AM23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[61]}]      ;# U2.C8 DQU5
#set_property -dict {LOC AN19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[62]}]      ;# U2.D3 DQU6
#set_property -dict {LOC AN23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dq[63]}]      ;# U2.D7 DQU7
#set_property -dict {LOC AK22 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[6]}]    ;# U2.G3 DQSL_T
#set_property -dict {LOC AK23 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[6]}]    ;# U2.F3 DQSL_C
#set_property -dict {LOC AM21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_t[7]}]    ;# U2.B7 DQSU_T
#set_property -dict {LOC AN21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_dqs_c[7]}]    ;# U2.A7 DQSU_C
#set_property -dict {LOC AL20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[6]}] ;# U2.E7 DML_B/DBIL_B
#set_property -dict {LOC AP19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_dm_dbi_n[7]}] ;# U2.E2 DMU_B/DBIU_B
