--------------------------------------------------------------------------------
-- Praktikum Recherorganisation
-- Versuch 1
-- Testbench für den Aufwaerts/Abwaerts-Zaehler
-- Hochschule Osnabrueck / Bernhard Lang, Rainer Hoeckmann
--------------------------------------------------------------------------------

entity UpDownCounter_tb is
end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture tb of UpDownCounter_tb is
    constant CLK_PERIOD : time      := 10 ns;
    constant N          : integer   := 3;
    signal   Clk        : std_logic;
    signal   En         : std_logic := '0';
    signal   Up         : std_logic := '0';
    signal   Q          : std_logic_vector(N-1 downto 0);
    signal   TC         : std_logic;
begin
    uut: entity work.UpDownCounter
    generic map(
        N   => N
    )
    port map(
        Clk => Clk,
        En  => En,
        Up  => Up,
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
        UP <= '1';
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
        for i in 4 to 6 loop
            wait until falling_edge(Clk);
            assert unsigned(Q) = i report "Falscher Wert fuer Q" severity failure;
            assert TC = '0' report "Falscher Wert fuer TC" severity failure;
        end loop;

        wait until falling_edge(Clk);
        assert unsigned(Q) = 7 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        report "Warten ..." severity note;
        En <= '0';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 7 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        report "Abwaerts zaehlen ..." severity note;
        UP <= '0';
        En <= '1';

        for i in 6 downto 4 loop
            wait until falling_edge(Clk);
            assert unsigned(Q) = i report "Falscher Wert fuer Q" severity failure;
            assert TC = '0' report "Falscher Wert fuer TC" severity failure;
        end loop;

        report "Warten ..." severity note;
        En <= '0';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 4 report "Falscher Wert fuer Q" severity failure;
        assert TC = '0' report "Falscher Wert fuer TC" severity failure;

        report "Weiterzaehlen ..." severity note;
        En <= '1';
        for i in 3 downto 1 loop
            wait until falling_edge(Clk);
            assert unsigned(Q) = i report "Falscher Wert fuer Q" severity failure;
            assert TC = '0' report "Falscher Wert fuer TC" severity failure;
        end loop;

        wait until falling_edge(Clk);
        assert unsigned(Q) = 0 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        report "Warten ..." severity note;
        En <= '0';
        wait until falling_edge(Clk);
        assert unsigned(Q) = 0 report "Falscher Wert fuer Q" severity failure;
        assert TC = '1' report "Falscher Wert fuer TC" severity failure;

        En <= '0';

        report "Alle Tests abgeschlossen";
        wait;
    end process;
end architecture;

