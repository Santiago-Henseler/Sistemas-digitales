library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controler is
	generic (
		F : natural := 50000;	-- Device clock frequency [KHz].
		min_baud : natural := 1200;
        ADD_W: natural := 8;
		num_data_bits : natural := 8
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
        rx : in std_logic;
        data: out std_logic_vector(num_data_bits-1 downto 0);
		addrW: out std_logic_vector(ADD_W-1 downto 0)
	);
end;

architecture arch of uart_controler is
    constant Divisor: std_logic_vector := "000000011011"; -- Divisor=27 para 115200 baudios

    signal ready: std_logic;
    signal dout: std_logic_vector(num_data_bits-1 downto 0);
begin
    uart_inst: entity work.uart
	generic map (
		F 	=> 50000, -- clock frequency
		min_baud => 1200,
		num_data_bits => 8
	)
	port map (
        clk	=> clk,
		rst	=> rst,
		Rx	=> rx,
        Divisor	=> Divisor,
		Dout	=> dout,
		RxRdy	=> ready,
		RxErr	=> open
	);
	
    process( ready )
        variable addr_act: unsigned(ADD_W-1 downto 0) := (others => '0');
    begin

        if ready = '1' then
            addr_act := addr_act+1;
            addrW <= std_logic_vector(addr_act);
            data <= dout;
        end if;

    end process; 

end;
