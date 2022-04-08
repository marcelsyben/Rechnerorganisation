---------------------------------------------------------------------------------------------------
-- UART fuer Beispielrechner
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity UART is
  generic (
    Bitbreite     : integer
  );
  port (
    -- Prozessorbus
    CLK_I        : in  std_logic;
    RST_I        : in  std_logic;
    STB_I        : in  std_logic;
    WE_I         : in  std_logic;
    ADR_I        : in  std_logic_vector(3 downto 0);
    SEL_I        : in  std_logic_vector(3 downto 0);
    DAT_I        : in  std_logic_vector(31 downto 0);
    DAT_O        : out std_logic_vector(31 downto 0);
    ACK_O        : out std_logic;
    -- Port Pins
    RxD          : in  std_logic;
    TxD          : out std_logic;
    IR_RxD       : out std_logic;
    IR_TxD       : out std_logic
  );
end UART;

library IEEE;
use IEEE.numeric_std.all;

architecture behavioral of UART is
  function UNSIGNED_NUM_BITS (ARG: natural) return natural is
    variable nBits: natural;
    variable N: natural;
  begin
    N := ARG;
    nBits := 1;
    while N>1 loop
      nBits := nBits + 1;
      N := N / 2;
    end loop;
    return nBits;
  end;

  constant Bitanzahl     : integer := 8;
  constant Zaehlerbreite : integer := UNSIGNED_NUM_BITS(Bitbreite);
  
  type RD_Mux_Type is (RD_SEL_nichts, RD_SEL_R, RD_SEL_K, RD_SEL_S);
  
  -- Kombinatorische Signale
  signal RD_Sel          : RD_Mux_Type;
  signal STB_TxD         : std_logic;
  signal STB_K           : std_logic;
  signal RD_Stat         : std_logic;
  signal RD_RxD          : std_logic;
  signal Empfaenger_OK   : std_logic;
  signal Empfaenger_Err  : std_logic;
  signal Empfaenger_Dout : std_logic_vector(Bitanzahl-1 downto 0);
  signal RxD_IrEn        : std_logic;
  signal TxD_OK          : std_logic;
  signal TxD_IrEn        : std_logic;
  signal Status          : std_logic_vector(2 downto 0);
  
  -- Register
  signal Kontroll        : std_logic_vector(1 downto 0) := (1 downto 0=>'0');
  signal RxData          : std_logic_vector(7 downto 0) := (7 downto 0=>'0');
  signal RxD_Err         : std_logic := '0';
  signal RxD_OK          : std_logic := '0';

begin
  Status   <= (0 => TxD_OK, 1 => RxD_OK, 2 => RxD_Err);
  TxD_IrEn <= Kontroll(0);
  RxD_IrEn <= Kontroll(1);
  
  IR_TxD <= TxD_IrEn and TxD_OK;
  IR_RxD <= RxD_IrEn and RxD_OK;
  
  Decoder: process(STB_I,ADR_I,SEL_I,WE_I)
  begin
    -- Default-Werte
    STB_TxD <= '0';
    STB_K   <= '0';
    RD_Stat <= '0';
    RD_RxD  <= '0';
    ACK_O   <= '0';
    RD_Sel  <= RD_SEL_nichts; 
    
    if STB_I='1' and SEL_I="1111" then -- Wortzugriff gefordert
      if WE_I = '1' then -- Schreiben
        case ADR_I is
          when "0000" => STB_TxD <= '1'; ACK_O <= '1'; -- TxData
          when "1000" => STB_K   <= '1'; ACK_O <= '1'; -- Kontroll
          when others => null;
        end case;
      elsif WE_I = '0' then -- Lesen
        case ADR_I is
          when "0100" => RD_Sel <= RD_SEL_R; ACK_O <= '1'; RD_RxD <= '1'; -- RxData
          when "1000" => RD_Sel <= RD_SEL_K; ACK_O <= '1'; -- Kontroll
          when "1100" => RD_Sel <= RD_SEL_S; ACK_O <= '1'; RD_Stat <= '1'; -- Status
          when others => null;
        end case;
      end if;
    end if;
  end process;

  REGs: process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        Kontroll <= (Kontroll'range=>'0');
        RxData   <= (RxData'range=>'0');
        RxD_Err  <= '0';
        RxD_OK   <= '0';
      elsif RST_I /= '0' then
        Kontroll <= (Kontroll'range=>'X');
        RxData   <= (RxData'range=>'X');
        RxD_Err  <= 'X';
        RxD_OK   <= 'X';
      else
        if STB_K='1' then 
          Kontroll <= DAT_I(Kontroll'range);
        end if;
        if RD_Stat='1' then 
          RxD_Err <= '0';
        end if;
        if RD_RxD='1' then 
          RxD_OK  <= '0';
        end if;
        if Empfaenger_Err = '1' then
          RxD_Err <= '1';
        end if;
        if Empfaenger_OK = '1' then
          RxD_OK <= '1';
          RxData <= Empfaenger_Dout;
        end if;
      end if;
    end if;
  end process;
  
  Lesedaten_MUX: process(RD_Sel, RxData, Kontroll, Status)
  begin
    DAT_O <= (DAT_O'range => '0');
    case RD_Sel is
      when RD_SEL_nichts => null;
      when RD_SEL_R  => DAT_O(RxData'range)   <= RxData;
      when RD_SEL_K  => DAT_O(Kontroll'range) <= Kontroll;
      when RD_SEL_S  => DAT_O(Status'range)   <= Status;
    end case;
  end process;
  
  Empfaenger: entity work.UART_Empfaenger
    generic map(
      Bitbreite     => Bitbreite,
      Zaehlerbreite => Zaehlerbreite,
      Bitanzahl     => Bitanzahl
    )
    port map(
      Takt   => CLK_I,
      Reset  => RST_I,
      Din    => RxD,
      OK     => Empfaenger_OK,
      Err    => Empfaenger_Err,
      Dout   => Empfaenger_Dout
    );
    
  Sender: entity work.UART_Sender
    generic map (
      Bitbreite     => Bitbreite,
      Zaehlerbreite => Zaehlerbreite,
      Bitanzahl     => Bitanzahl
    )
    port map (
      Takt   => CLK_I,
      Reset  => RST_I,
      Senden => STB_TxD,
      Wert   => DAT_I(7 downto 0),
      OK     => TxD_OK,
      TxD    => TxD
    );
end behavioral;

