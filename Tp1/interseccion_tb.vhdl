library ieee;
use ieee.std_logic_1164.all;

entity interseccion_tb is
end interseccion_tb;

architecture interseccion_tb_arq of interseccion_tb is

    signal clock_tb, reset_tb: std_logic := '0';
    signal rojo_1_tb, rojo_2_tb, amarillo_1_tb, amarillo_2_tb, verde_1_tb, verde_2_tb: std_logic;

begin
    
    clock_tb <= not clock_tb after 20 ns;
    reset_tb <= '1', '0' after 15 ns;

    Dut: entity work.interseccion
    port map(
        clock => clock_tb,
        reset => reset_tb,
        rojo_1 => rojo_1_tb,
        amarillo_1 => amarillo_1_tb,
        verde_1 => verde_1_tb,
        rojo_2 => rojo_2_tb,
        amarillo_2 => amarillo_2_tb,
        verde_2 => verde_2_tb
    );

end interseccion_tb_arq;