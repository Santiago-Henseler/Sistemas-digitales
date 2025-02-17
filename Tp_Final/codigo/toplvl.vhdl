library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplvl is
port(
		clock, rx: in std_logic;
		hsync , vsync : out std_logic;
		rgb : out std_logic_vector(2 downto 0);
		done: out std_logic
	);
end toplvl;

architecture Behavioral of toplvl is

    -- Instancio el vio para controlar la rotación del mundito
    component vio_0 
        port(
            clk : in std_logic;
            probe_out0 : out std_logic_vector(0 downto 0);
            probe_out1:  out std_logic_vector(0 downto 0);
            probe_out2 : out std_logic_vector(0 downto 0);
            probe_out3 : out std_logic_vector(0 downto 0);
            probe_out4 : out std_logic_vector(0 downto 0);
            probe_out5 : out std_logic_vector(0 downto 0);
            probe_out6 : out std_logic_vector(0 downto 0);
            probe_in0 : in std_logic_vector(9 downto 0);
            probe_in1 : in std_logic_vector(9 downto 0);
            probe_in2 : in std_logic_vector(9 downto 0);
            probe_in3 : in std_logic_vector(7 downto 0);
            probe_in4 : in std_logic_vector(0 downto 0)
            );
     end component;

   signal x0,x1 ,y0,y1,z0,z1, rst, err :std_logic_vector(0 downto 0);
   
   signal x_o, y_o, z_o: std_logic_vector(9 downto 0);
   
   signal recibidos: std_logic_vector(7 downto 0);
begin

	driver_inst: entity work.driver
	port map (
            clock => clock,
            reset => rst(0),
            rx => rx,
            btn_x0 => x0(0),
            btn_x1 => x1(0),
            btn_y0 => y0(0),
            btn_y1 => y1(0),
            btn_z0 => z0(0),
            btn_z1 => z1(0),
            hsync => hsync ,
            vsync => vsync,
            rgb => rgb,
            done => done,
            x_vio => x_o,
            y_vio => y_o,
            z_vio => z_o,
            recibidos => recibidos,
            err => err(0)
	);


    U_vio : vio_0
    port map (
        clk => clock,                
        probe_out0 => x0,
        probe_out1 => x1,
        probe_out2 => y0,
        probe_out3 => y1,
        probe_out4 => z0,
        probe_out5 => z1,
        probe_out6 => rst,
        probe_in0 => x_o,
        probe_in1 => y_o,
        probe_in2 => z_o,
        probe_in3 => recibidos,
        probe_in4 => err
    );

end Behavioral;
