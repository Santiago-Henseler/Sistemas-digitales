library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity timing is
generic (
	F : natural;
	min_baud: natural
);
port (
      CLK : in std_logic;
      RST : in std_logic;
      divisor : in std_logic_vector;
      ClrDiv : in std_logic;
      Top16 : buffer std_logic;
      TopRx : out std_logic
);
end timing;

Architecture timing of timing is
	constant max_div : natural := ((F*1000)/(16*min_baud));
	subtype div16_type is natural range 0 to max_div-1;
	signal Div16	: div16_type;
	signal ClkDiv	: integer;
	signal RxDiv	: integer;
begin

      process (RST, CLK)
         begin
            if RST='1' then
               Top16 <= '0';
               Div16 <= 0;
            elsif rising_edge(CLK) then
               Top16 <= '0';
               if Div16 = to_integer(unsigned(divisor)) then
               	  Div16 <= 0;
                  Top16 <= '1';
               else
                  Div16 <= Div16 + 1;
               end if;
            end if;
      end process;

      process (RST, CLK)
         begin
            if RST='1' then
               ClkDiv <= 0;
            elsif rising_edge(CLK) then
               if Top16='1' then
                  ClkDiv <= ClkDiv + 1;
                  if ClkDiv = 15 then
                     ClkDiv <= 0;
                  end if;
               end if;
            end if;
      end process;
      process (RST, CLK)
        begin
            if RST='1' then
               TopRx <= '0';
               RxDiv <= 0;
            elsif rising_edge(CLK) then
               TopRx <= '0';
               if ClrDiv='1' then
                  RxDiv <= 0;
               elsif Top16='1' then
                  if RxDiv = 7 then
                     RxDiv <= 0;
                     TopRx <= '1';
                  else
                    RxDiv <= RxDiv + 1;
                  end if;
               end if;
            end if;
      end process;
end architecture;
