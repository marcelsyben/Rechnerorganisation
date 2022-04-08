library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SSP is
  generic (
      MUX_CYCLES : integer
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
    -- Display
    Seg       : out std_logic_vector(7 downto 0);
    Mux       : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of SSP is

  -- TODO:  Aufzaehlungstyp RD_Mux_Type fuer die Multiplexer-Ansteuerung deklarieren
  type RD_Mux_Type is (RD_SEL_nichts, 
                        RD_Sel_W0, 
                        RD_Sel_W1, 
                        RD_Sel_W2, 
                        RD_Sel_W3);

  -- TODO: Steuersignale deklarieren (RD_Sel, STB_...)
  signal RD_Sel : RD_Mux_Type;
  signal STB_W0 : std_logic;
  signal STB_W1 : std_logic;
  signal STB_W2 : std_logic;
  signal STB_W3 : std_logic;
  -- TODO: Registersignale deklarieren
  signal Wert0: std_logic_vector(4 downto 0) := (4 downto 0=>'0');
  signal Wert1: std_logic_vector(4 downto 0) := (4 downto 0=>'0');
  signal Wert2: std_logic_vector(4 downto 0) := (4 downto 0=>'0');
  signal Wert3: std_logic_vector(4 downto 0) := (4 downto 0=>'0');

begin
  -- TODO: Decoder als kombinatorischen Prozess (ohne Takt) beschreiben
  decoder: process(STB_I, WE_I, ADR_I, SEL_I)
  begin
    STB_W0 <= '0';
    STB_W1 <= '0';
    STB_W2 <= '0';
    STB_W3 <= '0';
    RD_Sel <= RD_SEL_nichts;
    ACK_O <= '0';

    if STB_I='1' and SEL_I="1111" then

      if WE_I = '1' then
        case ADR_I is
          when "0000" => 
            STB_W0 <= '1';
            ACK_O <= '1';
          when "0100" =>
            STB_W1 <= '1';
            ACK_O <= '1';
          when "1000" =>
            STB_W2 <= '1';
            ACK_O <= '1';
          when "1100" =>
            STB_W3 <= '1';
            ACK_O <= '1';
          when others => null;
        end case;

      elsif WE_I = '0' then
        case ADR_I is
          when "0000" => 
            RD_Sel <= RD_SEL_W0;
            ACK_O <= '1';
          when "0100" =>
            RD_Sel <= RD_SEL_W1;
            ACK_O <= '1';
          when "1000" =>
            RD_Sel <= RD_SEL_W2;
            ACK_O <= '1';
          when "1100" =>
            RD_Sel <= RD_SEL_W3;
            ACK_O <= '1';
          when others => null;
        end case;
      end if;
    end if;
  end process;
  -- TODO: Register als synchrone(n) Prozess(e) (mit Takt) beschreiben
  reg: process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        Wert0 <= (Wert0'range => '0');
        Wert1 <= (Wert1'range => '0');
        Wert2 <= (Wert2'range => '0');
        Wert3 <= (Wert3'range => '0');
      elsif STB_W0='1' then
        Wert0 <= DAT_I(4 downto 0);
      elsif STB_W1='1' then
        Wert1 <= DAT_I(4 downto 0);
      elsif STB_W2='1' then
        Wert2 <= DAT_I(4 downto 0);
      elsif STB_W3='1' then
        Wert3 <= DAT_I(4 downto 0);
      end if;
    end if;
    end process;

  -- TODO: Lesedaten-Multiplexer als asynchronen Prozess (ohne Takt) beschreiben
  multiplexer: process(RD_Sel, Wert0, Wert1, Wert2, Wert3)
  begin
  	DAT_O <= (DAT_O'range => '0');
    case RD_Sel is
      when RD_SEL_nichts => null;
      when RD_SEL_W0 => DAT_O <= "000000000000000000000000000" & Wert0;
      when RD_SEL_W1 => DAT_O <= "000000000000000000000000000" & Wert1;
      when RD_SEL_W2 => DAT_O <= "000000000000000000000000000" & Wert2;
      when RD_SEL_W3 => DAT_O <= "000000000000000000000000000" & Wert3;
    end case;
  end process;
  -- TODO: Komponente "Siebensegment_Anzeige" instanziieren und Ports mit Signalen verbinden
  sieben_seg: entity work.Siebensegment_Anzeige
      generic map(MUX_CYCLES => MUX_CYCLES)
    port map (
      Clk  => CLK_I,

      Wert0 => Wert0(3 downto 0),
      Dp0   => Wert0(4),
      Wert1 => Wert1(3 downto 0),
      Dp1   => Wert1(4),
      Wert2 => Wert2(3 downto 0),
      Dp2   => Wert2(4),
      Wert3 => Wert3(3 downto 0),
      Dp3   => Wert3(4),

      Seg  => Seg(7 downto 0),
      Mux  => Mux(3 downto 0)
    );
end architecture;