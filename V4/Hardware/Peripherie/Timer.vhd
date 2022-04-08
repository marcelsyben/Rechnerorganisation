---------------------------------------------------------------------------------------------------
-- Timer-Komponente
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Timer is
  port (
    -- Prozessorbus
    CLK_I     : in    std_logic;
    RST_I     : in    std_logic;
    STB_I     : in    std_logic;
    WE_I      : in    std_logic;
    ADR_I     : in    std_logic_vector(4 downto 0);
    SEL_I     : in    std_logic_vector(3 downto 0);
    ACK_O     : out   std_logic;
    DAT_I     : in    std_logic_vector(31 downto 0);
    DAT_O     : out   std_logic_vector(31 downto 0);
    -- Ausgaenge
    IR_Tim    : out std_logic;
    PWM       : out std_logic
  );
end entity;

library ieee;
use ieee.numeric_std.all;

architecture behavioral of Timer is

  type RD_Mux_Type is (RD_SEL_nichts, RD_SEL_P, RD_SEL_S, RD_SEL_Z, RD_SEL_K, RD_SEL_Stat);
 
  signal RD_Sel       : RD_Mux_Type;
  signal STB_S        : std_logic;
  signal STB_P        : std_logic;
  signal STB_K        : std_logic;
  signal RD_Stat      : std_logic;
  signal Interrupt_FF : std_logic := '0';
  signal IrEn         : std_logic;
  
  -- Register
  signal TC           : std_logic := '1';
  signal Periode      : std_logic_vector(31 downto 0):= (31 downto 0=>'0');
  signal Schwelle     : std_logic_vector(31 downto 0):= (31 downto 0=>'0');
  signal Zaehlerstand : std_logic_vector(31 downto 0):= (31 downto 0=>'0');
  signal Kontroll     : std_logic_vector(0 downto 0) := ( 0 downto 0=>'0');
  signal Status       : std_logic_vector(0 downto 0);
begin
  Decoder: process(STB_I,ADR_I,SEL_I,WE_I)
  begin
    -- Default-Werte
    STB_P   <= '0';
    STB_S   <= '0';
    STB_K   <= '0';
    RD_Stat <= '0';
    RD_Sel  <= RD_SEL_nichts; 
    ACK_O   <= '0';
    
    if STB_I='1' and SEL_I="1111" then -- Wortzugriff gefordert
      if WE_I = '1' then -- Schreiben
        case ADR_I is
          when "00000" => STB_P <= '1'; ACK_O <= '1'; -- Periode
          when "00100" => STB_S <= '1'; ACK_O <= '1'; -- Schwelle
          when "01100" => STB_K <= '1'; ACK_O <= '1'; -- Kontroll
          when others => null;
        end case;
      elsif WE_I = '0' then -- Lesen
        case ADR_I is
          when "00000" => RD_Sel <= RD_SEL_P;    ACK_O <= '1'; -- Periode
          when "00100" => RD_Sel <= RD_SEL_S;    ACK_O <= '1'; -- Schwelle
          when "01000" => RD_Sel <= RD_SEL_Z;    ACK_O <= '1'; -- Zaehlerstand
          when "01100" => RD_Sel <= RD_SEL_K;    ACK_O <= '1'; -- Kontroll
          when "10000" => RD_Sel <= RD_SEL_Stat; ACK_O <= '1'; RD_Stat <= '1'; -- Status
          when others => null;
        end case;
      end if;
    end if;
  end process;

  REGs: process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        Periode      <= (Periode'range      => '0');
        Schwelle     <= (Schwelle'range     => '0');
        Kontroll     <= (Kontroll'range     => '0');
        Interrupt_FF <= '0';
      elsif RST_I /= '0' then
        Periode      <= (Periode'range      => 'X');
        Schwelle     <= (Schwelle'range     => 'X');
        Kontroll     <= (Kontroll'range     => 'X');
        Interrupt_FF <= 'X';
      else
        if STB_P='1' then 
          Periode  <= DAT_I(Periode'range);
        elsif STB_S='1' then 
          Schwelle <= DAT_I(Schwelle'range);
        elsif STB_K='1' then 
          Kontroll <= DAT_I(Kontroll'range);
        elsif RD_Stat = '1' then
          Interrupt_FF <= '0';
        elsif TC = '1' then
          Interrupt_FF <= '1';
        end if;
      end if;
    end if;
  end process;
  
  Lesedaten_MUX: process(RD_Sel, Periode, Schwelle, Zaehlerstand, Kontroll, Status)
  begin
    DAT_O <= (DAT_O'range => '0');
    case RD_Sel is
      when RD_SEL_nichts => null;
      when RD_SEL_P     => DAT_O(Periode'range)      <= Periode;
      when RD_SEL_S     => DAT_O(Schwelle'range)     <= Schwelle;
      when RD_SEL_Z     => DAT_O(Zaehlerstand'range) <= Zaehlerstand;
      when RD_SEL_K     => DAT_O(Kontroll'range)     <= Kontroll;
      when RD_SEL_Stat  => DAT_O(Status'range)       <= Status;
    end case;
  end process;
  
  IrEn      <= Kontroll(0);
  Status(0) <= Interrupt_FF;
  
  GenerateInt: process(IrEn, Interrupt_FF) 
  begin
    IR_Tim    <= IrEn and Interrupt_FF;
  end process;
  
  Vergleicher: process(Schwelle, Zaehlerstand)
  begin
    PWM <= '0';
    if unsigned(Schwelle) > unsigned(Zaehlerstand) then
      PWM <= '1';
    end if;
  end process;
  
  Zaehler: process(CLK_I)
    variable Q : unsigned(Zaehlerstand'range);
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        Q := to_unsigned(0, Q'length);
      else
        Q := unsigned(Zaehlerstand);
      
        if TC = '1' then
          Q := unsigned(Periode);
        else
          Q := Q - 1;
        end if;
      end if;     
      
      TC <= '0';
      if Q = 0 then
        TC <= '1';
      end if;
      
      Zaehlerstand <= std_logic_vector(Q);
    end if;
  end process;
end architecture;