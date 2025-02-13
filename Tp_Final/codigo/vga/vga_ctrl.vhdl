library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
	generic(
		ADD_W: natural := 8
	);
	port(
		clk, rst: in std_logic;
		data: in std_logic_vector(0 downto 0);
		addrR: out std_logic_vector (ADD_W-1 downto 0);
		hsync , vsync : out std_logic;
		rgb : out std_logic_vector(2 downto 0)
	);
	
end vga_ctrl;

architecture vga_ctrl_arch of vga_ctrl is

	signal pixel_x: std_logic_vector(9 downto 0); -- son 1024 posiciones y solo necesito 640
	signal pixel_y: std_logic_vector(9 downto 0); -- son 512 posiciones y solo necesito 480
	signal video_on: std_logic;

begin

	vga_sync_unit: entity work.vga_sync
		port map(
			clk 	=> clk,
			rst 	=> rst,
			hsync 	=> hsync,
			vsync 	=> vsync,
			vidon	=> video_on,
			p_tick 	=> open,
			pixel_x => pixel_x,
			pixel_y => pixel_y
		);

	pixeles: entity work.gen_pixels
	    generic map(
	       ADD_W => ADD_W
	    )
		port map(
			clk		=> clk,
			reset	=> rst,
			data	=> data,
			addrR   => addrR,
			pixel_x	=> pixel_x,
			pixel_y	=> pixel_y,
			ena		=> video_on,
			rgb		=> rgb
		);
		
end vga_ctrl_arch;