---------------------------------------------------------------------------------------------------
-- GPIO-Komponente
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity GPIO is
  generic (
    N         : positive
  );
  port (
    -- Prozessorbus
    CLK_I     : in    std_logic;
    RST_I     : in    std_logic;
    STB_I     : in    std_logic;
    WE_I      : in    std_logic;
    ADR_I     : in    std_logic_vector(3 downto 0);
    SEL_I     : in    std_logic_vector(3 downto 0);
    ACK_O     : out   std_logic;
    DAT_I     : in    std_logic_vector(31 downto 0);
    DAT_O     : out   std_logic_vector(31 downto 0);
    -- Ausgaenge
    Pins      : inout std_logic_vector(N-1 downto 0)
  );
end GPIO;

architecture behavioral of GPIO is

  type RD_Mux_Type is (RD_SEL_nichts, RD_SEL_Ri, RD_SEL_A, RD_SEL_E);
 
  signal RD_Sel   : RD_Mux_Type;
  signal STB_Ri   : std_logic;
  signal STB_A    : std_logic;
  
  -- Register
  signal Richtung : std_logic_vector(N-1 downto 0) := (N-1 downto 0=>'0');
  signal Ausgabe  : std_logic_vector(N-1 downto 0) := (N-1 downto 0=>'0');
  signal Eingabe  : std_logic_vector(N-1 downto 0) := (N-1 downto 0=>'0');
  
begin
  Decoder: process(STB_I,ADR_I,SEL_I,WE_I)
  begin
    -- Default-Werte
    STB_Ri <= '0';
    STB_A  <= '0';
    RD_Sel <= RD_SEL_nichts; 
    ACK_O  <= '0';
    
    if STB_I='1' and SEL_I="1111" then -- Wortzugriff gefordert
      if WE_I = '1' then -- Schreiben
        case ADR_I is
          when "0100" => STB_A  <= '1'; ACK_O <= '1'; -- Ausgabe
          when "1000" => STB_Ri <= '1'; ACK_O <= '1'; -- Richtung
          when others => null;
        end case;
      elsif WE_I = '0' then -- Lesen
        case ADR_I is
          when "0000" => RD_Sel <= RD_SEL_E;  ACK_O <= '1'; -- Eingabe
          when "0100" => RD_Sel <= RD_SEL_A;  ACK_O <= '1'; -- Ausgabe
          when "1000" => RD_Sel <= RD_SEL_Ri; ACK_O <= '1'; -- Richtung
          when others => null;
        end case;
      end if;
    end if;
  end process;

  REGs: process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        Richtung <= (Richtung'range => '0');
        Ausgabe  <= (Ausgabe'range  => '0');
        Eingabe  <= (Eingabe'range  => '0');
      elsif RST_I /= '0' then
        Richtung <= (Richtung'range => 'X');
        Ausgabe  <= (Ausgabe'range  => 'X');
        Eingabe  <= (Eingabe'range  => 'X');
      else
        if STB_Ri='1' then 
          Richtung <= DAT_I(Richtung'range);
        elsif STB_A='1' then 
          Ausgabe <= DAT_I(Ausgabe'range);
        end if;
        Eingabe <= Pins;
      end if;
    end if;
  end process;

  Lesedaten_MUX: process(RD_Sel, Richtung, Ausgabe, Eingabe)
  begin
    DAT_O <= (DAT_O'range => '0');
    case RD_Sel is
      when RD_SEL_nichts => null;
      when RD_SEL_Ri => DAT_O(Richtung'range) <= Richtung;
      when RD_SEL_A  => DAT_O(Ausgabe'range)  <= Ausgabe;
      when RD_SEL_E  => DAT_O(Eingabe'range)  <= Eingabe;
    end case;
  end process;

  TriState: process(Richtung, Ausgabe)
  begin
    for i in Pins'range loop
      if    Richtung(i)='0' then
        Pins(i) <= 'Z';
      elsif Richtung(i)='1' then
        Pins(i) <= Ausgabe(i);
      else
        Pins(i) <= 'X';
      end if;
    end loop;
  end process;

end behavioral;