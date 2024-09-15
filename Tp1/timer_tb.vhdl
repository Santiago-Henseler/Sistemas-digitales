library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std;

entity timer_tb is
end timer_tb;

architecture timer_tb_arq of timer_tb is

    signal sig_3seg_tb: std_logic;
    signal sig_30seg_tb: std_logic;
    signal clock_tb: std_logic := '0';
    signal reset_tb: std_logic;

    begin
    
    clock_tb <= not clock_tb after 20 ns;
    reset_tb <= '1', '0' after 5 ns, '0' after 40 ns;
  
    Dut: entity work.timer
    port map(
        sig_3seg => sig_3seg_tb,
        sig_30seg => sig_30seg_tb,
        clock => clock_tb,
        reset => reset_tb
    );

end timer_tb_arq;