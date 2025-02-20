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
		x_vio, y_vio, z_vio: out std_logic_vector(9 downto 0);
		recibidos: out std_logic_vector(7 downto 0)
	);
end driver;

architecture driver_arch of driver is
	constant ADDR_VRAM_W : natural := 19; --  El tamaño de la vram es de 19 bits porque 640X480 = 307.200 (tamaño de pantalla) < 2**19 = 524.288 
	constant ADDR_RAM_W: natural := 16; -- Uso direcciones de 16 bits porque tengo 35.838 (3X11946) coordenadas que almacenar
	constant SIZE : natural := 8; -- tamaño (en bits) de las coordenadas
	
	-- Señales para transpaso de datos
	signal addrW_Vram, addrR_Vram: std_logic_vector(ADDR_VRAM_W-1 downto 0);
	signal addrW_ram, addrR_ram: std_logic_vector(ADDR_RAM_W-1 downto 0);
	signal data_Vram_i, data_Vram_o: std_logic_vector(0 downto 0);
	signal data_ram_i, data_ram_o: std_logic_vector(SIZE-1 downto 0);
	
	signal fin_rx: std_logic; -- Indica que la uart recibio todas las coordenadas
	signal dout_uart: std_logic_vector(SIZE-1 downto 0);

	-- Flujo del programa
	type state_type is (UART, ROTATE_REQ, ROTATE, VGA, REFRESH_VGA);
    signal state, next_state: state_type;
	signal start_rot, done, vsync_ready, clear_ram_ack, clear_ram_req: std_logic;

	signal clear_ram_addr, rot_ram_addr: std_logic_vector(ADDR_VRAM_W-1 downto 0);

begin
	process(clock, reset, state)
	begin
		if rising_edge(clock) then
            if reset = '1' then
                state <= UART;
				start_rot <= '0';
				clear_ram_req <= '0';
            else
                -- Cambio de estado
                state <= next_state;
                case state is
                    when UART =>
						-- espero a que termine de recibir los datos por UART
                        if fin_rx = '1' then
                            next_state <= ROTATE_REQ;
                        else
                            next_state <= UART;
                        end if;
                    when ROTATE_REQ =>
   						start_rot <= '1';
						next_state <= ROTATE;
                    when ROTATE =>
						-- espero a que termine de hacer la rotación
						start_rot <= '0';
                        if done = '1' then
							next_state <= VGA;
						else
							next_state <= ROTATE;
						end if;
                    when VGA =>
                        --espero que se recorra toda la pantalla
						if vsync_ready = '1' then
							next_state <= REFRESH_VGA;
						else
							next_state <= VGA;
						end if;
					when REFRESH_VGA => 
					   -- limpio Vram
						clear_ram_req <= '1';
						if clear_ram_ack = '1' then
							clear_ram_req <= '0';
							next_state <= ROTATE_REQ;
						else
							next_state <= REFRESH_VGA;
						end if;
                    when others =>
                        next_state <= ROTATE_REQ;
                end case;
            end if;
        end if;
		
	end process;
	
	uart_inst: entity work.uart_controler
	generic map (
		BAUD_RATE 	=> 115200, 
		CLOCK_RATE => 125E6,
		ADD_W => ADDR_RAM_W,
		num_data_bits => SIZE
	)
	port map (
		clk	=> clock,
		rst	=> reset,
		rx	=> rx,
		data => dout_uart,
		addrW => addrW_ram,
		fin_rx => fin_rx, 
		recibidos => recibidos -- Dato al vio para confirmar recepcion
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
		start => start_rot,
		ram_read_data => data_ram_o,
		ram_read_addr => addrR_ram,
		ram_write_addr => rot_ram_addr,
		ram_write_data => data_Vram_i,
		btn_x0 => btn_x0,
		btn_x1 => btn_x1,
		btn_y0 => btn_y0,
		btn_y1 => btn_y1,
		btn_z0 => btn_z0,
		btn_z1 => btn_z1,		
		done => done,
		x_vio => x_vio,
		y_vio => y_vio,
		z_vio => z_vio
	);

	clear_vram: entity work.clear_video
	generic map(
		ADD_W => ADDR_VRAM_W
	)
	port map(
		clock => clock,
		reset => reset,
		req => clear_ram_req,
		addrW_Vram => clear_ram_addr,
		ack => clear_ram_ack
	);

	addrW_Vram <= clear_ram_addr when clear_ram_req = '1' else rot_ram_addr;
	
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

	vga_instance: entity work.vga_ctrl
	generic map(
		ADD_W => ADDR_VRAM_W
    )
	port map(
		clk => clock,
		rst => reset,
		data => data_Vram_o,
		addrR => addrR_Vram,
		hsync => hsync,
		vsync => vsync_ready,
		rgb => rgb
	);
	
	vsync <= vsync_ready;
	
end driver_arch;