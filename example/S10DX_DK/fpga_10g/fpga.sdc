# Timing constraints for the Intel Stratix 10 DX FPGA development board

set_time_format -unit ns -decimal_places 3

# Clock constraints
create_clock -period 7.519 -name {clk_133m_ddr4_1} [ get_ports {clk_133m_ddr4_1_p} ]
create_clock -period 7.519 -name {clk_133m_ddr4_0} [ get_ports {clk_133m_ddr4_0_p} ]
create_clock -period 7.519 -name {clk_133m_dimm_1} [ get_ports {clk_133m_dimm_1_p} ]
create_clock -period 7.519 -name {clk_133m_dimm_0} [ get_ports {clk_133m_dimm_0_p} ]

create_clock -period 10.000 -name {clk2_100m_fpga_2i} [ get_ports {clk2_100m_fpga_2i_p} ]
create_clock -period 10.000 -name {clk2_100m_fpga_2j_0} [ get_ports {clk2_100m_fpga_2j_0_p} ]
create_clock -period 10.000 -name {clk2_100m_fpga_2j_1} [ get_ports {clk2_100m_fpga_2j_1_p} ]
create_clock -period 10.000 -name {clk_100m_fpga_3h} [ get_ports {clk_100m_fpga_3h_p} ]
create_clock -period 10.000 -name {clk_100m_fpga_3l_0} [ get_ports {clk_100m_fpga_3l_0_p} ]
create_clock -period 10.000 -name {clk_100m_fpga_3l_1} [ get_ports {clk_100m_fpga_3l_1_p} ]

create_clock -period 20.000 -name {clk2_fpga_50m} [ get_ports {clk2_fpga_50m} ]

create_clock -period 10.000 -name {clk_100m_pcie_0} [ get_ports {clk_100m_pcie_0_p} ]
create_clock -period 10.000 -name {clk_100m_pcie_1} [ get_ports {clk_100m_pcie_1_p} ]

create_clock -period 10.000 -name {clk_100m_upi0_0} [ get_ports {clk_100m_upi0_0_p} ]
create_clock -period 10.000 -name {clk_100m_upi0_1} [ get_ports {clk_100m_upi0_1_p} ]

create_clock -period 10.000 -name {clk_100m_upi1_0} [ get_ports {clk_100m_upi1_0_p} ]
create_clock -period 10.000 -name {clk_100m_upi1_1} [ get_ports {clk_100m_upi1_1_p} ]

create_clock -period 10.000 -name {clk_100m_upi2_0} [ get_ports {clk_100m_upi2_0_p} ]
create_clock -period 10.000 -name {clk_100m_upi2_1} [ get_ports {clk_100m_upi2_1_p} ]

create_clock -period 3.2 -name {clk_312p5m_qsfp0} [ get_ports {clk_312p5m_qsfp0_p} ]
create_clock -period 6.4 -name {clk_156p25m_qsfp0} [ get_ports {clk_156p25m_qsfp0_p} ]
create_clock -period 3.2 -name {clk_312p5m_qsfp1} [ get_ports {clk_312p5m_qsfp1_p} ]
create_clock -period 6.4 -name {clk_156p25m_qsfp1} [ get_ports {clk_156p25m_qsfp1_p} ]
create_clock -period 3.2 -name {clk_312p5m_qsfp2} [ get_ports {clk_312p5m_qsfp2_p} ]

derive_clock_uncertainty

set_clock_groups -asynchronous -group [ get_clocks {clk_133m_ddr4_1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_133m_ddr4_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_133m_dimm_1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_133m_dimm_0} ]

set_clock_groups -asynchronous -group [ get_clocks {clk2_100m_fpga_2i} ]
set_clock_groups -asynchronous -group [ get_clocks {clk2_100m_fpga_2j_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk2_100m_fpga_2j_1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_fpga_3h} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_fpga_3l_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_fpga_3l_1} ]

set_clock_groups -asynchronous -group [ get_clocks {clk2_fpga_50m} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_100m_pcie_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_pcie_1} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi0_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi0_1} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi1_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi1_1} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi2_0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_100m_upi2_1} ]

set_clock_groups -asynchronous -group [ get_clocks {clk_312p5m_qsfp0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_156p25m_qsfp0} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_312p5m_qsfp1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_156p25m_qsfp1} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_312p5m_qsfp2} ]

# JTAG constraints
create_clock -name {altera_reserved_tck} -period 40.800 {altera_reserved_tck}

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

# IO constraints
set_false_path -from "cpu_resetn"
set_false_path -to   "user_led_g[*]"

set_false_path -from "pcie_rst_n"


source ../lib/eth/lib/axis/syn/quartus_pro/sync_reset.sdc
source ../lib/eth/lib/axis/syn/quartus_pro/axis_async_fifo.sdc

# clocking infrastructure
constrain_sync_reset_inst "sync_reset_100mhz_inst"

# MAC clocks
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|rx_clkout2|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout2|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch1} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch2} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch3} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|rx_clkout2|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout2|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch1} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch2} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp2_mac_inst|mac_inst|alt_ehipc3_0|alt_ehipc3_hard_inst|SL_NPHY.altera_xcvr_native_inst|alt_ehipc3_nphy_elane|tx_clkout|ch3} ]

# MAC resets
constrain_sync_reset_inst "qsfp1_mac_inst|mac_ch[0].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_mac_inst|mac_ch[1].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_mac_inst|mac_ch[2].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_mac_inst|mac_ch[3].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp2_mac_inst|mac_ch[0].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp2_mac_inst|mac_ch[1].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp2_mac_inst|mac_ch[2].mac_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp2_mac_inst|mac_ch[3].mac_rst_reset_sync_inst"

# async FIFOs
constrain_axis_async_fifo_inst "core_inst|max_rx_fifo"
constrain_axis_async_fifo_inst "core_inst|max_tx_fifo"