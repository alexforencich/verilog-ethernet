package require -exact qsys 20.4

# create the system "reset_release"
proc do_create_reset_release {} {
	# create the system
	create_system reset_release
	set_project_property DEVICE {1SD280PT2F55E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance s10_user_rst_clkgate_0 altera_s10_user_rst_clkgate
	set_instance_parameter_value s10_user_rst_clkgate_0 {outputType} {Reset Interface}
	set_instance_property s10_user_rst_clkgate_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property ninit_done EXPORT_OF s10_user_rst_clkgate_0.ninit_done

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="s10_user_rst_clkgate_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {reset_release.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {reset_release}

	# save the system
	sync_sysinfo_parameters
	save_system reset_release
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_reset_release

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
