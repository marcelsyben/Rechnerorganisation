--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- TopLevel fuer das Zaehlsystem
-- Hochschule Osnabrueck / Bernhard Lang, Rainer Hoeckmann
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity CountSystem is
  port (
    CLK      : in  std_logic;
    UP       : in  std_logic;
    SEG      : out std_logic_vector(7 downto 0);
    MUX      : out std_logic_vector(3 downto 0)
);
end entity;

library ieee;
use ieee.numeric_std.all;

architecture structural of CountSystem is

  -- *******************
  --  Konstanten setzen
  -- *******************
  -- constant MC_Width  : integer := ???; -- Wortbreite Modulo-Counter    
  constant MC_Width  : integer := 24;
  -- constant MC_MAX    : integer := ???; -- Endwert Modulo-Counter 
  constant MC_MAX    : integer := 12_000_000;
  -- constant UDC_Width : integer := ???; -- Wortbreite Up/Down-Counter
  constant UDC_Width : integer := 24;

  signal   UDC_Q     : std_logic_vector(UDC_Width-1 downto 0);  
  signal   MC_TC     : std_logic;   
  signal   UDC_Up    : std_logic := '0';  
    
  begin
  -- Prozess fuer ein D-FLipFlop
    Reg: process (CLK) 
      begin 
        if rising_edge(CLK) then 
          UDC_Up <= UP; 
        end if; 
    end process;
  -- Instanz der Komponente ModuloCounter
  MC: entity work.ModuloCounter
  generic map (
    N   => MC_Width,
    MAX => MC_MAX
  )
  port map (
    Clk => CLK,
    En          => '1',
    Q           => open,
    TC          => MC_TC
  );
    
  -- Instanz der Komponente UpDownCounter
  UDC: entity work.UpDownCounter
  generic map ( 
    N => UDC_Width
  )
  port map (
    Clk         => CLK,
    En          => MC_TC,
    Up          => UDC_Up,
    Q           => UDC_Q,
    TC          => open
  );
  -- Instanz der Komponente Siebensegment_Anzeige
  SSA: entity work.Siebensegment_Anzeige
    generic map (
        MUX_CYCLES => 10000
    )
    port map (
        Clk        => CLK,
        -- Eingaenge
        Wert0      => UDC_Q(3 downto 0),
        Dp0        => '0',
        Wert1      => UDC_Q(7 downto 4),
        Dp1        => '0',
        Wert2      => UDC_Q(11 downto 8),
        Dp2        => '0',
        Wert3      => UDC_Q(15 downto 12),
        Dp3        => '0',
        -- Display
        Seg        => SEG,
        Mux        => MUX
    );
end architecture;

