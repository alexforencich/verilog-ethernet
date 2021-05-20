package require -exact qsys 20.4

# create the system "mac"
proc do_create_mac {} {
	# create the system
	create_system mac
	set_project_property DEVICE {1SD280PT2F55E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance alt_ehipc3_0 alt_ehipc3
	set_instance_parameter_value alt_ehipc3_0 {AIB_test_sl} {0}
	set_instance_parameter_value alt_ehipc3_0 {AN_CHAN} {0}
	set_instance_parameter_value alt_ehipc3_0 {AN_PAUSE_C0} {1}
	set_instance_parameter_value alt_ehipc3_0 {AN_PAUSE_C1} {1}
	set_instance_parameter_value alt_ehipc3_0 {AVMM_test} {0}
	set_instance_parameter_value alt_ehipc3_0 {AVMM_test_sl} {0}
	set_instance_parameter_value alt_ehipc3_0 {CR_MODE} {1}
	set_instance_parameter_value alt_ehipc3_0 {DEV_BOARD} {0}
	set_instance_parameter_value alt_ehipc3_0 {EHIP_LOCATION} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_ADME} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_ADME_PTP_CHANNEL} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_AN} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_ANLT} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_ASYNC_ADAPTERS} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_ASYNC_ADAPTERS_SL} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_JTAG_AVMM} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_LT} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_PPM_TODSYNC} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_PTP} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_PTP_PPM} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_PTP_RX_DESKEW} {1}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_PTP_TOG} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_RSFEC} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENABLE_SYNCE} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENHANCED_PTP_ACCURACY} {0}
	set_instance_parameter_value alt_ehipc3_0 {ENHANCED_PTP_DBG} {0}
	set_instance_parameter_value alt_ehipc3_0 {EN_DYN_FEC} {0}
	set_instance_parameter_value alt_ehipc3_0 {EXAMPLE_DESIGN} {1}
	set_instance_parameter_value alt_ehipc3_0 {GEN_SIM} {1}
	set_instance_parameter_value alt_ehipc3_0 {GEN_SYNTH} {1}
	set_instance_parameter_value alt_ehipc3_0 {HDL_FORMAT} {1}
	set_instance_parameter_value alt_ehipc3_0 {LINK_TIMER_KR} {504}
	set_instance_parameter_value alt_ehipc3_0 {PHY_REFCLK} {156.250000}
	set_instance_parameter_value alt_ehipc3_0 {PHY_REFCLK_sl_0} {156.250000}
	set_instance_parameter_value alt_ehipc3_0 {PPM_VALUE_RX} {0}
	set_instance_parameter_value alt_ehipc3_0 {PPM_VALUE_TX} {0}
	set_instance_parameter_value alt_ehipc3_0 {RECONFIG_1025} {0}
	set_instance_parameter_value alt_ehipc3_0 {REQUEST_RSFEC} {0}
	set_instance_parameter_value alt_ehipc3_0 {RSFEC_CLOCKING_MODE} {fec_dir_adp_clk_0}
	set_instance_parameter_value alt_ehipc3_0 {RSFEC_FIRST_LANE_SEL} {first_lane0}
	set_instance_parameter_value alt_ehipc3_0 {SL_OPT} {2}
	set_instance_parameter_value alt_ehipc3_0 {STATUS_CLK_MHZ} {100.0}
	set_instance_parameter_value alt_ehipc3_0 {USE_PTP_PLLCH} {1}
	set_instance_parameter_value alt_ehipc3_0 {XCVR_test} {0}
	set_instance_parameter_value alt_ehipc3_0 {active_channel} {0}
	set_instance_parameter_value alt_ehipc3_0 {additional_ipg_removed} {0}
	set_instance_parameter_value alt_ehipc3_0 {additional_ipg_removed_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {adpt_multi_enable} {1}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_cnt} {1}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data0} {ctle_lf_val_a 999 ctle_lf_val_ada_a adaptable ctle_lf_min_a 999 ctle_lf_max_a 2 ctle_hf_val_a 999 ctle_hf_val_ada_a adaptable ctle_hf_min_a 999 ctle_hf_max_a 999 rf_p2_val_a 999 rf_p2_val_ada_a fix rf_p2_min_a 999 rf_p2_max_a 999 rf_p1_val_a 999 rf_p1_val_ada_a adaptable rf_p1_min_a 999 rf_p1_max_a 999 rf_reserved0_a 999 rf_p0_val_a 999 rf_p0_val_ada_a adaptable rf_reserved1_a 999 rf_b0t_a 999 ctle_gs1_val_a 2 ctle_gs2_val_a 1 rf_b1_a 5 rf_b1_ada_a fix rf_b0_a 1 rf_b0_ada_a fix rf_a_a 999 ctle_lf_val_b 999 ctle_lf_val_ada_b adaptable ctle_lf_min_b 999 ctle_lf_max_b 2 ctle_hf_val_b 999 ctle_hf_val_ada_b adaptable ctle_hf_min_b 999 ctle_hf_max_b 999 rf_p2_val_b 999 rf_p2_val_ada_b fix rf_p2_min_b 999 rf_p2_max_b 999 rf_p1_val_b 999 rf_p1_val_ada_b adaptable rf_p1_min_b 999 rf_p1_max_b 999 rf_reserved0_b 999 rf_p0_val_b 999 rf_p0_val_ada_b adaptable rf_reserved1_b 999 rf_b0t_b 999 ctle_gs1_val_b 2 ctle_gs2_val_b 1 rf_b1_b 5 rf_b1_ada_b fix rf_b0_b 1 rf_b0_ada_b fix rf_a_b 999}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data1} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data2} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data3} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data4} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data5} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data6} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_data7} {}
	set_instance_parameter_value alt_ehipc3_0 {adpt_recipe_select} {0}
	set_instance_parameter_value alt_ehipc3_0 {cal_recipe_sel} {NRZ_10Gbps}
	set_instance_parameter_value alt_ehipc3_0 {core_variant} {1}
	set_instance_parameter_value alt_ehipc3_0 {cpri_PHY_REFCLK} {184.320000}
	set_instance_parameter_value alt_ehipc3_0 {cpri_ehip_rate_gui} {2}
	set_instance_parameter_value alt_ehipc3_0 {cpri_enable_custom_sl_0} {1}
	set_instance_parameter_value alt_ehipc3_0 {cpri_include_alternate_ports} {0}
	set_instance_parameter_value alt_ehipc3_0 {cpri_include_refclk_mux_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {cpri_number_of_channel} {1}
	set_instance_parameter_value alt_ehipc3_0 {ctle_gs1_val_a} {2}
	set_instance_parameter_value alt_ehipc3_0 {ctle_gs1_val_b} {2}
	set_instance_parameter_value alt_ehipc3_0 {ctle_gs2_val_a} {1}
	set_instance_parameter_value alt_ehipc3_0 {ctle_gs2_val_b} {1}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_max_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_max_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_min_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_min_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_val_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_val_ada_a} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_val_ada_b} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {ctle_hf_val_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_max_a} {2}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_max_b} {2}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_min_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_min_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_val_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_val_ada_a} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_val_ada_b} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {ctle_lf_val_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_PHY_REFCLK} {250.000000}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_ehip_mode_gui} {PCS_Only}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_ehip_rate_gui} {25000}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_enable_custom} {1}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_fibre_channel_mode} {disable}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_include_alternate_ports} {0}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_modulation} {NRZ}
	set_instance_parameter_value alt_ehipc3_0 {custom_pcs_number_of_channel} {1}
	set_instance_parameter_value alt_ehipc3_0 {disable_internal_dr} {0}
	set_instance_parameter_value alt_ehipc3_0 {duplex_mode} {enable}
	set_instance_parameter_value alt_ehipc3_0 {ehip_mode_gui} {MAC+PCS}
	set_instance_parameter_value alt_ehipc3_0 {ehip_mode_gui_sl_0} {MAC+PCS}
	set_instance_parameter_value alt_ehipc3_0 {ehip_rate_gui} {100G}
	set_instance_parameter_value alt_ehipc3_0 {ehip_rate_gui_sl_0} {10G}
	set_instance_parameter_value alt_ehipc3_0 {enable_aib_latency_adj_ena_ports} {0}
	set_instance_parameter_value alt_ehipc3_0 {enable_custom_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {enable_external_aib_clocking} {0}
	set_instance_parameter_value alt_ehipc3_0 {enable_internal_options} {0}
	set_instance_parameter_value alt_ehipc3_0 {enable_rsfec_rst_ports} {0}
	set_instance_parameter_value alt_ehipc3_0 {enforce_max_frame_size_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {enforce_max_frame_size_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {flow_control_gui} {No}
	set_instance_parameter_value alt_ehipc3_0 {flow_control_gui_sl_0} {No}
	set_instance_parameter_value alt_ehipc3_0 {forward_rx_pause_requests_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {forward_rx_pause_requests_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {include_alternate_ports_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {include_dlat_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {include_refclk_mux_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {link_fault_mode_gui} {Bidirectional}
	set_instance_parameter_value alt_ehipc3_0 {link_fault_mode_gui_sl_0} {Bidirectional}
	set_instance_parameter_value alt_ehipc3_0 {number_of_channel} {3}
	set_instance_parameter_value alt_ehipc3_0 {preamble_passthrough_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {preamble_passthrough_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {preserve_unused_xcvr_channels} {0}
	set_instance_parameter_value alt_ehipc3_0 {rcp_load_enable} {1}
	set_instance_parameter_value alt_ehipc3_0 {ready_latency} {0}
	set_instance_parameter_value alt_ehipc3_0 {ready_latency_sl} {0}
	set_instance_parameter_value alt_ehipc3_0 {rf_a_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_a_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0_a} {1}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0_ada_a} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0_ada_b} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0_b} {1}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0t_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_b0t_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_b1_a} {5}
	set_instance_parameter_value alt_ehipc3_0 {rf_b1_ada_a} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_b1_ada_b} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_b1_b} {5}
	set_instance_parameter_value alt_ehipc3_0 {rf_p0_val_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p0_val_ada_a} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {rf_p0_val_ada_b} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {rf_p0_val_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_max_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_max_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_min_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_min_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_val_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_val_ada_a} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_val_ada_b} {adaptable}
	set_instance_parameter_value alt_ehipc3_0 {rf_p1_val_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_max_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_max_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_min_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_min_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_val_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_val_ada_a} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_val_ada_b} {fix}
	set_instance_parameter_value alt_ehipc3_0 {rf_p2_val_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_reserved0_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_reserved0_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_reserved1_a} {999}
	set_instance_parameter_value alt_ehipc3_0 {rf_reserved1_b} {999}
	set_instance_parameter_value alt_ehipc3_0 {rx_bytes_to_remove} {Remove CRC bytes}
	set_instance_parameter_value alt_ehipc3_0 {rx_bytes_to_remove_sl_0} {Remove CRC bytes}
	set_instance_parameter_value alt_ehipc3_0 {rx_max_frame_size_gui} {1518}
	set_instance_parameter_value alt_ehipc3_0 {rx_max_frame_size_gui_sl_0} {1518}
	set_instance_parameter_value alt_ehipc3_0 {rx_vlan_detection_gui} {1}
	set_instance_parameter_value alt_ehipc3_0 {rx_vlan_detection_gui_sl_0} {1}
	set_instance_parameter_value alt_ehipc3_0 {source_address_insertion_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {source_address_insertion_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {strict_preamble_checking_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {strict_preamble_checking_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {strict_sfd_checking_gui} {0}
	set_instance_parameter_value alt_ehipc3_0 {strict_sfd_checking_gui_sl_0} {0}
	set_instance_parameter_value alt_ehipc3_0 {tx_ipg_size_gui} {12}
	set_instance_parameter_value alt_ehipc3_0 {tx_ipg_size_gui_sl_0} {12}
	set_instance_parameter_value alt_ehipc3_0 {tx_max_frame_size_gui} {1518}
	set_instance_parameter_value alt_ehipc3_0 {tx_max_frame_size_gui_sl_0} {1518}
	set_instance_parameter_value alt_ehipc3_0 {tx_vlan_detection_gui} {1}
	set_instance_parameter_value alt_ehipc3_0 {tx_vlan_detection_gui_sl_0} {1}
	set_instance_parameter_value alt_ehipc3_0 {txmac_saddr_gui} {73588229205}
	set_instance_parameter_value alt_ehipc3_0 {user_bti_refclk_freq_mhz} {125}
	set_instance_property alt_ehipc3_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property o_cdr_lock EXPORT_OF alt_ehipc3_0.o_cdr_lock
	set_interface_property o_tx_pll_locked EXPORT_OF alt_ehipc3_0.o_tx_pll_locked
	set_interface_property i_clk_ref EXPORT_OF alt_ehipc3_0.i_clk_ref
	set_interface_property o_clk_pll_div64 EXPORT_OF alt_ehipc3_0.o_clk_pll_div64
	set_interface_property o_clk_pll_div66 EXPORT_OF alt_ehipc3_0.o_clk_pll_div66
	set_interface_property o_clk_rec_div64 EXPORT_OF alt_ehipc3_0.o_clk_rec_div64
	set_interface_property o_clk_rec_div66 EXPORT_OF alt_ehipc3_0.o_clk_rec_div66
	set_interface_property serial_p EXPORT_OF alt_ehipc3_0.serial_p
	set_interface_property serial_n EXPORT_OF alt_ehipc3_0.serial_n
	set_interface_property i_reconfig_clk EXPORT_OF alt_ehipc3_0.i_reconfig_clk
	set_interface_property i_reconfig_reset EXPORT_OF alt_ehipc3_0.i_reconfig_reset
	set_interface_property i_xcvr_reconfig_address EXPORT_OF alt_ehipc3_0.i_xcvr_reconfig_address
	set_interface_property i_xcvr_reconfig_read EXPORT_OF alt_ehipc3_0.i_xcvr_reconfig_read
	set_interface_property i_xcvr_reconfig_write EXPORT_OF alt_ehipc3_0.i_xcvr_reconfig_write
	set_interface_property o_xcvr_reconfig_readdata EXPORT_OF alt_ehipc3_0.o_xcvr_reconfig_readdata
	set_interface_property i_xcvr_reconfig_writedata EXPORT_OF alt_ehipc3_0.i_xcvr_reconfig_writedata
	set_interface_property o_xcvr_reconfig_waitrequest EXPORT_OF alt_ehipc3_0.o_xcvr_reconfig_waitrequest
	set_interface_property i_sl_stats_snapshot EXPORT_OF alt_ehipc3_0.i_sl_stats_snapshot
	set_interface_property o_sl_rx_hi_ber EXPORT_OF alt_ehipc3_0.o_sl_rx_hi_ber
	set_interface_property i_sl_eth_reconfig_addr EXPORT_OF alt_ehipc3_0.i_sl_eth_reconfig_addr
	set_interface_property i_sl_eth_reconfig_read EXPORT_OF alt_ehipc3_0.i_sl_eth_reconfig_read
	set_interface_property i_sl_eth_reconfig_write EXPORT_OF alt_ehipc3_0.i_sl_eth_reconfig_write
	set_interface_property o_sl_eth_reconfig_readdata EXPORT_OF alt_ehipc3_0.o_sl_eth_reconfig_readdata
	set_interface_property o_sl_eth_reconfig_readdata_valid EXPORT_OF alt_ehipc3_0.o_sl_eth_reconfig_readdata_valid
	set_interface_property i_sl_eth_reconfig_writedata EXPORT_OF alt_ehipc3_0.i_sl_eth_reconfig_writedata
	set_interface_property o_sl_eth_reconfig_waitrequest EXPORT_OF alt_ehipc3_0.o_sl_eth_reconfig_waitrequest
	set_interface_property o_sl_tx_lanes_stable EXPORT_OF alt_ehipc3_0.o_sl_tx_lanes_stable
	set_interface_property o_sl_rx_pcs_ready EXPORT_OF alt_ehipc3_0.o_sl_rx_pcs_ready
	set_interface_property o_sl_ehip_ready EXPORT_OF alt_ehipc3_0.o_sl_ehip_ready
	set_interface_property o_sl_rx_block_lock EXPORT_OF alt_ehipc3_0.o_sl_rx_block_lock
	set_interface_property o_sl_local_fault_status EXPORT_OF alt_ehipc3_0.o_sl_local_fault_status
	set_interface_property o_sl_remote_fault_status EXPORT_OF alt_ehipc3_0.o_sl_remote_fault_status
	set_interface_property i_sl_clk_tx EXPORT_OF alt_ehipc3_0.i_sl_clk_tx
	set_interface_property i_sl_clk_rx EXPORT_OF alt_ehipc3_0.i_sl_clk_rx
	set_interface_property i_sl_csr_rst_n EXPORT_OF alt_ehipc3_0.i_sl_csr_rst_n
	set_interface_property i_sl_tx_rst_n EXPORT_OF alt_ehipc3_0.i_sl_tx_rst_n
	set_interface_property i_sl_rx_rst_n EXPORT_OF alt_ehipc3_0.i_sl_rx_rst_n
	set_interface_property sl_xcvr_fifo_ports EXPORT_OF alt_ehipc3_0.sl_xcvr_fifo_ports
	set_interface_property sl_nonpcs_ports EXPORT_OF alt_ehipc3_0.sl_nonpcs_ports
	set_interface_property sl_pfc_ports EXPORT_OF alt_ehipc3_0.sl_pfc_ports
	set_interface_property sl_pause_ports EXPORT_OF alt_ehipc3_0.sl_pause_ports

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="alt_ehipc3_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {mac.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {mac}

	# save the system
	sync_sysinfo_parameters
	save_system mac
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_mac

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
