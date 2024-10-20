library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_multiplicador is
end entity tb_multiplicador;

architecture simulacion of tb_multiplicador is
	constant TCK: time:= 20 ns; -- periodo de reloj
	constant DELAY: natural:= 0; -- retardo de procesamiento del DUT
	constant N: natural:= 22;	-- tamano de datos
	
	signal clk: std_logic:= '0';
	signal operadorA_file: unsigned(N-1 downto 0):= (others => '1');
	signal operadorB_file: unsigned(N-1 downto 0):= (others => '1');
	signal cin_file, cout_file: std_logic:= '0';
	signal z_file: unsigned(N-1 downto 0):= (others => '0');
	signal z_del: unsigned(N-1 downto 0):= (others => '0');
	signal z_dut: unsigned(N-1 downto 0):= (others => '0');
	signal cout_dut: std_logic;
	-- z_del_aux se define por un problema de conversión
	signal z_del_aux: std_logic_vector(N-1 downto 0):= (others => '0');
	
	file datos: text open read_mode is "test_multiplicador/fmul_15_6.txt";
	
	component delay_gen is
		generic(
			N: natural:= 8;
			DELAY: natural:= 0
		);
		port(
			clk: in std_logic;
			A: in std_logic_vector(N-1 downto 0);
			B: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
begin
	-- generacion del clock del sistema
	clk <= not(clk) after TCK/ 2; -- reloj

	Test_Sequence: process
		variable l: line;
		variable ch: character:= ' ';
		variable aux: integer;
	begin
		while not(endfile(datos)) loop 		-- si se quiere leer de stdin se pone "input"
			wait until rising_edge(clk);
			readline(datos, l); 			-- se lee una linea del archivo de valores de prueba
			read(l, aux); 					-- se extrae un entero de la linea
			operadorA_file <= to_unsigned(aux, N); 	-- se carga el valor del operando A
			read(l, ch); 					-- se lee un caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero de la linea
			operadorB_file <= to_unsigned(aux, N); 	-- se carga el valor del operando B
			read(l, ch); 					-- se lee un caracter (es el espacio)
			read(l, aux); 					-- se lee otro entero de la linea
			z_file <= to_unsigned(aux, N); 	-- se carga el valor del operando B
		end loop;
		
		file_close(datos); -- cierra el archivo
		wait for TCK*(DELAY+1); -- se pone el +1 para poder ver los datos
		assert false report -- este assert se pone para abortar la simulacion
			"Fin de la simulacion" severity failure;
	end process Test_Sequence;
	
	-- instanciacion del DUT (sumador)
	DUT:entity work.multiplicador_float(multiplicador_float_arch) 
    generic map(
        Ne => 6,
        Nf => 15
    )
    port map(
        operandoA => std_logic_vector(operadorA_file),
        operandoB => std_logic_vector(operadorB_file),
        unsigned(resultado) => z_dut
    );
			
	del: delay_gen 	generic map(N, DELAY)
				port map(clk, std_logic_vector(z_file), z_del_aux);
				
	z_del <= unsigned(z_del_aux);
	
	-- Verificacion de la condicion
	verificacion: process(clk)
	begin
		if rising_edge(clk) then
			assert to_integer(z_del)=to_integer(z_dut) report
				"Error: Salida del DUT no coincide con referencia (salida del dut = " & 
				integer'image(to_integer(z_dut)) &
				", salida del archivo = " &
				integer'image(to_integer(z_del)) & ") " & integer'image(to_integer(operadorA_file)) & " "  & integer'image(to_integer(operadorB_file))
				severity warning;
		end if;
	end process;

end architecture simulacion; 
