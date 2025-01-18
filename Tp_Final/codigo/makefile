GHDL_CMD = ghdl

.PHONY: clean

all: clean driver

driver:
	@$(GHDL_CMD) -a dp_ram/dp_ram.vhdl
	echo --Ram compilado--
	@$(GHDL_CMD) -a rotacion/cordic/arctan_rom.vhdl
	@$(GHDL_CMD) -a rotacion/cordic/cordic.vhdl
	@$(GHDL_CMD) -a rotacion/cordic/cordic_iter.vhdl
	@$(GHDL_CMD) -a rotacion/cordic/pre_cordic.vhdl
	echo --Cordic compilado--
	@$(GHDL_CMD) -a rotacion/rotador_equ.vhdl
	@$(GHDL_CMD) -a rotacion/rotador.vhdl
	@$(GHDL_CMD) -a rotacion/rotador_controler.vhdl
	echo --Rotador compilado--
	@$(GHDL_CMD) -a vga/gen_pixels.vhdl
	@$(GHDL_CMD) -a vga/vga_sync.vhdl
	@$(GHDL_CMD) -a vga/vga_ctrl.vhdl
	echo --Vga compilado--
	@$(GHDL_CMD) -a uart/receive.vhdl
	@$(GHDL_CMD) -a uart/timing.vhdl
	@$(GHDL_CMD) -a uart/uart.vhdl
	@$(GHDL_CMD) -a uart/uart_controler.vhdl
	echo --Uart compilado--
	@$(GHDL_CMD) -a driver.vhdl
	echo --Codigo compilado--

clean:
	rm -f *.o *.ghw
	clear