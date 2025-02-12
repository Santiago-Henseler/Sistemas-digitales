library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_ram is
    generic(
		ADD_W: natural := 20;
        DATA_SIZE: natural := 1
    );
    port(
        clock: in std_logic;
        addrW: in std_logic_vector(ADD_W-1 downto 0); 
        addrR: in std_logic_vector(ADD_W-1 downto 0);
        data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
        data_o: out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end dual_ram;

architecture dual_ram_arch of dual_ram is
    type ram_type is array (0 to 2**(ADD_W)-1) of std_logic_vector(DATA_SIZE-1 downto 0);
    signal RAM : ram_type := (others => (others => '0'));
    
    signal data_o_reg, data_i_reg: std_logic_vector(DATA_SIZE-1 downto 0);
begin

    process(clock)
    begin
        if rising_edge(clock) then
            RAM(to_integer(unsigned(addrW))) <= data_i;
        end if;
    end process;
    
    process(clock)
    begin
        if rising_edge(clock) then
              data_o_reg <= RAM(to_integer(unsigned(addrR)));
        end if;
    end process;
    
    data_o <= data_o_reg;
    
end dual_ram_arch;