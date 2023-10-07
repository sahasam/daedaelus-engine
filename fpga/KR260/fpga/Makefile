# SPDX-License-Identifier: BSD-2-Clause-Views
# Copyright (c) 2019-2023 The Regents of the University of California

# FPGA settings
FPGA_PART = xck26-sfvc784-2LV-c
FPGA_TOP = fpga
FPGA_ARCH = zynquplus

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/sync_signal.v

# XDC files
XDC_FILES = fpga.xdc
#XDC_FILES += lib/axis/syn/vivado/axis_async_fifo.tcl
#XDC_FILES += lib/axis/syn/vivado/sync_reset.tcl
#XDC_FILES += lib/eth/syn/vivado/ptp_clock_cdc.tcl
#XDC_FILES += ../../../common/syn/vivado/mqnic_port.tcl
#XDC_FILES += ../../../common/syn/vivado/mqnic_ptp_clock.tcl
#XDC_FILES += ../../../common/syn/vivado/mqnic_rb_clk_info.tcl
#XDC_FILES += ../../../common/syn/vivado/rb_drp.tcl
#XDC_FILES += ../../../common/syn/vivado/eth_xcvr_phy_10g_gty_wrapper.tcl
#XDC_FILES += ../../../common/syn/vivado/tdma_ber_ch.tcl

# IP
#IP_TCL_FILES = ip/zynq_ps.tcl
#IP_TCL_FILES += ip/eth_xcvr_gth.tcl

# Configuration
CONFIG_TCL_FILES = ./config.tcl

include ../common/vivado.mk

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl

APP_DIR = app

$(APP_DIR)/shell.json:
	@mkdir -p $(@D)
	echo '{"shell_type": "XRT_FLAT", "num_slots": "1"}' > $@

$(APP_DIR)/$(FPGA_TOP).bin: $(FPGA_TOP).bin
	@mkdir -p $(@D)
	cp $< $@

$(APP_DIR)/overlay.dtbo: ../ps/overlay.dtsi
	@mkdir -p $(@D)
	dtc -@ -O dtb -o $@ $^

.PHONY: app
app: $(APP_DIR)/$(FPGA_TOP).bin $(APP_DIR)/shell.json $(APP_DIR)/overlay.dtbo

clean::
	-rm -rf $(APP_DIR)
