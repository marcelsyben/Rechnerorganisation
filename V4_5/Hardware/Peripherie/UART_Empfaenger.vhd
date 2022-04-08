------------------------------------------------------------------------
-- Vorlesung Digitaltechnik
-- Beispiel für digitales System: UART-Empfänger
-- (c) Prof. B. Lang, Hochschule Osnabrück
------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
entity UART_Empfaenger is
  generic (
    Bitbreite     : integer; -- Breite eines Bits in Systemtaktzyklen
    Zaehlerbreite : integer; -- Wert größer als ld(Bitbreite)
    Bitanzahl     : integer  -- Anzahl der Bits im Datenwort (1..16)
  );
  port(
    Takt    : in  std_logic;
    Reset   : in  std_logic;
    Din     : in  std_logic;
    OK      : out std_logic;
    Err     : out std_logic;
    Dout    : out std_logic_vector(7 downto 0)
  );
end UART_Empfaenger;

library ieee;
use ieee.numeric_std.all;
architecture arch of UART_Empfaenger is
  signal Starte    : std_logic;
  signal Fertig    : std_logic;
  signal D         : std_logic;
  signal Bitmitte  : std_logic;
  signal Schieben  : std_logic;
begin
  assert 2**Zaehlerbreite > Bitbreite report "Zaehlerbreite zu klein" severity failure;
  Rechenwerk: block
    signal Flanke : std_logic;
    signal D1     : std_logic;
    signal TC     : std_logic;
    signal Q      : unsigned(Zaehlerbreite-1 downto 0);
  begin
    -- Flankenerkennung
    Flankenerkennung: process (Takt)
    begin
      if rising_edge(Takt) then
        D1 <= Din;
        D  <= D1;
      end if;
    end process;
    Flanke <= D xor D1;
    
    -- Zaehler Bitbreite mit Vergleicher für Bitmitte
    Zaehler_Bitbreite: process (Takt)
      variable val: unsigned(Q'range) := (others=>'0');
    begin
      if rising_edge(Takt) then
        if Flanke='1' or TC='1' then
          val := to_unsigned(Bitbreite-1,Zaehlerbreite);
        else
          val := val - 1;
        end if;
        Q <= val;
        if val=0 then TC <= '1';
        else          TC <= '0';
        end if;
      end if;
    end process;
    Vergleicher: process(Q)
    begin
      if Q = (Bitbreite-1)/2 then Bitmitte <= '1';
      else                         Bitmitte <= '0';
      end if;
    end process;
    
    -- Schieberegister
    Schieberegister: process
      variable SR_Wert: std_logic_vector(Bitanzahl-1 downto 0);
    begin
      wait until rising_edge(Takt);
      if Schieben='1' then
        SR_Wert := D & SR_Wert(Bitanzahl-1 downto 1);
      end if;
      Dout <= SR_Wert;
    end process;

    -- Zaehler Bitanzahl (bis zu 16 Bit)
    assert (Bitanzahl > 0) and (Bitanzahl <= 16)
       report "Bitanzahl nicht im vorgesehenen Bereich"
       severity failure; 
    Zaehler_Bitanzahl: process (Takt)
      variable val: unsigned(3 downto 0) := (others=>'1');
    begin
      if rising_edge(Takt) then
        if    Starte='1' then val := to_unsigned(Bitanzahl-1,4);
        elsif Schieben='1' and Fertig='0' then val := val - 1;
        end if;
        if val=0 then Fertig <= '1';
        else          Fertig <= '0';
        end if;
      end if;
    end process;
    
  end block;
  
  Steuerwerk: block
    type Zustaende is (Start, Daten, Stopp, Fehler, Falsch);
    signal Zustand      : Zustaende;
    signal Folgezustand : Zustaende;
  begin
    -- Zustands- und Moore-Register
    Reg: process (Takt)
    begin
      if rising_edge(Takt) then
        -- Folgezustand wird zum aktuellen Zustand
        Zustand <= Folgezustand;
        -- Ermittlung der aktuellen Moore-Werte
        Err <= '0';
        case Folgezustand is
          when Fehler => Err <= '1';
          when others => null;
        end case;                          
      end if;
    end process;
    
    -- Berechung Folgezustand und Mealy-Ausgänge
    process (Zustand, Reset, Bitmitte, D, Fertig)
    begin
      Folgezustand <= Falsch;  -- initialer Wert, sollte überschrieben werden
      Starte       <= '0';     -- initialer Wert, kann überschrieben werden
      Schieben     <= '0';     -- initialer Wert, kann überschrieben werden
      OK           <= '0';     -- initialer Wert, kann überschrieben werden
      if Reset='1' then Folgezustand <= Start;
      elsif Reset='0' then
        case Zustand is
          when Start =>
            if    Bitmitte='0' or D='1'       then Folgezustand <= Start;
            elsif (Bitmitte='1') and (D='0')  then Folgezustand <= Daten; Starte <= '1';
            end if;
          when Daten =>
            if    Bitmitte='0'                then Folgezustand <= Daten;
            elsif Bitmitte='1' and Fertig='0' then Folgezustand <= Daten; Schieben <= '1';
            elsif Bitmitte='1' and Fertig='1' then Folgezustand <= Stopp; Schieben <= '1';
            end if;
          when Stopp =>
            if    Bitmitte='0'                then Folgezustand <= Stopp;
            elsif Bitmitte='1' and D='1'      then Folgezustand <= Start; OK <= '1';
            elsif Bitmitte='1' and D='0'      then Folgezustand <= Fehler;
            end if;
          when Fehler =>                           Folgezustand <= Start;
          when others =>  null;
        end case;
      end if;
    end process;

  end block;
end arch;
