###################################################################
# 
# Altera FPGA Makefile
# 
# Alex Forencich
# 
###################################################################
# 
# Parameters:
# FPGA_TOP - Top module name
# FPGA_FAMILY - FPGA family (e.g. Stratix V)
# FPGA_DEVICE - FPGA device (e.g. 5SGXEA7N2F45C2)
# SYN_FILES - space-separated list of source files
# QSF_FILES - space-separated list of settings files
# SDC_FILES - space-separated list of timing constraint files
# 
# Example:
# 
# FPGA_TOP = fpga
# FPGA_FAMILY = "Stratix V"
# FPGA_DEVICE = 5SGXEA7N2F45C2
# SYN_FILES = rtl/fpga.v rtl/clocks.v
# QSF_FILES = fpga.qsf
# SDC_FILES = fpga.sdc
# include ../common/altera.mk
# 
###################################################################

# phony targets
.PHONY: clean fpga

# output files to hang on to
.PRECIOUS: %.sof %.map.rpt %.fit.rpt %.asm.rpt %.sta.rpt

# any project specific settings
-include ../config.mk

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))

ifdef QSF_FILES
  QSF_FILES_REL = $(patsubst %, ../%, $(QSF_FILES))
else
  QSF_FILES_REL = ../$(FPGA_TOP).qsf
endif

SDC_FILES_REL = $(patsubst %, ../%, $(SDC_FILES))

ASSIGNMENT_FILES = $(FPGA_TOP).qpf $(FPGA_TOP).qsf 

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: fpga

fpga: $(FPGA_TOP).sof

clean:
	rm -rf *.rpt *.summary *.smsg *.chg smart.log *.htm *.eqn *.pin *.sof *.pof *.qsf *.qpf *.jdi *.sld *.txt db incremental_db reconfig_mif

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --family=$(FPGA_FAMILY)
FIT_ARGS = --part=$(FPGA_DEVICE)
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

%.map.rpt: map.chg $(SYN_FILES_REL)
	quartus_map $(MAP_ARGS) $(FPGA_TOP)

%.fit.rpt: fit.chg %.map.rpt
	quartus_fit $(FIT_ARGS) $(FPGA_TOP)

%.sta.rpt: sta.chg %.fit.rpt
	quartus_sta $(STA_ARGS) $(FPGA_TOP)

%.asm.rpt: asm.chg %.sta.rpt
	quartus_asm $(ASM_ARGS) $(FPGA_TOP)
	mkdir -p rev
	EXT=sof; COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.$$EXT ]; \
	do let COUNT=COUNT+1; done; \
	cp $*.$$EXT rev/$*_rev$$COUNT.$$EXT; \
	echo "Output: rev/$*_rev$$COUNT.$$EXT";

%.sof: smart.log %.asm.rpt
	

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(FPGA_TOP) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES): $(QSF_FILES_REL) $(SYN_FILES_REL)
	rm -f $(FPGA_TOP).qsf
	quartus_sh --prepare -f $(FPGA_FAMILY) -d $(FPGA_DEVICE) -t $(FPGA_TOP) $(FPGA_TOP)
	echo >> $(FPGA_TOP).qsf
	echo >> $(FPGA_TOP).qsf
	echo "# Source files" >> $(FPGA_TOP).qsf
	for x in $(SYN_FILES_REL); do \
		case $${x##*.} in \
			v|V) echo set_global_assignment -name VERILOG_FILE $$x >> $(FPGA_TOP).qsf ;;\
			vhd|VHD) echo set_global_assignment -name VHDL_FILE $$x >> $(FPGA_TOP).qsf ;;\
			qip|QIP) echo set_global_assignment -name QIP_FILE $$x >> $(FPGA_TOP).qsf ;;\
			*) echo set_global_assignment -name SOURCE_FILE $$x >> $(FPGA_TOP).qsf ;;\
		esac; \
	done
	echo >> $(FPGA_TOP).qsf
	echo "# SDC files" >> $(FPGA_TOP).qsf
	for x in $(SDC_FILES_REL); do echo set_global_assignment -name SDC_FILE $$x >> $(FPGA_TOP).qsf; done
	for x in $(QSF_FILES_REL); do printf "\n#\n# Included QSF file $$x\n#\n" >> $(FPGA_TOP).qsf; cat $$x >> $(FPGA_TOP).qsf; done

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg


