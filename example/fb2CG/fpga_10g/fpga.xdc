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
set_property -dict {LOC Y39 } [get_ports qsfp_0_rx_0_p] ;# MGTYRXP0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y40 } [get_ports qsfp_0_rx_0_n] ;# MGTYRXN0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y34 } [get_ports qsfp_0_tx_0_p] ;# MGTYTXP0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC Y35 } [get_ports qsfp_0_tx_0_n] ;# MGTYTXN0_130 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W41 } [get_ports qsfp_0_rx_1_p] ;# MGTYRXP1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W42 } [get_ports qsfp_0_rx_1_n] ;# MGTYRXN1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W36 } [get_ports qsfp_0_tx_1_p] ;# MGTYTXP1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC W37 } [get_ports qsfp_0_tx_1_n] ;# MGTYTXN1_130 GTYE4_CHANNEL_X0Y13 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V39 } [get_ports qsfp_0_rx_2_p] ;# MGTYRXP2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V40 } [get_ports qsfp_0_rx_2_n] ;# MGTYRXN2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V34 } [get_ports qsfp_0_tx_2_p] ;# MGTYTXP2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC V35 } [get_ports qsfp_0_tx_2_n] ;# MGTYTXN2_130 GTYE4_CHANNEL_X0Y14 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U41 } [get_ports qsfp_0_rx_3_p] ;# MGTYRXP3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U42 } [get_ports qsfp_0_rx_3_n] ;# MGTYRXN3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U36 } [get_ports qsfp_0_tx_3_p] ;# MGTYTXP3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC U37 } [get_ports qsfp_0_tx_3_n] ;# MGTYTXN3_130 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
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

set_property -dict {LOC M39 } [get_ports qsfp_1_rx_0_p] ;# MGTYRXP0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M40 } [get_ports qsfp_1_rx_0_n] ;# MGTYRXN0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M34 } [get_ports qsfp_1_tx_0_p] ;# MGTYTXP0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC M35 } [get_ports qsfp_1_tx_0_n] ;# MGTYTXN0_132 GTYE4_CHANNEL_X0Y20 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L41 } [get_ports qsfp_1_rx_1_p] ;# MGTYRXP1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L42 } [get_ports qsfp_1_rx_1_n] ;# MGTYRXN1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L36 } [get_ports qsfp_1_tx_1_p] ;# MGTYTXP1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC L37 } [get_ports qsfp_1_tx_1_n] ;# MGTYTXN1_132 GTYE4_CHANNEL_X0Y21 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K39 } [get_ports qsfp_1_rx_2_p] ;# MGTYRXP2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K40 } [get_ports qsfp_1_rx_2_n] ;# MGTYRXN2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K34 } [get_ports qsfp_1_tx_2_p] ;# MGTYTXP2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC K35 } [get_ports qsfp_1_tx_2_n] ;# MGTYTXN2_132 GTYE4_CHANNEL_X0Y22 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J41 } [get_ports qsfp_1_rx_3_p] ;# MGTYRXP3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J42 } [get_ports qsfp_1_rx_3_n] ;# MGTYRXN3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J36 } [get_ports qsfp_1_tx_3_p] ;# MGTYTXP3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
set_property -dict {LOC J37 } [get_ports qsfp_1_tx_3_n] ;# MGTYTXN3_132 GTYE4_CHANNEL_X0Y23 / GTYE4_COMMON_X0Y5
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
