library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

entity cordic is
    generic(
        SIZE: natural := 8  -- Cantidad de iteraciones
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        method: in std_logic; -- 0 para utilizar el modo rotación 1 para el modo vector
        n_iter: in unsigned(SIZE+1 downto 0);
        x0: in signed(SIZE+1 downto 0);
        y0: in signed(SIZE+1 downto 0);
        z0: in signed(SIZE+1 downto 0);
        x_out: out signed(SIZE+1 downto 0);
        y_out: out signed(SIZE+1 downto 0);
        z_out: out signed(SIZE+1 downto 0)
    );
end cordic;

architecture cordic_arch of cordic is

    CONSTANT add_size: integer := integer(ceil(log2(real(SIZE))));

    -- funcion para shiftear i veces a la derecha manteniendo el signo
    function shift(x :signed; i: integer) return signed is
        variable rta: signed(x'range) := x;
    begin
        for j in 1 to i loop
            rta := rta(SIZE) & rta(rta'high downto 1);
        end loop;

        return rta;
    end function shift;

    signal data_rom: std_logic_vector(SIZE+1 downto 0);
    signal addr: std_logic_vector(add_size-1 downto 0);
begin

    addr <= std_logic_vector(n_iter(add_size-1 downto 0));

    ROM: entity work.arctan_rom
    generic map(
        ADD_W => add_size,
        DATA_W => SIZE+2
    )
    port map(
        addr => addr,
        data => data_rom
    );

    x_out <= (x0 - shift(y0, to_integer(n_iter))) when z0(SIZE) = '0' else (x0 + shift(y0, to_integer(n_iter))); 
    y_out <= (y0 + shift(x0, to_integer(n_iter))) when z0(SIZE) = '0' else (y0 - shift(x0, to_integer(n_iter))); 
    z_out <= (z0 - signed(data_rom)) when z0(SIZE) = '0' else (z0 + signed(data_rom));

end cordic_arch;