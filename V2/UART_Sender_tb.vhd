entity UART_Sender_tb is
end UART_Sender_tb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
architecture test of UART_Sender_tb is
  constant Taktfrequenz:  natural := 45_000_000;
  constant Baudrate:      natural := 115200;
  constant Bitanzahl:     natural := 12;
  constant Bitbreite:     natural := (Taktfrequenz/Baudrate);
  constant Zaehlerbreite: natural := integer(ceil(log2(real(Bitbreite)))); 
  signal Takt   : std_logic; 
  signal Reset  : std_logic; 
  signal Senden : std_logic;
  signal Wert   : std_logic_vector(Bitanzahl-1 downto 0);
  signal OK     : std_logic;
  signal TxD    : std_logic;
  --
  signal Empfangenes_Zeichen : std_logic_vector(Bitanzahl-1 downto 0);
begin

  DUT: entity work.UART_Sender
    generic map (
      Bitbreite     => Bitbreite,
      Zaehlerbreite => Zaehlerbreite,
      Bitanzahl     => Bitanzahl
    )
    port map (
      Takt   => Takt,
      Reset  => Reset,
      -- Eingang
      Senden => Senden,
      Wert   => Wert,
      OK     => OK,
      -- Ausgang
      TxD    => TxD
    );

  Takt_Gen: process
    constant halbe_periode : time := (1 sec / Taktfrequenz) / 2; 
  begin
    Takt <= '1';
    wait for halbe_periode;
    Takt <= '0';
    wait for halbe_periode;
  end process;
  
  Stimulieren: process
  begin
    assert Bitanzahl=12 report "Bitanzahl passt nicht zum Testprozess 'Stimulieren'" severity failure;
    Senden <= '0';
    Wert   <= x"000";
    Reset <= '1';
    wait until falling_edge(Takt);
    wait until falling_edge(Takt);
    Reset <= '0';

    wait for 100 us; wait until falling_edge(Takt);
    
    Senden <= '1';
    Wert   <= x"AAA";
    loop
      wait until rising_edge(Takt);
      exit when OK='1';
    end loop;
  
    Senden <= '0';
    Wert   <= (others =>'-');
    wait for 500 us;  wait until falling_edge(Takt);

    Senden <= '1';
    Wert   <= x"555";
    loop
      wait until rising_edge(Takt);
      exit when OK='1';
    end loop;
    wait until falling_edge(Takt);

    Senden <= '1';
    Wert   <= x"FFF";
    loop
      wait until rising_edge(Takt);
      exit when OK='1';
    end loop;
    wait until falling_edge(Takt);
    
    Senden <= '1';
    Wert   <= x"000";
    loop
      wait until rising_edge(Takt);
      exit when OK='1';
    end loop;
    wait until falling_edge(Takt);

    Senden <= '0';
    Wert   <= (others =>'-');
    
    wait;
  end process;

  Empfangen: process
    variable Wert: unsigned(Bitanzahl-1 downto 0) := (others=>'0');
    variable Ausgabe: string(1 to 3);
    constant Conv: string := "0123456789ABCDEF";
    variable i: integer := 0;
    -- Passende Werte zu den prellenden Tastern spezifizieren
    type Ergebnisse is array (natural range <>) of unsigned(11 downto 0);
    constant Werte: Ergebnisse(0 to 3) 
                 := (x"AAA",x"555",x"FFF", x"000");
  begin
    assert Bitanzahl=12 report "Bitanzahl passt nicht zum Testprozess 'Empfangen'" severity failure;
    wait until TxD='0';
--  report "Startbit erkannt" severity note;
    Empfangenes_Zeichen <= (others=>'-');
    for j in 1 to Bitbreite/2 loop
      wait until falling_edge(Takt);
    end loop;
    for b in 0 to Bitanzahl-1 loop
      for j in 1 to Bitbreite loop
        wait until falling_edge(Takt);
      end loop;
--    report "Lese Datenbit" severity note;
      Wert(b) := TxD;
    end loop;
    for j in 1 to Bitbreite loop
      wait until falling_edge(Takt);
    end loop;
    if TxD='0' then report "Stoppbit falsch"  severity error;
    end if;
    Empfangenes_Zeichen <= std_logic_vector(Wert);
    Ausgabe(1) := Conv(to_integer(Wert(11 downto 8))+1);
    Ausgabe(2) := Conv(to_integer(Wert( 7 downto 4))+1);
    Ausgabe(3) := Conv(to_integer(Wert( 3 downto 0))+1);
    report "Wert empfangen: 0x"&Ausgabe severity note;

    if i<Werte'Length then
      Ausgabe(1) := Conv(to_integer(Werte(i)(11 downto 8))+1);
      Ausgabe(2) := Conv(to_integer(Werte(i)( 7 downto 4))+1);
      Ausgabe(3) := Conv(to_integer(Werte(i)( 3 downto 0))+1);
      assert Wert=Werte(i) report "Erwarte Wert "&Ausgabe severity error;
      i := i+1;
    end if;
    
    if i = Werte'length then 
      report "Alle erwarteten Werte empfangen" severity note;
      wait;
    end if;
  end process;  
  
  
end test;