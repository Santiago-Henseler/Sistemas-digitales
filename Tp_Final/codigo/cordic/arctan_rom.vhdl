library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE IEEE.MATH_REAL.ALL;

entity arctan_rom is
	generic(
		ADD_W: natural:= 10;
		DATA_W: natural:= 9
    );
	port(
		addr: in std_logic_vector(ADD_W-1 downto 0);
		data: out std_logic_vector(DATA_W-1 downto 0)
    );
end entity arctan_rom;

architecture arctan_rom_arq of arctan_rom is

	type rom_type is array (natural range <>) of std_logic_vector(DATA_W-1 downto 0);

	function arctan ( constant i : natural) return std_logic_vector is
		constant ph : real := 2.0**(-real(i)); 
    begin
		return std_logic_vector(to_unsigned(integer(round(arctan(ph)*real(2**(DATA_W-1))/MATH_PI)), DATA_W));
	end;

	function arctan_tabla (
		constant start : natural;
		constant stop  : natural)
		return rom_type is
		variable retval : rom_type(start to stop);
	begin
		for i in start to stop loop
			retval(i) := arctan(i);
		end loop;
		return retval;
	end;

	constant ROM : rom_type(0 to 2**(ADD_W)-1) := arctan_tabla(0, 2**(ADD_W)-1);
begin

	data <= ROM(to_integer(unsigned(addr)));

end architecture arctan_rom_arq;