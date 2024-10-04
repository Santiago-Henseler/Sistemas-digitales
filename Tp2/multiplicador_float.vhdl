library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador_float is
    generic(
        Ne: natural := 8;
        Nf: natural := 23
    );
    port (
        clock: in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        operandoA: in std_logic_vector(Ne+Nf-1 downto 0);
        operandoB: in std_logic_vector(Ne+Nf-1 downto 0);
        resultado: out std_logic_vector(Ne+Nf-1 downto 0)
    );
end multiplicador_float;

architecture multiplicador_float_arch of multiplicador_float is

    constant SIZE: natural := Ne+Nf;
    signal bias: integer := 2**(Ne-1)-1;
    
    signal significant_mult: unsigned(2*Nf-1 downto 0);
    signal exp, expA, expB: unsigned(Ne-1 downto 0);
    signal significantA, significantB: unsigned(Nf-1 downto 0);
    signal signo: std_logic;
    
begin

    signo <= operandoA(SIZE-1) xor operandoB(SIZE-1);
    expA <= unsigned(operandoA(SIZE-2 downto Nf-1));
    expB <= unsigned(operandoB(SIZE-2 downto Nf-1));
    
    significantA <= '1' & unsigned(operandoA(Nf-2 downto 0));
    significantB <= '1' & unsigned(operandoB(Nf-2 downto 0));
    significant_mult <= significantA * significantB;

    process(significant_mult)
    begin
        if significant_mult(2*Nf-1) = '0' then 
            --while significant_mult(2*Nf-1) = '0' then
            --  Desplazo un a posicion significant_mult 
            --end while;
        else
            exp <= expA + expB - to_unsigned(bias, Ne-1) + to_unsigned(1, Ne-1);
        end if;
    end process; 

    resultado <= signo & std_logic_vector(exp & significant_mult(2*Nf-2 downto Nf));

end multiplicador_float_arch;