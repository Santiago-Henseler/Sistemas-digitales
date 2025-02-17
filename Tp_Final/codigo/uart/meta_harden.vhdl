-----------------------------------------------------------------------------
--  
--  Copyright (c) 2008 Xilinx Inc.
--
--  Project  : Programmable Wave Generator
--  Module   : meta_harden.vhd
--  Parent   : Various
--  Children : None
--
--  Description: 
--    This is a basic meta-stability hardener; it double synchronizes an
--    asynchronous signal onto a new clock domain.
--
--  Parameters:
--    None
--
--  Notes       : 
--
--  Multicycle and False Paths, Timing Exceptions
--    A tighter timing constraint should be placed between the signal_meta
--    and signal_dst flip-flops to allow for meta-stability settling time
--

library IEEE;
use IEEE.std_logic_1164.all;

entity meta_harden is
	port(
		clk_dst: 	in std_logic;	-- Destination clock
		rst_dst: 	in std_logic;	-- Reset - synchronous to destination clock
		signal_src: in std_logic;	-- Asynchronous signal to be synchronized
		signal_dst: out std_logic	-- Synchronized signal
	);
end;

architecture meta_harden_arq of meta_harden is

	signal signal_meta: std_logic;	-- After sampling the async signal, this has
									-- a high probability of being metastable.
									-- The second sampling (signal_dst) has
									-- a much lower probability of being
									-- metastable

begin
	process(clk_dst)
	begin
		if rising_edge(clk_dst) then
			if rst_dst = '1' then
				signal_meta <= '0';
				signal_dst  <= '0';
			else
				signal_meta <= signal_src;
				signal_dst  <= signal_meta;
			end if;
		end if;
	end process;
end;
