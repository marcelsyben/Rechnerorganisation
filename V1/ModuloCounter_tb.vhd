--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- Testbench für den Modulozaehler
-- Hochschule Osnabrueck / Bernhard Lang, Rainer Hoeckmann
--------------------------------------------------------------------------------

entity ModuloCounter_tb is
end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture tb of ModuloCounter_tb is
    constant CLK_PERIOD : time      := 10 ns;
    constant N          : integer   := 3;
    constant MAX        : integer   := 5;
    signal   Clk        : std_logic;
    signal   En         : std_logic := '0';
    signal   Q          : std_logic_vector(N-1 downto 0);
    signal   TC         : std_logic;
begin
    uut: entity work.ModuloCounter
    generic map(
        N   => N,
        MAX => MAX
    )
    port map(
        Clk => Clk,
        En  => En,
        Q   => Q,
        TC  => TC
    );

    clk_proc: process
    begin
        Clk <= '0';
        wait for CLK_PERIOD / 2;
        Clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    suv_proc: process
    begin
        wait until falling_edge(Clk);

        report "Aufwaerts zaehlen ..." severity note;
        En <= '1';

        for i in 1 to 3 loop
            wait until falling_edge(Clk);
            assert unsigned(Q) = i report "Falscher Wert fuer Q" severity failure;
            assert TC = '0' report "Falscher Wert fuer TC" severity failure;
        end loop;

        report "Warten ..." severity note;
        En <= '0';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 3 report "Falscher Wert fuer Q" severity failure;
        assert TC = '0' report "Falscher Wert fuer TC" severity failure;

        report "Weiterzaehlen ..." severity note;
        En <= '1';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 4 report "Falscher Wert fuer Q" severity failure;
        assert TC = '0' report "Falscher Wert fuer TC" severity failure;

        wait until falling_edge(Clk);
        assert unsigned(Q) = 5 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        report "Warten ..." severity note;
        En <= '0';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 5 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        report "Weiterzaehlen ..." severity note;
        En <= '1';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 0 report "Falscher Wert fuer Q" severity failure;
        assert TC = '0' report "Falscher Wert fuer TC" severity failure;

        En <= '0';
        
        report "Alle Tests abgeschlossen";
        wait;
    end process;
end architecture;

