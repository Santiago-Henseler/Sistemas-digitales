library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        clock: in std_logic;
        reset: in std_logic;
        rst_sincrono: in std_logic;
        sig_3seg: out std_logic;
        sig_30seg: out std_logic
    );
end timer;

architecture timer_arq of timer is

    constant TRES_SEGUNDOS: unsigned(27 downto 0) := to_unsigned(149999999, 28);
    constant DIEZ: unsigned(3 downto 0):= to_unsigned(10, 4);

    signal current_time: unsigned(27 downto 0);
    signal count: unsigned(3 downto 0);

begin

    sig_3seg <= '1' when current_time = TRES_SEGUNDOS else '0';
    sig_30seg <= '1' when count = DIEZ else '0';

    process(clock, reset) is
    begin
        if reset = '1' then
            current_time <= (others => '0');
            count <= (others => '0');
        elsif rising_edge(clock) then
            if current_time = TRES_SEGUNDOS then
                current_time <= (others => '0');
            else
                current_time <= current_time + 1;
            end if;
            if count = DIEZ or rst_sincrono = '1' then 
                count <= (others => '0');
            elsif current_time = TRES_SEGUNDOS then
                count <= count + 1;
            end if;
        end if;
    end process;

end timer_arq;
