
# FPGA settings
FPGA_PART = xc7vx485tffg1761-2
FPGA_TOP = fpga
FPGA_ARCH = kintex7

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += ../../rtl/eth_mac_1g_fifo.v
SYN_FILES += ../../rtl/eth_mac_1g.v
SYN_FILES += ../../rtl/axis_gmii_rx.v
SYN_FILES += ../../rtl/axis_gmii_tx.v
SYN_FILES += ../../rtl/lfsr.v
SYN_FILES += ../../rtl/eth_axis_rx.v
SYN_FILES += ../../rtl/eth_axis_tx.v
SYN_FILES += ../../rtl/udp_complete.v
SYN_FILES += ../../rtl/udp_checksum_gen.v
SYN_FILES += ../../rtl/udp.v
SYN_FILES += ../../rtl/udp_ip_rx.v
SYN_FILES += ../../rtl/udp_ip_tx.v
SYN_FILES += ../../rtl/ip_complete.v
SYN_FILES += ../../rtl/ip.v
SYN_FILES += ../../rtl/ip_eth_rx.v
SYN_FILES += ../../rtl/ip_eth_tx.v
SYN_FILES += ../../rtl/ip_arb_mux.v
SYN_FILES += ../../rtl/arp.v
SYN_FILES += ../../rtl/arp_cache.v
SYN_FILES += ../../rtl/arp_eth_rx.v
SYN_FILES += ../../rtl/arp_eth_tx.v
SYN_FILES += ../../rtl/eth_arb_mux.v
SYN_FILES += ../../lib/axis/rtl/arbiter.v
SYN_FILES += ../../lib/axis/rtl/priority_encoder.v
SYN_FILES += ../../lib/axis/rtl/axis_fifo.v
SYN_FILES += ../../lib/axis/rtl/axis_async_fifo.v
SYN_FILES += ../../lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += ../../lib/axis/rtl/sync_reset.v

# XDC files
XDC_FILES = fpga.xdc
XDC_FILES += ../../syn/vivado/eth_mac_fifo.tcl
XDC_FILES += ../../lib/axis/syn/vivado/axis_async_fifo.tcl
XDC_FILES += ../../lib/axis/syn/vivado/sync_reset.tcl

# IP
IP_TCL_FILES = ip/gig_ethernet_pcs_pma_0.tcl

include ../common/vivado.mk

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

