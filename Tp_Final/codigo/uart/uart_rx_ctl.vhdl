-------------------------------------------------------------------------------
--  
--  Copyright (c) 2009 Xilinx Inc.
--
--  Project  : Programmable Wave Generator
--  Module   : uart_rx_ctl.vhd
--  Parent   : uart_rx
--  Children : none
--
--  Description: 
--     UART receiver controller
--     Implements the state machines for doing RS232 reception.
--
--     Based on the detection of the falling edge of the synchronized rxd
--     input, this module waits 1/2 of a bit period (8 periods of baud_x16_en)
--     to find the middle of the start bit, and resamples it. If rxd 
--     is still low it accepts it as a valid START bit, and captures the rest
--     of the character, otherwise it rejects the start bit and returns to
--     idle.
--
--     After detecting the START bit, it advances 1 full bit period at a time
--     (16 periods of baud_x16_en) to end up in the middle of the 8 data
--     bits, where it samples the 8 data bits. 
--
--     After the last bit is sampled (the MSbit, since the LSbit is sent
--     first), it waits one additional bit period to check for the STOP bit.
--     If the rxd line is not high (the value of a STOP bit), a framing error
--     is signalled. Regardless of the value of the rxd, though, the module
--     returns to the IDLE state and immediately begins looking for the 
--     start of the next character.
--
--     NOTE: The total cycle time through the state machine is 9 1/2 bit
--     periods (not 10) - this allows for a mismatch between the transmit and
--     receive clock rates by as much as 5%.
--
--  Parameters:
--     None
--
--  Local Parameters:
--
--  Notes       : 
--
--  Multicycle and False Paths
--    All flip-flops within this module share the same chip enable, generated
--    by the Baud rate generator. Hence, all paths from FFs to FFs in this
--    module are multicycle paths.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx_ctl is
	port(
		-- Write side inputs
		clk_rx: 		in std_logic;   -- Clock input
		rst_clk_rx: 	in std_logic;   -- Active HIGH reset - synchronous to clk_rx
		baud_x16_en: 	in std_logic;  	-- 16x oversampling enable

		rxd_clk_rx:		in std_logic;	-- RS232 RXD pin - after sync to clk_rx

		rx_data:		out std_logic_vector(7 downto 0);	-- 8 bit data output
															--  - valid when rx_data_rdy is asserted
		rx_data_rdy:	out std_logic;	-- Ready signal for rx_data
		frm_err:	    out std_logic	-- The STOP bit was not detected
	
	);
end;

architecture uart_rx_ctl_arq of uart_rx_ctl is 

	-- State encoding for main FSM
	constant IDLE  : std_logic_vector(1 downto 0) := "00";
	constant START : std_logic_vector(1 downto 0) := "01";
	constant DATA  : std_logic_vector(1 downto 0) := "10";
	constant STOP  : std_logic_vector(1 downto 0) := "11";


	signal state: std_logic_vector(1 downto 0);          	-- Main state machine
	signal over_sample_cnt: std_logic_vector(3 downto 0);	-- Oversample counter - 16 per bit
	signal bit_cnt: std_logic_vector(2 downto 0);			-- Bit counter - which bit are we RXing

	signal over_sample_cnt_done: std_logic;	-- We are in the middle of a bit
	signal bit_cnt_done: std_logic;        	-- This is the last data bit
  
begin	-- Main state machine

	process(clk_rx)
	begin
		if rising_edge(clk_rx) then
			if rst_clk_rx = '1' then
				state <= IDLE;
			else
				if baud_x16_en = '1' then
					case state is
						when IDLE =>
							-- On detection of rxd_clk_rx being low, transition to the START
							-- state
							if rxd_clk_rx = '0' then
								state <= START;
							end if;
						when START =>
							-- After 1/2 bit period, re-confirm the start state
							if over_sample_cnt_done = '1' then
								if rxd_clk_rx = '0' then
									-- Was a legitimate start bit (not a glitch)
									state <= DATA;
								else
									state <= IDLE;
								end if;
							end if;
						when DATA =>
							-- Once the last bit has been received, check for the stop bit
							if over_sample_cnt_done = '1' and bit_cnt_done = '1' then
								state <= STOP;
							end if;
						when STOP =>
							-- Return to idle
							if over_sample_cnt_done = '1' then
								state <= IDLE;
							end if;
						when others =>
							state <= IDLE;
					end case;				
				end if;	-- if baud_x16_en
			end if;	-- if rst_clk_rx
		end if;	-- if rising_edge
	end process;
		
		
		



	-- Oversample counter
	-- Pre-load to 7 when a start condition is detected (rxd_clk_rx is 0 while in
	-- IDLE) - this will get us to the middle of the first bit.
	-- Pre-load to 15 after the START is confirmed and between all data bits.
	process(clk_rx)
	begin
		if rising_edge(clk_rx) then
			if rst_clk_rx = '1' then
				over_sample_cnt <= (others => '0');
			else
				if baud_x16_en = '1' then
					if over_sample_cnt_done = '0' then
						over_sample_cnt <= std_logic_vector(unsigned(over_sample_cnt) - 1);
					else
						if state = IDLE and rxd_clk_rx = '0' then
							over_sample_cnt <= "0111";
						elsif (state = START and rxd_clk_rx = '0') or (state = DATA) then
							over_sample_cnt <= "1111";
						end if;
					end if;
				end if; -- baud_x16_en
			end if;	-- rst_clk_rx
		end if;	-- rising_edge
	end process;


	over_sample_cnt_done <= '1' when over_sample_cnt = "0000" else '0';

	-- Track which bit we are about to receive
	-- Set to 0 when we confirm the start condition
	-- Increment in all DATA states
	process(clk_rx)
	begin
		if rising_edge(clk_rx) then
			if rst_clk_rx = '1' then
				bit_cnt <= "000";
			else
				if baud_x16_en = '1' then
					if over_sample_cnt_done = '1' then
						if state = START then
							bit_cnt <= "000";
						elsif state = DATA then
							bit_cnt <= std_logic_vector(unsigned(bit_cnt) + 1);
						end if;
					end if; -- over_sample_cnt_done
				end if; -- baud_x16_en
			end if; -- rst_clk_rx
		end if; -- rising_edge
	end process;

	bit_cnt_done <= '1' when (bit_cnt = "111") else '0';

	-- Capture the data and generate the rdy signal
	-- The rdy signal will be generated as soon as the last bit of data
	-- is captured - even though the STOP bit hasn't been confirmed. It will
	-- remain asserted for one BIT period (16 baud_x16_en periods)
	process(clk_rx)
	begin
		if rising_edge(clk_rx) then
		    rx_data_rdy <= '0';
			if rst_clk_rx = '1' then
				rx_data <= "00000000";
				rx_data_rdy <= '0';
			else
				if baud_x16_en = '1' and over_sample_cnt_done = '1' then
					if state = DATA then
						rx_data(to_integer(unsigned(bit_cnt))) <= rxd_clk_rx;
						if bit_cnt = "111" then
							rx_data_rdy <= '1';
						else
							rx_data_rdy <= '0';
						end if;
					else
						rx_data_rdy <= '0';
					end if;
				end if; -- baud_x16_en
			end if; -- rst_clk_rx
		end if; -- rising_edge
	end process;


	-- Framing error generation
	-- Generate for one baud_x16_en period as soon as the framing bit
	-- is supposed to be sampled
	process(clk_rx)
	begin
		if rising_edge(clk_rx) then
			if rst_clk_rx = '1' then
				frm_err <= '0';
			else
				if baud_x16_en = '1' then
					if state = STOP and over_sample_cnt_done = '1' and rxd_clk_rx = '0' then
						frm_err <= '1';
					else
						frm_err <= '0';
					end if;
				end if; -- baud_x16_en
			end if;	-- rst_clk_rx
		end if; -- rising_edge
	end process;
	
end;