library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

entity cordic is
    generic(
        SIZE: natural := 8  -- Cantidad de iteraciones
    );
    port (
        method: in std_logic; -- 0 para utilizar el modo rotación 1 para el modo vector
        n_iter: unsigned(natural(ceil(log2(real(SIZE))))+1 downto 0);
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
    function shift(x : signed; i : integer) return signed is
        variable rta: signed(x'range) := x;
        variable count: integer := 0; -- Contador para iterar
    begin
        while count < i loop
            rta := rta(x'high) & rta(rta'high downto 1); -- Desplazamiento con signo
            count := count + 1;
        end loop;
        return rta;
    end function shift;

    signal data_rom: std_logic_vector(SIZE+1 downto 0);
    signal addr: std_logic_vector(add_size-1 downto 0);

    signal type_method: std_logic;

    signal x_shift, y_shift : signed(SIZE+1 downto 0);

    begin

    -- Direccion en la memoria ROM dependiendo de la etapa
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

    x_shift <= shift(x0, to_integer(n_iter));
    y_shift <= shift(y0, to_integer(n_iter));

    x_out <= (x0 - y_shift) when type_method = '0' else (x0 + y_shift); 
    y_out <= (y0 + x_shift) when type_method = '0' else (y0 - x_shift); 
    z_out <= (z0 - signed(data_rom)) when type_method = '0' else (z0 + signed(data_rom));

    type_method <= z0(SIZE+1) when method = '0' else y0(SIZE+1);

end cordic_arch;