--------------------------------------------------------------------------
--                                                                      --
--  Modulo Acumulador de Fase                                           --
--                                                                      --                                                                        ----
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity Sin_Rom is
	generic(
		ADD_W  : integer:= 10;
		DATA_W : integer:= 9
    );
	port(
		clk_i   : in std_logic;
		addr1_i : in std_logic_vector(ADD_W-1 downto 0);
		addr2_i : in std_logic_vector(ADD_W-1 downto 0);
		data1_o : out std_logic_vector(DATA_W-1 downto 0);
		data2_o : out std_logic_vector(DATA_W-1 downto 0)
    );
end entity Sin_Rom;

architecture Xilinx of Sin_Rom is

	type rom_type is array (natural range <>) of std_logic_vector(DATA_W-1 downto 0);

	-- Funcion
	function sin (
		constant i : natural;      -- punto a calcular
		constant n : natural)      -- cantidad de palabras
		return std_logic_vector is
		constant ph : real := (math_pi*real(i))/(2.0*real(n)); -- 2*pi*i/cant_puntos ==> desde 0 a 2*pi      (0 a 360°)
                                                              -- (pi/2)*(1/cant_puntos) ==> desde 0 a pi/2  (0 a 90°)
    begin
		return std_logic_vector(to_unsigned(integer(round(sin(ph)*real((2**DATA_W)-1))), DATA_W));
	end;

	-- Funcion: devuelve al ROM.
	function sintab (
		constant start : natural;
		constant stop  : natural;
		constant n     : natural)
		return rom_type is
		variable retval : rom_type(start to stop);
	begin
		for i in start to stop loop
			retval(i) := sin(i,n);
		end loop;
		return retval;
	end;

	constant SIN_ROM : rom_type(0 to 2**(ADD_W)-1) := sintab(0, 2**(ADD_W)-1, 2**ADD_W);

	signal addr1_r : std_logic_vector(ADD_W-1 downto 0):=(others => '0');
	signal addr2_r : std_logic_vector(ADD_W-1 downto 0):=(others => '0');
begin

	Read_ROM: process (clk_i)
	begin
		if falling_edge(clk_i) then
			addr1_r <= addr1_i;
			addr2_r <= addr2_i;
		end if;
	end process Read_ROM;

	data1_o <= SIN_ROM(to_integer(unsigned(addr1_r)));
	data2_o <= SIN_ROM(to_integer(unsigned(addr2_r)));

end architecture Xilinx; -- Entity: Sin_Rom