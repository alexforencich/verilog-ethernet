transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+clk_div  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.clk_div xil_defaultlib.glbl

do {clk_div.udo}

run

endsim

quit -force
