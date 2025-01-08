transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {/home/kavya/Desktop/forked/verilog-ethernet/example/AX7203_ARTIX7/fpga/fpga/fpga.cache/compile_simlib/riviera}
vlib riviera/xpm
vlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic" -l xpm -l xil_defaultlib \
"/home/kavya/Downloads/Downloads/Vivado/2023.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"/home/kavya/Downloads/Downloads/Vivado/2023.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic" -l xpm -l xil_defaultlib \
"../../../../fpga.gen/sources_1/ip/clk_div/clk_div_clk_wiz.v" \
"../../../../fpga.gen/sources_1/ip/clk_div/clk_div.v" \

vlog -work xil_defaultlib \
"glbl.v"

