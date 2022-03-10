vlib work
vcom -2008 -work work ../../src/rom_data/rom_data.vhd
vcom -2008 -work work ../../src/rom_instructions/rom_instructions.vhd
vcom -2008 -work work ../../src/rising_edge_synchronizer.vhd
vcom -2008 -work work ../../src/clock_synchronizer.vhd
vcom -2008 -work work ../../src/edge_detect.vhd
vcom -2008 -work work ../../src/reg_delay.vhd
vcom -2008 -work work ../../src/dj_roomba_3000.vhd
vcom -2008 -work work ../src/dj_roomba_3000_tb.vhd
vsim -voptargs=+acc dj_roomba_3000_tb
do wave.do
run 2 us