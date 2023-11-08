# Copyright (c) 2023 Alex Forencich
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

# Transceiver configuration
set eth_xcvr_freerun_freq {125}
set eth_xcvr_line_rate {25.78125}
set eth_xcvr_sec_line_rate {0}
set eth_xcvr_refclk_freq {161.1328125}
set eth_xcvr_qpll_fracn [expr {int(fmod($eth_xcvr_line_rate*1000/2 / $eth_xcvr_refclk_freq, 1)*pow(2, 24))}]
set eth_xcvr_sec_qpll_fracn [expr {int(fmod($eth_xcvr_sec_line_rate*1000/2 / $eth_xcvr_refclk_freq, 1)*pow(2, 24))}]
set eth_xcvr_rx_eq_mode {DFE}

set xcvr_config [dict create]

dict set xcvr_config CONFIG.TX_LINE_RATE $eth_xcvr_line_rate
dict set xcvr_config CONFIG.TX_QPLL_FRACN_NUMERATOR $eth_xcvr_qpll_fracn
dict set xcvr_config CONFIG.TX_REFCLK_FREQUENCY $eth_xcvr_refclk_freq
dict set xcvr_config CONFIG.RX_LINE_RATE $eth_xcvr_line_rate
dict set xcvr_config CONFIG.RX_QPLL_FRACN_NUMERATOR $eth_xcvr_qpll_fracn
dict set xcvr_config CONFIG.RX_REFCLK_FREQUENCY $eth_xcvr_refclk_freq
dict set xcvr_config CONFIG.RX_EQ_MODE $eth_xcvr_rx_eq_mode
if {$eth_xcvr_sec_line_rate != 0} {
    dict set xcvr_config CONFIG.SECONDARY_QPLL_ENABLE true
    dict set xcvr_config CONFIG.SECONDARY_QPLL_FRACN_NUMERATOR $eth_xcvr_sec_qpll_fracn
    dict set xcvr_config CONFIG.SECONDARY_QPLL_LINE_RATE $eth_xcvr_sec_line_rate
    dict set xcvr_config CONFIG.SECONDARY_QPLL_REFCLK_FREQUENCY $eth_xcvr_refclk_freq
} else {
    dict set xcvr_config CONFIG.SECONDARY_QPLL_ENABLE false
}
dict set xcvr_config CONFIG.FREERUN_FREQUENCY $eth_xcvr_freerun_freq

set_property -dict $xcvr_config [get_ips eth_xcvr_gt_full]
set_property -dict $xcvr_config [get_ips eth_xcvr_gt_channel]
