library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controler is
	generic (
		BAUD_RATE: integer := 115200;
		CLOCK_RATE: integer := 50E6;
        ADD_W: natural := 8; -- Tamaño de direccionamiento de la RAM
		num_data_bits : natural := 8 -- Tamaño del dato a recibir
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
        rx : in std_logic;
        data: out std_logic_vector(num_data_bits-1 downto 0);
		addrW: out std_logic_vector(ADD_W-1 downto 0);
		fin_rx: out std_logic;
		recibidos: out std_logic_vector(7 downto 0)
	);
end;

architecture arch of uart_controler is

    signal ready: std_logic;
    signal dout, dout_reg: std_logic_vector(num_data_bits-1 downto 0);
    signal rst_clk_rx: std_logic;
    
    signal addr_act:  unsigned(ADD_W-1 downto 0);
begin

	meta_harden_rst_i0: entity work.meta_harden
		port map(
			clk_dst 	=> clk,
			rst_dst 	=> '0',    		-- No reset on the hardener for reset!
			signal_src 	=> rst,
			signal_dst 	=> rst_clk_rx
		);

    uart_inst: entity work.uart_rx
	generic map (
		BAUD_RATE	=> BAUD_RATE,
		CLOCK_RATE => CLOCK_RATE
	)
	port map (
        clk_rx	=> clk,
		rst_clk_rx	=> rst_clk_rx,
		rxd_i	=> rx,
		rx_data	=> dout,
        rxd_clk_rx 	=> open,
		rx_data_rdy	=> ready,
		frm_err	=> open
	);
	    
    process(clk, rst , ready, dout)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                addr_act <= (others => '0');
                dout_reg <= (others => '0');
                fin_rx <= '0';
            elsif addr_act = to_unsigned(35838, ADD_W) then -- porque hay 35841 coordenadas a recibir
                fin_rx <= '1';
            elsif ready = '1' then -- Cuando el uart indica que termino de recibir el dato lo guardo en la RAM
                recibidos <= dout;
                dout_reg <= dout;
                addr_act <= addr_act+1;
            end if;
        end if;
    end process;
    
    data <= dout_reg;
    addrW <= std_logic_vector(addr_act);
end;
