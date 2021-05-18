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

# RGMII PHY IF timing constraints

foreach if_inst [get_cells -hier -filter {(ORIG_REF_NAME == rgmii_phy_if || REF_NAME == rgmii_phy_if)}] {
    puts "Inserting timing constraints for rgmii_phy_if instance $if_inst"

    # reset synchronization
    set reset_ffs [get_cells -hier -regexp ".*/(rx|tx)_rst_reg_reg\\\[\\d\\\]" -filter "PARENT == $if_inst"]

    set_property ASYNC_REG TRUE $reset_ffs
    set_false_path -to [get_pins -of_objects $reset_ffs -filter {IS_PRESET || IS_RESET}]

    # clock output
    set_property ASYNC_REG TRUE [get_cells $if_inst/clk_oddr_inst/oddr[0].oddr_inst]

    set src_clk [get_clocks -of_objects [get_pins $if_inst/rgmii_tx_clk_1_reg/C]]

    set_max_delay -from [get_cells $if_inst/rgmii_tx_clk_1_reg] -to [get_cells $if_inst/clk_oddr_inst/oddr[0].oddr_inst] -datapath_only [expr [get_property -min PERIOD $src_clk]/4]
    set_max_delay -from [get_cells $if_inst/rgmii_tx_clk_2_reg] -to [get_cells $if_inst/clk_oddr_inst/oddr[0].oddr_inst] -datapath_only [expr [get_property -min PERIOD $src_clk]/4]
}
