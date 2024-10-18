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
        operandoA: in std_logic_vector(Ne+Nf downto 0);
        operandoB: in std_logic_vector(Ne+Nf downto 0);
        resultado: out std_logic_vector(Ne+Nf downto 0)
    );
end multiplicador_float;

architecture multiplicador_float_arch of multiplicador_float is

    constant SIZE: natural := Ne+Nf+1;
    constant UNO: integer := 1;
    constant CERO: integer := 0;
    constant CEROVECTOR: std_logic_vector(Nf-1 downto 0) := (others => '0');

    signal bias: integer := 2**(Ne-1)-1;
    signal desp: integer := 0;

    signal exp, expA, expB: unsigned(Ne-1 downto 0);
    signal exp_exc: unsigned(Ne+1 downto 0);
    
    signal significant_mult: std_logic_vector(2*Nf+1 downto 0);
    signal significantA, significantB: unsigned(Nf downto 0);
    signal mantisa: std_logic_vector(Nf-1 downto 0);
    signal mntexp: std_logic_vector(Nf+Ne-1 downto 0);

    signal signo: std_logic;
    signal opA_cero, opB_cero: std_logic;

begin

    -- Defino como va a ser el signo
    signo <= operandoA(SIZE-1) xor operandoB(SIZE-1);

    -- Defino como va a ser el exponente
    expA <= unsigned(operandoA(SIZE-2 downto Nf));
    expB <= unsigned(operandoB(SIZE-2 downto Nf));

    desp <= UNO when significant_mult(2*Nf+1) = '1' else CERO;
    exp_exc <= ("00" & expA) + ("00" & expB) + ("00" & to_unsigned(desp, 2)) - to_unsigned(bias, Ne+2);
    exp <= (others => '0') when exp_exc(Ne) = '1' else 
        (others => '1') when exp_exc(Ne+1) = '1' else
        exp_exc(Ne-1 downto 0);

    -- Defino como va a ser la mantisa
    significantA <= '1' & unsigned(operandoA(Nf-1 downto 0));
    significantB <= '1' & unsigned(operandoB(Nf-1 downto 0));
    significant_mult <= std_logic_vector(significantA * significantB);

    mantisa <= (others => '1') when exp_exc(Ne+1) = '1' else  -- menor número representable
            (others => '0') when exp_exc(Ne) = '1' else -- mayor número a representar
            significant_mult(2*Nf downto Nf+1) when significant_mult(2*Nf+1) = '1' else
            significant_mult(2*Nf-1 downto Nf);

    -- Empaqueto el resultado teniendo en cuenta el caso de los 0
    opA_cero <= '1' when (to_integer(expA) = CERO and (operandoA(Nf-1 downto 0) = CEROVECTOR)) else '0';
    opB_cero <= '1' when (to_integer(expB) = CERO and (operandoB(Nf-1 downto 0) = CEROVECTOR)) else '0';

    mntexp <= std_logic_vector(exp) & mantisa when (opA_cero = '0' and opB_cero = '0')
    else (others => '0');

    resultado <= signo & mntexp;

end multiplicador_float_arch;
