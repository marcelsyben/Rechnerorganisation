entity BTN2TxD_tb is
end BTN2TxD_tb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
architecture test of BTN2TxD_tb is

    constant Taktfrequenz  : natural := 1_000_000;  
    constant Baudrate      : natural := 100_000;
    constant Bitanzahl     : natural := 8;
                           
    signal Takt            : std_logic;
    signal BTN             : std_logic_vector(3 downto 0) := "0000";
    signal TxD             : std_logic;
    signal Empfangen_char  : character;
    
begin

    -- DUT instanzieren
    DUT: entity work.BTN2TxD
    generic map(
        Taktfrequenz => Taktfrequenz,
        Baudrate     => Baudrate
    )
    port map (
        Takt => Takt,
        BTN  => BTN,
        TxD  => TxD
    );

    -- Taktgenerator
    Takt_Gen: process
        constant halbe_periode : time := (1 sec / Taktfrequenz) / 2; 
    begin
        Takt <= '1';
        wait for halbe_periode;
        Takt <= '0';
        wait for halbe_periode;
    end process;

    -- Buttons stimulieren
    Stimulieren: process
    begin
        wait for 50 us;
        for i in 1 to 15 loop
            BTN <= std_logic_vector(to_unsigned(i, 4));    
            wait for 50 us;
        end loop;
        BTN <= std_logic_vector(to_unsigned(0, 4));    
        wait;
    end process;

    Empfangen: process
        variable Empfangen     : unsigned(7 downto 0) := (others=>'0');
        variable Empfangen_hex : string(1 to 2);
        variable Erwartet_hex  : string(1 to 2);
        variable Erfolgreich   : integer := 0;
        constant Bitdauer      : time := 1 sec / Baudrate;
        
        function to_hexstr(u: unsigned) return string is
            constant Conv : string := "0123456789ABCDEF";
            variable r    : string(1 to 2);
        begin
            r(1) := Conv(to_integer(u(7 downto 4)) + 1);
            r(2) := Conv(to_integer(u(3 downto 0)) + 1);
            return r;
        end function;
        
        type Erwartet_t is array (natural range <>) of unsigned(7 downto 0);
        constant Erwartet : Erwartet_t := (x"31", x"32", x"33", x"34", x"35", x"36", x"37", x"38", x"39", x"41", x"42", x"43", x"44", x"45", x"46", x"30");

    begin
    assert Bitanzahl <= 8 report "Bitanzahl zu gross" severity error;
    
    for i in Erwartet'range loop
        Erwartet_hex := to_hexstr(Erwartet(i));
        
        -- Auf Startbit warten
        wait until TxD = '0';
        wait for Bitdauer;
        
        -- Datenbits einlesen 
        for b in 0 to Bitanzahl - 1 loop
            wait for Bitdauer / 2;        
            Empfangen(b) := TxD; -- Datenleitung in der Bitmitte ablesen
            wait for Bitdauer / 2;        
        end loop;
        
        Empfangen_hex  := to_hexstr(Empfangen);
        Empfangen_char <= character'val(to_integer(unsigned(Empfangen)));
        
        -- Stoppbit prüfen
        wait for Bitdauer / 2;        
        if TxD /= '1' then  -- Datenleitung in der Bitmitte ablesen
            report "Stoppbit falsch" severity error; 
        end if;
        wait for Bitdauer / 2;        
        
        if Empfangen = Erwartet(i) then
            report "Empfangen: '" & character'val(to_integer(Empfangen)) & "' (0x" & Empfangen_hex & ")" severity note;
            Erfolgreich := Erfolgreich + 1;
        else        
            report "FEHLER! Empfangen: '" & character'val(to_integer(Empfangen)) & "' (0x" & Empfangen_hex & "), " & "Erwartet: '" & character'val(to_integer(Erwartet(i))) & "' (0x" & Erwartet_hex & ")" severity error;
        end if;
        
    end loop;

    if Erfolgreich = 16 then
        report "Alle erwarteten Werte empfangen" severity note;
    end if;
    wait;
  end process;  
  
end test;
