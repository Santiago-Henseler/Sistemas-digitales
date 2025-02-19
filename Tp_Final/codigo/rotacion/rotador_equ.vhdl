library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotador_equ is
    generic(
        SIZE: natural := 10  -- Cantidad de iteraciones
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        req: in std_logic;
        x0: in signed(SIZE+1 downto 0);
        y0: in signed(SIZE+1 downto 0);
        z0: in signed(SIZE+1 downto 0);
        a1: in signed(SIZE+1 downto 0); 
        a2: in signed(SIZE+1 downto 0); 
        a3: in signed(SIZE+1 downto 0); 
        x_out: out signed(SIZE+1 downto 0);
        y_out: out signed(SIZE+1 downto 0);
        z_out: out signed(SIZE+1 downto 0);
        ack: out std_logic
    );
end rotador_equ;

architecture rotador_equ_arq of rotador_equ is

    constant GANANCIA: signed := to_signed(3, SIZE+1);  -- por cada cordic hay una ganancia de ≈ 1,65 => 1,65**3 ≈ 4.45

    signal req_y, req_z: std_logic;
    signal x_out_1, y_out_1, x_out_2, y_out_2, x_out_3, y_out_3: signed(SIZE+1 downto 0);
    signal ack_x, ack_y: std_logic;

begin

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                req_y <= '0';
                req_z <= '0';
            else
                if ack_x = '1' then
                    req_y <= '1';
                else 
                    req_y <= '0';
                end if;

                if ack_y = '1' then
                    req_z <= '1';
                else 
                    req_z <= '0';
                end if;

            end if;
        end if;
    end process;

    rot_x: entity work.pre_cordic 
    generic map(
        SIZE => SIZE
    )
    port map(
        clock => clock,
        reset => reset,
        req => req,
        method => '0',
        x0 => y0,
        y0 => z0,
        z0 => a1,
        x_out => x_out_1,
        y_out => y_out_1,
        z_out => open,
        ack => ack_x
    );

    rot_y: entity work.pre_cordic 
    generic map(
        SIZE => SIZE
    )
    port map(
        clock => clock,
        reset => reset,
        req => req_y,
        method => '0',
        x0 => y_out_1,
        y0 => x0,
        z0 => a2,
        x_out => x_out_2,
        y_out => y_out_2,
        z_out => open,
        ack => ack_y
    );

    rot_z: entity work.pre_cordic 
    generic map(
        SIZE => SIZE
    )
    port map(
        clock => clock,
        reset => reset,
        req => req_z,
        method => '0',
        x0 => y_out_2,
        y0 => x_out_1,
        z0 => a3,
        x_out => x_out_3,
        y_out => y_out_3,
        z_out => open,
        ack => ack
    );

    x_out <= resize(x_out_3 / GANANCIA, x_out'length);
    y_out <= resize(y_out_3 / GANANCIA, y_out'length);
    z_out <= resize(x_out_2 / GANANCIA, z_out'length);

end rotador_equ_arq;