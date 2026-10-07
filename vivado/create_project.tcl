# Rebuild Vivado Project
create_project axi4lite_ram_project ./vivado_project -part xc7a35tcpg236-1 -force

# Add RTL Source Files
add_files ../rtl/ram_16x32.v
add_files ../rtl/addr_decoder.v
add_files ../rtl/axi4lite_slave.v
add_files ../rtl/axi4lite_ram.v

# Add Simulation Source Files
add_files -fileset sim_1 ../tb/axi4lite_ram_tb.v
add_files -fileset sim_1 ../sim/axi4lite_ram_tb_behav.wcfg

# Add Constraints
add_files -fileset constrs_1 ./constraints/axi_ram.xdc

# Set Top Modules
set_property top axi4lite_ram [current_fileset]
set_property top axi4lite_ram_tb [get_filesets sim_1]

puts "Vivado project created successfully in ./vivado_project/"
