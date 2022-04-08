-------------------------------------------------
-- Serieller Sender
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity UART_Sender is
  generic (
    Bitbreite     : integer; -- Laenge eines Bits in Taktzyklen
    Zaehlerbreite : integer; -- Wert größer als ld(Bitbreite)
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
architecture Nur_Simulation of UART_Sender is
  constant SIMULATION: boolean := true;
begin

  SimModel: process
    variable SendeWert: std_logic_vector(Bitanzahl-1 downto 0);
  begin
    -- Initialisierung
    OK  <= '0';
    TxD <= '1';
    wait until rising_edge(Takt);
    assert Senden='1' or Senden='0' report "Falscher Wert für Signal 'Senden' (1)" severity Failure;
    
    loop -- Endlosschleife zum Senden von Zeichen
    
      -- Auf neuen Wert zum Senden warten
      OK <= '1';
      wait until rising_edge(Takt);
      while Senden='0' loop
        wait until rising_edge(Takt);
      end loop;
      assert Senden='1' report "Falscher Wert für Signal 'Senden' (2)" severity Failure;
      SendeWert := Wert;
      
      -- Startbit senden
      OK  <= '0';
      TxD <= '0';
      for i in 1 to Bitbreite loop
        wait until rising_edge(Takt);
      end loop;
      
      -- Wert senden
      for b in 0 to Bitanzahl-1 loop
        TxD <= SendeWert(b);
        for i in 1 to Bitbreite loop
          wait until rising_edge(Takt);
        end loop;
      end loop;
      
      -- Stoppbit senden
      TxD <= '1';
      for i in 1 to Bitbreite loop
        wait until rising_edge(Takt);
      end loop;
    
    end loop;
    
  end process;
  
end Nur_Simulation;


