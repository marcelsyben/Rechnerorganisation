library ieee;
use ieee.std_logic_1164.all;

entity BTN2TxD is
  generic (
    Taktfrequenz : natural := 100_000_000;
    Baudrate     : natural := 115_200
  );
  port (
    Takt : in  std_logic;
    BTN  : in  std_logic_vector(3 downto 0);
    TXD  : out std_logic
  );
end entity;

library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;

architecture arch of BTN2TxD is
  -- Konstanten
  constant Bitanzahl     : natural := 8;
  constant Bitbreite     : natural := (Taktfrequenz / Baudrate);
  constant Zaehlerbreite : natural := 16;
  
  -- Signale
  signal BTN_alt   : std_logic_vector(3 downto 0) := (others=>'0');
  signal BTN_neu   : std_logic_vector(3 downto 0) := (others=>'0');
  signal BTN_ASCII : std_logic_vector(7 downto 0);
  signal Ungleich  : std_logic;
  signal Senden    : std_logic;
  signal Wert      : std_logic_vector(7 downto 0);
  signal OK        : std_logic;
  
begin

  assert 2**Zaehlerbreite-1 >= Bitbreite
    report "Zahlerbreite zu klein gewaehlt"
    severity failure;
    
  -- Prozess fuer Register 1 und 2
  -- ... (VHDL-Code hier ergaenzen)
  Register1_2: process (Takt)
  begin
  	if rising_edge(Takt) then
  		BTN_neu <= BTN;
  		BTN_alt <= BTN_neu;	

  	end if;
  end process;


  -- Vergleicher
  -- ... (VHDL-Code hier ergaenzen)
  Vergleicher: process (BTN_alt, BTN_neu)
  begin
    if BTN_alt /= BTN_neu then
      Ungleich <= '1';
    else
      Ungleich <= '0';
    end if;
  end process;
      

  -- Ueberpruefung der Logikwerte des Vektors BTN_neu
  -- (wird bei der Synthese ignoriert)
  CheckBTN: process (BTN_neu)
    variable check: boolean;  
  begin
    check := true;
    for i in BTN_neu'range loop
      if BTN_neu(i) /= '0' and BTN_neu(i) /= '1' then
        check := false;
        exit; -- loop
      end if;
    end loop;
    assert check report "BTN: nicht zul�ssige Logikwerte" severity warning;
  end process;
  
  -- Kombinatorik: BTN_neu nach ASCII konvertieren
  -- ... (VHDL-Code hier ergaenzen)
  BTN2ASCII: process (BTN_neu)
  begin
    case BTN_neu is
      when "0000" => BTN_ASCII <= x"30";
      when "0001" => BTN_ASCII <= x"31";
      when "0010" => BTN_ASCII <= x"32";
      when "0011" => BTN_ASCII <= x"33";
      when "0100" => BTN_ASCII <= x"34";
      when "0101" => BTN_ASCII <= x"35";
      when "0110" => BTN_ASCII <= x"36";
      when "0111" => BTN_ASCII <= x"37";
      when "1000" => BTN_ASCII <= x"38";
      when "1001" => BTN_ASCII <= x"39";
      when "1010" => BTN_ASCII <= x"41";
      when "1011" => BTN_ASCII <= x"42";
      when "1100" => BTN_ASCII <= x"43";
      when "1101" => BTN_ASCII <= x"44";
      when "1110" => BTN_ASCII <= x"45";
      when "1111" => BTN_ASCII <= x"46";
      when others => null;
    end case;
  end process;
  
  -- Fifo
  Fifo: entity work.DF_Fifo
    generic map ( 
      DataSize    => Bitanzahl,
      AddressSize => 11
    )
    port map (
      -- commons
      Clock     => Takt,
      Reset     => '0',
      -- input side
      valid_in  => Ungleich,
      data_in   => BTN_ASCII,
      ready_in  => open,
      -- output side
      valid_out => Senden,
      data_out  => Wert,
      ready_out => OK
    );
  
  -- UART-Sender
  Sender: entity work.UART_Sender
    generic map (
      Bitbreite     => Bitbreite,
      Zaehlerbreite => Zaehlerbreite,
      Bitanzahl     => Bitanzahl
    )
    port map (
      Takt   => Takt,
      Reset  => '0',
      -- Eingang
      Senden => Senden,
      Wert   => Wert,
      OK     => OK,
      -- Ausgang
      TxD    => TXD
    );
end architecture;