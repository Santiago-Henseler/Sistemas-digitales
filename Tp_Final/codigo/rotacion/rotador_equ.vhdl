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

    signal req_y, req_z: std_logic;
    signal x_out_1, y_out_1, z_out_1, x_out_2, y_out_2, z_out_2, x_out_3, y_out_3, z_out_3: signed(SIZE+1 downto 0);
    signal ack_x, ack_y: std_logic;

begin
  
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
        z_out => z_out_1,
        ack => ack_x
    );

    req_y <= '1' when ack_x = '1' else '0';

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
        z_out => z_out_2,
        ack => ack_y
    );

    req_z <= '1' when ack_y = '1' else '0';

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
        z_out => z_out_3,
        ack => ack
    );


    x_out <= x_out_3;
    y_out <= y_out_3;
    z_out <= x_out_2;

end rotador_equ_arq;