# XDC constraints for the Digilent Nexys A7-100T board
# part: xc7a100tcsg324-1

# General configuration
set_property CFGBVS VCCO                               [current_design]
set_property CONFIG_VOLTAGE 3.3                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50            [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4           [current_design]

# 100 MHz clock
set_property -dict {LOC E3  IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk [get_ports clk]

# Reset button
set_property -dict {LOC C12 IOSTANDARD LVCMOS33} [get_ports reset_n]
set_false_path -from [get_ports reset_n]
set_input_delay 0 [get_ports reset_n]

# LEDs
set_property -dict {LOC H17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC K15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC J13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC N14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC R18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC V17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC U17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC U16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {led[7]}]
set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# Ethernet: LAN8720A RMII
set_property -dict {LOC D5  IOSTANDARD LVCMOS33 SLEW FAST} [get_ports phy_ref_clk]
set_property -dict {LOC D9  IOSTANDARD LVCMOS33} [get_ports phy_crs_dv]
set_property -dict {LOC C11 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[0]}]
set_property -dict {LOC D10 IOSTANDARD LVCMOS33} [get_ports {phy_rxd[1]}]
set_property -dict {LOC C10 IOSTANDARD LVCMOS33} [get_ports phy_rx_er]
set_property -dict {LOC A10 IOSTANDARD LVCMOS33} [get_ports {phy_txd[0]}]
set_property -dict {LOC A8  IOSTANDARD LVCMOS33} [get_ports {phy_txd[1]}]
set_property -dict {LOC B9  IOSTANDARD LVCMOS33} [get_ports phy_tx_en]
set_property -dict {LOC B3  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 16} [get_ports phy_reset_n]

# RMII is source-synchronous to the FPGA-forwarded 50 MHz REF_CLK. rmii_clk is an
# independent create_clock on the forwarded pin (not the MMCM-generated one) and
# the MAC<->PHY paths are bounded by data-path delay only, so STA does not charge
# the forward-path skew against setup. Numbers are from the RMII specification (rev 1.2).
set eth_clk [get_clocks -of_objects [get_pins clk_50_bufg_inst/O]]
create_clock -period 20.000 -name rmii_clk [get_ports phy_ref_clk]
set_max_delay -datapath_only 18.000 -from $eth_clk              -to [get_clocks rmii_clk]
set_max_delay -datapath_only 18.000 -from [get_clocks rmii_clk] -to $eth_clk

set_output_delay -clock rmii_clk -max  4.000 [get_ports {phy_txd[*] phy_tx_en}]
set_output_delay -clock rmii_clk -min -2.000 [get_ports {phy_txd[*] phy_tx_en}]
set_input_delay  -clock rmii_clk -max 14.000 [get_ports {phy_rxd[*] phy_crs_dv phy_rx_er}]
set_input_delay  -clock rmii_clk -min  2.000 [get_ports {phy_rxd[*] phy_crs_dv phy_rx_er}]
