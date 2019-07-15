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

# PTP timestamp capture module

foreach inst [get_cells -hier -filter {(ORIG_REF_NAME == ptp_clock_cdc || REF_NAME == ptp_clock_cdc)}] {
    puts "Inserting timing constraints for ptp_clock_cdc instance $inst"

    # get clock periods
    set input_clk [get_clocks -of_objects [get_pins $inst/wr_ptr_reg_reg[0]/C]]
    set output_clk [get_clocks -of_objects [get_pins $inst/rd_ptr_reg_reg[0]/C]]

    set input_clk_period [get_property -min PERIOD $input_clk]
    set output_clk_period [get_property -min PERIOD $output_clk]

    # pointer synchronization
    set_property ASYNC_REG TRUE [get_cells -hier -regexp ".*/(wr|rd)_ptr_gray_sync\[12\]_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    set_max_delay -from [get_cells "$inst/rd_ptr_reg_reg[*] $inst/rd_ptr_gray_reg_reg[*]"] -to [get_cells $inst/rd_ptr_gray_sync1_reg_reg[*]] -datapath_only $output_clk_period
    set_bus_skew  -from [get_cells "$inst/rd_ptr_reg_reg[*] $inst/rd_ptr_gray_reg_reg[*]"] -to [get_cells $inst/rd_ptr_gray_sync1_reg_reg[*]] $input_clk_period
    set_max_delay -from [get_cells "$inst/wr_ptr_reg_reg[*] $inst/wr_ptr_gray_reg_reg[*]"] -to [get_cells $inst/wr_ptr_gray_sync1_reg_reg[*]] -datapath_only $input_clk_period
    set_bus_skew  -from [get_cells "$inst/wr_ptr_reg_reg[*] $inst/wr_ptr_gray_reg_reg[*]"] -to [get_cells $inst/wr_ptr_gray_sync1_reg_reg[*]] $output_clk_period

    # output register (needed for distributed RAM sync write/async read)
    set output_reg_ffs [get_cells -quiet "$inst/mem_read_data_reg_reg[*]"]

    if {[llength $output_reg_ffs]} {
        set_false_path -from $input_clk -to $output_reg_ffs
    }

    # pointer synchronization (depth measurement)
    set sync_ffs [get_cells -quiet -hier -regexp ".*/rd_ptr_gray_sample_sync\[12\]_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/rd_ptr_gray_reg_reg[0]/C]]
        set dest_clk [get_clocks -of_objects [get_pins $inst/rd_ptr_gray_sample_sync1_reg_reg[0]/C]]

        set_max_delay -from [get_cells "$inst/rd_ptr_reg_reg[*] $inst/rd_ptr_gray_reg_reg[*]"] -to [get_cells $inst/rd_ptr_gray_sample_sync1_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
        set_bus_skew  -from [get_cells "$inst/rd_ptr_reg_reg[*] $inst/rd_ptr_gray_reg_reg[*]"] -to [get_cells $inst/rd_ptr_gray_sample_sync1_reg_reg[*]] [get_property -min PERIOD $dest_clk]
    }

    set sync_ffs [get_cells -quiet -hier -regexp ".*/wr_ptr_gray_sample_sync\[12\]_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/wr_ptr_gray_reg_reg[0]/C]]
        set dest_clk [get_clocks -of_objects [get_pins $inst/wr_ptr_gray_sample_sync1_reg_reg[0]/C]]

        set_max_delay -from [get_cells "$inst/wr_ptr_reg_reg[*] $inst/wr_ptr_gray_reg_reg[*]"] -to [get_cells $inst/wr_ptr_gray_sample_sync1_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
        set_bus_skew  -from [get_cells "$inst/wr_ptr_reg_reg[*] $inst/wr_ptr_gray_reg_reg[*]"] -to [get_cells $inst/wr_ptr_gray_sample_sync1_reg_reg[*]] [get_property -min PERIOD $dest_clk]
    }

    # sample update sync
    set sync_ffs [get_cells -quiet -hier -regexp ".*/sample_update_sync\[123\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/sample_update_reg_reg/C]]
        set dest_clk [get_clocks -of_objects [get_pins $inst/sample_update_sync1_reg_reg/C]]

        set_max_delay -from [get_cells $inst/sample_update_reg_reg] -to [get_cells $inst/sample_update_sync1_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]

        set_max_delay -from [get_cells "$inst/sample_avg_reg_reg[*]"] -to [get_cells $inst/sample_avg_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
        set_bus_skew  -from [get_cells "$inst/sample_avg_reg_reg[*]"] -to [get_cells $inst/sample_avg_sync_reg_reg[*]] [get_property -min PERIOD $dest_clk]
    }
}
