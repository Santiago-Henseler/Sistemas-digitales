library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity delay_gen is
	generic(
		N: natural:= 8;
		DELAY: natural:= 0
	);
	port(
		clk: in std_logic;
		A: in std_logic_vector(N-1 downto 0);
		B: out std_logic_vector(N-1 downto 0)
	);
end;

architecture del of delay_gen is
	type auxi is array(0 to DELAY+1) of std_logic_vector(N-1 downto 0);
	signal aux: auxi;
	
	component FFD is
		generic(N: natural:= 8);
		port(
			clk: in std_logic;
			rst: in std_logic;
			D: in std_logic_vector(N-1 downto 0);
			Q: out std_logic_vector(N-1 downto 0)
		);
	end component FFD;
	
begin

	aux(0) <= A;
	
	gen_retardo: for i in 0 to DELAY generate
		sin_retardo: if i = 0 generate
						aux(1) <= aux(0);
		end generate;
		con_retardo: if i > 0 generate
						aa: ffd
						generic map(N => N) 
						port map(clk => clk, rst => '0', D => aux(i), Q => aux(i+1));
		end generate;
	end generate;
	
	B <= aux(DELAY+1);
	
end;