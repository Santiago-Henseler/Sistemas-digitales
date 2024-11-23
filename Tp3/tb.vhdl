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
    signal x0:  signed(SIZE+1 downto 0) := "001111111111";
    signal clock: std_logic := '0';
    signal reset: std_logic := '1';
    signal req, ack: std_logic;
begin
    reset <= '0' after 20 ns;
    clock <= not clock after 10 ns;

    process( clock, reset )
    begin
        if rising_edge(clock) then
            if ack = '1' then
                z0 <= z0 + 1;
            end if;
        end if;

        if reset ='1' then
            req <= '1';
        elsif rising_edge(clock) then
            if ack = '1' then 
            req <= '1'; 
            else 
                req <= '0';
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
        req => req,
        method => '0',
        x0 => x0,
        y0 => y0,
        z0 => z0,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out,
        ack => ack
    );

end arq_tb;