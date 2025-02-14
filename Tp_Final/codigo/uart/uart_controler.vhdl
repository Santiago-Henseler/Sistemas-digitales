library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_controler is
	generic (
		F : natural := 50000;	-- Device clock frequency [KHz].
		min_baud : natural := 1200;
        ADD_W: natural := 8; -- Tamaño de direccionamiento de la RAM
		num_data_bits : natural := 8 -- Tamaño del dato a recibir
	);
	port (
		clk	: in std_logic;
		rst	: in std_logic;
        rx : in std_logic;
        data: out std_logic_vector(num_data_bits-1 downto 0);
		addrW: out std_logic_vector(ADD_W-1 downto 0);
		fin_rx: out std_logic
	);
end;

architecture arch of uart_controler is
    constant Divisor: std_logic_vector := "000000011011"; -- Divisor=27 para 115200 baudios

    signal ready: std_logic;
    signal dout, dout_reg: std_logic_vector(num_data_bits-1 downto 0);
    
    signal addr_act:  unsigned(ADD_W-1 downto 0);
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
	    
    process(clk, rst , ready, dout)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                addr_act <= (others => '0');
                dout_reg <= (others => '0');
                fin_rx <= '0';
            elsif addr_act >= to_unsigned(35842, ADD_W) then -- porque hay 35841 coordenadas a recibir
                fin_rx <= '1';
            elsif ready = '1' then -- Cuando el uart indica que termino de recibir el dato lo guardo en la RAM
                dout_reg <= dout;
                addr_act <= addr_act+1;
            end if;
        end if;
    end process;
    
    data <= dout_reg;
    addrW <= std_logic_vector(addr_act);
end;
