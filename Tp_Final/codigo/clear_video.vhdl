library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity clear_video is
	generic(
		ADD_W: natural := 10
	);
	port(
		clock, reset: in std_logic;
        req: in std_logic;
		addrW_Vram : out std_logic_vector(ADD_W-1 downto 0);
		ack : out std_logic
	);
end clear_video;

architecture clear_video_arq of clear_video is

	signal i: integer:=0;
begin

	process( clock, reset )
	begin
		if rising_edge(clock) then
			ack <= '0';
			if reset = '1' then
				i <= 0;
			elsif req = '1' then
				if i = 2** ADD_W-1 then
					ack <= '1';
					i <= 0;
				else
					addrW_Vram <= std_logic_vector(to_unsigned(i, ADD_W));
					i <= i+1;
				end if;
			end if;
		end if;
	end process;

end clear_video_arq;
