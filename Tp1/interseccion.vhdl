library ieee;
use ieee.std_logic_1164.all;

entity interseccion is
    port(
        clock: in std_logic;
        reset: in std_logic;
        rojo_1: out std_logic;
        amarillo_1: out std_logic;
        verde_1: out std_logic;
        rojo_2: out std_logic;
        amarillo_2: out std_logic;
        verde_2: out std_logic
    );
end interseccion;

architecture interseccion_arq of interseccion is

    type state is(vr, ar0, ar1, ra0, ra1, rv);

    signal current_state: state;
    signal sig_3seg: std_logic;
    signal sig_30seg: std_logic;
    signal rst_sincrono: std_logic;

begin

    rojo_1 <= '1' when current_state = ra0 or current_state = ra1 else '0';
    amarillo_1 <= '1' when current_state = ar0 or current_state = ar1 else '0';
    verde_1 <= '1' when current_state = vr else '0';

    rojo_2 <= '1' when current_state = ar0 or current_state = ar1 else '0';
    amarillo_2 <= '1'when current_state = ra0 or current_state = ra1 else '0';
    verde_2 <= '1' when current_state = rv else '0';
    
    process(clock) is
    begin
        if reset = '1' then 
            current_state <= vr;
        else if rising_edge(clock) then
            if current_state = vr and sig_30seg = '1' then
                current_state <= ar0;
            else if current_state = ar0 and sig_3seg = '1' then
                current_state <= ra0;
            else if current_state = ra0 and sig_3seg = '1' then
                current_state <= rv;
            else if current_state = rv and sig_30seg = '1' then
                current_state <= ra1;
            else if current_state = ra1 and sig_3seg = '1' then
                current_state <= ar1;
            else if current_state = ar1 and sig_3seg = '1' then
                current_state <= vr;
            end if;end if;end if;end if;end if;end if;
        end if;
        end if;
    end process;
    
    rst_sincrono <= '1' when current_state = ra0 or current_state = ar1 else '0';

    timer: entity work.timer
    port map(
        sig_3seg => sig_3seg,
        sig_30seg => sig_30seg,
        rst_sincrono => rst_sincrono,
        clock => clock,
        reset => reset
    );

end interseccion_arq;