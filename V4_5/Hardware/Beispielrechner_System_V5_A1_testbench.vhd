entity Beispielrechner_System_V5_A1_testbench is
end entity;

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.test_serial.all;

architecture test of Beispielrechner_System_V5_A1_testbench is

	constant TRACE          : boolean := true;
	constant TRACEFILE      : string  := "trace_sim.txt";
	constant HEXFILE        : string  := "Speicher/Software.hex";
	constant CLKIN_PERIOD   : Real    := 10.0;
    constant CLKMUL         : integer := 12;
    constant CLKDIV         : integer := 20;
    constant SSP_MUX_CYCLES : integer := 60;
    constant UART_BAUDRATE  : integer := 115_200;
    constant TEST_CHARS     : string  := "OSNA";

    signal   RXD            : std_logic := '1';
    signal   Start_Rx       : std_logic;
    signal   Wert_Rx        : std_logic_vector(7 downto 0);
    signal   TXD            : std_logic;
    signal   Wert_Tx        : std_logic_vector(7 downto 0);
    signal   Start_Tx       : std_logic;

begin
  
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
        
        PINS      => open,

        SEG       => open,
        MUX       => open,

        TXD       => TXD,
        RXD       => RXD,
        
        SDI_RXD   => '0',
        SDI_TXD   => open
    );
     
  -- Stimulus process
    stim_proc: process
        variable c : std_logic_vector(7 downto 0);
    begin		
        wait for 100 us;
        
        for i in TEST_CHARS'range loop
            -- send next character
            c := std_logic_vector(to_unsigned(character'pos(TEST_CHARS(i)), 8));
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
            wait for 700 us;
        end loop;
        wait;
    end process;
  
  -- Verification process
  veri_proc: process
    function to_ascii(i: integer) return character is
      constant conversion : string(1 to 16) := "0123456789ABCDEF";
    begin
      return conversion(i + 1);
    end function;
    
    function HIGH_NIBBLE(n: integer) return integer is
    
    begin
      return (n / 16) mod 16;
    end function;
    
    function LOW_NIBBLE(n: integer) return integer is
    begin
      return n mod 16;
    end function;
    
    variable erwartet : character;
    variable erhalten : character;
  begin		
    for i in TEST_CHARS'range loop
        -- receive next character
        Serial_Receive (
          Baudrate  => UART_BAUDRATE,
          Parity    => false,
          P_even    => false,
          RxD       => TxD,
          Value     => Wert_Tx,
          Start     => Start_Tx
        );
        erwartet := '0';
        erhalten := character'val(to_integer(unsigned(Wert_Tx)));
        assert erhalten = erwartet report "Falsches Zeichen empfangen: '" & erhalten & "' (Erwartet: '" & erwartet & "')" severity failure;
    
        -- receive next character
        Serial_Receive (
          Baudrate  => UART_BAUDRATE,
          Parity    => false,
          P_even    => false,
          RxD       => TxD,
          Value     => Wert_Tx,
          Start     => Start_Tx
        );
        erwartet := 'x';
        erhalten := character'val(to_integer(unsigned(Wert_Tx)));
        assert erhalten = erwartet report "Falsches Zeichen empfangen: '" & erhalten & "' (Erwartet: '" & erwartet & "')" severity failure;
        
        -- receive next character
        Serial_Receive (
          Baudrate  => UART_BAUDRATE,
          Parity    => false,
          P_even    => false,
          RxD       => TxD,
          Value     => Wert_Tx,
          Start     => Start_Tx
        );
        erwartet := to_ascii(HIGH_NIBBLE(character'pos(TEST_CHARS(i))));
        erhalten := character'val(to_integer(unsigned(Wert_Tx)));
        assert erhalten = erwartet report "Falsches Zeichen empfangen: '" & erhalten & "' (Erwartet: '" & erwartet & "')" severity failure;
        
        -- receive next character
        Serial_Receive (
          Baudrate  => UART_BAUDRATE,
          Parity    => false,
          P_even    => false,
          RxD       => TxD,
          Value     => Wert_Tx,
          Start     => Start_Tx
        );
        erwartet := to_ascii(LOW_NIBBLE(character'pos(TEST_CHARS(i))));
        erhalten := character'val(to_integer(unsigned(Wert_Tx)));
        assert erhalten = erwartet report "Falsches Zeichen empfangen: '" & erhalten & "' (Erwartet: '" & erwartet & "')" severity failure;
               
        -- receive next character
        Serial_Receive (
          Baudrate  => UART_BAUDRATE,
          Parity    => false,
          P_even    => false,
          RxD       => TxD,
          Value     => Wert_Tx,
          Start     => Start_Tx
        );
        erwartet := LF;
        erhalten := character'val(to_integer(unsigned(Wert_Tx)));
        assert erhalten = erwartet report "Falsches Zeichen empfangen: '" & erhalten & "' (Erwartet: <LF>)" severity failure;
    end loop;

    report "Test erfolgreich";
    wait;
  end process;
end architecture;