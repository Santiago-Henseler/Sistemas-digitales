library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cordic is
end tb_cordic;

architecture arq_tb of tb_cordic is
    constant SIZE: natural := 10;

    signal x0,y0,z0,x_out,y_out,z_out: signed(SIZE+1 downto 0);
    signal clock: std_logic:= '0';
    signal reset: std_logic := '1';
begin
    reset <= '0' after 20 ns;
    clock <= not clock after 10 ns;

    x0 <= "100001001000";
    y0 <= "000100100110";
    z0 <= "000100101100";

    pre_cord: entity work.pre_cordic 
    generic map(
        SIZE => SIZE
    )
    port map(
        clock => clock,
        reset => reset,
        method => '0',
        x0 => x0,
        y0 => y0,
        z0 => z0,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out
    );

end arq_tb;