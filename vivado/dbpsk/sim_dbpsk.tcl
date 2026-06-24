# sim_dbpsk.tcl
# Vivado 2025.2 behavioral simulation for DBPSK DUT
# Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
#
# Usage (from Vivado Tcl Console after opening project):
#   cd D:/zizim/Documents/UJN_HW/proj2
#   source vivado/dbpsk/sim_dbpsk.tcl

set project_dir [file dirname [file dirname [file dirname [info script]]]]
cd $project_dir

# Source directories
set src_dir  hdl_prj/hdlsrc/dbpsk_hdl_cosim/dbpsk_hdl_cosim
set tb_dir   hdl_prj/hdlsrc

# Create project
create_project dbpsk vivado/dbpsk -part xc7z020clg400-2 -force
set_property target_language Verilog [current_project]

# Add design sources (DUT + sub-modules)
add_files -norecurse [list \
    $src_dir/DUT.v \
    $src_dir/DBPSK_Mod_HDL.v \
    $src_dir/DBPSK_Demod_HDL.v \
    $src_dir/CmpZero.v \
]

# Add simulation sources (testbench)
add_files -fileset sim_1 -norecurse [list \
    $tb_dir/tb_DUT_dbpsk.sv \
]

# Set simulation top
set_property top tb_DUT [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Simulation settings
set_property -name {xsim.simulate.runtime} -value {50us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Launch behavioral simulation
puts "========================================"
puts "  Starting Vivado Behavioral Simulation"
puts "  Target: xc7z020-2clg400 (D-BPSK)"
puts "========================================"

launch_simulation

# Wait for simulation to finish
run 50us

puts ""
puts "Simulation complete. Check Tcl Console for PASS/FAIL."
puts "Waveform window should show signals."
