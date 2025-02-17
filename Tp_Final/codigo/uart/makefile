GHDL_CMD = ghdl

.PHONY: clean

all: clean uart

uart:
	@$(GHDL_CMD) -a meta_harden.vhdl
	@$(GHDL_CMD) -a uart_baud_gen.vhdl
	@$(GHDL_CMD) -a uart_rx_ctl.vhdl
	@$(GHDL_CMD) -a uart_rx.vhdl
	@$(GHDL_CMD) -a uart_controler.vhdl
	echo --Codigo compilado--

clean:
	rm -f *.o *.ghw
	clear