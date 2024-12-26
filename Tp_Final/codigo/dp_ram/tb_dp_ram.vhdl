library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dp_ram is
end tb_dp_ram;

architecture arq_tb of tb_dp_ram is
    constant ADD_W: natural := 2;

    signal write1, read1, read2, data1_i, data1_o, data2_o: std_logic;
    signal addr1, addr2: std_logic_vector(ADD_W-1 downto 0) := (others => '0');
begin
    
    -- cargo valores en la ram
    write1 <= '1', '0' after 40 ns;
    addr1 <= "00", "01" after 10 ns, "10" after 20 ns, "11" after 30 ns, "01" after 40 ns, "00" after 50 ns, "11" after 60 ns; 
    data1_i <= '1', '0' after 20 ns;

    -- leo los valores de la ram utilizando los dos puertos
    read1 <= '0', '1' after 40 ns;
    read2 <= '0', '1' after 40 ns;
    addr2 <= "01" after 40 ns, "10" after 50 ns, "11" after 60 ns; 


    dp_ram_inst: entity work.dual_ram 
    generic map(
        ADD_W => ADD_W
    )
    port map(
        write1 => write1,
        read1 => read1,
        read2 => read2,
        addr1 => addr1,
        addr2 => addr2,
        data1_i => data1_i,
        data1_o => data1_o,
        data2_o => data2_o
    );

end arq_tb;