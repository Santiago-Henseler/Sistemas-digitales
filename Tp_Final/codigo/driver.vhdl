library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity driver is
	port(
		clock, reset, rx: in std_logic;
		btn_x0, btn_x1: in std_logic;
		btn_y0, btn_y1: in std_logic;
		btn_z0, btn_z1: in std_logic;
		hsync , vsync : out std_logic;
		rgb : out std_logic_vector(2 downto 0);
		done: out std_logic
	);
end driver;

architecture driver_arch of driver is
	constant ADDR_VRAM_W : natural := 19; --  El tamaño de la vram es de 19 bits porque 640X480 = 307.200 (tamaño de pantalla) < 2**19 = 524.288 
	constant ADDR_RAM_W: natural := 16; -- Uso direcciones de 16 bits porque tengo 35.841 (3X11947) coordenadas que almacenar
	constant SIZE : natural := 8; -- tamaño (en bits) de las coordenadas
	
	signal addrW_Vram, addrR_Vram: std_logic_vector(ADDR_VRAM_W-1 downto 0);
	signal addrW_ram, addrR_ram: std_logic_vector(ADDR_RAM_W-1 downto 0);
	signal data_Vram_i, data_Vram_o: std_logic_vector(0 downto 0);
	signal data_ram_i, data_ram_o: std_logic_vector(SIZE-1 downto 0);
	
	signal fin_rx: std_logic; -- Indica que la uart recibio todas las coordenadas
	signal dout_uart: std_logic_vector(SIZE-1 downto 0);
begin
	
	uart_inst: entity work.uart_controler
	generic map (
		F 	=> 50000, 
		min_baud => 1200,
		ADD_W => ADDR_RAM_W,
		num_data_bits => SIZE
	)
	port map (
		clk	=> clock,
		rst	=> reset,
		rx	=> rx,
		data => dout_uart,
		addrW => addrW_ram,
		fin_rx => fin_rx
	);

	ram_instance: entity work.dual_ram
	generic map(
		ADD_W => ADDR_RAM_W, 
		DATA_SIZE => SIZE
    )
    port map(
        clock => clock,
        addrW => addrW_ram,
        addrR => addrR_ram,
        data_i => dout_uart,
        data_o => data_ram_o
    );

	rot_controler: entity work.rotador_controler
	generic map(
		SIZE => SIZE,
		ADDR_VRAM_W => ADDR_VRAM_W,
		ADDR_RAM_W => ADDR_RAM_W
	)
	port map(
		clock => clock,
		reset => reset,
		start => fin_rx,
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
		done => done
	);

	vram_instance: entity work.dual_ram
	generic map(
		ADD_W => ADDR_VRAM_W,
		DATA_SIZE => 1
    )
    port map(
        clock => clock, 
        addrW => addrW_Vram,
        addrR => addrR_Vram,
        data_i => data_Vram_i,
        data_o => data_Vram_o
    );

	vga: entity work.vga_ctrl
	generic map(
		ADD_W => ADDR_VRAM_W
    )
	port map(
		clk => clock,
		rst => reset,
		data => data_Vram_o,
		addrR => addrR_Vram,
		hsync => hsync,
		vsync => vsync,
		rgb => rgb
	);
	
end driver_arch;