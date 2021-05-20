

derive_pll_clocks
derive_clock_uncertainty

create_clock -period 20.000 -name {clk_sys_50m} [ get_ports {clk_sys_50m_p} ]
create_clock -period 10.000 -name {clk_sys_100m} [ get_ports {clk_sys_100m_p} ]
create_clock -period 10.000 -name {clk_core_bak} [ get_ports {clk_core_bak_p} ]
create_clock -period 10.000 -name {clk_uib0} [ get_ports {clk_uib0_p} ]
create_clock -period 10.000 -name {clk_uib1} [ get_ports {clk_uib1_p} ]
create_clock -period 10.000 -name {clk_esram0} [ get_ports {clk_esram0_p} ]
create_clock -period 10.000 -name {clk_esram1} [ get_ports {clk_esram1_p} ]
create_clock -period 7.500 -name {clk_ddr4_comp} [ get_ports {clk_ddr4_comp_p} ]
create_clock -period 7.500 -name {clk_ddr4_dimm} [ get_ports {clk_ddr4_dimm_p} ]

create_clock -period 10.000 -name {refclk_pcie_ep} [ get_ports {refclk_pcie_ep_p} ]
create_clock -period 10.000 -name {refclk_pcie_ep_edge} [ get_ports {refclk_pcie_ep_edge_p} ]
create_clock -period 10.000 -name {refclk_pcie_ep1} [ get_ports {refclk_pcie_ep1_p} ]
create_clock -period 10.000 -name {refclk_pcie_rp} [ get_ports {refclk_pcie_rp_p} ]

create_clock -period 1.551 -name {refclk_qsfp0} [ get_ports {refclk_qsfp0_p} ]
create_clock -period 1.551 -name {refclk_qsfp1} [ get_ports {refclk_qsfp1_p} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_sys_50m} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_sys_100m} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_core_bak} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_uib0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_uib1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_esram0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_esram1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_ddr4_comp} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_ddr4_dimm} ]

set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep_edge} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep1} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_rp} ]

set_clock_groups -asynchronous -group [ get_clocks {refclk_qsfp0} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_qsfp1} ]

# JTAG Signal Constraints
create_clock -name {altera_reserved_tck} -period 40.800 -waveform { 0.000 20.400 } [get_ports { altera_reserved_tck }]
set_input_delay -clock altera_reserved_tck 8 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck 8 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -max 5 [get_ports altera_reserved_tdo]
set_false_path -from [get_keepers {altera_reserved_ntrst}]
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

set_false_path -from [get_ports cpu_resetn] -to *
set_false_path -from * -to [get_ports {user_led[*]}]

source ../lib/eth/syn/quartus_pro/eth_mac_fifo.sdc
source ../lib/eth/lib/axis/syn/quartus_pro/sync_reset.sdc
source ../lib/eth/lib/axis/syn/quartus_pro/axis_async_fifo.sdc

# clocking infrastructure
constrain_sync_reset_inst "sync_reset_100mhz_inst"

# PHY clocks
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|rx_clkout|ch0} ]

# PHY resets
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_rx_rst_reset_sync_inst"

# 10G MAC
constrain_eth_mac_fifo_inst "core_inst|eth_mac_10g_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_10g_fifo_inst|rx_fifo|fifo_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_10g_fifo_inst|tx_fifo|fifo_inst"
