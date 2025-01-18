library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dp_ram is
end tb_dp_ram;

architecture arq_tb of tb_dp_ram is
    constant ADD_W: natural := 2;

    signal write, read: std_logic;
    signal addrW, addrR: std_logic_vector(ADD_W-1 downto 0);
    signal data_i, data_o: std_logic_vector(0 downto 0);
begin
    
    -- cargo valores en la ram
    write <= '1';
    addrW <= "00", "01" after 10 ns, "10" after 20 ns, "11" after 30 ns, "01" after 40 ns, "00" after 50 ns, "11" after 60 ns; 
    data_i <= "1", "0" after 30 ns;

    -- leo los valores de la ram utilizando los dos puertos
    read <= '1';
    addrR <= "00" after 20 ns, "01" after 40 ns, "10" after 50 ns, "11" after 60 ns; 

    dp_ram_inst: entity work.dual_ram 
    generic map(
        ADD_W => ADD_W,
        DATA_SIZE => 1
    )
    port map(
        write => write,
        read => read,
        addrW => addrW,
        addrR => addrR,
        data_i => data_i,
        data_o => data_o
    );

end arq_tb;