library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_pixels is
	generic(
		ADD_W: natural := 8
	);
	port(
		clk, reset: in std_logic;
		ena: in std_logic;
		pixel_x: in std_logic_vector (9 downto 0);
		pixel_y: in std_logic_vector(9 downto 0); 
		data: in std_logic_vector(0 downto 0);
		addrR: out std_logic_vector (ADD_W-1 downto 0);
		rgb : out std_logic_vector(2 downto 0)
	);
	
end gen_pixels;

architecture gen_pixels_arch of gen_pixels is

	signal rgb_reg: std_logic_vector(2 downto 0);

begin

	process(clk, reset)
	   variable tmp_addres : std_logic_vector(ADD_W downto 0);
	begin
		if reset = '1' then
			rgb_reg <= (others => '0');
		elsif rising_edge(clk) then
		    tmp_addres := std_logic_vector(unsigned(pixel_x) + (640 * unsigned(pixel_y)));
			addrR <= tmp_addres(ADD_W-1 downto 0);
			if data = "1" then 
				rgb_reg <= (others => '1');
			else 
				rgb_reg <= (others => '0');
			end if;
		end if;
	end process;

	rgb <= rgb_reg when ena = '1' else (others => '0');

end gen_pixels_arch;