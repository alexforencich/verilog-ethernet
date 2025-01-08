open_project fpga.xpr
reset_run impl_1
launch_runs -jobs 4 impl_1
wait_on_run impl_1
open_run impl_1
report_utilization -file fpga_utilization.rpt
report_utilization -hierarchical -file fpga_utilization_hierarchical.rpt
