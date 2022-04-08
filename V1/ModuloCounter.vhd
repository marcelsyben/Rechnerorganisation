--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- Modulozaehler
-- Hochschule Osnabrueck / Bernhard Lang, Rainer Hoeckmann
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ModuloCounter is
    generic (
        N   : integer;                            -- Wortbreite des Zaehlers
        MAX : integer                             -- Maximaler Zaehlerstand
    );
    port (
        Clk : in  std_logic;
        En  : in  std_logic;
        Q   : out std_logic_vector(N-1 downto 0); -- Zaehlerstand
        TC  : out std_logic                       -- Zaehlende
    );
end entity;

library ieee;
use ieee.numeric_std.all;

architecture rtl of ModuloCounter is
begin
    p: process(Clk)
        variable cnt : unsigned(N-1 downto 0) := to_unsigned(0, N);
    begin
        if rising_edge(Clk) then -- Auf steigende Taktflanke reagieren
            -- TODO: Code ergaenzen
            if En='1' then
                if cnt = MAX then 
                    cnt := to_unsigned(0, N);

                else
                    cnt := cnt+1;
                 
                end if;
            end if;
        
            Q <= std_logic_vector(cnt);
        
            if cnt = MAX then 
                TC <= '1';

            else
                TC <= '0';
                
            end if;
        
        end if;
    end process;
end architecture;
