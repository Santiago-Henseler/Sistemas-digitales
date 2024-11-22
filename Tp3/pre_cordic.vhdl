library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pre_cordic is
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
end pre_cordic;

architecture pre_cordic_arch of pre_cordic is
    signal x_aux, y_aux, z_aux : signed(SIZE+1 downto 0);
    signal change: std_logic;

    -- Complementa a 2 el numero pasado por parametro
    function complemento_a_2(num: signed) return signed is
        variable rta: signed(num'range);
    begin
        rta := not num;
        rta := rta + "1";
        return rta; 
    end function complemento_a_2;

begin

    change <= (z0(SIZE+1) xor z0(SIZE));

    x_aux <= x0 when change = '0' else complemento_a_2(x0);
    y_aux <= y0 when change = '0' else complemento_a_2(y0);
    z_aux <= z0 when change = '0' else ((not z0(SIZE+1)) & z0(SIZE downto 0));

    cor_type: entity work.cordic_des
    generic map(SIZE => SIZE)
    port map(
        clock => clock,
        reset => reset,
        method => method,
        x0 => x_aux,
        y0 => y_aux,
        z0 => z_aux,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out
    );


end pre_cordic_arch;