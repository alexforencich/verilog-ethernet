# Copyright (c) 2021 Alex Forencich
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
export COCOTB_RESOLVE_X ?= RANDOM

DUT      = eth_phy_10g
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../rtl/$(DUT)_rx.v
VERILOG_SOURCES += ../../rtl/$(DUT)_rx_if.v
VERILOG_SOURCES += ../../rtl/$(DUT)_rx_ber_mon.v
VERILOG_SOURCES += ../../rtl/$(DUT)_rx_frame_sync.v
VERILOG_SOURCES += ../../rtl/$(DUT)_rx_watchdog.v
VERILOG_SOURCES += ../../rtl/$(DUT)_tx.v
VERILOG_SOURCES += ../../rtl/$(DUT)_tx_if.v
VERILOG_SOURCES += ../../rtl/xgmii_baser_dec_64.v
VERILOG_SOURCES += ../../rtl/xgmii_baser_enc_64.v
VERILOG_SOURCES += ../../rtl/lfsr.v

# module parameters
export PARAM_DATA_WIDTH ?= 64
export PARAM_CTRL_WIDTH ?= $(shell expr $(PARAM_DATA_WIDTH) / 8 )
export PARAM_HDR_WIDTH ?= 2
export PARAM_BIT_REVERSE ?= 0
export PARAM_SCRAMBLER_DISABLE ?= 0
export PARAM_PRBS31_ENABLE ?= 1
export PARAM_TX_SERDES_PIPELINE ?= 2
export PARAM_RX_SERDES_PIPELINE ?= 2
export PARAM_BITSLIP_HIGH_CYCLES ?= 1
export PARAM_BITSLIP_LOW_CYCLES ?= 8
export PARAM_COUNT_125US ?= 195

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).DATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).CTRL_WIDTH=$(PARAM_CTRL_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).HDR_WIDTH=$(PARAM_HDR_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).BIT_REVERSE=$(PARAM_BIT_REVERSE)
	COMPILE_ARGS += -P $(TOPLEVEL).SCRAMBLER_DISABLE=$(PARAM_SCRAMBLER_DISABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).PRBS31_ENABLE=$(PARAM_PRBS31_ENABLE)
	COMPILE_ARGS += -P $(TOPLEVEL).TX_SERDES_PIPELINE=$(PARAM_TX_SERDES_PIPELINE)
	COMPILE_ARGS += -P $(TOPLEVEL).RX_SERDES_PIPELINE=$(PARAM_RX_SERDES_PIPELINE)
	COMPILE_ARGS += -P $(TOPLEVEL).BITSLIP_HIGH_CYCLES=$(PARAM_BITSLIP_HIGH_CYCLES)
	COMPILE_ARGS += -P $(TOPLEVEL).BITSLIP_LOW_CYCLES=$(PARAM_BITSLIP_LOW_CYCLES)
	COMPILE_ARGS += -P $(TOPLEVEL).COUNT_125US=$(PARAM_COUNT_125US)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GDATA_WIDTH=$(PARAM_DATA_WIDTH)
	COMPILE_ARGS += -GCTRL_WIDTH=$(PARAM_CTRL_WIDTH)
	COMPILE_ARGS += -GHDR_WIDTH=$(PARAM_HDR_WIDTH)
	COMPILE_ARGS += -GBIT_REVERSE=$(PARAM_BIT_REVERSE)
	COMPILE_ARGS += -GSCRAMBLER_DISABLE=$(PARAM_SCRAMBLER_DISABLE)
	COMPILE_ARGS += -GPRBS31_ENABLE=$(PARAM_PRBS31_ENABLE)
	COMPILE_ARGS += -GTX_SERDES_PIPELINE=$(PARAM_TX_SERDES_PIPELINE)
	COMPILE_ARGS += -GRX_SERDES_PIPELINE=$(PARAM_RX_SERDES_PIPELINE)
	COMPILE_ARGS += -GBITSLIP_HIGH_CYCLES=$(PARAM_BITSLIP_HIGH_CYCLES)
	COMPILE_ARGS += -GBITSLIP_LOW_CYCLES=$(PARAM_BITSLIP_LOW_CYCLES)
	COMPILE_ARGS += -GCOUNT_125US=$(PARAM_COUNT_125US)

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
