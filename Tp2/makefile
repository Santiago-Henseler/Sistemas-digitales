GHDL_CMD = ghdl

STOP_TIME = 500ns

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make

make:
	@$(GHDL_CMD) -a multiplicador_float.vhdl
	@$(GHDL_CMD) -a test/ffd.vhdl
	@$(GHDL_CMD) -a test/delay.vhdl
	@$(GHDL_CMD) -a test/tb.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb
	@$(GHDL_CMD) -r tb --wave="tb.ghw" $(GHDL_SIM_OPT)

view:
	@$(WAVEFORM_VIEWER) tb.ghw

clean:
	rm -f *.o tb.ghw tb
	clear