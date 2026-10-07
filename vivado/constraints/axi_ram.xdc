# AXI RAM Constraints File

# Define a 100 MHz clock for s_axi_aclk
create_clock -period 10.000 -name s_axi_aclk -waveform {0.000 5.000} [get_ports s_axi_aclk]

# (Optional) I/O constraints can be added here if this module is synthesized at the top level
