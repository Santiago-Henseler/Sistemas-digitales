GHDL_CMD = ghdl

STOP_TIME = 7000us

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

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
	@$(GHDL_CMD) -a tb_rotador_3d.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb_rotador_3d
	@$(GHDL_CMD) -r tb_rotador_3d --wave="tb_rotador_3d.ghw"  $(GHDL_SIM_OPT)
	@$(WAVEFORM_VIEWER) tb_rotador_3d.ghw


clean:
	rm -f *.o *.ghw tb_rotador_3d
	clear
