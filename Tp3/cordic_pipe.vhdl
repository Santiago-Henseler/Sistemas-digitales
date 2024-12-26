library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

entity cordic_pipe is
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
end cordic_pipe;

architecture cordic_pipe_arch of cordic_pipe is
    type matrix is array (SIZE+1 downto 0) of signed(SIZE+1 downto 0);
    signal x_i, y_i, z_i: matrix;
    signal x_reg, y_reg, z_reg: matrix;
begin
    p: process(clock, reset)
    begin
        if reset = '1' then
            for i in 0 to SIZE-1 loop
                x_reg(i) <= (others => '0');
                y_reg(i) <= (others => '0');
                z_reg(i) <= (others => '0');
            end loop;
        elsif rising_edge(clock) then
            x_reg(0) <= x0;
            y_reg(0) <= y0;
            z_reg(0) <= z0;
            for i in 0 to SIZE-1 loop
                x_reg(i+1) <= x_i(i+1);
                y_reg(i+1) <= y_i(i+1);
                z_reg(i+1) <= z_i(i+1);
            end loop;
        end if;
    end process; 
    
    cords: for i in 0 to SIZE-1 generate
        cords_inst: entity work.cordic
        generic map(
            SIZE => SIZE
        )
        port map (
            method => method,
            n_iter => to_unsigned(i, natural(ceil(log2(real(SIZE))))+2),
            x0 => x_reg(i),
            y0 => y_reg(i),
            z0 => z_reg(i),
            x_out => x_i(i+1),
            y_out => y_i(i+1),
            z_out => z_i(i+1)
        );
    end generate cords;

    -- Devuelve el ultimo valor luego de la operación
    x_out <= x_i(SIZE);
    y_out <= y_i(SIZE);
    z_out <= z_i(SIZE);

end cordic_pipe_arch;