# XDC constraints for the AMD KR260 board
# part: XCK26-SFVC784-2LV-C/I

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
#
# use the 25 MHz clock outputs to the PL from U91
# and feed that into a PLL to convert it to 125 MHz
set_property -dict {LOC C3 IOSTANDARD LVCMOS18} [get_ports clk_25mhz_ref] ;# HPA_CLK0P_CLK, HPA_CLK0_P, via U91, SOM240_1 A6
create_clock -period 40.000 -name clk_25mhz [get_ports clk_25mhz_ref]

# LEDs
set_property -dict {LOC F8 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}]  ;# HPA14P, HPA14_P, som240_1_d13, VCCO - som240_1_d1
set_property -dict {LOC E8 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}]  ;# HPA14N, HPA14_N, som240_1_d14, VCCO - som240_1_d1

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# SFP+ Interface
set_property -dict {LOC T2 } [get_ports sfp0_rx_p] ;# GTH_DP2_C2M_P, som240_2_b1
set_property -dict {LOC T1 } [get_ports sfp0_rx_n] ;# GTH_DP2_C2M_N, som240_2_b2
set_property -dict {LOC R4 } [get_ports sfp0_tx_p] ;# GTH_DP2_M2C_P, som240_2_b5
set_property -dict {LOC R3 } [get_ports sfp0_tx_n] ;# GTH_DP2_M2C_N, som240_2_b6

set_property -dict {LOC Y6 } [get_ports sfp_mgt_refclk_0_p] ;# GTH_REFCLK0_C2M_P via U90, SOM240_2 C3
set_property -dict {LOC Y5 } [get_ports sfp_mgt_refclk_0_n] ;# GTH_REFCLK0_C2M_N via U90, SOM240_2 C4
set_property -dict {LOC Y10 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8 } [get_ports sfp0_tx_disable_b]  ;# HDB19, SOM240_2_A47

# 156.25 MHz MGT reference clock
create_clock -period 6.400 -name sfp_mgt_refclk_0 [get_ports sfp_mgt_refclk_0_p]

set_false_path -to [get_ports {sfp0_tx_disable_b}]
set_output_delay 0 [get_ports {sfp0_tx_disable_b}]
