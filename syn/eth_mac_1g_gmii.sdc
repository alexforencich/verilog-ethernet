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

# GMII Gigabit Ethernet MAC timing constraints

proc constrain_eth_mac_1g_gmii_inst { inst } {
    puts "Inserting timing constraints for eth_mac_1g_gmii instance $inst"

    # MII select sync
    set_max_delay -from [get_registers "$inst|mii_select_reg"] -to [get_registers "$inst|tx_mii_select_sync[0]"] 8.000
    set_max_delay -from [get_registers "$inst|mii_select_reg"] -to [get_registers "$inst|rx_mii_select_sync[0]"] 8.000

    # RX prescale sync
    set_max_delay -from [get_registers "$inst|rx_prescale[2]"] -to [get_registers "$inst|rx_prescale_sync[0]"] 8.000

    constrain_gmii_phy_if_inst "$inst|gmii_phy_if_inst"
}
