-------------------------------------------------------------------------------
--  
--  Copyright (c) 2008 Xilinx Inc.
--
--  Project  : Programmable Wave Generator
--  Module   : uart_baud_gen.vhd
--  Parent   : uart_rx and uart_tx
--  Children : None
--
--  Description: 
--     Generates a 16x Baud enable. This signal is generated 16 times per bit
--     at the correct baud rate as determined by the parameters for the system
--     clock frequency and the Baud rate
--
--  Parameters:
--     BAUD_RATE : Baud rate - set to 57,600bps by default
--     CLOCK_RATE: Clock rate - set to 50MHz by default
--
--  Local Parameters:
--     OVERSAMPLE_RATE: The oversampling rate - 16 x BAUD_RATE
--     DIVIDER    : The number of clocks per baud_x16_en
--     CNT_WIDTH  : Width of the counter
--
--  Notes       : 
--    1) Divider must be at least 2 (thus CLOCK_RATE must be at least 32x
--       BAUD_RATE)
--
--  Multicycle and False Paths
--    None
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_baud_gen is
	generic(
		BAUD_RATE: natural := 57600;	-- Baud rate
		CLOCK_RATE: natural := 50E6

	);
	port(
		-- Write side inputs
		clk: 			in std_logic;       -- Clock input
		rst: 			in std_logic;       -- Active HIGH reset - synchronous to clk
		baud_x16_en: 	out std_logic   	-- Oversampled Baud rate enable
	);
end;

architecture uart_baud_gen_arq of uart_baud_gen is

	-- Generate the ceiling of the log base 2 - i.e. the number of bits
	-- required to hold N values. A vector of size clogb2(N) will hold the
	-- values 0 to N-1
	function clogb2(value: integer) return integer is
		variable my_value: integer;
		variable i: integer := 0;
	begin
		my_value :=  value - 1;
		while my_value > 0 loop
			i := i + 1;
	        my_value := to_integer(shift_right(to_unsigned(my_value, 32), 1));
		end loop;
		return i;
	end function;
	
	-- The OVERSAMPLE_RATE is the BAUD_RATE times 16
	constant OVERSAMPLE_RATE: natural := BAUD_RATE * 16;

	-- The divider is the CLOCK_RATE / OVERSAMPLE_RATE - rounded up
	-- (so add 1/2 of the OVERSAMPLE_RATE before the integer division)
	constant DIVIDER: natural := (CLOCK_RATE+OVERSAMPLE_RATE/2) / OVERSAMPLE_RATE;

	-- The value to reload the counter is DIVIDER-1;
	constant OVERSAMPLE_VALUE: integer := DIVIDER - 1;

	-- The required width of the counter is the ceiling of the base 2 logarithm
	-- of the DIVIDER
	constant CNT_WID: natural := clogb2(DIVIDER);

	signal internal_count: std_logic_vector(CNT_WID-1 downto 0);
	signal baud_x16_en_reg: std_logic;

	signal internal_count_m_1: std_logic_vector(CNT_WID-1 downto 0);  -- Count minus 1

begin

	internal_count_m_1 <= std_logic_vector(unsigned(internal_count) - 1);

	-- Count from DIVIDER-1 to 0, setting baud_x16_en_reg when internal_count=0.
	-- The signal baud_x16_en_reg must come from a flop (since it is a module
	-- output) so schedule it to be set when the next count is 1 (i.e. when
	-- internal_count_m_1 is 0).

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				internal_count <= std_logic_vector(to_unsigned(OVERSAMPLE_VALUE, CNT_WID));
				baud_x16_en_reg <= '0';
			else
				-- Assert baud_x16_en_reg in the next clock when internal_count will be
				-- zero in that clock (thus when internal_count_m_1 is 0).
				if internal_count_m_1 = (CNT_WID-1 downto 0 => '0') then
					baud_x16_en_reg	<= '1';
				else
					baud_x16_en_reg	<= '0';
				end if;
				
				-- Count from OVERSAMPLE_VALUE down to 0 repeatedly
				if internal_count = (CNT_WID-1 downto 0 => '0') then
					internal_count <= std_logic_vector(to_unsigned(OVERSAMPLE_VALUE, CNT_WID));
				else -- internal_count is not 0
					internal_count <= internal_count_m_1;
				end if;	
				
			end if;
		end if;
	end process;
	
	baud_x16_en <= baud_x16_en_reg;
end;
		