library ieee;
use ieee.std_logic_1164.all;

entity Siebensegment_Anzeige is
    generic (
        MUX_CYCLES : positive := 10000
    );
    port(
        Clk        : in  std_logic;
        -- Eingaenge
        Wert0      : in  std_logic_vector(3 downto 0);
        Dp0        : in  std_logic;
        Wert1      : in  std_logic_vector(3 downto 0);
        Dp1        : in  std_logic;
        Wert2      : in  std_logic_vector(3 downto 0);
        Dp2        : in  std_logic;
        Wert3      : in  std_logic_vector(3 downto 0);
        Dp3        : in  std_logic;
        -- Display
        Seg        : out std_logic_vector(7 downto 0);
        Mux        : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of Siebensegment_Anzeige is

    function to_7seg(digit: in std_logic_vector) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        if    digit = x"0" then seg := "0000001";
        elsif digit = x"1" then seg := "1001111";
        elsif digit = x"2" then seg := "0010010";
        elsif digit = x"3" then seg := "0000110";
        elsif digit = x"4" then seg := "1001100";
        elsif digit = x"5" then seg := "0100100";
        elsif digit = x"6" then seg := "0100000";
        elsif digit = x"7" then seg := "0001111";
        elsif digit = x"8" then seg := "0000000";
        elsif digit = x"9" then seg := "0000100";
        elsif digit = x"A" then seg := "0001000";
        elsif digit = x"B" then seg := "1100000";
        elsif digit = x"C" then seg := "0110001";
        elsif digit = x"D" then seg := "1000010";
        elsif digit = x"E" then seg := "0110000";
        elsif digit = x"F" then seg := "0111000";
                           else seg := "-------";
        end if;          
        return seg;
    end function;

    signal Seg0: std_logic_vector(7 downto 0);
    signal Seg1: std_logic_vector(7 downto 0);
    signal Seg2: std_logic_vector(7 downto 0);
    signal Seg3: std_logic_vector(7 downto 0);
    
begin
    Seg0(7) <= not DP0;
    Seg1(7) <= not DP1;
    Seg2(7) <= not DP2;
    Seg3(7) <= not DP3;

    Seg0(6 downto 0) <= to_7seg(Wert0);
    Seg1(6 downto 0) <= to_7seg(Wert1);
    Seg2(6 downto 0) <= to_7seg(Wert2);
    Seg3(6 downto 0) <= to_7seg(Wert3);
    
    Output_Proc: process is
        variable Mux_v   : std_logic_vector(3 downto 0)      := "0111";
        variable Count_v : integer range 0 to MUX_CYCLES - 1 := MUX_CYCLES - 1;
    begin
        wait until rising_edge(Clk);
        
        if Count_v = MUX_CYCLES - 1 then
        
            Count_v := 0;
            Mux_v   := Mux_v(Mux_v'High - 1 downto 0) & Mux_v(Mux_v'High);
                
        else
        
            Count_v := Count_v + 1;
            
        end if;
        
        case Mux_v is
            when "1110" => Seg <= Seg0;
            when "1101" => Seg <= Seg1;
            when "1011" => Seg <= Seg2;
            when "0111" => Seg <= Seg3;
            when others => Seg <= (others=>'1');
        end case;
        
        Mux <= Mux_v;
        
    end process;  

end architecture;
