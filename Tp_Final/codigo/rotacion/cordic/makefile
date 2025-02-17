GHDL_CMD = ghdl

STOP_TIME = 5000us

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean cordic

cordic:
	@$(GHDL_CMD) -a arctan_rom.vhdl
	@$(GHDL_CMD) -a cordic.vhdl
	@$(GHDL_CMD) -a cordic_iter.vhdl
	@$(GHDL_CMD) -a pre_cordic.vhdl
	@$(GHDL_CMD) -a tb_cordic.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb_cordic
	@$(GHDL_CMD) -r tb_cordic --wave="tb_cordic.ghw"  $(GHDL_SIM_OPT)
	@$(WAVEFORM_VIEWER) tb_cordic.ghw

clean:
	rm -f *.o *.ghw tb_cordic
	clear