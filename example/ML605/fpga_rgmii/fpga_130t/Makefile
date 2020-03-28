
# FPGA settings
FPGA_PART = xc6vlx130t-1ff1156
FPGA_TOP = fpga
FPGA_ARCH = spartan6

# PROM settings
#PROM = xc18v04
#SPI_PROM_SIZE = (in bytes)

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += lib/eth/rtl/iddr.v
SYN_FILES += lib/eth/rtl/oddr.v
SYN_FILES += lib/eth/rtl/ssio_ddr_in.v
SYN_FILES += lib/eth/rtl/ssio_ddr_out.v
SYN_FILES += lib/eth/rtl/rgmii_phy_if.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_rgmii_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_rgmii.v
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
SYN_FILES += lib/eth/rtl/ip_arb_mux.v
SYN_FILES += lib/eth/rtl/arp.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx.v
SYN_FILES += lib/eth/rtl/arp_eth_tx.v
SYN_FILES += lib/eth/rtl/eth_arb_mux.v
SYN_FILES += lib/eth/lib/axis/rtl/arbiter.v
SYN_FILES += lib/eth/lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += lib/eth/lib/axis/rtl/sync_reset.v
#SYN_FILES += coregen/dcm_i100_o125/dcm_i100_o125.v

# UCF files
UCF_FILES = fpga.ucf
UCF_FILES += clock.ucf

# NGC paths for ngdbuild
#NGC_PATHS = coregen/dcm_i100_o125

# Bitgen options
BITGEN_OPTIONS = -g StartupClk:Cclk -g ConfigRate:26

include ../common/xilinx.mk

program: $(FPGA_TOP).bit
	echo "setmode -bscan" > program.cmd
	echo "setcable -p auto" >> program.cmd
	echo "identify" >> program.cmd
	echo "assignfile -p 2 -file $(FPGA_TOP).bit" >> program.cmd
	echo "program -p 2" >> program.cmd
	echo "quit" >> program.cmd
	impact -batch program.cmd

