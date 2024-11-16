entity multiplicador_sanguche is
    generic(
        Ne: natural := 8;
        Nf: natural := 23
    );
    port (
        clock: in std_logic;
        operandoA: in std_logic_vector(Ne+Nf downto 0);
        operandoB: in std_logic_vector(Ne+Nf downto 0);
        resultado: out std_logic_vector(Ne+Nf downto 0)
    );
  end multiplicador_sanguche;
  
  architecture multiplicador_sanguche_arch of multiplicador_sanguche is

    signal operandoA_ff , operandoB_ff , resultado_ff: std_logic_vector(Ne+Nf downto 0);

  begin
  
    sanguche: process(clock)
    begin
       operandoA_ff <= operandoA;
       operandoB_ff <= operandoB;
       resultado <= resultado_ff;
    end process;
  
    entity work.multiplicador_float
    generic map(
        Ne => Ne,
        Nf => Nf
    )
    port map(   
        operandoA => operandoA_ff,
        operandoB => operandoB_ff,
        resultado => resultado_ff
    );

  
  end architecture ;