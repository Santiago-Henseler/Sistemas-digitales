library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_ram is
    generic(
		ADD_W: natural := 20  -- uso direcciones de 20 bits porque log(307199) es 19,585 
    );
    port(
        write1: in std_logic;
        read1: in std_logic;
        read2: in std_logic;
        addr1: in std_logic_vector(ADD_W-1 downto 0); 
        addr2: in std_logic_vector(ADD_W-1 downto 0);
        data1_i: in std_logic;
        data1_o: out std_logic;
        data2_o: out std_logic
    );
end dual_ram;

architecture dual_ram_arch of dual_ram is
    type ram_type is array (0 to 2**(ADD_W)-1) of std_logic;
    shared variable RAM : ram_type :=(others => '0');
begin
    process(write1, read1, addr1)
    begin
        if write1 = '1' and read1 = '0' then
           RAM(to_integer(unsigned(addr1))) := data1_i;
        elsif write1 = '0' and read1 = '1' then
            data1_o <= RAM(to_integer(unsigned(addr1)));
        else
            data1_o <= '0';
        end if;
    end process;

    process(read2, addr2)
    begin
        if read2 = '1' then
            data2_o <= RAM(to_integer(unsigned(addr2)));
        else
            data2_o <= '0';
        end if;
    end process;
end dual_ram_arch;