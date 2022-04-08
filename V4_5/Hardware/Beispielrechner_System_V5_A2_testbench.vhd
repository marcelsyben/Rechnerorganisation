entity Beispielrechner_System_V5_A2_testbench is
end entity;

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.test_serial.all;

architecture test of Beispielrechner_System_V5_A2_testbench is

	constant TRACE          : boolean := true;
	constant TRACEFILE      : string  := "trace_sim.txt";
	constant HEXFILE        : string  := "Speicher/Software.hex";
	constant CLKIN_PERIOD   : Real    := 10.0;
    constant CLKMUL         : integer := 12;
    constant CLKDIV         : integer := 20;
    constant SSP_MUX_CYCLES : integer := 60;
    constant UART_BAUDRATE  : integer := 115_200;

    signal START            : std_logic := '0';
    signal STOP             : std_logic := '0';
    signal RESET            : std_logic := '0';
    signal PINS             : std_logic_vector(2 downto 0);
    
    signal TXD              : std_logic;
    signal Wert_Tx          : std_logic_vector(7 downto 0) := (others=>'0');
    signal Start_Tx         : std_logic;
    signal RXD              : std_logic := '1';
    signal Start_Rx         : std_logic;
    signal Wert_Rx          : std_logic_vector(7 downto 0) := (others=>'0');

    signal SEG              : std_logic_vector(7 downto 0);
    signal MUX              : std_logic_vector(3 downto 0);
                            
    signal Anzeige          : string(1 to 2 * MUX'length) := (others=>'-');
begin

    Update_Anzeige: process(SEG, MUX)
        function seg_to_char(seg: in std_logic_vector(6 downto 0)) return character is
            variable r: character;
        begin
            case seg is
                when "0000001" => r := '0';
                when "1001111" => r := '1';
                when "0010010" => r := '2';
                when "0000110" => r := '3';
                when "1001100" => r := '4';
                when "0100100" => r := '5';
                when "0100000" => r := '6';
                when "0001111" => r := '7';
                when "0000000" => r := '8';
                when "0000100" => r := '9';
                when "0001000" => r := 'A';
                when "1100000" => r := 'b';
                when "0110001" => r := 'C';
                when "1000010" => r := 'd';
                when "0110000" => r := 'E';
                when "0111000" => r := 'F';
                when others    => r := '?';
            end case;
            return r;
        end function;
    begin
        for i in MUX'reverse_range loop
            if MUX(MUX'length - i - 1) = '0' then
                Anzeige(2 * i + 1) <= seg_to_char(Seg(6 downto 0));
                if    Seg(7) = '0' then Anzeige(2 * i + 2) <= '.';
                elsif Seg(7) = '1' then Anzeige(2 * i + 2) <= ' ';
                else                    Anzeige(2 * i + 2) <= '?';
                end if;
            end if;
        end loop;
    end process;
    
    PINS(0) <= START;
    PINS(1) <= STOP;
    PINS(2) <= RESET;
    
    uut: entity work.Beispielrechner_System
    generic map (
        CLKIN_PERIOD   => CLKIN_PERIOD,
        CLKMUL         => CLKMUL,
        CLKDIV         => CLKDIV,
        SDI_BAUDRATE   => 256_000,
		TRACE          => TRACE,
		TRACEFILE      => TRACEFILE,
        HEXFILE        => HEXFILE,
        SSP_MUX_CYCLES => SSP_MUX_CYCLES
    )
    port map(
        CLKIN     => '-',
        
        PINS      => PINS,

        SEG       => SEG,
        MUX       => MUX,

        TXD       => TXD,
        RXD       => RXD,
        
        SDI_RXD   => '0',
        SDI_TXD   => open
    );
     
    stim_proc: process
        variable c : std_logic_vector(7 downto 0);
    begin		
        wait for 1000 us;
        
        report "Uhr starten";
        c := std_logic_vector(to_unsigned(character'pos('s'), 8));
        Wert_Rx <= c;
        Serial_Transmit (
            Baudrate  => UART_BAUDRATE,
            Parity    => false,
            P_even    => false,
            Stopbits  => 1.0,
            TxD       => RxD,
            Value     => c,
            Start     => Start_Rx
        );
        Wert_Rx <= (others=>'0');
        wait for 3000 us;
        
        report "Uhr anhalten";
        c := std_logic_vector(to_unsigned(character'pos('x'), 8));
        Wert_Rx <= c;
        Serial_Transmit (
            Baudrate  => UART_BAUDRATE,
            Parity    => false,
            P_even    => false,
            Stopbits  => 1.0,
            TxD       => RxD,
            Value     => c,
            Start     => Start_Rx
        );
        Wert_Rx <= (others=>'0');
        wait for 1000 us;

        report "Uhr zuruecksetzen";
        c := std_logic_vector(to_unsigned(character'pos('r'), 8));
        Wert_Rx <= c;
        Serial_Transmit (
            Baudrate  => UART_BAUDRATE,
            Parity    => false,
            P_even    => false,
            Stopbits  => 1.0,
            TxD       => RxD,
            Value     => c,
            Start     => Start_Rx
        );
        Wert_Rx <= (others=>'0');       
        wait;
    end process;

    -- Receive process
    veri_proc: process
        procedure pruefe(Erwartet: string) is
            variable Empfangen: string(Erwartet'range);
        begin
            for i in erwartet'range loop
                -- receive next character
                Serial_Receive (
                  Baudrate  => UART_BAUDRATE,
                  Parity    => false,
                  P_even    => false,
                  RxD       => TxD,
                  Value     => Wert_Tx,
                  Start     => Start_Tx
                );
                Empfangen(i) := character'val(to_integer(unsigned(Wert_Tx)));                
            end loop;
            assert Empfangen = Erwartet report "Falsche Ausgabe";
        end procedure;
    begin
        pruefe("0:00,0" & LF);
        pruefe("0:00,1" & LF);
        pruefe("0:00,2" & LF);
        pruefe("0:00,3" & LF);
        pruefe("0:00,0" & LF);
        report "Test abgeschlossen";
        wait;
    end process;

end architecture;