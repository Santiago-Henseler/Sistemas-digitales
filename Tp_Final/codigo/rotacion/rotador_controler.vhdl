library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotador_controler is
	generic(
		SIZE: natural := 10;
		ADDR_W : natural := 19;   -- Tamaño de la RAM (32K direcciones)
        COORD_WIDTH : natural := 12   -- Ancho de coordenadas y ángulos
	);
	port(
		clock: in std_logic;
        reset: in std_logic;
		btn_x0, btn_x1: in std_logic; -- el btn_x0 rota un delta de angulo positivo, el btn_x1 rota un delta de angulo negativo
		btn_y0, btn_y1: in std_logic;
		btn_z0, btn_z1: in std_logic;
		ram_read_data: in std_logic_vector(COORD_WIDTH-1 downto 0); -- Datos desde RAM de lectura
        ram_read_addr: out std_logic_vector(ADDR_W-1 downto 0); -- Dirección de lectura
        ram_write_addr: out std_logic_vector(ADDR_W-1 downto 0); -- Dirección de escritura en VRAM
        ram_write_data: out std_logic_vector(0 downto 0); -- Datos para VRAM 
		done: out std_logic
	);
end rotador_controler;

architecture rotador_controler_arch of rotador_controler is
	constant DELTA : signed(SIZE+1 downto 0) := "000111111111"; -- Desplazamiento de angulo fijo
	signal a1, a2, a3 : signed(SIZE+1 downto 0);

begin

	ang_x:process(btn_x0, btn_x1)
	begin
		if (btn_x0 xor btn_x1) = '1' then 
			if btn_x0 = '1' then
				a1 <= DELTA;
			else
				a1 <= not DELTA + 1;
			end if;
		else
			a1 <= (others => '0');
		end if;
	end process;

	ang_y:process(btn_y0, btn_y1)
	begin
		if (btn_y0 xor btn_y1) = '1' then 
			if btn_y0 = '1' then
				a2 <= DELTA;
			else
				a2 <= not DELTA + 1;
			end if;
		else
			a2 <= (others => '0');
		end if;
	end process;

	ang_z:process(btn_z0, btn_z1)
	begin
		if (btn_z0 xor btn_z1) = '1' then 
			if btn_z0 = '1' then
				a3 <= DELTA;
			else
				a3 <= not DELTA + 1;
			end if;
		else
			a3 <= (others => '0');
		end if;
	end process;

	rot: entity work.rotador
	generic map(
		SIZE => SIZE,
		ADDR_W => ADDR_W,
		COORD_WIDTH => COORD_WIDTH
	)
	port map(	
		clock => clock,
		reset => reset,
	    start => '1',
		done => done,
		ram_read_data  => ram_read_data,
	    ram_read_addr  => ram_read_addr,
	    ram_write_addr => ram_write_addr,
	    ram_write_data => ram_write_data,
		angle_x => a1,
		angle_y => a2,
		angle_z => a3
	);

end rotador_controler_arch;