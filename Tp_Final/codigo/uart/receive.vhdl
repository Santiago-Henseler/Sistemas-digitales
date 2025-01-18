library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receive is
   generic (
	NDBits : natural := 8
   );
   port (
	CLK : in std_logic;
	RST : in std_logic;
	Rx : in std_logic;
	Dout : out std_logic_vector (NDBits-1 downto 0);
	RxErr : out std_logic;
	RxRdy : out std_logic;
	Top16 : in std_logic;
	ClrDiv : out std_logic;
	TopRx : in std_logic
   );
end;

architecture arch of receive is
   signal Rx_Reg : std_logic_vector (NDBits-1 downto 0);
   type State_Type is (Idle, Start_Rx, Edge_Rx, Shift_Rx, Stop_Rx, Rx_Ovf);
   signal RxFsm : State_Type;
   signal RxBitCnt : integer;
   signal Sig_RxRdy : std_logic;

begin
   RxRdy <= Sig_RxRdy;

   Rx_FSM: process (RST, CLK)
	begin
		if RST='1' then
			Rx_Reg <= (others => '0');
			Dout <= (others => '0');
			RxBitCnt <= 0;
			RxFSM <= Idle;
			Sig_RxRdy <= '0';
			ClrDiv <= '0';
			RxErr <= '0';
		elsif rising_edge(CLK) then
			ClrDiv <= '0';
			if Sig_RxRdy='1' then
				RxErr <= '0';
				Sig_RxRdy <= '0';
			end if;
			case RxFSM is
				when Idle => -- espera start bit
					RxBitCnt <= 0;
					if Top16='1' then
						if Rx='0' then
							RxFSM <= Start_Rx;
							ClrDiv <='1';
						end if; 
					end if;
				when Start_Rx => -- espera el primer bit de data 
					if TopRx = '1' then
						if Rx='1' then
							RxFSM <= Rx_OVF;
							report "Start bit error." severity note;
						else
							RxFSM <= Edge_Rx;
						end if;
					end if;
				when Edge_Rx =>
					if TopRx = '1' then
						RxFSM <= Shift_Rx;
						if RxBitCnt = NDbits then
							RxFSM <= Stop_Rx;
						else
							RxFSM <= Shift_Rx;
						end if;
					end if;
				when Shift_Rx =>
					if TopRx = '1' then
						RxBitCnt <= RxBitCnt + 1;
						Rx_Reg <= Rx & Rx_Reg (Rx_Reg'high downto 1);
						RxFSM <= Edge_Rx;
					end if;
				when Stop_Rx => -- Termina la recepcion de datos y lo almacena en Dout
					if TopRx = '1' then
						Dout <= Rx_reg;
						Sig_RxRdy <='1';
						RxFSM <= Idle;
					end if;
				when Rx_OVF => -- Error
					RxErr <= '1';
					if Rx='1' then
						RxFSM <= Idle;
					end if;
			end case;
		end if;
   end process;
end architecture; 
