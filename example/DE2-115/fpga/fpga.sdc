
create_clock -period 20.00 -name {CLOCK_50}   [get_ports {CLOCK_50}]
create_clock -period 20.00 -name {CLOCK2_50}  [get_ports {CLOCK2_50}]
create_clock -period 20.00 -name {CLOCK3_50}  [get_ports {CLOCK3_50}]
create_clock -period 40.00 -name {ENETCLK_25} [get_ports {ENETCLK_25}]

set_clock_groups -asynchronous -group [get_clocks {CLOCK_50}]
set_clock_groups -asynchronous -group [get_clocks {CLOCK2_50}]
set_clock_groups -asynchronous -group [get_clocks {CLOCK3_50}]
set_clock_groups -asynchronous -group [get_clocks {ENETCLK_25}]

create_clock -period "40.000 ns" -name {altera_reserved_tck} {altera_reserved_tck}
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

#JTAG Signal Constraints
#constrain the TDI TMS and TDO ports  -- (modified from timequest SDC cookbook)
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -fall -max 5 [get_ports altera_reserved_tdo]

# Ethernet MDIO interface
set_output_delay  -clock [get_clocks CLOCK_50] 2   [get_ports {enet0_mdc}]
set_input_delay   -clock [get_clocks CLOCK_50] 2   [get_ports {enet0_mdio}]
set_output_delay  -clock [get_clocks CLOCK_50] 2   [get_ports {enet0_mdio}]

set_output_delay  -clock [get_clocks CLOCK_50] 2   [get_ports {enet1_mdc}]
set_input_delay   -clock [get_clocks CLOCK_50] 2   [get_ports {enet1_mdio}]
set_output_delay  -clock [get_clocks CLOCK_50] 2   [get_ports {enet1_mdio}]

set_false_path -from [get_ports {KEY[*]}] -to *
set_false_path -from [get_ports {SW[*]}] -to *
set_false_path -from * -to [get_ports {LEDG[*]}]
set_false_path -from * -to [get_ports {LEDR[*]}]
set_false_path -from * -to [get_ports {HEX0[*]}]
set_false_path -from * -to [get_ports {HEX1[*]}]
set_false_path -from * -to [get_ports {HEX2[*]}]
set_false_path -from * -to [get_ports {HEX3[*]}]
set_false_path -from * -to [get_ports {HEX4[*]}]
set_false_path -from * -to [get_ports {HEX5[*]}]
set_false_path -from * -to [get_ports {HEX6[*]}]
set_false_path -from * -to [get_ports {HEX7[*]}]

set_false_path -from [get_ports ENET0_INT_N] -to *
set_false_path -from * -to [get_ports ENET0_RST_N]

set_false_path -from [get_ports ENET1_INT_N] -to *
set_false_path -from * -to [get_ports ENET1_RST_N]


derive_pll_clocks
derive_clock_uncertainty


source ../lib/eth/syn/quartus/eth_mac_1g_rgmii.sdc
source ../lib/eth/syn/quartus/rgmii_phy_if.sdc
source ../lib/eth/syn/quartus/rgmii_io.sdc
source ../lib/eth/lib/axis/syn/quartus/sync_reset.sdc
source ../lib/eth/lib/axis/syn/quartus/axis_async_fifo.sdc

# clocking infrastructure
constrain_sync_reset_inst "sync_reset_inst"

# ENET0 RGMII MAC
constrain_eth_mac_1g_rgmii_inst "core_inst|eth_mac_inst|eth_mac_1g_rgmii_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_inst|rx_fifo|fifo_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_inst|tx_fifo|fifo_inst"

# ENET0 RGMII interface
constrain_rgmii_input_pins "enet0" "ENET0_RX_CLK" "ENET0_RX_DV ENET0_RX_D*"
constrain_rgmii_output_pins "enet0" "altpll_component|auto_generated|pll1|clk[0]" "ENET0_GTX_CLK" "ENET0_TX_EN ENET0_TX_D*"

# ENET1 RGMII interface
constrain_rgmii_input_pins "enet1" "ENET1_RX_CLK" "ENET1_RX_DV ENET1_RX_D*"
constrain_rgmii_output_pins "enet1" "altpll_component|auto_generated|pll1|clk[0]" "ENET1_GTX_CLK" "ENET1_TX_EN ENET1_TX_D*"

