# Tools
COREGEN:=coregen
XAW2VERILOG:=xaw2verilog

# Source
XCO:=ten_gig_eth_pcs_pma_v2_6.xco ten_gig_eth_pcs_pma_v2_6_v6gth_wrapper.xco
XAW:=

# Targets
TARGETS += $(XCO:.xco=)
TARGETS += $(XAW:.xaw=)

# Rules
.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-rm -rf $(TARGETS)

%: %.xco
	$(eval $@_TMP := $(shell mktemp -d))
	cp -a coregen.cgp $($@_TMP)
	cp -a $< $($@_TMP)
	cd $($@_TMP) && $(COREGEN) -p coregen.cgp -b $(notdir $<)
	mv $($@_TMP) $@

%: %.xaw
	$(eval $@_TMP := $(shell mktemp -d))
	cp -a coregen.cgp $($@_TMP)
	cp -a $< $($@_TMP)
	cd $($@_TMP) && $(XAW2VERILOG) -st $(notdir $<) $(notdir $*)
	mv $($@_TMP) $@
