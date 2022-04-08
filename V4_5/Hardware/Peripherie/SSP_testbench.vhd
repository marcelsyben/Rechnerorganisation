---------------------------------------------------------------------------------------------------
-- Testbench zur Komponente "SSP"
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
entity SSP_testbench is
end SSP_testbench;

library IEEE;
use IEEE.std_logic_1164.all;
use work.wb_test_pack_v2_0.all;

architecture test of SSP_testbench is

    constant CLK_PERIOD    : time    := 10 ns;
    constant PRESCALE      : integer := 1;
    
    signal   CLK           : std_logic;
    signal   RST           : std_logic;
    signal   STB           : std_logic;
    signal   WE            : std_logic;
    signal   ADR           : std_logic_vector(31 downto 0);
    signal   SEL           : std_logic_vector(3 downto 0);
    signal   ACK           : std_logic;
    signal   DAT           : std_logic_vector(31 downto 0);
    signal   SSP_DAT       : std_logic_vector(31 downto 0);
    signal   Seg           : std_logic_vector(7 downto 0);
    signal   Mux           : std_logic_vector(3 downto 0);
    
    constant WERT0         : std_logic_vector(31 downto 0) := x"00000000";
    constant WERT1         : std_logic_vector(31 downto 0) := x"00000004";
    constant WERT2         : std_logic_vector(31 downto 0) := x"00000008";
    constant WERT3         : std_logic_vector(31 downto 0) := x"0000000C";
    
    signal Anzeige         : string(1 to 2 * MUX'length) := (others=>'-');
    
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
    
    clk_proc: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    uut: entity work.SSP
        generic map (
            MUX_CYCLES => 1
        )
        port map (
        CLK_I            => CLK,
        RST_I            => RST,
        STB_I            => STB,
        WE_I             => WE,
        SEL_I            => SEL,
        ADR_I            => ADR(3 downto 0),
        ACK_O            => ACK,
        DAT_I            => DAT,
        DAT_O            => SSP_DAT,
        Seg              => Seg,
        Mux              => Mux
        );
  
    stimulate: process
        procedure pruefe(Erwartet: string) is
        begin
            report "Pruefe die Anzeige";
            
            assert Anzeige(1) = Erwartet(1) report "Segment 3: Wert falsch. Erwarteter Wert: " & Erwartet(1) severity failure;   
            assert Anzeige(2) = Erwartet(2) report "Segment 3: DP falsch.   Erwarteter Wert: " & Erwartet(2) severity failure;   
            assert Anzeige(3) = Erwartet(3) report "Segment 2: Wert falsch. Erwarteter Wert: " & Erwartet(3) severity failure;   
            assert Anzeige(4) = Erwartet(4) report "Segment 2: DP falsch.   Erwarteter Wert: " & Erwartet(4) severity failure;   
            assert Anzeige(5) = Erwartet(5) report "Segment 1: Wert falsch. Erwarteter Wert: " & Erwartet(5) severity failure;   
            assert Anzeige(6) = Erwartet(6) report "Segment 1: DP falsch.   Erwarteter Wert: " & Erwartet(6) severity failure;   
            assert Anzeige(7) = Erwartet(7) report "Segment 0: Wert falsch. Erwarteter Wert: " & Erwartet(7) severity failure;   
            assert Anzeige(8) = Erwartet(8) report "Segment 0: DP falsch.   Erwarteter Wert: " & Erwartet(8) severity failure;   
        end procedure;

        variable data: std_logic_vector(SSP_DAT'range);    
    
  begin
    RST <= '1';
    wb_master_init(STB, STB, WE, SEL, ADR, DAT);    
    wait_cycle(2, CLK);
    RST <= '0';
  
  
    report "Schreibe Register (1. Durchgang)" severity note;
            
    wb_master_write("1111", WERT0, x"00000014", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT1, x"00000013", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT2, x"00000002", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT3, x"00000001", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    
    report "Lese Register (1. Durchgang)" severity note;

    wb_master_read(WERT0, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000014" report "falscher Wert aus Register 'Wert 0' zurueckgelesen" severity failure;
    wb_master_read(WERT1, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000013" report "falscher Wert aus Register 'Wert 1' zurueckgelesen" severity failure;
    wb_master_read(WERT2, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000002" report "falscher Wert aus Register 'Wert 2' zurueckgelesen" severity failure;
    wb_master_read(WERT3, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000001" report "falscher Wert aus Register 'Wert 3' zurueckgelesen" severity failure;
    
    pruefe("1 2 3.4.");

    report "Schreibe Register (2. Durchgang)" severity note;
            
    wb_master_write("1111", WERT0, x"00000008", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT1, x"00000007", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT2, x"00000016", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    wb_master_write("1111", WERT3, x"00000015", CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    
    report "Lese Register (2. Durchgang)" severity note;

    wb_master_read(WERT0, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000008" report "falscher Wert aus Register 'Wert 0' zurueckgelesen" severity failure;
    wb_master_read(WERT1, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000007" report "falscher Wert aus Register 'Wert 1' zurueckgelesen" severity failure;
    wb_master_read(WERT2, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000016" report "falscher Wert aus Register 'Wert 2' zurueckgelesen" severity failure;
    wb_master_read(WERT3, data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, SSP_DAT);
    assert data = x"00000015" report "falscher Wert aus Register 'Wert 3' zurueckgelesen" severity failure;
    
    pruefe("5.6.7 8 ");

    report "Test fertig" severity note;    
    wait;    
  end process;
end test;