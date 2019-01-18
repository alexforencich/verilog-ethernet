
# FPGA settings
FPGA_PART = xcku035-fbva676-2-e
FPGA_TOP = fpga
FPGA_ARCH = kintexu

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/sync_reset.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += lib/eth/rtl/eth_mac_10g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_10g.v
SYN_FILES += lib/eth/rtl/axis_xgmii_rx_64.v
SYN_FILES += lib/eth/rtl/axis_xgmii_tx_64.v
SYN_FILES += lib/eth/rtl/eth_phy_10g.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_frame_sync.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_ber_mon.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_tx.v
SYN_FILES += lib/eth/rtl/xgmii_baser_dec_64.v
SYN_FILES += lib/eth/rtl/xgmii_baser_enc_64.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx_64.v
SYN_FILES += lib/eth/rtl/eth_axis_tx_64.v
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
SYN_FILES += lib/eth/rtl/arp_64.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx_64.v
SYN_FILES += lib/eth/rtl/arp_eth_tx_64.v
SYN_FILES += lib/eth/rtl/eth_arb_mux.v
SYN_FILES += lib/eth/lib/axis/rtl/arbiter.v
SYN_FILES += lib/eth/lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo.v

# XDC files
XDC_FILES = fpga.xdc

# IP
XCI_FILES = ip/gtwizard_ultrascale_0.xci

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

