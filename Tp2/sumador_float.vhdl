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

    -- Constantes varias
    constant ALINGSIZE: natural := (2**Ne)+Nf;
    constant ALINGCEROMAYOR: unsigned(2**Ne-1 downto 0) := (others => '0');
    constant SIZE: natural := Ne+Nf+1;

    -- Definiciones para casos de cero
    constant CERO: integer := 0;
    constant CEROVECTOR: std_logic_vector(Nf-1 downto 0) := (others => '0');
    signal opA_cero, opB_cero: std_logic;
    
    -- Definiciones de exponentes
    signal exp_a, exp_b,indice: unsigned(Ne-1 downto 0);
    signal exp_dif, exp_final_exc: unsigned(Ne downto 0);
    signal absoluto:unsigned(Ne-1 downto 0);

    -- Definiciones de mantisas
    signal significantA, significantB: unsigned(Nf downto 0);
    signal mantisa_mayor, mantisa_menor: unsigned(Nf downto 0);
    signal mantisa_menor_cmp, mantisa_mayor_cmp, mantisa_mayor_aling, mantisa_menor_aling: unsigned(ALINGSIZE+1 downto 0);
    signal suma, suma_cmp: unsigned(ALINGSIZE+1 downto 0);
    signal mantisa: unsigned(Nf-1 downto 0);

    -- Signo 
    signal signo: std_logic;

    --Alinea la menor mantisa segun el desplazamiento
    function alineo_menor(menor: unsigned; dif: integer) return unsigned is
        variable rta: unsigned(ALINGSIZE downto 0) := (others => '0');
    begin
        for i in menor'range loop
            rta(i+2**Ne-dif-1) := menor(i);
        end loop;
    return rta;
    end function alineo_menor;

    -- Definiciones para complementar
    signal swap: std_logic;
    signal complementar: std_logic_vector(1 downto 0);

    -- Determina cual de las 2 mantizas hay que complementar el bit de la derecha es para la mantiza mayor
    function hay_q_complementar(signoA: std_logic; signoB: std_logic; swp: std_logic; op: std_logic) return std_logic_vector is
    begin
        if (((signoA = '1' and signoB = '1' and swp = '0') or (signoB = '1' and swp = '1' and signoA = '1')) and op = '0') then
            return "11";
        elsif (((signoA = '1' and signoB = '0' and swp = '0') or (signoB = '1' and swp = '1' and signoA = '0')) and op = '1') then 
            return "11";
        elsif (signoA = '1' and swp = '0') or (signoB = '1' and swp = '1') then
            return "10";
        elsif (((signoA = '1' and swp = '1') or (signoB = '1' and swp = '0')) and op = '0') then
            return "01";
        elsif (((signoA = '0' and swp = '1') or (signoB = '0' and swp = '0')) and op = '1') then
            return "01";
        else 
            return "00";
        end if;
    end function hay_q_complementar;

    -- Complementa a 2 el numero pasado por parametro
    function complemento_a_2(num: unsigned) return unsigned is
        variable rta: unsigned(num'range);
    begin
        rta := not num;
        rta := rta + "1";
        return rta; 
    end function complemento_a_2;

    -- Busco el primer 1 a la izquierda
    procedure desp_hasta_uno(num: unsigned; signal indexO: out unsigned; signal result_vec:out unsigned) is
        variable index: integer:= -1;
    begin
        for i in num'range loop
            if num(i) = '1' then
                index := i; 
                exit;
            end if;
        end loop;

        if index > 0 then
            indexO <= to_unsigned(num'LENGTH-index-1, Ne);
            result_vec <= num(index-1 downto index-Nf);
        else 
            indexO <= (others => '0');
            result_vec <= (others => '0');
        end if;
    end procedure desp_hasta_uno;

begin

    -- Desempaqueto el exponente
    exp_a <= unsigned(operandoA(SIZE-2 downto Nf));
    exp_b <= unsigned(operandoB(SIZE-2 downto Nf));

    -- Desempaqueto el significante
    significantA <= '1' & unsigned(operandoA(Nf-1 downto 0));
    significantB <= '1' & unsigned(operandoB(Nf-1 downto 0));

    -- Determino el exp mayor 
    exp_dif <= ('0' & exp_a) - ('0' & exp_b);

    swap <= exp_dif(Ne);
    absoluto <= exp_dif(Ne-1 downto 0) when swap = '0' else complemento_a_2(exp_dif(Ne-1 downto 0));

    -- Determino la operación y si hay que complementar
    complementar <= hay_q_complementar(operandoA(SIZE-1), operandoB(SIZE-1), swap, operacion);
    
    -- Invierto o no la ubicación de las mantisas
    mantisa_mayor <= significantA when swap = '0' else significantB; 
    mantisa_menor <= significantA when swap = '1' else significantB;

    -- Alineo 'trivialmente' la mantisa mayor 
    mantisa_mayor_aling <= '0' & mantisa_mayor & ALINGCEROMAYOR;

    -- Alineo la mantisa menor
    mantisa_menor_aling <= '0' & alineo_menor(mantisa_menor, to_integer(absoluto));

    -- Complemento las mantisas si es necesario
    mantisa_menor_cmp <= mantisa_menor_aling when complementar(0) = '0' else complemento_a_2(mantisa_menor_aling);
    mantisa_mayor_cmp <= mantisa_mayor_aling when complementar(1) = '0' else complemento_a_2(mantisa_mayor_aling);

    -- Efectuo la suma
    suma <= mantisa_mayor_cmp + mantisa_menor_cmp;

    -- Complemento el resultado de la suma si es necesario
    suma_cmp <= suma when suma(ALINGSIZE+1) = '0' else complemento_a_2(suma);

    -- Desplazo hasta el primer uno
    desp_hasta_uno(suma_cmp(ALINGSIZE downto 0), indice, mantisa);

    -- Empaqueto el exponente
    exp_final_exc <= ('0' & exp_a) - ('0' & indice) when swap = '0' else
                     ('0' & exp_b) - ('0' & indice);

    -- Signo 
    signo <= '1' when suma(ALINGSIZE+1) = '1' else '0';

    -- Empaqueto el resultado teniendo en cuenta el caso de los 0
    opA_cero <= '1' when (to_integer(exp_a) = CERO and (operandoA(Nf-1 downto 0) = CEROVECTOR)) else '0';
    opB_cero <= '1' when (to_integer(exp_b) = CERO and (operandoB(Nf-1 downto 0) = CEROVECTOR)) else '0';
    
    resultado <= operandoA when opB_cero = '1' else
                operandoB when opA_cero = '1' else
                (others => '1') when exp_final_exc(Ne) = '1' else
                signo & std_logic_vector(exp_final_exc(Ne-1 downto 0)) & std_logic_vector(mantisa);


end sumador_float_arch;