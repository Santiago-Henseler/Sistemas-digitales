library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rotador is
    generic (
        SIZE : natural := 10;      -- Tamaño de las coordenadas y ángulos
        ADDR_VRAM_W : natural := 19 ;  -- Tamaño de la RAM 
        ADDR_RAM_W : natural :=16
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        start: in std_logic;
        done: out std_logic;
        ram_read_data: in std_logic_vector(SIZE-1 downto 0); -- Datos desde RAM cargada por el uart
        ram_read_addr: out std_logic_vector(ADDR_RAM_W-1 downto 0); -- Dirección de lectura
        ram_write_addr: out std_logic_vector(ADDR_VRAM_W-1 downto 0); -- Dirección de escritura en VRAM
        ram_write_data: out std_logic_vector(0 downto 0); -- Datos para VRAM (siempre va a ser '1')
        angle_x: in signed(SIZE+1 downto 0);
        angle_y: in signed(SIZE+1 downto 0);
        angle_z: in signed(SIZE+1 downto 0)
    );
end rotador;

architecture rotador_arq of rotador is
type state_type is (IDLE, READ_RAM, ROTATE, WRITE_RAM, FIN);
    signal state, next_state: state_type;

    signal x, y, z : signed(SIZE+1 downto 0);
    signal x_rot, y_rot, z_rot : signed(SIZE+1 downto 0);
    signal rotation_req, rotation_ack : std_logic;

    signal read_addr_reg : std_logic_vector(ADDR_RAM_W-1 downto 0);
    signal write_addr_reg : std_logic_vector(ADDR_VRAM_W-1 downto 0);
    signal coord_ram: signed(SIZE+1 downto 0);
    signal step : natural;    
    
    signal tmp_addres : std_logic_vector(ADDR_VRAM_W downto 0);
begin

    process(clock, state, start, reset, rotation_ack) 
    begin
        if reset = '1' then
            step <= 0;
            state <= IDLE;
            read_addr_reg <= (others => '0');
            write_addr_reg <= (others => '0');
            rotation_req <= '0';
            done <= '0';
        elsif rising_edge(clock) then
            rotation_req <= '0';
            done <= '0';
            -- Cambio de estado
            state <= next_state;
            case state is
                when IDLE =>
                    if start = '1' then
                        next_state <= READ_RAM;
                    else
                        next_state <= IDLE;
                    end if;
                when READ_RAM =>
                    if unsigned(read_addr_reg) = 2**ADDR_RAM_W-1 then
                        next_state <= FIN;
                    else
                    -- agarro las coordenadas (x,y,z) guardadas en 3 direcciones de la ram  
                        if step = 0 then
                            x <= coord_ram;
                            step <= step+1;
                        elsif step = 1 then
                            y <= coord_ram;
                            step <= step+1;
                        else
                            z <= coord_ram;
                            next_state <= ROTATE;
                            step <= 0;
                        end if;
                        read_addr_reg <= std_logic_vector(unsigned(read_addr_reg) + 1);
                    end if;
                when ROTATE =>
                    rotation_req <= '1';
                    if rotation_ack = '1' then
                        next_state <= WRITE_RAM;
                    else
                        next_state <= ROTATE;
                    end if;
                when WRITE_RAM =>
                    write_addr_reg <= tmp_addres(ADDR_VRAM_W-1 downto 0);
                    next_state <= READ_RAM;
                when FIN =>
                    done <= '1';
                    next_state <= IDLE;
                when others =>
                    next_state <= IDLE;
            end case;
        end if;
    end process;
    
    coord_ram <=  signed(resize(signed(ram_read_data), SIZE+2));-- extiendo el signo para poder utilizar el cordic
    
                    -- Tomo la ram como una matriz de 640 x 480 posiciones
    tmp_addres <= std_logic_vector(unsigned(x_rot) + (640 * unsigned(y_rot)));
    ram_read_addr <= read_addr_reg;
    -- Datos de salida para la Vram
    ram_write_data <= "1";
    ram_write_addr <= write_addr_reg;

    rot: entity work.rotador_equ
    generic map (
        SIZE => SIZE
    )
    port map (
        clock => clock,
        reset => reset,
        req => rotation_req,
        x0 => x,
        y0 => y,
        z0 => z,
        a1 => angle_x,
        a2 => angle_y,
        a3 => angle_z,
        x_out => x_rot,
        y_out => y_rot,
        z_out => z_rot,
        ack => rotation_ack
        );

end rotador_arq;