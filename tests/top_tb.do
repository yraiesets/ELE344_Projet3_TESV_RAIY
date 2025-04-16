vlib work 

vcom -93 -work work ../src/top/controller.vhd
vcom -93 -work work ../src/top/regfile.vhd
vcom -93 -work work ../src/top/ual.vhd
vcom -93 -work work ../src/top/datapath.vhd
vcom -93 -work work ../src/top/dmem.vhd
vcom -93 -work work ../src/top/imem.vhd
vcom -93 -work work ../src/top/mips.vhd
vcom -93 -work work ../src/top/top.vhd

vsim top
view wave

add wave -bin /TOP/Clk
add wave -bin /TOP/reset
add wave -dec /TOP/PC(9:2)
add wave -dec /TOP/WriteData
add wave -dec /TOP/DataAddress

force clk 1 0 ns, 0 5 ns -repeat 10 ns
force reset 1, 0 25 ns
run 500 ns

vdel -all work