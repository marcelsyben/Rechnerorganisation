--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- Aufwaerts/Abwaerts-Zaehler
-- Hochschule Osnabrueck / Bernhard Lang, Rainer H�ckmann
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity UpDownCounter is
  generic(
    N   : integer                             -- Wortbreite des Zaehlers
  );
  port (
    Clk : in  std_logic;                      -- Takt mit positiver aktiver Flanke
    En  : in  std_logic;                      -- Zaehler freigeben (1) oder sperren (0)
    Up  : in  std_logic;                      -- Aufwaerts (1) oder abwaerts (0) zaehlen 
    Q   : out std_logic_vector(N-1 downto 0); -- Zaehlerstand
    TC  : out std_logic                       -- Zaehlende (1)
  );
end entity;

library ieee;
use ieee.numeric_std.all;

architecture rtl of UpDownCounter is
begin
  p: process(Clk)
    variable cnt : unsigned(N-1 downto 0) := to_unsigned(0, N);
  begin
    if rising_edge(Clk) then -- Auf steigende Taktflanke reagieren
    
    if En='1' and Up='1' then
        cnt := cnt+1;

    elsif En='1' and Up='0' then
        cnt := cnt-1;

    end if;
    
    
    if cnt = 2**N-1 and Up='1' then 
        TC <= '1';

    elsif cnt = 0 and Up='0' then
        TC <= '1';
      
    else
        TC <= '0';

    end if;
    
    Q <= std_logic_vector(cnt);

    end if;
  end process;
end architecture;

