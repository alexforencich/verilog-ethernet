# XDC constraints for the HiTech Global HTG-9200 board
# part: xcvu9p-flgb2104-2-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]

# System clocks
# DDR4 clocks from U5 (200 MHz)
#set_property -dict {LOC C36  IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_ddr4_a_p]
#set_property -dict {LOC C37  IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_ddr4_a_n]
#create_clock -period 5.000 -name sys_clk_ddr4_a [get_ports sys_clk_ddr4_a_p]

#set_property -dict {LOC BA34 IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_ddr4_b_p]
#set_property -dict {LOC BB34 IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_ddr4_b_n]
#create_clock -period 5.000 -name sys_clk_ddr4_b [get_ports sys_clk_ddr4_b_p]

# refclk from U24 (200 MHz)
set_property -dict {LOC AV26 IOSTANDARD LVDS} [get_ports ref_clk_p]
set_property -dict {LOC AW26 IOSTANDARD LVDS} [get_ports ref_clk_n]
create_clock -period 5.000 -name ref_clk [get_ports ref_clk_p]

# 80 MHz EMCCLK
#set_property -dict {LOC AL27 IOSTANDARD LVCMOS18} [get_ports emc_clk]
#create_clock -period 12.5 -name emc_clk [get_ports emc_clk]

# PLL control
# set_property -dict {LOC L24  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {clk_gty2_fdec}]
# set_property -dict {LOC K25  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {clk_gty2_finc}]
# set_property -dict {LOC K23  IOSTANDARD LVCMOS18} [get_ports {clk_gty2_intr_n}]
set_property -dict {LOC L25  IOSTANDARD LVCMOS18} [get_ports {clk_gty2_lol_n}]
# set_property -dict {LOC L23  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {clk_gty2_oe_n}]
# set_property -dict {LOC L22  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {clk_gty2_sync_n}]
# set_property -dict {LOC K22  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {clk_gty2_rst_n}]

# set_property -dict {LOC BE20 IOSTANDARD LVCMOS18} [get_ports {clk_gth_sd_oe}]
# set_property -dict {LOC BD20 IOSTANDARD LVCMOS18} [get_ports {clk_gth_out0_sel_i2cb}]

# LEDs
set_property -dict {LOC BA24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC BB24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC BC24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC BD24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC AP25 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC BD25 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC BC26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC BC27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

# Push buttons
set_property -dict {LOC B31  IOSTANDARD LVCMOS12} [get_ports {btn[0]}]
set_property -dict {LOC C31  IOSTANDARD LVCMOS12} [get_ports {btn[1]}]

# DIP switches
set_property -dict {LOC P33  IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC K34  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC E35  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC H38  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property -dict {LOC D35  IOSTANDARD LVCMOS12} [get_ports {sw[4]}]
set_property -dict {LOC D36  IOSTANDARD LVCMOS12} [get_ports {sw[5]}]
set_property -dict {LOC E37  IOSTANDARD LVCMOS12} [get_ports {sw[6]}]
set_property -dict {LOC F38  IOSTANDARD LVCMOS12} [get_ports {sw[7]}]

# GPIO
# set_property -dict {LOC AY25 IOSTANDARD LVCMOS18} [get_ports {gpio[0]}]
# set_property -dict {LOC AW25 IOSTANDARD LVCMOS18} [get_ports {gpio[1]}]
# set_property -dict {LOC AU26 IOSTANDARD LVCMOS18} [get_ports {gpio[2]}]
# set_property -dict {LOC BD26 IOSTANDARD LVCMOS18} [get_ports {gpio[3]}]
# set_property -dict {LOC BE27 IOSTANDARD LVCMOS18} [get_ports {gpio[4]}]
# set_property -dict {LOC BE26 IOSTANDARD LVCMOS18} [get_ports {gpio[5]}]
# set_property -dict {LOC AU25 IOSTANDARD LVCMOS18} [get_ports {gpio[6]}]
# set_property -dict {LOC AR26 IOSTANDARD LVCMOS18} [get_ports {gpio[7]}]

# UART
set_property -dict {LOC BB27 IOSTANDARD LVCMOS18} [get_ports uart_txd]
set_property -dict {LOC AY27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rxd]
set_property -dict {LOC BC28 IOSTANDARD LVCMOS18} [get_ports uart_rts]
set_property -dict {LOC AY28 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_cts]
set_property -dict {LOC AY26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rst_n]
set_property -dict {LOC BB26 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_suspend_n]
# set_property -dict {LOC AW28 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_gpio[0]}]
# set_property -dict {LOC AV28 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_gpio[1]}]
# set_property -dict {LOC AV27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_gpio[2]}]
# set_property -dict {LOC AU27 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {uart_gpio[3]}]

# I2C
set_property -dict {LOC BB21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_main_scl]
set_property -dict {LOC BC21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_main_sda]
set_property -dict {LOC BF20 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports i2c_main_rst_n]

# QSPI flash
# set_property -dict {LOC AM26 IOSTANDARD LVCMOS18 DRIVE 8} [get_ports {qspi_1_dq[0]}]
# set_property -dict {LOC AN26 IOSTANDARD LVCMOS18 DRIVE 8} [get_ports {qspi_1_dq[1]}]
# set_property -dict {LOC AL25 IOSTANDARD LVCMOS18 DRIVE 8} [get_ports {qspi_1_dq[2]}]
# set_property -dict {LOC AM25 IOSTANDARD LVCMOS18 DRIVE 8} [get_ports {qspi_1_dq[3]}]
# set_property -dict {LOC BF27 IOSTANDARD LVCMOS18 DRIVE 8} [get_ports {qspi_1_cs_n}]

# DDR4 A
# set_property -dict {LOC B36  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[0]}]
# set_property -dict {LOC C32  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[1]}]
# set_property -dict {LOC D34  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[2]}]
# set_property -dict {LOC C33  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[3]}]
# set_property -dict {LOC A35  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[4]}]
# set_property -dict {LOC D38  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[5]}]
# set_property -dict {LOC A39  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[6]}]
# set_property -dict {LOC C38  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[7]}]
# set_property -dict {LOC B39  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[8]}]
# set_property -dict {LOC D33  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[9]}]
# set_property -dict {LOC A10  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[10]}]
# set_property -dict {LOC D39  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[11]}]
# set_property -dict {LOC C34  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[12]}]
# set_property -dict {LOC A38  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[13]}]
# set_property -dict {LOC A40  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[14]}]
# set_property -dict {LOC E36  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[15]}]
# set_property -dict {LOC E38  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_a[16]}]

# set_property -dict {LOC B34  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_act_n}]
# set_property -dict {LOC A37  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_alert_n}]

# set_property -dict {LOC C39  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_ba[0]}]
# set_property -dict {LOC E39  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_ba[1]}]
# set_property -dict {LOC B40  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_bg[0]}]

# set_property -dict {LOC D40  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_cke}]
# set_property -dict {LOC A32  IOSTANDARD DIFF_SSTL2_DCI} [get_ports {ddr4_a_ck_t}]
# set_property -dict {LOC A33  IOSTANDARD DIFF_SSTL2_DCI} [get_ports {ddr4_a_ck_c}]
# set_property -dict {LOC B32  IOSTANDARD SSTL12_DCI} [get_ports {ddr4_a_cs_n}]

# set_property -dict {LOC N28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[0]}]
# set_property -dict {LOC N26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[1]}]
# set_property -dict {LOC R27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[2]}]
# set_property -dict {LOC P26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[3]}]
# set_property -dict {LOC P28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[4]}]
# set_property -dict {LOC R26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[5]}]
# set_property -dict {LOC T27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[6]}]
# set_property -dict {LOC T26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[7]}]
# set_property -dict {LOC H29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[8]}]
# set_property -dict {LOC G27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[9]}]
# set_property -dict {LOC D28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[10]}]
# set_property -dict {LOC F27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[11]}]
# set_property -dict {LOC G29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[12]}]
# set_property -dict {LOC G26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[13]}]
# set_property -dict {LOC E28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[14]}]
# set_property -dict {LOC E27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[15]}]
# set_property -dict {LOC H28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[16]}]
# set_property -dict {LOC L27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[17]}]
# set_property -dict {LOC J28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[18]}]
# set_property -dict {LOC H27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[19]}]
# set_property -dict {LOC J29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[20]}]
# set_property -dict {LOC M27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[21]}]
# set_property -dict {LOC K28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[22]}]
# set_property -dict {LOC J28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[23]}]
# set_property -dict {LOC E30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[24]}]
# set_property -dict {LOC B29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[25]}]
# set_property -dict {LOC A29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[26]}]
# set_property -dict {LOC C29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[27]}]
# set_property -dict {LOC D30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[28]}]
# set_property -dict {LOC B30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[29]}]
# set_property -dict {LOC A30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[30]}]
# set_property -dict {LOC D29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[31]}]
# set_property -dict {LOC T32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[32]}]
# set_property -dict {LOC T33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[33]}]
# set_property -dict {LOC U31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[34]}]
# set_property -dict {LOC U32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[35]}]
# set_property -dict {LOC V31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[36]}]
# set_property -dict {LOC R33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[37]}]
# set_property -dict {LOC U30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[38]}]
# set_property -dict {LOC T30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[39]}]
# set_property -dict {LOC F32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[40]}]
# set_property -dict {LOC E33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[41]}]
# set_property -dict {LOC E32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[42]}]
# set_property -dict {LOC F33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[43]}]
# set_property -dict {LOC G31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[44]}]
# set_property -dict {LOC H32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[45]}]
# set_property -dict {LOC H31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[46]}]
# set_property -dict {LOC G32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[47]}]
# set_property -dict {LOC R32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[48]}]
# set_property -dict {LOC P32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[49]}]
# set_property -dict {LOC R31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[50]}]
# set_property -dict {LOC N32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[51]}]
# set_property -dict {LOC N31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[52]}]
# set_property -dict {LOC N34  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[53]}]
# set_property -dict {LOC P31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[54]}]
# set_property -dict {LOC N33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[55]}]
# set_property -dict {LOC L30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[56]}]
# set_property -dict {LOC K32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[57]}]
# set_property -dict {LOC M30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[58]}]
# set_property -dict {LOC K33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[59]}]
# set_property -dict {LOC J31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[60]}]
# set_property -dict {LOC L33  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[61]}]
# set_property -dict {LOC K31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[62]}]
# set_property -dict {LOC L32  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[63]}]
# set_property -dict {LOC J35  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[64]}]
# set_property -dict {LOC G34  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[65]}]
# set_property -dict {LOC G37  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[66]}]
# set_property -dict {LOC H34  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[67]}]
# set_property -dict {LOC J36  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[68]}]
# set_property -dict {LOC F35  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[69]}]
# set_property -dict {LOC F37  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[70]}]
# set_property -dict {LOC F34  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dq[71]}]

# set_property -dict {LOC P29  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[0]}]
# set_property -dict {LOC N29  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[0]}]
# set_property -dict {LOC F28  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[1]}]
# set_property -dict {LOC F29  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[1]}]
# set_property -dict {LOC K26  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[2]}]
# set_property -dict {LOC K27  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[2]}]
# set_property -dict {LOC A27  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[3]}]
# set_property -dict {LOC A28  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[3]}]
# set_property -dict {LOC V32  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[4]}]
# set_property -dict {LOC V33  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[4]}]
# set_property -dict {LOC J33  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[5]}]
# set_property -dict {LOC H33  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[5]}]
# set_property -dict {LOC M34  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[6]}]
# set_property -dict {LOC L34  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[6]}]
# set_property -dict {LOC K30  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[7]}]
# set_property -dict {LOC J30  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[7]}]
# set_property -dict {LOC H36  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_t[8]}]
# set_property -dict {LOC G36  IOSTANDARD DIFF_POD12} [get_ports {ddr4_a_dqs_c[8]}]

# set_property -dict {LOC T28  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[0]}]
# set_property -dict {LOC J26  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[1]}]
# set_property -dict {LOC M29  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[2]}]
# set_property -dict {LOC C27  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[3]}]
# set_property -dict {LOC U34  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[4]}]
# set_property -dict {LOC G30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[5]}]
# set_property -dict {LOC R30  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[6]}]
# set_property -dict {LOC M31  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[7]}]
# set_property -dict {LOC H37  IOSTANDARD POD12_DCI} [get_ports {ddr4_a_dm_dbi_n[8]}]

# set_property -dict {LOC A34  IOSTANDARD LVCMOS12} [get_ports {ddr4_a_odt}]
# set_property -dict {LOC E40  IOSTANDARD LVCMOS12} [get_ports {ddr4_a_rst_n}]
# set_property -dict {LOC D31  IOSTANDARD LVCMOS12} [get_ports {ddr4_a_par}]
# set_property -dict {LOC B37  IOSTANDARD LVCMOS12} [get_ports {ddr4_a_ten}]

# DDR4 B
# set_property -dict {LOC AY35 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[0]}]
# set_property -dict {LOC BA35 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[1]}]
# set_property -dict {LOC AV34 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[2]}]
# set_property -dict {LOC BD34 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[3]}]
# set_property -dict {LOC BC34 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[4]}]
# set_property -dict {LOC BC39 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[5]}]
# set_property -dict {LOC BE37 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[6]}]
# set_property -dict {LOC BF38 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[7]}]
# set_property -dict {LOC BF37 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[8]}]
# set_property -dict {LOC AW34 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[9]}]
# set_property -dict {LOC BD35 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[10]}]
# set_property -dict {LOC BC38 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[11]}]
# set_property -dict {LOC BD36 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[12]}]
# set_property -dict {LOC BE38 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[13]}]
# set_property -dict {LOC BB36 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[14]}]
# set_property -dict {LOC BF40 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[15]}]
# set_property -dict {LOC BE40 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_a[16]}]

# set_property -dict {LOC BF35 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_act_n}]
# set_property -dict {LOC BD39 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_alert_n}]

# set_property -dict {LOC BB38 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_ba[0]}]
# set_property -dict {LOC BD40 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_ba[1]}]
# set_property -dict {LOC BC36 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_bg[0]}]

# set_property -dict {LOC BB35 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_cke}]
# set_property -dict {LOC BB37 IOSTANDARD DIFF_SSTL2_DCI} [get_ports {ddr4_b_ck_t}]
# set_property -dict {LOC BC37 IOSTANDARD DIFF_SSTL2_DCI} [get_ports {ddr4_b_ck_c}]
# set_property -dict {LOC BE36 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_b_cs_n}]

# set_property -dict {LOC AP29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[0]}]
# set_property -dict {LOC AR30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[1]}]
# set_property -dict {LOC AN29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[2]}]
# set_property -dict {LOC AP30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[3]}]
# set_property -dict {LOC AL29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[4]}]
# set_property -dict {LOC AN31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[5]}]
# set_property -dict {LOC AL30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[6]}]
# set_property -dict {LOC AM31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[7]}]
# set_property -dict {LOC AT29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[8]}]
# set_property -dict {LOC AU32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[9]}]
# set_property -dict {LOC AU30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[10]}]
# set_property -dict {LOC AV31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[11]}]
# set_property -dict {LOC AT30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[12]}]
# set_property -dict {LOC AW31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[13]}]
# set_property -dict {LOC AU31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[14]}]
# set_property -dict {LOC AV32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[15]}]
# set_property -dict {LOC BB30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[16]}]
# set_property -dict {LOC AY32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[17]}]
# set_property -dict {LOC BA30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[18]}]
# set_property -dict {LOC AY30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[19]}]
# set_property -dict {LOC BA29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[20]}]
# set_property -dict {LOC AY31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[21]}]
# set_property -dict {LOC BB29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[22]}]
# set_property -dict {LOC BB31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[23]}]
# set_property -dict {LOC BF30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[24]}]
# set_property -dict {LOC BE32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[25]}]
# set_property -dict {LOC BD29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[26]}]
# set_property -dict {LOC BD33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[27]}]
# set_property -dict {LOC BE30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[28]}]
# set_property -dict {LOC BE33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[29]}]
# set_property -dict {LOC BC29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[30]}]
# set_property -dict {LOC BE31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[31]}]
# set_property -dict {LOC Y33  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[32]}]
# set_property -dict {LOC W30  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[33]}]
# set_property -dict {LOC W34  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[34]}]
# set_property -dict {LOC Y32  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[35]}]
# set_property -dict {LOC AA34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[36]}]
# set_property -dict {LOC Y30  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[37]}]
# set_property -dict {LOC AB34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[38]}]
# set_property -dict {LOC W33  IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[39]}]
# set_property -dict {LOC AJ31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[40]}]
# set_property -dict {LOC AG30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[41]}]
# set_property -dict {LOC AJ28 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[42]}]
# set_property -dict {LOC AK28 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[43]}]
# set_property -dict {LOC AK31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[44]}]
# set_property -dict {LOC AG29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[45]}]
# set_property -dict {LOC AJ30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[46]}]
# set_property -dict {LOC AJ29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[47]}]
# set_property -dict {LOC AC32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[48]}]
# set_property -dict {LOC AE33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[49]}]
# set_property -dict {LOC AC33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[50]}]
# set_property -dict {LOC AD34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[51]}]
# set_property -dict {LOC AC34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[52]}]
# set_property -dict {LOC AD33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[53]}]
# set_property -dict {LOC AE30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[54]}]
# set_property -dict {LOC AF30 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[55]}]
# set_property -dict {LOC AF34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[56]}]
# set_property -dict {LOC AJ33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[57]}]
# set_property -dict {LOC AH33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[58]}]
# set_property -dict {LOC AG32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[59]}]
# set_property -dict {LOC AF33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[60]}]
# set_property -dict {LOC AG31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[61]}]
# set_property -dict {LOC AF32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[62]}]
# set_property -dict {LOC AG34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[63]}]
# set_property -dict {LOC AN34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[64]}]
# set_property -dict {LOC AL34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[65]}]
# set_property -dict {LOC AP34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[66]}]
# set_property -dict {LOC AM32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[67]}]
# set_property -dict {LOC AR33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[68]}]
# set_property -dict {LOC AL32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[69]}]
# set_property -dict {LOC AP33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[70]}]
# set_property -dict {LOC AM34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dq[71]}]

# set_property -dict {LOC AM29 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[0]}]
# set_property -dict {LOC AM30 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[0]}]
# set_property -dict {LOC AU29 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[1]}]
# set_property -dict {LOC AV29 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[1]}]
# set_property -dict {LOC BA32 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[2]}]
# set_property -dict {LOC BB32 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[2]}]
# set_property -dict {LOC BD30 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[3]}]
# set_property -dict {LOC BD31 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[3]}]
# set_property -dict {LOC W31  IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[4]}]
# set_property -dict {LOC Y31  IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[4]}]
# set_property -dict {LOC AH28 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[5]}]
# set_property -dict {LOC AH29 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[5]}]
# set_property -dict {LOC AC31 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[6]}]
# set_property -dict {LOC AD31 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[6]}]
# set_property -dict {LOC AH31 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[7]}]
# set_property -dict {LOC AH32 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[7]}]
# set_property -dict {LOC AN32 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_t[8]}]
# set_property -dict {LOC AN33 IOSTANDARD DIFF_POD12} [get_ports {ddr4_b_dqs_c[8]}]

# set_property -dict {LOC AP31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[0]}]
# set_property -dict {LOC AW29 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[1]}]
# set_property -dict {LOC BC31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[2]}]
# set_property -dict {LOC BF32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[3]}]
# set_property -dict {LOC AA32 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[4]}]
# set_property -dict {LOC AJ27 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[5]}]
# set_property -dict {LOC AE31 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[6]}]
# set_property -dict {LOC AH34 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[7]}]
# set_property -dict {LOC AT33 IOSTANDARD POD12_DCI} [get_ports {ddr4_b_dm_dbi_n[8]}]

# set_property -dict {LOC BE35 IOSTANDARD LVCMOS12} [get_ports {ddr4_b_odt}]
# set_property -dict {LOC AY36 IOSTANDARD LVCMOS12} [get_ports {ddr4_b_rst_n}]
# set_property -dict {LOC AV33 IOSTANDARD LVCMOS12} [get_ports {ddr4_b_par}]
# set_property -dict {LOC BF39 IOSTANDARD LVCMOS12} [get_ports {ddr4_b_ten}]

# QSFP28 Interfaces

# QSFP 1
set_property -dict {LOC G40 } [get_ports {qsfp_1_tx_p[1]}] ;# MGTYTXP0_133 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC G41 } [get_ports {qsfp_1_tx_n[1]}] ;# MGTYTXN0_133 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC J45 } [get_ports {qsfp_1_rx_p[1]}] ;# MGTYRXP0_133 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC J46 } [get_ports {qsfp_1_rx_n[1]}] ;# MGTYRXN0_133 GTYE4_CHANNEL_X0Y36 / GTYE4_COMMON_X0Y9
set_property -dict {LOC E42 } [get_ports {qsfp_1_tx_p[2]}] ;# MGTYTXP1_133 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC E43 } [get_ports {qsfp_1_tx_n[2]}] ;# MGTYTXN1_133 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC H43 } [get_ports {qsfp_1_rx_p[2]}] ;# MGTYRXP1_133 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC H44 } [get_ports {qsfp_1_rx_n[2]}] ;# MGTYRXN1_133 GTYE4_CHANNEL_X0Y37 / GTYE4_COMMON_X0Y9
set_property -dict {LOC C42 } [get_ports {qsfp_1_tx_p[0]}] ;# MGTYTXP2_133 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC C43 } [get_ports {qsfp_1_tx_n[0]}] ;# MGTYTXN2_133 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC F45 } [get_ports {qsfp_1_rx_p[0]}] ;# MGTYRXP2_133 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC F46 } [get_ports {qsfp_1_rx_n[0]}] ;# MGTYRXN2_133 GTYE4_CHANNEL_X0Y38 / GTYE4_COMMON_X0Y9
set_property -dict {LOC A42 } [get_ports {qsfp_1_tx_p[3]}] ;# MGTYTXP3_133 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC A43 } [get_ports {qsfp_1_tx_n[3]}] ;# MGTYTXN3_133 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC D45 } [get_ports {qsfp_1_rx_p[3]}] ;# MGTYRXP3_133 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC D46 } [get_ports {qsfp_1_rx_n[3]}] ;# MGTYRXN3_133 GTYE4_CHANNEL_X0Y39 / GTYE4_COMMON_X0Y9
set_property -dict {LOC K38 } [get_ports qsfp_1_mgt_refclk_p] ;# MGTREFCLK1P_133 from U48.28 OUT1_P
set_property -dict {LOC K39 } [get_ports qsfp_1_mgt_refclk_n] ;# MGTREFCLK1N_133 from U48.27 OUT1_N
set_property -dict {LOC BB20 IOSTANDARD LVCMOS18} [get_ports qsfp_1_resetl]
set_property -dict {LOC BE21 IOSTANDARD LVCMOS18} [get_ports qsfp_1_modprsl]
set_property -dict {LOC BA20 IOSTANDARD LVCMOS18} [get_ports qsfp_1_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_1_mgt_refclk [get_ports qsfp_1_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_1_mgt_refclk [get_ports qsfp_1_mgt_refclk_p]

# QSFP 2
set_property -dict {LOC N40 } [get_ports {qsfp_2_tx_p[1]}] ;# MGTYTXP0_132 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N41 } [get_ports {qsfp_2_tx_n[1]}] ;# MGTYTXN0_132 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N45 } [get_ports {qsfp_2_rx_p[1]}] ;# MGTYRXP0_132 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC N46 } [get_ports {qsfp_2_rx_n[1]}] ;# MGTYRXN0_132 GTYE4_CHANNEL_X0Y32 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M38 } [get_ports {qsfp_2_tx_p[2]}] ;# MGTYTXP1_132 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M39 } [get_ports {qsfp_2_tx_n[2]}] ;# MGTYTXN1_132 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M43 } [get_ports {qsfp_2_rx_p[2]}] ;# MGTYRXP1_132 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC M44 } [get_ports {qsfp_2_rx_n[2]}] ;# MGTYRXN1_132 GTYE4_CHANNEL_X0Y33 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L40 } [get_ports {qsfp_2_tx_p[0]}] ;# MGTYTXP2_132 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L41 } [get_ports {qsfp_2_tx_n[0]}] ;# MGTYTXN2_132 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L45 } [get_ports {qsfp_2_rx_p[0]}] ;# MGTYRXP2_132 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC L46 } [get_ports {qsfp_2_rx_n[0]}] ;# MGTYRXN2_132 GTYE4_CHANNEL_X0Y34 / GTYE4_COMMON_X0Y8
set_property -dict {LOC J40 } [get_ports {qsfp_2_tx_p[3]}] ;# MGTYTXP3_132 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC J41 } [get_ports {qsfp_2_tx_n[3]}] ;# MGTYTXN3_132 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC K43 } [get_ports {qsfp_2_rx_p[3]}] ;# MGTYRXP3_132 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC K44 } [get_ports {qsfp_2_rx_n[3]}] ;# MGTYRXN3_132 GTYE4_CHANNEL_X0Y35 / GTYE4_COMMON_X0Y8
set_property -dict {LOC R36 } [get_ports qsfp_2_mgt_refclk_p] ;# MGTREFCLK0P_132 from U48.35 OUT3_P
set_property -dict {LOC R37 } [get_ports qsfp_2_mgt_refclk_n] ;# MGTREFCLK0N_132 from U48.34 OUT3_N
set_property -dict {LOC BE22 IOSTANDARD LVCMOS18} [get_ports qsfp_2_resetl]
set_property -dict {LOC BD21 IOSTANDARD LVCMOS18} [get_ports qsfp_2_modprsl]
set_property -dict {LOC BF22 IOSTANDARD LVCMOS18} [get_ports qsfp_2_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_2_mgt_refclk [get_ports qsfp_2_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_2_mgt_refclk [get_ports qsfp_2_mgt_refclk_p]

# QSFP 3
set_property -dict {LOC U40 } [get_ports {qsfp_3_tx_p[1]}] ;# MGTYTXP0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U41 } [get_ports {qsfp_3_tx_n[1]}] ;# MGTYTXN0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U45 } [get_ports {qsfp_3_rx_p[1]}] ;# MGTYRXP0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC U46 } [get_ports {qsfp_3_rx_n[1]}] ;# MGTYRXN0_131 GTYE4_CHANNEL_X0Y28 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T38 } [get_ports {qsfp_3_tx_p[2]}] ;# MGTYTXP1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T39 } [get_ports {qsfp_3_tx_n[2]}] ;# MGTYTXN1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T43 } [get_ports {qsfp_3_rx_p[2]}] ;# MGTYRXP1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC T44 } [get_ports {qsfp_3_rx_n[2]}] ;# MGTYRXN1_131 GTYE4_CHANNEL_X0Y29 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R40 } [get_ports {qsfp_3_tx_p[0]}] ;# MGTYTXP2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R41 } [get_ports {qsfp_3_tx_n[0]}] ;# MGTYTXN2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R45 } [get_ports {qsfp_3_rx_p[0]}] ;# MGTYRXP2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC R46 } [get_ports {qsfp_3_rx_n[0]}] ;# MGTYRXN2_131 GTYE4_CHANNEL_X0Y30 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P38 } [get_ports {qsfp_3_tx_p[3]}] ;# MGTYTXP3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P39 } [get_ports {qsfp_3_tx_n[3]}] ;# MGTYTXN3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P43 } [get_ports {qsfp_3_rx_p[3]}] ;# MGTYRXP3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC P44 } [get_ports {qsfp_3_rx_n[3]}] ;# MGTYRXN3_131 GTYE4_CHANNEL_X0Y31 / GTYE4_COMMON_X0Y7
set_property -dict {LOC W36 } [get_ports qsfp_3_mgt_refclk_p] ;# MGTREFCLK0P_131 from U48.38 OUT4_P
set_property -dict {LOC W37 } [get_ports qsfp_3_mgt_refclk_n] ;# MGTREFCLK0N_131 from U48.37 OUT4_N
set_property -dict {LOC AY23 IOSTANDARD LVCMOS18} [get_ports qsfp_3_resetl]
set_property -dict {LOC AY22 IOSTANDARD LVCMOS18} [get_ports qsfp_3_modprsl]
set_property -dict {LOC BA22 IOSTANDARD LVCMOS18} [get_ports qsfp_3_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_3_mgt_refclk [get_ports qsfp_3_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_3_mgt_refclk [get_ports qsfp_3_mgt_refclk_p]

# QSFP 4
set_property -dict {LOC AA40} [get_ports {qsfp_4_tx_p[1]}] ;# MGTYTXP0_130 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA41} [get_ports {qsfp_4_tx_n[1]}] ;# MGTYTXN0_130 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA45} [get_ports {qsfp_4_rx_p[1]}] ;# MGTYRXP0_130 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AA46} [get_ports {qsfp_4_rx_n[1]}] ;# MGTYRXN0_130 GTYE4_CHANNEL_X0Y24 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y38 } [get_ports {qsfp_4_tx_p[2]}] ;# MGTYTXP1_130 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y39 } [get_ports {qsfp_4_tx_n[2]}] ;# MGTYTXN1_130 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y43 } [get_ports {qsfp_4_rx_p[2]}] ;# MGTYRXP1_130 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC Y44 } [get_ports {qsfp_4_rx_n[2]}] ;# MGTYRXN1_130 GTYE4_CHANNEL_X0Y25 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W40 } [get_ports {qsfp_4_tx_p[0]}] ;# MGTYTXP2_130 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W41 } [get_ports {qsfp_4_tx_n[0]}] ;# MGTYTXN2_130 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W45 } [get_ports {qsfp_4_rx_p[0]}] ;# MGTYRXP2_130 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC W46 } [get_ports {qsfp_4_rx_n[0]}] ;# MGTYRXN2_130 GTYE4_CHANNEL_X0Y26 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V38 } [get_ports {qsfp_4_tx_p[3]}] ;# MGTYTXP3_130 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V39 } [get_ports {qsfp_4_tx_n[3]}] ;# MGTYTXN3_130 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V43 } [get_ports {qsfp_4_rx_p[3]}] ;# MGTYRXP3_130 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC V44 } [get_ports {qsfp_4_rx_n[3]}] ;# MGTYRXN3_130 GTYE4_CHANNEL_X0Y27 / GTYE4_COMMON_X0Y6
set_property -dict {LOC AC36} [get_ports qsfp_4_mgt_refclk_p] ;# MGTREFCLK0P_130 from U48.42 OUT5_P
set_property -dict {LOC AC37} [get_ports qsfp_4_mgt_refclk_n] ;# MGTREFCLK0N_130 from U48.41 OUT5_N
set_property -dict {LOC BC22 IOSTANDARD LVCMOS18} [get_ports qsfp_4_resetl]
set_property -dict {LOC BB22 IOSTANDARD LVCMOS18} [get_ports qsfp_4_modprsl]
set_property -dict {LOC BA23 IOSTANDARD LVCMOS18} [get_ports qsfp_4_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_4_mgt_refclk [get_ports qsfp_4_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_4_mgt_refclk [get_ports qsfp_4_mgt_refclk_p]

# QSFP 5
set_property -dict {LOC AE40} [get_ports {qsfp_5_tx_p[1]}] ;# MGTYTXP0_129 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE41} [get_ports {qsfp_5_tx_n[1]}] ;# MGTYTXN0_129 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE45} [get_ports {qsfp_5_rx_p[1]}] ;# MGTYRXP0_129 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AE46} [get_ports {qsfp_5_rx_n[1]}] ;# MGTYRXN0_129 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD38} [get_ports {qsfp_5_tx_p[2]}] ;# MGTYTXP1_129 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD39} [get_ports {qsfp_5_tx_n[2]}] ;# MGTYTXN1_129 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD43} [get_ports {qsfp_5_rx_p[2]}] ;# MGTYRXP1_129 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AD44} [get_ports {qsfp_5_rx_n[2]}] ;# MGTYRXN1_129 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC40} [get_ports {qsfp_5_tx_p[3]}] ;# MGTYTXP2_129 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC41} [get_ports {qsfp_5_tx_n[3]}] ;# MGTYTXN2_129 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC45} [get_ports {qsfp_5_rx_p[3]}] ;# MGTYRXP2_129 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AC46} [get_ports {qsfp_5_rx_n[3]}] ;# MGTYRXN2_129 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB38} [get_ports {qsfp_5_tx_p[0]}] ;# MGTYTXP3_129 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB39} [get_ports {qsfp_5_tx_n[0]}] ;# MGTYTXN3_129 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB43} [get_ports {qsfp_5_rx_p[0]}] ;# MGTYRXP3_129 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AB44} [get_ports {qsfp_5_rx_n[0]}] ;# MGTYRXN3_129 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC AG36} [get_ports qsfp_5_mgt_refclk_p] ;# MGTREFCLK0P_129 from U48.24 OUT0_P
set_property -dict {LOC AG37} [get_ports qsfp_5_mgt_refclk_n] ;# MGTREFCLK0N_129 from U48.23 OUT0_N
set_property -dict {LOC BD23 IOSTANDARD LVCMOS18} [get_ports qsfp_5_resetl]
set_property -dict {LOC BE23 IOSTANDARD LVCMOS18} [get_ports qsfp_5_modprsl]
set_property -dict {LOC BF23 IOSTANDARD LVCMOS18} [get_ports qsfp_5_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_5_mgt_refclk [get_ports qsfp_5_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_5_mgt_refclk [get_ports qsfp_5_mgt_refclk_p]

# QSFP 6
set_property -dict {LOC AJ40} [get_ports {qsfp_6_tx_p[1]}] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ41} [get_ports {qsfp_6_tx_n[1]}] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ45} [get_ports {qsfp_6_rx_p[1]}] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AJ46} [get_ports {qsfp_6_rx_n[1]}] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y16 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH38} [get_ports {qsfp_6_tx_p[2]}] ;# MGTYTXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH39} [get_ports {qsfp_6_tx_n[2]}] ;# MGTYTXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH43} [get_ports {qsfp_6_rx_p[2]}] ;# MGTYRXP1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AH44} [get_ports {qsfp_6_rx_n[2]}] ;# MGTYRXN1_128 GTYE4_CHANNEL_X0Y17 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG40} [get_ports {qsfp_6_tx_p[0]}] ;# MGTYTXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG41} [get_ports {qsfp_6_tx_n[0]}] ;# MGTYTXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG45} [get_ports {qsfp_6_rx_p[0]}] ;# MGTYRXP2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AG46} [get_ports {qsfp_6_rx_n[0]}] ;# MGTYRXN2_128 GTYE4_CHANNEL_X0Y18 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF38} [get_ports {qsfp_6_tx_p[3]}] ;# MGTYTXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF39} [get_ports {qsfp_6_tx_n[3]}] ;# MGTYTXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF43} [get_ports {qsfp_6_rx_p[3]}] ;# MGTYRXP3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AF44} [get_ports {qsfp_6_rx_n[3]}] ;# MGTYRXN3_128 GTYE4_CHANNEL_X0Y19 / GTYE4_COMMON_X0Y4
set_property -dict {LOC AL36} [get_ports qsfp_6_mgt_refclk_p] ;# MGTREFCLK0P_128 from U48.59 OUT9_P
set_property -dict {LOC AL37} [get_ports qsfp_6_mgt_refclk_n] ;# MGTREFCLK0N_128 from U48.58 OUT9_N
set_property -dict {LOC AW24 IOSTANDARD LVCMOS18} [get_ports qsfp_6_resetl]
set_property -dict {LOC AR23 IOSTANDARD LVCMOS18} [get_ports qsfp_6_modprsl]
set_property -dict {LOC AV24 IOSTANDARD LVCMOS18} [get_ports qsfp_6_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_6_mgt_refclk [get_ports qsfp_6_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_6_mgt_refclk [get_ports qsfp_6_mgt_refclk_p]

# QSFP 7
set_property -dict {LOC AN40} [get_ports {qsfp_7_tx_p[1]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN41} [get_ports {qsfp_7_tx_n[1]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN45} [get_ports {qsfp_7_rx_p[1]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AN46} [get_ports {qsfp_7_rx_n[1]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM38} [get_ports {qsfp_7_tx_p[2]}] ;# MGTYTXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM39} [get_ports {qsfp_7_tx_n[2]}] ;# MGTYTXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM43} [get_ports {qsfp_7_rx_p[2]}] ;# MGTYRXP1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AM44} [get_ports {qsfp_7_rx_n[2]}] ;# MGTYRXN1_127 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL40} [get_ports {qsfp_7_tx_p[0]}] ;# MGTYTXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL41} [get_ports {qsfp_7_tx_n[0]}] ;# MGTYTXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL45} [get_ports {qsfp_7_rx_p[0]}] ;# MGTYRXP2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AL46} [get_ports {qsfp_7_rx_n[0]}] ;# MGTYRXN2_127 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK38} [get_ports {qsfp_7_tx_p[3]}] ;# MGTYTXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK39} [get_ports {qsfp_7_tx_n[3]}] ;# MGTYTXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK43} [get_ports {qsfp_7_rx_p[3]}] ;# MGTYRXP3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AK44} [get_ports {qsfp_7_rx_n[3]}] ;# MGTYRXN3_127 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC AR36} [get_ports qsfp_7_mgt_refclk_p] ;# MGTREFCLK0P_127 from U48.54 OUT8_P
set_property -dict {LOC AR37} [get_ports qsfp_7_mgt_refclk_n] ;# MGTREFCLK0N_127 from U48.53 OUT8_N
set_property -dict {LOC AU24 IOSTANDARD LVCMOS18} [get_ports qsfp_7_resetl]
set_property -dict {LOC AN23 IOSTANDARD LVCMOS18} [get_ports qsfp_7_modprsl]
set_property -dict {LOC AT24 IOSTANDARD LVCMOS18} [get_ports qsfp_7_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_7_mgt_refclk [get_ports qsfp_7_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_7_mgt_refclk [get_ports qsfp_7_mgt_refclk_p]

# QSFP 8
set_property -dict {LOC AU40} [get_ports {qsfp_8_tx_p[1]}] ;# MGTYTXP0_126 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU41} [get_ports {qsfp_8_tx_n[1]}] ;# MGTYTXN0_126 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU45} [get_ports {qsfp_8_rx_p[1]}] ;# MGTYRXP0_126 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AU46} [get_ports {qsfp_8_rx_n[1]}] ;# MGTYRXN0_126 GTYE4_CHANNEL_X0Y8 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT38} [get_ports {qsfp_8_tx_p[2]}] ;# MGTYTXP1_126 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT39} [get_ports {qsfp_8_tx_n[2]}] ;# MGTYTXN1_126 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT43} [get_ports {qsfp_8_rx_p[2]}] ;# MGTYRXP1_126 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AT44} [get_ports {qsfp_8_rx_n[2]}] ;# MGTYRXN1_126 GTYE4_CHANNEL_X0Y9 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR40} [get_ports {qsfp_8_tx_p[0]}] ;# MGTYTXP2_126 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR41} [get_ports {qsfp_8_tx_n[0]}] ;# MGTYTXN2_126 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR45} [get_ports {qsfp_8_rx_p[0]}] ;# MGTYRXP2_126 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AR46} [get_ports {qsfp_8_rx_n[0]}] ;# MGTYRXN2_126 GTYE4_CHANNEL_X0Y10 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP38} [get_ports {qsfp_8_tx_p[3]}] ;# MGTYTXP3_126 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP39} [get_ports {qsfp_8_tx_n[3]}] ;# MGTYTXN3_126 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP43} [get_ports {qsfp_8_rx_p[3]}] ;# MGTYRXP3_126 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AP44} [get_ports {qsfp_8_rx_n[3]}] ;# MGTYRXN3_126 GTYE4_CHANNEL_X0Y11 / GTYE4_COMMON_X0Y2
set_property -dict {LOC AV38} [get_ports qsfp_8_mgt_refclk_p] ;# MGTREFCLK0P_126 from U48.45 OUT6_P
set_property -dict {LOC AV39} [get_ports qsfp_8_mgt_refclk_n] ;# MGTREFCLK0N_126 from U48.44 OUT6_N
set_property -dict {LOC AN24 IOSTANDARD LVCMOS18} [get_ports qsfp_8_resetl]
set_property -dict {LOC AP24 IOSTANDARD LVCMOS18} [get_ports qsfp_8_modprsl]
set_property -dict {LOC AP23 IOSTANDARD LVCMOS18} [get_ports qsfp_8_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_8_mgt_refclk [get_ports qsfp_8_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_8_mgt_refclk [get_ports qsfp_8_mgt_refclk_p]

# QSFP 9
set_property -dict {LOC BF42} [get_ports {qsfp_9_tx_p[1]}] ;# MGTYTXP0_125 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BF43} [get_ports {qsfp_9_tx_n[1]}] ;# MGTYTXN0_125 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BC45} [get_ports {qsfp_9_rx_p[1]}] ;# MGTYRXP0_125 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BC46} [get_ports {qsfp_9_rx_n[1]}] ;# MGTYRXN0_125 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BD42} [get_ports {qsfp_9_tx_p[2]}] ;# MGTYTXP1_125 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BD43} [get_ports {qsfp_9_tx_n[2]}] ;# MGTYTXN1_125 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA45} [get_ports {qsfp_9_rx_p[2]}] ;# MGTYRXP1_125 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA46} [get_ports {qsfp_9_rx_n[2]}] ;# MGTYRXN1_125 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BB42} [get_ports {qsfp_9_tx_p[0]}] ;# MGTYTXP2_125 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BB43} [get_ports {qsfp_9_tx_n[0]}] ;# MGTYTXN2_125 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW45} [get_ports {qsfp_9_rx_p[0]}] ;# MGTYRXP2_125 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW46} [get_ports {qsfp_9_rx_n[0]}] ;# MGTYRXN2_125 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW40} [get_ports {qsfp_9_tx_p[3]}] ;# MGTYTXP3_125 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AW41} [get_ports {qsfp_9_tx_n[3]}] ;# MGTYTXN3_125 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AV43} [get_ports {qsfp_9_rx_p[3]}] ;# MGTYRXP3_125 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AV44} [get_ports {qsfp_9_rx_n[3]}] ;# MGTYRXN3_125 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC BA40} [get_ports qsfp_9_mgt_refclk_p] ;# MGTREFCLK0P_125 from U48.51 OUT7_P
set_property -dict {LOC BA41} [get_ports qsfp_9_mgt_refclk_n] ;# MGTREFCLK0N_125 from U48.50 OUT7_N
set_property -dict {LOC AM24 IOSTANDARD LVCMOS18} [get_ports qsfp_9_resetl]
set_property -dict {LOC AM22 IOSTANDARD LVCMOS18} [get_ports qsfp_9_modprsl]
set_property -dict {LOC AL24 IOSTANDARD LVCMOS18} [get_ports qsfp_9_intl]

# 156.25 MHz MGT reference clock
# create_clock -period 6.400 -name qsfp_9_mgt_refclk [get_ports qsfp_9_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_9_mgt_refclk [get_ports qsfp_9_mgt_refclk_p]

# SMA (GTY)
#set_property -dict {LOC E9  } [get_ports {sma_tx_p[0]}] ;# MGTYTXP0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC E8  } [get_ports {sma_tx_n[0]}] ;# MGTYTXN0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC E4  } [get_ports {sma_rx_p[0]}] ;# MGTYRXP0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC E3  } [get_ports {sma_rx_n[0]}] ;# MGTYRXN0_233 GTYE4_CHANNEL_X1Y56 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC D7  } [get_ports {sma_tx_p[1]}] ;# MGTYTXP1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC D6  } [get_ports {sma_tx_n[1]}] ;# MGTYTXN1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC D2  } [get_ports {sma_rx_p[1]}] ;# MGTYRXP1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC D1  } [get_ports {sma_rx_n[1]}] ;# MGTYRXN1_233 GTYE4_CHANNEL_X1Y57 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC C9  } [get_ports {sma_tx_p[2]}] ;# MGTYTXP2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC C8  } [get_ports {sma_tx_n[2]}] ;# MGTYTXN2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC C4  } [get_ports {sma_rx_p[2]}] ;# MGTYRXP2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC C3  } [get_ports {sma_rx_n[2]}] ;# MGTYRXN2_233 GTYE4_CHANNEL_X1Y58 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC A9  } [get_ports {sma_tx_p[3]}] ;# MGTYTXP3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC A8  } [get_ports {sma_tx_n[3]}] ;# MGTYTXN3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC A5  } [get_ports {sma_rx_p[3]}] ;# MGTYRXP3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC A4  } [get_ports {sma_rx_n[3]}] ;# MGTYRXN3_233 GTYE4_CHANNEL_X1Y59 / GTYE4_COMMON_X1Y14
#set_property -dict {LOC D11 } [get_ports sma_mgt_refclk_p] ;# MGTREFCLK0P_233 from X20 SMA CLKP
#set_property -dict {LOC D10 } [get_ports sma_mgt_refclk_n] ;# MGTREFCLK0N_233 from X19 SMA CLKN

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name sma_mgt_refclk [get_ports sma_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name sma_mgt_refclk [get_ports sma_mgt_refclk_p]

# FireFly
#set_property -dict {LOC BF5 } [get_ports {ff_tx_p[0]}]  ;# MGTYTXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BF4 } [get_ports {ff_tx_n[0]}]  ;# MGTYTXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BC2 } [get_ports {ff_rx_p[0]}]  ;# MGTYRXP0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BC1 } [get_ports {ff_rx_n[0]}]  ;# MGTYRXN0_226 GTYE4_CHANNEL_X1Y28 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BD5 } [get_ports {ff_tx_p[2]}]  ;# MGTYTXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BD4 } [get_ports {ff_tx_n[2]}]  ;# MGTYTXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BA2 } [get_ports {ff_rx_p[2]}]  ;# MGTYRXP1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BA1 } [get_ports {ff_rx_n[2]}]  ;# MGTYRXN1_226 GTYE4_CHANNEL_X1Y29 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BB5 } [get_ports {ff_tx_p[1]}]  ;# MGTYTXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC BB4 } [get_ports {ff_tx_n[1]}]  ;# MGTYTXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AW4 } [get_ports {ff_rx_p[1]}]  ;# MGTYRXP2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AW3 } [get_ports {ff_rx_n[1]}]  ;# MGTYRXN2_226 GTYE4_CHANNEL_X1Y30 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AV7 } [get_ports {ff_tx_p[3]}]  ;# MGTYTXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AV6 } [get_ports {ff_tx_n[3]}]  ;# MGTYTXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AV2 } [get_ports {ff_rx_p[3]}]  ;# MGTYRXP3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AV1 } [get_ports {ff_rx_n[3]}]  ;# MGTYRXN3_226 GTYE4_CHANNEL_X1Y31 / GTYE4_COMMON_X1Y7
#set_property -dict {LOC AU9 } [get_ports {ff_tx_p[5]}]  ;# MGTYTXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU8 } [get_ports {ff_tx_n[5]}]  ;# MGTYTXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU4 } [get_ports {ff_rx_p[5]}]  ;# MGTYRXP0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AU3 } [get_ports {ff_rx_n[5]}]  ;# MGTYRXN0_225 GTYE4_CHANNEL_X1Y24 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT7 } [get_ports {ff_tx_p[7]}]  ;# MGTYTXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT6 } [get_ports {ff_tx_n[7]}]  ;# MGTYTXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT2 } [get_ports {ff_rx_p[7]}]  ;# MGTYRXP1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AT1 } [get_ports {ff_rx_n[7]}]  ;# MGTYRXN1_225 GTYE4_CHANNEL_X1Y25 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR9 } [get_ports {ff_tx_p[4]}]  ;# MGTYTXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR8 } [get_ports {ff_tx_n[4]}]  ;# MGTYTXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR4 } [get_ports {ff_rx_p[4]}]  ;# MGTYRXP2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AR3 } [get_ports {ff_rx_n[4]}]  ;# MGTYRXN2_225 GTYE4_CHANNEL_X1Y26 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP7 } [get_ports {ff_tx_p[6]}]  ;# MGTYTXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP6 } [get_ports {ff_tx_n[6]}]  ;# MGTYTXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP2 } [get_ports {ff_rx_p[6]}]  ;# MGTYRXP3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AP1 } [get_ports {ff_rx_n[6]}]  ;# MGTYRXN3_225 GTYE4_CHANNEL_X1Y27 / GTYE4_COMMON_X1Y6
#set_property -dict {LOC AN9 } [get_ports {ff_tx_p[11]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AN8 } [get_ports {ff_tx_n[11]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AN4 } [get_ports {ff_rx_p[11]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AN3 } [get_ports {ff_rx_n[11]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X1Y20 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM7 } [get_ports {ff_tx_p[9]}]  ;# MGTYTXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM6 } [get_ports {ff_tx_n[9]}]  ;# MGTYTXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM2 } [get_ports {ff_rx_p[9]}]  ;# MGTYRXP1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AM1 } [get_ports {ff_rx_n[9]}]  ;# MGTYRXN1_224 GTYE4_CHANNEL_X1Y21 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AL9 } [get_ports {ff_tx_p[10]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AL8 } [get_ports {ff_tx_n[10]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AL4 } [get_ports {ff_rx_p[10]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AL3 } [get_ports {ff_rx_n[10]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X1Y22 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AK7 } [get_ports {ff_tx_p[8]}]  ;# MGTYTXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AK6 } [get_ports {ff_tx_n[8]}]  ;# MGTYTXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AK2 } [get_ports {ff_rx_p[8]}]  ;# MGTYRXP3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AK1 } [get_ports {ff_rx_n[8]}]  ;# MGTYRXN3_224 GTYE4_CHANNEL_X1Y23 / GTYE4_COMMON_X1Y5
#set_property -dict {LOC AP11} [get_ports ff_mgt_refclk_p] ;# MGTREFCLK1P_225 from U48.31 OUT2_P
#set_property -dict {LOC AP10} [get_ports ff_mgt_refclk_n] ;# MGTREFCLK1N_225 from U48.30 OUT2_N
#set_property -dict {LOC M22  IOSTANDARD LVCMOS18} [get_ports ff_tx_int_l]
#set_property -dict {LOC P21  IOSTANDARD LVCMOS18} [get_ports ff_tx_gpio]
#set_property -dict {LOC N23  IOSTANDARD LVCMOS18} [get_ports ff_tx_prsnt_l]
#set_property -dict {LOC N22  IOSTANDARD LVCMOS18} [get_ports ff_rx_int_l]
#set_property -dict {LOC R21  IOSTANDARD LVCMOS18} [get_ports ff_rx_gpio]
#set_property -dict {LOC P23  IOSTANDARD LVCMOS18} [get_ports ff_rx_prsnt_l]

# 100 MHz MGT reference clock
#create_clock -period 10.000 -name ff_mgt_refclk [get_ports ff_mgt_refclk_p]

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name ff_mgt_refclk [get_ports ff_mgt_refclk_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name ff_mgt_refclk [get_ports ff_mgt_refclk_p]

# FMC+
# set_property -dict {LOC BA15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[0]}] ;# CC
# set_property -dict {LOC BA14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[0]}] ;# CC
# set_property -dict {LOC AY13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[1]}] ;# CC
# set_property -dict {LOC BA13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[1]}] ;# CC
# set_property -dict {LOC AL15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[2]}]
# set_property -dict {LOC AM15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[2]}]
# set_property -dict {LOC AN14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[3]}]
# set_property -dict {LOC AN13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[3]}]
# set_property -dict {LOC AL14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[4]}]
# set_property -dict {LOC AM14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[4]}]
# set_property -dict {LOC AP13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[5]}]
# set_property -dict {LOC AR13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[5]}]
# set_property -dict {LOC AP15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[6]}]
# set_property -dict {LOC AP14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[6]}]
# set_property -dict {LOC AU16 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[7]}]
# set_property -dict {LOC AV16 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[7]}]
# set_property -dict {LOC AR16 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[8]}]
# set_property -dict {LOC AR15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[8]}]
# set_property -dict {LOC AT15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[9]}]
# set_property -dict {LOC AU15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[9]}]
# set_property -dict {LOC AU14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[10]}]
# set_property -dict {LOC AV14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[10]}]
# set_property -dict {LOC BD15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[11]}]
# set_property -dict {LOC BD14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[11]}]
# set_property -dict {LOC AY12 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[12]}]
# set_property -dict {LOC AY11 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[12]}]
# set_property -dict {LOC BA12 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[13]}]
# set_property -dict {LOC BB12 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[13]}]
# set_property -dict {LOC BB15 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[14]}]
# set_property -dict {LOC BB14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[14]}]
# set_property -dict {LOC BF14 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[15]}]
# set_property -dict {LOC BF13 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[15]}]
# set_property -dict {LOC BD16 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[16]}]
# set_property -dict {LOC BE16 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[16]}]
# set_property -dict {LOC AT20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[17]}] ;# CC
# set_property -dict {LOC AU20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[17]}] ;# CC
# set_property -dict {LOC AV19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[18]}] ;# CC
# set_property -dict {LOC AW19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[18]}] ;# CC
# set_property -dict {LOC AR17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[19]}]
# set_property -dict {LOC AT17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[19]}]
# set_property -dict {LOC AN18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[20]}]
# set_property -dict {LOC AN17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[20]}]
# set_property -dict {LOC AW20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[21]}]
# set_property -dict {LOC AY20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[21]}]
# set_property -dict {LOC AT19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[22]}]
# set_property -dict {LOC AU19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[22]}]
# set_property -dict {LOC AL17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[23]}]
# set_property -dict {LOC AM17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[23]}]
# set_property -dict {LOC AY17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[24]}]
# set_property -dict {LOC BA17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[24]}]
# set_property -dict {LOC AY18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[25]}]
# set_property -dict {LOC BA18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[25]}]
# set_property -dict {LOC AP20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[26]}]
# set_property -dict {LOC AP20 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[26]}]
# set_property -dict {LOC AN19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[27]}]
# set_property -dict {LOC AP19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[27]}]
# set_property -dict {LOC BB17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[28]}]
# set_property -dict {LOC BC17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[28]}]
# set_property -dict {LOC BB19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[29]}]
# set_property -dict {LOC BC18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[29]}]
# set_property -dict {LOC BD18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[30]}]
# set_property -dict {LOC BE18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[30]}]
# set_property -dict {LOC BC19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[31]}]
# set_property -dict {LOC BD19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[31]}]
# set_property -dict {LOC BF19 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[32]}]
# set_property -dict {LOC BF18 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[32]}]
# set_property -dict {LOC BE17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_p[33]}]
# set_property -dict {LOC BF17 IOSTANDARD LVCMOS18} [get_ports {fmc_la_n[33]}]

# set_property -dict {LOC G14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[0]}] ;# CC
# set_property -dict {LOC F14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[0]}] ;# CC
# set_property -dict {LOC G15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[1]}] ;# CC
# set_property -dict {LOC F15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[1]}] ;# CC
# set_property -dict {LOC A14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[2]}]
# set_property -dict {LOC A13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[2]}]
# set_property -dict {LOC B17  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[3]}]
# set_property -dict {LOC A17  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[3]}]
# set_property -dict {LOC C16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[4]}]
# set_property -dict {LOC B16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[4]}]
# set_property -dict {LOC B15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[5]}]
# set_property -dict {LOC A15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[5]}]
# set_property -dict {LOC G17  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[6]}]
# set_property -dict {LOC G16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[6]}]
# set_property -dict {LOC D13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[7]}]
# set_property -dict {LOC C13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[7]}]
# set_property -dict {LOC E15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[8]}]
# set_property -dict {LOC D15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[8]}]
# set_property -dict {LOC E16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[9]}]
# set_property -dict {LOC D16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[9]}]
# set_property -dict {LOC R16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[10]}]
# set_property -dict {LOC P16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[10]}]
# set_property -dict {LOC L13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[11]}]
# set_property -dict {LOC K13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[11]}]
# set_property -dict {LOC H17  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[12]}]
# set_property -dict {LOC H16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[12]}]
# set_property -dict {LOC J13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[13]}]
# set_property -dict {LOC H13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[13]}]
# set_property -dict {LOC P14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[14]}]
# set_property -dict {LOC N14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[14]}]
# set_property -dict {LOC N16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[15]}]
# set_property -dict {LOC M16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[15]}]
# set_property -dict {LOC M14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[16]}]
# set_property -dict {LOC L14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[16]}]
# set_property -dict {LOC J14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[17]}] ;# CC
# set_property -dict {LOC H14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[17]}] ;# CC
# set_property -dict {LOC J16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[18]}] ;# CC
# set_property -dict {LOC J15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[18]}] ;# CC
# set_property -dict {LOC F13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[19]}]
# set_property -dict {LOC E13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[19]}]
# set_property -dict {LOC K16  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[20]}]
# set_property -dict {LOC K15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[20]}]
# set_property -dict {LOC C14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[21]}]
# set_property -dict {LOC B14  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[21]}]
# set_property -dict {LOC R15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[22]}]
# set_property -dict {LOC P15  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[22]}]
# set_property -dict {LOC P13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_p[23]}]
# set_property -dict {LOC N13  IOSTANDARD LVCMOS18} [get_ports {fmc_ha_n[23]}]

# set_property -dict {LOC H19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[0]}] ;# CC
# set_property -dict {LOC H18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[0]}] ;# CC
# set_property -dict {LOC D18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[1]}]
# set_property -dict {LOC C18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[1]}]
# set_property -dict {LOC D19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[2]}]
# set_property -dict {LOC C19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[2]}]
# set_property -dict {LOC B20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[3]}]
# set_property -dict {LOC A20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[3]}]
# set_property -dict {LOC F18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[4]}]
# set_property -dict {LOC F17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[4]}]
# set_property -dict {LOC E18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[5]}]
# set_property -dict {LOC E17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[5]}]
# set_property -dict {LOC J20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[6]}] ;# CC
# set_property -dict {LOC J19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[6]}] ;# CC
# set_property -dict {LOC F20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[7]}]
# set_property -dict {LOC F19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[7]}]
# set_property -dict {LOC J21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[8]}]
# set_property -dict {LOC H21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[8]}]
# set_property -dict {LOC G20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[9]}]
# set_property -dict {LOC G19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[9]}]
# set_property -dict {LOC P19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[10]}]
# set_property -dict {LOC N19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[10]}]
# set_property -dict {LOC L17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[11]}]
# set_property -dict {LOC K17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[11]}]
# set_property -dict {LOC L19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[12]}]
# set_property -dict {LOC L18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[12]}]
# set_property -dict {LOC N17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[13]}]
# set_property -dict {LOC M17  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[13]}]
# set_property -dict {LOC N21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[14]}]
# set_property -dict {LOC M21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[14]}]
# set_property -dict {LOC R20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[15]}]
# set_property -dict {LOC P20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[15]}]
# set_property -dict {LOC L20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[16]}]
# set_property -dict {LOC K20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[16]}]
# set_property -dict {LOC K18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[17]}] ;# CC
# set_property -dict {LOC J18  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[17]}] ;# CC
# set_property -dict {LOC C21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[18]}]
# set_property -dict {LOC B21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[18]}]
# set_property -dict {LOC E21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[19]}]
# set_property -dict {LOC E20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[19]}]
# set_property -dict {LOC B19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[20]}]
# set_property -dict {LOC A19  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[20]}]
# set_property -dict {LOC D21  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_p[21]}]
# set_property -dict {LOC D20  IOSTANDARD LVCMOS18} [get_ports {fmc_hb_n[21]}]

# set_property -dict {LOC AW14 IOSTANDARD LVCMOS18} [get_ports {fmc_clk0_m2c_p}]
# set_property -dict {LOC AW13 IOSTANDARD LVCMOS18} [get_ports {fmc_clk0_m2c_n}]
# set_property -dict {LOC AV18 IOSTANDARD LVCMOS18} [get_ports {fmc_clk1_m2c_p}]
# set_property -dict {LOC AW18 IOSTANDARD LVCMOS18} [get_ports {fmc_clk1_m2c_n}]

# set_property -dict {LOC G25  IOSTANDARD LVCMOS18} [get_ports {fmc_user_def0_p}]
# set_property -dict {LOC G24  IOSTANDARD LVCMOS18} [get_ports {fmc_user_def0_n}]
# set_property -dict {LOC J24  IOSTANDARD LVCMOS18} [get_ports {fmc_sync_m2c_p}]
# set_property -dict {LOC H24  IOSTANDARD LVCMOS18} [get_ports {fmc_sync_m2c_n}]
# set_property -dict {LOC F24  IOSTANDARD LVCMOS18} [get_ports {fmc_refclk_m2c_p}]
# set_property -dict {LOC F23  IOSTANDARD LVCMOS18} [get_ports {fmc_refclk_m2c_n}]
# set_property -dict {LOC E23  IOSTANDARD LVCMOS18} [get_ports {fmc_sync_c2m_p}]
# set_property -dict {LOC E22  IOSTANDARD LVCMOS18} [get_ports {fmc_sync_c2m_n}]

# set_property -dict {LOC AV23 IOSTANDARD LVCMOS18} [get_ports {fmc_pg_m2c}]
# set_property -dict {LOC AW23 IOSTANDARD LVCMOS18} [get_ports {fmc_prsnt_m2c_l}]
# set_property -dict {LOC BC23 IOSTANDARD LVCMOS18} [get_ports {hspc_prsnt_m2c_l}]

#set_property -dict {LOC AA9 } [get_ports {fmc_dp_c2m_p[3]}]  ;# MGTYTXP0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC AA8 } [get_ports {fmc_dp_c2m_n[3]}]  ;# MGTYTXN0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC AA4 } [get_ports {fmc_dp_m2c_p[3]}]  ;# MGTYRXP0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC AA3 } [get_ports {fmc_dp_m2c_n[3]}]  ;# MGTYRXN0_229 GTYE4_CHANNEL_X1Y40 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC Y7  } [get_ports {fmc_dp_c2m_p[0]}]  ;# MGTYTXP1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC Y6  } [get_ports {fmc_dp_c2m_n[0]}]  ;# MGTYTXN1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC Y2  } [get_ports {fmc_dp_m2c_p[0]}]  ;# MGTYRXP1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC Y1  } [get_ports {fmc_dp_m2c_n[0]}]  ;# MGTYRXN1_229 GTYE4_CHANNEL_X1Y41 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC W9  } [get_ports {fmc_dp_c2m_p[2]}]  ;# MGTYTXP2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC W8  } [get_ports {fmc_dp_c2m_n[2]}]  ;# MGTYTXN2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC W4  } [get_ports {fmc_dp_m2c_p[2]}]  ;# MGTYRXP2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC W3  } [get_ports {fmc_dp_m2c_n[2]}]  ;# MGTYRXN2_229 GTYE4_CHANNEL_X1Y42 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC V7  } [get_ports {fmc_dp_c2m_p[1]}]  ;# MGTYTXP3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC V6  } [get_ports {fmc_dp_c2m_n[1]}]  ;# MGTYTXN3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC V2  } [get_ports {fmc_dp_m2c_p[1]}]  ;# MGTYRXP3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC V1  } [get_ports {fmc_dp_m2c_n[1]}]  ;# MGTYRXN3_229 GTYE4_CHANNEL_X1Y43 / GTYE4_COMMON_X1Y10
#set_property -dict {LOC Y11 } [get_ports fmc_mgt_refclk_1_0_p] ;# MGTREFCLK0P_229 from J9.D4 GBTCLK0_M2C_P
#set_property -dict {LOC Y10 } [get_ports fmc_mgt_refclk_1_0_n] ;# MGTREFCLK0N_229 from J9.D5 GBTCLK0_M2C_N
#set_property -dict {LOC V11 } [get_ports fmc_mgt_refclk_1_1_p] ;# MGTREFCLK1P_229 from U27.14 OUT3
#set_property -dict {LOC V10 } [get_ports fmc_mgt_refclk_1_1_n] ;# MGTREFCLK1N_229 from U27.13 OUT3B

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_1_0 [get_ports fmc_mgt_refclk_1_0_p]
#create_clock -period 6.400 -name fmc_mgt_refclk_1_1 [get_ports fmc_mgt_refclk_1_1_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_1_0 [get_ports fmc_mgt_refclk_1_0_p]
#create_clock -period 6.206 -name fmc_mgt_refclk_1_1 [get_ports fmc_mgt_refclk_1_1_p]

#set_property -dict {LOC AE9 } [get_ports {fmc_dp_c2m_p[5]}]  ;# MGTYTXP0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AE8 } [get_ports {fmc_dp_c2m_n[5]}]  ;# MGTYTXN0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AE4 } [get_ports {fmc_dp_m2c_p[5]}]  ;# MGTYRXP0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AE3 } [get_ports {fmc_dp_m2c_n[5]}]  ;# MGTYRXN0_228 GTYE4_CHANNEL_X1Y36 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AD7 } [get_ports {fmc_dp_c2m_p[6]}]  ;# MGTYTXP1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AD6 } [get_ports {fmc_dp_c2m_n[6]}]  ;# MGTYTXN1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AD2 } [get_ports {fmc_dp_m2c_p[6]}]  ;# MGTYRXP1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AD1 } [get_ports {fmc_dp_m2c_n[6]}]  ;# MGTYRXN1_228 GTYE4_CHANNEL_X1Y37 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AC9 } [get_ports {fmc_dp_c2m_p[4]}]  ;# MGTYTXP2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AC8 } [get_ports {fmc_dp_c2m_n[4]}]  ;# MGTYTXN2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AC4 } [get_ports {fmc_dp_m2c_p[4]}]  ;# MGTYRXP2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AC3 } [get_ports {fmc_dp_m2c_n[4]}]  ;# MGTYRXN2_228 GTYE4_CHANNEL_X1Y38 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AB7 } [get_ports {fmc_dp_c2m_p[7]}]  ;# MGTYTXP3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AB6 } [get_ports {fmc_dp_c2m_n[7]}]  ;# MGTYTXN3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AB2 } [get_ports {fmc_dp_m2c_p[7]}]  ;# MGTYRXP3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AB1 } [get_ports {fmc_dp_m2c_n[7]}]  ;# MGTYRXN3_228 GTYE4_CHANNEL_X1Y39 / GTYE4_COMMON_X1Y9
#set_property -dict {LOC AD11} [get_ports fmc_mgt_refclk_2_0_p] ;# MGTREFCLK0P_228 from J9.B20 GBTCLK1_M2C_P
#set_property -dict {LOC AD10} [get_ports fmc_mgt_refclk_2_0_n] ;# MGTREFCLK0N_228 from J9.B21 GBTCLK1_M2C_N

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_2_0 [get_ports fmc_mgt_refclk_2_0_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_2_0 [get_ports fmc_mgt_refclk_2_0_p]

#set_property -dict {LOC N9  } [get_ports {fmc_dp_c2m_p[11]}] ;# MGTYTXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC N8  } [get_ports {fmc_dp_c2m_n[11]}] ;# MGTYTXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC N4  } [get_ports {fmc_dp_m2c_p[11]}] ;# MGTYRXP0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC N3  } [get_ports {fmc_dp_m2c_n[11]}] ;# MGTYRXN0_231 GTYE4_CHANNEL_X1Y48 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M7  } [get_ports {fmc_dp_c2m_p[10]}] ;# MGTYTXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M6  } [get_ports {fmc_dp_c2m_n[10]}] ;# MGTYTXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M2  } [get_ports {fmc_dp_m2c_p[10]}] ;# MGTYRXP1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M1  } [get_ports {fmc_dp_m2c_n[10]}] ;# MGTYRXN1_231 GTYE4_CHANNEL_X1Y49 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC L9  } [get_ports {fmc_dp_c2m_p[8]}]  ;# MGTYTXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC L8  } [get_ports {fmc_dp_c2m_n[8]}]  ;# MGTYTXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC L4  } [get_ports {fmc_dp_m2c_p[8]}]  ;# MGTYRXP2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC L3  } [get_ports {fmc_dp_m2c_n[8]}]  ;# MGTYRXN2_231 GTYE4_CHANNEL_X1Y50 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC K7  } [get_ports {fmc_dp_c2m_p[9]}]  ;# MGTYTXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC K6  } [get_ports {fmc_dp_c2m_n[9]}]  ;# MGTYTXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC K2  } [get_ports {fmc_dp_m2c_p[9]}]  ;# MGTYRXP3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC K1  } [get_ports {fmc_dp_m2c_n[9]}]  ;# MGTYRXN3_231 GTYE4_CHANNEL_X1Y51 / GTYE4_COMMON_X1Y12
#set_property -dict {LOC M11 } [get_ports fmc_mgt_refclk_3_0_p] ;# MGTREFCLK0P_231 from J9.L12 GBTCLK2_M2C_P
#set_property -dict {LOC M10 } [get_ports fmc_mgt_refclk_3_0_n] ;# MGTREFCLK0N_231 from J9.L13 GBTCLK2_M2C_N
#set_property -dict {LOC K11 } [get_ports fmc_mgt_refclk_3_1_p] ;# MGTREFCLK1P_231 from U27.17 OUT2
#set_property -dict {LOC K10 } [get_ports fmc_mgt_refclk_3_1_n] ;# MGTREFCLK1N_231 from U27.16 OUT2B

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_3_0 [get_ports fmc_mgt_refclk_3_0_p]
#create_clock -period 6.400 -name fmc_mgt_refclk_3_1 [get_ports fmc_mgt_refclk_3_1_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_3_0 [get_ports fmc_mgt_refclk_3_0_p]
#create_clock -period 6.206 -name fmc_mgt_refclk_3_1 [get_ports fmc_mgt_refclk_3_1_p]

#set_property -dict {LOC U9  } [get_ports {fmc_dp_c2m_p[15]}] ;# MGTYTXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC U8  } [get_ports {fmc_dp_c2m_n[15]}] ;# MGTYTXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC U4  } [get_ports {fmc_dp_m2c_p[15]}] ;# MGTYRXP0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC U3  } [get_ports {fmc_dp_m2c_n[15]}] ;# MGTYRXN0_230 GTYE4_CHANNEL_X1Y44 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T7  } [get_ports {fmc_dp_c2m_p[14]}] ;# MGTYTXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T6  } [get_ports {fmc_dp_c2m_n[14]}] ;# MGTYTXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T2  } [get_ports {fmc_dp_m2c_p[14]}] ;# MGTYRXP1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T1  } [get_ports {fmc_dp_m2c_n[14]}] ;# MGTYRXN1_230 GTYE4_CHANNEL_X1Y45 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC R9  } [get_ports {fmc_dp_c2m_p[13]}] ;# MGTYTXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC R8  } [get_ports {fmc_dp_c2m_n[13]}] ;# MGTYTXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC R4  } [get_ports {fmc_dp_m2c_p[13]}] ;# MGTYRXP2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC R3  } [get_ports {fmc_dp_m2c_n[13]}] ;# MGTYRXN2_230 GTYE4_CHANNEL_X1Y46 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC P7  } [get_ports {fmc_dp_c2m_p[12]}] ;# MGTYTXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC P6  } [get_ports {fmc_dp_c2m_n[12]}] ;# MGTYTXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC P2  } [get_ports {fmc_dp_m2c_p[12]}] ;# MGTYRXP3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC P1  } [get_ports {fmc_dp_m2c_n[12]}] ;# MGTYRXN3_230 GTYE4_CHANNEL_X1Y47 / GTYE4_COMMON_X1Y11
#set_property -dict {LOC T11 } [get_ports fmc_mgt_refclk_4_0_p] ;# MGTREFCLK0P_230 from J9.L8 GBTCLK3_M2C_P
#set_property -dict {LOC T10 } [get_ports fmc_mgt_refclk_4_0_n] ;# MGTREFCLK0N_230 from J9.L9 GBTCLK3_M2C_N

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_4_0 [get_ports fmc_mgt_refclk_4_0_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_4_0 [get_ports fmc_mgt_refclk_4_0_p]

#set_property -dict {LOC AJ9 } [get_ports {fmc_dp_c2m_p[19]}] ;# MGTYTXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ8 } [get_ports {fmc_dp_c2m_n[19]}] ;# MGTYTXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ4 } [get_ports {fmc_dp_m2c_p[19]}] ;# MGTYRXP0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AJ3 } [get_ports {fmc_dp_m2c_n[19]}] ;# MGTYRXN0_227 GTYE4_CHANNEL_X1Y32 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH7 } [get_ports {fmc_dp_c2m_p[18]}] ;# MGTYTXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH6 } [get_ports {fmc_dp_c2m_n[18]}] ;# MGTYTXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH2 } [get_ports {fmc_dp_m2c_p[18]}] ;# MGTYRXP1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH1 } [get_ports {fmc_dp_m2c_n[18]}] ;# MGTYRXN1_227 GTYE4_CHANNEL_X1Y33 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG9 } [get_ports {fmc_dp_c2m_p[17]}] ;# MGTYTXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG8 } [get_ports {fmc_dp_c2m_n[17]}] ;# MGTYTXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG4 } [get_ports {fmc_dp_m2c_p[17]}] ;# MGTYRXP2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AG3 } [get_ports {fmc_dp_m2c_n[17]}] ;# MGTYRXN2_227 GTYE4_CHANNEL_X1Y34 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF7 } [get_ports {fmc_dp_c2m_p[16]}] ;# MGTYTXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF6 } [get_ports {fmc_dp_c2m_n[16]}] ;# MGTYTXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF2 } [get_ports {fmc_dp_m2c_p[16]}] ;# MGTYRXP3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AF1 } [get_ports {fmc_dp_m2c_n[16]}] ;# MGTYRXN3_227 GTYE4_CHANNEL_X1Y35 / GTYE4_COMMON_X1Y8
#set_property -dict {LOC AH11} [get_ports fmc_mgt_refclk_5_0_p] ;# MGTREFCLK0P_227 from J9.L4 GBTCLK4_M2C_P
#set_property -dict {LOC AH10} [get_ports fmc_mgt_refclk_5_0_n] ;# MGTREFCLK0N_227 from J9.L5 GBTCLK4_M2C_N
#set_property -dict {LOC AF11} [get_ports fmc_mgt_refclk_5_1_p] ;# MGTREFCLK1P_227 from U27.11 OUT4
#set_property -dict {LOC AF10} [get_ports fmc_mgt_refclk_5_1_n] ;# MGTREFCLK1N_227 from U27.12 OUT4B

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_5_0 [get_ports fmc_mgt_refclk_5_0_p]
#create_clock -period 6.400 -name fmc_mgt_refclk_5_1 [get_ports fmc_mgt_refclk_5_1_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_5_0 [get_ports fmc_mgt_refclk_5_0_p]
#create_clock -period 6.206 -name fmc_mgt_refclk_5_1 [get_ports fmc_mgt_refclk_5_1_p]

#set_property -dict {LOC J9  } [get_ports {fmc_dp_c2m_p[20]}] ;# MGTYTXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC J8  } [get_ports {fmc_dp_c2m_n[20]}] ;# MGTYTXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC J4  } [get_ports {fmc_dp_m2c_p[20]}] ;# MGTYRXP0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC J3  } [get_ports {fmc_dp_m2c_n[20]}] ;# MGTYRXN0_232 GTYE4_CHANNEL_X1Y52 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC H7  } [get_ports {fmc_dp_c2m_p[21]}] ;# MGTYTXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC H6  } [get_ports {fmc_dp_c2m_n[21]}] ;# MGTYTXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC H2  } [get_ports {fmc_dp_m2c_p[21]}] ;# MGTYRXP1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC H1  } [get_ports {fmc_dp_m2c_n[21]}] ;# MGTYRXN1_232 GTYE4_CHANNEL_X1Y53 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC G9  } [get_ports {fmc_dp_c2m_p[22]}] ;# MGTYTXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC G8  } [get_ports {fmc_dp_c2m_n[22]}] ;# MGTYTXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC G4  } [get_ports {fmc_dp_m2c_p[22]}] ;# MGTYRXP2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC G3  } [get_ports {fmc_dp_m2c_n[22]}] ;# MGTYRXN2_232 GTYE4_CHANNEL_X1Y54 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC F7  } [get_ports {fmc_dp_c2m_p[23]}] ;# MGTYTXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC F6  } [get_ports {fmc_dp_c2m_n[23]}] ;# MGTYTXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC F2  } [get_ports {fmc_dp_m2c_p[23]}] ;# MGTYRXP3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC F1  } [get_ports {fmc_dp_m2c_n[23]}] ;# MGTYRXN3_232 GTYE4_CHANNEL_X1Y55 / GTYE4_COMMON_X1Y13
#set_property -dict {LOC H11 } [get_ports fmc_mgt_refclk_6_0_p] ;# MGTREFCLK0P_232 from J9.Z20 GBTCLK5_M2C_P
#set_property -dict {LOC H10 } [get_ports fmc_mgt_refclk_6_0_n] ;# MGTREFCLK0N_232 from J9.Z21 GBTCLK5_M2C_N

# 156.25 MHz MGT reference clock
#create_clock -period 6.400 -name fmc_mgt_refclk_6_0 [get_ports fmc_mgt_refclk_6_0_p]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name fmc_mgt_refclk_6_0 [get_ports fmc_mgt_refclk_6_0_p]
