GHDL_CMD = ghdl

STOP_TIME = 7000us

GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean dpram

dpram:
	@$(GHDL_CMD) -a dp_ram.vhdl
	@$(GHDL_CMD) -a tb_dp_ram.vhdl
	echo --Codigo compilado--
	@$(GHDL_CMD) -e tb_dp_ram
	@$(GHDL_CMD) -r tb_dp_ram --wave="tb_dp_ram.ghw"  $(GHDL_SIM_OPT)
	@$(WAVEFORM_VIEWER) tb_dp_ram.ghw

clean:
	rm -f *.o *.ghw tb_dp_ram
	clear