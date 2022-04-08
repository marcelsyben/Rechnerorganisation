library ieee;
use ieee.std_logic_1164.all;

entity Clocking is
    generic (
        CLKIN_PERIOD : real;
        CLKMUL       : integer;
        CLKDIV       : integer
    );
    port (
        clkin  : in  std_logic;
        clkout : out std_logic;
        locked : out std_logic
    );
end entity;

architecture sim of Clocking is 
    constant CLKOUT_PERIOD : time := CLKIN_PERIOD * Real(CLKDIV) / Real(CLKMUL) * 1 ns;
begin
    GenClock: process
    begin
        locked <= '1';
        loop
            clkout <= '0';
            wait for CLKOUT_PERIOD / 2;
            clkout <= '1';
            wait for CLKOUT_PERIOD / 2;
        end loop;
    end process;
end architecture;
