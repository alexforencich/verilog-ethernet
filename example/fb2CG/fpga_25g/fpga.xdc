# XDC constraints for the fb2CG@KU15P
# part: xcku15p-ffve1760-2-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES        [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0          [current_design]
set_property CONFIG_MODE SPIx4                         [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable  [current_design]

# System clocks
# init clock 50 MHz
set_property -dict {LOC E7   IOSTANDARD LVCMOS18} [get_ports init_clk]
create_clock -period 20.000 -name init_clk [get_ports init_clk]

# E7 is not a global clock capable input, so need to set CLOCK_DEDICATED_ROUTE to satisfy DRC
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets init_clk_ibuf_inst/O]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets init_clk_bufg]

# DDR4 refclk1
#set_property -dict {LOC AT32 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_refclk1_p]
#set_property -dict {LOC AU32 IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_refclk1_n]
#create_clock -period 3.750 -name clk_ddr4_refclk1 [get_ports clk_ddr4_refclk1_p]

# DDR4 refclk2
#set_property -dict {LOC G29  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_refclk2_p]
#set_property -dict {LOC G28  IOSTANDARD DIFF_SSTL12} [get_ports clk_ddr4_refclk2_n]
#create_clock -period 3.750 -name clk_ddr4_refclk2 [get_ports clk_ddr4_refclk1_p]

# LEDs
set_property -dict {LOC C4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports led_sreg_d]
set_property -dict {LOC B3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports led_sreg_ld]
set_property -dict {LOC G3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports led_sreg_clk]
set_property -dict {LOC C5   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led_bmc[0]}]
set_property -dict {LOC C6   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led_bmc[1]}]
set_property -dict {LOC D3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {led_exp[0]}]
set_property -dict {LOC D4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {led_exp[1]}]

set_false_path -to [get_ports {led_sreg_d led_sreg_ld led_sreg_clk led_bmc[*] led_exp[*]}]
set_output_delay 0 [get_ports {led_sreg_d led_sreg_ld led_sreg_clk led_bmc[*] led_exp[*]}]

# GPIO
#set_property -dict {LOC B4   IOSTANDARD LVCMOS33} [get_ports pps_in] ;# from SMA J6 via Q1 (inverted)
#set_property -dict {LOC A4   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 4} [get_ports pps_out] ;# to SMA J6 via U4 and U5, and u.FL J7 (PPS OUT) via U3
#set_property -dict {LOC A3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports pps_out_en] ; # to U5 IN (connects pps_out to SMA J6 when high)
#set_property -dict {LOC H2   IOSTANDARD LVCMOS33} [get_ports misc_ucoax] ; from u.FL J5 (PPS IN)

#set_false_path -to [get_ports {pps_out pps_out_en}]
#set_output_delay 0 [get_ports {pps_out pps_out_en}]
#set_false_path -from [get_ports {pps_in}]
#set_input_delay 0 [get_ports {pps_in}]

# BMC interface
#set_property -dict {LOC D7   IOSTANDARD LVCMOS18} [get_ports bmc_miso]
#set_property -dict {LOC J4   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports bmc_nss]
#set_property -dict {LOC B6   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports bmc_clk]
#set_property -dict {LOC D5   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 4} [get_ports bmc_mosi]
#set_property -dict {LOC H4   IOSTANDARD LVCMOS18} [get_ports bmc_int]

#set_false_path -to [get_ports {bmc_nss bmc_clk bmc_mosi}]
#set_output_delay 0 [get_ports {bmc_nss bmc_clk bmc_mosi}]
#set_false_path -from [get_ports {bmc_miso bmc_int}]
#set_input_delay 0 [get_ports {bmc_miso bmc_int}]

# Board status
#set_property -dict {LOC J2   IOSTANDARD LVCMOS33} [get_ports {fan_tacho[0]}]
#set_property -dict {LOC J3   IOSTANDARD LVCMOS33} [get_ports {fan_tacho[1]}]
set_property -dict {LOC A6   IOSTANDARD LVCMOS18} [get_ports {pg[0]}]
set_property -dict {LOC C7   IOSTANDARD LVCMOS18} [get_ports {pg[1]}]
#set_property -dict {LOC E2   IOSTANDARD LVCMOS33} [get_ports pwrbrk]

set_false_path -from [get_ports {pg[*]}]
set_input_delay 0 [get_ports {pg[*]}]

# QSFP28 Interfaces
set_property -dict {LOC Y39 } [get_ports {qsfp_0_rx_p[0]}] ;# MGTYRXP0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y40 } [get_ports {qsfp_0_rx_n[0]}] ;# MGTYRXN0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y34 } [get_ports {qsfp_0_tx_p[0]}] ;# MGTYTXP0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y35 } [get_ports {qsfp_0_tx_n[0]}] ;# MGTYTXN0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W41 } [get_ports {qsfp_0_rx_p[1]}] ;# MGTYRXP1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W42 } [get_ports {qsfp_0_rx_n[1]}] ;# MGTYRXN1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W36 } [get_ports {qsfp_0_tx_p[1]}] ;# MGTYTXP1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W37 } [get_ports {qsfp_0_tx_n[1]}] ;# MGTYTXN1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V39 } [get_ports {qsfp_0_rx_p[2]}] ;# MGTYRXP2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V40 } [get_ports {qsfp_0_rx_n[2]}] ;# MGTYRXN2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V34 } [get_ports {qsfp_0_tx_p[2]}] ;# MGTYTXP2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V35 } [get_ports {qsfp_0_tx_n[2]}] ;# MGTYTXN2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U41 } [get_ports {qsfp_0_rx_p[3]}] ;# MGTYRXP3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U42 } [get_ports {qsfp_0_rx_n[3]}] ;# MGTYRXN3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U36 } [get_ports {qsfp_0_tx_p[3]}] ;# MGTYTXP3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U37 } [get_ports {qsfp_0_tx_n[3]}] ;# MGTYTXN3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W32 } [get_ports qsfp_0_mgt_refclk_p] ;# MGTREFCLK0P_130 from U28
set_property -dict {LOC W33 } [get_ports qsfp_0_mgt_refclk_n] ;# MGTREFCLK0N_130 from U28
set_property -dict {LOC B9   IOSTANDARD LVCMOS33 PULLUP true} [get_ports qsfp_0_mod_prsnt_n]
set_property -dict {LOC A8   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_0_reset_n]
set_property -dict {LOC A9   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_0_lp_mode]
set_property -dict {LOC A10  IOSTANDARD LVCMOS33 PULLUP true} [get_ports qsfp_0_intr_n]
#set_property -dict {LOC B8   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_0_i2c_scl]
#set_property -dict {LOC B7   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_0_i2c_sda]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_0_mgt_refclk [get_ports qsfp_0_mgt_refclk_p]

set_false_path -to [get_ports {qsfp_0_reset_n qsfp_0_lp_mode}]
set_output_delay 0 [get_ports {qsfp_0_reset_n qsfp_0_lp_mode}]
set_false_path -from [get_ports {qsfp_0_mod_prsnt_n qsfp_0_intr_n}]
set_input_delay 0 [get_ports {qsfp_0_mod_prsnt_n qsfp_0_intr_n}]

#set_false_path -to [get_ports {qsfp_0_i2c_scl qsfp_0_i2c_sda}]
#set_output_delay 0 [get_ports {qsfp_0_i2c_scl qsfp_0_i2c_sda}]
#set_false_path -from [get_ports {qsfp_0_i2c_scl qsfp_0_i2c_sda}]
#set_input_delay 0 [get_ports {qsfp_0_i2c_scl qsfp_0_i2c_sda}]

set_property -dict {LOC M39 } [get_ports {qsfp_1_rx_p[0]}] ;# MGTYRXP0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M40 } [get_ports {qsfp_1_rx_n[0]}] ;# MGTYRXN0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M34 } [get_ports {qsfp_1_tx_p[0]}] ;# MGTYTXP0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M35 } [get_ports {qsfp_1_tx_n[0]}] ;# MGTYTXN0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L41 } [get_ports {qsfp_1_rx_p[1]}] ;# MGTYRXP1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L42 } [get_ports {qsfp_1_rx_n[1]}] ;# MGTYRXN1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L36 } [get_ports {qsfp_1_tx_p[1]}] ;# MGTYTXP1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L37 } [get_ports {qsfp_1_tx_n[1]}] ;# MGTYTXN1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K39 } [get_ports {qsfp_1_rx_p[2]}] ;# MGTYRXP2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K40 } [get_ports {qsfp_1_rx_n[2]}] ;# MGTYRXN2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K34 } [get_ports {qsfp_1_tx_p[2]}] ;# MGTYTXP2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K35 } [get_ports {qsfp_1_tx_n[2]}] ;# MGTYTXN2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J41 } [get_ports {qsfp_1_rx_p[3]}] ;# MGTYRXP3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J42 } [get_ports {qsfp_1_rx_n[3]}] ;# MGTYRXN3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J36 } [get_ports {qsfp_1_tx_p[3]}] ;# MGTYTXP3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J37 } [get_ports {qsfp_1_tx_n[3]}] ;# MGTYTXN3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC P30 } [get_ports qsfp_1_mgt_refclk_p] ;# MGTREFCLK0P_132 from U28
set_property -dict {LOC P31 } [get_ports qsfp_1_mgt_refclk_n] ;# MGTREFCLK0N_132 from U28
set_property -dict {LOC E10  IOSTANDARD LVCMOS33 PULLUP true} [get_ports qsfp_1_mod_prsnt_n]
set_property -dict {LOC C10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_1_reset_n]
set_property -dict {LOC D9   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_1_lp_mode]
set_property -dict {LOC D10  IOSTANDARD LVCMOS33 PULLUP true} [get_ports qsfp_1_intr_n]
#set_property -dict {LOC C9   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_1_i2c_scl]
#set_property -dict {LOC D8   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports qsfp_1_i2c_sda]

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp_1_mgt_refclk [get_ports qsfp_1_mgt_refclk_p]

set_false_path -to [get_ports {qsfp_1_reset_n qsfp_1_lp_mode}]
set_output_delay 0 [get_ports {qsfp_1_reset_n qsfp_1_lp_mode}]
set_false_path -from [get_ports {qsfp_1_mod_prsnt_n qsfp_1_intr_n}]
set_input_delay 0 [get_ports {qsfp_1_mod_prsnt_n qsfp_1_intr_n}]

#set_false_path -to [get_ports {qsfp_1_i2c_scl qsfp_1_i2c_sda}]
#set_output_delay 0 [get_ports {qsfp_1_i2c_scl qsfp_1_i2c_sda}]
#set_false_path -from [get_ports {qsfp_1_i2c_scl qsfp_1_i2c_sda}]
#set_input_delay 0 [get_ports {qsfp_1_i2c_scl qsfp_1_i2c_sda}]

# Expansion connector
#set_property -dict {LOC AG41} [get_ports {exp_rx_p[0]}] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AG42} [get_ports {exp_rx_n[0]}] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AG36} [get_ports {exp_tx_p[0]}] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AG37} [get_ports {exp_tx_n[0]}] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AH39} [get_ports {exp_rx_p[1]}] ;# MGTYRXP0_128 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AH40} [get_ports {exp_rx_n[1]}] ;# MGTYRXN0_128 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AH34} [get_ports {exp_tx_p[1]}] ;# MGTYTXP0_128 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AH35} [get_ports {exp_tx_n[1]}] ;# MGTYTXN0_128 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
#set_property -dict {LOC AJ41} [get_ports {exp_rx_p[2]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AJ42} [get_ports {exp_rx_n[2]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AJ36} [get_ports {exp_tx_p[2]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AJ37} [get_ports {exp_tx_n[2]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AK39} [get_ports {exp_rx_p[3]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AK40} [get_ports {exp_rx_n[3]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AK34} [get_ports {exp_tx_p[3]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AK35} [get_ports {exp_tx_n[3]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AL41} [get_ports {exp_rx_p[4]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AL42} [get_ports {exp_rx_n[4]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AL36} [get_ports {exp_tx_p[4]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AL37} [get_ports {exp_tx_n[4]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AM39} [get_ports {exp_rx_p[5]}] ;# MGTYRXP0_127 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AM40} [get_ports {exp_rx_n[5]}] ;# MGTYRXN0_127 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AM34} [get_ports {exp_tx_p[5]}] ;# MGTYTXP0_127 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AM35} [get_ports {exp_tx_n[5]}] ;# MGTYTXN0_127 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
#set_property -dict {LOC AL32} [get_ports exp_refclk_0_p] ;# MGTREFCLK0P_128 from U28
#set_property -dict {LOC AL33} [get_ports exp_refclk_0_n] ;# MGTREFCLK0N_128 from U28
#set_property -dict {LOC AG32} [get_ports exp_refclk_1_p] ;# MGTREFCLK0P_127 from U28
#set_property -dict {LOC AG33} [get_ports exp_refclk_1_n] ;# MGTREFCLK0N_127 from U28
#set_property -dict {LOC E3   IOSTANDARD LVCMOS33} [get_ports {exp_gpio[0]}]
#set_property -dict {LOC F3   IOSTANDARD LVCMOS33} [get_ports {exp_gpio[1]}]

# 161.1328125 MHz MGT reference clock
#create_clock -period 6.206 -name exp_refclk_0 [get_ports exp_refclk_0_p]
#create_clock -period 6.206 -name exp_refclk_1 [get_ports exp_refclk_1_p]

# PCIe Interface
#set_property -dict {LOC AG2 } [get_ports {pcie_rx_p[0]}]  ;# MGTHRXP3_227 GTHE4_CHANNEL_X0Y15 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AG1 } [get_ports {pcie_rx_n[0]}]  ;# MGTHRXN3_227 GTHE4_CHANNEL_X0Y15 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AG6 } [get_ports {pcie_tx_p[0]}]  ;# MGTHTXP3_227 GTHE4_CHANNEL_X0Y15 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AG5 } [get_ports {pcie_tx_n[0]}]  ;# MGTHTXN3_227 GTHE4_CHANNEL_X0Y15 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AH4 } [get_ports {pcie_rx_p[1]}]  ;# MGTHRXP2_227 GTHE4_CHANNEL_X0Y14 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AH3 } [get_ports {pcie_rx_n[1]}]  ;# MGTHRXN2_227 GTHE4_CHANNEL_X0Y14 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AH8 } [get_ports {pcie_tx_p[1]}]  ;# MGTHTXP2_227 GTHE4_CHANNEL_X0Y14 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AH7 } [get_ports {pcie_tx_n[1]}]  ;# MGTHTXN2_227 GTHE4_CHANNEL_X0Y14 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AJ2 } [get_ports {pcie_rx_p[2]}]  ;# MGTHRXP1_227 GTHE4_CHANNEL_X0Y13 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AJ1 } [get_ports {pcie_rx_n[2]}]  ;# MGTHRXN1_227 GTHE4_CHANNEL_X0Y13 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AJ6 } [get_ports {pcie_tx_p[2]}]  ;# MGTHTXP1_227 GTHE4_CHANNEL_X0Y13 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AJ5 } [get_ports {pcie_tx_n[2]}]  ;# MGTHTXN1_227 GTHE4_CHANNEL_X0Y13 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AK4 } [get_ports {pcie_rx_p[3]}]  ;# MGTHRXP0_227 GTHE4_CHANNEL_X0Y12 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AK3 } [get_ports {pcie_rx_n[3]}]  ;# MGTHRXN0_227 GTHE4_CHANNEL_X0Y12 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AK8 } [get_ports {pcie_tx_p[3]}]  ;# MGTHTXP0_227 GTHE4_CHANNEL_X0Y12 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AK7 } [get_ports {pcie_tx_n[3]}]  ;# MGTHTXN0_227 GTHE4_CHANNEL_X0Y12 / GTHE4_COMMON_X0Y3
#set_property -dict {LOC AL2 } [get_ports {pcie_rx_p[4]}]  ;# MGTHRXP3_226 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AL1 } [get_ports {pcie_rx_n[4]}]  ;# MGTHRXN3_226 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AL6 } [get_ports {pcie_tx_p[4]}]  ;# MGTHTXP3_226 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AL5 } [get_ports {pcie_tx_n[4]}]  ;# MGTHTXN3_226 GTHE4_CHANNEL_X0Y11 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AM4 } [get_ports {pcie_rx_p[5]}]  ;# MGTHRXP2_226 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AM3 } [get_ports {pcie_rx_n[5]}]  ;# MGTHRXN2_226 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AM8 } [get_ports {pcie_tx_p[5]}]  ;# MGTHTXP2_226 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AM7 } [get_ports {pcie_tx_n[5]}]  ;# MGTHTXN2_226 GTHE4_CHANNEL_X0Y10 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AN2 } [get_ports {pcie_rx_p[6]}]  ;# MGTHRXP1_226 GTHE4_CHANNEL_X0Y9 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AN1 } [get_ports {pcie_rx_n[6]}]  ;# MGTHRXN1_226 GTHE4_CHANNEL_X0Y9 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AN6 } [get_ports {pcie_tx_p[6]}]  ;# MGTHTXP1_226 GTHE4_CHANNEL_X0Y9 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AN5 } [get_ports {pcie_tx_n[6]}]  ;# MGTHTXN1_226 GTHE4_CHANNEL_X0Y9 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AP4 } [get_ports {pcie_rx_p[7]}]  ;# MGTHRXP0_226 GTHE4_CHANNEL_X0Y8 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AP3 } [get_ports {pcie_rx_n[7]}]  ;# MGTHRXN0_226 GTHE4_CHANNEL_X0Y8 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AP8 } [get_ports {pcie_tx_p[7]}]  ;# MGTHTXP0_226 GTHE4_CHANNEL_X0Y8 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AP7 } [get_ports {pcie_tx_n[7]}]  ;# MGTHTXN0_226 GTHE4_CHANNEL_X0Y8 / GTHE4_COMMON_X0Y2
#set_property -dict {LOC AR2 } [get_ports {pcie_rx_p[8]}]  ;# MGTHRXP3_225 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AR1 } [get_ports {pcie_rx_n[8]}]  ;# MGTHRXN3_225 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AR6 } [get_ports {pcie_tx_p[8]}]  ;# MGTHTXP3_225 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AR5 } [get_ports {pcie_tx_n[8]}]  ;# MGTHTXN3_225 GTHE4_CHANNEL_X0Y7 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AT4 } [get_ports {pcie_rx_p[9]}]  ;# MGTHRXP2_225 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AT3 } [get_ports {pcie_rx_n[9]}]  ;# MGTHRXN2_225 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AT8 } [get_ports {pcie_tx_p[9]}]  ;# MGTHTXP2_225 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AT7 } [get_ports {pcie_tx_n[9]}]  ;# MGTHTXN2_225 GTHE4_CHANNEL_X0Y6 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AU2 } [get_ports {pcie_rx_p[10]}] ;# MGTHRXP1_225 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AU1 } [get_ports {pcie_rx_n[10]}] ;# MGTHRXN1_225 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AU6 } [get_ports {pcie_tx_p[10]}] ;# MGTHTXP1_225 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AU5 } [get_ports {pcie_tx_n[10]}] ;# MGTHTXN1_225 GTHE4_CHANNEL_X0Y5 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AV4 } [get_ports {pcie_rx_p[11]}] ;# MGTHRXP0_225 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AV3 } [get_ports {pcie_rx_n[11]}] ;# MGTHRXN0_225 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AV8 } [get_ports {pcie_tx_p[11]}] ;# MGTHTXP0_225 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AV7 } [get_ports {pcie_tx_n[11]}] ;# MGTHTXN0_225 GTHE4_CHANNEL_X0Y4 / GTHE4_COMMON_X0Y1
#set_property -dict {LOC AW2 } [get_ports {pcie_rx_p[12]}] ;# MGTHRXP3_224 GTHE4_CHANNEL_X0Y3 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AW1 } [get_ports {pcie_rx_n[12]}] ;# MGTHRXN3_224 GTHE4_CHANNEL_X0Y3 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AW6 } [get_ports {pcie_tx_p[12]}] ;# MGTHTXP3_224 GTHE4_CHANNEL_X0Y3 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AW5 } [get_ports {pcie_tx_n[12]}] ;# MGTHTXN3_224 GTHE4_CHANNEL_X0Y3 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AY4 } [get_ports {pcie_rx_p[13]}] ;# MGTHRXP2_224 GTHE4_CHANNEL_X0Y2 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AY3 } [get_ports {pcie_rx_n[13]}] ;# MGTHRXN2_224 GTHE4_CHANNEL_X0Y2 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AY8 } [get_ports {pcie_tx_p[13]}] ;# MGTHTXP2_224 GTHE4_CHANNEL_X0Y2 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AY7 } [get_ports {pcie_tx_n[13]}] ;# MGTHTXN2_224 GTHE4_CHANNEL_X0Y2 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BA2 } [get_ports {pcie_rx_p[14]}] ;# MGTHRXP1_224 GTHE4_CHANNEL_X0Y1 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BA1 } [get_ports {pcie_rx_n[14]}] ;# MGTHRXN1_224 GTHE4_CHANNEL_X0Y1 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BA6 } [get_ports {pcie_tx_p[14]}] ;# MGTHTXP1_224 GTHE4_CHANNEL_X0Y1 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BA5 } [get_ports {pcie_tx_n[14]}] ;# MGTHTXN1_224 GTHE4_CHANNEL_X0Y1 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BB4 } [get_ports {pcie_rx_p[15]}] ;# MGTHRXP0_224 GTHE4_CHANNEL_X0Y0 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BB3 } [get_ports {pcie_rx_n[15]}] ;# MGTHRXN0_224 GTHE4_CHANNEL_X0Y0 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BB8 } [get_ports {pcie_tx_p[15]}] ;# MGTHTXP0_224 GTHE4_CHANNEL_X0Y0 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC BB7 } [get_ports {pcie_tx_n[15]}] ;# MGTHTXN0_224 GTHE4_CHANNEL_X0Y0 / GTHE4_COMMON_X0Y0
#set_property -dict {LOC AN10} [get_ports pcie_refclk_p] ;# MGTREFCLK0P_226
#set_property -dict {LOC AN9 } [get_ports pcie_refclk_n] ;# MGTREFCLK0N_226
#set_property -dict {LOC G1   IOSTANDARD LVCMOS33 PULLUP true} [get_ports pcie_rst_n]

# 100 MHz MGT reference clock
#create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_refclk_p]

#set_false_path -from [get_ports {pcie_rst_n}]
#set_input_delay 0 [get_ports {pcie_rst_n}]

# DDR4 C0
# 5x K4A8G165WB-BCTD / MT40A512M16HA-075E
#set_property -dict {LOC AY22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[0]}]
#set_property -dict {LOC AY23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[1]}]
#set_property -dict {LOC AV23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[2]}]
#set_property -dict {LOC AY24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[3]}]
#set_property -dict {LOC AK23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[4]}]
#set_property -dict {LOC AV21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[5]}]
#set_property -dict {LOC AV22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[6]}]
#set_property -dict {LOC AT24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[7]}]
#set_property -dict {LOC AW24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[8]}]
#set_property -dict {LOC AY21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[9]}]
#set_property -dict {LOC AT22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[10]}]
#set_property -dict {LOC AP23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[11]}]
#set_property -dict {LOC BA21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[12]}]
#set_property -dict {LOC AU24 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[13]}]
#set_property -dict {LOC AL22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[14]}]
#set_property -dict {LOC BB22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[15]}]
#set_property -dict {LOC BB25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_adr[16]}]
#set_property -dict {LOC AW21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[0]}]
#set_property -dict {LOC AW23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_ba[1]}]
#set_property -dict {LOC BA22 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[0]}]
#set_property -dict {LOC BB23 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_bg[1]}]
#set_property -dict {LOC BA24 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_t}]
#set_property -dict {LOC BB24 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c0_ck_c}]
#set_property -dict {LOC AL21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cke}]
#set_property -dict {LOC BA25 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_cs_n}]
#set_property -dict {LOC AR21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_act_n}]
#set_property -dict {LOC AT21 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_odt}]
#set_property -dict {LOC AK17 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c0_par}]
#set_property -dict {LOC BB20 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_reset_n}]
#set_property -dict {LOC AV20 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_alert_n}]
#set_property -dict {LOC AU20 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c0_ten}]

#set_property -dict {LOC AL17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[0]}]
#set_property -dict {LOC AJ16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[1]}]
#set_property -dict {LOC AK19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[2]}]
#set_property -dict {LOC AK16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[3]}]
#set_property -dict {LOC AL19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[4]}]
#set_property -dict {LOC AH16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[5]}]
#set_property -dict {LOC AM17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[6]}]
#set_property -dict {LOC AH17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[7]}]
#set_property -dict {LOC AL24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[8]}]
#set_property -dict {LOC AH21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[9]}]
#set_property -dict {LOC AK24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[10]}]
#set_property -dict {LOC AJ24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[11]}]
#set_property -dict {LOC AK21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[12]}]
#set_property -dict {LOC AH22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[13]}]
#set_property -dict {LOC AJ21 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[14]}]
#set_property -dict {LOC AJ23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[15]}]
#set_property -dict {LOC BA14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[16]}]
#set_property -dict {LOC BB13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[17]}]
#set_property -dict {LOC AY13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[18]}]
#set_property -dict {LOC BB14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[19]}]
#set_property -dict {LOC AY14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[20]}]
#set_property -dict {LOC BB15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[21]}]
#set_property -dict {LOC BA15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[22]}]
#set_property -dict {LOC BB12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[23]}]
#set_property -dict {LOC AT15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[24]}]
#set_property -dict {LOC AW13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[25]}]
#set_property -dict {LOC AU15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[26]}]
#set_property -dict {LOC AU13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[27]}]
#set_property -dict {LOC AT16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[28]}]
#set_property -dict {LOC AW14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[29]}]
#set_property -dict {LOC AU14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[30]}]
#set_property -dict {LOC AV13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[31]}]
#set_property -dict {LOC BB18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[32]}]
#set_property -dict {LOC AY18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[33]}]
#set_property -dict {LOC BA19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[34]}]
#set_property -dict {LOC AW19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[35]}]
#set_property -dict {LOC BB17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[36]}]
#set_property -dict {LOC AW18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[37]}]
#set_property -dict {LOC BB19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[38]}]
#set_property -dict {LOC AY19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[39]}]
#set_property -dict {LOC AV17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[40]}]
#set_property -dict {LOC AT19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[41]}]
#set_property -dict {LOC AU18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[42]}]
#set_property -dict {LOC AU19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[43]}]
#set_property -dict {LOC AU17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[44]}]
#set_property -dict {LOC AR19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[45]}]
#set_property -dict {LOC AV18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[46]}]
#set_property -dict {LOC AR18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[47]}]
#set_property -dict {LOC AN16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[48]}]
#set_property -dict {LOC AM20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[49]}]
#set_property -dict {LOC AN18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[50]}]
#set_property -dict {LOC AN20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[51]}]
#set_property -dict {LOC AP16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[52]}]
#set_property -dict {LOC AL20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[53]}]
#set_property -dict {LOC AN17 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[54]}]
#set_property -dict {LOC AP20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[55]}]
#set_property -dict {LOC AR23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[56]}]
#set_property -dict {LOC AM23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[57]}]
#set_property -dict {LOC AR24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[58]}]
#set_property -dict {LOC AM24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[59]}]
#set_property -dict {LOC AR22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[60]}]
#set_property -dict {LOC AN22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[61]}]
#set_property -dict {LOC AP24 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[62]}]
#set_property -dict {LOC AM22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[63]}]
#set_property -dict {LOC AM14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[64]}]
#set_property -dict {LOC AR12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[65]}]
#set_property -dict {LOC AP15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[66]}]
#set_property -dict {LOC AR13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[67]}]
#set_property -dict {LOC AM15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[68]}]
#set_property -dict {LOC AT12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[69]}]
#set_property -dict {LOC AP14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[70]}]
#set_property -dict {LOC AP13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dq[71]}]
#set_property -dict {LOC AJ19 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[0]}]
#set_property -dict {LOC AJ18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[0]}]
#set_property -dict {LOC AH20 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[1]}]
#set_property -dict {LOC AJ20 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[1]}]
#set_property -dict {LOC AY12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[2]}]
#set_property -dict {LOC BA12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[2]}]
#set_property -dict {LOC AU12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[3]}]
#set_property -dict {LOC AV12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[3]}]
#set_property -dict {LOC AY17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[4]}]
#set_property -dict {LOC BA17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[4]}]
#set_property -dict {LOC AR17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[5]}]
#set_property -dict {LOC AT17 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[5]}]
#set_property -dict {LOC AM19 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[6]}]
#set_property -dict {LOC AM18 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[6]}]
#set_property -dict {LOC AN21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[7]}]
#set_property -dict {LOC AP21 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[7]}]
#set_property -dict {LOC AN13 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_t[8]}]
#set_property -dict {LOC AN12 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c0_dqs_c[8]}]
#set_property -dict {LOC AK18 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[0]}]
#set_property -dict {LOC AK22 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[1]}]
#set_property -dict {LOC AY16 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[2]}]
#set_property -dict {LOC AV15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[3]}]
#set_property -dict {LOC BA20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[4]}]
#set_property -dict {LOC AT20 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[5]}]
#set_property -dict {LOC AP19 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[6]}]
#set_property -dict {LOC AN23 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[7]}]
#set_property -dict {LOC AR14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c0_dm_dbi_n[8]}]

# DDR4 C1
# 5x K4A8G165WB-BCTD / MT40A512M16HA-075E
#set_property -dict {LOC AT30 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[0]}]
#set_property -dict {LOC AR29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[1]}]
#set_property -dict {LOC AP30 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[2]}]
#set_property -dict {LOC AR32 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[3]}]
#set_property -dict {LOC AU30 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[4]}]
#set_property -dict {LOC AP28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[5]}]
#set_property -dict {LOC AW31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[6]}]
#set_property -dict {LOC AM30 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[7]}]
#set_property -dict {LOC AR33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[8]}]
#set_property -dict {LOC AN28 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[9]}]
#set_property -dict {LOC AV31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[10]}]
#set_property -dict {LOC AP29 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[11]}]
#set_property -dict {LOC AR31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[12]}]
#set_property -dict {LOC AN30 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[13]}]
#set_property -dict {LOC AN32 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[14]}]
#set_property -dict {LOC AV32 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[15]}]
#set_property -dict {LOC BA34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_adr[16]}]
#set_property -dict {LOC AP34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[0]}]
#set_property -dict {LOC AT31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_ba[1]}]
#set_property -dict {LOC AP33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[0]}]
#set_property -dict {LOC AV33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_bg[1]}]
#set_property -dict {LOC AT34 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_t}]
#set_property -dict {LOC AU34 IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c1_ck_c}]
#set_property -dict {LOC AP31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cke}]
#set_property -dict {LOC AR34 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_cs_n}]
#set_property -dict {LOC AU33 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_act_n}]
#set_property -dict {LOC AN31 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_odt}]
#set_property -dict {LOC AW26 IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c1_par}]
#set_property -dict {LOC AV25 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_reset_n}]
#set_property -dict {LOC BA31 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_alert_n}]
#set_property -dict {LOC AT27 IOSTANDARD LVCMOS12       } [get_ports {ddr4_c1_ten}]

#set_property -dict {LOC AV41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[0]}]
#set_property -dict {LOC BB39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[1]}]
#set_property -dict {LOC AY42 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[2]}]
#set_property -dict {LOC BA40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[3]}]
#set_property -dict {LOC AV42 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[4]}]
#set_property -dict {LOC BA39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[5]}]
#set_property -dict {LOC AW41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[6]}]
#set_property -dict {LOC BB40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[7]}]
#set_property -dict {LOC AV38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[8]}]
#set_property -dict {LOC BA37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[9]}]
#set_property -dict {LOC AW38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[10]}]
#set_property -dict {LOC AV37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[11]}]
#set_property -dict {LOC AU37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[12]}]
#set_property -dict {LOC AW36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[13]}]
#set_property -dict {LOC BB38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[14]}]
#set_property -dict {LOC AV36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[15]}]
#set_property -dict {LOC BB34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[16]}]
#set_property -dict {LOC AY32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[17]}]
#set_property -dict {LOC BB33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[18]}]
#set_property -dict {LOC AY33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[19]}]
#set_property -dict {LOC BA36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[20]}]
#set_property -dict {LOC AW34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[21]}]
#set_property -dict {LOC BB37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[22]}]
#set_property -dict {LOC AW33 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[23]}]
#set_property -dict {LOC BA32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[24]}]
#set_property -dict {LOC BA29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[25]}]
#set_property -dict {LOC BB29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[26]}]
#set_property -dict {LOC AY29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[27]}]
#set_property -dict {LOC BB32 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[28]}]
#set_property -dict {LOC AW30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[29]}]
#set_property -dict {LOC BB28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[30]}]
#set_property -dict {LOC AW29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[31]}]
#set_property -dict {LOC AY28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[32]}]
#set_property -dict {LOC AV26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[33]}]
#set_property -dict {LOC BA26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[34]}]
#set_property -dict {LOC AV27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[35]}]
#set_property -dict {LOC AW28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[36]}]
#set_property -dict {LOC AV28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[37]}]
#set_property -dict {LOC AY26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[38]}]
#set_property -dict {LOC AY27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[39]}]
#set_property -dict {LOC AU27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[40]}]
#set_property -dict {LOC AP25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[41]}]
#set_property -dict {LOC AR27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[42]}]
#set_property -dict {LOC AP26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[43]}]
#set_property -dict {LOC AU28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[44]}]
#set_property -dict {LOC AN25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[45]}]
#set_property -dict {LOC AR26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[46]}]
#set_property -dict {LOC AR28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[47]}]
#set_property -dict {LOC AM29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[48]}]
#set_property -dict {LOC AK30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[49]}]
#set_property -dict {LOC AL29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[50]}]
#set_property -dict {LOC AH30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[51]}]
#set_property -dict {LOC AM28 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[52]}]
#set_property -dict {LOC AJ30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[53]}]
#set_property -dict {LOC AK29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[54]}]
#set_property -dict {LOC AJ29 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[55]}]
#set_property -dict {LOC AL25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[56]}]
#set_property -dict {LOC AH26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[57]}]
#set_property -dict {LOC AL27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[58]}]
#set_property -dict {LOC AJ25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[59]}]
#set_property -dict {LOC AM27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[60]}]
#set_property -dict {LOC AH27 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[61]}]
#set_property -dict {LOC AM25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[62]}]
#set_property -dict {LOC AJ26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[63]}]
#set_property -dict {LOC AK13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[64]}]
#set_property -dict {LOC AJ13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[65]}]
#set_property -dict {LOC AL14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[66]}]
#set_property -dict {LOC AH13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[67]}]
#set_property -dict {LOC AK14 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[68]}]
#set_property -dict {LOC AH12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[69]}]
#set_property -dict {LOC AL15 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[70]}]
#set_property -dict {LOC AK12 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dq[71]}]
#set_property -dict {LOC AY41 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[0]}]
#set_property -dict {LOC BA41 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[0]}]
#set_property -dict {LOC AY37 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[1]}]
#set_property -dict {LOC AY38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[1]}]
#set_property -dict {LOC BA35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[2]}]
#set_property -dict {LOC BB35 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[2]}]
#set_property -dict {LOC BA30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[3]}]
#set_property -dict {LOC BB30 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[3]}]
#set_property -dict {LOC BA27 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[4]}]
#set_property -dict {LOC BB27 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[4]}]
#set_property -dict {LOC AT29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[5]}]
#set_property -dict {LOC AU29 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[5]}]
#set_property -dict {LOC AJ28 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[6]}]
#set_property -dict {LOC AK28 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[6]}]
#set_property -dict {LOC AN26 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[7]}]
#set_property -dict {LOC AN27 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[7]}]
#set_property -dict {LOC AJ15 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_t[8]}]
#set_property -dict {LOC AJ14 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c1_dqs_c[8]}]
#set_property -dict {LOC AW39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[0]}]
#set_property -dict {LOC AU35 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[1]}]
#set_property -dict {LOC AY34 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[2]}]
#set_property -dict {LOC AY31 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[3]}]
#set_property -dict {LOC AU25 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[4]}]
#set_property -dict {LOC AT26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[5]}]
#set_property -dict {LOC AL30 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[6]}]
#set_property -dict {LOC AK26 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[7]}]
#set_property -dict {LOC AM13 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c1_dm_dbi_n[8]}]

# DDR4 C2
# 5x K4A8G165WB-BCTD / MT40A512M16HA-075E
#set_property -dict {LOC J30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[0]}]
#set_property -dict {LOC J29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[1]}]
#set_property -dict {LOC G32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[2]}]
#set_property -dict {LOC F31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[3]}]
#set_property -dict {LOC H29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[4]}]
#set_property -dict {LOC F28  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[5]}]
#set_property -dict {LOC J28  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[6]}]
#set_property -dict {LOC H32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[7]}]
#set_property -dict {LOC L29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[8]}]
#set_property -dict {LOC H31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[9]}]
#set_property -dict {LOC F30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[10]}]
#set_property -dict {LOC J32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[11]}]
#set_property -dict {LOC B28  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[12]}]
#set_property -dict {LOC K32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[13]}]
#set_property -dict {LOC F29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[14]}]
#set_property -dict {LOC D29  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[15]}]
#set_property -dict {LOC C32  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_adr[16]}]
#set_property -dict {LOC G31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[0]}]
#set_property -dict {LOC H30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_ba[1]}]
#set_property -dict {LOC E31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[0]}]
#set_property -dict {LOC D30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_bg[1]}]
#set_property -dict {LOC E32  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_t}]
#set_property -dict {LOC D32  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c2_ck_c}]
#set_property -dict {LOC E30  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cke}]
#set_property -dict {LOC C31  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_cs_n}]
#set_property -dict {LOC E28  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_act_n}]
#set_property -dict {LOC D28  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_odt}]
#set_property -dict {LOC J18  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c2_par}]
#set_property -dict {LOC L19  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_reset_n}]
#set_property -dict {LOC F19  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_alert_n}]
#set_property -dict {LOC E15  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c2_ten}]

#set_property -dict {LOC G38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[0]}]
#set_property -dict {LOC D42  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[1]}]
#set_property -dict {LOC F39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[2]}]
#set_property -dict {LOC G41  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[3]}]
#set_property -dict {LOC F38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[4]}]
#set_property -dict {LOC G42  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[5]}]
#set_property -dict {LOC G39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[6]}]
#set_property -dict {LOC E42  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[7]}]
#set_property -dict {LOC C39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[8]}]
#set_property -dict {LOC B41  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[9]}]
#set_property -dict {LOC B39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[10]}]
#set_property -dict {LOC C41  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[11]}]
#set_property -dict {LOC B38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[12]}]
#set_property -dict {LOC C42  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[13]}]
#set_property -dict {LOC A38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[14]}]
#set_property -dict {LOC C40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[15]}]
#set_property -dict {LOC AT36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[16]}]
#set_property -dict {LOC AR38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[17]}]
#set_property -dict {LOC AP36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[18]}]
#set_property -dict {LOC AR37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[19]}]
#set_property -dict {LOC AR36 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[20]}]
#set_property -dict {LOC AP39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[21]}]
#set_property -dict {LOC AP37 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[22]}]
#set_property -dict {LOC AP40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[23]}]
#set_property -dict {LOC N24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[24]}]
#set_property -dict {LOC M26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[25]}]
#set_property -dict {LOC N26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[26]}]
#set_property -dict {LOC L25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[27]}]
#set_property -dict {LOC N25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[28]}]
#set_property -dict {LOC L26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[29]}]
#set_property -dict {LOC M23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[30]}]
#set_property -dict {LOC L23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[31]}]
#set_property -dict {LOC AP41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[32]}]
#set_property -dict {LOC AT41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[33]}]
#set_property -dict {LOC AP42 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[34]}]
#set_property -dict {LOC AU40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[35]}]
#set_property -dict {LOC AR41 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[36]}]
#set_property -dict {LOC AV40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[37]}]
#set_property -dict {LOC AR42 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[38]}]
#set_property -dict {LOC AT40 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[39]}]
#set_property -dict {LOC K28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[40]}]
#set_property -dict {LOC K31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[41]}]
#set_property -dict {LOC P28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[42]}]
#set_property -dict {LOC N28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[43]}]
#set_property -dict {LOC M27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[44]}]
#set_property -dict {LOC L31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[45]}]
#set_property -dict {LOC N27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[46]}]
#set_property -dict {LOC L28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[47]}]
#set_property -dict {LOC D34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[48]}]
#set_property -dict {LOC A34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[49]}]
#set_property -dict {LOC C34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[50]}]
#set_property -dict {LOC A35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[51]}]
#set_property -dict {LOC C36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[52]}]
#set_property -dict {LOC A36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[53]}]
#set_property -dict {LOC C37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[54]}]
#set_property -dict {LOC B34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[55]}]
#set_property -dict {LOC B29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[56]}]
#set_property -dict {LOC B33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[57]}]
#set_property -dict {LOC A29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[58]}]
#set_property -dict {LOC B32  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[59]}]
#set_property -dict {LOC A28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[60]}]
#set_property -dict {LOC A33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[61]}]
#set_property -dict {LOC C29  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[62]}]
#set_property -dict {LOC B31  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[63]}]
#set_property -dict {LOC E37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[64]}]
#set_property -dict {LOC E36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[65]}]
#set_property -dict {LOC F36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[66]}]
#set_property -dict {LOC D37  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[67]}]
#set_property -dict {LOC E38  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[68]}]
#set_property -dict {LOC F33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[69]}]
#set_property -dict {LOC G36  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[70]}]
#set_property -dict {LOC E33  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dq[71]}]
#set_property -dict {LOC F41  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[0]}]
#set_property -dict {LOC E41  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[0]}]
#set_property -dict {LOC A39  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[1]}]
#set_property -dict {LOC A40  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[1]}]
#set_property -dict {LOC AT37 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[2]}]
#set_property -dict {LOC AU38 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[2]}]
#set_property -dict {LOC M24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[3]}]
#set_property -dict {LOC L24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[3]}]
#set_property -dict {LOC AT42 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[4]}]
#set_property -dict {LOC AU42 IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[4]}]
#set_property -dict {LOC L30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[5]}]
#set_property -dict {LOC K30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[5]}]
#set_property -dict {LOC B36  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[6]}]
#set_property -dict {LOC B37  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[6]}]
#set_property -dict {LOC A30  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[7]}]
#set_property -dict {LOC A31  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[7]}]
#set_property -dict {LOC F35  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_t[8]}]
#set_property -dict {LOC E35  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c2_dqs_c[8]}]
#set_property -dict {LOC G40  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[0]}]
#set_property -dict {LOC D39  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[1]}]
#set_property -dict {LOC AP38 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[2]}]
#set_property -dict {LOC P23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[3]}]
#set_property -dict {LOC AT39 IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[4]}]
#set_property -dict {LOC M28  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[5]}]
#set_property -dict {LOC D35  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[6]}]
#set_property -dict {LOC C30  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[7]}]
#set_property -dict {LOC G34  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c2_dm_dbi_n[8]}]

# DDR4 C3
# 5x K4A8G165WB-BCTD / MT40A512M16HA-075E
#set_property -dict {LOC F23  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[0]}]
#set_property -dict {LOC G23  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[1]}]
#set_property -dict {LOC H24  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[2]}]
#set_property -dict {LOC F25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[3]}]
#set_property -dict {LOC F26  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[4]}]
#set_property -dict {LOC F24  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[5]}]
#set_property -dict {LOC K26  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[6]}]
#set_property -dict {LOC G27  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[7]}]
#set_property -dict {LOC J27  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[8]}]
#set_property -dict {LOC G24  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[9]}]
#set_property -dict {LOC E25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[10]}]
#set_property -dict {LOC H27  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[11]}]
#set_property -dict {LOC E23  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[12]}]
#set_property -dict {LOC G26  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[13]}]
#set_property -dict {LOC J23  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[14]}]
#set_property -dict {LOC D23  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[15]}]
#set_property -dict {LOC B27  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_adr[16]}]
#set_property -dict {LOC J25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_ba[0]}]
#set_property -dict {LOC K25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_ba[1]}]
#set_property -dict {LOC J24  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_bg[0]}]
#set_property -dict {LOC D25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_bg[1]}]
#set_property -dict {LOC E27  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_t}]
#set_property -dict {LOC D27  IOSTANDARD DIFF_SSTL12_DCI} [get_ports {ddr4_c3_ck_c}]
#set_property -dict {LOC E26  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cke}]
#set_property -dict {LOC H25  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_cs_n}]
#set_property -dict {LOC D24  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_act_n}]
#set_property -dict {LOC B22  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_odt}]
#set_property -dict {LOC A14  IOSTANDARD SSTL12_DCI     } [get_ports {ddr4_c3_par}]
#set_property -dict {LOC M16  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c3_reset_n}]
#set_property -dict {LOC F20  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c3_alert_n}]
#set_property -dict {LOC J17  IOSTANDARD LVCMOS12       } [get_ports {ddr4_c3_ten}]

#set_property -dict {LOC E18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[0]}]
#set_property -dict {LOC G17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[1]}]
#set_property -dict {LOC F16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[2]}]
#set_property -dict {LOC G16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[3]}]
#set_property -dict {LOC E16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[4]}]
#set_property -dict {LOC H17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[5]}]
#set_property -dict {LOC E17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[6]}]
#set_property -dict {LOC F18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[7]}]
#set_property -dict {LOC N12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[8]}]
#set_property -dict {LOC P15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[9]}]
#set_property -dict {LOC M13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[10]}]
#set_property -dict {LOC P12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[11]}]
#set_property -dict {LOC M12  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[12]}]
#set_property -dict {LOC N15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[13]}]
#set_property -dict {LOC M14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[14]}]
#set_property -dict {LOC P13  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[15]}]
#set_property -dict {LOC C17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[16]}]
#set_property -dict {LOC C15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[17]}]
#set_property -dict {LOC A16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[18]}]
#set_property -dict {LOC A15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[19]}]
#set_property -dict {LOC B17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[20]}]
#set_property -dict {LOC D15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[21]}]
#set_property -dict {LOC D18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[22]}]
#set_property -dict {LOC D17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[23]}]
#set_property -dict {LOC J14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[24]}]
#set_property -dict {LOC L16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[25]}]
#set_property -dict {LOC H15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[26]}]
#set_property -dict {LOC H14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[27]}]
#set_property -dict {LOC J15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[28]}]
#set_property -dict {LOC K16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[29]}]
#set_property -dict {LOC K15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[30]}]
#set_property -dict {LOC H16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[31]}]
#set_property -dict {LOC K21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[32]}]
#set_property -dict {LOC H19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[33]}]
#set_property -dict {LOC J20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[34]}]
#set_property -dict {LOC J19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[35]}]
#set_property -dict {LOC K20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[36]}]
#set_property -dict {LOC K18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[37]}]
#set_property -dict {LOC H20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[38]}]
#set_property -dict {LOC L18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[39]}]
#set_property -dict {LOC D20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[40]}]
#set_property -dict {LOC B19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[41]}]
#set_property -dict {LOC A21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[42]}]
#set_property -dict {LOC A19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[43]}]
#set_property -dict {LOC B21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[44]}]
#set_property -dict {LOC D19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[45]}]
#set_property -dict {LOC C21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[46]}]
#set_property -dict {LOC A20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[47]}]
#set_property -dict {LOC N19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[48]}]
#set_property -dict {LOC N22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[49]}]
#set_property -dict {LOC P20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[50]}]
#set_property -dict {LOC N21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[51]}]
#set_property -dict {LOC P19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[52]}]
#set_property -dict {LOC N20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[53]}]
#set_property -dict {LOC P18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[54]}]
#set_property -dict {LOC P22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[55]}]
#set_property -dict {LOC C25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[56]}]
#set_property -dict {LOC A23  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[57]}]
#set_property -dict {LOC B26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[58]}]
#set_property -dict {LOC A26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[59]}]
#set_property -dict {LOC C26  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[60]}]
#set_property -dict {LOC C24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[61]}]
#set_property -dict {LOC A24  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[62]}]
#set_property -dict {LOC A25  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[63]}]
#set_property -dict {LOC H22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[64]}]
#set_property -dict {LOC E21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[65]}]
#set_property -dict {LOC G21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[66]}]
#set_property -dict {LOC E22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[67]}]
#set_property -dict {LOC H21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[68]}]
#set_property -dict {LOC E20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[69]}]
#set_property -dict {LOC G22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[70]}]
#set_property -dict {LOC D22  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dq[71]}]
#set_property -dict {LOC G14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[0]}]
#set_property -dict {LOC F14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[0]}]
#set_property -dict {LOC P14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[1]}]
#set_property -dict {LOC N14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[1]}]
#set_property -dict {LOC C16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[2]}]
#set_property -dict {LOC B16  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[2]}]
#set_property -dict {LOC L15  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[3]}]
#set_property -dict {LOC L14  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[3]}]
#set_property -dict {LOC K22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[4]}]
#set_property -dict {LOC J22  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[4]}]
#set_property -dict {LOC C20  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[5]}]
#set_property -dict {LOC C19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[5]}]
#set_property -dict {LOC M21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[6]}]
#set_property -dict {LOC L21  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[6]}]
#set_property -dict {LOC B23  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[7]}]
#set_property -dict {LOC B24  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[7]}]
#set_property -dict {LOC G19  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_t[8]}]
#set_property -dict {LOC G18  IOSTANDARD DIFF_POD12_DCI } [get_ports {ddr4_c3_dqs_c[8]}]
#set_property -dict {LOC F15  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[0]}]
#set_property -dict {LOC N16  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[1]}]
#set_property -dict {LOC B14  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[2]}]
#set_property -dict {LOC K17  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[3]}]
#set_property -dict {LOC L20  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[4]}]
#set_property -dict {LOC B18  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[5]}]
#set_property -dict {LOC M19  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[6]}]
#set_property -dict {LOC C27  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[7]}]
#set_property -dict {LOC F21  IOSTANDARD POD12_DCI      } [get_ports {ddr4_c3_dm_dbi_n[8]}]
