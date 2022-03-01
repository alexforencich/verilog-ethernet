###################################################################
#
# Makefile for Intel Quartus Prime Pro
#
# Alex Forencich
#
###################################################################
#
# Parameters:
# FPGA_TOP - Top module name
# FPGA_FAMILY - FPGA family (e.g. Stratix 10 DX)
# FPGA_DEVICE - FPGA device (e.g. 1SD280PT2F55E1VG)
# SYN_FILES - space-separated list of source files
# IP_FILES - space-separated list of IP files
# IP_TCL_FILES - space-separated list of TCL files for qsys-script
# QSF_FILES - space-separated list of settings files
# SDC_FILES - space-separated list of timing constraint files
#
# Example:
#
# FPGA_TOP = fpga
# FPGA_FAMILY = "Stratix 10 DX"
# FPGA_DEVICE = 1SD280PT2F55E1VG
# SYN_FILES = rtl/fpga.v
# QSF_FILES = fpga.qsf
# SDC_FILES = fpga.sdc
# include ../common/quartus_pro.mk
#
###################################################################

# phony targets
.PHONY: clean fpga

# output files to hang on to
.PRECIOUS: %.sof %.ipregen.rpt %.syn.rpt %.fit.rpt %.asm.rpt %.sta.rpt
.SECONDARY:

# any project specific settings
CONFIG ?= config.mk
-include ../$(CONFIG)

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))

IP_FILES_REL = $(patsubst %, ../%, $(IP_FILES))
IP_FILES_INT = $(patsubst %, ip/%, $(notdir $(IP_FILES)))

IP_TCL_FILES_REL = $(patsubst %, ../%, $(IP_TCL_FILES))
IP_TCL_FILES_INT = $(patsubst %, ip/%, $(notdir $(IP_TCL_FILES)))
IP_TCL_FILES_IP_INT = $(patsubst %.tcl, ip/%.ip, $(notdir $(IP_TCL_FILES)))

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

quartus: $(FPGA_TOP).qpf
	quartus $(FPGA_TOP).qpf

tmpclean:
	-rm -rf defines.v
	-rm -rf *.rpt *.summary *.done *.smsg *.chg smart.log *.htm *.eqn *.pin *.qsf *.qpf *.sld *.txt *.qws *.stp
	-rm -rf ip db qdb incremental_db reconfig_mif tmp-clearbox synth_dumps .qsys_edit

clean: tmpclean
	-rm -rf *.sof *.pof *.jdi *.jic *.map

distclean: clean
	-rm -rf rev

syn: smart.log output_files/$(PROJECT).syn.rpt
fit: smart.log output_files/$(PROJECT).fit.rpt
asm: smart.log output_files/$(PROJECT).asm.rpt
sta: smart.log output_files/$(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

IP_ARGS  = --run_default_mode_op
SYN_ARGS = --read_settings_files=on --write_settings_files=off
FIT_ARGS = --read_settings_files=on --write_settings_files=off
ASM_ARGS = --read_settings_files=on --write_settings_files=off
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

define COPY_IP_RULE
$(patsubst %, ip/%, $(notdir $(1))): $(1)
	@mkdir -p ip
	@cp -pv $(1) ip/
endef
$(foreach l,$(IP_FILES_REL) $(IP_TCL_FILES_REL),$(eval $(call COPY_IP_RULE,$(l))))

define TCL_IP_GEN_RULE
$(patsubst %.tcl, %.ip, $(1)): $(1)
	cd ip && qsys-script --script=$(notdir $(1))
endef
$(foreach l,$(IP_TCL_FILES_INT),$(eval $(call TCL_IP_GEN_RULE,$(l))))

%.ipregen.rpt: $(FPGA_TOP).qpf $(IP_FILES_INT) $(IP_TCL_FILES_IP_INT)
	quartus_ipgenerate $(IP_ARGS) $(FPGA_TOP)

%.syn.rpt: syn.chg %.ipregen.rpt $(SYN_FILES_REL)
	quartus_syn $(SYN_ARGS) $(FPGA_TOP)

%.fit.rpt: fit.chg %.syn.rpt $(SDC_FILES_REL)
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

$(ASSIGNMENT_FILES): $(QSF_FILES_REL) $(IP_FILES_INT) $(IP_TCL_FILES_IP_INT)
	rm -f $(FPGA_TOP).qsf
	quartus_sh --prepare -f $(FPGA_FAMILY) -d $(FPGA_DEVICE) -t $(FPGA_TOP) $(FPGA_TOP)
	echo >> $(FPGA_TOP).qsf
	echo >> $(FPGA_TOP).qsf
	echo "# Source files" >> $(FPGA_TOP).qsf
	for x in $(SYN_FILES_REL) $(IP_FILES_INT) $(IP_TCL_FILES_IP_INT); do \
		case $${x##*.} in \
			v|V) echo set_global_assignment -name VERILOG_FILE $$x >> $(FPGA_TOP).qsf ;;\
			vhd|VHD) echo set_global_assignment -name VHDL_FILE $$x >> $(FPGA_TOP).qsf ;;\
			qip|QIP) echo set_global_assignment -name QIP_FILE $$x >> $(FPGA_TOP).qsf ;;\
			ip|IP) echo set_global_assignment -name IP_FILE $$x >> $(FPGA_TOP).qsf ;;\
			*) echo set_global_assignment -name SOURCE_FILE $$x >> $(FPGA_TOP).qsf ;;\
		esac; \
	done
	echo >> $(FPGA_TOP).qsf
	echo "# SDC files" >> $(FPGA_TOP).qsf
	for x in $(SDC_FILES_REL); do echo set_global_assignment -name SDC_FILE $$x >> $(FPGA_TOP).qsf; done
	for x in $(QSF_FILES_REL); do printf "\n#\n# Included QSF file $$x\n#\n" >> $(FPGA_TOP).qsf; cat $$x >> $(FPGA_TOP).qsf; done

syn.chg:
	$(STAMP) syn.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg
