vlib work 

vcom -93 -work work ../src/top_bonus/controller.vhd
vcom -93 -work work ../src/top_bonus/regfile.vhd
vcom -93 -work work ../src/top_bonus/ual.vhd
vcom -93 -work work ../src/top_bonus/datapath.vhd
vcom -93 -work work ../src/top_bonus/dmem.vhd
vcom -93 -work work ../src/top_bonus/imem.vhd
vcom -93 -work work ../src/top_bonus/mips.vhd
vcom -93 -work work ../src/top_bonus/top.vhd

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