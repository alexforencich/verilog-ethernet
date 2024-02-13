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

DUT      = eth_mac_10g_fifo
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../rtl/eth_mac_10g.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_rx_32.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_tx_32.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_rx_64.v
VERILOG_SOURCES += ../../rtl/axis_xgmii_tx_64.v
VERILOG_SOURCES += ../../rtl/lfsr.v
VERILOG_SOURCES += ../../rtl/ptp_clock_cdc.v
VERILOG_SOURCES += ../../lib/axis/rtl/axis_adapter.v
VERILOG_SOURCES += ../../lib/axis/rtl/axis_async_fifo.v
VERILOG_SOURCES += ../../lib/axis/rtl/axis_async_fifo_adapter.v

# module parameters
export PARAM_DATA_WIDTH := 64
export PARAM_CTRL_WIDTH := $(shell expr $(PARAM_DATA_WIDTH) / 8 )
export PARAM_AXIS_DATA_WIDTH := $(PARAM_DATA_WIDTH)
export PARAM_AXIS_KEEP_ENABLE := $(shell expr $(PARAM_AXIS_DATA_WIDTH) \> 8 )
export PARAM_AXIS_KEEP_WIDTH := $(shell expr $(PARAM_AXIS_DATA_WIDTH) / 8 )
export PARAM_ENABLE_PADDING := 1
export PARAM_ENABLE_DIC := 1
export PARAM_MIN_FRAME_LENGTH := 64
export PARAM_TX_FIFO_DEPTH := 16384
export PARAM_TX_FIFO_RAM_PIPELINE := 1
export PARAM_TX_FRAME_FIFO := 1
export PARAM_TX_DROP_OVERSIZE_FRAME := $(PARAM_TX_FRAME_FIFO)
export PARAM_TX_DROP_BAD_FRAME := $(PARAM_TX_DROP_OVERSIZE_FRAME)
export PARAM_TX_DROP_WHEN_FULL := 0
export PARAM_RX_FIFO_DEPTH := 16384
export PARAM_RX_FIFO_RAM_PIPELINE := 1
export PARAM_RX_FRAME_FIFO := 1
export PARAM_RX_DROP_OVERSIZE_FRAME := $(PARAM_RX_FRAME_FIFO)
export PARAM_RX_DROP_BAD_FRAME := $(PARAM_RX_DROP_OVERSIZE_FRAME)
export PARAM_RX_DROP_WHEN_FULL := $(PARAM_RX_DROP_OVERSIZE_FRAME)
export PARAM_PTP_TS_ENABLE := 1
export PARAM_PTP_TS_FMT_TOD := 1
export PARAM_PTP_TS_WIDTH := $(if $(filter-out 1,$(PARAM_PTP_TS_FMT_TOD)),64,96)
export PARAM_TX_PTP_TS_CTRL_IN_TUSER := $(PARAM_PTP_TS_ENABLE)
export PARAM_TX_PTP_TS_FIFO_DEPTH := 64
export PARAM_TX_PTP_TAG_ENABLE := $(PARAM_PTP_TS_ENABLE)
export PARAM_PTP_TAG_WIDTH := 16
export PARAM_TX_USER_WIDTH := $(if $(filter-out 1,$(PARAM_PTP_TS_ENABLE)),1,$(shell expr $(if $(filter-out 1,$(PARAM_TX_PTP_TAG_ENABLE)),0,$(PARAM_PTP_TAG_WIDTH)) + $(if $(filter-out 1,$(TX_PTP_TS_CTRL_IN_TUSER)),0,1) + 1 ))
export PARAM_RX_USER_WIDTH := $(if $(filter-out 1,$(PARAM_PTP_TS_ENABLE)),1,$(shell expr $(PARAM_PTP_TS_WIDTH) + 1 ))

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += $(foreach v,$(filter PARAM_%,$(.VARIABLES)),-P $(TOPLEVEL).$(subst PARAM_,,$(v))=$($(v)))

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += $(foreach v,$(filter PARAM_%,$(.VARIABLES)),-G$(subst PARAM_,,$(v))=$($(v)))

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
