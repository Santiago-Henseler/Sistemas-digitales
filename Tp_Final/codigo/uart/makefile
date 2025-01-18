GHDL_CMD = ghdl

.PHONY: clean

all: clean uart

uart:
	@$(GHDL_CMD) -a receive.vhdl
	@$(GHDL_CMD) -a timing.vhdl
	@$(GHDL_CMD) -a uart.vhdl
	@$(GHDL_CMD) -a uart_controler.vhdl
	echo --Codigo compilado--

clean:
	rm -f *.o *.ghw
	clear