onerror {resume}
radix define States {
    "8'b000?????" "Play" -color "green",
    "8'b001?????" "Play Repeat" -color "purple",
    "8'b01??????" "Pause" -color "orange",
    "8'b10??????" "Seek" -color "blue",
    "8'b11??????" "Stop" -color "red",
    -default hexadecimal
    -defaultcolor white
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/clk
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/reset
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/execute_btn
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/sync
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/led
add wave -noupdate -radix hexadecimal /dj_roomba_3000_tb/dj_roomba/audio_out
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/PresentState
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/NextState
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/data_address
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/instr_addr
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_offset
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_off_reg
add wave -noupdate -radix States /dj_roomba_3000_tb/dj_roomba/instr_bus
add wave -noupdate -radix States /dj_roomba_3000_tb/dj_roomba/instr_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/count_sig
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/execute_instr_en
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/exe_pb_sync_n
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/instr_cntr_en
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/instr_fetch_en
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/play_cmd
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/repeat_cmd
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_cmd
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/stop_cmd
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/pause_cmd
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/valid_command
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/play_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/repeat_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/stop_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/pause_reg
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_value
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/repeat_funct
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/cmd_funct
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/MAX_COUNT_C
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/play_c
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/pause_c
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/seek_c
add wave -noupdate /dj_roomba_3000_tb/dj_roomba/stop_c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {658726 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2100 ns}
