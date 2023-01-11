transcript on

# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

vlog -O0 -f sim_list.f

vsim -voptargs="+acc -debugDB" work.robot_tb

add wave -noupdate /robot_tb/DUT/clk_i
add wave -noupdate /robot_tb/DUT/rstn_i
add wave -noupdate -expand -group Coordinates /robot_tb/x_axis
add wave -noupdate -expand -group Coordinates /robot_tb/y_axis
add wave -noupdate -expand -group Coordinates /robot_tb/move_side
add wave -noupdate -expand -group {Motor Status} /robot_tb/DUT/motor_status_o
add wave -noupdate -expand -group {Motor Status} -color Magenta /robot_tb/DUT/left_motor_o
add wave -noupdate -expand -group {Motor Status} -color Magenta /robot_tb/DUT/right_motor_o
add wave -noupdate -color Blue /robot_tb/DUT/STATUS_CURRENT
add wave -noupdate /robot_tb/DUT/STATUS_NEXT
add wave -noupdate /robot_tb/DUT/move_i
add wave -noupdate /robot_tb/DUT/tracker_fwrd_i
add wave -noupdate /robot_tb/DUT/tracker_status_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {110 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update

run -all