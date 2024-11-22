library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cordic is
end tb_cordic;

architecture arq_tb of tb_cordic is
    constant SIZE: natural := 10;

    signal x_out,y_out,z_out: signed(SIZE+1 downto 0);
    signal z0:  signed(SIZE+1 downto 0) := (others => '0');
    signal y0:  signed(SIZE+1 downto 0) := (others => '0');
    signal x0:  signed(SIZE+1 downto 0) := "011111111010";
    signal clock: std_logic:= '0';
    signal reset: std_logic := '1';

    signal i:integer:= 0;
begin
    reset <= '0' after 20 ns;
    clock <= not clock after 10 ns;

    process( clock )
    begin
        if rising_edge(clock) then
            if z0 > (2**SIZE)-1 then
                z0 <= (others => '0');
            end if;
            if i < SIZE+1 then
                i <= i + 1;
            else 
                i <= 0;
                z0 <= z0 + 1;
                x0 <= x_out;
                y0 <= y_out;
            end if;
        end if;
    end process;

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