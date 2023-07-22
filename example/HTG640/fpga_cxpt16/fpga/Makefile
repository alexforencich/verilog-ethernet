
# FPGA settings
FPGA_PART = xc6vhx565t-2ff1923
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
SYN_FILES += rtl/i2c_master.v
SYN_FILES += rtl/gth_i2c_init.v
SYN_FILES += rtl/eth_gth_phy_quad.v
SYN_FILES += lib/eth/rtl/eth_mac_10g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_10g.v
SYN_FILES += lib/eth/rtl/axis_xgmii_rx_64.v
SYN_FILES += lib/eth/rtl/axis_xgmii_tx_64.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_crosspoint.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += lib/eth/lib/axis/rtl/sync_reset.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6/ten_gig_eth_pcs_pma_v2_6.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6/ten_gig_eth_pcs_pma_v2_6/example_design/ten_gig_eth_pcs_pma_v2_6_management_arbiter.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_quad.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_gth_reset.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_gth_init.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_gth_tx_pcs_reset.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_gth_rx_pcs_cdr_reset.v
SYN_FILES += coregen/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper/ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper_pulse_synchronizer.v

# UCF files
UCF_FILES = fpga.ucf

# NGC paths for ngdbuild
NGC_PATHS = coregen/ten_gig_eth_pcs_pma_v2_6

# Bitgen options
BITGEN_OPTIONS = -g StartupClk:Cclk -g ConfigRate:26

include ../common/xilinx.mk

program: $(FPGA_TOP).bit
	echo "setmode -bscan" > program.cmd
	echo "setcable -p auto" >> program.cmd
	echo "identify" >> program.cmd
	echo "assignfile -p 1 -file $(FPGA_TOP).bit" >> program.cmd
	echo "program -p 1" >> program.cmd
	echo "quit" >> program.cmd
	impact -batch program.cmd

program_flash: $(FPGA_TOP).mcs
	echo "setmode -bscan" > program.cmd
	echo "setcable -p auto" >> program.cmd
	echo "identify" >> program.cmd
	echo "assignfile -p 1 -file $(FPGA_TOP).mcs" >> program.cmd
	echo "program -p 1 -e" >> program.cmd
	echo "quit" >> program.cmd
	impact -batch program.cmd

