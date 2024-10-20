library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumador_float is
    generic(
        Ne: natural := 8;
        Nf: natural := 23
    );
    port (
        operacion: in std_logic; --tipo de operación (1 si es resta, 0 si es suma)
        operandoA: in std_logic_vector(Ne+Nf downto 0);
        operandoB: in std_logic_vector(Ne+Nf downto 0);
        resultado: out std_logic_vector(Ne+Nf downto 0)
    );
end sumador_float;

architecture sumador_float_arch of sumador_float is

    constant ALINGSIZE: natural := 2**Ne-1;
    constant ALINGCEROMINOR: unsigned(ALINGSIZE downto Nf+1):= (others => '0'); 
    constant SIZE: natural := Ne+Nf+1;
    
    signal exp_a, exp_b: unsigned(Ne-1 downto 0);
    signal exp_dif: unsigned(Ne downto 0);

    -- Definiciones de mantisas
    signal significantA, significantB: unsigned(Nf downto 0);
    signal mantisa_mayor, mantisa_menor: unsigned(Nf downto 0);
    signal mantisa_mayor_aling, mantisa_menor_aling: unsigned(ALINGSIZE downto 0);

    -- Funcion para alinear la mayor mantisa
    function aling(x: unsigned(Nf downto 0); dif: natural) return unsigned is
        variable menor: unsigned(dif-1 downto 0) := (others => '0');
        variable mayor1: unsigned(ALINGSIZE-dif downto Nf + dif) := (others => '0');
        variable mayor2: unsigned(ALINGSIZE-dif downto Nf + 1) := (others => '0');
    
        variable result: unsigned(ALINGSIZE downto 0);
    begin
        if dif /= 0 then  
            result := mayor1 & x & menor;
        else
            result := mayor2 & x;
        end if;
    
        return result;
    end aling;

begin

    -- Desempaqueto el exponente
    exp_a <= unsigned(operandoA(SIZE-2 downto Nf));
    exp_b <= unsigned(operandoB(SIZE-2 downto Nf));

    -- Desempaqueto el significante
    significantA <= '1' & unsigned(operandoA(Nf-1 downto 0));
    significantB <= '1' & unsigned(operandoB(Nf-1 downto 0));

    -- Determino la operación y si hay que complementar

    
    -- Determino el exp mayor 
    exp_dif <= ('0' & exp_a) - ('0' & exp_b);

    -- Invierto o no la ubicación de las mantisas
    mantisa_mayor <= significantA when exp_dif(Ne) = '0' else significantB; 
    mantisa_menor <= significantA when exp_dif(Ne) = '1' else significantB;

    -- Alineo 'trivialmente' la mantisa menor 
    mantisa_menor_aling <= ALINGCEROMINOR & mantisa_menor;

    -- Alineo la mantisa mayor
    mantisa_mayor_aling <= aling(mantisa_mayor, to_integer(exp_dif));


end sumador_float_arch;
