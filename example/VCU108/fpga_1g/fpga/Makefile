
# FPGA settings
FPGA_PART = xcvu095-ffva2104-2-e
FPGA_TOP = fpga
FPGA_ARCH = VirtexUltrascale

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_reset.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_1g.v
SYN_FILES += lib/eth/rtl/axis_gmii_rx.v
SYN_FILES += lib/eth/rtl/axis_gmii_tx.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx.v
SYN_FILES += lib/eth/rtl/eth_axis_tx.v
SYN_FILES += lib/eth/rtl/udp_complete.v
SYN_FILES += lib/eth/rtl/udp_checksum_gen.v
SYN_FILES += lib/eth/rtl/udp.v
SYN_FILES += lib/eth/rtl/udp_ip_rx.v
SYN_FILES += lib/eth/rtl/udp_ip_tx.v
SYN_FILES += lib/eth/rtl/ip_complete.v
SYN_FILES += lib/eth/rtl/ip.v
SYN_FILES += lib/eth/rtl/ip_eth_rx.v
SYN_FILES += lib/eth/rtl/ip_eth_tx.v
SYN_FILES += lib/eth/rtl/ip_arb_mux_2.v
SYN_FILES += lib/eth/rtl/ip_mux_2.v
SYN_FILES += lib/eth/rtl/arp.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx.v
SYN_FILES += lib/eth/rtl/arp_eth_tx.v
SYN_FILES += lib/eth/rtl/eth_arb_mux_2.v
SYN_FILES += lib/eth/rtl/eth_mux_2.v
SYN_FILES += lib/eth/lib/axis/rtl/arbiter.v
SYN_FILES += lib/eth/lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_frame_fifo.v

# XDC files
XDC_FILES = fpga.xdc
XDC_FILES += eth.xdc

# IP
XCI_FILES = ip/gig_ethernet_pcs_pma_0.xci

include ../common/vivado.mk

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [lindex [get_hw_devices] 0]" >> program.tcl
	echo "program_hw_devices [lindex [get_hw_devices] 0]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -mode batch -source program.tcl

