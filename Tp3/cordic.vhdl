library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
    generic(
        SIZE: natural := 8  -- Cantidad de iteraciones
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        method: in std_logic; -- 0 para utilizar el modo rotación 1 para el modo vector
        x0: in std_logic_vector(SIZE-1 downto 0);
        y0: in std_logic_vector(SIZE-1 downto 0);
        z0: in std_logic_vector(SIZE-1 downto 0);
        z_rot: in std_logic_vector(SIZE-1 downto 0);  -- cambiar por signed de SIZE+1
        x_out: out std_logic_vector(SIZE-1 downto 0);
        y_out: out std_logic_vector(SIZE-1 downto 0);
        z_out: out std_logic_vector(SIZE-1 downto 0)
    );
end cordic;

architecture cordic_arch of cordic is

    signal aux, x_i, y_i, z_i: signed(SIZE+1 downto 0);
    signal n_iter: integer;

    function shift(x :signed; i: integer) return signed is
        variable rta: signed(x'range) := (others => '0');
    begin
        rta := x;
        for j in 1 to i loop
            rta := rta(rta'high) & rta(rta'high downto rta'low + 1);
        end loop;

        return rta;
    end function shift;

    signal y_shift, x_shift : signed(SIZE+1 downto 0);
begin

    logic: process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then 
                n_iter <= 0;
                x_i <= signed("00" & x0);
                y_i <= signed("00" & y0);
                z_i <= signed("00" & z0);
            elsif n_iter < SIZE then
                if z_i(SIZE) = '0' then
                    x_i <= (x_i - shift(y_i, n_iter));
                    y_i <= (y_i + shift(x_i, n_iter));
                else
                    x_i <= (x_i + shift(y_i, n_iter));
                    y_i <= (y_i - shift(x_i, n_iter));
                end if;
                n_iter <= n_iter + 1;
            else 
                n_iter <= 0;
                x_i <= signed("00" & x0);
                y_i <= signed("00" & y0);
                z_i <= signed("00" & z0);
            end if;
        end if;
    end process;
            
    x_out <= (others => '0') when n_iter /= SIZE else std_logic_vector(x_i(SIZE-1 downto 0)); 
    y_out <= (others => '0') when n_iter /= SIZE else std_logic_vector(y_i(SIZE-1 downto 0)); 
    z_out <= (others => '0') when n_iter /= SIZE else std_logic_vector(z_i(SIZE-1 downto 0)); 

end cordic_arch;