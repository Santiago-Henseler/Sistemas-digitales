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

    signal bias: integer := 2**(Ne-1)-1;

    signal significant_mult: unsigned(2*Nf-1 downto 0);
    signal exp, expA, expB: unsigned(Ne-1 downto 0);
    signal mantisaA, mantisaB: unsigned(Nf-1 downto 0);
    signal signo: std_logic;
    
begin

    signo <= operandoA(Ne+Nf-1) xor operandoB(Ne+Nf-1);
    expA <= unsigned(operandoA(Ne+Nf-2 downto Nf-1));
    expB <= unsigned(operandoB(Ne+Nf-2 downto Nf-1));
    exp <= expA + expB - to_unsigned(bias, Ne-1);

    mantisaA <= '1' & unsigned(operandoA(Nf-2 downto 0));
    mantisaB <= '1' & unsigned(operandoB(Nf-2 downto 0));

    significant_mult <= mantisaA * mantisaB;

    resultado <= signo & std_logic_vector(exp & significant_mult(2*Nf-2 downto Nf));

end multiplicador_float_arch;