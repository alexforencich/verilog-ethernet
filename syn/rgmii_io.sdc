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

# RGMII IO timing constraints

proc constrain_rgmii_input_pins { name clk_pin data_pins } {
    puts "Inserting timing constraints for RGMII input pins $name"
    puts "RGMII clock pin: $clk_pin"
    puts "RGMII data pins: $data_pins"
    
    #Virtual clock has no phase shift
    create_clock -name "virt_${name}_rx_clk_125m" -period 8.000
    # create_clock -name "virt_${name}_rx_clk_25m" -period 40.000
    # create_clock -name "virt_${name}_rx_clk_2m5" -period 400.000

    #input clock has 90 degree phase shift
    create_clock -name "${name}_rx_clk_125m" -period 8.000 "$clk_pin" -waveform {2 6}
    # create_clock -name "${name}_rx_clk_25m" -period 40.000 "$clk_pin" -waveform {10 30} -add
    # create_clock -name "${name}_rx_clk_2m5" -period 400.000 "$clk_pin" -waveform {100 300} -add

    ## Constraint the path to the rising/falling edge of the phy clock
    ## setup time: 2ns-0.75ns=1.25ns, 0.75ns skew,
    ## hold time: 0.75ns skew, 2-1.5-0.75=-0.25ns
    ## clock edge is 1.5 ns delay with data
    set_input_delay -add_delay -clock "virt_${name}_rx_clk_125m" -max 1.25 [get_ports "$data_pins"]
    set_input_delay -add_delay -clock "virt_${name}_rx_clk_125m" -min -0.25 [get_ports "$data_pins"]
    set_input_delay -add_delay -clock "virt_${name}_rx_clk_125m" -clock_fall -max 1.25 [get_ports "$data_pins"]
    set_input_delay -add_delay -clock "virt_${name}_rx_clk_125m" -clock_fall -min -0.25 [get_ports "$data_pins"]

    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_25m" -max 1.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_25m" -min -0.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_25m" -clock_fall -max 1.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_25m" -clock_fall -min -0.25 [get_ports "$data_pins"]

    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_2m5" -max 1.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_2m5" -min -0.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_2m5" -clock_fall -max 1.25 [get_ports "$data_pins"]
    # set_input_delay -add_delay -clock "virt_${name}_rx_clk_2m5" -clock_fall -min -0.25 [get_ports "$data_pins"]

    # set_clock_groups \
    #     -exclusive \
    #     -group [get_clocks "${name}_rx_clk_125m"] \
    #     -group [get_clocks "${name}_rx_clk_25m"] \
    #     -group [get_clocks "${name}_rx_clk_2m5"]

    # set_clock_groups \
    #     -exclusive \
    #     -group "virt_${name}_rx_clk_125m ${name}_rx_clk_125m" \
    #     -group "virt_${name}_rx_clk_25m ${name}_rx_clk_25m" \
    #     -group "virt_${name}_rx_clk_2m5 ${name}_rx_clk_2m5"

    ##setup time, set false path, rise-->fall, fall-->rise
    set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_125m"] -fall_to [get_clocks "${name}_rx_clk_125m"] -setup
    set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_125m"] -rise_to [get_clocks "${name}_rx_clk_125m"] -setup

    # set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_25m"] -fall_to [get_clocks "${name}_rx_clk_25m"] -setup
    # set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_25m"] -rise_to [get_clocks "${name}_rx_clk_25m"] -setup

    # set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_2m5"] -fall_to [get_clocks "${name}_rx_clk_2m5"] -setup
    # set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_2m5"] -rise_to [get_clocks "${name}_rx_clk_2m5"] -setup


    ##hold time, set false path, rise-->rise, fall-->fall
    set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_125m"] -rise_to [get_clocks "${name}_rx_clk_125m"] -hold
    set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_125m"] -fall_to [get_clocks "${name}_rx_clk_125m"] -hold

    # set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_25m"] -rise_to [get_clocks "${name}_rx_clk_25m"] -hold
    # set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_25m"] -fall_to [get_clocks "${name}_rx_clk_25m"] -hold

    # set_false_path -rise_from [get_clocks "virt_${name}_rx_clk_2m5"] -rise_to [get_clocks "${name}_rx_clk_2m5"] -hold
    # set_false_path -fall_from [get_clocks "virt_${name}_rx_clk_2m5"] -fall_to [get_clocks "${name}_rx_clk_2m5"] -hold
}

proc constrain_rgmii_output_pins { name clk_src clk_pin data_pins } {
    puts "Inserting timing constraints for RGMII output pins $name"
    puts "RGMII clock source: $clk_src"
    puts "RGMII clock pin: $clk_pin"
    puts "RGMII data pins: $data_pins"
    
    ##1ns setup time and 1ns hold time
    ##
    create_generated_clock -name "${name}_tx_clk_125m" -source [get_pins "$clk_src"] [get_ports "$clk_pin"]
    # create_generated_clock -name "${name}_tx_clk_25m" -source [get_pins "$clk_src"] [get_ports "$clk_pin"] -divide_by 5 -add
    # create_generated_clock -name "${name}_tx_clk_2m5" -source [get_pins "$clk_src"] [get_ports "$clk_pin"] -divide_by 50 -add

    set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_125m"] -max 1 [get_ports "$data_pins"]
    set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_125m"] -min -1 [get_ports "$data_pins"]
    set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_125m"] -max 1 -clock_fall [get_ports "$data_pins"]
    set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_125m"] -min -1 -clock_fall [get_ports "$data_pins"]

    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_25m"] -max 1 [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_25m"] -min -1 [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_25m"] -max 1 -clock_fall [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_25m"] -min -1 -clock_fall [get_ports "$data_pins"]

    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_2m5"] -max 1 [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_2m5"] -min -1 [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_2m5"] -max 1 -clock_fall [get_ports "$data_pins"]
    #set_output_delay -add_delay -clock [get_clocks "${name}_tx_clk_2m5"] -min -1 -clock_fall [get_ports "$data_pins"]

    #set_clock_groups \
    #    -exclusive \
    #    -group {get_clocks "$clk_src" "${name}_tx_clk_125m"} \
    #    -group {get_clocks "$clk_src" "${name}_tx_clk_25m"} \
    #    -group {get_clocks "$clk_src" "${name}_tx_clk_2m5"}

    # set_clock_groups \
    #     -exclusive \
    #     -group [get_clocks "$clk_src" "${name}_tx_clk_125m"]

    ##setup time, set false path, rise-->fall, fall-->rise
    set_false_path -rise_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_125m"] -setup
    set_false_path -fall_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_125m"] -setup

    #set_false_path -rise_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_25m"] -setup
    #set_false_path -fall_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_25m"] -setup

    #set_false_path -rise_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_2m5"] -setup
    #set_false_path -fall_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_2m5"] -setup


    ##hold time, set false path, rise-->rise, fall-->fall
    set_false_path -rise_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_125m"] -hold
    set_false_path -fall_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_125m"] -hold

    #set_false_path -rise_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_25m"] -hold
    #set_false_path -fall_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_25m"] -hold

    #set_false_path -rise_from [get_clocks "$clk_src"] -rise_to [get_clocks "${name}_tx_clk_2m5"] -hold
    #set_false_path -fall_from [get_clocks "$clk_src"] -fall_to [get_clocks "${name}_tx_clk_2m5"] -hold
}
