
create_clock -period 20.00  -name {c10_clk50m}    [get_ports {c10_clk50m}]
create_clock -period 10.00  -name {c10_clk_adj}   [get_ports {c10_clk_adj}]
create_clock -period 8.000  -name {c10_usb_clk}   [get_ports {c10_usb_clk}]
create_clock -period 8.000  -name {enet_clk_125m} [get_ports {enet_clk_125m}]
create_clock -period 20.000 -name {hbus_clk_50m}  [get_ports {hbus_clk_50m}]

set_clock_groups -asynchronous -group [get_clocks {c10_clk50m}]
set_clock_groups -asynchronous -group [get_clocks {c10_clk_adj}]
set_clock_groups -asynchronous -group [get_clocks {c10_usb_clk}]
set_clock_groups -asynchronous -group [get_clocks {enet_clk_125m}]
set_clock_groups -asynchronous -group [get_clocks {hbus_clk_50m}]

create_clock -period "40.000 ns" -name {altera_reserved_tck} {altera_reserved_tck}
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

#JTAG Signal Constraints
#constrain the TDI TMS and TDO ports  -- (modified from timequest SDC cookbook)
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -fall -max 5 [get_ports altera_reserved_tdo]

# c10_resetn
set_input_delay   -clock [get_clocks c10_clk50m] 10  [get_ports {c10_resetn}]

# Ethernet MDIO interface
set_output_delay  -clock [get_clocks c10_clk50m] 2   [get_ports {enet_mdc}]
set_input_delay   -clock [get_clocks c10_clk50m] 2   [get_ports {enet_mdio}]
set_output_delay  -clock [get_clocks c10_clk50m] 2   [get_ports {enet_mdio}]

set_false_path -from [get_ports c10_resetn] -to *
set_false_path -from [get_ports {user_pb[*]}] -to *
set_false_path -from [get_ports {user_dip[*]}] -to *
set_false_path -from * -to [get_ports {user_led[*]}]

set_false_path -from [get_ports enet_intn] -to *
set_false_path -from * -to [get_ports enet_resetn]


derive_pll_clocks
derive_clock_uncertainty


source ../lib/eth/syn/quartus/eth_mac_1g_rgmii.sdc
source ../lib/eth/syn/quartus/rgmii_phy_if.sdc
source ../lib/eth/syn/quartus/rgmii_io.sdc
source ../lib/eth/lib/axis/syn/quartus/sync_reset.sdc
source ../lib/eth/lib/axis/syn/quartus/axis_async_fifo.sdc

# clocking infrastructure
constrain_sync_reset_inst "sync_reset_inst"

# RGMII MAC
constrain_eth_mac_1g_rgmii_inst "core_inst|eth_mac_inst|eth_mac_1g_rgmii_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_inst|rx_fifo|fifo_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_inst|tx_fifo|fifo_inst"

# RGMII interface
constrain_rgmii_input_pins "enet" "enet_rx_clk" "enet_rx_dv enet_rx_d*"
constrain_rgmii_output_pins "enet" "altpll_component|auto_generated|pll1|clk[0]" "enet_tx_clk" "enet_tx_en enet_tx_d*"

