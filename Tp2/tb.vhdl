library ieee;
use ieee.std_logic_1164.all;

entity tb is
end tb;

architecture arq_tb of tb is
    constant SIZE: natural := 23;

    signal enable_tb, reset_tb, clock_tb: std_logic := '0';
    signal operandoA_tb, operandoB_tb: std_logic_vector(SIZE-1 downto 0);
    signal rta_tb: std_logic_vector(SIZE-1 downto 0);

begin

    clock_tb <= not clock_tb after 10 ns;
    reset_tb <= '1', '0' after 10 ns;
    enable_tb <= '1';
    operandoA_tb <= "11111101111111111111111";
    operandoB_tb <= "00111101010001110011001";

    mult: entity work.multiplicador_float(multiplicador_float_arch) 
    generic map(
        Ne => 6,
        Nf => 17
    )
    port map(
        enable => enable_tb,
        reset => reset_tb,
        clock => clock_tb,
        operandoA => operandoA_tb,
        operandoB => operandob_tb,
        resultado => rta_tb
    );
end arq_tb;