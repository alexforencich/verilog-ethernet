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

DUT      = ptp_clock
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v

# module parameters
export PARAM_PERIOD_NS_WIDTH ?= 4
export PARAM_OFFSET_NS_WIDTH ?= 4
export PARAM_DRIFT_NS_WIDTH ?= 4
export PARAM_FNS_WIDTH ?= 16
export PARAM_PERIOD_NS ?= 6
export PARAM_PERIOD_FNS ?= 26214
export PARAM_DRIFT_ENABLE ?= 1
export PARAM_DRIFT_NS ?= 0
export PARAM_DRIFT_FNS ?= 2
export PARAM_DRIFT_RATE ?= 5

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).PERIOD_NS_WIDTH=$(PARAM_PERIOD_NS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).OFFSET_NS_WIDTH=$(PARAM_OFFSET_NS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).DRIFT_NS_WIDTH=$(PARAM_DRIFT_NS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).FNS_WIDTH=$(PARAM_FNS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).PERIOD_NS=$(PARAM_PERIOD_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).PERIOD_FNS=$(PARAM_PERIOD_FNS)
	COMPILE_ARGS += -P $(TOPLEVEL).DRIFT_ENABLE=$(PARAM_DRIFT_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).DRIFT_NS=$(PARAM_DRIFT_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).DRIFT_FNS=$(PARAM_DRIFT_FNS)
	COMPILE_ARGS += -P $(TOPLEVEL).DRIFT_RATE=$(PARAM_DRIFT_RATE)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GPERIOD_NS_WIDTH=$(PARAM_PERIOD_NS_WIDTH)
	COMPILE_ARGS += -GOFFSET_NS_WIDTH=$(PARAM_OFFSET_NS_WIDTH)
	COMPILE_ARGS += -GDRIFT_NS_WIDTH=$(PARAM_DRIFT_NS_WIDTH)
	COMPILE_ARGS += -GFNS_WIDTH=$(PARAM_FNS_WIDTH)
	COMPILE_ARGS += -GPERIOD_NS=$(PARAM_PERIOD_NS)
	COMPILE_ARGS += -GPERIOD_FNS=$(PARAM_PERIOD_FNS)
	COMPILE_ARGS += -GDRIFT_ENABLE=$(PARAM_DRIFT_ENABLE)
	COMPILE_ARGS += -GDRIFT_NS=$(PARAM_DRIFT_NS)
	COMPILE_ARGS += -GDRIFT_FNS=$(PARAM_DRIFT_FNS)
	COMPILE_ARGS += -GDRIFT_RATE=$(PARAM_DRIFT_RATE)

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
