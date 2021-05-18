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

# GMII Gigabit Ethernet MAC timing constraints

foreach mac_inst [get_cells -hier -filter {(ORIG_REF_NAME == eth_mac_1g_gmii || REF_NAME == eth_mac_1g_gmii)}] {
    puts "Inserting timing constraints for eth_mac_1g_gmii instance $mac_inst"

    set select_ffs [get_cells -hier -regexp ".*/tx_mii_select_sync_reg\\\[\\d\\\]" -filter "PARENT == $mac_inst"]

    if {[llength $select_ffs]} {
        set_property ASYNC_REG TRUE $select_ffs

        set src_clk [get_clocks -of_objects [get_pins $mac_inst/mii_select_reg_reg/C]]

        set_max_delay -from [get_cells $mac_inst/mii_select_reg_reg] -to [get_cells $mac_inst/tx_mii_select_sync_reg[0]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set select_ffs [get_cells -hier -regexp ".*/rx_mii_select_sync_reg\\\[\\d\\\]" -filter "PARENT == $mac_inst"]

    if {[llength $select_ffs]} {
        set_property ASYNC_REG TRUE $select_ffs

        set src_clk [get_clocks -of_objects [get_pins $mac_inst/mii_select_reg_reg/C]]

        set_max_delay -from [get_cells $mac_inst/mii_select_reg_reg] -to [get_cells $mac_inst/rx_mii_select_sync_reg[0]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set prescale_ffs [get_cells -hier -regexp ".*/rx_prescale_sync_reg\\\[\\d\\\]" -filter "PARENT == $mac_inst"]

    if {[llength $prescale_ffs]} {
        set_property ASYNC_REG TRUE $prescale_ffs

        set src_clk [get_clocks -of_objects [get_pins $mac_inst/rx_prescale_reg[2]/C]]

        set_max_delay -from [get_cells $mac_inst/rx_prescale_reg[2]] -to [get_cells $mac_inst/rx_prescale_sync_reg[0]] -datapath_only [get_property -min PERIOD $src_clk]
    }
}
