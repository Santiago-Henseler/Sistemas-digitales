library ieee;
use ieee.std_logic_1164.all;

entity tb_cordic is
end tb_cordic;

architecture arq_tb of tb_cordic is
    constant SIZE: natural := 2;

    signal x0,y0,z0,x_out,y_out,z_out: std_logic_vector(SIZE-1 downto 0);
    signal clock: std_logic:= '0';
    signal reset: std_logic := '1';
begin
    reset <= '0' after 20 ns;
    clock <= not clock after 10 ns;

    x0 <= "10";
    y0 <= "01";
    z0 <= "11";
   
    dut: entity work.cordic 
    generic map(
        SIZE => 2
    )
    port map(
        clock => clock,
        reset => reset,
        x0 => x0,
        y0 => y0,
        z0 => z0,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out
    );

end arq_tb;