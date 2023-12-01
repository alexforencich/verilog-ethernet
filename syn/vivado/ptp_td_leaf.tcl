# Copyright (c) 2019-2023 Alex Forencich
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

# PTP time distribution leaf module

foreach inst [get_cells -hier -regexp -filter {(ORIG_REF_NAME =~ "ptp_td_leaf(__\w+__\d+)?" ||
        REF_NAME =~ "ptp_td_leaf(__\w+__\d+)?")}] {
    puts "Inserting timing constraints for ptp_td_leaf instance $inst"

    # get clock periods
    set input_clk [get_clocks -of_objects [get_pins "$inst/src_sync_reg_reg/C"]]
    set output_clk [get_clocks -of_objects [get_pins "$inst/dst_sync_reg_reg/C"]]

    set input_clk_period [if {[llength $input_clk]} {get_property -min PERIOD $input_clk} {expr 1.0}]
    set output_clk_period [if {[llength $output_clk]} {get_property -min PERIOD $output_clk} {expr 1.0}]

    # TD data sync
    set_property ASYNC_REG TRUE [get_cells -hier -regexp ".*/dst_td_(tdata|tid)_reg_reg(\\\[\\d+\\\])?" -filter "PARENT == $inst"]

    set_max_delay -from [get_cells "$inst/td_tdata_reg_reg[*]"] -to [get_cells "$inst/dst_td_tdata_reg_reg[*]"] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "$inst/td_tdata_reg_reg[*]"] -to [get_cells "$inst/dst_td_tdata_reg_reg[*]"] $input_clk_period
    set_max_delay -from [get_cells "$inst/td_tid_reg_reg[*]"] -to [get_cells "$inst/dst_td_tid_reg_reg[*]"] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "$inst/td_tid_reg_reg[*]"] -to [get_cells "$inst/dst_td_tid_reg_reg[*]"] $input_clk_period

    set sync_ffs [get_cells -quiet -hier -regexp ".*/td_sync_sync\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set_max_delay -from [get_cells "$inst/td_sync_reg_reg"] -to [get_cells "$inst/td_sync_sync1_reg_reg"] -datapath_only $input_clk_period
    }

    # timestamp sync
    set_property ASYNC_REG TRUE [get_cells -hier -regexp ".*/src_ns_sync_reg_reg(\\\[\\d+\\\])?" -filter "PARENT == $inst"]

    set_max_delay -from [get_cells "$inst/src_ns_reg_reg[*]"] -to [get_cells "$inst/src_ns_sync_reg_reg[*]"] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "$inst/src_ns_reg_reg[*]"] -to [get_cells "$inst/src_ns_sync_reg_reg[*]"] $input_clk_period

    # sample clock
    set sync_ffs [get_cells -quiet -hier -regexp ".*/src_sync_sample_sync\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set_max_delay -from [get_cells "$inst/src_sync_reg_reg"] -to [get_cells "$inst/src_sync_sample_sync1_reg_reg"] -datapath_only $input_clk_period
    }

    set sync_ffs [get_cells -quiet -hier -regexp ".*/dst_sync_sample_sync\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set_max_delay -from [get_cells "$inst/dst_sync_reg_reg"] -to [get_cells "$inst/dst_sync_sample_sync1_reg_reg"] -datapath_only $output_clk_period
    }

    # sample update sync
    set sync_ffs [get_cells -quiet -hier -regexp ".*/sample_update_sync\[123\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins "$inst/sample_update_reg_reg/C"]]

        set src_clk_period [if {[llength $src_clk]} {get_property -min PERIOD $src_clk} {expr 1.0}]

        set_max_delay -from [get_cells "$inst/sample_update_reg_reg"] -to [get_cells "$inst/sample_update_sync1_reg_reg"] -datapath_only $src_clk_period

        set_max_delay -from [get_cells "$inst/sample_acc_out_reg_reg[*]"] -to [get_cells $inst/sample_acc_sync_reg_reg[*]] -datapath_only $src_clk_period
        set_bus_skew  -from [get_cells "$inst/sample_acc_out_reg_reg[*]"] -to [get_cells $inst/sample_acc_sync_reg_reg[*]] $output_clk_period
    }

    # timestamp transfer sync
    set sync_ffs [get_cells -quiet -hier -regexp ".*/src_sync_sync\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set_max_delay -from [get_cells "$inst/src_sync_reg_reg"] -to [get_cells "$inst/src_sync_sync1_reg_reg"] -datapath_only $input_clk_period
    }

    set sync_ffs [get_cells -quiet -hier -regexp ".*/src_marker_sync\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set_max_delay -from [get_cells "$inst/src_marker_reg_reg"] -to [get_cells "$inst/src_marker_sync1_reg_reg"] -datapath_only $input_clk_period
    }
}
