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
        ram_read_addr: out std_logic_vector(ADDR_RAM_W-1 downto 0); -- Dirección de lectura en RAM
        ram_write_addr: out std_logic_vector(ADDR_VRAM_W-1 downto 0); -- Dirección de escritura en VRAM
        ram_write_data: out std_logic_vector(9 downto 0); -- Datos para VRAM (siempre va a ser '1')
        angle_x: in signed(SIZE+1 downto 0);
        angle_y: in signed(SIZE+1 downto 0);
        angle_z: in signed(SIZE+1 downto 0)
    );
end rotador;

architecture rotador_arq of rotador is
type state_type is (IDLE, READ_RAM, ROTATE, WRITE_RAM, FIN);
    signal state, next_state: state_type;

    signal x, y, z, data_vram : signed(SIZE+1 downto 0);
    signal x_rot, y_rot, z_rot : signed(SIZE+1 downto 0);
    signal rotation_req, rotation_ack : std_logic;

    signal read_addr_reg : std_logic_vector(ADDR_RAM_W-1 downto 0);
    signal write_addr_reg : unsigned(ADDR_VRAM_W-1 downto 0);
    signal coord_ram: signed(SIZE+1 downto 0);
    signal step, n : natural;    
begin

    process(clock, state, start, reset, rotation_ack) 
    begin
        if rising_edge(clock) then
            if reset = '1' then
                step <= 0;
                state <= IDLE;
                read_addr_reg <= (others => '0');
                write_addr_reg <= (others => '0');
                rotation_req <= '0';
                done <= '0';
            else
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
                        if unsigned(read_addr_reg) = 4 then
                            next_state <= FIN;
                        else
                        -- agarro las coordenadas (x,y,z) guardadas en 3 direcciones de la ram (por eso necesito 3 step por terna)
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
                        if n = 0 then
                            data_vram <= x_rot;
                            n <= n+1;
                        elsif n = 1 then
                            data_vram <= y_rot;
                            n <= n+1;
                        else
                            data_vram <= z_rot;
                            next_state <= READ_RAM;
                            n <= 0;
                        end if;
                            write_addr_reg <= write_addr_reg+1;
                    when FIN =>
                        done <= '1';
                        next_state <= IDLE;
                    when others =>
                        next_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    coord_ram <=  signed(resize(signed(ram_read_data), SIZE+2));-- extiendo el signo para poder utilizar el cordic
    
    -- Tomo la vram como una matriz de 640 x 480 posiciones
    ram_read_addr <= read_addr_reg;
    -- Datos de salida para la Vram
    ram_write_data <= std_logic_vector(data_vram);
    ram_write_addr <= std_logic_vector(write_addr_reg);
    
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
        x_rot => x_rot,
        y_rot => y_rot,
        z_rot => z_rot,
        ack => rotation_ack
    );

end rotador_arq;