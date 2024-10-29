library ieee;
use ieee.std_logic_1164.all;

entity tb_suma is
end tb_suma;

architecture arq_tb of tb_suma is
    constant SIZE: natural := 23;

    signal operandoA_tb, operandoB_tb: std_logic_vector(SIZE-1 downto 0);
    signal rta_tb: std_logic_vector(SIZE-1 downto 0);

begin

    operandoA_tb <= "11111101111111111111111";
    operandoB_tb <= "00111101010001110011001","00000000000000000000000" after 15 ns;

    mult: entity work.sumador_float(sumador_float_arch) 
    generic map(
        Ne => 6,
        Nf => 15
    )
    port map(
        operacion => '1',
        operandoA => operandoA_tb,
        operandoB => operandoB_tb,
        resultado => rta_tb
    );
end arq_tb;