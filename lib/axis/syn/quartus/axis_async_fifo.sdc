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

# AXI stream asynchronous FIFO timing constraints

proc constrain_axis_async_fifo_inst { inst } {
    puts "Inserting timing constraints for axis_async_fifo instance $inst"

    # reset synchronization
    set_false_path -from * -to [get_registers "$inst|s_rst_sync*_reg $inst|m_rst_sync*_reg"]

    if {[get_collection_size [get_registers -nowarn "$inst|s_rst_sync1_reg"]]} {
        set_max_delay  -from [get_registers "$inst|s_rst_sync1_reg"] -to [get_registers "$inst|s_rst_sync2_reg"] 8.000
    }

    if {[get_collection_size [get_registers -nowarn "$inst|m_rst_sync1_reg"]]} {
        set_max_delay  -from [get_registers "$inst|m_rst_sync1_reg"] -to [get_registers "$inst|m_rst_sync2_reg"] 8.000
    }

    # pointer synchronization
    set_max_delay -from [get_registers "$inst|rd_ptr_reg[*] $inst|rd_ptr_gray_reg[*]"] -to [get_registers "$inst|rd_ptr_gray_sync1_reg[*]"] 8.000
    set_max_delay -from [get_registers "$inst|wr_ptr_reg[*] $inst|wr_ptr_gray_reg[*] $inst|wr_ptr_sync_gray_reg[*]"] -to [get_registers "$inst|wr_ptr_gray_sync1_reg[*]"] 8.000

    # frame FIFO pointer update synchronization
    set_max_delay -from [get_registers "$inst|wr_ptr_update_reg"] -to [get_registers "$inst|wr_ptr_update_sync1_reg"] 8.000
    set_max_delay -from [get_registers "$inst|wr_ptr_update_sync3_reg"] -to [get_registers "$inst|wr_ptr_update_ack_sync1_reg"] 8.000

    # status synchronization
    foreach i {overflow bad_frame good_frame} {
        if {[get_collection_size [get_registers -nowarn "$inst|${i}_sync*_reg"]]} {
            set_max_delay -from [get_registers "$inst|${i}_sync1_reg"] -to [get_registers "$inst|${i}_sync2_reg"] 8.000
        }
    }
}
