-------------------------------------------------------------------------------
--  
--  Copyright (c) 2009 Xilinx Inc.
--
--  Project  : Programmable Wave Generator
--  Module   : uart_rx.vhd
--  Parent   : wave_gen.vhd and uart_led.vhd
--  Children : uart_rx_ctl.vhd uart_baud_gen.vhd meta_harden.vhd
--
--  Description: 
--     Top level of the UART receiver.
--     Brings together the metastability hardener for synchronizing the 
--     rxd pin, the baudrate generator for generating the proper x16 bit
--     enable, and the controller for the UART itself.
--     
--
--  Parameters:
--     BAUD_RATE : Baud rate - set to 57,600bps by default
--     CLOCK_RATE: Clock rate - set to 50MHz by default
--
--  Local Parameters:
--
--  Notes       : 
--
--  Multicycle and False Paths
--     The uart_baud_gen module generates a 1-in-N pulse (where N is
--     determined by the baud rate and the system clock frequency), which
--     enables all flip-flops in the uart_rx_ctl module. Therefore, all paths
--     within uart_rx_ctl are multicycle paths, as long as N > 2 (which it
--     will be for all reasonable combinations of Baud rate and system
--     frequency).
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx is
	generic(
		BAUD_RATE: integer := 115200; 	-- Baud rate
		CLOCK_RATE: integer := 50E6
	);
	port(
		-- Write side inputs
		clk_rx: 		in std_logic;      				-- Clock input
		rst_clk_rx: 	in std_logic;   				-- Active HIGH reset - synchronous to clk_rx
						
		rxd_i: 			in std_logic;      				-- RS232 RXD pin - Directly from pad
		rxd_clk_rx: 	out std_logic;					-- RXD pin after synchronization to clk_rx
	
		rx_data: 		out std_logic_vector(7 downto 0);	-- 8 bit data output
													--  - valid when rx_data_rdy is asserted
		rx_data_rdy: 	out std_logic;  				-- Ready signal for rx_data
		frm_err: 		out std_logic      				-- The STOP bit was not detected	
	);
end;

architecture uart_rx_arq of uart_rx is

	component meta_harden is
		port(
			clk_dst: 	in std_logic;	-- Destination clock
			rst_dst: 	in std_logic;	-- Reset - synchronous to destination clock
			signal_src: in std_logic;	-- Asynchronous signal to be synchronized
			signal_dst: out std_logic	-- Synchronized signal
		);
	end component;
	
	component uart_baud_gen is
		generic(
			BAUD_RATE: natural := 115200;	-- Baud rate
			CLOCK_RATE: natural := 50E6

		);
		port(
			-- Write side inputs
			clk: 			in std_logic;       -- Clock input
			rst: 			in std_logic;       -- Active HIGH reset - synchronous to clk
			baud_x16_en: 	out std_logic   	-- Oversampled Baud rate enable
		);
	end component;
	
	component uart_rx_ctl is
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
	end component;


	signal baud_x16_en: std_logic;			-- 1-in-N enable for uart_rx_ctl FFs
	
	signal rxd_clk_rx_aux: std_logic;		--	senal auxiliar
begin
	-- Synchronize the RXD pin to the clk_rx clock domain. Since RXD changes
	-- very slowly wrt. the sampling clock, a simple metastability hardener is
	-- sufficient
	meta_harden_rxd_i0: meta_harden
		port map(
			clk_dst    => clk_rx,
			rst_dst    => rst_clk_rx, 
			signal_src => rxd_i,
			signal_dst => rxd_clk_rx_aux
		);

	uart_baud_gen_rx_i0: uart_baud_gen
		generic map(
			BAUD_RATE => BAUD_RATE,
			CLOCK_RATE => CLOCK_RATE
		)
		port map(
			clk         => clk_rx,
			rst         => rst_clk_rx,
			baud_x16_en => baud_x16_en
		);

	uart_rx_ctl_i0: uart_rx_ctl
		port map(
			clk_rx      => clk_rx,
			rst_clk_rx  => rst_clk_rx,
			baud_x16_en => baud_x16_en,
			rxd_clk_rx  => rxd_clk_rx_aux,
			rx_data_rdy => rx_data_rdy,
			rx_data     => rx_data,
			frm_err     => frm_err
		);
		
	rxd_clk_rx <= rxd_clk_rx_aux;

end;
