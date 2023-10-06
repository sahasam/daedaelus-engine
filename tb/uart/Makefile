# Sahas Munamala
# Created: Tue Oct 03 2023, 11:59AM PDT
# Purpose: Run UART cocotb test suite

COCOTB_HDL_TIMEUNIT = 1ps
COCOTB_HDL_TIMEPRECISION = 1ps

TOPLEVEL_LANG = verilog
VERILOG_SOURCES += ../../rtl/uart/uart_tx.v

TOPLEVEL = uart_tx
MODULE = test_uart_tx

SIM ?= icarus
WAVES ?= 1

#ifeq ($(SIM), icarus)
#	PLUSARGS += -fst
#endif

include $(shell cocotb-config --makefiles)/Makefile.sim

#iverilog_dump.v:
#	echo 'module iverilog_dump();' > $@
#	echo 'initial begin' >> $@
#	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
#	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
#	echo 'end' >> $@
#	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
