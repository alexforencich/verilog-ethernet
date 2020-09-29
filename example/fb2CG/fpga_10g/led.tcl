# Timing constraints for led_sreg_driver

foreach inst [get_cells -hier -filter {(ORIG_REF_NAME == led_sreg_driver || REF_NAME == led_sreg_driver)}] {
    puts "Inserting timing constraints for led_sreg_driver instance $inst"

    set select_ffs [get_cells "$inst/led_sync_reg_1_reg[*] $inst/led_sync_reg_2_reg[*]"]

    if {[llength $select_ffs]} {
        set_property ASYNC_REG TRUE $select_ffs
        set_false_path -to [get_pins "$inst/led_sync_reg_1_reg[*]/D"]
    }
}
