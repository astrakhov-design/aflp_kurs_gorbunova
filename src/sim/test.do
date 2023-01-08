transcript on

# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

vlog -O0 -f sim_list.f

vsim -voptargs="+acc -debugDB" work.robot_tb
run -all