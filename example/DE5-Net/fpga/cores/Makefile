# Tools
QMEGAWIZ=qmegawiz

# Sources
QMWSRC=phy.v
QMWSRC+=phy_reconfig.v

# Targets
TARGETS=$(QMWSRC:.v=)

# Rules
.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	-rm -rf $(TARGETS)

%: %.v
	mkdir -p $@
	cp -a $< $@
	cd $@ && $(QMEGAWIZ) -silent $<

