# Copyright (c) 2020 Alex Forencich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT      = ptp_perout
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v

# module parameters
export PARAM_FNS_ENABLE ?= 1
export PARAM_OUT_START_S ?= 0
export PARAM_OUT_START_NS ?= 0
export PARAM_OUT_START_FNS ?= 0
export PARAM_OUT_PERIOD_S ?= 1
export PARAM_OUT_PERIOD_NS ?= 0
export PARAM_OUT_PERIOD_FNS ?= 0
export PARAM_OUT_WIDTH_S ?= 0
export PARAM_OUT_WIDTH_NS ?= 1000
export PARAM_OUT_WIDTH_FNS ?= 0

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).FNS_ENABLE=$(PARAM_FNS_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_START_S=$(PARAM_OUT_START_S)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_START_NS=$(PARAM_OUT_START_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_START_FNS=$(PARAM_OUT_START_FNS)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_PERIOD_S=$(PARAM_OUT_PERIOD_S)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_PERIOD_NS=$(PARAM_OUT_PERIOD_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_PERIOD_FNS=$(PARAM_OUT_PERIOD_FNS)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_WIDTH_S=$(PARAM_OUT_WIDTH_S)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_WIDTH_NS=$(PARAM_OUT_WIDTH_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).OUT_WIDTH_FNS=$(PARAM_OUT_WIDTH_FNS)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GFNS_ENABLE=$(PARAM_FNS_ENABLE)
	COMPILE_ARGS += -GOUT_START_S=$(PARAM_OUT_START_S)
	COMPILE_ARGS += -GOUT_START_NS=$(PARAM_OUT_START_NS)
	COMPILE_ARGS += -GOUT_START_FNS=$(PARAM_OUT_START_FNS)
	COMPILE_ARGS += -GOUT_PERIOD_S=$(PARAM_OUT_PERIOD_S)
	COMPILE_ARGS += -GOUT_PERIOD_NS=$(PARAM_OUT_PERIOD_NS)
	COMPILE_ARGS += -GOUT_PERIOD_FNS=$(PARAM_OUT_PERIOD_FNS)
	COMPILE_ARGS += -GOUT_WIDTH_S=$(PARAM_OUT_WIDTH_S)
	COMPILE_ARGS += -GOUT_WIDTH_NS=$(PARAM_OUT_WIDTH_NS)
	COMPILE_ARGS += -GOUT_WIDTH_FNS=$(PARAM_OUT_WIDTH_FNS)

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
