# XDC constraints for the AMD KR260 board
# part: XCK26-SFVC784-2LV-C/I

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
# 125 MHz
#
# The 125 MHz clock signal is a standard reference clock frequency used 
# in many Ethernet PHYs. This clock signal is used as a timing reference 
# for the PHY's internal circuitry, including the serializer/deserializer 
# (SERDES) components that convert digital data to analog signals for 
# transmission over the physical medium and vice versa. The SERDES components 
# require a precise clock signal to ensure accurate timing of the transmitted 
# and received data.
#
# NOTE: the GTH transceivers need a free-running clock.
#

# # Option 1: use the 125 MHz clock from the U87 chip
# # GTR pins, connected to the PS, cannot use directly
# set_property -dict {LOC C47  IOSTANDARD LVDS_25} [get_ports clk_125mhz_p]
# set_property -dict {LOC C48  IOSTANDARD LVDS_25} [get_ports clk_125mhz_n]
# create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# # Option 2: use the 156.25 MHz MGT reference clock
# # GTH pins, connected to the PL, however:
# # 
# # The MGT (Multi-Gigabit Transceiver) reference clock inputs and GTH (Gigabit Transceiver) 
# # pins are designed for different types of clock signals, and connecting them together can 
# # result in damage to the circuitry or a non-functioning design.
# # 
# # Connecting the MGT reference clock inputs to GTH pins can result in damage to the 
# # circuitry or a non-functioning design because the MGT reference clock signal has different 
# # voltage and timing requirements than the GTH system clock. The MGT reference clock signal 
# # requires a dedicated input buffer, such as the IBUFDS_GTE2 or IBUFDS_GTH, to properly 
# # receive the clock signal and perform the necessary signal conditioning before it can be 
# # used by the MGT transceiver. The GTH pins, on the other hand, require a specific input 
# # buffer, such as the IBUFDS_GTE2 or IBUFDS_GTH, to properly receive the system clock signal 
# # and perform the necessary signal conditioning before it can be used for data transfer.
# # 
# set_property -dict {LOC Y6 IOSTANDARD LVDS_25} [get_ports clk_125mhz_p] ;# GTH_REFCLK0_C2M_P via U90, SOM240_2 C3
# set_property -dict {LOC Y5 IOSTANDARD LVDS_25} [get_ports clk_125mhz_n] ;# GTH_REFCLK0_C2M_N via U90, SOM240_2 C4
# create_clock -period 6.400 -name clk_125mhz [get_ports clk_125mhz_p]

# Option 3: use the 25 MHz clock outputs to the PL from U91
# and feed that into a PLL to convert it to 125 MHz
set_property -dict {LOC C3 IOSTANDARD LVCMOS18} [get_ports clk_25mhz_ref] ;# HPA_CLK0P_CLK, HPA_CLK0_P, via U91, SOM240_1 A6
create_clock -period 40.000 -name clk_25mhz [get_ports clk_25mhz_ref]

# LEDs
set_property -dict {LOC F8 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}]  ;# HPA14P, HPA14_P, som240_1_d13, VCCO - som240_1_d1
set_property -dict {LOC E8 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}]  ;# HPA14N, HPA14_N, som240_1_d14, VCCO - som240_1_d1

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# # Reset button
# # PS_POR_L, note schematics hints C15 is PS_POR_B (Power-on Reset) signal
# # whereas the "Kria SOM Carrier Card Design Guide" says C15 is PS_POR_L.
# #
# # Signal is pulled up to 1.8V through a 4.70 KΩ resistor on the SOM, LVCMOS18
# #
# # NOTE: Connected to the PS, not accessible to the PL
# # 
# # see https://docs.xilinx.com/r/en-US/ug1091-carrier-card-design/Sideband-Signals
# set_property -dict {LOC P16 IOSTANDARD LVCMOS18} [get_ports reset]  ;# som240_1_c15, PS_POR_B, PS_POR_L
#
# set_false_path -from [get_ports {reset}]
# set_input_delay 0 [get_ports {reset}]

# No push buttons in KR260
# FWEN is used for other features
#
# set_property -dict {LOC AG15 IOSTANDARD LVCMOS33} [get_ports btnu]
# set_property -dict {LOC AF15 IOSTANDARD LVCMOS33} [get_ports btnl]
# set_property -dict {LOC AE15 IOSTANDARD LVCMOS33} [get_ports btnd]
# set_property -dict {LOC AE14 IOSTANDARD LVCMOS33} [get_ports btnr]
# set_property -dict {LOC AG13 IOSTANDARD LVCMOS33} [get_ports btnc]
#
# set_false_path -from [get_ports {btnu btnl btnd btnr btnc}]
# set_input_delay 0 [get_ports {btnu btnl btnd btnr btnc}]

# No DIP switches in KR260
#
# set_property -dict {LOC AN14 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
#
# set_false_path -from [get_ports {sw[*]}]
# set_input_delay 0 [get_ports {sw[*]}]

# No PL-Side UART available from default banks
#
# set_property -dict {LOC F13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports uart_txd]
# set_property -dict {LOC E13  IOSTANDARD LVCMOS33} [get_ports uart_rxd]
# set_property -dict {LOC D12  IOSTANDARD LVCMOS33} [get_ports uart_rts]
# set_property -dict {LOC E12  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports uart_cts]
#
# set_false_path -to [get_ports {uart_txd uart_cts}]
# set_output_delay 0 [get_ports {uart_txd uart_cts}]
# set_false_path -from [get_ports {uart_rxd uart_rts}]
# set_input_delay 0 [get_ports {uart_rxd uart_rts}]

# No PL-I2C interfaces
#set_property -dict {LOC J10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c0_scl]
#set_property -dict {LOC J11  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c0_sda]
#set_property -dict {LOC K20  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c1_scl]
#set_property -dict {LOC L20  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c1_sda]

#set_false_path -to [get_ports {i2c1_sda i2c1_scl}]
#set_output_delay 0 [get_ports {i2c1_sda i2c1_scl}]
#set_false_path -from [get_ports {i2c1_sda i2c1_scl}]
#set_input_delay 0 [get_ports {i2c1_sda i2c1_scl}]

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
