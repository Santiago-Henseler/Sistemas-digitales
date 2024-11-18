library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_iter is
    generic(
        SIZE: natural := 8  -- Cantidad de iteraciones
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        method: in std_logic; -- 0 para utilizar el modo rotación 1 para el modo vector
        x0: in signed(SIZE+1 downto 0);
        y0: in signed(SIZE+1 downto 0);
        z0: in signed(SIZE+1 downto 0);
        x_out: out signed(SIZE+1 downto 0);
        y_out: out signed(SIZE+1 downto 0);
        z_out: out signed(SIZE+1 downto 0)
    );
end cordic_iter;

architecture cordic_iter_arch of cordic_iter is
    signal x_i, y_i, z_i: signed(SIZE+1 downto 0);
    signal x_i_reg, y_i_reg, z_i_reg: signed(SIZE+1 downto 0);
    signal n_iter: unsigned(SIZE+1 downto 0);
begin

    cord: entity work.cordic
    generic map(SIZE => SIZE)
    port map(
        clock => clock,
        reset => reset,
        method => method,
        x0 => x_i,
        y0 => y_i,
        z0 => z_i,
        n_iter => n_iter,
        x_out => x_i_reg,
        y_out => y_i_reg,
        z_out => z_i_reg
    );

    logic: process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then 
                n_iter <= (others => '0');
                x_i <= x0;
                y_i <= y0;
                z_i <= z0;
            elsif n_iter < SIZE then
                x_i <= x_i_reg;
                y_i <= y_i_reg;
                z_i <= z_i_reg;
                n_iter <= n_iter +1;
            else 
                n_iter <= (others => '0');
                x_i <= x0;
                y_i <= y0;
                z_i <= z0;
            end if;
        end if;
    end process;

    x_out <= (others => '0') when n_iter /= SIZE else x_i; 
    y_out <= (others => '0') when n_iter /= SIZE else y_i; 
    z_out <= (others => '0') when n_iter /= SIZE else z_i; 

end cordic_iter_arch;