# create_project.tcl
# Vivado 2025.2 project creation for BPSK DUT
# Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
#
# Usage: vivado -mode batch -source vivado/bpsk/create_project.tcl

set project_dir [file dirname [file dirname [file dirname [info script]]]]
cd $project_dir

# Source directories
set src_dir  hdl_prj/hdlsrc/bpsk_hdl_cosim/bpsk_hdl_cosim
set tb_dir   hdl_prj/hdlsrc

# Create project in vivado/bpsk/
create_project bpsk vivado/bpsk -part xc7z020clg400-2 -force
set_property target_language Verilog [current_project]

# Add design sources (DUT + sub-modules)
add_files -norecurse [list \
    $src_dir/DUT.v \
    $src_dir/BPSK_Mod_HDL.v \
    $src_dir/BPSK_Demod_HDL.v \
    $src_dir/CmpZero.v \
]

# Add simulation sources (testbench)
add_files -fileset sim_1 -norecurse [list \
    $tb_dir/tb_DUT.sv \
]

# Set simulation top
set_property top tb_DUT [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Simulation settings
set_property -name {xsim.simulate.runtime} -value {50us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

puts "========================================"
puts "  Vivado project created: vivado/bpsk/bpsk.xpr"
puts "  Target: xc7z020-2clg400"
puts "========================================"
puts ""
puts "Next: open project in Vivado GUI and run simulation,"
puts "  or run: source vivado/bpsk/sim_bpsk.tcl"
