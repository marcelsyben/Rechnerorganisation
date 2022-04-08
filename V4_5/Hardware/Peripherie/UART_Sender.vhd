-------------------------------------------------
-- Serieller Sender
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity UART_Sender is
  generic (
    Bitbreite     : integer; -- Laenge eines Bits in Taktzyklen
    Zaehlerbreite : integer; -- Wert gr��er als ld(Bitbreite)
    Bitanzahl     : integer  -- Anzahl der Bits pro Datenwort
  );
  port (
    Takt   : in  std_logic;
    Reset  : in  std_logic;
    -- Eingang
    Senden : in  std_logic;
    Wert   : in  std_logic_vector(Bitanzahl-1 downto 0);
    OK     : out std_logic;
    -- Ausgang
    TxD    : out std_logic
  );
end UART_Sender;

library ieee;
use ieee.numeric_std.all;
architecture arch of UART_Sender is
  signal Starte  : std_logic;
  signal Schiebe : std_logic;
  signal Fertig  : std_logic;
  signal Bitende : std_logic;
begin
  Rechenwerk: block
  begin  
    
    -- Schieberegister (Startbit, Wert, Stoppbit)
    -- ... (VHDL-Code hier ergaenzen)
    SchiebeReg : process( Takt )
      variable SR_Wert: std_logic_vector(Bitanzahl+1 downto 0);
      variable i: unsigned(4 downto 0) := to_unsigned(0,5);
    begin
      if rising_edge(Takt) then

        if Starte = '1' then
          SR_Wert := '1' & Wert & '0';
          i := to_unsigned(0,5);
        end if;
        
        if Schiebe = '1' and i<31 then
          i := i + 1;
        end if;

        TxD <= SR_Wert(to_integer(i));

      end if ;
    end process;

    -- Zaehler Bitanzahl (bis zu 30 Bit)
    assert (Bitanzahl > 0) and (Bitanzahl <= 30)
       report "Bitanzahl nicht im vorgesehenen Bereich"
       severity failure; 
       
    -- ... (VHDL-Code hier ergaenzen)       
    Zaehler_Bitanzahl: process (Takt)
      variable val: unsigned(4 downto 0) := (others=>'1');
    begin
      if rising_edge(Takt) then
        if Starte='1' then
          val := to_unsigned(Bitanzahl+1,val'length);
        elsif Schiebe='1' and Fertig='0' then
          val := val - 1;
        end if;

        if val=0 then 
          Fertig <= '1';
         else
          Fertig <= '0';
        end if;

      end if;
    end process;

    -- Zaehler Bitbreite
    assert 2**Zaehlerbreite > Bitbreite
      report "Zaehlerbreite zu klein"
      severity failure;
      
    -- ... (VHDL-Code hier ergaenzen)       
    Zaehler_Bitbreite : process( Takt )
    variable val: unsigned(Zaehlerbreite-1 downto 0) := (Zaehlerbreite-1 downto 0 => '0');
    begin
      if rising_edge(Takt) then
      
        if (Starte = '1') or (Bitende = '1') then
          val := to_unsigned(Bitbreite-1, val'length);

        else
          val := val - 1;

        end if ;

        if val=0 then 
          Bitende <= '1';
        else
          Bitende <= '0';
        end if;

      end if;
    
    end process;
  
  end block;
  
  Steuerwerk: block
    type Zustaende is (Start, Ausgabe, Falsch);
    signal Zustand      : Zustaende;
    signal Folgezustand : Zustaende;
  begin
  
    -- Zustands- und Moore-Register
    -- ... (VHDL-Code hier ergaenzen)       
    Moore : process(Takt)
    begin
      if rising_edge(Takt) then
        Zustand <= Folgezustand;
        case (Folgezustand) is
          when Falsch => OK <= 'X';
          when Start => OK <= '1';
          when others => OK <= '0';
        end case;
      end if;
    end process;

    -- Berechung Folgezustand und Mealy-Ausg�nge
    -- ... (VHDL-Code hier ergaenzen)       
    Mealy : process( Zustand, Senden, Reset, Fertig, Bitende )
    begin
      Folgezustand <= Falsch;
      Starte <= '0';
      Schiebe <= '0';
      if Reset = '1' then
        Folgezustand <= Start;
      elsif Reset = '0' then
        case( Zustand ) is
          when Start =>
            if Senden = '0' then
              Folgezustand <= Start;
            elsif Senden = '1' then
              Folgezustand <= Ausgabe;
              Starte <= '1';
            end if ;
          when Ausgabe =>
            if Bitende = '0' then
              Folgezustand <= Ausgabe;
            elsif (Bitende = '1') and (Fertig = '0') then
              Folgezustand <= Ausgabe;
              Schiebe <= '1';
            elsif (Bitende = '1') and (Fertig = '1') then
              Folgezustand <= Start;
            end if ;
          when others => null;
        end case ;
      end if ;
    end process ; -- Mealy

  end block;
end arch;

