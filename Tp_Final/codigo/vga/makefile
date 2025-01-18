GHDL_CMD = ghdl

.PHONY: clean

all: clean vga

vga:
	@$(GHDL_CMD) -a gen_pixels.vhdl
	@$(GHDL_CMD) -a vga_sync.vhdl
	@$(GHDL_CMD) -a vga_ctrl.vhdl
	echo --Codigo compilado--

clean:
	rm -f *.o *.ghw
	clear