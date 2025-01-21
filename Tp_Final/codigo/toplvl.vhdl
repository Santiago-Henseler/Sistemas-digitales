library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplvl is
port(
		clock, reset, rx: in std_logic;
		hsync , vsync : out std_logic;
		rgb : out std_logic_vector(2 downto 0);
		done: out std_logic
	);
end toplvl;

architecture Behavioral of toplvl is

    component vio_0 
        port(
            clk : in std_logic;
            probe_out0 : out std_logic_vector(0 downto 0);
            probe_out1:  out std_logic_vector(0 downto 0);
            probe_out2 : out std_logic_vector(0 downto 0);
            probe_out3 : out std_logic_vector(0 downto 0);
            probe_out4 : out std_logic_vector(0 downto 0);
            probe_out5 : out std_logic_vector(0 downto 0)
            );
     end component;


   signal x0,x1 ,y0,y1,z0,z1 :std_logic_vector(0 downto 0);
begin

	driver_inst: entity work.driver
	port map (
            clock => clock,
            reset => reset,
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
            done => done
	);


    U_vio : vio_0
    port map (
        clk => clock,                
        probe_out0 => x0,
        probe_out1 => x1,
        probe_out2 => y0,
        probe_out3 => y1,
        probe_out4 => z0,
        probe_out5 => z1
    );

end Behavioral;
