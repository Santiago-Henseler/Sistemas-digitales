library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_ram is
    generic(
		ADD_W: natural := 20;
        DATA_SIZE: natural := 1
    );
    port(
        write: in std_logic;
        read: in std_logic;
        addrW: in std_logic_vector(ADD_W-1 downto 0); 
        addrR: in std_logic_vector(ADD_W-1 downto 0);
        data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
        data_o: out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end dual_ram;

architecture dual_ram_arch of dual_ram is
    type ram_type is array (0 to 2**(ADD_W)-1) of std_logic_vector(DATA_SIZE-1 downto 0);
    shared variable RAM : ram_type := (others => (others => '0'));
begin
    process(write, addrW)
    begin
        if write = '1' then
           RAM(to_integer(unsigned(addrW))) := data_i;
        end if;
    end process;

    process(read, addrR)
    begin
        if read = '1' then
            data_o <= RAM(to_integer(unsigned(addrR)));
        else
            data_o <= (others => '0');
        end if;
    end process;
end dual_ram_arch;