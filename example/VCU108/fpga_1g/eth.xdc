# Ethernet constraints

set_property LOC BITSLICE_RX_TX_X1Y35 [get_cells -hier -filter {name =~ */lvds_transceiver_mw/serdes_1_to_10_ser8_i/idelay_cal}]
#set_false_path -to [get_pins -hier -filter {name =~ *idelayctrl_inst/RST} -include_replicated_objects ]
