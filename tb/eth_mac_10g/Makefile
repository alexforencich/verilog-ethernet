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

DUT      = eth_mac_10g
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../rtl/axis_xgmii_rx_32.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_tx_32.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_rx_64.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_tx_64.v
VERILOG_SOURCES += ../../rtl/lfsr.v

# module parameters
export PARAM_DATA_WIDTH ?= 64
export PARAM_KEEP_WIDTH ?= $(shell expr $(PARAM_DATA_WIDTH) / 8 )
export PARAM_CTRL_WIDTH ?= $(shell expr $(PARAM_DATA_WIDTH) / 8 )
export PARAM_ENABLE_PADDING ?= 1
export PARAM_ENABLE_DIC ?= 1
export PARAM_MIN_FRAME_LENGTH ?= 64
export PARAM_PTP_PERIOD_NS ?= 6
export PARAM_PTP_PERIOD_FNS ?= 26214
export PARAM_TX_PTP_TS_ENABLE ?= 0
export PARAM_TX_PTP_TS_WIDTH ?= 96
export PARAM_TX_PTP_TAG_ENABLE ?= $(PARAM_TX_PTP_TS_ENABLE)
export PARAM_TX_PTP_TAG_WIDTH ?= 16
export PARAM_RX_PTP_TS_ENABLE ?= 0
export PARAM_RX_PTP_TS_WIDTH ?= 96
# export PARAM_TX_USER_WIDTH ?= (parameters['TX_PTP_TAG_WIDTH'] if parameters['TX_PTP_TAG_ENABLE'] else 0) + 1
export PARAM_TX_USER_WIDTH ?= 1
# export PARAM_RX_USER_WIDTH ?= (parameters['RX_PTP_TS_WIDTH'] if parameters['RX_PTP_TS_ENABLE'] else 0) + 1
export PARAM_RX_USER_WIDTH ?= 1

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).DATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).KEEP_WIDTH=$(PARAM_KEEP_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).CTRL_WIDTH=$(PARAM_CTRL_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).ENABLE_PADDING=$(PARAM_ENABLE_PADDING)
	COMPILE_ARGS += -P $(TOPLEVEL).ENABLE_DIC=$(PARAM_ENABLE_DIC)
	COMPILE_ARGS += -P $(TOPLEVEL).MIN_FRAME_LENGTH=$(PARAM_MIN_FRAME_LENGTH)
	COMPILE_ARGS += -P $(TOPLEVEL).PTP_PERIOD_NS=$(PARAM_PTP_PERIOD_NS)
	COMPILE_ARGS += -P $(TOPLEVEL).PTP_PERIOD_FNS=$(PARAM_PTP_PERIOD_FNS)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_PTP_TS_ENABLE=$(PARAM_TX_PTP_TS_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_PTP_TS_WIDTH=$(PARAM_TX_PTP_TS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_PTP_TAG_ENABLE=$(PARAM_TX_PTP_TAG_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_PTP_TAG_WIDTH=$(PARAM_TX_PTP_TAG_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).RX_PTP_TS_ENABLE=$(PARAM_RX_PTP_TS_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).RX_PTP_TS_WIDTH=$(PARAM_RX_PTP_TS_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_USER_WIDTH=$(PARAM_TX_USER_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).RX_USER_WIDTH=$(PARAM_RX_USER_WIDTH)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GDATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -GKEEP_WIDTH=$(PARAM_KEEP_WIDTH)
	COMPILE_ARGS += -GCTRL_WIDTH=$(PARAM_CTRL_WIDTH)
	COMPILE_ARGS += -GENABLE_PADDING=$(PARAM_ENABLE_PADDING)
	COMPILE_ARGS += -GENABLE_DIC=$(PARAM_ENABLE_DIC)
	COMPILE_ARGS += -GMIN_FRAME_LENGTH=$(PARAM_MIN_FRAME_LENGTH)
	COMPILE_ARGS += -GPTP_PERIOD_NS=$(PARAM_PTP_PERIOD_NS)
	COMPILE_ARGS += -GPTP_PERIOD_FNS=$(PARAM_PTP_PERIOD_FNS)
	COMPILE_ARGS += -GTX_PTP_TS_ENABLE=$(PARAM_TX_PTP_TS_ENABLE)
	COMPILE_ARGS += -GTX_PTP_TS_WIDTH=$(PARAM_TX_PTP_TS_WIDTH)
	COMPILE_ARGS += -GTX_PTP_TAG_ENABLE=$(PARAM_TX_PTP_TAG_ENABLE)
	COMPILE_ARGS += -GTX_PTP_TAG_WIDTH=$(PARAM_TX_PTP_TAG_WIDTH)
	COMPILE_ARGS += -GRX_PTP_TS_ENABLE=$(PARAM_RX_PTP_TS_ENABLE)
	COMPILE_ARGS += -GRX_PTP_TS_WIDTH=$(PARAM_RX_PTP_TS_WIDTH)
	COMPILE_ARGS += -GTX_USER_WIDTH=$(PARAM_TX_USER_WIDTH)
	COMPILE_ARGS += -GRX_USER_WIDTH=$(PARAM_RX_USER_WIDTH)

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
