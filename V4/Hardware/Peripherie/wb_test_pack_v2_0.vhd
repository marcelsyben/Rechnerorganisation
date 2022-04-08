library ieee;
use ieee.std_logic_1164.all;

package wb_test_pack_v2_0 is

  constant WB_TIMEOUT_CYCLES : positive := 16;
  constant WB_ADR_SIZE       : positive := 32;
  constant WB_DAT_SIZE       : positive := 32;
  constant WB_SEL_SIZE       : positive := WB_DAT_SIZE / 8;

  procedure wait_cycle(
    num_cycles  : in positive := 1;
    signal clk  : in  std_logic
  );
  
  procedure wb_master_init(
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  );  
  
  procedure wb_master_write(
    sel          : in  std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    adr          : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat          : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk   : in  std_logic;       
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal ack_i : in  std_logic;
    signal dat_i : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  );
  
  procedure wb_master_read(
    adr          : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat          : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk   : in  std_logic;       
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal ack_i : in  std_logic;
    signal dat_i : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  );
  
  type wb_mosi_type is record
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    adr : std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat : std_logic_vector(WB_DAT_SIZE - 1 downto 0);
  end record;  
  
  type wb_miso_type is record
    ack : std_logic;
    dat : std_logic_vector(WB_DAT_SIZE - 1 downto 0);
  end record;
  
  procedure wb_master_init(
    signal mosi : out wb_mosi_type
  );  
    
  procedure wb_master_write(
    sel          : in  std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    adr          : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat          : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk   : in  std_logic;       
    signal mosi  : out wb_mosi_type;
    signal miso  : in  wb_miso_type
  );
  
  procedure wb_master_read(
    adr         : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat         : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk  : in  std_logic;       
    signal mosi : out wb_mosi_type;
    signal miso : in  wb_miso_type
  );
      
  type wb_mosi_array_type       is array (natural range <>) of wb_mosi_type;
  type wb_miso_array_type       is array (natural range <>) of wb_miso_type;
    
end package;

package body wb_test_pack_v2_0 is
  
  procedure wait_cycle(
    num_cycles  : in positive := 1;
    signal clk  : in  std_logic
  ) is
  begin
    for i in 0 to num_cycles loop
      wait until rising_edge(clk);
    end loop;
  end procedure;
  
  procedure wb_master_init(
    signal mosi : out wb_mosi_type
  ) is 
  begin
    wb_master_init(
      cyc_o => mosi.cyc,
      stb_o => mosi.stb,
      we_o  => mosi.we,
      sel_o => mosi.sel,
      adr_o => mosi.adr,
      dat_o => mosi.dat
    );
  end procedure;
  
  procedure wb_master_init(
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  ) is
  begin
    cyc_o <= '0';
    stb_o <= '0';
    we_o  <= '-';
    for i in sel_o'range loop
      sel_o(i) <= '-';
    end loop;
    for i in adr_o'range loop
      adr_o(i) <= '-';
    end loop;
  end procedure;
  
  procedure wb_master_write(
    sel          : in  std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    adr          : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat          : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk   : in  std_logic;       
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal ack_i : in  std_logic;
    signal dat_i : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  ) is
    variable timeout_count: positive := 1;
  begin
    cyc_o <= '1';
    stb_o <= '1';
    we_o  <= '1';
    sel_o <= sel;
    adr_o <= adr;
    dat_o <= dat;
    wait until rising_edge(clk);
    
    while ack_i /= '1' loop
      assert timeout_count < WB_TIMEOUT_CYCLES report "Timeout when waiting for ack" severity failure;
      timeout_count := timeout_count + 1;
      wait until rising_edge(clk);
    end loop;
    
    wb_master_init(
      cyc_o => cyc_o,
      stb_o => stb_o,
      we_o  => we_o,
      sel_o => sel_o,
      adr_o => adr_o,
      dat_o => dat_o
    );
  end procedure;

  procedure wb_master_write(
    sel         : in  std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    adr         : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat         : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk  : in  std_logic;       
    signal mosi : out wb_mosi_type;
    signal miso : in  wb_miso_type
  ) is
  begin
    wb_master_write(
      sel   => sel,
      adr   => adr,
      dat   => dat,
      clk   => clk,
      cyc_o => mosi.cyc,
      stb_o => mosi.stb,
      we_o  => mosi.we,
      sel_o => mosi.sel,
      adr_o => mosi.adr,
      dat_o => mosi.dat,
      ack_i => miso.ack,
      dat_i => miso.dat
    );
  end procedure;

  procedure wb_master_read(
    adr         : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat         : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk  : in  std_logic;       
    signal mosi : out wb_mosi_type;
    signal miso : in  wb_miso_type
  ) is
  begin
    wb_master_read(
      adr   => adr,
      dat   => dat,
      clk   => clk,
      cyc_o => mosi.cyc,
      stb_o => mosi.stb,
      we_o  => mosi.we,
      sel_o => mosi.sel,
      adr_o => mosi.adr,
      dat_o => mosi.dat,
      ack_i => miso.ack,
      dat_i => miso.dat
    );
  end procedure;

  procedure wb_master_read(
    adr          : in  std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    dat          : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal clk   : in  std_logic;       
    signal cyc_o : out std_logic;
    signal stb_o : out std_logic;
    signal we_o  : out std_logic;
    signal sel_o : out std_logic_vector(WB_SEL_SIZE - 1 downto 0);
    signal adr_o : out std_logic_vector(WB_ADR_SIZE - 1 downto 0);
    signal dat_o : out std_logic_vector(WB_DAT_SIZE - 1 downto 0);
    signal ack_i : in  std_logic;
    signal dat_i : in  std_logic_vector(WB_DAT_SIZE - 1 downto 0)
  ) is
    variable timeout_count: positive := 1;
  begin
    cyc_o <= '1';
    stb_o <= '1';
    we_o  <= '0';
    adr_o <= adr;
    sel_o <= (WB_SEL_SIZE-1 downto 0=>'1');
    wait until rising_edge(clk);
    
    while ack_i /= '1' loop
      assert timeout_count < WB_TIMEOUT_CYCLES report "Timeout when waiting for ack" severity failure;
      timeout_count := timeout_count + 1;
      wait until rising_edge(clk);
    end loop;

    dat := dat_i;

    wb_master_init(
      cyc_o => cyc_o,
      stb_o => stb_o,
      we_o  => we_o,
      sel_o => sel_o,
      adr_o => adr_o,
      dat_o => dat_o
    );
  end procedure;
end package body;

