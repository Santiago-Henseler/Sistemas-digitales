library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotador_controler is
	generic(
		SIZE: natural := 10;   -- Ancho de coordenadas y ángulos
		ADDR_VRAM_W : natural := 19; -- Tamaño de la RAM 
	    ADDR_RAM_W : natural := 16
	);
	port(
		clock: in std_logic;
        reset: in std_logic;
		start: in std_logic;
		btn_x0, btn_x1: in std_logic; -- el btn_x0 rota un delta de angulo positivo, el btn_x1 rota un delta de angulo negativo
		btn_y0, btn_y1: in std_logic;
		btn_z0, btn_z1: in std_logic;
		ram_read_data: in std_logic_vector(SIZE-1 downto 0); -- Datos desde RAM de lectura
        ram_read_addr: out std_logic_vector(ADDR_RAM_W-1 downto 0); -- Dirección de lectura en RAM
        ram_write_addr: out std_logic_vector(ADDR_VRAM_W-1 downto 0); -- Dirección de escritura en VRAM
        ram_write_data: out std_logic_vector(9 downto 0); -- Datos para VRAM 
		done: out std_logic
	);
end rotador_controler;

architecture rotador_controler_arch of rotador_controler is
    constant DELTA : signed(SIZE+1 downto 0) := "0001111111"; -- Desplazamiento de angulo fijo
    signal ang_x, ang_y, ang_z : signed(SIZE+1 downto 0);

begin

    -- Lógica de asignación de ang_x, ang_y, ang_z
    process(btn_x0, btn_x1)
    begin
        if (btn_x0 xor btn_x1) = '1' then 
            if btn_x0 = '1' then
                ang_x <= DELTA;
            else
                ang_x <= not DELTA + 1;
            end if;
        else
            ang_x <= (others => '0');
        end if;
    end process;

    process(btn_y0, btn_y1)
    begin
        if (btn_y0 xor btn_y1) = '1' then 
            if btn_y0 = '1' then
                ang_y <= DELTA;
            else
                ang_y <= not DELTA + 1;
            end if;
        else
            ang_y <= (others => '0');
        end if;
    end process;

    process(btn_z0, btn_z1)
    begin
        if (btn_z0 xor btn_z1) = '1' then 
            if btn_z0 = '1' then
                ang_z <= DELTA;
            else
                ang_z <= not DELTA + 1;
            end if;
        else
            ang_z <= (others => '0');
        end if;
    end process;

    rot: entity work.rotador
        generic map(
            SIZE => SIZE,
            ADDR_VRAM_W => ADDR_VRAM_W,
            ADDR_RAM_W => ADDR_RAM_W
        )
        port map(    
            clock => clock,
            reset => reset,
            start => start,
            done => done,
            ram_read_data  => ram_read_data,
            ram_read_addr  => ram_read_addr,
            ram_write_addr => ram_write_addr,
            ram_write_data => ram_write_data,
            angle_x => ang_x,
            angle_y => ang_y,
            angle_z => ang_z
        );

end rotador_controler_arch;