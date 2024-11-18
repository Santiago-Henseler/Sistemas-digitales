library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_des is
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
end cordic_des;

architecture cordic_des_arch of cordic_des is
    type matrix is array (SIZE+1 downto 0) of signed(SIZE+1 downto 0);
    signal x_i, y_i, z_i: matrix;
    signal n_iter: unsigned(SIZE+1 downto 0):= (others => '0');
begin

    x_i(0) <= x0;
    y_i(0) <= y0;
    z_i(0) <= z0;
    
    cords: for i in 0 to SIZE generate
        n_iter <= n_iter +1 ;
        cords_inst: entity work.cordic port map (
            clock => clock,
            reset => reset,
            method => method,
            n_iter => n_iter,
            x0 => x_i(i),
            y0 => y_i(i),
            z0 => z_i(i),
            x_out => x_i(i+1),
            y_out => y_i(i+1),
            z_out => z_i(i+1)
            );
    end generate cords;

end cordic_des_arch;