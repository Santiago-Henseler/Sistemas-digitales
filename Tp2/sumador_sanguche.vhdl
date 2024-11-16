entity sumador_sanguche is
    generic(
        Ne: natural := 8;
        Nf: natural := 23
    );
    port (
        clock: in std_logic;
        operacion: in std_logic;
        operandoA: in std_logic_vector(Ne+Nf downto 0);
        operandoB: in std_logic_vector(Ne+Nf downto 0);
        resultado: out std_logic_vector(Ne+Nf downto 0)
    );
  end sumador_sanguche;
  
  architecture sumador_sanguche_arch of sumador_sanguche is

    signal operandoA_ff , operandoB_ff , resultado_ff: std_logic_vector(Ne+Nf downto 0);
    signal operacion_ff: std_logic;

  begin
  
    sanguche: process(clock)
    begin
        operacion_ff <= operacion;
        operandoA_ff <= operandoA;
        operandoB_ff <= operandoB;
        resultado <= resultado_ff;
    end process;
  
    entity work.sumador_float
    generic map(
        Ne => Ne,
        Nf => Nf
    )
    port map(   
        operacion => operacion_ff,
        operandoA => operandoA_ff,
        operandoB => operandoB_ff,
        resultado => resultado_ff
    );

  
  end architecture ;