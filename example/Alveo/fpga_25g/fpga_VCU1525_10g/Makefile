
# FPGA settings
FPGA_PART = xcvu9p-fsgd2104-2L-e
FPGA_TOP = fpga
FPGA_ARCH = virtexuplus

# Files for synthesis
SYN_FILES = rtl/fpga_au200.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/eth_xcvr_phy_wrapper.v
SYN_FILES += rtl/eth_xcvr_phy_quad_wrapper.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += lib/eth/rtl/eth_mac_10g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_10g.v
SYN_FILES += lib/eth/rtl/axis_xgmii_rx_64.v
SYN_FILES += lib/eth/rtl/axis_xgmii_tx_64.v
SYN_FILES += lib/eth/rtl/eth_phy_10g.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_if.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_frame_sync.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_ber_mon.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_watchdog.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_tx.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_tx_if.v
SYN_FILES += lib/eth/rtl/xgmii_baser_dec_64.v
SYN_FILES += lib/eth/rtl/xgmii_baser_enc_64.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx.v
SYN_FILES += lib/eth/rtl/eth_axis_tx.v
SYN_FILES += lib/eth/rtl/udp_complete_64.v
SYN_FILES += lib/eth/rtl/udp_checksum_gen_64.v
SYN_FILES += lib/eth/rtl/udp_64.v
SYN_FILES += lib/eth/rtl/udp_ip_rx_64.v
SYN_FILES += lib/eth/rtl/udp_ip_tx_64.v
SYN_FILES += lib/eth/rtl/ip_complete_64.v
SYN_FILES += lib/eth/rtl/ip_64.v
SYN_FILES += lib/eth/rtl/ip_eth_rx_64.v
SYN_FILES += lib/eth/rtl/ip_eth_tx_64.v
SYN_FILES += lib/eth/rtl/ip_arb_mux.v
SYN_FILES += lib/eth/rtl/arp.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx.v
SYN_FILES += lib/eth/rtl/arp_eth_tx.v
SYN_FILES += lib/eth/rtl/eth_arb_mux.v
SYN_FILES += lib/eth/lib/axis/rtl/arbiter.v
SYN_FILES += lib/eth/lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_register.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += lib/eth/lib/axis/rtl/sync_reset.v

# XDC files
XDC_FILES = fpga_au200.xdc
XDC_FILES += lib/eth/syn/vivado/eth_mac_fifo.tcl
XDC_FILES += lib/eth/lib/axis/syn/vivado/axis_async_fifo.tcl
XDC_FILES += lib/eth/lib/axis/syn/vivado/sync_reset.tcl

# IP
IP_TCL_FILES += ip/eth_xcvr_gt.tcl

# Configuration
CONFIG_TCL_FILES = ./config.tcl

include ../common/vivado.mk

%_fallback.bit: %.bit
	echo "open_project $*.xpr" > generate_fallback_bit.tcl
	echo "open_run impl_1" >> generate_fallback_bit.tcl
	echo "startgroup" >> generate_fallback_bit.tcl
	echo "set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]" >> generate_fallback_bit.tcl
	echo "set_property BITSTREAM.CONFIG.TIMER_CFG 0x03000000 [current_design]" >> generate_fallback_bit.tcl
	echo "set_property BITSTREAM.CONFIG.NEXT_CONFIG_REBOOT ENABLE [current_design]" >> generate_fallback_bit.tcl
	echo "set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0x04000000 [current_design]" >> generate_fallback_bit.tcl
	echo "endgroup" >> generate_fallback_bit.tcl
	echo "write_bitstream -verbose -force $*_fallback.bit" >> generate_fallback_bit.tcl
	echo "undo" >> generate_fallback_bit.tcl
	echo "exit" >> generate_fallback_bit.tcl
	vivado -nojournal -nolog -mode batch -source generate_fallback_bit.tcl
	mkdir -p rev
	EXT=bit; COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.$$EXT ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	cp $@ rev/$*_fallback_rev$$COUNT.$$EXT; \
	echo "Output: rev/$*_fallback_rev$$COUNT.$$EXT";

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl

%.mcs %.prm: %.bit
	echo "write_cfgmem -force -format mcs -size 128 -interface SPIx4 -loadbit {up 0x04000000 $*.bit} -checksum -file $*.mcs" > generate_mcs.tcl
	echo "exit" >> generate_mcs.tcl
	vivado -nojournal -nolog -mode batch -source generate_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in .mcs .prm; \
	do cp $*$$x rev/$*_rev$$COUNT$$x; \
	echo "Output: rev/$*_rev$$COUNT$$x"; done;

%_fallback.mcs %_fallback.prm: %_fallback.bit
	echo "write_cfgmem -force -format mcs -size 128 -interface SPIx4 -loadbit {up 0x00000000 $*_fallback.bit} -checksum -file $*_fallback.mcs" > generate_fallback_mcs.tcl
	echo "exit" >> generate_fallback_mcs.tcl
	vivado -nojournal -nolog -mode batch -source generate_fallback_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in .mcs .prm; \
	do cp $*_fallback$$x rev/$*_fallback_rev$$COUNT$$x; \
	echo "Output: rev/$*_fallback_rev$$COUNT$$x"; done;

%_full.mcs %_full.prm: %_fallback.bit %.bit
	echo "write_cfgmem -force -format mcs -size 128 -interface SPIx4 -loadbit {up 0x00000000 $*_fallback.bit up 0x04000000 $*.bit} -checksum -file $*_full.mcs" > generate_full_mcs.tcl
	echo "exit" >> generate_full_mcs.tcl
	vivado -nojournal -nolog -mode batch -source generate_full_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in .mcs .prm; \
	do cp $*_full$$x rev/$*_full_rev$$COUNT$$x; \
	echo "Output: rev/$*_full_rev$$COUNT$$x"; done;

flash: $(FPGA_TOP).mcs $(FPGA_TOP).prm
	echo "open_hw" > flash.tcl
	echo "connect_hw_server" >> flash.tcl
	echo "open_hw_target" >> flash.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash.tcl
	echo "create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4}] 0]" >> flash.tcl
	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash.tcl
	echo "set_property PROGRAM.FILES [list \"$(FPGA_TOP).mcs\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.PRM_FILES [list \"$(FPGA_TOP).prm\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash.tcl
	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash.tcl
	echo "program_hw_devices [current_hw_device]" >> flash.tcl
	echo "refresh_hw_device [current_hw_device]" >> flash.tcl
	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash.tcl
	echo "boot_hw_device [current_hw_device]" >> flash.tcl
	echo "exit" >> flash.tcl
	vivado -nojournal -nolog -mode batch -source flash.tcl

flash%: $(FPGA_TOP)%.mcs $(FPGA_TOP)%.prm
	echo "open_hw" > flash$*.tcl
	echo "connect_hw_server" >> flash$*.tcl
	echo "open_hw_target" >> flash$*.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash$*.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash$*.tcl
	echo "create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4}] 0]" >> flash$*.tcl
	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash$*.tcl
	echo "set_property PROGRAM.FILES [list \"$(FPGA_TOP)$*.mcs\"] [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.PRM_FILES [list \"$(FPGA_TOP)$*.prm\"] [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash$*.tcl
	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash$*.tcl
	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash$*.tcl
	echo "program_hw_devices [current_hw_device]" >> flash$*.tcl
	echo "refresh_hw_device [current_hw_device]" >> flash$*.tcl
	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash$*.tcl
	echo "boot_hw_device [current_hw_device]" >> flash$*.tcl
	echo "exit" >> flash$*.tcl
	vivado -nojournal -nolog -mode batch -source flash$*.tcl
