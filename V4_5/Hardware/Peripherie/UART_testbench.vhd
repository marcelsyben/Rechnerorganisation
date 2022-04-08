---------------------------------------------------------------------------------------------------
-- Testbench zur Komponente "UART"
-- Bernhard Lang
-- (c) Hochschule Osnabrueck
---------------------------------------------------------------------------------------------------
entity UART_testbench is
end UART_testbench;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.wb_test_pack_v2_0.all;

architecture test of UART_testbench is
  constant SYS_FREQUENCY : integer := 12_000_000;
  constant CLK_PERIOD    : time    := (1 sec) / SYS_FREQUENCY;
  constant UART_BAUDRATE : integer := 115_200;  

  signal   CLK           : std_logic;
  signal   RST           : std_logic := '1';
  signal   STB           : std_logic;
  signal   WE            : std_logic;
  signal   ADR           : std_logic_vector(31 downto 0);
  signal   SEL           : std_logic_vector(3 downto 0);
  signal   ACK           : std_logic;
  signal   DAT           : std_logic_vector(31 downto 0);
  signal   UART_DAT      : std_logic_vector(31 downto 0);  
  signal   RxD           : std_logic;
  signal   TxD           : std_logic;
  signal   IR_RxD        : std_logic;
  signal   IR_TxD        : std_logic;
  
  constant TxData        : std_logic_vector(31 downto 0) := x"00000000";
  constant RxData        : std_logic_vector(31 downto 0) := x"00000004";
  constant Kontroll      : std_logic_vector(31 downto 0) := x"00000008";
  constant Status        : std_logic_vector(31 downto 0) := x"0000000C";
begin
  clk_proc: process
    begin
      CLK <= '0';
      wait for CLK_PERIOD / 2;
      CLK <= '1';
      wait for CLK_PERIOD / 2;
    end process;
  
  uut: entity work.UART
    generic map (
      Bitbreite     => SYS_FREQUENCY / UART_BAUDRATE
    )
    port map(
      CLK_I  => CLK,
      RST_I  => RST,
      STB_I  => STB,
      WE_I   => WE,
      ADR_I  => ADR(3 downto 0),
      SEL_I  => SEL,
      ACK_O  => ACK,
      DAT_I  => DAT,
      DAT_O  => UART_DAT,
      RxD    => RxD,
      TxD    => TxD,
      IR_RxD => IR_RxD,
      IR_TxD => IR_TxD
    );

  -- TxD und RxD zum Test zusammenschalten
  RxD <= TxD;
  
  stim_and_verify: process
    variable write_data : std_logic_vector(31 downto 0);
    variable read_data  : std_logic_vector(31 downto 0);
  begin
    RST <= '1';
    wb_master_init(STB, STB, WE, SEL, ADR, DAT);        
    wait_cycle(2, CLK);
    RST <= '0';
    wait_cycle(2, CLK);

    report "Ueberpruefe, dass IR_TxD noch nicht gesetzt ist";
    assert  IR_TxD = '0' report "IR_TxD schon gesetzt" severity failure;
    report "Ueberpruefe, dass IR_RxD noch nicht gesetzt ist";
    assert  IR_RxD = '0' report "IR_RxD schon gesetzt" severity failure;
    
    report "Schreibe Kontroll (0x3)";
    write_data := x"0000000" & x"3";
    wb_master_write(x"f", Kontroll, write_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
    
    report "Lese Status";
    wb_master_read(Status, read_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
    assert read_data(2 downto 0) = "001" report "Falscher Status zurueckgelesen" severity failure;
        
    report "Schreibe TxData (0xaa)";
    write_data := x"000000" & x"aa";
    wb_master_write(x"f", TxData, write_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);

    report "Warte bis IR_RxD gesetzt wird";
    wait on IR_RxD until IR_RxD='1';
    
    report "Lese Status";
    wb_master_read(Status, read_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
    assert read_data(1) = '1' report "Falscher Status zurueckgelesen" severity failure;
    
    report "Lese RxData";
    wb_master_read(RxData, read_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
    assert read_data = x"000000aa" report "Falsche RxData zurueckgelesen" severity failure;
        
    wait until rising_edge(CLK);
        
    report "Ueberpruefe, dass IR_RxD nicht mehr gesetzt ist";
    assert  IR_RxD = '0' report "IR_RxD ist noch gesetzt" severity failure;
    
    wait for SYS_FREQUENCY / UART_BAUDRATE * CLK_PERIOD;
    wait until rising_edge(CLK);
    
    report "Ueberpruefe, dass IR_TxD wieder gesetzt ist";
    assert  IR_RxD = '0' report "IR_TxD ist nicht wieder gesetzt" severity failure;

    report "Schreibe TxData (0x55)";
    write_data := x"000000" & x"55";
    wb_master_write(x"f", TxData, write_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);

    report "Polle Status";
    loop
    wb_master_read(Status, read_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
      if read_data(1) = '1' then exit; end if;
    end loop;
    
    report "Lese RxData";
    wb_master_read(RxData, read_data, CLK, STB, STB, WE, SEL, ADR, DAT, ACK, UART_DAT);
    assert read_data = x"00000055" report "Falsche RxData zurueckgelesen" severity failure;
    
    report "Test fertig";
    wait;
    
  end process;

end architecture;