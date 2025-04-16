vlib work 

vcom -93 -work work ../src/top_bonus_2/controller.vhd
vcom -93 -work work ../src/top_bonus_2/regfile.vhd
vcom -93 -work work ../src/top_bonus_2/ual.vhd
vcom -93 -work work ../src/top_bonus_2/datapath.vhd
vcom -93 -work work ../src/top_bonus_2/dmem.vhd
vcom -93 -work work ../src/top_bonus_2/imem.vhd
vcom -93 -work work ../src/top_bonus_2/mips.vhd
vcom -93 -work work ../src/top_bonus_2/top.vhd

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