GHDL_CMD = ghdl

STOP_TIME = 500ns

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean multiplicador sumador

multiplicador:
	@$(GHDL_CMD) -a multiplicador_float.vhdl
	@$(GHDL_CMD) -a test_multiplicador/ffd.vhdl
	@$(GHDL_CMD) -a test_multiplicador/delay.vhdl
	@$(GHDL_CMD) -a test_multiplicador/tb.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb_multiplicador
	@$(GHDL_CMD) -r tb_multiplicador --wave="tb_multiplicador.ghw"

sumador:
	@$(GHDL_CMD) -a sumador_float.vhdl
	@$(GHDL_CMD) -a test_sumador/ffd.vhdl
	@$(GHDL_CMD) -a test_sumador/delay.vhdl
	@$(GHDL_CMD) -a test_sumador/tb.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb_sumador
	@$(GHDL_CMD) -r tb_sumador --wave="tb_sumador.ghw"

viewm:
	@$(WAVEFORM_VIEWER) tb_multiplicador.ghw

views:
	@$(WAVEFORM_VIEWER) tb_sumador.ghw

clean:
	rm -f *.o *.ghw tb_multiplicador tb_sumador
	clear