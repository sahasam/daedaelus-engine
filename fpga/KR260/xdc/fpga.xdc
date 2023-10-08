# XDC constraints for the Xilinx KR260 board
# part: xck26-sfvc784-2LV-c

# General configuration
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]

# System clocks
#
# use the 25 MHz clock outputs to the PL from U91
# and feed that into a PLL to convert it to 125 MHz
set_property -dict {LOC C3 IOSTANDARD LVCMOS18} [get_ports clk_25mhz_ref] ;# HPA_CLK0P_CLK, HPA_CLK0_P, via U91, SOM240_1 A6
create_clock -period 40.000 -name clk_25mhz [get_ports clk_25mhz_ref]

# LEDs
#set_property -dict {LOC F8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[0]}] ;# HPA14P som240_1_d13
#set_property -dict {LOC E8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {led[1]}] ;# HPA14N som240_1_d14
#
#set_property -dict {LOC G8   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {sfp_led[0]}] ;# HPA13P som240_1_a12
#set_property -dict {LOC F7   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports {sfp_led[1]}] ;# HPA13N som240_1_a13
#
#set_false_path -to [get_ports {led[*] sfp_led[*]}]
#set_output_delay 0 [get_ports {led[*] sfp_led[*]}]

