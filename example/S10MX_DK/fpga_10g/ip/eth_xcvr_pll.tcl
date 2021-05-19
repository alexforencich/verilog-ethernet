package require -exact qsys 20.4

# create the system "eth_xcvr_pll"
proc do_create_eth_xcvr_pll {} {
	# create the system
	create_system eth_xcvr_pll
	set_project_property DEVICE {1SM21CHU1F53E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_atx_pll_s10_htile_0 altera_xcvr_atx_pll_s10_htile
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {base_device} {Unknown}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {bw_sel} {high}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_28G_input_frm_abv_atx} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_28G_input_frm_blw_atx} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_28G_local_atx_path} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_28G_output_frm_abv_atx} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_28G_output_frm_blw_atx} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_8G_path} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_GXT_clock_source} {disabled}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_GXT_out_buffer_abv} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_GXT_out_buffer_blw} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_analog_resets} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_bonding_clks} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_cascade_out} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_debug_ports_parameters} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_ext_lockdetect_ports} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_fb_comp_bonding} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_hfreq_clk} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_hip_cal_done_port} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_manual_configuration} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_mcgb} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_mcgb_pcie_clksw} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_mcgb_reset} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_pcie_clk} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_pcie_hip_connectivity} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_pld_atx_cal_busy_port} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_pld_mcgb_cal_busy_port} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_pll_lock} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {enable_vco_bypass} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {generate_add_hdl_instance_example} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {mcgb_aux_clkin_cnt} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {mcgb_div} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {message_level} {error}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {pma_width} {64}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {primary_pll_buffer} {GX clock output buffer}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {prot_mode} {Basic}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_debug} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_enable_avmm_busy_port} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_file_prefix} {altera_xcvr_atx_pll_s10}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_files_as_common_package} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_h_file_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_jtag_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_mif_file_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_multi_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_cnt} {2}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data0} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data1} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data2} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data3} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data4} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data5} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data6} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_data7} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_profile_select} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_reduced_files_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data0} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data1} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data2} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data3} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data4} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data5} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data6} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sdc_derived_profile_data7} {}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_separate_avmm_busy} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_sv_file_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {rcfg_txt_file_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {refclk_cnt} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {refclk_index} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_altera_xcvr_atx_pll_s10_calibration_en} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_auto_reference_clock_frequency} {644.53125}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_capability_reg_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_csr_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_fref_clock_frequency} {156.25}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_hip_cal_en} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_k_counter} {1.0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_l_cascade_counter} {4}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_l_cascade_predivider} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_l_counter} {4}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_m_counter} {24}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_manual_reference_clock_frequency} {200.0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_output_clock_frequency} {5156.25}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_rcfg_emb_strm_enable} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_ref_clk_div} {1}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {set_user_identifier} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {silicon_rev} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {support_mode} {user_mode}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {test_mode} {0}
	set_instance_parameter_value xcvr_atx_pll_s10_htile_0 {usr_analog_voltage} {1_1V}
	set_instance_property xcvr_atx_pll_s10_htile_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property pll_refclk0 EXPORT_OF xcvr_atx_pll_s10_htile_0.pll_refclk0
	set_interface_property tx_serial_clk EXPORT_OF xcvr_atx_pll_s10_htile_0.tx_serial_clk
	set_interface_property pll_locked EXPORT_OF xcvr_atx_pll_s10_htile_0.pll_locked
	set_interface_property pll_cal_busy EXPORT_OF xcvr_atx_pll_s10_htile_0.pll_cal_busy

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_atx_pll_s10_htile_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {eth_xcvr_pll.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {eth_xcvr_pll}

	# save the system
	sync_sysinfo_parameters
	save_system eth_xcvr_pll
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_eth_xcvr_pll

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
