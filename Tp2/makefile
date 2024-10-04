GHDL_CMD = ghdl

STOP_TIME = 500ns

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make run

make:
	@$(GHDL_CMD) -a multiplicador_float.vhdl
	@$(GHDL_CMD) -a tb.vhdl
	echo --Codigo compilado--

run:
	@$(GHDL_CMD) -e tb
	@$(GHDL_CMD) -r tb --wave="tb.ghw" $(GHDL_SIM_OPT)
	@$(WAVEFORM_VIEWER) tb.ghw

clean:
	rm -f *.o tb.ghw tb
	clear