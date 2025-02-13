library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	generic (
		F : natural := 50000;	-- Device clock frequency [KHz].
		min_baud : natural := 1200;
		num_data_bits : natural := 8
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
		Rx	: in std_logic; -- Bit entrante
		Divisor	: in std_logic_vector; 
		Dout	: out std_logic_vector(num_data_bits-1 downto 0); --Dato recibido
		RxRdy	: out std_logic; 
		RxErr	: out std_logic
	);
end;

architecture arch of uart is
	signal top16		: std_logic;
	signal toprx		: std_logic;
	signal Sig_ClrDiv	: std_logic;
begin
	reception_unit: entity work.receive
		generic map(NDBits=>num_data_bits)
		port map (
			CLK 	=> clk,
			RST 	=> rst,
			Rx		=> Rx,
			Dout	=> Dout,
			RxErr	=> RxErr,
			RxRdy	=> RxRdy,
			ClrDiv	=> Sig_ClrDiv,
			Top16	=> top16,
			TopRx	=> toprx
		);
	timings_unit: entity work.timing
		generic map (F => F,	min_baud => min_baud)
		port map (
  			CLK	=> clk,
  			RST	=> rst,
			divisor	=> Divisor,
			ClrDiv	=> Sig_ClrDiv,
			Top16	=> top16,
			TopRx	=> toprx
			);
	
end;
