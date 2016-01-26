#############################################################################
# Author: Lane Brooks/Keith Fife
# Date: 04/28/2006
# License: GPL
# Desc: This is a Makefile intended to take a verilog rtl design
# through the Xilinx ISE tools to generate configuration files for
# Xilinx FPGAs. This file is generic and just a template. As such
# all design specific options such as synthesis files, fpga part type,
# prom part type, etc should be set in the top Makefile prior to
# including this file. Alternatively, all parameters can be passed
# in from the command line as well.
#
##############################################################################
#
# Parameter:
# SYN_FILES - Space seperated list of files to be synthesized
# PART - FPGA part (see Xilinx documentation)
# PROM - PROM part
# NGC_PATHS - Space seperated list of any dirs with pre-compiled ngc files.
# UCF_FILES - Space seperated list of user constraint files. Defaults to xilinx/$(FPGA_TOP).ucf
#
#
# Example Calling Makefile:
#
# SYN_FILES = fpga.v fifo.v clks.v
# PART = xc3s1000
# FPGA_TOP = fpga
# PROM = xc18v04
# NGC_PATH = ipLib1 ipLib2
# FPGA_ARCH = spartan6
# SPI_PROM_SIZE = (in bytes)
# include xilinx.mk
#############################################################################
#
# Command Line Example:
# make -f xilinx.mk PART=xc3s1000-4fg320 SYN_FILES="fpga.v test.v" FPGA_TOP=fpga
#
##############################################################################
#
# Required Setup:
#
# %.ucf - user constraint file. Needed by ngdbuild
#
# Optional Files:
# %.xcf - user constraint file. Needed by xst.
# %.ut - File for pin states needed by bitgen


.PHONY: clean bit prom fpga spi


# Mark the intermediate files as PRECIOUS to prevent make from
# deleting them (see make manual section 10.4).
.PRECIOUS: %.ngc %.ngd %_map.ncd %.ncd %.twr %.bit %_timesim.v

# include the local Makefile for project for any project specific targets
CONFIG ?= config.mk
-include ../$(CONFIG)

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ../%, $(INC_FILES))
INC_PATHS_REL = $(patsubst %, ../%, $(INC_PATHS))
NGC_PATHS_REL = $(patsubst %, ../%, $(NGC_PATHS))

ifdef UCF_FILES
  UCF_FILES_REL = $(patsubst %, ../%, $(UCF_FILES))
else
  UCF_FILES_REL = $(FPGA_TOP).ucf
endif



fpga: $(FPGA_TOP).bit

mcs: $(FPGA_TOP).mcs

prom: $(FPGA_TOP).spi

spi: $(FPGA_TOP).spi

fpgasim: $(FPGA_TOP)_sim.v


########################### XST TEMPLATES ############################
# There are 2 files that XST uses for synthesis that we auto generate.
# The first is a project file which is just a list of all the verilog
# files. The second is the src file which passes XST all the options.
# See XST user manual for XST options.
%.ngc: $(SYN_FILES_REL) $(INC_FILES_REL)
	rm -rf xst $*.prj $*.xst defines.v
	touch defines.v
	mkdir -p xst/tmp
	for x in $(DEFS); do echo '`define' $$x >> defines.v; done
	echo verilog work defines.v > $*.prj
	for x in $(SYN_FILES_REL); do echo verilog work $$x >> $*.prj; done
	@echo "set -tmpdir ./xst/tmp" >> $*.xst
	@echo "set -xsthdpdir ./xst" >> $*.xst
	@echo "run" >> $*.xst
	@echo "-ifn $*.prj" >> $*.xst
	@echo "-ifmt mixed" >> $*.xst
	@echo "-top $*" >> $*.xst
	@echo "-ofn $*" >> $*.xst
	@echo "-ofmt NGC" >> $*.xst
	@echo "-opt_mode Speed" >> $*.xst
	@echo "-opt_level 1" >> $*.xst
	# @echo "-verilog2001 YES" >> $*.xst
	@echo "-keep_hierarchy NO" >> $*.xst
	@echo "-p $(FPGA_PART)" >> $*.xst
	xst -ifn $*.xst -ofn $*.log


########################### ISE TRANSLATE ############################
# ngdbuild will automatically use a ucf called %.ucf if one is found.
# We setup the dependancy such that %.ucf file is required. If any
# pre-compiled ncd files are needed, set the NGC_PATH variable as a space
# seperated list of directories that include the pre-compiled ngc files.
%.ngd: %.ngc $(UCF_FILES_REL)
	ngdbuild -dd ngdbuild $(patsubst %,-sd %, $(NGC_PATHS_REL)) $(patsubst %,-uc %, $(UCF_FILES_REL)) -p $(FPGA_PART) $< $@


########################### ISE MAP ###################################
ifeq ($(FPGA_ARCH),spartan6)
  MAP_OPTS= -register_duplication on -timing -xe n
else
  MAP_OPTS= -cm speed -register_duplication on -timing -xe n -pr b
endif

%_map.ncd: %.ngd
	map -p $(FPGA_PART) $(MAP_OPTS) -w -o $@ $< $*.pcf
	
#	map -p $(FPGA_PART) -cm area -pr b -k 4 -c 100 -o $@ $< $*.pcf


########################### ISE PnR ###################################
%.ncd: %_map.ncd
	par -w -ol high $< $@ $*.pcf
	
#	par -w -ol std -t 1 $< $@ $*.pcf


##################### ISE Static Timing Analysis #####################
%.twr: %.ncd
	-trce -e 3 -l 3 -u -xml $* $< -o $@ $*.pcf

%_sim.v: %.ncd
	netgen -s 4 -pcf $*.pcf -sdf_anno true -ism -sdf_path netgen -w -dir . -ofmt verilog -sim $< $@
	
#	netgen -ise "/home/lane/Second/xilinx/Second/Second" -intstyle ise -s 4 -pcf Second.pcf -sdf_anno true -sdf_path netgen/par -w -dir netgen/par -ofmt verilog -sim Second.ncd Second_timesim.v


########################### ISE Bitgen #############################
%.bit: %.twr
	bitgen $(BITGEN_OPTIONS) -w $*.ncd $*.bit
	mkdir -p rev
	EXT=bit; COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.$$EXT ]; \
	do let COUNT=COUNT+1; done; \
	cp $@ rev/$*_rev$$COUNT.$$EXT; \
	echo "Output: rev/$*_rev$$COUNT.$$EXT";


########################### ISE Promgen #############################
%.mcs: %.bit
	promgen -spi -w -p mcs -s $(SPI_PROM_SIZE) -o $@ -u 0 $<
	# promgen -w -p mcs -c FF -o $@ -u 0 $< -x $(PROM)
	mkdir -p rev
	EXT=mcs; COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.$$EXT ]; \
	do let COUNT=COUNT+1; done; \
	cp $@ rev/$*_rev$$COUNT.$$EXT; \
	echo "Output: rev/$*_rev$$COUNT.$$EXT";


%.spi: %.mcs
	objcopy -I ihex -O binary $< $@
	EXT=spi; COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.$$EXT ]; \
	do let COUNT=COUNT+1; done; \
	cp $@ rev/$*_rev$$COUNT.$$EXT; \


tmpclean:
	-rm -rf xst ngdbuild *_map.* *.ncd *.ngc *.log *.xst *.prj *.lso *~ *.pcf *.bld *.ngd *.xpi *_pad.* *.unroutes *.twx *.par *.twr *.pad *.drc *.bgn *.prm *.sig netgen *.v *.nlf *.xml

clean: tmpclean
	-rm -rf *.bit *.mcs

# clean everything
distclean: clean
	-rm -rf rev

