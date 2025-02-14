library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gettter is
	generic(
		ADD_W: natural := 8
	);
	port(
		clk, reset: in std_logic;
		data: in std_logic_vector(9 downto 0);
		addrR: out std_logic_vector (ADD_W-1 downto 0)
	);
	
end gettter;

architecture gettter_arch of gettter is
	signal n: natural;
	signal tmp_addr: unsigned(ADD_W-1 downto 0); 
	
	 component vio_1
           port(
               clk : in std_logic;
               probe_out0 : out std_logic_vector(9 downto 0);
               probe_out1 : out std_logic_vector(9 downto 0);
               probe_out2 : out std_logic_vector(9 downto 0)
           );
        end component;
        
           signal x,y,z: std_logic_vector(9 downto 0);

begin

    U_vio : vio_1
    port map (
        clk => clk,                
        probe_out0 => x,
        probe_out1 => y,
        probe_out2 => z
    );

process(clk, reset)    
begin 
    if rising_edge(clk) then 
        if reset = '1' then
            tmp_addr <=(others => '0');
        else 
            if n = 0 then
                x <= data;
                n <= n+1;
            elsif n = 1 then
                y <= data;
                n <= n+1;
            else
                z <= data;
                n <= 0;
            end if;
		     -- Calcular la dirección de memoria    
            tmp_addr <= tmp_addr+1;
        end if;
    end if;
end process;   
	addrR <= std_logic_vector(tmp_addr);
end gettter_arch;