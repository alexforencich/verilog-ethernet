open_project fpga.xpr
open_run impl_1
write_bitstream -force fpga.runs/impl_1/fpga.bit
write_debug_probes -force fpga.runs/impl_1/fpga.ltx
