GHDL_CMD = ghdl

.PHONY: clean

all: clean rotador

rotador:
	@$(GHDL_CMD) -a cordic/arctan_rom.vhdl
	@$(GHDL_CMD) -a cordic/cordic.vhdl
	@$(GHDL_CMD) -a cordic/cordic_iter.vhdl
	@$(GHDL_CMD) -a cordic/pre_cordic.vhdl
	echo --Cordic compilado--
	@$(GHDL_CMD) -a rotador_equ.vhdl
	@$(GHDL_CMD) -a rotador.vhdl
	@$(GHDL_CMD) -a rotador_controler.vhdl
	echo --Codigo compilado--

clean:
	rm -f *.o *.ghw
	clear