library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_rotador_3d is
end tb_rotador_3d;

architecture arq_tb of tb_rotador_3d is
    constant SIZE: natural := 10;

    signal x_out,y_out,z_out: signed(SIZE+1 downto 0);
    signal z0:  signed(SIZE+1 downto 0) := (others => '0');
    signal y0:  signed(SIZE+1 downto 0) := (others => '0');
    signal x0:  signed(SIZE+1 downto 0) := (others => '0');

    signal a1,a2,a3: signed(SIZE+1 downto 0) := "000000000000";

    signal clock: std_logic := '0';
    signal reset: std_logic := '1';
    signal req, ack: std_logic := '0';

    signal step: natural:= 0;
begin
    reset <= '0' after 20 ns;
    clock <= not clock after 10 ns;

    process(clock, ack)
    begin
        if rising_edge(clock) then
            if req = '1' then
                req <= '0';
            elsif req = '0' then
                if step = 0 then
                    -- Vector original (120, 0 , 0) y deberia devolver el mismo
                    -- Pero por los errores de aproximación del coordic se transfomra en (110,0,0)
                    x0 <= to_signed(120,SIZE+2);
                    step <= step+1;
                    req <= '1';
                elsif ack = '1' and step = 1 then 
                    -- Vector original (120, 0 , 0) y deberia devolver (116,0,-29)
                    -- Pero por los errores de aproximación del coordic se transfomra en (107,0,-4)
                    a2 <= to_signed(40, SIZE+2); -- Angulo de aproximadamente 14 grados en eje y 
                    step <= step+1;
                    req <= '1';
                elsif ack = '1' and step = 2 then 
                    -- Vector original (120, 0 , 80) y deberia devolver (135,0,50)
                    -- Pero por los errores de aproximación del coordic se transfomra en (117,0,69)
                    z0 <= to_signed(80, SIZE+2);
                    step <= step+1;
                    req <= '1';
                elsif ack = '1' and step = 3 then 
                    -- Vector original (120, 70 , 80) y deberia devolver (135,70,50)
                    -- Pero por los errores de aproximación del coordic se transfomra en (116,63,68)
                    y0 <= to_signed(70, SIZE+2);
                    step <= step+1;
                    req <= '1';
                end if;
            end if;
        end if;
    end process;



    d_rot: entity work.rotador_equ 
    generic map(
        SIZE => SIZE
    )
    port map(
        clock => clock,
        reset => reset,
        req => req,
        x0 => x0,
        y0 => y0,
        z0 => z0,
        a1 => a1,
        a2 => a2,
        a3 => a3,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out,
        ack => ack
    );

end arq_tb;