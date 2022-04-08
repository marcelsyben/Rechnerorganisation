entity Beispielrechner_System_V4_testbench is
end entity;

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture test of Beispielrechner_System_V4_testbench is

	constant TRACE          : boolean := true;
	constant TRACEFILE      : string  := "trace_sim.txt";
	constant HEXFILE        : string  := "Speicher/Software.hex";
	constant CLKIN_PERIOD   : Real    := 10.0;
    constant CLKMUL         : integer := 12;
    constant CLKDIV         : integer := 20;
    constant SSP_MUX_CYCLES : integer := 60;

    signal START            : std_logic := '0';
    signal STOP             : std_logic := '0';
    signal RESET            : std_logic := '0';
    signal PINS             : std_logic_vector(2 downto 0);
    

    signal SEG              : std_logic_vector(7 downto 0);
    signal MUX              : std_logic_vector(3 downto 0);
    
    signal Anzeige           : string(1 to 2 * MUX'length) := (others=>'-');
    
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

        
        SDI_RXD   => '0',
        SDI_TXD   => open
    );
     
    -- Stimulus process
    stim_proc: process
        procedure pruefe(Erwartet: string) is
        begin
            assert Anzeige(1) = Erwartet(1) report "Minuten falsch. Erwarteter Wert: "    & Erwartet(1) severity failure;   
            assert Anzeige(2) = Erwartet(2) report "Minuten-DP falsch. Erwarteter Wert: " & Erwartet(2) severity failure;   
            assert Anzeige(3) = Erwartet(3) report "Zehner falsch. Erwarteter Wert: "     & Erwartet(3) severity failure;   
            assert Anzeige(4) = Erwartet(4) report "Zehner-DP falsch. Erwarteter Wert: "  & Erwartet(4) severity failure;   
            assert Anzeige(5) = Erwartet(5) report "Einer falsch. Erwarteter Wert: "      & Erwartet(5) severity failure;   
            assert Anzeige(6) = Erwartet(6) report "Einer-DP falsch. Erwarteter Wert: "   & Erwartet(6) severity failure;   
            assert Anzeige(7) = Erwartet(7) report "Zehntel falsch. Erwarteter Wert: "    & Erwartet(7) severity failure;   
            assert Anzeige(8) = Erwartet(8) report "Zehntel-DP falsch. Erwarteter Wert: " & Erwartet(8) severity failure;   
        end procedure;
    begin		
        START <= '0';
        STOP <= '0';
        RESET <= '0';
        wait for 1000 us;
        pruefe("0.0 0.0 ");
        
        report "Uhr starten";
        START <= '1';
        wait for 500 us;        
        START <= '0';               
        wait for 500 us;
        
        pruefe("0.0 0.1 ");
        wait for 1000 us;
        
        pruefe("0.0 0.2 ");
        wait for 1000 us;
               
        report "Uhr anhalten";
        pruefe("0.0 0.3 ");
        STOP <= '1';
        wait for 500 us;          
        STOP <= '0';
        wait for 500 us; 
        
        report "Uhr zuruecksetzen";
        pruefe("0.0 0.3 ");
        RESET <= '1';
        wait for 500 us;         
        RESET <= '0';
        wait for 500 us; 

        pruefe("0.0 0.0 ");    
        report "Test beendet";
        wait;
    end process;
end architecture;