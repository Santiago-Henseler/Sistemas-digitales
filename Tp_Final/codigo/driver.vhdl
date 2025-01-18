library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity driver is
end driver;

architecture driver_arch of driver is
	constant ADD_W : natural := 19; -- tamaño de las ram
	constant SIZE : natural := 10; -- cantidad de operaciones del cordic
	
	signal addrW_Vram, addrR_Vram, addrW_ram, addrR_ram: std_logic_vector(ADD_W-1 downto 0);
	signal data_Vram_i, data_Vram_o: std_logic_vector(0 downto 0);
	signal data_ram_i, data_ram_o: std_logic_vector(7 downto 0);

	signal dout_uart: std_logic_vector(num_data_bits-1 downto 0);
begin
	
	uart_inst: entity work.uart_controler
	generic map (
		F 	=> 50000, -- clock frequency
		min_baud => 1200,
		ADD_W => ADD_W,
		num_data_bits => 8
	)
	port map (
		clk	=> clock,
		rst	=> reset,
		rx	=> rx,
		data => dout_uart,
		addrW => addrW_ram
	);

	ram_instance: entity work.dp_ram
	generic map(
		ADD_W => ADD_W,
		DATA_SIZE => 8
    );
    port map(
		write => '1',
        read => '1',
        addrW => addrW_ram,
        addrR => addrR_ram,
        data_i => dout_uart,
        data_o => data_ram_o
    );

	rot_controler: entity work.rotador_controler
	generic map(
		SIZE => SIZE
	);
	port map(
		clock => clock,
		reset => reset,
		ram_read_data => data_ram_o,
		ram_read_addr => addrR_ram,
		ram_write_addr => addrW_Vram,
		ram_write_data => data_Vram_i,
		btn_x0 => btn_x0,
		btn_x1 => btn_x1,
		btn_y0 => btn_y0,
		btn_y1 => btn_y1,
		btn_z0 => btn_z0,
		btn_z1 => btn_z1,		
		done => 
	);

	vram_instance: entity work.dp_ram
	generic map(
		ADD_W => ADD_W --uso direcciones de 19 bits porque 2^19 es 524.288 > 307.199
		DATA_SIZE => 1
    );
    port map(
		write => '1',
        read => '1',
        addrW => addrW_Vram,
        addrR => addrR_Vram,
        data_i => data_Vram_i,
        data_o => data_Vram_o
    );

	vga: entity work.vga_ctrl
	generic map(
		ADD_W => ADD_W
    );
	port map(
		clk => clock,
		rst => reset,
		data => data_Vram_o,
		addrR => addrR_Vram,
		hsync => hsync,
		vsync => vsync,
		rgb => rgb
	)
	
end driver_arch;