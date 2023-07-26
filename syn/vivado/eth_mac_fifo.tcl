# Copyright (c) 2019 Alex Forencich
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

# Ethernet MAC with FIFO timing constraints

foreach mac_inst [get_cells -hier -filter {(ORIG_REF_NAME == eth_mac_1g_fifo || REF_NAME == eth_mac_1g_fifo || \
            ORIG_REF_NAME == eth_mac_10g_fifo || REF_NAME == eth_mac_10g_fifo || \
            ORIG_REF_NAME == eth_mac_1g_gmii_fifo || REF_NAME == eth_mac_1g_gmii_fifo || \
            ORIG_REF_NAME == eth_mac_1g_rgmii_fifo || REF_NAME == eth_mac_1g_rgmii_fifo || \
            ORIG_REF_NAME == eth_mac_mii_fifo || REF_NAME == eth_mac_mii_fifo)}] {
    puts "Inserting timing constraints for ethernet MAC with FIFO instance $mac_inst"

    set sync_ffs [get_cells -hier -regexp ".*/rx_sync_reg_\[1234\]_reg\\\[\\d+\\\]" -filter "PARENT == $mac_inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $mac_inst/rx_sync_reg_1_reg[*]/C]]

        set src_clk_period [if {[llength $src_clk]} {get_property -min PERIOD $src_clk} {expr 8.0}]

        set_max_delay -from [get_cells $mac_inst/rx_sync_reg_1_reg[*]] -to [get_cells $mac_inst/rx_sync_reg_2_reg[*]] -datapath_only $src_clk_period
    }

    set sync_ffs [get_cells -hier -regexp ".*/tx_sync_reg_\[1234\]_reg\\\[\\d+\\\]" -filter "PARENT == $mac_inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $mac_inst/tx_sync_reg_1_reg[*]/C]]

        set src_clk_period [if {[llength $src_clk]} {get_property -min PERIOD $src_clk} {expr 8.0}]

        set_max_delay -from [get_cells $mac_inst/tx_sync_reg_1_reg[*]] -to [get_cells $mac_inst/tx_sync_reg_2_reg[*]] -datapath_only $src_clk_period
    }
}
