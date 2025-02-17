    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    USE ieee.math_real.all;
    
    entity cordic_iter is
        generic(
            SIZE: natural := 8  -- Cantidad de iteraciones
        );
        port (
            clock: in std_logic;
            reset: in std_logic;
            req: in std_logic;
            method: in std_logic; -- 0 para utilizar el modo rotación 1 para el modo vector
            x0: in signed(SIZE+1 downto 0);
            y0: in signed(SIZE+1 downto 0);
            z0: in signed(SIZE+1 downto 0);
            x_out: out signed(SIZE+1 downto 0);
            y_out: out signed(SIZE+1 downto 0);
            z_out: out signed(SIZE+1 downto 0);
            ack: out std_logic
        );
    end cordic_iter;
    
architecture cordic_iter_arch of cordic_iter is
        signal x_i, y_i, z_i: signed(SIZE+1 downto 0);
        signal n_iter: unsigned(natural(ceil(log2(real(SIZE)))) downto 0);
        signal x_i_aux, y_i_aux, z_i_aux: signed(SIZE+1 downto 0);
        signal start: std_logic;
    begin
        cord: entity work.cordic
        generic map(SIZE => SIZE)
        port map(
            method => method,
            x0 => x_i,
            y0 => y_i,
            z0 => z_i,
            n_iter => n_iter,
            x_out => x_i_aux,
            y_out => y_i_aux,
            z_out => z_i_aux
        );
    
        logic: process(clock, reset, req)
        begin
            if rising_edge(clock) then
                if reset = '1' then
                    n_iter <= (others => '0');
                    x_i <= (others => '0');
                    y_i <= (others => '0');
                    z_i <= (others => '0');
                    ack <= '0';
                    start <= '0';
                else
                    if req = '1' then
                        ack <= '0';
                        start <= '1';
                    elsif n_iter = SIZE-1 then
                        ack <= '1';
                        start <= '0';
                    else
                        ack <= '0';
                    end if;
    
                    if req = '1' then
                        x_i <= x0;
                        y_i <= y0;
                        z_i <= z0;
                    elsif n_iter < SIZE then
                        x_i <= x_i_aux;
                        y_i <= y_i_aux;
                        z_i <= z_i_aux;
                    end if;
    
                    if req = '1' then
                        n_iter <= (others => '0');
                    elsif start = '1' then
                        n_iter <= n_iter + 1;
                    elsif n_iter = SIZE-1 then
                        n_iter <= (others => '0');
                    end if;
                end if;
            end if;
        end process;
    
        x_out <= x_i;
        y_out <= y_i;
        z_out <= z_i;
    
    end cordic_iter_arch;
