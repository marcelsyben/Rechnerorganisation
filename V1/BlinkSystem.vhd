--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- TopLevel fuer das Blinksystem
-- Hochschule Osnabrueck / Bernhard Lang, Rainer Hoeckmann
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity BlinkSystem is
  port (
    CLK      :  in  std_logic;
    LD0      :  out std_logic;
    LD1      :  out std_logic    
  );
end entity;

library ieee;
use ieee.numeric_std.all;

architecture structural of BlinkSystem is

  -- *******************
  --  Konstanten setzen
  -- *******************
  -- constant MC_Width  : integer := ???; -- Wortbreite Modulo-Counter    
  -- constant MC_MAX    : integer := ???; -- Endwert Modulo-Counter 

  -- constant UDC_Width : integer := ???; -- Wortbreite Up/Down-Counter

  constant MC_Width  : integer := 26;
  constant MC_MAX    : integer := 50_000_000-1;
  
  constant UDC_Width : integer := 26;



  signal   UDC_Q     : std_logic_vector(UDC_Width-1 downto 0);  
  signal   MC_TC     : std_logic;    
  signal   TFF_Q     : std_logic := '0';
    
begin
  MC: entity work.ModuloCounter
    generic map ( 
      N   => MC_Width,
      MAX => MC_MAX
    )
    port map (
      Clk         => CLK,
      En          => '1',
      Q           => open,
      TC          => MC_TC
    );
            
  TFF : process(CLK)
  begin
    if rising_edge(CLK) then
      if MC_TC = '1' then
         TFF_Q <= not TFF_Q;
      end if;
    end if;
  end process;
    
  LD0_Out: process(TFF_Q)
  begin
    LD0 <= TFF_Q;
  end process;
  
  UDC: entity work.UpDownCounter
    generic map ( 
      N => UDC_Width
    )
    port map (
      Clk         => CLK,
      En          => '1',
      Up          => '1',
      Q           => UDC_Q,
      TC          => open
    );

  LD1_Out: process(UDC_Q)
  begin
    LD1 <= UDC_Q(UDC_Width - 1);            
  end process;            
end architecture;

