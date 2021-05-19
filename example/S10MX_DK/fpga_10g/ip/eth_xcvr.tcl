package require -exact qsys 20.4

# create the system "eth_xcvr"
proc do_create_eth_xcvr {} {
	# create the system
	create_system eth_xcvr
	set_project_property DEVICE {1SM21CHU1F53E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance xcvr_native_s10_htile_0 altera_xcvr_native_s10_htile
	set_instance_parameter_value xcvr_native_s10_htile_0 {adapter_ehip_mode} {disable_hip}
	set_instance_parameter_value xcvr_native_s10_htile_0 {anlg_link} {lr}
	set_instance_parameter_value xcvr_native_s10_htile_0 {anlg_voltage} {1_1V}
	set_instance_parameter_value xcvr_native_s10_htile_0 {avmm_ehip_mode} {disable_hip}
	set_instance_parameter_value xcvr_native_s10_htile_0 {base_device} {Unknown}
	set_instance_parameter_value xcvr_native_s10_htile_0 {bonded_mode} {not_bonded}
	set_instance_parameter_value xcvr_native_s10_htile_0 {cdr_refclk_cnt} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {cdr_refclk_select} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {channel_type} {GX}
	set_instance_parameter_value xcvr_native_s10_htile_0 {channels} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {delay_measurement_clkout2_sel} {clock_delay_measurement_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {delay_measurement_clkout_sel} {clock_delay_measurement_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {design_environment} {NATIVE}
	set_instance_parameter_value xcvr_native_s10_htile_0 {design_example_filename} {dexample}
	set_instance_parameter_value xcvr_native_s10_htile_0 {disable_digital_reset_sequencer} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {disable_reset_sequencer} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {duplex_mode} {duplex}
	set_instance_parameter_value xcvr_native_s10_htile_0 {early_spd_chng_t1} {60}
	set_instance_parameter_value xcvr_native_s10_htile_0 {early_spd_chng_t2} {150}
	set_instance_parameter_value xcvr_native_s10_htile_0 {early_spd_chng_t3} {1000}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_advanced_user_mode} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_background_cal_gui} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_channel_powerdown} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_de_hardware_debug} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_debug_ports} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_direct_reset_control} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_double_rate_transfer} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_early_spd_chng} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ehip} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_fast_sim} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_hard_reset} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_hip} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_insert_eios_err} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_mac_total_control} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_manual_bonding_settings} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_clock_delay_measurement} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_krfec_rx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_krfec_rx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_krfec_tx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_latency_measurement} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_clkout2} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_clkout2_hioint} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_clkout_hioint} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_data_valid} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_bitslip} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_blk_lock} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_clr_errblk_count} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_crc32_err} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_frame_lock} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_highber} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_enh_highber_clr_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_align_clr} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_del} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_full} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_insert} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_latency_adj_ena} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_pempty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_pfull} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_fifo_rd_en} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_is_lockedtodata} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_is_lockedtoref} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_pcs_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_pcs_fifo_full} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_pma_clkslip} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_pma_iqtxrx_clkout} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_pma_qpipulldn} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_polinv} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_seriallpbken} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_bitrev_ena} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_bitslip} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_bitslipboundarysel} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_byterev_ena} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_rmfifo_empty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_rmfifo_full} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_signaldetect} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_wa_a1a2size} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_rx_std_wa_patternalign} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_clkout2} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_clkout2_hioint} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_clkout_hioint} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_dll_lock} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_enh_bitslip} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_enh_frame} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_enh_frame_burst_en} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_enh_frame_diag_status} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_fifo_full} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_fifo_latency_adj_ena} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_fifo_pempty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_fifo_pfull} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pcs_fifo_empty} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pcs_fifo_full} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_elecidle} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_iqtxrx_clkout} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_qpipulldn} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_qpipullup} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_rxfound} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_pma_txdetectrx} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_polinv} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_port_tx_std_bitslipboundarysel} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_adaptation} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_pipe_hclk} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_pipe_rx_elecidle} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_pipe_sw} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_rx_manual_cdr_mode} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_ports_rx_prbs} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_qpi_async_transfer} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_qpi_mode} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_rcfg_tx_digitalreset_release_ctrl} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_rx_fast_pipeln_reg} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_simple_interface} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_split_interface} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_transparent_pcs} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_tx_coreclkin2} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_tx_fast_pipeln_reg} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enable_workaround_rules} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_advanced_user_mode} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_low_latency_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_pcs_pma_width} {64}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_pld_pcs_width} {66}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_64b66b_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_bitslip_enable} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_blksync_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_crcchk_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_descram_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_dispchk_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_frmsync_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_frmsync_mfrm_length} {2048}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_krfec_err_mark_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_krfec_err_mark_type} {10G}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_rx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_64b66b_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_bitslip_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_crcerr_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_crcgen_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_dispgen_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_frmgen_burst_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_frmgen_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_frmgen_mfrm_length} {2048}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_krfec_burst_err_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_krfec_burst_err_len} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_randomdispbit_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_scram_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_scram_seed} {2.88230376152e+17}
	set_instance_parameter_value xcvr_native_s10_htile_0 {enh_tx_sh_err} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {generate_add_hdl_instance_example} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {generate_docs} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {hip_channels} {x1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {hip_mode} {disable_hip}
	set_instance_parameter_value xcvr_native_s10_htile_0 {hip_prot_mode} {gen1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {loopback_tx_clk_sel} {internal_clk}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_pcs_bonding_comp_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_pcs_bonding_mode} {individual}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_core_aib_bonding_comp_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_core_aib_bonding_mode} {individual}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_core_aib_indv} {indv_en}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_hssi_aib_bonding_comp_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_hssi_aib_bonding_mode} {individual}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_rx_hssi_aib_indv} {indv_en}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_core_aib_bonding_comp_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_core_aib_bonding_mode} {individual}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_core_aib_indv} {indv_en}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_hssi_aib_bonding_comp_cnt} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_hssi_aib_bonding_mode} {individual}
	set_instance_parameter_value xcvr_native_s10_htile_0 {manual_tx_hssi_aib_indv} {indv_en}
	set_instance_parameter_value xcvr_native_s10_htile_0 {message_level} {error}
	set_instance_parameter_value xcvr_native_s10_htile_0 {number_physical_bonding_clocks} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {osc_clk_divider} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {ovrd_rx_dv_mode} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {ovrd_tx_dv_mode} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {parallel_loopback_mode} {disable}
	set_instance_parameter_value xcvr_native_s10_htile_0 {pcie_rate_match} {Bypass}
	set_instance_parameter_value xcvr_native_s10_htile_0 {pcs_direct_width} {8}
	set_instance_parameter_value xcvr_native_s10_htile_0 {pcs_reset_sequencing_mode} {not_bonded}
	set_instance_parameter_value xcvr_native_s10_htile_0 {pll_select} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {plls} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {pma_mode} {basic}
	set_instance_parameter_value xcvr_native_s10_htile_0 {protocol_mode} {basic_enh}
	set_instance_parameter_value xcvr_native_s10_htile_0 {qsf_assignments_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_debug} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_enable_avmm_busy_port} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_file_prefix} {altera_xcvr_rcfg_10}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_files_as_common_package} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_h_file_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_iface_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_jtag_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_mif_file_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_multi_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_cnt} {2}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data0} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data1} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data2} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data3} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data4} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data5} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data6} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_data7} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_profile_select} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_reduced_files_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data0} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data1} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data2} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data3} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data4} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data5} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data6} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sdc_derived_profile_data7} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_separate_avmm_busy} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_shared} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_sv_file_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_txt_file_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rcfg_use_clk_reset_only} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {reduced_reset_sim_time} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_clkout2_sel} {pcs_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_clkout_sel} {pma_div_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_coreclkin_clock_network} {dedicated}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_ctle_ac_gain} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_ctle_eq_gain} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_fifo_align_del} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_fifo_control_del} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_fifo_mode} {Phase compensation}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_fifo_pempty} {2}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_fifo_pfull} {10}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_pma_adapt_mode} {ctle_dfe}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_pma_analog_mode} {user_custom}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_pma_div_clkout_divider} {33}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_pma_optimal_settings} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_pma_term_sel} {r_r2}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_ppm_detect_threshold} {1000}
	set_instance_parameter_value xcvr_native_s10_htile_0 {rx_vga_dc_gain} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_capability_reg_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_cdr_refclk_freq} {644.531250}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_cdr_refclk_receiver_detect_src} {iqclk}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_csr_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_data_rate} {10312.5}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_embedded_debug_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_enable_calibration} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_enable_eios_rx_protect} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_hip_cal_en} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_odi_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_pcs_bonding_master} {Auto}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_prbs_soft_logic_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_rcfg_emb_strm_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {set_user_identifier} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_low_latency_bypass_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_pcs_pma_width} {10}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_8b10b_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_bitrev_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_byte_deser_mode} {Disabled}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_byterev_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_rmfifo_mode} {disabled}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_rmfifo_pattern_n} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_rmfifo_pattern_p} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_fast_sync_status_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_mode} {bitslip}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_pattern} {0.0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_pattern_len} {7}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_renumber} {3}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_rgnumber} {3}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_rknumber} {3}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_rx_word_aligner_rvnumber} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_8b10b_disp_ctrl_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_8b10b_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_bitrev_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_bitslip_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_byte_ser_mode} {Disabled}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_byterev_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {std_tx_polinv_enable} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {support_mode} {user_mode}
	set_instance_parameter_value xcvr_native_s10_htile_0 {suppress_design_example_messages} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tile_type_suffix} {}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_clkout2_sel} {pcs_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_clkout_sel} {pma_div_clkout}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_coreclkin_clock_network} {dedicated}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_fifo_mode} {Phase compensation}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_fifo_pempty} {2}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_fifo_pfull} {10}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pcs_bonding_clock_network} {dedicated}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pll_refclk} {644.53125}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pll_type} {ATX}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_analog_mode} {user_custom}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_clk_div} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_compensation_en} {enable}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_div_clkout_divider} {33}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_optimal_settings} {1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_output_swing_ctrl} {12}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_pre_emp_sign_1st_post_tap} {negative}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_pre_emp_sign_pre_tap_1t} {negative}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_pre_emp_switching_ctrl_1st_post_tap} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_pre_emp_switching_ctrl_pre_tap_1t} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_slew_rate_ctrl} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {tx_pma_term_sel} {r_r1}
	set_instance_parameter_value xcvr_native_s10_htile_0 {use_rx_clkout2} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {use_tx_clkout2} {0}
	set_instance_parameter_value xcvr_native_s10_htile_0 {usr_rx_dv_mode} {enable}
	set_instance_parameter_value xcvr_native_s10_htile_0 {usr_tx_dv_mode} {enable}
	set_instance_parameter_value xcvr_native_s10_htile_0 {validation_rule_select} {}
	set_instance_property xcvr_native_s10_htile_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property tx_analogreset EXPORT_OF xcvr_native_s10_htile_0.tx_analogreset
	set_interface_property rx_analogreset EXPORT_OF xcvr_native_s10_htile_0.rx_analogreset
	set_interface_property tx_digitalreset EXPORT_OF xcvr_native_s10_htile_0.tx_digitalreset
	set_interface_property rx_digitalreset EXPORT_OF xcvr_native_s10_htile_0.rx_digitalreset
	set_interface_property tx_analogreset_stat EXPORT_OF xcvr_native_s10_htile_0.tx_analogreset_stat
	set_interface_property rx_analogreset_stat EXPORT_OF xcvr_native_s10_htile_0.rx_analogreset_stat
	set_interface_property tx_digitalreset_stat EXPORT_OF xcvr_native_s10_htile_0.tx_digitalreset_stat
	set_interface_property rx_digitalreset_stat EXPORT_OF xcvr_native_s10_htile_0.rx_digitalreset_stat
	set_interface_property tx_cal_busy EXPORT_OF xcvr_native_s10_htile_0.tx_cal_busy
	set_interface_property rx_cal_busy EXPORT_OF xcvr_native_s10_htile_0.rx_cal_busy
	set_interface_property tx_serial_clk0 EXPORT_OF xcvr_native_s10_htile_0.tx_serial_clk0
	set_interface_property rx_cdr_refclk0 EXPORT_OF xcvr_native_s10_htile_0.rx_cdr_refclk0
	set_interface_property tx_serial_data EXPORT_OF xcvr_native_s10_htile_0.tx_serial_data
	set_interface_property rx_serial_data EXPORT_OF xcvr_native_s10_htile_0.rx_serial_data
	set_interface_property rx_is_lockedtoref EXPORT_OF xcvr_native_s10_htile_0.rx_is_lockedtoref
	set_interface_property rx_is_lockedtodata EXPORT_OF xcvr_native_s10_htile_0.rx_is_lockedtodata
	set_interface_property tx_coreclkin EXPORT_OF xcvr_native_s10_htile_0.tx_coreclkin
	set_interface_property rx_coreclkin EXPORT_OF xcvr_native_s10_htile_0.rx_coreclkin
	set_interface_property tx_clkout EXPORT_OF xcvr_native_s10_htile_0.tx_clkout
	set_interface_property tx_clkout2 EXPORT_OF xcvr_native_s10_htile_0.tx_clkout2
	set_interface_property rx_clkout EXPORT_OF xcvr_native_s10_htile_0.rx_clkout
	set_interface_property rx_clkout2 EXPORT_OF xcvr_native_s10_htile_0.rx_clkout2
	set_interface_property tx_parallel_data EXPORT_OF xcvr_native_s10_htile_0.tx_parallel_data
	set_interface_property tx_control EXPORT_OF xcvr_native_s10_htile_0.tx_control
	set_interface_property tx_enh_data_valid EXPORT_OF xcvr_native_s10_htile_0.tx_enh_data_valid
	set_interface_property unused_tx_parallel_data EXPORT_OF xcvr_native_s10_htile_0.unused_tx_parallel_data
	set_interface_property rx_parallel_data EXPORT_OF xcvr_native_s10_htile_0.rx_parallel_data
	set_interface_property rx_control EXPORT_OF xcvr_native_s10_htile_0.rx_control
	set_interface_property rx_enh_data_valid EXPORT_OF xcvr_native_s10_htile_0.rx_enh_data_valid
	set_interface_property unused_rx_parallel_data EXPORT_OF xcvr_native_s10_htile_0.unused_rx_parallel_data
	set_interface_property rx_bitslip EXPORT_OF xcvr_native_s10_htile_0.rx_bitslip

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="xcvr_native_s10_htile_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {eth_xcvr.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {eth_xcvr}

	# save the system
	sync_sysinfo_parameters
	save_system eth_xcvr
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_eth_xcvr

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
