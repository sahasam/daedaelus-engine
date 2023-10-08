# Sahas Munamala
# Created: Sat Oct 07 2023, 08:14PM PDT

#######################################
# Project Specific Configuration
#
# These commands allow for vivado to use it's knowledge of the
# KR260 SOM pinout and configuration in the KR260 dev board
# and automate block design features.
#
# TODO: Move this to its own file. It should run from create_project.tcl
set_property board_part xilinx.com:kr260_som:part0:1.1 [current_project]
set_property board_connections {som240_1_connector xilinx.com:kr260_carrier:som240_1_connector:1.0 som240_2_connector xilinx.com:kr260_carrier:som240_2_connector:1.0} [current_project]

create_bd_design "zynq_ps"

#######################################
# Create
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset


#######################################
# Configure
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps]
set_property -dict [list \
  CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {10} \
  CONFIG.PSU__USE__M_AXI_GP0 {0} \
  CONFIG.PSU__USE__M_AXI_GP1 {0} \
] [get_bd_cells zynq_ultra_ps]


#######################################
# Connect
connect_bd_net [get_bd_pins zynq_ultra_ps/pl_resetn0] [get_bd_pins proc_sys_reset/ext_reset_in]
connect_bd_net [get_bd_pins zynq_ultra_ps/pl_clk0] [get_bd_pins proc_sys_reset/slowest_sync_clk]


#######################################
# Save block design
validate_bd_design
save_bd_design [current_bd_design]
close_bd_design [current_bd_design]
