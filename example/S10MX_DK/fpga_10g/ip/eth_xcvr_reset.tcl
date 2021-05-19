package require -exact qsys 20.4

# create the system "eth_xcvr_reset"
proc do_create_eth_xcvr_reset {} {
	# create the system
	create_system eth_xcvr_reset
	set_project_property DEVICE {1SM21CHU1F53E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_reset_control_s10_0 altera_xcvr_reset_control_s10
	set_instance_parameter_value xcvr_reset_control_s10_0 {CHANNELS} {4}
	set_instance_parameter_value xcvr_reset_control_s10_0 {ENABLE_DIGITAL_SEQ} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {PLLS} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {REDUCED_SIM_TIME} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {RX_ENABLE} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {RX_MANUAL_RESET} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {RX_PER_CHANNEL} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {SYS_CLK_IN_MHZ} {100}
	set_instance_parameter_value xcvr_reset_control_s10_0 {TILE_TYPE} {h_tile}
	set_instance_parameter_value xcvr_reset_control_s10_0 {TX_ENABLE} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {TX_MANUAL_RESET} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {TX_PER_CHANNEL} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {TX_PLL_ENABLE} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_PLL_LOCK_HYST} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_PLL_POWERDOWN} {1000}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_RX_ANALOGRESET} {40}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_RX_DIGITALRESET} {5000}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_TX_ANALOGRESET} {0}
	set_instance_parameter_value xcvr_reset_control_s10_0 {T_TX_DIGITALRESET} {20}
	set_instance_parameter_value xcvr_reset_control_s10_0 {gui_pll_cal_busy} {1}
	set_instance_parameter_value xcvr_reset_control_s10_0 {gui_split_interfaces} {0}
	set_instance_property xcvr_reset_control_s10_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property clock EXPORT_OF xcvr_reset_control_s10_0.clock
	set_interface_property reset EXPORT_OF xcvr_reset_control_s10_0.reset
	set_interface_property tx_analogreset EXPORT_OF xcvr_reset_control_s10_0.tx_analogreset
	set_interface_property tx_digitalreset EXPORT_OF xcvr_reset_control_s10_0.tx_digitalreset
	set_interface_property tx_ready EXPORT_OF xcvr_reset_control_s10_0.tx_ready
	set_interface_property pll_locked EXPORT_OF xcvr_reset_control_s10_0.pll_locked
	set_interface_property pll_select EXPORT_OF xcvr_reset_control_s10_0.pll_select
	set_interface_property tx_cal_busy EXPORT_OF xcvr_reset_control_s10_0.tx_cal_busy
	set_interface_property tx_analogreset_stat EXPORT_OF xcvr_reset_control_s10_0.tx_analogreset_stat
	set_interface_property tx_digitalreset_stat EXPORT_OF xcvr_reset_control_s10_0.tx_digitalreset_stat
	set_interface_property pll_cal_busy EXPORT_OF xcvr_reset_control_s10_0.pll_cal_busy
	set_interface_property rx_analogreset EXPORT_OF xcvr_reset_control_s10_0.rx_analogreset
	set_interface_property rx_digitalreset EXPORT_OF xcvr_reset_control_s10_0.rx_digitalreset
	set_interface_property rx_ready EXPORT_OF xcvr_reset_control_s10_0.rx_ready
	set_interface_property rx_is_lockedtodata EXPORT_OF xcvr_reset_control_s10_0.rx_is_lockedtodata
	set_interface_property rx_cal_busy EXPORT_OF xcvr_reset_control_s10_0.rx_cal_busy
	set_interface_property rx_analogreset_stat EXPORT_OF xcvr_reset_control_s10_0.rx_analogreset_stat
	set_interface_property rx_digitalreset_stat EXPORT_OF xcvr_reset_control_s10_0.rx_digitalreset_stat

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_reset_control_s10_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {eth_xcvr_reset.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {eth_xcvr_reset}

	# save the system
	sync_sysinfo_parameters
	save_system eth_xcvr_reset
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_eth_xcvr_reset

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
